---
task_type: code
e2e_required: no
research_required: yes
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: Capability Pack — Research Methodology
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-05-08
**Project:** TAD Framework
**Task ID:** TASK-20260508-001
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260507-agent-capability-packs.md

---

## 1. Task Overview

Build a **Research Methodology Capability Pack** — a single, portable SKILL that gives AI agents the judgment and orchestration logic to execute complete research workflows autonomously, with human checkpoints at critical decision points.

**Core problem:** Research logic is currently scattered across 3 separate SKILLs (research-notebook 14 commands, research-github 6 commands, Alex research-plan protocol), causing agents to lose context mid-workflow, skip steps, choose wrong tools, and produce inconsistent quality output.

**Solution:** One unified orchestration pack with state-tracking, saturation detection, anti-hallucination guards, and PIVOT/REFINE decision logic. The pack wraps NotebookLM CLI as its execution engine but owns all workflow decisions.

---

## 2. Business Context

**Why now:** 4 capability packs shipped (web-ui-design, product-thinking, web-backend, ai-agent-architecture), 2 in progress (ai-prompt-engineering, web-frontend). Research methodology is the meta-capability that improves the quality of ALL future pack creation and project research.

**Success when:** User says "研究 X" → agent autonomously executes Plan→Source→Curate→Analyze→Output, asking human at 3 gate checkpoints, producing a QCE report + extracted ACs. No manual intervention needed between gates.

---

## 3. Requirements

### Functional Requirements

**FR1 — Unified Entry Point:** Single CAPABILITY.md replaces the need to know 3 separate SKILLs. Agent reads one file and knows the full pipeline.

**FR2 — 5-Phase Pipeline with State Tracking:**
- Phase 1: PLAN — Decompose research question into sub-queries (problem tree), define source strategy, set success criteria
- Phase 2: SOURCE — Execute GitHub-First sourcing (awesome-lists → company repos → tool repos → docs → articles), add to NotebookLM notebook
- Phase 3: CURATE — Clean errors, deduplicate, tier sources (T1/T2/T3), validate quality threshold
- Phase 4: ANALYZE — Baseline report → multi-round ask loop with CRAG gap detection → PIVOT/REFINE decision
- Phase 5: OUTPUT — QCE structured report + extracted AC list

**FR3 — Human Gates (3 checkpoints):**
- Gate H1: After PLAN — user approves question tree + source strategy
- Gate H2: After CURATE — user reviews source quality distribution (T1/T2/T3 ratio)
- Gate H3: After OUTPUT — user reviews final deliverables

**FR4 — Saturation Detection (CR-P0-4 + BA-P1-4 fix: algorithm fully specified):**
Track "new finding rate" across ask rounds. Algorithm:
- **Finding unit**: one `### Claim:` block in ask output = one finding. A finding is "new" if no prior round's claim list contains a semantically equivalent statement (LLM judgment with explicit prompt: "Is this claim covered by any of the following prior claims?")
- **Counting**: after each ask round, LLM extracts claims → compares against cumulative claim list → counts net new claims → appends count to `new_findings_per_round[]` array
- **Stop condition**: rate = 0 for ≥2 consecutive rounds AND total findings ≥3 (minimum threshold prevents premature stop on bad first questions)
- **Secondary signal**: if rate drops to ≤1 for ≥3 consecutive rounds, present user with AskUserQuestion: "研究收敛中 — 继续还是进入 OUTPUT？"
- **`saturation-check.sh` role**: mechanical check on the `new_findings_per_round` array (reads from research-state.yaml). Outputs `SATURATED`, `DIMINISHING`, or `CONTINUE`. LLM does the semantic novelty judgment; script does the numerical pattern check

**FR5 — PIVOT/REFINE Decision:**
At ANALYZE phase, when gap signals persist after enrichment:
- REFINE: same angle, add more sources (default)
- PIVOT: change research angle entirely (user approval required)
Record decision in dead-end registry to prevent repeating failed paths.

