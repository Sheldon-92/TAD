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
#   cora-check.sh gate3-files <.tad/{active,archive}/epics/EPIC-....md> <phase N>
# Exit: 0 = fine (a CHECKPOINT line is still exit 0), 1 = ALARM / MISSING, 2 = usage (also: not run from a root, absolute
#       or odd Epic path, unreadable file). An Epic whose Budget line has no
#       `estimate <N>` (or a leading `约 N 次派发` / `N dispatches`) is not an error: `dispatches` prints the count and
#       `estimate: none (old Epic; no checkpoint or alarm)` and exits 0.
#
# dispatches: counts this Epic's dispatches from the files on disk: ids in the first
#   15 lines of every *.md under .tad/evidence/yolo/<slug>/ (any depth) and of the
#   handoffs HANDOFF-<date>-<slug>-phase<n>.md (active + archive), read from
#   `dispatch_id:` and `dispatch_history:`; plus the ids of the Epic's `Dispatched:`
#   lines (a dispatch in flight is spent). An id ending -t<m> counts m, merged with
#   its base. Prints `checkpoint: 2E` and `guard: 3E`. CHECKPOINT (exit 0) when
#   count + 1 >= 2E and < 3E: Cora's own re-route point (cora SKILL.md, Route and
#   spend). ALARM (exit 1) when count + 1 >= 3E: the next dispatch would be the
#   3E-th, the stop. A `carried-spent <N>` on the Budget line (Up 5) is added to the count. Per `Dispatched:` line prints present / other-id <x> / missing.
# gate3-files: by file name only, in .tad/evidence/yolo/<slug>/ (cwd = repo root): the
#   Gate 3 files the protocol (step_Y6) requires for phase N exist: the run verdict
#   phase<N>-gate3-verdict, the consistency review phase<N>-impl-review-consistency,
#   and phase<N>-impl-review-domain when the `risk_triggers:` header line of the
#   phase's latest risk or fit design review (phase<N>-design-review-risk|fit) names
#   security, data or money. For each, the latest round counts (`<base>.md` is round 1,
#   `<base>-r<k>.md` round k). Prints `OK <file>` or `MISSING <what>`; exit 1 on any
#   MISSING. It reads no verdict: it does not replace reading the headers.
# gate4-record: the `## For the human` section of a Gate 4 report holds a
#   `light acceptance: <reason>` line, or at least one `real use: <path> ...` line and
#   every such path exists (paths from the current directory).

