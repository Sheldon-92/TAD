#!/usr/bin/env bash
# validate-curation-config.sh — Deterministic checker for a data-curation pipeline config
#
# Usage: bash scripts/validate-curation-config.sh <pipeline-config-file>
#   <pipeline-config-file>  A pipeline description in JSONL / YAML / plain text
#                           (the config that declares the curation stages).
#
# This script does the deterministic file-grep work that should be CODE, not
# punted to Claude (QUALITY-BAR A10). It asserts the five pack-load-bearing
# invariants and prints a P0/P1 verdict per check:
#
#   1. Near-duplicate pass exists  (MinHashLSH / LSHBloom present, not exact-only)   [DEDUP3/DEDUP5]
#   2. Self-Instruct / Evol loops declare a ROUGE-L <= 0.7 reject threshold          [GEN1]
#   3. MinHash signatures declared as BINARY_VECTOR (not float32)                    [DEDUP4]
#   4. Chat-template config sets roles_to_train + map_eos_token/train_on_eos         [PA5]
#   5. A decontamination stage precedes any benchmark-score step                     [cross-cutting]
#
# Pure POSIX/BSD-safe text greps. No external deps, no network, no Windows paths.
# Exit code: 0 if no P0 violations, 1 if any P0 violation.

set -euo pipefail

CFG="${1:-}"

if [ -z "$CFG" ]; then
  echo "Usage: bash scripts/validate-curation-config.sh <pipeline-config-file>" >&2
  echo "  Example: bash scripts/validate-curation-config.sh pipeline.yaml" >&2
  echo "  Example: bash scripts/validate-curation-config.sh pipeline.jsonl" >&2
  exit 1
fi

if [ ! -f "$CFG" ]; then
  echo "✗ Config file not found: $CFG" >&2
  exit 1
fi

echo "=== Curation Config Validation: $CFG ==="
echo ""

P0=0
P1=0

# Helper: case-insensitive fixed-ish presence test over the whole file.
has() { grep -iqE "$1" "$CFG"; }

# ── Check 1: near-duplicate pass (not exact-only) — DEDUP3/DEDUP5 ─────────────
echo "[ 1/5 ] Near-duplicate dedup pass (MinHashLSH / LSHBloom)..."
if has 'minhash[ _-]?lsh|lshbloom|min_?hash'; then
  echo "  ✓ Near-duplicate pass declared (MinHashLSH/LSHBloom)."
elif has 'sha-?256|exact[ _-]?(match|dedup)|dedup'; then
  echo "  ✗ [P0] Only exact-match dedup found — no MinHashLSH/LSHBloom near-duplicate pass."
  echo "        Fix (DEDUP3): add a MinHashLSH (5-gram, num_perm=256, J=0.7, ~20 bands) near-duplicate stage."
  P0=$((P0 + 1))
else
  echo "  ⚠ [P1] No dedup stage detected at all — add exact SHA-256 then a MinHashLSH near-dup pass."
  P1=$((P1 + 1))
fi
echo ""

# ── Check 2: ROUGE-L <= 0.7 reject threshold on generation loops — GEN1 ──────
echo "[ 2/5 ] Self-Instruct / Evol-Instruct ROUGE-L <= 0.7 reject threshold..."
if has 'self[ _-]?instruct|evol[ _-]?instruct|wizardlm|instruction[ _-]?gen'; then
  if grep -iE 'rouge' "$CFG" | grep -qE '0\.7|<=?\s*0\.7|>\s*0\.7'; then
    echo "  ✓ ROUGE-L 0.7 reject threshold declared on generation loop."
  else
    echo "  ✗ [P0] Generation loop present but no ROUGE-L 0.7 reject threshold declared."
    echo "        Fix (GEN1): reject any generated instruction with ROUGE-L > 0.7 vs the existing pool."
    P0=$((P0 + 1))
  fi
else
  echo "  ℹ No Self-Instruct/Evol generation loop in this config — skipping ROUGE-L check."
fi
echo ""

