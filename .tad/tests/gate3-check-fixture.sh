#!/bin/bash
# gate3-check-fixture.sh — fixture for the bug-evidence block of
# .tad/hooks/lib/gate3-check.sh (review-contract.md §10; TAD 4.0.13), in both
# modes: handoff mode (a handoff path) and journal mode (a simple-tier task
# addressed `<journal>:<n>`, n = the line number of its `request:` line).
#
# Self-contained: it reads nothing outside itself and its own temp root T
# (mktemp -d, removed by name at the end), uses no git, and runs the same in any
# checkout. Heredocs write a minimal handoff / verdict / completion / Epic tree;
# each case edits its own copy and runs the script from inside that copy with
# repo-relative arguments, as review-contract.md §5 calls it.
#
# Usage: gate3-check-fixture.sh
# Output: one `PASS <case>: <what>` / `FAIL <case>: <what>` line per case, last
# line `GATE3-CHECK-FIXTURE: PASS <n>/<n>` (else `GATE3-CHECK-FIXTURE: FAIL <k>/<n>`);
# exit 0 only when every case passes.

here="$(cd "$(dirname "$0")" && pwd)"
G="$here/../hooks/lib/gate3-check.sh"
[ -f "$G" ] || { echo "GATE3-CHECK-FIXTURE: FAIL no script at $G"; exit 1; }
G="$(cd "$(dirname "$G")" && pwd)/gate3-check.sh"

T="$(mktemp -d "${TMPDIR:-/tmp}/g3fx.XXXXXX")" || { echo "GATE3-CHECK-FIXTURE: FAIL mktemp"; exit 1; }
# normalise the path (a TMPDIR ending in "/", the macOS default, gives "//"): the script
# under test names Epic paths from its own working directory, which has single slashes
T="$(cd "$T" && pwd)" || { echo "GATE3-CHECK-FIXTURE: FAIL temp root"; exit 1; }
B="$T/base"
mkdir -p "$B/.tad/active/handoffs" "$B/.tad/evidence" "$B/.tad/active/epics" "$B/.tad/archive/epics"

cat > "$B/.tad/active/handoffs/H.md" <<'EOF'
---
task_type: code
real_paths:
  - id: RP1
    path: "a user path"
    run: "the reviewer runs it"
---

# Handoff
**Epic:** EPIC-x.md (Phase 1/1)

## 9.1 Spec Compliance Checklist
| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output |
|---|---|---|---|---|---|
| AC1 | the thing works | post-impl-verifiable | `true` | rc 0 | (post-impl) |
EOF

cat > "$B/.tad/evidence/v.md" <<'EOF'
---
dispatch_id: fx-run
verdict: PASS
judged: .tad/evidence/c.md (the changed files)
lens: run
---
## Bug evidence
| item | checked | observed | result |
|---|---|---|---|
| before-file | before file shows the failure | holds | pass |
| after-file | after file shows the pass | holds | pass |
| rerun-unfixed | own re-run on the unfixed state | fails as shown | pass |
| rerun-fixed | own re-run on the fixed state | passes | pass |

## AC runs
| id | command | exit | result |
|---|---|---|---|
| AC1 | `true` | 0 | pass |

## Real paths
| id | result | output pointer |
|---|---|---|
| RP1 | pass | run log line 1 |

## Not run

## Blocked
EOF

cat > "$B/.tad/evidence/c.md" <<'EOF'
dispatch_id: fx-impl
# completion
gate3_verdict:
EOF

cat > "$B/.tad/active/epics/EPIC-x.md" <<'EOF'
# Epic x

## Requirement
- **A**: a block.
- **Done check**: run it.

## Notes
- none
EOF

# simple-tier journal J (journal mode) and its run verdicts
mkdir -p "$B/.tad/evidence/journal" "$B/.tad/evidence/simple"
cat > "$B/.tad/evidence/journal/conductor-simple-2026-01-01.md" <<'EOF'
# Conductor journal: simple tasks (2026-01-01)