**FR6 — Anti-Hallucination Guards:**
- Layer 1: URL existence check (NotebookLM source add already validates)
- Layer 2: Claim-to-source traceability (NotebookLM citations provide natively)
- Layer 3: QCE output structure requiring explicit evidence per claim + contradictory evidence section
- Layer 4: Dead-end registry prevents citing previously-refuted findings

**FR7 — QCE Output Structure:**
```
## Question: {research question}
### Claim 1: {analytical statement — arguable, not descriptive}
**Evidence:** {citations from notebook sources}
**Contradictory evidence:** {what sources disagree and why}
**Confidence:** {high/medium/low based on source count + tier}
### Claim 2: ...
## Extracted ACs
- AC1: {concrete acceptance criterion derived from findings}
- AC2: ...
```

**FR8 — Dead-End Registry (CR-P0-5 + BA-P1-2 fix: schema + TTL + override):**
`.research/dead-ends.yaml` per project. Schema:
```yaml
dead_ends:
  - id: "DE-001"
    question: "What tools exist for automated grounded theory coding?"
    scope: "exact"          # exact | fuzzy (exact = blocks only identical question; fuzzy = blocks semantically similar)
    reason: "No CLI tools found; all solutions are GUI-only SaaS — not usable in agent context"
    contradicting_evidence: "ASReview exists but is active-learning for screening, not grounded theory coding"
    recorded_at: "2026-05-08"
    session_id: "RS-20260508-001"
    ttl_days: 90            # entry expires after 90 days (research landscape changes)
    overridable: true       # user can force the question through with explicit confirmation
```
- PLAN phase checks: for each question in proposed tree, scan dead-ends with matching scope. If match found AND not expired AND overridable=true → AskUserQuestion "此问题曾标记为死胡同: {reason}。要继续吗？"
- Entries added at: PIVOT decision (the abandoned angle) AND OUTPUT phase (any claim with confidence=low and zero supporting evidence)

**FR9 — NotebookLM Unavailability Fallback (BA-P0-1 fix):**
CAPABILITY.md Step 0 must include preflight check (`test -x ~/.tad-notebooklm-venv/bin/notebooklm`).
- If PASS → normal pipeline (all 5 phases + 4-layer anti-hallucination)
- If FAIL → degraded mode:
  - Phase 1 PLAN: ✅ runs normally (no CLI dependency)
  - Phase 2 SOURCE: WebSearch fallback (3+ queries per question, save results in context)
  - Phase 3 CURATE: N/A (no notebook to curate)
  - Phase 4 ANALYZE: WebSearch-in-context synthesis (no cross-source NotebookLM ask)
  - Phase 5 OUTPUT: ✅ QCE structure still applies
  - Anti-hallucination degradation: Layer 1 → WebFetch URL + HTTP 200 check; Layer 2 → agent must include exact quote from source (not paraphrased); Layers 3-4 unchanged
  - All 3 human gates still apply in degraded mode
  - Error message: "⚠️ NotebookLM not available. Running in degraded mode (WebSearch only). For full capability: bash .tad/cross-model/setup-notebooklm.sh"

**FR10 — Crash Recovery (BA-P0-2 fix):**
CAPABILITY.md Step 0 (before Phase 1) must check for existing `.research/research-state.yaml`:
- If not found → fresh session, proceed to Phase 1
- If found with `phase != complete`:
  - Stale check: if `updated` timestamp > 7 days ago → AskUserQuestion "发现 7 天前的未完成研究 '{topic}'。恢复还是重新开始？"
  - Notebook validation: verify `notebook_id` still exists via `notebooklm source list -n <id>` (if NotebookLM available)
  - If notebook missing → warn, allow restart without notebook
  - Resume protocol: read state file → announce "恢复研究: '{topic}', 当前阶段: {phase}" → enter that phase
- If found with `phase == complete` → archive to `.research/sessions/` and start fresh

