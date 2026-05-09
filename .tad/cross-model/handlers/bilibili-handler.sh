#!/usr/bin/env bash
# Bilibili Video Handler — extracts subtitles via yt-dlp, falls back to metadata
# Usage: bash bilibili-handler.sh video <url> <output_dir>
# Exit: 0 = success, stdout = .md path
#       1 = extraction failed
#       2 = dependency missing (yt-dlp not installed)

set -euo pipefail

mode="${1:-}"
url="${2:-}"
output_dir="${3:-/tmp/tad-preprocess}"

if [ -z "$mode" ] || [ -z "$url" ]; then
  echo "Usage: bilibili-handler.sh video <url> <output_dir>" >&2
  exit 2
fi

# Preflight: yt-dlp
if ! command -v yt-dlp >/dev/null 2>&1; then
  echo "ERROR: yt-dlp not installed. Run: brew install yt-dlp" >&2
  exit 2
fi

mkdir -p "$output_dir"

# Extract BV ID — BV followed by alphanumeric
extract_bv_id() {
  echo "$1" | grep -oE 'BV[A-Za-z0-9]+'
}

timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%SZ")

case "$mode" in
  video)
    bv_id=$(extract_bv_id "$url")
    if [ -z "$bv_id" ]; then
      # P1-3 fix: take first 8 chars after hash computation (portable md5/md5sum)
      hash=$(printf '%s' "$url" | { md5 2>/dev/null || md5sum 2>/dev/null; } | awk '{print substr($1,1,8)}')
      bv_id="unknown-${hash:-vid}"
    fi

    tmpdir="/tmp/tad-preprocess/${bv_id}"
    mkdir -p "$tmpdir"

    # Extract video metadata
    title=$(yt-dlp --print title -- "$url" 2>/dev/null || echo "")
    description=$(yt-dlp --print description -- "$url" 2>/dev/null || echo "")

    # Attempt subtitle extraction
    yt-dlp \
      --write-sub \
      --write-auto-sub \
      --sub-lang "zh-Hans,zh,en" \
      --skip-download \
      --sub-format "srt/vtt/best" \
      -o "${tmpdir}/%(id)s" \
      -- "$url" 2>/dev/null || true

    # Parse subtitles if found
    subtitle_text=""
    for sub_file in "$tmpdir"/*.srt "$tmpdir"/*.vtt; do
      [ -f "$sub_file" ] || continue
      case "$sub_file" in
        *.srt)
          # Strip sequence numbers (lines that are only digits) and timestamp lines
          subtitle_text=$(grep -vE '^[0-9]+$' "$sub_file" | grep -vE '^[0-9]{2}:[0-9]{2}:[0-9]{2}' | grep -v '^$' | tr '\n' ' ')
          ;;
        *.vtt)
          # Strip WEBVTT header and timestamp lines
          subtitle_text=$(grep -vE '^WEBVTT' "$sub_file" | grep -vE '^[0-9]{2}:[0-9]{2}:[0-9]{2}' | grep -vE '^[0-9]+$' | grep -v '^$' | tr '\n' ' ')
          ;;
      esac
      [ -n "$subtitle_text" ] && break
    done

    out_file="$output_dir/bilibili-${bv_id}.md"
    {
      echo "---"
      echo "source: bilibili"
      echo "original_url: $url"
      echo "extracted_at: $timestamp"
      echo "bv_id: $bv_id"
      echo "method: yt-dlp subtitle extraction"
      echo "---"
      echo ""
      if [ -n "$title" ]; then
        echo "# $title"
        echo ""
      fi
      if [ -n "$description" ]; then
        echo "## Description"
        echo ""
        echo "$description"
        echo ""
      fi
      if [ -n "$subtitle_text" ]; then
        echo "## Transcript"
        echo ""
        echo "$subtitle_text"
      else
        echo "## Note"
        echo ""
        echo "_No subtitles available. Metadata only._"
        echo "WARN: No subtitles available, metadata only" >&2
      fi
    } > "$out_file"

    # Cleanup temp dir
    rm -rf "$tmpdir"

    echo "$out_file"
    ;;

  *)
    echo "Usage: bilibili-handler.sh video <url> <output_dir>" >&2
    exit 2
    ;;
esac
