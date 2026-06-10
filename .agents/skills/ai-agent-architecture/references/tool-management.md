# D4: Tool Loading and Management

**Decision**: How does the agent discover, load, and execute tools? How many tools should be loaded at once?

Tool management is a hidden cost multiplier. An agent with 40 tools loaded wastes 8K-55K tokens on definitions alone, before a single query is processed. A well-designed tool interface reduces parameter errors by an order of magnitude.

---

## The Core Problem: Tool Token Cost [Source: research finding #3]

40 MCP tools loaded at session start = **8,000 to 55,000 tokens** on tool definitions before any user query is processed. At GPT-4 pricing (2026), that's $0.08-$0.55 per session just to load tools — before doing anything. At 1,000 sessions/day, that's $80-$550/day in wasted context.

**Rule**: if the agent uses >5 tools, implement deferred loading. Load tools when they're needed, not at session start. [Source: research finding #12, Claude Code #9]

---

## Selection Matrix: Tool Loading Strategy

| Tool Count | Agent Type | Strategy |
|------------|-----------|----------|
| ≤5 | Any | Upfront loading — overhead acceptable |
| 6-20 | Specialized | Category deferred — load by domain |
| >20 | General purpose | Search-then-load — dynamic retrieval |
| Variable | Multi-session | Registry with TTL — cache loaded tools |

---

## Claude Code: Graduated Cost Hierarchy [Source: Claude Code #9]

Not all tools cost the same. Design tool extensions in ascending order of context cost:

| Extension Type | Context Cost | Examples |
|---------------|-------------|----------|
| Hooks | 0 tokens | Pre/post tool events, file watchers |
| Skills/Prompts | Low (~500-2K tokens) | Workflow definitions, specialized prompts |
| Plugins | Medium (~2K-8K tokens) | Domain-specific tool bundles |
| MCP Servers | High (~8K-55K tokens) | Full external API connections |