**FR11 — Concurrent Session Guard (BA-P0-3 fix):**
When user says "研究 X" and `.research/research-state.yaml` exists with `phase != complete`:
- AskUserQuestion: "已有进行中的研究 '{existing_topic}'。怎么处理？"
  - "恢复现有研究" → resume per FR10
  - "归档并开始新研究" → move state to `.research/sessions/{session_id}/` → start fresh
  - "取消" → return to standby

**FR12 — PIVOT/REFINE Concrete Triggers (BA-P1-1 fix):**
Decision tree with measurable conditions:
- **REFINE trigger**: ask round returns ≥1 new finding BUT answer contains explicit gap signal ("sources do not contain", "not mentioned in the provided sources") → add targeted sources → re-ask same question
- **PIVOT trigger**: 2 consecutive REFINE attempts produce 0 net new sources AND gap persists AND question has been active for ≥3 rounds → AskUserQuestion "这个角度连续 2 次补源失败。换方向还是接受现有结果？" Options: "换方向 (PIVOT)" / "接受现有结果"
- Max REFINE per question: 3 (prevent infinite enrichment loop)
- On PIVOT: record abandoned angle in dead-end registry (FR8) before switching

### Non-Functional Requirements

**NFR1 — Relationship to existing SKILLs (BA-P0-4 fix: routing + deprecation plan):**
Pack is the **orchestration layer**. It calls NotebookLM CLI commands directly (using absolute paths from tool-quick-reference-alex.md). After pack installation:
- **Routing priority**: Pack's Step 0 keyword list is a strict superset of research-notebook's. When CLAUDE.md research routing triggers, pack takes priority.
- **Deprecation plan**: After pack ships and is validated in ≥1 real project:
  1. Add `# DEPRECATED: use /research-methodology pack instead` header to research-notebook and research-github SKILLs
  2. Modify Alex SKILL research_plan_protocol (A7) to delegate to the pack's CAPABILITY.md instead of inline CLI calls
  3. Existing SKILLs remain for direct `*research-notebook ask` invocations (backward compat) but are no longer the recommended entry point
- **Single source of truth for CLI paths**: Pack references `tool-quick-reference-alex.md` for all CLI paths. If notebooklm upgrades, update tool-quick-reference only (not pack AND old SKILLs).

**NFR4 — .gitignore (CR-P1-6 fix):** install.sh must append `.research/` to project `.gitignore` if not already present. Session state and dead-end registry should not be committed.

**NFR5 — Script I/O Contracts (BA-P1-5 fix):**
- `saturation-check.sh`: INPUT = path to `research-state.yaml` (reads `analyze.new_findings_per_round` array). OUTPUT = stdout one of `SATURATED` / `DIMINISHING` / `CONTINUE` followed by space + latest count. Exit 0 always (status in stdout, not exit code).
- `source-quality.sh`: INPUT = path to `research-state.yaml` (reads `curate.tier1_count`, `tier2_count`, `tier3_count`). OUTPUT = stdout `PASS` or `FAIL` + space + T1 ratio as decimal. Exit 0 when T1 ratio ≥ 0.30, exit 1 otherwise.

**NFR6 — Session Budget Guardrails (CR-P1-5 fix):**
To prevent cost/resource overruns in autonomous mode:
- Max ask rounds per session: 10 (after 10, force human confirmation to continue)
- Max sources per notebook: 100 (after 100, warn and require human approval to add more)
- These are defaults in CAPABILITY.md, not hardcoded — user can override via AskUserQuestion

**NFR2 — Portability:** Same structure as other capability packs. `install.sh --agent=claude-code` installs to `.claude/skills/`. Phase 3 stubs for codex/cursor/gemini. Flag uses `--agent=VALUE` (equals-sign, single arg) per existing pack convention.

**NFR3 — State file location:** `.research/` directory at project root (created by pack on first use). Contains `research-state.yaml` (current session) + `sessions/` (archived sessions) + `dead-ends.yaml`.

---

## 4. Technical Design

### Architecture: State-Tracking Orchestrator (Orchestra + AutoResearchClaw hybrid)

