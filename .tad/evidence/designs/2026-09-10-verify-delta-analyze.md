# Analyze / Design: verify-delta (runnable Verification Method fail-close)

**Date:** 2026-09-10  
**Mode:** Alex `*analyze` (standard) — demand + design only  
**Channel / model (this design session):** `channel=cursor` `model=cursor-grok-4.6-medium`  
**Discuss baseline:** `.tad/evidence/designs/2026-09-10-pstack-verify-delta-discuss.md`  
**Handoff:** `.tad/active/handoffs/HANDOFF-20260910-verify-delta.md`  
**Status:** design for Blake; **Alex must not implement** skill/`tad.sh` edits; **do not dispatch Blake** from this terminal.

---

## 1. Outcome

Landing work (`*analyze` / formal `HANDOFF-*` / `*express` / `*bug` mini-handoff) **cannot go Gate 3 green or Gate 4 green** unless every in-scope acceptance row has a **legal runnable Verification Method** (shell command in backticks, evidence-path check, fixture runner, or existing rubric-judge spawn). Light work (`*discuss` / `*idea` / `*learn`) may mark **N/A** with a one-line reason and must not invent fake commands.

This is a **wording / grammar tightening of the existing §9.1 Verification Method column** — **not** a new `verify:` YAML/frontmatter/table field.

## 2. Human-locked decisions (2026-09-10) — Socratic closed

| # | Question (from discuss) | Lock |
|---|-------------------------|------|
| 1 | New `verify:` field vs tighten §9.1 | **Tighten existing Verification Method grammar. No new field.** |
| 2 | `*bug` + AR-001 reviewer | **Runnable verification only first. Do not mandate ≥1 review on mini tickets yet.** |
| 3 | `*express` skip e2e | **Cheaper runnable checks (grep / fixture / targeted test) are OK.** |
| 4 | Fail-close height | **Cannot go green at BOTH Gate 3 and Gate 4** if runnable verification is missing or never executed. |
| 5 | Trust-curve home | **Skills/judgment only. Do not add an L1 `principles.md` line.** |

Process depth: **standard** (protocol-contract change, ~10–16 files including dual-platform mirrors, no new architecture). Human said **可以派了** after locks — Adaptive Complexity treated as decided; not re-opened.

Epic: **no**. Single handoff. Do not attach to in-flight publish/v2.44.4 or other epics.

## 3. Problem (why this patch)

Formal handoffs already execute §9.1; empty §9.1 already BLOCKS Gate 3; paper-accept is a VIOLATION. The **remaining hole** is **prose-as-method**, especially `*bug` mini-handoffs whose AC is still “Bug no longer reproduces under reported conditions” with no command. `step1d` and `verify-ac-commands.sh` stay **smoke alarms** (not hooks). Dev-floor stays **WARN not BLOCK**.

pstack/Lauren Tan: take only this fail-close. Skip auto-merge PRs, thicker GM/PM, Dune/Grok Bot source, wholesale parallelism, eval tools (Workshop).

## 4. Legal Verification Method grammar (no new column)

Keep table columns: `# | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output`.

A Method cell is **LEGAL** iff it is exactly one of:

1. **Runnable command** — pasteable shell in backticks (`grep` / `test -f` / test runner / script). Expected Evidence is an observable exit/output.
2. **Evidence path check** — named path plus a command that asserts existence or content.
3. **Fixture runner** — named fixture path plus the command that executes it.
4. **Rubric/judge spawn** — existing deliverable phrase (`spawn independent judge per Rubric Evaluation Protocol…`).
5. **`N/A` + reason** — **only** on light-tier artifacts that never enter Gate 3/4 (`*discuss` / `*idea` / `*learn`).

**ILLEGAL** (Gate 3 row FAIL → cannot Gate 3 PASS; Gate 4 Functional acceptance cannot PASS):

- Prose-only (“bug no longer reproduces”, “looks OK”, “human verified”, “manual check” with no command).
- Empty Method cell on a landing-tier row.
- Invented commands on light-tier notes.

`*express` with `e2e_required: no` is still landing-tier: **≥1 legal cheaper runnable** is required.

`*bug` mini-handoff: replace checkbox-only AC with **at least one legal Method** (repro command, failing-then-passing test, or grep/fixture). **Do not** add min-1 expert review in this patch.

## 5. Fail-close (judgment in Gates, not hooks)

| Gate | Rule |
|------|------|
| Gate 3 | Empty §9.1 still BLOCKS. **New:** any landing row whose Method is illegal → that row FAIL → **cannot mark Gate 3 PASS** (or a “green” PARTIAL whose only gap is missing verification). `honest_partial` remains for unrelated env/scope gaps, not as a bypass for missing runnable methods. |
| Gate 4 | Functional acceptance **cannot PASS** if landing rows lacked legal methods or Blake never **executed** them. **Cannot accept on Blake summary / story alone.** Independent recompute of the same commands still required. |
| Gate 1 | “Acceptance criteria verifiable” already exists; cite the same grammar (SSOT still `gate-canonical-checklist.md`). |

**Forbidden:** PreToolUse / settings registration; making `step1d` or `verify-ac-commands.sh` a deny-hook (Mechanical Enforcement Rejected).

