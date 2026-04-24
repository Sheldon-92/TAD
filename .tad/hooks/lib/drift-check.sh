#!/usr/bin/env bash
# drift-check.sh — TAD handoff lifecycle drift detector (Phase 1 P1.2, 2026-04-24)
#
# Runs 4 subchecks against a single snapshot of .tad/active/handoffs/:
#   a) slug_consistency  — handoff filename slug ↔ Required Evidence Manifest paths
#   b) zombie_handoffs   — git commit detected but handoff still in active/
#   c) supersedes_chains — supersedee still in active/ (propose archive)
#   d) ghost_tasks       — housekeeping-prefix handoff missing grounded_state
#
# Smoke alarm contract:
#   - Non-blocking, advisory only
#   - Never modifies files (report-only)
#   - Serial execution (deterministic output ordering)
#   - Failure-isolated (one subcheck dying ≠ others skipped)
#   - Additive findings (one handoff can trigger multiple subchecks)
#
# Output:
#   stdout — one JSON line per finding
#     {"subcheck":"...","handoff":"...","status":"ok|drift|info|error",
#      "message":"...","suggested_action":"..."}
#   stderr — one status line per decision + human-readable errors
#     [drift-check] {subcheck} {handoff} {status}
#
# Exit codes:
#   0 — checks completed (any drift count; drift is in stdout, NOT exit code)
#   1 — internal error (bad args, missing dep like jq, fatal)
#
# Usage:
#   drift-check.sh check-all              # run all 4 subchecks
#   drift-check.sh check <subcheck-name>  # run a single subcheck
#   drift-check.sh --help                 # show this help
#
# BSD-portable: grep -E, no grep -P, no awk gensub, no gdate, no EPOCHREALTIME.

set -uo pipefail

# ─── Constants ──────────────────────────────────────────────────────────
SCRIPT_VERSION="1.0.0"
ACTIVE_HANDOFFS_DIR=".tad/active/handoffs"
ARCHIVE_HANDOFFS_DIR=".tad/archive/handoffs"
CONFIG_FILE=".tad/config-workflow.yaml"

# ─── Defaults (overridden by config) ────────────────────────────────────
ZOMBIE_WINDOW_DAYS=60
GHOST_PREFIXES_DEFAULT='housekeeping
sync
rsync
cleanup
maintenance
audit
refresh'
GHOST_PREFIXES="$GHOST_PREFIXES_DEFAULT"

# ─── Config loading (best effort, falls back to defaults) ───────────────
_load_config() {
  if ! command -v yq >/dev/null 2>&1; then return 0; fi
  [ -r "$CONFIG_FILE" ] || return 0

  local window
  window=$(yq '.drift_check.zombie_window_days // 60' "$CONFIG_FILE" 2>/dev/null || echo 60)
  # Guard against yq returning "null" or non-numeric
  if [[ "$window" =~ ^[0-9]+$ ]]; then
    ZOMBIE_WINDOW_DAYS="$window"
  fi

  local prefixes
  prefixes=$(yq '.drift_check.ghost_task_prefixes[]' "$CONFIG_FILE" 2>/dev/null || true)
  if [ -n "$prefixes" ]; then
    GHOST_PREFIXES="$prefixes"
  fi
}

# ─── Argparse / help ────────────────────────────────────────────────────
_usage() {
  cat <<EOF
drift-check.sh v${SCRIPT_VERSION} — TAD handoff lifecycle drift detector

Usage:
  drift-check.sh check-all                # Run all 4 subchecks serially
  drift-check.sh check <subcheck-name>    # Run a single subcheck
  drift-check.sh --help | -h | help       # Show this help

Subchecks:
  slug_consistency    — handoff filename slug vs Required Evidence Manifest paths
  zombie_handoffs     — implementing git commit exists but handoff still active
  supersedes_chains   — supersedee handoff still in active/ (proposes archive)
  ghost_tasks         — housekeeping/audit/sync handoff missing grounded_state

Output (stdout): one JSON line per finding
  {"subcheck":...,"handoff":...,"status":ok|drift|info|error,
   "message":...,"suggested_action":...}

Exit codes:
  0 — completed (drift count NOT in exit code; read stdout JSON)
  1 — internal error
EOF
}

