# DR-20260824: YOLO 2.0 Orchestration Kernel

**Date**: 2026-08-24  
**Status**: SUPERSEDED IN SEQUENCING by `DR-20260824-yolo2-vertical-slice-first.md`  
**Decided by**: Human — 2026-08-24 (continue with the complete recommended direction)  
**Evidence base**:
- `.tad/evidence/research/longhorizon-harness/2026-08-24-raw-web-research.md`
- `https://github.com/AMAP-ML/LongHorizon-Harness`
- `https://arxiv.org/abs/2608.01964`
- `https://docs.langchain.com/oss/javascript/langgraph/persistence`
- `https://docs.temporal.io/`

---

## Decision

> 2026-08-24 reset: the local-first direction remains valid, but the decision to build the generic deterministic kernel before a real YOLO recovery slice is withdrawn. See `DR-20260824-yolo2-vertical-slice-first.md`.

Adopt **Option B — File-native deterministic orchestration kernel inside YOLO**.

The human confirmed that the researched decisions were complete and directed Alex to continue research and design. This selects the proposed recommendation: preserve TAD's existing authority model and add durability, replay, bounded Manage-Execute-Audit rounds, and mechanical completion checks inside YOLO without adding a cloud runtime or LongHorizon-Harness dependency.

## Context

Current YOLO preserves Epic-, Phase-, and review-level artifacts, but Y5 implementation is one long executor episode and the workflow's live `result` is not a durable source of truth. The requested outcome is to preserve the original target and verified progress across long execution while preventing quality regression, false completion, duplicate side effects, and silent cross-harness permission degradation.

The chosen architecture must preserve TAD's Alex/Blake separation, Gate 1-4, independent review, final human acceptance, local-first operation, and Claude Code/Codex/OpenCode portability. The first release does not require a cloud service or full Web Dashboard and must not depend on LongHorizon-Harness at runtime.

## Options Considered

### Option A — Prompt-only hardening

Add more instructions to existing Manager/Blake/Reviewer prompts and keep the current two workflow calls per Phase.

- **Enables**: smallest diff and fastest implementation.
- **Prevents**: almost nothing mechanically; live state remains process-local.
- **Failure if wrong**: false completion and stale progress remain possible while the stronger prose creates false confidence.
- **Verdict**: reject. This contradicts the project lesson that protection belongs at the execution point, not only the declaration point.

### Option B — File-native deterministic orchestration kernel inside YOLO (recommended)

Keep Y1-Y8. Add a small typed state machine inside Y5/Y6 using versioned contracts, atomic state snapshots, append-only events, bounded Manage-Execute-Audit rounds, role capability declarations, action idempotency, recovery preflight, and a mechanical completion guard.

- **Enables**: local-first durable execution, inspectable Git-friendly evidence, cross-harness semantic parity, incremental rollout, and reuse of current Epic/Handoff/Gate artifacts.
- **Prevents**: state advancement from executor claims, restart-from-zero, silent completion without clean audit, and duplicate uncertain retries.
- **Cost**: custom state-transition and recovery code must be maintained and tested adversarially.
- **Failure if wrong**: an underspecified state machine could add complexity without reliability; rollout therefore needs a shadow/spike phase and non-regression benchmark before becoming default.
- **Verdict**: recommended for the current single-user CLI deployment.

### Option C — Adopt LangGraph or Temporal as the runtime

Model YOLO as an external durable workflow with framework-managed checkpoints/replay.

- **Enables**: mature checkpointing, interrupts, history, replay, and stronger distributed durability. Temporal is the strongest option for multi-day production services; LangGraph fits typed agent state graphs.
- **Prevents**: many crash-recovery problems if every side effect is modeled correctly and idempotently.
- **Cost**: adds a new runtime, dependency, state model, operational surface, migration burden, and cross-harness adapter layer. Temporal additionally introduces a service/worker deployment model that the first release explicitly excludes.
- **Failure if wrong**: TAD ends up maintaining two orchestration systems, and framework checkpoints may preserve execution state without preserving TAD's semantic audit contract.
- **Verdict**: defer. Revisit only if TAD becomes a multi-user or remote service, or file-native recovery fails measured targets.

### Option D — Embed or fork LongHorizon-Harness

Invoke LongHorizon-Harness as YOLO's execution engine or fork its source.

- **Enables**: fastest access to MEA rounds, event streams, resume, human controls, and its existing adapters.
- **Prevents**: reimplementing the basic loop.
- **Cost**: Python runtime alongside the current workflow stack, duplicated role/gate concepts, early-version API drift, and backend permission asymmetry. Its Codex adapter does not currently provide the same auditor workspace guard as Claude Code.
- **Failure if wrong**: TAD quality authority becomes split between two frameworks and cross-harness behavior looks equivalent when it is not.
- **Verdict**: reject as a runtime dependency; retain as researched prior art and benchmark reference.

## Proposed Decision

Choose **Option B** with these boundaries:

1. Preserve Y1-Y8; insert the durable MEA loop inside Y5/Y6.
2. Preserve Handoff as the human-approved execution contract; Manager may select work but may not silently revise scope.
3. Only the harness transition reducer can advance verified state, and only from a valid independent audit.
4. Use portable files and atomic writes in v1; do not add a database or server.
5. Declare adapter capabilities explicitly and fail closed or visibly degrade when read-only/snapshot guarantees are unavailable.
6. Roll out behind an opt-in execution mode until fault-injection and YOLO v1/v2 non-regression gates pass.

## Revisit Triggers

Reconsider Option C when any of the following becomes true:

- TAD needs concurrent multi-user/cloud execution.
- A single run spans machines or workers.
- File locking/atomic-write semantics fail supported-platform tests.
- Event replay latency or state size exceeds explicit Phase acceptance thresholds.
- Operational evidence shows the custom kernel costs more to maintain than adopting a durable workflow runtime.

## Consequences if Accepted

- The Epic must start with schemas, invariants, reducer, replay, and failure injection before changing the live YOLO execution loop.
- Existing YOLO remains available as a compatibility path during the spike and shadow evaluation.
- Completion, permission parity, and state provenance become harness-level contracts rather than prompt conventions.
- Full Dashboard and distributed execution remain explicitly out of scope.

## Amendment — Phase 1/Phase 4 Node Runtime Proof Boundary

**Date:** 2026-08-24  
**Decided by:** Human — selected option 1 after Gate 2 cycle 1 exposed an unavailable Node 14 runtime

Phase 1 records only a closed static compatibility hypothesis (`node14-static-v1`) under the available host runtime, including forbidden API/import checks and `NODE_PATH` isolation. It must not claim that Node 14 executed. Real execution of the frozen Phase 1 suite and Alex verifier on Node 14.0.x moves to Phase 4, where it is blocking before Phase 5 integration or Phase 6 default-on. An unavailable Node 14 runtime produces `honest_partial`, not an inferred PASS.

This amendment changes proof timing, not the final compatibility requirement. Evidence: `.tad/evidence/designs/yolo2-architecture-audit-cycle2.md`.
