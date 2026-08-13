#!/usr/bin/env bash
# prompt-lint.sh — deterministic pre-ship checker for a prompt suite.
# Validates the three mechanical things "punt to Claude" gets wrong:
#   1. every promptfoo test has >=1 assertion (Anti-Slop rule 4: no test without assertions)
#   2. the provider model ID is PINNED, not an alias (Phase 4.2 / FM-3 silent regression)
#   3. the system prompt has no banned aggressive-language tokens (claude.md Rule 4 over-trigger)
#
# Usage:
#   tools/prompt-lint.sh <promptfooconfig.yaml> [system-prompt.txt]
# Exit codes: 0 = pass | 2 = lint failures | 3 = usage/file error
# Pure bash + grep/awk — no npm, no jq, no python. macOS/BSD + Linux compatible.

set -u

CONFIG="${1:-}"
SYSPROMPT="${2:-}"

if [ -z "$CONFIG" ]; then
  echo "usage: prompt-lint.sh <promptfooconfig.yaml> [system-prompt.txt]" >&2
  exit 3
fi
if [ ! -f "$CONFIG" ]; then
  echo "error: config not found: $CONFIG" >&2
  exit 3
fi

# Current pinned model IDs (claude.md model-pinning table, 2026-06-13). Anything matching the
# provider regex but NOT in this set is treated as an unpinned alias (e.g. anthropic:claude-sonnet).
PINNED='claude-opus-4-8|claude-opus-4-7|claude-opus-4-6|claude-sonnet-4-6|claude-haiku-4-5|claude-haiku-4-5-20251001|claude-fable-5|gpt-4o-2024|gpt-4-0|gemini-1.5'

fail=0

# --- Check 1: every test block has at least one assertion -------------------
# Count `- description:`/`vars:` test entries vs `assert:` keys. A test without an `assert:`
# (or with an empty assert list) is a non-discriminative "looks good" test.
# grep -c prints "0" and exits 1 on no match; capture stdout only and default empties to 0.
tests=$(grep -cE '^[[:space:]]*-[[:space:]]*(description|vars):' "$CONFIG" 2>/dev/null); tests=${tests:-0}
asserts=$(grep -cE '^[[:space:]]*assert:' "$CONFIG" 2>/dev/null); asserts=${asserts:-0}
# count actual assertion items (lines like `- type:` under an assert block)
assert_items=$(grep -cE '^[[:space:]]*-[[:space:]]*type:' "$CONFIG" 2>/dev/null); assert_items=${assert_items:-0}
if [ "$asserts" -eq 0 ] || [ "$assert_items" -eq 0 ]; then
  echo "FAIL [assertions]: no 'assert:' blocks found — every test needs >=1 measurable assertion (Anti-Slop rule 4)" >&2
  fail=1
elif [ "$tests" -gt 0 ] && [ "$asserts" -lt "$tests" ]; then
  echo "WARN [assertions]: $tests test entries but only $asserts assert: blocks — confirm each test has an assertion" >&2
fi

# --- Check 2: provider model ID is pinned, not an alias ---------------------
# Pull provider lines (anthropic:messages:<id> / anthropic:<id> / openai:<id> / etc.)
providers=$(grep -hoE '(anthropic|openai|google|vertex|bedrock)[:a-zA-Z0-9._-]*' "$CONFIG" 2>/dev/null \
  | grep -E 'anthropic|openai|google|vertex|bedrock' | sort -u)
if [ -z "$providers" ]; then
  echo "WARN [model-pin]: no provider line found in $CONFIG" >&2
else
  while IFS= read -r p; do
    [ -z "$p" ] && continue
    # extract the trailing model token after the last ':'
    mid="${p##*:}"
    if printf '%s' "$mid" | grep -qE "$PINNED"; then
      :  # pinned — ok
    elif printf '%s' "$mid" | grep -qE 'claude|gpt|gemini'; then
      echo "FAIL [model-pin]: '$p' looks like an UNPINNED alias — pin an exact version (e.g. claude-opus-4-8), not '$mid' (FM-3 silent regression)" >&2
      fail=1
    fi
  done <<EOF
$providers
EOF
fi

# --- Check 3: banned aggressive-language tokens in system prompt ------------
# Over-triggers on Claude 4.6+ (claude.md Rule 4). Only run if a system prompt file is given.
if [ -n "$SYSPROMPT" ]; then
  if [ ! -f "$SYSPROMPT" ]; then
    echo "error: system prompt file not found: $SYSPROMPT" >&2
    exit 3
  fi
  # word-boundary-ish match for the emphatic directives
  banned=$(grep -noiE 'MUST USE|ALWAYS INCLUDE|NEVER EVER|CRITICAL:|YOU MUST' "$SYSPROMPT" 2>/dev/null)
  if [ -n "$banned" ]; then
    echo "FAIL [aggressive-language]: banned over-triggering tokens in $SYSPROMPT (claude.md Rule 4 — use direct language):" >&2
    printf '%s\n' "$banned" | sed 's/^/    /' >&2
    fail=1
  fi
  # also flag deprecated/removed thinking API in any embedded code
  if grep -qE 'budget_tokens|output_format[^.]' "$SYSPROMPT" 2>/dev/null; then
    echo "WARN [stale-api]: $SYSPROMPT references budget_tokens or output_format — both removed/deprecated (claude.md Rule 1/2)" >&2
  fi
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: prompt-lint clean ($tests test entries, $assert_items assertions checked)"
  exit 0
else
  echo "prompt-lint: FAILURES found — fix before shipping (Phase 4 gate)" >&2
  exit 2
fi
