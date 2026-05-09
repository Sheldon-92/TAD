# Research Methodology Capability Pack — Ask Findings
Date: 2026-05-07
Notebook: 81af517d (20 sources, 5 ask rounds)

## Round 1: Competitor Decision Logic

### Key Patterns Found

**1. Query Decomposition**
- AutoResearchClaw: LLM scoping phase → "structured problem tree with research questions"
- DeepResearchAgent: hierarchical top-level planning agent → specialized lower-level agents
- DeerFlow: lead agent "spawns sub-agents on the fly", each exploring different angle in parallel
- Orchestra: two-loop architecture (inner optimization + outer synthesis)

**2. Stopping Signals**
- DeerFlow: per-agent scoped termination conditions (each sub-agent has its own stop criteria)
- AutoResearchClaw: PIVOT/REFINE Loop — if experiments fail → multi-agent debate → "REFINE" (tweak) or "PIVOT" (new direction)
- DeepResearchAgent: Self Evolution Protocol Layer (SEPL) — closed-loop Observe→Optimize until sufficient
- LangChain: separates decision logic into Research/Summarization/Compression/Final Report models

**3. Insufficient Results Handling**
- AutoResearchClaw: autonomous PIVOT with artifact versioning
- Orchestra: "autonomous research pivoting" — refute own hypothesis and pivot to stronger finding
- LangChain: Plan-and-Execute with reflection + human-in-the-loop feedback

## Round 2: Academic Framework Automation Potential

### PRISMA Pipeline — What Can vs Can't Be Automated
**Automatable:**
- Identification: aggregate records, citation chasing, deduplication
- Screening (Title/Abstract): ML-based filtering (RobotSearch), multi-agent scoring (LatteReview)
- Eligibility: parameter extraction, risk of bias assessment (RobotReviewer)

**Requires Human Judgment:**
- Verification of automated recommendations (PRISMA 2020 mandate)
- Citation integrity / hallucination checks
- Conflict resolution between reviewers
- Final synthesis interpretation

### Theoretical Saturation → Programmatic Stopping
Three measurable signals (Corbin & Strauss):
1. **Zero new data emergence**: zero new codes across additional data
2. **Conceptual density**: categories fully developed with rich descriptions
3. **Stable relationships**: inter-category relationships repeatedly validated

**Key insight**: Track rate of new code generation → when rate drops to zero over sequential threshold → auto-stop and shift to refinement/reporting

### QCE Framework (Question-Claim-Evidence)
- Question: define specific research gap
- Claim: analytical statement (not listing), must be arguable
- Evidence: multiple sources, include contradictory evidence, evaluate strength
- Different from PRISMA: QCE = analytical writing structure; PRISMA = process reporting checklist

## Round 3: Decision Tree + Failure Modes + Quality Metrics

### Decision: Deep Research vs Quick Search
Router-based classification using:
- Task decomposition requirement (multi-hop reasoning → deep)
- Document-centric vs isolated retrieval
- Cross-domain correlation needs

**Concrete split:**
- Single fact lookup → web search
- Multi-source synthesis / domain correlation → deep research notebook

### Failure Modes (Critical for Pack Design)
1. **Hallucination/fabrication** — #1 reason AutoResearchClaw added HITL. AI generates fake references, ungrounded claims, fabricated numbers
2. **Cost/budget overruns** — fully autonomous research without limits
3. **Stuck agents** — DeerFlow: malformed history errors when tool-call loops interrupted. Fix: strip metadata + inject placeholder tool results
4. **No acceptable false negative threshold defined** — ASReview keeps humans as oracle

### Source Quality Metrics
- **AutoResearchClaw 4-layer citation verification**: arXiv IDs → CrossRef/DataCite DOIs → Semantic Scholar title match → LLM relevance scoring
- **Orchestra ARA Rigor Reviewer**: 6 dimensions — evidence relevance, falsifiability, scope calibration, argument coherence, exploration integrity, methodological rigor
- **RobotReviewer**: RoB 2 / ROBINS-I / QUADAS-2 standardized bias rubrics
- **QCE**: evaluate evidence strength + require contradictory evidence reporting
- **NOT found in sources**: recency or author authority as hardcoded metrics

## Synthesis: Design Implications for Our Capability Pack

### Must-Have (from research)
1. **Router with explicit decision signals** — not just keyword matching, but complexity/reasoning-depth classification
2. **Structured query decomposition** — problem tree, not flat keyword list
3. **Programmatic saturation detection** — track new-code rate, stop when zero over threshold
4. **PIVOT/REFINE loop** — our CRAG is primitive; need explicit pivot vs refine decision
5. **Anti-hallucination layer** — citation verification pipeline (at minimum: URL exists + content matches claim)
6. **Human gates at PRISMA-mandated points** — verification, conflict resolution, final synthesis

