# Gate 4 Security Review — Lite / Standard / Full Routing

- **Reviewer:** security-auditor (fresh independent review)
- **Date:** 2026-08-01
- **Verdict:** BLOCK Gate 4
- **Scope:** routing SSOT, four Lite skills, AGENTS.md, verifiers, Completion/evidence

## Positive findings

- No new hooks, settings, runtime dependencies, credentials, or application-layer vulnerability were introduced by the implementation commits.
- F0/F1, missing-SSOT, and user-request downgrade scenarios are represented in the behavior evidence.

## Gate-blocking findings

1. **Evidence drift:** the current `.tad/routing-contract.yaml` hash does not match the hash recorded by the behavior transcripts/review. Re-run or rebind all affected behavior evidence to the current SSOT.
2. **Approval authority is not mechanically represented:** `approval_record` is not part of the SSOT decision schema, and the verifier does not validate human actor, timestamp, route revision, evidence, or legal transition.
3. **Route enforcement is declarative rather than independently executable:** the verifier consumes pre-generated transcripts and does not recompute prompt → risk class → route or prove a real side-effect interceptor. Treat this as a protocol-assurance gap requiring explicit acceptance or a follow-up boundary.

## Non-blocking observations

- Sentinel validation remains transcript-level rather than fixture-hash-level.
- Route schema verification is marker-oriented rather than a structural YAML parser.

The implementation's lack of newly introduced application vulnerabilities does not remove these Full Gate 4 assurance blockers.
