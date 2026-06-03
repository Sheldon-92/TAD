# Epic: Dynamic Workflow Integration

**Created:** 2026-06-03
**Objective:** Evolve TAD from static prompt-based orchestration to dynamic workflow-based orchestration. SKILL.md keeps judgment rules (WHAT to do); orchestration logic (HOW to do) moves to deterministic JS workflow scripts.
**Success Criteria:** TAD daily operations (Gate review, design decisions, Epic execution) use saved workflows; measurable quality improvement over single-agent approach.
**Source:** Thariq article "A harness for every task" (2026-06-03) + 3 validation experiments (23 agents, ~1.2M tokens)

---

## Phase Map

| Phase | Name | Status | Handoff |
|-------|------|--------|---------|
| P0 | Workflow Infrastructure: Save First Reusable Workflow | Done | epic-audit.workflow.js verified |
| P1 | Gate Review: Rule Adherence Pattern | Done | gate-review.workflow.js verified (9 AC, 12 agents, PASS) |
| P2 | Design: Tournament Pattern | Done | tournament-design.workflow.js (389 lines, commit 2292e04, Gate 4 PASS) |
| P3 | YOLO: Budget-Aware Workflow Execution | Done | yolo-epic.workflow.js (419 lines, commit c8f7e97, Gate 4 PASS, SKILL.md -211 lines) |
| P4 | Cross-Platform: Dual Adapter (Claude Code + Codex) | Done | detect-platform.sh + tournament-codex.sh (commit 3cbee48, Gate 4 PASS) |
| P5 | Loop-Discover: Loop Until Done + /loop Integration | Done | loop-discover.workflow.js (147 lines, commits c683ce6+1d27392, Gate 4 PASS) |

---

## Phase Details

### Phase 0: Workflow Infrastructure — Save First Reusable Workflow

**Status:** Planned
**Scope:** Take the Epic audit workflow (validated 2026-06-03, 7 agents, fan-out + adversarial + synthesis) and save it as TAD's first persistent .workflow.js in `.claude/workflows/`. Verify it can be re-invoked, parameterized, and shared via *sync.

NOT in scope: designing new workflows. This phase is purely about proving the save/load/share infrastructure works.

**Input:** Today's epic-audit-experiment workflow script (session transcript)
**Output:** `.claude/workflows/epic-audit.workflow.js` + verified re-run + documentation

