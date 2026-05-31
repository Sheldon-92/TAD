---
task_type: mixed
e2e_required: no
research_required: no
skip_knowledge_assessment: no
git_tracked_dirs:
  - .claude/skills/alex
  - .tad/templates
---

# HANDOFF: Research Breadth + Quality Gate (Epic goal-driven-research Phase 5/6)

**From:** Alex | **To:** Blake | **Date:** 2026-05-31
**Epic:** EPIC-20260504-goal-driven-research.md (Phase 5/6)
**Priority:** P1

## 1. Executive Summary
Phase 4 wired the research engine (effort-scaling triggers dynamic seeds + adversarial challenge; proven: seed_origin 0→2, challenge auto-fired). Phase 5 closes the two real gaps the OSS landscape scan identified (vs STORM + Anthropic):
- **FR1 — Persona perspective-seeding (STORM):** the question tree is single-angle. Before baseline seed generation, generate 3-4 stakeholder personas and seed sub-questions per persona — attacks breadth-at-question-time.
- **FR2 — 5-dimension quality rubric (Anthropic):** the Phase 4c challenge emits a coarse INSUFFICIENT/ADEQUATE/STRONG. Phase 5 makes the SAME challenge step ALSO emit a structured 5-dim 0-1 score (factual / citation / completeness / source-quality / efficiency), advisory (low → WARN, never block).

NOT in scope (deferred): CRAG strip-filtering, separate citation pass, coverage mind-map.

## 4. Technical Design

