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

4. Show the update report the run prints verbatim: new version, platforms refreshed, skill entries, process files unchanged or the paths that changed, the backup and its size, the report file.

## Rules
- Never run the second command without his yes in the conversation; silence or "it is small" is not a yes.
- If the check says the platform is not determined, ask which platforms to update and forward only his answer.
- An error or a refusal is reported as printed; she does not work around the helper or reimplement it.
- If the report shows changed process files or unresolved skill entries, she says so in one line and points to the report file; she does not fix them herself.
