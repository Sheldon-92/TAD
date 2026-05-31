#!/usr/bin/env bash
# verify-ac-commands.sh — Advisory §9.1 AC-verification-command linter.
#
# Scans a handoff's §9.1 region (from `## 9.1` to the next `## `) PLUS fenced
# ```bash blocks inside §9.1 for the finite, recurrence-grounded set of
# dangerous AC-verification command patterns, and WARNs/INFOs. Never blocks.
#   Rule A (WARN) — grep with `c` flag piped to `sort -u` ... `wc -l`
#   Rule B (WARN) — grep -E/-nE/egrep quoted pattern with a literal `\|`
#   Rule C (INFO) — single-file grep -n/-c output-shape ambiguity
#   Rule D (INFO) — sentinel/marker self-leak (token also in nearby doc prose)
# Usage: verify-ac-commands.sh <handoff.md>
#
# ⚠️ SAFETY / forbidden (architecture.md 2026-04-15 "Mechanical Enforcement
#    Rejected on Single-User CLI"; 2026-05-30 "Ad-hoc audit tools are themselves
#    validation theater"): this script is a SMOKE ALARM, NOT a fire suppressor.
#    - MUST NOT be registered as a PreToolUse / UserPromptSubmit / SessionStart hook.
#    - MUST NOT be added to .claude/settings.json (any matcher / permissions.deny).
#    - MUST NOT return a blocking/deny exit code; exit is ALWAYS 0 (advisory only).
#    - MUST NOT fail-closed or abort (no `set -e`); every parse path tolerates
#      malformed input and continues.
#    BSD/macOS-safe shell only (Perl-regex grep mode, .*? and \d are forbidden).
#    ⚠️ Self-discipline: this linter's OWN internal greps must be correct — it
#       must NOT write `grep -c ... | sort -u | wc -l` (the very bug it lints).

HANDOFF="${1:-}"

if [ -z "$HANDOFF" ] || [ ! -f "$HANDOFF" ]; then
  echo "verify-ac-commands: usage: verify-ac-commands.sh <handoff.md> (file not found) — ADVISORY, never blocks"
  exit 0
fi

TMP_DIR="$(mktemp -d 2>/dev/null || echo /tmp)"
REGION_FILE="$TMP_DIR/vac_region.$$"   # §9.1 region with original line numbers
PROSE_FILE="$TMP_DIR/vac_prose.$$"     # §9.1 prose (non-command) lines, for Rule D
INFO_FILE="$TMP_DIR/vac_info.$$"       # Rule D INFO tally (subshell-safe counter)
: > "$REGION_FILE"; : > "$PROSE_FILE"; : > "$INFO_FILE"

cleanup() { rm -f "$REGION_FILE" "$PROSE_FILE" "$INFO_FILE" 2>/dev/null || true; }
trap cleanup EXIT

# --- Extract the §9.1 region (heading "9.1" → next heading), prefixing each line
#     with its 1-based file line number as "N:content". awk is single-pass +
#     BSD-safe. Real handoffs mark §9.1 with two OR three hashes
#     (`## 9.1` / `### 9.1 Spec Compliance Checklist`); the region ends at the
#     NEXT markdown heading line (`^#{2,} `, e.g. `### 9.2` / `## 10`). ---
awk '
  /^#{2,} *9\.1([^0-9]|$)/ { in91 = 1; next }   # enter region on the 9.1 heading
  /^#{2,} / { if (in91) in91 = 0 }              # any later heading ends the region
  in91 { printf "%d:%s\n", NR, $0 }
' "$HANDOFF" > "$REGION_FILE" 2>/dev/null || true

W=0
I=0

# Helper: strip the "N:" line-number prefix to get the raw content
content_of() { printf '%s' "$1" | sed 's/^[0-9]*://'; }
lineno_of()  { printf '%s' "$1" | sed 's/:.*//'; }

# --- Build prose-only set for Rule D (lines that are NOT command lines) ---
while IFS= read -r entry; do
  [ -n "$entry" ] || continue
  c="$(content_of "$entry")"
  case "$c" in
    *grep*|*awk*|*sed*|*wc*) : ;;        # command line → not prose
    *) printf '%s\n' "$c" >> "$PROSE_FILE" ;;
  esac
done < "$REGION_FILE"