## fix-a (2026-01-01)
- request: "fix a" bug_fix: repro: sh a.sh | symptom: prints x
Dispatched: s-a-1 -> .tad/evidence/simple/a-completion.md
Dispatched: s-a-2 (run) -> .tad/evidence/simple/a-run.md

## do-b (2026-01-01)
- request: "do b" playback confirmed: "ok"
| note | request: x bug_fix: y |
Prose that quotes request: and bug_fix: on one line.
Dispatched: s-b-2 (run) -> .tad/evidence/simple/b-run.md

## note (2026-01-01)
- fix-a rework. Dispatched: s-a-3 (run r2) -> .tad/evidence/simple/a-run-r2.md
- Request: "do c" playback confirmed: "ok"
- request: "do d";bug_fix: repro: a | symptom: b
EOF
for v in a-run:s-a-2 a-run-r2:s-a-3 b-run:s-b-2; do
  f="${v%%:*}"; id="${v#*:}"
  {
    printf -- '---\ndispatch_id: %s\nverdict: PASS\n' "$id"
    [ "$f" = b-run ] && printf 'judged: .tad/evidence/simple/b-completion.md\n'
    printf 'lens: run\n---\n# run verdict\n\n## Not run\n- legs (x): not-run: y\n'
  } > "$B/.tad/evidence/simple/$f.md"
done
printf 'dispatch_id: s-b-1\n# completion b\n' > "$B/.tad/evidence/simple/b-completion.md"
JP=.tad/evidence/journal/conductor-simple-2026-01-01.md

n=0; k=0
pass() { n=$((n + 1)); echo "PASS $1: $2"; }
fail() { n=$((n + 1)); k=$((k + 1)); echo "FAIL $1: $2"; }

# new copy of the base tree for case $1; sets C
mk() { C="$T/c-$1"; rm -rf "$C"; cp -R "$B" "$C"; }
# run the script in C; sets out / rc
run() { out="$(cd "$C" && /bin/bash "$G" .tad/active/handoffs/H.md .tad/evidence/v.md 2>&1)"; rc=$?; }
# journal mode: run the script with address $1 and verdict $2 (repo-relative); sets out / rc
runj() { out="$(cd "$C" && /bin/bash "$G" "$1" "$2" 2>&1)"; rc=$?; }
# exact output: the lines given as arguments, in order, and nothing else
exactly() { [ "$out" = "$(printf '%s\n' "$@")" ]; }
has() { printf '%s\n' "$out" | grep -qxF -- "$1"; }
nobug() { ! printf '%s\n' "$out" | grep -Eq '^BUGFIX|^BUG |bug-evidence'; }
# edit file $1 in C with sed program $2 (temp + mv, BSD and GNU alike)
ed_() { sed -E "$2" "$C/$1" > "$C/$1.tmp" && mv -f "$C/$1.tmp" "$C/$1"; }
cmark() { printf 'bug_repro: %s\n' "$1" >> "$C/.tad/evidence/c.md"; }
delsec() { awk '/^## Bug evidence/ { skip = 1; next } skip && /^## / { skip = 0 } !skip' "$C/.tad/evidence/v.md" > "$C/v.tmp" && mv -f "$C/v.tmp" "$C/.tad/evidence/v.md"; }
setres() { ed_ .tad/evidence/v.md "s/^(\| $1 \|[^|]*\|[^|]*\|) pass \|$/\1 $2 |/"; }
delrow() { ed_ .tad/evidence/v.md "/^\| $1 \|/d"; }
CM="completion:.tad/evidence/c.md"

# --- unmarked control: no mark at all; with and without ## Bug evidence
mk unmarked-control; run
ctl_out="$out"; ctl_rc=$rc
if [ "$rc" -eq 0 ] && nobug; then
  delsec; run
  if [ "$rc" -eq 0 ] && nobug; then pass unmarked-control "no mark: exit 0 and no bug-evidence line, with and without the section"
  else fail unmarked-control "section removed: rc=$rc"; fi
else fail unmarked-control "rc=$rc or a bug line printed"; fi

