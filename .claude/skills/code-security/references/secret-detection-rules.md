# Secret Detection Rules
<!-- capability: secret_detection -->

## Quick Rule Index

| # | Rule | Scope |
|---|------|-------|
| SE1 | Two-layer defense: pre-commit (Gitleaks) + CI (Gitleaks + TruffleHog) | architecture |
| SE2 | Pre-commit hook: Gitleaks `protect --staged` in .pre-commit-config.yaml | prevention |
| SE3 | Baseline management: `--baseline-path` for delta scanning (new secrets only) | adoption |
| SE4 | TruffleHog `--fail` flag: exit 183 blocks CI on verified leaked credentials | ci-pipeline |
| SE5 | Inline suppression: `# gitleaks:allow` with mandatory review | suppression |
| SE6 | Remediation order: rotate FIRST, then clean code, then purge history | incident |
| SE7 | Verified vs unverified: TruffleHog `--only-verified` for active credential detection | triage |

---

## Rules

### SE1: Two-Layer Secret Detection Architecture

Secret detection MUST run at two layers — pre-commit hooks alone are insufficient:

| Layer | Tool | Command | Why |
|-------|------|---------|-----|
| Pre-commit | Gitleaks | `gitleaks protect --staged -v` | Fast (<5s), catches before commit |
| CI pipeline | Gitleaks + TruffleHog | See SE4 | Safety net (catches `--no-verify` bypass) |

Why both layers:
- Pre-commit: `git commit --no-verify` bypasses ALL hooks. Any developer can skip it.
- CI-only: secrets exist in working copy for minutes/hours before CI runs.
- Both: defense in depth. Pre-commit is the fast feedback loop; CI is the safety net.

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.18.0  # pin version
    hooks:
      - id: gitleaks
```

**Anti-pattern**: Pre-commit hooks without CI verification. A single `--no-verify` flag bypasses the entire secret detection layer.

### SE2: Pre-Commit Hook Setup

Install Gitleaks as a pre-commit hook for instant feedback:

```bash
# Option 1: via pre-commit framework
pip install pre-commit
# Add .pre-commit-config.yaml (see SE1)
pre-commit install

# Option 2: native git hook
# .git/hooks/pre-commit
#!/bin/bash
gitleaks protect --staged -v
```

Pre-commit scan MUST complete in <5 seconds. If it exceeds this:
- Check if `.gitleaks.toml` allowlist is configured (reduces regex matching)
- Ensure only staged files are scanned (`--staged` flag, not full repo)
- Large binary files should be in `.gitignore` (not scanned)

```bash
# Verify hook timing
time gitleaks protect --staged -v
# Should be <5s. If >10s, add allowlist paths.
```

**Anti-pattern**: Installing secret detection as a CI-only check. By the time CI runs, the secret has been pushed to the remote — it is already in git history.

### SE3: Baseline Management for Existing Repos

When adopting secret scanning on a repo with existing history, use baseline to avoid alert flood:

```bash
# Step 1: Generate baseline (record existing known findings)
gitleaks detect --source . --report-format json --report-path .gitleaks-baseline.json -v

# Step 2: Review and triage existing findings
# (rotate any truly active secrets found in baseline)

# Step 3: Future scans compare against baseline (only NEW secrets reported)
gitleaks detect --source . --baseline-path .gitleaks-baseline.json -v
```

Baseline workflow:
1. Run full scan, export to `.gitleaks-baseline.json`
2. Triage: rotate active secrets, accept-risk historical ones
3. Commit baseline file to repo
4. Future CI scans use `--baseline-path` — only new findings trigger alerts
5. Periodically re-audit baseline (quarterly)

**Anti-pattern**: Running full history scan without baseline on day one. Hundreds of historical findings (many already rotated) cause immediate alert fatigue and team rejection.

### SE4: TruffleHog CI Integration and Exit Code 183

TruffleHog verifies secrets are actually active by testing them against services. Use `--fail` flag in CI:

```bash
# CI pipeline: scan and fail on verified leaks
trufflehog git file://. --only-verified --fail --json > trufflehog-results.json
```

Exit codes:
| Code | Meaning | CI Action |
|------|---------|-----------|
| 0 | No verified secrets found | Pass |
| 1 | Scanner error | Fail (investigate) |
| 183 | Verified leaked credentials found | **Fail pipeline — credential is ACTIVE** |

Exit 183 specifically means: TruffleHog found a credential AND confirmed it works by testing against the service (AWS, GitHub, Slack, Stripe, etc.). This is not a false positive.

```yaml
# GitHub Actions
- name: Secret scan (TruffleHog)
  run: |
    trufflehog git file://. --only-verified --fail --json > trufflehog.json
  # Exit 183 automatically fails this step