## 6. Trust curve (judgment only)

Do **not** expand parallelism, extra bots, or unverified capability until that capability’s evidence chain has actually run. Encode as **short judgment notes** in `gate/SKILL.md` and (if needed) Alex/Blake skill judgment — **not** a Gate checklist item, **not** `principles.md`.

## 7. Optional `*eval` intent-shell (cheap only)

If it fits in **≤20 lines** total across Alex `SKILL.md` commands + intent-router explicit list (both platform trees): add `*eval` as **intent-shell** — tell the human eval/blind-eval tools live in Agent Workshop; **do not** add eval runners, checklists-as-tools, or Gate items. If it would bloat the SKILL body, Blake records `EVAL_STUB_DEFERRED` and skips. **Blind-eval tools are out of Blake scope.**

## 8. File / protocol map (Blake later)

| Path | Change |
|------|--------|
| `.tad/templates/handoff-a-to-b.md` | §9.1 grammar: legal/illegal Method; no `verify:` field; examples include grep/fixture as legal; prose-only as FAIL. |
| `.claude/skills/alex/references/handoff-creation-protocol.md` | `step1_ac_generation` + `step1d`: same grammar; still not a hook. Dual: `.agents/skills/alex/references/…` byte-identical. |
| `.claude/skills/alex/references/bug-path-protocol.md` | Mini-handoff AC: legal Method required; keep skip Socratic **and** skip expert review. Dual `.agents/…`. |
| `.claude/skills/alex/references/express-path-protocol.md` | Skip e2e only if ≥1 cheaper legal runnable remains. Dual `.agents/…`. |
| `.claude/skills/gate/SKILL.md` | `Spec_Compliance_Verification` + empty guard note + Gate 4 Functional acceptance fail-close; trust-curve **judgment** paragraph (not a checklist row). Dual `.agents/skills/gate/SKILL.md`. |
| `.tad/gates/gate-canonical-checklist.md` | Gate 1 “verifiable” + Gate 3 §9.1 + Gate 4 functional: same fail-close sentences (SSOT first, then propagate). |
| `.tad/templates/acceptance-verification-guide.md` | Align “each AC needs a runnable verification” with the grammar; mention `*bug` mini. |
| `.claude/skills/alex/references/acceptance-protocol.md` | Gate 4 must recompute methods; cannot green on summary if methods missing/unrun. Dual `.agents/…`. |
| Light-tier one-liners (optional if cheap) | `discuss` / `idea` / `learn` path refs: N/A allowed; no fake commands. Dual mirrors. |
| Optional | Alex `SKILL.md` `*eval` stub + intent-router token; dual `.agents/skills/alex/SKILL.md`. |
| Fixture | `.tad/evidence/acceptance-tests/verify-delta/` — LEGAL vs ILLEGAL Method examples (ILLEGAL example may quote the old bug checkbox **only inside this fixture / gate illegal-example**, not as the live bug template). |
| **Do not touch** | `principles.md`; `tad.sh`; `.tad/hooks/**`; `.claude/settings.json`; `.codex/hooks.json`; auto-merge; `docs/pm/` thicken; Dune/Grok sources; parallelism quotas; version bump unless human later bundles. |

Parity: every edited `.claude/skills/{alex,gate}/**` file that has an `.agents/skills/` twin must remain **byte-identical**.

## 9. Success / discrimination

- A planted **prose-only** Method on a landing handoff **fails** Gate 3 (and cannot Gate 4 PASS).
- A **grep/fixture** Method **can pass** (express skip-e2e path).
- `*discuss` with N/A is unchanged / not a Gate event.
- `git diff` on `principles.md` is empty for this task.
- No new `verify:` key in handoff template frontmatter or §9.1 column headers.

## 10. AC conflict matrix

| Tension | Resolution |
|---------|------------|
| Byte-preservation of SKILL SAFETY counts vs adding FAIL language | Add **genuine** fail-close sentences on the new surface (prose-method); do not pad; do not delete MUST/VIOLATION blocks. Line-set > global count. |
| `*bug` skip review vs AR-001 | **In-scope:** only Method fail-close. AR-001 / min-1 review on mini tickets **out of scope** (human lock). Do not “fix” that conflict in this patch. |
| Empty-§9.1 BLOCK vs present-but-prose §9.1 | Empty still BLOCKS; prose-only is a **row FAIL**, not the empty guard. |
| Dev-floor WARN vs this fail-close | Unchanged: missing tsc/test on code handoffs stays WARN. This patch is about **illegal Method cells**, not missing dev-floor rows. |
| `honest_partial` vs “cannot go green” | PARTIAL is allowed for other honest gaps. Missing/unrun runnable verification **cannot** be the thing that is still called a green PASS. |

## 12. Gate 2 R1 (2026-09-10)

Independent spec + code reviews **FAIL**. Integrated into handoff v3.1.1: legality-before-execute as ordered Gate 3 step; Gate 4 recompute + no-summary; mini-handoff **must include §9.1**; AC1 removed from Gate 3 table; ACs exit-0 on success; lock 2 preservation AC.


Auto-merge PRs; thicken PM; Dune/Grok Bot source; wholesale parallelism; blind-eval tools; L1 principle; new YAML field; hook enforcement.
