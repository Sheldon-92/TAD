# Session Protocol — Running a Traces Hour

## 1. Cadence & timebox

- **Weekly**, or after every **N=200 completed runs**, whichever comes first. High-volume agents hit the run threshold; low-volume agents keep the weekly floor so drift never ages past seven days unobserved.
- **60 minutes**, hard stop. Overflow findings are logged unread-in-detail with a class guess and carried to next week's sample as a forced stratum — the timebox is what makes the practice survivable, and a survivable practice beats a thorough one that gets cancelled.
- Same slot every week. A practice that needs scheduling negotiation each time will lose to whatever shouts loudest.

## 2. Roles

| Role | Who | Does |
|------|-----|------|
| Facilitator | The agent's designer side (Alex-role in TAD terms) | Prepares the sample (watch-list.md), runs the per-trace loop, writes the record, owns routing follow-through |
| Domain judge | The human who owns the agent's purpose | Answers human-domain calls — taste, direction, perception — as **choices** (pick from a shortlist the facilitator presents), never as verification ("is this output OK?" is a rubber-stamp question and is banned at the table) |
| Implementer side | Blake-role, optional attendee | Answers "what would that fix actually touch" feasibility questions; takes no fix away from the table — fixes arrive later, through their routed path |

One person may hold facilitator + implementer in small teams; the domain-judge role may not be delegated to the facilitator. The whole point of the hour is a judgment the builders do not carry.

## 3. Agenda (60 min)

| Block | Min | Content |
|-------|-----|---------|
| Carry-over check | 5 | Last session's routed items: landed? stuck? A route with no movement two weeks running is escalated on the spot (see §5). |
| Metrics snapshot | 5 | Read the snapshot (watch-list §4). One question only: what moved, and does the sample explain it? |
| Per-trace review | 40 | The loop in §4, trace by trace, in stratum order: hard failures → abandonment → outliers → random successes. |
| Routing sweep | 10 | Every finding gets its class + disposition + owner (failure-taxonomy-and-routing.md). New classes are named here if not already. Record is completed and filed before anyone leaves. |

## 4. The per-trace loop

For each trace, in order, out loud:

1. **User goal** — what did the user actually want, in one sentence, from the trace alone (not from the agent's summary of it)?
2. **Divergence point** — the first turn/action where the run left the path to that goal. Not the last error: the *first* divergence. Everything after it is consequence.
3. **Class** — assign from the taxonomy. If nothing fits, say so — that is a NEW candidate, the highest-value output of the hour (see taxonomy reference).
4. **Disposition** — route per the taxonomy's routing table, or no-action-with-reason (reason stated in one line; "seems fine" is not a reason, "user error, agent recovered correctly, trace id is the evidence" is).

Discipline inside the loop:

- Read the **raw trace**, never the agent's self-summary of the session. An agent's summary of its own failure is a claim, not evidence.
- One trace, one divergence point. A trace with three problems is three findings sharing a trace id.
- Disagreement about class is resolved by the divergence point, not by seniority: the class describes where it diverged, and the routing follows the class mechanically.
- Human-domain divergence (the output was competent and still not what anyone would want) is called by the domain judge, and the facilitator does not argue it back into a technical class.

## 5. Follow-through (the loop's memory)

- The facilitator files the record (template: `.tad/templates/traces-hour-record.md`) the same day.
- Routed items are checked at the next session's carry-over block. An item unmoved after **two** sessions is escalated to whoever owns the routed path (the handoff queue, the bug queue) with the session records as evidence — silent expiry is the failure mode this protocol exists to prevent.
- A failure class that reaches its escalation threshold (taxonomy reference §3) stops waiting for the weekly rhythm: its work item is opened the same day, and the session is merely notified.

## 6. What the session never does

- Never edits a prompt, config, or line of code (cross-cutting rule: routes, not fixes).
- Never re-runs the agent "to see if it still does that" as a substitute for routing — a re-run is a test, and tests belong to the eval leg with the trace filed as its case candidate.
- Never expands the sample mid-session because one class looks interesting — note the suspicion, widen that stratum *next* week, keep this week's manifest honest.
