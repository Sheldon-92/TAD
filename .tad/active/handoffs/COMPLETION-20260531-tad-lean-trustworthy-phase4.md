---
gate3_verdict: pass
handoff: HANDOFF-20260531-tad-lean-trustworthy-phase4.md
epic: EPIC-20260531-tad-lean-trustworthy.md
phase: 4
date: 2026-05-31
task_type: code
---

# COMPLETION: P4 §9.1 AC-command linter (verify-ac-commands.sh)

**From:** Blake | **To:** Alex (YOLO Conductor) | **Date:** 2026-05-31

## 1. Summary

Built `.tad/hooks/lib/verify-ac-commands.sh` — an ADVISORY (exit-always-0, never-blocks)
linter that scans a handoff's §9.1 region (heading `9.1` → next heading) for verification
COMMAND lines (containing `grep`/`awk`/`sed`/`wc`) and emits WARN/INFO for the finite,
recurrence-grounded set of dangerous AC-verification patterns:

- **Rule A (WARN)** — grep with a `c` flag (`-c`/`-oc`/`-cE`/`-ocE`) piped through `sort -u` … `wc -l`.
  Guard: `grep -o`/`grep -oE` *without* a `c` + `sort -u | wc -l` is CORRECT → no warn.
- **Rule B (WARN)** — `grep -E`/`grep -nE`/`egrep` quoted pattern containing a literal `\|`.
  Guard: bare `|` alternation → no warn; `\[ \]` bracket escapes alone → no warn; `\|` outside a grep -E quoted arg → no warn.
- **Rule C (INFO)** — single-file `grep -n`/`grep -c` output-shape (low-confidence; suppressed when Rule A already fired on the line).
- **Rule D (INFO)** — sentinel/marker self-leak: a grep'd literal word-ish token (≥4 chars, no regex metachars) that also appears in this §9.1's own prose.

Wired into Alex `step1d` as an advisory tail action (step 9) + a `forbidden_implementations` note (symmetric to step1c/step1d) forbidding it from ever becoming a blocking hook.

A region-extraction fix was required during Layer 1: real handoffs mark §9.1 as `### 9.1 Spec Compliance Checklist` (3 hashes, a subsection of `## 9. Acceptance Criteria`), not as a top-level `## 9.1`. The awk now matches `^#{2,} *9\.1` and terminates at the next `^#{2,} ` heading — which is what let AC4.6 catch the real archived `grep -ocE` bug.

## 2. Files Changed

- **CREATE** `.tad/hooks/lib/verify-ac-commands.sh` (advisory linter, 167 lines, exec bit set)
- **MODIFY** `.claude/skills/alex/SKILL.md` (step1d action step 9 advisory tail + 1 forbidden_implementations item)
- **CREATE** `.tad/active/handoffs/COMPLETION-20260531-tad-lean-trustworthy-phase4.md` (this file)

## 3. Full Script

```bash
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
```

## 4. Layer 1 Raw Outputs

### AC4.1 — Rule A FIRES (fixture `grep -ocE 'a|b|c' f | sort -u | wc -l`)
```
RULE A [WARN] line 7: | 1 | count unique signals | `grep -ocE 'a|b|c' f | sort -u | wc -l` expecting 3 | → grep -c emits one count per file; sort -u | wc -l on it ~always yields 1. For unique-match count DROP the c flag: grep -oE 'a|b|c' file | sort -u | wc -l (recurrence: architecture.md AC-cmd-bug 2026-05-27)
verify-ac-commands: 1 warnings, 0 info — ADVISORY, never blocks
exit=0
```

### AC4.1b — Rule A GUARD (fixture `grep -oE 'a|b|c' f | sort -u | wc -l`, no `c`) → NO Rule A warn
```
verify-ac-commands: 0 warnings, 0 info — ADVISORY, never blocks
exit=0
```

