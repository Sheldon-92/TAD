---
name: cicd-sha-pin-oidc
description: "Tests SHA-pinning of GitHub Actions + OIDC over stored secrets + immutable deploy + rollback strategy + scoped environment secrets"
pack: web-deployment
tests_rules:
  - "ci-cd-pipeline-rules.md CI2/CI9: SHA-pin actions, not @latest/@v4 tags (CVE-2025-30066 tj-actions)"
  - "ci-cd-pipeline-rules.md CI11: actions/upload-artifact@v3 dead since 2025-01-30, migrate to @v4"
  - "ci-cd-pipeline-rules.md CI10: run zizmor (unpinned-uses/impostor-commit/template-injection)"
  - "ci-cd-pipeline-rules.md CI12 / SH8: artifact attestation + SLSA provenance, gh attestation verify"
  - "Cross-Cutting: Immutable Deploys + OIDC Auth"
  - "environment-config-rules.md: scoped environment secrets"
  - "rollback-rules.md: blue-green / canary / atomic / Docker SHA"
min_marker_count: 4
# DISCRIMINATIVE gate: ONLY pack-specific markers. Excludes generic "set up CI/CD"/"use env
# vars"/"rollback" (bare). The discriminative tokens are research-grounded specifics an LLM
# cannot restate without the pack: SHA-pinning, OIDC over stored secrets, immutable-deploy/
# Docker-image-SHA, named blue-green/canary/atomic strategies, the dated tj-actions CVE
# (CVE-2025-30066), the dead @v3 artifact cutoff, zizmor, and SLSA/attestation verification.
discriminative_pattern: "SHA.?pin|OIDC|[Ii]mmutable [Dd]eploy|blue.?green|canary|atomic deploy|Docker image SHA|CVE.?2025.?30066|tj-actions|zizmor|@v3|attestation|SLSA|gh attestation verify"
min_discriminative: 4
---

# Fixture: CI/CD Supply-Chain + Auth Review

## Input Scenario

"Our GitHub Actions deploy workflow uses `actions/checkout@v4` and `tj-actions/changed-files@v45`, uploads its build with `actions/upload-artifact@v3`, authenticates to AWS with a long-lived access key stored as a repo secret, then SSHes in and updates the running server in place. No rollback plan, and we only run `actionlint`. Review it."

## Expected Markers

When an AI agent processes the Input Scenario with the web-deployment pack loaded,
the output MUST contain these markers:

1. **SHA-pin GitHub Actions + cite the dated incident** [structural]: the agent flags `@v4`/`@v45`/`@latest` as a supply-chain risk and pins to a commit SHA, naming CVE-2025-30066 / the tj-actions tag-mutation compromise — not just "update the action"
   grep pattern: `SHA.?pin|pin (to )?(a )?(commit )?SHA|@v4|@latest|supply.?chain|CVE.?2025.?30066|tj-actions|checkout@[0-9a-f]{7}`
2. **OIDC over stored secrets**: replace the long-lived AWS key with OIDC identity tokens
   grep pattern: `OIDC|identity token|stored (long.?lived )?(secret|credential)|short.?lived (token|credential)`
3. **Immutable deploy (no in-place updates)**: the in-place server update is flagged; prescribe immutable artifact
   grep pattern: `immutable (deploy|artifact|image|snapshot)|in.?place (update|deploy)|Docker (image )?SHA|mutable deploy`
4. **Rollback strategy**: the pack's named rollback patterns
   grep pattern: `rollback|blue.?green|canary|atomic deploy|previous.?SHA|vercel rollback`
5. **Dead artifact action**: `upload-artifact@v3` no longer works (2025-01-30 cutoff); migrate to `@v4`
   grep pattern: `@v3|upload-artifact|2025.?01.?30|@v4`
6. **Run zizmor (not just actionlint)**: add the supply-chain auditor with its named audits
   grep pattern: `zizmor|unpinned-uses|impostor-commit|template-injection|excessive-permissions`
7. **Attestation / SLSA provenance**: sign the build and verify before deploy
   grep pattern: `attestation|SLSA|provenance|gh attestation verify|attest-build-provenance`

## Verification Command

```bash
grep -oE 'SHA.?pin|pin to a commit SHA|@v4|@latest|supply.?chain|CVE.?2025.?30066|tj-actions|OIDC|identity token|stored long.?lived secret|short.?lived token|immutable deploy|immutable artifact|in.?place update|Docker image SHA|rollback|blue.?green|canary|atomic deploy|previous.?SHA|@v3|zizmor|unpinned-uses|impostor-commit|template-injection|attestation|SLSA|gh attestation verify' cicd-sha-pin-oidc-output.md | sort -u | wc -l | tr -d ' '
# Expected: ≥ 4
```

## Anti-Slop Check

These markers are pack-specific (would NOT appear without the pack):
- ✅ "SHA-pin actions/checkout (not @v4 tag) — CVE-2025-30066 mutated tj-actions v1–v45" (dated supply-chain incident, not restatable without research)
- ✅ "OIDC identity tokens over stored long-lived secrets" (the pack's cross-cutting auth rule)
- ✅ "immutable deploy / Docker image SHA vs in-place update" (the pack's rollback-safety rule)
- ✅ "blue-green / canary / atomic rollback" (the pack's named rollback strategies)
- ✅ "upload-artifact@v3 dead since 2025-01-30 — migrate to @v4" (dated hard cutoff)
- ✅ "run zizmor (unpinned-uses / impostor-commit / template-injection), not just actionlint" (named auditor + audit IDs)
- ✅ "attest-build-provenance + gh attestation verify (SLSA/Sigstore)" (provenance gate)
- ❌ "set up CI/CD" (generic — restates the input)
- ❌ "use environment variables" (generic without the OIDC/scoped-secret specifics)
- ❌ "make it more secure" (non-discriminative)
- ❌ "scan for vulnerabilities" (generic without the named zizmor audits / CVE)
