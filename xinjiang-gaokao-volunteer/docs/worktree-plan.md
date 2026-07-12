# Step 9 Git Worktree Plan

## Truth classification
`LOCAL_REPOSITORY_STATUS = UNVERIFIED`

Reason: this ChatGPT execution environment can read Project data-source files under `/mnt/data`, but cannot inspect the user's live Mac repository. The following commands are a verification plan, not completed checks.

## 1. Non-destructive verification — run from repository root

```bash
pwd
git status --short --branch
git branch --show-current
git branch -a
git remote -v
git worktree list
git log --oneline --decorate -n 10

test -d xinjiang-gaokao-volunteer && echo "project dir exists" || echo "project dir missing"
test -d xinjiang-gaokao-volunteer/docs && echo "docs exists" || echo "docs missing"
test -d xinjiang-gaokao-volunteer/.codex/skills && echo "skills exists" || echo "skills missing"

for f in   00-project-master-context.md 00-decision-register.md 00-progress-tracker.md   00-checkpoint-b-report.md 01-prd.md 02-xinjiang-business-rules.md   03-system-architecture.md 04-database-design.md 05-api-contract.md   06-information-architecture.md 07-ui-specification.md; do
  test -f "xinjiang-gaokao-volunteer/docs/$f"     && echo "OK docs/$f"     || echo "MISSING docs/$f"
done
```

If the repository root is already `xinjiang-gaokao-volunteer`, remove that prefix from checks.

## 2. Preconditions

- Preserve any uncommitted work. Do not create worktrees until `git status` is understood.
- Ensure `dev` exists locally/remotely and reflects intended integration baseline.
- Fetch safely: `git fetch --all --prune` (non-destructive to working files).
- Do not use `reset --hard`, `clean -fd`, force push.

## 3. Suggested worktree creation

Assuming current repository root is `My-AI-Code-Project`, project directory is `xinjiang-gaokao-volunteer`, and sibling worktrees should live under `../xjgv-wt`:

```bash
mkdir -p ../xjgv-wt
git fetch --all --prune

git worktree add -b feature/backend-foundation ../xjgv-wt/backend-foundation dev
git worktree add -b feature/mini-program-p0 ../xjgv-wt/mini-program-p0 dev
git worktree add -b feature/admin-web-p0 ../xjgv-wt/admin-web-p0 dev
git worktree add -b feature/data-pipeline-foundation ../xjgv-wt/data-pipeline-foundation dev
```

After first merge barrier, create later sessions from updated `dev`:

```bash
git switch dev
git pull --ff-only origin dev

git worktree add -b feature/database-phase-a ../xjgv-wt/database-phase-a dev
# after database barrier:
git worktree add -b feature/recommendation-core ../xjgv-wt/recommendation-core dev
git worktree add -b feature/ai-commerce-safety ../xjgv-wt/ai-commerce-safety dev
```

If a branch/worktree already exists, stop and inspect `git branch -a` and `git worktree list`; do not recreate blindly.

## 4. Cleanup after merge

Only after branch is merged and worktree has no uncommitted changes:

```bash
git -C ../xjgv-wt/backend-foundation status --short --branch
git worktree remove ../xjgv-wt/backend-foundation
git worktree prune
# delete local feature branch only after merge verification
git branch --merged dev
# then, if listed as merged:
git branch -d feature/backend-foundation
```

Never remove a worktree containing unexplained changes.
