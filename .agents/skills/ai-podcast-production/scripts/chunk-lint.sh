#!/usr/bin/env bash
# chunk-lint.sh — Deterministic lint for the large-chunk TTS strategy (TP1/TP2/TP3).
#
# Usage: bash scripts/chunk-lint.sh <chunks-file>
#   <chunks-file>: a text file with one chunk per line, OR a directory of seg_*.wav
#
# TEXT MODE (one chunk per line): asserts every chunk is 200-350 chars (TP1),
#   warns if total chunk count is far from the ~20/episode target (TP1).
# AUDIO MODE (directory of seg_*.wav): asserts no post-cut segment is < 8 s (TP3),
#   the minimum that preserves large-chunk coherence.
#
# Exit 0 = all chunks within spec, exit 1 = at least one violation.
# This replaces "punt chunk-size judgment to Claude" with a runnable check.

set -euo pipefail

TARGET="${1:-}"
MIN_CHARS=200
MAX_CHARS=350
MIN_SEG_SEC=8

if [ -z "$TARGET" ]; then
  echo "✗ usage: chunk-lint.sh <chunks.txt | seg-dir/>" >&2
  exit 1
fi

fail=0

if [ -d "$TARGET" ]; then
  # AUDIO MODE — check seg_*.wav durations ≥ 8 s (TP3)
  if ! command -v python3 >/dev/null 2>&1; then
    echo "✗ python3 not available (needed for audio-duration mode)" >&2
    exit 1
  fi
  python3 - "$TARGET" "$MIN_SEG_SEC" <<'PY'
import sys, glob, os
seg_dir, min_sec = sys.argv[1], float(sys.argv[2])
try:
    import soundfile as sf
except ImportError as e:
    print(f"✗ missing dependency: {e} (pip install soundfile)"); sys.exit(1)
segs = sorted(glob.glob(os.path.join(seg_dir, "seg_*.wav")))
if not segs:
    print(f"✗ no seg_*.wav in {seg_dir}"); sys.exit(1)
bad = 0
for s in segs:
    info = sf.info(s)
    dur = info.frames / info.samplerate if info.samplerate else 0
    if dur < min_sec:
        print(f"  ✗ {os.path.basename(s)}: {dur:.1f}s < {min_sec}s (TP3 post-cut min)")
        bad += 1
print(f">>> {'FAIL' if bad else 'PASS'}: {len(segs)} segments, {bad} below {min_sec}s")
sys.exit(1 if bad else 0)
PY
  exit $?
fi

if [ ! -f "$TARGET" ]; then
  echo "✗ not a file or directory: $TARGET" >&2
  exit 1
fi

# TEXT MODE — char-count lint per line (TP1/TP2)
count=0
lineno=0
while IFS= read -r line || [ -n "$line" ]; do
  lineno=$((lineno + 1))
  [ -z "$line" ] && continue
  count=$((count + 1))
  # char count (handles multibyte CJK via wc -m)
  n=$(printf '%s' "$line" | wc -m | tr -d ' ')
  if [ "$n" -lt "$MIN_CHARS" ] || [ "$n" -gt "$MAX_CHARS" ]; then
    echo "  ✗ chunk $count (line $lineno): $n chars (must be $MIN_CHARS-$MAX_CHARS, TP1)"
    fail=1
  fi
done < "$TARGET"

if [ "$count" -lt 12 ] || [ "$count" -gt 30 ]; then
  echo "  ⚠ $count chunks (TP1 target ~20/episode; outside 12-30 is unusual)"
fi

if [ "$fail" -eq 0 ]; then
  echo ">>> PASS: all $count chunks within $MIN_CHARS-$MAX_CHARS chars"
else
  echo ">>> FAIL: at least one chunk outside $MIN_CHARS-$MAX_CHARS chars (TP1)"
fi
exit $fail
