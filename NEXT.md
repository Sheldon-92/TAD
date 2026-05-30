# Next Steps

## In Progress

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
