#!/bin/bash
# gate3-check.sh — Gate 3 AC re-run and real_path coverage (review-redesign Phase 3).
# Advisory CLI, NEVER a hook: do not register it in settings, hooks.json or any
# plugin. No `set -e` on purpose.
#
# SECURITY: `rerun` EXECUTES command lines read from a handoff file — the same
# commands a reviewer runs by hand, no wider trust. A handoff's §9.1 commands must
# be read-only (scratch writes only through `mktemp -d`). Outward or destructive
# commands are never executed (see DENY below); they are recorded as not-run.
#
# Usage:
#   gate3-check.sh rerun <handoff> [--out <file>] [--id <dispatch_id>]
#       exit 0 always (it records; judging is the reviewer's), 2 on usage.
#   gate3-check.sh paths <handoff> <verdict-file>
#       prints COVERED <ID> run | COVERED <ID> not-run | BLOCKED <ID> | MISSING <ID>
#       exit 0 when no MISSING (BLOCKED lines allowed: the verdict rule caps them),
#       1 on any MISSING or when the handoff has no real_paths, 2 on usage.

usage() {
  echo "Usage: gate3-check.sh rerun <handoff> [--out <file>] [--id <dispatch_id>]" >&2
  echo "       gate3-check.sh paths <handoff> <verdict-file>" >&2
  exit 2
}

