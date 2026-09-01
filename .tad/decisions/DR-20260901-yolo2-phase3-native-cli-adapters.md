# DR-20260901 — YOLO2 Phase 3 Native CLI Adapters

**Status:** Accepted  
**Date:** 2026-09-01  
**Human decision:** option 1 selected in the Alex design session  
**Research:** `.tad/evidence/research/yolo2-phase3/2026-09-01-harness-capability-research.md`

> **Amended 2026-09-01:**
> `DR-20260901-yolo2-phase3-progressive-harness-qualification.md` supersedes the
> all-four live-classification release condition. The architecture and safety
> boundaries below remain accepted.

## Context

Phase 3 must let one maintainer move among Claude Code, Codex, OpenCode, and a
DeepSeek-backed path while preserving the same goal, verified progress, decisions,
blockers, and legal next action. Native session formats and permission mechanisms
are different, and DeepSeek is available locally through OpenCode rather than as a
standalone executable.

## Decision

1. Keep `goal.json + journal.jsonl` as the cross-harness authority. Native chat
   history, compact summaries, and provider reasoning are never progress authority.
2. Implement one TAD adapter contract with a separate native CLI profile for Claude
   Code, Codex, and OpenCode.
3. Treat DeepSeek as a distinct target profile whose identity is
   `runtime=opencode, provider=deepseek, model=<explicit frozen model>`. A profile is
   not allowed to masquerade as a standalone DeepSeek runtime.
4. Capability claims remain per-profile and evidence-backed. Under the progressive
   qualification amendment, Codex is the Phase-3 core release profile; the other
   profiles remain experimental and are classified lazily on first use. Unknown is
   never implicit support.
5. Preserve the Phase-1/2 runner and artifact formats. Phase-3 support is additive;
   old evidence remains replayable without conversion.
6. Keep Phase 3 opt-in/shadow. This decision does not authorize default-on, paid
   probes, or reuse of Phase-2 token budgets/degradation approvals.

## Alternatives rejected

- **ACP-first:** promising, but only OpenCode exposes it in the current installed
  set. It would create two transport families before the semantic contract is proven.
- **Unified SDK replacement:** changes the runtime boundary and still lacks proven
  coverage for the four target identities.
- **Shared transcript store:** shares the wrong memory layer and creates privacy,
  compatibility, and false-progress risks.

## Consequences

- Platform-specific parsing remains, but all authoritative state transitions and
  semantic recovery rules remain shared.
- A native session resume can improve efficiency but never bypasses the recovery
  assertion.
- DeepSeek capability and cost are measured independently even when OpenCode is its
  transport.
- ACP can be adopted later behind one profile without changing the state contract.
