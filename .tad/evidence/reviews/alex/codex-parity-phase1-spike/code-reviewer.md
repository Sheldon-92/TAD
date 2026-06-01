# Code Review — HANDOFF-20260601-codex-parity-phase1-spike (DRAFT)

**Reviewer:** code-reviewer (Alex pre-handoff, blue-team QA)
**Date:** 2026-06-01
**Artifact:** design spec / handoff draft (no code yet)
**Scope:** §6, §7, §9 + §9.1, §10 of the handoff; `.tad/portable-rules.md`; live `codex-alex-skill.md` head.
**Verdict:** CONDITIONAL PASS — 2 P0 must fix before ship; both are cheap.

All grep/wc claims below were empirically re-derived on the live edition and source SKILL, not read from the handoff's own dry-run log.

---

## 1. Critical Issues (P0 — must fix before handoff ships)

### P0-1 — §9.1 AC1-constraint command has the `\|`-in-ERE literal-pipe bug → returns 0, would FALSE-FAIL the regen

The §9.1 table (line 189) writes the constraint command with an **escaped** pipe:

```
grep -coE 'MUST\|MANDATORY\|VIOLATION' <regen>
```

With `-E` (ERE), `\|` is a **literal pipe character**, NOT alternation. Empirically:

```
$ grep -coE 'MUST|MANDATORY|VIOLATION' codex-alex-skill.md     # AC1 body form (line 177)
54
$ grep -coE 'MUST\|MANDATORY\|VIOLATION' codex-alex-skill.md   # §9.1 table form (line 189)
0
```

The §9.1 "Verified Output" cell claims this command "returns `54` on live edition (baseline)" — that is **wrong**; the command as written returns `0`. The handoff's own dry-run log (§9.1 line 199) repeats the false `54`. This is exactly the known bug class flagged in the task brief. Blake will copy the §9.1 command literally; on the regen it returns 0 < 10 → AC1 **false-fails** a correct regen.

Note the AC1 **body** (line 177) is correct (bare `|`, no backslash). Only the §9.1 table row and the dry-run log are wrong — the contract is internally contradictory, and §9.1 is the row Blake runs.

**Fix:** in §9.1 line 189 change `'MUST\|MANDATORY\|VIOLATION'` → `'MUST|MANDATORY|VIOLATION'` (drop both backslashes; `-E` is present). Re-run and paste the real `54`.

Caveat for the fixer: AC2-step45 (`grep -ci 'step4_5\|Pack Awareness'`, lines 178 & 193) is **BRE** (no `-E`), where `\|` IS correct alternation — verified returns the expected value on a file that contains `step4_5`. Do **not** "fix" that one by removing the backslash; it is only the `-E` row that is broken. This asymmetry is itself a footgun and should get an inline comment.

### P0-2 — `portable-rules.md` does not say whether dream/evolve/optimize/yolo/sync/publish protocols are CARRIED or STRIPPED → regen + parity-criterion are both undefined for 16 of 30 protocol sections

The parity-criterion §4 layer 1 ("section coverage") enumerates the source's `*_protocol:` YAML keys and requires the Codex edition to carry a corresponding section. Empirically the source has **30** such keys; the live drifted edition has **14**. Of the 16 missing:

```
dream_ evolve_ optimize_ yolo_execution_ sync_ sync_add_ sync_list_ publish_
research_plan_ research_review_ research_decision_ status_panoramic_
update_roadmap_ test_review_ exit_ idea_list_ idea_promote_
```

Some of these (dream/evolve/optimize/yolo_execution/sync/publish) are **Conductor / release-automation** protocols that arguably *should not* exist in a Codex single-session edition. But `portable-rules.md`'s Preserve-NEVER-Delete list **does not name any of them** (verified: grep for dream|evolve|optimize|yolo|sync|publish|conductor in portable-rules.md → 0 hits), and its Transform table has no "strip these whole protocols" row either. So today the rules are **silent** on 16/30 sections.

