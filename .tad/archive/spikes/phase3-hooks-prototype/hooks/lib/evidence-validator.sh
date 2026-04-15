#!/usr/bin/env bash
# evidence-validator.sh — H-009 manifest structure check + KG-001 mtime freshness
# v3-LEAN §1.1 evidence manifest + §7.1 KG-001
# Functions:
#   validate_manifest <manifest_id> <handoff_slug> <handoff_path>
#     → 0 satisfied | 1 missing (list of missing files on stderr)

# shellcheck shell=bash
set -uo pipefail

: "${EVIDENCE_VALIDATOR_LOADED:=0}"
if [[ "$EVIDENCE_VALIDATOR_LOADED" == "1" ]]; then return 0 2>/dev/null || exit 0; fi
EVIDENCE_VALIDATOR_LOADED=1

EV_SCHEMA="${EV_SCHEMA:-.tad/schemas/evidence-manifest.yaml}"

# Get mtime in seconds (portable: Linux stat -c, macOS stat -f)
_ev_mtime() {
  local f="$1"
  if stat -c %Y "$f" 2>/dev/null; then return 0; fi
  stat -f %m "$f" 2>/dev/null || echo 0
}

# Check if file content matches anchor outside ``` fences.
# Returns 0 if anchor found outside fence, 1 otherwise.
_ev_anchor_outside_fence() {
  local file="$1" anchor="$2"
  [[ ! -f "$file" ]] && return 1
  perl -CSD -e '
    my ($file, $anchor) = @ARGV;
    open(my $fh, "<:utf8", $file) or exit 1;
    my $in_fence = 0;
    while (my $line = <$fh>) {
      if ($line =~ /^```/) { $in_fence = !$in_fence; next; }
      next if $in_fence;
      if ($line =~ /$anchor/) { exit 0 }
    }
    exit 1
  ' -- "$file" "$anchor"
}

# Expand a manifest pattern with ${handoff_slug} and check requirements.
# Returns 0 if requirement satisfied, 1 otherwise.
# Writes missing-reason to stderr on failure.
_ev_check_requirement() {
  local req_json="$1" slug="$2" handoff_path="$3"
  local pattern min_count min_bytes anchor must_contain outside_fence
  pattern=$(printf '%s' "$req_json" | yq -p=json -r '.pattern')
  min_count=$(printf '%s' "$req_json" | yq -p=json -r '.min_count // 1')
  min_bytes=$(printf '%s' "$req_json" | yq -p=json -r '.min_bytes // 0')
  anchor=$(printf '%s' "$req_json" | yq -p=json -r '.anchor // ""')
  must_contain=$(printf '%s' "$req_json" | yq -p=json -r '.must_contain // ""')
  outside_fence=$(printf '%s' "$req_json" | yq -p=json -r '.anchor_outside_fence // false')

  # Expand ${handoff_slug}
  local expanded="${pattern//\$\{handoff_slug\}/$slug}"

  # Glob expand — BSD bash: use find or globbing w/ nullglob
  shopt -s nullglob globstar 2>/dev/null || true
  local files=()
  # shellcheck disable=SC2206
  files=( $expanded )

  if (( ${#files[@]} < min_count )); then
    printf 'EVIDENCE_MISSING: pattern=%s expanded=%s found=%d min=%d\n' \
      "$pattern" "$expanded" "${#files[@]}" "$min_count" >&2
    return 1
  fi

  local f size ho_mtime f_mtime
  # Handoff mtime for freshness
  ho_mtime=0
  if [[ -n "$handoff_path" && -f "$handoff_path" ]]; then
    ho_mtime=$(_ev_mtime "$handoff_path")
  fi

  local count_ok=0
  for f in "${files[@]}"; do
    [[ ! -f "$f" ]] && continue
    if (( min_bytes > 0 )); then
      size=$(wc -c < "$f" 2>/dev/null | tr -d ' ')
      if (( size < min_bytes )); then
        printf 'EVIDENCE_TOO_SMALL: %s (%d < %d)\n' "$f" "$size" "$min_bytes" >&2
        continue
      fi
    fi
    if [[ -n "$anchor" ]]; then
      if [[ "$outside_fence" == "true" ]]; then
        if ! _ev_anchor_outside_fence "$f" "$anchor"; then
          printf 'EVIDENCE_ANCHOR_FENCED_OR_MISSING: %s anchor="%s"\n' "$f" "$anchor" >&2
          continue
        fi
      else
        if ! perl -CSD -ne 'BEGIN { $a = shift @ARGV } if (/$a/) { exit 0 } END { exit 1 }' "$anchor" < "$f"; then
          printf 'EVIDENCE_ANCHOR_MISSING: %s anchor="%s"\n' "$f" "$anchor" >&2
          continue
        fi
      fi
    fi
    if [[ -n "$must_contain" ]]; then
      if ! grep -qF -- "$must_contain" "$f" 2>/dev/null; then
        printf 'EVIDENCE_STRING_MISSING: %s must_contain="%s"\n' "$f" "$must_contain" >&2
        continue
      fi
    fi
    # KG-001 freshness: evidence mtime >= handoff mtime
    if (( ho_mtime > 0 )); then
      f_mtime=$(_ev_mtime "$f")
      if (( f_mtime < ho_mtime )); then
        printf 'EVIDENCE_STALE: %s mtime(%d) < handoff mtime(%d)\n' "$f" "$f_mtime" "$ho_mtime" >&2
        continue
      fi
    fi
    count_ok=$(( count_ok + 1 ))
  done

  if (( count_ok < min_count )); then
    printf 'EVIDENCE_COUNT_INSUFFICIENT: pattern=%s valid=%d required=%d\n' \
      "$pattern" "$count_ok" "$min_count" >&2
    return 1
  fi
  return 0
}

# Main validate entry.
validate_manifest() {
  local manifest_id="$1" slug="${2:-}" handoff_path="${3:-}"
  [[ -z "$manifest_id" ]] && return 1
  if [[ -z "$slug" ]]; then
    printf 'EVIDENCE_ERROR: handoff_slug empty\n' >&2
    return 1
  fi
  if [[ ! -f "$EV_SCHEMA" ]]; then
    printf 'EVIDENCE_ERROR: schema missing: %s\n' "$EV_SCHEMA" >&2
    return 1
  fi

  # Read requirement list as JSON array
  local reqs
  reqs=$(yq -o=json ".${manifest_id}.required" "$EV_SCHEMA" 2>/dev/null || echo 'null')
  if [[ "$reqs" == "null" || -z "$reqs" ]]; then
    printf 'EVIDENCE_ERROR: manifest_id=%s not found in %s\n' "$manifest_id" "$EV_SCHEMA" >&2
    return 1
  fi

  local n i req all_ok=1
  n=$(printf '%s' "$reqs" | yq -p=json -r 'length' 2>/dev/null || echo 0)
  for ((i=0; i<n; i++)); do
    req=$(printf '%s' "$reqs" | yq -p=json -o=json ".[${i}]" 2>/dev/null)
    if ! _ev_check_requirement "$req" "$slug" "$handoff_path"; then
      all_ok=0
    fi
  done

  if [[ "$all_ok" == "1" ]]; then
    return 0
  fi
  return 1
}
