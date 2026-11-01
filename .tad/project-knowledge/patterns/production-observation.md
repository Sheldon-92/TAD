# Production Observation — The Lifecycle Does Not End at Delivery

## Rule

An agent built with TAD enters a second loop at delivery: **observe → improve → redesign**. Delivery is the midpoint of the lifecycle, not its end. What runs this loop is a recurring human trace review (Traces Hour, weekly or per 200 completed runs): real production traces are sampled, read raw, classed by where they first diverged, and every finding is routed into machinery TAD already has. The practice lives in the `production-observation` capability pack (`.agents/skills/production-observation/`); the session record template is `.tad/templates/traces-hour-record.md`.

## Why a human leg at all

Automated evals detect regression in failure classes already known. Production's most valuable failures are classes nobody predicted — they exist in no eval set by construction. A human reading raw traces is currently the only instrument that discovers a *new* class. Conversely, humans cannot watch everything: the division of labor is fixed —

| Leg | Instrument | Finds |
|-----|-----------|-------|
| Automated | trajectory-eval harness | Recurrence of known classes, at scale |
| Human | Traces Hour (this pattern) | New classes; human-domain mismatches (taste/direction/perception) |
| Instrumentation | llm-observability pack | The traces themselves; cost/latency attribution |

Closure rule between the legs: every reasoning/instruction finding the human leg routes is also filed as an eval-case candidate, so once the automated leg adopts it, the human leg never has to find that class twice.

## Load-bearing constraints

- **Routes, not fixes.** The review session never edits a prompt, config, or code. An in-session edit is an unreviewed change with no handoff and no evidence — the exact bypass the gates exist to prevent. The session's product is routed findings with owners.
- **Class determines route.** Classification is by first divergence point, and the destination follows mechanically (capability miss → handoff; tool failure → *bug; instruction defect → change path with review; human-domain mismatch → add a choice point; drift → handoff + watch-list amendment; unclassifiable → named NEW, a knowledge candidate). If classification feels arbitrary, the taxonomy is the failing component — a NEW share above ~20% twice running makes taxonomy repair the next session's first item.
- **Raw traces or it didn't happen.** Review reads raw traces, never the agent's self-summary of its own run — a self-summary of a failure is a claim, not evidence. Sampling is stratified (all hard failures + random successes + abandonment + outliers) with a filed manifest; the random-success stratum exists because silent wrongness — successful runs with wrong results — surfaces nowhere else.
- **Human-domain calls are choices, not verifications.** Where divergence is taste/direction/perception, the human picks from a shortlist; "is this OK?" is a rubber-stamp question and is banned at the table (see principles: AI/Human Judgment Domain Awareness).

## failure_mode

Naive default A: ship and stop — the lifecycle ends at Gate 4, production failures accumulate invisibly, and the first systematic look happens after a user-facing incident, with no sampled history to learn from.
Naive default B: dashboard-only observation — aggregates show rates moving but no raw trace is ever read, so new failure classes stay invisible behind healthy-looking averages (a completion rate can rise while silent wrongness rises faster).
Naive default C: the review that fixes — the session becomes a shadow change channel; prompts drift away from every reviewed artifact and the next incident cannot be traced to any decision.
