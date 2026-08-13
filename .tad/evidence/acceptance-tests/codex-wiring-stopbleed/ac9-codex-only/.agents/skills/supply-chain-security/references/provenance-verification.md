# Provenance Verification

> Verify package origin authenticity — publisher identity, build provenance, SLSA level, trust score.
> Output artifacts: `provenance-report.md`, `scorecard.json`.

## Step 1: Check Signatures

For container images, verify cosign signatures and attestations:

    cosign verify myregistry.io/myimage:latest \
      --certificate-identity=expected@publisher.com \
      --certificate-oidc-issuer=https://accounts.google.com

For npm packages, verify provenance:

    npm audit signatures

For GitHub Actions:

Verify actions are pinned to full commit SHA (not mutable tags). Check:

    grep -r "uses:" .github/workflows/ | grep -v "@[a-f0-9]\{40\}"

Any match = unpinned action = supply chain risk.
Reference: trivy-action March 2026 compromise (75/76 tags hijacked).

**Quality bar**: All container images verified. All GH Actions pinned to SHA.

## Step 2: Verify Build Provenance (SLSA)

Check SLSA provenance attestations for critical dependencies:

    cosign verify-attestation --type slsaprovenance <artifact>

Assess SLSA level:

- Level 1: Provenance exists (build metadata documented)
- Level 2: Signed provenance (cryptographic signature)
- Level 3: Hardened builds (isolated, reproducible build environment)

For each critical dependency, record:

- Does provenance exist? (many PyPI packages: no)
- Is it signed? (sigstore adoption still growing)
- What build system produced it? (GitHub Actions, Jenkins, etc.)

**Quality bar**: SLSA level documented for each critical dependency.

## Step 3: Validate Publisher

Cross-reference package publisher identity with expected maintainer:

- npm: Check package page → publisher field vs known maintainer
- PyPI: Check Trusted Publishers (GitHub OIDC-based publishing)
- Docker: Check image publisher in registry metadata

For npm:

    npm view <package> maintainers

Flag if:

- Publisher changed between versions
- Package has single maintainer (bus factor = 1)
- Publisher email domain changed
- Package ownership transferred recently

**Quality bar**: Publisher identity verified for top-10 most critical deps.

## Step 4: Score Trust (OSSF Scorecard)

Run OSSF Scorecard on dependency repos to quantify trust:

    scorecard --repo=github.com/owner/repo --format json > scorecard.json

Key checks to examine:

- Branch-Protection (are PRs reviewed?)
- Code-Review (are changes reviewed by different person?)
- Vulnerabilities (known unpatched vulns?)
- Maintained (recent commits?)
- Signed-Releases (are releases cryptographically signed?)
- Token-Permissions (are CI tokens minimal scope?)

Flag repos with:

- Overall score < 5 (out of 10)
- Branch-Protection = 0
- Code-Review = 0
- Any check = 0 for critical dependencies

Combine: signature status + SLSA level + Scorecard score = provenance grade.

**Quality bar**: Scorecard results for top-10 critical deps. Cached and refreshed weekly.

## Quality Criteria (pass/fail)

- All container images have verified signatures before deployment
- SLSA level documented for each critical dependency
- Publisher identity verified for top-10 most critical dependencies
- Scorecard results cached and refreshed weekly
- GitHub Actions pinned to full commit SHA
