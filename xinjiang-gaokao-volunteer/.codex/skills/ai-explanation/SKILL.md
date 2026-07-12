# ai-explanation

- **Category:** Safety / Domain
- **Status:** Active
- **Step:** 8 / Codex Skills

## Purpose

Implement AI explanation as a constrained downstream interpretation layer over persisted structured recommendation facts.

## When to use

Use for AI analysis, prompt templates/versions, internal AI gateway, guard logic, AI call logs, explanation UI payloads, or provider adapters.

## Inputs

Persisted RecommendationRun/result/traces; locale; prompt version; allowed evidence; user request; entitlement context.

## Required upstream documents

- `docs/02-xinjiang-business-rules.md`
- `docs/03-system-architecture.md`
- `docs/04-database-design.md`
- `docs/05-api-contract.md`
- `docs/00-decision-register.md`

## Frozen constraints

Internal AI Gateway; Prompt versioning; AI provider remains Open; AI is not data source; AI cannot override Hard Rules; AI is outside core recommendation sync chain; no exact uncalibrated probability.

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

1. Require a successful/persisted structured recommendation or explicitly supported analysis context.
2. Minimize input to necessary structured facts and evidence; avoid raw sensitive data when unnecessary.
3. Resolve prompt version and locale.
4. Apply guard rules before and after model call.
5. Call only through Internal AI Gateway/provider adapter.
6. Validate output against forbidden claims, fabricated facts, rule override, probability language, and unsupported citations.
7. Persist AI call audit metadata as designed; keep provider-specific details internal.
8. On rejection/failure, preserve structured recommendation and return defined guard/failure state.

## Output contract

Guarded explanation payload with promptVersion, source fact references, locale, warnings, guard status, and audit correlation.

Every output must also state: changed paths, decisions relied on, tests/validation run, and unresolved risks.

## Validation checklist

- [ ] Every recommendation claim traceable to structured input.
- [ ] No new plan item invented.
- [ ] No hard rule override.
- [ ] No unsupported official-policy claim.
- [ ] No precise admission probability.
- [ ] Provider choice not leaked into public contract.

## Forbidden actions

- LLM as official data source.
- LLM directly producing formal recommendation list from score/rank.
- Closing OD-003 by selecting provider.
- Suppressing warnings from structured result.

## Escalation / Conflict handling

If requested explanation requires unavailable evidence or policy resolution, return guarded limitation and escalate to governance/policy conflict; never hallucinate.

Conflict handling is fail-explicit: do not silently choose one source. Include conflicting documents/sections, impact, blocking status, and human decision needed.
