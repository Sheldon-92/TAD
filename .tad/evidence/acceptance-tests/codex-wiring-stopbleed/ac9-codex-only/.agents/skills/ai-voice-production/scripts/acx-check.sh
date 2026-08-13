#!/usr/bin/env bash
# acx-check.sh — Deterministic ACX/Audible submission validator.
# Converts the prose ACX spec block (audiobook-pipeline.md §ACX/Audible Specifications)
# into an executable gate. ACX auto-rejects any file that misses a hard spec —
# "no manual overrides".
#
# SCOPE (honest): this script asserts the deterministically-measurable subset of the
# ACX specs from the audio signal: RMS band, sample peak < -3 dBFS, noise floor,
# sample rate, channel layout (mono OR stereo — ACX allows either, but ALL files
# must match), format/bitrate (MP3 192 kbps CBR), and head/tail room-tone duration.
# Two ACX rules remain manual: (a) the silence MUST be ROOM TONE, not digital zero —
# this script measures DURATION only, it cannot tell room tone from absolute silence;
# (b) cross-file channel/format consistency is enforced across the batch you pass.
#
# Source of thresholds: https://help.acx.com/s/article/what-are-the-acx-audio-submission-requirements (retrieved 2026-06-13)
# Wraps ffmpeg volumedetect (RMS / sample-peak) + astats (noise floor) + ffprobe-free banner parse (rate/channels/codec/bitrate) + silencedetect (head/tail).
#
# Usage: scripts/acx-check.sh final/ch-001.mp3 [more files...]
# Exit:  0 = all files PASS every checked ACX spec ; 1 = at least one spec FAIL ; 2 = usage / missing dep.

set -euo pipefail

# --- ACX hard specs (auto-reject thresholds) ---
RMS_MIN=-23.0          # RMS floor, dBFS  (ACX: -23 to -18)
RMS_MAX=-18.0          # RMS ceiling, dBFS
PEAK_MAX=-3.0          # sample-peak ceiling, dBFS (ACX: peak below -3 dBFS — sample peak, NOT dBTP)
NOISE_FLOOR_MAX=-60.0  # noise floor, dBFS (ACX: below -60)
SAMPLE_RATE=44100      # Hz (ACX: 44.1 kHz)
MP3_BITRATE=192        # kbps (ACX: MP3 192 kbps CBR)
HEAD_MIN=0.5           # s — room tone at head (ACX: 0.5-1.0 s)
HEAD_MAX=1.0           # s
TAIL_MIN=1.0           # s — room tone at tail (ACX: 1.0-5.0 s)
TAIL_MAX=5.0           # s
SILENCE_THRESH=-50     # dB — silencedetect floor for head/tail room-tone detection

if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "ERROR: ffmpeg not found on PATH. Install via 'brew install ffmpeg'." >&2
  exit 2
fi
if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <audio-file> [more files...]" >&2
  exit 2
fi

# float compare without bc dependency: awk returns "1" if true.
flt() { awk "BEGIN{print ($1) ? 1 : 0}"; }

