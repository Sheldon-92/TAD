# Dogfood Judgment — Web Deployment Review (GitHub Actions in-place deploy)

Date: 2026-06-13
Judge: independent technical judge (blind to which answer used the skill)
Task: Review a GitHub Actions deploy workflow (checkout@v4, tj-actions/changed-files@v45,
upload-artifact@v3, long-lived AWS key, SSH in-place update, no rollback, only actionlint).

## WebSearch verification of key specifics

| Claim | Verdict | Source |
|---|---|---|
| tj-actions/changed-files supply-chain compromise = CVE-2025-30066 | TRUE | GitHub Advisory GHSA-mrrh-fwg8-r2c3 |
| Tags v1–v45.0.7 retroactively mutated to malicious commit | TRUE — v45 IS in range | CISA / GitHub Advisory |
| Dates 2025-03-14/15 | TRUE (malicious commit 03-12; tag mutation window 03-14→03-15) | Wiz / CISA |
| ~23,000 repos impacted | TRUE | TheHackerNews / Aqua |
| Patched in v46.0.1 | TRUE | tj-actions release v46.0.1 |
| Secrets dumped into build logs (AWS keys, PATs, npm, RSA) | TRUE | Multiple |
| upload-artifact@v3 shut down 2025-01-30, runs FAIL (not warn) | TRUE | GitHub Changelog / Issue #635 |
| upload-artifact v4: artifact name must be unique per run | TRUE | v4 migration docs |
| zizmor is a GHA security auditor; flags unpinned-uses, template-injection, excessive-permissions, known-vulnerable-actions, impostor-commit | TRUE | docs.zizmor.sh/audits |
| zizmor "would have mitigated every major GitHub Actions attack of the past 18 months" | TRUE (real maintainer claim) | zizmor project |
| OIDC via aws-actions/configure-aws-credentials, id-token: write | TRUE | AWS/GitHub docs |

### Wrong specifics found
NONE in either answer. Every load-bearing number, version, date, CVE id, and tool name in
both answers checks out against primary docs. This is a rare clean sheet on both sides.

## Scoring (1-5)

### Answer 1
- Correctness: 5 — all specifics correct; "early 2025" / "many tags including v45" are
  slightly less precise than A2 but not wrong.
- Actionability: 5 — explicit priority order, "do today" list, concrete YAML, symlink-swap
  rollback recipe, `set -euo pipefail`, host-key pinning, Dependabot+SHA combo.
- Specificity: 4 — names the right tools and mechanisms but omits the CVE number, exact
  patched version (v46.0.1), the 23k-repo/exposure-window facts, and the secret-rotation
  imperative.
- Completeness: 5 — adds two items A2 underplays: script-injection via `env:` for
  `${{ github.* }}` in `run:` steps, and SSH host-key pinning / known_hosts. Strong
  cross-cutting coverage plus a clean priority sequence.

### Answer 2
- Correctness: 5 — all specifics correct and the most precise of the two (CVE id, exact
  tag range, exact dates, patched v46.0.1, 2025-01-30 shutdown).
- Actionability: 5 — P0/P1/P2 triage, OIDC YAML, Docker-SHA immutable + one-command
  rollback, <5-min rollback SOP, health-check auto-revert, concurrency + environment gate,
  attest-build-provenance. Honest "no file exists, this is a judgment review."
- Specificity: 5 — adds the secret-ROTATION imperative (the genuinely critical follow-on
  that A1 misses: a v45 tag user was likely already exfiltrated and MUST rotate the AWS key),
  CVE number, exposure window, patched version.
- Completeness: 5 — covers everything A1 does on the supply-chain/auth/rollback axes plus
  provenance, concurrency, deployment gate, platform-fit. Minor gap vs A1: does not call out
  shell script-injection via `${{ }}` interpolation or SSH host-key pinning explicitly.
  The internal "(ci-cd CI9 / RB4 / SH8)" citation tags are skill-internal cross-refs — mildly
  noisy to an end reader but do not harm correctness.

## Winner: 2 — margin: slight

Rationale: This is a near-tie; both answers are correct, well-structured, and actionable
with ZERO wrong specifics on either side — so the decision is NOT about verbosity or
confident-wrongness. It turns on CORRECT specificity that materially changes operator action.
Answer 2 wins on two substantive, verified points: (1) it surfaces the secret-ROTATION
imperative — a v45-tag user during the exposure window was very likely already compromised,
so SHA-pinning forward is necessary but insufficient; the AWS key must be rotated NOW. A1
never says this, which is the single most consequential omission given the workflow stores a
long-lived key. (2) A2 anchors the supply-chain finding to the exact CVE, tag range, dates,
and patched version (v46.0.1), making the fix auditable. A1 is genuinely better on two
secondary axes (shell script-injection via `env:`, SSH host-key pinning) and has a cleaner
"do-today" priority narrative, which keeps the margin to slight rather than clear. If A1 had
included secret rotation it would likely be a tie.