# --- complete
mk complete; cmark reproduced; run
if [ "$rc" -eq 0 ] && has "BUGFIX marked by $CM" && has "BUG before-file pass" && has "BUG after-file pass" && has "BUG rerun-unfixed pass" && has "BUG rerun-fixed pass"; then
  pass complete "four BUG ... pass lines, exit 0"
else fail complete "rc=$rc"; fi

# --- failures (each exit 1 with its line)
mk no-section; cmark reproduced; delsec; run
{ [ "$rc" -eq 1 ] && has "MISSING section ## Bug evidence"; } && pass no-section "MISSING section, exit 1" || fail no-section "rc=$rc"
for it in before after; do
  mk "$it-missing"; cmark reproduced; delrow "$it-file"; run
  { [ "$rc" -eq 1 ] && has "MISSING bug-evidence $it-file"; } && pass "$it-missing" "MISSING bug-evidence $it-file, exit 1" || fail "$it-missing" "rc=$rc"
  mk "$it-fail"; cmark reproduced; setres "$it-file" fail; run
  { [ "$rc" -eq 1 ] && has "UNEXPLAINED bug-evidence $it-file result 'fail'"; } && pass "$it-fail" "UNEXPLAINED $it-file fail, exit 1" || fail "$it-fail" "rc=$rc"
done
mk rerun-fail; cmark reproduced; setres rerun-fixed fail; run
{ [ "$rc" -eq 1 ] && has "UNEXPLAINED bug-evidence rerun-fixed result 'fail'"; } && pass rerun-fail "UNEXPLAINED rerun-fixed fail, exit 1" || fail rerun-fail "rc=$rc"
mk rerun-missing; cmark reproduced; delrow rerun-unfixed; run
{ [ "$rc" -eq 1 ] && has "MISSING bug-evidence rerun-unfixed"; } && pass rerun-missing "MISSING bug-evidence rerun-unfixed, exit 1" || fail rerun-missing "rc=$rc"

# --- valid not-run forms
mk rerun-notrun; cmark reproduced; setres rerun-fixed "not-run: section 6 forbids the run"; run
{ [ "$rc" -eq 0 ] && has "BUG rerun-fixed not-run"; } && pass rerun-notrun "not-run with a reason is valid (BUG rerun-fixed not-run), exit 0" || fail rerun-notrun "rc=$rc"
mk rerun-notrebuildable; cmark reproduced; setres rerun-unfixed "not-rebuildable: no copy of the old file"; run
{ [ "$rc" -eq 0 ] && has "BUG rerun-unfixed not-run"; } && pass rerun-notrebuildable "not-rebuildable with a reason is valid, exit 0" || fail rerun-notrebuildable "rc=$rc"

# --- mark sources, each alone
mk mark-reproduction; printf '\n## Reproduction\nrepro: bash x.sh\nsymptom: it fails\n' >> "$C/.tad/active/handoffs/H.md"; run
{ [ "$rc" -eq 0 ] && has "BUGFIX marked by reproduction:.tad/active/handoffs/H.md"; } && pass mark-reproduction "## Reproduction marks it" || fail mark-reproduction "rc=$rc out=$(printf '%s' "$out" | grep BUGFIX)"
mk mark-epic; awk '{ print } /^## Requirement/ { print "- **Bug fix**: repro: bash x.sh — symptom: exit 1" }' "$B/.tad/active/epics/EPIC-x.md" > "$C/.tad/active/epics/EPIC-x.md"; run
{ [ "$rc" -eq 0 ] && has "BUGFIX marked by epic:$C/.tad/active/epics/EPIC-x.md"; } && pass mark-epic "an active Epic's Bug fix line marks it" || fail mark-epic "rc=$rc out=$(printf '%s' "$out" | grep BUGFIX)"
mk mark-epic-archive; awk '{ print } /^## Requirement/ { print "- **Bug fix**: repro: bash x.sh — symptom: exit 1" }' "$B/.tad/active/epics/EPIC-x.md" > "$C/.tad/archive/epics/EPIC-x.md"; rm -f "$C/.tad/active/epics/EPIC-x.md"; run
{ [ "$rc" -eq 0 ] && has "BUGFIX marked by epic:$C/.tad/archive/epics/EPIC-x.md"; } && pass mark-epic-archive "an Epic only in archive/epics marks it" || fail mark-epic-archive "rc=$rc out=$(printf '%s' "$out" | grep BUGFIX)"
mk mark-completion; cmark reproduced; run
{ [ "$rc" -eq 0 ] && has "BUGFIX marked by $CM"; } && pass mark-completion "a bug_repro: line in the judged completion marks it" || fail mark-completion "rc=$rc"
mk mark-epic-otherphase; awk '{ print } /^## Requirement/ { print "- **Bug fix (phase 2)**: repro: bash x.sh — symptom: exit 1" }' "$B/.tad/active/epics/EPIC-x.md" > "$C/.tad/active/epics/EPIC-x.md"; delsec; run
{ [ "$rc" -eq 0 ] && nobug; } && pass mark-epic-otherphase "a (phase 2) mark leaves phase 1 unmarked" || fail mark-epic-otherphase "rc=$rc"

