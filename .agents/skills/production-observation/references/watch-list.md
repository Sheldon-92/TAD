# Watch List — What to Watch, How to Sample

The preparation reference for a Traces Hour. Everything here happens *before* the session; the session hour is for judgment, not for hunting data.

## 1. Data sources, by agent type

Watch the sources where the agent's real behavior is recorded — never a dashboard summary of them. Review works on raw traces; aggregates only choose where to look.

| Source | All agent types | Chat agents | Automation agents | Tool/API agents |
|--------|:---:|:---:|:---:|:---:|
| Full conversation / run logs (user turns + agent turns) | ✓ | ✓ | ✓ (run transcripts) | ✓ (request/response pairs) |
| Tool-call chains (call, args, result, latency, error) | ✓ | ✓ | ✓ | ✓ |
| Abandonment points (session ends mid-task, no completion) | ✓ | ✓ | ✓ (job killed/timeout) | ✓ (caller gave up / retried elsewhere) |
| User corrections in-conversation ("no, I meant…", rephrasing) | ✓ | ✓ | — | ✓ (caller re-sends corrected request) |
| Explicit feedback (thumbs, ratings, tickets, complaints) | ✓ | ✓ | ✓ | ✓ |
| Human overrides / manual completions after agent failure | ✓ | ✓ | ✓ | ✓ |
| Cost & latency outliers (top decile runs) | ✓ | ✓ | ✓ | ✓ |
| Downstream outcome signals (task actually succeeded in the world: booking held, file correct, payment matched) | ✓ | when available | ✓ | ✓ |

Rule: if a source in the agent's row does not exist, that absence is itself the first finding — file it as an instrumentation gap routed to the llm-observability surface, and run the session on what exists. Never cancel the session because one source is missing; never pretend a missing source was reviewed.

## 2. Sampling rules (stratified, not random-only, never full-read)

Weekly sample = the union of four strata. Sizes are defaults for a one-hour session; scale proportionally, never drop a stratum.

1. **All hard failures** (tool errors, crashes, human override, explicit negative feedback) — cap at 15; if more, take the 15 most recent and note the overflow count in the record.
2. **Random successes** — 5 completed runs drawn at random. Successes are reviewed to catch *silent* wrongness: the run "worked" and the result was still not what the user wanted. A practice that only reads failures trains itself blind to its most dangerous class.
3. **Abandonment stratum** — 5 sessions that ended mid-task. Read the last three exchanges/actions before the exit; the divergence is almost always upstream of the exit point.
4. **Outlier stratum** — 3 runs from the top cost/latency decile. Outliers concentrate novel tool-chain behavior — and novel failure classes.

Sampling is drawn by whoever prepares, using a recorded seed/query, and the sample manifest (stratum, selection rule, trace ids) is pasted into the session record. An unmanifested sample is unauditable: nobody can later tell whether a missing class was absent or just unsampled.

## 3. Privacy & redaction (before any human sees the sample)

- Strip or mask direct identifiers (names, emails, account ids, payment data) unless the identifier *is* the subject of the trace's failure.
- Traces containing credentials or secrets are excluded from the sample and routed as a security finding on the spot — a secret in a trace is a defect in the pipeline, not review material.
- Retention follows the host project's own rules; this pack sets none. When in doubt, redact more: a redacted trace still teaches its failure class.

## 4. Metrics snapshot (context for the session, never its subject)

Snapshot, recomputed at preparation time: run volume, completion rate, abandonment rate, tool-error rate, human-override rate, median + p90 cost/latency, explicit-feedback ratio. Paste into the record.

Vanity exclusions — do not snapshot, do not discuss: raw conversation counts with no denominator, average satisfaction over self-selected respondents only, "total tokens" as a success proxy. A metric that cannot move a routing decision is decoration.

## 5. Preparation checklist

- [ ] Sample drawn per §2, manifest recorded
- [ ] Redaction pass done per §3 (secrets excluded & routed)
- [ ] Metrics snapshot recomputed per §4
- [ ] Each trace linked to the design artifact it ran under (prompt/config/handoff version) — a trace without its version cannot be routed to a fix
- [ ] Last session's routed items listed with their current status (the loop's memory; see session-protocol.md §5)
