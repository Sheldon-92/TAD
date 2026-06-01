# Next Steps

## In Progress

- [x] **EPIC: Agent-Adjacent Pack Factory (8 packs) — ✅ COMPLETE 2026-06-01** — Epic: `.tad/active/epics/EPIC-20260531-agent-adjacent-pack-factory.md` · research: `.tad/evidence/research/agent-pack-factory/` · eval: `.tad/evidence/pack-eval/2026-06-01/`
  - Mass-produced 8 agent-adjacent capability packs via NotebookLM deep research (Conductor seq, ~401 sources/~370KB cited) → parallel build Workflow (32 agents) → adversarial review+fix → real spot-eval. Registry **16→24 packs**. "用满 usage" generative direction.
  - Packs: **rag-retrieval · agent-memory · llm-observability · ai-guardrails · data-engineering · agent-orchestration · synthetic-data · knowledge-graph**. All 0 P0 remaining; valid frontmatter; 5-6 refs + fixture + install.sh each; SKILL==CAP byte-identical.
  - Anti-theater proof: review loop caught 4 real P0 (2 fixture-theater, 1 fabricated-number, 1 wrong-OWASP-code). **REAL spot-eval on all 8** (WITH-pack vs knowledgeable-no-pack CONTROL, discriminative gate): **7/8 verified** (rag 13/2, agent-memory 9/1, llm-obs 4/0, ai-guardrails 9/2, agent-orch 5/0, synth 9/0, kg 10/2 — all clean WITH»CONTROL deltas). **data-engineering honestly `pending`** — CONTROL also scored 5/4 PASS (markers train-serve-skew/RRF/SCD2/pre-filter are common senior-DE knowledge, not pack-unique) → fixture needs tightening like web-backend.
  - **PUBLISHED v2.20.0 + SYNCED to 14 projects (2026-06-01):** *publish pushed main + tag v2.20.0 (rebase hit knowledge-file conflicts → switched to one-shot merge, clean). *sync full-refresh to all 14: every project verified 2.20.0 / 8/8 packs / registry 24 / dormant-sync hook present. 13/14 committed; my-openclaw-agents files synced but its own pre-commit hook blocked auto-commit (left for manual). Registry → 2.20.0 (commit 2ac5bad).
  - **Codex cross-model review (2026-06-01, commit 6c79a3d):** ran codex adversarial review on all 8 → 8/8 FIX-FIRST, ~44 Cat-A/C concrete factual+API errors the all-Claude build+review loop MISSED (wrong class names, deprecated APIs, OTel Histogram-not-Counter, F2 β=2 math, etc.). Fixed ~44 (verified each, NOT blind-trust); **3 codex claims SKIPPED — codex itself was wrong** (GraphRAG Leiden level direction + LangChain HITL 4-decisions, both confirmed via WebSearch primary docs → pack was right). All 8 byte-identical. Lesson in architecture.md "Cross-Model Adversarial Review...". Remaining Cat-B (over-absolute claims ~20) deliberately NOT touched — optional softening pass.
  - **P1 follow-ups (non-blocking):** (a) **citation-pointer audit** — findings.md reports carry a top source-list AND a report-body reference list with DIFFERENT [N] numbering; pack `> Source: [N]` tags may point to wrong URLs (claims are correct, pointers ambiguous) — audit + pin URLs; (b) **keyword-overlap collision signatures** — add scan-collisions signatures for GraphRAG (rag-retrieval↔knowledge-graph, boundary note already added) + checkpoint/durable (agent-memory↔agent-orchestration); (c) **real-eval the 5 remaining packs** (agent-memory/ai-guardrails/data-engineering/agent-orchestration/knowledge-graph) to flip pending→verified; (d) agent-memory missing Anthropic prompt-caching min-prefix length (1024 Sonnet/Opus, 2048 Haiku); (e) sibling **ai-evaluation** has same OWASP stale-numbering bug (adversarial-rules.md:127) — pre-existing, fix in a sweep; (f) Phase 3 optional: install 8 packs to downstream projects via *sync.

