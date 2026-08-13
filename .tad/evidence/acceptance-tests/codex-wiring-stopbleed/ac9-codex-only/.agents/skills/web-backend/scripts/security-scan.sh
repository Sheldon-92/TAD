#!/usr/bin/env bash
# security-scan.sh — Security scan for a backend project
#
# Usage: bash scripts/security-scan.sh <project-root>
#
# Checks:
#   1. Secrets detection (common API key patterns in source files)
#   2. Dependency vulnerability audit (npm / pip-audit / govulncheck)
#   3. OFFAT API security scan (if OpenAPI spec found)
#
# Requirements: git (for secret patterns), plus language-specific tools

set -euo pipefail

PROJECT_ROOT="${1:-.}"

if [ ! -d "$PROJECT_ROOT" ]; then
  echo "✗ Directory not found: $PROJECT_ROOT" >&2
  exit 1
fi

echo "=== Security Scan: $PROJECT_ROOT ==="
echo ""

ERRORS=0
WARNINGS=0

# ── Dependency preflight ─────────────────────────────────────────────────────
echo "[ Checking available scanners... ]"
HAS_NPM=false
HAS_PIP_AUDIT=false
HAS_GOVULNCHECK=false
HAS_OFFAT=false

command -v npm >/dev/null 2>&1 && HAS_NPM=true
command -v pip-audit >/dev/null 2>&1 && HAS_PIP_AUDIT=true
command -v govulncheck >/dev/null 2>&1 && HAS_GOVULNCHECK=true
command -v offat >/dev/null 2>&1 && HAS_OFFAT=true

echo "  npm audit: $([ $HAS_NPM = true ] && echo available || echo 'not found — install Node.js')"
echo "  pip-audit: $([ $HAS_PIP_AUDIT = true ] && echo available || echo 'not found — pip install pip-audit')"
echo "  govulncheck: $([ $HAS_GOVULNCHECK = true ] && echo available || echo 'not found — go install golang.org/x/vuln/cmd/govulncheck@latest')"
echo "  offat: $([ $HAS_OFFAT = true ] && echo available || echo 'not found — pip install offat (optional)')"
echo ""

# ── 1. Secrets detection ─────────────────────────────────────────────────────
echo "[ 1/3 ] Secrets detection..."

# Common secret patterns — not exhaustive, but catches the most common leaks
SECRET_PATTERNS=(
  'AKIA[0-9A-Z]{16}'                                  # AWS Access Key
  'sk-[a-zA-Z0-9]{20,}'                               # OpenAI / Stripe / generic sk- key
  'gh[pousr]_[A-Za-z0-9]{36,}'                        # GitHub tokens
  'xox[baprs]-[0-9A-Za-z\-]+'                         # Slack tokens
  '-----BEGIN (RSA|EC|OPENSSH) PRIVATE KEY-----'       # Private keys
  'password\s*=\s*['\''"][^'\''"\s]{8,}'              # Hardcoded password assignments
  'api.?key\s*[=:]\s*['\''"][^'\''"\s]{10,}'          # Generic API key assignments
)

EXCLUDE_DIRS="--exclude-dir=.git --exclude-dir=node_modules --exclude-dir=vendor \
  --exclude-dir=.tox --exclude-dir=.venv --exclude-dir=dist --exclude-dir=build"
EXCLUDE_FILES="--exclude=*.min.js --exclude=package-lock.json --exclude=*.lock \
  --exclude=*.sum --exclude=*.env.example"

SECRET_HITS=0
for pattern in "${SECRET_PATTERNS[@]}"; do
  # Use -l to list files only, avoiding overwhelming output
  matches=$(grep -rlE "$pattern" $EXCLUDE_DIRS $EXCLUDE_FILES "$PROJECT_ROOT" 2>/dev/null || true)
  if [ -n "$matches" ]; then
    echo "  ✗ Potential secret pattern '$pattern' found in:"
    echo "$matches" | head -5 | sed 's/^/     /'
    SECRET_HITS=$((SECRET_HITS + 1))
    ERRORS=$((ERRORS + 1))
  fi
done

# Check .env committed to git
if [ -d "$PROJECT_ROOT/.git" ]; then
  if git -C "$PROJECT_ROOT" ls-files --error-unmatch ".env" >/dev/null 2>&1; then
    echo "  ✗ .env file is tracked by git — remove with: git rm --cached .env"
    ERRORS=$((ERRORS + 1))
  fi
