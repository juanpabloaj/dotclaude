---
name: Git staging policy
description: Never use git add -A or git add . — always stage files explicitly by name
type: feedback
---

Never use `git add -A` or `git add .` when staging commits. Always stage files explicitly by name (e.g. `git add src/foo.py tests/test_foo.py`).

**Why:** Avoids accidentally including unintended files (e.g. .env, generated files, temporary artifacts).

**How to apply:** Before every commit, list the specific files changed and add them individually.
