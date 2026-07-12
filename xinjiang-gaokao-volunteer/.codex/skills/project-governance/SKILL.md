# project-governance

- **Category:** Global governance
- **Status:** Active
- **Step:** 8 / Codex Skills

## Purpose

Enforce SSOT precedence, Frozen Decision integrity, Open Decision preservation, conflict reporting, and change-control discipline.

## When to use

Use for every task that may alter semantics, contracts, architecture, domain models, project status, or multiple documents.

## Inputs

Task; proposed files; current docs; selected skills; any requested decision change.

## Required upstream documents

- `docs/00-project-master-context.md`
- `docs/00-decision-register.md`
- `docs/00-progress-tracker.md`
- `docs/00-checkpoint-b-report.md`

## Frozen constraints

All decision register statuses are authoritative. `FROZEN` items cannot be changed by Codex. `OPEN`, `GATE-0 OPEN`, `CRITICAL OPEN`, and `REQUIRES_POLICY_RECONCILIATION` remain unresolved.

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

1. Read decision register and current progress state before edits.
2. Classify proposed work as implementation, compatible extension, breaking change, or decision change.
3. Search relevant upstream docs for same concept and compare semantics.
4. If contradiction exists, emit Conflict Report before choosing behavior.
5. Reject unauthorized Frozen Decision changes.
6. For Open Decisions, implement adapters/placeholders only when already allowed by contracts; do not select a vendor/value.
7. After accepted work, update only truthful progress and handoff records.

## Output contract

Governance note with applicable DR/OD IDs, conflicts, allowed change scope, files changed, and unresolved items.

Every output must also state: changed paths, decisions relied on, tests/validation run, and unresolved risks.

## Validation checklist

- [ ] No Frozen Decision overridden.
- [ ] No Open Decision silently closed.
- [ ] Progress reflects actual artifacts.
- [ ] Cross-document conflicts are explicit.
- [ ] No product/architecture redesign hidden in implementation.

## Forbidden actions

- Silent conflict resolution.
- Changing database domain model without approved design change.
- Changing stack or API contract ad hoc.
- Marking work complete without artifact existence and validation.

## Escalation / Conflict handling

Conflict Report fields: ID, severity, documents, conflicting statements, impact, blocking status, allowed temporary behavior, human decision required.

Conflict handling is fail-explicit: do not silently choose one source. Include conflicting documents/sections, impact, blocking status, and human decision needed.
