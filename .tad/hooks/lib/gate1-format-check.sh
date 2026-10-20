#!/bin/bash
# gate1-format-check.sh — Gate 1 format smoke alarm (review-redesign Phase 3).
# Advisory CLI, NEVER a hook: do not register it in settings, hooks.json or any
# plugin. No `set -e` on purpose (greps that do not match are a normal outcome).
#
# Usage: gate1-format-check.sh <Epic | handoff | journal file>
# Exit:  0 = every check OK, 1 = any MISSING, 2 = usage / unreadable file.
# Output: one line per check, `OK <id> <what>` or `MISSING <id> <what>`.
# Mode by content: basename HANDOFF-* -> handoff; a file with **Epic ID** -> Epic;
# anything else -> journal line (simple tier).
# Content is judged by the human's confirmed playback and Alex's "can design from
# it"; this script only checks that the lines exist.

f="$1"
if [ -z "$f" ] || [ -d "$f" ] || [ ! -r "$f" ]; then
  echo "Usage: gate1-format-check.sh <Epic | handoff | journal file>" >&2
  exit 2
fi

miss=0
ok()  { printf 'OK %s %s\n' "$1" "$2"; }
bad() { printf 'MISSING %s %s\n' "$1" "$2"; miss=$((miss + 1)); }

# sec START_ERE STOP_ERE : lines from the first line matching START up to (not
# including) the next line matching STOP. Patterns go through ENVIRON, not -v.
sec() {
  S="$1" E="$2" awk '
    BEGIN { s = ENVIRON["S"]; e = ENVIRON["E"]; on = 0 }
    {
      if (!on) { if ($0 ~ s) { on = 1; print } ; next }
      if ($0 ~ e) exit
      print
    }' "$f"
}

# has TEXT ERE [-i] : does TEXT contain a line matching ERE
has() {
  if [ "$3" = "-i" ]; then
    printf '%s\n' "$1" | command grep -Eiq -- "$2"
  else
    printf '%s\n' "$1" | command grep -Eq -- "$2"
  fi
}

# hasf TEXT ERE [-i] : like has, but only a matching line that is FILLED counts: a line
# still holding a template placeholder `{...}` does not satisfy a check.
hasf() {
  if [ "$3" = "-i" ]; then
    printf '%s\n' "$1" | command grep -Ei -- "$2" | command grep -Evq '\{[^{}]+\}'
  else
    printf '%s\n' "$1" | command grep -E -- "$2" | command grep -Evq '\{[^{}]+\}'
  fi
}

base=$(basename "$f")
case "$base" in
  HANDOFF-*) mode=handoff ;;
  *)
    if command grep -q '\*\*Epic ID\*\*' "$f"; then mode=epic; else mode=journal; fi
    ;;
esac

whole=$(cat "$f")

if [ "$mode" = epic ]; then
  req=$(sec '^## Requirement' '^## ')
  rc=$(sec '^## Result contract' '^## ')
  hasf "$req" '^- \*\*' && ok c0a "Requirement has a filled block line" || bad c0a "Requirement has a filled block line"
  has "$whole" '^### Q→A log' && ok c0b "Q->A log" || bad c0b "Q->A log"
  has "$whole" '^### Assumptions' && ok c0c "Assumptions" || bad c0c "Assumptions"
  hasf "$rc" 'What the human gets' && ok c1a "Result contract: What the human gets (filled)" || bad c1a "Result contract: What the human gets (filled)"
  hasf "$rc" 'Not wanted' && ok c1b "Result contract: Not wanted (filled)" || bad c1b "Result contract: Not wanted (filled)"
  hasf "$req" '^- \*\*([A-Za-z0-9]+\. )?Done check' -i && ok c2 "Requirement: Done check block (filled)" || bad c2 "Requirement: Done check block (filled)"
  dec=$(sec '^### Decisions for the human' '^#{1,3} ')
  { has "$dec" '^### Decisions for the human' && hasf "$dec" '^- '; } && ok c3a "Decisions for the human: heading and a filled line" || bad c3a "Decisions for the human: heading and a filled line"
  hasf "$rc" '^Premise:' && ok c3b "Result contract: Premise (filled)" || bad c3b "Result contract: Premise (filled)"
  hasf "$whole" '^\*\*Depth\*\*:.*blast radius' && ok c3c "Depth line with blast radius (filled)" || bad c3c "Depth line with blast radius (filled)"
  hasf "$whole" '^\*\*Budget\*\*:.*[0-9]' && ok c4 "Budget line with an estimate (filled)" || bad c4 "Budget line with an estimate (filled)"

elif [ "$mode" = handoff ]; then
  # The Epic pointer counts only as a header line: line-anchored, between the first
  # `# ` title and the first `---` after it. A quote of the string in the body does not.
  # A leading YAML frontmatter block (line 1 `---` through the next `---`) is skipped
  # first: its `# ` comment lines are not the title (template handoff-a-to-b.md shape).
  hdr=$(awk '
    NR == 1 && $0 == "---" { fm = 1; next }
    fm { if ($0 == "---") fm = 0; next }
    !on { if ($0 ~ /^# /) on = 1; next }
    /^---$/ { exit }
    { print }' "$f")
  ep=$(printf '%s\n' "$hdr" | command grep -m1 -E '^\*\*Epic:\*\* *EPIC-' | sed -E 's/.*\*\*Epic:\*\* *//; s/ .*//')
  if [ -n "$ep" ]; then
    ok g0 "Gate 1 is the Epic's: run on $ep"
  elif command grep -q '^## Bug Description' "$f"; then
    bd=$(sec '^## Bug Description' '^## ' | sed '1d')
    has "$bd" '[^[:space:]]' && ok b1 "Bug Description has text" || bad b1 "Bug Description has text"
    v=$(sec '^## 9\.1' '^## ' | sed '1d')
    has "$v" '^\| *AC' && ok b2 "9.1 has a repro row" || bad b2 "9.1 has a repro row"
  else
    h=$(awk '
      !on { if ($0 ~ /^### 1\.5 Requirement/) { on = 1; print }; next }
      /^## / || /^---$/ { exit }
      { print }' "$f")
    has "$h" '^### 1\.5 Requirement' && ok c0 "1.5 Requirement heading" || bad c0 "1.5 Requirement heading"
    hasf "$h" '^- \*\*([A-Za-z0-9]+\. )?Done check' -i && ok c2 "1.5: Done check line (filled)" || bad c2 "1.5: Done check line (filled)"
    hasf "$h" '^- \*\*([A-Za-z0-9]+\. )?Not wanted' -i && ok c1 "1.5: Not wanted line (filled)" || bad c1 "1.5: Not wanted line (filled)"
    has "$h" '^#### Q→A log' && ok c0b "1.5: Q->A log" || bad c0b "1.5: Q->A log"
    has "$h" '^#### Assumptions' && ok c0c "1.5: Assumptions" || bad c0c "1.5: Assumptions"
  fi

else
  line=$(command grep 'request:' "$f" | tail -1)
  chk() { case "$line" in *"$2"*) ok "$1" "journal line has $2" ;; *) bad "$1" "journal line has $2" ;; esac; }
  if [ -z "$line" ]; then
    bad j0 "a journal line containing request:"
  else
    chk j1 'blocks:'
    chk j2 'Done check'
    chk j3 'Not wanted'
    chk j4 'qa:'
    chk j5 'assumptions:'
    chk j6 'risk_triggers:'
  fi
fi

[ "$miss" -eq 0 ] && exit 0
exit 1
