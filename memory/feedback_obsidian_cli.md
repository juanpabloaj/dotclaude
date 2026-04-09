---
name: Obsidian CLI setup
description: How to use the Obsidian CLI in this environment — wrapper, PATH, validation
type: feedback
---

The Obsidian CLI is available as a wrapper script at `~/.local/bin/obsidian`, which calls `/Applications/Obsidian.app/Contents/MacOS/Obsidian`. A direct symlink does not work — Electron fails to find its helper apps when the executable path doesn't resolve inside the app bundle.

The PATH is set in `~/.zprofile` (added by Obsidian when installing the CLI from the app). `~/.local/bin` is already in the shell PATH, so the wrapper is available without any `source` command.

Validate with: `obsidian eval code="app.vault.getName()"` — should return `general_vault`.

**Why:** symlink breaks Electron's relative lookup for helper apps. Wrapper script calls the binary at its real path, keeping the bundle structure intact.
**How to apply:** use `obsidian <command>` directly. If it fails, verify `~/.local/bin` is in PATH.
