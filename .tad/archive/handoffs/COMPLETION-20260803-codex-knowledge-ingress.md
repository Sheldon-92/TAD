---
completion_id: COMPLETION-20260803-codex-knowledge-ingress
handoff_id: HANDOFF-20260803-codex-knowledge-ingress.md
agent: blake
date: 2026-08-03
gate3_verdict: pass
---

# COMPLETION: Codex knowledge ingress + hook envelope

**Handoff ID:** HANDOFF-20260803-codex-knowledge-ingress.md
**Date:** 2026-08-03
**Role:** Blake (Execution Master)
**Implementation commits:** `55751de` (`feat: wire Codex knowledge ingress and hook envelope`),
`6893d6c` (`fix: normalize Gate 3 acceptance count`)

## Outcome

Implemented the v3 handoff. Codex now has an explicit knowledge-ingress route,
critical-rule parity, a TTY-safe normalized hook envelope, portable skill-tree
fallbacks, honest platform-signal behavior, and explicit manual gate modes.
Claude behavior remains covered by the frozen same-basename comparison.

The three required spikes ran before implementation changes:

| Spike | Real observation | Decision | Status |
|---|---|---|---|
| C envelope | Isolated `CODEX_HOME`, trusted scratch repo, `workspace-write`; Codex returned HTTP 401 before an authenticated turn, so no hook payload was delivered | Keep unsupported/absent fields empty; use fixture-based normalization only | PASS with honest no-delivery limitation |
| D compaction | Same isolated probe returned HTTP 401; no PreCompact event/fire was observed | No PreCompact wiring; keep `context_compaction` as `verified_partial` and document re-probe | PASS with fire unmeasured |
| E signal | Non-injected harness signal set observed as `{}`; candidate variables were not promoted from documentation | No automatic candidate-variable reads; preserve explicit `TAD_PLATFORM` override and conservative fallback | PASS with empty measured set |

No fixture, documentation, or CLI availability observation is presented as
real Codex hook delivery.

## Acceptance checklist

- [x] AC-00 — C/D/E spike reports, scratch commit history, and honest mappings.
- [x] AC-01 — scoped knowledge ingress and critical rules in `AGENTS.md`.
- [x] AC-02 — per-event envelope observation and field mapping.
- [x] AC-03 — Claude fixtures, empty input, TTY guard, and jq-absent fallbacks.
- [x] AC-04 — frozen same-basename Claude comparison with only three registered filters; second trace run adds zero lines on both trees.
- [x] AC-04b — manual gate negative/positive, bare-call, and invalid-argument behavior.
- [x] AC-05 — Spike D evidence/ledger/wiring linkage with no docs-only verified claim.
- [x] AC-06 — Spike E set-equality oracle, stdout purity, override, and fallback table.
- [x] AC-07 — registered line-set diff, two-tree parity, and Source headers 38 → 0.
- [x] AC-08 — scratch Codex-only `.agents/skills` and no-tree brain-index fallback without repository index mutation.
- [x] AC-09 — parity, skill-body, current hook schema, accepted limitation, and runtime freshness 21/21 PASS.
- [x] AC-10a — compact discriminator reminder and honest no-discriminator Layer-1 route.
- [x] AC-10b — notebook fail-open behavior with empty `HOOK_SOURCE` and compact filtering.
- [x] Gate 3 — PASS; evidence: `.tad/evidence/gates/gate3-codex-knowledge-ingress.md`.

## 执行证据

The full acceptance suite was run after implementation and after the immutable
baseline was pinned:

```text
AC-00..AC-10b: all PASS
AC-04: frozen same-basename behavior matches; both second trace deltas = 0
AC-04b: no-arg/invalid calls fail; missing Completion BLOCKs; valid Completion allows
AC-07: registered line-set only; old Source headers 38 -> 0; parity and lite guards pass
AC-09: runtime freshness Total 21 | PASS 21 | WARN 0 | BLOCK 0
```

Independent checks:

```text
bash -n .tad/hooks/*.sh .tad/hooks/lib/*.sh tad.sh       PASS
jq -e . .codex/hooks.json                                PASS
bash .tad/hooks/lib/release-verify.sh parity .            PASS
bash .tad/hooks/lib/runtime-freshness-verify.sh .         PASS (21/21/0/0)
bash .tad/hooks/lib/layer2-audit.sh codex-knowledge-ingress PASS (3 distinct reviewers)
git diff --check                                         PASS
```

