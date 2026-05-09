#!/usr/bin/env bash
# Jina Reader Handler — generic content extraction via https://r.jina.ai
# Usage: bash jina-handler.sh <url> <output_dir>
# Exit: 0 = success, stdout = .md path
#       1 = extraction failed (rate limit, HTTP error, minimal content)

set -euo pipefail

url="${1:-}"
output_dir="${2:-/tmp/tad-preprocess}"

if [ -z "$url" ]; then
  echo "Usage: jina-handler.sh <url> <output_dir>" >&2
  exit 1
fi

mkdir -p "$output_dir"

timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%SZ")

# Fetch via Jina Reader
# curl returns exit 3 ("URL malformed") for nested https://r.jina.ai/https://... URLs
# even when content is successfully fetched. Suppress with || true; validate via http_code + body.
# P0-2 fix: --connect-timeout + --max-time for handler-level timeout enforcement
response=$(curl -s --connect-timeout 10 --max-time 25 -w "\n%{http_code}" \
  -H "Accept: text/markdown" \
  -- "https://r.jina.ai/${url}" \
  2>/dev/null || true)

# P0-3 fix: guard against empty response (network/DNS failure)
if [ -z "$response" ]; then
  echo "ERROR: Jina Reader returned no response (network/DNS failure?)" >&2
  exit 1
fi

http_code=$(echo "$response" | tail -1)
body=$(echo "$response" | sed '$d')

# HTTP error handling
if [ "$http_code" = "429" ]; then
  echo "ERROR: Rate limited by Jina Reader. Wait and retry." >&2
  exit 1
elif [ "${http_code:-0}" -ge 400 ] 2>/dev/null; then
  echo "ERROR: Jina Reader returned HTTP $http_code" >&2
  exit 1
fi

# Content length check — minimal content threshold: 500 chars
char_count=$(echo "$body" | wc -c | tr -d ' ')
if [ "${char_count:-0}" -lt 500 ]; then
  echo "ERROR: Jina Reader returned minimal content (${char_count} chars) — likely a redirect or error page" >&2
  exit 1
fi

# Generate slug from URL domain + path (first 40 alphanum chars, hyphen-separated)
# P2-1 fix: BSD sed does not support \| alternation — use two separate passes for trimming
slug=$(echo "$url" | sed 's|https\?://||' | sed 's|[^A-Za-z0-9]|-|g' | sed 's|-\{2,\}|-|g' | cut -c1-40)
slug="${slug#-}"; slug="${slug%-}"

out_file="$output_dir/jina-${slug}.md"
{
  echo "---"
  echo "source: jina-reader"
  echo "original_url: $url"
  echo "extracted_at: $timestamp"
  echo "method: Jina Reader API (https://r.jina.ai)"
  echo "content_chars: $char_count"
  echo "---"
  echo ""
  echo "$body"
} > "$out_file"

echo "$out_file"