fi

if [ $SECRET_HITS -eq 0 ] && [ $ERRORS -eq 0 ]; then
  echo "  ✓ No secrets detected in source files"
fi
echo ""

# ── 2. Dependency vulnerability audit ───────────────────────────────────────
echo "[ 2/3 ] Dependency vulnerability audit..."

DEP_ERRORS=0

# Node.js
if [ $HAS_NPM = true ] && [ -f "$PROJECT_ROOT/package.json" ]; then
  echo "  Running npm audit (production deps only)..."
  if npm --prefix "$PROJECT_ROOT" audit --audit-level=high --omit=dev 2>&1; then
    echo "  ✓ npm audit: PASS"
  else
    echo "  ✗ npm audit: high/critical vulnerabilities found"
    DEP_ERRORS=$((DEP_ERRORS + 1))
  fi
fi

# Python
if [ $HAS_PIP_AUDIT = true ] && ([ -f "$PROJECT_ROOT/requirements.txt" ] || [ -f "$PROJECT_ROOT/pyproject.toml" ]); then
  echo "  Running pip-audit..."
  if pip-audit --project-dir "$PROJECT_ROOT" 2>&1; then
    echo "  ✓ pip-audit: PASS"
  else
    echo "  ✗ pip-audit: vulnerabilities found"
    DEP_ERRORS=$((DEP_ERRORS + 1))
  fi
fi

# Go
if [ $HAS_GOVULNCHECK = true ] && [ -f "$PROJECT_ROOT/go.mod" ]; then
  echo "  Running govulncheck..."
  if govulncheck "$PROJECT_ROOT/..." 2>&1; then
    echo "  ✓ govulncheck: PASS"
  else
    echo "  ✗ govulncheck: vulnerabilities found"
    DEP_ERRORS=$((DEP_ERRORS + 1))
  fi
fi

if [ $DEP_ERRORS -gt 0 ]; then
  ERRORS=$((ERRORS + DEP_ERRORS))
elif ! $HAS_NPM && ! $HAS_PIP_AUDIT && ! $HAS_GOVULNCHECK; then
  echo "  ⚠ No dependency scanner available — install npm, pip-audit, or govulncheck"
  WARNINGS=$((WARNINGS + 1))
else
  echo "  ✓ All available dependency scans passed"
fi
echo ""

# ── 3. OFFAT API security scan ───────────────────────────────────────────────
echo "[ 3/3 ] OFFAT API security scan..."

if [ $HAS_OFFAT = false ]; then
  echo "  ⚠ offat not installed — skipping (pip install offat)"
  WARNINGS=$((WARNINGS + 1))
else
  # Find OpenAPI spec
  SPEC_FILE=""
  for candidate in openapi.yaml openapi.json swagger.yaml swagger.json docs/api.yaml docs/openapi.yaml; do
    if [ -f "$PROJECT_ROOT/$candidate" ]; then
      SPEC_FILE="$PROJECT_ROOT/$candidate"
      break
    fi
  done

  if [ -z "$SPEC_FILE" ]; then
    echo "  ⚠ No OpenAPI spec found — skipping OFFAT (place spec at openapi.yaml)"
    WARNINGS=$((WARNINGS + 1))
  else
    echo "  Running OFFAT against $SPEC_FILE..."
    echo "  ⚠ NOTE: OFFAT requires a running server. If server is not running, this will show connection errors."
    if offat -f "$SPEC_FILE" --no-ssl-verification 2>&1 | head -40; then
      echo "  ✓ OFFAT scan complete — review output for findings"
    else
      echo "  ⚠ OFFAT returned non-zero — ensure server is running for full scan"
      WARNINGS=$((WARNINGS + 1))
    fi
  fi
fi

# ── Summary ──────────────────────────────────────────────────────────────────
echo ""
echo "=== Summary ==="
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
  echo "✓ PASS — no security issues found"
  exit 0
elif [ $ERRORS -eq 0 ]; then
  echo "⚠ PASS with warnings — 0 errors, $WARNINGS warning(s)"
  exit 0
else
  echo "✗ FAIL — $ERRORS error(s), $WARNINGS warning(s)"
  exit 1
fi
