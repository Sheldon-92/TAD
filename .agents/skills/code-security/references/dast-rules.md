# DAST Scanning Rules
<!-- capability: dast_scan -->

## Quick Rule Index

| # | Rule | Scope |
|---|------|-------|
| D1 | Default tool: Nuclei for template-based scanning, ZAP for comprehensive web app testing | tool-selection |
| D2 | NEVER run active DAST against production — staging/dev only | safety |
| D3 | Severity filtering: `-severity critical,high` in CI, full spectrum in nightly | ci-pipeline |
| D4 | Rate limiting: `-rl` flag to avoid DoS'ing own infrastructure | safety |
| D5 | Template updates: `nuclei -update-templates` before every scan | freshness |
| D6 | Auto-scan mode: `-as` for target technology auto-detection | efficiency |
| D7 | SAST+DAST correlation: cross-reference findings for dual verification | accuracy |

---

## Rules

### D1: Tool Selection by Context

Match DAST tool to scanning context:

| Context | Tool | Command | When |
|---------|------|---------|------|
| CVE detection (known vulns) | Nuclei | `nuclei -u https://staging.example.com -tags cve` | Always — fast, template-based |
| Full web app testing | ZAP | `docker run zaproxy/zap-stable zap-full-scan.py -t URL` | Deep web app audit |
| API-specific | ZAP | `zap-api-scan.py -t openapi.yaml -f openapi` | API endpoints with OpenAPI spec |
| Server misconfiguration | Nikto | `nikto -h https://staging.example.com` | Quick server sweep |
| Cloud infrastructure | Nuclei | `nuclei -u target -tags cloud` | Cloud-exposed services |

Default recommendation:
- **Quick scan**: Nuclei with CVE + misconfig templates
- **Thorough audit**: Nuclei + ZAP full scan
- **API-focused**: ZAP API scan with OpenAPI spec

**Anti-pattern**: Using only Nuclei for web app testing. Nuclei matches known templates; ZAP discovers unknown vulnerabilities through active fuzzing.

### D2: Production Safety — NEVER Active-Scan Production

Active DAST scans send exploit payloads to the target. On production, this causes:
- Service disruption (fuzzing can crash endpoints)
- Data corruption (write-path injection tests)
- Alert fatigue in monitoring/WAF (legitimate-looking attacks from internal IPs)

```bash
# CORRECT: scan staging
nuclei -u https://staging.example.com -severity critical,high

# WRONG: scan production
# nuclei -u https://production.example.com  # NEVER DO THIS
```

Exception: **Passive-only** scanning (ZAP baseline scan) is safe for production:
```bash
# Passive only — safe for production monitoring
docker run zaproxy/zap-stable zap-baseline.py -t https://production.example.com
```

**Anti-pattern**: "We don't have staging, so we scan production carefully." Get a staging environment. There is no safe way to run active DAST against production.

### D3: Severity Filtering for CI Gates

In CI pipelines, filter by severity to keep gate fast and actionable:

```bash
# CI gate: block on critical and high only
nuclei -u https://staging.example.com -severity critical,high -json -o dast-ci.json

# Nightly full scan: all severities
nuclei -u https://staging.example.com -json -o dast-nightly.json

# Specific tag focus
nuclei -u https://staging.example.com -tags cve -severity critical,high
nuclei -u https://staging.example.com -tags misconfig
nuclei -u https://staging.example.com -tags tech -severity critical
```

Severity mapping for pipeline gating:
- **critical + high**: block deployment (P0/P1)
- **medium**: warn, track in backlog (P2)
- **low + info**: nightly scan only (P3)

**Anti-pattern**: Running all-severity scan in PR gate. Low/info findings flood the output and delay deployment without security benefit.

### D4: Rate Limiting to Protect Infrastructure

Always set rate limits to avoid overwhelming the target:

