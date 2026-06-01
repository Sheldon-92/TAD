# State Persistence & Time-Travel Rules (LangGraph)
<!-- capability: state_persistence -->

## Quick Rule Index

| # | Rule | determinismLevel |
|---|------|-----------------|
| SP1 | Checkpoint at every super-step boundary; no persistence = restart-from-zero on crash | deterministic |
| SP2 | Use a durable backend in production — MemorySaver is prototyping only | deterministic |
| SP3 | Time travel has two distinct ops: Replay (rerun) vs Fork (branch) | deterministic |
| SP4 | Subgraph time-travel depends on the checkpointer compile flag | semi-deterministic |
| SP5 | HITL interrupts gate high-risk actions via interrupt_before / interrupt_after | deterministic |
| SP6 | Tune production checkpointers: compression, TTL pruning, S3 offload | semi-deterministic |

---

## Rules

### SP1: Checkpoint at Every Super-Step Boundary

In LangGraph, multi-actor workflows pass a shared state object (a Blackboard) node to node. **Without persistence, an API timeout or container crash forces the entire workflow to restart from the beginning.** A **checkpointer** intercepts the workflow at every execution step ("super-step" boundary), serializes the active Blackboard JSON state, and commits it under a unique **thread ID** and deterministic version hash. On failure, the orchestrator re-hydrates the last successful checkpoint and resumes without repeating prior steps.

> Source: findings.md "State Persistence, Checkpoint-Based Replay, and Time Travel" [7, 8, 24]

Checkpointing also serves as an **audit flight-recorder** — for regulated domains (credit underwriting, medical triage, security ops) immutable checkpoint logging of intermediary node states is the technical mitigation for discrimination-lawsuit and regulatory-fine exposure.

> Source: findings.md "State Persistence" — Risk Category table [27]

**determinismLevel**: deterministic.

### SP2: Durable Backend in Production

`MemorySaver` (in-memory) is for local prototyping ONLY. Production workloads require a durable backend:

- `PostgresSaver` (PostgreSQL)
- `CouchbaseSaver` (Couchbase)
- `DynamoDBSaver` (AWS DynamoDB)

> Source: findings.md "State Persistence" [7, 8, 25, 26]

**Rule**: Shipping `MemorySaver` to production means every restart loses all checkpoints — defeating the entire purpose.

**determinismLevel**: deterministic.

### SP3: Time Travel — Replay vs Fork

Checkpoint history enables two distinct time-travel capabilities — do not conflate them:

1. **Replay**: call `get_state_history` to retrieve past checkpoints, reload a specific historical checkpoint ID, and re-execute the graph forward from that point. (Re-runs the SAME timeline.)
2. **Fork**: use `update_state` to modify parameters on an older checkpoint, creating a NEW execution branch under the same thread ID — preserving the original timeline for auditing while exploring an alternative trajectory.

> Source: findings.md "State Persistence" — time-travel capabilities [24, 28, 29, 30]

**Rule**: Use Replay to debug "what happened"; use Fork to test "what if" without destroying the original trajectory. Forking is the non-destructive option for scenario exploration.

**determinismLevel**: deterministic.

### SP4: Subgraph Time-Travel Depends on the Compile Flag

For nested multi-agent workflows, time-travel granularity is set at compile time:

- **Default** (subgraph inherits parent checkpointer): the parent treats the entire subgraph execution as a single atomic step. Time-traveling to any point before the subgraph forces the WHOLE subgraph to re-execute from scratch.
- **`checkpointer=True`** on the subgraph: establishes an isolated checkpoint history. You can then query internal states via `get_state(subgraphs=True)` and execute precise rollbacks between individual nodes inside the subgraph.

> Source: findings.md "State Persistence" — nested subgraph time-travel [29, 30]

**Rule**: If you need node-level rollback inside a subgraph, you MUST compile it with its own checkpointer — the default gives you only atomic whole-subgraph replay.

**determinismLevel**: semi-deterministic — behavior is determined by the compile flag.

### SP5: HITL Interrupts Gate High-Risk Actions

Checkpointing enables Human-in-the-Loop workflows via **`interrupt_before`** and **`interrupt_after`**: pause execution before a high-risk task (DB write, financial transaction), save state, yield control to an operator. Once the operator approves or corrects the proposed action, the system re-hydrates the state and continues.

> Source: findings.md "State Persistence" — HITL interrupts [7]

**Rule**: Any node that performs an irreversible high-risk action should sit behind an `interrupt_before` breakpoint, not run autonomously.

**determinismLevel**: deterministic.

### SP6: Tune Production Checkpointers

Serialization has overhead — in complex multi-agent workflows the serialized state can reach **several megabytes**; high-frequency writes strain DB I/O. Production configs need compressed writes and automated state-pruning. Example `DynamoDBSaver`:

```python
from langgraph_checkpoint_aws import DynamoDBSaver

checkpointer = DynamoDBSaver(
    table_name="langgraph_checkpoints",
    region_name="us-west-2",
    ttl_seconds=86400 * 7,                # 7-day automated state pruning
    enable_checkpoint_compression=True,   # Gzip to reduce DB I/O
    s3_offload_config={
        "bucket_name": "my-langgraph-checkpoints"  # offload states exceeding DynamoDB size limits
    }
)
```

> Source: findings.md "State Persistence" — DynamoDBSaver tuning [7, 26]

**Rule**: Configure compression + a TTL retention window + large-payload offload. Unbounded checkpoint writes cause DB write failures at scale.

**determinismLevel**: semi-deterministic — values are deployment-specific.

---

## Anti-Patterns

- **No checkpointer**: one timeout restarts a multi-step workflow from zero.
- **MemorySaver in production**: every restart wipes all state.
- **Conflating Replay and Fork**: overwriting the original trajectory when you meant to branch (use Fork/`update_state`).
- **Default subgraph checkpointing when you need node-level rollback**: forces whole-subgraph re-execution.
- **Autonomous high-risk nodes**: irreversible actions with no `interrupt_before` gate.
- **Untuned production checkpointer**: no compression/TTL/offload → multi-MB writes cause I/O failures.
