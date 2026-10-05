#!/usr/bin/env bash
# setup-run.sh <run-id> <base-commit>
# Creates an isolated worktree at the frozen base commit, copies the frozen
# inputs (task, sealed oracle, approved handoff, goal spec) into it, and
# initialises the recovery ledger. Idempotent only in the sense that it refuses
# to clobber: remove the worktree first to re-run.
set -euo pipefail

RUN_ID="$1"; BASE="$2"
MAIN="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../../../.." && pwd)"
REL=".tad/evidence/yolo/yolo2-verified-orchestration/phase1/dogfood"
SRC="$MAIN/$REL"
WT="/private/tmp/tad-yolo2-p1/wt-$RUN_ID"
HANDOFF=".tad/active/handoffs/HANDOFF-20260824-yolo2-phase1-recovery-slice.md"

mkdir -p /private/tmp/tad-yolo2-p1
[ -e "$WT" ] && { echo "worktree already exists: $WT" >&2; exit 1; }

git -C "$MAIN" worktree add --detach "$WT" "$BASE" >/dev/null
mkdir -p "$WT/$REL" "$WT/.tad/active/handoffs"
cp "$SRC/task.md"                     "$WT/$REL/task.md"
cp "$SRC/action-b.md"                 "$WT/$REL/action-b.md"
cp "$SRC/oracle-$RUN_ID.sealed.txt"   "$WT/$REL/oracle.sealed.txt"
cp "$MAIN/$HANDOFF"                   "$WT/$HANDOFF"

cat > "$WT/$REL/goal-spec.json" <<JSON
{
  "run_id": "$RUN_ID",
  "goal_id": "yolo2-p1-guide-maintenance",
  "base_commit": "$BASE",
  "goal": "Maintain .tad/guides/yolo-recovery.md by adding a Command Reference (S1), a Troubleshooting table (S2) and a Worked Example (S3), without changing any other file.",
  "success": [
    "S1: section '## 10. Command Reference' documents every CLI command with its required flags and exit codes",
    "S2: section '## 11. Troubleshooting' maps real CLI reason strings to symptom and remedy",
    "S3: section '## 12. Worked Example' is a copy-pasteable transcript from init through resume"
  ],
  "non_goals": [
    "do not improve or restructure the existing guide sections",
    "do not change the CLI or its tests"
  ],
  "forbidden_scope": [".tad/scripts/", ".claude/", ".tad/hooks/"],
  "oracle_path": "$REL/oracle.sealed.txt",
  "slices": [
    { "id": "S1", "statement": "add the '## 10. Command Reference' section" },
    { "id": "S2", "statement": "add the '## 11. Troubleshooting' section" },
    { "id": "S3", "statement": "add the '## 12. Worked Example' section" }
  ]
}
JSON

cd "$WT"
node .tad/scripts/yolo-recovery.mjs init \
  --run "$REL/run" \
  --handoff "$HANDOFF" \
  --goal-file "$REL/goal-spec.json" | tail -1

echo "WORKTREE=$WT"
echo "RUNDIR=$WT/$REL/run"
echo "TASK_SHA256=$(shasum -a 256 "$WT/$REL/task.md" | cut -d' ' -f1)"
