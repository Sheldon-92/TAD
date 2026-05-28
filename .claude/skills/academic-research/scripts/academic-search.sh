#!/usr/bin/env bash
# Academic Research Pack — Database Query Helper
# Wraps common academic database searches with rate limiting and structured output.
# Usage: academic-search.sh <database> "<query>" [--limit N]

set -euo pipefail

SCRIPT_NAME="$(basename "$0")"

usage() {
  cat <<EOF
Usage: $SCRIPT_NAME <database> "<query>" [--limit N]

Databases:
  semantic-scholar   Semantic Scholar Graph API (free, 100 req/5min)
  openalex           OpenAlex works search (free, unlimited with mailto)
  pubmed             PubMed/MEDLINE via NCBI E-utilities (free, 3 req/s)
  arxiv              arXiv preprints via Atom API (free, 1 req/3s)
  europeana          Europeana cultural heritage (requires EUROPEANA_API_KEY)
  usda-food          USDA FoodData Central (DEMO_KEY or USDA_API_KEY)

Options:
  --limit N   Max results to return (default: 5)
  --help      Show this message

Examples:
  $SCRIPT_NAME semantic-scholar "CRISPR cancer therapy" --limit 10
  $SCRIPT_NAME openalex "machine learning protein folding"
  $SCRIPT_NAME europeana "ornamental plant pattern" --limit 3
  $SCRIPT_NAME usda-food "sesame paste nutrition" --limit 5
EOF
  exit "${1:-0}"
}

LIMIT=5

