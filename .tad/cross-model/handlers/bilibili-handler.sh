#!/usr/bin/env bash
# Bilibili Video Handler — 4-phase fallback: CC subs → B站API → yt-dlp metadata → Jina
# Usage: bash bilibili-handler.sh video <url> <output_dir>
# Exit: 0 = success (local .md path on stdout)
#       1 = extraction failed
#       2 = dependency missing (yt-dlp, jq, or curl not installed)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mode="${1:-}"
url="${2:-}"
output_dir="${3:-/tmp/tad-preprocess}"

if [ -z "$mode" ] || [ -z "$url" ]; then
  echo "Usage: bilibili-handler.sh video <url> <output_dir>" >&2
  exit 2
fi

# Preflight: yt-dlp, jq, curl all required [CR-P0-4]
if ! command -v yt-dlp >/dev/null 2>&1; then
  echo "ERROR: yt-dlp not installed. Run: brew install yt-dlp" >&2; exit 2
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: jq not installed. Run: brew install jq" >&2; exit 2
fi
if ! command -v curl >/dev/null 2>&1; then
  echo "ERROR: curl not installed. Run: brew install curl" >&2; exit 2
fi

mkdir -p "$output_dir"

timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date +"%Y-%m-%dT%H:%M:%SZ")

# Extract BV ID — BV followed by alphanumeric characters
extract_bv_id() {
  printf '%s' "$1" | grep -oE 'BV[A-Za-z0-9]+'
}

# Initialize tmpdir for EXIT trap (may be set in case arm below)
tmpdir=""