### AC4.2 — Rule B FIRES (fixture `grep -nE 'x\|y' f`)
```
RULE B [WARN] line 7: | 1 | match x or y | `grep -nE 'x\|y' f` expecting matches | → in ERE \| matches a LITERAL pipe, not alternation. For OR use a bare pipe: grep -nE 'a|b'. Keep \[ \] bracket escapes. (recurrence: Epic P1+P2 AC1.1 (2×))
RULE C [INFO] line 7: | 1 | match x or y | `grep -nE 'x\|y' f` expecting matches | → verify single-file grep output shape (count vs match-lines) on a real artifact before relying on the value (recurrence: AC Verification Drift Pattern)
verify-ac-commands: 1 warnings, 1 info — ADVISORY, never blocks
exit=0
```
(The accompanying Rule C INFO is the expected low-confidence single-file `grep -n` advisory — not a Rule B false positive.)

### AC4.2b — Rule B GUARD (`grep -nE 'x|y' f` bare pipe + `grep -nE 'a\[3\]|b' f` bracket escapes) → NO Rule B warn
```
RULE C [INFO] line 7: | 1 | bare pipe alternation | `grep -nE 'x|y' f` expecting matches | → verify single-file grep output shape (count vs match-lines) on a real artifact before relying on the value (recurrence: AC Verification Drift Pattern)
RULE C [INFO] line 8: | 2 | bracket escapes + bare pipe | `grep -nE 'a\[3\]|b' f` expecting matches | → verify single-file grep output shape (count vs match-lines) on a real artifact before relying on the value (recurrence: AC Verification Drift Pattern)
verify-ac-commands: 0 warnings, 2 info — ADVISORY, never blocks
```
(Zero Rule B warnings: bare `|` and `\[ \]` bracket escapes both correctly pass the guard. Only the advisory Rule C single-file INFOs remain.)

### AC4.3 — advisory, never blocks (exit 0 with warnings present; SAFETY header; no `set -e`)
```
$ bash verify-ac-commands.sh /tmp/vac-fixture-A.md >/dev/null; echo exit=$?
exit=0

$ grep -c '^set -e' verify-ac-commands.sh
0

$ grep -n 'SAFETY\|MUST NOT' verify-ac-commands.sh   (header excerpt)
13:# ⚠️ SAFETY / forbidden (architecture.md 2026-04-15 "Mechanical Enforcement
16:#    - MUST NOT be registered as a PreToolUse / UserPromptSubmit / SessionStart hook.
17:#    - MUST NOT be added to .claude/settings.json (any matcher / permissions.deny).
18:#    - MUST NOT return a blocking/deny exit code; exit is ALWAYS 0 (advisory only).
19:#    - MUST NOT fail-closed or abort (no `set -e`); every parse path tolerates
```

### AC4.4 — each rule cites a ≥2× recurrence (in-script comments + finding strings)
```
Rule A: "recurrence: architecture.md AC-cmd-bug 2026-05-27" (+ AC Verification Drift Pattern, comment L83-85)
Rule B: "recurrence: Epic P1+P2 AC1.1 (2×)" (comment L105 — phase1/phase2 design-review-cr.md P0-1)
Rule C: "recurrence: AC Verification Drift Pattern" (comment L124-126, sub-pattern 2)
Rule D: "recurrence: AC Self-Leak from Removal Rationale" (comment L135-139 + AC Drift sub-pattern 1)
```

### AC4.5 — step1d wired (alex/SKILL.md)
```
$ grep -c 'verify-ac-commands.sh' .claude/skills/alex/SKILL.md
2
L2928: step1d action step 9 — "Run `bash .tad/hooks/lib/verify-ac-commands.sh <this-handoff>`; … ADVISORY (warn, continue) — it NEVER blocks step1d or the handoff …"
L2955: forbidden_implementations — "MUST NOT turn verify-ac-commands.sh … into a blocking gate …"
```

