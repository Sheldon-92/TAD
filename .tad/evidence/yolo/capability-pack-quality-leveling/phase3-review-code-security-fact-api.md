# Phase 3 Adversarial Review — code-security pack — fact-api lens

- **Lens**: fact-api (factual / API / version-sensitive correctness; replaces cross-model review)
- **Reviewer**: Claude Opus 4.8 subagent, 2026-06-13
- **meets_bar**: true (with required fixes — see findings; no fabricated-fact / hard-block error, but 2 wrong-API claims should be fixed before "accepted")

---

## meets_bar rationale

The pack's headline version-sensitive claims are remarkably well-grounded: every extraordinary
claim I could falsify (BOD 26-04 exists and supersedes BOD 22-01, EPSS v4 date, the exact
FIRST.org effort/coverage/efficiency numbers, osv-scanner v2 + v2.3.5 transitive-Python, TruffleHog
exit 183, Nuclei rate-limit precedence) checks out against current primary docs. That clears the
fact-api bar that "version-sensitive specifics must be verifiable," which is exactly where same-model
loops historically leak ~44 errors. BUT there are 2 genuine wrong-API errors (osv-scanner KEV flag,
Checkov CKV_AWS_19 meaning) and 1 stale/deprecated-command gap (gitleaks protect/detect) that a
ruthless fact-api pass must flag. None are fabrications that poison the core thesis, so meets_bar=true
with fixes mandated, not a FAIL.

---

## Findings (ordered by severity)

### P1 — Wrong Checkov ID semantics: CKV_AWS_19 is encryption-at-rest, NOT "Public S3 bucket"
`references/iac-security-rules.md` I3 compliance table (line ~106) maps **CKV_AWS_19 → "Public S3 bucket"**,
and `vulnerability-triage-rules.md` V4 dedup example (line ~159) repeats it ("CKV_AWS_19 + main.tf" as a
public-bucket finding). Primary source: Checkov's CKV_AWS_19 = *"Ensure all data stored in the S3 bucket is
securely encrypted at rest"* (server-side encryption), not public access. Public-bucket exposure is a
different family of IDs (CKV_AWS_53/54/55/56 public-access-block, or CKV2 graph checks). This is exactly
the "wrong constant/ID" class the lens hunts. Fix: relabel CKV_AWS_19 as encryption-at-rest, or swap the
public-bucket row to a correct public-access ID.

