#!/usr/bin/env bash
# verify-mcp-server.sh — Deterministic validator for an MCP server source tree.
#
# Runs the checks this pack would otherwise "punt to Claude":
#   M3  console.log() in a STDIO server  → stdout is the JSON-RPC channel (FORBIDDEN)
#   M6  tool count per server            → warn at >15, hard context note at >35
#   S8  Zod .strict() / additionalProperties:false on object schemas
#   T1  MCP Inspector --cli tools/list   → live smoke test (skipped if no run cmd / npx)
#
# Usage:
#   bash scripts/verify-mcp-server.sh <server-src-dir> [-- <run command for Inspector>]
#   e.g. bash scripts/verify-mcp-server.sh ./src -- node dist/index.js
#
# Exit codes: 0 = all checks passed (or skipped). 1 = at least one violation. 2 = usage error.
# Portable: bash 3.2 (macOS), BSD + GNU grep. No Windows paths. No external deps required
# for the static checks; jq + npx only used (optionally) for the Inspector smoke test.

set -uo pipefail

# ── Args ─────────────────────────────────────────────────────────────────────
SRC_DIR="${1:-}"
RUN_CMD=""
if [ "$#" -ge 2 ]; then
  shift
  if [ "${1:-}" = "--" ]; then
    shift
    RUN_CMD="$*"
  fi
fi

if [ -z "$SRC_DIR" ]; then
  echo "Usage: bash scripts/verify-mcp-server.sh <server-src-dir> [-- <run command>]" >&2
  echo "  Example: bash scripts/verify-mcp-server.sh ./src -- node dist/index.js" >&2
  exit 2
fi
if [ ! -d "$SRC_DIR" ]; then
  echo "✗ Source dir not found: $SRC_DIR" >&2
  exit 2
fi

VIOLATIONS=0
fail() { echo "✗ [$1] $2"; VIOLATIONS=$((VIOLATIONS + 1)); }
pass() { echo "✓ [$1] $2"; }
warn() { echo "⚠ [$1] $2"; }

# Collect candidate source files (TS/JS), excluding tests and build output.
FILES=$(find "$SRC_DIR" -type f \( -name '*.ts' -o -name '*.js' -o -name '*.mjs' \) \
  2>/dev/null | grep -vE '(\.test\.|\.spec\.|/node_modules/|/dist/)' || true)

echo "=== verify-mcp-server: $SRC_DIR ==="

# ── M3: console.log() forbidden in STDIO servers ─────────────────────────────
if [ -n "$FILES" ]; then
  LOG_HITS=$(echo "$FILES" | tr '\n' '\0' | xargs -0 grep -nE 'console\.log' 2>/dev/null \
    | grep -vE 'console\.(error|warn)' || true)
  if [ -n "$LOG_HITS" ]; then
    fail "M3" "console.log() found — corrupts the STDIO JSON-RPC stream. Use console.error()/server.sendLoggingMessage():"
    echo "$LOG_HITS" | sed 's/^/      /'
  else
    pass "M3" "no console.log() in source (STDIO stream safe)"
  fi
else
  warn "M3" "no .ts/.js source files found under $SRC_DIR"
fi

# ── M6: tool count per server ────────────────────────────────────────────────
# Count tool registrations: registerTool( (current) + server.tool( (deprecated).
if [ -n "$FILES" ]; then
  TOOL_COUNT=$(echo "$FILES" | tr '\n' '\0' \
    | xargs -0 grep -hoE '\.(registerTool|tool)\(' 2>/dev/null | wc -l | tr -d ' ')
  DEPRECATED=$(echo "$FILES" | tr '\n' '\0' \
    | xargs -0 grep -hoE '\.tool\(' 2>/dev/null | wc -l | tr -d ' ')
  if [ "$TOOL_COUNT" -gt 35 ]; then
    fail "M6" "$TOOL_COUNT tool registrations — God Server. 58 tools ≈ 55K tokens of defs before the first task. Split or use the Tool Search Tool (M11)."
  elif [ "$TOOL_COUNT" -gt 15 ]; then
    warn "M6" "$TOOL_COUNT tool registrations (>15) — consider merging into workflow tools or enabling the Tool Search Tool (M11)."
  else
    pass "M6" "$TOOL_COUNT tool registrations (≤15)"
  fi
  if [ "$DEPRECATED" -gt 0 ]; then
    fail "M4" "$DEPRECATED use(s) of deprecated 4-arg server.tool(...). SDK v1.29.0 uses server.registerTool(name, {title,description,inputSchema,outputSchema,annotations}, handler)."
  fi
fi

# ── S8: strict object schemas ────────────────────────────────────────────────
# Heuristic: every z.object( should be followed (eventually) by .strict(); flag the count gap.
if [ -n "$FILES" ]; then
  ZOBJ=$(echo "$FILES" | tr '\n' '\0' | xargs -0 grep -hoE 'z\.object\(' 2>/dev/null | wc -l | tr -d ' ')
  ZSTRICT=$(echo "$FILES" | tr '\n' '\0' | xargs -0 grep -hoE '\.strict\(\)' 2>/dev/null | wc -l | tr -d ' ')
  if [ "$ZOBJ" -gt 0 ] && [ "$ZSTRICT" -lt "$ZOBJ" ]; then
    fail "S8" "$ZOBJ z.object( schemas but only $ZSTRICT .strict() — non-strict schemas silently accept hallucinated params. Add .strict() (or additionalProperties:false)."
  elif [ "$ZOBJ" -gt 0 ]; then
    pass "S8" "all $ZOBJ z.object( schemas appear to use .strict()"
  else
    warn "S8" "no z.object( schemas found (zero-param tools or JSON-Schema only)"
  fi
fi

# ── T1: MCP Inspector --cli tools/list smoke test (optional) ─────────────────
if [ -n "$RUN_CMD" ]; then
  if command -v npx >/dev/null 2>&1; then
    echo "--- T1: MCP Inspector tools/list smoke ($RUN_CMD) ---"
    INSPECT=$(npx -y @modelcontextprotocol/inspector --cli $RUN_CMD --method tools/list 2>&1)
    RC=$?
    if [ "$RC" -ne 0 ]; then
      fail "T1" "Inspector tools/list exited $RC — server did not respond to a tools/list request:"
      echo "$INSPECT" | head -10 | sed 's/^/      /'
    elif echo "$INSPECT" | grep -q '"tools"'; then
      pass "T1" "server responded to tools/list"
    else
      fail "T1" "Inspector ran but no \"tools\" array in response:"
      echo "$INSPECT" | head -10 | sed 's/^/      /'
    fi
  else
    warn "T1" "npx not found — skipping Inspector smoke test. Install Node.js: https://nodejs.org"
  fi
else
  warn "T1" "no run command given (pass '-- <cmd>') — skipping Inspector tools/list smoke test"
fi

echo "=== verify-mcp-server: $VIOLATIONS violation(s) ==="
[ "$VIOLATIONS" -eq 0 ] || exit 1
exit 0
