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

4. Show the block from the `TAD update report` line to the end of the output, not the whole log.

5. **After the update**: act on the report's `After this update` block — re-read the files it names with your file-read tool, then tell the human in at most three lines what changed and whether a new session is needed (the block's line for this harness).

## Rules

- Relay the report and stop: an installer hint is not a question to ask.
- Never run `--yes` without explicit human confirmation.
- Report helper output as-is; never bypass or reimplement the helper.
- When the check cannot determine the platform, its "To apply" line asks for a choice:
  forward the user's explicit answer, never invent one.
