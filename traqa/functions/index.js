const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { GoogleGenerativeAI } = require('@google/generative-ai');
const Razorpay = require('razorpay');
const crypto = require('crypto');
const { google } = require('googleapis');

admin.initializeApp();
const db = admin.firestore();
const storage = admin.storage();

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });

const razorpay = new Razorpay({
  key_id: process.env.RAZORPAY_KEY_ID,
  key_secret: process.env.RAZORPAY_KEY_SECRET,
});

// ─── PRICING ─────────────────────────────────────────────────────────────────
const PRICES = {
  family_slot_yearly: 5000,       // ₹50 in paise
  tracking_monthly: 5000,         // ₹50 in paise
};

// ─── LANGUAGE NAMES FOR GEMINI PROMPTS ───────────────────────────────────────
const LANG_NAMES = {
  hi: 'Hindi (Hinglish style — casual and warm, use everyday Indian words)',
  ta: 'Tamil (colloquial spoken Tamil, with warmth)',
  bn: 'Bengali (casual Bangla, like talking to a close friend)',
  te: 'Telugu (conversational, like a caring neighbor)',
  mr: 'Marathi (casual Marathi with warmth)',
  gu: 'Gujarati (conversational Gujarati)',
  kn: 'Kannada (friendly spoken Kannada)',
  ml: 'Malayalam (casual, warm Malayalam)',
  pa: 'Punjabi (warm and direct Punjabi)',
  or: 'Odia (friendly conversational Odia)',
  as: 'Assamese (warm conversational Assamese)',
  ur: 'Urdu (soft and caring Urdu)',
  en: 'English (simple Indian English, warm and friendly)',
};

