#!/bin/bash
# cora-check.sh — Cora's mechanical checks (cora-loop-fixes Phase 2).
# Advisory CLI, NEVER a hook: do not register it in settings, hooks.json or any
# plugin. No `set -e` on purpose (greps that do not match are a normal outcome).
# Runs under macOS /bin/bash 3.2 and BSD tools: no mapfile, no assoc arrays, no
# globstar; every file set is listed by `find`.
#
# Usage (run from the repo root, the directory that holds .tad/):
#   cora-check.sh dispatches <.tad/{active,archive}/epics/EPIC-....md>
#   cora-check.sh gate4-record <gate report .md>
# Exit: 0 = fine, 1 = ALARM / MISSING, 2 = usage (also: not run from a root, absolute
#       or odd Epic path, unreadable file, no `estimate <N>` on the Budget line).
#
# dispatches: counts this Epic's dispatches from the files on disk: ids in the first
#   15 lines of every *.md under .tad/evidence/yolo/<slug>/ (any depth) and of the
#   handoffs HANDOFF-<date>-<slug>-phase<n>.md (active + archive), read from
#   `dispatch_id:` and `dispatch_history:`; plus the ids of the Epic's `Dispatched:`
#   lines (a dispatch in flight is spent). An id ending -t<m> counts m, merged with
#   its base. ALARM (exit 1) when count + 1 >= 2 x estimate: the next dispatch would be
#   the 2E-th. Per `Dispatched:` line prints present / other-id <x> / missing.
# gate4-record: the `## For the human` section of a Gate 4 report holds a
#   `light acceptance: <reason>` line, or at least one `real use: <path> ...` line and
#   every such path exists (paths from the current directory).

usage() {
  echo "Usage: cora-check.sh dispatches <.tad/{active,archive}/epics/EPIC-*.md> | gate4-record <report.md>" >&2
  exit 2
}

# first15 FILE : the first 15 lines
first15() { head -15 "$1" 2>/dev/null; }

# idof FILE : the dispatch_id of FILE (first 15 lines), "none" when it carries none
idof() {
  local v
  v=$(first15 "$1" | sed -nE 's/^[#[:space:]]*dispatch_id:[[:space:]]*([^[:space:]]+).*/\1/p' | head -1)
  case "$v" in ''|*'{'*) echo none ;; *) echo "$v" ;; esac
}

# idsof FILE : every id the file carries (dispatch_id + dispatch_history), one per line
idsof() {
  first15 "$1" | sed -nE 's/^[#[:space:]]*(dispatch_id|dispatch_history):[[:space:]]*(.*)$/\2/p' |
    tr ',' ' ' | tr -s ' ' '\n' | sed '/^$/d' | command grep -v '[{}]'
}

cmd_dispatches() {
  local epic="$1" slug est ids runs line id paths t p cnt guard st first_other present other
  [ -n "$epic" ] && [ -d .tad ] || usage
  case "$epic" in
    .tad/active/epics/*|.tad/archive/epics/*) ;;
    *) usage ;;
  esac
  case "$epic" in *..*) usage ;; esac
  [ -f "$epic" ] && [ -r "$epic" ] || usage
  slug=$(sed -nE 's/^\*\*Epic ID\*\*:[[:space:]]*EPIC-[0-9]{8}-([A-Za-z0-9_-]+).*/\1/p' "$epic" | head -1)
  [ -n "$slug" ] || usage
  est=$(command grep -m1 '^\*\*Budget\*\*:' "$epic" | sed -nE 's/.*estimate[[:space:]]+([0-9]+).*/\1/p')
  [ -n "$est" ] || { echo "cora-check.sh: no 'estimate <N>' on the Budget line of $epic" >&2; exit 2; }

  ids=""
  # evidence tree, any depth, listed by find
  while IFS= read -r p; do
    [ -n "$p" ] || continue
    ids="$ids
$(idsof "$p")"
  done <<EOF_E
$(find ".tad/evidence/yolo/$slug" -type f -name '*.md' 2>/dev/null)
EOF_E
  # handoffs of this Epic only: exact HANDOFF-<date>-<slug>-phase<digits>.md
  while IFS= read -r p; do
    [ -n "$p" ] || continue
    printf '%s\n' "$(basename "$p")" | command grep -Eq "^HANDOFF-[0-9]{4}-[0-9]{2}-[0-9]{2}-$slug-phase[0-9]+\.md$" || continue
    ids="$ids
$(idsof "$p")"
  done <<EOF_H
$(find .tad/active/handoffs .tad/archive/handoffs -maxdepth 1 -type f -name "HANDOFF-*-$slug-phase*.md" 2>/dev/null)
EOF_H

  # Dispatched: lines of the Epic
  runs=$(command grep '^Dispatched:' "$epic")
  out=""
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    rest="${line#Dispatched:}"
    id=$(printf '%s\n' "$rest" | tr -s ' ' '\n' | sed '/^$/d' | head -1)
    case "$id" in ''|'—'|'-'|'--'|*'{'*) continue ;; esac
    ids="$ids
