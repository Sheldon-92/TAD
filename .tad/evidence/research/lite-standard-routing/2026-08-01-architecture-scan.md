# Research Evidence: Lite / Standard / Full Routing

**Date**: 2026-08-01
**Question**: What established agent-workflow patterns should constrain TAD's depth routing and shared-state design?

## Sources

1. Anthropic, *Building Effective AI Agents: Architecture Patterns and Implementation Frameworks* (PDF, published 2026-05):
   https://resources.anthropic.com/hubfs/Building%20Effective%20AI%20Agents-%20Architecture%20Patterns%20and%20Implementation%20Frameworks.pdf
   - Implication: keep workflow structure explicit; routing is a control-flow decision, not a new worker identity.
2. LangGraph, *Persistence*:
   https://docs.langchain.com/oss/python/langgraph/persistence
   - Implication: human review, memory continuity and recovery require explicit persisted checkpoints/state carriers.
3. LangGraph, *Workflows and agents*:
   https://docs.langchain.com/oss/python/langgraph/workflows-agents
   - Implication: predetermined workflows and dynamic agents are different concerns; evaluator/optimizer loops need explicit feedback and stop conditions.
4. LangChain, *Human-in-the-loop*:
   https://docs.langchain.com/oss/python/langchain/human-in-the-loop
   - Implication: irreversible or high-risk actions need an interrupt before execution and an explicit resume decision.

## Design Consequences

- Standard is a depth profile layered over the same role, not another peer agent.
- Route decisions need a stable contract with a reason, authority, state transition and evidence carrier.
- Shared `.tad/` files act as the persisted state boundary; chat text alone is not a durable carrier.
- Full routing must be decided before any protocol-contract write or fatal operation; user preference cannot lower a fatal route.
