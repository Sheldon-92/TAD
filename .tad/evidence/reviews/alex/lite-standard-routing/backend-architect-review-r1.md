# Full Gate 2 Review — Backend Architect (R1)

- **Reviewer:** McClintock (fresh-context backend-architect)
- **Date:** 2026-08-01
- **Target:** `.tad/active/handoffs/HANDOFF-20260801-lite-standard-routing-full.md`
- **Scope:** route SSOT, risk boundary, independent depth merge, state/data flow, Standard profile contract
- **Verdict:** FAIL / BLOCK

## P0 findings

1. The Route Contract was described as intent and marker checks, not a complete executable schema. It lacked machine-readable matching inputs, invariants, state transitions, and field association checks.
2. Standard lacked explicit inputs, outputs, budgets, stop conditions, escalation conditions, and a persisted Standard-to-Full transition.
3. `design_depth` and `execution_depth` had no append-only ownership, merge algorithm, revision lifecycle, or Blake-to-Full escalation behavior.

## P1 findings

1. `escalated_review` was not defined in the risk matrix or state model.
2. The derived meaning of single-valued `route_level` was unspecified for asymmetric routes.
3. The shared-state table omitted approval, session/Progress, `NEXT.md`, archive, and the policy-vs-snapshot authority boundary.
4. Functions were marked verified despite only planned marker checks and no behavior input/output contract.
5. Gate 2 evidence references were not independent review carriers.

## Required resolution

Add the executable YAML contract and invariants in §4.4/§4.6, explicit Standard profile contracts in §4.5, append-only route lifecycle and authority map in §4.6/MQ3/MQ5, real scenario/evidence requirements in §8.2/§8.6/AC12, and a fresh incremental review before Gate 2 PASS.