// ─── MAIN REPORT ANALYSIS FUNCTION ───────────────────────────────────────────
exports.analyzeReport = functions
  .runWith({ timeoutSeconds: 120, memory: '512MB' })
  .https.onCall(async (data, context) => {
    if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Login required');

    const { imageBase64Array, pdfBase64, reportType, outputLanguage, memberId, memberName } = data;
    const uid = context.auth.uid;
    const langName = LANG_NAMES[outputLanguage] || LANG_NAMES['en'];

    // Build the Gemini prompt based on report type
    const reportTypePrompts = {
      lab_report: buildLabReportPrompt(langName),
      prescription: buildPrescriptionPrompt(langName),
      general: buildGeneralReportPrompt(langName),
      mri_scan: buildMRIScanPrompt(langName),
      xray: buildXrayPrompt(langName),
      other: buildGeneralReportPrompt(langName),
    };

    const promptText = reportTypePrompts[reportType] || reportTypePrompts.general;

    // Prepare content parts for Gemini (images)
    const parts = [{ text: promptText }];

    if (imageBase64Array && imageBase64Array.length > 0) {
      for (const imgB64 of imageBase64Array) {
        parts.push({
          inlineData: { mimeType: 'image/jpeg', data: imgB64 }
        });
      }
    }

    if (pdfBase64) {
      parts.push({
        inlineData: { mimeType: 'application/pdf', data: pdfBase64 }
      });
    }

    try {
      const result = await model.generateContent(parts);
      const responseText = result.response.text();

      // Parse the structured JSON response
      let parsed;
      try {
        const jsonMatch = responseText.match(/```json\n([\s\S]*?)\n```/);
        parsed = JSON.parse(jsonMatch ? jsonMatch[1] : responseText);
      } catch {
        // Fallback if not valid JSON
        parsed = {
          summary: responseText.substring(0, 500),
          parameters: [],
          medications: [],
          speakableText: responseText.substring(0, 2000),
          aiExplanation: `<div class="explanation">${responseText}</div>`
        };
      }

      // Save to Firestore
      const reportData = {
        memberId: memberId || null,
        memberName: memberName || 'Self',
        reportType,
        outputLanguage,
        summary: parsed.summary || '',
        aiExplanation: parsed.aiExplanation || '',
        speakableText: parsed.speakableText || parsed.summary || '',
        extractedValues: parsed.parameters ?
          Object.fromEntries(parsed.parameters.map(p => [p.name, {
            value: p.value, unit: p.unit, status: p.status
          }])) : {},
        medications: parsed.medications || [],
        reportDate: admin.firestore.FieldValue.serverTimestamp(),
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      const reportRef = await db
        .collection('users').doc(uid)
        .collection('reports').add(reportData);

      return {
        reportId: reportRef.id,
        ...parsed,
      };

    } catch (error) {
      console.error('Gemini error:', error);
      throw new functions.https.HttpsError('internal', 'AI analysis failed: ' + error.message);
    }
  });

// ─── PROMPT BUILDERS ────────────────────────────────────────────────────────
function buildLabReportPrompt(langName) {
  return `You are a compassionate medical educator helping Indian families understand their lab reports.

**ROLE:** Medical Translator for Indian Families
**TONE:** Warm, caring, simple - like explaining to a worried family member in ${langName}
**AUDIENCE:** Often elderly parents, non-medical family members

**TASK:**
1. **EXTRACT** all numerical values, parameters, and their units
2. **INTERPRET** each parameter with simple color coding:
   - 🟢 GREEN: Normal/Good
   - 🟡 YELLOW: Slightly off - "Keep an eye on this"
   - 🔴 RED: Concerning - "Talk to doctor soon"
3. **EXPLAIN** what each test measures in 1 simple sentence
4. **SUMMARIZE** overall health in 2-3 bullet points
5. **RECOMMEND** simple next steps (when to see doctor, lifestyle tips)

**CRITICAL FORMAT REQUIREMENTS:**
- Return ONLY valid JSON wrapped in \`\`\`json ... \`\`\`
- Structure output exactly as specified below
- NEVER include markdown, asterisks, or formatting in the JSON

**JSON OUTPUT FORMAT:**
\`\`\`json
{
  "summary": "2-3 line overall summary in ${langName}",
  "parameters": [
    {
      "name": "Hemoglobin",
      "value": "12.5",
      "unit": "g/dL",
      "normalRange": "12-16 g/dL",
      "status": "normal",
      "explanation": "Simple 1-line explanation in ${langName}"
    }
  ],
  "medications": [
    {
      "name": "Medicine Name",
      "dosage": "500mg",
      "frequency": "Twice daily",
      "purpose": "Simple purpose in ${langName}"
    }
  ],
  "speakableText": "Text optimized for text-to-speech in ${langName} (max 2000 chars)",
  "aiExplanation": "HTML formatted explanation with colors and simple styling for UI display"
}
\`\`\`

**LANGUAGE STYLE GUIDE FOR ${langName.toUpperCase()}:**
- Use everyday conversational language
- Avoid medical jargon - say "blood sugar" not "glucose levels"
- Include warm phrases like "Don't worry", "This is common", "Your body is telling us"
- Use emojis sparingly for emotional connection 🫀❤️🩺
- Speak directly to the family member

Now analyze this medical report and provide the structured JSON output.`;
}

function buildPrescriptionPrompt(langName) {
  return `You are helping an Indian family understand a medical prescription in ${langName}.

**TASK:**
1. Identify all medications with names, dosages, frequencies
2. Explain each medicine's purpose in simple terms
3. Highlight important instructions (with/without food, timing)
4. Note potential side effects to watch for
5. Provide storage instructions if mentioned
6. Create speakable text for audio playback

Return structured JSON as specified for lab reports.`;
}

function buildMRIScanPrompt(langName) {
  return `You are helping an Indian family understand an MRI scan report in ${langName}.

**TASK:**
1. Explain the scan purpose and body part scanned
2. Describe findings in simple anatomical terms
3. Highlight areas of concern with simple explanations
4. Explain medical terms (e.g., "hyperintensity" → "brighter area that might need attention")
5. Provide context on urgency and next steps

Return structured JSON as specified for lab reports.`;
}

function buildXrayPrompt(langName) {
  return `You are helping an Indian family understand an X-ray report in ${langName}.

**TASK:**
1. Explain what the X-ray shows in simple terms
2. Describe any fractures, abnormalities, or findings
3. Use visual metaphors ("like a crack in a teacup", "cloudy area")
4. Explain healing process and timeline if applicable
5. Provide comfort and reassurance

Return structured JSON as specified for lab reports.`;
}

function buildGeneralReportPrompt(langName) {
  return `You are helping an Indian family understand a general medical document in ${langName}.

**TASK:**
1. Extract key information and findings
2. Explain medical terminology in simple language
3. Provide context and importance of the document
4. Suggest next steps if actionable items are present
5. Create reassuring, easy-to-understand explanations

Return structured JSON as specified for lab reports.`;
}

// ─── NOTIFICATION FUNCTIONS ──────────────────────────────────────────────────
exports.sendFamilyNotification = functions.firestore
  .document('users/{userId}/reports/{reportId}')
  .onCreate(async (snapshot, context) => {
    const reportData = snapshot.data();
    const { memberId, memberName, reportType, summary } = reportData;

    if (memberId) {
      // This is a family member's report - notify the family manager
      const familyManagerId = context.params.userId;

      // Get family manager's FCM token
      const userDoc = await db.collection('users').doc(familyManagerId).get();
      const fcmToken = userDoc.data()?.fcmToken;

      if (fcmToken) {
        const message = {
          token: fcmToken,
          notification: {
            title: `${memberName}'s ${reportType} Report Ready`,
            body: summary.substring(0, 100) + '...',
          },
          data: {
            type: 'report_ready',
            reportId: context.params.reportId,
            memberId: memberId,
            click_action: 'FLUTTER_NOTIFICATION_CLICK',
          },
        };

        await admin.messaging().send(message);
      }
    }
  });

// ─── PAYMENT FUNCTIONS ──────────────────────────────────────────────────────
exports.createPaymentOrder = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Login required');

  const { feature, memberId, memberName } = data;
  const uid = context.auth.uid;

  const amount = PRICES[feature];
  if (!amount) throw new functions.https.HttpsError('invalid-argument', 'Invalid feature');

  const order = await razorpay.orders.create({
    amount,
    currency: 'INR',
    notes: { uid, feature, memberId: memberId || '', memberName: memberName || '' },
  });

  // Save pending payment
  await db.collection('users').doc(uid).collection('payments').add({
    razorpayOrderId: order.id,
    feature,
    memberId: memberId || null,
    amountPaise: amount,
    status: 'pending',
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { orderId: order.id, amount, keyId: process.env.RAZORPAY_KEY_ID };
});

// ─── PAYMENT VERIFICATION ────────────────────────────────────────────────────
exports.verifyPayment = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Login required');

  const { razorpayPaymentId, razorpayOrderId, razorpaySignature } = data;
  const uid = context.auth.uid;

  // Verify payment signature
  const generatedSignature = crypto
    .createHmac('sha256', process.env.RAZORPAY_KEY_SECRET)
    .update(razorpayOrderId + '|' + razorpayPaymentId)
    .digest('hex');

  if (generatedSignature !== razorpaySignature) {
    throw new functions.https.HttpsError('invalid-argument', 'Invalid payment signature');
  }

  // Get payment details
  const payment = await razorpay.payments.fetch(razorpayPaymentId);

  if (payment.status !== 'captured') {
    throw new functions.https.HttpsError('failed-precondition', 'Payment not captured');
  }

  // Update payment status and grant feature access
  const paymentsSnapshot = await db
    .collection('users').doc(uid)
    .collection('payments')
    .where('razorpayOrderId', '==', razorpayOrderId)
    .get();

  if (!paymentsSnapshot.empty) {
    const paymentDoc = paymentsSnapshot.docs[0];
    await paymentDoc.ref.update({
      status: 'completed',
      razorpayPaymentId: razorpayPaymentId,
      completedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    const paymentData = paymentDoc.data();
    const { feature, memberId } = paymentData;

    // Grant feature access based on payment type
    if (feature === 'family_slot_yearly') {
      await db.collection('users').doc(uid).update({
        'subscription.familySlots': admin.firestore.FieldValue.increment(1),
        'subscription.familySlotsExpiry': new Date(Date.now() + 365 * 24 * 60 * 60 * 1000),
      });
    } else if (feature === 'tracking_monthly') {
      const updateData = memberId
        ? { ['familyMembers.' + memberId + '.premiumTracking']: true }
        : { 'subscription.premiumTracking': true };

      await db.collection('users').doc(uid).update(updateData);
    }
  }

  return { success: true, paymentId: razorpayPaymentId };
});

// ─── WEBHOOK HANDLER FOR RAZORPAY ─────────────────────────────────────────────
exports.razorpayWebhook = functions.https.onRequest(async (req, res) => {
  // Verify webhook signature
  const razorpaySignature = req.headers['x-razorpay-signature'];
  const expectedSignature = crypto
    .createHmac('sha256', process.env.RAZORPAY_KEY_SECRET)
    .update(JSON.stringify(req.body))
    .digest('hex');

  if (razorpaySignature !== expectedSignature) {
    console.error('Invalid webhook signature');
    return res.status(400).send('Invalid signature');
  }

  const event = req.body.event;
  const payload = req.body.payload;

  try {
    if (event === 'payment.captured') {
      // Handle successful payment capture
      const payment = payload.payment.entity;
      const notes = payment.notes || {};

      if (notes.uid) {
        await db.collection('users').doc(notes.uid).collection('payments').add({
          razorpayOrderId: payment.order_id,
          razorpayPaymentId: payment.id,
          feature: notes.feature,
          memberId: notes.memberId || null,
          amountPaise: payment.amount,
          status: 'completed',
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          completedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        // Grant feature access (same logic as verifyPayment)
        if (notes.feature === 'family_slot_yearly') {
          await db.collection('users').doc(notes.uid).update({
            'subscription.familySlots': admin.firestore.FieldValue.increment(1),
            'subscription.familySlotsExpiry': new Date(Date.now() + 365 * 24 * 60 * 60 * 1000),
          });
        }
      }
    }

    res.status(200).send('Webhook processed');
  } catch (error) {
    console.error('Webhook error:', error);
    res.status(500).send('Error processing webhook');
  }
});

module.exports = exports;