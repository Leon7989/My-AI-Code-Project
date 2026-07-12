# git-workflow

- **Category:** Git / Workflow
- **Status:** Active
- **Step:** 8 / Codex Skills

## Purpose

Coordinate Codex multi-session work with frozen branch strategy, Git worktrees, minimal overlap, traceable commits, and safe handoff.

## When to use

Use for Step 9 sessions, branch/worktree setup, commit/merge planning, conflict handling, or handoff between Codex sessions.

## Inputs

Task slice; current branch; target base; repository status; assigned paths; dependency order.

## Required upstream documents

- `docs/03-system-architecture.md`
- `docs/00-decision-register.md`
- `docs/00-progress-tracker.md`

## Frozen constraints

Branch strategy `main / dev / feature/*`; Step 9 parallelism uses Branch + Git Worktree; monorepo; docs SSOT. Do not rewrite shared history or bypass review semantics.

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

1. Inspect status and base branch before changes.
2. Create one feature branch per task slice from agreed base (normally dev unless project handoff says otherwise).
3. Create dedicated worktree per parallel Codex session.
4. Assign file ownership to minimize overlap; shared contract/docs changes go first or to designated owner.
5. Commit coherent changes with task/skill trace.
6. Rebase/merge only after dependent contract changes land; resolve semantic conflicts via governance, not textual guess.
7. Run validation before handoff.
8. Provide handoff with branch, worktree, commits, changed paths, tests, dependencies, unresolved conflicts.

## Output contract

Git Handoff Record with branch/worktree, base, commit list, file ownership, validation, merge order, and cleanup status.

Every output must also state: changed paths, decisions relied on, tests/validation run, and unresolved risks.

## Validation checklist

- [ ] No direct accidental work on main.
- [ ] Parallel sessions do not share same mutable worktree.
- [ ] Branch names follow feature/* convention.
- [ ] Dirty unrelated files are preserved/not overwritten.
- [ ] Merge order respects contract dependencies.

## Forbidden actions

- Force-pushing shared branch without explicit approval.
- Using one worktree for parallel agents.
- Committing secrets.
- Resolving semantic conflict by taking ours/theirs blindly.

## Escalation / Conflict handling

On semantic merge conflict or overlapping SSOT edits, stop and emit Conflict Report with owning skill/session; do not auto-pick a side.

Conflict handling is fail-explicit: do not silently choose one source. Include conflicting documents/sections, impact, blocking status, and human decision needed.
