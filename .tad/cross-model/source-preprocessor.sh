#!/usr/bin/env bash
# Source Preprocessor — URL type detection + handler dispatch
# Subcommands:
#   detect        — read URL from stdin, output source type string
#   validate      — read URL from stdin, exit 0=valid, 1=invalid
#   dispatch <url> <notebook_id> [output_dir]  — dispatch to appropriate handler
#
# Handler exit codes (propagated to caller):
#   0  = success, stdout = local .md path
#   10 = success, stdout = remote URL for direct source add
#   1  = extraction failed (stderr has reason)
#   2  = dependency missing (stderr has install instructions)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HANDLERS_DIR="$SCRIPT_DIR/handlers"

# timeout_seconds enforces NFR1 (30s per handler)
timeout_seconds=30

# P0-1 fix: macOS ships without GNU `timeout`; prefer gtimeout (coreutils), fallback to no-op
if command -v gtimeout >/dev/null 2>&1; then
  TIMEOUT_BIN="gtimeout"
elif command -v timeout >/dev/null 2>&1; then
  TIMEOUT_BIN="timeout"
else
  TIMEOUT_BIN=""
fi

run_with_timeout() {
  if [ -n "$TIMEOUT_BIN" ]; then
    "$TIMEOUT_BIN" "$timeout_seconds" "$@"
  else
    # No timeout binary available — rely on handler-internal curl --max-time enforcement
    "$@"
  fi
}

normalize_url() {
  local url="$1"
  local base query filtered_query

  # BA-P0-2 fix: split on first '?', filter utm_* params per-param, reconstruct
  base="${url%%\?*}"
  if [[ "$url" == *"?"* ]]; then
    query="${url#*\?}"
    # Split by '&', drop params starting with utm_, rejoin surviving params
    filtered_query=$(printf '%s' "$query" | tr '&' '\n' | grep -v '^utm_' | tr '\n' '&' | sed 's/&$//')
    if [ -n "$filtered_query" ]; then
      url="${base}?${filtered_query}"
    else
      url="$base"
    fi
  fi

  # Normalize mobile prefixes
  url="${url//mobile.twitter.com/x.com}"
  url="${url//m.bilibili.com/www.bilibili.com}"
  # Normalize twitter.com → x.com
  url="${url//twitter.com/x.com}"
  # Strip trailing slash
  url="${url%/}"
  echo "$url"
}

validate_url() {
  local url="$1"
  if [[ ! "$url" =~ ^https?:// ]]; then
    echo "ERROR: URL must start with http:// or https://" >&2
    return 1
  fi
  if [[ "$url" =~ [\;\|\&\$\`\(\)\{\}] ]]; then
    echo "ERROR: URL contains unsafe characters" >&2
    return 1
  fi
  return 0
}

detect_source_type() {
  local url="$1"
  case "$url" in
    *x.com/*/articles/*)           echo "x_article" ;;
    *x.com/*/status/*)             echo "x_tweet" ;;
    *bilibili.com/video/BV*)       echo "bilibili" ;;
    *b23.tv/*)                     echo "bilibili" ;;
    *arxiv.org/pdf/*)              echo "arxiv_pdf" ;;
    *arxiv.org/abs/*)              echo "arxiv_abs" ;;
    *semanticscholar.org/paper/*)  echo "scholar" ;;
    *scholar.google.com/*)         echo "scholar" ;;
    *.substack.com/p/*)            echo "substack" ;;
    *medium.com/*)                 echo "medium" ;;
    *)                             echo "generic_web" ;;
  esac
}

cmd="${1:-}"
shift || true

case "$cmd" in
  detect)
    url=$(cat)
    norm_url=$(normalize_url "$url")
    detect_source_type "$norm_url"
    ;;

  validate)
    url=$(cat)
    norm_url=$(normalize_url "$url")
    validate_url "$norm_url"
    ;;

  dispatch)
    url="${1:-}"
    notebook_id="${2:-}"
    output_dir="${3:-/tmp/tad-preprocess}"
    if [ -z "$url" ]; then
      echo "Usage: source-preprocessor.sh dispatch <url> <notebook_id> [output_dir]" >&2
      exit 2
    fi
    norm_url=$(normalize_url "$url")
    if ! validate_url "$norm_url"; then
      exit 1
    fi
    mkdir -p "$output_dir"
    source_type=$(detect_source_type "$norm_url")
    case "$source_type" in
      x_article)
        run_with_timeout bash "$HANDLERS_DIR/x-handler.sh" article "$norm_url" "$output_dir"
        ;;
      x_tweet)
        run_with_timeout bash "$HANDLERS_DIR/x-handler.sh" tweet "$norm_url" "$output_dir"
        ;;
      bilibili)
        # Bilibili has 4-phase fallback (CC→API→yt-dlp→Jina); budget 60s instead of default 30s
        if [ -n "$TIMEOUT_BIN" ]; then
          "$TIMEOUT_BIN" 60 bash "$HANDLERS_DIR/bilibili-handler.sh" video "$norm_url" "$output_dir"
        else
          bash "$HANDLERS_DIR/bilibili-handler.sh" video "$norm_url" "$output_dir"
        fi
        ;;
      arxiv_pdf)
        # Proven direct path — return URL for source add
        echo "$norm_url"
        exit 10
        ;;
      arxiv_abs)
        run_with_timeout bash "$HANDLERS_DIR/scholar-handler.sh" arxiv "$norm_url" "$output_dir"
        ;;
      scholar)
        run_with_timeout bash "$HANDLERS_DIR/scholar-handler.sh" search "$norm_url" "$output_dir"
        ;;
      substack|medium)
        run_with_timeout bash "$HANDLERS_DIR/jina-handler.sh" "$norm_url" "$output_dir"
        ;;
      generic_web)
        # Return URL for direct-first path; caller handles Jina fallback after quality check
        echo "$norm_url"
        exit 10
        ;;
      *)
        # BA-P0-3 fix: detect/dispatch desync guard — prevents silent exit 0 with empty stdout
        echo "ERROR: unknown source_type '$source_type' — detect/dispatch out of sync" >&2
        exit 1
        ;;
    esac
    ;;

  *)
    echo "Usage: source-preprocessor.sh <detect|validate|dispatch> ..." >&2
    exit 2
    ;;
esac
