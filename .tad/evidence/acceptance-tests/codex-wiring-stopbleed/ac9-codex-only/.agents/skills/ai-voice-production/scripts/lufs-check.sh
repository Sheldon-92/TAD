#!/usr/bin/env bash
# lufs-check.sh — Deterministic platform-loudness validator (LUFS / true-peak dBTP).
# Backs the FFmpeg two-pass loudnorm mastering recipe. Asserts integrated LUFS within
# the per-platform target band and true peak <= -1 dBTP (universal across platforms).
#
# Platform target bands (integrated LUFS), source:
#   https://sone.app/blog/podcast-loudness-standards-2026-spotify-apple-youtube (retrieved 2026-06-13)
#   apple  = -16 LUFS stereo  | apple-mono = -19 LUFS mono
#   spotify= -14 LUFS (platform normalizes podcasts to -14)
#   youtube= -14 LUFS
#   ebu    = -23 LUFS (EBU R128 broadcast)
# True peak: <= -1 dBTP across all platforms.
#
# Measures integrated loudness + true peak via ffmpeg loudnorm pass-1 JSON
# (loudnorm=print_format=json). No external deps beyond ffmpeg.
#
# Usage: scripts/lufs-check.sh <platform> <audio-file> [more files...]
#        platform in: apple | apple-mono | spotify | youtube | ebu
# Exit:  0 = all files within band & TP ok ; 1 = at least one out of band ; 2 = usage / missing dep.

set -euo pipefail

TOL=1.0          # +/- LUFS tolerance band around the platform target
TP_MAX=-1.0      # max true peak, dBTP (universal)

case "${1:-}" in
  apple)      TARGET=-16.0 ;;
  apple-mono) TARGET=-19.0 ;;
  spotify)    TARGET=-14.0 ;;
  youtube)    TARGET=-14.0 ;;
  ebu)        TARGET=-23.0 ;;
  *)
    echo "Usage: $0 <apple|apple-mono|spotify|youtube|ebu> <audio-file> [more files...]" >&2
    exit 2
    ;;
esac
PLATFORM="$1"; shift

if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "ERROR: ffmpeg not found on PATH. Install via 'brew install ffmpeg'." >&2
  exit 2
fi
if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <platform> <audio-file> [more files...]" >&2
  exit 2
fi

flt() { awk "BEGIN{print ($1) ? 1 : 0}"; }

echo "Platform: ${PLATFORM} (target ${TARGET} +/- ${TOL} LUFS, TP <= ${TP_MAX} dBTP)"
overall=0
for f in "$@"; do
  echo "=== $(basename "$f") ==="
  if [ ! -f "$f" ]; then
    echo "  FAIL exists: file not found"; overall=1; continue
  fi

  # loudnorm print_format=json emits input_i (integrated LUFS) + input_tp (true peak dBTP).
  out="$(ffmpeg -hide_banner -i "$f" \
        -af "loudnorm=I=${TARGET}:TP=${TP_MAX}:LRA=11:print_format=json" \
        -f null /dev/null 2>&1 || true)"

  ilufs="$(printf '%s\n' "$out" | grep -oE '"input_i"[^,]*' | grep -oE '[-0-9.]+' | head -1 || true)"
  itp="$(printf '%s\n' "$out" | grep -oE '"input_tp"[^,]*' | grep -oE '[-0-9.]+' | head -1 || true)"

  lo="$(awk "BEGIN{print $TARGET - $TOL}")"
  hi="$(awk "BEGIN{print $TARGET + $TOL}")"

  fail=0
  if [ -n "$ilufs" ] && [ "$(flt "$ilufs >= $lo && $ilufs <= $hi")" = "1" ]; then
    echo "  PASS integrated: ${ilufs} LUFS (band ${lo}..${hi})"
  else
    echo "  FAIL integrated: ${ilufs:-?} LUFS (band ${lo}..${hi})"; fail=1
  fi

  if [ -n "$itp" ] && [ "$(flt "$itp <= $TP_MAX")" = "1" ]; then
    echo "  PASS true peak: ${itp} dBTP (need <= ${TP_MAX})"
  else
    echo "  FAIL true peak: ${itp:-?} dBTP (need <= ${TP_MAX})"; fail=1
  fi

  if [ "$fail" -eq 0 ]; then
    echo "  >>> LUFS: PASS"
  else
    echo "  >>> LUFS: FAIL — re-master with two-pass loudnorm I=${TARGET}:TP=${TP_MAX}"
    overall=1
  fi
done

exit "$overall"
