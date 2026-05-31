# Next Steps

## In Progress

- [ ] **Debt Bundle 1/2: Release Hygiene + Conventions** — Handoff ready for Blake (Gate 2 PASS 2026-05-31)
  - HANDOFF-20260531-release-hygiene-conventions.md: doc-drift→2.19.1 (preserve history) + tad.sh 3-part + `*)` arm + runbook codex-greeting rows + express-slug convention
  - Expert review: code-reviewer + backend-architect; P0 fixed (version-scheme rationale was wrong consumer → detect_state line 303; +line 171 + detect_state AC)
- [ ] **Debt Bundle 2/2: Hook Code Hardening** — Handoff ready for Blake (Gate 2 PASS 2026-05-31)
  - HANDOFF-20260531-hook-hardening.md: dream-scanner fromjson guard(a) + classify_scope(b) + expert_finding heading-only(d)
  - Expert review caught bug(c) dedup probe = validation theater (0/31 real values match) → DROPPED, deferred to proper semantic design

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
