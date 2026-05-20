#!/bin/bash
# Sync TAD v2.8.4 to all registered projects per release-runbook Phase 5-7
# One-off script — committed for reproducibility.
#
# Usage:
#   bash .tad/scripts/sync-v2.8.4.sh [--dry-run] [--project <name>]
#
# --dry-run : print actions but don't execute
# --project : sync only the specified project (by name)

set -uo pipefail

NEW_VERSION="2.8.4"
TAD_SRC="$(cd "$(dirname "$0")/../.." && pwd)"
REGISTRY="${TAD_SRC}/.tad/sync-registry.yaml"
DEPRECATION="${TAD_SRC}/.tad/deprecation.yaml"

DRY_RUN=false
ONLY_PROJECT=""
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --project=*) ONLY_PROJECT="${arg#*=}" ;;
    --project) shift; ONLY_PROJECT="${1:-}" ;;
  esac
done

# Framework subdirs to full-refresh (mirror tad.sh::copy_framework_files)
FW_DIRS=(agents data domains gates guides hooks ralph-config references schemas skills sub-agents tasks templates workflows)

# Zero-touch — never modify
ZERO_TOUCH_RE='^(project-knowledge|active|archive|evidence|pair-testing|decisions)$'

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log()  { printf "${BLUE}[INFO]${NC} %s\n" "$*"; }
ok()   { printf "${GREEN}[ OK ]${NC} %s\n" "$*"; }
warn() { printf "${YELLOW}[WARN]${NC} %s\n" "$*"; }
err()  { printf "${RED}[FAIL]${NC} %s\n" "$*"; }

run() {
  if $DRY_RUN; then
    printf "${YELLOW}[DRY ]${NC} %s\n" "$*"
  else
    eval "$@"
  fi
}

# ============================================
# Pre-flight
# ============================================
[ -f "$REGISTRY" ] || { err "registry not found: $REGISTRY"; exit 1; }
[ -f "$DEPRECATION" ] || { err "deprecation.yaml not found"; exit 1; }
[ "$(cat "$TAD_SRC/.tad/version.txt" | tr -d '[:space:]')" = "$NEW_VERSION" ] || { err "source version != $NEW_VERSION"; exit 1; }

log "TAD source: $TAD_SRC"
log "New version: $NEW_VERSION"
log "Registry: $REGISTRY"
$DRY_RUN && warn "DRY RUN MODE — no actual changes will be made"

# ============================================
# Get list of files to delete from deprecation.yaml for this version
# ============================================
get_deprecated_files() {
  yq -r ".deprecations.\"$NEW_VERSION\".files[]?" "$DEPRECATION" 2>/dev/null
}
DEPRECATED_FILES=$(get_deprecated_files)
log "Deprecated files for $NEW_VERSION: $(echo "$DEPRECATED_FILES" | wc -l | tr -d ' ') (typically 0 for in-file changes)"

