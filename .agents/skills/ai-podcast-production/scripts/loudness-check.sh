#!/usr/bin/env bash
# loudness-check.sh — Deterministic loudness / peak / LRA verifier for podcast audio.
#
# Usage: bash scripts/loudness-check.sh <audio.wav> [platform]
#   platform ∈ apple_stereo | apple_mono | spotify | youtube | amazon | google
#   default platform = spotify (-14 LUFS), the multi-platform default per TP7a.
#
# Asserts (per references/tts-production.md TP7a/TP7c):
#   - integrated loudness within ±1.0 LU of the per-platform target   [pyloudnorm, measured]
#   - LRA in the 5-15 LU band (EBU Tech 3342, spoken word)            [pyloudnorm, measured]
#   - SAMPLE peak ≤ -1.0 dBFS                                          [proxy lower-bound]
#
# IMPORTANT — what this script does and does NOT measure:
#   pyloudnorm implements ITU-R BS.1770-4 integrated loudness and EBU Tech 3342 LRA.
#   It has NO true-peak (dBTP) meter — `normalize.peak` is a sample-peak scaler
#   (np.max(np.abs)). So the peak assertion here is a SAMPLE-peak lower bound at
#   -1 dBFS, a conservative proxy for the platform -1 dBTP target, NOT a measured
#   true-peak. For a real dBTP guarantee this script will use `ffmpeg ebur128=peak=true`
#   when ffmpeg is on PATH; otherwise it reports the sample-peak proxy and SAYS SO.
#
# Exit 0 = PASS, exit 1 = out of spec / measurement error / a required check could
#          not be measured (LRA skip is a FAIL, not a silent pass).

set -euo pipefail

AUDIO="${1:-}"
PLATFORM="${2:-spotify}"

if [ -z "$AUDIO" ]; then
  echo "✗ usage: loudness-check.sh <audio.wav> [platform]" >&2
  exit 1
fi
if [ ! -f "$AUDIO" ]; then
  echo "✗ file not found: $AUDIO" >&2
  exit 1
fi
if ! command -v python3 >/dev/null 2>&1; then
  echo "✗ python3 not available" >&2
  exit 1
fi

# Measure TRUE-peak (dBTP) with ffmpeg's oversampling EBU R128 meter if available.
# pyloudnorm cannot do this; ffmpeg ebur128=peak=true can. Empty = ffmpeg absent.
TRUE_PEAK_DBTP=""
if command -v ffmpeg >/dev/null 2>&1; then
  # ebur128 prints a summary block ending with "Peak: <value> dBFS" (true-peak when peak=true).
  TRUE_PEAK_DBTP="$(ffmpeg -nostats -i "$AUDIO" -af ebur128=peak=true -f null - 2>&1 \
    | grep -i 'Peak:' | tail -1 | grep -oE '\-?[0-9]+(\.[0-9]+)?' | tail -1 || true)"
fi

python3 - "$AUDIO" "$PLATFORM" "${TRUE_PEAK_DBTP:-}" <<'PY'
import sys

audio_path, platform = sys.argv[1], sys.argv[2]
true_peak_arg = sys.argv[3] if len(sys.argv) > 3 else ""

# Per-platform integrated-loudness targets (LUFS) — must match TP7a.
TARGETS = {
    "apple_stereo": -16.0,
    "apple_mono":   -19.0,
    "spotify":      -14.0,
    "youtube":      -14.0,
    "amazon":       -14.0,
    "google":       -14.0,
}
PEAK_CEILING = -1.0   # dBFS sample-peak proxy; also the dBTP ceiling Apple cites (BS.1770-5)
LRA_MIN, LRA_MAX = 5.0, 15.0   # EBU Tech 3342 spoken-word band
LUFS_TOL = 1.0             # Apple ±1 dB tolerance

if platform not in TARGETS:
    print(f"✗ unknown platform '{platform}' (expected: {', '.join(TARGETS)})")
    sys.exit(1)
target = TARGETS[platform]

try:
    import numpy as np
    import soundfile as sf
    import pyloudnorm as pyln
except ImportError as e:
    print(f"✗ missing dependency: {e} (pip install soundfile pyloudnorm numpy)")
    sys.exit(1)

data, rate = sf.read(audio_path)
meter = pyln.Meter(rate)                       # ITU-R BS.1770-4 (integrated loudness)
loudness = meter.integrated_loudness(data)

# Sample peak (pyloudnorm has NO true-peak meter; np.max(np.abs) is a sample peak).
sample_peak_lin = float(np.max(np.abs(data))) if data.size else 0.0
sample_peak_db = 20.0 * np.log10(sample_peak_lin) if sample_peak_lin > 0 else -120.0

# True peak (dBTP) from ffmpeg ebur128=peak=true if the bash wrapper measured one.
true_peak_db = None
if true_peak_arg.strip():
    try:
        true_peak_db = float(true_peak_arg)
    except ValueError:
        true_peak_db = None

# LRA per EBU Tech 3342 — pyloudnorm exposes Meter.loudness_range(). This is a REQUIRED
# measurement: if it cannot be produced we FAIL (no silent PASS-on-skip).
lra = None
lra_error = None
try:
    lra = meter.loudness_range(data)
except Exception as e:                          # pragma: no cover (defensive)
    lra_error = str(e)

fails = []
ok = "✓"; bad = "✗"

lufs_pass = abs(loudness - target) <= LUFS_TOL
print(f"{ok if lufs_pass else bad} integrated loudness {loudness:.2f} LUFS "
      f"(target {target} ±{LUFS_TOL})  [BS.1770-4, measured]")
if not lufs_pass: fails.append("loudness")

# Peak: prefer the real dBTP (ffmpeg) when available; otherwise sample-peak proxy.
if true_peak_db is not None:
    tp_pass = true_peak_db <= PEAK_CEILING + 0.05
    print(f"{ok if tp_pass else bad} true-peak {true_peak_db:.2f} dBTP "
          f"(ceiling {PEAK_CEILING} dBTP)  [ffmpeg ebur128 peak=true, measured]")
    if not tp_pass: fails.append("true-peak")
else:
    sp_pass = sample_peak_db <= PEAK_CEILING + 0.05
    print(f"{ok if sp_pass else bad} sample-peak {sample_peak_db:.2f} dBFS "
          f"(ceiling {PEAK_CEILING} dBFS)  [proxy — pyloudnorm has no true-peak meter; "
          f"install ffmpeg for a real dBTP check]")
    if not sp_pass: fails.append("sample-peak")

if lra is not None:
    lra_pass = LRA_MIN <= lra <= LRA_MAX
    print(f"{ok if lra_pass else bad} LRA {lra:.2f} LU (band {LRA_MIN}-{LRA_MAX})  "
          f"[EBU Tech 3342, measured]")
    if not lra_pass: fails.append("LRA")
else:
    print(f"{bad} LRA could not be measured ({lra_error or 'unknown'}) — REQUIRED check failed")
    fails.append("LRA-unmeasured")

if fails:
    print(f">>> FAIL: {', '.join(fails)} out of spec for platform={platform}")
    sys.exit(1)
print(f">>> PASS: {platform} loudness spec met")
PY