The AC-04 comparison uses the recorded pre-edit commit
`e73a3c88bd4152e53204fb2991623aae34903b84`, not the moving post-implementation
`HEAD`. The baseline measurements and sentinel hashes are in
`.tad/evidence/acceptance-tests/codex-knowledge-ingress/baseline.md`.

## Layer 2 review

Final reviewer outcomes (interrupted earlier attempts remain preserved in the
artifacts rather than being rewritten as passes):

| Reviewer | Final result | Evidence |
|---|---|---|
| spec-compliance-reviewer | PASS | `.tad/evidence/reviews/blake/codex-knowledge-ingress/spec-compliance-reviewer.md` |
| code-reviewer | PASS (R2) | `.tad/evidence/reviews/blake/codex-knowledge-ingress/code-reviewer.md` |
| test-runner | PASS (R3) | `.tad/evidence/reviews/blake/codex-knowledge-ingress/test-runner.md` |

`layer2-audit.sh` found exactly three distinct recognized reviewers:
`code-reviewer`, `test-runner`, and `spec-compliance-reviewer`.

## Friction Status

| Friction point | Status | Approval / substitute evidence |
|---|---|---|
| Spike C authenticated Codex hook delivery unavailable | DEGRADED_WITH_APPROVAL | Handoff §6 explicitly permits no-delivery PASS; `spike-c.md` records HTTP 401, no payload, and the exact limitation on 2026-08-03. |
| Spike D PreCompact fire unavailable | DEGRADED_WITH_APPROVAL | Handoff §3.3/§6 permits honest no-delivery; `spike-d.md` keeps fire unmeasured, adds no wiring, and ledger state is `verified_partial`. |
| Spike E harness signals unavailable in an authenticated model turn | DEGRADED_WITH_APPROVAL | Handoff §3.4/§6 permits honest empty mapping; `spike-e.md` records measured set `{}` and no candidate-variable inference. |

These are accepted evidence limitations, not hidden blockers. Re-probing with a
trusted authenticated scratch session remains the follow-up.

## Knowledge Assessment (MANDATORY)

| Question | Answer | Evidence |
|---|---|---|
| New discoveries? | Yes | `.tad/evidence/journal/codex-knowledge-ingress-2026-08-03.md` |
| Category | Hook contract / runtime verification / shell portability | Journal entry |
| One-sentence summary | Empty/no-delivery runtime observations must remain empty and partial; normalized envelopes and immutable baselines make that limitation auditable. | Journal entry |

Journal entry added: `.tad/evidence/journal/codex-knowledge-ingress-2026-08-03.md`.
Blake records the raw discovery in the journal; project-knowledge distillation is
deferred to Alex's Gate 4 work.

## Spec-compliance source note

This v3 handoff labels its executable acceptance section `## 5. AC` rather than
using the newer literal `§9.1` heading. Gate 3 maps each AC-00 through AC-10b
verification script one-to-one to that active handoff section; no AC is silently
omitted or replaced by a hardcoded green check.

## Reflection history

1. Baseline exposed the old manual pre-gate false-green (`{}`, exit 0). The
   count normalization and explicit manual-argument path were added, then AC4b
   was rerun for both negative and positive cases.
2. AC4 was hardened to pin the immutable pre-edit commit and retain trace
   idempotency as a measured behavior; no broad normalization filter was added.
3. Reviewer interruptions were recorded as PARTIAL/BLOCK in their artifacts;
   R2/R3 follow-ups completed the missing checks and produced final PASS
   verdicts without changing implementation.

## Gate 3 Result — PASS

**PASS** — `.tad/evidence/gates/gate3-codex-knowledge-ingress.md`.
All AC-00 through AC-10b rows passed, independent checks passed, the two
implementation commits are present, and the three distinct Layer 2 reviewers
have final PASS outcomes. The universal post-step marker is
`gate3_verdict: pass`.

## Files / evidence

Implementation is committed in `55751de` and `6893d6c`. Product files are the requested
`AGENTS.md`, Codex hooks/config/mapping/adapter files, hook consumers and
envelope library, `tad.sh`, runtime ledger, and the synchronized Alex/Blake
SKILL/reference trees. The new acceptance, spike, Ralph, journal, and Layer 2
review artifacts are under `.tad/evidence/`.

The generated Codex client cache from the isolated probe was not committed; it
was moved recoverably to `/tmp/tad-codex-knowledge-ingress-spike-home-20260803`.
