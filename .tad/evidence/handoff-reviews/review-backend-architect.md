# Backend-Architect Review — HANDOFF-20260613-pack-quality-phase1-bar-baseline

**Reviewer lens:** data flow, type/set extensions, storage patterns, contracts, system architecture, state management
**Scope read:** §6, §9 + §9.1, §10, §7 listed files (pack-eval-runner.sh, EPIC, 24 SKILL.md set, evidence dir). §2.1/§3/§4 read as OPTIONAL to disambiguate findings.
**Date:** 2026-06-13
**Note:** This handoff is already in `.tad/archive/`; BASELINE-AUDIT.md / QUALITY-BAR.md / negative-controls already produced. I reviewed the DRAFT design for Gate-2 architectural correctness and cross-checked against the produced state.

---

## Critical Issues (P0)

### P0-1 — The input premise that drives §4.2 / §4.3 / AC8 is a HARDCODED COUNT of a DERIVED SET, and the count is WRONG
- **§2.1** asserts: "26 个 fixtures 跨 23 个包 …即 **1 个包没有 fixture**". §4.2 then encodes the singular: "无 fixture 的**那个**包 … 自动进最弱批". §4.3 mirrors "无 fixture 的包". AC8 verifies a single LOW marker.
- **Ground truth (scoped to the 24-pack target set):** Blake's MQ1 re-scan found **2** no-fixture packs (`ml-training` + `ai-podcast-production`); the "23" miscounted by folding the non-target pack `research-methodology` into the denominator. The frontmatter `gate4_delta` already records this exact divergence.
- **Now even more divergent:** a live re-scan today shows fixtures were added to BOTH `ml-training` (`examples/lora-config-decision.md`, created 12:46) and `ai-podcast-production` (`examples/full-episode-production.md`, created 19:01). At this moment **0 of 24** target packs lack a fixture, and every fixture carries a `discriminative_pattern`.
- **Architectural defect (the real one):** the design hardcodes the cardinality of a set (`{packs without fixture}`) that is DERIVED from the filesystem and CHANGES over time. This is precisely the anti-pattern in this project's own L1 principle *"Never pin an absolute count — assert set-equality live"* and *"diff -r is the universal omission catcher."* The audit's "auto-into-Batch-1" routing rule must consume `derive {p : no fixture(p)}` at runtime, not a literal "1" / "the one pack."
- **Fix:** Rewrite §2.1/§4.2/§4.3/AC8 to (a) DERIVE the no-fixture set at audit time (`for p in <24-list>: test -d examples && ls examples/*.md`), (b) state the rule for **0..N** packs (plural, set-valued), (c) make AC8 conditional: *if* the derived set is non-empty, every member must be LOW-tagged AND in Batch 1; *if* empty, AC8 is N/A (and the audit must say so explicitly rather than fabricate a LOW row). The handoff as drafted is unbuildable-as-written against current reality (no "that pack" exists).

