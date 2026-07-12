# recommendation-engine

- **Category:** Domain
- **Status:** Active
- **Step:** 8 / Codex Skills

## Purpose

Implement the deterministic structured recommendation pipeline while preserving hard-rule safety, auditability, version pinning, tier/risk separation, and quota idempotency.

## When to use

Use for recommendation creation, filtering, historical comparability, scoring, ranking, tiering, traces, result persistence, replay, or quota consumption.

## Inputs

Candidate and explicit/active profile versions; published RuleSet; required DataVersions; algorithm version; idempotency key; normalized request.

## Required upstream documents

- `docs/02-xinjiang-business-rules.md`
- `docs/04-database-design.md`
- `docs/05-api-contract.md`
- `docs/03-system-architecture.md`
- `docs/00-decision-register.md`

## Frozen constraints

Minimum result fact is AdmissionPlanItem. Pipeline order follows contract. AI is outside core synchronous recommendation. Successful run version refs are immutable. Use request_hash + idempotency_key. Quota ledger dedupes. Tier and Risk separate. No uncalibrated admission probability.

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

1. Authenticate and verify object ownership.
2. Check idempotency scope before expensive execution.
3. Load profile versions; resolve published RuleSet and DataVersions.
4. Canonicalize request and compute request_hash over all contract-required determinants.
5. Execute hard filters in contract order: scope → plan compatibility → batch → special qualification → program constraints.
6. Evaluate historical comparability; preserve NON_COMPARABLE where applicable.
7. Compute risk and preference scores separately; assign tier independently from risk display semantics.
8. Persist request/run/results/traces/snapshot with version pins.
9. Commit quota transaction once using ledger business key; replay returns original result without re-charge.
10. Trigger AI explanation only as downstream optional explanation.

## Output contract

Structured RecommendationRun result with AdmissionPlanItem IDs, tier, risk, traces, pinned versions, requestHash, quota fact, warnings, and tests.

Every output must also state: changed paths, decisions relied on, tests/validation run, and unresolved risks.

## Validation checklist

- [ ] Pipeline order matches API contract.
- [ ] Hard-filtered item never re-enters.
- [ ] Same key+same request replays original result.
- [ ] Same key+different request returns conflict.
- [ ] Failed system/rule/data run does not consume quota.
- [ ] Successful run version refs immutable.
- [ ] No probability masquerade.

## Forbidden actions

- LLM generating official result list directly from score/rank.
- University as recommendation truth grain.
- Preference override of hard rule.
- AI timeout invalidating successful structured run.
- Double quota charge.

## Escalation / Conflict handling

Missing published RuleSet/DataVersion or unresolved blocking PolicyConflict must fail/degrade explicitly using contract codes; never substitute guessed versions.

Conflict handling is fail-explicit: do not silently choose one source. Include conflicting documents/sections, impact, blocking status, and human decision needed.
