---
name: subagent-model-routing
description: "Pick a subagent's model by capability tier (design top, review/execution mid, mechanical checks cheap); never write concrete model names into TAD artifacts"
metadata:
  node_type: memory
  type: feedback
  originSessionId: da31115e-cc41-4e1b-84fc-5a9166d68aeb
  modified: 2026-10-13T20:26:53.665Z
---

When I conduct TAD work through subagents, pick each subagent's model by the kind of work, expressed as a **tier**, not a model name:

- **Design (Alex subagent)** → the strongest tier the harness offers.
- **Review and execution (reviewers, Blake subagent)** → the middle tier.
- **Purely mechanical judgment** (a check with a fixed criterion, listing, counting, format validation) → the cheapest tier.

**Do not write concrete model names into anything TAD ships or keeps** — skills, protocols, Epics, handoffs, templates, design docs. Write the tier and let the harness map it.

**Why:** Sheldon gave the tiering on 2026-10-13 while I was conducting EPIC-20261013 (the Cora role) on Claude Code, naming Opus 5.5 / Sonnet 5.5 / Haiku 5.5. I recorded those names in the Epic, the session state and this memory. He corrected me the same day: the names are only how the tiers map in Claude Code right now; models keep changing, and other harnesses do not have these models at all, so a rule written with model names is wrong the moment it is read anywhere else.

**How to apply:** In a Claude Code session today the mapping is top = Opus, middle = Sonnet, cheapest = Haiku — use it when spawning, and re-check it against what the session actually offers rather than trusting this line. In any written artifact say "strongest / middle / cheapest tier" (TAD's config already uses `capability-tier` wording). On another harness, map the tiers to whatever that harness has; if it has only one model, the tiering simply does not apply. My own reading, not his words: inventory and grounding reads count as execution (middle tier).

Related: [[yolo-epic-workflow-args]], [[execution-review-separation]]