### P0-2 — §7.2 file-to-modify (`EPIC-…leveling.md`) does not exist at the stated path; the Phase's required write target is mis-grounded
- **§7.2 / FR3 / Step 3** mandate "回填 Epic Phase Map" into `.tad/active/epics/EPIC-20260613-capability-pack-quality-leveling.md`.
- **Ground truth:** that path does NOT exist. The file lives at `.tad/archive/epics/EPIC-20260613-capability-pack-quality-leveling.md` (already archived). `ls .tad/active/epics/` shows only surplus-burn / reading-companion / tier1-workflow.
- **Why this is P0 for an architect:** the handoff §7.3 claims everything is "Grounded Against" reality and Gate-2 ticks "Functions Verified ✅" — but the single mutable write target of the whole Phase was never grounded. A Phase whose terminal data-flow sink (write batch grouping back into the Phase Map) points at a nonexistent/archived file has an incomplete write contract. Blake would either fail the write or silently create a stray file.
- **Fix:** correct the path to the real EPIC location and confirm it is writable/active; if the Epic is already archived, define explicitly where the Phase-2-5 batch assignment is persisted (the audit's "回填动作" sink must resolve to a real, intended file).

---

## Recommendations (P1)

### P1-1 — AC8's grep is a substring sieve that fires on bare `LOW`, decoupled from the routing semantics it claims to verify
- AC8: `grep -iE 'LOW|低置信|无 ?fixture|missing fixture'`. Dry-run: `echo "confidence LOW here" | grep -iE 'LOW…'` → matches. Any prose containing the substring `LOW` (e.g. "follow", "below", "flow", "allow") satisfies it. The criterion's stated intent — "the no-fixture pack is LOW-confidence AND routed to Batch 1" — is a TWO-part relational claim (per-pack confidence + batch membership), but the verifier checks neither relationally; it just proves the token exists somewhere. This is the validation-theater shape §10.1 warns against, reappearing in the gate that polices it. **Fix:** verify the conjunction on the SAME row: for each derived no-fixture pack, assert its table row carries LOW *and* that pack appears in the Batch-1 grouping (a 2-column row-scoped check, mirroring how AC2 was already hardened to "name + score on the same row").

### P1-2 — Double-counting guard (§4.1 分层归属规则) is asserted as prose but has no verifier
- §4.1 correctly identifies the contract: each criterion belongs to exactly one layer; `CONSUMES/PRODUCES`→Layer A only; fixture-existence is a Layer-A structural item whose *discriminative result* is a separate behavioral sub-score; "审计表里的列只是展示 flag (同一事实不得灌 3 个数)." This is the right architecture (separation of structure / depth / behavior axes). **But no AC checks it.** Nothing prevents the produced audit from feeding fixture-presence into Layer-A score AND Layer-B score AND a behavior column as three independent positive signals — the exact failure mode §4.1 names. **Fix:** add an AC that the综合分 formula is stated and that fixture-presence contributes to exactly one additive term (the produced BASELINE already does `compA + 2*B` with disc as a separate non-additive flag — good — but that invariant should be gate-checked, not left to Blake's discipline).

### P1-3 — Confidence is a first-class data field but its domain/derivation rule is under-specified
- The audit introduces a `置信度 ∈ {LOW, MED, HIGH}` column that materially drives ranking trust. §4.2 only defines LOW (no fixture). HIGH (gold anchors) and MED (single-reviewer specN-informed) are used in the produced table but NOT defined anywhere in the handoff design. For a field that gates how much weight the human puts on each batch assignment, the state machine (what makes a pack MED vs HIGH) must be in the rubric, not invented at execution. **Fix:** define the full confidence enum + derivation predicate in QUALITY-BAR.md so the column is reproducible/auditable (NFR2 spirit).

---

## Suggestions (P2)

### P2-1 — `disc` column conflates "eval-harness wired" with "behavioral result"
- The produced table uses `disc = fixtures-with-discriminative-pattern / total fixtures` and explicitly footnotes "N/A=无 fixture (非新鲜行为评估——那是 Phase 2-5 DoD)." That is the correct scoping, but the handoff §4.3 calls it "取 discriminative 结果作为客观分量," which reads as if a real PASS/FAIL behavioral verdict is produced in Phase 1. Tighten §4.3 wording to "wiring-readiness flag, not a behavioral verdict" to prevent a future reader treating the column as an objective quality score.

### P2-2 — `git_tracked_dirs: []` in frontmatter vs artifacts under `.tad/evidence/`
- Frontmatter declares no git-tracked dirs, yet the Phase writes `QUALITY-BAR.md` / `BASELINE-AUDIT.md` into `.tad/evidence/pack-quality/` and modifies an EPIC. If these are intended to be committed (they are durable rubrics, not transient evidence), the empty `git_tracked_dirs` may misroute the release/sync deny-list logic. Worth a one-line confirmation that pack-quality rubrics are intentionally evidence-tier (untracked) vs methodology-tier (tracked).

---

## Overall Assessment: **CONDITIONAL PASS**

The two-layer rubric architecture is genuinely sound: Layer A (structure) / Layer B (depth, 0/2/5 operationalized) / discriminative behavior are correctly separated onto distinct axes (§4.1), both layers carry symmetric negative controls (NFR1 + NFR4), and the "never pin 6/6/6/6" + re-rankable-batches design (§4.2) respects the project's count-pinning principle for the *batch* dimension.

The blocker is that the SAME count-pinning anti-pattern leaks into the **fixture-set** dimension: §2.1's "1 pack without fixture" is a hardcoded, derived, and factually-wrong cardinality that propagates into §4.2/§4.3/AC8 (P0-1), and the Phase's terminal write target is mis-grounded (P0-2). Both are pure data-flow / contract defects an architect must block on. Notably, Blake's execution already self-corrected P0-1 at runtime (gate4_delta records 1→2), which is evidence the design *underspecified* the set rather than the executor failing — i.e. the handoff should have shipped the derive-the-set rule, not a literal "the one pack."

Resolve P0-1 (set-valued, runtime-derived no-fixture routing + conditional AC8) and P0-2 (correct EPIC write path), and this passes.
