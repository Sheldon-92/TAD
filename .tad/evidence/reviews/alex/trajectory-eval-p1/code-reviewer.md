# Code-Reviewer Review — HANDOFF-20260702-trajectory-eval-p1

**Reviewer**: code-reviewer (Gate 2 expert review)
**Date**: 2026-07-02
**Scope**: §4.2, §6 (6.1 + 6.7), §9 + §9.1, §10 (narrow-scope per instruction)
**Blast-radius checks**: `.tad/eval/` does NOT exist (exit 1) ✓ | `grep -rl 'eval/rubric'` over CLAUDE.md/.claude/skills/.agents/skills = `0` ✓ (AC10 claim holds)

**Verdict**: CONDITIONAL PASS — 2 P0 (both mechanical, quickly fixable; no design-level defect).

---

## 1. Critical Issues (P0 — must fix before implementation)

### P0-1 — AC2 regex is broken by the blanket pipe-escape rule; the correct form exists only in §6.7, not in the §9.1 PRIMARY source

§9.1 is labeled "PRIMARY VERIFICATION SOURCE — Gate 3 executes each row", and the pipe-escape note at the bottom says: *"表格内 `\|` 提取到 bash 运行时须还原为 `|`"* — a **blanket** rule applied to every `\|`.

AC2 cell: `grep -cE '^\| *(GS-\|S)[0-9]+'`. It contains **two** `\|` that need **opposite** treatment:
- Leading `^\|` — meant to match a literal `|` at the start of a table row.
- Alternation `(GS-\|S)` — meant to be ERE alternation `GS-` OR `S`.

Neither blanket policy produces a correct command:
- **Un-escape all `\|` → `|`** (what the note instructs): yields `^| *(GS-|S)[0-9]+`. In ERE `^|` = `^` OR empty-string, and empty-string matches every line → **`grep -c` returns the TOTAL line count of the audit report**. AC2 then passes unconditionally (any audit report has ≥10 lines). This is exactly the "a rubric/gate that can only PASS is theater" failure the handoff itself cites (gate-design.md 2026-05-31/06-06). AC2 can never FAIL.
- **Preserve all `\|`**: `(GS-\|S)` becomes the literal string `GS-|S`, so a real `| GS-01 ...` row no longer matches → false FAIL.

Only the mixed form in §6.7 works: `^[|] *(GS-|S)[0-9]+` (char-class `[|]` for the literal leading pipe, bare `|` for alternation). This is also the portable choice (BSD/macOS `grep -E` handling of `\|` is not reliable).

**Fix**: replace the AC2 §9.1 cell with the `[|]` form verbatim (`grep -cE '^[|] *(GS-|S)[0-9]+' <file>`) so no blanket rule is needed, and add a per-row exception to the pipe-escape note (the leading pipe is `[|]`, do NOT un-escape it into `|`). Right now a Gate-3 executor that trusts §9.1 + the note gets a command that silently always passes.

### P0-2 — AC11 allowlist omits `.tad/evidence/reviews/`, but the Required Evidence Manifest MANDATES Blake write review files there → doing the required work makes AC11 false-FAIL

AC11 exclusion grep (un-escaped): `(\.tad/eval/|trajectory-data-audit|trajectory-eval-p1-git-baseline|\.tad/active/|\.tad/evidence/traces/|\.tad/evidence/decisions/|COMPLETION-20260702-trajectory-eval-p1)`.

The Required Evidence Manifest (§ end of doc) requires:
`blake_layer2_reviews: ".tad/evidence/reviews/blake/trajectory-eval-p1/{reviewer}.md (>=2 distinct)"`.

`.tad/evidence/` is **not** gitignored (current `git status` shows `?? .tad/evidence/traces/...`, `?? .tad/evidence/decisions/...`, `?? .tad/evidence/research/...` all as untracked). Blake's Layer-2 review files are created during implementation, so at Gate 3 they appear as `??` in `git status --porcelain`, are NOT in the baseline snapshot, and are NOT matched by the allowlist → AC11 counts ≥2 → **AC11 = ≥2, expected 0 → FAIL**. Performing the mandatory min-2 Layer-2 review is what breaks AC11.

This is a three-way inconsistency: the manifest **requires** the path, §7.1 Files-to-Create **omits** it, and AC11 **forbids** it. Note traces/decisions were allowlisted for exactly this "accumulates as `??` during the session" reason — reviews need the same treatment.

