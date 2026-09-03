---
name: tad-update
description: Safely update TAD in the current project through the shared updater helper. Use when the user wants to update, upgrade, or check the TAD framework version.
---

# TAD Update Command

Update TAD in the current project. This skill delegates exclusively to the shared
updater helper `.tad/scripts/tad-update.sh` — it contains no version comparison,
download, backup, migration, or copy logic of its own.

## Workflow (two-step human confirmation boundary)

1. Run the read-only check first:

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

- Never run `--yes` without an explicit human confirmation in the conversation.
- Never infer consent from a check result, from silence, or from "the update is
  small". If the user declines, do nothing.
- If the helper reports an error, decline, or "confirmation required", report it
  as-is; do not bypass the helper or reimplement its behavior.
- If the helper exits with the non-TTY status, tell the user it requires an
  explicit `--yes` after they approve, or a terminal with a controlling TTY.