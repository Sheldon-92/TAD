---
task_type: code
e2e_required: no
research_required: no
git_tracked_dirs: [".tad/hooks/lib", ".claude/skills/alex"]
skip_knowledge_assessment: no
gate4_delta: []
---

# HANDOFF: P4 §9.1 AC-command linter (verify-ac-commands.sh)

**From:** Alex (YOLO Conductor) | **To:** Blake | **Date:** 2026-05-31
**Epic:** EPIC-20260531-tad-lean-trustworthy.md (Phase 4/5)

## 1. Task Overview
Build `.tad/hooks/lib/verify-ac-commands.sh` — an ADVISORY linter that scans a handoff's §9.1 verification
COMMANDS for the finite set of recurrence-grounded dangerous patterns and WARNS (never blocks). Wire it as the
last action of Alex's step1d (warn-and-continue). This catches the lintable subset of the recurring
AC-verification-drift class that step1d's dry-run alone keeps missing.

## 3. Requirements
- ADVISORY ONLY: exit code MUST NOT block; the script prints warnings to stdout; step1d wiring is "warn, continue".
- Every lint rule MUST cite a real recurrence (≥2×) in a code comment — no speculative rules (architecture.md
  "Ad-hoc audit tools are themselves validation theater" — rules must be evidence-grounded + calibrated).
