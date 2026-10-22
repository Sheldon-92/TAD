---
description: Update the TAD framework in this project. OpenCode support is updater-only — this entrypoint runs the shared updater helper; it does not provide Alex/Blake/Gate roles, hooks, or gate parity.
---

# TAD Update (updater-only)

Run the project's shared updater helper. OpenCode compatibility is updater-only:
this command projects exactly one TAD-owned command and delegates to the same
helper used by Claude Code and Codex. It is not full TAD platform support.

## Workflow (two commands, one yes)

1. Read-only check first:

   ```bash
   /bin/bash .tad/scripts/tad-update.sh --check
   ```

2. Show the check screen to the user verbatim (versions, platforms, what changes, the
   backup, and the "To apply:" line) and ask once whether to update.

3. Only after the user explicitly says yes, run the "To apply" line the check printed,
   exactly as printed:

   ```bash
   /bin/bash .tad/scripts/tad-update.sh --yes --platform <platforms>
   ```

4. Show the update report the run prints to the user verbatim.

## Rules

- Never run `--yes` without explicit human confirmation.
- Report helper output as-is; never bypass or reimplement the helper.
- When the check cannot determine the platform, its "To apply" line asks for a choice:
  forward the user's explicit answer, never invent one.
