# Phase 4 Adversarial Review — ai-agent-architecture (correctness lens)

- **Lens**: correctness (does the upgraded SKILL.md meet the dual-layer bar; is guidance internally consistent and actionable; refute that it meets the bar)
- **Reviewer**: Blake subagent (adversarial, default-skeptic)
- **Date**: 2026-06-13
- **Verdict (meets_bar)**: **true** — clears the bar on the correctness lens despite findings; defects are localized and fixable, none invalidate the dual-layer pass.

---

## Bar checks (measured, not asserted)

### Layer A (structure, threshold 7/10)
- A1 frontmatter name+description: PASS (name lower-case/no "anthropic"; description third-person, what+when, "Two modes").
- A2 progressive disclosure: PASS (11 references/ + examples/ + scripts/).
- A3 body size <550: PASS (SKILL.md = 193 lines).
- A4 routing/steps: PASS (Step 0/1 + Decision Reference Index).
- A5 CONSUMES/PRODUCES: PASS (lines 8-9).
- A6 anti-skip table: PASS (5-row Anti-Skip Table with counter-arguments + legitimate skip conditions).
- A7 navigation index: PASS (Decision Reference Index table).
- A8 fixture present: PASS (examples/multi-agent-design-decisions.md).
- A9 eval-ready: PASS (fixture has `discriminative_pattern:` + `min_discriminative: 3`).
- A10 validation script: PASS (scripts/audit-decisions.sh, executable, ran clean).
→ Layer A = 10/10.

### Layer B (depth, must be >2)
- specN = **70** (measured with the QUALITY-BAR command, LC_ALL=en_US.UTF-8, pack-anchored paths) → ≥60 bucket → Layer B 5.
- B1-B4 reading: rules carry research thresholds (0.95^20≈36%, 15x token multiplier, 8K-55K tool tokens, 98.7% reduction, 50%/85% compaction triggers, 5-gate self-evolution, exit-code semantics in the script). Deep, not restatable-from-training.
→ Layer B = 5/5.

### Discriminative wiring
- Fixture `discriminative_pattern` is pack-unique (D-IDs, "Architecture Decision Document", "Incident #", "dual-agent"); `min_discriminative: 3`; combined `## Verification Command` correctly demoted to SECONDARY. Eval-harness ready.
- audit-decisions.sh ran: PASS all 10 IDs / artifact / conditional dual-agent trigger; exit 0. Locale-safe, no Windows paths, no network.

The pack genuinely clears both layers — the question for the correctness lens is whether the *content is true and consistent*. It mostly is, with the defects below.

---

## Findings (correctness defects — none fatal to the bar, but real)

### F1 (P1, factual accuracy) — Future/false launch date asserted as confirmed past fact, AND mis-labeled "confirmed"
`references/context-compression.md` L63 states the Anthropic context-editing API "**launched 2026-09-29 alongside Sonnet 4.5**". Today is 2026-06-13, so 2026-09-29 is a FUTURE date asserted as a completed past event. WebSearch (2026-06-13) shows automatic/server-side compaction is associated with **Opus 4.6 / Sonnet 4.6** and the **March 13 2026** 1M-context GA — not a Sept-2026 "Sonnet 4.5" launch. The model/date pairing is wrong.
Worse: the file's own VERIFICATION FLAG (L75-78) hedges only the +29%/+39%/−84% percentages and explicitly says "the mechanism (auto-clear stale tool calls, **launch date**) is confirmed" — but the launch date is exactly the unverified/incorrect claim. The pack actively asserts confidence on the wrong fact. Per QUALITY-BAR §6 (version-sensitive claims → check primary docs first), this should be corrected or down-graded to a hedge. Fix: drop the date, or rewrite as "context-editing API (beta header `context-management-2025-06-27`); automatic compaction productized in the Opus 4.6 / Sonnet 4.6 generation (1M-context GA 2026-03-13)".

