#!/usr/bin/env bash
# api-lint.sh — Lint an OpenAPI specification against Spectral + naming rules
#
# Usage: bash scripts/api-lint.sh <path-to-openapi-spec>
#
# Checks:
#   - Spectral OWASP API Security ruleset
#   - Zalando RESTful API naming conventions (resource names, versioning)
#   - No auth material in URL path or query parameters
#
# Requirements: @stoplight/spectral-cli (npm), jq

set -euo pipefail

SPEC_PATH="${1:-}"

# ── Dependency preflight ─────────────────────────────────────────────────────
MISSING=0
if ! command -v npx >/dev/null 2>&1; then
  echo "✗ npx not found. Install Node.js: https://nodejs.org" >&2
  MISSING=1
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "✗ jq not found. Install: brew install jq / apt-get install jq" >&2
  MISSING=1
fi
[ $MISSING -eq 1 ] && exit 1

if [ -z "$SPEC_PATH" ]; then
  echo "Usage: bash scripts/api-lint.sh <path-to-openapi-spec>" >&2
  echo "  Example: bash scripts/api-lint.sh openapi.yaml" >&2
  exit 1
fi

if [ ! -f "$SPEC_PATH" ]; then
  echo "✗ Spec file not found: $SPEC_PATH" >&2
  exit 1
fi

echo "=== API Lint: $SPEC_PATH ==="
echo ""

ERRORS=0

# ── Spectral OWASP ruleset ───────────────────────────────────────────────────
echo "[ 1/3 ] Spectral OWASP API Security ruleset..."

if npx --yes -p @stoplight/spectral-cli -p @stoplight/spectral-owasp-rules \
     spectral lint \
     --ruleset @stoplight/spectral-owasp-rules \
     --format text \
     "$SPEC_PATH" 2>&1; then
  echo "  ✓ Spectral OWASP: PASS"
else
  echo "  ✗ Spectral OWASP: FAIL — fix findings above before shipping"
  ERRORS=$((ERRORS + 1))
fi
echo ""

# ── Naming convention checks ─────────────────────────────────────────────────
echo "[ 2/3 ] Naming conventions..."

# Check for camelCase in paths (should be kebab-case for multi-word resources)
CAMEL_PATHS=$(grep -oE '/[a-z]+[A-Z][a-zA-Z]+' "$SPEC_PATH" 2>/dev/null || true)
if [ -n "$CAMEL_PATHS" ]; then
  echo "  ✗ camelCase in URL paths — use kebab-case for multi-word resources:"
  echo "$CAMEL_PATHS" | sed 's/^/     /'
  ERRORS=$((ERRORS + 1))
else
  echo "  ✓ URL path casing: OK (no camelCase paths)"
fi

# Check versioning prefix exists
if grep -qE '^[[:space:]]*/(v[0-9]|api/v[0-9])' "$SPEC_PATH" 2>/dev/null; then
  echo "  ✓ API versioning prefix found"
else
  echo "  ⚠ No /v1 versioning prefix found in paths — add per Rule 6 in references/architecture.md"
fi
echo ""

# ── Auth material in URLs ────────────────────────────────────────────────────
echo "[ 3/3 ] Auth material in URLs..."

# Check for token/key/secret in query parameters
AUTH_IN_QUERY=$(grep -oE 'name:[[:space:]]*(api_key|apikey|token|access_token|secret|password)' "$SPEC_PATH" 2>/dev/null | head -5 || true)
if [ -n "$AUTH_IN_QUERY" ]; then
  echo "  ✗ Authentication material in query parameters — use Authorization header:"
  echo "$AUTH_IN_QUERY" | sed 's/^/     /'
  ERRORS=$((ERRORS + 1))
else
  echo "  ✓ No auth material in query parameters"
fi

# Summary
echo ""
echo "=== Summary ==="
if [ $ERRORS -eq 0 ]; then
  echo "✓ PASS — no blocking issues found"
  exit 0
else
  echo "✗ FAIL — $ERRORS issue(s) require attention"
  exit 1
fi
