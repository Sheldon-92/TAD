#!/usr/bin/env bash
# audit-memory-layers.sh — deterministic CoALA layer-to-storage map validator
# (Rules MA1/MA2/MA3).
#
# Takes a Memory Layer Map (the pack's required output shape: piece-of-state →
# CoALA layer → storage) as a 3-column file and flags the two structural errors
# the pack names:
#   1. Durable state (preferences/facts) parked in WORKING memory / a FIFO queue
#      → MA2 "working-memory persistence" anti-pattern (evaporates at session end).
#   2. A vector DB used AS the memory layer with no consolidation/scoring/temporal
#      signal → MA3 "Memory != Vector DB".
# Plus a coverage check that every row names a recognized CoALA layer (MA1).
#
# Input format (pipe '|' separated, '#' comments allowed, header optional):
#   <state description> | <coala layer> | <storage impl>
# e.g.
#   user prefers black coffee | semantic | Mem0 user memory
#   recent turns             | working  | FIFO queue
#
# Usage:
#   audit-memory-layers.sh <map.txt>
#   cat map.txt | audit-memory-layers.sh -
# Exit codes: 0 = valid, 1 = violation, 2 = usage error.
set -euo pipefail

usage() { echo "usage: $(basename "$0") <map.txt|->" >&2; exit 2; }
[ "$#" -eq 1 ] || usage

VALID_LAYERS='working|episodic|semantic|procedural|organizational'
DURABLE_RE='prefer|preference|durable|profile|fact|setting|persona|long-term|api key|policy'
WORKING_RE='working|fifo|queue|scratchpad|volatile|in-context'
VECTOR_RE='vector|pinecone|milvus|faiss|chroma|weaviate|qdrant|embedding'
COGNITIVE_RE='consolidat|scor|temporal|decay|importance|graphiti|zep|validity interval'

src="$1"
[ "$src" = "-" ] || [ -f "$src" ] || { echo "error: no such file: $src" >&2; exit 2; }

rc=0 rows=0
while IFS= read -r raw || [ -n "$raw" ]; do
  line="$(printf '%s' "$raw" | sed 's/#.*$//' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
  [ -n "$line" ] || continue
  case "$line" in *'|'*) ;; *) continue ;; esac   # need at least one pipe

  # LC_ALL=C keeps tr ranges ASCII-only (safe under CJK/UTF-8 locales — per
  # the project's shell-portability knowledge).
  state="$(printf '%s' "$line"  | cut -d'|' -f1 | LC_ALL=C tr '[:upper:]' '[:lower:]')"
  layer="$(printf '%s' "$line"  | cut -d'|' -f2 | LC_ALL=C tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')"
  store="$(printf '%s' "$line"  | cut -d'|' -f3 | LC_ALL=C tr '[:upper:]' '[:lower:]')"

  # Skip a header row.
  case "$layer" in coalalayer|layer|coala) continue ;; esac
  rows=$((rows+1))

  # MA1: layer must be a recognized CoALA layer.
  if ! printf '%s' "$layer" | grep -qE "^($VALID_LAYERS)$"; then
    echo "FAIL (MA1): unrecognized CoALA layer '${layer}' for: ${state}"
    rc=1
    continue
  fi

  # MA2: durable state must NOT live in working memory / FIFO queue.
  if printf '%s' "$state" | grep -qiE "$DURABLE_RE"; then
    if printf '%s' "$layer" | grep -qiE '^working$' || printf '%s' "$store" | grep -qiE "$WORKING_RE"; then
      echo "FAIL (MA2): durable state '${state}' is in working/FIFO storage '${store}' — it evaporates at session end. Move to semantic memory."
      rc=1
    fi
  fi

  # MA3: a vector store used AS memory must show consolidation/scoring/temporal signal.
  if printf '%s' "$store" | grep -qiE "$VECTOR_RE"; then
    if ! printf '%s %s' "$state" "$store" | grep -qiE "$COGNITIVE_RE"; then
      echo "WARN (MA3): '${state}' uses a vector store '${store}' with no consolidation/scoring/temporal-tracking signal — that's RAG, not memory."
    fi
  fi
done < <(if [ "$src" = "-" ]; then cat; else cat "$src"; fi)

if [ "$rows" -eq 0 ]; then
  echo "error: no parsable 'state | layer | storage' rows found" >&2
  exit 2
fi

[ "$rc" -eq 0 ] && echo "ok: ${rows} layer mappings valid (MA1/MA2/MA3)"
exit "$rc"