**Fix**: add `\.tad/evidence/reviews/` to the AC11 exclusion alternation. Also list the blake_layer2_reviews dir in §7.1 for consistency.

---

## 2. Recommendations (P1 — should address)

### P1-1 — AC2's audit sample-table row format is never defined in §4.2 (only hinted in a Verified-Output cell)
Even with the corrected `[|]` regex, AC2 depends on audit rows starting with `| GS-<n>` or `| S<n>`. §4.2 defines B (rubric) and C (golden-set) conventions but **nothing** for the audit report's sample-list table. The only place the convention appears is the AC2 Verified-Output note ("Blake 表格行首用编号列"). If Blake writes rows starting with the slug or a bare number (`| 1 | sep-phase2 | …`), the regex returns 0 → false FAIL. FOCUS-AREA-1 explicitly requires each §9.1 method to match a §4.2 convention — AC2 has no such anchor. **Fix**: add an "E. Audit sample-table format" block to §4.2 pinning the first column to `S{nn}` (or `GS-{nn}`), matching the regex.

### P1-2 — AC11 uses process substitution `<(git status --porcelain | sort)`; requires bash, breaks under sh/dash
`<(...)` is a bashism. If the Gate-3 executor runs the row through `sh -c` / dash, it errors out. **Fix**: either assert bash in the AC row, or use a temp-file form:
`git status --porcelain | sort > /tmp/cur.txt; comm -13 baseline.txt /tmp/cur.txt | grep -vE '...' | wc -l`. (The Bash tool default is bash, so this is a portability guard rather than a live break, but Gate execution context is worth pinning.)

### P1-3 — Knowledge journal location may fall outside the AC11 allowlist
The manifest allows `knowledge_updates: "journal entry OR explicit 'no discovery' in completion report"`. The "no discovery in completion report" path is covered (COMPLETION file is allowlisted). But if Blake writes a **separate** raw journal file (per the Capture/Distill three-moment model, principles.md 2026-06-22), its path (e.g. `.tad/evidence/journal/…`) is not in the allowlist → AC11 false-positive. **Fix**: pin the journal path and either allowlist it or mandate the in-completion-report form for this Phase.

---

## 3. Suggestions (P2 — nice to have)

- **P2-1** Micro-task 5 verification (`grep -c '^human_confirmed:'`) is looser than AC9 (`grep -c '^human_confirmed: false'`). Align micro-task 5 to the AC9 form so the two verification surfaces don't diverge.
- **P2-2** AC8 hard-codes 2-space frontmatter indentation (`^  D[0-9]+: [1-5]$`). §4.2C's template shows 2 spaces, so it matches — but a Blake choice of valid 4-space YAML would false-FAIL. Promote "scores children indented **exactly 2 spaces**" to an explicit written rule in §4.2C, not just template whitespace.
- **P2-3** AC4 alone yields `0 -eq 0 → OK` on an empty rubric; it relies on AC3 (≥5) for non-emptiness. Fine when ACs run together, but consider guarding AC4 with a `>0` dimension check so it's self-standing.
- **Positive**: FOCUS-AREA-4 (GS-1 vs GS-01 naming) is robustly handled — AC6/7/8 use the `GS-*.md` glob, which matches either zero-padding. Good. AC11's baseline line-set diff (vs a raw whole-tree grep) is the correct design and correctly neutralizes the pre-existing 8-line uncommitted noise; the `comm -13` on sorted snapshots is sound and porcelain lines for a re-modified file stay stable so they cancel. The pipe-escape handling in AC6/7/8/10/11 (shell pipes + AC11's regex alternations) is uniformly correct under blanket un-escape — AC2 is the sole exception (P0-1).

---

## 4. Overall Assessment

**CONDITIONAL PASS.**

The design is sound (audit→rubric→golden-set ordering, honest-partial gates, Claims-Need-Carriers via `human_confirmed`, anti-Goodhart AC10 verified at 0). The blocking issues are two mechanical AC defects, both quick to fix:

1. **P0-1** AC2 regex — replace §9.1 cell with the `[|]` form from §6.7 and add a per-row exception to the blanket pipe-escape note (otherwise AC2 always passes = validation theater).
2. **P0-2** AC11 allowlist — add `\.tad/evidence/reviews/` (mandatory Blake Layer-2 review files currently make AC11 false-FAIL); also add the dir to §7.1.

Address P0-1 and P0-2 (and ideally P1-1/P1-2/P1-3) before handing to Blake. No architectural rework required.
