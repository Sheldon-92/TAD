---
name: tad-update
description: Safely update TAD in the current project through the shared updater helper. Use when the user wants to update, upgrade, or check the TAD framework version.
---

# TAD Update Command

Update TAD in the current project. This skill delegates exclusively to the shared
updater helper `.tad/scripts/tad-update.sh` — it contains no version comparison,
download, backup, migration, or copy logic of its own.

## Workflow (two commands, one yes)

1. Run the read-only check first:

   ```bash
   /bin/bash .tad/scripts/tad-update.sh --check
   ```

2. Show the check screen to the user verbatim (versions, platforms, what changes, the
   backup, and the "To apply:" line) and ask once whether to update.

3. Only after the user explicitly says yes, run the "To apply" line the check printed,
   exactly as printed (the platform list on it is what the user confirmed):

   ```bash
   /bin/bash .tad/scripts/tad-update.sh --yes --platform <platforms>
   ```

4. Show the update report the run prints (version, platforms, process files, backup,
   report file) to the user verbatim.

## Rules

- Never run `--yes` without an explicit human confirmation in the conversation.
- Never infer consent from a check result, from silence, or from "the update is
  small". If the user declines, do nothing.
- If the helper reports an error, decline, or "confirmation required", report it
  as-is; do not bypass the helper or reimplement its behavior.
- If the check could not determine the platform (the "To apply" line asks you to
  choose), ask the user which platforms to update and forward only their explicit
  answer; never guess one.
- If the helper exits with the non-TTY status, tell the user it requires an
  explicit `--yes` after they approve, or a terminal with a controlling TTY.
