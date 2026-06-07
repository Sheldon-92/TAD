# Phase 2 Impl — product-thinking categorical rubric (Blake)

**Handoff:** HANDOFF-20260606-nondev-verdict-shapes-p2.md
**Epic:** EPIC-20260606-nondev-verdict-shapes.md (Phase 2/3)
**Date:** 2026-06-06
**task_type:** yaml · **e2e_required:** no

---

## Files created / modified

| Action | Path |
|--------|------|
| CREATE | `.tad/capability-packs/product-thinking/references/pressure-test-rubric.md` (canonical source) |
| CREATE | `.claude/skills/product-thinking/references/pressure-test-rubric.md` (installed; byte-identical copy via `cp`) |
| EDIT (surgical, product-thinking row only) | `.tad/capability-packs/deliverable-rubrics.yaml` |

mkdir -p created both `references/` dirs (neither existed before).

## Rubric contents (per §3a)

- Header: verdict_shape categorical; Gate judges RIGOR not BUILD/PIVOT/KILL; rigorously-argued KILL = `rigorous` (PASS); cites Phase-1 decoupling firewall (`gate/SKILL.md` categorical branch).
- 5 rigor dimensions D1–D5, each with rigorous/partial/superficial criteria:
  - D1 Adversarial rigor (load-bearing) · D2 Evidence grounding · D3 Fatal-flaw analysis · D4 Verdict justification · D5 Product-type adapter use.
- Band decision tree (§B): `superficial` if D1==superficial OR ≥2 superficial; `rigorous` if D1==rigorous AND ≥4 rigorous AND 0 superficial; else `partial`. Includes worked thin-test discrimination check → superficial/FAIL.
- Anti-theater/decoupling rule + Swap Test (§C), verbatim intent sentence.
- Judge output contract (§D): per-dimension band table → swap-test line → `band:` ABOVE `content_verdict:` → derived `verdict: PASS|PARTIAL|FAIL`. Matches `gate/SKILL.md` L479 order firewall.
- Source citations table pointing to real on-disk lines (pressure-test.md L8/L10-11/Step7; fatal-flaws.md L5 verbatim; adapters/*.md; gate/SKILL.md L453-479).
- Explicitly self-contained: usable by a judge given only rubric path + artifact path.

## Registry edit (per §3b)

product-thinking row now: `rubric_ref` → installed rubric path; `pass_threshold`/`partial_threshold` null; `verdict_shape: categorical`; `dogfood_capable: yes`; `status: active`.
Kept `interim_rubric_source` line as a provenance anchor (annotated "folded into the active rubric's D3 citation") — judgment call per §3b ("keep as comment/provenance anchor"). No other packs' rows touched (the ai-podcast-production block appears in `git diff` only as a hunk-boundary artifact from the product-thinking row growing by 1 line; its bytes are unchanged, and it was already present + pre-modified per session-start `git status`).

## §5 Verification output

```
AC-files-exist
AC5-byte-identical
AC1-dims-present
AC2-decouple-OK
AC2-swaptest-OK
AC3-cite-OK
AC4-rubric_ref-exists: .claude/skills/product-thinking/references/pressure-test-rubric.md
AC4-shape-OK
AC4-active-OK
```

Supplementary checks:
- `yq '.packs | keys'` → all 5 packs parse (YAML valid): academic-research, ai-voice-production, video-creation, product-thinking, ai-podcast-production.
- `grep -cE '^### D[0-9]'` rubric → 5 dimensions.
- `grep "Two or more fatal flaws = KILL"` fatal-flaws.md → L5 (verbatim source confirmed; rubric quotes it).
- `diff SRC INST` → empty (byte-identical).

## AC1–AC5 self-assessment

- **AC1 PASS** — 5 named rigor dimensions (D1–D5), each with rigorous/partial/superficial criteria. Evidence: `grep -cE '^### D[0-9]'` = 5; `AC1-dims-present`.
- **AC2 PASS** — Header + D4 state "rigorously-argued KILL … is `rigorous` (PASS)"; §C carries the verbatim swap-test sentence ("If flipping the final BUILD/PIVOT/KILL word would change your band, you are scoring the conclusion — re-score"). Evidence: `AC2-decouple-OK` + `AC2-swaptest-OK`.
- **AC3 PASS** — "2+ fatal flaws = KILL" cited to fatal-flaws.md L5 (quoted verbatim, not interpolated); 6 forcing rounds cited to pressure-test.md Steps 0–6 / L8. Evidence: `AC3-cite-OK`; source-line grep confirms L5 text exists on disk.
- **AC4 PASS** — registry product-thinking row: `rubric_ref` non-null and points to an EXISTING file (`test -f` passed), `verdict_shape: categorical`, `status: active`. Evidence: `AC4-rubric_ref-exists` + `AC4-shape-OK` + `AC4-active-OK`.
- **AC5 PASS** — both copies byte-identical. Evidence: `AC5-byte-identical` + post-cp `diff … && echo BYTE-IDENTICAL-OK`.

## Discrimination guarantee (handoff §6)

Band criteria reference ONLY rigor (rounds run, real searches, FACT/ASSUMPTION discipline, fatal-flaw scan, adapter use) — never BUILD/PIVOT/KILL. A thin pressure-test (single encouraging answer, 0–1 searches, no fatal-flaw scan) forces D1=superficial + D2=superficial + D3=superficial → §B rule 1 → `superficial` → FAIL. Documented as the worked example inside the rubric.

## Deviations

None functional. One judgment call: retained `interim_rubric_source` as provenance (handoff §3b permitted "keep as comment/provenance anchor OR remove — your judgment"). Annotated rather than removed so the fatal-flaws.md provenance trail stays visible.

---

## Phase-2 impl-review fix log (2 P1 + 1 P2)

Applied to BOTH copies; re-verified byte-identical (`BYTE-IDENTICAL-OK`) + full §5 block re-run green.

- **P1-1 (D5 self-containment) — FIXED.** Embedded a compact 6-row per-type differentiator table inside D5 (software/hardware/ecommerce/service/content/marketplace), each row giving the distinguishing data sources + wedge/2-week shape a judge can check in the artifact. Signals condensed from `adapters/{type}.md` (Data Sources §, Q4 row, 2-week section) — verified against on-disk adapters before writing. D5 band cells updated to reference "the table above". D5 is now scorable from the rubric path alone — no need to open `adapters/*.md`.
- **P1-2 (D4 skim-misread) — FIXED.** Inserted the decoupling clause INTO the D4 `rigorous` cell itself: "A named verdict — **any of BUILD/PIVOT/KILL; a rigorously-justified KILL scores `rigorous` here exactly like a rigorously-justified BUILD** — …". No longer relies only on the note box below the table.
- **P2-1 (citation off-by-one) — FIXED.** Pinpoint citation for "refuse category-level answers / demand actual names" corrected L28→L27 (verified on disk: L27 is the bullet, L28 is blank). The block-range citations "L14–28" (D1 source block + citations table) are intentionally left as-is: they describe the whole Anti-Sycophancy Rules block, which legitimately spans L14 header through L27 last bullet with L28 the trailing blank line — a correct block range, not a pinpoint.

Re-verification: §5 block all green (AC1-AC5), `diff` empty, registry resolves (`AC4-rubric_ref-exists`). Fix-specific greps: differentiator table + all 6 type rows present; D4 in-cell decoupling present; no remaining `L28/L139` pinpoint, `rejected at L27/L139` present.
