# Phase 1 Design Review — code-reviewer

**Handoff:** `.tad/active/handoffs/HANDOFF-surplus-pack-behavioral-examples-scaffold.md`
**Reviewer:** code-reviewer (shell-portability + contract-completeness lens)
**Date:** 2026-07-05
**Verdict:** CONDITIONAL — 1 P0 blocks; must be resolved before Blake starts.

Scope reviewed: §4 (design), §7 (file list), §9.1 (AC verifiability), frontmatter metadata,
design↔requirement coherence. All claims verified against live repo state.

---

## Grounding verification (what I confirmed as CORRECT)

The reuse-not-rewrite core design is sound and accurately grounded:

- Baseline B1–B4 all reproduce exactly (3 packs × 1 fixture; `pack-eval.sh` absent; gate files 0
  pack-eval mentions; SAFETY counts gate/SKILL.md=32, canonical=1).
- Runner contract in MQ2 is accurate: `parse_pattern` L103, `parse_disc_pattern` L127,
  `count_matches` L170, `assert_one` L191, single-mode `main` returns 0 (advisory). Verdict lines
  really do contain `→ PASS` / `→ FAIL` / `→ SKIP` — the `--check` mapping is well-founded.
- Existing fixtures really carry `## Input Scenario`, `## Expected Markers`, `## Verification
  Command`, `## Anti-Slop Check` + a `grep -oE` line — so `--validate` rules 4/5 will pass them.
- Line references are accurate: inline Gate 3 checklist is at `gate/SKILL.md` L277 ("5 items",
  drifted from canonical's 6) — §10.2's drift note is correct; no automated canonical↔inline drift
  gate exists, so leaving that drift is safe.
- Frontmatter `task_type: mixed`, `e2e_required: no`, `research_required: no` are all defensible.

---

## 🔴 P0 (BLOCKING)

### P0-1 — File list omits ALL `.agents/` Codex-mirror targets; release parity gate enforces byte-identity unconditionally

The repo maintains a **Codex edition** at `.agents/skills/` that must be **byte-identical** to
`.claude/skills/`. This is not advisory — `release-verify.sh parity` (L87-101, L526+) states:
"The invariant is FULL BYTE-PARITY … NO PATCH-RELEASE DOWNGRADE: parity drift is fixed
unconditionally." I ran it: `parity PASS (exit 0)` — the two trees are byte-identical **today**.

Both artifact classes this handoff touches live INSIDE that parity scope, but §7.1/§7.2 list only
the `.claude/` side and never mention `.agents/`:

| Handoff-listed (`.claude` only) | Missing mirror the parity gate requires |
|---|---|
| 3 new fixtures `.claude/skills/<pack>/examples/<slug>.md` | `.agents/skills/<pack>/examples/<slug>.md` (×3) |
| edit `.claude/skills/gate/SKILL.md` | edit `.agents/skills/gate/SKILL.md` (currently byte-identical — verified `diff -q` IDENTICAL) |

If Blake follows the handoff literally, `release-verify.sh parity` FAILS and blocks release/Gate 4.
Worse: **the §9.1 AC suite is completely blind to it** — no row runs the parity verifier, and rows
2/4/9/13 inspect `.claude/` paths only. The handoff would show all-green at Gate 3 while silently
introducing parity drift. This is the exact silent-omission / "diff -r is the universal omission
catcher" failure class that principles.md warns about repeatedly (2026-06-01 entries, Codex-parity
Epic). `pack-eval.sh` is safe (it lives in `.tad/hooks/lib/`, outside the parity scope); the
canonical checklist is safe (`.tad/gates/`, outside scope).

**Required fixes:**
1. Add to §7.1: `.agents/skills/{ai-agent-architecture,web-frontend,code-security}/examples/<slug>.md` (×3).
2. Add to §7.2: `.agents/skills/gate/SKILL.md` (propagate the same additive item, keep byte-identical).
3. Add the `.agents/skills/*/examples` dirs to the frontmatter `git_tracked_dirs`.
4. Add a §9.1 AC row: `bash .tad/hooks/lib/release-verify.sh parity "$(pwd)"` → `VERDICT: parity PASS (exit 0)`. (Or explicitly mandate `parity --fix` after edits, then assert PASS.)
5. Extend AC rows 9 & 13 (and the B4 baseline) to also cover `.agents/skills/gate/SKILL.md`.

