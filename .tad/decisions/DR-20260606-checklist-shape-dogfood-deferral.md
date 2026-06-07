# DR-20260606: checklist verdict_shape ships gate-logic-only (real dogfood deferred)

**Date:** 2026-06-06
**Epic:** EPIC-20260606-nondev-verdict-shapes
**Status:** Accepted

## Context
backend-architect Gate-2 design review (P1-4) flagged: implementing the `checklist`
verdict_shape Gate logic while its only consumers (ai-voice-production, video-creation) are
hardware-blocked for dogfood reproduces the project's own "Validation Theater" anti-pattern
(YOLO audit finding 2026-05-15) — shipping gate logic no real run ever exercised.

## Decision
Ship the `checklist` gate logic this Epic (user-confirmed scope: implement both categorical
+ checklist gate-side). Mitigate the no-dogfood risk with a **synthetic checklist fixture**
(Phase 3 AC6): a small fake export-spec manifest run through the checklist Gate-3 branch
once, exercising both a PASS (all required pass) and a FAIL (a required item fails) path.
Real voice/video content dogfood stays deferred (needs TTS/render hardware) and is honestly
labelled "gate verified via fixture, real-content dogfood pending hardware" in the track guide.

## Rationale
- A synthetic fixture is cheap (no hardware) and converts "0 evidence the branch fires" into
  "branch proven to discriminate PASS vs FAIL on a controlled input" — the minimum honest bar.
- Deferring checklist entirely would leave the verdict_shape_guard gap half-open and require a
  second pass; the marginal cost of the branch is low since categorical is already being built.

## Alternatives rejected
- **Defer checklist to a later Epic**: leaves guard gap, second pass cost. Rejected.
- **Ship checklist with zero verification**: the exact validation-theater pattern. Rejected.

## Consequences
- product-thinking (categorical) gets a full real dogfood (the load-bearing proof).
- checklist gets fixture-level proof only — flagged as such everywhere (guide + completion).
