#!/bin/bash
# TAD Notebook Lifecycle — Dormant Status Recompute (library)
#
# Provides recompute_notebook_dormancy(): recompute each notebook's active/dormant
# status from `last_queried` vs the configured `dormant_after_days` threshold.
#
# CONTRACT (treat as load-bearing — consumed by notebook-dormant-sync.sh hook):
#   recompute_notebook_dormancy <registry_path>
#     - Updates ONLY non-archived entries; archived entries are never touched.
#     - active  → set when last_queried age <= dormant_after_days (boundary: <= keeps active)
#     - dormant → set when last_queried age >  dormant_after_days
#     - Per-entry targeting via yq (addresses entries by .id); the other entries stay
#       byte-identical. NEVER a blanket line-based substitution.
#     - Atomic write: compute to a .tmp file, then mv over the original (same-fs atomic).
#     - Threshold read from .tad/config-workflow.yaml research_notebook.dormant_after_days
#       (NOT hardcoded; falls back to 30 only if the config key is missing/unreadable).
#     - DERIVED STATE ONLY. This function is purely advisory hygiene. It must NEVER
#       block anything and must NEVER return a non-zero status that a caller treats as
#       a block decision. Any parse failure on an entry → skip that entry, keep going.
#     - Requires yq (mikefarah v4). If yq is absent the caller MUST no-op (this function
#       is only invoked once yq presence is confirmed). It does NOT fall back to sed.
#
# Returns: 0 always (function never signals failure upward).

# Recompute dormancy for all non-archived notebooks in the given registry file.
recompute_notebook_dormancy() {
  local registry="$1"
  local config="${2:-.tad/config-workflow.yaml}"

  # Guard: registry must exist and be non-empty.
  [ -f "$registry" ] || return 0
  [ -s "$registry" ] || return 0

  # Guard: yq is required for structure-aware editing. If somehow missing, no-op.
  command -v yq >/dev/null 2>&1 || return 0

  # Read threshold from config (do NOT hardcode 30). Fall back to 30 only if missing.
  local threshold=""
  if [ -f "$config" ]; then
    threshold=$(yq -r '.research_notebook.dormant_after_days // ""' "$config" 2>/dev/null) || threshold=""
  fi
  case "$threshold" in
    ''|*[!0-9]*) threshold=30 ;;   # missing or non-numeric → default 30
  esac

  local now_epoch
  now_epoch=$(date "+%s" 2>/dev/null) || return 0

  # Collect ids + last_queried + current status for every non-archived entry.
  # Compact one-record-per-line (id<TAB>last_queried<TAB>status) — but use a delimiter
  # that won't collide; ids/dates are simple tokens so a tab is safe here.
  local rows
  rows=$(yq -r '.notebooks[] | select(.status != "archived") | [.id, (.last_queried // ""), (.status // "")] | @tsv' "$registry" 2>/dev/null) || return 0
  [ -n "$rows" ] || return 0

  # Build the list of (id -> desired status) changes; only entries whose status
  # actually changes get written.
  local changed=0
  local tmp="${registry}.tmp.$$"

  # Work on a copy so the live file is only replaced atomically at the very end,
  # and only if at least one entry changed.
  cp "$registry" "$tmp" 2>/dev/null || return 0

  local id last_queried cur_status
  while IFS=$'\t' read -r id last_queried cur_status; do
    [ -n "$id" ] || continue
    [ -n "$last_queried" ] || continue   # no last_queried → cannot compute → skip

    # BSD-safe date parse (macOS `date -j -f` first, GNU `date -d` fallback).
    local lq_epoch
    lq_epoch=$(date -j -f "%Y-%m-%d" "$last_queried" "+%s" 2>/dev/null \
            || date -d "$last_queried" "+%s" 2>/dev/null) || continue   # parse fail → skip
    [ -n "$lq_epoch" ] || continue

    # Future last_queried (clock skew / typo): age would be negative → treat as active.
    local age_days
    age_days=$(( ( now_epoch - lq_epoch ) / 86400 ))

    local desired
    if [ "$age_days" -gt "$threshold" ]; then
      desired="dormant"
    else
      desired="active"
    fi

    # Only edit when the persisted status actually differs (per-entry targeting).
    if [ "$cur_status" != "$desired" ]; then
      # Address the entry by id and set ONLY its .status field. yq leaves the rest intact.
      ID="$id" STATUS="$desired" \
        yq -i '(.notebooks[] | select(.id == env(ID)) | .status) = env(STATUS)' "$tmp" 2>/dev/null \
        && changed=1
    fi
  done <<EOF
$rows
EOF

  # Atomic replace only if something changed and the tmp file is still valid YAML.
  if [ "$changed" -eq 1 ]; then
    if yq -e '.notebooks' "$tmp" >/dev/null 2>&1; then
      mv "$tmp" "$registry" 2>/dev/null || rm -f "$tmp" 2>/dev/null
    else
      rm -f "$tmp" 2>/dev/null   # corrupted somehow → discard, keep original
    fi
  else
    rm -f "$tmp" 2>/dev/null
  fi

  return 0
}
