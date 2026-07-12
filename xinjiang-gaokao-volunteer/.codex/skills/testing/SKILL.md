# testing

- **Category:** Testing
- **Status:** Active
- **Step:** 8 / Codex Skills

## Purpose

Apply the architecture test strategy and create regression coverage for rules, modules, integrations, API contracts, UI states, safety invariants, and audit semantics.

## When to use

Use for every executable behavior change and every bug fix; mandatory for recommendation/payment/rule/idempotency/profile-version changes.

## Inputs

Changed behavior; owning skill; acceptance criteria; affected invariants; known regression scenario.

## Required upstream documents

- `docs/03-system-architecture.md`
- `docs/02-xinjiang-business-rules.md`
- `docs/05-api-contract.md`
- `docs/07-ui-specification.md`
- `docs/00-decision-register.md`

## Frozen constraints

Testing must validate frozen semantics rather than redefine them. Required strategy layers include rule unit, module, integration, API contract, and frontend component tests where applicable.

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

1. Derive invariants from owning skill and upstream contract.
2. Choose smallest sufficient layers; add more for cross-boundary behavior.
3. Write failing regression test first for bug fixes where practical.
4. Cover positive, negative, UNKNOWN, conflict, replay, and boundary cases.
5. For DB concurrency-sensitive behavior, test duplicate/replay/transaction semantics.
6. For UI, test loading/error/degraded and RTL states when touched.
7. Run targeted tests, then relevant module/contract suite.
8. Report commands and outcomes; do not mark pass without execution evidence.

## Output contract

Test changes plus `Verification Record` listing invariants, layers, commands, pass/fail, and untested residual risk.

Every output must also state: changed paths, decisions relied on, tests/validation run, and unresolved risks.

## Validation checklist

- [ ] Hard-rule negative cases covered.
- [ ] UNKNOWN not Booleanized.
- [ ] Idempotency replay and mismatch covered where relevant.
- [ ] Quota/payment no-double-effect covered.
- [ ] User/Admin separation covered for API changes.
- [ ] RTL covered for direction-sensitive UI.

## Forbidden actions

- Snapshot-only safety testing.
- Deleting failing tests to make build green.
- Mocking away the invariant under test.
- Claiming tests passed when not run.

## Escalation / Conflict handling

If environment prevents execution, state `NOT_RUN` with exact reason and provide static validation only; never fabricate green status.

Conflict handling is fail-explicit: do not silently choose one source. Include conflicting documents/sections, impact, blocking status, and human decision needed.
