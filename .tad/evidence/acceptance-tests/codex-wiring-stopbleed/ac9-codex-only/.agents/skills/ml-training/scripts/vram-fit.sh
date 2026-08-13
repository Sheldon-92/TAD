#!/usr/bin/env bash
# vram-fit.sh — Does this LoRA/QLoRA config fit the chosen GPU's VRAM budget?
#
# Usage: bash scripts/vram-fit.sh <params_billion> <method> <gpu_vram_gb>
#   params_billion : model size, e.g. 7 8 13 20 70
#   method         : qlora4 | lora8 | lora16   (also accepts unsloth-qlora4 for -30% checkpointing)
#   gpu_vram_gb    : card VRAM, e.g. 16 24 80
#
# Example: bash scripts/vram-fit.sh 8 qlora4 16   -> FITS (T4)
#          bash scripts/vram-fit.sh 8 lora16 16   -> FITS (4090 territory, tight)
#
# Numbers grounded in references/lora-finetune.md (Unsloth/2026 anchors).

set -euo pipefail

PARAMS="${1:-}"
METHOD="${2:-}"
GPU="${3:-}"

if [ -z "$PARAMS" ] || [ -z "$METHOD" ] || [ -z "$GPU" ]; then
  echo "Usage: bash scripts/vram-fit.sh <params_billion> <method:qlora4|lora8|lora16> <gpu_vram_gb>" >&2
  echo "  Example: bash scripts/vram-fit.sh 8 qlora4 16" >&2
  exit 1
fi

# Per-billion-param VRAM (GB) estimates at 7-8B baseline, scaled linearly.
# qlora4 ~6GB@7B, lora8 ~10GB@7B, lora16 ~16GB@7B.
case "$METHOD" in
  qlora4)         PER=0.80 ;;   # ~6GB / 7.5B
  unsloth-qlora4) PER=0.56 ;;   # qlora4 minus ~30% selective checkpointing
  lora8)          PER=1.33 ;;   # ~10GB / 7.5B
  lora16)         PER=2.13 ;;   # ~16GB / 7.5B
  *) echo "✗ Unknown method '$METHOD' (use qlora4|unsloth-qlora4|lora8|lora16)" >&2; exit 1 ;;
esac

# integer-safe arithmetic via awk (BSD/macOS compatible, no bc dependency)
NEED=$(awk -v p="$PARAMS" -v per="$PER" 'BEGIN { printf "%.1f", p * per }')
VERDICT=$(awk -v need="$NEED" -v gpu="$GPU" 'BEGIN { print (need <= gpu) ? "FITS" : "OVER" }')

echo "=== VRAM Fit Check ==="
echo "  model       : ${PARAMS}B"
echo "  method      : ${METHOD}"
echo "  est. VRAM   : ${NEED} GB"
echo "  GPU budget  : ${GPU} GB"
echo ""

if [ "$VERDICT" = "FITS" ]; then
  echo "✓ FITS — config fits in ${GPU}GB (need ~${NEED}GB)."
  exit 0
else
  echo "✗ OVER — need ~${NEED}GB > ${GPU}GB budget."
  echo "  Mitigations (see references/lora-finetune.md):"
  echo "   - switch to qlora4 (or unsloth-qlora4 for a further ~30% cut)"
  echo "   - use_gradient_checkpointing=\"unsloth\""
  echo "   - move to a larger card (references/platform-selection.md VRAM->card table)"
  exit 1
fi
