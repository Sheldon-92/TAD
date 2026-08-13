#!/usr/bin/env bash
# readiness-score.sh — Score Tier 1 automatable production readiness checks
#
# Usage: bash scripts/readiness-score.sh <project-root>
#
# Scores Tier 1 (~25 automatable checks) from references/production.md.
# Tier 2 (human attestation) and Tier 3 (infra-dependent) are listed but
# not scored — they require human verification.
#
# Output: X/25 PASS, details per check

set -euo pipefail

PROJECT_ROOT="${1:-.}"

# ── Dependency preflight ─────────────────────────────────────────────────────
if ! command -v grep >/dev/null 2>&1 || ! command -v find >/dev/null 2>&1; then
  echo "✗ Core tools (grep, find) not available" >&2
  exit 1
fi

if [ ! -d "$PROJECT_ROOT" ]; then
  echo "✗ Directory not found: $PROJECT_ROOT" >&2
  exit 1
fi

echo "=== Production Readiness Score: $PROJECT_ROOT ==="
echo ""

PASS=0
FAIL=0
WARN=0
TOTAL=25

pass() { echo "  ✓ $1"; PASS=$((PASS + 1)); }
fail() { echo "  ✗ $1"; FAIL=$((FAIL + 1)); }
warn() { echo "  ⚠ $1"; WARN=$((WARN + 1)); }

# ── Tier 1 automated checks ──────────────────────────────────────────────────
echo "─── Tier 1: Automated Checks ───"
echo ""

# PC-01: Secrets not hardcoded
echo "[PC-01] Secrets not hardcoded..."
SRC_DIRS=()
for d in "$PROJECT_ROOT/src" "$PROJECT_ROOT/app" "$PROJECT_ROOT/lib"; do
  [ -d "$d" ] && SRC_DIRS+=("$d")
