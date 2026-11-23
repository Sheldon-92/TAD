#!/bin/bash
# gate3-check.sh — Gate 3 evidence check (review-redesign Phase 3, rework 5).
# Advisory CLI, NEVER a hook: do not register it in settings, hooks.json or any
# plugin. No `set -e` on purpose.
#
# It executes nothing from the handoff. The acceptance commands (§9.1) and every
# real_path are run by the independent run reviewer, by hand, in one throwaway copy
# of the project; this script only reads the run reviewer's verdict file and checks
# that the evidence is complete:
#   - the verdict file exists;
#   - every AC row of the handoff's AC table (found by its header row) is accounted for by `## AC runs`
#     (`| AC<n>[/sub] | command | exit | result |`), `## Not run` or `## Blocked`;
#   - every real_paths id of the handoff front matter is accounted for by
#     `## Real paths`, `## Not run` or `## Blocked`;
#   - every row of both tables passes the one status classifier below;
#   - every line of `## Not run` reads `- <id> not-run: <reason>` with a reason.
# ID matching is ASCII only (AC<n>, RP ids); headings and table text may hold CJK.
#
# Status classifier (ONE rule for every table the script reads: `## AC runs`,
# `## Real paths`). Nothing but a provable run counts as run.
#   Columns, by header name, not by position: the first `|` line of the section is
#   the header; `|---|` lines are skipped; cells split on `|` (an escaped `\|` stays
#   inside its cell) and trimmed. id = first column; status = the column named
#   `result` or `status`; evidence = the column whose name holds `output`,
#   `pointer` or `evidence`, else the column named `exit`. Extra columns are
#   ignored. No status column or no evidence column => every row is invalid.
#   The status cell is normalised (lower case, `-`/`_` -> space) and classified:
#     run      first word pass|passed|ok|fail|failed|run|ran|done, AND the evidence
#              cell is non-empty and not `-`, `n/a`, `na`, `none`;
#     not-run  starts with `not run`, `notrun`, `skip` (Not-run, NOT RUN, skipped,
#              not_run ...); valid only with a non-empty reason: text after `:` in
#              the cell, or a `- <id> not-run: <reason>` line in `## Not run`;
#     blocked  starts with `blocked`; valid only when the id is in `## Blocked`;
#     invalid  anything else: empty status, unknown word (n/a, maybe ...), a run
#              row without evidence, a not-run/blocked row without its
#              reason/listing, a row whose id is not an id of the handoff.
#   An invalid row prints `UNEXPLAINED <row-id> invalid: <why>` (consumers keyed on
#   MISSING/UNEXPLAINED fail it). Per id, after all its rows (sub-rows `<id>/x`
#   count for <id>): any invalid row => that id is only reported invalid; else a
#   valid run row => `AC <id> run` / `COVERED <id> run`; else not-run (row or
#   `## Not run` line) => `AC <id> not-run` / `COVERED <id> not-run`; else blocked
#   (row or `## Blocked` listing) => `BLOCKED <id>`; else `MISSING <id>`.
#
# Two modes, chosen by the first argument (the usage stays two arguments):
#   handoff mode  every path whose basename does not match `conductor-simple-*.md`
#                 (or `conductor-simple-*.md:*`): every check above, unchanged.
#   journal mode  the simple tier (cora SKILL.md Triage). The run reviewer passes the
#                 task's address `<journal file>:<n>` as <handoff>: the journal
#                 `.tad/evidence/journal/conductor-simple-<date>.md` and n = the line
#                 number of the task's `request:` line, named by Cora in the dispatch.
#                 In order: no `:<n>` part, or n not all digits, or n = 0 =>
#                 `MISSING task line: pass <journal>:<n>, n = the line number of the
#                 task's request: line` (the literal `<n>`), exit 1; the journal not a
#                 readable file => usage, exit 2; the verdict-file check as above; line n
#                 must match, ignoring case, `^[[:space:]]*(- )?request:`, else (n past
#                 the end included) `MISSING request line at <journal>:<n>`, exit 1;
#                 then `SIMPLE task <journal>:<n>`. The AC-table, `## AC runs`,
#                 real_paths, `## Real paths` and `## Not run` checks and the m1/m3
#                 marks do not run (a journal has none of them); no `Dispatched:` line,
#                 no dispatch_id and no section is read: only line n. An unmarked task
#                 prints the SIMPLE line alone and exits 0.
#
# Bug evidence (review-contract.md §10, 4.0.13). The script decides itself whether
# the matter is a bug fix, from these marks (a source that cannot be read is no
# mark and prints nothing):
#   m1 (handoff mode) the handoff has a `## Reproduction` section holding a `repro:`
#      line (*bug);
#   m2 (journal mode) line n of the journal holds `bug_fix:` anywhere on it (fail
#      closed: `"...";bug_fix:` counts); source `journal:<journal>:<n>`. A `request:`
#      line inside a handoff is no mark;
#   m3 (handoff mode) its `**Epic:** <name> (Phase <N>/...)` line names an Epic under
#      <root>/.tad/active/epics/ or else <root>/.tad/archive/epics/ (<root> = the
#      handoff path made absolute, cut at its last `/.tad/`) whose `## Requirement`
#      has a line starting `- **Bug fix**:` or `- **Bug fix (phase <N>)**:`;
#   m4 (both modes) the verdict front matter's `judged:` line names (first token) a readable
#      completion report holding a whole line `bug_repro: <value>`.
# No mark => output and exit code exactly as without this block. A marked matter
# prints `BUGFIX marked by <source>[,<source>]`, then reads the `## Bug evidence`
# table by header name (id = first column, status = column `result`):
#   before-file, after-file: `pass` => `BUG <item> pass`;
#   rerun-unfixed, rerun-fixed: `pass` => `BUG <item> pass`; `not-run: <reason>`
#      (rerun-unfixed also `not-rebuildable: <reason>`), or a `## Not run` line
#      `- <item> not-run: <reason>` => `BUG <item> not-run` (valid; Gate 4, never a pass);
#   no section => `MISSING section ## Bug evidence`; no row => `MISSING bug-evidence
#   <item>`; any other cell => `UNEXPLAINED bug-evidence <item> result '<cell>'`;
#   completion `bug_repro: not-reproduced` => `MISSING bug-evidence fix (...)`;
#   each of these sets exit 1.
# gate3-check.sh (bug evidence): for a handoff, a matter is checked as a bug fix when the handoff has a `## Reproduction` section with a `repro:` line, or its `**Epic:**` line names an Epic (active or archived) whose `## Requirement` has a `- **Bug fix**:` line or a `- **Bug fix (phase N)**:` line for this phase, or the completion report named by the verdict's `judged:` line has a `bug_repro:` line; on the simple tier the run reviewer passes `<journal>:<n>` as the handoff, the journal `conductor-simple-<date>.md` and n the line number of the task's `request:` line, the script reads that one line, checks no AC table, real paths or not-run lines, and checks the task as a bug fix when that line has a `bug_fix:` field or the `judged:` completion report has a `bug_repro:` line, and a journal passed without `:<n>` or a line n that is not a `request:` line fails with exit 1; then `## Bug evidence` must have the rows `before-file` and `after-file` with result `pass`, and `rerun-unfixed` and `rerun-fixed` with `pass` or `not-run: <reason>` (`not-rebuildable: <reason>` also for `rerun-unfixed`), which go to Gate 4 and are never a pass, while anything else, a missing row, a missing section or `bug_repro: not-reproduced` fails with exit 1.
#
# Usage:
#   gate3-check.sh <handoff> <verdict-file>
#   gate3-check.sh <journal file>:<n> <verdict-file>      (simple tier, journal mode)
#       prints AC <ID> run | AC <ID> not-run | COVERED <ID> run | COVERED <ID> not-run |
#              BLOCKED <ID> | MISSING <what> | UNEXPLAINED <ID> [invalid: <why>] |
#              SIMPLE task <journal>:<n> |
#              MISSING task line: pass <journal>:<n>, n = the line number of the task's request: line |
#              MISSING request line at <journal>:<n> |
#              BUGFIX marked by <source>[,<source>] | BUG <item> pass | BUG <item> not-run
#       exit 0 when nothing is MISSING or UNEXPLAINED (BLOCKED lines allowed: the
#       verdict rule caps them), 1 otherwise (a missing verdict file included),
#       2 on usage.

