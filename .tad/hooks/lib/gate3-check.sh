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
#   - every line of `## Not run` reads `- <id> not-run: <reason>` with a reason, and
#     every `not-run` result cell in `## AC runs` is explained there.
# ID matching is ASCII only (AC<n>, RP ids); headings and table text may hold CJK.
#
# Usage:
#   gate3-check.sh <handoff> <verdict-file>
#       prints AC <ID> run | AC <ID> not-run | COVERED <ID> run | COVERED <ID> not-run |
#              BLOCKED <ID> | MISSING <what> | UNEXPLAINED <ID>
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
  case "$last" in
    not-run*)
      if notrun_ok "$id"; then echo "AC $id not-run"; else echo "UNEXPLAINED $id"; rc=1; fi ;;
    "")
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
for id in $ids; do
  pat="(^|[^A-Za-z0-9_-])${id}([^A-Za-z0-9_-]|\$)"
  last=$(lastcell "$rp" "$id")
  if [ -n "$last" ]; then
    echo "COVERED $id run"
  elif notrun_ok "$id"; then
    echo "COVERED $id not-run"
  elif printf '%s\n' "$bl" | command grep -Eq -- "$pat"; then
    echo "BLOCKED $id"
  else
    echo "MISSING $id"
    rc=1
  fi
done

exit $rc
