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
#   cora-check.sh judge-first <.tad/{active,archive}/epics/EPIC-....md> <phase N> <.tad/{active,archive}/handoffs/HANDOFF-....md>
#   cora-check.sh rounds <.tad/{active,archive}/epics/EPIC-....md> <phase N>
#   (judge-first and rounds take the slug by the same rule; rounds never exits 1.)
# Slug source (both epic-taking subcommands): the Epic's **Epic ID** line;
# when that line is absent, the slug falls back to the EPIC-<date>-<slug>
# filename. An ID line, when present, always wins over the filename.
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
# judge-first: run by Cora before every dispatch of the Gate 3 run reviewer (conductor
#   protocol step_Y6 1b). The handoff is the argument (Cora's {handoff_path}); it reads
#   the handoff's front matter (the lines before the first line starting `## `), keys
#   matched at line start only, so a `# rubric_ac: ...` comment line is not the key;
#   the first matching line wins. First match decides: (1) `task_type: deliverable`
#   or a non-empty `rubric_ref:` (not null/~) -> rubric AC (front matter); (2) a
#   `rubric_ac:` line: `none` (any case) -> no rubric AC, any other non-empty value ->
#   rubric AC (declared); (3) no such line or an empty value: the word rubric or judge
#   anywhere in the file -> rubric AC (inferred), neither -> no rubric AC. Then the
#   judge file phase<N>-rubric-verdict.md (latest -r<k>) in .tad/evidence/yolo/<slug>/.
#   Prints one line: `no rubric AC (...)` or `OK <judge file>` (exit 0), or
#   `MISSING <path> (rubric AC in <handoff>, <source>: ...)` (exit 1). Nothing else from
#   the handoff is printed. No exit is a stop: any non-zero exit costs at most one judge.
# rounds: run by Cora at step_Y7 1a only, into her journal (conductor protocol
#   rounds_record). Derives G2, G3, G4 and TOTAL_ROUNDS from the round-numbered review
#   files of phase N in .tad/evidence/yolo/<slug>/ (maxdepth 1): Gate 2
#   design-review-consistency|risk|fit, Gate 3 gate3-verdict|impl-review-consistency|
#   impl-review-domain, Gate 4 gate-report; `<base>.md` is round 1, `<base>-r<k>.md`
#   round k, other names are not rounds. A file's label is the first `verdict:` line of
#   its first 15 lines whose first word is PASS, CONDITIONAL, FAIL or PARTIAL, else
#   UNREADABLE; a round is the worst of its files (FAIL > PARTIAL > UNREADABLE >
#   CONDITIONAL > PASS) and counts unless PASS. Prints the four count lines and one
#   `unreadable: <path>` line per unreadable file; it compares no threshold and stops
#   nothing (review contract §7). Exit 0, usage 2.
# Both read only: no file or temp file written, no git, no network.

usage() {
  echo "Usage: cora-check.sh dispatches <.tad/{active,archive}/epics/EPIC-*.md> | gate4-record <report.md> | gate3-files <.tad/{active,archive}/epics/EPIC-*.md> <phase N> | judge-first <.tad/{active,archive}/epics/EPIC-*.md> <phase N> <.tad/{active,archive}/handoffs/HANDOFF-*.md> | rounds <.tad/{active,archive}/epics/EPIC-*.md> <phase N>" >&2
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
  # Filename fallback: only when the ID line above yields no slug.
  if [ -z "$slug" ]; then
    slug=$(basename "$epic" | sed -n 's/^EPIC-[0-9]\{8\}-\([A-Za-z0-9_-]*\)\.md$/\1/p')
  fi
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
  # Filename fallback: only when the ID line above yields no slug.
  if [ -z "$slug" ]; then
    slug=$(basename "$epic" | sed -n 's/^EPIC-[0-9]\{8\}-\([A-Za-z0-9_-]*\)\.md$/\1/p')
  fi
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

# epicslug EPIC : the slug of an Epic path checked as in gate3-files; prints it or calls usage
epicslug() {
  local epic="$1" slug
  case "$epic" in
    .tad/active/epics/*|.tad/archive/epics/*) ;;
    *) usage ;;
  esac
  case "$epic" in *..*) usage ;; esac
  [ -f "$epic" ] && [ -r "$epic" ] || usage
  slug=$(sed -nE 's/^\*\*Epic ID\*\*:[[:space:]]*EPIC-[0-9]{8}-([A-Za-z0-9_-]+).*/\1/p' "$epic" | head -1)
  # Filename fallback: only when the ID line above yields no slug.
  if [ -z "$slug" ]; then
    slug=$(basename "$epic" | sed -n 's/^EPIC-[0-9]\{8\}-\([A-Za-z0-9_-]*\)\.md$/\1/p')
  fi
  [ -n "$slug" ] || usage
  printf '%s\n' "$slug"
}

# fmval FRONTMATTER KEY : the value of the first line that starts with KEY: (the key at
# line start only, so a `# KEY: ...` comment line is not the key), with a ` #` comment,
# spaces, quotes and [ ] removed. Prints nothing when there is no such line.
fmval() {
  printf '%s\n' "$1" | sed -n "s/^$2:\(.*\)\$/\1/p" | head -1 |
    sed -E 's/[[:space:]]#.*$//' | sed -E "s/[][[:space:]\"']//g"
}

cmd_judgefirst() {
  local epic="$1" n="$2" h="$3" slug dir fm v tt rr src j
  [ -n "$epic" ] && [ -n "$n" ] && [ -n "$h" ] && [ -d .tad ] || usage
  case "$n" in ''|*[!0-9]*) usage ;; esac
  case "$h" in
    .tad/active/handoffs/*|.tad/archive/handoffs/*) ;;
    *) usage ;;
  esac
  case "$h" in *..*) usage ;; esac
  [ -f "$h" ] && [ -r "$h" ] || usage
  slug=$(epicslug "$epic") || exit 2
  [ -n "$slug" ] || usage
  dir=".tad/evidence/yolo/$slug"
  # front matter: the lines before the first line starting "## " (with or without ---)
  fm=$(awk '/^## /{exit} {print}' "$h")
  src=""
  # (1) front matter backstop (gate skill rubric_ac_trigger (b))
  tt=$(fmval "$fm" task_type | tr '[:upper:]' '[:lower:]')
  rr=$(fmval "$fm" rubric_ref)
  if [ "$tt" = "deliverable" ]; then src="front matter"
  else
    case "$rr" in ''|null|NULL|Null|'~') ;; *) src="front matter" ;; esac
  fi
  # (2) declared: a rubric_ac: line at line start with a non-empty value
  if [ -z "$src" ]; then
    v=$(fmval "$fm" rubric_ac)
    if [ -n "$v" ]; then
      case "$(printf '%s' "$v" | tr '[:upper:]' '[:lower:]')" in
        none) echo "no rubric AC (declared): $h"; exit 0 ;;
        *) src="declared" ;;
      esac
    fi
  fi
  # (3) inferred: no rubric_ac: line or an empty value; the whole file, case-insensitive
  if [ -z "$src" ]; then
    if command grep -Eiq 'rubric|judge' "$h"; then src="inferred"
    else echo "no rubric AC (inferred: neither word in the file): $h"; exit 0; fi
  fi
  j=$(latestof "$dir" "phase$n-rubric-verdict")
  if [ -n "$j" ]; then echo "OK $j"; exit 0; fi
  echo "MISSING $dir/phase$n-rubric-verdict.md (rubric AC in $h, $src: dispatch the judge before the run reviewer)"
  exit 1
}

# labelof FILE : the first `verdict:` line in the first 15 lines whose value's first word is
# PASS, CONDITIONAL, FAIL or PARTIAL; else UNREADABLE
labelof() {
  local w
  while IFS= read -r w; do
    case "$w" in PASS|CONDITIONAL|FAIL|PARTIAL) echo "$w"; return 0 ;; esac
  done <<EOF_L
$(first15 "$1" | sed -nE 's/^verdict:[[:space:]]*([A-Za-z]+).*/\1/p')
EOF_L
  echo UNREADABLE
}

