# Apple Silicon Optimization

> Hardware-specific judgment rules for Mac users. All memory numbers from research data.
> Apple Silicon uses **unified memory** (shared CPU/GPU pool), NOT discrete VRAM — the
> figures below are unified-memory footprint, the GPU-addressable share of total RAM.
> If a tool's memory footprint is not listed here, it was not measured in the research — do not guess.

---

## 16GB Memory Budget

The following tools have confirmed unified-memory measurements on Apple Silicon:

| Tool | Params | Unified Memory Usage | MPS Support | Config Required |
|---|---|---|---|---|
| VoxCPM2 | 2B | ~8GB | Yes (--device auto) | None (auto-detects MPS) |
| Qwen3-TTS Base | 1.7B | 6-8GB | Yes | `dtype=torch.float32` (MANDATORY on MPS) |
| Chatterbox | 0.5B (Llama backbone) | ~6GB | Yes | Auto float32 patch for s3tokenizer |
| Kokoro | 82M | Minimal | Yes (fallback) | `PYTORCH_ENABLE_MPS_FALLBACK=1` |
| Bark (small) | ~300M | <4GB | Yes | `SUNO_USE_SMALL_MODELS=True` |
| MLX-Audio | Varies | Native | Native MLX | No PyTorch needed |

> Source: ask-findings-summary.md §Apple Silicon (16GB) Viable Tools

### Memory Priority Order (16GB Mac)

1. **Kokoro** — safest choice, minimal footprint, leaves room for other apps
2. **Bark (small)** — <4GB, good for experimental/generative use
3. **Chatterbox** — ~6GB, good paralinguistic support
4. **Qwen3-TTS** — 6-8GB, tight fit with other apps running
5. **VoxCPM2** — ~8GB, requires closing other memory-heavy apps
6. **MLX-Audio** — native framework, efficient memory management

---

## 32GB Memory Budget

With 32GB, the main beneficiaries are:
- **VoxCPM2 (2B)** — comfortable headroom for concurrent inference
- **Qwen3-TTS 1.7B** — can run quality variant without memory pressure

Other tools already fit in 16GB — 32GB provides headroom, not new capabilities.

---

## MPS Configuration Reference

### Qwen3-TTS (CRITICAL)
```python
# MUST use float32 on MPS — float16/bfloat16 causes silent numerical errors
model = AutoModelForCausalLM.from_pretrained(
    "Qwen/Qwen3-TTS-Base",
    torch_dtype=torch.float32,  # NOT float16
    device_map="mps"
)
```
> Source: ask-findings-summary.md §Apple Silicon Viable Tools

### Chatterbox s3tokenizer Patch
Chatterbox auto-patches its `s3tokenizer` dependency to handle MPS float64→float32 conversion. No manual config needed — but verify the patch loaded:
```bash
# If you see "RuntimeError: MPS does not support float64" → s3tokenizer patch failed
# Fix: update to latest Chatterbox version or set PYTORCH_ENABLE_MPS_FALLBACK=1
```
> Source: baseline-report.md §5 Apple Silicon

### Kokoro MPS Fallback
```bash
export PYTORCH_ENABLE_MPS_FALLBACK=1
# Required for ops not yet implemented in MPS backend
# Some ops fall back to CPU — expect slower than native MPS, still faster than pure CPU
```
> Source: baseline-report.md §5

### MLX-Audio (Native Framework)
```bash
pip install mlx-audio
# Runs natively on Apple Silicon via MLX framework — no PyTorch MPS needed
# Exposes OpenAI-compatible API for easy integration
```
> Source: ask-findings-summary.md §Apple Silicon Viable Tools

---

## Decision Tree: Mac User Tool Selection

```
START: Mac Apple Silicon user
  ├── 16GB RAM?
  │   ├── Need multilingual (3+ languages)?
  │   │   └── VoxCPM2 (~8GB, close other apps) or Kokoro (minimal, EN/ZH)
  │   ├── Need voice cloning?
  │   │   └── Chatterbox (~6GB, 10s ref) or Kokoro (minimal, 15s ref)
  │   ├── Need paralinguistic expression?
  │   │   └── Chatterbox (~6GB, native [laugh]/[cough])
  │   ├── Need lowest resource usage?
  │   │   └── Kokoro (82M, minimal VRAM)
  │   ├── Need native Apple framework?
  │   │   └── MLX-Audio (no PyTorch dependency)
  │   └── CPU-only fallback?
  │       └── MeloTTS or Piper (no GPU needed)
  │
  └── 32GB RAM?
      ├── Same decision tree, but VoxCPM2 becomes comfortable default
      └── Qwen3-TTS Base runs without memory pressure
```

---

## Troubleshooting MPS Issues

| Symptom | Likely Cause | Fix |
|---|---|---|
| `RuntimeError: MPS does not support float64` | s3tokenizer or model using float64 | Set `PYTORCH_ENABLE_MPS_FALLBACK=1` or update Chatterbox |
| Silent bad output (garbled audio) | float16 on MPS | Switch to `torch.float32` |
| OOM crash | Model too large for available memory | Use smaller model variant or set `SUNO_USE_SMALL_MODELS=True` |
| `MPS backend out of memory` | Cumulative allocation | Restart Python process between long runs |
| Slow generation (worse than CPU) | MPS fallback for many ops | Check if tool has MLX-native variant |
