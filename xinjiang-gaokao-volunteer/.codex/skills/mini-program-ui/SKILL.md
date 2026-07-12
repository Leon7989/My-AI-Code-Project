# mini-program-ui

- **Category:** UI
- **Status:** Active
- **Step:** 8 / Codex Skills

## Purpose

Implement the native WeChat Mini Program UI exactly within approved IA/UI core structure and API semantics.

## When to use

Use for `miniprogram/` routes, pages, components, state handling, assessment, recommendation, membership, quota, payment, or user-facing evidence.

## Inputs

Route/page; UI state; API dependencies; locale; acceptance behavior.

## Required upstream documents

- `docs/07-ui-specification.md`
- `docs/06-information-architecture.md`
- `docs/05-api-contract.md`
- `docs/01-prd.md`
- `docs/00-decision-register.md`

## Frozen constraints

Native WeChat Mini Program + TypeScript; approved 4-tab structure; do not mix Admin IA; recommendation card visual focus never changes AdmissionPlanItem truth; free result reach/match/safe display baseline; payment final success only after server confirmation.

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

1. Locate approved route and page state in UI spec/IA.
2. Load i18n-rtl skill for any user-visible text/layout.
3. Map each state to API contract: loading, empty, warning, degraded, retryable, non-retryable.
4. Implement with approved design tokens/components and safe-area/sticky-action rules.
5. Preserve Auth Gate and versioned profile flows.
6. Render tier and risk separately and never as probability.
7. For payment, show confirming after client callback until server-confirmed status.
8. Add component/page tests including RTL where touched.

## Output contract

TypeScript page/component change with route/state mapping, API mapping, locale behavior, and tests.

Every output must also state: changed paths, decisions relied on, tests/validation run, and unresolved risks.

## Validation checklist

- [ ] No new top-level IA capability.
- [ ] No Admin route/component semantics mixed in.
- [ ] AdmissionPlanItem ID remains actionable truth.
- [ ] Tier and risk visually/semantically separate.
- [ ] Warnings/evidence visible as specified.
- [ ] Server truth for payment/quota.

## Forbidden actions

- Showing “82% admission probability”.
- Treating client pay success as final.
- Booleanizing UNKNOWN eligibility.
- Changing 4-tab core navigation ad hoc.
- Hardcoding only Chinese layout.

## Escalation / Conflict handling

Missing IA source or route ambiguity: preserve existing route/core structure and issue IA/UI Conflict rather than invent navigation.

Conflict handling is fail-explicit: do not silently choose one source. Include conflicting documents/sections, impact, blocking status, and human decision needed.