usage() {
  echo "Usage: gate3-check.sh <handoff> <verdict-file>" >&2
  exit 2
}

[ $# -eq 2 ] || usage
handoff="$1"
vf="$2"
mode=handoff
case "${handoff##*/}" in
  conductor-simple-*.md|conductor-simple-*.md:*) mode=journal ;;
esac
if [ "$mode" = journal ]; then
  # the task's address <journal file>:<n>, split at its last ':'
  case "${handoff##*/}" in
    *.md:*) jp="${handoff%:*}"; jn="${handoff##*:}" ;;
    *) jp="$handoff"; jn="" ;;
  esac
  case "$jn" in
    ""|*[!0-9]*) jv="" ;;
    *) jv=$(printf '%s' "$jn" | sed 's/^0*//') ;;
  esac
  if [ -z "$jv" ]; then
    echo "MISSING task line: pass $jp:<n>, n = the line number of the task's request: line"
    exit 1
  fi
  [ -f "$jp" ] && [ -r "$jp" ] || usage
else
  [ -f "$handoff" ] && [ -r "$handoff" ] || usage
fi

if [ ! -f "$vf" ] || [ ! -r "$vf" ]; then
  echo "MISSING evidence file $vf"
  exit 1
fi

rc=0
set -f   # ids come from the handoff and are word-split below: no glob expansion