# --- Walk candidate COMMAND lines (contain grep/awk/sed/wc) ---
while IFS= read -r entry; do
  [ -n "$entry" ] || continue
  c="$(content_of "$entry")"
  n="$(lineno_of "$entry")"

  # Only consider lines that look like verification commands.
  case "$c" in
    *grep*|*awk*|*sed*|*wc*) : ;;
    *) continue ;;
  esac

  snippet="$(printf '%s' "$c" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"

  # ----- Rule A: grep with a `c` flag, piped through sort -u ... wc -l -----
  # recurrence: architecture.md "AC Verification Command Bug: grep -ocE |
  #   sort -u | wc -l — 2026-05-27" + AC Verification Drift Pattern (output-shape).
  # Trigger = a grep flag CLUSTER containing `c` (e.g. -c, -oc, -cE, -ocE) AND a
  # `sort -u` ... `wc -l` tail. GUARD: `grep -o`/`grep -oE` WITHOUT a c in flags
  # + sort -u|wc -l is CORRECT (each match on its own line) → MUST NOT warn.
  ruleA_flagc=0
  # Detect a grep short-flag cluster (-xxx) that contains the letter c.
  # Extract each "grep -<cluster>" and test the cluster for a literal c.
  if printf '%s' "$c" | grep -Eq 'grep[[:space:]]+-[A-Za-z]*c[A-Za-z]*'; then
    ruleA_flagc=1
  fi
  ruleA_tail=0
  if printf '%s' "$c" | grep -q 'sort -u' && printf '%s' "$c" | grep -q 'wc -l'; then
    ruleA_tail=1
  fi
  if [ "$ruleA_flagc" -eq 1 ] && [ "$ruleA_tail" -eq 1 ]; then
    echo "RULE A [WARN] line $n: $snippet → grep -c emits one count per file; sort -u | wc -l on it ~always yields 1. For unique-match count DROP the c flag: grep -oE 'a|b|c' file | sort -u | wc -l (recurrence: architecture.md AC-cmd-bug 2026-05-27)"
    W=$((W + 1))
  fi

  # ----- Rule B: grep -E/-nE/egrep quoted pattern with a literal \| -----
  # recurrence: Epic P1+P2 AC1.1 (2×; phase1/phase2 design-review-cr.md P0-1).
  # In ERE, `\|` matches a LITERAL pipe, not alternation. GUARD: a `\|` that is
  # NOT inside a grep -E/-nE/egrep quoted arg (awk field-sep, markdown escape
  # outside any command) → no warn. Bare `|` alternation → no warn. `\[ \]`
  # bracket escapes alone → no warn (only `\|` triggers).
  ruleB_isE=0
  if printf '%s' "$c" | grep -Eq '(grep[[:space:]]+-[A-Za-z]*E[A-Za-z]*|egrep)'; then
    ruleB_isE=1
  fi
  if [ "$ruleB_isE" -eq 1 ]; then
    # Look only at the quoted argument(s). Extract single- and double-quoted
    # spans, then test those spans for a literal backslash-pipe.
    qspans="$(printf '%s' "$c" | grep -oE "'[^']*'" 2>/dev/null; printf '%s' "$c" | grep -oE '"[^"]*"' 2>/dev/null)"
    if printf '%s' "$qspans" | grep -q '\\|'; then
      echo "RULE B [WARN] line $n: $snippet → in ERE \\| matches a LITERAL pipe, not alternation. For OR use a bare pipe: grep -nE 'a|b'. Keep \\[ \\] bracket escapes. (recurrence: Epic P1+P2 AC1.1 (2×))"
      W=$((W + 1))
    fi
  fi

  # ----- Rule C: single-file grep -n/-c output-shape (LOW-confidence INFO) -----
  # recurrence: AC Verification Drift Pattern sub-pattern 2 (output-shape
  # single-vs-multi-file). Heuristic only → INFO, never WARN, to avoid noise.
  # Skip if Rule A already fired on this line (the -c case is covered there).
  if [ "${ruleA_flagc}${ruleA_tail}" != "11" ]; then
    if printf '%s' "$c" | grep -Eq 'grep[[:space:]]+-[A-Za-z]*[nc][A-Za-z]*'; then
      echo "RULE C [INFO] line $n: $snippet → verify single-file grep output shape (count vs match-lines) on a real artifact before relying on the value (recurrence: AC Verification Drift Pattern)"
      I=$((I + 1))
    fi
  fi

  # ----- Rule D: sentinel/marker self-leak (LOW-confidence INFO) -----
  # recurrence: AC Verification Drift Pattern sub-pattern 1 + "AC Self-Leak from
  # Removal Rationale". Heuristic: a grep for a literal quoted token whose value
  # ALSO appears verbatim in this §9.1 region's own prose → the AC that verifies
  # "no occurrence of X" can self-leak from the doc's own text. INFO only.
  if printf '%s' "$c" | grep -q 'grep'; then
    tokens="$(printf '%s' "$c" | grep -oE "'[^']*'" 2>/dev/null; printf '%s' "$c" | grep -oE '"[^"]*"' 2>/dev/null)"
    printf '%s\n' "$tokens" | while IFS= read -r tok; do
      [ -n "$tok" ] || continue
      bare="$(printf '%s' "$tok" | sed "s/^['\"]//; s/['\"]$//")"
      # Only meaningful for plain word-ish sentinels (avoid regex metacharacters).
      case "$bare" in
        ""|*'|'*|*'\'*|*'['*|*']'*|*'('*|*')'*|*'.'*|*'*'*|*'^'*|*'$'*|*'+'*|*'?'*) continue ;;
      esac
      [ "${#bare}" -ge 4 ] || continue
      if grep -Fq "$bare" "$PROSE_FILE" 2>/dev/null; then
        echo "RULE D [INFO] line $n: searched token '$bare' also appears in this §9.1 prose → ensure the sentinel doesn't self-leak; reference META artifacts not the token verbatim (recurrence: AC Self-Leak from Removal Rationale)"
        # Rule D runs inside a `while ... done < pipe` subshell; record each INFO
        # in a file so the parent shell can include it in the summary tally.
        echo x >> "$INFO_FILE"
      fi
    done
  fi
done < "$REGION_FILE"

# Fold subshell-recorded Rule D INFOs into the info tally.
if [ -s "$INFO_FILE" ]; then
  I=$((I + $(wc -l < "$INFO_FILE" | tr -d ' ')))
fi

echo "verify-ac-commands: ${W} warnings, ${I} info — ADVISORY, never blocks"
exit 0
