# xinjiang-rules

- **Category:** Domain
- **Status:** Active
- **Step:** 8 / Codex Skills

## Purpose

Implement and review Xinjiang annual admission rules as typed, versioned, auditable rules with explicit conflict handling.

## When to use

Use for exam regime, plan type, subject track, single-column language path, application scope, batch, qualification, subject requirement, program constraint, or policy conflict logic.

## Inputs

Candidate profile versions; admission plan item; RuleSet version; policy snapshot/conflict state; target year; requested rule behavior.

## Required upstream documents

- `docs/02-xinjiang-business-rules.md`
- `docs/01-prd.md`
- `docs/04-database-design.md`
- `docs/00-decision-register.md`

## Frozen constraints

2026 uses `TRADITIONAL_WENLI`; 2027 uses `XJ_3_1_2` architecture reservation; single-column language path is independently modeled; RuleSet versioning and PolicyConflict first-class entity; typed Java rules + versioned metadata; AI cannot decide rules.

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

1. Resolve target exam year and ExamRegime before evaluating rules.
2. Load exact RuleSet and policy state; never infer from current date alone.
3. Evaluate in documented hard-rule order and emit trace with rule/reason/scope.
4. Preserve UNKNOWN states; apply documented block/watch/warning behavior, never coerce to true/false.
5. For OD-010 or active PolicyConflict, use configured conflict semantics and explicit warning/blocking; do not adjudicate.
6. Return structured rule outcome usable by recommendation and audit layers.
7. Add boundary tests for 2026 ordinary/single-column paths and reserved 2027 branches.

## Output contract

Typed rule implementation or rule review with rule code, version, inputs, outcome, trace, policy source/conflict linkage, and tests.

Every output must also state: changed paths, decisions relied on, tests/validation run, and unresolved risks.

## Validation checklist

- [ ] Correct year/regime branch.
- [ ] Single-column language path not collapsed.
- [ ] UNKNOWN preserved.
- [ ] Hard rule cannot be re-added by preference or AI.
- [ ] Policy conflict remains explicit.
- [ ] Trace is deterministic and auditable.

## Forbidden actions

- AI-decided eligibility.
- Inventing official policy.
- Closing OD-010.
- One universal subjectType for 2026/2027.
- Database arbitrary scripts.

## Escalation / Conflict handling

For missing/contradictory official basis, emit Policy Conflict Report and mark behavior blocked or warning per existing rule metadata; never guess.

Conflict handling is fail-explicit: do not silently choose one source. Include conflicting documents/sections, impact, blocking status, and human decision needed.
