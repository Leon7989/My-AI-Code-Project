# i18n-rtl

- **Category:** UI / Domain localization
- **Status:** Active
- **Step:** 8 / Codex Skills

## Purpose

Preserve bilingual `zh-CN` / `ug-CN` behavior, RTL layout correctness, translation-state honesty, and mixed-content safety.

## When to use

Use for any user-visible text, layouts, design tokens, locale APIs, translation review, policy content, or formatting touched by UI work.

## Inputs

Surface; locale; strings; component tree; direction-sensitive styles; translation status.

## Required upstream documents

- `docs/07-ui-specification.md`
- `docs/01-prd.md`
- `docs/03-system-architecture.md`
- `docs/05-api-contract.md`
- `docs/00-decision-register.md`

## Frozen constraints

Both locales supported; ug-CN uses RTL; translation human-review resource OD-008 remains open; translation missing/review state must not be disguised as verified.

Cross-cutting constraints that always apply when relevant:

- Respect every `FROZEN` / `FROZEN FOR P0` / `FROZEN FOR STEP 9` decision in `00-decision-register.md`.
- Keep every Open Decision open unless the human explicitly approves closure.
- `docs/` is SSOT; implementation must not silently redefine product, rules, architecture, database, API, IA, or UI semantics.
- User and Candidate remain separate.
- ExamProfile, EligibilityProfile, and PreferenceProfile remain versioned.
- Eligibility is never reduced to Boolean.
- Recommendation truth unit remains `AdmissionPlanItem`.
- Successful `RecommendationRun` keeps immutable audit semantics and frozen version references.
- Recommendation creation uses `idempotency_key + request_hash`; replay must not double-charge quota.
- Quota uses `QuotaAccount + QuotaLedger`; Membership, Entitlement, and Quota are not collapsed into `user.vip`.
- Payment success is server-confirmed fact, never client assertion.
- User API and Admin API remain separated.
- AI may explain structured facts but may not override Hard Rules.
- No uncalibrated precise admission probability.
- Recommendation Tier (`REACH/MATCH/SAFE/WATCH`) and Risk remain separate concepts.
- Preserve `zh-CN`, `ug-CN`, and RTL behavior.

## Procedure

1. Classify text as static UI, dynamic domain content, policy content, or AI output.
2. Use locale resource/content model; do not duplicate hardcoded branches.
3. Set root direction by locale and use logical CSS/layout properties.
4. Mirror only items approved by UI spec; do not mirror numbers, logos, media controls, or semantics that must remain.
5. Test mixed digits, ranks, scores, dates, Latin abbreviations, and Chinese names inside RTL.
6. Preserve translation missing/review indicators.
7. Add visual/component RTL test for touched components.

## Output contract

Locale-safe UI/content change with translation keys/status, RTL behavior note, and tests.

Every output must also state: changed paths, decisions relied on, tests/validation run, and unresolved risks.

## Validation checklist

- [ ] No zh-CN-only hardcode in bilingual surface.
- [ ] Direction changes at root correctly.
- [ ] Logical spacing used.
- [ ] Mixed numeric content readable.
- [ ] Missing translation not presented as reviewed.

## Forbidden actions

- Global `transform: scaleX(-1)` mirroring.
- Auto-claiming human review.
- Closing OD-008.
- Using color alone for semantics.

## Escalation / Conflict handling

For unreviewed policy translation that affects eligibility/recommendation, surface review status and escalate; do not let translation invent rule meaning.

Conflict handling is fail-explicit: do not silently choose one source. Include conflicting documents/sections, impact, blocking status, and human decision needed.
