#!/usr/bin/env bash
# rag-config-lint.sh — Deterministic linter for a RAG pipeline config against the
# rag-retrieval capability pack's grounded thresholds. Moves the deterministic
# checks out of prose ("punt to Claude") into code (QUALITY-BAR A10).
#
# Usage: bash scripts/rag-config-lint.sh <path-to-pipeline-config>
#
# Config format: a flat key=value text/INI file (or JSON with these keys). Keys
# (all optional — only present keys are checked):
#   chunker            recursive-512 | fixed-512 | page-level | semantic | proposition | late
#   contextual         true | false        (Contextual Retrieval applied at index time — CH8)
#   embedder           any model name
#   embed_dims         integer
#   vector_db          pgvector | qdrant | chroma | pinecone | milvus | weaviate | ...
#   corpus_vectors     integer (total vectors / corpus size)
#   doc_type           academic | legal | medical | code | faq | web | general | paginated-tables
#   fusion             rrf | linear | raw-sum | sum
#   rrf_k              integer
#   candidate_pool     integer (first-stage pool size fed to reranker)
#   reranker           any reranker name
#   faithfulness_gate  float (0.0–1.0) — the production gate threshold. Judged
#                      domain-tiered: < 0.85 (general) or < 0.90 (legal/medical
#                      doc_type) = P0; 0.85–0.99 = P1 review band; 1.0 = clean
#                      (aspirational). NOT a strict ==1.0 gate.
#   eval_queries       integer (size of the continuous eval suite)
#
# Findings:
#   P0 — blocking (wrong / hallucinated results). ANY P0 → exit 1.
#   P1 — required before trusting retrieval quality. exit 2 if no P0 but ≥1 P1.
#   P2 — advisory (quality/latency/cost).
#   Clean → exit 0.
#
# Requirements: bash + standard POSIX tools (grep, awk, tr). No npm/jq required.

set -euo pipefail

CONFIG_PATH="${1:-}"

if [ -z "$CONFIG_PATH" ]; then
  echo "Usage: bash scripts/rag-config-lint.sh <path-to-pipeline-config>" >&2
  echo "  Example: bash scripts/rag-config-lint.sh my-rag-pipeline.conf" >&2
  exit 64
fi

if [ ! -f "$CONFIG_PATH" ]; then
  echo "✗ Config file not found: $CONFIG_PATH" >&2
  exit 64
fi

# ── Parse: extract value for a key from key=value / "key": value lines. ───────
# Tolerant of JSON (strips quotes/commas/colons) and INI (strips spaces).
get() {
  local key="$1" line
  # match key as `key=`, `key :`, `"key":` — case-insensitive on the key.
  # `|| true` so a no-match (grep exit 1) does not trip `set -e` + pipefail.
  line=$(grep -iE "(^|[\"[:space:]])${key}([\"[:space:]]*[:=])" "$CONFIG_PATH" 2>/dev/null | head -1 || true)
  [ -z "$line" ] && return 0
  printf '%s\n' "$line" \
    | sed -E "s/.*${key}[\"[:space:]]*[:=][[:space:]]*//I" \
    | tr -d '",' \
    | tr 'A-Z' 'a-z' \
    | awk '{$1=$1; print $1}'
}

# integer extraction (digits only; empty if absent/non-numeric)
get_int() {
  get "$1" | grep -oE '[0-9]+' | head -1 || true
}
# float extraction
get_float() {
  get "$1" | grep -oE '[0-9]+(\.[0-9]+)?' | head -1 || true
}

CHUNKER=$(get chunker)
CONTEXTUAL=$(get contextual)
EMBED_DIMS=$(get_int embed_dims)
VECTOR_DB=$(get vector_db)
CORPUS_VECTORS=$(get_int corpus_vectors)
DOC_TYPE=$(get doc_type)
FUSION=$(get fusion)
RRF_K=$(get_int rrf_k)
CANDIDATE_POOL=$(get_int candidate_pool)
RERANKER=$(get reranker)
FAITHFULNESS_GATE=$(get_float faithfulness_gate)
EVAL_QUERIES=$(get_int eval_queries)

