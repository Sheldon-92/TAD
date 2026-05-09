#!/bin/bash
# .tad/hooks/generate-keywords.sh
#
# One-shot generator for .tad/hooks/keywords.yaml.draft from .tad/domains/*.yaml.
# ENGLISH-ONLY heuristic. Chinese keywords MUST be hand-added after generation.
# (tr cannot reliably tokenize CJK; Blake / user must curate CJK anchors manually.)
#
# Usage:
#   ./generate-keywords.sh                       # writes keywords.yaml.draft (overwrites)
#   ./generate-keywords.sh --append-missing-only # writes only packs not already in keywords.yaml
#
# Deduplication audit REQUIRED before moving draft to keywords.yaml:
#   - Any keyword in > 2 packs → force-specialize or delete
#   - Each pack must have >= 3 unique anchors (zero cross-pack)
#   - Each pack must have >= 3 Chinese AND >= 3 English (after hand-curation)
#   - Minimum length: English 3 chars, Chinese 2 chars
#
# BSD-compatible (macOS). Do not use grep -P, sed -i without backup, or GNU-only flags.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOMAINS_DIR="${SCRIPT_DIR}/../domains"
DRAFT_OUT="${SCRIPT_DIR}/keywords.yaml.draft"
CURRENT_YAML="${SCRIPT_DIR}/keywords.yaml"
MODE="${1:-full}"   # full | --append-missing-only

# High-collision words banned unless explicitly added by a curator.
# Extended from handoff §3.1 FR6.
# shellcheck disable=SC2016
STOPWORDS='^(the|a|an|is|are|of|to|for|with|and|or|in|on|at|by|from|as|that|this|it|its|be|been|being|will|shall|can|may|should|must|has|have|had|do|does|did|not|no|all|any|some|more|most|less|only|just|also|than|then|when|where|what|which|who|how|why|so|if|but|yet|still|into|out|up|down|off|over|under|about|between|through|after|before|during|without|within|your|you|we|our|their|they|them|he|she|i|me|my|build|code|test|project|system|api|design|tool|file|data|setup|use|using|used|make|making|made|get|got|take|taken|give|given|new|old|good|bad|best|worst|fast|slow|high|low|big|small|large|main|other|next|last|first|same|different|each|every|such|very|much|many|few|several|one|two|three|four|five|six|seven|eight|nine|ten|yaml|json|md|sh|py|js|ts|html|css|xml|txt|log|yml|io|tad|eg|ie|etc|vs|re|etc)$'

EXCLUDE_PACKS='tools-registry HOW-TO-CREATE-DOMAIN-PACK'

list_domain_files() {
  # Deterministic ordering: alphabetical
  ls "${DOMAINS_DIR}"/*.yaml 2>/dev/null | sort
}

is_excluded() {
  local base="$1"
  for skip in $EXCLUDE_PACKS; do
    [ "$base" = "$skip" ] && return 0
  done
  return 1
}

# Extract description value (line starting with `description:` at top level)
extract_description() {
  local f="$1"
  # Top-level description (not indented) — grep with anchor
  grep -E '^description:' "$f" | head -1 | sed 's/^description:[[:space:]]*//;s/^"//;s/"$//' | cut -c1-400
}

# Extract capability names using STRICT 2-space anchor per P0-C4.
# Pattern: exactly 2 leading spaces, identifier, colon, end of line (or trailing spaces).
extract_capability_names() {
  local f="$1"
  awk '
    /^capabilities:/ { in_caps = 1; next }
    /^[a-z_]+:/      { if (!/^  /) in_caps = 0 }
    in_caps && /^  [a-z_]+:[[:space:]]*$/ {
      name = $0
      sub(/^  /, "", name)
      sub(/:[[:space:]]*$/, "", name)
      print name
    }
  ' "$f"
}

# Extract capability descriptions (one-line after "    description:" nested under capability)
# Used for tokenization; does NOT need to be field-perfect.
extract_capability_descriptions() {
  local f="$1"
  grep -E '^    description:' "$f" \
    | sed 's/^    description:[[:space:]]*//;s/^"//;s/"$//' \
    | cut -c1-500
}

# Tokenize a blob of English text into candidate keywords.
# - lowercase
# - split on whitespace and common punctuation
# - dedupe (sort -u)
# - filter by stopwords
# - keep words length >= 3 ASCII chars, exclude pure digits
tokenize_english() {
  local text="$1"
  printf '%s\n' "$text" \
    | tr '[:upper:]' '[:lower:]' \
    | tr -cs 'a-z0-9_-' '\n' \
    | grep -v '^[[:space:]]*$' \
    | awk 'length($0) >= 3 && $0 !~ /^[0-9]+$/' \
    | grep -Ev "$STOPWORDS" \
    | sort -u
}

