---
name: firebase-firestore-enterprise-native-mode
description: Comprehensive guide for Firestore enterprise native including provisioning, data model, security rules, and SDK usage. Use this skill when the user needs help setting up Firestore Enterprise with the Native mode, writing security rules, or using the Firestore SDK in their application.
compatibility: This skill is best used with the Firebase CLI, but does not require it. Firebase CLI can be accessed through `npx -y firebase-tools@latest`.
---

# Firestore Enterprise Native Mode

This skill provides a complete guide for getting started with Firestore Enterprise Native Mode, including provisioning, data model, security rules, and SDK usage.

## Provisioning

To set up Firestore Enterprise Native Mode in your Firebase project and local environment, see [provisioning.md](references/provisioning.md).

## Data Model

To learn about Firestore data model and how to organize your data, see [data_model.md](references/data_model.md).

## Security Rules

For guidance on writing and deploying Firestore Security Rules to protect your data, see [security_rules.md](references/security_rules.md).

## SDK Usage

To learn how to use Firestore Enterprise Native Mode in your application code, see:
- [Web SDK Usage](references/web_sdk_usage.md)
- [Python SDK Usage](references/python_sdk_usage.md)

## Indexes

Indexes help improve query performance and speed up slow queries. For checking index types, query support tables, and best practices, see [indexes.md](references/indexes.md).

## Vault Connections

**Thinking Chronology Phase:** Phase 5 (Defense — data moat), Phase 6 (Architecture — enterprise infrastructure).

**Vault connections:**
- `[[SCALABILITY PLAN]]` — Enterprise mode exists because Traqa will outgrow standard. Enterprise features (strong consistency, multi-region, higher throughput) are required for healthcare-scale data.
- `[[TECHNOLOGY BRAIN]]` — Advanced data infrastructure. The decision between standard vs enterprise is a technology brain decision that affects cost, performance, and architecture for years.
- `[[NON- NEGOTIABLES]]` — Healthcare data compliance demands enterprise-grade security and data integrity guarantees.
- `[[Bezos (Amazon)]]` — Enterprise infrastructure that survives billion-dollar scale without breaking. Invest in architecture now to avoid rebuilding later.
- `[[Michael Porter]]` — Enterprise data capabilities as a competitive moat. Most health startups use basic storage; enterprise-grade data infrastructure is a defensible advantage.

**Customization:** "Run firestore-enterprise without Porter."