---

## 🟡 P1 (SHOULD FIX)

### P1-1 — §4.2.1 rule-6 regex-sanity snippet aborts under the NFR2-mandated `set -euo pipefail`

NFR2 mandates `set -euo pipefail`. The suggested rule-6 snippet is:

```
printf 'x' | grep -oE "$pat" >/dev/null 2>&1; [ $? -le 1 ]
```

Under `set -e` + `pipefail`, a **no-match** grep returns exit 1 — and for a *valid* discriminative
pattern (which contains pack terms, not `x`) a no-match is the **normal** result. As a standalone
pipeline (not in an `if`/`&&`/`||` condition), that non-zero exit trips `set -e` and **aborts the
validator before `[ $? -le 1 ]` ever runs** — on virtually every fixture, valid or not. A bad regex
(exit 2) would likewise crash instead of producing the intended clean `FAIL:` line, contradicting
NFR2 ("never … crash"). If Blake copies the snippet verbatim it will not work.

**Fix:** guard the pipeline so the exit code is captured, e.g.
`rc=0; printf 'x' | grep -oE "$pat" >/dev/null 2>&1 || rc=$?; [ "$rc" -le 1 ] || FAIL...`
(exit 2 → bad regex → FAIL). Note the same discipline applies to the `--check` verdict mapping and
any other bare `grep` under `set -e` — use `if/elif`, never a bare piped grep.

### P1-2 — No AC exercises the parity verifier or the release gate (validation-theater gap)

Independent of P0-1's file-list fix: because the §9.1 suite never runs `release-verify.sh parity`,
a reviewer who fixed only the file list could still ship drift. The task's own stated purpose is to
replace presence-only checks with runnable quality checks — the handoff should hold itself to that
standard by adding the parity assertion as a first-class AC row (see P0-1 fix #4). Without it, "6
fixtures pass --validate" proves the `.claude` side only.

---

## 🟢 P2 (NICE TO HAVE)

- **P2-1 — `--validate` under-covers the documented schema.** FR3/§4.2.4 require `tests_rules`,
  `description`, and a `## Anti-Slop Check` section, but §4.2.1 rule 2/4 only check `name`, `pack`,
  `discriminative_pattern`, the two numeric fields, and three body sections. A fixture missing
  `tests_rules` or `## Anti-Slop Check` still passes `--validate`. Since the whole point is
  mechanical structure enforcement, consider adding these to the lint (rule 2 → also require
  non-empty `tests_rules`; rule 4 → also require `## Anti-Slop Check`).

- **P2-2 — AC row 3 (disjoint `tests_rules`) is eyeball-verified, not mechanical.** "Paste side by
  side … zero overlapping entries" relies on human reading. Given the mechanical-verification theme,
  make it a command: extract each fixture's `tests_rules` bullets, `sort`, `comm -12`, expect empty.

- **P2-3 — FR2's SKIP→exit 2 branch has no §9.1 row.** Rows 6/7 cover PASS→0 and FAIL→1, but the
  documented `--check` SKIP→2 mapping (8.1/8.3 mention it) is unverified in the PRIMARY source. Add
  a one-line row: `--check <fixture> /nonexistent-output.md; echo exit=$?` → `→ SKIP`, `exit=2`.

- **P2-4 — MECE count/prose not fully addressed.** Canonical L33 ("6 items check 6 distinct
  artifacts") and inline L276 ("5 items … 5 distinct artifacts") plus the "Why CE" prose will be
  stale after adding a 7th/6th item. §4.2.3 says "update stated item counts" but not the "N distinct
  artifacts" / "Why CE" wording. Since the new item is conditional ("pack handoffs only"), a short
  note there keeps the MECE claim honest.

---

## Summary

The reuse-not-rewrite architecture is sound, well-grounded, and the runner contract / line
references / baselines all check out. **One P0 blocks:** the handoff ignores the `.agents/` Codex
mirror entirely, yet both the new fixtures and the gate/SKILL.md edit sit inside a scope where
`release-verify.sh parity` enforces unconditional byte-identity — and no AC would catch the
resulting drift. Fix the file list (add 3 `.agents` fixtures + `.agents/skills/gate/SKILL.md`) and
add a parity AC row before Blake starts. P1-1 (the `set -e` rule-6 snippet) will otherwise cost a
debug cycle. P2s are polish.
