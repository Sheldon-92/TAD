# Dogfood Judgment: code-security pipeline task

## Task
Set up a security scanning pipeline (SAST, secrets, SCA, IaC/Terraform) in GitHub Actions for a
Python + TypeScript monorepo; pick concrete tools + config; specify triage to avoid day-one noise;
be explicit about gate vs. report-only.

## WebSearch verification of key specifics

| Claim | Answer | Verdict |
|---|---|---|
| TruffleHog `--fail` exit code **183** on verified secret | A1 | CORRECT — exit 183 = "no errors but results found", only with `--fail` |
| BOD 26-04 risk tiers (internet-facing+KEV+automatable+total-control → **3 days**; partial → 14/60d) | A1 | CORRECT — CISA BOD 26-04 issued 2026-06-10, four-variable model, 3/14/60-day tiers, supersedes BOD 22-01 |
| EPSS: ~**96%** of CVEs <0.1 EPSS neither exploited nor remediated; managed by FIRST.org | A1 | CORRECT |
| EPSS 0.1 ≈ 88th percentile / "top-12%" | A1 | Directionally correct (percentile is a monotonic function of score; exact mapping drifts daily but 0.1 is a high percentile). Not wrong. |
| Checkov `--hard-fail-on CRITICAL,HIGH` valid severity flag | A1 | CORRECT syntax. Caveat neither answer flags: severity metadata on OSS checks historically needs a BC/Prisma API key — a real gotcha both miss. |
| osv-scanner v2 `scan source --lockfile=` + `scan image` subcommands | A1 | CORRECT — v2 uses `scan source` (default) / `scan image` hierarchy |
| `SEMGREP_BASELINE_REF=main` for diff-aware | A1 | Real env var, but per Semgrep docs it "does NOT apply to GitHub Actions" (auto-handled there). A1 sets it inside a GH Actions job → harmless redundancy, not a false claim. |
| `semgrep ci` diff-aware on PRs by default; `semgrep scan` is full-repo | A2 | CORRECT |
| osv-scanner reads `uv.lock`/`pnpm-lock.yaml` for transitive deps | A2 | CORRECT |
| `--only-verified` checks if credential is live | A2 | CORRECT |

### Shared inaccuracy (equal weight, penalizes neither over the other)
- **Both** cite a DEPRECATED Semgrep action: A1 `returntocorp/semgrep-action@v1`, A2 `semgrep/semgrep-action@v1`.
  Both repos are archived; current guidance is native `semgrep ci` via the `semgrep/semgrep` image.
  A2 partially hedges by also showing bare `semgrep ci` semantics; A1 leans on the deprecated action node.
  Net: a wash.

**No materially WRONG specific found in either answer.** Every distinctive number/threshold/tool A1 leaned
on (183, BOD 26-04 tiers, EPSS 96%, osv-scanner v2 syntax, Checkov flag) verified TRUE. A2's claims also
verified TRUE. This is the key finding: A1's confidence is *earned*, not bluffed.

## Scoring

### Answer 1 (the skill-backed one — rule citations S1/SE1/V1/I7, bundled triage scripts)
- Correctness: **5** — every checked specific is correct; the one debatable item (SEMGREP_BASELINE_REF in GHA)
  is redundant, not wrong.
- Actionability: **5** — pre-commit + PR + nightly split, exit-code-mapped gate table, week-by-week ramp,
  rotate-first secret runbook, suppression governance, deterministic triage script.
- Specificity: **5** — KEV+EPSS+reachability triage stack with an explicit P0-P3 formula and BOD 26-04
  deadline tiers; this is the part the task explicitly asked for ("how to triage so the team isn't drowned")
  and A1 answers it at a depth A2 does not reach.
- Completeness: **5** — covers the deliberately-omitted tools (Bandit/CodeQL/DAST) with reasons, flags
  coverage gaps (no DAST target, no container scan), suppression + rotation governance.

### Answer 2 (the generalist — also strong, GitHub-native framing)
- Correctness: **5** — all checked claims correct; same deprecated-action issue as A1 (shared).
- Actionability: **5** — full runnable PR + nightly YAML, branch-protection required-status-checks step
  (which A1 omits and is genuinely necessary — "workflows don't gate, required checks do" is a real
  insight A1 misses), CODEOWNERS routing, dismiss-with-reason audit trail.
- Specificity: **4** — gate matrix is good ((new)×(high severity)×(actionable) is a defensible heuristic),
  but the triage layer is shallower: SLA table is a flat 7d/30d (vs A1's exploit-aware KEV/EPSS/reachability
  model + current BOD 26-04 tiers). On the task's single most-emphasized ask (triage depth), A2 is one tier down.
- Completeness: **4** — covers branch protection + CODEOWNERS (A1 gaps), but no reachability concept,
  no rotate-first runbook, no explicit deprecated-tool/coverage-gap callouts.

## Decision
- **Winner: Answer 1**, margin **slight**.
- What decided it: the task put the heaviest weight on triage ("critically, tell me how to triage so the
  team isn't drowned... be specific about gate vs report-only"). A1 delivers a verifiably-CORRECT,
  exploit-aware triage stack (KEV → EPSS → reachability → dedup, P0-P3 formula, current BOD 26-04 deadline
  tiers) that is both more specific AND confirmed accurate by WebSearch — not verbosity, real correct
  specifics. A2 is genuinely excellent and beats A1 on two real points (branch-protection required-status-
  checks as the actual enforcement mechanism; CODEOWNERS routing) — these are not noise and keep the margin
  to "slight," not "clear." But A2's triage SLA is a generic flat table where A1's is risk-based and current.
- It was NOT verbosity that won. A1 is longer, but the win comes from correct, load-bearing specifics on the
  exact dimension the user prioritized. Had any of A1's distinctive numbers been wrong (183, BOD 26-04, EPSS),
  this would have flipped — they all held.
- Best-of-both: A1's triage model + A2's branch-protection/CODEOWNERS enforcement layer + drop the deprecated
  Semgrep action in favor of native `semgrep ci`.