# ---- journal mode: read line n only; it must be a request: line
jline=""
if [ "$mode" = journal ]; then
  jline=$(sed -n "${jv}p" "$jp" 2>/dev/null)
  if ! printf '%s\n' "$jline" | command grep -Eiq '^[[:space:]]*(- )?request:'; then
    echo "MISSING request line at $jp:$jn"
    exit 1
  fi
  echo "SIMPLE task $jp:$jn"
fi

# section body of the verdict file: heading regex -> lines up to the next "## "
secof() {
  H="$1" awk 'BEGIN{h=ENVIRON["H"]} !on { if ($0 ~ h) on = 1; next } /^## / { exit } { print }' "$vf"
}
acr=$(secof '^## AC runs')
rp=$(secof '^## Real paths')
nr=$(secof '^## Not run')
bl=$(secof '^## Blocked')
us=$(printf '\037')

# 0 when <id> is listed in ## Not run with a non-empty reason
notrun_ok() { # $1 = id
  printf '%s\n' "$nr" | command grep -E -- "^- *$1(/[A-Za-z0-9_-]+)? +not-run: *[^[:space:]]" >/dev/null
}
# 0 when <id> is listed in ## Blocked
blocked_ok() { # $1 = id
  printf '%s\n' "$bl" | command grep -Eq -- "(^|[^A-Za-z0-9_-])$1([^A-Za-z0-9_-]|\$)"
}
# normalised status word class of a status cell: run | notrun | blocked | empty | other
stclass() { # $1 = cell
  n=$(printf '%s' "$1" | tr 'A-Z_-' 'a-z  ' | sed -E 's/^[[:space:]]+//; s/[[:space:]]+/ /g; s/^\*+//; s/\*+$//')
  case "$n" in
    "") echo empty ;;
    "not run"*|notrun*|skip*) echo notrun ;;
    blocked*) echo blocked ;;
    *)
      w=$(printf '%s' "$n" | sed -E 's/[^a-z].*$//')
      case "$w" in
        pass|passed|ok|fail|failed|run|ran|done) echo run ;;
        *) echo other ;;
      esac ;;
  esac
}
# 0 when a not-run cell carries its own reason after ':'
cellreason_ok() { # $1 = cell
  printf '%s\n' "$1" | command grep -Eq ':[[:space:]]*[^[:space:]]'
}

