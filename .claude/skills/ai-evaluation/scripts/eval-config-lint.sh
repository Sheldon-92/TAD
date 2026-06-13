#!/usr/bin/env bash
# eval-config-lint.sh — Deterministic linter for promptfoo / deepeval eval configs.
#
# Usage: bash scripts/eval-config-lint.sh <path-to-eval-config.{yaml,yml,json}>
#
# Flags this pack's load-bearing evaluation violations (judgment rules → mechanical check):
#   (a) only ONE provider family appears in the whole config  → self-enhancement-bias FAIL [P0]
#       (Judge ≠ Optimizer cross-cutting rule; MT-Bench arXiv:2306.05685)
#       SMOKE-ALARM ONLY: this counts globally-distinct families; it does NOT parse which
#       provider is the judge vs the generator. A config with generator=claude + judge=claude
#       PLUS an unrelated gpt-4o baseline shows 2 families and PASSES this check — a known
#       false-negative. The actual judge==generator-family determination requires reading
#       ab-testing-rules.md AB3 + SKILL.md cross-cutting rule by hand. This is a smoke alarm,
#       not a substitute for that review.
#   (b) llm-rubric / g-eval assertion with NO `threshold`    → no-op gate WARN             [P2]
#       (promptfoo: un-thresholded model-graded assertion passes on grader.pass alone)
#   (c) golden test/scenario count < B3 floor (>=5)          → under-covered FAIL          [P0]
#   (d) non-deterministic suite with no --repeat / repeat<3  → unbounded variance WARN     [P2]
#
# Exit codes:  0 = clean   |   1 = >=1 P0 violation   |   2 = advisory-only (P2 warnings, no P0)
#
# Requirements: grep, sed, awk (POSIX). jq used ONLY if the config is .json AND jq is present;
#               otherwise falls back to grep. No npm / pip / network.

set -euo pipefail

CONFIG="${1:-}"

if [ -z "$CONFIG" ]; then
  echo "Usage: bash scripts/eval-config-lint.sh <path-to-eval-config.{yaml,yml,json}>" >&2
  echo "  Example: bash scripts/eval-config-lint.sh promptfooconfig.yaml" >&2
  exit 2
fi
if [ ! -f "$CONFIG" ]; then
  echo "✗ Config file not found: $CONFIG" >&2
  exit 2
fi

# Force byte-stable matching of the multibyte / case markers regardless of host locale.
export LC_ALL="${LC_ALL:-C}"

P0=0
P2=0

echo "=== eval-config-lint: $CONFIG ==="
echo ""

# Lowercased copy for case-insensitive provider-family detection.
LC_BODY="$(tr '[:upper:]' '[:lower:]' < "$CONFIG")"

# Detect provider families mentioned anywhere in the config.
# Map vendor tokens → a single family label so claude==anthropic, gpt==openai, etc.
declare_family() {
  # echoes one family label per matched vendor token, deduped by the caller
  printf '%s\n' "$LC_BODY" \
    | grep -oE 'anthropic|claude|openai|gpt-?[0-9o]|azure:|google|gemini|vertex|mistral|cohere|llama|groq|bedrock' \
    | sed -E \
        -e 's/^(anthropic|claude).*/anthropic/' \
        -e 's/^(openai|gpt.*|azure:).*/openai/' \
        -e 's/^(google|gemini|vertex).*/google/' \
        -e 's/^(mistral).*/mistral/' \
        -e 's/^(cohere).*/cohere/' \
        -e 's/^(llama|groq|bedrock).*/meta/' \
    | sort -u
}

# ── (a) Judge ≠ Optimizer: provider family collision ─────────────────────────
echo "[ 1/4 ] Judge ≠ Optimizer (provider family) ..."
FAMILIES="$(declare_family || true)"
FAMILY_COUNT=$(printf '%s\n' "$FAMILIES" | grep -cE '.' || true)
# A "judge"/"grader"/"provider" config that names exactly ONE family while also using
# llm-rubric/g-eval/model-graded judging => generator family == judge family.
USES_LLM_JUDGE=$(grep -ciE 'llm-rubric|g-eval|model-graded|llm.?as.?judge|gradingProvider|provider:' "$CONFIG" || true)
if [ "$USES_LLM_JUDGE" -gt 0 ] && [ "$FAMILY_COUNT" -le 1 ]; then
  echo "  ✗ [P0] Single provider family ($(printf '%s' "${FAMILIES:-none}" | tr '\n' ',')) used for both generation AND LLM judging."
  echo "        Self-enhancement bias: a model rates its own family's outputs higher (MT-Bench arXiv:2306.05685)."
  echo "        FIX: set a different-family gradingProvider (e.g. generator=claude → judge=gpt-4o), or document the bias."
  P0=$((P0 + 1))