# ── Check 3: MinHash signatures as BINARY_VECTOR (not float32) — DEDUP4 ──────
echo "[ 3/5 ] MinHash signatures stored as BINARY_VECTOR (not float32)..."
if has 'minhash[ _-]?lsh|lshbloom|min_?hash'; then
  if has 'float32|float_32'; then
    echo "  ✗ [P0] MinHash present but float32 declared — precision corrupts above 16,777,216."
    echo "        Fix (DEDUP4): store MinHash signatures as BINARY_VECTOR (e.g. Milvus MINHASH_LSH)."
    P0=$((P0 + 1))
  elif has 'binary_?vector'; then
    echo "  ✓ MinHash signatures declared as BINARY_VECTOR."
  else
    echo "  ⚠ [P1] MinHash present but signature dtype unspecified — declare BINARY_VECTOR explicitly."
    P1=$((P1 + 1))
  fi
else
  echo "  ℹ No MinHash stage in this config — skipping signature-dtype check."
fi
echo ""

# ── Check 4: chat-template token-mapping config — PA5 ─────────────────────────
echo "[ 4/5 ] Chat-template config (roles_to_train + map_eos_token/train_on_eos)..."
if has 'chat[ _-]?template|sharegpt|axolotl|unsloth|fine[ _-]?tune|sft'; then
  HAS_ROLES=0; HAS_EOS=0
  has 'roles_to_train' && HAS_ROLES=1
  has 'map_eos_token|train_on_eos' && HAS_EOS=1
  if [ $HAS_ROLES -eq 1 ] && [ $HAS_EOS -eq 1 ]; then
    echo "  ✓ roles_to_train + map_eos_token/train_on_eos declared."
  else
    echo "  ✗ [P0] Fine-tune config missing token-mapping fields"
    [ $HAS_ROLES -eq 0 ] && echo "        Fix (PA5): set roles_to_train: [\"assistant\"] — else you train on user turns."
    [ $HAS_EOS -eq 0 ]   && echo "        Fix (PA5): set map_eos_token / train_on_eos: last — else you train on pad tokens."
    P0=$((P0 + 1))
  fi
else
  echo "  ℹ No chat-template / fine-tune stage in this config — skipping token-mapping check."
fi
echo ""

# ── Check 5: decontamination precedes any benchmark-score step — cross-cutting
echo "[ 5/5 ] Decontamination stage precedes any benchmark-score step..."
# Find the first line declaring contamination/decontam vs first benchmark-score line.
DECON_LINE=$(grep -niE 'decontam|contamination|contam[ _-]?(audit|check)|contam_remove' "$CFG" | head -1 | cut -d: -f1 || true)
BENCH_LINE=$(grep -niE 'benchmark[ _-]?(score|eval|accuracy)|report[ _-]?accuracy|eval[ _-]?score|leaderboard' "$CFG" | head -1 | cut -d: -f1 || true)
if [ -z "$BENCH_LINE" ]; then
  echo "  ℹ No benchmark-score step in this config — decontamination ordering N/A."
elif [ -z "$DECON_LINE" ]; then
  echo "  ✗ [P0] A benchmark-score step exists but NO decontamination stage is declared."
  echo "        Fix (cross-cutting): run contamination detection (ConTAM/CoDeC) BEFORE any score is reported."
  P0=$((P0 + 1))
elif [ "$DECON_LINE" -lt "$BENCH_LINE" ]; then
  echo "  ✓ Decontamination (line $DECON_LINE) precedes benchmark-score step (line $BENCH_LINE)."
else
  echo "  ✗ [P0] Decontamination (line $DECON_LINE) declared AFTER the benchmark-score step (line $BENCH_LINE)."
  echo "        Fix (cross-cutting): move the contamination audit before the score step."
  P0=$((P0 + 1))
fi
echo ""

# ── Summary ───────────────────────────────────────────────────────────────────
echo "=== Summary ==="
if [ $P0 -eq 0 ] && [ $P1 -eq 0 ]; then
  echo "✓ PASS — no curation-config violations."
  exit 0
elif [ $P0 -eq 0 ]; then
  echo "⚠ PASS with advisories — $P1 P1 warning(s), 0 P0 blocking."
  exit 0
else
  echo "✗ FAIL — $P0 P0 blocking violation(s), $P1 P1 warning(s)."
  exit 1
fi