```bash
# Default: 150 requests/second (Nuclei default)
nuclei -u https://staging.example.com -rl 150

# Conservative: shared staging environment
nuclei -u https://staging.example.com -rl 50

# Aggressive: dedicated test environment
nuclei -u https://staging.example.com -rl 300

# Concurrent template limit
nuclei -u https://staging.example.com -rl 100 -c 25
```

Rate limit guidelines:
- **Shared staging**: `-rl 50` (other teams use it too)
- **Dedicated test**: `-rl 150-300` (default is fine)
- **External target**: `-rl 10-25` (respect third-party resources)

**Anti-pattern**: Running Nuclei with unlimited rate against a shared staging server. This triggers alerts, slows down QA, and may get your CI IP blocked.

### D5: Template Freshness

Always update templates before scanning — new CVEs are added daily:

```bash
# Update before scan
nuclei -update-templates

# Then scan
nuclei -u https://staging.example.com -severity critical,high
```

In CI, update templates as a separate step:
```yaml
- name: Update Nuclei templates
  run: nuclei -update-templates

- name: DAST scan
  run: nuclei -u $STAGING_URL -severity critical,high -json -o dast.json
```

Template sources:
- Default: `nuclei-templates` community repository (8000+ templates)
- Custom: `-t /path/to/custom/templates/`
- Specific: `-t cves/2024/CVE-2024-XXXX.yaml`

**Anti-pattern**: Caching Nuclei templates in CI without periodic refresh. Templates more than 1 week old miss recently disclosed CVEs.

### D6: Auto-Scan Mode for Technology Detection

Use `-as` (auto-scan) to let Nuclei detect target technology and select relevant templates:

```bash
# Auto-detect technology stack and scan with matching templates
nuclei -u https://staging.example.com -as

# Combine with severity filter
nuclei -u https://staging.example.com -as -severity critical,high
```

Auto-scan detects:
- Web framework (Django, Express, Spring, etc.)
- Server software (Nginx, Apache, Tomcat)
- CMS (WordPress, Drupal, Joomla)
- Cloud providers (AWS, GCP, Azure metadata)

When to use:
- **First scan of unknown target**: always use `-as`
- **Known target**: use specific tags (`-tags cve,misconfig`) for speed
- **Broad audit**: combine `-as` with `-tags` for coverage

### D7: SAST+DAST Cross-Reference

Cross-reference DAST findings with SAST results for confidence scoring:

| Scenario | Confidence | Action |
|----------|------------|--------|
| SAST + DAST both find it | HIGH (dual-verified) | P0 — fix immediately |
| Only DAST found it | MEDIUM (runtime-only) | P1 — likely real, runtime issue |
| Only SAST found it | MEDIUM (needs DAST path) | P1 — DAST may not have hit the code path |
| DAST verified exploit | CRITICAL | P0 — proven exploitable |

Dedup key for cross-reference: CWE + endpoint/file + vulnerability type.

Mark dual-verified findings explicitly in triage output:
```
[P0] SQL Injection — /api/users?id= (CWE-89)
  Verified by: Semgrep (sast-results.sarif:line 42) + Nuclei (CVE template match)
  Confidence: DUAL-VERIFIED
```

**Anti-pattern**: Running SAST and DAST independently without correlating results. Dual-verified findings are high-confidence — prioritize them over single-source findings.

---

## Nuclei CLI Quick Reference

```bash
# Basic scan
nuclei -u https://target.com

# Multiple targets
nuclei -l urls.txt

# Severity filter
nuclei -u target -severity critical,high

# Tag filter
nuclei -u target -tags cve,misconfig,tech

# Custom template
nuclei -u target -t /path/to/template.yaml

# Auto-scan (detect tech stack)
nuclei -u target -as

# Rate limit
nuclei -u target -rl 50

# JSON output
nuclei -u target -json -o results.json

# Silent mode (findings only, no banner)
nuclei -u target -silent

# Combine all
nuclei -u https://staging.example.com \
  -severity critical,high \
  -tags cve \
  -rl 100 \
  -json -o dast-results.json
```
