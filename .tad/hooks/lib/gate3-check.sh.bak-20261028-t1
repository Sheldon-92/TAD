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
        if (!sc && (h == "result" || h == "status")) sc = i
        if (!ec && (h ~ /output/ || h ~ /pointer/ || h ~ /evidence/)) ec = i
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
# a markdown table row whose cells include `Expected Evidence` and an AC-criterion
# column (`Acceptance Criterion`/`Acceptance Criteria`/`Criterion`); the rows below it
# (until the table ends) are read, first cell `AC<n>`.
acs=$(awk '
  function lowcells(line,   n, i, t) {
    n = split(line, c, "|")
    for (i = 1; i <= n; i++) { t = tolower(c[i]); gsub(/^[ \t]+|[ \t]+$/, "", t); c[i] = t }
    return n
  }
  /^[[:space:]]*\|/ {
    if (!intab) {
      n = lowcells($0); ev = 0; cr = 0
      for (i = 1; i <= n; i++) {
        if (c[i] ~ /^expected evidence/) ev = 1
        if (c[i] ~ /^(acceptance criteri|criterion)/) cr = 1
      }
      if (ev && cr) { intab = 1 }
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
classify "$rp" "$ids"
for id in $ids; do settle "$id" COVERED COVERED; done

exit $rc