P0=0; P1=0; P2=0
p0() { echo "[P0] $1"; P0=$((P0 + 1)); }
p1() { echo "[P1] $1"; P1=$((P1 + 1)); }
p2() { echo "[P2] $1"; P2=$((P2 + 1)); }

echo "=== RAG Config Lint: $CONFIG_PATH ==="
echo ""

# ── HR3: raw-score fusion is mathematically invalid (P0). ─────────────────────
case "$FUSION" in
  raw-sum|sum|linear-raw)
    p0 "Fusion=$FUSION: BM25 is unbounded, cosine ∈ [-1,1] — summing raw scores lets BM25 dominate (mathematically invalid). Fuse by rank with RRF, k=60. [HR3]"
    ;;
  linear)
    p2 "Fusion=linear: acceptable ONLY with labeled training data + continuous manual re-tuning under distribution shift. RRF (k=60) is the plug-and-play default. [HR3]"
    ;;
  rrf|"")
    if [ "$FUSION" = "rrf" ] && [ -n "$RRF_K" ] && [ "$RRF_K" -ne 60 ]; then
      p2 "rrf_k=$RRF_K: industry-default smoothing constant is k=60 (prevents top items from over-dominating). Justify any deviation with an eval. [HR3]"
    fi
    ;;
esac

# ── CH4: semantic-by-default on academic docs (P0). ───────────────────────────
if [ "$CHUNKER" = "semantic" ]; then
  if [ "$DOC_TYPE" = "academic" ] || [ -z "$DOC_TYPE" ]; then
    p0 "chunker=semantic on doc_type='${DOC_TYPE:-unspecified}': benchmarked < 55% accuracy vs recursive-512's 69% under equal context budget; reserve semantic for dense-unstructured recall-priority text only. Default to recursive-512. [CH4]"
  else
    p1 "chunker=semantic: justified only for long-form dense unstructured text where recall (not budget) is the priority. Confirm doc_type='$DOC_TYPE' fits; else use recursive-512 (69%). [CH4]"
  fi
fi
if [ "$CHUNKER" = "fixed-512" ]; then
  p2 "chunker=fixed-512 (67%): recursive-512 (69%) preserves paragraph/syntactic structure and wins the benchmark — switch unless an eval proves otherwise. [CH1]"
fi
# CH3: paginated tables want page-level
if [ "$DOC_TYPE" = "paginated-tables" ] && [ -n "$CHUNKER" ] && [ "$CHUNKER" != "page-level" ]; then
  p1 "doc_type=paginated-tables with chunker=$CHUNKER: page-level chunking won NVIDIA 2024 (0.648 acc, lowest variance) by keeping tables intact. Use page-level. [CH3]"
fi

# ── HR6: candidate pool > 50 (P1). ────────────────────────────────────────────
if [ -n "$CANDIDATE_POOL" ]; then
  if [ "$CANDIDATE_POOL" -gt 50 ]; then
    p1 "candidate_pool=$CANDIDATE_POOL: reranking top-50 captures ~90% of the accuracy gain of top-200; capping at 50 holds the ~120ms P95 budget. Cap at 50 unless an eval proves the extra candidates matter. [HR6]"
  fi
fi

