#!/bin/bash
# gate3-check.sh — Gate 3 evidence check (review-redesign Phase 3, rework 3).
# Advisory CLI, NEVER a hook: do not register it in settings, hooks.json or any
# plugin. No `set -e` on purpose.
#
# It executes nothing from the handoff. The acceptance commands (§9.1) and every
# real_path are run by the independent run reviewer, by hand, in one throwaway copy
# of the project; this script only reads the run reviewer's verdict file and checks
# that the evidence is complete:
#   - the verdict file exists;
#   - every AC row of the handoff's §9.1 table has a row in `## AC runs`
#     (`| AC<n>... | command | exit | result |`, result cell not empty) or is listed
#     in `## Not run` with a reason;
#   - every real_paths id of the handoff front matter has a row in `## Real paths`,
#     is listed in `## Not run` with a reason, or is listed in `## Blocked`;
#   - every row of `## Real paths` is classified (see "Real paths table" below);
#   - every line of `## Not run` reads `- <id> not-run: <reason>` with a reason, and
#     every not-run result cell in `## AC runs` is explained there.
# ID matching is ASCII only (AC<n>, RP ids); headings and table text may hold CJK.
#
# Real paths table (column parsing, by header name, not by position):
#   The first `|` line of the section is the header; the `|---|` line is skipped.
#   Cells are split on `|` (an escaped `\|` stays inside its cell) and trimmed.
#   Columns are found by header name, case-insensitive: id = first column;
#   status = the column named `result` or `status`; evidence = the column whose
#   name holds `output`, `pointer` or `evidence`. Extra columns are ignored.
#   No status column or no evidence column => every row is invalid.
#   The status cell is normalised (lower case, `-`/`_` -> space) and classified:
#     run      first word pass|passed|ok|fail|failed|run|ran|done, AND the evidence
#              cell is non-empty and not `-`, `n/a`, `none`;
#     not-run  starts with `not run`, `notrun`, `skip` (Not-run, NOT RUN, skipped,
#              not_run ...); valid only with a non-empty reason: text after `:` in
#              the cell, or a `- <id> not-run: <reason>` line in `## Not run`;
#     blocked  starts with `blocked`; valid only when the id is in `## Blocked`;
#     invalid  anything else: empty status, unknown word, a run row without
#              evidence, a not-run/blocked row without its reason/listing, a row
#              whose id is not a real_paths id of the handoff.
#   An invalid row prints `UNEXPLAINED <id> invalid: <why>` (so consumers keyed on
#   MISSING/UNEXPLAINED fail it). An id is `COVERED <id> run` only when it has a
#   valid run row and no invalid row.
#
# Usage:
#   gate3-check.sh <handoff> <verdict-file>
#       prints AC <ID> run | AC <ID> not-run | COVERED <ID> run | COVERED <ID> not-run |
#              BLOCKED <ID> | MISSING <what> | UNEXPLAINED <ID> [invalid: <why>]
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
[ -f "$handoff" ] && [ -r "$handoff" ] || usage

if [ ! -f "$vf" ] || [ ! -r "$vf" ]; then
  echo "MISSING evidence file $vf"
  exit 1
fi

rc=0
set -f   # ids come from the handoff and are word-split below: no glob expansion

# section body of the verdict file: heading regex -> lines up to the next "## "
secof() {
  H="$1" awk 'BEGIN{h=ENVIRON["H"]} !on { if ($0 ~ h) on = 1; next } /^## / { exit } { print }' "$vf"
}
acr=$(secof '^## AC runs')
rp=$(secof '^## Real paths')
nr=$(secof '^## Not run')
bl=$(secof '^## Blocked')

