# Traces Hour Record: {{agent-name}} — {{YYYY-MM-DD}}

> One record per session. Filed by the facilitator the same day.
> Method: production-observation pack (`references/session-protocol.md`); sampling per `references/watch-list.md`; classes & routes per `references/failure-taxonomy-and-routing.md`.

- **Agent / version under review**: {{name}} ({{prompt/config/handoff version the sampled traces ran under}})
- **Facilitator**: {{name/role}}
- **Domain judge**: {{name}}
- **Session #**: {{n}} · **Period covered**: {{start}} → {{end}} · **Trigger**: weekly / run-threshold ({{N}} runs)

## 1. Sample manifest

| Stratum | Selection rule | Count | Trace ids |
|---------|---------------|-------|-----------|
| Hard failures | {{all / 15 most recent + overflow count}} | | |
| Random successes | {{seed / query used}} | | |
| Abandonment | {{definition used for this agent}} | | |
| Cost/latency outliers | top decile | | |

Redaction pass: done / exceptions: {{none | list}}

## 2. Metrics snapshot (recomputed at preparation)

| Metric | This week | Last week |
|--------|-----------|-----------|
| Run volume | | |
| Completion rate | | |
| Abandonment rate | | |
| Tool-error rate | | |
| Human-override rate | | |
| Cost median / p90 | | |
| Latency median / p90 | | |
| Explicit-feedback ratio | | |

What moved, in one line: {{}}

## 3. Carry-over from last session

| Routed item | Route | Status now | Action (continue / escalate) |
|-------------|-------|-----------|-------------------------------|
| | | | |

## 4. Per-trace findings

| # | Trace id | User goal (one line) | Divergence point | Class | Disposition |
|---|----------|----------------------|------------------|-------|-------------|
| 1 | | | | | |
| 2 | | | | | |

Disposition vocabulary: routed (→ §6 id) / no-action — {{reason}}. One trace with multiple problems = multiple rows.

## 5. New failure classes named

| Candidate name | One-line signature | Exemplar trace id |
|----------------|--------------------|-------------------|
| | | |

(none) is a valid entry — write it explicitly; a blank section reads as unexamined.

## 6. Routed items

| Route id | Class | Destination | Artifact / queue id | Owner | Escalated same-day? (§3 threshold hit) |
|----------|-------|-------------|---------------------|-------|----------------------------------------|
| | | *bug / handoff / eval-case / knowledge / watch-list amendment | | | |

## 7. Eval-case candidates filed

| Trace id | Class | Divergence point | Expected behavior |
|----------|-------|------------------|-------------------|
| | | | |

## 8. Session notes

- Taxonomy strain (NEW share of findings): {{x}}% {{— if >20% twice running, taxonomy repair is next session's first item}}
- Watch-list gaps found (sources missing in §1 of the watch list): {{}}
- Next session: {{date}} · forced strata / widened strata: {{}}
