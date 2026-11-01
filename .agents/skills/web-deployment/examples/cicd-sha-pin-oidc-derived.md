---
name: cicd-sha-pin-oidc-derived
description: "Derived fixture (Phase 3 §4.4 step 3): tests the artifact-attestation rules the main fixture's CONTROL missed — SLSA provenance generation in CI + fail-closed gh attestation verify at deploy"
pack: web-deployment
tests_rules:
  - "ci-cd-pipeline-rules.md CI12: Artifact Attestations + SLSA provenance — sign + verify the build output"
  - "security-hardening-rules.md SH8: verify artifact attestations before deploy — fail closed on unsigned artifacts"
min_marker_count: 2
# DISCRIMINATIVE gate: ONLY markers tied to the substantive-analysis error point (main-fixture
# CONTROL covered SHA-pinning/OIDC/zizmor/rollback but contained zero occurrences of
# attestation/SLSA/Sigstore/Rekor; its only adjacent advice was a generic 'sign or checksum
# it'). Pre-check on the main fixture's CONTROL output: distinct hits = 0 (below min 2) —
# recorded in p3-eval-web-deployment.md ## Analysis.
discriminative_pattern: "attestation|SLSA|Sigstore|Rekor"
min_discriminative: 2
---

# Fixture (derived): Artifact Provenance — Attestation Verify at Deploy

## Input Scenario

"Our CI builds a release tarball and uploads it as a workflow artifact. The deploy job downloads the tarball and installs it on the production server. Review this artifact flow: how do we know the file that lands on the server is exactly what CI built, and wasn't swapped or tampered with in between?"

## Expected Markers

When an AI agent processes the Input Scenario with the web-deployment pack loaded,
the output MUST contain these markers:

1. **Artifact attestations + SLSA provenance**: generate a build-provenance attestation in CI (Sigstore-signed, Rekor transparency log) binding the artifact digest to the pipeline
   grep pattern: `attestation|SLSA|Sigstore|Rekor`
2. **Fail-closed verification at deploy**: the deploy step verifies the attestation (gh attestation verify) and refuses to deploy an artifact with no valid attestation for the expected repo

## Verification Command

```bash
grep -oE 'attestation|SLSA|Sigstore|Rekor' cicd-sha-pin-oidc-derived-output.md | sort -u | wc -l | tr -d ' '
# Expected: ≥ 2
```

## Anti-Slop Check

These markers are pack-specific (would NOT appear without the pack):
- ✅ "GitHub Artifact Attestations / SLSA build provenance (Sigstore + Rekor)" (CI12)
- ✅ "gh attestation verify … fail closed on unsigned artifacts" (SH8)
- ❌ "sign or checksum it and verify" (the main-fixture CONTROL's generic substitute — a checksum stored with the artifact proves no provenance)
- ❌ "use HTTPS / trusted network" (transport safety, not artifact provenance)