### Nice-to-Have
7. Orchestra's 6-dimension rigor scoring for source quality
8. QCE structure for final output (Question-Claim-Evidence, not just summary)
9. Per-sub-query termination conditions (DeerFlow pattern)
10. Cost/token budget tracking per research session

### Our Existing Strengths (already better than most)
- GitHub-First source strategy (unique — no competitor does this)
- NotebookLM cross-source synthesis with citations (unique tool advantage)
- Research → AC Bridge (extracting actionable items — unique to TAD)
- OBJECTIVES.md alignment (goal-driven, not aimless exploration)

## Round 4: Orchestra Architecture Deep Dive

### Two-Loop Architecture (Concrete)
- **Inner loop**: empirical execution — run experiments, train models, evaluate benchmarks, generate optimization trajectory plots
- **Outer loop**: research lifecycle — literature survey → ideation → synthesis → paper writing
- **Transition trigger**: inner loop outputs data → updates `Findings.md` with "Lessons and Constraints" → state change triggers outer loop to synthesize + evaluate phase completion

### Skill System (98 skills, 23 categories)
- npm package `@orchestra-research/ai-research-skills`
- Interactive installer detects agent type (Claude Code / Cursor / Gemini CLI)
- Installs to `~/.orchestra/skills/` with symlinks to agent environment
- Each skill: YAML frontmatter + curated SKILL.md (200-500 lines)
- Registry: `.claude-plugin/marketplace.json` manifest
- Routing: Autoresearch orchestrator auto-routes based on `research-state.yaml` active state

### Pivot Prevention (Anti-Infinite-Loop)
- ARA Research Manager runs as post-task epilogue
- Scans full conversation history → extracts decisions, experiments, dead ends, pivots
- Tags with strict user/AI provenance
- `Findings.md` maintains recorded dead ends → outer loop BLOCKED from repeating historically failed paths

## Round 5: Anti-Hallucination + Process Integration

### Anti-Hallucination Techniques (Beyond Citation Verification)
1. **4-layer citation verification** (AutoResearchClaw): arXiv → CrossRef/DataCite → Semantic Scholar → LLM relevance. Failed citations are AUTO-REMOVED (block, not warn)
2. **Inline Claim Verification**: extracts claims → cross-references against collected literature → flags ungrounded citations + fabricated numbers
3. **VerifiedRegistry**: only ground-truth experiment data enters paper — sanitizes unverified numbers
4. **Sentinel Watchdog**: background quality monitor enforcing paper-evidence consistency during drafting
5. **ARA Rigor Reviewer** (Orchestra): scores across evidence relevance, falsifiability, scope calibration, argument coherence, exploration integrity, methodological rigor

### Process Integration Architecture Patterns

**Three models found:**

| Model | Framework | Mechanism | Transition |
|-------|-----------|-----------|------------|
| State-Machine + Gates | AutoResearchClaw | 23-stage, 8-phase rigid pipeline | Gate Stages (5, 9, 20) pause for human → rollback if rejected. Decision Loops: PROCEED/REFINE/PIVOT |
| State-Tracking + Two-Loop | Orchestra | `research-state.yaml` + `Findings.md` | State file update triggers phase transition |
| Dynamic Agent Delegation | DeerFlow | Lead agent spawns sub-agents on-the-fly | Per-agent termination conditions → structured results → lead synthesizes |

**Best fit for our pack**: State-Tracking model (Orchestra) — closest to TAD's existing session-state.md + REGISTRY.yaml pattern. Augment with Gate Stages from AutoResearchClaw for human checkpoints.

## Updated Design Implications

### Architecture Decision
**State-Tracking + Human Gates** (Orchestra + AutoResearchClaw hybrid):
- research-state.yaml tracks current phase (plan → source → curate → analyze → output)
- Gate checkpoints at: query decomposition approval, source quality review, final synthesis
- PIVOT/REFINE decision at analyze phase: if saturation signals fail → REFINE (add sources) or PIVOT (change angle)
- Dead-end registry prevents repeating failed research paths

### Anti-Hallucination (Minimum Viable)
- Layer 1: URL existence check (source add already does this)
- Layer 2: Claim-to-source traceability (NotebookLM citations provide this natively)
- Layer 3: QCE output structure requiring contradictory evidence reporting
- Layer 4 (future): Rigor scoring on final output
