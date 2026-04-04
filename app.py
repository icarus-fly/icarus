import io
import os
import sqlite3
from datetime import datetime

import pdfplumber
from dotenv import load_dotenv
from flask import Flask, jsonify, render_template, request
import google.generativeai as genai

load_dotenv()

app = Flask(__name__)

# ── Gemini setup ────────────────────────────────────────────────────────────
genai.configure(api_key=os.getenv("GEMINI_API_KEY"))
model = genai.GenerativeModel("gemini-1.5-flash")


# ── Database ─────────────────────────────────────────────────────────────────
DB_PATH = "reports.db"

def init_db():
    """Create the reports table if it doesn't exist."""
    conn = sqlite3.connect(DB_PATH)
    conn.execute("""
        CREATE TABLE IF NOT EXISTS reports (
            id          INTEGER PRIMARY KEY AUTOINCREMENT,
            raw_input   TEXT    NOT NULL,
            ai_output   TEXT,
            report_type VARCHAR(50),
            created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)
    conn.commit()
    conn.close()


def save_report(raw_input: str, ai_output: str, report_type: str) -> int:
    """Insert one report row and return the new row id."""
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.execute(
        "INSERT INTO reports (raw_input, ai_output, report_type) VALUES (?, ?, ?)",
        (raw_input, ai_output, report_type),
    )
    row_id = cursor.lastrowid
    conn.commit()
    conn.close()
    return row_id


# ── Helpers ───────────────────────────────────────────────────────────────────
def detect_report_type(text: str) -> str:
    """Guess the report category from keywords in the pasted text."""
    t = text.lower()
    checks = {
        "CBC":             ["hemoglobin", "hgb", "wbc", "rbc", "platelet", "cbc",
                            "hematocrit", "mcv", "mch", "mchc", "neutrophil"],
        "Thyroid":         ["tsh", "t3", "t4", "thyroid", "free t3", "free t4",
                            "triiodothyronine", "thyroxine"],
        "Lipid Panel":     ["cholesterol", "ldl", "hdl", "triglyceride", "lipid",
                            "vldl", "total cholesterol"],
        "Blood Sugar":     ["glucose", "hba1c", "fasting blood sugar", "fbs",
                            "ppbs", "random blood sugar", "rbs", "glycated"],
        "Kidney Function": ["creatinine", "urea", "bun", "gfr", "uric acid",
                            "kidney", "creatine clearance"],
        "Liver Function":  ["sgpt", "sgot", "alt", "ast", "bilirubin", "liver",
                            "alkaline phosphatase", "alp", "albumin", "ggt"],
        "Vitamin Panel":   ["vitamin d", "vitamin b12", "folate", "ferritin",
                            "iron", "b12", "25-oh"],
    }
    for report_type, keywords in checks.items():
        if any(k in t for k in keywords):
            return report_type
    return "General"


GEMINI_PROMPT = """You are a friendly clinical lab educator helping an Indian patient understand
their blood test or pathology report. The patient is NOT a medical professional.

TASK — for every parameter / test value you find in the report:
  1. Write a plain-English sentence explaining what the test measures (no jargon).
  2. State their value and the standard normal range.
  3. Give a status: Normal | Slightly Low | Low | Slightly High | High.
  4. If OUTSIDE range: explain the biology behind it in 1–2 simple sentences
     (do NOT diagnose — only explain the biology).
  5. If within range: a brief, warm reassurance.

FORMAT — output ONLY clean HTML, exactly like this pattern for every parameter:

<div class="param">
  <div class="param-header">
    <span class="param-name">Hemoglobin</span>
    <span class="param-badge normal">Normal</span>
  </div>
  <div class="param-meta">Your value: 13.8 g/dL &nbsp;|&nbsp; Normal range: 12–16 g/dL (female) / 13–17 g/dL (male)</div>
  <div class="param-explanation">Hemoglobin carries oxygen in your red blood cells. Your level is comfortably within the healthy range — good oxygen transport.</div>
</div>

Use these exact badge class names: normal | slightly-low | low | slightly-high | high

After all parameters, always add:
<div class="report-footer">
  <strong>Important:</strong> This is educational information only — not a diagnosis.
  Please discuss your results with your doctor, who knows your complete medical history.
</div>

If the input does not look like a lab report, respond with ONLY:
<div class="not-a-report">
  This does not look like a lab report. Please paste the actual values from your
  blood test — for example: <em>Hemoglobin: 13.5 g/dL, WBC: 7,200 /µL</em>
</div>

LAB REPORT TO DECODE:
{report_text}"""


# ── Routes ────────────────────────────────────────────────────────────────────
@app.route("/")
def index():
    return render_template("index.html")


@app.route("/decode", methods=["POST"])
def decode():
    data = request.get_json(silent=True) or {}
    raw_text = data.get("report_text", "").strip()

    # Basic validation
    if not raw_text:
        return jsonify({"error": "Please paste your lab report first."}), 400
    if len(raw_text) > 6000:
        return jsonify({
            "error": "Report is too long (max 6,000 characters). "
                     "Try pasting just the values table."
        }), 400

    # Call Gemini
    try:
        prompt = GEMINI_PROMPT.format(report_text=raw_text)
        response = model.generate_content(prompt)
        explanation = response.text.strip()

        # Strip markdown code fences if Gemini wraps them
        for fence in ("```html", "```"):
            if explanation.startswith(fence):
                explanation = explanation[len(fence):]
        if explanation.endswith("```"):
            explanation = explanation[:-3]
        explanation = explanation.strip()

    except Exception as exc:
        return jsonify({"error": f"Gemini API error: {exc}"}), 500

    # Save to database
    report_type = detect_report_type(raw_text)
    row_id = save_report(raw_text, explanation, report_type)

    return jsonify({
        "explanation": explanation,
        "report_type": report_type,
        "id": row_id,
    })


# ── PDF extraction ────────────────────────────────────────────────────────────
MAX_PDF_BYTES = 15 * 1024 * 1024  # 15 MB


@app.route("/extract-pdf", methods=["POST"])
def extract_pdf():
    if "pdf" not in request.files:
        return jsonify({"error": "No PDF received."}), 400

    pdf_file = request.files["pdf"]

    if not pdf_file.filename:
        return jsonify({"error": "No file selected."}), 400

    if not pdf_file.filename.lower().endswith(".pdf"):
        return jsonify({"error": "Please upload a .pdf file."}), 400

    pdf_bytes = pdf_file.read()

    if len(pdf_bytes) > MAX_PDF_BYTES:
        return jsonify({"error": "PDF is too large (max 15 MB). Try a smaller file."}), 400

    try:
        text_parts = []

        with pdfplumber.open(io.BytesIO(pdf_bytes)) as pdf:
            for page in pdf.pages:
                # Try table extraction first — lab reports are usually tables
                tables = page.extract_tables()
                if tables:
                    for table in tables:
                        for row in table:
                            if not row:
                                continue
                            # Join cells, skip fully-empty rows
                            cells = [c.strip() if c else "" for c in row]
                            row_str = "  ".join(cells).strip()
                            if row_str:
                                text_parts.append(row_str)
                else:
                    # Fallback: plain text (works for non-table PDFs)
                    plain = page.extract_text()
                    if plain:
                        text_parts.append(plain.strip())

        extracted = "\n".join(text_parts).strip()

        if not extracted:
            return jsonify({
                "error": (
                    "No text found in this PDF — it may be a scanned image. "
                    "Try taking a photo of the report and typing the key values manually, "
                    "or ask your lab for a digital copy."
                )
            }), 422

        # Trim to the app's character limit
        if len(extracted) > 6000:
            extracted = extracted[:6000]

        return jsonify({"text": extracted, "chars": len(extracted)})

    except Exception as exc:
        return jsonify({"error": f"Could not read this PDF: {exc}"}), 500


# ── (Optional) quick stats endpoint — useful for your own market research ────
@app.route("/stats")
def stats():
    conn = sqlite3.connect(DB_PATH)
    rows = conn.execute("""
        SELECT report_type, COUNT(*) as count
        FROM reports
        GROUP BY report_type
        ORDER BY count DESC
    """).fetchall()
    conn.close()
    return jsonify({"totals": [{"type": r[0], "count": r[1]} for r in rows]})


# ── Entrypoint ────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    init_db()
    app.run(debug=True, port=5000)
