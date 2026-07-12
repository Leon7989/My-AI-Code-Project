# 新疆高考 AI 志愿助手 — Codex Skills Index

This directory is the Step 8 executable constraint layer for Codex. It does not replace `docs/`; it operationalizes the approved SSOT into task-scoped Skills.

## Skills

| Skill | Category | Main ownership |
|---|---|---|
| skill-router | Global governance | minimal selection / load order |
| project-governance | Global governance | Frozen/Open decisions, conflicts, SSOT |
| xinjiang-rules | Domain | annual rules and PolicyConflict |
| recommendation-engine | Domain | structured recommendation pipeline |
| data-governance | Domain/Safety | provenance, DataVersion, quality |
| backend-architecture | Coding | Java modular monolith |
| database | Coding/Domain | ER-aligned persistence and Flyway |
| api-contract | Coding | contract-first API/OpenAPI |
| mini-program-ui | UI | WeChat Mini Program |
| admin-web-ui | UI | Admin Web |
| i18n-rtl | UI/Domain | zh-CN/ug-CN/RTL |
| ai-explanation | Safety/Domain | guarded downstream AI explanation |
| payment-safety | Safety | server-truth payment flow |
| testing | Testing | multi-layer verification |
| git-workflow | Git/Workflow | branch + worktree collaboration |

Start with `skill-router/SKILL.md` and `ROUTING.md`; never load all Skills by default.
