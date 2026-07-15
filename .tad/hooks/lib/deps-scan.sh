#!/usr/bin/env bash
# deps-scan.sh — Upstream dependency scanner for TAD's dependency registry.
# Reads REGISTRY.yaml, queries upstream APIs (GitHub/npm/PyPI/Homebrew),
# writes raw results to scan-results.yaml. No LLM dependency — pure bash.
#
# Usage: bash .tad/hooks/lib/deps-scan.sh [<project-root>]
# Env:   REGISTRY_PATH  override registry file path (for testing)
#
# BSD/macOS safe. LC_ALL=C on sorts. No grep -P.
set -euo pipefail

SCANNER_VERSION="1.0.0"
MAX_CHANGELOG_CHARS=2000

# ──────────────── paths ────────────────
ROOT="${1:-.}"
REGISTRY="${REGISTRY_PATH:-$ROOT/.tad/dependencies/REGISTRY.yaml}"
OUTPUT="$ROOT/.tad/dependencies/scan-results.yaml"

if [ ! -f "$REGISTRY" ]; then
  echo "ERROR: registry not found: $REGISTRY" >&2
  exit 2
fi

# ──────────────── helpers ────────────────
log_info()    { echo "[deps-scan] $*" >&2; }
log_warning() { echo "[deps-scan] WARN: $*" >&2; }

validate_name() {
  [[ "$1" =~ ^[a-zA-Z0-9@/_.-]+$ ]]
}

validate_repo() {
  [[ "$1" =~ ^[a-zA-Z0-9._-]+/[a-zA-Z0-9._-]+$ ]]
}

sanitize_error() {
  local msg="$1"
  msg="${msg:0:200}"
  msg=$(printf '%s' "$msg" | sed -E 's/token=[^ ]*/token=REDACTED/g; s/ghp_[a-zA-Z0-9]*/ghp_REDACTED/g; s/gho_[a-zA-Z0-9]*/gho_REDACTED/g; s/Authorization:[^ ]*/Authorization:REDACTED/g')
  printf '%s' "$msg"
}

truncate_changelog() {
  local text="$1"
  local url="${2:-}"
  if [ "${#text}" -gt "$MAX_CHANGELOG_CHARS" ]; then
    text="${text:0:$MAX_CHANGELOG_CHARS}"
    if [ -n "$url" ]; then
      text="$text
[... truncated, full text at $url]"
    else
      text="$text
[... truncated]"
    fi
  fi
  printf '%s' "$text"
}

days_since() {
  local release_date="$1"
  if [ -z "$release_date" ] || [ "$release_date" = "null" ]; then
    echo "0"
    return
  fi
  local release_epoch today_epoch
  release_epoch=$(date -j -f "%Y-%m-%d" "${release_date:0:10}" "+%s" 2>/dev/null || echo "0")
  today_epoch=$(date "+%s")
  if [ "$release_epoch" -eq 0 ]; then
    echo "0"
    return
  fi
  echo $(( (today_epoch - release_epoch) / 86400 ))
}

# ──────────────── portable timeout ────────────────
TIMEOUT_CMD=""
if command -v gtimeout >/dev/null 2>&1; then
  TIMEOUT_CMD="gtimeout 15"
elif command -v timeout >/dev/null 2>&1; then
  TIMEOUT_CMD="timeout 15"
fi

run_with_timeout() {
  if [ -n "$TIMEOUT_CMD" ]; then
    $TIMEOUT_CMD "$@"
  else
    "$@"
  fi
}

# ──────────────── registry scanning ────────────────
SCAN_START=$(date "+%s")
TODAY=$(date "+%Y-%m-%d")
DEP_COUNT=$(yq '.dependencies | length' "$REGISTRY")
RESULTS_JSON="[]"

log_info "Scanning $DEP_COUNT dependencies from $REGISTRY"