### P1 — Wrong osv-scanner KEV invocation + stale v1 flag
`vulnerability-triage-rules.md` V7 (line ~259): `osv-scanner -r . --experimental-all-packages` claimed to
"flag KEV-listed vulns automatically." Two errors: (a) `-r` is the v1-era recursive flag; v2 syntax (used
correctly everywhere else in the pack) is `osv-scanner scan source .`. (b) `--all-packages` /
`--experimental-all-packages` outputs ALL packages — it does NOT flag KEV. KEV auto-tagging in osv-scanner
is an open proposal/discussion (#2397), not a shipped feature. The surrounding curl-to-cisa.gov KEV check is
fine; the osv-scanner line is factually wrong on both the command and the capability. Fix: delete the
"osv-scanner flags KEV automatically" claim or replace with the manual KEV-feed join already shown above it.

### P2 — gitleaks `protect`/`detect` are deprecated (v8.19.0); pack uses them throughout with no warning
SE1/SE2/SE3/SE7 use `gitleaks protect --staged` and `gitleaks detect --source`. As of gitleaks v8.19.0
these legacy commands are deprecated (hidden in --help) in favor of `gitleaks git` / `gitleaks dir` /
`gitleaks stdin` (migration: `gitleaks protect --staged` -> `gitleaks git --pre-commit --staged`). Commands
still function, so not a hard error, and the pack pins `rev: v8.18.0` (pre-deprecation) so it's internally
consistent. But a pack advertising "current version" should note the deprecation + new syntax. Fix: add a
one-line note + the `gitleaks git --pre-commit --staged` form.

### P2 — "EPSS 0.10 ≈ 88th percentile" is asserted as fact but not on the cited primary page
V1 (line ~49) and `scripts/triage-prioritize.sh` (pctBand + footer) hardcode "0.10 ≈ 88th percentile." This
is NOT on the cited FIRST.org /epss/model page (it has no percentile mapping; that lives in a separate
"Understanding EPSS Probabilities and Percentiles" blog). EPSS percentiles also drift each model rebuild, so
a frozen 0.10=88th is time-sensitive. The pack already hedges well ("present prob% (Nth pct) rather than
inventing a cutoff"), so impact is low. Fix: cite the percentile-specific FIRST source or soften to "~top
~10-12%."

### P3 — Semgrep v1.163.0 date off by ~2 weeks
SKILL Tool Quick Reference + sast-rules S1 say "v1.163.0 (2026-05-27)". Actual release = 2026-05-13. Version
number is correct; date is wrong. The "~25-30% scan-time reduction" claim is corroborated by the v1.163.0
changelog (parallel rule parsing/validation, prefiltering) vs v1.162.0. Fix: 2026-05-27 -> 2026-05-13.

### P3 — Nuclei concurrency default stated as 10; actual default is 25
`dast-rules.md` D4 table (line ~93) lists `-c`/`-concurrency` v3 default = **10**. ProjectDiscovery mass-
scanning docs: default `-c` = **25** (and `-bs` = 25, `-rl` = 150). The `-rl` value (150), `-bs` (25), and
the precedence rule (rl caps total throughput regardless of c/bs) are all correct — only the concurrency
default number is wrong. Fix: 10 -> 25.

### Note (not a defect) — BOD 26-04 tier compression is acceptable
V7 collapses the directive's four tiers (3d / 14d / 60d / next-major-upgrade) into "Fastest 3d / Fast 14d /
Slower=longer." The 3-day all-four-signals condition + forensic-triage-on-total-control are verified correct.
The compression of 60d+next-upgrade into "longer tiers (per directive risk band)" is a fair simplification,
not an error — but could optionally name the 60-day tier for precision.

---

## fact_checks (each = one verified claim against current primary doc)

1. Semgrep v1.163.0 — VERSION CORRECT, DATE WRONG. Released 2026-05-13 (pack says 2026-05-27). ~25-30% scan-time drop vs 1.162.0 corroborated by changelog (parallel parse/validate + prefilter). Source: pypi.org/project/semgrep, github.com/semgrep/semgrep CHANGELOG.
2. Nuclei v3 defaults — `-rl` 150 CORRECT; `-bs` 25 CORRECT; precedence (rl caps throughput) CORRECT; `-c` default WRONG (pack 10, actual 25). Source: docs.projectdiscovery.io/tools/nuclei/mass-scanning-cli.
3. TruffleHog exit 183 (verified leaked creds, only with --fail) — CORRECT. `--only-verified` works but newer canonical flag is `--results=verified`. Source: github.com/trufflesecurity/trufflehog.
4. osv-scanner v2 (released 2025-03-17) added container scanning + Maven guided remediation + interactive HTML — CORRECT. Source: security.googleblog.com 2025-03 announcement.
5. osv-scanner v2.3.5 transitive Python requirements.txt via deps.dev API — CORRECT (Feature #2571). Source: github.com/google/osv-scanner releases/tag/v2.3.5.
6. osv-scanner KEV auto-flag via `osv-scanner -r . --experimental-all-packages` — WRONG. `-r` is v1 syntax; `--all-packages` lists packages, does not flag KEV; KEV tagging is proposal #2397, not shipped. Source: github.com/google/osv-scanner discussions/2397 + usage docs.
7. CISA BOD 26-04 (issued 2026-06-10) supersedes/revokes BOD 22-01 (and BOD 19-02); risk-based tiers; drops CVSS as required input — CORRECT. Source: cisa.gov/news-events/directives/bod-26-04.
8. BOD 26-04 deadline tiers — 3-day requires all four signals (internet-exposed + KEV + automatable + attacker-gains-control) + forensic triage on the fastest rows — CORRECT. Actual directive has FOUR tiers (3d/14d/60d/next-upgrade); pack compresses to 3/14/longer (acceptable). Source: automox.com BOD 26-04 analysis.
9. EPSS v4 released 2025-03-17, monitors 10,000+ CVEs/month — CORRECT. Source: research.empiricalsecurity.com Introducing EPSS v4 + first.org.
10. FIRST.org strategy numbers — CVSS≥7: 57.4% effort / 82.2% coverage / 3.96% efficiency CORRECT; EPSS≥0.1: 2.7% / 63.2% / 65.2% CORRECT (verbatim from FIRST page). Source: first.org/epss/model.
11. "EPSS 0.10 ≈ 88th percentile" — UNVERIFIED on cited model page (no percentile mapping there); plausible but time-sensitive/drifts per model rebuild. Source: first.org/epss/model (absence).
12. gitleaks `protect`/`detect` — DEPRECATED in v8.19.0 (hidden, still functional); new commands `gitleaks git/dir/stdin`; migration `protect --staged` -> `git --pre-commit --staged`. Pack pins v8.18.0 (pre-deprecation, internally consistent) but doesn't warn. Source: github.com/gitleaks/gitleaks README + pkg.go.dev v8.
13. Checkov CKV_AWS_19 — pack labels it "Public S3 bucket"; actual = "Ensure all data stored in the S3 bucket is securely encrypted at rest" (encryption-at-rest). WRONG mapping. CKV_AWS_18 = access logging (pack's I2 suppression example uses this correctly). Source: bridgecrewio/checkov + checkov.io docs.
