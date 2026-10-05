Model: harness=codex | model=unknown | route=unknown
Reviewer: /root/experiment_review (terra_reviewer; independent session)
Verdict: FAIL

## Findings (reviewer returned, retained)

- P0 E1 — source freeze is not reproducible or enforced. verify-sources only checks existence/readability although source paths are relative to cloud-sync root and CLI uses repository root. All six exist one directory above the repo, not under it. Source-change/hash mismatch negative test lacks an executable contract. Fix: canonical source root, static allowlist, path escape/symlink rejection, persisted hash and recomputation.
- P0 E2 — H is contaminated by open validation yet all 12 H/V cases remain in the final evaluation population. H cannot support confirmatory comparisons after informing candidate design; hiding split does not remove design-time leakage. Fix: H calibration-only; V separate holdout, author receives no H artifacts/scores/candidate feedback/oracles.
- P0 E3 — oracle independence is asserted but not established. The builder supplies cases, controls and oracle, then reviewers check them; an internally consistent wrong oracle can pass. Fix: independent derivation from case requirements before rehearsal, reviewer-approved freeze and decision trace; author not sole approver.
- P1 E4 — synthetic injected outputs must be called offline pipeline rehearsal, not E2E validation. Readiness must disclose that task solvability, arm loading/fidelity, isolation and model behavior were not tested.
- P1 E5 — AC4 verifies freeze, not fairness. Task-applicability selection needs independent closure rationale; adapter-ineligible must remain a P2 blocker.
- P2 E6 — keep small-sample limits and pre-register P2 analysis. No extra P1 large-sample expansion needed.

Original report received in conversation before revision 1.1. No first-round PASS is claimed.
