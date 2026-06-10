---
name: cicd-sha-pin-oidc
description: "Tests SHA-pinning of GitHub Actions + OIDC over stored secrets + immutable deploy + rollback strategy + scoped environment secrets"
pack: web-deployment
tests_rules:
  - "ci-cd-pipeline-rules.md: SHA-pin actions, not @latest/@v4 tags"
  - "Cross-Cutting: Immutable Deploys + OIDC Auth"
  - "environment-config-rules.md: scoped environment secrets"
  - "rollback-rules.md: blue-green / canary / atomic / Docker SHA"
min_marker_count: 3
# DISCRIMINATIVE gate: ONLY pack-specific markers. Excludes generic "set up CI/CD"/"use env
# vars"/"rollback" (bare). SHA-pinning actions, OIDC over stored secrets, immutable-deploy/
# Docker-image-SHA, and named blue-green/canary/atomic strategies are pack hardening rules.
discriminative_pattern: "SHA.?pin|OIDC|[Ii]mmutable [Dd]eploy|blue.?green|canary|atomic deploy|Docker image SHA"
min_discriminative: 3
---

# Fixture: CI/CD Supply-Chain + Auth Review

## Input Scenario

"Our GitHub Actions deploy workflow uses `actions/checkout@v4`, authenticates to AWS with a long-lived access key stored as a repo secret, SSHes in and updates the running server in place. No rollback plan. Review it."

## Expected Markers

When an AI agent processes the Input Scenario with the web-deployment pack loaded,
the output MUST contain these markers:

1. **SHA-pin GitHub Actions** [structural]: the agent flags `@v4`/`@latest` as a supply-chain risk and pins to a commit SHA, not just "update the action"
   grep pattern: `SHA.?pin|pin (to )?(a )?(commit )?SHA|@v4|@latest|supply.?chain|checkout@[0-9a-f]{7}`
2. **OIDC over stored secrets**: replace the long-lived AWS key with OIDC identity tokens
   grep pattern: `OIDC|identity token|stored (long.?lived )?(secret|credential)|short.?lived (token|credential)`
3. **Immutable deploy (no in-place updates)**: the in-place server update is flagged; prescribe immutable artifact
   grep pattern: `immutable (deploy|artifact|image|snapshot)|in.?place (update|deploy)|Docker (image )?SHA|mutable deploy`
4. **Rollback strategy**: the pack's named rollback patterns
   grep pattern: `rollback|blue.?green|canary|atomic deploy|previous.?SHA|vercel rollback`

## Verification Command

```bash
grep -oE 'SHA.?pin|pin to a commit SHA|@v4|@latest|supply.?chain|OIDC|identity token|stored long.?lived secret|short.?lived token|immutable deploy|immutable artifact|in.?place update|Docker image SHA|rollback|blue.?green|canary|atomic deploy|previous.?SHA' cicd-sha-pin-oidc-output.md | sort -u | wc -l | tr -d ' '
# Expected: ≥ 3
```

## Anti-Slop Check

These markers are pack-specific (would NOT appear without the pack):
- ✅ "SHA-pin actions/checkout (not @v4 tag) — supply-chain" (the pack's specific CI/CD hardening rule)
- ✅ "OIDC identity tokens over stored long-lived secrets" (the pack's cross-cutting auth rule)
- ✅ "immutable deploy / Docker image SHA vs in-place update" (the pack's rollback-safety rule)
- ✅ "blue-green / canary / atomic rollback" (the pack's named rollback strategies)
- ❌ "set up CI/CD" (generic — restates the input)
- ❌ "use environment variables" (generic without the OIDC/scoped-secret specifics)
- ❌ "make it more secure" (non-discriminative)