[ $# -ge 2 ] || usage
cmd="$1"; shift
handoff="$1"; shift
[ -f "$handoff" ] && [ -r "$handoff" ] || usage

DENY='git push|git tag [^-]|npm publish|gh release|rm -rf|sudo |curl .*\| *(sh|bash|zsh)'

# ---------------------------------------------------------------- paths
if [ "$cmd" = paths ]; then
  [ $# -eq 1 ] || usage
  vf="$1"
  [ -f "$vf" ] && [ -r "$vf" ] || usage
  ids=$(awk '
    NR == 1 && $0 != "---" { exit }
    NR > 1 && $0 == "---" { exit }
    /^real_paths:/ { on = 1; next }
    on && /^[^[:space:]-]/ { on = 0 }
    on && /^[[:space:]]*- id:/ { sub(/^[[:space:]]*- id:[[:space:]]*/, ""); gsub(/["'\'']/, ""); sub(/[[:space:]].*$/, ""); print }
  ' "$handoff")
  if [ -z "$ids" ]; then
    echo "MISSING real_paths"
    exit 1
  fi
  secof() { # heading-regex -> section body of the verdict file
    H="$1" awk 'BEGIN{h=ENVIRON["H"]} !on { if ($0 ~ h) on = 1; next } /^## / { exit } { print }' "$vf"
  }
  rp=$(secof '^## Real paths')
  nr=$(secof '^## Not run')
  bl=$(secof '^## Blocked')
  rc=0
  for id in $ids; do
    pat="(^|[^A-Za-z0-9_-])${id}([^A-Za-z0-9_-]|\$)"
    last=$(printf '%s\n' "$rp" | command grep -E "^\\| *${id} *\\|" | head -1 | sed -E 's/[[:space:]]*\|[[:space:]]*$//; s/.*\|//; s/^[[:space:]]+//; s/[[:space:]]+$//')
    if [ -n "$last" ]; then
      echo "COVERED $id run"
    elif printf '%s\n' "$nr" | command grep -E -- "$pat" | command grep -q 'not-run:'; then
      echo "COVERED $id not-run"
    elif printf '%s\n' "$bl" | command grep -Eq -- "$pat"; then
      echo "BLOCKED $id"
    else
      echo "MISSING $id"
      rc=1
    fi
  done
  exit $rc
fi

# ---------------------------------------------------------------- rerun
[ "$cmd" = rerun ] || usage
out=""; rid=""
while [ $# -gt 0 ]; do
  case "$1" in
    --out) [ $# -ge 2 ] || usage; out="$2"; shift 2 ;;
    --id)  [ $# -ge 2 ] || usage; rid="$2"; shift 2 ;;
    *) usage ;;
  esac
done

root=$(git rev-parse --show-toplevel 2>/dev/null)
[ -n "$root" ] || { echo "gate3-check.sh: not inside a git work tree" >&2; exit 2; }
# resolve the handoff and --out before changing directory
case "$handoff" in /*) ;; *) handoff="$PWD/$handoff" ;; esac
if [ -n "$out" ]; then case "$out" in /*) ;; *) out="$PWD/$out" ;; esac; fi
sha=$(git -C "$root" rev-parse --short HEAD 2>/dev/null)

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

# Parse the §9.1 region into records: name<US>kind<US>payload  (kind: CMD | NS)
US=$(printf '\037')
S="$US" awk '
  function trim(x) { sub(/^[[:space:]]+/, "", x); sub(/[[:space:]]+$/, "", x); return x }
  BEGIN { us = ENVIRON["S"]; on = 0; fence = 0; nrows = 0; nb = 0 }
  !on { if ($0 ~ /^## 9\.1/) on = 1; next }
  /^## / { exit }
  /^```/ { fence = !fence; if (fence) { nb++; benv[nb] = "" } ; next }
  fence {
    if (match($0, /^[A-Za-z][A-Za-z0-9]*:[ \t]/)) {
      id = substr($0, 1, index($0, ":") - 1)
      rest = substr($0, index($0, ":") + 1); sub(/^[ \t]+/, "", rest)
      if (id == "ENV") { benv[nb] = rest }
      else if (!(id in idcmd)) { idcmd[id] = rest; idblk[id] = nb }
    }
    next
  }
  /^\|/ && !hdr && index($0, "Verification Method") {
    t = $0; gsub(/\\\|/, "\001", t); n = split(t, c, "|")
    for (i = 1; i <= n; i++) if (trim(c[i]) == "Verification Method") hdr = i
    next
  }
  /^\| *AC/ {
    if (!hdr) next
    t = $0; gsub(/\\\|/, "\001", t); n = split(t, c, "|")
    first = trim(c[2]); name = first
    if (match(first, /AC[0-9]+/)) name = substr(first, RSTART, RLENGTH)
    cell = trim(c[hdr + 0])
    nrows++; rname[nrows] = name; rcell[nrows] = cell
  }
  END {
    for (r = 1; r <= nrows; r++) {
      cell = rcell[r]; name = rname[r]
      if (cell ~ /^`[^`]*`$/) {
        cmd = substr(cell, 2, length(cell) - 2); gsub(/\001/, "|", cmd)
        printf "%s%sCMD%s%s\n", name, us, us, cmd
      } else if (cell ~ /^[A-Za-z][A-Za-z0-9]*(, *[A-Za-z][A-Za-z0-9]*)*$/) {
        m = split(cell, ids, /, */)
        for (k = 1; k <= m; k++) {
          id = ids[k]
          if (id in idcmd) {
            cmd = idcmd[id]; e = benv[idblk[id]]
            if (e != "") cmd = e "; " cmd
            printf "%s/%s%sCMD%s%s\n", name, id, us, us, cmd
          } else printf "%s/%s%sNS%s\n", name, id, us, us
        }
      } else printf "%s%sNS%s\n", name, us, us
    }
  }
' "$handoff" > "$work/rows.txt"

have_perl=0; command -v perl >/dev/null 2>&1 && have_perl=1

{
  [ -n "$rid" ] && echo "dispatch_id: $rid"
  echo "# AC re-run: $handoff @ $sha"
  [ "$have_perl" -eq 0 ] && echo "# note: perl absent, commands ran without a timeout"
  echo
  echo "| row | exit | command |"
  echo "|---|---|---|"
} > "$work/head.txt"
: > "$work/table.txt"
: > "$work/detail.txt"

while IFS= read -r line; do
  name="${line%%"$US"*}"
  rest="${line#*"$US"}"
  kind="${rest%%"$US"*}"
  payload="${rest#*"$US"}"
  if [ "$kind" = NS ]; then
    printf '| %s | not-scriptable |  |\n' "$name" >> "$work/table.txt"
    continue
  fi
  shown=$(printf '%s' "$payload" | sed 's/|/\\|/g')
  if printf '%s' "$payload" | command grep -Eq -- "$DENY"; then
    printf '| %s | not-run: outward or destructive — run by hand | %s |\n' "$name" "$shown" >> "$work/table.txt"
    continue
  fi
  if [ "$have_perl" -eq 1 ]; then
    (cd "$root" && perl -e 'alarm shift; exec @ARGV' 300 bash -c "$payload") > "$work/o.txt" 2>&1 < /dev/null
  else
    (cd "$root" && bash -c "$payload") > "$work/o.txt" 2>&1 < /dev/null
  fi
  ec=$?
  printf '| %s | %s | %s |\n' "$name" "$ec" "$shown" >> "$work/table.txt"
  { echo; echo "### $name"; echo '```'; head -40 "$work/o.txt"; echo '```'; } >> "$work/detail.txt"
done < "$work/rows.txt"

if [ -n "$out" ]; then
  cat "$work/head.txt" "$work/table.txt" "$work/detail.txt" > "$out"
else
  cat "$work/head.txt" "$work/table.txt" "$work/detail.txt"
fi
exit 0
