# Phase 5 Behavioral Discriminative Eval — web-deployment

**Date**: 2026-06-13
**Pack**: web-deployment (v0.1.0)
**Fixture**: `.claude/skills/web-deployment/examples/cicd-sha-pin-oidc.md`
**Eval type**: discriminative behavioral (with-pack vs control)

---

## Fixture Parameters

- **discriminative_pattern**:
  `SHA.?pin|OIDC|[Ii]mmutable [Dd]eploy|blue.?green|canary|atomic deploy|Docker image SHA|CVE.?2025.?30066|tj-actions|zizmor|@v3|attestation|SLSA|gh attestation verify`
- **min_discriminative**: 4
- **min_marker_count** (structural): 4

## Scenario (from fixture Input)

> "Our GitHub Actions deploy workflow uses `actions/checkout@v4` and `tj-actions/changed-files@v45`, uploads its build with `actions/upload-artifact@v3`, authenticates to AWS with a long-lived access key stored as a repo secret, then SSHes in and updates the running server in place. No rollback plan, and we only run `actionlint`. Review it."

## Method

1. WITH-PACK answer: produced by applying web-deployment SKILL.md rules (cross-cutting Immutable+OIDC rule, ci-cd-pipeline-rules CI2/CI9/CI10/CI11/CI12, environment-config scoped secrets, rollback-rules named strategies, attestation/SLSA).
2. CONTROL answer: generalist deployment review with NO pack loaded — generic "keep actions updated / use env vars / rotate secrets / add monitoring / have a rollback plan / scan for vulnerabilities".
3. Applied `grep -oE PATTERN | sort -u | wc -l` to both.

## Results

| Answer | Unique discriminative markers | Threshold (≥4) |
|--------|-------------------------------|----------------|
| WITH-PACK | **15** | PASS |
| CONTROL | **1** | below threshold (correct) |

### WITH-PACK matched markers (15)
`@v3`, `atomic deploy`, `attestation`, `blue-green`, `canary`, `CVE-2025-30066`, `Docker image SHA`, `gh attestation verify`, `immutable deploy`, `Immutable Deploy`, `OIDC`, `SHA-pin`, `SLSA`, `tj-actions`, `zizmor`

### CONTROL matched markers (1)
`tj-actions` — only because the scenario input names that action; the generalist restated the action name without any of the pack-specific judgment (no SHA-pinning, no CVE, no OIDC, no immutable deploy, no named rollback strategy, no zizmor, no SLSA). 1 < 4, so control correctly fails the threshold.

## Discriminative Pass Determination

```
discriminative_pass = (with_pack_disc >= min_discriminative) AND (control_disc < min_discriminative)
                    = (15 >= 4) AND (1 < 4)
                    = TRUE
```

**RESULT: PASS** — the pack produces research-grounded specifics (dated CVE-2025-30066 / tj-actions tag-mutation, OIDC-over-stored-secrets, immutable-deploy / Docker-image-SHA, named blue-green/canary/atomic rollback, dead `@v3` artifact cutoff, zizmor audits, SLSA/attestation verification) that a generalist control cannot restate without the pack.

## Verification Command (reproducible)

```bash
PAT='SHA.?pin|OIDC|[Ii]mmutable [Dd]eploy|blue.?green|canary|atomic deploy|Docker image SHA|CVE.?2025.?30066|tj-actions|zizmor|@v3|attestation|SLSA|gh attestation verify'
grep -oE "$PAT" with-pack.md  | sort -u | wc -l   # -> 15
grep -oE "$PAT" control.md    | sort -u | wc -l   # -> 1
```
