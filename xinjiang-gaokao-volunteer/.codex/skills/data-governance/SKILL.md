# data-governance

- **Category:** Domain / Safety
- **Status:** Active
- **Step:** 8 / Codex Skills

## Purpose

Protect provenance, versioning, quality state, publication gates, and non-fabrication of admissions/policy data.

## When to use

Use for data imports, offline pipeline, DataVersion, provenance, quality issues, object files, publication, historical datasets, or source metadata.

## Inputs

Dataset/source; target DataVersion type/year; import job; provenance; quality checks; publication intent.

## Required upstream documents

- `docs/04-database-design.md`
- `docs/03-system-architecture.md`
- `docs/02-xinjiang-business-rules.md`
- `docs/05-api-contract.md`
- `docs/00-decision-register.md`

## Frozen constraints

OD-009 data source/authorization remains CRITICAL OPEN. AI is not a data source. Admission plan/history/control line/subject requirements keep independent versions. Python is offline pipeline only. Recommendation pins exact versions.

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

1. Identify dataset type, year, grain, source, license/authorization state, and intended environment.
2. Ingest through offline pipeline; preserve raw object/source linkage.
3. Create/import into a new DataVersion rather than mutating published facts in place.
4. Run schema, uniqueness, range, referential, grain, and cross-source checks.
5. Record DataQualityIssue for failures/ambiguity.
6. Block or warn publication according to existing status rules; high-risk publish uses Admin contract.
7. Never label unverified/synthetic data as official production truth.
8. After publish, ensure recommendation resolver can pin exact version.

## Output contract

DataVersion/import result with provenance, authorization status, quality summary, issues, publication state, and reproducibility metadata.

Every output must also state: changed paths, decisions relied on, tests/validation run, and unresolved risks.

## Validation checklist

- [ ] Source/provenance present.
- [ ] Authorization uncertainty explicit.
- [ ] Grain explicit.
- [ ] Independent version category preserved.
- [ ] Published data not silently mutated.
- [ ] Synthetic fixtures clearly labeled non-production.

## Forbidden actions

- Fabricating official data source.
- Using LLM output as admissions facts.
- Closing OD-009.
- Python online recommendation service.
- Overwriting historical published version in place.

## Escalation / Conflict handling

Missing authorization or contradictory source facts: keep OD-009/open issue explicit, block production claim/publication as required, and issue Data Provenance Conflict.

Conflict handling is fail-explicit: do not silently choose one source. Include conflicting documents/sections, impact, blocking status, and human decision needed.