# last table cell of the first row that starts with <id> (exact id, or id/sub-row)
lastcell() { # $1 = section text, $2 = id
  printf '%s\n' "$1" | command grep -E "^\\| *$2(/[A-Za-z0-9_-]+)? *\\|" | head -1 |
    sed -E 's/[[:space:]]*\|[[:space:]]*$//; s/.*\|//; s/^[[:space:]]+//; s/[[:space:]]+$//'
}
# 0 when <id> is listed in ## Not run with a non-empty reason
notrun_ok() { # $1 = id
  printf '%s\n' "$nr" | command grep -E -- "^- *$1(/[A-Za-z0-9_-]+)? +not-run: *[^[:space:]]" >/dev/null
}
# normalised status word class of a result cell: run | notrun | blocked | empty | other
stclass() { # $1 = cell
  n=$(printf '%s' "$1" | tr 'A-Z_-' 'a-z  ' | sed -E 's/^[[:space:]]+//; s/[[:space:]]+/ /g')
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

# ---- AC rows of the handoff's §9.1 table
acs=$(awk '
  !on { if ($0 ~ /^## 9\.1/) on = 1; next }
  /^## / { exit }
  /^\| *AC[0-9]+/ { if (match($0, /AC[0-9]+/)) print substr($0, RSTART, RLENGTH) }
' "$handoff" | awk '!seen[$0]++')

if [ -z "$acs" ]; then
  echo "MISSING ac-table (no AC row in the handoff's §9.1)"
  rc=1
elif ! printf '%s\n' "$acr" | command grep -q '^|'; then
  echo "MISSING section ## AC runs"
  rc=1
fi

for id in $acs; do
  last=$(lastcell "$acr" "$id")
  case "$(stclass "$last")" in
    notrun)
      if notrun_ok "$id"; then echo "AC $id not-run"; else echo "UNEXPLAINED $id"; rc=1; fi ;;
    empty)
      if notrun_ok "$id"; then echo "AC $id not-run"; else echo "MISSING $id"; rc=1; fi ;;
    *)
      echo "AC $id run" ;;
  esac
done

# ---- real_paths of the handoff front matter
ids=$(awk '
  NR == 1 && $0 != "---" { exit }
  NR > 1 && $0 == "---" { exit }
  /^real_paths:/ { on = 1; next }
  on && /^[^[:space:]-]/ { on = 0 }
  on && /^[[:space:]]*- id:/ { sub(/^[[:space:]]*- id:[[:space:]]*/, ""); gsub(/["'\'']/, ""); sub(/[[:space:]].*$/, ""); print }
' "$handoff")
if [ -z "$ids" ]; then
  echo "MISSING real_paths"
  rc=1
fi
# ---- ## Real paths table: one line per data row: id, status cell, evidence cell,
# separated by \037 (not tab: IFS whitespace would collapse an empty cell)
# (or a single "NOCOL <name>" line when the header lacks a needed column)
rows=$(printf '%s\n' "$rp" | awk '
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
    hdr = 1; n = cells($0); sc = 0; ec = 0
    for (i = 2; i <= n; i++) {
      h = tolower(c[i])
      if (!sc && (h == "result" || h == "status")) sc = i
      if (!ec && (h ~ /output/ || h ~ /pointer/ || h ~ /evidence/)) ec = i
    }
    if (!sc) print "NOCOL\037result/status"
    if (!ec) print "NOCOL\037output pointer/evidence"
    next
  }
  /^[[:space:]]*\|[-:| [:space:]]*$/ { next }
  {
    n = cells($0)
    s = (sc && sc <= n) ? c[sc] : ""
    e = (ec && ec <= n) ? c[ec] : ""
    print c[1] "\037" s "\037" e
  }
')
nocol=$(printf '%s\n' "$rows" | awk -F '\037' '$1 == "NOCOL" { print $2 }' | paste -sd ';' -)
us=$(printf '\037')
okids=" "    # ids with a valid run row
nrids=" "    # ids with a valid not-run row
blids=" "    # ids with a valid blocked row
badids=" "   # ids with an invalid row
while IFS="$us" read -r rid st ev; do
  [ -n "$rid" ] || continue
  [ "$rid" = NOCOL ] && continue
  base=${rid%%/*}
  why=""
  known=0
  for k in $ids; do [ "$k" = "$base" ] && known=1; done
  if [ "$known" -eq 0 ]; then
    why="row id is not a real_paths id of the handoff"
  elif [ -n "$nocol" ]; then
    why="table has no $nocol column"
  else
    case "$(stclass "$st")" in
      run)
        evn=$(printf '%s' "$ev" | tr 'A-Z' 'a-z')
        case "$evn" in
          ""|-|n/a|na|none) why="run row without evidence (output pointer empty)" ;;
          *) okids="$okids$base " ;;
        esac ;;
      notrun)
        if cellreason_ok "$st" || notrun_ok "$base"; then nrids="$nrids$base "
        else why="not-run without a reason (cell or ## Not run)"; fi ;;
      blocked)
        if printf '%s\n' "$bl" | command grep -Eq -- "(^|[^A-Za-z0-9_-])${base}([^A-Za-z0-9_-]|\$)"; then blids="$blids$base "
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

for id in $ids; do
  pat="(^|[^A-Za-z0-9_-])${id}([^A-Za-z0-9_-]|\$)"
  case "$badids" in *" $id "*) continue ;; esac   # already reported
  case "$okids" in
    *" $id "*) echo "COVERED $id run"; continue ;;
  esac
  if case "$nrids" in *" $id "*) true ;; *) false ;; esac || notrun_ok "$id"; then
    echo "COVERED $id not-run"
  elif case "$blids" in *" $id "*) true ;; *) false ;; esac ||
       printf '%s\n' "$bl" | command grep -Eq -- "$pat"; then
    echo "BLOCKED $id"
  else
    echo "MISSING $id"
    rc=1
  fi
done

exit $rc