```
User: "研究 X"
  ↓
CAPABILITY.md loaded by agent
  ↓
[Phase 1: PLAN] ← research-state.yaml: phase=plan
  Question decomposition (problem tree)
  Source strategy selection
  Success criteria definition
  → GATE H1: User approves plan
  ↓
[Phase 2: SOURCE] ← research-state.yaml: phase=source
  GitHub-First sourcing (awesome-lists → repos → docs)
  NotebookLM source add (CLI calls)
  → No gate (automated)
  ↓
[Phase 3: CURATE] ← research-state.yaml: phase=curate
  Error cleanup + dedup + tier scoring
  Quality threshold check (≥30% T1 sources)
  → GATE H2: User reviews source quality
  ↓
[Phase 4: ANALYZE] ← research-state.yaml: phase=analyze
  Baseline report (summary --topics)
  Ask loop (question tree → sequential asks)
  Saturation detection (new_findings_rate tracking)
  CRAG gap detection → REFINE or PIVOT
  → No gate (automated, but PIVOT requires user confirmation)
  ↓
[Phase 5: OUTPUT] ← research-state.yaml: phase=output
  QCE report generation
  AC extraction
  Dead-end registry update
  → GATE H3: User reviews deliverables
```

### State File: research-state.yaml
```yaml
session_id: "RS-20260508-001"
topic: "Research Methodology for AI Agents"
phase: "analyze"  # plan | source | curate | analyze | output | complete
notebook_id: "81af517d-..."
created: "2026-05-08T00:00:00Z"
updated: "2026-05-08T01:30:00Z"

plan:
  question_tree:
    - q1: "How do competitor frameworks decompose research questions?"
      sub_queries: [...]
  source_strategy: "github-first"
  success_criteria: "能回答完整决策树"
  gate_h1: approved

source:
  total_added: 22
  errors_cleaned: 2
  sources_healthy: 20

curate:
  tier1_count: 8
  tier2_count: 9
  tier3_count: 3
  tier1_ratio: 0.40
  gate_h2: approved

analyze:
  ask_rounds: 5
  new_findings_per_round: [12, 8, 6, 4, 1]  # saturation trending
  saturation_reached: false
  pivots: []
  refines: [{round: 3, reason: "gap in anti-hallucination details"}]

output:
  qce_report_path: ".research/sessions/RS-20260508-001/report.md"
  extracted_acs_path: ".research/sessions/RS-20260508-001/acs.md"
  gate_h3: pending
```

### Pack Directory Structure
```
~/research-methodology/
├── CAPABILITY.md           # Main orchestration SKILL (YAML frontmatter + full pipeline)
├── CONVENTIONS.md          # Research methodology conventions + decision heuristics
├── references/
│   ├── planning.md         # Question decomposition patterns, problem tree format
│   ├── sourcing.md         # GitHub-First strategy, source type priority matrix
│   ├── quality-control.md  # Tier criteria, saturation signals, anti-hallucination
│   ├── analysis.md         # Ask loop patterns, PIVOT/REFINE decision, CRAG
│   └── output.md           # QCE format spec, AC extraction rules
├── checklists/
│   └── research-quality.md # Per-session quality checklist (pre-output review)
├── scripts/
│   ├── saturation-check.sh # Parse ask findings, compute new-finding rate
│   └── source-quality.sh   # Tier classification + T1 ratio check
├── install.sh              # Multi-agent installer (--agent claude/codex/cursor/gemini)
├── README.md
├── LICENSE
├── LICENSE-ATTRIBUTION.md
└── CHANGELOG.md
```

---

## 5. Research Evidence

Research conducted 2026-05-07/08 via NotebookLM notebook `81af517d` (20 sources, 5 ask rounds).

Key findings driving design:
1. **Orchestra AI-Research-SKILLs**: two-loop architecture (inner optimization + outer synthesis) with research-state.yaml state tracking — directly inspired our Phase 4 ANALYZE design
2. **AutoResearchClaw**: 23-stage pipeline with Gate Stages + PIVOT/REFINE Loop — inspired our 3-gate + PIVOT decision
3. **Theoretical saturation (Grounded Theory)**: zero new codes = programmatic stop signal — inspired FR4
4. **PRISMA-trAIce**: screening automatable, verification requires human — informed gate placement
5. **Orchestra ARA dead-end registry**: prevents repeating failed paths — inspired FR8

