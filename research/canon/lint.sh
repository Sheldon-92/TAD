#!/usr/bin/env bash
# lint.sh — Local Wiki Iron Rule validator (6 rules)
# Usage: bash research/canon/lint.sh [file]
#   no arg → lint all canon + wiki files
#   file   → lint single file (for negative tests)
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CANON_DIR="$REPO_ROOT/research/canon"
WIKI_DIR="$REPO_ROOT/research/wiki"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

files=()
if [ $# -gt 0 ]; then
  files=("$1")
else
  # Find all canon and wiki markdown files (exclude generated indexes, _*.yaml, _*.md templates)
  while IFS= read -r -d '' f; do
    # Skip generated indexes and docs
    case "$f" in
      *"/_index.md"|*"/index.md"|*"/_clusters.md"|*"/README.md"|*"/log.md") continue ;;
    esac
    files+=("$f")
  done < <(find "$CANON_DIR" "$WIKI_DIR" -type f -name "*.md" -print0 2>/dev/null | sort -z)
  if [ ${#files[@]} -eq 0 ]; then
    echo "No canon/wiki files found"
    exit 0
  fi
fi

overall_fail=0

for file in "${files[@]}"; do
  # Skip if file not existence
  if [ ! -f "$file" ]; then
    echo -e "${RED}FAIL${NC}: $file — file not found"
    overall_fail=1
    continue
  fi

  rel_path="${file#$REPO_ROOT/}"
  fail_reasons=()
  warn_reasons=()

  # --- Extract frontmatter ---
  # Count delimiter lines exactly "---"
  delim_count=$(grep -c '^---$' "$file" || true)
  if [ "$delim_count" -lt 2 ]; then
    fail_reasons+=("rule1: frontmatter delimiters !=2 (found $delim_count)")
  fi

  # Extract frontmatter content between first and second ---
  frontmatter=$(awk 'BEGIN{f=0} /^---$/ {f++; next} f==1 {print}' "$file")
  body=$(awk 'BEGIN{f=0} /^---$/ {f++; next} f==2 {print}' "$file")

  if [ -z "$frontmatter" ]; then
    fail_reasons+=("rule1: empty frontmatter")
  else
    # Rule 1 & 6: valid YAML via ruby -ryaml (also catches injection)
    tmpfm=$(mktemp)
    printf '%s\n' "$frontmatter" > "$tmpfm"
    if ! ruby -ryaml -e "YAML.load_file('$tmpfm')" >/dev/null 2>&1; then
      fail_reasons+=("rule1/6: frontmatter invalid YAML or injection (ruby -ryaml FAIL)")
    fi
    # Also test with python if ruby missing? ruby is present per preflight
    rm -f "$tmpfm"
  fi

  # Rule 1/6 injection: also test whole file via yq front-matter extract
  if ! yq --front-matter=extract 'true' "$file" >/dev/null 2>&1; then
    # yq may fail if frontmatter invalid
    if [[ ! " ${fail_reasons[*]} " =~ "rule1" ]]; then
      fail_reasons+=("rule6: yq front-matter extract FAIL")
    fi
  fi

  # Extract fields via yq front-matter process (safe)
  # Use yq to get raw_refs length, wiki_page, depth, citable, topics
  raw_refs_len=0
  if yq --front-matter=extract '.raw_refs | length' "$file" >/tmp/lint-rawlen 2>/dev/null; then
    raw_refs_len=$(cat /tmp/lint-rawlen | tr -d ' ')
    # yq returns null if field missing
    if [ "$raw_refs_len" = "null" ] || [ -z "$raw_refs_len" ]; then
      raw_refs_len=0
    fi
  else
    raw_refs_len=0
  fi

  # Rule 2: claim count == raw_refs count (or each claim has [^raw/path])
  # Count claim lines: bullet lines or fallback to non-empty non-heading lines
  claim_count=$( (printf '%s\n' "$body" | grep -E '^- |^\* |^[0-9]+\. ' || true) | wc -l | tr -d ' ')
  if [ "$claim_count" -eq 0 ]; then
    # Fallback: count non-empty lines not starting with # and not blank, excluding code fences
    claim_count=$( (printf '%s\n' "$body" | grep -v '^#' | grep -v '^```' | grep -v '^$' || true) | wc -l | tr -d ' ')
    # Also handle case where body is empty -> 0
  fi
  # If file has no body (e.g., raw files not linted here) but we still check?
  # For canon/wiki, raw_refs_len may be 0 if citable false seed? But per AC, all our files have 3
  # If raw_refs_len is 0, rule2 should check no raw_refs needed? But Iron Rule says must have raw_refs for wiki.
  # For this lint, enforce for files under wiki or canon with depth != seed
  is_wiki=false
  if [[ "$file" == *"/wiki/"* ]]; then is_wiki=true; fi
  depth_val=$(yq --front-matter=extract '.depth // ""' "$file" 2>/dev/null | tr -d '"' || echo "")
  # If file is wiki, raw_refs must exist
  if [ "$is_wiki" = true ]; then
    if [ "$raw_refs_len" -eq 0 ]; then
      fail_reasons+=("rule2: wiki file has 0 raw_refs (Iron Rule requires ≥1)")
    else
      # Check claim vs raw_refs count OR fallback footnote check
      # If claim count != raw_refs_len, check alternative: each claim line has [^raw/
      if [ "$claim_count" -ne "$raw_refs_len" ]; then
        # Look for footnote style [^raw/
        footnote_count=$(printf '%s\n' "$body" | grep -c '\[\^raw/' || true)
        if [ "$footnote_count" -ne "$raw_refs_len" ] && [ "$footnote_count" -ne "$claim_count" ]; then
          fail_reasons+=("rule2: claim_count ($claim_count) != raw_refs_len ($raw_refs_len) and no matching [^raw/ footnotes]")
        fi
      fi
    fi
  else
    # For canon, if depth is cited/compiled, require raw_refs; if seed, 0 allowed
    if [[ "$depth_val" == "cited" || "$depth_val" == "compiled" ]]; then
      if [ "$raw_refs_len" -eq 0 ]; then
        fail_reasons+=("rule2: canon depth=$depth_val requires raw_refs")
      fi
    fi
    # Also check claim vs raw_refs for canon? Body word/line limit is rule3 but also Iron Rule not strict for canon?
    # We skip strict claim count for canon (only wiki enforces)
  fi

  # Rule 2b: body ≤15 lines and ≤120 words (for canon)
  if [[ "$file" == *"/canon/"* ]]; then
    body_lines=$( (printf '%s\n' "$body" | grep -v '^$' || true) | wc -l | tr -d ' ')
    body_words=$(printf '%s\n' "$body" | wc -w | tr -d ' ')
    if [ "$body_lines" -gt 15 ]; then
      fail_reasons+=("rule3: canon body >15 lines ($body_lines)")
    fi
    if [ "$body_words" -gt 120 ]; then
      fail_reasons+=("rule3: canon body >120 words ($body_words)")
    fi
  fi

  # Rule 3 & 4: each raw_refs[].path exists and locator non-empty matches p.|para|timestamp
  # Extract via yq
  if [ "$raw_refs_len" -gt 0 ]; then
    for i in $(seq 0 $((raw_refs_len - 1))); do
      ref_path=$(yq --front-matter=extract ".raw_refs[$i].path" "$file" 2>/dev/null | tr -d '"' || echo "")
      locator=$(yq --front-matter=extract ".raw_refs[$i].locator" "$file" 2>/dev/null | tr -d '"' || echo "")
      # Rule 3: path exists
      if [ -z "$ref_path" ] || [ "$ref_path" = "null" ]; then
        fail_reasons+=("rule3: raw_refs[$i] missing path")
      else
        full_path="$REPO_ROOT/$ref_path"
        if [ ! -f "$full_path" ]; then
          fail_reasons+=("rule3: raw_refs[$i] path not found: $ref_path")
        fi
      fi
      # Rule 4: locator non-empty and format
      if [ -z "$locator" ] || [ "$locator" = "null" ]; then
        fail_reasons+=("rule4: raw_refs[$i] missing locator")
      else
        if ! printf '%s' "$locator" | grep -qE 'p\.|para|timestamp'; then
          fail_reasons+=("rule4: raw_refs[$i] locator invalid format (need p.|para|timestamp): $locator")
        fi
      fi
    done
  fi

  # Rule 5: depth derived consistent (wiki_page exists → cited)
  wiki_page_val=$(yq --front-matter=extract '.wiki_page // ""' "$file" 2>/dev/null | tr -d '"' || echo "")
  if [ -n "$wiki_page_val" ] && [ "$wiki_page_val" != "null" ] && [ "$wiki_page_val" != "" ]; then
    wiki_full="$REPO_ROOT/$wiki_page_val"
    if [ ! -f "$wiki_full" ]; then
      fail_reasons+=("rule5: wiki_page $wiki_page_val not found")
    else
      # If wiki_page exists, depth must not be seed
      if [ "$depth_val" = "seed" ]; then
        fail_reasons+=("rule5: wiki_page exists but depth=seed (should be cited/compiled)")
      fi
    fi
    # citable may only be true when wiki_page exists — if citable true but no wiki file, fail
    citable_val=$(yq --front-matter=extract '.citable' "$file" 2>/dev/null | tr -d ' ' || echo "")
    if [ "$citable_val" = "true" ] && [ ! -f "$wiki_full" ]; then
      fail_reasons+=("rule5: citable=true but wiki_page missing")
    fi
  fi

  # Additional: check frontmatter valid YAML already done
  # Check for unregistered topic WARN (not FAIL)
  # Load core topics
  if [ -f "$CANON_DIR/_topics.yaml" ]; then
    topics_in_file=$(yq --front-matter=extract '.topics[] // .explores[]' "$file" 2>/dev/null | tr -d '"' || echo "")
    # For each topic, check against core
    for t in $topics_in_file; do
      if [ -z "$t" ] || [ "$t" = "null" ]; then continue; fi
      if ! yq -e ".core[] | select(. == \"$t\")" "$CANON_DIR/_topics.yaml" >/dev/null 2>&1; then
        warn_reasons+=("unregistered topic: $t")
      fi
    done
  fi

  if [ ${#fail_reasons[@]} -gt 0 ]; then
    echo -e "${RED}FAIL${NC}: $rel_path"
    for r in "${fail_reasons[@]}"; do
      echo "  - $r"
    done
    if [ ${#warn_reasons[@]} -gt 0 ]; then
      for w in "${warn_reasons[@]}"; do
        echo -e "  ${YELLOW}WARN${NC}: $w"
      done
    fi
    overall_fail=1
  else
    echo -e "${GREEN}PASS${NC}: $rel_path"
    if [ ${#warn_reasons[@]} -gt 0 ]; then
      for w in "${warn_reasons[@]}"; do
        echo -e "  ${YELLOW}WARN${NC}: $w"
      done
    fi
  fi
done

if [ $overall_fail -eq 1 ]; then
  echo "lint: FAIL"
  exit 1
else
  echo "lint: PASS"
  exit 0
fi