# Table rows of a section, parsed by header name: one line per data row,
# id \037 status \037 evidence (\037, not tab: IFS whitespace collapses empty cells),
# or "NOCOL \037 <name>" when the header lacks a needed column.
tabrows() { # $1 = section text
  printf '%s\n' "$1" | awk '
    function cells(line,   t, n, i) {
      gsub(/\\\|/, "\036", line)
      sub(/^[[:space:]]*\|/, "", line); sub(/\|[[:space:]]*$/, "", line)
      n = split(line, c, "|")
      for (i = 1; i <= n; i++) {
        t = c[i]; gsub(/\036/, "|", t)
        sub(/^[[:space:]]+/, "", t); sub(/[[:space:]]+$/, "", t)
        gsub(/\037/, " ", t); c[i] = t
      }
      return n
    }
    !/^[[:space:]]*\|/ { next }
    !hdr {
      hdr = 1; n = cells($0); sc = 0; ec = 0; xc = 0
      for (i = 2; i <= n; i++) {
        h = tolower(c[i])
        if (!sc && (h == "result" || h == "status" || index(h, "结果") > 0)) sc = i
        if (!ec && (h ~ /output/ || h ~ /pointer/ || h ~ /evidence/ || index(h, "证据") > 0)) ec = i
        if (!xc && h == "exit") xc = i
      }
      if (!ec) ec = xc
      if (!sc) print "NOCOL\037result/status"
      if (!ec) print "NOCOL\037output pointer/evidence/exit"
      next
    }
    /^[[:space:]]*\|[-:| [:space:]]*$/ { next }
    {
      n = cells($0)
      s = (sc && sc <= n) ? c[sc] : ""
      e = (ec && ec <= n) ? c[ec] : ""
      print c[1] "\037" s "\037" e
    }
  '
}

# The one status classifier, used for every table (AC runs, Real paths).
# Sets okids / nrids / blids / badids (space-delimited base ids); prints
# `UNEXPLAINED <row-id> invalid: <why>` for every invalid row.
classify() { # $1 = section text, $2 = known ids of that table
  okids=" "; nrids=" "; blids=" "; badids=" "
  rows=$(tabrows "$1")
  nocol=$(printf '%s\n' "$rows" | awk -F '\037' '$1 == "NOCOL" { print $2 }' | paste -sd ';' -)
  while IFS="$us" read -r rid st ev; do
    [ -n "$rid" ] || continue
    [ "$rid" = NOCOL ] && continue
    base=${rid%%/*}
    btok=$(printf '%s' "$base" | sed -E 's/^((AC|RP)[0-9]+) .*/\1/')
    [ "$btok" != "$base" ] && base=$btok
    why=""
    known=0
    for k in $2; do [ "$k" = "$base" ] && known=1; done
    if [ "$known" -eq 0 ]; then
      why="row id is not an id of the handoff"
    elif [ -n "$nocol" ]; then
      why="table has no $nocol column"
    else
      case "$(stclass "$st")" in
        run)
          evn=$(printf '%s' "$ev" | tr 'A-Z' 'a-z')
          case "$evn" in
            ""|-|n/a|na|none) why="run row without evidence (evidence cell empty)" ;;
            *) okids="$okids$base " ;;
          esac ;;
        notrun)
          if cellreason_ok "$st" || notrun_ok "$base"; then nrids="$nrids$base "
          else why="not-run without a reason (cell or ## Not run)"; fi ;;
        blocked)
          if blocked_ok "$base"; then blids="$blids$base "
          else why="blocked but not listed in ## Blocked"; fi ;;
        empty) why="empty status cell" ;;
        *) why="unrecognised status '$st'" ;;
      esac
    fi
    if [ -n "$why" ]; then
      echo "UNEXPLAINED $rid invalid: $why"
      badids="$badids$base "
      rc=1
    fi
  done <<EOF
$rows
EOF
}
inset() { case "$1" in *" $2 "*) return 0 ;; esac; return 1; }

# Harvest list-form Real paths items (`- **RP<n>...` / `- RP<n>...`, the id at
# the item start) into table rows `| <id> | <status> | <rest> |`. Status, in
# order: the line holds `not-run` or `not run` -> `not-run: <rest>`; it holds
# `已走查` -> `ran`; it holds a standalone pass/passed/ok/done word -> `ran`;
# otherwise the status stays empty, so the classifier reports the row
# UNEXPLAINED (no status marker, no silent pass). <rest> is the line minus
# the `- ` bullet, the id token, the bold markers and the title parenthesis
# after the id, with `|` flattened to `/`.
rpharvest() { # $1 = section text
  printf '%s\n' "$1" | while IFS= read -r line; do
    printf '%s' "$line" | command grep -Eq '^- +\*\*RP[0-9]+|^- +RP[0-9]+' || continue
    id=$(printf '%s' "$line" | command grep -oE 'RP[0-9]+' | head -1)
    rest=$(printf '%s' "$line" | sed -E 's/^- +//; s/\*\*//g; s/^RP[0-9]+//; s/^（[^）]*）//; s/^[[:space:]]+//; s/^：//; s/^:[[:space:]]*//; s/\|/\//g')
    if printf '%s' "$line" | command grep -Eq 'not-run|not run'; then
      st="not-run: $rest"
    elif printf '%s' "$line" | command grep -q '已走查'; then
      st="ran"
    elif printf '%s' "$line" | command grep -Eiq '(^|[^A-Za-z])(pass|passed|ok|done)([^A-Za-z]|$)'; then
      st="ran"
    else
      st=""
    fi
    printf '| %s | %s | %s |\n' "$id" "$st" "$rest"
  done
}