Full findings: `.tad/evidence/research/research-methodology-capability-pack/2026-05-07-ask-findings.md`

---

## 6. Files to Create

| # | Path | Purpose |
|---|------|---------|
| 1 | `~/research-methodology/CAPABILITY.md` | Main SKILL (~200-250 lines) — orchestration router + Step 0 + phase transitions. Phase-specific logic lives in references/*.md (loaded on demand) |
| 2 | `~/research-methodology/CONVENTIONS.md` | Research conventions + decision heuristics (~200 lines) |
| 3 | `~/research-methodology/references/planning.md` | Question decomposition + problem tree + success criteria |
| 4 | `~/research-methodology/references/sourcing.md` | GitHub-First strategy + source type priority matrix |
| 5 | `~/research-methodology/references/quality-control.md` | Tier criteria + saturation + anti-hallucination |
| 6 | `~/research-methodology/references/analysis.md` | Ask loop + CRAG + PIVOT/REFINE decision tree |
| 7 | `~/research-methodology/references/output.md` | QCE format spec + AC extraction rules |
| 8 | `~/research-methodology/checklists/research-quality.md` | Per-session quality checklist |
| 9 | `~/research-methodology/scripts/saturation-check.sh` | Compute new-finding rate from ask outputs |
| 10 | `~/research-methodology/scripts/source-quality.sh` | Tier classification + T1 ratio validation |
| 11 | `~/research-methodology/install.sh` | Multi-agent installer |
| 12 | `~/research-methodology/README.md` | Pack overview + quick start |
| 13 | `~/research-methodology/LICENSE` | Apache 2.0 |
| 14 | `~/research-methodology/LICENSE-ATTRIBUTION.md` | Source credits |
| 15 | `~/research-methodology/CHANGELOG.md` | Version history |

---

## 7. Acceptance Criteria

### Core Functionality
- [ ] **AC1**: CAPABILITY.md has YAML frontmatter with `name` + `description` fields (Claude Code SKILL loader requirement)
- [ ] **AC2**: CAPABILITY.md implements all 5 phases (PLAN/SOURCE/CURATE/ANALYZE/OUTPUT) with explicit state transitions
- [ ] **AC3**: research-state.yaml schema tracks phase, notebook_id, question_tree, source counts, tier ratios, ask rounds, saturation metrics
- [ ] **AC4**: 3 human gates implemented — H1 (plan approval), H2 (source quality), H3 (output review) — each uses AskUserQuestion
- [ ] **AC5**: Saturation detection: CAPABILITY.md defines algorithm for tracking new-finding rate and auto-stop when rate = 0 for ≥2 consecutive rounds
- [ ] **AC6**: PIVOT/REFINE decision tree documented in references/analysis.md with explicit signals for each path
- [ ] **AC7**: QCE output format specified in references/output.md with Question → Claim (arguable) → Evidence (cited) → Contradictory Evidence → Confidence structure
- [ ] **AC8**: Dead-end registry (`.research/dead-ends.yaml`) schema defined + PLAN phase checks it before finalizing question tree

### Quality & Anti-Hallucination
- [ ] **AC9**: Anti-hallucination: 4 layers documented (URL check + citation traceability + QCE structure + dead-end registry)
- [ ] **AC10**: Source quality tiering criteria defined in references/quality-control.md with T1/T2/T3 URL patterns
- [ ] **AC11**: `scripts/source-quality.sh` exits 0 when T1 ratio ≥ 0.30, exits 1 otherwise
- [ ] **AC12**: `scripts/saturation-check.sh` accepts ask-findings file path, outputs `SATURATED` or `CONTINUE` with new-finding count

### Portability
- [ ] **AC13**: `install.sh --agent=claude-code` copies CAPABILITY.md to `.claude/skills/research-methodology/SKILL.md` and references to appropriate location
- [ ] **AC14**: `install.sh --agent=codex` exits 2 with "not yet implemented" message (same for cursor, gemini)
- [ ] **AC15**: README.md includes Quick Start section with usage examples

### Existing SKILL Relationship
- [ ] **AC16**: CAPABILITY.md Step 0 (Context Detection) includes explicit routing: keyword list is strict superset of research-notebook SKILL keywords
- [ ] **AC17**: All NotebookLM CLI calls use absolute path `~/.tad-notebooklm-venv/bin/notebooklm` (not bare `notebooklm`)

### Robustness (from expert review P0 fixes)
- [ ] **AC18**: CAPABILITY.md Step 0 includes NotebookLM preflight check + degraded mode announcement when unavailable (FR9)
- [ ] **AC19**: CAPABILITY.md Step 0 includes existing-state check with resume/stale-detection/notebook-validation (FR10)
- [ ] **AC20**: CAPABILITY.md handles concurrent session: existing active session detected → AskUserQuestion resume/archive/cancel (FR11)
- [ ] **AC21**: references/analysis.md contains PIVOT/REFINE decision tree with measurable trigger conditions (FR12: REFINE=gap+sources available, PIVOT=2 failed REFINEs+≥3 rounds, max 3 REFINEs per question)
- [ ] **AC22**: install.sh appends `.research/` to .gitignore if not present (NFR4)
- [ ] **AC23**: Dead-end registry schema in CAPABILITY.md matches FR8 spec (id, question, scope, reason, contradicting_evidence, recorded_at, session_id, ttl_days, overridable)

---

## 8. Important Notes

### 8.1 Key Design Decisions

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | Pack-to-SKILL relationship | Replace / Wrap / Parallel | **Wrap** | Pack is orchestration layer; calls NotebookLM CLI directly. Users invoke pack, not raw commands. Existing SKILLs remain for backward compat but are not the recommended entry point. |
| 2 | State tracking model | Event-driven / Agent-negotiation / State-tracking | **State-tracking** (Orchestra pattern) | Closest to TAD's existing session-state.md pattern. Simplest to implement. |
| 3 | Anti-hallucination depth | Minimal (QCE only) / Full (4-layer) | **Full 4-layer** | Research showed AutoResearchClaw added HITL specifically because hallucination was #1 failure mode |
| 4 | Output format | Summary / QCE / Flexible | **QCE** | Research showed QCE (analytical) >> summary (descriptive). Required contradictory evidence reporting. |
| 5 | Saturation algorithm | Time-based / Round-based / Rate-based | **Rate-based** | Theoretical saturation literature: "new code rate → 0" is the gold standard. 2 consecutive zero-rate rounds = stop. |

### 8.2 Anti-Patterns (Blake must avoid)
- ❌ Writing CAPABILITY.md as a command reference (it must be an orchestration router that loads references on demand)
- ❌ Putting all phase logic in CAPABILITY.md (>250 lines = you're building a monolith. Phase logic goes in references/*.md)
- ❌ Implementing saturation as simple round count (must track new-finding rate with LLM semantic novelty judgment)
- ❌ Skipping dead-end registry (this prevents the #2 failure mode: repeating failed research)
- ❌ Making gates optional (gates are the anti-hallucination safety net — AutoResearchClaw learned this the hard way)
- ❌ Assuming NotebookLM CLI always succeeds (must handle: auth expired, version <0.3.4, venv missing, rate limits)
- ❌ Using bare `notebooklm` command (must use absolute path `~/.tad-notebooklm-venv/bin/notebooklm`)
- ❌ Using `notebooklm use` in loops (must use `-n <id>` flag — stateless per-command override)

### 8.3 Reference Sources
- Research findings: `.tad/evidence/research/research-methodology-capability-pack/2026-05-07-ask-findings.md`
- Orchestra AI-Research-SKILLs: https://github.com/Orchestra-Research/AI-Research-SKILLs
- AutoResearchClaw: https://github.com/aiming-lab/AutoResearchClaw
- Existing pack examples: `~/product-thinking/` (3-skill deep design), `~/web-backend/` (reference-based)

---

## 📚 Project Knowledge

### ⚠️ Blake 必须注意的历史教训

| Entry | Source | Relevance |
|-------|--------|-----------|
| Capability Pack: YAML Frontmatter is Load-Bearing | architecture.md | CAPABILITY.md must have frontmatter or SKILL won't load |
| Capability Pack: Multi-Agent Install Pattern | architecture.md | install.sh needs --agent flag + Phase 3 stubs |
| Capability Pack: 3-Skill Deep Design vs Template Proliferation | architecture.md | Prefer deep skills with interaction contract over thin templates |
| Capability Pack Rule Sourcing: Read the Cited Source | architecture.md | Rules with [Source: X] must be verified by reading X, not from memory |
| Venv Absolute Path for AI-Invoked CLI Tools | architecture.md | NotebookLM CLI must use absolute path, not bare command |
| NotebookLM CLI State Management: -n Flag vs use Command | architecture.md | Use -n flag (stateless) not `use` (stateful) in loops |

---

## 9. Spec Compliance Checklist

### 9.1 Acceptance Criteria Verification

| AC# | Verification Method | Expected Evidence |
|-----|--------------------|--------------------|
| AC1 | `head -5 ~/research-methodology/CAPABILITY.md` | YAML frontmatter with name + description |
| AC2 | `grep -c 'Phase [1-5]' ~/research-methodology/CAPABILITY.md` | ≥ 5 |
| AC3 | Inspect research-state.yaml schema in CAPABILITY.md | All fields listed in §4 present |
| AC4 | `grep -c 'AskUserQuestion' ~/research-methodology/CAPABILITY.md` | ≥ 3 (one per gate) |
| AC5 | Inspect saturation detection section | Algorithm with "2 consecutive zero-rate rounds" |
| AC6 | `test -f ~/research-methodology/references/analysis.md` | File exists with PIVOT/REFINE section |
| AC7 | `test -f ~/research-methodology/references/output.md` | File exists with QCE format spec |
| AC8 | `grep -c 'dead-ends' ~/research-methodology/CAPABILITY.md` | ≥ 1 |
| AC9 | `grep -c 'Layer [1-4]' ~/research-methodology/references/quality-control.md` | ≥ 4 |
| AC10 | Inspect T1/T2/T3 patterns | URL pattern lists present |
| AC11 | `bash ~/research-methodology/scripts/source-quality.sh --help` | Usage info exits 0 |
| AC12 | `bash ~/research-methodology/scripts/saturation-check.sh --help` | Usage info exits 0 |
| AC13 | `bash ~/research-methodology/install.sh --agent=claude-code --dry-run` | Prints target paths, exits 0 |
| AC14 | `bash ~/research-methodology/install.sh --agent=codex` | Exits 2 with "not yet implemented" |
| AC15 | `grep -c 'Quick Start' ~/research-methodology/README.md` | ≥ 1 |
| AC16 | Inspect Step 0 in CAPABILITY.md | Research keyword routing present |
| AC17 | `grep -c 'tad-notebooklm-venv' ~/research-methodology/CAPABILITY.md` | ≥ 1 |

### 9.2 Expert Review Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | CR-P0-1/2: `--agent` flag naming + syntax | NFR2, AC13, AC14 — changed to `--agent=claude-code` | Resolved |
| code-reviewer | CR-P0-3: 700-line monolith CAPABILITY.md | §6 File #1 — changed to ~250 line router, references hold executable logic | Resolved |
| code-reviewer | CR-P0-4: Saturation algorithm underspecified | FR4 — added finding unit, counting method, minimum threshold, secondary signal, script role | Resolved |
| code-reviewer | CR-P0-5: Dead-end registry no schema | FR8 — added full YAML schema with TTL, scope, override | Resolved |
| backend-architect | BA-P0-1: No NotebookLM fallback | FR9 — added preflight + degraded mode per-phase spec + anti-hallucination degradation | Resolved |
| backend-architect | BA-P0-2: Crash recovery undefined | FR10 — added Step 0 state check, stale detection (7-day TTL), notebook validation, resume protocol | Resolved |
| backend-architect | BA-P0-3: Concurrent sessions missing | FR11 — added active session guard with resume/archive/cancel AskUserQuestion | Resolved |
| backend-architect | BA-P0-4: Dual-source-of-truth routing | NFR1 — added routing priority, deprecation plan (3-step), CLI path single-source via tool-quick-reference | Resolved |
| code-reviewer | CR-P1-3: Missing NotebookLM error handling | Covered by FR9 preflight + degraded mode | Resolved |
| code-reviewer | CR-P1-5: No cost/token budget | NFR6 — added max ask rounds (10), max sources (100) defaults | Resolved |
| code-reviewer | CR-P1-6: .research/ not in .gitignore | NFR4 — install.sh appends to .gitignore | Resolved |
| backend-architect | BA-P1-1: PIVOT/REFINE under-specified | FR12 — added concrete trigger conditions, max REFINE limit, PIVOT confirmation | Resolved |
| backend-architect | BA-P1-5: Script I/O undefined | NFR5 — added input/output contracts for both scripts | Resolved |

---

## 10. Micro-Tasks

| # | Task | Files | Est. Lines | Dependencies |
|---|------|-------|------------|-------------|
| MT1 | Scaffold directory + LICENSE + CHANGELOG | All boilerplate | ~50 | None |
| MT2 | Write CAPABILITY.md (orchestration router — Step 0 + phase transitions + state mgmt) | CAPABILITY.md | ~250 | MT1 |
| MT3 | Write references/planning.md | planning.md | ~150 | MT2 |
| MT4 | Write references/sourcing.md | sourcing.md | ~200 | MT2 |
| MT5 | Write references/quality-control.md | quality-control.md | ~200 | MT2 |
| MT6 | Write references/analysis.md | analysis.md | ~200 | MT2 |
| MT7 | Write references/output.md | output.md | ~150 | MT2 |
| MT8 | Write CONVENTIONS.md | CONVENTIONS.md | ~200 | MT2-MT7 |
| MT9 | Write checklists/research-quality.md | research-quality.md | ~100 | MT2 |
| MT10 | Write scripts/ (saturation + quality) | 2 scripts | ~150 | MT5 |
| MT11 | Write install.sh | install.sh | ~100 | MT2 |
| MT12 | Write README.md | README.md | ~100 | All above |

---

## 11. Decision Summary

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | Pack architecture | Replace 3 SKILLs / Wrap as orchestrator / Parallel | Wrap as orchestrator | User confirms main trigger is via Alex; root cause is scattered logic; wrapping unifies without breaking backward compat. Post-review (BA-P0-4): deprecation plan added — pack takes routing priority, old SKILLs marked deprecated after validation |
| 6 | CAPABILITY.md structure | 700-line monolith / Router+references | Router+references (~250 lines + 5 reference files) | CR-P0-3: monolith SKILL makes editing any single phase require touching a 700-line file. Router pattern (web-backend precedent) keeps CAPABILITY.md as orchestration + Step 0, references hold executable phase logic |
| 2 | State model | Event-driven / Agent-negotiation / State-tracking | State-tracking (research-state.yaml) | Orchestra uses identical pattern; closest to TAD session-state.md; simplest mental model |
| 3 | Scope | MVP (integrate only) / Full (all features) | Full | User chose "全部都要" — saturation + anti-hallucination + PIVOT + dead-end registry all in v1 |
| 4 | Output format | Summary / QCE / Flexible | QCE + extracted ACs | Research showed QCE > summary for analytical research; ACs bridge research→implementation |
| 5 | Human gates | 0 (full auto) / 3 (plan+curate+output) / 5 (every phase) | 3 gates | Balance: user wants semi-autonomous ("关键点问我"); AutoResearchClaw proved full-auto fails |
