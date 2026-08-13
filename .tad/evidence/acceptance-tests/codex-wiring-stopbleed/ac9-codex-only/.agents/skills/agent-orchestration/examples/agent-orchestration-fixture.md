---
name: swarm-300-step-orchestration-review
description: "Tests the Complexity-Cliff P(fail) formula + O(n²) swarm failure-surface rule + durable-execution mandate on a long-running multi-agent design"
pack: agent-orchestration
tests_rules:
  - "Cross-Cutting Rule: Complexity Cliff P(fail) = 1 - (1-p)^s (63.4% at 100 steps)"
  - "SUP3: Swarm directed-handoff failure surface O(n²) = n(n-1) (10 agents = 90 pathways)"
  - "SUP4: Swarm semantic drift after 8-10 turns"
  - "DUR1/DUR2: above the cliff use Temporal event sourcing, resume from event log not step 1"
  - "OW1: orchestrator-worker costs ~15x chat tokens; 90.2% improvement only pays off for parallelizable breadth"
  - "OW3: single-writer principle — peer subagents w/ conflicting implicit decisions can't be combined"
  - "FM1/FM2: MAST taxonomy 42% spec / 37% misalignment / 21% verification — fix the spec before the topology"
min_marker_count: 4
# DISCRIMINATIVE gate: ONLY pack-specific markers (named rules, pack-introduced
# numbers/formulas from research). Excludes generic agent vocabulary
# ("multi-agent", "checkpoint", "retry"), severity tags, and words from the input
# scenario ("300 steps", "10 agents"). These are markers a WITH-pack agent emits
# that a no-pack agent would NOT: the cliff formula, the n(n-1) directed-handoff
# surface, the 63.4% figure, event-sourcing replay, the 20-40% supervisor tax,
# the ~15x token multiplier + 90.2% improvement (OW1), and the MAST 42/37/21 split.
discriminative_pattern: "1 ?- ?\\(1 ?- ?p\\)\\^s|63\\.4%|99\\.3%|n\\(n ?- ?1\\)|O\\(n.?2\\)|event[ -]sourc|complexity cliff|20.?40% token|8.?12 (round|turn)|15x|90\\.2%|single.?writer|42%.*spec|MAST"
min_discriminative: 3
---

# Fixture: Long-Running Swarm Orchestration Review

## Input Scenario

"I'm building an autonomous research agent that runs about 300 sequential tool/LLM steps per task. I'm using a fully-connected swarm of 10 specialist agents that hand off to each other with no shared context, and I wrap everything in a try/except retry loop so it restarts if it crashes. It keeps producing incoherent final reports and sometimes stops before finishing. I figure I'll just upgrade to a bigger model. Review my orchestration design and tell me why it's failing."

## Expected Markers

When an AI agent processes the Input Scenario with the agent-orchestration pack loaded,
the output MUST contain these markers:

1. **Complexity-Cliff computation** [structural]: the agent computes cumulative failure with the pack's formula and a concrete percentage — not a generic "it might fail"
   grep pattern: `1 ?- ?\(1 ?- ?p\)\^s|P\(fail\)|63\.4%|99\.3%|complexity cliff`
2. **O(n²) swarm failure surface** [structural]: the agent applies n(n-1) directed handoffs and names the pathway count for the stated agent count
   grep pattern: `n\(n ?- ?1\)|O\(n.?2\)|90 (directed |handoff )?(pathways|failure)|quadratic`
3. **Swarm semantic drift bound**: the agent flags drift past the 8-10 turn threshold
   grep pattern: `8.?10 (sequential )?(agent )?turn|semantic drift`
4. **Durable-execution mandate**: the agent rejects the bare retry loop in favor of event-sourced replay that resumes from the log, not step 1
   grep pattern: `event[ -]sourc|Temporal|resume.*(event log|exact point)|not.*step 1`
5. **Supervisor trade-off awareness**: if recommending a supervisor, the agent cites the token tax / saturation numbers
   grep pattern: `20.?40% token|8.?12 (round|turn)|context (window )?saturat`
6. **Orchestrator-worker economics** [OW1]: the agent reasons about the ~15x token multiplier / 90.2% improvement instead of treating multi-agent as free reliability
   grep pattern: `15x|90\.2%|orchestrator.?worker`
7. **Single-writer / coherence failure** [OW3]: the agent names WHY no-shared-context peers produce incoherent output (conflicting implicit decisions / single-writer)
   grep pattern: `single.?writer|conflicting (implicit )?decision|shared (full )?(agent )?trace`
8. **MAST design-over-model diagnosis** [FM1/FM2/FM5]: the agent rejects "just use a bigger model" and cites the spec/coordination/verification split
   grep pattern: `MAST|42%|37%|21%|spec(ification)? failure|design.*not.*(bigger )?model`

## Verification Command

```bash
grep -oE '1 ?- ?\(1 ?- ?p\)\^s|63\.4%|99\.3%|complexity cliff|n\(n ?- ?1\)|O\(n.?2\)|quadratic|8.?10 (sequential )?(agent )?turn|semantic drift|event[ -]sourc|Temporal|20.?40% token|8.?12 (round|turn)|15x|90\.2%|single.?writer|MAST|42%' agent-orchestration-fixture-output.md | sort -u | wc -l | tr -d ' '
# Expected: ≥ 4
```

## Anti-Slop Check

These markers are pack-specific (would NOT appear without the pack):
- ✅ "P(fail) = 1 - (1-p)^s → 63.4% at 100 steps / 99.3% at 500" (the pack's named complexity-cliff formula + the exact figures from research [2])
- ✅ "n(n-1) → 90 directed handoff pathways for 10 agents" (the pack's quadratic swarm failure-surface law [23])
- ✅ "semantic drift after 8-10 agent turns" (the pack's specific swarm-drift threshold [23])
- ✅ "event-sourcing replay resumes from the event log, not step 1" (the pack's Temporal durability rule [2,29,30])
- ✅ "20-40% token tax / context saturates after 8-12 round trips" (the pack's supervisor-cost numbers [23])
- ✅ "orchestrator-worker costs ~15x chat tokens; the 90.2% improvement only pays off for parallelizable breadth" (OW1, Anthropic multi-agent research system)
- ✅ "no-shared-context peers make conflicting implicit decisions → incoherent output; use a single-writer / single-threaded linear agent" (OW3, Cognition single-writer principles)
- ✅ "MAST: 42% spec / 37% misalignment / 21% verification — fix the spec and add a verifier, don't just upgrade the model" (FM1/FM2/FM4/FM5, MAST arXiv 2503.13657)
- ❌ "use a multi-agent framework" (generic — any agent says this with no pack)
- ❌ "add error handling / checkpoints" (generic — no specific formula or threshold)
- ❌ "10 agents may be too many" (restates the input without the n(n-1) directed-handoff law)
- ❌ "make it more reliable" (generic, non-discriminative)
- ❌ "a bigger model will help" (the exact anti-pattern FM5 rejects — non-discriminative without the MAST design-over-model framing)