# Final state of one id after classify: prints <runline> / <notrunline> / BLOCKED /
# MISSING; invalid ids were already reported.
settle() { # $1 = id, $2 = run label, $3 = not-run label
  inset "$badids" "$1" && return
  if inset "$okids" "$1"; then echo "$2 $1 run"
  elif inset "$nrids" "$1" || notrun_ok "$1"; then echo "$3 $1 not-run"
  elif inset "$blids" "$1" || blocked_ok "$1"; then echo "BLOCKED $1"
  else echo "MISSING $1"; rc=1
  fi
}

if [ "$mode" = handoff ]; then
# ---- ## Not run lines: each must carry a reason
while IFS= read -r line; do
  case "$line" in
    -*) ;;
    *) continue ;;
  esac
  id=$(printf '%s\n' "$line" | sed -E 's/^- *//; s/[[:space:]].*$//')
  if ! printf '%s\n' "$line" | command grep -Eq -- "^- *[^[:space:]]+ +not-run: *[^[:space:]]"; then
    echo "UNEXPLAINED $id"
    rc=1
  fi
done <<EOF
$nr
EOF

# ---- AC rows of the handoff's AC table, found by its header row (not by a heading):
# two header forms latch the table. Form A (`.tad/templates/handoff-a-to-b.md`
# §9.1): a row whose cells include `Expected Evidence` and an AC-criterion column
# (`Acceptance Criterion`/`Acceptance Criteria`/`Criterion`). Form B (the r4
# phase4/phase5 contracts' current form): a row whose cells include all of an
# id column (`ID`/`#`), `Requirement`, `Verification Method` and
# `Verified Output`. The rows below the header (until the table ends) are
# read, first cell `AC<n>`.
acs=$(awk '
  function lowcells(line,   n, i, t) {
    n = split(line, c, "|")
    for (i = 1; i <= n; i++) { t = tolower(c[i]); gsub(/^[ \t]+|[ \t]+$/, "", t); c[i] = t }
    return n
  }
  /^[[:space:]]*\|/ {
    if (!intab) {
      n = lowcells($0); ev = 0; cr = 0; idc = 0; rq = 0; vm = 0; vo = 0
      for (i = 1; i <= n; i++) {
        if (c[i] ~ /^expected evidence/) ev = 1
        if (c[i] ~ /^(acceptance criteri|criterion)/) cr = 1
        if (c[i] == "id" || c[i] == "#") idc = 1
        if (c[i] ~ /^requirement/) rq = 1
        if (c[i] ~ /^verification method/) vm = 1
        if (c[i] ~ /^verified output/) vo = 1
      }
      if ((ev && cr) || (idc && rq && vm && vo)) { intab = 1 }
      next
    }
    if ($0 ~ /^[[:space:]]*\|[-:| \t]*$/) next
    if ($0 ~ /^[[:space:]]*\| *AC[0-9]+/) { if (match($0, /AC[0-9]+/)) print substr($0, RSTART, RLENGTH) }
    next
  }
  { intab = 0 }
' "$handoff" | awk '!seen[$0]++')

if [ -z "$acs" ]; then
  echo "MISSING ac-table (no AC table with an Expected Evidence header, or no AC row in it)"
  rc=1
elif ! printf '%s\n' "$acr" | command grep -q '^|'; then
  echo "MISSING section ## AC runs"
  rc=1
fi
classify "$acr" "$acs"
for id in $acs; do settle "$id" AC AC; done

# ---- real_paths of the handoff front matter
# The front matter may be preceded by a dispatch header: `dispatch_id:` /
# `dispatch_history:` key lines and blank lines (the dispatch_id_rule form of
# conductor-protocol) — at most 4 skipped lines, and at least one dispatch key
# line must have been seen before the opening `---` counts. Any other leading
# content ends the scan exactly as before: no tolerance for arbitrary headers.
ids=$(awk '
  BEGIN { st = 0; key = 0; skipped = 0 }
  st == 0 {
    if ($0 == "---") { if (NR == 1 || key) { st = 1 } else { exit } next }
    if ($0 ~ /^dispatch_(id|history):/ || $0 == "") {
      if ($0 != "") key = 1
      skipped++; if (skipped > 4) exit
      next
    }
    exit
  }
  st == 1 && $0 == "---" { exit }
  st == 1 && /^real_paths:/ { on = 1; next }
  st == 1 && on && /^[^[:space:]-]/ { on = 0 }
  st == 1 && on && /^[[:space:]]*- id:/ { sub(/^[[:space:]]*- id:[[:space:]]*/, ""); gsub(/["'\'']/, ""); sub(/[[:space:]].*$/, ""); print }
' "$handoff")
if [ -z "$ids" ]; then
  echo "MISSING real_paths"
  rc=1
fi
# A verdict may file Real paths as a list instead of a table (r4 phase5 run
# file): only when the section yields no table data rows, harvest its list
# items into a synthetic table appended to the section text and classify
# that; otherwise classify the section exactly as before.
rptext="$rp"
if [ -z "$(tabrows "$rp" | awk -F '\037' '$1 != "NOCOL" && $0 != "" { print; exit }')" ]; then
  synth=$(rpharvest "$rp")
  if [ -n "$synth" ]; then
    rptext=$(printf '%s\n| id | result | output pointer |\n| --- | --- | --- |\n%s' "$rp" "$synth")
  fi
fi
classify "$rptext" "$ids"
for id in $ids; do settle "$id" COVERED COVERED; done
fi   # handoff mode

# ---- bug evidence (review-contract.md §10): only for a marked matter
bmarks=""
bmark() { if [ -z "$bmarks" ]; then bmarks="$1"; else bmarks="$bmarks,$1"; fi; }
if [ "$mode" = handoff ]; then
# m1: ## Reproduction section holding a repro: line
if awk '!on { if ($0 ~ /^## Reproduction[[:space:]]*$/) on = 1; next } /^## / { exit } /^[[:space:]]*(- )?repro:/ { f = 1; exit } END { exit !f }' "$handoff" 2>/dev/null; then
  bmark "reproduction:$handoff"
fi
# m3: the handoff's Epic line names an Epic whose ## Requirement marks this phase
eline=$(command grep -m1 -E '^\*\*Epic:\*\*[[:space:]]*[^[:space:]]+[[:space:]]*\(Phase[[:space:]]*[0-9]+' "$handoff" 2>/dev/null)
if [ -n "$eline" ]; then
  ename=$(printf '%s\n' "$eline" | sed -E 's/^\*\*Epic:\*\*[[:space:]]*([^[:space:]]+).*/\1/')
  ephase=$(printf '%s\n' "$eline" | sed -E 's/.*\(Phase[[:space:]]*([0-9]+).*/\1/')
  case "$handoff" in /*) habs="$handoff" ;; *) habs="$PWD/$handoff" ;; esac
  eroot=""
  case "$habs" in */.tad/*) eroot="${habs%/.tad/*}" ;; esac
  efile=""
  case "$ename" in
    */*|"") ;;
    *)
      if [ -n "$eroot" ]; then
        if [ -f "$eroot/.tad/active/epics/$ename" ] && [ -r "$eroot/.tad/active/epics/$ename" ]; then
          efile="$eroot/.tad/active/epics/$ename"
        elif [ -f "$eroot/.tad/archive/epics/$ename" ] && [ -r "$eroot/.tad/archive/epics/$ename" ]; then
          efile="$eroot/.tad/archive/epics/$ename"
        fi
      fi ;;
  esac
  if [ -n "$efile" ] && P="$ephase" awk 'BEGIN { p = ENVIRON["P"] } !on { if ($0 ~ /^## Requirement[[:space:]]*$/) on = 1; next } /^## / { exit } index($0, "- **Bug fix**:") == 1 || index($0, "- **Bug fix (phase " p ")**:") == 1 { f = 1; exit } END { exit !f }' "$efile" 2>/dev/null; then
    bmark "epic:$efile"
  fi
fi
else
# m2 (journal mode): line n holds bug_fix: anywhere on it
case "$jline" in *bug_fix:*) bmark "journal:$jp:$jn" ;; esac
fi
# m4: the verdict's judged: completion report holds a bug_repro: line
judged=$(awk 'NR == 1 && $0 != "---" { exit } NR == 1 { next } $0 == "---" { exit } /^judged:/ { sub(/^judged:[[:space:]]*/, ""); sub(/[[:space:]].*$/, ""); print; exit }' "$vf")
brepro=""
if [ -n "$judged" ] && [ -f "$judged" ] && [ -r "$judged" ]; then
  brepro=$(command grep -m1 -E '^bug_repro: [^[:space:]]' "$judged" 2>/dev/null)
  [ -n "$brepro" ] && bmark "completion:$judged"
fi

if [ -n "$bmarks" ]; then
  echo "BUGFIX marked by $bmarks"
  if ! command grep -Eq '^## Bug evidence[[:space:]]*$' "$vf"; then
    echo "MISSING section ## Bug evidence"
    rc=1
  else
    be=$(secof '^## Bug evidence[[:space:]]*$')
    # item \037 result cell, one line per data row, by header name
    berows=$(printf '%s\n' "$be" | awk '
      function cells(line,   t, n, i) {
        gsub(/\\\|/, "\036", line)
        sub(/^[[:space:]]*\|/, "", line); sub(/\|[[:space:]]*$/, "", line)
        n = split(line, c, "|")
        for (i = 1; i <= n; i++) {
          t = c[i]; gsub(/\036/, "|", t)
          sub(/^[[:space:]]+/, "", t); sub(/[[:space:]]+$/, "", t)
          gsub(/\037/, " ", t); c[i] = t
        }
        return n
      }
      !/^[[:space:]]*\|/ { next }
      !hdr { hdr = 1; n = cells($0); sc = 0; for (i = 2; i <= n; i++) if (tolower(c[i]) == "result") { sc = i; break } ; next }
      /^[[:space:]]*\|[-:| [:space:]]*$/ { next }
      { n = cells($0); s = (sc && sc <= n) ? c[sc] : ""; print tolower(c[1]) "\037" s }
    ')
    for item in before-file after-file rerun-unfixed rerun-fixed; do
      found=0; cell=""
      while IFS="$us" read -r bid bst; do
        [ "$bid" = "$item" ] || continue
        found=1; cell="$bst"; break
      done <<EOF
$berows
EOF
      lc=$(printf '%s' "$cell" | tr 'A-Z' 'a-z')
      if [ "$found" -eq 0 ]; then
        case "$item" in
          rerun-*) if notrun_ok "$item"; then echo "BUG $item not-run"; continue; fi ;;
        esac
        echo "MISSING bug-evidence $item"; rc=1; continue
      fi
      if [ "$lc" = pass ]; then echo "BUG $item pass"; continue; fi
      case "$item" in
        rerun-*)
          if printf '%s\n' "$lc" | command grep -Eq '^not-run:[[:space:]]*[^[:space:]]'; then echo "BUG $item not-run"; continue; fi
          if [ "$item" = rerun-unfixed ] && printf '%s\n' "$lc" | command grep -Eq '^not-rebuildable:[[:space:]]*[^[:space:]]'; then echo "BUG $item not-run"; continue; fi
          if printf '%s\n' "$lc" | command grep -Eq '^not-run:?[[:space:]]*$' && notrun_ok "$item"; then echo "BUG $item not-run"; continue; fi ;;
      esac
      echo "UNEXPLAINED bug-evidence $item result '$cell'"; rc=1
    done
  fi
  case "$brepro" in
    "bug_repro: not-reproduced"*) echo "MISSING bug-evidence fix (bug_repro: not-reproduced is a BF3 stop, not a Gate 3)"; rc=1 ;;
  esac
fi

exit $rc