- [x] **EPIC: Non-Dev Execution Track (4 phases) — ✅ COMPLETE + ARCHIVED 2026-05-31** — Epic: `.tad/archive/epics/EPIC-20260531-nondev-execution-track.md` · report: `.tad/evidence/yolo/nondev-execution-track/EPIC-COMPLETION.md`
  - Gave TAD a NON-CODE delivery lane: `task_type: deliverable` routes Gate 3/4 to additive sibling sections that score a content artifact against a pack rubric via an INDEPENDENT judge sub-agent (judge≠producer) instead of `tsc/test/lint`. Turns the orphaned non-dev packs (academic/voice/video/product) into a runnable pipeline. "TAD beyond software dev."
  - P1 contract v2.1 (4 P0+6 P1 caught/fixed) · P2 gate Gate3/Gate4 sibling branches byte-safe (originals IDENTICAL vs 9fc6c50; 1 P0 dead-telemetry + 4 P1 fixed) · P3 **real dogfood: 0.737 PARTIAL → revise → fresh judge 0.7725 PASS** (3 distinct agents — gate discriminated, not theater) · P4 track guide + KA. Commits 23339a9, 897bed9, 9986de8, 179556d.
  - **Follow-ups (tracked, non-blocking):** (a) implement categorical (product BUILD/PIVOT/KILL) + checklist (voice/video) `verdict_shape` so those 3 packs become runnable (currently registered rubric-tbd + guarded/BLOCKed by verdict_shape_guard); (b) author product-thinking rubric (no hardware barrier) + real dogfood; (c) voice/video real dogfood needs hardware (deferred by design); (d) harmonize product-thinking `dogfood_capable` wording (registry "yes" hardware-axis vs guide "no" rubric-ready-axis).

- [x] **EPIC: Pack Collision Detection (2 phases) — ✅ COMPLETE + ARCHIVED 2026-05-31** — Epic: `.tad/archive/epics/EPIC-20260531-pack-collision-detection.md` · report: `.tad/evidence/yolo/pack-collision-detection/EPIC-COMPLETION.md` *(parallel Alex — zero lean-trustworthy file overlap)*
  - P1 ✅ Done (d296374 + 1b714f4): cross-pack collision detector. `scan-collisions.sh` (grep-seed over `.claude/skills/` canonical tree, 2.2s, LC_ALL=C CJK-safe pre-filter, atomic write) + `collision-signatures.txt` + `pack-collisions.yaml` (3 confirmed: Inter→auto perf>style, APCA-vs-WCAG→escalate a11y, pyramid→escalate correctness) + `pack-collision-detection.md` guide (precedence engine + LLM-confirm contract + anti-theater rule) + 3 fixtures. Gate 3+4 PASS; 4 reviewers (2 design+2 impl) 0 P0; all 6 collision refs hand-re-derived live. Anti-theater spot-check caught its OWN false positive (video-creation CJK comm bug → fixed).
  - P2 ✅ Done (5d41c20): wired `pack-collisions.yaml` into Alex `step4_5` (additive `5b`) + Blake `1_5a` (additive `2.5`). Purely additive (4 files, 144 insertions, 0 deletions); constraint-token counts held (alex 132, blake 49); structure intact. AC8 fixture traced live (web-ui-design + web-frontend → Inter ⚙️ resolved line). Gate 3 PASS. Loser-quote carry-forward (architect P2-B) included in the alex 5b auto template.
  - P2 carry-forward: surfacing one-liner should also carry the loser's quote (architect P2-B) for the human spot-check.

