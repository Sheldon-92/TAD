---
name: api-pagination-review
description: "Tests offset-vs-cursor pagination rule + GET side-effect rule + secrets-in-env + graceful shutdown + P0/P1/P2 severity on a backend API review"
pack: web-backend
tests_rules:
  - "api-design.md Rule 1: pagination (offset vs keyset/cursor on large tables)"
  - "api-design.md Rule 3: GET must not modify state"
  - "security.md Rule 4: secrets in env, not hardcoded"
  - "infrastructure.md Rule 7: graceful shutdown / preStop"
  - "P0/P1/P2 severity classification"
min_marker_count: 3
---

# Fixture: Backend API Pagination + Side-Effect Review

## Input Scenario

"Review this endpoint: `GET /users/search?page=5000` runs an offset query on a 50M-row table and also writes an audit-log row on each call. We hardcode the DB password in the handler. Deployed on Kubernetes."

## Expected Markers

When an AI agent processes the Input Scenario with the web-backend pack loaded,
the output MUST contain these markers:

1. **Offset→cursor/keyset pagination on large tables** [structural]: the agent flags deep offset pagination on a 50M-row table and prescribes keyset/cursor pagination, not "add an index"
   grep pattern: `offset pagination|keyset|cursor.?(based )?pagination|seek method|deep offset|50M`
2. **GET must not modify state**: the audit-log write on a GET is flagged as a side-effect violation
   grep pattern: `GET .*(modif|side.?effect|write|mutat)|side.?effect on GET|idempotent|safe method`
3. **Secrets in env, not hardcoded**: the hardcoded DB password is a P0 security finding
   grep pattern: `hardcoded (secret|password|credential)|secrets? in env|env var|secret manager`
4. **Graceful shutdown / K8s preStop**: the pack's infrastructure rule
   grep pattern: `graceful shutdown|preStop|SIGTERM|drain (connections|requests)`
5. **P0/P1/P2 severity + rule references**: the pack's structured findings format
   grep pattern: `\[P0\]|\[P1\]|\[P2\]|Rule [0-9].*(api.?design|security|infrastructure)`

## Verification Command

```bash
grep -oE 'offset pagination|keyset|cursor.?based pagination|seek method|deep offset|GET .*(modif|side.?effect|write)|idempotent|hardcoded password|hardcoded credential|secrets in env|secret manager|graceful shutdown|preStop|SIGTERM|\[P0\]|\[P1\]|\[P2\]' api-pagination-review-output.md | sort -u | wc -l | tr -d ' '
# Expected: ≥ 3
```

## Anti-Slop Check

These markers are pack-specific (would NOT appear without the pack):
- ✅ "offset → keyset/cursor pagination on 50M rows" (the pack's specific pagination rule — no-pack agent says "add an index")
- ✅ "GET must not modify state (audit-write is a side-effect violation)" (the pack's HTTP-semantics rule)
- ✅ "graceful shutdown / preStop / SIGTERM drain" (the pack's K8s infrastructure rule)
- ✅ "P0/P1/P2 + Rule N references" (the pack's structured severity output)
- ❌ "optimize the query" (generic — misses the offset-vs-keyset distinction)
- ❌ "don't hardcode passwords" is borderline-generic, but paired with "secret manager / env" it is pack-aligned
- ❌ "review the code" (non-discriminative)
