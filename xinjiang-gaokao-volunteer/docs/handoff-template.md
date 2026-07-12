# Standard Codex Handoff Template

```yaml
handoff_version: 1
session_id: Sxx
session_name: ""
branch: feature/...
worktree: ../xjgv-wt/...
base_commit: ""
head_commit: ""
primary_skill: ""
supporting_skills: []
explicitly_not_loaded_skills: []
ssot_read:
  - file: docs/...
    sections: []
owned_scope: []
changed_files: []
shared_files_changed: []
validation:
  - command: ""
    result: PASS|FAIL|NOT_RUN
    note: ""
contract_dependencies:
  api: []
  db: []
  ui: []
  rules: []
open_decisions_touched: []
frozen_decisions_touched: []
unresolved_conflicts: []
known_risks: []
merge_prerequisites: []
recommended_next_session: []
ready_for_review: true|false
```

Rules: no chat-history dependency; list concrete commits/files/tests; never claim PASS for an unrun command; any Frozen/Open semantic issue becomes a typed Conflict Record.