- [x] **EPIC: Lean & Trustworthy TAD (5 phases) — ✅ COMPLETE + ARCHIVED 2026-05-31** — Epic: `.tad/archive/epics/EPIC-20260531-tad-lean-trustworthy.md` (other Alex, parallel session)
  - P1 ✅ Done (85fe0a9): trace §11 parser header-aware (4-col column-shift fixed) + 6 dead dream candidates purged. Gate 3+4 PASS; 2+2 reviewers raw-recomputed.
  - P2 ✅ Done (b95a577 + 35b5a60): ai-voice-production full source-dir-ification (now Tier1+Tier2 sync-portable) + registry 14→16 + advisory type-probe drift-check (`.tad/hooks/lib/pack-registry-driftcheck.sh`, no allowlist rot) + all 16 packs now have real consumes/produces. Gate 3+4 PASS; 2+2 reviewers.
  - P3 ✅ Done (7c5a59f + 1216bac): OPTION A progressive disclosure — 9 token-free path protocols → `.claude/skills/alex/references/`, 6441→5825 (~9.6%), constraint count 131 UNCHANGED (byte-identity SAFETY held). honest_partial correctly surfaced AC3.1(≤3500)×AC3.2(byte-identity) conflict → user chose safe Option A. 2 impl reviewers raw-recomputed all 9 diffs.
  - P4 ✅ Done (eb53ee7 + fd6e1a5): advisory §9.1 AC-command linter (`.tad/hooks/lib/verify-ac-commands.sh`) wired at step1d, never blocks. Rule A 100% precision; Rule B surfaced **34 latent literal-pipe-in-ERE bugs across already-shipped handoffs**; calibration removed Rule C 218-hit noise. 2 impl reviewers ran it on 14+ handoffs.
  - P5 ✅ Done (68c85a1 + 2311f9e + 4e88bff): pack behavioral eval runner + fixtures; discriminative gate (gates on pack-specific markers, not contaminated combined count); 2 packs verified via discriminative delta, web-backend honestly held pending. 8448c7d Epic bookkeeping.
  - P4 follow-ups: sweep the 34 Rule-B latent bugs in shipped handoffs; KA "advisory INFO rules need real-volume calibration (a rule firing 218× on correct commands trains the user to ignore all output)".
  - P3 follow-ups: (a) stub↔reference drift-check (advisory, mirror pack-registry-driftcheck.sh); (b) dogfood-monitor that direct `*bug`-typed entry triggers the reference Read (load_when reliability); (c) OPTION B (reframe AC3.2 to moved-not-deleted + inline router constraint summary) available for a deeper progressive-disclosure pass on research_plan(724)/express/experiment — needs SAFETY-AC sign-off; would reach the original ~45% target.
  - P2 follow-ups: add `type:` to product-thinking/research-methodology installed SKILLs (drift-check type-probe symmetry); drift-check SKILLS_DIR layout note + optional SessionStart wiring; pack-build checklist must require `.tad/capability-packs/{name}/` source dir from the start (ai-voice was built skipping it).

- [x] **Debt Bundle 1/2: Release Hygiene + Conventions** — YOLO Gate 4 PASS + ARCHIVED 2026-05-31 (commit ae387ef)
  - doc-drift→2.19.1 (README:354 history preserved) + tad.sh 3-part + `*)` arm + line 171 fallback + runbook codex-greeting rows 17/18 + express-slug convention (alex/blake SKILL)
  - Design review: code-reviewer + backend-architect (P0: version-scheme rationale wrong consumer → detect_state line 303; fixed). Impl review (YOLO Y6): both PASS 0 P0. Gate 4 raw-recompute: AC1/AC3/AC9 verified.
- [x] **Debt Bundle 2/2: Hook Code Hardening** — YOLO Gate 4 PASS + ARCHIVED 2026-05-31 (commit b37d41b)
  - dream-scanner fromjson try-guard(a) + classify_scope TAD-keywords(b) + expert_finding heading-only(d). bug(c) dedup DROPPED (validation theater, 0/31 real match).
  - Impl review: code-reviewer PASS 0 P0; backend-architect CONDITIONAL PASS 0 P0 + 1 P1 (slug substring over-classify). Gate 4: malformed→0 junk, sync→project, heading-only=1 verified.

- [x] **Research Engine Upgrade (Epic goal-driven-research Phase 4+5+6A)** — Gate 4 PASS 2026-05-31
  - Triggered by *discuss audit: NotebookLM advanced flow "built-not-wired" (seed_origin 0 uses, challenge 2/25; 3/14 adoption)
  - **P4** effort-scaling + dormant hook + AR-001 carve-out (DR-20260531) + dogfood seed_origin 0→2: 92bbfc3→4c84b09→58c9cac
  - **P5** persona-seeding + 5-dim rubric (rides existing 4c, no new invocation): 5456afb→09de56c. ux-expert 3 methodology P0→resolved
  - **P6A** research-gate (right-moment nudge + declined-domains dedup): 7d41768→7c08f37. backend-architect 2 dedup P1→resolved
  - All 3 phases: worktree Blake impl + 2-round expert review + Gate 4 raw-recompute. SAFETY guards held throughout (DR=9, codex/gemini 3/3)
  - ⏭️ **P6 AC6.3 *sync to 14 projects DEFERRED** — pending explicit authorization (outward-facing)
  - ⏭️ **P3 Research-Decision Loop** still ⬚ Planned (director-layer)
  - 💡 AKU governance-as-code (14.5% of 2303 agent files) → capability-pack gap candidate; optional full tad-evolution refresh
  - 💡 Optional: full tad-evolution landscape refresh (dogfood was bounded to prove wiring)