# --- not reproduced
mk not-reproduced; cmark not-reproduced; run
{ [ "$rc" -eq 1 ] && has "MISSING bug-evidence fix (bug_repro: not-reproduced is a BF3 stop, not a Gate 3)"; } && pass not-reproduced "bug_repro: not-reproduced fails, exit 1" || fail not-reproduced "rc=$rc"

# --- handoff mode: a request: line in a handoff is no mark; the handoff checks still bite
mk handoff-requestline; printf '%s\n' '- request: "x" bug_fix: repro: a | symptom: b' >> "$C/.tad/active/handoffs/H.md"; run
{ [ "$rc" -eq "$ctl_rc" ] && [ "$out" = "$ctl_out" ]; } && pass handoff-requestline "a request: line with bug_fix: in a handoff: output and exit equal unmarked-control" || fail handoff-requestline "rc=$rc out=$(printf '%s' "$out" | tr '\n' ';')"
mk handoff-noac-control; awk '/^\| # \| Acceptance Criterion/ { skip = 1 } skip && !/^\|/ { skip = 0 } !skip' "$B/.tad/active/handoffs/H.md" > "$C/.tad/active/handoffs/H.md"; run
{ [ "$rc" -eq 1 ] && printf '%s\n' "$out" | grep -q '^MISSING ac-table'; } && pass handoff-noac-control "a handoff without its AC table still fails MISSING ac-table, exit 1" || fail handoff-noac-control "rc=$rc"