if [[ $# -lt 1 ]]; then
  usage 1
fi

DATABASE="${1:-}"
shift

if [[ "$DATABASE" == "--help" || "$DATABASE" == "-h" ]]; then
  usage 0
fi

if [[ $# -lt 1 ]]; then
  echo "Error: query string required" >&2
  usage 1
fi

QUERY="${1:-}"
shift

while [[ $# -gt 0 ]]; do
  case "$1" in
    --limit)
      [[ -z "${2:-}" ]] && echo "Error: --limit requires a value" >&2 && exit 1
      if ! [[ "$2" =~ ^[0-9]+$ ]] || [[ "$2" -eq 0 ]]; then
        echo "Error: --limit must be a positive integer" >&2
        exit 1
      fi
      LIMIT="$2"
      shift 2
      ;;
    --help|-h) usage 0 ;;
    *) echo "Unknown option: $1" >&2; usage 1 ;;
  esac
done

ENCODED_QUERY="$(printf '%s' "$QUERY" | jq -sRr @uri)"

format_header() {
  echo "=== $1 ==="
  echo "Query: $QUERY"
  echo "Limit: $LIMIT"
  echo "---"
}

search_semantic_scholar() {
  format_header "Semantic Scholar"
  local url="https://api.semanticscholar.org/graph/v1/paper/search?query=${ENCODED_QUERY}&limit=${LIMIT}&fields=title,authors,year,citationCount,url,externalIds"
  local response
  response="$(curl -s --max-time 20 "$url" 2>/dev/null)" || { echo "Error: Semantic Scholar API request failed" >&2; return 1; }
  if [[ -z "$response" ]] || ! echo "$response" | python3 -c "import json,sys; json.load(sys.stdin)" 2>/dev/null; then
    echo "Error: Semantic Scholar returned invalid response" >&2; return 1
  fi

  echo "$response" | python3 -c "
import json, sys
data = json.load(sys.stdin)
for i, p in enumerate(data.get('data', [])[:${LIMIT}]):
    print(f\"[{i+1}] {p.get('title', 'N/A')}\")
    authors = ', '.join(a.get('name','') for a in (p.get('authors') or [])[:3])
    if len(p.get('authors') or []) > 3: authors += ' et al.'
    print(f\"    Authors: {authors}\")
    print(f\"    Year: {p.get('year', 'N/A')}  Citations: {p.get('citationCount', 'N/A')}\")
    ids = p.get('externalIds') or {}
    doi = ids.get('DOI', '')
    if doi: print(f\"    DOI: {doi}\")
    print(f\"    URL: {p.get('url', 'N/A')}\")
    print()
" 2>/dev/null || echo "Error: failed to parse response" >&2
  sleep 3
}

search_openalex() {
  format_header "OpenAlex"
  local url="https://api.openalex.org/works?search=${ENCODED_QUERY}&per_page=${LIMIT}&sort=relevance_score:desc&select=title,publication_year,cited_by_count,doi,authorships&mailto=tad-academic-research@openclaw.ai"
  local response
  response="$(curl -sf --max-time 15 "$url" 2>/dev/null)" || { echo "Error: OpenAlex API request failed" >&2; return 1; }

  echo "$response" | python3 -c "
import json, sys
data = json.load(sys.stdin)
for i, w in enumerate(data.get('results', [])[:${LIMIT}]):
    print(f\"[{i+1}] {w.get('title', 'N/A')}\")
    authors = ', '.join(a.get('author',{}).get('display_name','') for a in (w.get('authorships') or [])[:3])
    if len(w.get('authorships') or []) > 3: authors += ' et al.'
    print(f\"    Authors: {authors}\")
    print(f\"    Year: {w.get('publication_year', 'N/A')}  Citations: {w.get('cited_by_count', 'N/A')}\")
    doi = w.get('doi', '')
    if doi: print(f\"    DOI: {doi}\")
    print()
" 2>/dev/null || echo "Error: failed to parse response" >&2
  sleep 1
}

search_pubmed() {
  format_header "PubMed (NCBI E-utilities)"
  local url="https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&retmode=json&retmax=${LIMIT}&sort=relevance&term=${ENCODED_QUERY}"
  local response
  response="$(curl -sf --max-time 15 "$url" 2>/dev/null)" || { echo "Error: PubMed API request failed" >&2; return 1; }

  local ids
  ids="$(echo "$response" | python3 -c "
import json, sys
data = json.load(sys.stdin)
result = data.get('esearchresult', {})
ids = result.get('idlist', [])
print(f\"Found {result.get('count', 0)} results, showing top {len(ids)}\")
print(','.join(ids))
" 2>/dev/null)" || { echo "Error: failed to parse search results" >&2; return 1; }

  echo "$ids" | head -1
  local id_list
  id_list="$(echo "$ids" | tail -1)"

  if [[ -n "$id_list" && "$id_list" != "," ]]; then
    sleep 1
    local summary_url="https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed&retmode=json&id=${id_list}"
    local summary
    summary="$(curl -sf --max-time 15 "$summary_url" 2>/dev/null)" || { echo "Error: PubMed summary request failed" >&2; return 1; }

    echo "$summary" | python3 -c "
import json, sys
data = json.load(sys.stdin)
result = data.get('result', {})
uids = result.get('uids', [])
for i, uid in enumerate(uids):
    p = result.get(uid, {})
    print(f\"[{i+1}] {p.get('title', 'N/A')}\")
    authors = ', '.join(a.get('name','') for a in (p.get('authors') or [])[:3])
    if len(p.get('authors') or []) > 3: authors += ' et al.'
    print(f\"    Authors: {authors}\")
    print(f\"    Year: {p.get('pubdate', 'N/A')}\")
    print(f\"    PMID: {uid}\")
    doi = ''
    for aid in (p.get('articleids') or []):
        if aid.get('idtype') == 'doi': doi = aid.get('value','')
    if doi: print(f\"    DOI: {doi}\")
    print()
" 2>/dev/null || echo "Error: failed to parse summary" >&2
  fi
  sleep 1
}

search_arxiv() {
  format_header "arXiv"
  local url="https://export.arxiv.org/api/query?search_query=all:${ENCODED_QUERY}&start=0&max_results=${LIMIT}&sortBy=relevance&sortOrder=descending"
  local response
  response="$(curl -s --max-time 20 "$url" 2>/dev/null)" || { echo "Error: arXiv API request failed" >&2; return 1; }
  if [[ -z "$response" ]]; then echo "Error: arXiv returned empty response" >&2; return 1; fi

  local count=0
  local in_entry=0
  local title="" authors="" published="" entry_id="" summary=""
  while IFS= read -r line; do
    if echo "$line" | grep -q '<entry>'; then
      in_entry=1; title=""; authors=""; published=""; entry_id=""; summary=""
    elif echo "$line" | grep -q '</entry>'; then
      in_entry=0; count=$((count + 1))
      title="$(echo "$title" | sed 's/^[[:space:]]*//' | tr '\n' ' ')"
      echo "[${count}] ${title}"
      echo "    Authors: ${authors}"
      echo "    Year: ${published}"
      echo "    URL: ${entry_id}"
      echo ""
      if [[ $count -ge $LIMIT ]]; then break; fi
    elif [[ $in_entry -eq 1 ]]; then
      if echo "$line" | grep -q '<title>'; then
        title="$(echo "$line" | sed 's/.*<title[^>]*>//;s/<\/title>.*//')"
        while ! echo "$line" | grep -q '</title>'; do
          IFS= read -r line || break
          title="${title} $(echo "$line" | sed 's/<\/title>.*//')"
        done
      elif echo "$line" | grep -q '<name>'; then
        local name="$(echo "$line" | sed 's/.*<name>//;s/<\/name>.*//')"
        if [[ -n "$authors" ]]; then authors="${authors}, ${name}"; else authors="$name"; fi
      elif echo "$line" | grep -q '<published>'; then
        published="$(echo "$line" | sed 's/.*<published>//;s/<\/published>.*//' | cut -c1-4)"
      elif echo "$line" | grep -q '<id>http'; then
        entry_id="$(echo "$line" | sed 's/.*<id>//;s/<\/id>.*//')"
      fi
    fi
  done <<< "$response"
  if [[ $count -eq 0 ]]; then echo "No results found" >&2; fi
  sleep 3
}

search_europeana() {
  format_header "Europeana"
  local api_key="${EUROPEANA_API_KEY:-}"
  if [[ -z "$api_key" ]]; then
    echo "⚠️  EUROPEANA_API_KEY not set. Get a free key: https://pro.europeana.eu/page/get-api" >&2
    echo "Set it: export EUROPEANA_API_KEY=your_key" >&2
    return 0
  fi

  local url="https://api.europeana.eu/record/v2/search.json?wskey=${api_key}&query=${ENCODED_QUERY}&rows=${LIMIT}"
  local response
  response="$(curl -sf --max-time 15 "$url" 2>/dev/null)" || { echo "Error: Europeana API request failed" >&2; return 1; }

  echo "$response" | python3 -c "
import json, sys
data = json.load(sys.stdin)
if not data.get('success', False):
    print(f\"Error: {data.get('error', 'unknown')}\", file=sys.stderr)
    sys.exit(1)
items = data.get('items', [])
print(f\"Total results: {data.get('totalResults', 0)}\")
for i, item in enumerate(items[:${LIMIT}]):
    title = (item.get('title') or ['N/A'])[0]
    print(f\"[{i+1}] {title}\")
    creator = (item.get('dcCreator') or ['Unknown'])[0] if item.get('dcCreator') else 'Unknown'
    print(f\"    Creator: {creator}\")
    year = (item.get('year') or ['N/A'])[0] if item.get('year') else 'N/A'
    print(f\"    Year: {year}\")
    provider = (item.get('dataProvider') or ['N/A'])[0]
    print(f\"    Provider: {provider}\")
    link = item.get('guid', 'N/A')
    print(f\"    URL: {link}\")
    print()
" 2>/dev/null || echo "Error: failed to parse response" >&2
  sleep 1
}

search_usda_food() {
  format_header "USDA FoodData Central"
  local api_key="${USDA_API_KEY:-DEMO_KEY}"
  if [[ "$api_key" == "DEMO_KEY" ]]; then
    echo "⚠️  Using DEMO_KEY (30 req/hr). Get free key: https://fdc.nal.usda.gov/api-key-signup.html" >&2
  fi

  local url="https://api.nal.usda.gov/fdc/v1/foods/search?api_key=${api_key}&query=${ENCODED_QUERY}&pageSize=${LIMIT}"
  local response
  response="$(curl -sf --max-time 15 "$url" 2>/dev/null)" || { echo "Error: USDA FoodData API request failed" >&2; return 1; }

  echo "$response" | python3 -c "
import json, sys
data = json.load(sys.stdin)
foods = data.get('foods', [])
print(f\"Total results: {data.get('totalHits', 0)}\")
for i, f in enumerate(foods[:${LIMIT}]):
    print(f\"[{i+1}] {f.get('description', 'N/A')}\")
    print(f\"    FDC ID: {f.get('fdcId', 'N/A')}\")
    print(f\"    Data Type: {f.get('dataType', 'N/A')}\")
    brand = f.get('brandOwner', '')
    if brand: print(f\"    Brand: {brand}\")
    nutrients = f.get('foodNutrients', [])[:5]
    for n in nutrients:
        name = n.get('nutrientName', '')
        val = n.get('value', '')
        unit = n.get('unitName', '')
        if name and val: print(f\"    {name}: {val} {unit}\")
    print()
" 2>/dev/null || echo "Error: failed to parse response" >&2
  sleep 2
}

case "$DATABASE" in
  semantic-scholar) search_semantic_scholar ;;
  openalex)         search_openalex ;;
  pubmed)           search_pubmed ;;
  arxiv)            search_arxiv ;;
  europeana)        search_europeana ;;
  usda-food)        search_usda_food ;;
  *)
    echo "Unknown database: $DATABASE" >&2
    echo "Supported: semantic-scholar, openalex, pubmed, arxiv, europeana, usda-food" >&2
    exit 1
    ;;
esac
