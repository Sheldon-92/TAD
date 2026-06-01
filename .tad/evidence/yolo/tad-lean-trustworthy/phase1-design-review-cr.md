# Phase 1 Design Review — code-reviewer (YOLO Y4)

Verdict: **CONDITIONAL PASS**. Core header-aware awk algorithm empirically verified correct
(prototyped against both archived corpora + fault injection). Defects concentrated in §9.1 AC commands.

## P0
- **P0-1 AC1.1 grep uses `\|` (literal pipe in ERE), not alternation → both checks broken.**
  Negative check `grep -nE 'd=a\[3\]\|c=a\[5\]\|r=a\[6\]'` can NEVER match (no literal `|` on line 188)
  → falsely PASSES even if Blake leaves hardcoded indices. Positive check falsely FAILS. Validation theater.
  FIX: unescape alternation pipes → `grep -nE 'di=i|ci=i|ri=i|havehdr'` (hit) and
  `grep -nE 'd=a\[3\]|c=a\[5\]|r=a\[6\]'` (no hit). Keep `\[ \]` bracket escapes; only pipe loses backslash.
- **P0-2 AC1.4a fail-open baseline (file-wide `grep -c '|| true'`=14) doesn't pin the ONE in emit_decision_points.**
  FIX: scope to function body: `awk '/^emit_decision_points\(\)/{f=1} f&&/^}/{print;exit} f' file | grep -c '|| true'` ≥1,
  keep file-wide ≥14 as secondary. Also assert awk subshell keeps `2>/dev/null` + `[ -n "$rows" ] || return 0`.

## P1
- **P1-1 dream-state.yaml reconciliation contradictory** (grounding says reconcile total_rejected; handoff §6 says keep 6 + zero last_scan_candidates; semantically zeroing last_scan_candidates falsifies scan history — same append-only violation Decision 2 forbids). FIX: leave dream-state.yaml UNTOUCHED (counts = immutable scan history); delete only the 6 files. Removes a 7th changed file, makes "minimal edit" true.
- **P1-2 AC1.2 dry-run shows only post-fix output, no before/after swap contrast.** FIX: also run the ORIGINAL a[3]/a[5]/a[6] awk on the 4-col handoff, show row 5 emits chosen="Some projects legitimately don't need research"/rationale=empty; the diff is the swap-back evidence.

## P2
- P2-1 document one-table-per-section assumption (havehdr first-table-wins) in a comment.
- P2-2 AC1.3b git status: plain `rm` shows ` D` (space-D unstaged); accept either ` D`/`D ` or use `git rm`.
- P2-3 self-trigger surface well-handled; ensure COMPLETION uses <<SEP>> output form not reconstructed markdown table.

## Verified firsthand
Prototyped header-aware awk: 4-col row5 swapped-back correct; 5-col unchanged; malformed/no-header → empty exit 0;
override marker in 4-col Chosen cell carried to $c. AC1.1 both greps proven broken against live file.
