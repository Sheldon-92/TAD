# D9: Testing and Evaluation of Agent Systems

**Decision**: How does the agent system prove it behaves correctly when output is non-deterministic?

Binary pass/fail testing fails for agents. An agent that generates slightly different code each run may be correct on every run or wrong on some — a single test cannot distinguish these. Agent testing requires a different methodology from traditional software testing.

---

## Core Principle: Stochastic Behavior Fingerprinting [Source: research finding #24]

Non-deterministic agents cannot be tested with binary pass/fail assertions. Instead, test statistical behavior:

```
Wrong approach: assert output == expected_output
Right approach: assert P(correct_behavior) > 0.95 over N runs
```

**Fingerprinting method**:
1. Define behavioral invariants (properties that must ALWAYS hold, regardless of specific output)
2. Run N tests (typically 10-50 for expensive agents, 100+ for cheap ones)
3. Assert invariant holds in ≥X% of runs (configurable threshold per invariant criticality)

**Examples of invariants**:
- "The agent never sends an email without explicit user confirmation" (must hold 100%)
- "The agent's code suggestions compile without errors" (must hold 95%+)
- "The agent's output is in the requested language" (must hold 99%+)

---

## Test Each Agent-to-Agent Transition Independently [Source: research finding #24]

**Multi-agent chain testing principle**: test each agent-to-agent transition point in isolation with corrupted inputs.

**Why**: if you only test the full pipeline end-to-end, an error in Agent C might only appear when Agent A's output happens to trigger the specific input pattern that breaks C. You've tested the happy path for A and B but not C's failure modes.

**Per-transition test pattern**:
```
For each Agent_N → Agent_N+1 transition:
  1. Generate N valid inputs for Agent_N
  2. Generate N corrupted inputs (missing fields, wrong types, boundary values)
  3. Verify Agent_N+1 handles corrupted inputs gracefully (error, not silent corruption)
  4. Verify the error propagates correctly (logged, not swallowed)
```

**Probabilistic pipeline math** [Source: research finding #1]: 10-agent chain at 98% per step = 81.7% success. Each individual transition test that catches a failure mode improves this number. A transition that fails 5% of the time (95% pass rate) in isolation drops the full chain success from 81.7% to 59.9%.

---

## Hermes: Self-Evolution Test Gates [Source: Hermes #1]

When an agent modifies itself, these 5 gates must ALL pass before the modification is applied:

1. **100% test pass rate**: run the full regression suite on the mutated agent version. No exceptions for "obvious" mutations.
2. **Size limits**: the agent cannot grow beyond a defined maximum (prevents bloat from accumulated mutations).
3. **Cache compatibility**: existing cached states (session state, tool result caches) must remain valid under the new version. Breaking cache compatibility causes silent corruption for in-flight sessions.
4. **Semantic preservation**: the mutated agent must produce outputs within an acceptable distribution of the pre-mutation version (measured by embedding distance or LLM-as-judge evaluation).
5. **Human PR review**: a human reviews the diff and confirms the change is intentional before deployment.

**Rule**: if any gate fails, the mutation is discarded. Not retried. Not modified to pass. Discarded.

---

## Network Isolation for Web-Enabled Benchmarks [Source: research finding #22]

**The problem**: if an agent being evaluated can access the internet, it can find and read its own answer keys.

Published benchmarks (SWE-bench, HumanEval, etc.) are indexed by search engines. A web-enabled agent can literally search for the answer to the test question during evaluation.

**Required**: completely network-isolate the benchmark environment. No outbound internet access. No DNS resolution. The agent may only access:
- Its tools (local execution environment)
- A curated local knowledge base (if applicable)

**This invalidates all published benchmarks measured without network isolation on web-enabled agents.**

---

## Validation Strategies by Agent Type

### Simple agents (single-turn, deterministic tools)
- Unit test each tool independently
- Integration test the full turn with mock LLM responses
- Assert output schema correctness (type, required fields, value ranges)

### Stateful agents (multi-turn, session state)
- Test state transitions explicitly (is_state_A → action → expect_state_B)
- Test state recovery after crash (persist state, kill agent, restart, verify state)
- Test concurrent session isolation (session A's state must not affect session B)

### Multi-agent systems
- Test each agent-to-agent transition independently (see above)
- Test the full happy path end-to-end
- Test failure propagation (Agent B fails → does Agent A get an actionable error?)
- Test partial failure (Agents B and C run in parallel; B fails; does C's result still process?)

### Autonomous agents
- Stochastic invariant testing (see above)
- Red team evaluation (adversarial inputs designed to trigger safety violations)
- Sandbox isolation verified (agent's tools cannot reach outside the sandbox)

---

## Testing Tools [Source: research — Tool Mapping]

| Tool | Strength | When to Use |
|------|----------|-------------|
| promptfoo | YAML-driven, LLM-as-judge, CI integration | Assertion-based testing for known expected outputs |
| DeepEval | 20+ built-in metrics (faithfulness, relevance, hallucination, toxicity), pytest | Comprehensive metric-based evaluation |
| Inspect AI | UK AI Security Institute, safety-grade evaluation | Safety-critical agents requiring rigorous evaluation |
| AgentOps | Session replay, real test traces | Debugging specific session failures |
| AgentBench | Agent capability benchmarks | Comparing agent versions |
| SWE-bench | Code agent benchmarks | Evaluating coding agents specifically |
| tau-bench | Tool-use evaluation | Evaluating tool selection accuracy |

**Recommendation**: promptfoo for CI integration (YAML tests that run in pipeline), DeepEval for production quality monitoring (continuous eval against metrics).

---

## Minimum Viable Testing Checklist

Before a new agent goes to production:

- [ ] Unit tests for every tool (inputs, outputs, error cases)
- [ ] Integration test for the full session (happy path)
- [ ] Transition tests for each agent-to-agent boundary (with corrupted inputs)
- [ ] Stochastic invariant tests for the 3-5 most critical behavioral properties
- [ ] Network isolation verified (if web-enabled)
- [ ] Budget cap test (verify agent terminates cleanly when budget is exhausted)
- [ ] Compression test (verify agent behaves correctly at 80% and 95% context fullness)
- [ ] State recovery test (verify agent recovers from crash with correct state)

---

## Cross-Reference

- **What to test from each coordination pattern**: see D2 (coordination-and-state.md)
- **Memory tests (staleness, invalidation)**: see D3 (context-memory.md)
- **Compression behavior under test**: see D6 (context-compression.md)
- **Test trace analysis with observability**: see D8 (observability.md)
- **Disasters better testing would have prevented**: see D10 (production-disasters.md) — all 7 incidents are testable with pre-production validation
