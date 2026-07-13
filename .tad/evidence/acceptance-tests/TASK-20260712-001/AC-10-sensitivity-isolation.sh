#!/usr/bin/env bash
# AC10: sensitivity report coverage + gitignore isolation + no credential patterns tracked
cd "$(git rev-parse --show-toplevel)"
R=.tad/evidence/memory-migration-sensitivity-report.md
[ -f "$R" ] || { echo "AC10 FAIL: report missing"; exit 1; }
ROWS=$(grep -cE '^\| [0-9]+ \|' "$R")
[ "$ROWS" -eq 36 ] || { echo "AC10 FAIL: report rows=$ROWS (need 36)"; exit 1; }
for f in user_agent-builder-goals.md MEMORY.md feedback_share-mode-and-deflation.md project_co-thinking-workshop-seed.md project_tad-evolution-directions.md project_tad-universal-method.md reference_claude-code-source.md; do
  git check-ignore -q ".tad/memory/$f" || { echo "AC10 FAIL: not ignored: $f"; exit 1; }
done
T=$(git ls-files .tad/memory | grep -cE 'user_' || true)
[ "$T" -eq 0 ] || { echo "AC10 FAIL: user_* tracked"; exit 1; }
HITS=$(git ls-files .tad/memory | xargs grep -lEi '@[a-z0-9.-]+\.(edu|com|org)|api[_-]?key|password' 2>/dev/null | wc -l | tr -d ' ')
[ "$HITS" -eq 0 ] || { echo "AC10 FAIL: credential-pattern hits in tracked files"; exit 1; }
echo "AC10 PASS: 36 rows; 7 SENSITIVE ignored; 0 user_* tracked; 0 credential hits"
