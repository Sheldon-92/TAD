# DR-20260901 — YOLO2 Phase 3 Progressive Harness Qualification

**Status:** Accepted  
**Date:** 2026-09-01  
**Human decision:** Do not block overall progress on exhaustive up-front validation;
Codex validation is sufficient for the Phase-3 core, and other harnesses may be
qualified incrementally when first used.

## Context

The deterministic adapter and safety layer is complete, but the original release
threshold required live classification of Claude Code, Codex, OpenCode, and the
OpenCode-hosted DeepSeek profile before Phase 3 could pass. That requirement makes
optional adapters part of the critical path and spends time and provider budget
before the maintainer has an actual need for them.

## Decision

1. Phase-3 core acceptance requires one live `strict` result from the primary Codex
   profile plus the already-required deterministic safety, compatibility, scope, and
   independent-review checks.
2. Claude Code, OpenCode, and OpenCode-DeepSeek are retained as experimental,
   opt-in adapters. They do not block Phase-3 core acceptance and must not be
   described as verified until their own first-use probe succeeds.
3. Qualification is lazy and isolated: on first real use of an experimental adapter,
   run the smallest harmless probe needed for that adapter, persist its honest
   `strict | degraded | blocked` result, and continue or fall back accordingly.
4. Failure of an experimental adapter degrades only that adapter. It does not revoke
   the accepted Codex path or roll back the shared semantic-state contract.
5. Existing pre-spawn safety controls remain mandatory. This amendment removes
   redundant cross-provider release testing; it does not remove lease, budget,
   credential isolation, process termination, scope, or fail-closed checks.
6. Every provider call still needs an exact profile/model and bounded mandate. No
   mandate is implied for Claude Code, OpenCode, or DeepSeek by accepting this DR.

## Revised release threshold

Phase 3 may reach Gate 3 PASS when:

- the Codex profile is live-probed `strict` on a frozen executable/profile/model;
- deterministic AC1-AC7 and AC9-AC14 pass, with AC8 scoped to the Codex carrier;
- Phase-2 protected evidence remains unchanged;
- required reviews report no unresolved P0/P1;
- the other three profiles are explicitly marked `experimental_unverified`,
  `degraded`, or `blocked`, without being counted against the core verdict.

## Consequences

- The project gets a usable cross-harness memory foundation without waiting for
  speculative parity work.
- Capability claims become per-adapter and evidence-backed, not an all-platform
  release promise.
- DeepSeek can be tried cheaply when needed; failure is visible and recoverable.
- Default-on and universal multi-harness support remain out of scope.

## Supersession

This DR supersedes only the all-four live-classification release condition in
`DR-20260901-yolo2-phase3-native-cli-adapters.md`, the Phase-3 design, and its active
handoff. The native-adapter architecture and safety boundaries remain in force.