done
if [ ${#SRC_DIRS[@]} -eq 0 ]; then
  warn "PC-01: No source directories found (src/app/lib) — run from project root"
else
  SECRET_HITS=$(grep -rlE "(api.?key|secret|password)\s*[=:]\s*['\"][^'\"]{8,}" \
    --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=vendor \
    --exclude="*.env.example" --exclude="package-lock.json" \
    "${SRC_DIRS[@]}" 2>/dev/null | wc -l | tr -d ' ')
  [ "$SECRET_HITS" -eq 0 ] && pass "PC-01: No hardcoded secrets" || fail "PC-01: Potential secrets in source ($SECRET_HITS file(s))"
fi

# PC-02: .env in .gitignore
echo "[PC-02] .env excluded from git..."
if [ -f "$PROJECT_ROOT/.gitignore" ] && grep -q '\.env' "$PROJECT_ROOT/.gitignore"; then
  pass "PC-02: .env in .gitignore"
else
  fail "PC-02: .env not in .gitignore — add it"
fi

# PC-03: .env.example exists
echo "[PC-03] .env.example exists..."
[ -f "$PROJECT_ROOT/.env.example" ] && pass "PC-03: .env.example present" || fail "PC-03: .env.example missing"

# PC-04: Dependency audit (check tool availability, not run full audit here — use security-scan.sh)
echo "[PC-04] Dependency audit tool available..."
if command -v npm >/dev/null 2>&1 && [ -f "$PROJECT_ROOT/package.json" ]; then
  pass "PC-04: npm available (run: npm audit --audit-level=high --omit=dev)"
elif command -v pip-audit >/dev/null 2>&1 && [ -f "$PROJECT_ROOT/requirements.txt" ]; then
  pass "PC-04: pip-audit available"
elif command -v govulncheck >/dev/null 2>&1 && [ -f "$PROJECT_ROOT/go.mod" ]; then
  pass "PC-04: govulncheck available"
else
  fail "PC-04: No dependency audit tool found — install npm/pip-audit/govulncheck"
fi

# PC-05: Structured logging
echo "[PC-05] Structured logging..."
if grep -rqE "(pino|winston|structlog|zerolog|zap|python-json-logger)" \
   "$PROJECT_ROOT/src" "$PROJECT_ROOT/app" "$PROJECT_ROOT/lib" 2>/dev/null; then
  pass "PC-05: Structured logging library detected"
elif grep -rqE "console\.log|print\(" "$PROJECT_ROOT/src" "$PROJECT_ROOT/app" 2>/dev/null; then
  warn "PC-05: console.log/print found — switch to structured logger"
else
  warn "PC-05: Could not verify structured logging"
fi

# PC-06: Health endpoint
echo "[PC-06] Health endpoint..."
if grep -rqiE "(\/health|\/healthz|health.*route|route.*health)" \
   "$PROJECT_ROOT/src" "$PROJECT_ROOT/app" 2>/dev/null; then
  pass "PC-06: Health endpoint found in source"
else
  fail "PC-06: No health endpoint found — add GET /health"
fi

# PC-07: Readiness endpoint (softer check)
echo "[PC-07] Readiness endpoint..."
if grep -rqiE "(\/ready|\/readyz|readiness)" \
   "$PROJECT_ROOT/src" "$PROJECT_ROOT/app" 2>/dev/null; then
  pass "PC-07: Readiness endpoint found"
else
  warn "PC-07: No readiness endpoint found — add GET /ready (checks DB)"
fi

# PC-08: TLS check (look for HTTP rejection in config)
echo "[PC-08] TLS enforcement..."
if grep -rqiE "(ssl|tls|https|HTTPS_ONLY|secure.*true)" \
   "$PROJECT_ROOT/src" "$PROJECT_ROOT/app" "$PROJECT_ROOT/nginx.conf" "$PROJECT_ROOT/Caddyfile" 2>/dev/null; then
  pass "PC-08: TLS/HTTPS configuration found"
else
  warn "PC-08: No TLS config found — ensure HTTPS is enforced at ingress"
fi

# PC-09: Request timeout
echo "[PC-09] Request timeout..."
if grep -rqiE "(timeout|Timeout|REQUEST_TIMEOUT)" \
   "$PROJECT_ROOT/src" "$PROJECT_ROOT/app" 2>/dev/null; then
  pass "PC-09: Timeout configuration found"
else
  fail "PC-09: No timeout configuration found"
fi

# PC-10: Database connection pool
echo "[PC-10] Database connection pool..."
if grep -rqiE "(pool\.|Pool\(|connection_pool|pg\.Pool|SqlAlchemy|pool_size)" \
   "$PROJECT_ROOT/src" "$PROJECT_ROOT/app" 2>/dev/null; then
  pass "PC-10: Database connection pool configured"
else
  warn "PC-10: No connection pool found — configure pool.max and idleTimeout"
fi

# PC-11: Query timeout
echo "[PC-11] Query timeout..."
if grep -rqiE "(statement_timeout|query.*timeout|QUERY_TIMEOUT)" \
   "$PROJECT_ROOT/src" "$PROJECT_ROOT/app" 2>/dev/null; then
  pass "PC-11: Query timeout found"
else
  warn "PC-11: No query timeout — set statement_timeout in DB config"
fi

# PC-12: External HTTP timeouts
echo "[PC-12] External dependency timeouts..."
# Check for fetch/requests/http calls without timeout
APP_DIRS=()
for d in "$PROJECT_ROOT/src" "$PROJECT_ROOT/app"; do
  [ -d "$d" ] && APP_DIRS+=("$d")
done
if [ ${#APP_DIRS[@]} -eq 0 ]; then
  warn "PC-12: No source directories found — skipping external timeout check"
else
  UNTIMED=$({ grep -rE "(fetch\(|requests\.get\(|http\.Get\()" \
    "${APP_DIRS[@]}" 2>/dev/null | \
    grep -vE "(timeout|signal|AbortSignal)" || true; } | wc -l | tr -d ' ')
  [ "$UNTIMED" -eq 0 ] && pass "PC-12: External calls have timeouts" || \
    fail "PC-12: $UNTIMED external call(s) without timeout"
fi

# PC-13: RFC 9457 error format
echo "[PC-13] RFC 9457 error format..."
if grep -rqE "(problem.json|application/problem|type.*problems|RFC.?9457)" \
   "$PROJECT_ROOT/src" "$PROJECT_ROOT/app" 2>/dev/null; then
  pass "PC-13: RFC 9457 error format found"
else
  fail "PC-13: No RFC 9457 Problem Details error format found"
fi

# PC-14: Rate limiting
echo "[PC-14] Rate limiting..."
if grep -rqiE "(rateLimit|rate.limit|RateLimiter|throttle)" \
   "$PROJECT_ROOT/src" "$PROJECT_ROOT/app" 2>/dev/null; then
  pass "PC-14: Rate limiting found"
else
  fail "PC-14: No rate limiting found — add to authentication endpoints"
fi

# PC-15: CORS wildcard check
echo "[PC-15] CORS configuration..."
CORS_DIRS=()
for d in "$PROJECT_ROOT/src" "$PROJECT_ROOT/app"; do
  [ -d "$d" ] && CORS_DIRS+=("$d")
done
if [ ${#CORS_DIRS[@]} -eq 0 ]; then
  warn "PC-15: No source directories found — skipping CORS check"
else
  WILDCARD_CORS=$({ grep -rE "origin.*\*.*cred|cred.*origin.*\*" \
    "${CORS_DIRS[@]}" 2>/dev/null || true; } | wc -l | tr -d ' ')
  [ "$WILDCARD_CORS" -eq 0 ] && pass "PC-15: No wildcard CORS with credentials" || \
    fail "PC-15: Wildcard CORS with credentials found"
fi

# PC-16: Input validation
echo "[PC-16] Input validation..."
if grep -rqE "(zod|joi|yup|class-validator|pydantic|cerberus|marshmallow|validate)" \
   "$PROJECT_ROOT/src" "$PROJECT_ROOT/app" 2>/dev/null; then
  pass "PC-16: Input validation library found"
else
  fail "PC-16: No input validation library found"
fi

# PC-17: OpenAPI spec
echo "[PC-17] OpenAPI spec..."
SPEC_FOUND=false
for f in openapi.yaml openapi.json swagger.yaml swagger.json docs/api.yaml docs/openapi.yaml; do
  [ -f "$PROJECT_ROOT/$f" ] && SPEC_FOUND=true && break
done
$SPEC_FOUND && pass "PC-17: OpenAPI spec found" || warn "PC-17: No OpenAPI spec found"

# PC-18: Database migrations
echo "[PC-18] Database migrations..."
if [ -d "$PROJECT_ROOT/migrations" ] || [ -d "$PROJECT_ROOT/db/migrations" ] || \
   [ -d "$PROJECT_ROOT/alembic" ] || [ -f "$PROJECT_ROOT/atlas.hcl" ]; then
  pass "PC-18: Database migrations directory found"
else
  fail "PC-18: No migrations directory — use Atlas/Flyway/Alembic"
fi

# PC-19: Non-root Dockerfile user
echo "[PC-19] Container non-root user..."
if [ -f "$PROJECT_ROOT/Dockerfile" ]; then
  if grep -q '^USER' "$PROJECT_ROOT/Dockerfile" && ! grep -q '^USER root' "$PROJECT_ROOT/Dockerfile"; then
    pass "PC-19: Dockerfile USER is non-root"
  else
    fail "PC-19: Dockerfile missing non-root USER directive"
  fi
else
  warn "PC-19: No Dockerfile found"
fi

# PC-20: Container HEALTHCHECK
echo "[PC-20] Container health check..."
if [ -f "$PROJECT_ROOT/Dockerfile" ]; then
  grep -q '^HEALTHCHECK' "$PROJECT_ROOT/Dockerfile" && \
    pass "PC-20: Dockerfile HEALTHCHECK found" || \
    fail "PC-20: No HEALTHCHECK in Dockerfile"
else
  warn "PC-20: No Dockerfile found"
fi

# PC-21: Graceful shutdown
echo "[PC-21] Graceful shutdown..."
if grep -rqiE "(SIGTERM|graceful.*shutdown|server\.close|lifespan)" \
   "$PROJECT_ROOT/src" "$PROJECT_ROOT/app" 2>/dev/null; then
  pass "PC-21: Graceful shutdown handler found"
else
  fail "PC-21: No SIGTERM/graceful shutdown handler found"
fi

# PC-22: Request ID
echo "[PC-22] Request ID propagation..."
if grep -rqiE "(request.?id|x.request.id|x.correlation.id|requestId|correlationId)" \
   "$PROJECT_ROOT/src" "$PROJECT_ROOT/app" 2>/dev/null; then
  pass "PC-22: Request ID propagation found"
else
  warn "PC-22: No request ID found — add X-Request-Id to responses"
fi

# PC-23: Pagination
echo "[PC-23] Pagination on list endpoints..."
if grep -rqiE "(limit|cursor|pagination|paginate|LIMIT \$)" \
   "$PROJECT_ROOT/src" "$PROJECT_ROOT/app" 2>/dev/null; then
  pass "PC-23: Pagination pattern found"
else
  fail "PC-23: No pagination found — unbounded list endpoints risk OOM"
fi

# PC-24: Background jobs
echo "[PC-24] Background jobs..."
if grep -rqiE "(202|bullmq|celery|sidekiq|rq\.|background.*job|async.*queue)" \
   "$PROJECT_ROOT/src" "$PROJECT_ROOT/app" 2>/dev/null; then
  pass "PC-24: Background job pattern found"
else
  warn "PC-24: No background job system found — long operations should return 202"
fi

# PC-25: Memory limit
echo "[PC-25] Memory limit configured..."
if find "$PROJECT_ROOT" -name "*.yaml" -o -name "*.yml" 2>/dev/null | \
   xargs grep -ql "memory:" 2>/dev/null | head -1 | grep -q .; then
  pass "PC-25: Memory limit found in YAML config"
elif find "$PROJECT_ROOT" -name "docker-compose*.yml" 2>/dev/null | \
   xargs grep -ql "mem_limit:" 2>/dev/null | head -1 | grep -q .; then
  pass "PC-25: Memory limit found in Docker Compose"
else
  warn "PC-25: No memory limit found in K8s/Docker config"
fi

# ── Summary ──────────────────────────────────────────────────────────────────
echo ""
echo "─────────────────────────────────────────────"
echo "Tier 1 automated score: ${PASS}/${TOTAL} PASS, ${FAIL} FAIL, ${WARN} warnings"
echo ""
echo "Tier 2 — Human attestation required (12 items):"
echo "  See references/production.md PC-26 through PC-37"
echo "  On-call, runbook, SLO, security review, monitoring dashboard, etc."
echo ""
echo "Tier 3 — Infrastructure-dependent (9 items):"
echo "  See references/production.md PC-38 through PC-46"
echo "  HPA, read replicas, chaos engineering, load testing, tracing, etc."
echo ""

RECOMMENDED_MIN=20
if [ $PASS -ge $RECOMMENDED_MIN ]; then
  echo "✓ Tier 1 score meets recommended minimum (≥${RECOMMENDED_MIN}/${TOTAL})"
  exit 0
else
  echo "✗ Tier 1 score below recommended minimum (${PASS}/${TOTAL} < ${RECOMMENDED_MIN}/${TOTAL})"
  echo "  Fix FAIL items before proceeding to launch"
  exit 1
fi