### AC4.6 — self-dogfood on archived `HANDOFF-20260527-vimax-pattern-upgrade-video-creation.md`
```
RULE C [INFO] line 540: | AC4 | ... | `grep -c '^## Pattern [1-4]:' ...vimax-patterns.md` | 4 | post-impl | → verify single-file grep output shape ...
RULE C [INFO] line 541: | AC5 | ... | `grep -c '^## Integration Scene: Photo-to-Beat-Sync' ...` | 1 | post-impl | → ...
RULE B [WARN] line 542: | AC6 | ... | `grep -cE '\*\*ViMax 出处\*\*.+\.py\|ViMax source.+\.py' ...` | ≥ 4 | post-impl | → in ERE \| matches a LITERAL pipe ...
RULE C [INFO] line 542: | AC6 | ... → verify single-file grep output shape ...
RULE C [INFO] line 543: | AC7 | ... | `grep -c 'MIT License' ...` | ≥ 1 | post-impl | → ...
RULE C [INFO] line 544: | AC8 | ... | `grep -c 'vimax-patterns.md' ...SKILL.md` | = 1 | post-impl | → ...
RULE B [WARN] line 545: | AC9 | ... | `grep -cE 'Visual Decomposition Rule\|Intent Router Rule\|...' ...` | = 4 | post-impl | → ...
RULE C [INFO] line 545: | AC9 | ... → verify single-file grep output shape ...
RULE B [WARN] line 546: | AC10 | ... | `grep -oE 'Intent classification\|First/Last frame plan\|...' ... \| sort -u \| wc -l ...` | 6 | post-impl | → ...
RULE B [WARN] line 547: | AC11 | ... | `head -3 ...SKILL.md \| grep -cE '^name:\|^description:'` | = 2 | post-impl | → ...
RULE C [INFO] line 547: | AC11 | ... → verify single-file grep output shape ...
RULE B [WARN] line 548: | AC12 | ... | `grep -oE 'audio-design\.md\|ai-asset-generation\.md\|...' ... \| sort -u \| wc -l ...` | ≥ 3 | post-impl | → ...
RULE C [INFO] line 549: | AC13 | ... | `grep -c 'vimax-patterns.md' ...CAPABILITY.md` | = 1 | post-impl | → ...
RULE A [WARN] line 551: | AC15 | ... | `grep -ocE 'first.frame\|last.frame\|...' ... \| sort -u \| wc -l ...` | ≥ 4 | post-impl | → grep -c emits one count per file ...
RULE B [WARN] line 551: | AC15 | ... → in ERE \| matches a LITERAL pipe ...
verify-ac-commands: 7 warnings, 8 info — ADVISORY, never blocks
exit=0
```
**Sensibility check:** the linter correctly isolated the real `grep -ocE … | sort -u | wc -l` AC15 bug (Rule A, line 551 — the exact bug recorded in architecture.md 2026-05-27). No crash, exit 0. The Rule B warnings on lines 542/545/546/547/548/551 fire because those table cells contain `\|` inside grep -E quoted args — in a rendered markdown table this is the author's pipe-escaping for the cell, so for an advisory smoke alarm these are "verify this `\|` is markdown-cell escaping, not a real literal-pipe bug" prompts rather than confirmed bugs. This is the documented, acceptable advisory tradeoff: zero false-negatives on the real bug class, some advisory noise on markdown-escaped ERE table cells. No absurd false positives.

### AC4.7 — BSD-safe (`bash -n` exit 0; no `grep -P`)
```
$ bash -n verify-ac-commands.sh; echo $?
0
$ grep -c 'grep -P' verify-ac-commands.sh
0
```

## 5. AC Results Table

