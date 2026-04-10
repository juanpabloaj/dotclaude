---
name: tmux multi-agent patterns
description: Patterns for orchestrating multiple AI agents (Claude, Codex, Gemini) with tmux
type: feedback
---

No additional plugins are needed to orchestrate agents with tmux. Native tmux is sufficient.

## Key patterns (from mitsuhiko/agent-stuff skills/tmux/SKILL.md)

**Private socket** — keep agent sessions separate from the user's personal tmux:
```bash
SOCKET="${TMPDIR:-/tmp}/claude-tmux-sockets/claude.sock"
mkdir -p "${TMPDIR:-/tmp}/claude-tmux-sockets"
tmux -S "$SOCKET" new -d -s "descriptive-name"
```

**Literal send** — safer for complex prompts with special characters. Always send Enter as a separate command — `-l` pastes text but does not submit it. Add `sleep 1` between the message and the Enter to ensure the terminal has processed the text before submitting:
```bash
tmux -S "$SOCKET" send-keys -t target -l -- "$cmd"
sleep 1
tmux -S "$SOCKET" send-keys -t target Enter
```

**Clean capture** — use `-J` to join lines split by terminal width:
```bash
tmux -S "$SOCKET" capture-pane -p -J -t target -S -200
```

**Always give the user a monitor command** right after launching an agent:
```
tmux -S "$SOCKET" attach -t session-name
```

**Session state** — to recover context after compression:
```bash
tmux -S "$SOCKET" list-sessions
tmux -S "$SOCKET" list-panes -a
```

## State file for multi-agent sessions
Before launching complex sessions, write a state file to disk:
```
# /tmp/tmux_agents_state.md
- pane 0:0.0 → codex | task: X | status: running
- pane 0:0.1 → gemini | task: Y | status: done
```

## Detecting when an agent is done
Poll with `capture-pane -p -J` and check for absence of `Working` in the output, or presence of the input prompt `›`.

## Agent notes
- Codex: faster and more reliable for active web searches and filesystem exploration
- For non-interactive Gemini use `--prompt` or `-p` flag

**Why:** without a private socket, agent sessions mix with the user's tmux. Without a state file, context is lost after compression.
**How to apply:** whenever launching 2+ agents in parallel, use private socket + state file.