else
  echo "  ✓ ≥2 provider families present (or no LLM judge in config) — NOTE: cannot confirm the JUDGE differs from the GENERATOR; verify by hand per AB3."
fi
echo ""

# ── (b) Un-thresholded model-graded assertions ───────────────────────────────
echo "[ 2/4 ] llm-rubric / g-eval threshold presence ..."
# Count model-graded assertion lines, then count how many have a sibling threshold.
GRADED=$(grep -cE 'type:[[:space:]]*(llm-rubric|g-eval|model-graded[a-z-]*)' "$CONFIG" || true)
THRESHOLDS=$(grep -cE 'threshold:[[:space:]]*[0-9]' "$CONFIG" || true)
if [ "$GRADED" -gt 0 ] && [ "$THRESHOLDS" -lt "$GRADED" ]; then
  echo "  ⚠ [P2] $GRADED model-graded assertion(s) but only $THRESHOLDS explicit threshold(s)."
  echo "        An un-thresholded llm-rubric/g-eval passes on grader.pass alone — a silent no-op gate."
  echo "        FIX: add 'threshold: 0.7' (qualitative bar) or 0.66 (2-of-3 majority) to each model-graded assert."
  P2=$((P2 + 1))
else
  echo "  ✓ All model-graded assertions carry a threshold (or none present)."
fi
echo ""

# ── (c) Golden dataset / test count below B3 floor (>=5) ─────────────────────
echo "[ 3/4 ] Golden test count (B3 floor >= 5 scenarios) ..."
# promptfoo: count top-level test entries (`- vars:` / `- description:`) ; deepeval: `LLMTestCase(`.
TESTS=$(grep -cE '^[[:space:]]*-[[:space:]]*(vars|description|assert):|LLMTestCase\(|"vars"[[:space:]]*:' "$CONFIG" || true)
if [ "$TESTS" -gt 0 ] && [ "$TESTS" -lt 5 ]; then
  echo "  ✗ [P0] Only $TESTS test scenario(s) detected — below the B3 floor of >=5 (core/edge/error/performance)."
  echo "        FIX: expand to >=5 scenarios; >=50-100 trajectories for production decisions (benchmark-rules.md B2/B3)."
  P0=$((P0 + 1))
elif [ "$TESTS" -eq 0 ]; then
  echo "  ⚠ [P2] No test scenarios detected — confirm this file is an eval config, not a provider stub."
  P2=$((P2 + 1))
else
  echo "  ✓ $TESTS test scenarios (>= B3 floor of 5)."
fi
echo ""

# ── (d) Non-deterministic suite without --repeat>=3 ──────────────────────────
echo "[ 4/4 ] Repeat-count for non-deterministic suites ..."
NONDET=$(grep -ciE 'llm-rubric|g-eval|model-graded|non.?deterministic|temperature:[[:space:]]*0*\.[1-9]' "$CONFIG" || true)
REPEAT=$(grep -oE 'repeat:[[:space:]]*[0-9]+|--repeat[[:space:]=]+[0-9]+' "$CONFIG" | grep -oE '[0-9]+' | sort -rn | head -1 || true)
REPEAT="${REPEAT:-0}"
if [ "$NONDET" -gt 0 ] && [ "$REPEAT" -lt 3 ]; then
  echo "  ⚠ [P2] Non-deterministic judging present but repeat=$REPEAT (< 3)."
  echo "        FIX: 'npx promptfoo eval --repeat 3' (or repeat: 3) to bound variance (benchmark-rules.md B5)."
  P2=$((P2 + 1))
else
  echo "  ✓ Repeat>=3 (or deterministic suite)."
fi
echo ""

# ── Verdict ──────────────────────────────────────────────────────────────────
echo "=== Summary: $P0 P0 violation(s), $P2 advisory warning(s) ==="
if [ "$P0" -gt 0 ]; then
  echo ">>> VERDICT: FAIL (fix P0 before running this eval)"
  exit 1
elif [ "$P2" -gt 0 ]; then
  echo ">>> VERDICT: ADVISORY (no P0; address warnings to trust results)"
  exit 2
else
  echo ">>> VERDICT: CLEAN"
  exit 0
fi
