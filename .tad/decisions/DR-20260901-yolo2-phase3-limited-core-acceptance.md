# DR-20260901 — YOLO2 Phase 3 Limited-Core Acceptance

**Status:** Accepted
**Date:** 2026-09-01
**Human decision:** “可以，那通过吧” after reviewing the independent Codex live
verification and the two disclosed runner wiring limitations.

## Decision

Phase 3 is accepted for its bounded core:

- deterministic lease, isolation, budget, termination, classification, scope, and
  Phase-2 compatibility foundation;
- native Codex fresh + exact-session resume capability on `codex-cli 0.151.0` with
  `gpt-5.6-luna`;
- bounded semantic progress can be restored from an injected recovery packet;
- Claude Code, OpenCode, and DeepSeek remain non-blocking experiments.

The following automation is explicitly deferred until the first actual automated
Codex runner use:

1. concatenate/inject `packetContent` into the native Codex turn;
2. translate the runner's session field into `codex exec resume <session-id>`;
3. remove the deterministic synthetic-`strict` placeholder and bind the aggregate
   only to real live evidence.

## Claim boundary

This acceptance does **not** claim that commit `b9e04f1` already provides end-to-end
automated packet injection or native resume through `yolo-harness-runner.mjs`.
It accepts the Phase-3 foundation and independently proven Codex runtime capability,
with those two integration steps deferred by explicit human risk acceptance.

Failure on first actual use degrades only the affected adapter and triggers the
focused wiring repair; it does not revoke the accepted Phase-3 foundation.
