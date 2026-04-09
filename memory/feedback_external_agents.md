---
name: External agent invocation conventions
description: Always resume prior session when invoking Codex or Gemini
type: feedback
---

When the user asks to invoke Codex or Gemini, always resume the previous session to preserve context:

- **Codex**: `codex exec resume --last "prompt"`
- **Gemini**: `gemini -r latest -p "prompt"`

Never start a new session when a prior one exists.

**Why:** The user iterates with these agents across multiple turns in the same conversation. Starting fresh loses all prior context and forces re-explanation.

**How to apply:** Any time the user says "tell Codex..." or "ask Gemini...", use the resume form above.
