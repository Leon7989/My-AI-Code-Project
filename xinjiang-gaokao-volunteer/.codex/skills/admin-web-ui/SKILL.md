# admin-web-ui

- **Category:** UI
- **Status:** Active
- **Step:** 8 / Codex Skills

## Purpose

Implement Vue Admin Web operations within approved admin IA/UI, with high-risk mutation safeguards and strict separation from Mini Program UX.

## When to use

Use for `admin-web/` pages/components including PolicyConflict, DataVersion, recommendation audit, prompt, translation review, commerce/payment operations.

## Inputs

Admin route; mutation/read use case; API endpoint; role/permission context; locale needs.

## Required upstream documents

- `docs/07-ui-specification.md`
- `docs/06-information-architecture.md`
- `docs/05-api-contract.md`
- `docs/03-system-architecture.md`
- `docs/00-decision-register.md`

## Frozen constraints

Vue 3 + TypeScript + Vite + Element Plus baseline. Admin API remains separate. PolicyConflict is first-class. High-risk mutations use confirmation/reason/typed confirmation where specified. Open Decisions remain open.

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

1. Locate approved admin route and corresponding Admin API.
2. Classify operation as read, normal mutation, or high-risk mutation.
3. Use approved table/filter/pagination/status patterns.
4. For high-risk changes, implement confirmation, typed confirmation and reason per UI/contract.
5. Keep evidence/version/audit metadata visible.
6. Load i18n-rtl for bilingual or translation-review surfaces.
7. Add component and contract-mocking tests.

## Output contract

Vue page/component with Admin API mapping, risk classification, permission/error states, audit UX, and tests.

Every output must also state: changed paths, decisions relied on, tests/validation run, and unresolved risks.

## Validation checklist

- [ ] No user API called as Admin substitute.
- [ ] No Mini Program IA mixed in.
- [ ] Policy conflict resolution not silently automated.
- [ ] Publish actions show exact version/status.
- [ ] High-risk mutation protections present.

## Forbidden actions

- Using client-only success as system truth.
- Closing policy/open decisions through UI defaults.
- Inventing admin endpoints.
- Removing audit reason for high-risk changes.

## Escalation / Conflict handling

If required operation lacks Admin API contract, emit Contract Gap; do not call user endpoints or invent path.

Conflict handling is fail-explicit: do not silently choose one source. Include conflicting documents/sections, impact, blocking status, and human decision needed.
