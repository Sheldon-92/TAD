# Gate 4 — YOLO2 Phase 3 Limited-Core Acceptance

**Date:** 2026-09-01  
**Verdict:** PASS — bounded core, with explicit human-approved deferred integration  
**Human acceptance:** “可以，那通过吧”

## Accepted scope

| Item | Result | Evidence |
|---|---|---|
| Local deterministic safety foundation | PASS | Blake Phase-3 reviews and fixtures |
| Phase-2 protected evidence | PASS | 7,749 before/after entries byte-equal |
| Codex native fresh call | PASS | Alex independent live verification |
| Codex exact native resume | PASS | same thread restored prior packet fields and nonce |
| Experimental adapters | NON-BLOCKING | first-use qualification under P3-R1 |

## DEGRADED_WITH_APPROVAL

| Deferred item | Accepted risk | Trigger / recovery |
|---|---|---|
| Runner does not inject `packetContent` | automated runner cannot yet restore the packet by itself | fix when first automated Codex runner use begins; inject packet + prompt |
| Runner does not call native `codex exec resume` | session metadata currently overstates native resume wiring | fix at the same trigger; translate session ID into native resume argv |
| Synthetic Codex strict placeholder exists | aggregate is not a trustworthy live carrier | do not use it as trust source; use Alex live report until placeholder is removed |

Approval source: human chat, 2026-09-01, after all three limitations were disclosed.
Rationale: avoid blocking overall progress on speculative multi-harness and automation
work; accept the proven core and repair only when actual usage demands it.

## Quality evidence

- Blake: spec compliance, code review, security audit, and test review all report
  P0=0/P1=0 for the deterministic implementation.
- Alex: two real Codex calls, zero retries, 16.6 seconds, same native thread, exact
  recovery nonce restored without reinjection.
- No Claude Code, OpenCode, or DeepSeek provider call was made.

## Knowledge Assessment

**New discovery:** yes. A deterministic capability classifier can validate its own
matrix while still fabricating the release carrier; live evidence and automation
wiring must remain separate claims. Recorded in the acceptance DR and Alex live
verification report rather than promoted to shared project knowledge until it repeats.

## Final disposition

Phase 3 limited core is accepted. The Epic may proceed to its next phase. Deferred
runner wiring remains visible backlog and must not be described as already shipped.