**Rule**: implement the cheapest extension type that solves the problem. Reserve MCP for tools that genuinely require external state or cannot be expressed as hooks/skills. [Source: Claude Code #9]

---

## Deferred Loading: Search-Then-Load Pattern [Source: research finding #12]

Instead of loading all tools at session start:
1. The agent receives a summary index of available tools (names + one-line descriptions, ~10-50 tokens each)
2. For each task, the agent searches the index for relevant tools
3. Full tool definition loads only for selected tools

**Cost example**: 40 tools with 20-word descriptions each = ~1,000 tokens for the index. Agent selects 3 relevant tools, loads their full definitions = ~1,500 tokens. Total: ~2,500 tokens instead of 55,000.

**Implementation**: maintain a tool registry with name, description, capability tags. Load full definitions on demand via a `get_tool_definition(tool_name)` meta-tool.

---

## Dynamic Tool Dependency Retrieval (DTDR) [Source: research finding #5]

**Problem**: the right tool for step 2 depends on step 1's outcome, which isn't known at session start.

**Solution**: instead of loading all potentially-useful tools upfront, the agent:
1. Executes step 1
2. Inspects the output
3. Retrieves the tool most appropriate for step 2's specific output type

This prevents loading 5 different parsers when only 1 will ever be used.

**Anti-pattern**: loading the full "possible tools for this task type" set, then filtering. The filtering still happens in context — you've paid the token cost for all tools whether used or not.

---

## Tool Interface Design: ACI (Agent-Computer Interface) [Source: Claude Code, research finding #9]

**Core principle**: design tool interfaces as if a junior developer with no context will call them.

**ACI requirements**:
1. **Descriptive function names**: `read_file_lines(path, start, end)` not `get(f, s, e)`
2. **Fully specified parameters**: include units, allowed ranges, example values in docstrings
3. **Return type contracts**: specify what the return value means, not just its type
4. **Error message quality**: error responses must tell the agent what to do differently, not just that something failed

**Rule** [Source: research finding #8]: if the agent repeatedly makes parameter mistakes on a tool, the tool interface is broken, not the agent. Fix the interface.

**Poka-yoke tool design** [Source: research finding #8]: "mistake-proof" interfaces that make the wrong call impossible:
- Enums instead of free strings (prevent invalid values)
- Mutual exclusion enforced at interface level (prevent invalid parameter combinations)
- Path normalization at the interface level (prevent relative-vs-absolute path errors)
- Type coercion at the interface boundary (prevent string/int confusion)

---

## Meta-Tool Pattern [Source: research finding #10]

**When**: the agent repeatedly executes the same sequence of 2-4 tools in the same order.

**Solution**: bundle the sequence into a single deterministic meta-tool.

```
Before: search(query) → parse_results(results) → extract_entities(text)
After: search_and_extract(query) → entities
```

**Benefits**:
- Reduces token cost (1 tool call instead of 3)
- Reduces error surface (3 calls that could fail → 1 call)
- Deterministic behavior (the sequence is now code, not LLM inference)

**Rule**: if you observe a tool sequence repeated >10 times in logs, it's a meta-tool candidate. [Source: research finding #10]

---

## Parallel Tool Calling [Source: research finding #11]

**When**: multi-step agent with high latency where multiple tools can run simultaneously.

If steps A and B are independent (B does not depend on A's output), they can run in parallel:
```
Sequential: A (2s) → B (2s) = 4s total
Parallel:   A (2s) ‖ B (2s) = 2s total
```

**Requirement**: the agent must explicitly identify independent steps. This requires dependency analysis at the orchestrator level. [Source: D2 — coordination-and-state.md]

**Implementation**: most agent frameworks support `tool_calls` as a list in the model response. Models capable of parallel tool calling will return multiple tool calls in one response when the context allows.

---

## SkillTool vs AgentTool: The 7x Cost Decision [Source: Claude Code #13]

| Mechanism | When RIGHT | Token Cost | Use For |
|-----------|-----------|-----------|---------|
| SkillTool (in-context instructions) | Instructions needed in current context | ~1x | Standard tools with instructions |
| AgentTool (spawns isolated sub-agent) | Subtask is verbose, exploratory, or risks context pollution | ~7x (summary-only return) | Long research tasks, untrusted execution |

**AgentTool isolation**: the sub-agent's full execution history is NOT returned to the parent. Only a summary result returns. This protects the parent context from a verbose sub-agent (a sub-agent that reads 20 files returns a 3-paragraph summary, not 20 files of content).

**Cost implication**: AgentTool costs ~7x more per invocation. Use only when context isolation is worth 7x the price. [Source: D7 — cost-token-economics.md]

---

## OpenClaw: Plugin Isolation from Core [Source: OpenClaw #10]

New tool capabilities must be implemented as discrete plugins, never by modifying the core engine.

**Why**: core engine modifications have system-wide blast radius. A bug in a plugin affects only tasks using that plugin. A bug in the core affects all tasks.

**Plugin interface requirements**:
- Defined input/output contract
- Failure mode: plugin fails, core continues (graceful degradation)
- Versioned independently of core engine
- Sandboxed execution context (plugin cannot access core internals directly)

---

## Hermes: Tool-Use Enforcement [Source: Hermes #10]

**Rule**: if the agent says "I will do X," it MUST execute the corresponding tool call in the SAME response. The agent cannot end a response with a promise of future action.

**What this prevents**: an agent that says "I'll process this file" but then forgets in the next turn. By the time the next turn starts, the conversation may have moved on. The commitment is lost.

**Implementation**: validate that any response containing future-tense action statements also contains tool_call entries in the same response.

---

## Cross-Reference

- **How many tools is too many for context**: see D6 (context-compression.md)
- **Permission scope per tool**: see D5 (permissions-safety.md)
- **Token cost of different tool loading strategies**: see D7 (cost-token-economics.md)
- **Monitoring tool call patterns in production**: see D8 (observability.md)
- **Disasters this decision prevents**: see D10 (production-disasters.md), Incident #2 (tool poisoning through unsafe tool loading)
