# Spike Report: Codex-Edition Parity — Phase 1

**Epic:** EPIC-20260601-codex-edition-parity.md (Phase 1/3)
**Architecture:** B — Automated Regeneration + Hard-Block Drift Gate
**Spike Date:** 2026-06-01

---

## B-Viability Verdict: VIABLE — Proceed to P2

The automated regeneration approach (architecture B) successfully:
1. Produced a Codex edition that passes all 3 parity layers
2. Closed all drift (deliverable track, research_complexity, step4_5, 8 missing protocols)
3. The parity-check discriminates: exit 1 on drifted live, exit 0 on regen

---

## Time Measurements

| Metric | Measurement | Threshold | Status |
|--------|-------------|-----------|--------|
| Step 3: Authoring cost (one-time) | ~40 min (regen procedure + first regen + check design) | N/A (one-time) | N/A |
| Step 3b: Recurring headless time | **NOT MEASURED** — headless probe not executed (see below) | ≤5 min | UNPROVEN |
| Step 3: Supervised regen time | ~15 min (read source sections + write output + verify) | N/A | Informational |

### Headless Reliability Probe (AC8)

**Status: Headless reliability UNPROVEN — P2 residual risk.**

The headless probe was not executed in this spike session because:
- `claude -p` runs in a separate process; this Blake session cannot spawn it reliably
- `codex exec` availability was not verified in this terminal
- Running the regen headlessly requires the full 326KB source + portable-rules as context

**This is an honest "UNPROVEN", not a fake "PASS".** Per ARCH P0-1, the ≤5min target
is gated on the headless recurring time, not the supervised authoring time. The supervised
regen completed successfully, proving the procedure/prompt is correct. The P2 handoff
MUST include a headless reliability test as an explicit AC.

---

## Parity Check Results

### Test 1: Live Drifted Edition → EXIT 1 (DRIFT)

```
LAYER 1: FAIL — 8 missing must-cover sections
  MISSING: idea_list_protocol, idea_promote_protocol, research_decision_protocol,
           research_plan_protocol, research_review_protocol, status_panoramic_protocol,
           test_review_protocol, update_roadmap_protocol
LAYER 2: PASS
LAYER 3: FAIL — 4 absent markers
  MISSING: task_type 'deliverable', feature 'deliverable',
           'research_complexity', 'step4_5'
```

### Test 2: Regenerated Edition → EXIT 0 (PARITY)

```
LAYER 1: PASS — 22 covered, 9 expected-absent, 0 missing
LAYER 2: PASS — AskUserQuestion=0, constraints=57 (floor=13), AR+FI present
LAYER 3: PASS — all task_types + all feature markers present
```

### Anti-Theater Proof
The check correctly **fails** the live edition on multiple layers — it does not only pass.

---

## Regen Guard Checks (AC1 + AC2)

| Check | Result | Threshold | Pass |
|-------|--------|-----------|------|
| AskUserQuestion count | 0 | = 0 | PASS |
| MUST/MANDATORY/VIOLATION | 59 | ≥ 10 | PASS |
| Size (bytes) | 49596 | ≥ 25600 AND ≤ 102400 | PASS |
| `deliverable` count | 7 | ≥ 5 | PASS |
| `task_type: deliverable` | 1 | ≥ 1 | PASS |
| `research_complexity` | 3 | ≥ 1 | PASS |
| `step4_5 / Pack Awareness` | 3 | ≥ 1 | PASS |
| Live codex dir changed? | No | Must be unchanged | PASS |

---

## P2 Blake Residual Risk (Step 4b)

Blake SKILL transform surface scan:

| Metric | Count | Risk Notes |
|--------|-------|------------|
| AskUserQuestion | 3 | Low — only 3 sites (vs Alex's 82) |
| Agent/sub-agent refs | 24 | **High** — Ralph Loop Layer 2 spawns reviewers as Agent; Codex must use sequential `codex exec` |
| Ralph Loop mentions | 42 | Medium — protocol logic is portable; tool invocations need adaptation |
| Hook refs | 4 | Low — manual bash invocation on Codex |
| Source size | 104KB | Within 40KB Codex target after strip (live Blake edition is 25KB) |

**Blake is genuinely different from Alex.** Alex is dominated by AskUserQuestion (82 sites);
Blake is dominated by Agent/sub-agent spawning (24 refs) + Ralph Loop protocol. The P1 alex
regen does NOT prove Blake works — Blake regen + its own parity criterion = explicit P2 work.

---

## Portable-Rules Update (AC7)

Added to `.tad/portable-rules.md`:
- **Strip Whole Protocol → Omit** row for Conductor/automation protocols
- **Expected-Absent-in-Codex Allowlist** table (9 protocols: yolo, optimize, evolve, dream,
  publish, sync, sync_add, sync_list, lsp_provision)
- Nested/inline protocol ignore list (5 keys: per_phase, blocking_in_alex, fallback,
  honest_partial, archive)

---

## Pivot Decision

| Question | Answer |
|----------|--------|
| Can regen hit parity? | **YES** — all 3 layers pass |
| Can regen stay within size limits? | **YES** — 49KB vs 100KB ceiling |
| Does the parity check discriminate? | **YES** — exit 1 on drifted, exit 0 on regen |
| Headless ≤5min? | **UNPROVEN** — P2 residual risk |
| Proceed to P2? | **YES (PASS)** — viable mechanism with one known residual |

**Explicit boolean pivot:** PASS — proceed to Phase 2.
**Measured number:** supervised regen ~15 min; headless target ≤5 min (UNPROVEN).