case "$mode" in
  video)
    # Resolve b23.tv short URLs [BA-P2-1]
    if [[ "$url" == *"b23.tv"* ]]; then
      resolved=$(curl -sL --connect-timeout 5 --max-time 10 \
        -o /dev/null -w '%{url_effective}' "$url" 2>/dev/null || true)
      [ -n "$resolved" ] && [ "$resolved" != "$url" ] && url="$resolved"
    fi

    bv_id=$(extract_bv_id "$url" || true)
    if [ -z "$bv_id" ]; then
      hash=$(printf '%s' "$url" | { md5 2>/dev/null || md5sum 2>/dev/null; } | awk '{print substr($1,1,8)}')
      bv_id="unknown-${hash:-vid}"
    fi

    tmpdir="/tmp/tad-preprocess/${bv_id}"
    mkdir -p "$tmpdir"
    trap '[ -n "${tmpdir:-}" ] && rm -rf "$tmpdir" 2>/dev/null; true' EXIT

    out_file="$output_dir/bilibili-${bv_id}.md"
    title=""
    description=""
    subtitle_text=""

    # ────────────────────────────────────────────────────────────────
    # Phase A: yt-dlp CC subtitle extraction (consolidated single call) [FR8]
    # --no-playlist BEFORE -- separator [CR-P0-2]
    # --print title + --print description in same invocation (no --write-auto-sub)
    # ────────────────────────────────────────────────────────────────
    yt-dlp \
      --write-sub \
      --no-playlist \
      --sub-lang "zh-Hans,zh,en" \
      --skip-download \
      --sub-format "srt/vtt/best" \
      --print title \
      --print description \
      -o "${tmpdir}/%(id)s" \
      -- "$url" > "${tmpdir}/yt-print.txt" 2>/dev/null || true

    # Parse --print output: line 1 = title, lines 2+ = description
    if [ -s "${tmpdir}/yt-print.txt" ]; then
      title=$(head -1 "${tmpdir}/yt-print.txt" | tr -d '\r' || true)
      description=$(tail -n +2 "${tmpdir}/yt-print.txt" | tr -d '\r' | head -20 || true)
    fi

    # Parse CC subtitle files if found (no auto-subs)
    for sub_file in "$tmpdir"/*.srt "$tmpdir"/*.vtt; do
      [ -f "$sub_file" ] || continue
      case "$sub_file" in
        *.srt)
          subtitle_text=$(grep -vE '^[0-9]+$' "$sub_file" \
            | grep -vE '^[0-9]{2}:[0-9]{2}:[0-9]{2}' \
            | grep -v '^$' \
            | tr '\n' ' ' || true)
          ;;
        *.vtt)
          subtitle_text=$(grep -vE '^WEBVTT' "$sub_file" \
            | grep -vE '^[0-9]{2}:[0-9]{2}:[0-9]{2}' \
            | grep -vE '^[0-9]+$' \
            | grep -v '^$' \
            | tr '\n' ' ' || true)
          ;;
      esac
      [ -n "$subtitle_text" ] && break
    done

    if [ -n "$subtitle_text" ]; then
      {
        printf '%s\n' "---"
        printf 'source: bilibili\n'
        printf 'original_url: %s\n' "$url"
        printf 'extracted_at: %s\n' "$timestamp"
        printf 'bv_id: %s\n' "$bv_id"
        printf 'method: yt-dlp-cc-subtitles\n'
        printf '%s\n' "---"
        printf '\n'
        [ -n "$title" ] && printf '# %s\n\n' "$title"
        [ -n "$description" ] && printf '## Description\n\n%s\n\n' "$description"
        printf '## Transcript\n\n%s\n' "$subtitle_text"
      } > "$out_file"
      printf '%s\n' "$out_file"
      exit 0
    fi
    echo "INFO: Phase A (CC subs): no subtitles found" >&2

    # ────────────────────────────────────────────────────────────────
    # Phase A.5: Optional cookies-from-browser [BA-P0-3, FR10]
    # Enabled only when TAD_BILIBILI_BROWSER env var is set (e.g., safari, chrome)
    # ────────────────────────────────────────────────────────────────
    if [ -n "${TAD_BILIBILI_BROWSER:-}" ]; then
      yt-dlp \
        --cookies-from-browser "$TAD_BILIBILI_BROWSER" \
        --write-sub \
        --no-playlist \
        --sub-lang "zh-Hans,zh,en" \
        --skip-download \
        --sub-format "srt/vtt/best" \
        -o "${tmpdir}/cookie-%(id)s" \
        -- "$url" 2>/dev/null || true

      subtitle_text=""
      for sub_file in "$tmpdir"/cookie-*.srt "$tmpdir"/cookie-*.vtt; do
        [ -f "$sub_file" ] || continue
        case "$sub_file" in
          *.srt)
            subtitle_text=$(grep -vE '^[0-9]+$' "$sub_file" \
              | grep -vE '^[0-9]{2}:[0-9]{2}:[0-9]{2}' \
              | grep -v '^$' \
              | tr '\n' ' ' || true)
            ;;
          *.vtt)
            subtitle_text=$(grep -vE '^WEBVTT' "$sub_file" \
              | grep -vE '^[0-9]{2}:[0-9]{2}:[0-9]{2}' \
              | grep -vE '^[0-9]+$' \
              | grep -v '^$' \
              | tr '\n' ' ' || true)
            ;;
        esac
        [ -n "$subtitle_text" ] && break
      done

      if [ -n "$subtitle_text" ]; then
        {
          printf '%s\n' "---"
          printf 'source: bilibili\n'
          printf 'original_url: %s\n' "$url"
          printf 'extracted_at: %s\n' "$timestamp"
          printf 'bv_id: %s\n' "$bv_id"
          printf 'method: yt-dlp-cookies-subtitles\n'
          printf '%s\n' "---"
          printf '\n'
          [ -n "$title" ] && printf '# %s\n\n' "$title"
          [ -n "$description" ] && printf '## Description\n\n%s\n\n' "$description"
          printf '## Transcript\n\n%s\n' "$subtitle_text"
        } > "$out_file"
        printf '%s\n' "$out_file"
        exit 0
      fi
      echo "INFO: Phase A.5 (cookies-from-browser: $TAD_BILIBILI_BROWSER): no subtitles" >&2
    fi

    # ────────────────────────────────────────────────────────────────
    # Phase B: B站 API metadata — fast (~200ms) [BA-P0-1 reorder: API before yt-dlp]
    # Parse via jq, write via printf '%s\n' (no echo for user content) [CR-P0-1]
    # ────────────────────────────────────────────────────────────────
    if [[ "$bv_id" != unknown-* ]]; then
      api_json=$(curl -sf --connect-timeout 5 --max-time 10 \
        "https://api.bilibili.com/x/web-interface/view?bvid=${bv_id}" \
        2>/dev/null || true)
      if [ -n "$api_json" ]; then
        api_code=$(printf '%s' "$api_json" | jq -r '.code // -1' 2>/dev/null || echo "-1")
        if [ "$api_code" = "0" ]; then
          api_title=$(printf '%s' "$api_json" | jq -r '.data.title // ""' 2>/dev/null || true)
          if [ -n "$api_title" ]; then
            api_desc=$(printf '%s' "$api_json" | jq -r '.data.desc // ""' 2>/dev/null || true)
            api_owner=$(printf '%s' "$api_json" | jq -r '.data.owner.name // ""' 2>/dev/null || true)
            api_view=$(printf '%s' "$api_json" | jq -r '.data.stat.view // ""' 2>/dev/null || true)
            api_tags=$(printf '%s' "$api_json" | jq -r '[.data.tag[]?.tag_name // empty] | join(", ")' 2>/dev/null || true)
            {
              printf '%s\n' "---"
              printf 'source: bilibili\n'
              printf 'original_url: %s\n' "$url"
              printf 'extracted_at: %s\n' "$timestamp"
              printf 'bv_id: %s\n' "$bv_id"
              printf 'method: bilibili-api\n'
              printf '%s\n' "---"
              printf '\n'
              printf '# %s\n\n' "$api_title"
              [ -n "$api_owner" ] && printf '**UP主**: %s\n' "$api_owner"
              [ -n "$api_view" ]  && printf '**播放量**: %s\n' "$api_view"
              [ -n "$api_tags" ]  && printf '**标签**: %s\n\n' "$api_tags"
              if [ -n "$api_desc" ]; then
                printf '## Description\n\n'
                printf '%s\n' "$api_desc"
                printf '\n'
              fi
            } > "$out_file"
            printf '%s\n' "$out_file"
            exit 0
          fi
        fi
        echo "INFO: Phase B (B站 API): code=${api_code} (地域限制或稿件不可见)" >&2
      else
        echo "INFO: Phase B (B站 API): no response from api.bilibili.com" >&2
      fi
    else
      echo "INFO: Phase B (B站 API): skipped (unknown bv_id)" >&2
    fi

    # ────────────────────────────────────────────────────────────────
    # Phase C: yt-dlp metadata retry — slow (~5-10s)
    # Only retry if Phase A returned empty title+description [CR-P1-1]
    # Empty title+description guard: fall through to Phase D (NOT exit 0)
    # ────────────────────────────────────────────────────────────────
    if [ -z "$title" ] && [ -z "$description" ]; then
      echo "INFO: Phase C (yt-dlp metadata): retrying metadata extraction" >&2
      yt_meta=$(yt-dlp --print title --print description --no-playlist \
        -- "$url" 2>/dev/null || true)
      if [ -n "$yt_meta" ]; then
        title=$(printf '%s' "$yt_meta" | head -1 | tr -d '\r' || true)
        description=$(printf '%s' "$yt_meta" | tail -n +2 | tr -d '\r' | head -20 || true)
      fi
    fi

    # Phase C exit: if we have at least title or description, write .md [CR-P1-1]
    if [ -n "$title" ] || [ -n "$description" ]; then
      {
        printf '%s\n' "---"
        printf 'source: bilibili\n'
        printf 'original_url: %s\n' "$url"
        printf 'extracted_at: %s\n' "$timestamp"
        printf 'bv_id: %s\n' "$bv_id"
        printf 'method: yt-dlp-metadata\n'
        printf '%s\n' "---"
        printf '\n'
        [ -n "$title" ] && printf '# %s\n\n' "$title"
        if [ -n "$description" ]; then
          printf '## Description\n\n'
          printf '%s\n' "$description"
          printf '\n'
        fi
        printf '## Note\n\n_No subtitles available. Metadata only._\n'
      } > "$out_file"
      printf '%s\n' "$out_file"
      exit 0
    fi
    echo "INFO: Phase C (yt-dlp metadata): empty title+description — falling through to Phase D" >&2

    # ────────────────────────────────────────────────────────────────
    # Phase D: Jina Reader fallback [FR3, CR-P0-3]
    # Use SCRIPT_DIR for reliable path resolution (not bare jina-handler.sh)
    # method: jina-reader-fallback (jina-handler.sh writes its own frontmatter)
    # ────────────────────────────────────────────────────────────────
    echo "INFO: Phase D (Jina Reader): jina-reader-fallback for $url" >&2
    if jina_path=$(bash "$SCRIPT_DIR/jina-handler.sh" "$url" "$output_dir" 2>/dev/null); then
      printf '%s\n' "$jina_path"
      exit 0
    fi
    echo "ERROR: All phases failed (A: no CC subs, B: API geo-restricted, C: empty metadata, D: Jina failed)" >&2
    exit 1
    ;;

  *)
    echo "Usage: bilibili-handler.sh video <url> <output_dir>" >&2
    exit 2
    ;;
esac
