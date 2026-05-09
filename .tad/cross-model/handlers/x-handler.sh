#!/usr/bin/env bash
# X/Twitter Content Handler — extracts article or tweet/thread content via twitterapi.io
# Usage: bash x-handler.sh article <url> <output_dir>
#        bash x-handler.sh tweet   <url> <output_dir>
# Exit: 0 = success, stdout = .md path
#       1 = extraction failed (rate limit, HTTP error, parse error)
#       2 = dependency missing (API key not found, jq not installed)

set -euo pipefail

mode="${1:-}"
url="${2:-}"
output_dir="${3:-/tmp/tad-preprocess}"

if [ -z "$mode" ] || [ -z "$url" ]; then
  echo "Usage: x-handler.sh <article|tweet> <url> <output_dir>" >&2
  exit 2
fi

# Preflight: API key
KEY_FILE="$HOME/.openclaw/workspace/data/twitterapi.key"
if [ ! -r "$KEY_FILE" ]; then
  echo "ERROR: Twitter API key not found at $KEY_FILE" >&2
  echo "Create the file with your twitterapi.io API key to use X/Twitter extraction." >&2
  exit 2
fi
API_KEY=$(tr -d '\r\n' < "$KEY_FILE")

# Preflight: jq
if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: jq not installed. Run: brew install jq" >&2
  exit 2
fi

mkdir -p "$output_dir"

# Extract tweet_id from URL — last numeric segment in /status/DIGITS path
extract_tweet_id() {
  # Handle both /status/DIGITS (tweet URLs) and /articles/DIGITS (article URLs)
  echo "$1" | grep -oE '/(status|articles)/[0-9]+' | grep -oE '[0-9]+'
}

# Generate ISO timestamp
timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%SZ")

handle_http_error() {
  local http_code="$1"
  if [ "$http_code" = "429" ]; then
    echo "ERROR: Rate limited by twitterapi.io. Wait and retry." >&2
    exit 1
  elif [ "$http_code" = "402" ] || [ "$http_code" = "403" ]; then
    echo "ERROR: API credits may be exhausted or access denied (HTTP $http_code)." >&2
    exit 1
  elif [ "${http_code:-0}" -ge 400 ] 2>/dev/null; then
    echo "ERROR: twitterapi.io returned HTTP $http_code" >&2
    exit 1
  fi
}

case "$mode" in
  article)
    tweet_id=$(extract_tweet_id "$url")
    if [ -z "$tweet_id" ]; then
      echo "ERROR: Could not extract tweet_id from URL: $url" >&2
      exit 1
    fi

    response=$(curl -s --connect-timeout 10 --max-time 25 -w "\n%{http_code}" \
      -H "X-API-Key: ${API_KEY}" \
      -- "https://api.twitterapi.io/twitter/article?tweet_id=${tweet_id}" \
      2>/dev/null)
    http_code=$(echo "$response" | tail -1)
    body=$(echo "$response" | sed '$d')
    handle_http_error "$http_code"

    # P0-1 fix: API returns .contents (plural) not .content
    # P1-3 fix: printf '%s\n' avoids echo backslash interpretation
    md_content=$(printf '%s\n' "$body" | jq -r '
      .data.article.contents // .article.contents // .contents // .data.article.content // .article.content // .content // [] |
      .[] |
      if .type == "unstyled" then (.text // "")
      elif .type == "header-one" then "# " + (.text // "")
      elif .type == "header-two" then "## " + (.text // "")
      elif .type == "header-three" then "### " + (.text // "")
      elif .type == "unordered-list-item" then "- " + (.text // "")
      elif .type == "ordered-list-item" then "1. " + (.text // "")
      elif .type == "atomic" then "![](" + (.data.src // "") + ")"
      else (.text // "")
      end
    ' 2>/dev/null)

    if [ -z "$md_content" ]; then
      echo "ERROR: No content blocks found in API response" >&2
      exit 1
    fi

    out_file="$output_dir/x-article-${tweet_id}.md"
    {
      echo "---"
      echo "source: x-article"
      echo "original_url: $url"
      echo "extracted_at: $timestamp"
      echo "tweet_id: $tweet_id"
      echo "method: twitterapi.io /twitter/article"
      echo "---"
      echo ""
      echo "$md_content"
    } > "$out_file"

    echo "$out_file"
    ;;

  tweet)
    tweet_id=$(extract_tweet_id "$url")
    if [ -z "$tweet_id" ]; then
      echo "ERROR: Could not extract tweet_id from URL: $url" >&2
      exit 1
    fi

    # Fetch main tweet
    response=$(curl -s --connect-timeout 10 --max-time 25 -w "\n%{http_code}" \
      -H "X-API-Key: ${API_KEY}" \
      -- "https://api.twitterapi.io/twitter/tweets?tweet_ids=${tweet_id}" \
      2>/dev/null)
    http_code=$(echo "$response" | tail -1)
    body=$(echo "$response" | sed '$d')
    handle_http_error "$http_code"

    # P1-3 fix: printf to avoid echo backslash interpretation
    tweet_text=$(printf '%s\n' "$body" | jq -r '.data[0].full_text // .data[0].text // .tweets[0].full_text // .tweets[0].text // ""' 2>/dev/null)
    if [ -z "$tweet_text" ]; then
      echo "ERROR: No tweet text found in API response" >&2
      exit 1
    fi

    # Thread detection: attempt to fetch thread context (graceful degradation on failure)
    thread_content=""
    thread_response=$(curl -s --connect-timeout 10 --max-time 25 -w "\n%{http_code}" \
      -H "X-API-Key: ${API_KEY}" \
      -- "https://api.twitterapi.io/twitter/tweet/thread?tweet_id=${tweet_id}" \
      2>/dev/null) || true
    thread_code=$(echo "$thread_response" | tail -1)
    if [ "$thread_code" = "200" ]; then
      thread_body=$(echo "$thread_response" | sed '$d')
      thread_content=$(echo "$thread_body" | jq -r '
        .thread // [] |
        sort_by(.created_at) |
        .[] |
        "**@" + (.author.username // "unknown") + ":** " + (.full_text // .text // "")
      ' 2>/dev/null) || true
    fi

    out_file="$output_dir/x-tweet-${tweet_id}.md"
    {
      echo "---"
      echo "source: x-tweet"
      echo "original_url: $url"
      echo "extracted_at: $timestamp"
      echo "tweet_id: $tweet_id"
      echo "method: twitterapi.io /twitter/tweets"
      echo "---"
      echo ""
      if [ -n "$thread_content" ]; then
        echo "## Thread"
        echo ""
        echo "$thread_content"
        echo ""
        echo "---"
        echo ""
      fi
      echo "## Tweet"
      echo ""
      echo "$tweet_text"
    } > "$out_file"

    echo "$out_file"
    ;;

  *)
    echo "Usage: x-handler.sh <article|tweet> <url> <output_dir>" >&2
    exit 2
    ;;
esac