# --- journal mode (simple tier), J = $JP
SV=.tad/evidence/simple
mk journal-marked-missing; runj "$JP:4" "$SV/a-run.md"
{ [ "$rc" -eq 1 ] && exactly "SIMPLE task $JP:4" "BUGFIX marked by journal:$JP:4" "MISSING section ## Bug evidence"; } && pass journal-marked-missing "marked task without ## Bug evidence: exactly SIMPLE, BUGFIX, MISSING section; exit 1" || fail journal-marked-missing "rc=$rc out=$(printf '%s' "$out" | tr '\n' ';')"
bevid() { printf '\n## Bug evidence\n| item | checked | observed | result |\n|---|---|---|---|\n| before-file | b | holds | pass |\n| after-file | a | holds | pass |\n| rerun-unfixed | u | fails | pass |\n| rerun-fixed | f | passes | pass |\n' >> "$C/$SV/$1"; }
mk journal-marked-complete; bevid a-run.md; runj "$JP:4" "$SV/a-run.md"
{ [ "$rc" -eq 0 ] && exactly "SIMPLE task $JP:4" "BUGFIX marked by journal:$JP:4" "BUG before-file pass" "BUG after-file pass" "BUG rerun-unfixed pass" "BUG rerun-fixed pass"; } && pass journal-marked-complete "marked task with four pass rows: exit 0" || fail journal-marked-complete "rc=$rc out=$(printf '%s' "$out" | tr '\n' ';')"
mk journal-marked-after-missing; bevid a-run.md; ed_ "$SV/a-run.md" '/^\| after-file \|/d'; runj "$JP:4" "$SV/a-run.md"
{ [ "$rc" -eq 1 ] && has "MISSING bug-evidence after-file"; } && pass journal-marked-after-missing "marked task without the after-file row: MISSING bug-evidence after-file, exit 1" || fail journal-marked-after-missing "rc=$rc"
mk journal-unmarked; runj "$JP:9" "$SV/b-run.md"
{ [ "$rc" -eq 0 ] && exactly "SIMPLE task $JP:9"; } && pass journal-unmarked "unmarked task next to a marked one and to lines quoting both tokens: exactly SIMPLE, exit 0" || fail journal-unmarked "rc=$rc out=$(printf '%s' "$out" | tr '\n' ';')"
mk journal-mark-completion; printf 'bug_repro: reproduced\n' >> "$C/$SV/b-completion.md"; runj "$JP:9" "$SV/b-run.md"
{ [ "$rc" -eq 1 ] && has "SIMPLE task $JP:9" && has "BUGFIX marked by completion:$SV/b-completion.md" && has "MISSING section ## Bug evidence"; } && pass journal-mark-completion "the judged completion's bug_repro: marks a simple task, exit 1 without the section" || fail journal-mark-completion "rc=$rc out=$(printf '%s' "$out" | tr '\n' ';')"
mk journal-dispatch-anywhere; runj "$JP:4" "$SV/a-run-r2.md"
{ [ "$rc" -eq 1 ] && exactly "SIMPLE task $JP:4" "BUGFIX marked by journal:$JP:4" "MISSING section ## Bug evidence"; } && pass journal-dispatch-anywhere "verdict whose Dispatched: entry sits mid-line under another heading: same three lines, exit 1" || fail journal-dispatch-anywhere "rc=$rc out=$(printf '%s' "$out" | tr '\n' ';')"
mk journal-request-capital; runj "$JP:16" "$SV/b-run.md"
{ [ "$rc" -eq 0 ] && exactly "SIMPLE task $JP:16"; } && pass journal-request-capital "a '- Request:' line is a request line: exactly SIMPLE, exit 0" || fail journal-request-capital "rc=$rc out=$(printf '%s' "$out" | tr '\n' ';')"
mk journal-bugfix-nospace; runj "$JP:17" "$SV/b-run.md"
{ [ "$rc" -eq 1 ] && has "BUGFIX marked by journal:$JP:17" && has "MISSING section ## Bug evidence"; } && pass journal-bugfix-nospace "'\"...\";bug_fix:' marks the task (fail closed), exit 1" || fail journal-bugfix-nospace "rc=$rc out=$(printf '%s' "$out" | tr '\n' ';')"
mk journal-no-line; runj "$JP" "$SV/a-run.md"
{ [ "$rc" -eq 1 ] && exactly "MISSING task line: pass $JP:<n>, n = the line number of the task's request: line"; } && pass journal-no-line "a journal without :<n>: exactly MISSING task line, exit 1" || fail journal-no-line "rc=$rc out=$(printf '%s' "$out" | tr '\n' ';')"
mk journal-not-request; runj "$JP:10" "$SV/b-run.md"
{ [ "$rc" -eq 1 ] && exactly "MISSING request line at $JP:10"; } && pass journal-not-request "line 10 (a table row holding both tokens) is not a request line: exit 1" || fail journal-not-request "rc=$rc out=$(printf '%s' "$out" | tr '\n' ';')"
mk journal-beyond; runj "$JP:99" "$SV/b-run.md"
{ [ "$rc" -eq 1 ] && exactly "MISSING request line at $JP:99"; } && pass journal-beyond "a line past the end: MISSING request line, exit 1" || fail journal-beyond "rc=$rc out=$(printf '%s' "$out" | tr '\n' ';')"

case "$T" in */g3fx.*) rm -rf "$T" ;; esac

if [ "$k" -eq 0 ]; then echo "GATE3-CHECK-FIXTURE: PASS $n/$n"; exit 0; fi
echo "GATE3-CHECK-FIXTURE: FAIL $k/$n"; exit 1
