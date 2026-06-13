# SAST Scanning Rules
<!-- capability: sast_scan -->

## Quick Rule Index

| # | Rule | Scope |
|---|------|-------|
| S1 | Default tool: Semgrep v1.163.0; `semgrep ci` for CI, `semgrep scan` for local, `--pro` for interfile | tool-selection |
| S2 | Rule sets: `p/ci` for general, `p/security-audit` for deep, `p/owasp-top-ten` for compliance | config |
| S3 | Diff-aware scanning: GitHub Actions auto-diffs on `pull_request` (no env var); set SEMGREP_BASELINE_REF=main only on Jenkins/GitLab | ci-pipeline |
| S4 | Taint mode: `mode: taint` + `--pro` interfile (cross-file) data-flow for real SQLi/SSRF flows | custom-rules |
| S5 | SARIF output: `--sarif` for GitHub Security tab integration | output |
| S6 | Exit code: 1 = blocking findings, 0 = clean — use in CI gate decisions | ci-pipeline |
| S7 | Custom rules: YAML with metavariables ($X) and ellipsis (...) for pattern matching | custom-rules |
| S8 | Baseline mode: `--baseline-commit` for existing codebases to avoid alert flood | adoption |

---

## Rules

### S1: Tool Selection — Semgrep as Default SAST

When setting up SAST scanning, start with Semgrep:

```bash
# Local scan (developer workstation)
semgrep scan --config auto .

# CI mode (GitHub Actions, GitLab CI, etc.)
semgrep ci
```

Semgrep covers 30+ languages with 2000+ free community rules (current engine: **v1.163.0, 2026-05-27**). It is the correct default because:
- Zero config needed (`--config auto` selects rules by detected language)
- Fast enough for PR gates (<30s on most repos) — recent Community Edition releases cut scan time **~25-30%** via parallel rule parsing + prefiltering
- SARIF output for GitHub Security tab
- The `--pro` flag unlocks **interfile (cross-file) dataflow/taint analysis** (see S4) — the main reason cross-module SQLi/SSRF flows are caught

