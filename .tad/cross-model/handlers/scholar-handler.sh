#!/usr/bin/env bash
# Academic Paper Handler — arXiv abs→PDF conversion + Semantic Scholar open-access discovery
# Usage: bash scholar-handler.sh arxiv  <url> <output_dir>
#        bash scholar-handler.sh search <url> <output_dir>
# Exit: 0  = success, stdout = local .md path (abstract only fallback)
#       10 = success, stdout = remote PDF URL for direct source add
#       1  = extraction failed
#       2  = dependency missing (jq not installed)

set -euo pipefail

mode="${1:-}"
url="${2:-}"
output_dir="${3:-/tmp/tad-preprocess}"

if [ -z "$mode" ] || [ -z "$url" ]; then
  echo "Usage: scholar-handler.sh <arxiv|search> <url> <output_dir>" >&2
  exit 2
fi

# Preflight: jq
if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: jq not installed. Run: brew install jq" >&2
  exit 2
fi

mkdir -p "$output_dir"

# Extract arXiv paper ID — digits.digits with optional version
extract_arxiv_id() {
  echo "$1" | grep -oE '[0-9]{4}\.[0-9]{4,5}(v[0-9]+)?'
}

# Extract Semantic Scholar 40-char hex hash from URL path end
extract_s2_id() {
  echo "$1" | grep -oE '[0-9a-f]{40}$'
}

timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%SZ")

case "$mode" in
  arxiv)
    arxiv_id=$(extract_arxiv_id "$url")
    if [ -z "$arxiv_id" ]; then
      echo "ERROR: Could not extract arXiv ID from URL: $url" >&2
      exit 1
    fi
    pdf_url="https://arxiv.org/pdf/${arxiv_id}"
    echo "$pdf_url"
    exit 10
    ;;

  search)
    # Determine if Semantic Scholar or Google Scholar
    s2_id=$(extract_s2_id "$url")
    if [ -n "$s2_id" ]; then
      # Semantic Scholar direct paper lookup — P0-2 fix: --connect-timeout + --max-time
      response=$(curl -s --connect-timeout 10 --max-time 25 -- \
        "https://api.semanticscholar.org/graph/v1/paper/${s2_id}?fields=title,abstract,openAccessPdf,externalIds" \
        2>/dev/null)
    else
      # Google Scholar — extract query terms and search via Semantic Scholar
      query=$(echo "$url" | grep -oE 'q=[^&]+' | sed 's/q=//' | sed 's/%20/ /g' | sed 's/+/ /g' | head -1)
      if [ -z "$query" ]; then
        echo "ERROR: Could not extract search query from Google Scholar URL" >&2
        exit 1
      fi
      # use jq @uri — avoids Python -c shell interpolation risk
      encoded_query=$(printf '%s' "$query" | jq -sRr '@uri' 2>/dev/null || echo "${query// /+}")
      # P0-2 fix: --connect-timeout + --max-time
      response=$(curl -s --connect-timeout 10 --max-time 25 -- \
        "https://api.semanticscholar.org/graph/v1/paper/search?query=${encoded_query}&fields=title,abstract,openAccessPdf,externalIds&limit=1" \
        2>/dev/null)
      # For search results, the paper is nested under .data[0]
      # P1-3 fix: printf '%s\n' to avoid echo backslash interpretation
      response=$(printf '%s\n' "$response" | jq '.data[0] // {}' 2>/dev/null)
      s2_id=$(printf '%s\n' "$response" | jq -r '.paperId // ""' 2>/dev/null)
    fi

    if [ -z "$response" ] || [ "$response" = "null" ] || [ "$response" = "{}" ]; then
      echo "ERROR: Semantic Scholar API returned no data" >&2
      exit 1
    fi

    # P1-2 fix: if all key fields null, try title-based re-search
    s2_title=$(printf '%s\n' "$response" | jq -r '.title // empty' 2>/dev/null)
    s2_abstract=$(printf '%s\n' "$response" | jq -r '.abstract // empty' 2>/dev/null)
    if [ -z "$s2_title" ] && [ -z "$s2_abstract" ]; then
      fallback_query=$(echo "$url" | sed 's|.*/paper/||' | sed 's|/[a-f0-9]*$||' | sed 's/%3A/:/g; s/-/ /g; s/+/ /g')
      if [ -n "$fallback_query" ]; then
        encoded_q=$(printf '%s' "$fallback_query" | jq -sRr '@uri')
        fallback_resp=$(curl -s --connect-timeout 10 --max-time 25 -- \
          "https://api.semanticscholar.org/graph/v1/paper/search?query=${encoded_q}&fields=title,abstract,openAccessPdf,externalIds&limit=1" \
          2>/dev/null || true)
        fallback_data=$(printf '%s\n' "$fallback_resp" | jq '.data[0] // empty' 2>/dev/null)
        if [ -n "$fallback_data" ]; then
          response="$fallback_data"
        fi
      fi
    fi

    # Try open-access PDF first
    # P1-3 fix: printf '%s\n' to avoid echo backslash interpretation
    pdf_url=$(printf '%s\n' "$response" | jq -r '.openAccessPdf.url // empty' 2>/dev/null)
    if [ -n "$pdf_url" ]; then
      echo "$pdf_url"
      exit 10
    fi

    # Try arXiv ID as fallback PDF source
    arxiv_id=$(printf '%s\n' "$response" | jq -r '.externalIds.ArXiv // empty' 2>/dev/null)
    if [ -n "$arxiv_id" ]; then
      echo "https://arxiv.org/pdf/${arxiv_id}"
      exit 10
    fi

    # Fallback: write abstract-only .md
    title=$(printf '%s\n' "$response" | jq -r '.title // "Unknown Paper"' 2>/dev/null)
    abstract=$(printf '%s\n' "$response" | jq -r '.abstract // "Abstract not available."' 2>/dev/null)
    # P1-1 fix: portable md5 truncation (matches bilibili-handler.sh pattern)
    # $1 is correct for both BSD md5 (single-field output) and GNU md5sum (<hash>  -)
    paper_id="${s2_id:-$(printf '%s' "$url" | { md5 2>/dev/null || md5sum 2>/dev/null; } | awk '{print substr($1,1,8)}')}"

    out_file="$output_dir/scholar-${paper_id}.md"
    {
      echo "---"
      echo "source: semantic-scholar"
      echo "original_url: $url"
      echo "extracted_at: $timestamp"
      echo "paper_id: $paper_id"
      echo "method: Semantic Scholar API (abstract only — full text not available)"
      echo "---"
      echo ""
      echo "# $title"
      echo ""
      echo "## Abstract"
      echo ""
      echo "$abstract"
      echo ""
      echo "_Note: Full text PDF not available via open access. Abstract only._"
    } > "$out_file"

    echo "WARN: Full text not available, abstract only" >&2
    echo "$out_file"
    ;;

  *)
    echo "Usage: scholar-handler.sh <arxiv|search> <url> <output_dir>" >&2
    exit 2
    ;;
esac