for i in $(seq 0 $((DEP_COUNT - 1))); do
  name=$(yq -r ".dependencies[$i].name" "$REGISTRY")
  registry=$(yq -r ".dependencies[$i].upstream.registry" "$REGISTRY")
  repo=$(yq -r ".dependencies[$i].upstream.repo" "$REGISTRY")
  current_version=$(yq -r ".dependencies[$i].current_version" "$REGISTRY")
  changelog_url=$(yq -r ".dependencies[$i].upstream.changelog_url" "$REGISTRY")

  if ! validate_name "$name"; then
    log_warning "Invalid dependency name: $name — skipping"
    continue
  fi

  log_info "[$((i+1))/$DEP_COUNT] Scanning: $name (registry: $registry)"

  upstream_latest=""
  released=""
  changelog_text=""
  security_advisories="[]"
  scan_status="success"
  error_message=""

  case "$registry" in
    github_releases)
      if [ "$repo" = "null" ] || [ -z "$repo" ] || ! validate_repo "$repo"; then
        scan_status="error"
        error_message="github_releases requires valid upstream.repo (got: $repo)"
        log_warning "$name: $error_message"
      else
        release_json=$(run_with_timeout gh api "repos/$repo/releases/latest" 2>/dev/null) || {
          scan_status="error"
          error_message=$(sanitize_error "gh api failed for $repo")
          log_warning "$name: $error_message"
        }
        if [ "$scan_status" = "success" ] && [ -n "$release_json" ]; then
          upstream_latest=$(printf '%s' "$release_json" | jq -r '.tag_name // empty' 2>/dev/null || true)
          released=$(printf '%s' "$release_json" | jq -r '.published_at // empty' 2>/dev/null | cut -c1-10 || true)
          raw_changelog=$(printf '%s' "$release_json" | jq -r '.body // empty' 2>/dev/null || true)
          changelog_text=$(truncate_changelog "$raw_changelog" "$changelog_url")
        fi
      fi
      ;;

    homebrew)
      if ! command -v brew >/dev/null 2>&1; then
        scan_status="error"
        error_message="brew not found"
        log_warning "$name: $error_message"
      else
        brew_json=$(run_with_timeout brew info --json=v2 "$name" 2>/dev/null) || {
          scan_status="error"
          error_message=$(sanitize_error "brew info failed for $name")
          log_warning "$name: $error_message"
        }
        if [ "$scan_status" = "success" ] && [ -n "$brew_json" ]; then
          upstream_latest=$(printf '%s' "$brew_json" | jq -r '.formulae[0].versions.stable // empty' 2>/dev/null || true)
          if [ "$repo" != "null" ] && [ -n "$repo" ] && validate_repo "$repo"; then
            release_json=$(run_with_timeout gh api "repos/$repo/releases/latest" 2>/dev/null) || true
            if [ -n "$release_json" ]; then
              released=$(printf '%s' "$release_json" | jq -r '.published_at // empty' 2>/dev/null | cut -c1-10 || true)
              raw_changelog=$(printf '%s' "$release_json" | jq -r '.body // empty' 2>/dev/null || true)
              changelog_text=$(truncate_changelog "$raw_changelog" "$changelog_url")
            fi
          fi
        fi
      fi
      ;;

    npm)
      if ! command -v npm >/dev/null 2>&1; then
        scan_status="error"
        error_message="npm not found"
        log_warning "$name: $error_message"
      else
        upstream_latest=$(run_with_timeout npm view "$name" version 2>/dev/null) || {
          scan_status="error"
          error_message=$(sanitize_error "npm view failed for $name")
          log_warning "$name: $error_message"
        }
        if [ "$scan_status" = "success" ] && [ -n "$upstream_latest" ]; then
          modified_date=$(run_with_timeout npm view "$name" time.modified 2>/dev/null || true)
          if [ -n "$modified_date" ]; then
            released="${modified_date:0:10}"
          fi
        fi
      fi
      ;;

    pypi)
      pypi_json=$(run_with_timeout curl -sf "https://pypi.org/pypi/${name}/json" 2>/dev/null) || {
        scan_status="error"
        error_message=$(sanitize_error "curl pypi failed for $name")
        log_warning "$name: $error_message"
      }
      if [ "$scan_status" = "success" ] && [ -n "$pypi_json" ]; then
        upstream_latest=$(printf '%s' "$pypi_json" | jq -r '.info.version // empty' 2>/dev/null || true)
        released=$(printf '%s' "$pypi_json" | jq -r '[.releases | to_entries[] | select(.value | length > 0) | .value[0].upload_time_iso_8601] | sort | last // empty' 2>/dev/null | cut -c1-10 || true)
      fi
      ;;

    null|"null"|"")
      scan_status="skipped"
      error_message="no upstream registry configured"
      log_info "$name: skipped (no upstream registry)"
      ;;

    *)
      scan_status="skipped"
      error_message="unsupported registry type: $registry"
      log_warning "$name: $error_message"
      ;;
  esac

  # Security advisories (GitHub only, best-effort)
  if [ "$scan_status" = "success" ] && [ "$repo" != "null" ] && [ -n "$repo" ] && validate_repo "$repo"; then
    ecosystem=""
    case "$registry" in
      npm) ecosystem="NPM" ;;
      pypi) ecosystem="PIP" ;;
      *) ecosystem="" ;;
    esac
    if [ -n "$ecosystem" ]; then
      advisory_json=$(gh api graphql \
        -F eco="$ecosystem" \
        -F pkg="$name" \
        -f query='query($eco:SecurityAdvisoryEcosystem,$pkg:String!){
          securityVulnerabilities(first:5, ecosystem:$eco, package:$pkg) {
            nodes { advisory { summary severity } }
          }
        }' 2>/dev/null) || true
      if [ -n "$advisory_json" ]; then
        security_advisories=$(printf '%s' "$advisory_json" | jq '[.data.securityVulnerabilities.nodes[]? | {summary: .advisory.summary, severity: .advisory.severity}]' 2>/dev/null || echo "[]")
      fi
    fi
  fi

  # Version comparison
  version_changed="false"
  if [ "$scan_status" = "success" ] && [ -n "$upstream_latest" ] && [ -n "$current_version" ]; then
    clean_latest=$(printf '%s' "$upstream_latest" | sed 's/^v//')
    clean_current=$(printf '%s' "$current_version" | sed 's/^v//; s/\.x$//')
    if [ "$clean_latest" != "$clean_current" ]; then
      version_changed="true"
    fi
  fi

  # Days since release
  dsr=0
  if [ -n "$released" ] && [ "$released" != "null" ]; then
    dsr=$(days_since "$released")
  fi

  # Build result JSON entry (Option A: JSON → YAML)
  result_entry=$(jq -n \
    --arg dep "$name" \
    --arg status "$scan_status" \
    --arg err "$error_message" \
    --arg latest "$upstream_latest" \
    --arg rel "$released" \
    --argjson dsr "$dsr" \
    --arg cl "$changelog_text" \
    --argjson sec "$security_advisories" \
    --arg cur "$current_version" \
    --argjson vc "$([ "$version_changed" = "true" ] && echo "true" || echo "false")" \
    '{
      dependency: $dep,
      scan_status: $status,
      error_message: (if $err == "" then null else $err end),
      upstream_latest: (if $latest == "" then null else $latest end),
      released: (if $rel == "" then null else $rel end),
      days_since_release: $dsr,
      changelog_text: (if $cl == "" then null else $cl end),
      security_advisories: $sec,
      current_version: $cur,
      version_changed: $vc
    }')

  RESULTS_JSON=$(printf '%s' "$RESULTS_JSON" | jq --argjson entry "$result_entry" '. + [$entry]')
done

# ──────────────── write output (Option A: JSON → YAML) ────────────────
SCAN_END=$(date "+%s")
SCAN_DURATION=$((SCAN_END - SCAN_START))

FULL_JSON=$(jq -n \
  --arg ver "$SCANNER_VERSION" \
  --arg scan_date "$TODAY" \
  --argjson dur "$SCAN_DURATION" \
  --arg sver "$SCANNER_VERSION" \
  --argjson results "$RESULTS_JSON" \
  '{
    version: $ver,
    last_scan: $scan_date,
    scan_duration_seconds: $dur,
    scanner_version: $sver,
    results: $results
  }')

printf '%s' "$FULL_JSON" | yq -P '.' > "${OUTPUT}.tmp" && mv "${OUTPUT}.tmp" "$OUTPUT"

log_info "Scan complete: $DEP_COUNT deps in ${SCAN_DURATION}s → $OUTPUT"
