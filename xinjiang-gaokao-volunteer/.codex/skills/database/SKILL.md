# database

- **Category:** Coding / Domain persistence
- **Status:** Active
- **Step:** 8 / Codex Skills

## Purpose

Implement schema, query, migration, and persistence changes strictly within Database ER V1.0 and its staged rollout.

## When to use

Use for Flyway migrations, MySQL schema/index/query work, MyBatis mappings, persistence constraints, or data-version references.

## Inputs

Entity/table requirement; query use case; target phase; API/domain semantics; performance evidence if optimizing.

## Required upstream documents

- `docs/04-database-design.md`
- `docs/03-system-architecture.md`
- `docs/02-xinjiang-business-rules.md`
- `docs/00-decision-register.md`

## Frozen constraints

Do not redesign the domain model. Keep User/Candidate separation, versioned profiles, non-Boolean eligibility, AdmissionPlanGroup, AdmissionPlanItem recommendation grain, explicit history Grain, independent DataVersions, immutable successful RecommendationRun references, QuotaAccount+QuotaLedger.

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

1. Map requested behavior to existing logical table(s) and schema phase.
2. Verify keys, unique constraints, statuses, version references, and audit fields in DB design.
3. Prefer compatible migration; never mutate historical successful-run facts.
4. Use Flyway with forward migration naming and deterministic SQL.
5. For complex SQL, use handwritten/XML mapping as architecture allows.
6. Check concurrency for idempotency/quota/payment publishing operations.
7. Add index only from query pattern and cardinality rationale; avoid speculative indexing.
8. Add migration and persistence tests.

## Output contract

Flyway migration and/or persistence change with mapped ER sections, invariant notes, rollback/forward-fix strategy, and query tests.

Every output must also state: changed paths, decisions relied on, tests/validation run, and unresolved risks.

## Validation checklist

- [ ] No duplicate competing entity introduced.
- [ ] Eligibility status preserves multi-state semantics.
- [ ] Profile updates create versions when required.
- [ ] Recommendation success references remain immutable.
- [ ] Unique constraints support idempotency and ledger dedupe.
- [ ] No DB-executed arbitrary SpEL/Groovy/JavaScript.

## Forbidden actions

- Re-modeling 64-table logical design ad hoc.
- Adding `user.vip`.
- Replacing ledger with mutable counter-only semantics.
- Boolean eligibility shortcut.
- Changing recommendation grain to University.

## Escalation / Conflict handling

If use case cannot fit existing ER without semantic change, issue DB Model Conflict and wait for explicit design approval.

Conflict handling is fail-explicit: do not silently choose one source. Include conflicting documents/sections, impact, blocking status, and human decision needed.
