#!/usr/bin/env bash
# sentinel-detect.sh — AW-2/BW-1 sentinel detection (v3-LEAN §3)
# Canonicalization pipeline (2 steps):
#   1. Strip U+200B..U+200F, U+202A..U+202E, U+2060..U+2069, U+FEFF
#   2. Unicode casefold (locale=und)
# Then literal match + box-drawing U+2500{16+} + path context.
# Functions:
#   detect_sentinel_in_content <role> <content> <target_path>
#     → 0 none | 1 primary_block | 2 secondary_only (log)
#     Reason on stderr.

# shellcheck shell=bash
set -uo pipefail

: "${SENTINEL_DETECT_LOADED:=0}"
if [[ "$SENTINEL_DETECT_LOADED" == "1" ]]; then return 0 2>/dev/null || exit 0; fi
SENTINEL_DETECT_LOADED=1

SD_SCHEMA="${SD_SCHEMA:-.tad/schemas/sentinel-patterns.yaml}"

# Canonicalize content via perl (invisible strip + casefold). One spawn per call.
_sd_canon() {
  local s="$1"
  printf '%s' "$s" | perl -CSD -Mutf8 -e '
    local $/;
    my $x = <STDIN>;
    $x =~ s/[\x{200B}-\x{200F}\x{202A}-\x{202E}\x{2060}-\x{2069}\x{FEFF}]//g;
    if (eval { require Unicode::CaseFold; 1 }) {
      $x = Unicode::CaseFold::fc($x);
    } else {
      $x = lc $x;
    }
    print $x;
  ' 2>/dev/null || printf '%s' "$s" | tr '[:upper:]' '[:lower:]'
}

# Check if path matches allowlist + sentinel is inside ``` fence → LOG-ONLY.
_sd_in_allowlist_fence() {
  local path="$1" content="$2"
  [[ -z "$path" || -z "$content" ]] && return 1
  local allowlist
  allowlist=$(yq -r '.allowlist_paths[]?' "$SD_SCHEMA" 2>/dev/null || true)
  [[ -z "$allowlist" ]] && return 1
  local match=0 pat re
  while IFS= read -r pat; do
    [[ -z "$pat" ]] && continue
    re=$(printf '%s' "$pat" | sed 's|[].[^$()+{}|]|\\&|g; s|\\\*\\\*|.*|g; s|\\\*|[^/]*|g')
    if [[ "$path" =~ $re ]]; then match=1; break; fi
  done <<< "$allowlist"
  [[ "$match" == "0" ]] && return 1
  # Check if any sentinel substring occurs inside ``` fences
  # Use perl to detect: split by ``` markers, sentinel in odd-indexed block = fenced.
  printf '%s' "$content" | perl -CSD -e '
    local $/;
    my $c = <STDIN>;
    my @parts = split /\x60\x60\x60/, $c;
    for (my $i = 1; $i < @parts; $i += 2) {
      if ($parts[$i] =~ /Message from (alex|blake)/i) { exit 0 }
    }
    exit 1
  '
}

# Primary match: canonicalized content contains literal + at least 16 consecutive U+2500.
_sd_primary_match() {
  local role="$1" canon_content="$2"
  local literal
  case "$role" in
    alex)  literal="📨 message from alex" ;;
    blake) literal="📨 message from blake" ;;
    *) return 1 ;;
  esac
  # Literal match
  [[ "$canon_content" != *"$literal"* ]] && return 1
  # Box-drawing (U+2500) ≥16 — perl regex on ORIGINAL (not canonicalized,
  # canonicalization doesn't touch U+2500).
  printf '%s' "$canon_content" | perl -CSD -e '
    local $/;
    my $c = <STDIN>;
    exit ($c =~ /\x{2500}{16,}/ ? 0 : 1);
  '
}

# Check if path is in secondary (path_in) for this role.
_sd_path_matches_role() {
  local role="$1" path="$2"
  local patterns
  case "$role" in
    alex)  patterns=$(yq -r '.alex_handoff_sentinel.secondary.path_in[]?' "$SD_SCHEMA" 2>/dev/null || true) ;;
    blake) patterns=$(yq -r '.blake_completion_sentinel.secondary.path_in[]?' "$SD_SCHEMA" 2>/dev/null || true) ;;
    *) return 1 ;;
  esac
  local pat re
  while IFS= read -r pat; do
    [[ -z "$pat" ]] && continue
    re=$(printf '%s' "$pat" | sed 's|[].[^$()+{}|]|\\&|g; s|\\\*|[^/]*|g')
    local base; base=$(basename -- "$path")
    local bre; bre=$(printf '%s' "$(basename -- "$pat")" | sed 's|[].[^$()+{}|]|\\&|g; s|\\\*|[^/]*|g')
    if [[ "$path" =~ $re$ || "$base" =~ ^${bre}$ ]]; then return 0; fi
  done <<< "$patterns"
  return 1
}

# Main entry: returns 0 (no sentinel), 1 (primary — block), 2 (secondary only — log)
detect_sentinel_in_content() {
  local role="$1" content="$2" target="${3:-}"
  [[ -z "$content" ]] && return 0
  if ! [[ -f "$SD_SCHEMA" ]]; then
    printf 'SENTINEL_DETECT_ERROR: schema missing: %s\n' "$SD_SCHEMA" >&2
    return 1
  fi

  local canon
  canon=$(_sd_canon "$content")

  # Primary: literal + box-drawing
  if _sd_primary_match "$role" "$canon"; then
    # Allowlist carve-out: if target is in allowlist AND sentinel inside fence → LOG-ONLY
    if [[ -n "$target" ]] && _sd_in_allowlist_fence "$target" "$content"; then
      printf 'SENTINEL_LOG: %s sentinel in allowlist fenced block (path=%s)\n' "$role" "$target" >&2
      return 2
    fi
    printf 'SENTINEL_PRIMARY: %s sentinel literal+U+2500 detected in content (path=%s)\n' "$role" "$target" >&2
    return 1
  fi

  # Secondary: path match alone (no primary)
  if [[ -n "$target" ]] && _sd_path_matches_role "$role" "$target"; then
    printf 'SENTINEL_SECONDARY: path matches %s pattern (no primary literal)\n' "$role" >&2
    return 2
  fi

  return 0
}

# Cross-role sentinel detection: for AW-3 (Blake editing Alex handoff, etc.)
# Returns 0 if content contains OTHER role's sentinel, 1 if not.
detect_cross_role_sentinel() {
  local role="$1" content="$2"
  local other
  case "$role" in
    alex)  other=blake ;;
    blake) other=alex ;;
    *) return 1 ;;
  esac
  local canon; canon=$(_sd_canon "$content")
  local lit="📨 message from $other"
  [[ "$canon" == *"$lit"* ]]
}