# ─── Helper: emit a JSON finding to stdout + stderr status line ──────────
# All args single-string; jq handles escaping.
_emit() {
  local subcheck="$1" handoff="$2" status="$3" message="$4" action="${5:-}"
  jq -nc \
    --arg sc "$subcheck" \
    --arg ho "$handoff" \
    --arg st "$status" \
    --arg msg "$message" \
    --arg act "$action" \
    '{subcheck:$sc,handoff:$ho,status:$st,message:$msg,suggested_action:$act}'
  printf '[drift-check] %s %s %s\n' "$subcheck" "$handoff" "$status" >&2
}

# Extract slug from HANDOFF-YYYYMMDD-<slug>.md filename
_slug_of() {
  # sed -E for BSD compatibility
  printf '%s' "$1" | sed -E 's/^HANDOFF-[0-9]{8}-(.+)\.md$/\1/'
}

# ─── P1.2.a — slug consistency ──────────────────────────────────────────
check_slug_consistency() {
  local handoffs="$1"
  while IFS= read -r handoff_path; do
    [ -z "$handoff_path" ] && continue
    local handoff_base slug
    handoff_base=$(basename "$handoff_path")
    slug=$(_slug_of "$handoff_base")

    # Look for "Required Evidence Manifest" anywhere in a heading
    # (accepts `## Required...`, `## 5. Required...`, `### N.N Required...`)
    if ! grep -qE '^##+.*Required Evidence Manifest' "$handoff_path" 2>/dev/null; then
      _emit slug_consistency "$handoff_base" info \
        "pre-manifest-era, slug check skipped" ""
      continue
    fi

    # Extract path: entries from the YAML code block under the section.
    # awk state machine: enters section at heading, enters yaml at ```yaml,
    # exits on closing ```.
    local manifest_paths
    manifest_paths=$(awk '
      /^##+.*Required Evidence Manifest/ { in_section = 1; next }
      in_section && /^```yaml/ { in_yaml = 1; next }
      in_section && in_yaml && /^```/ { in_yaml = 0; in_section = 0; exit }
      in_section && in_yaml && /path:/ { print }
    ' "$handoff_path")

    if [ -z "$manifest_paths" ]; then
      _emit slug_consistency "$handoff_base" info \
        "manifest section present but no path: entries extracted" ""
      continue
    fi

    # For each path line, strip leading indent + "- path: " / "path: " prefix,
    # then strip optional surrounding quotes.
    local cleaned_paths
    cleaned_paths=$(printf '%s' "$manifest_paths" \
      | sed -E 's/^[[:space:]]*-?[[:space:]]*path:[[:space:]]*//' \
      | sed -E 's/^"(.*)"$/\1/' \
      | sed -E "s/^'(.*)'$/\1/")

    # Minimal allowlist: shared project-level files are intentionally cross-handoff.
    # If a manifest path is one of these, slug check doesn't apply.
    # Pattern is anchored on absolute-ish relative paths; keep tight to avoid
    # accidentally muting real handoff-specific files.
    local ALLOWLIST_REGEX='^(\.tad/project-knowledge/|NEXT\.md$|PROJECT_CONTEXT\.md$|CHANGELOG\.md$|README\.md$|\.tad/config[-a-zA-Z0-9_]*\.yaml$|\.claude/skills/|\.tad/hooks/|\.tad/templates/)'

    local mismatches=""
    while IFS= read -r p; do
      [ -z "$p" ] && continue
      # Skip shared project-level paths (not handoff-specific by design)
      if printf '%s' "$p" | grep -qE "$ALLOWLIST_REGEX"; then
        continue
      fi
      if ! printf '%s' "$p" | grep -qF "$slug"; then
        mismatches="${mismatches}${p}; "
      fi
    done <<< "$cleaned_paths"

    if [ -n "$mismatches" ]; then
      _emit slug_consistency "$handoff_base" drift \
        "slug '$slug' missing in manifest path(s): ${mismatches%; }" \
        "review paths for typo, or canonicalize the handoff filename slug"
    else
      _emit slug_consistency "$handoff_base" ok \
        "all manifest paths contain slug" ""
    fi
  done <<< "$handoffs"
}

# ─── P1.2.b — zombie handoff detection ──────────────────────────────────
check_zombie_handoffs() {
  local handoffs="$1"

  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    _emit zombie_handoffs "*" error "not inside a git repo; zombie check cannot run" \
      "cd into a git repo before running drift-check"
    return 0
  fi

  while IFS= read -r handoff_path; do
    [ -z "$handoff_path" ] && continue
    local handoff_base slug
    handoff_base=$(basename "$handoff_path")
    slug=$(_slug_of "$handoff_base")

    # Identifier-boundary search to avoid false-positive substring match.
    # CR-P0-2: slug="auth" must NOT match "post-auth" or "pre-auth" commits.
    # `\b` won't work here — BSD grep treats '-' as a word boundary, so
    # `\bauth\b` WOULD match `post-auth` (boundary between '-' and 'a').
    # We define identifier chars as [A-Za-z0-9_-] and require the slug to be
    # surrounded by either start-of-string or a non-identifier char.
    # Pattern: (^|[^A-Za-z0-9_-])SLUG([^A-Za-z0-9_-]|$)
    # Example matches:    "feat(zombie-fix): ..."  (paren is non-id)
    # Example non-matches: "post-zombie-fix"        (dash is id char)
    local git_match
    git_match=$(git log --since="${ZOMBIE_WINDOW_DAYS} days ago" --format='%H %s' 2>/dev/null \
                | grep -iE "(^|[^A-Za-z0-9_-])${slug}([^A-Za-z0-9_-]|\$)" \
                | head -3 || true)

    # Secondary: is there a COMPLETION report in archive?
    local completion_found=false
    if compgen -G "${ARCHIVE_HANDOFFS_DIR}/COMPLETION-*${slug}*.md" >/dev/null 2>&1; then
      completion_found=true
    fi

    if [ -n "$git_match" ]; then
      if [ "$completion_found" = "true" ]; then
        _emit zombie_handoffs "$handoff_base" drift \
          "git commit(s) detected for slug '$slug' AND COMPLETION report archived — handoff should be moved" \
          "retrospective *accept (Alex moves $handoff_base to .tad/archive/handoffs/)"
      else
        _emit zombie_handoffs "$handoff_base" info \
          "git commit(s) detected for slug '$slug' but no COMPLETION report — verify state (half-done vs false match)" \
          "check commit history; either produce COMPLETION or rename handoff to disambiguate"
      fi
    else
      _emit zombie_handoffs "$handoff_base" ok \
        "no implementing commits in last ${ZOMBIE_WINDOW_DAYS} days" ""
    fi
  done <<< "$handoffs"
}

# ─── P1.2.c — Supersedes chain detection ────────────────────────────────
check_supersedes_chains() {
  local handoffs="$1"
  while IFS= read -r handoff_path; do
    [ -z "$handoff_path" ] && continue
    local handoff_base
    handoff_base=$(basename "$handoff_path")

    # Match both plain and bold-markdown formats (CR-P0-1):
    #   Supersedes: HANDOFF-xxx
    #   **Supersedes:** HANDOFF-xxx
    local sup_line
    sup_line=$(grep -E '^(\*\*)?Supersedes(\*\*)?:' "$handoff_path" 2>/dev/null | head -1 || true)

    if [ -z "$sup_line" ]; then
      _emit supersedes_chains "$handoff_base" ok "no Supersedes field" ""
      continue
    fi

    # Silent skip on clear placeholders (N/A / YYYYMMDD template / {slug} unresolved).
    # These appear in handoff drafts and template-reference sections — not real drift.
    if printf '%s' "$sup_line" | grep -qE 'N/A|YYYYMMDD|\{slug\}|\{.*\}'; then
      _emit supersedes_chains "$handoff_base" ok \
        "Supersedes placeholder / N/A (not a real reference)" ""
      continue
    fi

    # Extract HANDOFF name with loose regex; allow optional .md and link syntax.
    local supersedee
    supersedee=$(printf '%s' "$sup_line" \
                 | grep -oE 'HANDOFF-[0-9]{8}-[a-zA-Z0-9_-]+(\.md)?' \
                 | head -1 || true)

    if [ -z "$supersedee" ]; then
      _emit supersedes_chains "$handoff_base" info \
        "Supersedes field present but no HANDOFF name extracted" ""
      continue
    fi

    # Normalize to always include .md
    local supersedee_base="${supersedee%.md}.md"

    if [ -f "${ACTIVE_HANDOFFS_DIR}/${supersedee_base}" ]; then
      _emit supersedes_chains "$handoff_base" drift \
        "supersedes ${supersedee_base} but the older handoff is still in active/" \
        "archive ${supersedee_base} (human review, then /tad-maintain SYNC or mv)"
    else
      _emit supersedes_chains "$handoff_base" ok \
        "supersedee ${supersedee_base} already archived or not in active/" ""
    fi
  done <<< "$handoffs"
}

# ─── P1.2.d — Ghost task precheck ───────────────────────────────────────
check_ghost_tasks() {
  local handoffs="$1"

  # Build regex: "^(housekeeping|sync|rsync|...)-"
  local prefix_regex
  prefix_regex=$(printf '%s\n' "$GHOST_PREFIXES" \
                 | grep -v '^$' \
                 | tr '\n' '|' \
                 | sed 's/|$//')
  prefix_regex="^(${prefix_regex})-"

  while IFS= read -r handoff_path; do
    [ -z "$handoff_path" ] && continue
    local handoff_base slug
    handoff_base=$(basename "$handoff_path")
    slug=$(_slug_of "$handoff_base")

    if ! printf '%s' "$slug" | grep -qE "$prefix_regex"; then
      _emit ghost_tasks "$handoff_base" ok \
        "slug does not match housekeeping prefix pattern" ""
      continue
    fi

    # Slug matches — check for grounded_state in frontmatter.
    local has_grounded
    has_grounded=$(awk '
      BEGIN { started = 0; in_fm = 0 }
      NR == 1 && /^---[[:space:]]*$/ { in_fm = 1; started = 1; next }
      started && in_fm && /^---[[:space:]]*$/ { exit }
      in_fm && /^grounded_state:/ { print "yes"; exit }
    ' "$handoff_path")

    if [ "$has_grounded" = "yes" ]; then
      _emit ghost_tasks "$handoff_base" ok \
        "housekeeping slug has grounded_state field" ""
    else
      _emit ghost_tasks "$handoff_base" drift \
        "housekeeping-pattern slug '$slug' missing grounded_state field" \
        "Alex: add grounded_state frontmatter with snapshot of repo state at handoff creation (step0_5)"
    fi
  done <<< "$handoffs"
}

# ─── Pre-flight: jq required for JSON emission ──────────────────────────
if ! command -v jq >/dev/null 2>&1; then
  printf 'drift-check.sh: jq is required but not installed\n' >&2
  exit 1
fi

# ─── Dispatch ───────────────────────────────────────────────────────────
_load_config

case "${1:-}" in
  ""|--help|-h|help) _usage; exit 0 ;;
  check-all)
    # Single snapshot, ONCE, passed to each subcheck. No live-refresh.
    HANDOFF_SNAPSHOT=$(find "$ACTIVE_HANDOFFS_DIR" -maxdepth 1 -type f \
                        -name 'HANDOFF-*.md' 2>/dev/null | sort || true)

    # Fail isolation: each subcheck's failure emits error + continues.
    # set -uo pipefail (no -e) means one subcheck's failure doesn't exit the
    # script. The `|| _emit ... error ""` catch-all below is the safety net.
    check_slug_consistency "$HANDOFF_SNAPSHOT" \
      || _emit slug_consistency "*" error "subcheck internal error (see stderr)" ""
    check_zombie_handoffs "$HANDOFF_SNAPSHOT" \
      || _emit zombie_handoffs "*" error "subcheck internal error (see stderr)" ""
    check_supersedes_chains "$HANDOFF_SNAPSHOT" \
      || _emit supersedes_chains "*" error "subcheck internal error (see stderr)" ""
    check_ghost_tasks "$HANDOFF_SNAPSHOT" \
      || _emit ghost_tasks "*" error "subcheck internal error (see stderr)" ""
    exit 0
    ;;
  check)
    NAME="${2:-}"
    if [ -z "$NAME" ]; then
      printf 'drift-check.sh check: missing subcheck name\n' >&2
      _usage; exit 1
    fi
    HANDOFF_SNAPSHOT=$(find "$ACTIVE_HANDOFFS_DIR" -maxdepth 1 -type f \
                        -name 'HANDOFF-*.md' 2>/dev/null | sort || true)
    case "$NAME" in
      slug_consistency)   check_slug_consistency "$HANDOFF_SNAPSHOT" ;;
      zombie_handoffs)    check_zombie_handoffs "$HANDOFF_SNAPSHOT" ;;
      supersedes_chains)  check_supersedes_chains "$HANDOFF_SNAPSHOT" ;;
      ghost_tasks)        check_ghost_tasks "$HANDOFF_SNAPSHOT" ;;
      *)
        printf 'drift-check.sh: unknown subcheck: %s\n' "$NAME" >&2
        _usage; exit 1
        ;;
    esac
    exit 0
    ;;
  *)
    printf 'drift-check.sh: unknown command: %s\n' "$1" >&2
    _usage; exit 1
    ;;
esac
