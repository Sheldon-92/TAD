# D8: Observability in Production

**Decision**: How does the agent expose its internal behavior for debugging, alerting, and cost tracking?

The most frequent production failure mode is not catastrophe — it is silent degradation. An agent that "does something subtly wrong and nobody noticed for 3 days because there were no traces" causes more cumulative damage than a dramatic crash that alerts on-call immediately. [Source: research finding #23]

---

## The Core Requirement

An agent without observability is a black box. When it misbehaves (and it will), you have no way to:
- Determine which turn introduced the error
- Identify which tool call caused unexpected behavior
- Attribute cost to which session or task type
- Detect loops before they exhaust budgets

**Observability must be designed before the agent goes to production.** Retrofitting trace correlation across a live multi-agent system typically takes 3-6 weeks. Building it into the initial design takes 2 days.

---

## Structured Logging: JSONL Append-Only [Source: Claude Code #8, OpenClaw #7]

**Format**: JSONL (JSON Lines) — one JSON object per line, appended to stdout or a file.

```json
{"ts": "2026-05-07T14:23:01.234Z", "session": "abc-123", "turn": 5, "event": "tool_call", "tool": "read_file", "args": {"path": "src/main.py"}, "latency_ms": 47, "tokens_in": 1200, "tokens_out": 340}
{"ts": "2026-05-07T14:23:01.890Z", "session": "abc-123", "turn": 5, "event": "tool_result", "tool": "read_file", "status": "ok", "bytes": 4200}
```

**Why JSONL** [Source: Claude Code #8]:
- Append-only: no destructive edits, full audit trail
- Streamable: can process tail -f in real time
- Queryable: standard tools (jq, grep, awk) work without special tooling
- Scalable: each line is independent, can be partitioned by session_id

**Required fields**: timestamp (ISO 8601), session_id, turn_number, event_type, tool_name (if applicable), latency_ms, tokens_in, tokens_out.

**Framework-native checkpoints as observability anchors** [Source: research finding #29, https://github.com/langchain-ai/langgraph retrieved 2026-06-13]: if the orchestrator runs on a durable-execution framework, its checkpointer is also a free observability surface — each persisted checkpoint is a recoverable, inspectable state snapshot. **LangGraph 1.0** (GA October 2025, ~33,900 GitHub stars, 34.5M monthly downloads) persists through failures and **resumes from the exact checkpoint**; time-travel over checkpoints lets you replay the exact state that preceded a misbehavior instead of reconstructing it from JSONL alone. Pair JSONL event logs (what happened) with checkpoint snapshots (the state it happened in).

---

## Trace Correlation IDs Across Multi-Agent Transitions [Source: research]

When Agent A hands off to Agent B, the trace must maintain continuity.

**Correlation ID chain**:
```
Request arrives → root_trace_id generated
Agent A logs all events with root_trace_id
Agent A spawns Agent B → passes root_trace_id + span_id
Agent B logs all events with root_trace_id + parent_span=Agent_A_span_id
```

**Why this matters**: without correlation IDs, a failure in Agent B appears as an unexplained error with no attribution to the request that triggered it. Debugging requires manually correlating timestamps across log files — a multi-hour process for complex systems.

**Implementation**: pass trace context in every agent-to-agent transition message. Never start a new trace for a task that is a continuation of an existing request.

---

## OpenClaw: Graceful Telemetry Degradation [Source: OpenClaw #7]

**Rule**: telemetry errors must NOT crash the agent loop.

```
telemetry_write_error → fall back to safe defaults (log to stderr, continue)
Never: raise exception from telemetry path
Never: block on telemetry (async + fire-and-forget)
```

**Why**: an agent that crashes because its log sink is unavailable is worse than an agent that continues without telemetry. The mission is to serve the user; telemetry is observability infrastructure, not the primary path.

**Implementation**: wrap all telemetry writes in try/catch. On failure, fall back to stderr with a warning. Set a rate limit on fallback warnings (one per minute) to avoid flooding stderr.

---

## Cost Dashboards: Per-Session and Per-Tool [Source: Helicone, Claude Code]

**Required dashboards** (minimum viable observability):

| Metric | Granularity | Alert Threshold |
|--------|-------------|-----------------|
| Token cost per session | Per session | > $X (configurable) |
| API calls per session | Per session | > N calls (configurable) |
| Tool invocations | Per tool type | > M calls/session |
| p95 latency | Per tool | > L ms (configurable) |
| Error rate | Per tool | > E% |
| Context size at session end | Per session | > 90% of limit |

**Cost tracking tools**: Helicone (LLM proxy, cost attribution), LiteLLM (multi-provider tracking), tokencost (pre-call estimation).

**Rule**: cost dashboards must be live on day 1 of production. Discovering cost overruns a week after launch means a week of uncontrolled spending.

---

## Runaway Loop Detection [Source: research, D7]

**Alert**: consecutive identical tool calls > 3 → runaway loop signal.

**Implementation**:
```python
if len({recent_tool_calls[-3:]}) == 1:  # all 3 identical
    alert("runaway_loop_detected", tool=recent_tool_calls[-1])
    apply_budget_cap()  # or pause + notify human
```

**Common loop patterns**:
1. Evaluator-optimizer that never converges (criteria not met → regenerate → criteria still not met)
2. Tool retry on transient failure (no backoff, retries immediately, same failure)
3. Orchestrator waiting for worker state update (polling instead of event-driven)

**Detection threshold**: 3 identical calls is signal. 5 is high-confidence runaway. Act at 3, not 5.

---

## AI-Assisted Trace Analysis [Source: research finding #23]

**When**: trace spans hundreds of steps (long autonomous sessions, multi-day research tasks).

**Manual review limit**: a human can meaningfully review ~50 trace steps. Above 100, patterns are invisible and errors are missed.

**Solution**: use an auxiliary AI evaluator to:
1. Segment the trace into logical blocks (10-20 steps each)
2. Score each block for goal progress (1-5 scale)
3. Identify the block where reasoning diverged from goal
4. Generate a "trace summary with anomaly flags"

The human then reviews the flagged blocks, not the full trace.

**Tools**: AgentOps (session replay with execution graphs), Arize Phoenix (self-hostable trace UI), Langfuse (self-hostable, supports trace + evaluation).

---

## Alert Thresholds (Configurable Defaults)

```yaml
observability:
  alerts:
    session_cost_usd: 1.00          # alert if session costs > $1
    session_api_calls: 100          # alert if session makes > 100 API calls
    consecutive_identical_tools: 3  # runaway loop detection
    context_fullness_pct: 85        # alert when context > 85% full
    tool_p95_latency_ms: 5000       # alert if tool p95 > 5s
    error_rate_pct: 10              # alert if tool error rate > 10%
  sampling:
    trace_sample_rate: 1.0          # 100% during beta, reduce in production
    cost_reporting_interval: 3600   # cost report every hour
```

**Tuning process**: start at 100% sampling. After 2 weeks, analyze trace volume vs. alert signal ratio. Reduce sampling rate until P95 of important events are still captured.

---

## Observability Tool Recommendations [Source: research — Tool Mapping]

| Tool | Use Case | Cost Model |
|------|----------|-----------|
| AgentOps | Session replay, execution graphs, cost tracking | Managed, per-session |
| OpenLLMetry | OTel-based, no code changes to instrument | Open source |
| Langfuse | Self-hostable, traces + prompt versioning | Open source |
| Arize Phoenix | Self-hostable trace UI + evaluation | Open source |
| Helicone | LLM proxy for cost tracking + dashboards | Managed, per-request |

**Recommendation sequence**:
1. Start with Langfuse or Arize Phoenix (free, self-hostable, full traces)
2. Add Helicone for cost attribution if token cost is a concern
3. Add AgentOps for session replay when debugging complex multi-turn sessions

---

## Cross-Reference

- **What to log from each agent coordination pattern**: see D2 (coordination-and-state.md)
- **Compression events to observe**: see D6 (context-compression.md)
- **Cost metrics to track**: see D7 (cost-token-economics.md)
- **Testing traces before they're needed in production**: see D9 (testing-evaluation.md)
- **Disasters observability would have surfaced earlier**: see D10 (production-disasters.md) — all 7 incidents were silent before damage was done