```

TruffleHog scan modes:
```bash
# Git repo (all history)
trufflehog git file://. --only-verified --json

# Remote repo
trufflehog git https://github.com/org/repo --only-verified --json

# Filesystem (no git history)
trufflehog filesystem /path/to/code --only-verified --json

# S3 bucket
trufflehog s3 --bucket=my-bucket --only-verified --json
```

**Anti-pattern**: Using TruffleHog without `--only-verified`. Unverified findings have high false-positive rate. Use Gitleaks for broad pattern matching, TruffleHog specifically for verification of active credentials.

### SE5: Inline Suppression Rules

Suppress known false positives with inline comments:

```python
# Gitleaks suppression
api_key = "EXAMPLE_KEY_FOR_DOCS"  # gitleaks:allow

# detect-secrets suppression
password = "test-fixture-not-real"  # pragma: allowlist secret
```

Suppression governance:
1. Every `# gitleaks:allow` MUST have a code review comment explaining why
2. Suppressions should be reviewed quarterly (they accumulate)
3. Configure `.gitleaks.toml` for project-wide patterns:

```toml
# .gitleaks.toml
[allowlist]
  description = "Project-wide allowlist"
  paths = [
    "test/fixtures/*",
    "docs/examples/*",
    "*.test.*",
  ]
  regexes = [
    "EXAMPLE_KEY_.*",
    "sk-test-.*",
    "placeholder",
  ]
```

**Anti-pattern**: Adding `# gitleaks:allow` to suppress a real secret instead of rotating it. Suppression is for false positives and test fixtures, not for convenience.

### SE6: Secret Remediation Order

When a secret is found in code or git history, follow this EXACT order:

```
Step 1: ROTATE the credential (generate new key via service dashboard)
  -> The old credential is assumed compromised from the moment it was committed
  -> Do NOT wait to "understand the impact" — rotate FIRST

Step 2: Update running applications to use the new credential
  -> Deploy with new secret via vault/env/CI secrets

Step 3: Remove secret from code
  -> Delete from source files
  -> Add pattern to .gitleaks.toml allowlist

Step 4: Purge from git history (if committed)
  -> bfg --replace-text passwords.txt repo.git
  -> git filter-repo --invert-paths --path secrets.env
  -> Force push cleaned history
  -> Notify all contributors to re-clone

Step 5: Prevent recurrence
  -> Add pre-commit hook (SE2)
  -> Add CI scan (SE4)
  -> Move secret to vault/env vars
```

Why rotate FIRST:
- From the moment a secret enters git history, it is accessible to anyone with repo access
- GitHub/GitLab search indexes commit content — the secret may already be scraped
- Cleaning code without rotating leaves the attacker with a working credential

**Anti-pattern**: Deleting the secret from code and assuming the problem is solved. The secret is in git history. Anyone who cloned the repo (or a scraper that indexed it) has it.

### SE7: Verified vs Unverified Secret Triage

Not all detected secrets are equally urgent:

| Category | Priority | Action |
|----------|----------|--------|
| Verified active (TruffleHog confirmed) | P0 | Rotate immediately |
| Unverified, in current code | P1 | Investigate + rotate if real |
| Unverified, in git history only | P2 | Check if already rotated |
| Test fixture / example key | P3 | Suppress with `# gitleaks:allow` |

```bash
# TruffleHog: only verified (high confidence)
trufflehog git file://. --only-verified --json

# Gitleaks: all patterns (broad, includes unverified)
gitleaks detect --source . --report-format json --report-path findings.json -v
```

Use TruffleHog for triage prioritization (verified = P0), Gitleaks for coverage (catches patterns TruffleHog doesn't test against).

**Anti-pattern**: Treating all Gitleaks findings as P0. Many matches are false positives (high-entropy strings, test fixtures, example keys). Use TruffleHog verification to separate real from noise.

---

## Secret Type Coverage

Top secret types that MUST be detected:

| Type | Example Pattern | Tool Coverage |
|------|----------------|---------------|
| AWS Access Key | `AKIA[0-9A-Z]{16}` | Gitleaks, TruffleHog (verified) |
| GitHub Token | `ghp_[A-Za-z0-9]{36}` | Gitleaks, TruffleHog (verified) |
| Private Key | `-----BEGIN RSA PRIVATE KEY-----` | Gitleaks, TruffleHog |
| Slack Token | `xoxb-[0-9]{10,}` | Gitleaks, TruffleHog (verified) |
| Stripe Key | `sk_live_[A-Za-z0-9]{24,}` | Gitleaks, TruffleHog (verified) |
| DB Connection String | `postgres://user:pass@host/db` | Gitleaks |
| JWT Secret | High-entropy string in config | Gitleaks (heuristic) |
| Generic API Key | `api_key`, `apikey`, `API_KEY` variable assignments | Gitleaks |
