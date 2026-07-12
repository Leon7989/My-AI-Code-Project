# api-contract

- **Category:** Coding
- **Status:** Active
- **Step:** 8 / Codex Skills

## Purpose

Keep implementation and clients contract-first against API Contract V1.0, including namespace separation, envelopes, errors, idempotency, and compatibility.

## When to use

Use for endpoints, DTOs, controllers, OpenAPI, client SDK calls, response/error changes, headers, or admin/user boundary work.

## Inputs

Requested API behavior; existing path/schema; affected client/server; compatibility requirement.

## Required upstream documents

- `docs/05-api-contract.md`
- `docs/04-database-design.md`
- `docs/03-system-architecture.md`
- `docs/00-decision-register.md`

## Frozen constraints

User `/api/v1` and Admin `/admin/api/v1` semantics stay separated; callback trust boundary preserved; recommendation idempotency contract preserved; payment server truth preserved; external AI provider hidden behind internal gateway.

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

1. Locate existing endpoint/schema/error namespace in contract.
2. Determine whether change is implementation-only, compatible additive, or breaking.
3. For implementation-only, match exact method/path/header/envelope/status/error semantics.
4. For contract change, edit docs and `openapi.yaml` first, then implementation and clients.
5. Preserve unknown-enum fallback requirement for additive enum values.
6. Add contract tests and ownership/auth tests.
7. Document compatibility impact.

## Output contract

Contract-aligned code plus OpenAPI change when authorized, contract tests, and compatibility note.

Every output must also state: changed paths, decisions relied on, tests/validation run, and unresolved risks.

## Validation checklist

- [ ] No ghost endpoint.
- [ ] No user/admin auth crossover.
- [ ] Headers and status codes match.
- [ ] Error code namespace matches.
- [ ] Idempotent operations honor replay/conflict semantics.
- [ ] Breaking change was not smuggled into code.

## Forbidden actions

- Controller-first reverse documentation.
- Private endpoint invention without contract update.
- Client-selected RuleSet/DataVersion for normal recommendation.
- Exposing AI provider as public contract detail.

## Escalation / Conflict handling

If requested behavior contradicts contract, emit API Contract Conflict; do not pick implementation over SSOT.

Conflict handling is fail-explicit: do not silently choose one source. Include conflicting documents/sections, impact, blocking status, and human decision needed.
