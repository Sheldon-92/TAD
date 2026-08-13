# Review Checklist — Supply Chain Security Engineer

> Security review is cross-cutting: the same persona reviews ALL capabilities in a single
> audit pass (unlike per-capability review in some other packs).

## Reviewer Persona

**Supply Chain Security Engineer**

Focus on: dependency trust, behavioral anomalies, publisher provenance,
lockfile integrity, package naming attacks.
Context: assumes pre-install analysis — post-install monitoring is a separate pack.

## Audit Review Checklist

- Are ALL ecosystems in the project covered by scanning?
- Are behavioral analysis results reviewed for new/updated dependencies?
- Are CRITICAL findings blocking the pipeline (not just warning)?
- Is the SBOM complete (direct + transitive dependencies)?
- Are GitHub Actions pinned to full commit SHA?
- Would this audit have detected the litellm 1.82.7 behavioral change?
- Are lockfile hashes validated (not just lockfile existence)?
- Is there an accept-risk process for findings that cannot be fixed immediately?
- Are provenance checks running for container images?
- Is the typosquat allowlist maintained and up-to-date?

## Gate 2 (Design) Checklist

- Audit scope covers all project ecosystems (not just primary language)
- Behavioral analysis included (not CVE-only scanning)
- SBOM generation planned as foundation step
- Severity policy defined with pipeline gating thresholds
- Accept-risk process documented

## Gate 4 (Acceptance) Checklist

- All CRITICAL/HIGH findings have remediation plan or accept-risk documentation
- Behavioral analysis run on last dependency change
- Container images have verified signatures
- Lockfile integrity validated
- Audit report is machine-readable (JSON) for CI consumption

## Expected Output Structure

Expected output directory tree from a supply chain security audit
(under `.tad/active/research/{project}/`):

    {project}/
    ├── sbom.cdx.json                    # CycloneDX SBOM (foundation artifact)
    ├── audit-report.md                  # Dependency audit with severity analysis
    ├── osv-results.json                 # Raw osv-scanner output
    ├── behavioral-report.md             # Behavioral analysis with allow/block decisions
    ├── socket-scan-results.json         # Raw socket CLI scan output
    ├── provenance-report.md             # Signature, SLSA, publisher, trust scores
    ├── scorecard.json                   # OSSF Scorecard results
    ├── lockfile-report.md               # Lockfile integrity validation
    ├── typosquat-report.md              # Typosquat detection results
    └── scan-results/                    # Additional scanner outputs
        ├── pip-audit.json
        ├── cargo-audit.json
        └── npm-audit.json