Add language-specific tools only when Semgrep coverage is insufficient:
- Python deep analysis: add `bandit -r ./src -ll`
- Deep semantic (Java/C#/Go/JS/TS/Python): add CodeQL (runs in full CI, not PR gate — too slow)
- Data-flow PII tracking: add `bearer scan .`

**Anti-pattern**: Installing 4 SAST tools on day one. Start with Semgrep alone. Add tools only when you find specific coverage gaps.

### S2: Rule Set Selection

Match rule set to scan objective:

| Objective | Command | When |
|-----------|---------|------|
| General security | `semgrep scan --config auto .` | Default for all projects |
| OWASP Top 10 audit | `semgrep scan --config p/owasp-top-ten .` | Compliance-driven scan |
| Security audit (deep) | `semgrep scan --config p/security-audit .` | Pre-release deep scan |
| Language-specific | `semgrep scan --config p/python .` | Targeted scan |
| CI pipeline | `semgrep ci` | Automated CI (uses SEMGREP_APP_TOKEN) |
| Custom + community | `semgrep scan --config auto --config ./rules/ .` | Custom rules alongside defaults |

For CI with Semgrep App integration:
```bash
export SEMGREP_APP_TOKEN=<your-token>
semgrep ci
```

**Anti-pattern**: Running `p/security-audit` (deep, slow) in PR gates. Use `p/ci` or `auto` for PR speed, reserve `security-audit` for nightly/weekly.

### S3: Diff-Aware Scanning on PRs

On pull requests, scan only changed code to keep PR gates fast. **How you enable diff-aware depends on the CI system:**

```bash
# GitHub Actions: `semgrep ci` on a `pull_request` trigger is AUTOMATICALLY
# diff-aware. Do NOT set SEMGREP_BASELINE_REF — it does not apply to GitHub
# Actions (per Semgrep docs) and is silently ignored.
semgrep ci

# Jenkins / GitLab CI / other systems: set the baseline ref manually
export SEMGREP_BASELINE_REF=main
semgrep ci
```

This tells Semgrep to report only NEW findings introduced by the PR, not existing tech debt. Without this:
- Every PR shows hundreds of pre-existing findings
- Developers ignore all findings (alert fatigue)
- Real new vulnerabilities get lost in the noise

For non-Semgrep-App setups:
```bash
semgrep scan --config auto --baseline-commit=$(git merge-base HEAD main) .
```

**Anti-pattern**: Running full-repo scan on every PR without baseline. This is the #1 cause of "developers ignoring SAST" — 30-50% of triage time wasted on pre-existing findings.

### S4: Taint Mode for Data-Flow Vulnerabilities

For vulnerabilities that require tracking data from source to sink (SQL injection, XSS, SSRF), use taint mode in custom rules:

```yaml
rules:
  - id: sql-injection-flask
    message: "User input flows to SQL query without parameterization"
    severity: ERROR
    languages: [python]
    mode: taint
    pattern-sources:
      - pattern: flask.request.$ATTR
    pattern-sinks:
      - pattern: cursor.execute($QUERY, ...)
    pattern-sanitizers:
      - pattern: parameterize(...)
```

Key concepts:
- `pattern-sources`: where untrusted data enters (request params, file reads)
- `pattern-sinks`: where data must not arrive unsanitized (SQL, shell, HTML)
- `pattern-sanitizers`: functions that make data safe (parameterization, escaping)
- Metavariables (`$X`): capture any expression in that position
- Ellipsis (`...`): match zero or more arguments

**Single-file vs interfile (cross-file) taint** — this is the difference between catching and missing real flows:

By default, taint mode tracks data flow **within a single file**. Most real SQLi/SSRF flows cross module boundaries (request handler in `routes.py` → service in `db.py` → raw query), and single-file taint never sees them. The **`--pro` flag enables interfile dataflow/taint analysis** across **C/C++/C#/Go/Java/JS/TS/Kotlin/Python/Scala**:

```bash
# Single-file taint (default) — misses cross-module flows
semgrep scan --config ./semgrep-rules/ .

# Interfile taint — tracks source→sink ACROSS files (Pro engine)
semgrep scan --pro --config ./semgrep-rules/ .
```

The redesigned Pro interfile engine gives **~20-40% taint-analysis perf improvement** and may shift the true/false-positive set (re-baseline after enabling). (Source: semgrep.dev release notes, retrieved 2026-06-13.)

**Anti-pattern**: Writing pattern-only rules for injection vulnerabilities. Without taint tracking, you get false positives on every SQL query, not just ones with user input flowing in. Second anti-pattern: relying on default single-file taint mode and concluding "no SQLi" — the real flow crosses files and is only visible with `--pro` interfile analysis.

### S5: SARIF Output for CI Integration

Always produce SARIF alongside JSON for GitHub Security tab integration:

```bash
# SARIF for GitHub code scanning
semgrep scan --config auto --sarif --output=sast-results.sarif .

# JSON for programmatic processing
semgrep scan --config auto --json --output=sast-results.json .

# Both in CI
semgrep scan --config auto --sarif --output=sast-results.sarif .
semgrep scan --config auto --json --output=sast-results.json .
```

GitHub Actions upload:
```yaml
- name: Upload SARIF
  uses: github/codeql-action/upload-sarif@v3
  with:
    sarif_file: sast-results.sarif
```

SARIF is the standard interchange format. All major SAST tools produce it (Semgrep, Bandit, CodeQL, Bearer). GitHub Security tab consumes it natively.

**Anti-pattern**: Using only human-readable text output in CI. Text output cannot be uploaded to GitHub Security tab, cannot be compared across runs, and cannot be consumed by ASPM platforms.

### S6: Exit Code Pipeline Gating

Semgrep exit codes determine CI pass/fail:

| Exit Code | Meaning | CI Action |
|-----------|---------|-----------|
| 0 | No findings (or only informational) | Pass |
| 1 | Blocking findings found | Fail pipeline |
| 2+ | Scanner error (config issue, crash) | Fail pipeline (investigate) |

In CI, use the exit code directly. **Run `semgrep ci` inside the official `semgrep/semgrep` container** — do NOT use the deprecated `semgrep/semgrep-action@v1` / `returntocorp/semgrep-action@v1` GitHub Actions (both repos are archived; Semgrep now recommends native `semgrep ci`):
```yaml
# GitHub Actions — current recommended setup
semgrep:
  runs-on: ubuntu-latest
  container:
    image: semgrep/semgrep        # official image; pin a digest/tag in prod
  if: github.actor != 'dependabot[bot]'
  steps:
    - uses: actions/checkout@v4
    - name: SAST Scan
      run: semgrep ci             # auto diff-aware on pull_request; exit 1 fails the step
      env:
        SEMGREP_APP_TOKEN: ${{ secrets.SEMGREP_APP_TOKEN }}  # for managed policy / Supply-Chain / Pro
```
If you are not using Semgrep Cloud, drop `SEMGREP_APP_TOKEN` and pass rules explicitly, e.g. `run: semgrep ci --config auto` (or `--config p/ci`).

For soft-fail during adoption (existing codebase, first rollout):
```bash
semgrep scan --config auto . || true  # temporary: log but don't block
```

Transition plan: start with `|| true`, then switch to hard-fail after baseline clears.

**Anti-pattern**: Running Semgrep with `|| true` permanently. Soft-fail is an adoption tool, not a steady state. Set a deadline (e.g., 2 sprints) to switch to hard-fail.

### S7: Custom Rule Patterns

Write custom rules for project-specific patterns:

```yaml
rules:
  - id: no-eval-user-input
    message: "eval() called with potentially untrusted input"
    severity: ERROR
    languages: [python]
    patterns:
      - pattern: eval($X)
      - pattern-not: eval("...")  # literal strings are safe

  - id: no-hardcoded-localhost
    message: "Hardcoded localhost URL — use environment variable"
    severity: WARNING
    languages: [python, javascript, typescript]
    pattern: $URL = "http://localhost:$PORT/..."
```

Metavariable reference:
- `$X`: matches any single expression
- `$...X`: matches zero or more arguments
- `...`: matches zero or more statements
- `$_`: matches anything (unnamed capture)

Store custom rules in `./semgrep-rules/` at repo root. Load alongside community rules:
```bash
semgrep scan --config auto --config ./semgrep-rules/ .
```

### S8: Baseline Mode for Existing Codebases

When adopting SAST on an existing codebase, use baseline to avoid overwhelming developers:

```bash
# Record current state as baseline
semgrep scan --config auto --baseline-commit=$(git rev-parse main) .

# Future scans show only NEW findings.
# NOTE: SEMGREP_BASELINE_REF applies to Jenkins/GitLab/local CI only.
# On GitHub Actions, `semgrep ci` is auto diff-aware on pull_request — omit this.
export SEMGREP_BASELINE_REF=main
semgrep ci
```

Adoption timeline:
1. **Week 1**: Run full scan, triage P0/P1, establish baseline
2. **Week 2-4**: Diff-aware on PRs (new findings only), fix P0 backlog
3. **Month 2+**: Hard-fail on new findings, continue backlog burn-down
4. **Quarter 2+**: Expand rule sets (add security-audit, custom rules)

**Anti-pattern**: Running full scan without baseline on a legacy codebase. 500+ findings on day one guarantees the team ignores SAST permanently.

---

## Common Semgrep Gotchas

1. **`semgrep ci` vs `semgrep scan`**: `ci` uses SEMGREP_APP_TOKEN for managed policy; `scan` is local-only
2. **Config auto vs explicit**: `auto` selects rules by detected language; explicit (`p/python`) overrides
3. **Memory on large repos**: Use `--max-memory 4096` flag if Semgrep OOMs on monorepos
4. **Timeout on complex rules**: Taint rules on large files can timeout; use `--timeout 60` (default 30s)
5. **nosemgrep comment**: Suppress inline with `# nosemgrep: rule-id` — requires documented justification
