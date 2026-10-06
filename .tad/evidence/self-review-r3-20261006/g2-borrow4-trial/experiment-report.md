# Experiment Report — R3 Group 2: Borrow-4 Unfreeze Evaluation (Three-Layer Index Trial)

- Batch: TICKET-20261006-self-review-r3, group 2 (HANDOFF §4.2)
- Date: 2026-10-06
- Question: does a mempalace-style three-layer index (wings/rooms/drawers)
  over the incidents corpus improve recall versus the R2 baseline, enough
  to justify formally proposing the three-layer index ("borrow 4")?
- Design: §4.2.2 construction (builder sub-session, blind), §4.2.3 run
  protocol (runner sub-session, blind; three surfaces in R2 order with
  only surface 3 replaced by `trial-index/routing.md`), §4.2.4 criteria
  frozen at Gate 2 PASS — applied mechanically below, not adjusted.

## Per-question results

Baseline verdicts are quoted from the R2 baseline result file
(`.tad/evidence/self-review-r2-20261006/g5-recall-baseline-result.md`).
Scoring is file-level set judgment (HANDOFF §4.2.3): a hit means the
expected incident file appears in the returned top-3; surface-3
candidates are drawer stems, identical to incident file stems by
construction (build-record registers the mapping).

| Q# | Expected | R2 baseline | This run: returned candidates | This run verdict |
|---|---|---|---|---|
| Q33 | incidents/2026-05/academic-research-pack-pilot.md | 命中（@3 第 2 位） | academic-research-pack-pilot | 命中（@1） |
| Q34 | incidents/2026-05/claude-md-routing-label-conflicts.md | 命中（@1） | claude-md-routing-label-conflicts | 命中（@1） |
| Q35 | incidents/2026-05/gemini-cli-constraints.md | 未命中 | gemini-cli-constraints | 命中（@1） |
| Q36 | incidents/2026-05/pack-collision-detection.md | 未命中 | pack-collision-detection | 命中（@1） |
| Q37 | incidents/2026-05/scienceclaw-skill-decoupling.md | 未命中（零候选） | scienceclaw-skill-decoupling | 命中（@1） |
| Q38 | incidents/2026-06/alex-role-decay-direct-execution.md | 命中（@1） | alex-role-decay-direct-execution | 命中（@1） |
| Q39 | incidents/2026-06/cross-agent-parity-check.md | 未命中 | cross-agent-parity-check | 命中（@1） |
| Q40 | incidents/2026-06/pack-value-cross-vendor.md | 命中（@3 第 3 位） | pack-value-cross-vendor | 命中（@1） |
| Q41 | 无答案（语料外） | 误报（2 候选） | (none) | 正确无候选 |
| Q42 | 无答案（语料外） | 正确无候选 | (none) | 正确无候选 |
| Q43 | 无答案（语料外） | 正确无候选 | (none) | 正确无候选 |
| Q44 | 无答案（语料外） | 误报（1 候选） | (none) | 正确无候选 |
| Q45 | 无答案（语料外） | 误报（3 候选） | (none) | 正确无候选 |

## Metrics (frozen criteria caliber, §4.2.4)

| Metric | This run | R2 baseline | Role |
|---|---|---|---|
| incidents Recall@3 (Q33–Q40) | **8/8** | 4/8 | 主指标 |
| 无答案误报数 (Q41–Q45) | **0** | 3 | 守门指标 |
| incidents Recall@1 (Q33–Q40) | 8/8 | 2/8 | 附值（只报不判） |

## Verdict (mechanical application of §4.2.4)

- 立项建议线：Recall@3 ≥ 6/8（较基线 +2 题）且误报 ≤ 3 → 本轮
  Recall@3 = 8/8（≥ 6/8 ✅）、误报 = 0（≤ 3 ✅）。两条同时成立。
- **判读：建议立项。** 正式立项另走票/Epic，PM 在 Gate 4 终裁；
  本报告只出评估判读，不构成立项本身。
- Validity: not INVALID — all frozen artifacts re-verified after the
  run (below); no forbidden path was opened per both self-signs.

Scope honesty (for the Gate 4 reader): this is one run over the
pre-registered 13-question subset at file-level granularity — exactly
the design the criteria were frozen for, no more. It shows the drawer
hooks carry the semantic clues (vendor names, mechanism names,
thresholds) whose absence from the old file-level index lines the R2
baseline itself named as the miss cause for Q35–Q37/Q39. It does not
by itself prove the structure scales to the other knowledge surfaces;
that judgment belongs to the initiation decision.

## Validity evidence

- Frozen subsets: questions sha256 `5f15be1f…c125419`, expected sha256
  `04acb2a7…84368a` (build-record Section A); both are byte-identical
  extractions of the R2 sources (AC-G2-1 cmps silent).
- Routing freeze: `trial-index/routing.md` sha256
  `c755465a1cfba4a6de22f16978344563a284bd4107b7ee8ae97baa34821387eb`,
  frozen before the runner was spawned and re-verified identical at
  scoring time (run-trace).
- Blind protocol: builder and runner were separate independent
  sub-sessions; the extractor (Blake) served as neither. Builder
  self-sign (build-record Section B): read only the corpus index, the
  drawer copies it made, its own routing file, and the repo AGENTS.md
  house rules; declared no forbidden opens. Runner self-sign
  (run-trace): read only the question subset and the three surfaces,
  plus the repo AGENTS.md opened under a runtime house-rules note (not
  a forbidden path, not a retrieval surface, contains no answers —
  disclosed in run-trace); declared no forbidden opens.
- Authority surfaces untouched: `authority-manifest-before.sha256` vs
  `-after.sha256` (28 entries: 25 incidents + incidents/_index.md +
  brain-index.md + patterns/_index.md) — diff empty (AC-G2-2).
- Runner behavior note: the runner returned exactly one candidate per
  recall question (the protocol allows fewer than 3). All eight landed
  at position 1, so Recall@3 and Recall@1 coincide this run.

## Standing items (recorded, not acted on)

- **ChromaDB license check**: still outstanding （挂账）. This trial used
  no vector backend — the index is structured text routing
  (wings/rooms/drawers rendered as markdown) — per §4.2.4 the backend
  question stays parked until/unless an initiation takes it up.
- **Patterns entry-level granularity (parallel observation from R2)**:
  the R2 baseline found the patterns surface is indexed only at file
  level. This trial changed only the incidents surface; the patterns
  surface competed in its existing form and the winning candidates all
  came from the trial surface. Whether the patterns surface needs the
  same per-entry discriminator treatment is an observation for the
  initiation decision, not a finding of this experiment.