Consequence:
- **Regen (Step 3):** Blake has no rule telling it whether to include or drop these → the regen's section set is non-deterministic / reviewer-judgment, defeating "rule-driven, not blind deletion" (§2).
- **Parity-criterion (Step 4):** if the check requires all 30, it will report MISSING for legitimately-stripped Conductor protocols → it cannot reach exit 0 on *any* faithful Codex edition (false-FAIL the regen, AC4-parity unreachable). If it requires only the live 14, it bakes the drift into the baseline (false-PASS). There is no correct threshold without an explicit carry/strip classification.

**Fix (pick one, state it in the handoff):**
(a) Add to §6 Step 2 / §4 an explicit **"expected-absent in Codex edition" allowlist** (the Conductor/automation protocols) that parity-criterion subtracts from the required-section set, AND add the corresponding strip row to `portable-rules.md` so the regen is deterministic. This is the principled fix and likely surfaces a real `portable-rules.md` gap (the handoff already anticipates this in its Evidence Manifest "knowledge_updates" line — make it a required output, not optional).
(b) If Phase 1 wants to stay minimal: scope the parity-criterion's section layer to a **named must-cover subset** (the user-facing Alex protocols: socratic, adaptive_complexity, intent_router, design, handoff_creation, acceptance, research_plan, express, experiment, bug/discuss/idea/learn paths) rather than "all `*_protocol:` keys", and explicitly defer the Conductor-protocol classification to P3. Document the subset in `parity-criterion.md`.

Either way the handoff currently ships an unrunnable layer-1 definition. This is load-bearing because AC4 (the anti-theater heart of the spike) depends on the criterion both failing the drifted edition AND passing the regen.

---

## 2. Recommendations (P1)

### P1-1 — Section-coverage layer DOES discriminate; lock that into AC4 so it isn't satisfied by a weaker layer
Good news for soundness: the drifted edition is missing 16/30 protocol keys, so layer 1 alone already exits 1 on it. But AC4 only checks "reports missing deliverable track" — that is the *capability-marker* layer (layer 3), not section/constraint. Strengthen AC4 to assert the **specific missing items per layer** the drifted edition must report (e.g. "MISSING must include ≥1 protocol section AND the `deliverable`/`research_complexity` capability markers"), so a future regression where only one layer fires is caught. As written, a parity-check that implemented only layer 3 would pass AC4 while leaving layers 1–2 as dead code.

### P1-2 — `grep -co` occurrence-vs-line semantics is an undocumented load-bearing assumption
AC1-constraint expects `≥10` "constraints". `grep -coE` on BSD returns **occurrence count** (54), while `grep -cE` (no `-o`) returns **line count** (52). The floor of 10 is comfortably clear either way, so this is not a P0, but the criterion/AC should state which it means, because a future tighter floor (e.g. "≥ source_count − N") would be sensitive to it. Recommend documenting "`grep -coE` = occurrence count" in `parity-criterion.md` where the constraint floor is derived. (Also note: deriving the floor from the *source* count is better than a magic `10` — the live edition has 54; a regen that dropped to 12 would pass AC1 yet have silently lost ~75% of constraints. Consider `≥ floor(0.8 × source_occurrences)` for the constraint layer in parity-criterion, keeping the AC1 hard floor of 10 as a separate cheap smoke check.)

### P1-3 — Regen as a single Blake step is feasible but the size/fidelity tension needs an explicit decomposition guard
The source is **326,300 bytes** (~319KB, claim confirmed) with **82** `AskUserQuestion` sites. "LLM reads 326KB + applies ~12 transform rows + preserves ~16 NEVER-Delete categories → emit ≤100KB edition" in one shot is plausible for a 1M-context model but is the single highest-risk step. The risk is **silent truncation/summarization**: an LLM asked to emit a long transformed doc tends to compress prose, which would drop protocol content and *reduce* the constraint count — directly threatening AC1-constraint and AC2. Recommend §6 Step 3 add an explicit instruction: "transform is **line-local strip/replace**, NOT summarization — preserve all non-stripped lines verbatim; do not paraphrase protocol bodies", plus a post-emit self-check that constraint occurrence count ≥ source minus the stripped-rows delta. This is cheaper than decomposing into N chunked steps and de-risks the one-shot. If the first regen comes back under, say, 25KB (vs live 35KB / source 326KB), treat that as a truncation tell, not success.

