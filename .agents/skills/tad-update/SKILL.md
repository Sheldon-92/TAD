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

4. Show the block from the `TAD update report` line to the end of the output (version,
   platforms, project files, holding area, backup, report file, After this update), not the whole log.

5. **After the update**: act on the report's `After this update` block — re-read the files it names with your file-read tool, then tell the human in at most three lines what changed and whether a new session is needed (the block's line for this harness).

## Held backups ("清掉" and "看备份")

Older backups move to a holding area outside the project and are deleted only with the human's yes. Two sentences from the human open the flows below; nothing here runs on its own.

- **"清掉"** (clear held backups): run `/bin/bash .tad/scripts/tad-backups.sh list`, show its output verbatim, give a one-line recommendation (absorb first when any item is flagged for review), ask once, and only on a yes run the `To clear:` line it printed, exactly as printed. Items held for review are never cleared by it.
- **"看备份"** (what the project edited inside TAD files): run `/bin/bash .tad/scripts/tad-backups.sh salvage` and show its output verbatim (it holds no file content). For each `edited` file give the diff file path it printed for the human to open himself, and a one-line recommendation from the path, class and line counts; on a yes for one file run that item's `To absorb:` line exactly as printed. For a held item flagged for review that is not absorbed, offer its `To discard:` line (it needs its own yes). Files printed as having no released TAD file to compare with are named for the human to open himself.
- Both flows: never open or print a diff file or a backup file in the conversation.
- A `--clear-held <token>` on the "To apply" line is part of the same yes: the held backups the check listed under "Will clear" are cleared only after the update succeeded.

## Rules

- Relay the report and stop: an installer hint is not a question to ask.
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