cmd_rounds() {
  local epic="$1" n="$2" slug dir f b rest g bl base k t lab rk recs unr
  [ -n "$epic" ] && [ -n "$n" ] && [ -d .tad ] || usage
  case "$n" in ''|*[!0-9]*) usage ;; esac
  slug=$(epicslug "$epic") || exit 2
  [ -n "$slug" ] || usage
  dir=".tad/evidence/yolo/$slug"
  recs=""; unr=""
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    b=${f##*/}; b=${b%.md}; rest=${b#phase$n-}
    for g in 2 3 4; do
      case "$g" in
        2) bl="design-review-consistency design-review-risk design-review-fit" ;;
        3) bl="gate3-verdict impl-review-consistency impl-review-domain" ;;
        4) bl="gate-report" ;;
      esac
      for base in $bl; do
        k=""
        if [ "$rest" = "$base" ]; then k=1
        else
          case "$rest" in
            "$base"-r*) t=${rest#"$base"-r}
              case "$t" in ''|*[!0-9]*) ;; *) k=$((10#$t)) ;; esac ;;
          esac
        fi
        [ -n "$k" ] || continue
        lab=$(labelof "$f")
        case "$lab" in FAIL) rk=5 ;; PARTIAL) rk=4 ;; UNREADABLE) rk=3 ;; CONDITIONAL) rk=2 ;; *) rk=1 ;; esac
        [ "$lab" = UNREADABLE ] && unr="$unr
unreadable: $f"
        recs="$recs
$g $k $rk"
      done
    done
  done <<EOF_F
$(find "$dir" -maxdepth 1 -type f -name "phase$n-*.md" 2>/dev/null | LC_ALL=C sort)
EOF_F
  # numeric fields only in awk (labels are printed from a fixed table, never compared)
  printf '%s\n' "$recs" | sed '/^$/d' | awk '
    { g = $1 + 0; k = $2 + 0; r = $3 + 0
      if (!((g, k) in w) || r > w[g, k]) w[g, k] = r
      if (k > mx[g]) mx[g] = k }
    END {
      nm[1] = "PASS"; nm[2] = "CONDITIONAL"; nm[3] = "UNREADABLE"; nm[4] = "PARTIAL"; nm[5] = "FAIL"
      tot = 0
      for (g = 2; g <= 4; g++) {
        c = 0; l = ""
        for (k = 1; k <= mx[g]; k++) {
          if (!((g, k) in w)) continue
          if (w[g, k] > 1) c++
          l = l (l == "" ? "" : ", ") "r" k " " nm[w[g, k]]
        }
        if (l == "") l = "none"
        print "G" g ": " c " (" l ")"
        tot += c
      }
      print "TOTAL_ROUNDS: " tot }'
  printf '%s\n' "$unr" | sed '/^$/d' | LC_ALL=C sort
  exit 0
}

case "$1" in
  dispatches) cmd_dispatches "$2" ;;
  gate4-record) cmd_gate4 "$2" ;;
  gate3-files) cmd_gate3files "$2" "$3" ;;
  judge-first) cmd_judgefirst "$2" "$3" "$4" ;;
  rounds) cmd_rounds "$2" "$3" ;;
  *) usage ;;
esac