usage() {
  echo "Usage: cora-check.sh dispatches <.tad/{active,archive}/epics/EPIC-*.md> | gate4-record <report.md> | gate3-files <.tad/{active,archive}/epics/EPIC-*.md> <phase N>" >&2
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
  local epic="$1" slug est ids runs line id paths t p cnt chk guard st first_other present other
  [ -n "$epic" ] && [ -d .tad ] || usage
  case "$epic" in
    .tad/active/epics/*|.tad/archive/epics/*) ;;
    *) usage ;;
  esac
  case "$epic" in *..*) usage ;; esac
  [ -f "$epic" ] && [ -r "$epic" ] || usage
  slug=$(sed -nE 's/^\*\*Epic ID\*\*:[[:space:]]*EPIC-[0-9]{8}-([A-Za-z0-9_-]+).*/\1/p' "$epic" | head -1)
  [ -n "$slug" ] || usage
  # Estimate from the Budget line (bytewise sed, so UTF-8 約/次派发 work under any locale):
  #   1. the number right after `estimate` (optionally `~`, `约` or `about` between);
  #   2. else a number that STARTS the Budget text (optionally after 约 / ~ / about / at most)
  #      and is directly followed by [subagent] dispatch(es) / 次派发 / 次;
  #   3. else none. A number later in the line is never read (a date such as
  #      `from 2026-10-16, ... 2 subagent dispatches` gives no estimate, not 2026 or 2).
  bline=$(command grep -m1 '^\*\*Budget\*\*:' "$epic")
  est=$(printf '%s\n' "$bline" | LC_ALL=C sed -nE 's/.*estimate[[:space:]]+(~|约|about[[:space:]]+)?[[:space:]]*([0-9]+).*/\2/p')
  [ -n "$est" ] || est=$(printf '%s\n' "$bline" | LC_ALL=C sed -nE 's/^\*\*Budget\*\*:[[:space:]]*(约|~|about|at most)?[[:space:]]*([0-9]+)[[:space:]]*(subagent[[:space:]]+)?(dispatch|次派发|次).*/\2/p')
  # no estimate (an old Epic): count anyway, note it, no alarm (est stays empty)

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
  # carried count (Up 5): a retriaged Epic's Budget line may say `carried-spent <N>`: the dispatches the former
  # simple task already spent. They are added, so the 3x guard counts all dispatches, not only this Epic's own.
  carried=$(printf '%s\n' "$bline" | LC_ALL=C sed -nE 's/.*carried-spent[[:space:]]+([0-9]+).*/\1/p')
  [ -n "$carried" ] && cnt=$((cnt + carried))
  echo "count: $cnt"
  if [ -z "$est" ]; then
    echo "estimate: none (old Epic; no checkpoint or alarm)"
    printf '%s\n' "$out" | sed '/^$/d'
    exit 0
  fi
  chk=$((est * 2))
  guard=$((est * 3))
  echo "estimate: $est"
  echo "checkpoint: $chk"
  echo "guard: $guard"
  printf '%s\n' "$out" | sed '/^$/d'
  if [ $((cnt + 1)) -ge "$guard" ]; then
    echo "ALARM: the next dispatch would be number $((cnt + 1)) of a guard of $guard (three times the estimate $est); stop and tell the human before it goes out"
    exit 1
  fi
  if [ $((cnt + 1)) -ge "$chk" ]; then
    echo "CHECKPOINT: the next dispatch would be number $((cnt + 1)); twice the estimate $est: re-route (cora SKILL.md Route and spend) and record why"
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

# latestof SLUGDIR PREFIX : latest round file of PREFIX (`PREFIX.md` = round 1,
# `PREFIX-r<k>.md` = round k), found by `find`; prints the path or nothing
latestof() {
  find "$1" -maxdepth 1 -type f \( -name "$2.md" -o -name "$2-r*.md" \) 2>/dev/null | awk -v pre="$1/$2" '
    { f = $0; k = 0; ok = 0
      if (f == pre ".md") { k = 1; ok = 1 }
      else if (index(f, pre "-r") == 1) {
        t = substr(f, length(pre) + 3); sub(/\.md$/, "", t)
        if (t ~ /^[0-9]+$/) { k = t + 0; ok = 1 }
      }
      if (ok && k >= best) { best = k; bf = f } }
    END { if (bf != "") print bf }'
}

cmd_gate3files() {
  local epic="$1" n="$2" slug dir f rt need bad=0 base
  [ -n "$epic" ] && [ -n "$n" ] && [ -d .tad ] || usage
  case "$epic" in
    .tad/active/epics/*|.tad/archive/epics/*) ;;
    *) usage ;;
  esac
  case "$epic" in *..*) usage ;; esac
  case "$n" in ''|*[!0-9]*) usage ;; esac
  [ -f "$epic" ] && [ -r "$epic" ] || usage
  slug=$(sed -nE 's/^\*\*Epic ID\*\*:[[:space:]]*EPIC-[0-9]{8}-([A-Za-z0-9_-]+).*/\1/p' "$epic" | head -1)
  [ -n "$slug" ] || usage
  dir=".tad/evidence/yolo/$slug"
  need="gate3-verdict impl-review-consistency"
  # domain lens: the latest risk or fit design review of the phase lists security, data or money
  rt=""
  f=$(latestof "$dir" "phase$n-design-review-risk")
  [ -n "$f" ] || f=$(latestof "$dir" "phase$n-design-review-fit")
  if [ -n "$f" ]; then
    rt=$(first15 "$f" | command grep -m1 '^risk_triggers:')
    if printf '%s\n' "$rt" | command grep -Eiq 'security|data|money'; then
      need="$need impl-review-domain"
    fi
  else
    echo "note: no risk or fit design review file for phase $n in $dir; domain file not decidable"
  fi
  for base in $need; do
    f=$(latestof "$dir" "phase$n-$base")
    if [ -n "$f" ]; then echo "OK $f"; else echo "MISSING $dir/phase$n-$base.md (or its -r<k> round file)"; bad=1; fi
  done
  [ "$bad" -eq 0 ] && exit 0
  exit 1
}

case "$1" in
  dispatches) cmd_dispatches "$2" ;;
  gate4-record) cmd_gate4 "$2" ;;
  gate3-files) cmd_gate3files "$2" "$3" ;;
  *) usage ;;
esac