- BSD/macOS safe (no `grep -P`). NEVER fail-closed, no `set -e` abort, SAFETY header comment.
- Must itself be dry-run on a representative §9.1 before shipping (don't recurse the very bug class it lints).

## 6. Implementation Steps
### The linter `.tad/hooks/lib/verify-ac-commands.sh`
- Usage: `verify-ac-commands.sh <handoff.md>`. Extract candidate command lines: lines inside the §9.1 region
  (from `## 9.1` to the next `## `) that contain `grep`/`awk`/`sed`/`wc` (i.e., verification commands), PLUS
  fenced ```bash blocks within §9.1. (Scan COMMANDS, not prose.)
- **Rule A (grep-c-then-count)** — recurrence: architecture.md "AC Verification Command Bug: grep -ocE | sort -u
  | wc -l — 2026-05-27" + AC Verification Drift Pattern (output-shape). DETECT: a command using `grep` with a
  `c` in its flag cluster (e.g. `-c`, `-oc`, `-cE`, `-ocE`) AND piped through `sort -u` ... `wc -l`.
  WARN: "grep -c emits one count per file; `sort -u | wc -l` on it ~always yields 1. For unique-match count drop
  `-c`: `grep -oE 'a|b|c' file | sort -u | wc -l`." FALSE-POSITIVE GUARD: `grep -o`/`grep -oE` WITHOUT `c` +
  `sort -u | wc -l` is CORRECT → MUST NOT warn (the `c` flag is the trigger, not `-o`).
- **Rule B (literal-pipe-in-ERE)** — recurrence: THIS Epic P1 AC1.1 + P2 AC1.1 (2×, see phase1/phase2
  design-review-cr.md P0-1). DETECT: a `grep -E`/`grep -nE`/`egrep` whose quoted pattern contains a literal `\|`
  (backslash-pipe). WARN: "In ERE `\|` matches a LITERAL pipe, not alternation. For OR use bare `|`:
  `grep -nE 'a|b'`. Keep `\[ \]` bracket escapes." FALSE-POSITIVE GUARD: a `\|` that is NOT inside a `grep -E`
  quoted arg (e.g. an awk field-sep, or markdown table escaping outside any command) → do not warn.
- **Rule C (single-vs-multi-file grep shape)** — recurrence: AC Verification Drift Pattern sub-pattern 2.
  DETECT (heuristic, LOW-confidence → INFO not WARN): `grep -n` or `grep -c` on a SINGLE file whose output is
  then compared to a multi-line expectation. Emit an INFO note: "verify single-file grep output shape (count vs
  match-lines) on a real artifact." Keep this advisory/INFO to avoid false-positive noise.
- **Rule D (sentinel/marker self-leak)** — recurrence: AC Verification Drift Pattern sub-pattern 1 + "AC Self-Leak
  from Removal Rationale". DETECT (heuristic): a `grep`/`grep -c` for a literal token that ALSO appears in the
  handoff's own prose near the command (the AC verifies "no occurrence of X" but X is written in the doc). INFO:
  "ensure the searched sentinel doesn't self-leak from this doc's own prose; reference META artifacts not the token."
- Output format: per finding `RULE <A-D> [WARN|INFO] line N: <cmd snippet> → <fix hint> (recurrence: <cite>)`.
  Summary line `verify-ac-commands: {W} warnings, {I} info — ADVISORY, never blocks`.
- Exit: ALWAYS 0 (advisory). (Optionally exit nonzero ONLY as an informational signal IF the caller opts in, but
  default + step1d use = exit 0, never blocks.)
- SAFETY header comment (mirror post-write-sync.sh:6-11 style): MUST NOT register as PreToolUse/UserPromptSubmit
  hook; MUST NOT add to settings.json; MUST NOT return a blocking/deny exit; no `set -e`; advisory smoke-alarm only.

### Wire into step1d
- In alex/SKILL.md step1d (after the dry-run sub-rules, before the §6.7 log append), add an advisory action:
  "Run `bash .tad/hooks/lib/verify-ac-commands.sh <this-handoff>`; surface any WARN/INFO to the author; this is
  advisory (warn, continue) — it NEVER blocks step1d or the handoff." Add a forbidden_implementations note
  (symmetric to step1c/step1d) that the linter MUST NOT become a blocking hook.

## 7. Files
- CREATE `.tad/hooks/lib/verify-ac-commands.sh`
- MODIFY `.claude/skills/alex/SKILL.md` (step1d advisory invocation + forbidden note)
- **Grounded Against:** step1d @ alex/SKILL.md:2878; architecture.md AC-cmd-bug 2026-05-27 + AC Verification Drift Pattern; phase1/phase2 design-review-cr.md P0-1 (Rule B 2× recurrence); post-write-sync.sh:6-11 SAFETY style.

## 9. Acceptance Criteria
- [ ] **AC4.1 (Rule A fires)**: a fixture handoff §9.1 containing `grep -ocE 'a|b|c' f | sort -u | wc -l` → linter WARNs Rule A citing 2026-05-27. (Build the fixture in /tmp.)
- [ ] **AC4.1b (Rule A false-positive guard)**: `grep -oE 'a|b|c' f | sort -u | wc -l` (no `c`) → NO Rule A warning.
- [ ] **AC4.2 (Rule B fires)**: §9.1 with `grep -nE 'x\|y' f` → WARNs Rule B citing P1/P2.
- [ ] **AC4.2b (Rule B false-positive guard)**: `grep -nE 'x|y' f` (bare pipe) → NO Rule B warning; `\[ \]` bracket escapes alone → NO warning.
- [ ] **AC4.3 (advisory, never blocks)**: `bash verify-ac-commands.sh <any handoff>; echo exit=$?` → exit 0 even when warnings present. Script has a forbidden_implementations/SAFETY header (grep it). No `set -e` (grep -c '^set -e' == 0).
- [ ] **AC4.4 (rules cite recurrence)**: each rule in the script has a comment citing a ≥2× recurrence (grep the citations).
- [ ] **AC4.5 (step1d wired)**: alex/SKILL.md step1d contains the advisory `verify-ac-commands.sh` invocation + a "never blocks" note.
- [ ] **AC4.6 (self-dogfood)**: run the linter on an ARCHIVED real handoff (e.g. the vimax one that had the grep-ocE bug, if present, else any archived handoff) and paste output — confirm it doesn't crash + findings are sensible (no absurd false positives).
- [ ] **AC4.7 (BSD-safe)**: `bash -n` exit 0; no `grep -P` in the script.

## 10. Important Notes
- ⚠️ NEVER fail-closed / never a blocking hook (single-user CLI lesson). Advisory smoke alarm only.
- ⚠️ Don't recurse the bug class: the linter's OWN internal greps must be correct (dry-run it; e.g. don't write
  `grep -c ... | sort -u | wc -l` inside the linter).
- ⚠️ Keep rules to the evidence-grounded finite set (A/B firm WARN; C/D low-confidence INFO). Adding speculative
  rules makes the linter itself validation theater (architecture.md 2026-05-30).
- Anti-self-trigger: COMPLETION must not contain a §11 Decision Summary table / bare-pipe Decision-Chosen rows.

## 11. Decision Summary
| # | Decision | Chosen | Rationale |
|---|----------|--------|-----------|
| 1 | linter enforcement | ADVISORY exit 0, never blocks | single-user CLI mechanical-enforcement-rejected lesson; smoke alarm not suppressor |
| 2 | rule set | A/B firm WARN (≥2× grounded) + C/D low-confidence INFO | evidence-grounded only; avoid speculative-rule validation theater |
| 3 | wiring | step1d advisory tail action | step1d already the AC dry-run step; linter complements the manual dry-run with mechanical pattern catch |

## Required Evidence Manifest
```yaml
required_evidence:
  completion_report:
    path: ".tad/active/handoffs/COMPLETION-20260531-tad-lean-trustworthy-phase4.md"
    must_contain:
      - "verify-ac-commands.sh full script"
      - "AC4.1/4.1b Rule A fire + false-positive-guard raw output"
      - "AC4.2/4.2b Rule B fire + false-positive-guard raw output"
      - "AC4.3 exit 0 with warnings present + SAFETY header grep + no set -e"
      - "AC4.6 self-dogfood on a real archived handoff (raw output)"
      - "AC4.7 bash -n + no grep -P"
    gate3_verdict: "frontmatter marker: pass|fail|partial"
```
