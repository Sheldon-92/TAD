#!/usr/bin/env bash
# otel-conformance-check.sh — deterministic verifier for OpenTelemetry GenAI semconv conformance.
#
# Greps a user-supplied OTLP/trace export (JSON), an SDK config/env file, or any text that
# captures the emitted telemetry, and asserts the four load-bearing semconv rules this pack
# enforces. This converts the OT-rule audit from prose ("punt to Claude") into a runnable checker
# (Anthropic best-practice: deterministic ops -> code, not prose).
#
# Usage:
#   scripts/otel-conformance-check.sh <export-or-config-file> [<more-files>...]
#   cat trace.json env.sh | scripts/otel-conformance-check.sh -      # read from stdin
#
# Checks (each independently scored; a failed check appends to the failure list):
#   C1  OTEL_SEMCONV_STABILITY_OPT_IN=gen_ai_latest_experimental is set
#   C2  required span attrs gen_ai.operation.name AND gen_ai.provider.name present
#   C3  raw gen_ai.usage.*_tokens counters present AND no pre-computed flat 'cost' field
#   C4  gen_ai.client.token.usage emitted as Histogram (not Counter / Gauge)
#
# Exit codes:
#   0   PASS — all four checks passed
#   N   non-zero — N = number of failed checks (1..4); see stderr for which
#   64  usage error (no input / unreadable file)
#
# Portable: POSIX grep -E only; no GNU-only flags; no Windows paths.

set -u

usage() {
  echo "usage: $(basename "$0") <export-or-config-file> [more-files...]   (or '-' for stdin)" >&2
  exit 64
}

[ "$#" -ge 1 ] || usage

# ---- Collect input into a single buffer -------------------------------------
INPUT=""
if [ "$1" = "-" ]; then
  INPUT="$(cat)"
else
  for f in "$@"; do
    if [ ! -r "$f" ]; then
      echo "error: cannot read file: $f" >&2
      exit 64
    fi
    INPUT="$INPUT
$(cat "$f")"
  done
fi

if [ -z "$(printf '%s' "$INPUT" | tr -d '[:space:]')" ]; then
  echo "error: empty input" >&2
  exit 64
fi

# grep helper over the buffer
has() { printf '%s' "$INPUT" | grep -Eq "$1"; }

FAILS=0
fail() { echo "FAIL $1" >&2; FAILS=$((FAILS + 1)); }
pass() { echo "PASS $1"; }

# ---- C1: opt-in env var set to the latest-experimental value (OT1) ----------
# Accept OTEL_SEMCONV_STABILITY_OPT_IN containing gen_ai_latest_experimental
# (the value may carry other comma-separated opt-ins, e.g. "...,gen_ai_latest_experimental").
if has 'OTEL_SEMCONV_STABILITY_OPT_IN[^[:alnum:]_]*=?[^#]*gen_ai_latest_experimental'; then
  pass "C1 OTEL_SEMCONV_STABILITY_OPT_IN=gen_ai_latest_experimental set"
else
  fail "C1 OTEL_SEMCONV_STABILITY_OPT_IN=gen_ai_latest_experimental NOT set (OT1: latest semconv is opt-in)"
fi

# ---- C2: required span attributes present (OT2) -----------------------------
if has 'gen_ai\.operation\.name' && has 'gen_ai\.provider\.name'; then
  pass "C2 required span attrs gen_ai.operation.name + gen_ai.provider.name present"
else
  MISSING=""
  has 'gen_ai\.operation\.name' || MISSING="$MISSING gen_ai.operation.name"
  has 'gen_ai\.provider\.name'  || MISSING="$MISSING gen_ai.provider.name"
  fail "C2 missing required span attr(s):$MISSING (OT2)"
fi

# ---- C3: raw token counters present AND no pre-computed flat cost (OT3 + cross-cutting) ----
RAW_TOKENS_OK=0
has 'gen_ai\.usage\.(input|output|total)_tokens|gen_ai\.usage\.cache_(read|creation)\.input_tokens|gen_ai\.usage\.reasoning\.output_tokens' && RAW_TOKENS_OK=1

# A pre-computed cost field is a flat dollar value baked into the span/metric, e.g.
#   "cost": 0.0123 | gen_ai.usage.cost | "total_cost_usd" | cost_usd=...
# We FLAG it; raw counters + a versioned pricing matrix downstream are the correct pattern.
PRECOMPUTED_COST=0
has '"(cost|total_cost|cost_usd|total_cost_usd)"[[:space:]]*:[[:space:]]*[0-9]|gen_ai\.usage\.cost|(^|[^a-zA-Z_.])cost_usd[[:space:]]*=' && PRECOMPUTED_COST=1

if [ "$RAW_TOKENS_OK" -eq 1 ] && [ "$PRECOMPUTED_COST" -eq 0 ]; then
  pass "C3 raw gen_ai.usage.*_tokens counters present, no pre-computed flat cost field"
else
  REASON=""
  [ "$RAW_TOKENS_OK" -eq 0 ] && REASON="$REASON no raw gen_ai.usage.*_tokens counters found;"
  [ "$PRECOMPUTED_COST" -eq 1 ] && REASON="$REASON pre-computed flat cost field detected (store raw counters + versioned pricing matrix instead);"
  fail "C3$REASON (cross-cutting: emit raw counters, not pre-multiplied cost)"
fi

# ---- C4: token.usage emitted as Histogram, not Counter/Gauge (OT5) ----------
# Look for the metric name; if present, its instrument type must be Histogram.
if has 'gen_ai\.client\.token\.usage'; then
  # Pull lines near the metric name and check the declared instrument type.
  CONTEXT="$(printf '%s' "$INPUT" | grep -E -A4 -B1 'gen_ai\.client\.token\.usage' 2>/dev/null || printf '%s' "$INPUT")"
  if printf '%s' "$CONTEXT" | grep -Eiq 'histogram'; then
    if printf '%s' "$CONTEXT" | grep -Eiq '(^|[^a-z])(counter|gauge|sum)([^a-z]|$)'; then
      fail "C4 gen_ai.client.token.usage declares a Counter/Gauge/Sum instrument (OT5: must be Histogram for p50/p95/p99)"
    else
      pass "C4 gen_ai.client.token.usage emitted as Histogram"
    fi
  else
    fail "C4 gen_ai.client.token.usage present but NOT typed Histogram (OT5: substituting Counter/Gauge breaks percentile aggregation)"
  fi
else
  # Metric not emitted at all — flag as a conformance gap (the spec-defined token-usage metric is missing).
  fail "C4 gen_ai.client.token.usage metric not found (OT5: emit the spec-defined token-usage Histogram)"
fi

# ---- Verdict ----------------------------------------------------------------
echo "----"
if [ "$FAILS" -eq 0 ]; then
  echo ">>> OTEL GENAI CONFORMANCE: PASS (4/4 checks)"
  exit 0
else
  echo ">>> OTEL GENAI CONFORMANCE: FAIL ($FAILS check(s) failed)" >&2
  exit "$FAILS"
fi
