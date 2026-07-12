# skill-router

- **Category:** Global governance
- **Status:** Active
- **Step:** 8 / Codex Skills

## Purpose

Select the smallest sufficient set of project skills for a Codex task, order them by dependency, and prevent unnecessary context loading or rule drift.

## When to use

Use at the start of every Codex session, after a material task pivot, or when the requested change spans more than one bounded area.

## Inputs

Task statement; target paths; intended deliverable; current branch/worktree; any referenced issue or acceptance criteria.

## Required upstream documents

- `docs/00-project-master-context.md`
- `docs/00-decision-register.md`
- `docs/00-progress-tracker.md`
- `docs/00-checkpoint-b-report.md`

## Frozen constraints

Do not reinterpret domain facts. Router only selects skills. Never close Open Decisions, invent missing source facts, or treat an omitted skill as permission to violate its constraints.

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

1. Normalize the task into one primary capability and zero or more secondary capabilities.
2. Read `00-decision-register.md` first; identify applicable Frozen/Open decisions.
3. Map target paths and requested behavior to the routing table in `ROUTING.md`.
4. Load exactly one primary skill when possible; add dependency skills only for actual cross-boundary effects.
5. Apply dependency order: governance → domain/safety → contract/architecture → UI/coding → testing → git workflow.
6. If task changes meaningfully, reroute before editing more files.
7. Record selected skills and reasons in the session work note or final handoff.

## Output contract

A `Skill Selection Record` containing task class, primary skill, dependency skills, excluded skills, source documents to read, and escalation status.

Every output must also state: changed paths, decisions relied on, tests/validation run, and unresolved risks.

## Validation checklist

- [ ] Selection is minimal but sufficient.
- [ ] Every touched bounded area has an owning skill.
- [ ] Safety-critical recommendation/payment/AI changes load the corresponding safety/domain skill.
- [ ] Testing skill is loaded for executable behavior changes.
- [ ] Git workflow skill is loaded only for branch/worktree/merge/handoff operations.

## Forbidden actions

- Loading all skills by default.
- Using router as a substitute for domain rules.
- Silently continuing after a cross-document conflict.
- Assuming missing documents or Open Decisions.

## Escalation / Conflict handling

On ambiguous ownership, choose the narrower owner plus `project-governance`. On cross-document contradiction, stop semantic choice and emit a Conflict Report.

Conflict handling is fail-explicit: do not silently choose one source. Include conflicting documents/sections, impact, blocking status, and human decision needed.
