# Step 10 Codex Session Prompts

These prompts are executable session contracts produced by Step 9. Use one prompt per independent Codex conversation/worktree. Do not merge chat histories.

| Session | Prompt | Branch |
|---|---|---|
| S01 Backend Foundation | `session-foundation.md` | `feature/backend-foundation` |
| S02 Database Phase A | `session-database-core.md` | `feature/database-phase-a` |
| S03 Core Recommendation | `session-recommendation-core.md` | `feature/recommendation-core` |
| S04 Mini Program P0 | `session-mini-program-p0.md` | `feature/mini-program-p0` |
| S05 Admin Web P0 | `session-admin-web-p0.md` | `feature/admin-web-p0` |
| S06 Data Pipeline Foundation | `session-data-pipeline.md` | `feature/data-pipeline-foundation` |
| S07 AI & Commerce Safety | `session-ai-commerce-safety.md` | `feature/ai-commerce-safety` |

First wave: S01, S04, S05, S06 can start after repository verification. S02 starts after S01 merge barrier unless migration infrastructure already exists and is verified. S03 starts after S01 + S02. S07 starts after S01 and waits for DB/API prerequisites as needed.