### 4.1 Persona Perspective-Seeding (FR1, AC5.1)
In `research_plan_protocol` Phase 4 **Step 1** (baseline seed question tree — the part that runs ALL tiers), BEFORE generating KR-derived seed questions, add a persona pass:
1. Generate stakeholder personas from the research topic. Persona pool (pick by relevance): **end-user, implementer/builder, skeptic/critic, operator/maintainer, domain-expert, cost-owner**.
2. Scale persona count by the persisted `research_complexity` (read from Phase 0class, frontmatter key — already persisted Phase 4): simple → 2, comparison → 3, complex → 4.
3. Each persona generates ≥1 sub-question following the EXISTING question-format rules (specificity anchor mandatory; reject "best practices for X").
4. Persona sub-questions MERGE into the baseline seed tree (they don't replace KR-derived seeds). Display the persona set to the user (consistent with the existing display+override ethos).
⚠️ This augments Step 1 (runs all tiers) — it does NOT touch the `run_dynamic_seeds`/`run_adversarial_challenge` gating. No SAFETY/carve-out interaction.

### 4.2 5-Dimension Quality Rubric (FR2, AC5.2/5.3/5.4)
⚠️ **Carve-out coverage (design decision — confirm in review):** the rubric is NOT a new auto-invoke step. It is an **output enhancement of the EXISTING Phase 4c adversarial-challenge step** (the step the DR-20260531 carve-out already names). The same Codex+Gemini invocation that produces the INSUFFICIENT/ADEQUATE/STRONG verdict ALSO returns the 5-dim score. No new external-CLI invocation path → **no new carve-out / SAFETY edit needed.** (Blake: confirm you are NOT adding a separate auto-invoke step; if FR2 ends up needing one, STOP — that would require a DR amendment.)

**4 SCORED dimensions (0.0-1.0) + 1 ADVISORY** — efficiency demoted to advisory-unscored per ux-expert P0-2 (not reliably inter-rater scorable without a logged tool-call denominator):

1. **citation_accuracy** (scored) — citation MECHANICS only: does the citation exist, is the source real, does the cited text actually say what the claim attributes? (verifiable without domain knowledge)
2. **factual_accuracy** (scored) — claim TRUTH only: is a claim correct even where cited? (domain judgment; a correctly-cited claim can still be a wrong interpretation)
3. **completeness** (scored) — coverage RATIO = KRs addressed / KRs targeted ("addressed" = ≥1 Tier-1/Tier-2 source contributes evidence). 0.5 = ~half targeted KRs addressed; 1.0 = all.
4. **source_quality** (scored) — tier mix. ⚠️ the rubric file MUST embed the Tier-1/2/3 definitions self-contained (don't reference "existing curate tiers" — ux-expert P1-2; the Codex/Gemini prompt includes the tier table).
5. **efficiency** (ADVISORY, unscored) — signal density note only; NOT in the numeric aggregate (ux-expert P0-2).

**Orthogonality decision tree (ux-expert P0-1 — MUST be in rubric file):** no citation at all → `citation_accuracy` failure ONLY. Citation misrepresents source → BOTH. Correct citation, false conclusion → `factual_accuracy` ONLY. This prevents double-counting + rater divergence on the shared "missing citation" failure.

**Aggregation = hybrid floor rule (ux-expert P2-1 — NOT plain mean):** if either of {factual_accuracy, citation_accuracy} < 0.5 → overall = min(those two); else overall = mean(the 4 scored dims). Rationale: plain mean lets fabrication (factual=0.0) hide behind 4 good scores → 0.8 overall, masking the highest-consequence failure.

- Output: 4 sub-scores + efficiency advisory note + overall (hybrid floor) appended to findings under `## Quality Rubric (Phase 4c)`.
- **Advisory + per-dim severity (AC5.3, ux-expert P2-2):** overall < **0.6** (FIXED threshold, not "e.g.") → WARN, with per-dim labels: factual/citation low = "accuracy concern — verify before citing"; completeness low = "coverage gap — consider re-ask"; source_quality low = "weak sources — add primary". WARN never blocks (single-user CLI principle).
- **Calibration (AC5.4):** create `.tad/templates/research-quality-rubric.md` with: per-dim 0.0/0.5/1.0 anchor definitions, the orthogonality decision tree, embedded tier table, the hybrid floor rule, AND ≥20 calibration cases with **mandated score-range distribution** (ux-expert P1-3): ≥5 below 0.5 (one per scored dim failing), ≥5 in 0.5-0.65 borderline, rest ≥0.7 — cases reference REAL past findings files (not fabricated, per provenance lesson). Add `## Calibration Metadata` (last_calibrated, cases_count, review_trigger) for quieting (ux-expert P2-3).

## 6. Files to Modify / Create
- `.claude/skills/alex/SKILL.md` — MODIFY `research_plan_protocol`: Phase 4 Step 1 persona pass (FR1) + Phase 4c rubric output (FR2). ~40 lines.
- `.tad/templates/research-quality-rubric.md` — CREATE: 5-dim anchor definitions + ~20 calibration cases.

**Grounded Against** (Alex step1c, 2026-05-31, against the WIRED protocol post-merge 4c84b09):
- `.claude/skills/alex/SKILL.md:1174` PHASE 0class (research_complexity persisted at :1539; read by Phase 5 at :1541)
- `.claude/skills/alex/SKILL.md:1359` Phase 4 Step 1 baseline seed gen (all tiers — persona pass attaches here)
- `.claude/skills/alex/SKILL.md:1543` PHASE 4c challenge (rubric output attaches here — same step the carve-out names at :487)
- DR-20260531 carve-out scope = "Phase 0c/4c/5b adversarial-challenge step" (rubric stays inside 4c → covered)

## 9. Acceptance Criteria
- [ ] AC5.1: Phase 4 Step 1 has a persona pass. Count scaled by research_complexity: **simple 0-1** (must NOT inflate the simple-tier single-ask path — code-reviewer P2), comparison 3, complex 4. Each persona ≥1 specificity-anchored sub-question, MERGED into (not replacing) KR-derived seeds. **Persona sub-questions count against the existing Step 1 cap** (don't silently bypass the 2-3 baseline cap — code-reviewer P2; state how personas + KR seeds share the budget).
- [ ] AC5.2: Phase 4c challenge ALSO emits the 4-scored-dim + efficiency-advisory rubric, written to findings `## Quality Rubric` section, from the EXISTING Codex+Gemini invocation (no new call site).
- [ ] AC5.3: overall < 0.6 → WARN with per-dim severity label, findings still proceed (positive check: WARN path EXISTS + "proceed/does NOT block"; no block/deny/return-fail in rubric region).
- [ ] AC5.4: `.tad/templates/research-quality-rubric.md` exists with: 4 scored-dim anchors + efficiency-advisory, orthogonality decision tree, embedded tier table, hybrid floor rule, ≥20 calibration cases with mandated distribution (≥5 <0.5, ≥5 in 0.5-0.65, rest ≥0.7), `## Calibration Metadata`. ux-expert confirms dims orthogonal + anchors definable.
- [ ] AC5.5: NO new SAFETY/carve-out edit AND no new external-CLI invocation. Guards: `DR-20260531` count = 9; `NOT_via_alex_auto: true` = 1 (byte-identical anchor); `codex exec --full-auto` = 3; `gemini -p` = 3 (call sites UNCHANGED — the real new-invocation tripwire); forbidden_implementations block byte-identical.

### 9.1 Spec Compliance Checklist
| AC | Verification (raw cmd) — baselines: persona=13(noise), stakeholder-persona=0, Quality-Rubric=0, codex/gemini=3/3, DR=9, anchor=1 | Type |
|----|------------------------|------|
| AC5.1 | NEW baseline-0 marker scoped to Step 1 region: `awk '/Step 1: Generate 2-3 seed questions/,/Step 2: Execute ask loops/' SKILL.md \| grep -c 'stakeholder persona'` ≥1; + scaling row greppable (`simple.*0\|1.*comparison.*3.*complex.*4`) | post-impl |
| AC5.2 | `awk '/PHASE 4c/,/PHASE 4.5/' SKILL.md \| grep -c 'Quality Rubric'` ≥1 (baseline 0) AND co-located with existing `## Advisory` append (not a new invocation) | post-impl |
| AC5.3 | rubric region: `grep -c 'WARN'` ≥1 AND `grep -c 'proceed\|does NOT block'` ≥1 AND `grep -c 'BLOCK\|deny\|return.*fail'` = 0 | post-impl |
| AC5.4 | `test -f .tad/templates/research-quality-rubric.md`; `grep -c 'decision tree\|floor rule\|Calibration Metadata'` =3; ≥20 cases w/ distribution | post-impl |
| AC5.5 | `grep -c 'DR-20260531'`=9 AND `grep -c 'NOT_via_alex_auto: true'`=1 AND `grep -c 'codex exec --full-auto'`=3 AND `grep -c 'gemini -p'`=3 (all unchanged) | post-impl |

## 10. Important Notes
- ⚠️ **No new SAFETY edit** (AC5.5): FR2 rides the existing 4c challenge invocation. If implementation drifts toward a new auto-invoke step, STOP + escalate (DR amendment needed → human).
- ⚠️ **Rubric methodology** (2026-05-28 lesson): overlapping/simultaneously-satisfiable dimension definitions fail inter-rater reliability. ux-expert-reviewer reviews the rubric file specifically.
- ⚠️ Persona pass attaches to Phase 4 Step 1 (all-tiers baseline) — must NOT re-gate it on run_dynamic_seeds (that was the Phase 4 disambiguation; don't regress it).
- ⚠️ Advisory not blocking (AC5.3): low score warns, never blocks — single-user CLI principle.
- ⚠️ **Parser self-trigger** (code-reviewer P2, architecture.md 2026-05-30): the `## Quality Rubric` output is an artifact `post-write-sync.sh` may scan. Do NOT quote parser-matched label patterns (heading-form `P0`, `INSUFFICIENT`) in the rubric output text — paraphrase.
- ⚠️ **Carve-out temptation** (code-reviewer P1-2): if the existing 4c report text is too signal-poor to score 4 dims, do NOT add a second targeted scoring call — that's a new invocation needing a DR amendment. STOP + escalate instead.

## 11. Decision Summary
| # | Decision | Chosen | Rationale |
|---|----------|--------|-----------|
| 1 | Rubric placement | Enhance existing Phase 4c output, not new step | Stays under DR-20260531 carve-out; no new SAFETY edit |
| 2 | Persona source | Generate from topic (STORM) | User Round-1 choice; lightweight, no external corpus |
| 3 | Persona count | Scale by research_complexity (2/3/4) | Reuses Phase 4 persisted key; effort-proportional |
| 4 | Rubric verdict | Advisory (WARN), not blocking | Single-user CLI anti-mechanical-enforcement |
| 5 | Rubric engine | Reuse Codex+Gemini | User Round-1 choice; reuses challenge infra |
| 6 | efficiency dimension | Demoted to advisory-unscored | ux-expert P0-2: not reliably inter-rater scorable (undefined "signal"/denominator) |
| 7 | Aggregation | Hybrid floor rule (not plain mean) | ux-expert P2-1: plain mean masks fabrication behind good scores |

## Audit Trail (Expert Review — code-reviewer + ux-expert-reviewer)
| Reviewer | Issue | Resolution | Status |
|----------|-------|-----------|--------|
| ux-expert | P0-1: factual/citation not orthogonal (double-count) | §4.2 3-way orthogonality decision tree | Resolved |
| ux-expert | P0-2: efficiency not operationalizable | §4.2 efficiency → advisory-unscored | Resolved |
| code-reviewer | P0: AC5.1/5.2 validation-theater (persona baseline 13) | §9.1 baseline-0 markers scoped to regions | Resolved |
| code-reviewer | P1: AC5.5 count doesn't detect new invocation | §9 AC5.5 + codex/gemini call-site count + anchor guards | Resolved |
| ux-expert | P1-1/P1-2/P1-3: completeness ratio / tier embed / calibration distribution | §4.2 + AC5.4 | Resolved |
| ux-expert | P2-1/P2-2/P2-3: aggregation / severity labels / calibration metadata | §4.2 hybrid floor + severity + metadata | Resolved |
| code-reviewer | P2: simple-tier persona inflation / seed-cap interaction | §9 AC5.1 (simple 0-1, count against cap) | Resolved |
| code-reviewer | P2: parser self-trigger; carve-out temptation | §10 notes | Resolved |
| code-reviewer | FOCUS 1: carve-out coverage claim | confirmed SOUND (FR2 rides existing 4c) | Verified |

## 12. Project Knowledge (Blake 必读)
- **Scoring Rubrics in Reference Files Need Methodology Review** (architecture.md 2026-05-28): the 5-dim rubric is exactly this — needs ux-expert inter-rater check, not just code-review. Overlapping score defs + undefined terms are the failure mode.
- **YOLO Audit: behavioral eval per pack** (architecture.md 2026-05-15): structured rubric is the antidote to validation-theater — this Phase operationalizes it for research.
- **Per-Tool Numeric Thresholds Require Research Provenance** (architecture.md 2026-05-28): the ~20 calibration cases must be real (reference actual findings files), not fabricated.

## Required Evidence Manifest
```yaml
expert_reviews:
  - .tad/evidence/reviews/blake/research-breadth-quality-phase5/code-reviewer.md
  - .tad/evidence/reviews/blake/research-breadth-quality-phase5/ux-expert-reviewer.md
gate_verdicts:
  - COMPLETION frontmatter gate3_verdict
completion: .tad/active/handoffs/COMPLETION-20260531-research-breadth-quality-phase5.md
rubric_file: .tad/templates/research-quality-rubric.md
knowledge_updates: project-knowledge entry if a rubric-design lesson surfaces
```

## Blake Instructions
- Standard TAD. Socratic done (Alex, folded from Phase 4 Socratic + Round-1 answers). Layer 1 (grep ACs) + Layer 2 (≥2: code-reviewer + ux-expert-reviewer — rubric methodology).
- Implement → Gate 3 → COMPLETION + gate3_verdict.
- This is pure protocol-prose + a template file (no hook, no SAFETY edit). If you find yourself adding a hook or a new auto-invoke or editing a forbidden/DR line → STOP, escalate (out of scope).
