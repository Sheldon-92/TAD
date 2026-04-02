#set document(title: "Menu Snap AI — Multi-Agent Design Analysis", author: "TAD Domain Pack: ai-agent-architecture")
#set page(paper: "a4", margin: (x: 2cm, y: 2.5cm))
#set text(font: "New Computer Modern", size: 11pt)
#set heading(numbering: "1.1")

#align(center)[
  #text(size: 24pt, weight: "bold")[Menu Snap AI]
  #v(0.3em)
  #text(size: 16pt, fill: rgb("#555"))[Multi-Agent Design Analysis]
  #v(0.5em)
  #text(size: 11pt, fill: rgb("#777"))[TAD Domain Pack: ai-agent-architecture | Capability: multi_agent_design]
  #v(0.3em)
  #text(size: 11pt, fill: rgb("#777"))[2026-04-02]
  #v(0.5em)
  #line(length: 60%, stroke: 0.5pt + rgb("#ccc"))
]

#v(1em)

#rect(fill: rgb("#E8F5E9"), radius: 4pt, width: 100%, inset: 12pt)[
  #text(weight: "bold", size: 13pt)[Verdict: Single Agent + Tool Suite]
  #v(0.3em)
  Menu Snap AI does *not* need a multi-agent architecture. A single agent with four specialized tools handles all capabilities (vision, recommendation, allergy checking, memory) with lower cost, simpler debugging, and faster response times.
]

#v(1em)

= Research Summary

== Multi-Agent Frameworks (2026 Landscape)

#table(
  columns: (1fr, 1.5fr, 1.5fr, 1.5fr),
  inset: 8pt,
  fill: (_, row) => if row == 0 { rgb("#E3F2FD") } else { none },
  [*Framework*], [*Orchestration*], [*Strength*], [*Weakness*],
  [LangGraph], [DAG with conditional edges], [State checkpointing], [Steep learning curve],
  [CrewAI], [Role-based crews], [Intuitive team metaphor], [Limited state mgmt],
  [AutoGen/AG2], [Event-driven GroupChat], [Iterative refinement], [Complex for simple cases],
)

#v(0.5em)

== Claude Code Execution Levels

#table(
  columns: (1fr, 1.5fr, 2fr),
  inset: 8pt,
  fill: (_, row) => if row == 0 { rgb("#FFF3E0") } else { none },
  [*Level*], [*Communication*], [*Use Case*],
  [Sub-agent], [Return value only], [Single focused task],
  [Coordinator], [Aggregates results], [Parallel independent tasks],
  [Agent Teams], [File-based P2P mailbox], [Complex multi-step collaboration],
)

#v(0.5em)

== Documented Failures

- *\$47,000 recursive loop* --- Two agents talked non-stop for 11 days with no circuit breaker.
- *"Politeness loops"* --- Agents confirming each other without progress, exhausting API budgets.
- *"17x error trap"* --- Bag-of-agents approach multiplies errors vs. single-agent baseline.

*2026 consensus*: Loop detection must be mechanical (counters, state hashes, timeouts). Never ask an agent "are you in a loop?"

= Critical Analysis: Does Menu Snap Need Multi-Agent?

== The Honest Answer: No.

#table(
  columns: (1.5fr, 1fr, 2fr),
  inset: 8pt,
  fill: (_, row) => if row == 0 { rgb("#FFEBEE") } else { none },
  [*Capability*], [*Single Agent?*], [*Reasoning*],
  [Menu photo analysis], [YES], [Single vision API tool call],
  [Dish recommendation], [YES], [Core LLM reasoning over structured data],
  [Allergy checking], [YES], [Deterministic rule-based lookup],
  [Past order memory], [YES], [Vector DB retrieval tool],
)

#v(0.5em)

The critical test: do any two capabilities need to _negotiate_, _disagree_, or _independently explore_ to produce a result? *No.* Data flows in a clear sequential pipeline:

#align(center)[
  #rect(fill: rgb("#F5F5F5"), radius: 4pt, inset: 10pt)[
    Photo → Vision Tool → Menu Items → Filter + Rank → Memory → Output
  ]
]

== Why Multi-Agent Would Be Wrong

#table(
  columns: (1.5fr, 2.5fr),
  inset: 8pt,
  fill: (_, row) => if row == 0 { rgb("#FCE4EC") } else { none },
  [*Multi-Agent Cost*], [*Impact on Menu Snap*],
  [Communication overhead], [Agents serializing menu data to talk --- pointless when one agent already has it],
  [Coordination complexity], [Orchestrator needed for a simple 4-step pipeline],
  [Debugging difficulty], [Tracing allergy failures across agent boundaries],
  [Cost multiplication], [3--4x token usage for inter-agent context passing],
  [Latency], [+2--5 seconds per agent hop],
)