### F2 (P2, internal contradiction) — "Stale memory > no memory" stated both directions
`references/context-memory.md` L57 (Pattern 2) leads with the bare proposition "**Stale memory > no memory** — an agent confidently acting on month-old information causes worse outcomes…" — the lead clause asserts stale IS better, then the explanation argues the OPPOSITE. L131 (JIT Invalidation) explicitly states "**Stale memory > no memory is FALSE** for high-change domains." A careful reader infers intent from the explanations, but as written L57 asserts a claim its own sentence refutes. Fix L57 to "Stale memory > no memory is FALSE" (or "no memory > stale memory") to match L131.

### F3 (P3, stale self-reference) — claimed replacement not applied everywhere
`references/testing-evaluation.md` L45 says it "**Replaces** the older undated '10-agent chain at 98% = 81.7%' statement". But `references/coordination-and-state.md` L148 STILL contains "10-step chain at 98% = 81.7%". The number is mathematically correct (0.98^10 = 0.8171, verified), so this is not a math error — only a not-fully-applied edit / stale cross-claim. Either remove the "Replaces" wording or update L148 to the dated 0.95-per-step framing.

### F4 (P3, doc/structure nit) — D10 cross-reference table omits D10 row
`references/production-disasters.md` Decision-Disaster table (L137-147) lists D1-D9 but no D10 row. Harmless (D10 IS the disasters file) but asymmetric vs the SKILL's "10 decisions" framing; a reader auditing "all 10 mapped" sees only 9 rows.

### Non-findings (checked, OK)
- Lusser's-law math all verified: 0.95^20≈0.3585 (~36%), 0.95^14≈0.488, 0.90^20≈0.122 (12%), 0.90^7≈0.478, 0.98^20≈0.668 (67%), 0.98^10≈0.817. Consistent across need-an-agent.md + testing-evaluation.md.
- SKILL "single agent → D2 skipped" vs audit-script "all D1-D10 required": NOT a contradiction. The Architecture Decision Document template renders skipped decisions as `D2 → (or: SKIPPED — reason)`, so the literal `D2` token is still emitted → script's `D<n>([^0-9]|$)` regex matches → exit 0. Verified by running the script. Skip-but-list is the intended contract.
- audit-decisions.sh boundary guards (MD5≠D5, D1≠D10) and conditional untrusted-input trigger behave correctly on test input.
- Source URLs carry retrieval dates (2026-06-13) per the YOLO-audit principle; research-findings.md + LICENSE-ATTRIBUTION.md present.

---

## fact_checks
1. specN measured = 70 (QUALITY-BAR DISC alternation, UTF-8 locale, pack-anchored find) → Layer B 5-bucket. CONFIRMED.
2. Lusser's-law percentages (36%/12%/67%/81.7%/48.8%) all match python recompute. CONFIRMED CORRECT.
3. context-compression.md "launched 2026-09-29 alongside Sonnet 4.5": date is in the FUTURE vs current date 2026-06-13; WebSearch shows real products are Opus 4.6/Sonnet 4.6 + 2026-03-13 1M GA, beta header `context-management-2025-06-27`. Claim is FALSE/unverifiable and mis-labeled "confirmed" by the file's own flag. (F1)
4. context-memory.md L57 vs L131: same proposition stated in opposite directions. INTERNAL CONTRADICTION (F2).
5. testing-evaluation.md L45 claims to replace a statement that still lives in coordination-and-state.md L148. STALE SELF-REFERENCE (F3); underlying number correct.
6. audit-decisions.sh executed on synthetic doc → exit 0, all three checks PASS, conditional dual-agent trigger fired. CONFIRMED working; skip-but-list contract holds (no SKILL/script contradiction).

## meets_bar
true — Layer A 10/10, Layer B 5/5, discriminative wiring live and verified. The correctness defects (F1 factual date error mis-labeled confirmed; F2 reversible self-contradiction; F3/F4 stale-edit nits) are localized, do not break the navigator's actionability, and do not pull either layer below threshold. F1 should be fixed before final accept (version-sensitive false claim), but it does not negate the bar.
