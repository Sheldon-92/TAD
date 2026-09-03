---
description: Update the TAD framework in this project. OpenCode support is updater-only — this entrypoint runs the shared updater helper; it does not provide Alex/Blake/Gate roles, hooks, or gate parity.
---

# TAD Update (updater-only)

Run the project's shared updater helper. OpenCode compatibility is updater-only:
this command projects exactly one TAD-owned command and delegates to the same
helper used by Claude Code and Codex. It is not full TAD platform support.

## Workflow (two-step human confirmation boundary)

1. Read-only check first:

   ```bash
   bash .tad/scripts/tad-update.sh --check
   ```

2. Present the result (current version, remote version, update availability,
   backup pattern) to the user verbatim.

3. Only after the user explicitly confirms, run the approved noninteractive path:

   ```bash
   bash .tad/scripts/tad-update.sh --yes
   ```

## Rules

- Never run `--yes` without explicit human confirmation.
- Report helper output as-is; never bypass or reimplement the helper.
- The helper may ask for `--platform claude-code|codex|both` when the installed
  platform is ambiguous — forward the user's explicit choice, never invent one.
