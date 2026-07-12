# payment-safety

- **Category:** Safety
- **Status:** Active
- **Step:** 8 / Codex Skills

## Purpose

Protect commerce/payment trust boundaries, Gate-0 status, idempotency, amount verification, provider callback handling, and entitlement granting.

## When to use

Use for order creation, payment attempts, callbacks, polling, reconciliation, refunds, payment UI states, or entitlement grant after payment.

## Inputs

Order/payment request; server order facts; provider notification/query; idempotency key; configured payment capability/Gate-0 state.

## Required upstream documents

- `docs/05-api-contract.md`
- `docs/04-database-design.md`
- `docs/03-system-architecture.md`
- `docs/00-decision-register.md`

## Frozen constraints

OD-007/Gate-0 remains open until human approval. Real payment before Gate-0 is forbidden. Client success is not final success. Server confirms provider fact and amount/order identity before entitlement. Membership/Entitlement/Quota separate.

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

1. Check Gate-0 state before real-provider behavior.
2. Create/replay order and payment attempt using contract idempotency.
3. Derive amount/SKU/order facts server-side.
4. Treat client callback as “confirmation pending” signal only.
5. Verify provider notification signature and/or query provider through adapter when capability exists.
6. Match provider transaction, order, currency/amount, status, and replay state.
7. Persist payment fact and notification idempotently.
8. Grant entitlement only after server-confirmed paid fact, once.
9. Expose polling/status per contract; handle timeout/unknown safely.

## Output contract

Payment state transition with server evidence, idempotency result, entitlement action, audit record, and tests.

Every output must also state: changed paths, decisions relied on, tests/validation run, and unresolved risks.

## Validation checklist

- [ ] Gate-0 respected.
- [ ] No client-trusted amount/status.
- [ ] Callback replay safe.
- [ ] Entitlement granted once.
- [ ] Unknown/timeout not shown as paid.
- [ ] Provider remains adapter/Open Decision compatible.

## Forbidden actions

- Fake enabling real payment.
- `wx.requestPayment` success => final paid.
- Granting membership from client fields.
- Collapsing paid membership and AI quota.

## Escalation / Conflict handling

If real payment is requested while Gate-0 open, block implementation path and report OD-007 gate; stubs/sandbox only if already contractually allowed.

Conflict handling is fail-explicit: do not silently choose one source. Include conflicting documents/sections, impact, blocking status, and human decision needed.