- [x] **Bugfix: dream-scanner Pass C weaves override chosen/rationale** — Gate 4 PASS + ARCHIVED 2026-05-31
  - Pass C now extracts .chosen/.rationale (newline-flattened in jq, stderr-quiet) → content-rich candidates; fallback intact
  - Layer 2 code-reviewer PASS (raised P0 heredoc-injection → empirically refuted → withdrawn); test-runner PASS
  - Commit ecf912e + 7e1e54b (Gate 3 artifacts); KA(Blake) → code-quality "Heredoc injection depends on the SINK"
  - Gate 4: Alex raw-recompute AC2/AC3/AC4 from real trace events (✅); Layer2 audit 2 reviewers tier MET; KA(Alex) → architecture "Parser feeding review queue must propagate VALUE not just key"
  - Trigger: 6 empty `human_override` dream candidates (2026-05-30) all rejected → root cause = Pass C dropped captured rationale

- [x] **Release v2.19.0 + v2.19.1 PUBLISHED + SYNCED to 14 projects** — DONE 2026-05-30
  - *publish: pushed main + tags v2.19.0 (87665e0) & v2.19.1 (40989f2); rebased through remote dream-state churn
  - *sync: all 14 projects got V2 trace hooks (6 emit fns each, verified); 6 V1-stuck projects upgraded
  - merge projects (toy/my-openclaw-agents/内存管理): CLAUDE.md backed-up + restored (toy marker preserved)
  - tad.sh --yes flag (commit 4767901) unblocked non-TTY sync; registry → 2.19.1 (commit e6ca251)
  - Codex Phase 7 smoke test PASS before sync push