$id"
    paths=""
    case "$rest" in
      *'->'*) paths=$(printf '%s\n' "${rest#*->}" | tr '| ' '\n\n' | sed -E 's/[,;)]+$//; s/^\(//' | command grep -E '\.md$') ;;
    esac
    present=0; other=""; first_other=1
    while IFS= read -r p; do
      [ -n "$p" ] || continue
      if [ -f "$p" ]; then
        t=$(idof "$p")
        if [ "$t" = "$id" ]; then present=1; fi
        if [ "$first_other" = 1 ]; then other="$t"; first_other=0; fi
      fi
    done <<EOF_P
$paths
EOF_P
    if [ "$present" = 1 ]; then st="present"
    elif [ "$first_other" = 0 ]; then st="other-id $other"
    else st="missing"; fi
    out="$out
dispatched $id: $st"
  done <<EOF_R
$runs
EOF_R

  cnt=$(printf '%s\n' "$ids" | sed '/^$/d' | awk '
    { id = $0
      if (match(id, /-t[0-9]+$/)) { base = substr(id, 1, RSTART - 1); m = substr(id, RSTART + 2) + 0 }
      else { base = id; m = 1 }
      if (!(base in w) || m > w[base]) w[base] = m }
    END { n = 0; for (b in w) n += w[b]; print n }')
  guard=$((est * 2))
  echo "count: $cnt"
  echo "estimate: $est"
  echo "guard: $guard"
  printf '%s\n' "$out" | sed '/^$/d'
  if [ $((cnt + 1)) -ge "$guard" ]; then
    echo "ALARM: the next dispatch would be number $((cnt + 1)) of a guard of $guard (twice the estimate $est); stop and ask before it goes out"
    exit 1
  fi
  exit 0
}

cmd_gate4() {
  local rep="$1" sec lights reals bad=0 p n r
  [ -n "$rep" ] && [ -f "$rep" ] && [ -r "$rep" ] || usage
  sec=$(awk '
    on && /^#/ { exit }
    !on && /^#{2,4} For the human/ { on = 1; next }
    on { print }' "$rep")
  r=$(printf '%s\n' "$sec" | command grep 'light acceptance:' | sed -E 's/.*light acceptance:[[:space:]]*//; s/[[:space:]]*\|.*$//; s/[[:space:]]+$//' | command grep -v '^$' | head -1)
  if [ -n "$r" ]; then
    echo "OK light acceptance: $r"
    exit 0
  fi
  if printf '%s\n' "$sec" | command grep -q 'light acceptance:'; then
    echo "MISSING light acceptance: reason is empty"
    bad=1
  fi
  reals=$(printf '%s\n' "$sec" | command grep -o 'real use: [^ |]*' | sed 's/^real use: //')
  n=0
  while IFS= read -r p; do
    [ -n "$p" ] || continue
    n=$((n + 1))
    if [ -e "$p" ]; then echo "OK real use: $p"; else echo "MISSING real use path: $p"; bad=1; fi
  done <<EOF_G
$reals
EOF_G
  if [ "$n" -eq 0 ]; then
    echo "MISSING real use: or light acceptance: line in ## For the human"
    bad=1
  fi
  [ "$bad" -eq 0 ] && exit 0
  exit 1
}

case "$1" in
  dispatches) cmd_dispatches "$2" ;;
  gate4-record) cmd_gate4 "$2" ;;
  *) usage ;;
esac
