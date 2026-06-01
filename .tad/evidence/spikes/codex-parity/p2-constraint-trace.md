# P2 Constraint Trace — Per-Owner SAFETY Preservation

> Generated 2026-06-01 as part of codex-parity-phase2-catchup.
> Confirms zero must-cover SAFETY loss in both P2 regenerated editions.

## Methodology

For each SAFETY category, the must-cover owner set = source bodies containing
the category token, minus expected-absent allowlisted bodies. The codex-body-count
MUST be >= source-body-count per (category, owner).

## Alex Edition (codex-alex-skill.md)

| Category | Owner | Source Count | Codex Count | Status |
|----------|-------|-------------|-------------|--------|
| forbidden_implementations | cross_model_awareness | 1 | 1 | PASS |
| forbidden_implementations | express_path_protocol | 1 | 1 | PASS |
| forbidden_implementations | experiment_path_protocol | 1 | 1 | PASS |
| forbidden_implementations | handoff_creation_protocol | 3 | 3 | PASS |
| forbidden_implementations | acceptance_protocol | 4 | 4 | PASS |
| forbidden_implementations | cancel_protocol | 2 | 2 | PASS |
| **forbidden_implementations TOTAL** | **6 owners** | **12** | **12** | **PASS** |
| anti_rationalization_registry | intent_router_protocol | 1 | 1 | PASS |
| anti_rationalization_registry | handoff_creation_protocol | 1 | 1 | PASS |
| anti_rationalization_registry | on_start | 2 | 2 | PASS |
| anti_rationalization_registry | anti_rationalization_registry | 2 | 2 | PASS |
| **anti_rationalization_registry TOTAL** | **4 owners** | **6** | **6** | **PASS** |
| NOT_via_alex_auto | cross_model_awareness | 1 | 1 | PASS |
| NOT_via_alex_auto | research_plan_protocol | 3 | 3 | PASS |
| NOT_via_alex_auto | anti_rationalization_registry | 1 | 1 | PASS |
| **NOT_via_alex_auto TOTAL** | **3 owners** | **5** | **5** | **PASS** |
| honest_partial | (all in yolo = allowlisted) | 0 | 0 | SKIP |

**must-cover = source_total - in_allowlisted_bodies:**
- forbidden_implementations: source total across ALL bodies = 12 + (yolo:0, optimize:0, evolve:0, dream:0, publish:0, sync*:0, lsp:0) = 12. Allowlisted = 0. Must-cover = 12. Codex = 12. Zero loss.
- anti_rationalization_registry: source total = 6 + (yolo:0, ...) = 6. Allowlisted = 0. Must-cover = 6. Codex = 6. Zero loss.
- NOT_via_alex_auto: source total = 5. Allowlisted = 0. Must-cover = 5. Codex = 5. Zero loss.
- honest_partial: source total = 4 (all in yolo_execution_protocol). Allowlisted = 4. Must-cover = 0. SKIP.

## Blake Edition (codex-blake-skill.md)

| Category | Owner | Source Count | Codex Count | Status |
|----------|-------|-------------|-------------|--------|
| forbidden_implementations | cross_model_invocation | 1 | 1 | PASS |
| forbidden_implementations | ralph_loop_execution | 1 | 1 | PASS |
| forbidden_implementations | execution_checklist | 3 | 3 | PASS |
| forbidden_implementations | completion_knowledge_override | 1 | 1 | PASS |
| **forbidden_implementations TOTAL** | **4 owners** | **6** | **6** | **PASS** |
| anti_rationalization_registry | (0 source owners) | 0 | 0 | SKIP |
| NOT_via_alex_auto | (0 source owners) | 0 | 0 | SKIP |
| honest_partial | on_start | 2 | 4 | PASS |
| honest_partial | honest_partial_protocol | 2 | 2 | PASS |
| **honest_partial TOTAL** | **2 owners** | **4** | **6** | **PASS** |

**must-cover = source_total - in_allowlisted_bodies:**
- forbidden_implementations: must-cover = 6. Codex = 6. Zero loss.
- anti_rationalization_registry: must-cover = 0. SKIP (Alex-only).
- NOT_via_alex_auto: must-cover = 0. SKIP (Alex-only).
- honest_partial: must-cover = 4. Codex = 6 (surplus in on_start transition text — safe). Zero loss.

## Pin Table Validation

All 8 pins matched (4 alex + 4 blake). Derivation = pin for every (source, category) pair.

## P1 → P2 Delta Summary

P1 (codex-alex, 2026-05-04): forbidden_implementations must-cover loss of 4 owners, anti_rat loss of 3, NOT_via_alex loss of 3.
P2 (codex-alex, 2026-06-01): zero must-cover loss across all categories.

P1 (codex-blake, 2026-05-04): forbidden_implementations must-cover loss of 3 owners, honest_partial loss of 2.
P2 (codex-blake, 2026-06-01): zero must-cover loss.

## Headless Probe Results (AC7)

| Method | Duration | Output Size | Parity-Check | Status |
|--------|----------|-------------|-------------|--------|
| `claude -p` | 224s | 2,140 bytes | N/A (wrong format) | FAIL — model produced analysis instead of raw file |
| `codex exec --full-auto` | 175s | 46,870 bytes | exit 0, all 3 layers PASS | PASS |

Recurring human-touch time via codex exec: **~175s (~3 min)** — within <=5min standing guarantee.
Headless remediation path: not tested (first `codex exec` pass succeeded).

## regen-procedure.md Step D

Step D (bounded <=2 re-emit, honest_partial on persistent failure) added to regen-procedure.md.
Not invoked for P2 regen (both editions passed on first generation).
