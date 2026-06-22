# Changelog

All notable changes to the TAD Framework will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.32.0] - 2026-06-22

### Added
- **Knowledge Recording Redesign** — 4-phase Epic: Capture/Distill/Maintain
  - New L1 principle: "Knowledge Is Forged at Distill, Not Captured"
  - Typed playbook-entry schema (6 fields, `failure_mode` REQUIRED)
  - Knowledge writing rules (variabilize test + 5 rules + before/after exemplar)
  - Gate 3 KA → raw journal (evidence/journal/); Gate 4 KA → distillation loop
  - `*knowledge-maintain` command: hash-dedup + 4-way reconcile + usage-retire + soft lint
  - `knowledge-lint.sh` — soft lint (exit 0 always, 3 checks, BSD-compatible)
  - 110 existing entries migrated to new schema (0 UNRESOLVABLE)
  - E2E distillation loop validated live (gap-handback mechanism confirmed working)
- Research: Mem0/Letta/AWM/Anthropic Skills source-level study

## [2.32.0] - 2026-06-18

### Added
- **Pack Content Protection System** — 4-phase Epic: hash manifest → smart copy → conflict resolution → fork support
  - `generate_pack_meta()` — SHA-256 hash manifest per pack (`.tad-pack-meta.yaml`)
  - `copy_pack_skill_smart()` — per-file hash comparison, customized files preserved on install
  - `resolve_conflict()` — three-way conflict detection with interactive diff resolution
  - `--fork-pack <name>` / `--unfork-pack <name>` — permanently fork/unfork individual packs
  - `--list-packs` — table view of all pack statuses (policy/baseline/files)
  - `--resolve=local|upstream|ask` — conflict resolution strategy parameter
  - `.tad-conflict-backup` — automatic backup before overwrite on conflict
  - Non-TTY fallback for `curl | bash` environments

### Fixed
- sync-protocol.md: removed dangerous `rm -rf` + `install.sh --force` references (root cause of v2.30.0 pack downgrade)
- release-verify.sh: filtered `.tad-pack-meta.yaml` from structural diff to avoid noise

## [2.31.1] - 2026-06-17

### Fixed
- Installer self-check false positive on upgrade (bidirectional diff → one-directional: only flag source files missing from target)
- CLAUDE.md silently overwritten on upgrade (added marker-based merge preserving project-specific content)
- No way to reinstall same version (added --force flag, refuses downgrade)
- package.json version drift (added to release-runbook version list)
- curl|bash docs missing --yes flag for non-interactive use
- package.json files missing .agents/ directory

## [2.31.0] - 2026-06-17

