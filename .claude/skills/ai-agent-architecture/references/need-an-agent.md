# D1: Do You Even Need an Agent?

**Decision**: Is an autonomous agent the right solution, or is a simpler deterministic approach sufficient?

This is the first and most important architectural decision. Every unnecessary agent adds failure probability, latency, cost, and debugging complexity. Make this decision before writing any agent code.

---

## Selection Matrix: 5 Levels of Complexity

| Level | Pattern | Use When | Example |
|-------|---------|----------|---------|
| 0 | Single LLM call | One-shot generation with retrieval | Summarize document, answer question |
| 1 | Prompt chaining | Fixed sequence of steps | Extract → format → translate |
| 2 | Routing | Categorize then specialize | Simple query → cheap model, complex → capable model |
| 3 | Orchestrator-Workers | Dynamic subtask decomposition | Research task: agent decides which tools to use |
| 4 | Autonomous Agent | Fully open-ended | Open-ended debugging, self-directed research |

**Rule**: Do not use Level N if Level N-1 can solve the problem. [Source: Claude Code #11]

---

## Primary Decision Gate

**Before building any agent, answer this question**:

> Can a single LLM call plus deterministic code solve this problem?

If YES → build the deterministic solution. If NO → define exactly what makes it insufficient, then choose the minimum agent complexity that resolves the insufficiency.

**The "Agent Everywhere" trap** [Source: Hermes — research finding, Expert Mistake #1]: replacing `if/else` logic with autonomous LLMs because it seems more powerful. An autonomous LLM solving a binary routing decision costs 100x more, takes 10x longer, and fails more often than a simple classifier.

---

## When to Choose Each Level

### Level 0: Single LLM Call
- The task is a single transformation (text → text, text → structured output)
- All inputs are known at call time
- No external state needs to be read or updated
- Success/failure is immediate and deterministic

**Do NOT upgrade to Level 1+ if**: the task seems "complex" but a single call with a good system prompt handles it reliably.

### Level 1: Prompt Chaining
- Task has fixed, predictable subtasks
- Each subtask has a well-defined input/output contract
- Subtasks are sequential (step N depends on step N-1's output)
- The sequence does not change based on intermediate results

**Upgrade to Level 2+ if**: the subtask sequence changes based on input category.

### Level 2: Routing
- Inputs fall into distinct categories requiring different handling
- A cheap classifier can distinguish categories with >90% accuracy
- Wrong category assignment is recoverable (not catastrophic)

**Upgrade to Level 3+ if**: subtasks cannot be classified upfront; they emerge during execution.

### Level 3: Orchestrator-Workers
- Subtask list is unpredictable (determined by the orchestrator at runtime)
- Workers have specialized tools the orchestrator doesn't need to understand
- Results must be integrated by the orchestrator with reasoning

**Use when**: research tasks, multi-step debugging, complex document processing where the number and type of operations isn't known upfront.

### Level 4: Autonomous Agent
- Task is fully open-ended with no predictable structure
- Human oversight is explicitly in the loop
- Failure is recoverable and non-catastrophic
- Performance requirements allow for higher latency and cost

**Risk quantification** [Source: research finding #1]: 10-step agent chain at 98% per-step reliability = 81.7% total success. Each additional step reduces success probability multiplicatively. At 20 steps at 98%: 66.7%. At 30 steps: 54.5%. Design for the minimum number of steps.

---

## Hermes Self-Evolution Exception [Source: Hermes #1]

The only well-documented case where an autonomous agent improves itself safely:

**5-gate safety requirement** before any self-mutation is applied:
1. 100% test pass rate on the mutated agent
2. Size limits enforced (mutation cannot grow the agent beyond bounds)
3. Cache compatibility verified (existing cached states still valid)
4. Semantic preservation verified (agent still produces expected outputs on regression set)
5. Human PR review before deployment

If any gate fails, the mutation is discarded. Without all 5 gates, self-evolving agents diverge from intended behavior within a small number of generations.

---

## Claude Code Design Philosophy [Source: Claude Code #11, #10]

> "The loop is trivial, the harness is the moat."

Claude Code's agent loop is ~30 lines of code. The value is in the 512K lines of harness that surrounds it: permission model, tool sandboxing, context management, compression pipeline.

**Implication for new agents**: invest in the harness, not the loop. The loop complexity (how sophisticated the agent's reasoning is) improves automatically as models improve. The harness (how safely the agent is constrained) must be designed explicitly and does not improve on its own.

**Trust the model, constrain the environment** [Source: Claude Code #11]: don't pre-specify every decision the agent makes. Give it tools, boundaries, and context. Let it reason. The harness constrains what can go wrong; the model decides what to do within those constraints.

---

## Output: Architecture Decision Document (Starter Template)

When using this pack in /design mode, D1 produces the following before proceeding to D2:

```
Agent Complexity Decision:
- Selected Level: [0-4]
- Justification: [why simpler levels are insufficient]
- Expected Failure Rate: [N steps at X% each = Y% success]
- Sandboxing Required: [yes/no — Level 3+ almost always yes]
- Human Oversight: [none / optional / mandatory]
```

---

## Cross-Reference

- **If Level 3+: how agents coordinate**: see D2 (coordination-and-state.md)
- **All levels: what complexity they add to context management**: see D3 (context-memory.md) and D6 (context-compression.md)
- **Autonomous agents: permission design required**: see D5 (permissions-safety.md)
- **Disasters this decision prevents**: see D10 (production-disasters.md) — all 7 incidents involve agents at Level 3 or 4 doing Level 1 tasks
