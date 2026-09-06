# Harness Degradation Approval — yolo2 Phase 2 (persisted)

**Date:** 2026-08-26 · **Approver:** Sheldon (human, Value Guardian), explicit
reply "批准 degraded" in session.
**Scope:** TASK-20260825-YOLO2-P2 paired dogfood ONLY (Phase 2).

Human authorizes running the Phase-2 paired dogfood under the DEGRADED
capability verdict recorded in `reference-harness-capability.json` (capability
9 unproven: codex read-only sandbox permits host-side reads; isolation of
hidden acceptance relies on host-side storage outside the worktree + packet
not naming it, NOT on process-level namespace enforcement). All other strict
capabilities (fresh context, write-disabled assertion sandbox, exact-session
continuation, native usage, nonce binding) are proven and enforced by the
reference runner.
