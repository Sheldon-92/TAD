# Dependency Audit

> Scan project dependencies against known vulnerability databases across all ecosystems.
> Output artifacts: `sbom.cdx.json`, `osv-results.json`, `audit-report.md` (under `.tad/active/research/{project}/`).

## Step 1: Generate SBOM (foundation artifact)

Generate a Software Bill of Materials (SBOM) FIRST. The SBOM is consumed by other
capabilities (typosquat detection, downstream monitoring pack).

For source code:

    syft dir:/path/to/project -o cyclonedx-json > sbom.cdx.json

For container images:

    syft <image>:<tag> -o cyclonedx-json > sbom.cdx.json

For specific ecosystem:

    syft dir:. -o spdx-json > sbom.spdx.json

Verify the SBOM includes both direct AND transitive dependencies.
CycloneDX format preferred (spec >= 1.5).

**Quality bar**: SBOM includes all lockfile dependencies. Direct vs transitive marked.

## Step 2: Detect Ecosystem(s)

Scan project root for package manager files to determine ecosystem(s):

- `package.json` / `package-lock.json` / `yarn.lock` → npm ecosystem
- `requirements.txt` / `Pipfile` / `pyproject.toml` / `uv.lock` / `poetry.lock` → pip ecosystem
- `Cargo.toml` / `Cargo.lock` → cargo ecosystem
- `go.mod` / `go.sum` → go ecosystem
- `pom.xml` / `build.gradle` → maven/gradle ecosystem
- `Gemfile` / `Gemfile.lock` → ruby ecosystem
- `composer.json` / `composer.lock` → PHP ecosystem

Multiple ecosystems may coexist (e.g., JS frontend + Python backend).
Record all detected ecosystems for subsequent steps.

**Quality bar**: All package manager files detected. No ecosystem missed.

## Step 3: Run Scanner(s)

Execute ecosystem-appropriate vulnerability scanner(s).

Multi-ecosystem (recommended first pass):

    osv-scanner -r /path/to/project --format json > osv-results.json

Ecosystem-specific (run if osv-scanner insufficient):

    npm:   npm audit --json > npm-audit.json
    pip:   pip-audit -r requirements.txt --format json -o pip-audit.json
    cargo: cargo audit --json > cargo-audit.json
    go:    osv-scanner --lockfile=go.sum

OWASP deep scan (dependency confusion, risk audit):

    depscan --src $PWD --deep --reports-dir $PWD/reports

Run ALL applicable scanners — cross-reference finds blind spots.

**Quality bar**: All detected ecosystems scanned. Zero lockfiles skipped.

## Step 4: Analyze Severity

Parse scan results and classify findings:

1. Filter by severity: CRITICAL > HIGH > MEDIUM > LOW
2. For each CRITICAL/HIGH finding:
   - Check if a fix version exists
   - Assess upgrade risk (breaking changes between current and fix version)
   - Check EPSS score if available (exploit probability)
   - Check KEV catalog (known exploited vulnerabilities — highest priority)
3. Separate direct vs transitive dependency findings
4. Flag unmaintained dependencies (no release in 12+ months)

**Quality bar**: Every CRITICAL/HIGH has remediation path or documented accept-risk.

## Step 5: Generate Report

Produce structured audit report (`audit-report.md`):

    ## Dependency Audit Report
    - **Date**: {timestamp}
    - **Project**: {name}
    - **Ecosystems**: {detected list}
    - **SBOM**: sbom.cdx.json ({N} components)

    ### Summary
    | Severity | Count | Fixable | Accept-Risk |
    |----------|-------|---------|-------------|

    ### CRITICAL Findings
    | Package | Version | CVE | CVSS | EPSS | Fix Version | KEV | Action |

    ### HIGH Findings
    (same table)

    ### Remediation Plan
    | Priority | Package | Current | Target | Breaking Changes | Effort |

    ### Transitive Dependencies
    | Vulnerable Dep | Via (direct dep) | Depth | Fix Strategy |

**Quality bar**: Report is actionable — every finding has a clear next step.

## Quality Criteria (pass/fail)

- All direct dependencies scanned (zero skip)
- CRITICAL vulnerabilities have explicit remediation path or documented accept-risk
- Report includes transitive dependency depth for each finding
- SBOM generated as foundation artifact (CycloneDX >= 1.5)
- JSON output available for CI pipeline consumption
- Cross-reference at least 2 scanners for CRITICAL findings