### Added
- **agent-computer-interface capability pack (#26)** — 5-layer tool selection model (engine/data/hybrid/agent/desktop), two-tier capability detection (ToolSearch + shell), security-aware fallback chains. 6 references, 35+ judgment rules, 2 executable scripts
- **agent-skill-evolution capability pack (#25)** — SkillOpt-based self-improving agent judgment rules. 7 references + gate-check.sh
- **Unified *research command** — 9 separate research entries consolidated into Quick/Standard/Deep routing (default: Standard via NotebookLM)
- **6 research quality improvements** — Q1 decision point, Q2 source verification, Q3 semantic saturation, Q4 decision brief template, Q5 claim verification, Q6 feedback loop
- **SkillOpt methodology integration** — TAD methodology updated with SkillOpt research insights
- **Research decision brief template** — .tad/templates/research-decision-brief.md

### Changed
- pack-upgrade workflow migrated from research-engine to NotebookLM-based agent
- pack-dogfood workflow enhanced with regression stage

### Removed
- research-engine.workflow.js (405 lines) — replaced by Standard *research flow

### Fixed
- Sync install.sh ordering bug that silently downgraded 21 packs in v2.30.0

## [2.30.0] - 2026-06-15

### New Features
- **AI-Native Reading Companion (Epic, 4 phases)**: turn an EPUB/PDF/TXT/URL into an e-reader-grade, annotatable HTML reading surface with a live AI co-reader. Phase 2 reader (66 CPL, themed, pagination+scroll) + W3C TextQuote-anchored annotations persisted to a sidecar (survive HTML regeneration); Phase 3 localhost stdlib co-read bridge — select-to-discuss, session open/close, Socratic/synthesis-first AI, security-hardened (127.0.0.1 bind + per-start token + per-response CSP nonce + path-traversal guard + injection-as-DATA envelope); Phase 4 durable sinks (structured notes / question list / Markdown export) + multi-format adapters (PDF/TXT/URL). New `reading-companion` skill, stdlib-only (no external deps).
- **Capability Pack Quality Leveling (Epic, 6 phases)**: 21 capability packs upgraded to a dual-layer quality bar — Layer A (structure <500 lines + fixture + validation script) + Layer B (research-grounded depth with cited sources). 3 gold reference packs (web-backend / web-frontend / web-ui-design). The dual-layer bar is frozen into `capability-upgrade` Gate 2. `.agents` Codex mirror brought to parity.
- **Tier-1 Workflow Formalization**: 4 proven hand-orchestration practices canonicalized as reusable `.claude/workflows/` — handoff-review, pack-dogfood, pack-upgrade, research-engine.
- **pack-upgrade research-grounding**: the pack-upgrade workflow's Plan stage is now deep-research-grounded (research → cited report → upgrade plan whose additions trace to sources) instead of search-as-you-edit.

### Bug Fixes
- **tad.sh `detect_state`**: replaced brittle prefix-glob version routing (the `2.2*` arm had begun swallowing all 2.20–2.29.x) with numeric semver comparison; cross-major jumps now route to the migrate path (structural backup); a newer-than-target install is a no-op (never downgrades). 12 isolated-tempdir AC fixtures added.
- **Workflow StructuredOutput schemas**: wrapped 3 top-level-array schemas (rejected by the API) into object schemas — un-breaks `loop-discover` (its core discovery loop) and `epic-audit`; `surplus-scan` now warns loudly instead of silently stamping `undated`.
- **Installer deny-list drift**: `tad.sh`'s inlined `TAD_TRANSIENT` was missing `domains` (retired) vs `derive-sync-set.sh` — synced (drift-check now passes).

## [2.29.1] - 2026-06-11

### New Features
- **Pack System Unification (3 phases)**: retired YAML Domain Packs as active runtime/sync mechanism; installer single-sourcing for 7 target packs (prebuilt SKILL.md, byte-identical Claude/Codex output); `release-verify.sh platform-skills` verifier for framework-owned skill symmetry with FR7 local-skill INFO exceptions

### Documentation
- Fixed INSTALLATION_GUIDE.md and tad-help/SKILL.md version references (stuck at 2.25.0 since v2.26.0)
- Updated docs/MULTI-PLATFORM.md and docs/CODEX-USER-GUIDE.md: SKILL.md Capability Packs declared as sole active pack system

## [2.29.0] - 2026-06-10

### New Features
- **Self-Evolution Pruning (3 phases)**: retired the near-zero-yield automated loops (*dream incl. manual, *evolve, *optimize, skillify auto-detection, dream-scanner, trace-digest mining) based on measured yield: 18 machine proposals → 1 accepted (5.6%). Negative-result evidence preserved at `.tad/archive/proposals/NEGATIVE-RESULT.md`. Trace EMISSION kept for forensics.
- **3-Tier Skill Formalization** (replaces the broken skillify last mile): T1 — Blake materializes project-local skills via in-session human confirmation (AskUserQuestion mandatory; unattended forbidden); T2 — `.tad/skill-library/` master reference shelf (zero-touch deny-listed, never distributed); T3 — promotion to capability packs requires ≥2-project evidence, detected via `*harvest` cross-project slug collisions. Dogfooded on Colin声音项目 (smart-interval materialized as first real T1 skill).
- **`*harvest` command**: master-side, explicit-only review of skillify candidates across all registered projects; replaces the removed Alex startup review steps (3.56/3.57).
- **Feedback Collector (3 phases, parallel line)**: Blake generates self-contained feedback HTML alongside non-code artifacts; humans export structured JSON; Alex `read_feedback_protocol` turns it into targeted modification handoffs; Gate 4 feedback check; overlay model for spatial artifacts. `/playground` DEPRECATED.
- **TAD Friction Protocol (2 phases)**: missing dependency/auth/approval/reviewer friction is never a skip reason — status enum (READY/BLOCKED/DEGRADED_WITH_APPROVAL/EQUIVALENT_SUBSTITUTE/N_A), handoff §8.4 Friction Preflight, Gate 3/4 checks, advisory checker.
- **Codex parity gate v2 (step3b)**: DIRECTION signal + `release-verify.sh parity --fix` subcommand; dual-platform skills byte-parity now release-gated.

### Bug Fixes
- layer2-audit fail-open fixed: 0 distinct reviewers now FAIL + exit 1 (was PASS) — closes the distinct-reviewer false-PASS backlog item
- release-verify structural: target-side extra `.claude/skills` dirs (project-local skills) report as INFO, no longer fail the gate — required by the T1 local-skill model
- surplus SKILL + surplus-scan.workflow.js no longer scan retired dirs (dream-candidates, evidence/proposals)
- Downstream contamination cleanup: 25,312 stale pre-deny-list synced archive/evidence copies (~290MB) quarantined from all 14 registered projects, with per-project manifests

### Knowledge & Process
- New L2 pattern "Claims Need Carriers": every completion claim must name an on-disk carrier file with an existence AC; smoke alarms fail closed
- Incident recorded: alex-role-decay-direct-execution (cross-project destructive ops are Blake-class by definition)
- SCAND template: status defaults to draft (discoverer must not self-accept), tier/materialized_at/reference_at contract fields

## [2.28.0] - 2026-06-10

### Added
- **Migration Engine** (`migration-engine.sh`, ~1000L): 5-step path safety pipeline for declarative upgrade operations (delete/rename/merge/verify). Single `rm` choke point with TOCTOU re-validation. User-modified file detection via `git show` + graceful degradation.
- **Merge execution**: `execute_merge_entry()` with `<!-- TAD:PROJECT-CONTENT-BELOW -->` marker-based content merge. grep -F (no regex injection), mktemp temp files, 0/1/2 return convention.
- **tad.sh integration**: `call_migration_engine()` in upgrade + migrate paths. `|| engine_rc=$?` ERR-trap bypass (bash 3.2 safe). Migrate backup renamed to `.tad-migrate-backup` (no collision with engine's `.tad-backup/`).
- **\*sync integration**: step3.b3 migration engine call, `.tad-backup/` in PRESERVE list.
- **Publish gate**: `release-verify.sh migration` mode detects unmanifested file deletions/renames between tags. Hard-block on minor/major releases.
- **`migration-draft.sh`**: Generate draft manifests from `git diff --name-status` between adjacent tags.
- **12 historical manifests**: v2.19.0 → v2.27.0 complete chain (`.tad/migrations/`).
- **22 E2E fixtures**: 14 engine + 4 merge + 3 migration gate + AC17 inline.
- **Acceptance tooling**: `upgrade-acceptance.sh` (post-sync per-project verifier), `gate-exercise.sh` (real git state interception exercise).

### Changed
- Release gate graduated from shadow mode (TAD_RELEASE_GATE=warn) to hard-block after 14/14 project validation.
- tad.sh:721 comment fix ("lexicographic" → "version_le uses sort -V").
- Removed stale `.tad.backup.*` directories (superseded by engine's per-version backup mechanism).

### Architecture
- Migration manifest schema v1 frozen (`.tad/evidence/designs/migration-manifest-schema-v1.md`): 4 sections (delete/rename/merge/verify), path safety pipeline, consumer semantics contract.
- 3 Decision Records: DR-1 (backfill v2.19.0), DR-2 (user-modified detection hybrid), DR-3 (deprecation.yaml absorb).
- KA: APFS `pwd -P` case preservation (patterns/shell-portability.md).

## [2.27.0] - 2026-06-09

### Fixed
- Blake SKILL: inlined 3 circular-trigger references (ralph-loop, execution-checklist, completion-protocol) back into body — fixes Codex dogfood where Blake skipped Layer 2 / Gate 3 / completion report
- Agent message + 人话版 forgetting: added compact-resistant final output checklist to both SKILL bodies
- 人话版 quality: replaced structural compliance rules with reader-value test (3 questions + 2-3 paragraph limit)

### Added
- `skill-body-verify.sh`: body-integrity checker with 6 markers + safety floor + mirror sync + negative presence for deleted refs
- principles.md: "Circular Trigger Test" principle (14/15)
- Dual-platform native runtime architecture: Codex/Claude Code compatibility ledgers, runtime freshness verifier, drift-check release gate
- `.codex/config.toml` native policy + `.codex/agents/` evaluation framework

### Architecture
- Blake SKILL.md: 737 → 2005 lines (3 refs inlined, 2 ref-ok remain)
- Alex SKILL.md: minor additions (收尾 checklist + 人话版 rules)
- Dual-platform: both runtimes treated as first-class with independent compatibility tracking

## [2.26.0] - 2026-06-08

### New Features
- **Cross-Platform Unified SKILL**: Codex CLI now receives the same full SKILL.md files as Claude Code, installed to `.agents/skills/` via `tad.sh --platform codex`. Eliminates the compressed "Codex edition" dual-maintenance burden.
- **`--platform both`**: New install option writes to both `.claude/skills/` and `.agents/skills/` simultaneously, enabling dual-platform development in a single project.
- **Codex hooks.json**: `tad.sh --platform codex|both` auto-generates `.codex/hooks.json` with 4 lifecycle handlers (SessionStart, PostToolUse).
- **Sync multi-platform**: `sync-registry.yaml` now has a `platform` field per project. *sync routes skills to the correct platform path.
- **Platform annotations**: Alex and Blake SKILL.md contain HTML comment annotations mapping Claude Code tool names to Codex equivalents (e.g., `AskUserQuestion` → `ask_user_question`).

### Removed
- **Compressed Codex editions**: `.tad/codex/codex-alex-skill.md` and `codex-blake-skill.md` deleted (replaced by unified SKILL routing).
- **Codex launcher scripts**: `.tad/codex/codex-tad-alex.sh` and `codex-tad-blake.sh` removed (use `$alex` / `$blake` in Codex).
- **Parity infrastructure**: `codex-parity-check.sh`, `regen-codex-editions.sh`, tournament adapter, and all Codex adapter guides removed.
- **Publish parity gate**: `*publish` step3b (Codex Edition Parity Gate) removed from Alex SKILL and release-runbook.

### Fixed
- YAML frontmatter in `ai-agent-architecture` and `web-ui-design` SKILL.md now properly quotes `description` fields containing colons.

### Documentation
- `AGENTS.md` simplified: trigger-phrase table only, `$alex`/`$blake` as primary activation method.
- `INSTALLATION_GUIDE.md` Codex section rewritten with `--platform both` instructions.
- `.tad/guides/hooks-platform-mapping.md` created: documents all hook conversion rules and known limitations.
- `.tad/deprecation.yaml` v2.26.0 entry added (12 files for downstream auto-cleanup on sync).

## [2.25.0] - 2026-06-07

### New Features
- **Universal AC-Driven Gate**: Gate 3/4 now executes handoff §9.1 Spec Compliance Checklist row-by-row as the PRIMARY verification source, replacing hardcoded tsc/test/lint checks. Any project type (dev, podcast, content, e-commerce) gets meaningful quality gates through task-specific ACs.
- **Alex step1_ac_generation**: Alex auto-generates baseline ACs (tsc/test/lint) for dev projects based on task-scoped file detection. Non-dev projects get domain-specific ACs from Socratic Inquiry.
- **Rubric Evaluation Protocol**: Judge≠producer SAFETY machinery (5 VIOLATIONs, 3 verdict_shapes, decoupling firewall) extracted from the deleted deliverable branch into a universal Gate section, activated when §9.1 ACs reference rubric/judge evaluation.
- **Gate3_Verdict_Marker universal**: Telemetry marker now emitted for ALL task_types (was deliverable-only).
- **§9.1 empty guard**: Gate 3 BLOCKS if §9.1 is missing or empty (prevents silent zero-verification pass).
- **Dev-floor WARN**: Advisory warning when a code/mixed handoff touching buildable files has no compile/test AC.

### Breaking Changes
- `deliverable-handoff.md` template DEPRECATED — all task_types now use `handoff-a-to-b.md` with §9.1.
- `## Gate 3 — Deliverable Branch` and `## Gate 4 — Deliverable Branch` removed from gate/SKILL.md (logic migrated to Rubric Evaluation Protocol).
- `task_type: deliverable` frontmatter value preserved but now signals "§9.1 contains rubric ACs" instead of routing to a separate Gate branch.

## [2.24.1] - 2026-06-07

### New Features
- **npx cross-platform installer** (`bin/tad-install.mjs`): `npx github:Sheldon-92/TAD` offers interactive platform selection (Claude Code / Codex CLI) + capability-pack selection with one-line descriptions. Codex users get a slimmed install (excludes the 86K Claude-edition alex/blake SKILLs + hooks via deny-delta) → significantly lower context/quota footprint.
- **`tad.sh --platform <claude-code|codex>` + `--packs <list>`**: config-driven platform routing via `.tad/platform-codes.yaml` (deny-delta model, not allow-list). Backward compatible — no flag defaults to claude-code.

### Documentation
- README + INSTALLATION_GUIDE: added npx installation method (platform + pack selection).

### Notes
- Distribution: `npx github:Sheldon-92/TAD#v2.24.1` (pin recommended).
- Codex adapter validated end-to-end (13 capabilities) — see `.tad/evidence/codex-validation/`.

## [2.24.0] - 2026-06-07

### Added
- **Non-dev deliverable lane — categorical + checklist verdict_shapes**: Gate 3/4 deliverable branches now support `categorical` (rigor band, decoupled from the artifact's BUILD/PIVOT/KILL conclusion via an order-of-emission firewall + swap test) and `checklist` (export-spec pass/fail with a ≥1-required guard), in addition to `weighted`. product-thinking gains a dogfood-verified categorical rubric (a rigorously-argued KILL PASSes; a superficial BUILD FAILs). voice/video checklist gate-logic verified via synthetic fixture (real-content dogfood pending hardware).
- **visual-code-bridge capability** (web-frontend): React fiber source locator.
- **ai-podcast-production capability pack**: script writing with Codex review, large-chunk TTS, dual-BGM envelope-follower arrangement, show notes. Registry → 25 packs.

### Changed
- **Triple-Question KA simplified**: draft-then-confirm replaces the carve-out mechanism.

## [2.23.1] - 2026-06-03

### Added
- **Triple-Question KA**: Knowledge Assessment expanded from 2Q to 3Q (knowledge + skill + workflow pattern)
- **Skillify Step 5 — Pattern Type Routing**: after 4-gate pass, routes patterns to SKILL.md (judgment) or .workflow.js (orchestration)
- **Workflow Evaluation**: Blake KA detects workflow patterns via signal-word scanning (non-blocking, with skip_KA chain support)
- **Workflow Completion Trigger**: Alex lightweight 3Q assessment fires when Workflow tool returns agent_count ≥ 3
- **Alex .workflow.js Authoring Carve-out**: formal exception to "Alex doesn't code" for orchestration design artifacts (5-item forbidden_implementations guard)
- **Skillify Candidate `type` field**: `judgment | orchestration` routing in SCAND template frontmatter
- **Completion Report Q3 row**: Workflow Pattern Discovered row in Knowledge Assessment table

## [2.23.0] - 2026-06-03

### Added
- **Dynamic Workflow System**: 5 reusable `.claude/workflows/` scripts for deterministic multi-agent orchestration
  - `epic-audit.workflow.js` — fan-out + adversarial verification + synthesis for Epic status review
  - `gate-review.workflow.js` — per-AC verifier agents + skeptic filter (replaces single-context serial review)
  - `tournament-design.workflow.js` — N competing designers + pairwise judges + merged design (30% richer than single-agent)
  - `yolo-epic.workflow.js` — hybrid Conductor + workflow execution with budget reporting
  - `loop-discover.workflow.js` — loop-until-done discovery with dedup and dry-round stop condition
- **Cross-Platform Adapter**: `detect-platform.sh` + `tournament-codex.sh` for running tournament on Codex CLI
  - Runtime detection: TAD_PLATFORM override + workflow>codex file-based priority
  - Codex tournament uses `--output-schema` for mechanical JSON validation
  - JSON schemas in `.tad/codex/schemas/` (design, judge, merged)
- **ROADMAP**: "Dynamic Workflow Integration" theme with 6 completed phases
- **tad.sh + release-verify.sh**: `.claude/workflows/` added to sync and verification scope

### Changed
- **YOLO execution**: 240-line prose protocol replaced by 30-line invocation stub + `yolo-epic.workflow.js`
  - 4 constraint rules preserved in stub (file-as-truth, Conductor-spawned review, persistence, Blake Layer 1 only)
  - Original prose archived to `.tad/archive/protocols/yolo-execution-v1-prose.md`
- **alex/SKILL.md**: -211 lines net reduction. Added `step1_5c` (tournament option in *design), `*tournament` command, `loop_discover_option` in *optimize/*dream

### Fixed
- **YOLO stop-on-P0**: Added deterministic gate between Y4 design review and Y5 implementation — blocks implement when P0 found (Codex audit finding, Safety 2/5 → 4/5)
- **YOLO Y6 fail-closed**: All-null implementation reviewers now trigger early return instead of reporting 0 P0s
- **Tournament deep mode**: `judgePairs` undeclared variable fixed (would throw ReferenceError in ES module mode)
- **Budget label**: "budget-aware" corrected to "budget-reporting" (observation, not enforcement)

### Security
- Codex cross-model audit: 3 rounds (12/25 → 16/25 → 18/25). All P0 safety issues resolved.
- 7-experiment safety validation executed with pass/fail evidence

## [2.22.0] - 2026-06-01

### Added
- **Self-Deriving + Self-Verifying Release/Sync** — publish, sync, and install now DERIVE their file sets
  from the repo structure (deny-list) instead of hardcoded lists that silently go stale when the structure
  evolves. Replaces the recurring "release/sync missed a file" failures (e.g. `.tad/codex/` was frozen for
  a month; `tad.sh` stuck at an old version).
  - `.tad/hooks/lib/derive-sync-set.sh` — deny-list derivation, the single source of truth (a new framework
    dir is auto-included; zero-touch project data is never synced).
  - `.tad/hooks/lib/release-verify.sh` — structure-agnostic verification: `structural` (diff source==target)
    + `version` (grep for stale version refs, scoped to git-tracked files). Exit 0/1/2; `TAD_RELEASE_GATE=warn`
    shadow mode for first cutover.
  - Release-time HARD-BLOCK gate wired into `*publish` (version) + `*sync` (structural) — minor+ blocks on
    a detected omission/mismatch; advisory on patch. NOT a settings.json hook (release-time only).
  - `tad.sh` installer self-derives its copy-set (incl. previously-omitted dirs + top-level files of any
    extension), derives the version from source, runs a post-install `diff` self-check, and `--verify-denylist`
    drift-checks its inlined deny-list against the lib.
  - `release-runbook` SKILL upgraded to the derive+verify procedure; the old hardcoded 18-item version table
    and 14-dir sync list demoted to non-authoritative ("DERIVED — illustrative only").

### Notes
- This is the first release that USES the new mechanism (grep-derived version bump + shadow-mode gate).

## [2.21.0] - 2026-06-01

### Added
- **Codex-Edition Parity Mechanism** — TAD's Codex-CLI editions (Alex+Blake) now stay in sync with the
  Claude source on every release, automatically.
  - `*publish` runs a **detect-only** parity gate (`codex-parity-check.sh`) on both Codex editions:
    per-must-cover-owner-body SAFETY-constraint presence (compensation-resistant), fail-CLOSED. Drift on a
    minor+ release is a **HARD BLOCK**; advisory on patch. The gate is READ-ONLY — it never modifies editions.
  - `regen-codex-editions.sh` — a separate, human-invoked, atomic regeneration command (regen both via
    `codex exec` → parity-check → batch-replace only if both pass → human reviews `git diff` + commits).
    Keeps unreviewed LLM-generated content out of tagged releases.
  - Codex editions regenerated to current parity (they had drifted, frozen at 2026-05-04 — the deliverable
    track, research-engine, and pack-collision wiring were missing).
- `.tad/hooks/lib/codex-parity-check.sh` + `parity-criterion.md` (graduated to a stable path).

### Fixed
- `layer2-audit.sh` now recognizes the `spec-compliance` reviewer name (recurring false "1 reviewer" WARN).
- `tad.sh` `TARGET_VERSION` was stale at 2.19.1 (missed in the v2.20.0 release) — now bumped with the rest.

### Decision Records
- DR-20260601: Codex-Edition Parity Architecture (automated regeneration + decoupled release gate).

## [2.20.0] - 2026-06-01

### New Features

- **8 new agent-adjacent capability packs (16 → 24 total)** — `rag-retrieval`, `agent-memory`, `llm-observability`, `ai-guardrails`, `data-engineering`, `agent-orchestration`, `synthetic-data`, `knowledge-graph`. Each is a reference-based pack giving an agent senior-engineer judgment in that domain (named rules + specific thresholds + tool selection + anti-patterns). Auto-activate via the existing pack-awareness scan (Alex `step4_5`/`step1_5b`, Blake `1_5a`) on Chinese + English keyword match, and as native Claude Code skills. Registered in `pack-registry.yaml` with `consumes`/`produces` chain metadata.
- **Pack factory methodology (proven, reusable)** — NotebookLM deep research (Conductor-sequential, ~401 cited sources across 8 notebooks) → parallel build workflow (one agent per pack, grounded in research findings) → adversarial 2-reviewer + fix loop → real discriminative behavioral eval (WITH-pack vs knowledgeable-no-pack CONTROL).

### Quality / Validation

- **Cross-model adversarial review (Codex)** caught + fixed ~44 factual/API errors the same-model (Claude) build+review loop missed (wrong class names, deprecated APIs, OTel metric types, F2 math, etc.). 3 Codex claims were verified-and-skipped as Codex's own errors (GraphRAG Leiden levels, LangChain HITL decision count) — primary-source verified.
- **Behavioral eval status (honest)**: 7/8 packs verified via clean WITH»CONTROL discriminative delta; `data-engineering` left `pending` (CONTROL also passed — markers are common senior-DE knowledge, fixture needs tightening).
- **Measured findings** (recorded in `.tad/project-knowledge/architecture.md`): pack value is cross-vendor (Codex Δ6-9, Gemini Δ6-12) and **non-monotonic in model strength — peaks at Sonnet-tier** (strong enough to apply the full pack, weak enough to need the specifics); content-rich packs underperform on the weakest models that can't operationalize them.

### Notes

- All packs ship with `SKILL.md == CAPABILITY.md` byte-identical (installed-skill + source copies) and an `install.sh` (`--agent` portability path).
- No breaking changes. No trace schema change.

## [2.19.1] - 2026-05-30

### Bug Fixes

- **`tad.sh --yes` / `-y` non-interactive flag** — `tad.sh` had an interactive `read -p "Continue? (y/n)" < /dev/tty` (line 426) that blocked in non-TTY contexts (Claude Code Bash, CI, `curl … | bash`), making non-interactive `*sync` and `curl | bash` installs impossible. Added `--yes`/`-y` argument parsing that skips the confirmation prompt. Also hardened the cancel check to be `set -u`-safe on all paths (`${REPLY:-}`) and added an EOF guard (`read … || REPLY=""`) so a non-TTY run *without* `--yes` degrades to a clean "Cancelled." instead of an opaque `set -e` abort. Resolves the project-knowledge "Never Hand-Write What An Existing Tool Already Does" recommendation — non-interactive installs now run via `curl … | bash -s -- --yes`.

## [2.19.0] - 2026-05-30

### New Features — Observational Trace Instrumentation + ML Pack

- **v2 Observational Trace Instrumentation** — the self-evolution data layer is now functional.
  - Decision-level trace events (`gate_result`, `expert_review_finding`, `decision_point`, `reflexion_diagnosis`) now fire **observationally** — the `post-write-sync.sh` hook parses agent-written artifacts (COMPLETION `gate3_verdict:` frontmatter marker, HANDOFF §11 Decision Summary table, `## Reflexion History` blocks, `reviews/blake/<slug>/*.md` files) — instead of relying on imperative helper calls (which fired only 1 time in 328 events).
  - Fixed `handoff_created` 6× over-fire via per-(slug, day) dedup; `gate_result` re-emits only on verdict change.
  - Analyzer fixes: `*optimize`/`*evolve` expert-density schema correction (priority at top-level `.outcome`, count in `.context`) + N=0 gate-pass-rate skip guard (prevents false "Gate 2 0%" alarms when only Gate 3 is instrumented).
  - Removed the unreliable imperative `trace_reflexion_diagnosis` call from Blake's reflexion step; reflexions are now emitted from the COMPLETION report.
  - Hook **never fail-closed** (all parse paths tolerate malformed input); no trace schema change; JSON-object contexts use full detail to avoid truncation.

### Bug Fixes

- **`*sync` directory-list drift** — added `.tad/domains/` and `.tad/hooks/` to the `sync_protocol` Framework-subdirectories list in `alex/SKILL.md` (12 → 14 entries, now mirrors `tad.sh:115`). Fixes downstream projects retaining V1 trace hooks. Added a `SYNC-MIRROR` drift-prevention comment.
- **`tad.sh` version drift** — `TARGET_VERSION` was stale at `2.15` (3 minor versions behind); bumped to `2.19`.

### New Capability Pack

- **ML Training capability pack** (reference-based) — cloud-GPU training judgment rules, companion to the AI voice production pack.

### Documentation

- **Cloud compute resource awareness** embedded into Socratic inquiry and 2 other files — "hardware limitation ≠ infeasibility"; free/paid cloud GPU tiers as a resource-allocation option for ML-adjacent tasks.

## [2.18.0] - 2026-05-28

### New Features — Academic Research + Voice Production Packs

- **Academic Research Capability Pack** (7-phase Epic, 19 reference files, 4700+ lines)
  - Phase 1: ScienceClaw deep source study (285 skills analyzed, architecture-analysis.md)
  - Phase 2: Core pack build (research-protocol, literature-search, scholar-eval, zero-hallucination, statistics, writing, experiment-design, reflexion-cycle, fallback-chains)
  - Phase 3: Extract 86 ScienceClaw skills into 10 cluster references (domain-biomedical, domain-physical, domain-social, database-apis, multimodal-research, pattern-extraction, quantitative-analysis, visualization)
  - Phase 4-7: Database integration, multimodal image analysis, Python CV toolkit, pilot test (food science)
  - Includes: academic-search.sh CLI tool, image-analysis.py with OpenCV, setup-cv.sh

- **AI Voice Production Capability Pack** (8 reference files, 1317 lines)
  - Tool landscape: 13 TTS tools compared (9 Tier A with benchmarks, 4 Tier B)
  - Apple Silicon deployment rules (16GB/32GB memory budgets, MPS workarounds)
  - Voice cloning quality rules (zero-shot/fine-tuned/voice design, SIM/WER/MOS thresholds)
  - Audiobook pipeline (5-step workflow, ACX specs, ffmpeg mastering commands)
  - ChatTTS end-to-end workflow (344 lines, from real dogfood test)
  - Licensing safety (GREEN/YELLOW/RED classification for all tools)

- **Video-Creation Pack Upgrade**: ViMax agentic pipeline patterns (decomposition/intent/view/camera-tree) + behavioral examples framework with dogfood fixtures

### Documentation

- CHANGELOG, README, INSTALLATION_GUIDE, tad-help version bumped to 2.18.0
- pack-registry.yaml updated (13 → 15 packs)
- 48 new architecture knowledge entries from 7-phase Epic execution

## [2.17.0] - 2026-05-22

### New Features — Auto-Evolve + Domain Pack Freeze

- **Auto-Evolve Epic (4 phases)**: TAD now has a self-improvement pipeline
  - Phase 1: Decision-level trace schema v2 — 11 event types, env-var convention, sampling/compression, 180-day rotation
  - Phase 2: Blake Reflexion — structured failure diagnosis in Ralph Loop Layer 1 (per-iteration, not per-check)
  - Phase 3: Dream scanner — 4-pass pattern detection (grep/jq), SessionStart candidate display (STEP 3.56), `*dream --auto`, daily cron support
  - Phase 4: *optimize v2 (9 lifecycle health metrics) + *evolve v2 (cross-project v2 analysis, framework proposal staging)
- **Lifecycle Health Improvements**: `*accept --quick` (3-step lightweight archive), YOLO auto-archive safety net, startup zombie detection (STEP 3.5 + 3.55), *optimize lifecycle health metrics

### Breaking Changes

- **Domain Pack keyword router removed**: `userprompt-domain-router.sh`, `keywords.yaml`, and 4 supporting files deleted. Replaced by Capability Pack auto-awareness (Alex step4_5 + SessionStart context)
- **12 Domain Pack YAML files archived**: overlapping packs moved to `.tad/archive/domains/`. 9 YAML packs remain (hw×4, mobile×4, supply-chain-security). `startup-health.sh` now skips YAML packs that have Capability Pack SKILL.md equivalents
- **settings.json**: `UserPromptSubmit` hook section removed (keyword router was the only consumer)

### Documentation

- CHANGELOG, README, INSTALLATION_GUIDE version bumped to 2.17.0

## [2.16.0] - 2026-05-15

### New Features — Capability Pack Expansion (8→13 packs)
- **5 new capability packs** built via research-driven /capability-upgrade methodology:
  - `ai-evaluation`: 43 rules — promptfoo, deepeval, deepteam, ragas; eval frameworks, benchmarking, adversarial red-teaming, regression testing, A/B comparison (n≥550 statistical rigor), human eval calibration (ICC>0.92)
  - `web-testing`: 48 rules — Playwright, Vitest Browser Mode, k6, axe-core, MSW, Pact; unit/API/performance/accessibility/pair testing, testing pyramid strategy
  - `code-security`: 36 rules — Semgrep, Nuclei, Gitleaks/TruffleHog, Checkov, Trivy; SAST/DAST/secret detection/IaC security, four-gate pipeline architecture (exit codes: Semgrep 1, TruffleHog 183)
  - `web-deployment`: 51 rules — Vercel/Netlify/Fly.io/Coolify, GitHub Actions (SHA pinning, scoped secrets), OIDC auth, Uptime Kuma/Prometheus, blue-green/canary/atomic rollback, domain/DNS/SSL
  - `ai-tool-integration`: MCP server dev (TypeScript SDK), CLI wrapping (inner/outer loop decision), API integration (OpenAPI-to-MCP), OAuth 2.1/PKCE, tool schema design, MCP Inspector testing
- **5 NotebookLM research notebooks** created with ~400+ curated sources (GitHub-First methodology)
- **YOLO mode Epic execution**: first full autonomous Epic — research→build→validate→freeze in one session

### Domain Pack YAML Freeze
- **11 Domain Pack YAMLs deprecated**: ai-agent-architecture, ai-evaluation, ai-prompt-engineering, ai-tool-integration, code-security, product-definition, web-backend, web-deployment, web-frontend, web-testing, web-ui-design
- **Deprecation header**: `# DEPRECATED: Frozen as of 2026-05-15. Use capability pack instead.`
- **SessionStart hook**: automatically skips frozen packs (no longer injected into additionalContext)
- **9 unconverted packs remain active**: hw-circuit-design, hw-enclosure, hw-firmware, hw-testing, mobile-development, mobile-release, mobile-testing, mobile-ui-design, supply-chain-security

### Cross-Agent Validation
- **AGENTS.md**: added 13-pack routing table for Codex — keyword matching → SKILL.md path
- **Codex validation**: tested 2 tasks (code-security + web-deployment), packs loaded and rules extracted correctly

### Template Extraction
- **Capability pack template**: `.tad/templates/capability-pack-template/` — CAPABILITY.md template + reference file template + install.sh template + README
- **Documented patterns**: 3 architecture types (reference-based/deep-skill/orchestration-router), CONSUMES/PRODUCES interface, anti-slop formula, quality bar metrics

### Cross-Model Quality Audit
- **Codex audit**: 22.2/25 pack quality (3 STRONG, 2 ADEQUATE), 23/35 workflow
- **Gemini audit**: 23/25 pack quality (5 STRONG), 24/35 workflow
- **Key findings recorded**: validation theater, rule soup risk, behavioral eval needed — saved to project-knowledge/architecture.md

### Knowledge
- 4 new architecture.md entries: YOLO Audit Findings, YOLO Mode Strengths, Anti-Slop Metrics, capability pack quality bar
- OBJECTIVES.md O2-KR2 and O2-KR3 completed (Feasibility × Impact matrix + 3 Epic outlines)

## [2.15.1] - 2026-05-14

### Enhancement — Capability Pack Auto-Awareness
- **`*sync` step b2**: Automatically installs all 8 capability packs to downstream projects during sync (via install.sh --force)
- **Alex `step4_5`**: Pack awareness scan fires after intent router for all 6 user-task modes (*analyze, *express, *bug, *discuss, *learn, *experiment)
- **Blake `1_5a`**: Auto-detects relevant packs from handoff file types during *develop, independent of Alex's handoff references
- **Post-install validation**: Verifies SKILL.md YAML frontmatter after each pack install (catches silent registration failures)
- **Expert review fixes**: Separate Bash calls per pack (prevents set -e propagation), .claude/ pre-check, broadened keyword mapping, max 2 packs ranking rule

### Context
- Diagnosed: 14 downstream projects had pack-registry.yaml but zero packs actually installed as skills
- Prior activation surface: only Alex *design step1_5b (missed 99% of use cases)
- Now: Alex all modes + Blake *develop = packs loaded proactively without user intervention

## [2.15.0] - 2026-05-14

### New Features — *dream Knowledge Consolidation
- **`*dream` command**: 4-phase knowledge consolidation for Alex — Orient → Gather Signal → Consolidate → Summarize & Rebuild
- **dream-validator.sh**: Safety validator preserving MUST/MANDATORY/VIOLATION/BLOCKING keyword count + Foundational section byte-identical check
- **Candidate-only model**: Never modifies originals — produces candidate file for human review, with backup snapshot for rollback
- **`--promote` / `--rollback`**: Backup originals → replace with candidate; restore from `.tad/archive/knowledge-snapshots/`
- **Deterministic merge rules**: AMENDED+ORIGINAL pairs, identical title prefix, same handoff Context (not vague "70% overlap")
- **Safety entry protection**: Entries containing MUST/MANDATORY/VIOLATION/BLOCKING excluded from auto-merge — human-only review

### Results (first run on TAD itself)
- architecture.md: 1125 → 262 lines (**76% reduction**), 120 → 60 entries
- Safety keywords: 15 → 15 lines preserved (0 information loss)
- Foundational section: byte-identical
- 5 merge demonstrations with Supersedes: provenance
- Per-session token savings: ~30K → ~7K (~77% reduction)

### Research Foundation
- NotebookLM notebook query (49 sources) → Anthropic Dreams API + dream-skill + Mem0 patterns
- Codex+Gemini dual-model adversarial challenge (2 rounds, plan + findings)
- Key pivot: Gemini corrected research paradigm from "runtime memory" to "offline batch consolidation"

## [2.14.1] - 2026-05-14

### New Features — Research Adversarial Challenge
- **Dual-model adversarial review**: Research pipeline now has 3 challenge points (Phase 0c/4c/5b) where Codex + Gemini independently challenge Alex's research conclusions
- **5-dimension challenge framework**: Evidence sufficiency, angle completeness, assumption reliability, causal reasoning, decision support strength
- **Pass criteria**: Both models must rate ADEQUATE+ (strict — prevents single-model bias)
- **Max 2-round loop**: INSUFFICIENT triggers gap-driven re-research, hard cap prevents infinite loops
- **Experiment mode**: First 3 runs collect data from both models for comparison
- **Challenge prompt template**: `.tad/templates/research-challenge-prompt.md` with 3 adversarial variants (plan/findings/actions)

### Improvements
- **Fail-closed rating extraction**: `grep -oE` on first 5 lines, defaults to INSUFFICIENT if unparseable
- **CHALLENGE_INSTRUCTION constant**: Symmetric prompt string defined once, referenced across all phases (prevents cross-model prompt asymmetry)
- **AskUserQuestion gate**: Each challenge point requires user confirmation (respects NOT_via_alex_auto constraint)
- **Graceful degradation**: Codex/Gemini unavailable → single-model or skip with WARN

### Cleanup
- Archived Cross-Model Orchestration Epic (4/4 phases validated via menu-snap)
- Archived 8 obsolete/promoted/done Ideas (19→11 active)
- NEXT.md rewritten: 235→75 lines

## [2.14.0] - 2026-05-14

### New Features — YOLO Mode (Autonomous Epic Execution)
- **YOLO Execution Protocol**: Alex can now autonomously drive multi-Phase Epics — spawns Blake sub-agent for implementation, runs independent reviewer sub-agents for design + code review, executes Gates, all with persistent file artifacts. Human only participates at Epic definition and final acceptance.
- **Enhanced Epic Template**: Phase Detail Blocks with Scope/Input/Output/AC/Files/Dependencies/Notes. When sufficiently detailed, Alex reduces Socratic inquiry to light tier (2-3 questions instead of 3-5).
- **Step7 Execution Mode**: After Gate 2, Epic handoffs offer 3 execution modes — manual (current), YOLO (full auto), semi-auto (pause between phases).
- **audit-yolo.sh**: 4-dimension post-execution audit script — artifact chain completeness, content truthfulness (min lines + P0/P1/P2 classification), code verification (tsc re-run), timing order. 379 lines, pure bash.
- **Dogfood Validated**: First real YOLO execution on menu-snap (Chinese allergen detection, 2 phases) — 39/39 audit checks passed.

### New Features — LSP Code Understanding (from v2.13.1)
- **LSP Auto-Provision**: 12-language plugin mapping, auto-detect + install + graceful fallback to grep
- **Alex step1c_lsp**: incomingCalls scope gap detection after grounding pass
- **Blake 1_5d_lsp_blast_radius**: impact analysis before implementation

### Architecture Decisions
- Conductor = Alex (not a separate role). YOLO mode is an Alex capability, not a new entity.
- Sub-agents have no Agent tool (nesting impossible). All independent review at Conductor (Alex) level.
- File is source of truth — sub-agent prompts contain only file paths, never business content.
- 34-step TAD flow mapped: 18 KEEP, 7 ADAPT, 5 SKIP, 4 REPLACE for YOLO mode.

## [2.13.1] - 2026-05-14

### New Features — LSP Code Understanding
- **LSP Auto-Provision Protocol**: Alex/Blake auto-detect project language → try LSP → install plugin if missing → graceful fallback to grep. npm prereqs auto-install; brew prereqs recommend only. 12-language mapping in `.tad/guides/lsp-language-map.yaml`
- **Alex step1c_lsp**: After grounding pass, runs LSP `incomingCalls` on modified symbols to detect scope gaps in §6 file list. Auto-adds missing callers with annotation. Directly addresses the 4-instance scope estimation drift pattern
- **Blake 1_5d_lsp_blast_radius**: Before implementation, checks blast radius via LSP `incomingCalls`. Informational only — does not block
- **Tool Quick References**: Both alex and blake reference files updated with LSP section under new "Claude Code Native Tools" heading

### Bug Fixes
- Fixed stale transition arrow in Blake 1_5c (`proceed to 1_6_tdd_check` → `proceed to 1_5d_lsp_blast_radius`)

## [2.13.0] - 2026-05-09

### New Features — Research Methodology Upgrade
- **STORM Multi-Perspective Questioning**: New `perspective_shift` strategy (#4 of 6) in step3_5 dynamic follow-up protocol. Simulates 2-3 expert viewpoints derived from OBJECTIVES.md stakeholders (Tier 1), Domain Pack reviewer personas (Tier 2), or generic [engineer, end-user, skeptic] (Tier 3). Triggers when same strategy fires 2+ consecutive rounds (tunnel detection). Includes self-loop guard and `current_depth < max_depth` overflow protection.
- **Elicit Structured Paper Extraction**: New Phase 4.5 in *research-plan. Auto-extracts Research Question, Methodology, Key Findings, Stated Limitations, Baselines Compared, and Publication Year from academic sources (arxiv, scholar, .edu, ACM, IEEE). Runs ONLY inside *research-plan, never on standalone ask. Max 5 papers per research item.
- **Auto Source Discovery**: New Phase 4b step 3c. When both fast AND deep internal gap enrichment fail (net new sources = 0), automatically searches externally via WebSearch → selects top 3 URLs → routes through source-preprocessor.sh → adds with quality probe verification → re-asks. Last-resort fallback, not primary.
- **Adaptive Seed Generation**: New Phase 4 Step 2.5. After each seed's chain + Phase 4b completes, analyzes chain findings for uncovered sub-topics. Generates new seed question with user confirmation (AskUserQuestion). Max 2 dynamic seeds total. Seeds execute after all original seeds (append to end, not insert). Dynamic seeds receive full Phase 4b treatment but do NOT trigger further adaptive seeds (prevents meta-seed explosion).

### Bug Fixes
- Bilibili handler: 4-phase fallback rewrite (CC subs → B站API → yt-dlp metadata → Jina) with per-phase `method:` audit trail
- Quality probe: structural pre-check (<500 chars → QUALITY:NONE) + improved QUALITY:NONE criteria
- Source preprocessor: bilibili-specific timeout 60s (per-handler override, not global)

### Architecture Knowledge
- Multi-Phase Handler Fallback: Fast-Fail Before Slow-Fail (bilibili ordering rationale)
- Phase-Specific method: Field as Zero-Cost Audit Trail
- LLM Protocol Index-Access Guards: Off-by-One in Array-Based Tunnel Detection

## [2.12.0] - 2026-05-09

### New Features — Source Preprocessor + Dynamic Research
- **`add-smart` command**: Auto-detects URL type (X/Bilibili/arXiv/Scholar/Substack/Medium/generic) and routes to appropriate handler for preprocessing before NotebookLM import
- **4 Handler scripts**: x-handler.sh (twitterapi.io articles + tweets), bilibili-handler.sh (4-phase fallback: CC subs → B站API → yt-dlp → Jina), scholar-handler.sh (Semantic Scholar API + arXiv PDF), jina-handler.sh (Jina Reader generic)
- **Quality verification probe**: Post-import structural pre-check (<500 chars → QUALITY:NONE) + LLM probe (QUALITY:HIGH/LOW/NONE) with false-success detection and Jina fallback recovery
- **Dynamic Research Protocol (step3_5)**: Every `ask` now auto-chains follow-up questions with 3 strategies — Follow-the-Thread (chase surprising findings), Contradiction Hunting (resolve cross-source conflicts), So-What Chain (force actionable conclusions)
- **Research chain storage**: Multi-round findings saved as structured .md to `.tad/evidence/research/{topic}/` with frontmatter metadata
- **`--no-follow` flag**: Opt-out of dynamic follow-up, preserving single Q→A behavior
- **Seed question model**: *research-plan Phase 4 reduced from 5-10 static questions to 2-3 seed questions with depth-first dynamic exploration

### Bug Fixes
- X article handler: `.content` → `.contents` (plural) jq path fix
- All handlers: added `--connect-timeout 10 --max-time 25` for stock macOS (no gtimeout)
- Jina handler: curl exit 3 on nested URLs (`|| true` fix) + empty response guard
- Scholar handler: md5 portability (`$1` not `$NF`) + title-search fallback for all-null S2 responses
- Bilibili handler: `--no-playlist` before `--` separator + `jq`/`curl` preflight

### Architecture Knowledge
- NotebookLM Source Import: "False Success" More Dangerous Than Failure (7/14 tested sources returned `ready` with useless content)
- Shell Dispatcher: set -e + Exit-10 Propagation, Portable Timeout, Set-Diff Source ID
- Expert Reviewer Premise Check: Raw CLI vs SKILL Command Distinction
- Dynamic Research Chain: Saturation Counter Must Be Explicitly Persisted

## [2.11.0] - 2026-05-08

### New Features — Capability Pack System
- **8 Capability Packs**: web-backend, web-frontend, web-ui-design, product-thinking, ai-agent-architecture, ai-prompt-engineering, research-methodology, video-creation — all migrated to `.tad/capability-packs/`
- **Pack Registry**: `pack-registry.yaml` auto-generated by `scan-packs.sh` with CONSUMES/PRODUCES/keywords/type for each pack
- **Alex Pack Orchestration (step1_5b)**: Auto-discover packs from registry via semantic matching. When ≥2 packs matched, propose serial pipeline execution order. 3-tier lookup: source dir → installed skill → GitHub install prompt
- **Blake Notebook Lookup (1_5b)**: Auto-query relevant NotebookLM notebook before implementation starts
- **Blake Research Execution (1_5c)**: When `task_type: research`, Blake loads and executes research-methodology pack's 5-phase pipeline as primary workflow
- **Research Methodology Pack**: 5-phase pipeline (Plan→Source→Curate→Analyze→Output) with state-tracking, saturation detection (3-state: SATURATED/DIMINISHING/CONTINUE), anti-hallucination guards (4 layers), PIVOT/REFINE decision logic, QCE output format, dead-end registry
- **Registry Sync to Downstream**: `*sync` distributes `pack-registry.yaml` (not pack source) to downstream projects. Install via `gh api` (private repo) or `curl` (public repo)
- **3 Capability Pack Architecture Patterns**: reference-based (web-backend), deep-skill (product-thinking), orchestration-router (research-methodology)

### Architecture
- **Capability Pack Architecture Spectrum**: Documented 3 validated patterns for pack design (reference-based / deep-skill / orchestration-router)
- **Pack-to-SKILL Relationship**: Packs are orchestration layer; LLM is the only bridge between packs (no peer-worker dependencies)
- **≤12 skill accuracy limit**: Research-backed guardrail — beyond 12 loaded skills, LLM routing accuracy degrades

### Documentation
- Updated NEXT.md with all capability pack completion records
- Research evidence: 2 NotebookLM notebooks (37 sources, 8 ask rounds total)

## [2.10.5] - 2026-05-05

### New Features — Research Routing + Action Bridge
- **CLAUDE.md Global Research Routing**: Added `深度研究` routing row to §2 使用场景 table. Deep research tasks (signal: 研究/research/调研/landscape/对比/深入) now route to `*research-notebook` CLI pipeline instead of WebSearch. Quick lookups still use WebSearch.
- **Global Skill Exclusion**: Added `研究工具排除` note suppressing `/deep-research` global skill and generic Agent web searches for research tasks. Prevents routing race where global skill wins over TAD's NotebookLM integration.
- **Standalone Research Mode**: `*research-notebook` SKILL now usable without `/alex` activation. Removed "Alex-domain only" restriction. Added "Standalone Usage" section with precedence rule (when /alex IS active, Alex's own protocols take over).
- **Research → Action Bridge (step6)**: After `*research-plan` completes, Alex offers 5 next-step options: enter *analyze design / add to NEXT.md / continue researching / save to project-knowledge / just save. Closes the gap between "research done" and "what to do next".

### Research Infrastructure
- **Persistent Research Notebook**: Created NotebookLM notebook `37cfefa5` with 49 curated sources on AI Agent Framework Landscape 2025-2026. 5 rounds of deep ask completed covering: competitive analysis, failure modes, evaluation, memory systems, domain pack activation.
- **OBJECTIVES.md**: Created project-level OKR defining 3 research objectives (competitive positioning, upgrade directions, persistent knowledge base).
- **Research Findings**: Documented in `.tad/evidence/research/2026-05-05-tad-evolution-deep-ask-findings.md`.

### Strategic Direction
- **Depth-First Capability Building**: New epic prioritizing primitive capability deepening over Domain Pack breadth. Key insight from Knowledge Activation paper: SKILL.md (action-ready recipes) > YAML Domain Packs (informational ingredient lists).

---

## [2.10.4] - 2026-05-05

### New Features — CRAG Judge Loop + Parallel Curate
- **PHASE 4b CRAG Judge Loop**: Auto-detects source gaps in NotebookLM ask answers (3 signal phrases: "sources do not contain" / "not from your sources" / "not mentioned in the provided sources"), triggers targeted `--mode fast` re-research per-notebook, re-asks with enriched sources. `max_reask_per_question: 1` prevents infinite loops; diminishing returns detection stops wasted re-asks.
- **Parallel Batch Delete**: Replaced 4x sequential `source delete + sleep 0.5` loops with `xargs -P5` two-step batch pattern (collect IDs → parallel delete with safe `"$1"` positional args). Applies to both Alex `*research-plan` Phase 2 and `*research-notebook curate` Step 1b/1c. ~2x faster on real NotebookLM API (tested: 10/10 OK, 0 rate limit errors).
- **Query Narrowing**: PHASE 4b extracts 2-3 specific noun phrases from the original KR question for targeted fast research (avoids reproducing broad search that missed intersections).
- **Zero-Source Guard**: Skips re-ask if fast research returns 0 usable new sources after error cleanup.

### Research Backing
- Autonomous Research Agents notebook (`f3d46229`) with 15 sources: identified CRAG (Corrective RAG), STORM multi-perspective, and IterDRAG reflection loop as candidate architectures. CRAG chosen for lowest cost (NotebookLM provides free gap signals).
- menu-snap experiment report validated 5-Phase pipeline and identified the 4 improvement recommendations that drove this release.

## [2.10.3] - 2026-05-05

### New Features — Research Methodology Upgrade (5-Phase Pipeline)
- **5-Phase Research Pipeline**: Upgraded `*research-plan` step4 from report-only to full lifecycle: PHASE 1 (Deep Research) → PHASE 2 (Auto-Curate: clean errors + dedup + tier) → PHASE 3 (Baseline Report) → PHASE 4 (Question Tree + Ask Loops) → PHASE 5 (Extract Actionable Items → AC bridge)
- **Auto-Curate**: `*research-notebook curate` now includes Step 1b (auto-clean error sources) + Step 1c (auto-deduplicate by title+domain) + source quality tiering (Tier 1/2/3 by URL pattern)
- **Question Tree**: Alex generates KR-driven questions from OBJECTIVES.md (1-3 per KR based on breadth), user confirms before executing
- **Cross-Notebook Query**: Serial query across multiple relevant notebooks with `-n` flag (stateless, no `use` state leak)
- **Research→AC Bridge**: Phase 5 extracts actionable items from ask answers, suggests AC entries for future handoffs

### Bug Fixes
- Fixed NotebookLM CLI state leak: cross-notebook loops now use `-n` flag only (no `use` command)
- Added OBJECTIVES.md existence guard in Phase 4-5 (graceful skip if absent)
- Added defensive JSON guard for `source list --json` output format changes

## [2.10.2] - 2026-05-05

### New Features — Global Skill Exclusion + Tool Quick Reference
- **Global Skill Exclusion**: Added `global_skill_exclusion` block to Alex SKILL preventing 10 global/user-level skills from shadowing TAD-specific methods (deep-research, code-review, review, consulting-analysis, security-review, frontend-design, archive:full-review, archive:security-check, archive:refactor-module, archive:deploy-prep)
- **Tool Quick Reference Cards**: Created `tool-quick-reference-alex.md` and `tool-quick-reference-blake.md` — compact CLI cheat sheets loaded at activation so Alex/Blake know CLI paths, preflight checks, and key commands for NotebookLM, Codex, Gemini, gh, and TAD hook scripts
- **Execution Mechanism Declaration**: Added explicit anti-delegation rule in `*research-plan` step4 — Alex must execute `*research-notebook` commands IN-SESSION via Bash tool, not spawn background Agent tools
- **Activation Protocol STEP 3.3**: Alex now reads tool quick reference at startup before roadmap context

### Bug Fixes
- Fixed stale version strings: Alex SKILL header (was v2.8.5), Blake SKILL header (was v2.8.5), tad.sh TARGET_VERSION (was "2.8")
- Archived 5 conflicting project-level skills that duplicated global skill functionality (research, code-review, coordinator, product)

## [2.10.0] - 2026-05-04

### New Features — Goal-Driven Research Director + NotebookLM Full Integration
- **NotebookLM Research Director**: Complete research lifecycle integration (19 commands in *research-notebook SKILL). Includes: source add-research (deep mode: 64 sources + AI synthesis), generate report + download as markdown, knowledge loop (source add local .md → queryable in 30s), fulltext extraction, quiz/flashcards for *learn mode, notebook consolidation, language set, and more.
- **Alex Research Director Behavior**: STEP 3.8 research + objective alignment scan at activation. *research-review command for portfolio management (4-category diagnostic: strengthen/maintain/pivot/close). Proactive notebook consolidation suggestions. Research citations in handoffs.
- **`*research-plan` Command**: Autonomous goal-driven research — reads OBJECTIVES.md, identifies gaps, generates research plan, user confirms, Alex executes via NotebookLM. Updates objective coverage status.
- **OBJECTIVES.md (OKR Format)**: Business objective definition template. Alex reads at startup and checks research coverage against Key Results.
- **Blake NotebookLM Access**: Read-only + controlled ingest channel (10 allowed / 9 forbidden commands with default-deny rule).
- **Cross-Model Invocation Guide**: Best practices for calling Gemini/Codex as sub-agents from Claude Code.

### Bug Fixes
- Fixed setup-notebooklm.sh pinning deprecated notebooklm-py 0.1.1 → now pins 0.3.4
- Fixed NotebookLM CLI auth preflight: uses `auth check --test` instead of file-exists check

### Documentation
- New: `.tad/templates/objectives-template.md`
- New: `.tad/guides/cross-model-invocation.md` (Codex/Gemini sub-agent best practices)
- Updated: `.tad/cross-model/capabilities.yaml` (+89 lines — fulltext, quiz, flashcards, language capabilities)
- 3 new architecture.md knowledge entries (version deprecation, capability matrix, knowledge feedback loop)

---

## [2.9.1] - 2026-05-03

### New Features — Cross-Model Orchestration + NotebookLM Knowledge Layer

#### Cross-Model Orchestration (EPIC-20260503)
- **NEW**: `*research-notebook` skill — 8-command NotebookLM integration (create/add/ask/list/sync/curate/archive/use)
- **NEW**: `.tad/cross-model/capabilities.yaml` — pluggable capability catalog for cross-model abilities
- **NEW**: `.tad/research-notebooks/REGISTRY.yaml` — notebook lifecycle management (active/dormant/archived)
- **NEW**: `.tad/cross-model/setup-notebooklm.sh` — one-time auth setup with persistent venv
- **NEW**: Alex SKILL integration — `research_notebook_awareness` in *discuss + `step2_5_notebook_check` in Research Decision Protocol
- **NEW**: Fallback chains in config-workflow.yaml (research / image_generation / code_review)

#### Cross-Model Capabilities Verified
- **Codex Image-2**: GPT Image-2 image generation via `codex exec --full-auto` (architecture diagrams, UI mockups)
- **NotebookLM**: Multi-source knowledge base (YouTube + PDF + web) with cross-source reasoning via CLI
- **Gemini CLI**: Accessible from sub-agents (`gemini -p`), DEFER for research (needs symmetric-prompt retest)

#### Architecture Findings (8 new entries in architecture.md)
- Gemini CLI `-p` flag required for non-TTY invocation
- Codex stderr noise is benign — exit code is source of truth
- `codex exec review --commit` incompatible with `--full-auto [PROMPT]`
- Gemini CLI `-p` mode is read-only (no write_file/shell)
- Gemini regex uses PCRE — validate with BSD grep -E before use in hooks
- NotebookLM YouTube source strategy: conference/official videos with captions
- Cross-model prompt symmetry is load-bearing for fair comparison
- NotebookLM cross-source quality: 5/5, cites video content inline

## [2.9.0] - 2026-05-02

### New Features — Codex CLI Support

#### Codex CLI Adapter (`.tad/codex/`)
- **NEW**: Codex CLI adapter — run full TAD workflows on OpenAI Codex CLI as a fallback when Claude Code quota is exhausted
- **NEW**: Launchers: `bash .tad/codex/codex-tad-alex.sh` / `codex-tad-blake.sh` — one-command Codex TAD sessions with `--dry-run` and `--extract-only` flags
- **NEW**: Static Codex-edition SKILL files (25KB Blake, 35KB Alex) — stripped Claude Code-only tools, preserved all constraint rules (18 / 52 MUST/MANDATORY/VIOLATION lines)
- **NEW**: Portable extraction: `portable-rules.md` (classification) + `portable-extract.sh` (export helper)
- **NEW**: 4 operation guides: `manual-gates.md`, `sequential-review.md`, `socratic-fallback.md`, `expert-review-sequential.md`
- **NEW**: INSTALLATION_GUIDE Codex CLI Setup chapter
- **NEW**: release-runbook Codex Adapter Smoke Test — 5-step verification, hard block on minor+ releases

#### Validation
- Phase 0 spike: 5/6 PASS | Phase 1 build: 13/13 ACs PASS | Phase 2 dogfood: `codex exec --full-auto` CONFIRMED, write access confirmed, both personas operational

#### Known Limitations
- ChatGPT sandbox: write access confirmed in testing; use interactive mode if writes fail in other environments
- No AskUserQuestion: options presented as numbered text; no parallel sub-agents; gpt-5.5 default

## [2.8.5] - 2026-04-28

### New Features

#### Compact Recovery — Two-Layer Session State Persistence
- **CLAUDE.md §4.5**: Post-Compact Recovery self-check — agents verify identity + task state before every response
- **Blake SKILL `session_state_protocol`**: Session state written at 4 key moments (init, Layer 1 pass, Layer 2 rounds, completion)
- **Alex SKILL STEP 3.7**: 5-case routing on startup based on session-state.md (resume, Blake-done detection, stale skip)
- **`post-write-sync.sh`**: `update_session_state_metadata()` — hook updates timestamps when HANDOFF/COMPLETION files are written
- **New template**: `.tad/templates/session-state-template.md` with Big Picture fields (Goal, Why Now, Key Constraint, Success When)
- **`.gitignore`**: session-state.md excluded (runtime file, not versioned)

### Purpose
Prevents agent identity and task progress loss after Claude Code context compaction (Sonnet 4.6 shorter context triggers auto-compact, causing agents to forget their role and current handoff).

## [2.8.4] - 2026-04-27

### New Features — Token Efficiency Bundle (4 levers)

#### L1 — Tiered Layer 2 Reviewer Count by `task_type`
- **Blake SKILL `gate3_v2.layer2_expert_review.hard_requirement_distinct_reviewers`**: Layer 2 reviewer count is now task_type-aware:
  - `task_type: code` OR `mixed` → ≥2 distinct sub-agents (current rigor)
  - `task_type: yaml` OR `research` OR `doc-only` → ≥1 distinct (code-reviewer required)
  - `task_type: e2e` → ≥2 distinct (test-runner + code-reviewer or equivalent)
  - Fallback (missing/unrecognized task_type) → Tier 1 ≥2 (NFR1 + NFR4 silent quality loss prevention)
- **Alex SKILL `acceptance_protocol.step4c`**: New step 3.5 reads handoff frontmatter `task_type`, applies tier rule; step 4 Interpret adds tier-aware PASS/`LAYER 2 TIER UNDER-MET` WARN branches
- **Token savings**: ~60K per yaml/research/doc-only handoff (1 fewer reviewer)

#### L2 — Lazy Knowledge Load
- **Alex SKILL `handoff_creation_protocol.step0_5`**: Reordered from "read all 9 project-knowledge files" to "identify task keywords → read README index → match → read only matched category files"
- Inclusivity rule preserved (`relevant_knowledge` MUST include all matches; "false positives acceptable, false negatives are not")
- `stale-knowledge-check.sh` advisory call preserved
- **Token savings**: ~30-50K per handoff (skip 3-4 unrelated category files; architecture.md still loaded for most handoffs as default)

#### L4 — `*express` Default-ization (≤3 → ≤5 files)
- **Alex SKILL `express_path_protocol.scope_constraints.file_count_max`**: 3 → 5
- **Alex SKILL `express_path_protocol.when_NOT_appropriate`**: ">3 files" → ">5 files" (P0 fix from 2-expert review — was missed in initial draft)
- More cleanup/config handoffs eligible for `*express` (skips Socratic + ≥1 reviewer instead of ≥2)
- AR-001 mechanical SKILL grep anchor (`expert review.*code-reviewer`) preserved
- **Token savings**: ~250-280K per handoff that newly fits `*express` scope (Socratic skip + 1 fewer reviewer)

#### L6 — Narrow-Scope Expert Prompts
- **Alex SKILL `expert_prompt_template`** (line 2167): replaced from "FILE + FOCUS AREAS" stub with structured narrow-scope template
  - REQUIRED READS: §6 (Implementation Steps) + §9 (Acceptance Criteria) + §10 (Important Notes) + specific files in §7
  - OPTIONAL READS: §3 / §4 / §11 (only if §6 ambiguous)
  - NOT ALLOWED: free-grep wider codebase (except explicit blast-radius checks)
- **Blake SKILL `layer2_expert_review.expert_prompt_template`** (new sub-section): byte-symmetric with Alex template, oriented to post-impl reviewer context (diff + §6 + §9 instead of full handoff)
- **Token savings**: ~50% per sub-agent review (~115K → ~50-60K), 4 reviews per handoff = ~240K savings per Standard architecture handoff

### Total Estimated Savings
- Architecture-heavy week (most handoffs ≥5 files / code task_type): **~30-35% per handoff**
- Mixed week: ~25-30% per handoff
- Cleanup-heavy week (most handoffs newly fit `*express`): up to ~40% per handoff
- Quality防线 fully preserved (4-reviewer count unchanged for code handoffs; only context narrowed)

### New Features — Cleanup + Linear Removal (commit 2209648)
- **Linear integration removed** across 5 files (Alex STEP 3.7 startup full sync + `*accept` step4b_linear_sync + config-platform.yaml linear_integration section + config.yaml description/contains + handoff template `**Linear:**` field + post-write-sync.sh hint) — user judged feature unused
- **`*accept` slim**: Removed duplicate `step0b_evidence_check` (was strict subset of `acceptance_protocol.step4b`)
- **Domain Pack router hook → passive mode**: `userprompt-domain-router.sh` no longer injects `additionalContext` into agent context; keyword scoring + `.router.log` write preserved for future trace analysis
- **YAML structural fix**: `important_notes` dedented to top-level in config-platform.yaml (was incorrectly nested under linear_integration)
- Aligns with 2026-04-15 mechanical-enforcement-rejected lesson: smoke alarm > auto-extinguisher

### Bug Fixes — Pre-Publish Cleanup (commit 95b154b)
- **3 dangling consumers of removed `additionalContext` injection migrated to read `.router.log`**:
  - `.tad/hooks/run-phase2b-tests.sh`: Python `run_case` parser
  - `.tad/evidence/acceptance-tests/phase1-state-consistency/AC-P1.4-router-event-filter.sh`: Bash `_assert_match`
  - `.claude/skills/release-runbook/SKILL.md`: per-project smoke test (would have BROKEN every downstream `*publish` smoke test if not fixed)
- **Phase 2b regression test recovery**: 5/30 → 30/30 PASS
- **AC-P1.4 acceptance test recovery**: 0/7 → 6/7 PASS (1 perf bench dev-host variance, not regression)
- **BUSINESS-VALUE-FIRST RULE installed** (Alex SKILL step7 + Blake SKILL step8): handoff/completion 人话版 must lead with what user gains, not with file counts / expert findings / P0 numbers

### Migration Notes
- **No breaking changes for active code** (Linear integration was optional and unused; removal is config-section deletion only)
- New frontmatter fields `skip_knowledge_assessment` and `gate4_delta` continue to default to safe values when absent
- Domain Pack router hook passive mode: agents no longer see "⚠️ 检测到任务匹配 Domain Pack..." injection — pack catalog still injected via SessionStart hook for awareness
- `claude.ai` Linear MCP connection unaffected — only TAD's automatic sync was removed
- `deprecation.yaml` "2.8.4" entry lists files modified for downstream sync awareness
- `*express` widening (≤3 → ≤5 files): more handoffs naturally fit `*express` scope going forward — review your in-flight handoff drafts

### Documentation
- README.md / INSTALLATION_GUIDE.md / tad-help SKILL.md: version banner + tagline updated to "Token Efficiency + Linear Cleanup + Hook Passive Mode"
- README.md version history table: new v2.8.4 row
- `.tad/project-knowledge/architecture.md`: 5 new entries (cleanup scope-estimation drift / AC self-leak / pre-handoff vs post-impl reviewer scope / AC verification drift recurring 4-6 phases / honest_partial protocol real use validation)

### Known Issues Carried Forward
- **AC verification command literal-form drift**: 6 consecutive phases exhibited INTENT-PASS-LITERAL-FAIL on §9.1 verification commands. Recommended Phase-7+ Epic to operationalize "Alex MUST dry-run AC verification commands during handoff drafting" via PreToolUse hook on handoff Write. Tracked in NEXT.md.
- **L6 placeholder substitution**: `{list_of_files}` and `{blast_radius_grep_patterns}` placeholders introduced in expert_prompt_template but no Alex SKILL step populates them at runtime. v2.8.5 sub-handoff candidate to wire substitution.
- **Token savings unmeasurable from diff**: ~30-35% claim is estimate-only. v2.9.0 `*evolve` schema may add `est_input_tokens` field to gate4_delta for empirical measurement.

## [2.8.3] - 2026-04-15

### New Feature — Layer 2 Audit (smoke-alarm replacement for Epic 1)
- **`.tad/hooks/lib/layer2-audit.sh`** (88 lines): Utility script invoked by Alex `*accept` step4c. Validates Blake's Layer 2 reviewer artifacts exist on disk (`.tad/evidence/reviews/blake/<slug>/` with ≥1 ≥200B md file). Non-hook, non-blocking, zero `.claude/settings.json` footprint — no dogfood-paradox risk
- **Alex SKILL `acceptance_protocol.step4c`**: Runs audit between business AC verification and Knowledge Assessment. FAIL → red-flag warning in verdict (does NOT block acceptance — human accepter decides)
- **Blake SKILL `completion_protocol.step3c` — Slug Contract (MANDATORY)**: Blake MUST write reviewer artifacts to `.tad/evidence/reviews/blake/<slug-from-handoff-filename>/` with exact slug from regex `^(HANDOFF|COMPLETION)-\d{8}-(.+)\.md$` $2. No abbreviation, no case change, no suffix
- **Fixture matrix**: 11 cases (4 slug-validation negatives + 5 FAIL scenarios + 2 independent dogfood) — all PASS

### SKILL Hardening (from archived Phase 3.A work)
- **Alex SKILL `anti_rationalization_registry`**: 5 named rationalization patterns (AR-001 express-exempt / AR-002 small-edit / AR-003 spike-exempt / AR-004 perf-borderline / AR-005 knowledge-default) with explicit `must_scan_before` list. Soft reminders, zero runtime cost
- **Blake SKILL `honest_partial_protocol`**: Mandates `Overall: PARTIAL-GO` with explicit AC conflict statement when handoff ACs contradict — replaces silent AC-picking
- **Alex SKILL `handoff_creation_protocol` step0_5**: AC Conflict Matrix self-check before finalizing AC list
- **Alex SKILL `acceptance_protocol.step7`**: Raw-TSV recompute for Gate 4 verification integrity

### Product Decision — Epic 1 Mechanical Enforcement Cancelled
- **Epic 1 (EPIC-20260413-symmetric-quality-enforcement)** cancelled mid-Phase-3 implementation after dogfood paradox: Phase 3.C activated PreToolUse hook → `dep-guard.sh` PATH pin missed Apple Silicon Homebrew (`/opt/homebrew/bin`) → jq/yq not found → fail-closed denied ALL Claude tool calls → user had to manually `git checkout` in a separate terminal to recover
- **Technical verdict**: all 4 prior phases (1a/1b/1c/2) PASS — mechanism works. **Product verdict**: single-user CLI threat model doesn't justify "Claude tools can be totally locked out via minor env bug" cost
- **Archived**: Phase 3 handoff + 3 expert reviews + v2 extracts in `.tad/archive/spikes/phase3-attempt-20260415/`; Phase 3.B hook code in `.tad/archive/spikes/phase3-hooks-prototype/`
- **Knowledge**: `.tad/project-knowledge/architecture.md` entry "Mechanical Enforcement Rejected on Single-User CLI - 2026-04-15" — core lesson: LLM alignment ≠ must intercept tools; deployment threat model determines mechanism

### Documentation
- CHANGELOG entry for this release (you're reading it)
- README version history row for v2.8.3
- Epic 1 cancellation notes inline in archived Epic file

### Migration Notes
- **No breaking changes**. Existing `.claude/settings.json` hooks unchanged — v2.8.3 adds NO new hook registration
- SKILL additions are pure prose; downstream agents will pick them up on next session start
- `layer2-audit.sh` is opt-in via Alex SKILL; if downstream projects haven't synced the Alex SKILL, audit simply won't run (no error)

## [2.8.2] - 2026-04-08

### New Features — Domain Pack Auto-Loading Hook (Epic 1)
- **UserPromptSubmit keyword router hook**: `.tad/hooks/userprompt-domain-router.sh` — production `type: command` hook that classifies user messages against 20 Domain Packs using deterministic keyword matching (no LLM calls)
- **20-pack keywords database**: `.tad/hooks/keywords.yaml` — hand-curated, zero cross-pack collisions, ≥3 unique anchors per pack, Chinese + English coverage
- **One-shot generator**: `.tad/hooks/generate-keywords.sh` — English-heuristic baseline generator for future pack additions
- **Regression test harness**: `.tad/hooks/run-phase2b-tests.sh` — standalone 30-case integration test + latency microbench
- **Performance**: 30/30 = 100% accuracy, 81ms median latency (2.4x under 200ms target)
- **Kill-switch**: `TAD_DOMAIN_ROUTER=off` env var OR `.tad/hooks/.router-disabled` file
- **Structured log**: `.tad/hooks/.router.log` (size-rotated, privacy-safe, no prompt content)

### Bug Fixes
- **tad.sh deprecation cleanup**: `copy_framework_files()` now reads `.tad/deprecation.yaml` and deletes files listed for deprecation ≤ current version (fixes 2.8.1 cleanup that never actually executed — downstream projects still had old `/tad-alex`, `/tad-blake` slash commands)
- **tad.sh hooks copy**: added `hooks` to framework subdirectories copy list (was missing)
- **config.yaml stale version**: was 2.8.0 since 2.8.1 release, now 2.8.2

### Epic 1 Architecture Journey (3 spikes → production)
- **Phase 1**: Light TAD spike validated `UserPromptSubmit` hook exists + Haiku accuracy 93.75% (`type: command` proof)
- **Phase 2a**: Contract micro-spike proved `type: prompt` is permission-gate-only — Architecture A DEAD, pivoted to Architecture C
- **Phase 2b**: Production `type: command` keyword router shipped with 100% accuracy
- **Knowledge captured**: 4 new architecture.md entries (hook perf single-awk pattern, `claude -p` as valid testing channel, keyword uniqueness > count, Epic architecture pivot through successive spikes)

### Documentation
- README.md, INSTALLATION_GUIDE.md, tad-help SKILL version refs updated 2.8.0 → 2.8.2
- CHANGELOG retroactive 2.8.1 entry added below

## [2.8.1] - 2026-04-04

### Refactor — Commands Consolidation
- **Commands → Skills migration**: 18 `.claude/commands/*.md` files merged into `.claude/skills/*/SKILL.md` (single source of truth)
- `/alex`, `/blake`, `/gate`, `/tad-maintain` etc. are now skill invocations
- Path references updated across 10+ files (tad.sh, config files, docs)
- `domain_pack_awareness` added to `*discuss` mode
- **Deprecation registry**: `.tad/deprecation.yaml` added with 18 command file entries for sync cleanup
- **Known bug (fixed in 2.8.2)**: deprecation cleanup was never actually applied — `tad.sh` didn't read deprecation.yaml. Fixed in 2.8.2.

## [2.8.0] - 2026-04-03

### New Features — Self-Evolving Framework
- **Execution Trace Recording**: PostToolUse hook auto-records file events (JSONL)
- **Step-Level Trace**: trace-step.sh CLI for Domain Pack step start/end recording
- **`*optimize` Command**: Analyze project traces → propose Domain Pack + Project Knowledge improvements
- **`*evolve` Command**: Cross-project trace aggregation → propose TAD framework improvements
- **Human Approval Workflow**: PROPOSAL YAML schema + AskUserQuestion approval + safety constraints
- **Quality Gate Hooks**: pre-accept-check.sh (BLOCK without COMPLETION), pre-gate-check.sh (BLOCK Gate 3 without evidence)

### Domain Packs (20 packs, 78 tools across 5 chains)
- Phase 1 Web: product-definition, web-ui-design, web-frontend, web-backend, web-testing, web-deployment
- Phase 2 Mobile: mobile-ui-design, mobile-development, mobile-testing, mobile-release
- Phase 3 AI: ai-agent-architecture (9 caps incl self-improvement), ai-prompt-engineering, ai-tool-integration, ai-evaluation
- Phase 4 Hardware: hw-circuit-design, hw-enclosure, hw-firmware, hw-testing (research supplement: +4 steps, +2 tools)
- Phase 5 Security: supply-chain-security (litellm-class attack detection), code-security (SAST + DAST + secrets + IaC)
- tools-registry.yaml: 78 tools across all packs
- Domain Pack creation template + HOW-TO guide + ROADMAP

### Knowledge Assessment Pipeline Fix
- Gate 3/4 tables upgraded: Action → Evidence column (file path + entry title required)
- "Yes" without evidence = Gate FAIL enforcement
- Alex step7 split: A (verify Blake's Gate 3 knowledge) + B (write own Gate 4 knowledge)
- Handoff step0_5: keyword-based semantic scan of all knowledge entries for exhaustive matching

### Domain Pack Workflow Integration (2-Point Injection)
- design_protocol step1_5: Domain Pack Loading with AskUserQuestion confirmation
- handoff step1a: Domain Pack Injection — quality_criteria as advisory ACs, anti_patterns to Important Notes
- Both points have skip_conditions for Light TAD and no-match scenarios

### AI Agent Self-Improvement
- self_improvement_design capability with 6-step design process
- 6-environment reference table (OpenClaw, LangSmith, Firebase RC, Langfuse, Claude Code, Enterprise)
- Based on production research (Meta-Harness, EvoAgentX, NeMo Guardrails, DeerFlow)

### Quality Enforcement
- pre-accept-check.sh: BLOCK *accept without COMPLETION report (exit 2)
- pre-gate-check.sh: BLOCK /gate 3 without evidence (cold-start safe)
- Enhanced post-write-sync.sh: COMPLETION→Gate3 reminder, HANDOFF→expert review 4-step checklist, Ralph Loop→workflow reminder
- Batch expert review of all 6 initial Domain Packs (4 P0 fixed)

### Quality Chain Full Repair (4-Phase Epic)
- **Root cause**: v2.7 slimming misclassified constraint rules as mechanical instructions
- **Three-layer defense**: Prompt (what to do) + Template (how to record) + Hook (did you do it)
- Phase 1: Handoff YAML frontmatter (task_type/e2e_required/research_required) + completion-report Gate 3 v2 structure + Knowledge Assessment + Evidence Checklist
- Phase 2: Blake EXECUTION CHECKLIST (4 stages + task_type branching + 7 anti-rationalization comments) + frontmatter_compliance mandatory rule
- Phase 3: Alex step1b frontmatter validation + step4 AC-by-AC verification table + step4b evidence completeness check + Knowledge Assessment enforcement + step0b archive safety net
- Phase 4: pre-gate-check.sh comprehensive Gate 3 checks (evidence files, Ralph Loop state, conditional E2E/research BLOCK, Git dirty check)
- Hook Coverage Boost: 8 content-level checks (evidence non-empty, Knowledge Assessment filled, Evidence Checklist checked, Gate 3 FAIL→BLOCK, AC count matching, Ralph Loop layer2 completion, expert review ≥2, commit hash non-placeholder)
- Hook coverage: 2.5% → ~35-40% (from 3 rules to ~45 rules)
- New architecture learning: Three-type rule classification (judgment / mechanical / constraint)

### Architecture Knowledge
- Domain Pack Step Model: Type A (doc) / B (code) / Mixed
- Hook path matching: *.tad/ for relative+absolute
- Judgment-only skill files: 76% reduction safe when hooks handle automation
- Claude Code enforcement priority: deny > hooks > allow
- **Three-type rule classification**: judgment (keep in SKILL.md), mechanical (move to hook/config), constraint (NEVER remove — anti-LLM-shortcut guardrails)

## [2.7.0] - 2026-03-31

### Breaking Changes — Hook-Native Architecture Rebuild

- `settings.json` rewritten to Claude Code native format (hooks + permissions)
- Alex SKILL.md reduced from 2528 to 570 lines (78% reduction)
- Blake SKILL.md reduced from 1052 to 283 lines (73% reduction)
- CLAUDE.md reduced from 155 to 69 lines (56% reduction)

### New Features

- **Hook Infrastructure**: SessionStart health check, PostToolUse workflow reminders
- **PreToolUse Prompt Hook**: Haiku-based intelligent gating for Write/Edit operations
- **Native Claude Code Integration**: settings.json uses Claude Code's hook system directly

### Architecture Changes

- 5-layer architecture: CLAUDE.md router → settings.json hooks → .tad/hooks/ scripts → Skills (judgment-only) → Config YAML
- Hook event keys confirmed PascalCase (PostToolUse, PreToolUse, SessionStart)
- additionalContext injects as `<system-reminder>` (system-level authority)
- Enforcement priority: permissions.deny > hooks > allow > user prompt

### Context Optimization

- Total context footprint reduced ~76% (59K → 14K tokens)
- Hook scripts execute externally (zero context cost)
- Skills contain only judgment logic (Socratic inquiry, intent routing, design decisions)

### Known Limitations

- `allowed-tools` frontmatter not enforced in Claude Code v2.1.88
- Per-skill hooks in frontmatter not implemented
- PreToolUse prompt hook adds ~2-5s latency per Write/Edit (Haiku round trip)
- `permissions.deny` only works at tool-name level (no path patterns)

### Migration Notes

- Old settings.json backed up as `.claude/settings.json.v2-backup`
- Hooks require `jq` installed (with grep fallback)
- TAD v2.7 should NOT use `bypassPermissions` mode (deny rules don't work in bypass)

## [2.6.0] - 2026-03-25

### Added — 4D Pair Testing + Autoresearch + Linear Integration

- **4D Protocol Pair Testing** (Discover→Discuss→Decide→Deliver)
  - Core methodology upgrade: decisions made at discovery time, not deferred
  - Leverages 1M context window for in-session decision-making
  - Updated test-brief-template.md + pair-test-report-template.md
  - "Solutions Decided" table added to Round summaries and reports

- **Autoresearch Optimization Mode** (Ralph Loop Layer 0.5)
  - Autonomous optimization loop for tasks with numeric targets
  - Inspired by Karpathy's autoresearch: modify → benchmark → keep/discard → repeat
  - Git commit/reset as state management, safety anchor tags
  - Scope enforcement, circuit breaker (5 consecutive failures), max 50 iterations
  - Config: `optional_features.autoresearch_mode` (opt-in, default enabled)
  - New template: `.tad/templates/optimization-program.md`

- **Linear Kanban Integration** (Cross-Project Human Dashboard)
  - Linear MCP Server integration for cross-project time/energy management
  - 4 projects: Menu Snap, TAD, OpenClaw Agents, Sober Creator
  - `step4b_linear_sync` in Alex *accept flow (non-blocking, explicit ID linking)
  - `linear_integration` section in config-platform.yaml
  - Optional `**Linear:**` field in handoff template header

- **Linear Auto-Sync** (NEXT.md → Linear One-Way Sync)
  - `step3.7_linear_sync` in Alex activation protocol (startup full sync)
  - NEXT.md sections map to Linear statuses (In Progress/Todo/Backlog/Done)
  - Linear ID writeback `[XXX-NN]` to NEXT.md for reliable matching
  - Max 10 creations per startup, skip untagged completed items
  - Conflict detection (file modification time check)

### Removed

- **Mode A (Chrome MCP / Claude Desktop)** from pair testing templates and commands
  - Only Mode B (Claude Code + Playwright) remains

### Changed

- `config-platform.yaml`: added `linear_integration` with `auto_sync` section
- `config-execution.yaml`: added `autoresearch` section
- `tad-alex.md`: added step3.7 (Linear sync) + step4b (enhanced) + 4D pair testing refs
- `tad-blake.md`: added step 1_8 + 1_9 (autoresearch optimization loop)
- `pair-test-report-template.md`: added Section 2c (Per-Round Findings & Decisions)
- Removed "Claude Desktop" references from tad-test-brief.md, tad-help.md, tad.md

---

## [2.5.0] - 2026-03-23

### Added — Superpowers-Inspired Tactical Upgrades

- **Spec Compliance Reviewer** (Ralph Loop Group 0)
  - New `spec-compliance-reviewer` subagent runs BEFORE code-reviewer
  - Separates "did we build the right thing?" from "did we build it right?"
  - Blocking: Group 1 cannot start until Group 0 passes
  - Handoff template gains optional §9.1 Spec Compliance Checklist

- **Anti-Rationalization Tables**
  - 12 entries across 3 categories: Socratic bypass (4), Gate bypass (5), Terminal isolation bypass (3)
  - Standalone guide: `.tad/guides/anti-rationalization-tables.md`
  - 8 inline embeds across `tad-alex.md`, `tad-blake.md`, `CLAUDE.md`

- **TDD Enforcement Skill** (opt-in)
  - `.tad/skills/tdd-enforcement/SKILL.md` with RED-GREEN-REFACTOR cycle
  - Config toggle: `optional_features.tdd_enforcement.enabled: false` (default OFF)
  - Blake `1_6_tdd_check` step in develop_command
  - 5 TDD-specific anti-rationalization entries

- **Micro-Tasks Template**
  - Optional §6.1 Micro-Tasks section in handoff template
  - 2-5 minute tasks with file paths + verification commands
  - Recommended for Full/Standard TAD, skip for Light

- **Pressure Testing Methodology**
  - `.tad/guides/skill-pressure-testing.md` — RED-GREEN-REFACTOR for rules
  - Metrics: Rule Hold Rate, Bypass Discovery Rate, False Positive Rate
  - Worked example: Socratic Inquiry rule

- **Git Worktree Integration** (opt-in)
  - `*develop --worktree` creates isolated branch for implementation
  - 4 finishing options: merge / PR / keep / discard
  - Config: `optional_features.git_worktree.enabled: true`
  - Edge cases: existing branch, merge conflicts, non-git repo

### Changed
- `loop-config.yaml` v1.1 → v1.2 (Group 0 added)
- `expert-criteria.yaml` v1.1 → v1.2 (spec-compliance-reviewer entry)
- Ralph Loop summary format includes spec-compliance column

### Research
- Session Hook Technical Spike: Verdict ⚠️ PARTIAL — hooks work but session start overhead is only ~8.5% of total context. Architecture already well-optimized. Knowledge: "Measure Before Optimizing" pattern.

---

## [Unreleased] - 2026-02-01

### Added

- **Epic/Roadmap Multi-Phase Task Tracking**
  - `epic-template.md` with derived status design (no independent Status field)
  - Directory structure: `.tad/active/epics/`, `.tad/archive/epics/`
  - Alex `step2b`: Epic Assessment in Adaptive Complexity protocol
  - Alex `step2b_epic_update`: Epic update in `*accept` flow (after handoff archive)
  - Alex `epic_linkage`: Concurrent control in handoff creation protocol
  - Handoff template: optional `**Epic:**` field
  - `config-workflow.yaml`: `epic_lifecycle` section (constraints, derived status, health checks)
  - CLAUDE.md §2.1: Epic rules (lifecycle, sequential constraint, error handling)
  - `tad-maintain`: 7 Epic check types (STALE, ORPHAN, DANGLING_REF, BACK_REF_MISMATCH, STUCK, OVER_ACTIVE, OVER_LIMIT)
  - `tad-help`: Epic/Roadmap documentation section

- **CLAUDE.md Router Architecture (先补后砍)**
  - Phase 1: 13 execution rules backfilled to agent files (`tad-alex.md`, `tad-gate.md`, `tad-blake.md`)
  - Phase 2: `CLAUDE.md` rewritten from 657→109 lines (router pattern)
  - Phase 3: Alex config loading optimized from 5→4 modules (dropped `config-execution`)
  - Router preserves all enforcement markers: BLOCKING, VIOLATION, CRITICAL
  - Backup: `.tad/backups/CLAUDE.md.pre-slim-backup`
  - 3 expert reviews, 9 P0 resolved, 24/24 verification criteria passed

### Changed

- **Pair Testing Redesign**: Human-initiated, Alex-owned
  - Trigger moved from Gate 3 (Blake auto-generates) to Gate 4 (Alex evaluates, human decides)
  - `test-brief-template.md` Section 6 rewritten as Claude Desktop collaboration guide (4 subsections)
  - New `pair-test-report-template.md` for standardized report output
  - `config-workflow.yaml`: Updated `pair_testing.brief.trigger` to Gate 4 + Alex
  - `tad-blake.md`: Removed `step4b_generate_test_brief` and message line
  - `tad-alex.md`: Added `step_pair_testing_assessment` with AskUserQuestion
  - CLAUDE.md §8: Updated pair testing rules

---

## [2.2.1] - 2026-01-31

### Added

- **Pair Testing Protocol** - Cross-tool E2E testing integration (TAD CLI → Claude Desktop)
  - `test-brief-template.md` - 8-section generic template (Web defaults, universal design)
  - Blake `step4b`: Conditional TEST_BRIEF.md generation after Gate 3 (user-facing changes only)
  - Alex `step_test_brief`: Supplement Section 5 (design intent) after Gate 4, remind user
  - Alex `STEP 3.6`: Auto-detect `PAIR_TEST_REPORT*.md` on startup
  - Alex `*test-review`: Read report → classify P0/P1/P2 → generate fix Handoff or add to NEXT.md
  - `/tad-test-brief` standalone command for ad-hoc testing needs
  - File lifecycle: naming conventions, directory structure, archival to `.tad/evidence/pair-tests/`
  - `tad-maintain` integration: PAIR TESTING check items in CHECK and FULL mode reports
  - CLAUDE.md §8: Pair testing rules (Gate integration, cross-tool collaboration, file lifecycle)

- **Philosophy: Beneficial Friction** - Core design rationale added to README.md
  - Three critical friction points: requirement clarification, priority decision, E2E acceptance
  - Beneficial vs wasteful friction distinction
  - Key Principles section updated to reference Beneficial Friction consistently

### Changed

- CLAUDE.md section renumbering: §8 = Pair Testing, §9 = Violations
- `config-workflow.yaml`: Added `pair_testing` section (brief, report, screenshot config)
- `config.yaml`: Updated module index and command binding for `tad-test-brief`

## [2.2.0] - 2026-01-31

### Added

- **Bidirectional Message Protocol**: Structured copy-pasteable messages between agents
  - Alex auto-generates "Message from Alex" after handoff creation (task, priority, key files, notes)
  - Blake auto-generates "Message from Blake" after completion (status, changes, evidence)
  - Messages designed for human to copy-paste between Terminal 1 and Terminal 2

- **Blake Active Handoff Auto-Detection** (STEP 3.6)
  - On startup, Blake scans `.tad/active/handoffs/` for pending handoffs
  - Presents list to user via AskUserQuestion
  - User can pick one to execute or skip

- **Adaptive Complexity Assessment**
  - Alex auto-assesses task complexity (Small/Medium/Large) based on signals
  - Suggests process depth: Full TAD / Standard TAD / Light TAD / Skip TAD
  - Human makes final decision via AskUserQuestion
  - User's choice overrides internal complexity detection

- **Modular Config Architecture** (config.yaml split)
  - `config.yaml` (master index, 327 lines) - module index, per-command binding, system config
  - `config-agents.yaml` (288 lines) - activation protocol, triangle model, human role
  - `config-quality.yaml` (741 lines) - quality gates, evidence, mandatory questions, sub-agents
  - `config-workflow.yaml` (478 lines) - document management, elicitation, socratic inquiry
  - `config-execution.yaml` (375 lines) - Ralph Loop, release management, learning mechanisms
  - `config-platform.yaml` (287 lines) - multi-platform support, MCP tools
  - Original 2398-line monolith → 6 focused modules with master index
  - Per-command module binding: each command loads only what it needs
  - Full backup preserved at `config-full-backup.yaml`

### Changed

- **Alex workflow** updated to 8 steps (added Assess step)
- **Alex on_start** greeting mentions complexity assessment
- **Blake on_start** greeting mentions auto-detect feature
- **Agent STEP 3** now loads modular config files instead of monolithic config.yaml
- **tad-help.md** updated with Adaptive Complexity and Bidirectional Message sections
- **CLAUDE.md** updated with Adaptive Complexity table

---

## [2.1.2] - 2026-01-31

### Removed

- **`/tad-learn` command**: Deprecated framework-level learning recorder
  - TAD methodology improvements now made directly in the TAD mother repository
  - Existing learnings archived to `.tad/archive/learnings-archived/`
  - Project Knowledge system (`.tad/project-knowledge/`) remains unchanged
  - Cleaned up references in CLAUDE.md, README.md, tad-help.md, tad.sh

### Changed

- CLAUDE.md section numbering updated (removed Section 7, renumbered 8→7, 9→8)
- `tad.sh` install script no longer creates `.tad/learnings/` directories
- README.md contributing section updated to direct users to TAD repo

---

## [2.1.1] - 2026-01-31

### Added

- **`/tad-maintain` Command**: Document health check and synchronization
  - Three modes: CHECK (read-only), SYNC (scoped writes), FULL (comprehensive)
  - Handoff lifecycle audit with 4 detection criteria (A/B/C/D)
  - NEXT.md automatic size monitoring and archival
  - PROJECT_CONTEXT.md sync and creation
  - Document consistency checks (version alignment, orphan detection)
  - Auto-triggers on agent activation (`*exit`) and `*accept`

- **Handoff Stale Detection** (Criterion C/D)
  - Criterion C (AGE_STALE): Flags active handoffs older than `stale_age_days` (default 7)
  - Criterion D (TOPIC_SUPERSEDED): Cross-references archived handoffs by topic keyword overlap
  - Interactive user confirmation via AskUserQuestion (never auto-archives)
  - Configurable thresholds in `config.yaml` under `handoff_lifecycle`

- **New Configuration**: `handoff_lifecycle` section in `config.yaml`
  - `stale_age_days`, `cross_reference_window_days`, `topic_match_threshold`
  - `common_words_exclude` list for topic matching

- **New Templates**
  - `.tad/templates/AGENTS.md.template` - Codex CLI project instructions template
  - `.tad/templates/GEMINI.md.template` - Gemini CLI project instructions template

- **CLAUDE.md Section 8**: Document maintenance rules with Criterion 1-4

### Changed

- **Simplified Adapter Architecture**: Removed `.tad/adapters/` directory
  - All platform conversion logic consolidated into `/tad-init` command
  - Removed `adapter-schema.yaml`, `platform-codes.yaml`, per-platform adapter files
  - Removed `.tad/templates/command-converters/` (to-codex.template, to-gemini.template)
  - Simpler, more maintainable multi-platform support

- **config.yaml**: Updated to v2.1.1 with `handoff_lifecycle` and simplified `multi_platform` section

### Removed

- `.tad/adapters/` directory (replaced by `/tad-init` inline logic)
- `.tad/templates/command-converters/` directory (replaced by `/tad-init` inline logic)

---

## [2.1.0] - 2026-01-26

### Added

- **Agent-Agnostic Architecture**: Multi-platform support for AI coding assistants
  - Claude Code (primary): Full subagent support
  - Codex CLI (secondary): Self-check mode with native SKILL.md support
  - Gemini CLI (secondary): Self-check mode with TOML commands

- **Platform-Agnostic Skills System** (`.tad/skills/`)
  - 8 P0 skills: testing, code-review, security-audit, performance, ux-review, architecture, api-design, debugging
  - YAML frontmatter with platform compatibility info
  - Checklist format executable by any AI assistant
  - Pass criteria with severity levels (P0-P3)

- **Platform Adapter System** (`.tad/adapters/`)
  - `adapter-schema.yaml` - Adapter interface contract
  - `platform-codes.yaml` - Platform definitions and detection
  - Platform-specific adapters for Claude, Codex, and Gemini

- **Multi-Platform Installation Script** (`tad.sh` v2.1)
  - Auto-detection of installed AI CLI tools
  - Automatic generation of platform-specific configs
  - `AGENTS.md` generation for Codex CLI
  - `GEMINI.md` generation for Gemini CLI
  - TOML command conversion for Gemini
  - Automatic rollback on failure

- **Command Conversion Templates**
  - `.tad/templates/command-converters/to-codex.template`
  - `.tad/templates/command-converters/to-gemini.template`

- **New Configuration**
  - `multi_platform` section in `.tad/config.yaml`
  - Platform-specific skill execution modes

### Changed

- Installation script now detects and configures multiple platforms
- Skills now have YAML frontmatter for platform compatibility
- Evidence directory structure supports multi-platform reviews

### Research Findings

- Codex CLI has native SKILL.md support (similar to TAD skills design)
- Codex CLI uses TOML for config (not JSON as initially assumed)
- Gemini CLI uses JSON settings + TOML commands
- Both support hierarchical instruction loading

### Backward Compatibility

- Existing Claude Code users: No changes required
- All `.claude/` configurations preserved
- subagent calls unchanged for Claude Code

### Documentation

- Platform research evidence: `.tad/evidence/reviews/20260126-phase0-research-validation.md`
- Skills README: `.tad/skills/README.md`

---

## [2.0.0] - 2026-01-26

### Added

- **Ralph Loop Integration**: Iterative quality mechanism with expert-driven exit conditions
  - Layer 1: Self-check (build, test, lint, tsc) with circuit breaker
  - Layer 2: Expert review with priority groups
  - State persistence for crash recovery
  - Automatic escalation to human/Alex when stuck

- **New Configuration Files**
  - `.tad/ralph-config/loop-config.yaml` - Ralph Loop configuration
  - `.tad/ralph-config/expert-criteria.yaml` - Expert pass conditions
  - `.tad/schemas/loop-config.schema.json` - Schema validation
  - `.tad/schemas/expert-criteria.schema.json` - Schema validation

- **New Blake Commands**
  - `*develop [task-id]` - Start Ralph Loop development cycle
  - `*ralph-status` - Show current Ralph Loop state
  - `*ralph-resume` - Resume from last checkpoint
  - `*ralph-reset` - Reset loop state
  - `*layer1` - Run Layer 1 self-check only
  - `*layer2` - Run Layer 2 expert review only

- **New Evidence Directories**
  - `.tad/evidence/ralph-loops/` - Ralph Loop state and summaries
  - `.tad/evidence/reviews/_iterations/` - Iteration-specific evidence

- **Documentation**
  - `docs/RALPH-LOOP.md` - Ralph Loop documentation
  - `docs/MIGRATION-v2.md` - Migration guide

### Changed

- **Gate 3 v2 (Expanded)**: Now includes all technical quality checks
  - Layer 1 self-check verification
  - Layer 2 expert review verification
  - Evidence file verification
  - Knowledge Assessment
  - Owned entirely by Blake

- **Gate 4 v2 (Simplified)**: Now pure business acceptance
  - Business requirement verification
  - Human approval
  - Archive handoff
  - No technical review (moved to Gate 3 v2)
  - Owned by Alex

- **Gate Responsibility Matrix**: Clear separation of technical (Blake) vs business (Alex) experts

### Deprecated

- `*implement` command in Blake (use `*develop` instead)

### Migration

See `docs/MIGRATION-v2.md` for detailed migration instructions.

---

## [1.8.0] - 2026-01-25

### Added

- Human-in-the-Loop Excellence
- Terminal isolation rules for Alex and Blake
- Enhanced handoff creation protocol

---

## [1.6.0] - 2026-01-24

### Added

- Unified install/upgrade script
- Improved sync capabilities

---

## [1.5.1] - 2026-01-23

### Fixed

- Sync improvements from menu-snap project

---

## [1.5.0] - 2026-01-22

### Added

- Project knowledge trigger integration
- Knowledge bootstrap workflow

---

## [1.1.0] - 2026-01-15

### Added

- TAD Framework initial release
- Alex (Solution Lead) agent
- Blake (Execution Master) agent
- 4-gate quality system
- Handoff-based workflow

## [2.10.1] - 2026-05-04

### New Features
- GitHub Awesome-List Registry: 24 domains, 50 curated awesome-lists (.tad/github-registry/)
- `*research-github` SKILL with 8 commands: list, search, add, explore, notebook, refresh, scan, scan-log
- Alex step2c_github: auto-checks GitHub Registry during *analyze, offers research before design
- Notebook auto-refresh: sources refreshed before query (30s timeout, max 5 sources)
- Research priority rule: fresh research overrides stale Domain Pack criteria (with feedback log)
- Weekly scan automation: scan-log.yaml + STEP 3.9 SessionStart report + scheduled routine docs
- domain-pack-feedback.yaml: records research/DomainPack conflicts for *evolve processing

### Architecture
- Three-layer knowledge model: Registry (discovery) → Notebook (understanding) → Domain Pack (standards)
- Cross-registry sync contract: github-registry ↔ research-notebooks REGISTRY consistency
- Single-writer principle: scan routine only writes scan-log, REGISTRY updated only on consumption

## v2.23.0 — Knowledge Lifecycle System + Code Intelligence (2026-06-02)

### New Features
- **Knowledge Lifecycle System** (TAD's 4th core subsystem) — 3-phase Epic:
  - Sense: Alex STEP 3.5 detects knowledge health (flat structure, bloated files)
  - Organize: 116 entries migrated to principles(13)/patterns(75)/incidents(25)
  - Maintain: Gate 4 KA auto-classify + *dream graduation(≥2) + 90-day expiration + L1 Epic protection
- **codebase-memory-mcp integration** — persistent code graph as graph→LSP→grep three-tier fallback
- **knowledge-blame.sh** — in-session rule provenance tool (git blame wrapper for project-knowledge)

### Improvements
- CLAUDE.md @import now loads principles.md (~3KB) instead of architecture.md (~40KB) — ~90% token reduction
- Blake 1_5_context_refresh uses patterns/_index.md matching (on-demand loading)
- tad.sh prints install hint for codebase-memory-mcp (v0.7.0, non-executing)

### Ideas Captured
- GitAgent Protocol (GAP) export for cross-platform portability
- DiffMem git-blame tool (promoted + delivered as knowledge-blame.sh)