# ============================================
# Per-project sync
# ============================================
sync_project() {
  local proj_path="$1" proj_name="$2" claude_md_strategy="$3"

  echo ""
  echo "═══════════════════════════════════════════════════════════════"
  log "Syncing project: $proj_name"
  log "  Path: $proj_path"
  log "  CLAUDE.md strategy: $claude_md_strategy"
  echo "───────────────────────────────────────────────────────────────"

  # Path validation
  if [ ! -d "$proj_path" ]; then
    err "  Path does not exist — SKIPPED"
    return 1
  fi
  if [ ! -d "$proj_path/.tad" ]; then
    err "  .tad/ directory missing — SKIPPED (project may not have TAD installed)"
    return 1
  fi

  # 1. Backup .claude/settings.json
  if [ -f "$proj_path/.claude/settings.json" ]; then
    run "cp \"$proj_path/.claude/settings.json\" \"$proj_path/.claude/settings.json.bak.v2.8.3\""
    ok "  Backed up .claude/settings.json → .bak.v2.8.3"
  fi

  # 2. Full refresh framework subdirs
  for d in "${FW_DIRS[@]}"; do
    if [ -d "$TAD_SRC/.tad/$d" ]; then
      run "rm -rf \"$proj_path/.tad/$d\""
      run "cp -R \"$TAD_SRC/.tad/$d\" \"$proj_path/.tad/$d\""
    fi
  done
  ok "  Framework dirs refreshed (${#FW_DIRS[@]} dirs)"

  # 3. Top-level .tad/ config files (yaml/md/txt) — copy individual files only
  while IFS= read -r f; do
    local fname=$(basename "$f")
    run "cp \"$f\" \"$proj_path/.tad/$fname\""
  done < <(find "$TAD_SRC/.tad" -maxdepth 1 -type f \( -name "*.yaml" -o -name "*.md" -o -name "*.txt" \))
  ok "  Top-level .tad/ config files copied"

  # 4. .claude/skills/ full refresh
  if [ -d "$TAD_SRC/.claude/skills" ]; then
    # Identify TAD-owned skill dirs (everything in source); preserve project-custom skills if any
    while IFS= read -r src_skill; do
      local skill_name=$(basename "$src_skill")
      if [ -d "$src_skill" ]; then
        run "rm -rf \"$proj_path/.claude/skills/$skill_name\""
        run "cp -R \"$src_skill\" \"$proj_path/.claude/skills/$skill_name\""
      fi
    done < <(find "$TAD_SRC/.claude/skills" -mindepth 1 -maxdepth 1 -type d)
    ok "  .claude/skills/ refreshed"
  fi

  # 5. tad.sh + docs/MULTI-PLATFORM.md (root-level framework files)
  for rf in tad.sh docs/MULTI-PLATFORM.md; do
    if [ -f "$TAD_SRC/$rf" ]; then
      local target_dir=$(dirname "$proj_path/$rf")
      run "mkdir -p \"$target_dir\""
      run "cp \"$TAD_SRC/$rf\" \"$proj_path/$rf\""
    fi
  done
  ok "  tad.sh + docs/MULTI-PLATFORM.md copied"

  # 6. Apply deprecations from deprecation.yaml ≤ NEW_VERSION
  while IFS= read -r dep_file; do
    if [ -n "$dep_file" ] && [ -e "$proj_path/$dep_file" ]; then
      run "rm -rf \"$proj_path/$dep_file\""
      ok "  Deleted deprecated: $dep_file"
    fi
  done <<< "$DEPRECATED_FILES"

  # 7. CLAUDE.md per strategy
  if [ "$claude_md_strategy" = "overwrite" ]; then
    if [ -f "$TAD_SRC/CLAUDE.md" ]; then
      run "cp \"$TAD_SRC/CLAUDE.md\" \"$proj_path/CLAUDE.md\""
      ok "  CLAUDE.md overwritten"
    fi
  elif [ "$claude_md_strategy" = "merge" ]; then
    local marker='<!-- TAD:PROJECT-CONTENT-BELOW -->'
    if [ ! -f "$proj_path/CLAUDE.md" ]; then
      warn "  CLAUDE.md missing in project — copying TAD source as fallback"
      run "cp \"$TAD_SRC/CLAUDE.md\" \"$proj_path/CLAUDE.md\""
    elif grep -qF "$marker" "$proj_path/CLAUDE.md"; then
      # Backup original
      run "cp \"$proj_path/CLAUDE.md\" \"$proj_path/CLAUDE.md.bak.v2.8.3\""
      # Find marker line, take everything from marker onwards from project, prepend with TAD source up to and excluding the marker
      if ! $DRY_RUN; then
        local proj_below=$(awk "/$marker/,EOF" "$proj_path/CLAUDE.md")
        cat "$TAD_SRC/CLAUDE.md" > "$proj_path/CLAUDE.md.new"
        printf '\n%s\n' "$proj_below" >> "$proj_path/CLAUDE.md.new"
        mv "$proj_path/CLAUDE.md.new" "$proj_path/CLAUDE.md"
      fi
      ok "  CLAUDE.md merged (marker preserved)"
    else
      warn "  CLAUDE.md merge marker not found — leaving project CLAUDE.md untouched (user must add '$marker' to enable merge)"
    fi
  fi

  # 8. .claude/settings.json — JSON merge (preserve project hooks; only update TAD-owned)
  if [ -f "$TAD_SRC/.claude/settings.json" ] && [ -f "$proj_path/.claude/settings.json" ]; then
    if ! $DRY_RUN; then
      # Use --argjson with command substitution per release-runbook (jq 1.7+)
      local src_json
      src_json=$(cat "$TAD_SRC/.claude/settings.json")
      # Take project settings.json, then overlay TAD-owned hooks (UserPromptSubmit, SessionStart, PostToolUse, PreToolUse) from source
      jq -s '
        .[0] as $src | .[1] as $tgt |
        $tgt
        | .hooks.UserPromptSubmit = ($src.hooks.UserPromptSubmit // $tgt.hooks.UserPromptSubmit)
        | .hooks.SessionStart = ($src.hooks.SessionStart // $tgt.hooks.SessionStart)
        | .hooks.PostToolUse = ($src.hooks.PostToolUse // $tgt.hooks.PostToolUse)
        | .hooks.PreToolUse = ($src.hooks.PreToolUse // $tgt.hooks.PreToolUse)
      ' "$TAD_SRC/.claude/settings.json" "$proj_path/.claude/settings.json" > "$proj_path/.claude/settings.json.new" \
        && mv "$proj_path/.claude/settings.json.new" "$proj_path/.claude/settings.json"
    fi
    ok "  .claude/settings.json TAD-hooks merged (project hooks preserved)"
  elif [ ! -f "$proj_path/.claude/settings.json" ]; then
    if [ -f "$TAD_SRC/.claude/settings.json" ]; then
      run "mkdir -p \"$proj_path/.claude\""
      run "cp \"$TAD_SRC/.claude/settings.json\" \"$proj_path/.claude/settings.json\""
      ok "  .claude/settings.json copied (project had none)"
    fi
  fi

  # 9. Update target version.txt (final step)
  run "echo \"$NEW_VERSION\" > \"$proj_path/.tad/version.txt\""
  ok "  .tad/version.txt → $NEW_VERSION"

  # 10. Phase 7 verify (per release-runbook)
  echo "───────────────────────────────────────────────────────────────"
  log "  Phase 7 verify:"

  local v_mismatch=false v_dep_remain=false

  # 7.1 Version match
  local target_ver=$(cat "$proj_path/.tad/version.txt" 2>/dev/null | tr -d '[:space:]')
  if [ "$target_ver" = "$NEW_VERSION" ]; then
    ok "    Version: $target_ver ✓"
  else
    err "    Version mismatch: '$target_ver' (expected $NEW_VERSION)"
    v_mismatch=true
  fi

  # 7.2-7.4: Router ecosystem checks removed (Domain Pack keyword router deprecated v2.17)
  # Router files (.tad/hooks/userprompt-domain-router.sh, keywords.yaml) are now in deprecation.yaml
  # for downstream cleanup via *sync. Capability Packs (.claude/skills/) replaced this functionality.

  # 7.5 No deprecated files (post-cleanup)
  while IFS= read -r dep_file; do
    if [ -n "$dep_file" ] && [ -e "$proj_path/$dep_file" ]; then
      err "    Deprecated file still present: $dep_file"
      v_dep_remain=true
    fi
  done <<< "$DEPRECATED_FILES"
  $v_dep_remain || ok "    No deprecated files remain ✓"

  # 7.6: Router smoke test removed (Domain Pack keyword router deprecated v2.17)

  # Summary
  echo "───────────────────────────────────────────────────────────────"
  if ! $v_mismatch && ! $v_hook_missing && ! $v_settings_hook_bad && ! $v_smoke_fail && ! $v_dep_remain; then
    ok "  ✅ $proj_name SYNCED + VERIFIED"
    return 0
  else
    err "  ⚠️  $proj_name SYNCED with warnings (review above)"
    return 2
  fi
}

# ============================================
# Iterate registry
# ============================================
echo ""
log "Iterating projects from $REGISTRY"

PROJECT_COUNT=$(yq '.projects | length' "$REGISTRY")
log "Total projects: $PROJECT_COUNT"

PASS=0
FAIL=0
WARN=0

for i in $(seq 0 $((PROJECT_COUNT - 1))); do
  proj_path=$(yq -r ".projects[$i].path" "$REGISTRY")
  proj_name=$(yq -r ".projects[$i].name" "$REGISTRY")
  claude_md_strategy=$(yq -r ".projects[$i].claude_md_strategy // \"overwrite\"" "$REGISTRY")

  if [ -n "$ONLY_PROJECT" ] && [ "$proj_name" != "$ONLY_PROJECT" ]; then
    continue
  fi

  if sync_project "$proj_path" "$proj_name" "$claude_md_strategy"; then
    PASS=$((PASS + 1))
  else
    rc=$?
    if [ "$rc" = "2" ]; then
      WARN=$((WARN + 1))
    else
      FAIL=$((FAIL + 1))
    fi
  fi
done

# ============================================
# Final summary
# ============================================
echo ""
echo "════════════════════════════════════════════════════════════════"
echo "Sync v$NEW_VERSION Summary"
echo "════════════════════════════════════════════════════════════════"
ok "  PASS: $PASS"
[ "$WARN" -gt 0 ] && warn "  WARN: $WARN (synced with warnings)"
[ "$FAIL" -gt 0 ] && err "  FAIL: $FAIL"

if [ "$FAIL" -gt 0 ]; then
  err "Some projects FAILED — investigate before declaring release done"
  exit 1
fi

if ! $DRY_RUN; then
  log "Updating sync-registry.yaml last_synced_version + date for all 12 projects..."
  # Update via sed (BSD-compatible — no -i without backup)
  sed -i.bak \
    -e "s/last_synced_version: \"2.8.3\"/last_synced_version: \"$NEW_VERSION\"/g" \
    -e "s/last_synced_date: \"2026-04-15\"/last_synced_date: \"$(date +%Y-%m-%d)\"/g" \
    -e "s/last_synced_date: \"2026-04-19\"/last_synced_date: \"$(date +%Y-%m-%d)\"/g" \
    "$REGISTRY"
  rm -f "${REGISTRY}.bak"
  ok "Registry updated"
fi

ok "v$NEW_VERSION sync complete"