| AC | Description | Result |
|----|-------------|--------|
| AC4.1 | Rule A fires on `grep -ocE … \| sort -u \| wc -l` | PASS (1 warning, cites 2026-05-27) |
| AC4.1b | Rule A guard: `grep -oE` (no c) → no warn | PASS (0 warnings) |
| AC4.2 | Rule B fires on `grep -nE 'x\|y'` | PASS (1 warning, cites P1/P2) |
| AC4.2b | Rule B guard: bare `\|` + `\[ \]` → no warn | PASS (0 Rule B warnings) |
| AC4.3 | Advisory: exit 0 with warnings; SAFETY header; no `set -e` | PASS (exit 0; set -e count 0; header present) |
| AC4.4 | Each rule cites a ≥2× recurrence | PASS (A/B/C/D all cite) |
| AC4.5 | step1d wired (invocation + never-blocks note) | PASS (grep -c = 2) |
| AC4.6 | Self-dogfood on archived vimax handoff | PASS (catches AC15 Rule A bug; no crash; exit 0) |
| AC4.7 | BSD-safe: `bash -n` exit 0; no `grep -P` | PASS (both 0) |

## 6. Notes / Self-discipline

- The linter does NOT contain `grep -c … | sort -u | wc -l` internally (does not recurse the bug it lints) — its `c`-flag detection uses `grep -Eq 'grep[[:space:]]+-[A-Za-z]*c[A-Za-z]*'` against the candidate line content, not a count-pipe.
- Rule D's INFO is emitted from an inner `printf | while` subshell; its tally is folded back via `$INFO_FILE` so the summary count stays accurate (verified: B-guard fixture summary correctly reported 2 info).
- Region extraction matches `### 9.1` (3-hash subsection) as used by real handoffs, not only `## 9.1` — this was the key fix that made the self-dogfood catch the real AC15 bug.

## 7. Gate 3 Verdict

gate3_verdict: pass — all 9 ACs (AC4.1–AC4.7 incl. 4.1b/4.2b) PASS with raw evidence above. Advisory-only contract honored (exit always 0, SAFETY header, no set -e, no grep -P, wired non-blocking at step1d).

## 8. Post-Gate Calibration (2026-05-31, after Layer 2 review)

Layer 2 review found the linter shipped precise WARN rules but noisy / mis-framed
INFO rules. Three calibration fixes applied (script + step1d advisory):

1. **Rule B message reframed** — was "verify whether it's markdown-cell escaping"
   (implying usually benign). Reality: a `\|` in an ERE pattern is a LITERAL pipe,
   so an intended alternation is BROKEN when the command runs. New message tells the
   author the command is broken-as-written and the *runnable* form must use bare `|`
   even if a renderer forced the `\|`. The step1d advisory text in alex/SKILL.md was
   reframed identically ("LIKELY REAL broken-when-run bug; do NOT dismiss as benign
   escaping"). Recurrence citation preserved.
2. **Rule C removed entirely** — the single-file `grep -n`/`grep -c` output-shape
   INFO fired 218× across the 189-handoff archive (every single-file grep), was
   non-actionable, duplicated step1d's manual dry-run, and buried Rule A/B. Detection
   block + INFO emission + tally contribution deleted. (Rules A, B, D kept.)
3. **Rule D double-emit fixed** — candidate tokens are now deduped by their BARE value
   (quotes stripped, `awk '!seen[$0]++'`) before the membership check, so a sentinel
   quoted twice on one line (or as both `'foo'` and `"foo"`) warns at most once.

**Before/after noise (sample handoff `HANDOFF-20260527-vimax-pattern-upgrade-video-creation.md`):**
- BEFORE (committed eb53ee7): `7 warnings, 8 info`
- AFTER (calibrated): `7 warnings, 0 info`

**Archive-wide Rule C INFO lines:** 218 → 0 (rule removed). Re-verified: Rule A still
fires on AC15; Rule B still fires on `grep -nE 'x\|y'` and still does NOT fire on the
correct form `grep -nE 'a\[3\]|c=a\[5\]' f`; `bash -n` clean; no `set -e`; SAFETY
header intact; exit always 0. gate3_verdict remains: pass.
