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

**Literal send** — safer for complex prompts with special characters:
```bash
tmux -S "$SOCKET" send-keys -t target -l -- "$cmd" && tmux -S "$SOCKET" send-keys -t target Enter
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

## Agent notes
- Gemini CLI (free plan, gemini-3-flash-preview): can take 4+ minutes on research tasks — consider timeout
- Codex: faster and more reliable for active web searches
- For non-interactive Gemini use `--prompt` or `-p` flag

**Why:** without a private socket, agent sessions mix with the user's tmux. Without a state file, context is lost after compression.
**How to apply:** whenever launching 2+ agents in parallel, use private socket + state file.
