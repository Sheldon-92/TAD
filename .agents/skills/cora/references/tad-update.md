<!-- Cora's route for updating TAD (EPIC-20261022-tad-update-flow, Phase 1) -->

# Updating TAD

Updating TAD is an operation, not work to triage: the human says one sentence ("升级 TAD", "更新 TAD", "update TAD" or "/tad-update") and Cora runs the project's updater herself. No tier is stated, no subagent is dispatched, no code is written and no verdict is given.

## Steps
1. Run the read-only check from the project root:

   ```bash
   /bin/bash .tad/scripts/tad-update.sh --check
   ```

2. Show the check screen to the human verbatim: versions, platforms, what changes, the backup and the "To apply:" line. Give her recommendation in one line (update now, or wait, and why) and ask once whether to update. "Already up to date" or a refused downgrade ends the matter: she reports it as printed.
3. Only after the human's explicit yes, run the "To apply" line exactly as the check printed it (the platform list on it is what he confirmed):

   ```bash
   /bin/bash .tad/scripts/tad-update.sh --yes --platform <platforms>
   ```

4. Show the block from the `TAD update report` line to the end of the output, not the whole log: new version, platforms refreshed, skill entries, project files unchanged (or the paths that changed outside TAD's areas), your edits in TAD files, the holding area, the backup and its size, the report file, After this update.

5. **After the update**: act on the report's `After this update` block — re-read the files it names with your file-read tool, then tell the human in at most three lines what changed and whether a new session is needed (the block's line for this harness).

## Held backups ("清掉" and "看备份")

Older backups move to a holding area outside the project and are deleted only with the human's yes. Two sentences from the human open the flows below; nothing here runs on its own.

- **"清掉"** (clear held backups): run `/bin/bash .tad/scripts/tad-backups.sh list`, show its output verbatim, give a one-line recommendation (absorb first when any item is flagged for review), ask once, and only on a yes run the `To clear:` line it printed, exactly as printed. Items held for review are never cleared by it.
- **"看备份"** (what the project edited inside TAD files): run `/bin/bash .tad/scripts/tad-backups.sh salvage` and show its output verbatim (it holds no file content). For each `edited` file give the diff file path it printed for the human to open himself, and a one-line recommendation from the path, class and line counts; on a yes for one file run that item's `To absorb:` line exactly as printed. For a held item flagged for review that is not absorbed, offer its `To discard:` line (it needs its own yes). Files printed as having no released TAD file to compare with are named for the human to open himself.
- Both flows: never open or print a diff file or a backup file in the conversation.
- A `--clear-held <token>` on the "To apply" line is part of the same yes: the held backups the check listed under "Will clear" are cleared only after the update succeeded.

## Rules
- Relay the report and stop: an installer hint is not a question to ask.
- Never run the second command without his yes in the conversation; silence or "it is small" is not a yes.
- If the check says the platform is not determined, ask which platforms to update and forward only his answer.
- An error or a refusal is reported as printed; she does not work around the helper or reimplement it.
- If the report shows changed project files or unresolved skill entries, she says so in one line and points to the report file; she does not fix them herself.