# Candidate tokens from an underscore-separated capability name
# e.g. "component_development" -> "component", "development"
tokenize_capability_name() {
  local name="$1"
  printf '%s' "$name" | tr '_' '\n' | tokenize_english "$(cat)"
}

pack_in_current_yaml() {
  local pack="$1"
  [ ! -f "$CURRENT_YAML" ] && return 1
  # yq is a hard dependency for --append-missing-only mode
  if command -v yq >/dev/null 2>&1; then
    yq -r '.packs[]?.name // empty' "$CURRENT_YAML" 2>/dev/null | grep -Fxq "$pack"
  else
    grep -E "^\s+- name:\s+${pack}\s*$" "$CURRENT_YAML" >/dev/null 2>&1
  fi
}

generate_pack_block() {
  local f="$1"
  local base="$2"
  local desc cap_names cap_descs tokens

  desc=$(extract_description "$f")
  cap_names=$(extract_capability_names "$f")
  cap_descs=$(extract_capability_descriptions "$f")

  # Build tokenization input from: description + cap names (split on _) + cap descs
  # Use a temp string with spaces instead of newlines for tokenization input
  local blob
  blob="$desc $(printf '%s' "$cap_names" | tr '_' ' ') $cap_descs"

  tokens=$(printf '%s\n' "$blob" \
    | tr '[:upper:]' '[:lower:]' \
    | tr -cs 'a-z0-9_-' '\n' \
    | awk 'length($0) >= 3 && $0 !~ /^[0-9]+$/' \
    | grep -Ev "$STOPWORDS" \
    | sort -u)

  # Drop the pack base-name itself if it appears (too generic for matching)
  local pack_base_stem
  pack_base_stem=$(printf '%s' "$base" | tr '-' ' ')
  for w in $pack_base_stem; do
    tokens=$(printf '%s\n' "$tokens" | grep -Fxv "$w" || true)
  done

  # Print pack block
  printf '  - name: %s\n' "$base"
  printf '    file: .tad/domains/%s.yaml\n' "$base"
  printf '    # description: %s\n' "$(printf '%s' "$desc" | cut -c1-120)"
  printf '    # NOTE: English tokens only. Chinese keywords MUST be hand-added.\n'
  printf '    keywords:\n'
  if [ -n "$tokens" ]; then
    printf '%s\n' "$tokens" | while IFS= read -r kw; do
      [ -z "$kw" ] && continue
      printf '      - "%s"\n' "$kw"
    done
  fi
  printf '    threshold: 1   # adjust to 2 if pack has >= 8 keywords\n'
  printf '\n'
}

main() {
  if [ "$MODE" = "--append-missing-only" ]; then
    if [ ! -f "$CURRENT_YAML" ]; then
      printf '⚠️  %s does not exist — running in full mode\n' "$CURRENT_YAML" >&2
      MODE="full"
    fi
  fi

  # Header
  {
    printf '# Generated by .tad/hooks/generate-keywords.sh on %s\n' "$(date +%Y-%m-%d)"
    printf '# MODE: %s\n' "$MODE"
    printf '# ENGLISH HEURISTIC ONLY. Chinese keywords MUST be hand-added after generation.\n'
    printf '# Deduplication audit required before use:\n'
    printf '#   - Any keyword in > 2 packs → remove or specialize\n'
    printf '#   - Each pack must have >= 3 unique anchors (zero cross-pack)\n'
    printf '#   - Each pack must have >= 3 Chinese AND >= 3 English after curation\n'
    printf '# Banned high-collision words: build, code, test, project, system, api, design, tool, file, data\n'
    printf '\n'
    printf 'whitelist:\n'
    printf '  - "yes"\n  - "no"\n  - "ok"\n  - "y"\n  - "n"\n'
    printf '  - "继续"\n  - "嗯"\n  - "明白"\n  - "收到"\n  - "好的"\n'
    printf '\n'
    printf 'packs:\n'
  } > "$DRAFT_OUT"

  local count=0 skipped=0
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    base=$(basename "$f" .yaml)
    if is_excluded "$base"; then
      skipped=$((skipped + 1))
      continue
    fi

    if [ "$MODE" = "--append-missing-only" ] && pack_in_current_yaml "$base"; then
      printf '  ⏭  skipping %s (already in keywords.yaml)\n' "$base" >&2
      skipped=$((skipped + 1))
      continue
    fi

    generate_pack_block "$f" "$base" >> "$DRAFT_OUT"
    count=$((count + 1))
  done < <(list_domain_files)

  printf '✅ wrote %s (%d packs, %d skipped)\n' "$DRAFT_OUT" "$count" "$skipped"
  printf '⚠️  REVIEW before moving to %s\n' "$CURRENT_YAML"
}

main "$@"