== When Would Multi-Agent Be Justified?

Multi-agent becomes necessary only at significantly larger scale:
- *Multi-restaurant concurrent ordering* --- parallel fan-out to different APIs
- *Real-time POS integration* --- separate agent per restaurant system
- *Group ordering coordination* --- per-person agents negotiating shared dishes

Current scope (single user, single menu photo) does not justify this.

= Chosen Architecture: Single Agent + Tool Suite

== Component Design

#table(
  columns: (1.2fr, 1.5fr, 1fr, 0.8fr),
  inset: 8pt,
  fill: (_, row) => if row == 0 { rgb("#E8F5E9") } else { none },
  [*Component*], [*Implementation*], [*Model Tier*], [*Cost*],
  [Core Agent], [LLM with tool-use], [Tier 1 (Sonnet)], [\$0.03],
  [Vision Tool], [Vision API for OCR], [Tier 1 (vision)], [\$0.01],
  [Allergy Checker], [Allergen DB lookup], [No LLM], [\$0.00],
  [Preference Matcher], [Scoring function], [Tier 3 / rules], [\$0.005],
  [Memory Tool], [Vector DB query], [No LLM], [\$0.005],
)

== Tool Isolation

#table(
  columns: (1.2fr, 1.2fr, 1.2fr, 1fr),
  inset: 8pt,
  fill: (_, row) => if row == 0 { rgb("#E0F7FA") } else { none },
  [*Tool*], [*File Access*], [*Network*], [*Write State?*],
  [Vision Tool], [Read: photo only], [Vision API], [No],
  [Allergy Checker], [Read: allergen DB], [None], [No],
  [Preference Matcher], [Read: user profile], [None], [No],
  [Memory Tool], [R/W: history], [Vector DB], [Yes (append)],
)

*Principle*: Only Memory Tool can write state. All others are pure functions.

== Budget Ceilings

#rect(fill: rgb("#FFF3E0"), radius: 4pt, width: 100%, inset: 12pt)[
  #table(
    columns: (2fr, 1fr, 1.5fr),
    inset: 6pt,
    [*Resource*], [*Ceiling*], [*Circuit Breaker*],
    [Vision API calls / req], [2], [Hard stop after 2],
    [LLM tokens / session], [10,000], [Truncate if > 8K input],
    [Total cost / request], [\$0.05], [Abort if exceeded],
    [Memory queries / session], [5], [Return "no history"],
    [End-to-end latency], [10 sec], [Timeout, partial results],
    [Monthly / user], [\$5.00], [Disable + notify user],
  )
]

*Formula*: Cost/request = Vision(\$0.01) + LLM(\$0.03) + Memory(\$0.005) + 20% buffer = approx \$0.054

== Loop Detection (Mechanical)

#table(
  columns: (1.5fr, 2.5fr),
  inset: 8pt,
  fill: (_, row) => if row == 0 { rgb("#FCE4EC") } else { none },
  [*Mechanism*], [*Implementation*],
  [Tool call counter], [Max 8 calls per session --- hard stop],
  [Repeat detector], [Same tool + same params 3x --- abort],
  [State hash], [Hash working memory after each call; 2 identical = loop],
  [Wall-clock timeout], [30 second total session limit],
)

Detection leads to action: Return best partial result + log for review. *Never ask the agent "are you stuck?"*

== Lifecycle

- *Startup*: On-demand per user request. No persistent agent.
- *Execution*: Sequential tool pipeline (Vision, Memory, Allergy, Preference, Output).
- *Shutdown*: Session ends after response delivered.
- *Recovery*: Stateless pipeline --- retry from start. Idempotent Memory writes via request ID.

= Architecture Diagram

#align(center)[
  #image("architecture.svg", width: 95%)
]

= Conclusion

Menu Snap AI is a *tool-use problem*, not a *multi-agent collaboration problem*. The recommendation pipeline is sequential, data flows in one direction, and no capability requires autonomous negotiation. A single agent with four tools delivers:

- *Lower cost*: approx \$0.05/request vs approx \$0.15--0.20 with multi-agent
- *Simpler debugging*: Single conversation trace
- *Faster response*: No inter-agent latency
- *Easier maintenance*: One agent to update, not 3--4

Multi-agent should only be reconsidered when Menu Snap scales to multi-restaurant concurrent ordering or group dining coordination.

#v(2em)
#line(length: 100%, stroke: 0.3pt + rgb("#ccc"))
#v(0.5em)
#text(size: 9pt, fill: rgb("#999"))[
  Generated by TAD ai-agent-architecture Domain Pack | multi\_agent\_design capability \
  Sources: gurusup.com, datacamp.com, code.claude.com, techstartups.com, cogentinfo.com, galileo.ai, langchain.dev, decodingai.com
]
