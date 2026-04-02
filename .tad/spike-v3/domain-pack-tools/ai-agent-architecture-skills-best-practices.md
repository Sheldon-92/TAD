# AI Agent Architecture — Skills Best Practices

## Sources

| Source | Type | Key Value |
|--------|------|-----------|
| Alex's Research (ai-agent-architecture-research.md) | Primary analysis | Three-layer reliability model, 8 universal patterns, cross-env comparison |
| Claude Code Source (gist/yanchuk) | Architecture deep dive | Permission pipeline, compaction tiers, multi-agent coordination |
| OpenClaw Agents (user's project) | Real-world case | AGENTS.md/SOUL.md/HEARTBEAT.md pattern, prompt-only constraints |
| wshobson/agents (GitHub, multi-agent) | Agent orchestration | Tier-based model assignment, PluginEval 3-layer quality, anti-pattern detection |
| marcusgoll/atlas-guardrails (GitHub) | Guardrails framework | Symbol indexing, drift detection, pre-write duplicate check |
| 2026 Industry Research (Cogent, Codebridge, BVP) | Production patterns | Mechanical guardrails, hard ceilings, budget as safety |
| FrancyJGLisboa/agent-skill-creator (GitHub) | Skill lifecycle | 3-phase UNDERSTAND→BUILD→VERIFY, staleness detection, cross-platform adapters |

---

## Capability 1: reliability_design (Three-Layer Verification)

**Best Step Design** (from Alex research + Claude Code source):
1. Map existing enforcement mechanisms in the target environment
2. Classify each mechanism by layer: Schema (structure) → Semantic (logic) → Permission (authorization)
3. Identify single-point-of-failure gaps (e.g., only prompt-level constraints)
4. Design enforcement at each layer with concrete tool/config
5. Define priority order (deny > hooks > prompt, per Claude Code pattern)
6. Test: attempt to bypass each layer, document results

**Best Analysis Framework** (from Alex research):
- Three-Layer Model: Prompt (weakest) → Hook/Middleware (medium) → Architecture Constraint (strongest)
- Claude Code enforcement priority: `permissions.deny > hooks.PreToolUse > permissions.allow > user prompt`
- Key metric: "10 steps at 85% accuracy → 80% failure rate. 3 steps at 85% → 39% failure."
- Principle: Reduce agent steps > improve single-step accuracy

**Best Quality Standards** (from Claude Code gist + Atlas):
- Every critical behavior has ≥2 independent enforcement layers
- No single point of failure (deny cannot be overridden by hooks)
- Bypass attempt documentation (what happens when each layer is bypassed?)
- Concrete mechanism mapping (not "add guardrails" but "PreToolUse hook with Haiku classifier")

**Anti-Patterns**:
- ❌ Relying only on prompt instructions for safety ("MANDATORY" in prompt ≠ enforced)
- ❌ Asking the agent if it's in a loop (must prove mechanically — 2026 industry consensus)
- ❌ Single-layer enforcement (one bypass = total failure)
- ❌ Over-constraining (OVER_CONSTRAINED anti-pattern from wshobson/agents PluginEval)

---

## Capability 2: role_behavior_design (Agent Identity & Boundaries)

**Best Step Design** (from OpenClaw SOUL.md + AGENTS.md + Claude Code):
1. Define agent identity: role, mission, personality (SOUL.md pattern)
2. Define operating rules: commands, message handling, workflows (AGENTS.md pattern)
3. Define immutable constraints: what the agent MUST NEVER do (HEARTBEAT.md pattern)
4. Define behavior matrix: for each input type, what action to take
5. Design forbidden actions list with enforcement mechanism (not just "don't do X")
6. Map each constraint to its enforcement layer (prompt vs hook vs architecture)

**Best Analysis Framework** (from OpenClaw + wshobson/agents):
- Three-file pattern: Identity (SOUL) + Operations (AGENTS) + Hard Rules (HEARTBEAT)
- Tier-based responsibility: Critical tasks → strongest model, support tasks → smaller models
- Self-knowledge rule: Agent must read its own config before answering "how do I work?" (OpenClaw AGENTS.md)
- Mandatory template formats prevent drift (hardcoded, not suggested)

**Best Quality Standards** (from OpenClaw HEARTBEAT + Claude Code):
- Every "NEVER" rule has a cost incident or failure case justifying it
- Forbidden actions enforced at ≥ hook level (not just prompt)
- Behavior matrix covers all input types (no "undefined behavior")
- Self-knowledge test: ask agent to describe itself, verify accuracy

**Anti-Patterns**:
- ❌ "Be helpful and safe" without specific constraints (too vague to enforce)
- ❌ Prompt-only MANDATORY rules (OpenClaw lesson: MANDATORY ≈ suggestion without hooks)
- ❌ Mixing identity/operations/constraints in one file (separation of concerns)
- ❌ No cost/incident justification for rules (rules without "why" get ignored/removed)

---

## Capability 3: tool_system_design (Tool Architecture)

**Best Step Design** (from Claude Code source analysis):
1. Inventory all tools the agent needs (read/write/destructive classification)
2. Define schema for each tool: input types, output format, error conditions
3. Design permission model: who can call what, under what conditions
4. Design concurrency model: which tools are parallel-safe, which need serialization
5. Implement tool documentation as contract (purpose + example + strict types)
6. Design error feedback: specific, actionable, with retry guidance

**Best Analysis Framework** (from Claude Code gist):
- Tool safety classification: `isConcurrencySafe()`, `isReadOnly()`, `isDestructive()`
- Permission pipeline: Static rules → Mode-based → LLM classifier → User prompt (escalating cost)
- Concurrency batching: Parallel batch (read-only, up to 10) vs Serial batch (write, exclusive)
- Deferred schema loading: Names in prompt, full schemas on demand (saves 1000s of tokens)
- Dangerous pattern detection: rm -rf, DROP TABLE, .gitconfig modification

**Best Quality Standards** (from Anthropic API docs + Claude Code):
- `strict: true` on all tool schemas (prevents AI from inventing parameters)
- Every tool has: purpose line + usage example + error conditions + escalation path
- No tool can be called without schema validation
- Destructive tools require explicit user approval (not auto-approved)

**Anti-Patterns**:
- ❌ Tools without schema (AI hallucinates parameters — Anthropic API known risk)
- ❌ All tools always available (context bloat — use deferred loading)
- ❌ No concurrency control (parallel writes corrupt data)
- ❌ Generic error messages ("error" instead of "parameter X invalid, try Y")
- ❌ EMPTY_DESCRIPTION anti-pattern (from wshobson/agents PluginEval)

---

## Capability 4: memory_design (Memory Architecture)

**Best Step Design** (from Claude Code memdir + OpenClaw changelog):
1. Classify memory needs: session (conversation) vs persistent (cross-session) vs external (DB/API)
2. Design context budget: max tokens per layer, compaction strategy
3. Design retrieval strategy: keyword? semantic? LLM-driven selection?
4. Design write triggers: when to save, what format, where to store
5. Design decay/cleanup: stale detection, archive rules, size limits
6. Test: verify retrieval accuracy after 10+ rounds of conversation

**Best Analysis Framework** (from Claude Code gist):
- Multi-layer context: System prompt → User context (CLAUDE.md) → Conversation → Reserved output
- 4-tier progressive compaction: Micro-compact (80%) → Auto-compact (167K) → Session memory (90%) → Reactive (API error)
- Persistent memory pattern: MEMORY.md index (≤200 lines) + individual topic files
- LLM-driven selection: Sidequery to pick ≤5 relevant memories (not keyword match)
- OpenClaw changelog pattern: memory/YYYY-MM-DD-{slug}.md per event

**Best Quality Standards** (from Claude Code + OpenClaw):
- Context budget explicitly defined per layer (not "as needed")
- Compaction preserves key decisions (not random truncation)
- Memory retrieval verified: recall test after N rounds
- Stale detection: memories older than threshold flagged for review
- Circuit breaker: 3 compaction failures → disable that tier

**Anti-Patterns**:
- ❌ No compaction strategy (context grows until crash)
- ❌ Keyword-only retrieval (misses semantic relevance)
- ❌ Saving everything (memory bloat, irrelevant noise)
- ❌ No stale detection (outdated memory treated as current truth)
- ❌ Single compaction tier (no progressive degradation)

---

## Capability 5: multi_agent_design (Agent Collaboration)

**Best Step Design** (from Claude Code coordinator + wshobson/agents):
1. Define agent roster: roles, responsibilities, model tiers
2. Design communication protocol: how agents exchange information
3. Design isolation boundaries: what each agent can/cannot access
4. Design coordination pattern: sequential pipeline vs parallel fan-out vs hierarchical
5. Design conflict resolution: what happens when agents disagree
6. Design shutdown protocol: graceful termination with state preservation

**Best Analysis Framework** (from Claude Code gist):
- Three execution levels: Sub-agents (isolated children) → Coordinator (orchestration) → Teams (persistent named)
- Fork subagent cache optimization: Shared prefix → cache HIT for all children (cost reduction)
- Communication channels: In-process queue → File-based mailbox → Broadcast (`to="*"`)
- Team patterns: review, debug, feature, fullstack, research, security, migration (wshobson/agents)
- Dream Task: Background memory consolidation during idle periods

**Best Quality Standards** (from 2026 industry research):
- Every inter-agent message has schema validation
- Budget ceiling per agent (model logic cannot override)
- Loop detection is mechanical, not self-reported
- Shutdown requires approval flow (not instant kill)
- Communication logged for audit trail

**Anti-Patterns**:
- ❌ Agents self-reporting loop status (must prove mechanically)
- ❌ No budget ceiling (API cost explosion — OpenClaw ¥74 incident)
- ❌ Shared mutable state without locking (race conditions)
- ❌ No shutdown protocol (orphaned agents consuming resources)
- ❌ Fan-out without aggregation (results lost)

---

## Capability 6: safety_design (Security & Guardrails)

**Best Step Design** (from NeMo Guardrails + Atlas + Guardrails AI):
1. Identify all risk vectors: prompt injection, tool misuse, data leakage, infinite loops
2. Design input validation: schema check, content filtering, injection detection
3. Design output validation: hallucination check, PII detection, format enforcement
4. Design execution guardrails: budget limits, timeout, circuit breaker
5. Define human-in-the-loop boundary: irreversibility threshold
6. Test adversarially: attempt to bypass each safeguard

**Best Analysis Framework** (from NeMo + Atlas + 2026 research):
- Three-rail model (NeMo): Input rails → Execution rails → Output rails
- Mechanical vs cognitive guardrails: Mechanical (outside LLM) > Cognitive (LLM self-check)
- Atlas pattern: Pre-write check (duplicates) + Post-write check (drift) + CI gate
- Human-in-the-loop: Define irreversibility threshold per domain, auto-escalate above threshold
- Budget as safety: Hard ceiling that model logic cannot override

**Best Quality Standards** (from Guardrails AI + Claude Code):
- Critical=0, High=0 for production deployment
- Every safety rule has a bypass test result documented
- Adversarial test: 5+ injection attempts with results
- PII detection: automated scan on all agent outputs
- Circuit breaker: 3 consecutive failures → stop + escalate

**Anti-Patterns**:
- ❌ LLM-only safety ("please don't be harmful" in prompt)
- ❌ No budget limit (infinite loop = infinite cost)
- ❌ Safety as afterthought (must be designed in from start)
- ❌ Testing only happy path (adversarial testing required)
- ❌ No circuit breaker (3 same errors should stop, not retry forever)

---

## Capability 7: prompt_architecture (System Prompt Design)

**Best Step Design** (from Claude Code source + SKILL.md ecosystem):
1. Design prompt hierarchy: system → user context → conversation → dynamic
2. Define each layer's content and max token budget
3. Design assembly pipeline: what loads when, in what order
4. Design caching strategy: what can be shared across sessions
5. Design deferred loading: names first, full content on demand
6. Measure: actual token usage per layer, cache hit rate

**Best Analysis Framework** (from Claude Code gist + wshobson):
- CLAUDE.md hierarchy: global → user → project → local (inheritance with override)
- Skill loading: metadata always → instructions on activation → resources on demand
- Deferred tool schemas: Names in prompt, ToolSearch for full schemas (saves tokens)
- Fork cache optimization: Shared prefix across sub-agents for cache hits
- Token budgeting: Multiple estimation strategies (API exact / character approx / fixed for images)

**Best Quality Standards** (from Claude Code + wshobson/agents):
- Context budget: each layer has explicit max tokens
- No BLOATED_SKILL (>500 lines without segmentation)
- Assembly order tested: verify prompt renders correctly
- Cache hit rate measured (fork pattern should achieve >80%)
- Deferred loading reduces initial context by >50%

**Anti-Patterns**:
- ❌ Everything in system prompt (context explosion)
- ❌ No hierarchy (flat prompt = unmaintainable at scale)
- ❌ Eager loading of all tools/skills (waste tokens on unused capabilities)
- ❌ No caching strategy (re-compute everything per request)
- ❌ ORPHAN_REFERENCE: referencing non-existent files in prompt (wshobson PluginEval)

---

## Capability 8: production_readiness (Production Checklist)

**Best Step Design** (from Alex research + Claude Code + 2026 patterns):
1. Design state persistence: what tool/DB, what schema, recovery procedure
2. Design error communication: how to tell the agent what went wrong (specific + actionable)
3. Design human escalation flow: triggers, channels, response SLA
4. Design observability: what to log, where, how to query
5. Design failure modes: for each external dependency, what happens if it's down
6. Design degradation strategy: graceful fallback when components fail
7. Create deployment checklist: pre-flight, canary, rollback

**Best Analysis Framework** (from Claude Code gist + OpenClaw):
- State persistence: Checkpoint after each phase (crash recovery without progress loss)
- MCP connection states: Connected → Failed → NeedsAuth → Pending → Disabled (explicit state machine)
- Denial tracking escalation: >3 consecutive or >20 total → auto-escalate
- 4-tier compaction as degradation: surgical → moderate → high cost → last resort
- OpenClaw single-execution architecture: Run once, never retry (cost safety)
- Dream Task: Background consolidation during idle (efficiency)

**Best Quality Standards** (from Alex research + 2026 industry):
- Recovery test: kill process mid-execution, verify state restored
- Failure mode documentation: every external dependency has a "what if down?" answer
- Observability: key decisions logged with timestamp + context + reasoning
- Cost monitoring: budget alerts before hitting ceiling
- Canary deployment: new version tested on subset before full rollout

**Anti-Patterns**:
- ❌ No state persistence (crash = restart from zero)
- ❌ Generic error messages ("something went wrong")
- ❌ No degradation strategy (one component down = total failure)
- ❌ No cost monitoring (discover $74 bill after the fact — OpenClaw incident)
- ❌ No rollback plan (deploy and pray)

---

## Cross-Cutting Patterns

### Pattern: Enforcement Priority Order
```
Architecture constraint (impossible to violate) > Hook/middleware (framework enforced) > Prompt instruction (can be rationalized away)
```
Every critical rule must be enforced at the highest feasible layer.

### Pattern: Circuit Breaker
```
3 consecutive same errors → stop + escalate to human
```
Applies to: tool retries, agent loops, compaction failures, permission denials.

### Pattern: Progressive Degradation
```
Tier 1 (surgical, cheap) → Tier 2 (moderate) → Tier 3 (expensive) → Tier 4 (last resort)
```
Applies to: compaction, error handling, permission escalation.

### Pattern: Budget as Safety
```
Hard ceiling that model logic cannot override.
Not a metric — an active safety feature.
```