## Deferred (surfaced 2026-05-31 debt-bundle expert review)
- [ ] **Multi-table §11 decision parser re-bind** (Epic P1 Y6 reviewers, 2026-05-31): `emit_decision_points` locks `havehdr` on the FIRST Decision Summary table and never re-binds → 2nd+ decision tables in one §11 silently dropped, and a trailing non-Decision table (§11.3 disposition) over-emits with stale indices. Pre-existing (NOT a regression from the header-aware fix), append-only. Fix = re-bind havehdr whenever a fresh row's cells are `decision`+`chosen`. Also closes a contrived spurious-bind (non-decision table whose data row literally reads `| Decision | Chosen |`). Low priority (multi-table §11 rare).
- [ ] **classify_scope word-boundary slug matching** (H2 impl review P1, backend-architect): unbounded substring globs `*hook*`/`*trace*`/`*registry*` false-classify project slugs as framework (`webhook-handler`→framework, `registry-of-products`→framework). Framework candidates fan out cross-project in *evolve. Fix = bracket-class word-boundary per architecture.md 2026-04-24 (NOT `\b`). Low risk (human_override rare + human-reviewed). decision_text guard already correct.
- [ ] **tad.sh:165 stale comment** (H1 impl review): comment still says "MAJOR.MINOR" after 3-part switch — cosmetic, fold into next tad.sh touch.
- [ ] **Semantic dedup for dream-scanner candidates** — grep-on-`.decision`/`.chosen` is inert (0/31 real values match; backend-architect). Needs title/discovery match or embedding-based semantic dedup. bug(c) dropped from hook-hardening handoff pending this design.
- [ ] **detect_state glob-arm hazard (next version bump)** — tad.sh `2.1*`/`2.2*` arms (~305-313) will misclassify 3-part `2.19.x` as `v2.0` once `TARGET_VERSION` moves past 2.19.1. Next-release handoff MUST address before bumping.
- [ ] **Express tier: durable frontmatter marker** — slug-naming convention (this cycle's fix) still false-WARNs any express handoff that forgets the name. Durable fix = `express: true` frontmatter consumed by layer2-audit (vs slug-as-proxy). backend-architect P2-1.

## Follow-ups (from this release cycle)
- [ ] **Doc-drift sweep to 2.19.1**: README/INSTALL/tad-help/codex skills still say 2.19.0 (cosmetic; fold into next minor)
- [ ] **Version-scheme inconsistency**: tad.sh stamps downstream version.txt = "2.19" (MAJOR.MINOR via TARGET_VERSION:537) while source = 3-part "2.19.1". Decide unified scheme.
- [ ] **runbook gap**: add codex greeting lines (855/632) to release-runbook Phase 2 version table
- [ ] **expert_finding parser**: tighten count to heading-form-only (prose "P0" self-trigger — trace-fix follow-up)
- [ ] **dream-scanner Pass C dedup + scope** (deferred from bugfix-dream-scanner-override-content): (a) dedup new candidates against existing project-knowledge before emit; (b) `file=null` → override candidates mis-classify as `project` even when framework-scoped; (c) line ~183 `fromjson`-error on malformed context → `""` not `"unknown"` → guard leaks junk candidate. Bundle into one Pass C hardening handoff.
- [ ] tad.sh `*)` default arm for unknown flags (code-reviewer P2, non-blocking)
- [ ] **dream-scanner Pass C dedup + scope**: (a) dedup override candidates vs existing project-knowledge; (b) classify_scope mis-tags framework overrides as `project` (file=null on decision_point); (c) line 183 `(.context|fromjson|.decision)//"unknown"` doesn't catch fromjson *errors* → malformed context yields junk candidate. Bundle into one Pass C follow-up handoff.
- [ ] **express slug convention**: express handoffs should encode "express" in the slug so layer2-audit detects the Tier (bugfix-... slug + task_type=code → false ≥2-reviewer WARN)

- [x] **Release TAD v2.19.0** — Gate 3 PASS 2026-05-30 (awaiting Alex *publish)
  - Bumped 18 version strings (7 files) + fixed tad.sh TARGET_VERSION drift (2.15→2.19)
  - CHANGELOG [2.19.0]: trace v2 / sync-fix / ML pack / cloud compute
  - Commits: 7e1bd86 (release) + dfb9740 (framework state + lifecycle + evidence)
  - Blake STOPPED before push/tag — ⏭️ Alex: *publish (push+tag v2.19.0) → *sync (14 projects)
  - ⚠️ Alex: run Codex adapter smoke test (runbook Phase 7) before sync push
  - 📝 Runbook gap: add codex greeting lines (855/632) to Phase 2 table

- [x] **Fix v2 Trace Instrumentation** — Gate 4 PASS + ARCHIVED 2026-05-30
  - Gate 4: raw-recompute verified AC8 (real gate_result event), Layer 2 audit 3 reviewers, dream-scanner exit 0
  - gate4_delta: 1 (expert_finding parser self-triggered on review prose → false P0); Alex KA: dead-code-audit=validation-theater
  - Observational emission: hook parses HANDOFF §11 / COMPLETION gate3_verdict marker / Reflexion blocks / review files
  - FR1-6 + NFR1-4 + P1 fix (detail=full); hook never fail-closed (fault-injection verified)
  - Layer 2: code-reviewer + backend-architect (P1 resolved) + test-runner (PASS)
  - **AC8 dogfood**: first non-synthetic gate_result event emitted into real trace
  - Commit: b0e1c78
  - ⏭️ After Gate 4: run *evolve — it now has real decision-level data for the first time
  - Follow-up (out-of-scope): tighten expert_finding count to heading-only; dream-scanner try/catch hardening

- [x] **Fix *sync Directory List** — Gate 3 PASS 2026-05-30 (awaiting Alex Gate 4)
  - Added .tad/domains/ + .tad/hooks/ to alex/SKILL.md sync list (12 → 14 entries, mirrors tad.sh:115)
  - SYNC-MIRROR drift-prevention comment added
  - Commit: d94e956
  - ⏭️ After Gate 4: Alex runs *sync to push V2 trace hooks to 16 projects (6 stuck on V1)

- [x] **video-creation Pack ViMax Upgrade** — Gate 4 PASS + ARCHIVED 2026-05-27
  - 4 ViMax patterns + Photo-to-Beat-Sync (309 lines, ≤400 cap)
  - Pre/post behavioral comparison: AI correctly applies montage intent + first/last frame decomposition
  - Research notebook `79b4c4a9` (38 sources)
  - Commit: 0cc4d8b
  - gate4_delta: 3 entries (AC grep-count + verification cmd bug + Layer 2 reviewer naming drift)
  - Alex architecture knowledge: 2 new entries (AC cmd bug pattern, Layer 2 reviewer convention)

- [x] **TAD Lifecycle Health Improvements** — Gate 4 PASS + ARCHIVED 2026-05-19
  - *accept --quick, YOLO auto-archive, zombie detection (STEP 3.5+3.55), *optimize redesign
  - Commit: 816449f

- [x] **EPIC: Auto-Evolve** — 4/4 Phases COMPLETE ✅ (archived 2026-05-20)
  - Epic: `.tad/archive/epics/EPIC-20260518-auto-evolve.md`
  - Phase 1: Trace v2 schema + writer (4740def)
  - Phase 2: Blake Reflexion mode (f5489e4)
  - Phase 3: Dream scanner + auto-trigger (9b51e1b)
  - Phase 4: Optimize/Evolve v2 (b904c9c)

- [x] **Capability Pack Auto-Awareness + Sync Install** — Gate 4 PASS + ARCHIVED 2026-05-14
  - *sync step b2 installs all 8 packs to downstream projects
  - Alex step4_5 pack awareness scan across 6 modes
  - Blake 1_5a auto-detection in *develop
  - Commit: baf5618 + e28acbf

- [x] **Domain Pack Freeze + Cleanup** — Gate 4 PASS + ARCHIVED 2026-05-20
  - Archived 12 YAML, kept 9 (hw/mobile/supply-chain), deleted 6 router ecosystem files
  - startup-health.sh SKILL.md-first guard, Alex 10 refs updated, deprecation.yaml v2.17.0
  - Commit: 27a0bc6

- [ ] **EPIC: Agent Capability Packs** — 6/9 Phases Done
  - Epic: `.tad/active/epics/EPIC-20260507-agent-capability-packs.md`
  - 8 packs built (web-ui-design, product-thinking, web-backend, ai-agent-arch, web-frontend, video-creation, ai-prompt-eng, research-methodology)
  - Phase 2: Real project validation (use packs in menu-snap, measure quality delta)
  - Phase 3: Cross-agent validation (same pack on Codex)
  - Phase 4: Template extraction (CONSUMES/PRODUCES standard)

- [x] **\*dream Knowledge Consolidation** — Gate 4 PASS + PROMOTED 2026-05-14
  - architecture.md: 1125→262 lines (76% reduction), 120→60 entries
  - Safety keywords: 15→15 preserved. Foundational section byte-identical.
  - Snapshot: `.tad/archive/knowledge-snapshots/2026-05-14/`

- [ ] **EPIC: Goal-Driven Research Director** — 3/4 Phases Done
  - Epic: `.tad/active/epics/EPIC-20260504-goal-driven-research.md`
  - Phase 3: Research-Decision Loop (decision traceability + --caller flag)

- [ ] **EPIC: Security Domain Pack Chain** — 2/5 Phases Done (paused)
  - Epic: `.tad/active/epics/EPIC-20260403-security-domain-pack-chain.md`
  - Phase 2-4: Paused — run real-project security audit first to validate value

## Pending

- [ ] Run *optimize on menu-snap (14 trace files) to analyze execution patterns
- [ ] Run *evolve cross-project (5 projects with traces, 50+ trace files total)
- [ ] Test Agent Teams on next Full or Standard TAD task
- [ ] Add Bash command deny patterns to PreToolUse hook (rm -rf, DROP TABLE etc.)

## Ideas (16 active — 8 archived 2026-05-14)

Domain Pack related (input for Freeze + Rebuild):
- [ ] IDEA-20260508-deprecate-domain-pack-yaml: Deprecate YAML format entirely
- [ ] IDEA-20260427-domain-pack-taxonomy-reorg: Horizontal vs vertical reorganization
- [ ] IDEA-20260402-domain-pack-monthly-refresh: Monthly tool freshness refresh
- [ ] IDEA-20260402-self-evolving-domain-pack: Auto-improvement from traces

Framework infrastructure:
- [ ] IDEA-20260401-tad-self-test-agent: Automated TAD behavior validation
- [ ] IDEA-20260402-deerflow-patterns: Borrow patterns from DeerFlow 2.0
- [ ] IDEA-20260403-config-env-override: Environment variable config override
- [ ] IDEA-20260403-hook-timeout-config: Hook timeout control
- [ ] IDEA-20260403-session-health-check: Framework component integrity check

Skill ecosystem:
- [ ] IDEA-20260407-local-skill-capture: Local skill capture mechanism
- [ ] IDEA-20260407-cross-project-skill-harvest: Cross-project skill promotion

From ECC research (2026-05-27):
- [ ] IDEA-20260527-dream-auto-scope: Dream scanner auto-scope via git remote hash + 2-project promotion
- [ ] IDEA-20260527-codex-adapter-yaml: Capability pack Codex YAML adapter (6-line openai.yaml)
- [ ] IDEA-20260527-tad-methodology-skeleton: TAD universal methodology skeleton (domain-agnostic process)

From OpenCode research (2026-05-28):
- [ ] IDEA-20260528-declarative-agent-constraints: Declarative agent constraints — separate config from judgment (OpenCode pattern)

From html-anything research (2026-05-27):
- [x] IDEA-20260527-pack-behavioral-examples: Promoted → Handoff 2026-05-27
- [ ] IDEA-20260527-agent-adapter-pattern: Unified agent detection + invocation protocol (TAD 跨 agent 运行基础设施)
- [x] **Pack Behavioral Examples Framework** — Gate 4 PASS + ARCHIVED 2026-05-27
  - Fixture format spec + install.sh examples/ copy + 2 video-creation dogfood fixtures
  - Dogfood: Fixture A 9/4 markers, Fixture B 8/3 markers (raw-TSV recompute matched)
  - Commit: 9993ce7

## Recently Completed

- [x] **AI Voice Production Capability Pack** — Gate 4 PASS + ARCHIVED 2026-05-28
  - 7 files, 966 lines (SKILL.md router + 6 references), 13 TTS tools covered
  - Research: NotebookLM e2f862c7 (26 sources, 5 ask rounds)
  - Expert review: 2 pre-handoff (code-reviewer + backend-architect, 6 P0 fixed) + 3 post-impl (Blake Layer 2)
  - Commit: c119d1f
  - Reference-based pack: SKILL.md + 6 references (966 lines total)
  - 13 TTS tools (9 Tier A benchmarked + 7 Tier B notable), 26 NotebookLM sources
  - 3 P0 fixed (fabricated durations, non-research terminology, missing research tools)
  - Awaiting Alex Gate 4

- [x] **Research Adversarial Challenge Layer** — Gate 4 PASS 2026-05-14, commit 8ea1eed
  - 3 challenge points (0c plan / 4c findings / 5b actions) with Codex+Gemini dual-model review
  - AskUserQuestion gate per challenge, CHALLENGE_INSTRUCTION constant, fail-closed rating extraction
  - Experiment mode: first 3 runs compare both models

### 2026-05-14 cleanup

- [x] **EPIC: Cross-Model Orchestration — ALL 4/4 PHASES COMPLETE** — Archived 2026-05-14 (validated via menu-snap 4 notebooks, 646 sources)
- [x] **v2.14.0 released + synced to 14 projects** — YOLO Mode + LSP Code Understanding (2026-05-14)
- [x] **EPIC: YOLO Mode — ALL 3 PHASES COMPLETE** — Dogfood 39/39 PASS on menu-snap
- [x] **LSP Code Understanding Integration** — 12-language plugin map, auto-provision
- [x] **NotebookLM Research Upgrade (5 tasks)** — add-smart, dynamic research, methodology upgrade
- [x] **8 Capability Packs built** — web-ui-design, product-thinking, web-backend, ai-agent-arch, web-frontend, video-creation, ai-prompt-eng, research-methodology
- [x] **Pack Integration & Migration** — 7 packs to .tad/capability-packs/ + pack-registry.yaml
- [x] **EPIC: Codex CLI Adaptation — ALL 3 PHASES** — launchers + AGENTS.md + dogfood
- [x] **EPIC: GitHub Knowledge Integration — ALL 3 PHASES** — 24 domains, 50 awesome-lists, weekly scan
- [x] **EPIC: NotebookLM Research Director — ALL 4 PHASES** — 19 commands, E2E 6/6 PASS
- [x] **EPIC: TAD Self-Upgrade from Cross-Project Learning — ALL 6 PHASES**
- [x] Earlier: see [docs/HISTORY.md](docs/HISTORY.md)

## Blocked

(none)

---

> 8 Ideas archived 2026-05-14: linear-auto-sync, linear-kanban, domain-pack-framework, tad-universal-method (promoted), cross-model-orchestration (promoted), goal-driven-research-director (promoted), research-methodology-upgrade (done), epic-auto-conductor (done as YOLO)
> Archived history: see [docs/HISTORY.md](docs/HISTORY.md)
