#!/usr/bin/env bash
# audit-decisions.sh — deterministic structural checker for ai-agent-architecture output.
#
# Verifies that a candidate /design Architecture Decision Document or /audit Architecture
# Audit Report actually walked the 10-decision navigator instead of giving freeform advice.
# This is the deterministic counterpart to examples/multi-agent-design-decisions.md's
# discriminative_pattern — structural verification stays in code, not "punted to Claude".
#
# Usage:   bash scripts/audit-decisions.sh path/to/design-or-audit.md
# Exit:    0 = structurally complete | 1 = missing decisions/artifact | 2 = bad usage
#
# Portable: POSIX bash + grep only. No Windows paths, no network, no extra deps.
# Locale-safe: forces en_US.UTF-8 so multibyte em-dashes in "D1 —" headers match.

set -euo pipefail
export LC_ALL=en_US.UTF-8

if [ "$#" -ne 1 ]; then
  echo "usage: bash scripts/audit-decisions.sh <design-or-audit.md>" >&2
  exit 2
fi

DOC="$1"
if [ ! -f "$DOC" ]; then
  echo "error: file not found: $DOC" >&2
  exit 2
fi

fail=0

# ---- Check 1: all 10 decision IDs present (D1..D10) -----------------------------
# A decision is "addressed" if its ID appears followed by a separator (— - : ( space).
missing_ids=""
for n in 1 2 3 4 5 6 7 8 9 10; do
  # Match "D<n>" with BOTH boundaries guarded: a non-alphanumeric (or start) before D,
  # and a non-digit (or end) after the number. The leading boundary stops "MD5" from
  # matching "D5", "CMD8" from "D8", "RND9" from "D9", etc. The trailing boundary stops
  # "D1" from matching "D10". Covers "D1 —", "D1:", "D1 (", "D1 -", "Decision 1".
  if ! grep -Eq "(^|[^A-Za-z0-9])D${n}([^0-9]|$)|(^|[^A-Za-z0-9])Decision ${n}([^0-9]|$)" "$DOC"; then
    missing_ids="${missing_ids} D${n}"
  fi
done
if [ -n "$missing_ids" ]; then
  echo "FAIL: missing decision IDs:${missing_ids}"
  fail=1
else
  echo "PASS: all 10 decision IDs (D1-D10) present"
fi

# ---- Check 2: named pack artifact emitted ---------------------------------------
if grep -Eq "Architecture Decision Document|Architecture Audit Report" "$DOC"; then
  echo "PASS: named artifact (Architecture Decision Document / Audit Report) present"
else
  echo "FAIL: no 'Architecture Decision Document' or 'Architecture Audit Report' artifact heading"
  fail=1
fi

# ---- Check 3: conditional dual-agent / D5 MCP-checklist safety trigger -----------
# Load-bearing contract: IF the doc references untrusted external input, the dual-agent
# architecture / D5 MCP checklist MUST be present. If the doc never mentions untrusted
# external input, this trigger is N/A (trusted-only systems legitimately skip it).
if grep -Eiq "untrusted (external )?(input|data|email|web|content|source|third.?party|api)|external (email|web|third.?party|api) (data|input|content)" "$DOC"; then
  if grep -Eiq "dual.?agent|MCP checklist|quarantined (parser|llm)|unprivileged parser" "$DOC"; then
    echo "PASS: untrusted input present AND dual-agent/MCP-checklist trigger fired"
  else
    echo "FAIL: doc references untrusted external input but no dual-agent / D5 MCP checklist mitigation"
    fail=1
  fi
else
  echo "N/A : no untrusted external input declared — dual-agent trigger not required"
fi

echo "---"
if [ "$fail" -eq 0 ]; then
  echo "RESULT: structurally complete (exit 0)"
  exit 0
else
  echo "RESULT: structural gaps found (exit 1)"
  exit 1
fi
