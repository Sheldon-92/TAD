---
name: production-observation
description: "Production observation capability pack for agents already deployed. Gives the judgment rules for the human trace-review practice (Traces Hour): what production data to watch, how to sample real traces, how to run the weekly review session, how to classify observed failures, and how to route every finding back into TAD's existing machinery (*bug, handoff, eval-case, knowledge). Use after an agent built with TAD ships — for post-deployment improvement, trace review, failure-class discovery, or 'the agent is live, now what' tasks. Does NOT cover instrumentation (how traces get emitted/collected — that is llm-observability) or automated eval design (that is ai-evaluation / the trajectory-eval harness)."
keywords: ["traces hour", "trace review", "生产观察", "上线后", "post-deployment", "部署后改进", "轨迹复盘", "失败分类", "failure taxonomy", "production traces", "生产轨迹", "agent 上线", "持续改进", "新失败类别"]
type: reference-based
---

**CONSUMES**: A deployed agent + access to its production traces (conversation logs, tool-call chains, user feedback) + the agent's design artifacts (handoff/prompt/config it was built from)
**PRODUCES**: A completed Traces Hour record (per `.tad/templates/traces-hour-record.md`) + routed findings (each with exactly one route: *bug / new handoff / eval-case candidate / knowledge candidate / no-action-with-reason) + named new failure classes

# Production Observation Capability Pack

**Version**: 0.1.0 (draft — landed unregistered; registration is a release step, see below)
**Compatibility**: Any harness that loads `.agents/skills/`
**License**: Apache 2.0

---

## What This Pack Does

TAD's lifecycle used to end at delivery: design → implement → Gate → ship. But an agent's real failure classes only exist in production, in real user conversations, and most of them are classes nobody predicted — which is precisely why pre-built eval datasets cannot contain them. PostHog's team found a weekly human review of real production traces ("Traces Hour") surfaces failure classes their automated evals structurally miss.

This pack is the human leg of post-deployment improvement. It answers the four questions the design phase cannot: **what to watch, how often, who watches, and where a finding goes.** It is a practice pack, not an instrumentation pack: it assumes traces exist (llm-observability covers emitting them) and automated evals exist (ai-evaluation / trajectory-eval covers running them). Its one job is the loop those two cannot close by themselves:

```
design → implement → Gate → deliver → OBSERVE → improve → redesign (loop)
```

**Pack = production-observation judgment. TAD gates = process constraint. No overlap.** This pack adds no gate and no lifecycle step; it feeds what it finds into the machinery TAD already has.

**When to use:** a TAD-built agent is live and someone asks "now what", schedules recurring trace review, or investigates a production complaint that no eval predicted.
**When NOT to use:** the agent has no production traces yet (instrument first — llm-observability); the task is designing an automated benchmark (ai-evaluation); a single known defect needs fixing (go straight to *bug).

---

## Cross-Cutting Rule: The Session Produces Routes, Not Fixes

> **No finding is closed inside the session. Every reviewed trace leaves with exactly one disposition and an owner — or it was not reviewed, only read.**

Why: the moment a Traces Hour starts fixing prompts at the table, it becomes an unreviewed change channel — the exact bypass the gates exist to prevent (an in-session prompt edit has no handoff, no review, no evidence). The session's product is a set of *routed* findings; fixes travel the normal paths and get their normal scrutiny. A session that ends with edits but no routes has destroyed evidence and produced unreviewed change.

---

## Step 0: Context Detection

Read the user's task. Match against the signal table below. Load the matching reference file(s).

| Signal in User Task | Reference to Load | What It Covers |
|---------------------|-------------------|----------------|
| run a traces hour / weekly review / 复盘 / 看这周的轨迹 | `references/session-protocol.md` | Cadence, roles, timebox, per-trace review loop, session outputs |
| what to watch / sampling / 看什么数据 / 抽样 / 上线后看什么 | `references/watch-list.md` | Data sources per agent type, sampling rules, redaction, vanity-metric exclusions |
| classify a failure / routing / 发现问题怎么办 / new failure class / 新失败类别 | `references/failure-taxonomy-and-routing.md` | Failure classes F1–F6 + NEW, routing table, escalation thresholds, eval-case conversion |
| "review everything" / "set up observation from scratch" | Load ALL references | Full practice setup |

**If no signal matches:** ask which deployed agent and which data source — do not invent a trace source.

## Step 1: Run the Practice

1. **Prepare** (before anyone sits down): pull the sample per `watch-list.md` sampling rules; redact per its privacy rules; snapshot the week's headline metrics. Preparation is mechanical — never let the session spend its hour hunting for traces.
2. **Review** (the session itself): follow `session-protocol.md`. Per trace: what did the user actually want → where did the run diverge → which class → which disposition. Human-domain calls (taste, direction, perception) go to the human as *choices*, never as verification questions.
3. **Route** (same day, before the record is filed): every finding gets its route per `failure-taxonomy-and-routing.md`. New classes get named in the session, not "miscellaneous".

## Step 2: Output

File the completed session record from `.tad/templates/traces-hour-record.md`. Its non-negotiable contents:

```
## Traces Hour: {agent} — {date}

### Sample & metrics snapshot   (from watch-list rules; counts recomputed, not copied)
### Per-trace findings          (trace id | user goal | divergence point | class | disposition | route target)
### New failure classes named   (name + one-line signature + exemplar trace id)
### Eval-case candidates        (findings converted for the trajectory-eval harness)
### Routed items                (id + route + owner — every finding appears here or in no-action-with-reason)
```

---

## Anti-Skip Table

| Excuse | Why It's Wrong | Counter |
|--------|---------------|---------|
| "Evals are green, skip this week" | Green evals only prove the *known* classes didn't regress. The session exists to find classes the evals don't contain. | A green week is when a short session is cheapest — run it at half sample, never zero. |
| "Just fix the prompt here at the table" | An in-session edit is an unreviewed change with no handoff and no evidence; it also destroys the trace's value as a before-state. | Route it: F3 goes to a spec/prompt fix through the normal path with review. |
| "Read every trace, sampling might miss something" | Full reads collapse under real volume within weeks and the practice dies; a stratified sample (all failures + random successes + edge strata) has higher class-discovery yield per hour. | Sample per watch-list rules; widen a stratum only when a class is suspected there. |
| "Users aren't complaining, so it's fine" | Abandonment is silent: users who leave mid-task file no complaint. Complaints are the smallest, most biased stratum of failure evidence. | The watch list includes abandonment and silent-failure strata precisely because they never self-report. |
| "That failure is a one-off, don't log it" | A class is a one-off until the third time — and without the first two logged, the third is invisible as a pattern. | Log every finding with a class or NEW; the routing thresholds, not the table's mood, decide what escalates. |

---

## Division of Labor (read before duplicating another mechanism)

| Mechanism | Leg | Owns | Does NOT own |
|-----------|-----|------|--------------|
| trajectory-eval harness | automated | Regression detection over known classes, wide coverage | Discovering new classes |
| **This pack (Traces Hour)** | human | New-class discovery, judgment-domain calls, routing | Fixing anything at the table |
| llm-observability pack | instrumentation | Emitting/collecting traces, cost & latency attribution | Reviewing what traces mean |
| Knowledge lifecycle (KA/distill) | memory | Turning repeated findings into durable knowledge | Per-week routing |
