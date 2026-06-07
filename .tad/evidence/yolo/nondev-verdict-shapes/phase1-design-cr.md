# Gate 2 Design Review — HANDOFF-20260606-nondev-verdict-shapes-p1

**Reviewer:** code-review specialist (mechanical correctness + safety pass)
**Target:** `.claude/skills/gate/SKILL.md` (Gate 3 deliverable branch L341-483, Gate 4 deliverable branch L758-821)
**Date:** 2026-06-06
**Method:** byte-level grep verification of every old-text anchor, YAML re-parse (ruby) of every inserted block, simulation of all §5 verification commands, codex-mirror investigation.

---

## Summary

The five edits are well-formed and surgical. **All old-text anchors match the current file byte-for-byte** (Edit A 3 lines, Edit B weighted ladder + on_pass/on_partial, Edit C judge_prompt_constraint, Edit D weighted_score bullet, Edit E verify_note). **All inserted YAML re-parses cleanly** (verified with ruby YAML on Edit B, C, D simulations). **Byte-preservation of the weighted ladder is satisfied** — Edit B inserts strictly between the `rule:` block and `on_pass:`, leaving the three ladder lines and the two trailing keys untouched (AC2 holds). **Fence balance stays even** (22 → 22; all edits insert *inside* existing ` ```yaml ` fences, no new fences). Indentation of every inserted key is at the correct sibling level.

The one genuine defect is in the **verification commands (§5), not the edits themselves**: the AC7 command is broken and reports a false/misleading result. Several ACs lack any automated verifier.

---

## P0 (blocking — must fix before impl)

**None.** No edit will fail to apply, no edit corrupts YAML, no edit alters a byte-preserved SAFETY line.

---

## P1 (should-fix)

### P1-1 — AC7 verification command is WRONG (reports a misleading match)
§5 line:
```bash
ls .tad/codex/ 2>/dev/null | grep -i gate || echo AC7-no-codex-gate-mirror
```
`.tad/codex/` actually contains **`manual-gates.md`**, which matches `grep -i gate`. So the command prints `manual-gates.md`, exits 0, and the `|| echo AC7-no-codex-gate-mirror` fallback **never fires**. The operator sees a filename instead of the expected "no mirror" token — the AC appears to FAIL / is unverifiable as written.

Note: the *underlying claim* is still correct. I traced `.tad/codex/regen-codex-editions.sh` (L11-14): it regenerates ONLY `codex-alex-skill.md` and `codex-blake-skill.md` from `alex/SKILL.md` / `blake/SKILL.md`. `manual-gates.md` is a hand-maintained guide, contains **zero** `verdict_shape`/`Verdict_Mapping` tokens (`grep -c` = 0), and is NOT auto-derived from `gate/SKILL.md`. So "no parity regen needed" is TRUE — only the command that proves it is broken.
**Fix:** narrow the grep, e.g. `ls .tad/codex/ | grep -i 'gate-skill\|gate/SKILL' || echo AC7-no-codex-gate-mirror`, or assert content: `grep -rl 'Verdict_Mapping\|verdict_shape' .tad/codex/ || echo AC7-no-codex-gate-mirror`.

### P1-2 — AC1 command passes for an unintended reason (fragile)
§5 AC1:
```bash
grep -A1 'verdict_shape_guard:' ... | grep -q 'weighted, categorical, checklist'
```
In Edit A's new text, `supported: [weighted, categorical, checklist]` is the **2nd** line after `verdict_shape_guard:`, so `grep -A1` (1 line) does **not** reach it. The command nonetheless passes — but only because the rewritten `rule:` line (the *1st* line after) now also contains the substring `weighted, categorical, checklist`. The AC's intent (verify the `supported:` list) is not actually what's being tested; it's coincidentally satisfied by the rule prose. If a future edit rewords the `rule:` line, AC1 silently breaks while the `supported:` list is fine.
**Fix:** use `grep -A2` (or `grep -A3`) so it reaches the `supported:` line, matching the stated intent.

---

## P2 (nice)

### P2-1 — AC5 and AC6 have no §5 verifier
AC5 (`verdict:` line mandated for all shapes — Edit D bullet) and AC6 (diff scoped to additive deliverable-branch lines only) appear only in the §4 checklist; §5 provides no command. AC6 in particular is the load-bearing byte-preservation AC and currently relies on manual `git diff` reading. Suggest adding:
- AC5: `grep -q 'verdict:` machine-readable line is REQUIRED for ALL shapes' gate/SKILL.md`
- AC6: `git diff -U0 .claude/skills/gate/SKILL.md | grep '^-' | grep -v '^---'` should show **zero** removed content lines (purely additive ⇒ no `-` lines except the Edit A 3-line replacement). Equivalently assert the only `-` lines belong to the verdict_shape_guard block.

### P2-2 — AC2 grep relies on unanchored substring (acceptable, document it)
AC2 greps `'IF weighted_score ≥ pass_threshold           → PASS'` without a leading-`^` or `-F`. The actual file line has 4 leading spaces (`    IF weighted_score...`). Substring match succeeds (verified: the `≥` U+2265 and `→` U+2192 are byte-identical, hexdump `e2 89 a5` / `e2 86 92`). This is fine, but a stricter `grep -Fq` with the exact 4-space indent would prove byte-identity more strongly for a SAFETY line. Not required.

### P2-3 — Edit B comment lines use box-drawing `──` inside YAML
The inserted `# ── verdict_shape: categorical ... ──` comments parse fine (YAML comments, verified by ruby load). No issue; noting only that the non-ASCII `──` (U+2500) is cosmetic and could be plain `--` if any downstream ASCII-only tool ever scans this file. Negligible.

---

## Verification evidence (what I actually ran)

- **Anchors (all OK, byte-exact):** `grep -Fxq` on Edit A's 3 lines, Edit B's PASS/PARTIAL/FAIL ladder + `on_pass:`; `grep -Fxq '  judge_prompt_constraint: |'` + end-anchor `...framing.`; `grep -Fq` on weighted_score bullet; `grep -Fq` on Gate-4 `verify_note:`. All matched.
- **YAML re-parse (ruby):** Edit B full Verdict_Mapping → VALID, keys `[rule, categorical, checklist, on_pass, on_partial_or_fail]` (weighted rule preserved, ordering correct). Edit C → VALID, keys `[judge_prompt_constraint, judge_prompt_by_shape, output_to]`. Edit D → VALID, 2 list items.
- **Indentation:** judge_prompt_by_shape at 2-space (sibling of judge_prompt_constraint under Required_Subagent ✓); Edit D bullet 4-space (matches existing `    - ` bullets ✓); shape_agnostic_note 2-space (sibling of verify_note under Prerequisite ✓); categorical/checklist 2-space (children of Verdict_Mapping ✓).
- **Fences:** 22 before; all edits insert inside existing fences ⇒ 22 after (even). §5 python fence-check passes.
- **§5 grep sims:** AC2-weighted-line-OK ✓; AC3 `rigorously-argued KILL` ✓; AC4 `ALL required pass …→ PASS` substring ✓; AC1 passes-but-for-wrong-reason (P1-2); AC7 broken (P1-1).
- **Codex mirror:** `regen-codex-editions.sh` sources only alex/blake SKILLs; `manual-gates.md` has 0 verdict_shape tokens ⇒ claim correct, command wrong.

---

## Overall: CONDITIONAL PASS

All five edits apply cleanly, preserve the weighted ladder byte-for-byte, and produce valid YAML/markdown. No P0. Condition: fix the two §5 verification-command defects (P1-1 AC7 false match, P1-2 AC1 `-A1`→`-A2`) before relying on §5 as the Gate-3 evidence, since as written they give a misleading pass/fail signal. P2 items optional.
