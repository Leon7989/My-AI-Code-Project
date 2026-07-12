    # Codex Session Prompt — S07 AI & Commerce Safety

    ## Session identity
    You are **S07 / AI & Commerce Safety** in the Xinjiang Gaokao AI Volunteer Assistant monorepo. This is an implementation session under Step 10, not a product/architecture redesign session.

    ## Objective
    在 Gate-0 Open 前仅实现支付接口+Mock/服务端事实边界，并实现 AI Gateway/Guard 骨架；不选 Provider、不激活真实支付。

    ## Git identity
    - Required branch: `feature/ai-commerce-safety`
    - Intended worktree: `../xjgv-wt/ai-commerce-safety`
    - Never commit directly to `main` or `dev`.
    - Before edits run: `git status --short --branch`, `git branch --show-current`, `git log --oneline --decorate -n 10`.
    - Stop if current branch is not `feature/ai-commerce-safety` or worktree has unexplained changes.

    ## Owned scope
    Writable owner scope:
    - `backend/src/main/java/com/xjgaokao/{ai,commerce}/`

    You may create tests adjacent to code you own and minimal build/config files strictly necessary for this scope. Any required edit outside owner scope must be escalated through a Handoff/Conflict Record before editing.

    ## Read-only scope
    - `docs/**`
- `00/Step 9 orchestration artifacts in repository`
- `other sessions owned directories`

    ## Forbidden scope
    - Do not edit `docs/**` SSOT from this implementation session.
    - Do not edit another session's owner directory.
    - Do not redesign DB/API/IA/UI contracts.
    - Do not close any Open Decision.
    - Do not use destructive Git commands (`reset --hard`, `clean -fd`, force push).

    ## Required Skills — minimal loading
    - Primary: `payment-safety`
- Supporting: `ai-explanation`
- Supporting: `api-contract`
- Supporting: `database`
- Supporting: `backend-architecture`
- Supporting: `testing`
- Explicitly not loaded: `mini-program-ui`
- Explicitly not loaded: `admin-web-ui`
- Explicitly not loaded: `data-governance`
- Explicitly not loaded: `xinjiang-rules`

    Load Skills from repository runtime paths under `.codex/skills/<skill>/SKILL.md`. Do not load all 15 Skills. Start with `skill-router`; record the final Selection Record. Re-route only if the task materially pivots.

    ## Required upstream docs
    First read governance baseline:
    - `docs/00-project-master-context.md`
    - `docs/00-decision-register.md`
    - `docs/00-progress-tracker.md`

    Then read only these task-specific upstream documents:
    - `docs/03-system-architecture.md`
- `docs/04-database-design.md`
- `docs/05-api-contract.md`
- `docs/06-information-architecture.md`

    If a required file is missing, stop and emit `SOURCE_AVAILABILITY_CONFLICT`; do not reconstruct it from memory.

    ## Frozen constraints
    - 不修改 Frozen Decisions；Open Decisions 保持 Open。
- User 与 Candidate 分离；Exam/Eligibility/Preference Profile 版本化；Eligibility 非 Boolean。
- Recommendation 最小真值单位为 AdmissionPlanItem；成功 RecommendationRun 保持不可变审计语义。
- 推荐创建保持 idempotency_key + request_hash；QuotaAccount + QuotaLedger 防重复扣次。
- Membership、Entitlement、Quota 不合并为 user.vip。
- 支付成功只信服务端确认；Gate-0 未关闭不得接真实支付。
- User API `/api/v1/**` 与 Admin API `/admin-api/v1/**` 分离。
- zh-CN / ug-CN / RTL 保留。
- 不输出未经校准精确录取概率；Tier 与 Risk 分离。
- AI 不突破 Hard Rules，不作为 Eligibility 或正式 Recommendation 结构化结果真值来源。

    ## Task procedure
    1. Verify Git branch/worktree status non-destructively.
    2. Read `skill-router`, select the minimum Skills above, and output a `Skill Selection Record` before coding.
    3. Read governance baseline and task-specific SSOT sections; do not paste whole documents into working context.
    4. Inventory existing files in owned scope and detect pre-existing changes.
    5. Produce a small implementation plan mapped to existing contracts; identify any dependency on another session.
    6. Implement only owned scope in small coherent commits.
    7. Add/update tests for executable behavior.
    8. Run the narrowest relevant validation first, then package-level/build validation where available.
    9. Review `git diff --check`, `git status --short`, and changed-file ownership before handoff.
    10. Emit the required Handoff Record; do not merge yourself unless explicitly instructed.

    ## Validation
    Minimum:
    - No changed file outside owned scope except explicitly approved shared build file.
    - `git diff --check` passes.
    - Relevant unit/component tests pass, or failure is recorded with exact command/output summary.
    - No Frozen Decision override.
    - No API/DB/IA/UI semantic drift.
    - Open Decisions remain open.

    ## Output contract
    Return:
    1. `Skill Selection Record`
    2. `Baseline/SSOT Read Record` (filenames + relevant sections only)
    3. `Changed Files`
    4. `Validation Commands and Results`
    5. `Known Risks / Unresolved Dependencies`
    6. `Handoff Record`
    7. `READY_FOR_REVIEW = YES|NO`

    ## Handoff requirements
    Handoff must include session id, branch, base commit, head commit, owned files changed, tests, SSOT assumptions, API/DB dependencies, unresolved conflicts, and recommended merge prerequisite.

    ## Stop / escalation conditions
    Stop without guessing when:
    - SSOT documents conflict materially;
    - implementation requires changing Frozen Decision;
    - API change is needed but not already in `05-api-contract.md`;
    - DB model change is needed but not already in `04-database-design.md`;
    - UI route/core structure change is needed but not already in IA/UI SSOT;
    - another session owns the required file;
    - Open Decision must be closed to proceed;
    - repository/worktree state is unsafe or ambiguous.

    Emit a typed Conflict Record (`SSOT_CONFLICT`, `API_CONFLICT`, `DB_CONFLICT`, `UI_OWNERSHIP_CONFLICT`, `RULE_CONFLICT`, `GIT_CONFLICT`, or `TEST_CONFLICT`) and stop the affected change only.