### P1-4 — AC1 body vs §9.1 `wc -c` form mismatch (cosmetic but copy-paste hazard)
AC1 body (line 177) writes `wc -c <regen>` (space form → prints `35849 filename`); §9.1 (line 190) writes `wc -c < <regen>` (redirect form → prints `35849`). Both yield a usable number, but a `≤102400` numeric comparison on the space-form output requires field extraction. Standardize on the redirect form (`wc -c < FILE`) in both places so the value is directly comparable.

### P1-5 — AC6 scratch-isolation is verifiable but incomplete as a guarantee
`git status --porcelain .tad/codex/codex-alex-skill.md` empty (verified currently empty, exit 0) correctly proves the *tracked* live file is byte-unchanged. Good. But it does **not** prove the regen wrote only to scratch — a stray write to any *other* live file under `.tad/codex/` would pass AC6. Recommend broadening to `git status --porcelain .tad/codex/` (whole dir) empty, OR asserting the regen output path is exactly `.tad/evidence/spikes/codex-parity/codex-alex-skill.regen.md` and nothing under `.tad/codex/` changed. The handoff's "MUST NOT touch" is dir-level intent; the AC should match that scope.

---

## 3. Suggestions (P2)

- **P2-1 — Add `LC_ALL=C` to the parity-criterion's comm/sort, and say so in AC4's runnable form.** §10.4 mentions it; Step 4 mentions it; but the section-coverage layer will almost certainly use `comm`/`sort` over protocol-key lists. Per the project's own "comm -12 CJK LC_ALL=C" lesson, set `LC_ALL=C` on the `comm` AND both feeding `sort`s. Protocol keys are ASCII so the risk is low here, but capability-marker tokens or section titles could carry CJK — make it a rule in `parity-criterion.md` not an afterthought.
- **P2-2 — `parity-check.sh` exit-code contract is clean (0/1/2); document the WARN-and-continue path's exit code.** §10.4 says fail-open WARN on parse error. Specify: does a parse-error WARN still allow exit 0 (parity) if all checks otherwise pass, or force exit 2 (NA)? An anti-theater check should arguably never silently exit 0 after a WARN it couldn't evaluate. Recommend: any WARN that skipped a coverage layer → max exit 2, never 0.
- **P2-3 — Capability-marker list provenance.** §4 layer 3 says markers are "auto-extracted". Specify the extraction source (the source SKILL's new tokens since the live edition's `Generated:` date is not mechanically knowable). A hand-seeded list (`deliverable`, `research_complexity`, `step4_5`, pack-collision `5b`) is fine for Phase 1 — just label it "hand-seeded, P3 automates" in `parity-criterion.md` so it isn't mistaken for a derived guarantee.
- **P2-4 — `grep -c 'deliverable'` counts lines, not the deliverable *track*.** AC2 `≥5` is a reasonable smoke proxy, but a regen could contain 5 incidental mentions of the word without the actual `task_type: deliverable` routing. Cheap hardening: AC2 also assert `grep -c 'task_type: deliverable' <regen> ≥1` (the routing anchor), not only the bare word.

---

## 4. Overall Assessment

**CONDITIONAL PASS.**

The spike is well-scoped, correctly spike-first, and the anti-theater framing (§10.1, AC4) is exactly right. Empirical re-derivation confirms the core premise is sound: the live edition is genuinely drifted (deliverable=0, research_complexity=0, step4_5=0, and missing 16/30 protocol sections), and the section-coverage criterion demonstrably discriminates — so the spike's central question ("can a mechanizable parity check reliably fail the drifted edition?") is answerable yes.

Two P0s block ship, both cheap:
- **P0-1**: the §9.1 AC1-constraint command is the literal `\|`-in-ERE bug → returns 0, would false-fail the regen, and the dry-run log certifies a wrong value. One-character-class fix + re-run.
- **P0-2**: `portable-rules.md` is silent on whether 16/30 protocols (incl. Conductor/automation ones) are carried or stripped, leaving both the regen and the parity-criterion's section layer undefined. Needs an explicit carry/strip classification (allowlist or named-subset) before Step 3/Step 4 are runnable.

Fix both, apply P1-1/P1-3 (strengthen AC4 per-layer + add the "strip ≠ summarize" guard), and this is ready for handoff.
