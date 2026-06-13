#!/usr/bin/env bash
# cost-estimate.sh — Estimate GPU-hour cost of a fine-tune run.
#
# Usage: bash scripts/cost-estimate.sh <num_examples> <epochs> <eff_batch> <sec_per_step> <hourly_rate>
#   defaults: epochs=2 eff_batch=8 sec_per_step=3 hourly_rate=0.34 (RunPod Community 4090)
#
# Example: bash scripts/cost-estimate.sh 500
#          bash scripts/cost-estimate.sh 5000 3 16 4 2.89   # 70B-ish on H100 PCIe
#
# Formula (references/cost-estimation.md):
#   steps = ceil(num_examples * epochs / eff_batch)
#   hours = steps * sec_per_step / 3600
#   cost  = hours * hourly_rate

set -euo pipefail

N="${1:-}"
EPOCHS="${2:-2}"
BATCH="${3:-8}"
SPS="${4:-3}"
RATE="${5:-0.34}"

if [ -z "$N" ]; then
  echo "Usage: bash scripts/cost-estimate.sh <num_examples> [epochs=2] [eff_batch=8] [sec_per_step=3] [hourly_rate=0.34]" >&2
  echo "  Rate anchors (2026): 4090=0.34  A100-80=0.89  H100-PCIe=2.89  Vast-A100=0.67  Secure-A100=1.89" >&2
  exit 1
fi

awk -v n="$N" -v ep="$EPOCHS" -v b="$BATCH" -v sps="$SPS" -v rate="$RATE" 'BEGIN {
  steps = (n * ep) / b
  steps = (steps == int(steps)) ? steps : int(steps) + 1   # ceil
  hours = steps * sps / 3600
  cost  = hours * rate
  printf "=== Cost Estimate ===\n"
  printf "  examples       : %d\n", n
  printf "  epochs         : %d\n", ep
  printf "  eff batch size : %d\n", b
  printf "  sec/step       : %d\n", sps
  printf "  hourly rate    : $%.2f/hr\n\n", rate
  printf "  steps          : %d\n", steps
  printf "  est. GPU hours : %.2f hr\n", hours
  printf "  EST. COST      : $%.2f\n", cost
  if (b < 4 || b > 16)
    printf "\n   note: eff batch %d is outside recommended 4-16 (references/lora-finetune.md)\n", b
  if (ep > 3)
    printf "  note: %d epochs > 3 = diminishing returns + overfit risk\n", ep
}'
