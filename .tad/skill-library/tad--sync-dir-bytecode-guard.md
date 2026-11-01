# sync-dir-bytecode-guard

**Source project**: TAD
**Date**: 2026-10-31
**Type**: protocol

## Selector
Applies whenever a Python script is executed with its working directory or
script path inside a file-synced folder (Syncthing / iCloud / Dropbox trees).
Near-miss: running Python from a non-synced local directory (e.g. /tmp,
~/.local) does NOT trigger this — no second machine ever sees the artifacts.

## Action
1. Prefix the invocation: `PYTHONDONTWRITEBYTECODE=1 python3 script.py`
   (or export it for the whole shell session inside the synced tree).
2. If a `__pycache__/` directory already exists in the synced tree, do not
   delete it blindly: check whether the other side created it on purpose;
   normally remove it once and note it in the run evidence.
3. Test harnesses and detectors that run inside synced trees inherit the
   same rule — set the variable in the harness, not per call.

## failure_mode
Naive default: run Python in the synced folder as anywhere else. Why wrong:
Python writes `__pycache__/*.pyc` next to the source; the sync engine ships
those to every peer, where timestamp/merge races surface as `.sync-conflict`
copies of bytecode nobody wrote on purpose — observed in this workspace
2026-09-17 (yun-sync tree, detector runs), after which the guard became a
standing rule for the seat.