# ── Faithfulness gate: domain-tiered (RE2). ───────────────────────────────────
# Regulated corpora (legal/medical) floor at 0.90; everything else at 0.85.
# 1.0 is aspirational, not a blocking target — a strict ==1.0 gate rejects every
# real deployment because the LLM-judge score is semi-deterministic (RE4).
#   block (P0):  gate below the domain floor (the deployment is set to ship known-risky answers)
#   review (P1): gate in the 0.85–0.99 band (inspect; don't auto-ship)
if [ -n "$FAITHFULNESS_GATE" ]; then
  case "$DOC_TYPE" in
    legal|medical) FAITH_FLOOR=0.90; FAITH_TIER="regulated" ;;
    *)             FAITH_FLOOR=0.85; FAITH_TIER="general"  ;;
  esac
  # compare as float via awk (no bc dependency)
  if awk "BEGIN{exit !($FAITHFULNESS_GATE < $FAITH_FLOOR)}"; then
    p0 "faithfulness_gate=$FAITHFULNESS_GATE below the $FAITH_TIER floor ($FAITH_FLOOR): a gate this low ships answers with an unacceptable share of unsupported claims. Raise the gate to ≥$FAITH_FLOOR (regulated finance/health/legal ≥0.90), averaged over the eval suite. [RE2]"
  elif awk "BEGIN{exit !($FAITHFULNESS_GATE < 1.0)}"; then
    p1 "faithfulness_gate=$FAITHFULNESS_GATE in the 0.85–0.99 review band: acceptable as a $FAITH_TIER gate but inspect unsupported claims rather than auto-shipping; 1.0 is aspirational, not required (judge variance keeps grounded answers <1.0). [RE2]"
  fi
  # caveat reminder (advisory): faithfulness != correctness.
  # Only surface when the config could plausibly be over-trusting the gate — i.e.
  # NOT on a clean, deliberately-aspirational 1.0 gate (avoids noise on clean configs, F2).
  if awk "BEGIN{exit !($FAITHFULNESS_GATE < 1.0)}"; then
    p2 "faithfulness_gate=$FAITHFULNESS_GATE: remember Faithfulness measures grounding, NOT correctness — a 0.95-faithful answer can still be wrong if retrieved context is stale. Pair with retrieval metrics + source-freshness. [RE7]"
  fi
fi

# ── RE6: eval suite < 100 queries (P1). ───────────────────────────────────────
if [ -n "$EVAL_QUERIES" ] && [ "$EVAL_QUERIES" -lt 100 ]; then
  p1 "eval_queries=$EVAL_QUERIES: < 100 representative queries cannot support a trustworthy production gate. Floor is 100–200 covering the real query distribution. [RE6]"
fi

# ── VD/scale: dedicated vector DB below 100M vectors (P2). ─────────────────────
if [ -n "$CORPUS_VECTORS" ] && [ "$CORPUS_VECTORS" -lt 100000000 ]; then
  case "$VECTOR_DB" in
    qdrant|pinecone|milvus|weaviate)
      p2 "vector_db=$VECTOR_DB at corpus_vectors=$CORPUS_VECTORS (< 100M): for < 100M vectors, pgvector + pgvectorscale hit 471 QPS @ 99% recall — 11.4× Qdrant's 41 QPS. Don't add a second datastore prematurely. [VD2]"
      ;;
  esac
fi

# ── CH8: non-self-contained corpora without Contextual Retrieval (P2). ────────
if [ "$CONTEXTUAL" != "true" ]; then
  case "$DOC_TYPE" in
    legal|medical|academic)
      p2 "doc_type=$DOC_TYPE without contextual=true: chunks here often lose meaning out of context. Contextual Retrieval (prepend 50–100 token LLM context before embedding AND BM25) cuts top-20 failure rate 35–67% at ~\$1.02/M tokens with prompt caching. [CH8]"
      ;;
  esac
fi

# ── Summary + exit code. ──────────────────────────────────────────────────────
echo ""
echo "=== Summary: $P0 P0 / $P1 P1 / $P2 P2 ==="
if [ "$P0" -gt 0 ]; then
  echo "✗ FAIL — $P0 blocking (P0) issue(s); will produce wrong or hallucinated results."
  exit 1
elif [ "$P1" -gt 0 ]; then
  echo "⚠ REVIEW — no P0, but $P1 required (P1) issue(s) before trusting retrieval quality."
  exit 2
else
  echo "✓ PASS — no P0/P1 issues found."
  exit 0
fi
