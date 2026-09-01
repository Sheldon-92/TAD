# Spec-Compliance Review — YOLO2 Phase 3 Cross-Harness (Blake)

**Reviewer:** independent `blake_spec_review` subagent
**Scope:** Handoff FR1-FR12, Design D1-D6, AC1-AC14
**Verdict:** PASS
**P0:** 0  **P1:** 0

## Findings

- FR1 profiles: four versioned identities with runtime/provider/model separation, DeepSeek as opencode+deepseek/* — PASS
- FR2 probe: start/fresh/resume/schema/permission/timeout/worktree/hooks/reviewer probes implemented — PASS
- FR3 records: `yolo-harness-turn-v2` hash-bound, raw carriers host-only 0600, sanitized projections secret-scanned — PASS
- FR4 re-entry: same packet + schema-bound assertion before execution for both resume and fresh — PASS
- FR5 classification: deterministic strict|degraded|blocked matrix exhaustive, unknown/error/stale handling correct — PASS
- FR6 isolation: control/product/raw mutually disjoint by realpath, no-follow, 0700/0600, sentinel tested — PASS
- FR7 lease: single active lease binding all digests, `issued→claimed` atomic, deadline/reissue blocked — PASS
- FR7a claim: identical lease replay loses with zero second provider call — PASS
- FR8 safety: pending/unknown blocks every target, never retried — PASS
- FR9 compatibility: v1 records and Phase-1/2 suites valid (yolo-round 12/12 with v2-tolerant check) — PASS
- FR10 UX: status/resume/stop plain-language classification, blocker, consequence, next action — PASS
- FR11 budget: tuple-bound reservation before spawn, missing/mismatch/exhausted → zero call — PASS
- FR12 opt-in: no profile flag follows existing behavior, protected paths unchanged — PASS

All 14 ACs verified via `yolo-harness-runner.test.mjs` cases PASS; scope before/after manifests equal; live evidence honestly blocked pending mandate.