**AC:**
- [ ] `.claude/workflows/epic-audit.workflow.js` exists and can be invoked via `Workflow({name: 'epic-audit'})`
- [ ] Workflow accepts `args` parameter for custom Epic paths (not hardcoded to today's 3 epics)
- [ ] Re-run produces consistent structured output (EPIC_SCHEMA + CHALLENGE_SCHEMA + SYNTHESIS_SCHEMA)
- [ ] Workflow saved in a location that *sync distributes to downstream projects
- [ ] Documentation: add "Dynamic Workflows" section to INSTALLATION_GUIDE.md or a guide file

**Files Likely Affected:**
- CREATE `.claude/workflows/epic-audit.workflow.js`
- MODIFY `.tad/hooks/lib/derive-sync-set.sh` (add `.claude/workflows/` to sync set if not already)
- CREATE `.tad/guides/dynamic-workflows.md` (usage guide)

**Dependencies:** None (P0 is the foundation)

---

### Phase 1: Gate Review — Rule Adherence Pattern

**Status:** Planned
**Scope:** Replace the current single-context serial Gate 3 Layer 2 expert review with a workflow-based per-AC verifier + skeptic pattern. Each AC gets its own verifier agent in a clean context; flagged violations go to a skeptic agent that filters false positives.

NOT in scope: changing Gate 3 Layer 1 (build/test/lint) or Gate 4 (business acceptance). Only Layer 2 expert review changes.

**Input:** Current blake/SKILL.md Layer 2 expert review protocol + 2 measured false-negative incidents (scoring-rubrics, section-9-1-region-marker)
**Output:** `.claude/workflows/gate-review.workflow.js` + Blake SKILL.md integration

**AC:**
- [ ] Workflow splits handoff ACs into individual verifier agents (one per AC or per AC group)
- [ ] Each verifier gets only: the AC text, the relevant source file(s), and the completion report section — NOT the full handoff context
- [ ] Skeptic agent receives all flagged violations and outputs only confirmed ones
- [ ] On handoffs with 10+ ACs: workflow mode auto-activates. On < 10 ACs: existing serial review (no overhead for small handoffs)
- [ ] Measured: false-negative rate compared to baseline (2 incidents across 22 reviews)
- [ ] Blake SKILL.md updated to invoke workflow when available, fallback to serial review when not

**Files Likely Affected:**
- CREATE `.claude/workflows/gate-review.workflow.js`
- MODIFY `.claude/skills/blake/SKILL.md` (Layer 2 section: add workflow invocation path)

**Dependencies:** P0 (workflow infrastructure must be validated first)

---

### Phase 2: Design — Tournament Pattern

**Status:** Planned
**Scope:** Add Tournament as a standard *design option. When Alex enters *design for important decisions, offer "tournament mode" where 3 agents each design from different prior art, pairwise judges evaluate, and a synthesizer merges the best ideas from all designs.

NOT in scope: replacing ALL *design flows. Tournament is an option for important/ambiguous design decisions, not every task.

**Input:** Today's tournament experiment (declarative constraints, 7 agents, winner + merged design 30% richer than single agent)
**Output:** `.claude/workflows/tournament-design.workflow.js` + Alex SKILL.md integration at *design step

**AC:**
- [ ] Workflow accepts `{ task_description, prior_art_sources: [...], rubric: {...} }` as args
- [ ] Spawns N competitors (default 3), each reads a different prior art source
- [ ] Pairwise judging with rubric scores (cross-platform compat, expressiveness, migration cost, principle alignment — or custom rubric)
- [ ] Synthesizer produces merged design: winner as base + best ideas grafted from losers
- [ ] Alex SKILL.md updated: adaptive_complexity_protocol offers tournament for "full" depth tasks
- [ ] Human can override: decline tournament and go single-agent (Alex SUGGESTS, human DECIDES)

**Files Likely Affected:**
- CREATE `.claude/workflows/tournament-design.workflow.js`
- MODIFY `.claude/skills/alex/SKILL.md` (design_protocol: add tournament option)

**Dependencies:** P0 (workflow infrastructure)

---

### Phase 3: YOLO — Budget-Aware Workflow Execution

**Status:** Planned
**Scope:** Convert YOLO execution protocol from SKILL.md prose into a workflow script with token budget observation and human checkpoints. Currently YOLO is a ~200-line text protocol in alex/SKILL.md that the LLM follows step-by-step; it should be a deterministic JS workflow with `budget.remaining()` awareness.

NOT in scope: changing YOLO's logic (phases, review counts, gate criteria). Only the execution mechanism changes from prompt-following to workflow-scripting.

**Input:** Current alex/SKILL.md `yolo_execution_protocol` section + 14 YOLO gate reports (5 completed Epics) + zero token cost data (blind spot confirmed)
**Output:** `.claude/workflows/yolo-epic.workflow.js` + alex/SKILL.md simplified to invoke workflow

**AC:**
- [ ] Workflow implements the full YOLO cycle: Y1(activate) → Y2(ground) → Y3(design) → Y3b(validate) → Y4(design review) → Y5(implement) → Y6(impl review) → Y7(gate) → Y8(KA)
- [ ] Each step produces evidence files on disk (same paths as current protocol)
- [ ] `budget.remaining()` checked at each phase boundary; human gets cost report at step_Y_pause
- [ ] Human can choose: continue full / continue lean (1 reviewer) / pause / honest_partial exit
- [ ] YOLO section in alex/SKILL.md reduced from ~200 lines to ~20 lines (invoke workflow + judgment rules)
- [ ] Backward compat: if Workflow tool unavailable, Alex falls back to existing prompt-based YOLO

**Files Likely Affected:**
- CREATE `.claude/workflows/yolo-epic.workflow.js`
- MODIFY `.claude/skills/alex/SKILL.md` (yolo_execution_protocol: replace with workflow invocation + judgment)

**Dependencies:** P0 (workflow infrastructure), P1 preferred (gate-review workflow can be called FROM yolo workflow)

---

### Phase 4: Cross-Platform — Dual Adapter (Claude Code + Codex)

**Status:** Planned
**Scope:** Design an adapter layer that translates TAD's judgment rules into platform-specific orchestration. Claude Code uses .workflow.js; Codex uses TOML agent definitions + MCP server. Same WHAT (judgment), different HOW (orchestration).

NOT in scope: full Codex implementation. P4 designs the adapter interface and creates a PoC for one workflow (e.g., gate-review) running on both platforms.

**Input:** P1-P3 workflow scripts + Codex subagent docs (https://developers.openai.com/codex/subagents) + Codex Agents SDK (https://developers.openai.com/codex/guides/agents-sdk)
**Output:** Adapter interface design + one PoC workflow running on both Claude Code and Codex

**AC:**
- [ ] Adapter interface defined: `{ judgmentRules: SKILL.md, orchestration: platform-specific }`
- [ ] gate-review workflow runs on Claude Code (via .workflow.js) AND Codex (via TOML agents + MCP)
- [ ] Same judgment criteria produces comparable results on both platforms
- [ ] Runtime detection: TAD detects which platform is available and selects adapter
- [ ] Degradation documented: Tier 1a (Claude workflow) / Tier 1b (Codex agents) / Tier 2 (Agent tool) / Tier 3 (single context)

**Files Likely Affected:**
- CREATE `.tad/adapters/` directory with platform-specific orchestration
- MODIFY `.claude/skills/alex/SKILL.md` and `blake/SKILL.md` (runtime detection)
- MODIFY `.tad/config-platform.yaml` (orchestration capability tiers)

**Dependencies:** P1 + P2 + P3 (need actual workflows to adapt)

---

## Context for Next Phase

Today's session (2026-06-03) validated:
- Epic audit: 7 agents, fan-out + adversarial + synthesis, found real blind spots in all 3 analyst reports
- Deep research: 9 agents, pattern research + challenger + synthesis, produced actionable roadmap
- Tournament: 7 agents, 3 competitors + 3 judges + merger, produced design 30% richer than single-agent

Evidence: `.tad/evidence/research/2026-06-03-dynamic-workflows-thariq.md` (article), `2026-06-03-workflow-pattern-measurement.md` (baseline data), `2026-06-03-tournament-declarative-constraints-result.md` (tournament output)

The declarative-constraints handoff (HANDOFF-20260603-declarative-constraints-v01.md) is a parallel workstream, NOT a Phase of this Epic. It was a tournament experiment side-product.
