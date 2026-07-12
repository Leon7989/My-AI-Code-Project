# Codex Skill Router / Selection Strategy

## Core rule

Do not load every Skill. Select the smallest sufficient set for the task, then add dependencies only when the change truly crosses boundaries.

## Selection order

1. `skill-router`
2. `project-governance` when semantics, SSOT, decisions, progress, or multiple areas are involved
3. Primary domain or safety skill
4. Contract/architecture/coding skill
5. UI skill if a UI surface is touched
6. `testing` for executable behavior changes
7. `git-workflow` only for branch/worktree/merge/handoff operations

## Routing table

| Task signal | Primary Skill | Typical dependencies |
|---|---|---|
| Decision/SSOT/conflict/progress | project-governance | testing only if executable behavior changes |
| Java module/service/transaction | backend-architecture | domain owner, api-contract, testing |
| Flyway/table/query/MyBatis | database | domain owner, backend-architecture, testing |
| 新疆年度规则/资格/单列类 | xinjiang-rules | recommendation-engine, testing |
| 推荐过滤/评分/分层/幂等/扣次 | recommendation-engine | xinjiang-rules, database, api-contract, testing |
| Endpoint/DTO/OpenAPI/error | api-contract | backend-architecture or UI owner, testing |
| 小程序 route/page/component | mini-program-ui | i18n-rtl, api-contract, testing |
| Admin page/high-risk mutation | admin-web-ui | api-contract, i18n-rtl as needed, testing |
| AI explanation/prompt/gateway | ai-explanation | recommendation-engine, i18n-rtl, testing |
| Order/payment/callback/entitlement | payment-safety | api-contract, database, testing |
| locale/ug-CN/RTL | i18n-rtl | owning UI skill, testing |
| data import/version/provenance | data-governance | database, xinjiang-rules as needed, testing |
| tests/regression/verification | testing | owning implementation/domain skill |
| branch/worktree/merge/handoff | git-workflow | project-governance if SSOT overlap |

## Minimal-loading examples

- Fix an RTL spacing bug: `skill-router + mini-program-ui + i18n-rtl + testing`.
- Add recommendation replay handling: `skill-router + recommendation-engine + api-contract + database + testing`.
- Add Admin DataVersion publish button: `skill-router + admin-web-ui + data-governance + api-contract + testing`.
- Create Step 9 worktrees only: `skill-router + git-workflow`.
- Change a Frozen Decision: `skill-router + project-governance`; stop and escalate.

## Anti-drift rules

- Re-run routing after a material task pivot.
- A loaded skill cannot authorize changes outside its ownership.
- Omitted skills do not waive global Frozen Decisions.
- Cross-cutting safety rules are duplicated only as concise guardrails; domain details stay in their owning skill.
- Session handoff records exact Skills loaded so later sessions can reproduce context.