overall=0
for f in "$@"; do
  echo "=== $(basename "$f") ==="
  if [ ! -f "$f" ]; then
    echo "  FAIL exists: file not found"
    overall=1
    continue
  fi

  # astats gives per-stream RMS + noise floor; ffprobe-free channel/rate/codec/bitrate via ffmpeg banner.
  stats="$(ffmpeg -hide_banner -i "$f" -af "astats=metadata=1:reset=0,ametadata=print" -f null /dev/null 2>&1 || true)"
  vol="$(ffmpeg -hide_banner -i "$f" -af "volumedetect" -f null /dev/null 2>&1 || true)"
  probe="$(ffmpeg -hide_banner -i "$f" -f null /dev/null 2>&1 || true)"
  # silencedetect at -50 dB: leading window from t=0 = head room tone; trailing window to EOF = tail.
  sil="$(ffmpeg -hide_banner -i "$f" -af "silencedetect=noise=${SILENCE_THRESH}dB:d=0.3" -f null /dev/null 2>&1 || true)"
  dur="$(printf '%s\n' "$probe" | grep -oE 'Duration: [0-9:.]+' | head -1 | grep -oE '[0-9]+:[0-9]+:[0-9.]+' | awk -F: '{print ($1*3600)+($2*60)+$3}' || true)"

  rms="$(printf '%s\n' "$vol" | grep -oE 'mean_volume: [-0-9.]+' | grep -oE '[-0-9.]+' | head -1 || true)"
  peak="$(printf '%s\n' "$vol" | grep -oE 'max_volume: [-0-9.]+' | grep -oE '[-0-9.]+' | head -1 || true)"
  # astats via ametadata prints "lavfi.astats.Overall.Noise_floor=-NN.nn"; prefer Overall, fall back to per-channel.
  noise="$(printf '%s\n' "$stats" | grep -E 'astats\.Overall\.Noise_floor=' | grep -oE '=[-0-9.]+' | grep -oE '[-0-9.]+' | head -1 || true)"
  if [ -z "$noise" ]; then
    noise="$(printf '%s\n' "$stats" | grep -E 'Noise_floor=' | grep -oE '=[-0-9.]+' | grep -oE '[-0-9.]+' | head -1 || true)"
  fi
  rate="$(printf '%s\n' "$probe" | grep -oE '[0-9]+ Hz' | grep -oE '[0-9]+' | head -1 || true)"
  ch="$(printf '%s\n' "$probe" | grep -oE 'Hz, (mono|stereo|[0-9.]+ channels)' | head -1 || true)"
  # codec + bitrate from the AUDIO STREAM line only: "Stream #0:0: Audio: mp3 ... 192 kb/s".
  # MUST scope to the Audio: line — the container "Duration: ... bitrate: NNN kb/s" header line
  # reports a SLIGHTLY HIGHER muxed-overhead figure (e.g. 194) and would false-FAIL a true 192k stream.
  aline="$(printf '%s\n' "$probe" | grep -E 'Stream #.*Audio:' | head -1 || true)"
  codec="$(printf '%s\n' "$aline" | grep -oE 'Audio: [a-z0-9]+' | head -1 | awk '{print $2}' || true)"
  kbps="$(printf '%s\n' "$aline" | grep -oE '[0-9]+ kb/s' | grep -oE '[0-9]+' | head -1 || true)"

  fail=0

  # Spec #1 — Format: MP3, 192 kbps. (CBR vs VBR is not detectable from the banner; a 192-kbps
  # nominal reading + the libmp3lame -b:a 192k recipe in audiobook-pipeline.md yields CBR.)
  if [ "${codec:-}" = "mp3" ] && [ "${kbps:-0}" = "$MP3_BITRATE" ]; then
    echo "  PASS format: mp3 ${kbps} kb/s (need mp3 ${MP3_BITRATE} kbps CBR)"
  else
    echo "  FAIL format: ${codec:-?} ${kbps:-?} kb/s (need mp3 ${MP3_BITRATE} kbps CBR — VBR is rejected even if avg=192)"; fail=1
  fi

  # Spec #4 — RMS in [-23, -18]
  if [ -n "$rms" ] && [ "$(flt "$rms >= $RMS_MIN && $rms <= $RMS_MAX")" = "1" ]; then
    echo "  PASS RMS: ${rms} dBFS (need ${RMS_MIN}..${RMS_MAX})"
  else
    echo "  FAIL RMS: ${rms:-?} dBFS (need ${RMS_MIN}..${RMS_MAX})"; fail=1
  fi

  # Spec #5 — Sample peak < -3 dBFS (this is SAMPLE peak via volumedetect max_volume, NOT dBTP;
  # ACX's "-3 dB peak" is a sample-peak spec. For genuine dBTP use lufs-check.sh input_tp.)
  if [ -n "$peak" ] && [ "$(flt "$peak < $PEAK_MAX")" = "1" ]; then
    echo "  PASS sample peak: ${peak} dBFS (need < ${PEAK_MAX})"
  else
    echo "  FAIL sample peak: ${peak:-?} dBFS (need < ${PEAK_MAX})"; fail=1
  fi

  # Spec #6 — Noise floor < -60
  if [ -n "$noise" ] && [ "$(flt "$noise < $NOISE_FLOOR_MAX")" = "1" ]; then
    echo "  PASS noise floor: ${noise} dBFS (need < ${NOISE_FLOOR_MAX})"
  else
    echo "  FAIL noise floor: ${noise:-unmeasured} dBFS (need < ${NOISE_FLOOR_MAX})"; fail=1
  fi

  # Spec #2 — Sample rate 44.1kHz
  if [ "${rate:-0}" = "$SAMPLE_RATE" ]; then
    echo "  PASS sample rate: ${rate} Hz"
  else
    echo "  FAIL sample rate: ${rate:-?} Hz (need ${SAMPLE_RATE})"; fail=1
  fi

  # Spec #3 — Channels: ACX allows ALL-mono OR ALL-stereo. Accept either layout per-file;
  # cross-file consistency is checked across the batch (BATCH_CH) below.
  this_ch=""
  if printf '%s' "$ch" | grep -q 'mono'; then this_ch="mono"
  elif printf '%s' "$ch" | grep -q 'stereo'; then this_ch="stereo"; fi
  if [ -n "$this_ch" ]; then
    echo "  PASS channels: ${this_ch} (ACX allows all-mono OR all-stereo)"
    if [ -z "${BATCH_CH:-}" ]; then
      BATCH_CH="$this_ch"
    elif [ "$BATCH_CH" != "$this_ch" ]; then
      echo "  FAIL channels: ${this_ch} — mixed with earlier ${BATCH_CH}; ALL files must share one layout"; fail=1
    fi
  else
    echo "  FAIL channels: ${ch:-?} (ACX requires all-mono OR all-stereo)"; fail=1
  fi

  # Spec #7 — Head room tone 0.5-1.0 s. silencedetect: a silence_start at ~0 whose matching
  # silence_duration falls in band = compliant head room tone.
  head_sil="$(printf '%s\n' "$sil" | grep -A1 'silence_start: 0' | grep -oE 'silence_duration: [0-9.]+' | grep -oE '[0-9.]+' | head -1 || true)"
  if [ -n "$head_sil" ] && [ "$(flt "$head_sil >= $HEAD_MIN && $head_sil <= $HEAD_MAX")" = "1" ]; then
    echo "  PASS head silence: ${head_sil}s (need ${HEAD_MIN}-${HEAD_MAX}s room tone)"
  else
    echo "  FAIL head silence: ${head_sil:-none@0s} (need ${HEAD_MIN}-${HEAD_MAX}s room tone at start)"; fail=1
  fi

  # Spec #8 — Tail room tone 1.0-5.0 s. Find the last silence segment and require it to end at EOF.
  tail_start="$(printf '%s\n' "$sil" | grep -oE 'silence_start: [0-9.]+' | tail -1 | grep -oE '[0-9.]+' || true)"
  tail_sil="$(printf '%s\n' "$sil" | grep -oE 'silence_duration: [0-9.]+' | tail -1 | grep -oE '[0-9.]+' || true)"
  if [ -n "$tail_sil" ] && [ -n "$tail_start" ] && [ -n "$dur" ] \
     && [ "$(flt "($tail_start + $tail_sil) >= ($dur - 0.3)")" = "1" ] \
     && [ "$(flt "$tail_sil >= $TAIL_MIN && $tail_sil <= $TAIL_MAX")" = "1" ]; then
    echo "  PASS tail silence: ${tail_sil}s (need ${TAIL_MIN}-${TAIL_MAX}s room tone)"
  else
    echo "  FAIL tail silence: ${tail_sil:-none}@${tail_start:-?} (need ${TAIL_MIN}-${TAIL_MAX}s room tone ending at EOF)"; fail=1
  fi

  if [ "$fail" -eq 0 ]; then
    echo "  >>> ACX: PASS"
  else
    echo "  >>> ACX: FAIL (ACX auto-rejects on ANY failed spec — no manual override)"
    overall=1
  fi
done

exit "$overall"
