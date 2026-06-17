# Regression Check — code-security

**Date**: 2026-06-17
**Baseline**: dogfood-code-security.prev.md (2026-06-16)
**Current pack**: .claude/skills/code-security/SKILL.md + references/

## Task

Review a security pipeline running Semgrep + Nuclei, dumping CRITICAL CVSS to dev channel, fixing top-down by severity, flat 14-day KEV deadline, secret scanning setup request.

## Methodology

1. Read the previous dogfood judgment to identify the winning answer (A1) and its verified correct claims.
2. Read all current pack files (SKILL.md + 5 reference files).
3. Answered the task using current pack rules.
4. Compared every verified-correct claim from A1 against the current pack's coverage.

## Claim-by-Claim Comparison

| Prev A1 Claim (verified correct by judge) | Current Pack Coverage | Status |
|---|---|---|
| BOD 26-04 supersedes/revokes BOD 22-01 (June 2026) | V7: explicit, with TIME-SENSITIVE CORRECTION callout | RETAINED |
| BOD 26-04 risk-based tiers (3-day fastest with forensic) | V7: 3 tiers (Fastest 3d / Fast 14d / Slower) | RETAINED |
| FIRST.org EPSS stats (57.4% / 82.2% / 3.96% / ~96% waste) | V1: exact numbers with source citation | RETAINED |
| EPSS >= 0.1 is ~20x less work, ~16x more efficient | V1: exact claim preserved | RETAINED |
| TruffleHog exit code 183 = verified credential | SE4: full exit code table | RETAINED |
| Nuclei v3 default rate limit 150 req/s | D4: explicit with precedence rule | RETAINED |
| Semgrep `--pro` enables interfile taint | S4: detailed with perf improvement note | RETAINED |
| `semgrep ci` on GH Actions `pull_request` is auto diff-aware | S3: explicit with "do NOT set SEMGREP_BASELINE_REF" note | RETAINED |
| SSVC decision tree (Act/Attend/Track*/Track) | V1: full table with timeline | RETAINED |
| Priority formula P0-P3 with CVSS+EPSS+KEV+reachability | V1: full formula preserved | RETAINED |

## Known Baseline Errors (NOT regressions — same error in both)

| Error | Baseline Status | Current Status |
|---|---|---|
| GitLab CI/CD grouped with Jenkins as needing SEMGREP_BASELINE_REF | A1 had this error, judge flagged PARTIALLY WRONG | S3 still says "Jenkins / GitLab CI / other systems" — same error persists |
| Gitleaks pre-commit rev: v8.18.0 (from 2019, latest is v8.30.1) | A1 had this, judge flagged OUTDATED | SE1 still pins v8.18.0 — same outdated pin |

These are pre-existing errors in both baseline and current, not regressions.

## Coverage Gaps from A2 (loser, not regressions)

The judge noted A2 had broader coverage (SCA gap, authenticated DAST, IaC, container scanning, pipeline architecture). These items were NOT in the winning answer and therefore NOT part of the baseline to regress against. However, the current pack actually covers most of them (V3 for SCA/containers, IaC reference, Four-Gate Pipeline cross-cutting rule).

## Verdict

**No regression found.** All verified-correct knowledge from the previous winning answer (A1) is fully retained in the current pack version. The two known errors (GitLab CI/CD baseline ref, Gitleaks v8.18.0 pin) are pre-existing in both the baseline and the current pack — they are not regressions but rather unfixed issues that should be addressed in a future pack update.
