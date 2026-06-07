#!/usr/bin/env bash
# TAD v2.24.0 sync — mixed strategy, per release-runbook Phases 5-7.
# Continue-on-error: uses `set -u` (NOT `set -e`) — one project failing must NOT abort the rest.
# OVERWRITES framework files in downstream projects. Zero-touch dirs are NEVER touched.
# Generated for: 14 projects in .tad/sync-registry.yaml.
set -u

VERSION="2.24.0"
SRC="/Users/sheldonzhao/01-on progress programs/TAD"
REGISTRY="$SRC/.tad/sync-registry.yaml"
DEPRECATION="$SRC/.tad/deprecation.yaml"

# Framework dirs derived live (single source of truth) MINUS capability-packs (registry-only handling).
FRAMEWORK_DIRS=()
while IFS= read -r d; do
  [ -z "$d" ] && continue
  [ "$d" = "capability-packs" ] && continue
  FRAMEWORK_DIRS+=("$d")
done < <(bash "$SRC/.tad/hooks/lib/derive-sync-set.sh" --dirs)

echo "=== TAD v$VERSION SYNC ==="
echo "Source: $SRC"
echo "Framework dirs (${#FRAMEWORK_DIRS[@]}, capability-packs excluded): ${FRAMEWORK_DIRS[*]}"
echo

# Parse registry: emit "path|name|strategy" per project (block-scalar aware via awk).
parse_registry() {
  awk '
    /^[[:space:]]*- path:/ {
      if (have) print path "|" name "|" strat
      have=1; name=""; strat=""
      line=$0; sub(/^[^"]*"/,"",line); sub(/"[[:space:]]*$/,"",line); path=line; next
    }
    /^[[:space:]]*name:/ && have {
      line=$0; sub(/^[^"]*"/,"",line); sub(/"[[:space:]]*$/,"",line); name=line; next
    }
    /^[[:space:]]*claude_md_strategy:/ && have {
      line=$0; sub(/^[^"]*"/,"",line); sub(/"[[:space:]]*$/,"",line); strat=line; next
    }
    END { if (have) print path "|" name "|" strat }
  ' "$REGISTRY"
}

# Collect deprecation files for versions <= 2.24.0 (numeric semver compare).
ver_le() {
  # returns 0 if $1 <= $2
  printf '%s\n%s\n' "$1" "$2" | sort -V -C
}
DEP_FILES=()
while IFS= read -r line; do
  DEP_FILES+=("$line")
done < <(
  awk -v MAX="$VERSION" '
    function ver_le(a,b,   na,nb,i,x,y) {
      split(a,na,"."); split(b,nb,".")
      for(i=1;i<=3;i++){ x=na[i]+0; y=nb[i]+0; if(x<y)return 1; if(x>y)return 0 }
      return 1
    }
    /^[[:space:]]{2}"[0-9]+\.[0-9]+\.[0-9]+":[[:space:]]*$/ {
      v=$0; gsub(/[^0-9.]/,"",v); cur=v; infiles=0; ok=ver_le(cur,MAX); next
    }
    /^[[:space:]]{4}files:/ { if(ok) infiles=1; else infiles=0; next }
    /^[[:space:]]{4}[a-z]/  { infiles=0 }   # any other 4-space key ends files block
    infiles && /^[[:space:]]{6}-[[:space:]]/ {
      f=$0; sub(/^[[:space:]]*-[[:space:]]*/,"",f); gsub(/"/,"",f); gsub(/[[:space:]]*$/,"",f)
      if(f!="") print f
    }
  ' "$DEPRECATION" | sort -u
)
echo "Deprecation files to clean (<= $VERSION): ${#DEP_FILES[@]}"
echo

OVERALL_LOG=""

while IFS='|' read -r target name strategy; do
  [ -z "$target" ] && continue
  echo "######################################################################"
  echo "## PROJECT: $name"
  echo "## PATH:    $target"
  echo "## STRATEGY (CLAUDE.md): $strategy"
  echo "######################################################################"

  PACK_OK=0; PACK_FAIL=0
  CLAUDE_RESULT="-"
  GATE_VERDICT="-"
  STATUS="ok"

  # --- a. PATH VALIDATION ---
  if [ ! -d "$target/.tad" ]; then
    echo "[SKIP] $target/.tad missing — skipping project."
    OVERALL_LOG+="$name|SKIPPED|.tad missing"$'\n'
    echo
    continue
  fi

  # --- b. FRAMEWORK FULL-REFRESH (each derived dir except capability-packs) ---
  echo "[b] Framework full-refresh..."
  for d in "${FRAMEWORK_DIRS[@]}"; do
    if [ -d "$SRC/.tad/$d" ]; then
      rm -rf "$target/.tad/$d"
      cp -R "$SRC/.tad/$d" "$target/.tad/$d" \
        && echo "    refreshed .tad/$d" \
        || { echo "    [ERR] cp .tad/$d failed"; STATUS="partial"; }
    else
      echo "    [WARN] source .tad/$d missing — skipped"
    fi
  done

  # --- c. CAPABILITY-PACKS = REGISTRY-ONLY ---
  echo "[c] capability-packs registry-only..."
  mkdir -p "$target/.tad/capability-packs"
  for f in pack-registry.yaml deliverable-rubrics.yaml pack-collisions.yaml; do
    if [ -f "$SRC/.tad/capability-packs/$f" ]; then
      cp "$SRC/.tad/capability-packs/$f" "$target/.tad/capability-packs/$f" \
        && echo "    copied $f" \
        || { echo "    [ERR] cp $f failed"; STATUS="partial"; }
    fi
  done

  # --- d. .claude/skills FULL-REFRESH + workflows ---
  echo "[d] .claude/skills full-refresh + workflows..."
  if [ -d "$SRC/.claude/skills" ]; then
    mkdir -p "$target/.claude"
    rm -rf "$target/.claude/skills"
    cp -R "$SRC/.claude/skills" "$target/.claude/skills" \
      && echo "    refreshed .claude/skills" \
      || { echo "    [ERR] cp .claude/skills failed"; STATUS="partial"; }
  fi
  mkdir -p "$target/.claude/workflows"
  for wf in "$SRC"/.claude/workflows/*.workflow.js; do
    [ -e "$wf" ] || continue
    cp "$wf" "$target/.claude/workflows/" \
      && echo "    copied workflow $(basename "$wf")" \
      || { echo "    [ERR] cp workflow $(basename "$wf") failed"; STATUS="partial"; }
  done

  # --- e. settings.json JSON-MERGE (preserve non-TAD hooks; only update TAD-owned events) ---
  echo "[e] settings.json merge..."
  SRC_SETTINGS="$SRC/.claude/settings.json"
  TGT_SETTINGS="$target/.claude/settings.json"
  if [ ! -f "$TGT_SETTINGS" ]; then
    if [ -f "$SRC_SETTINGS" ]; then
      cp "$SRC_SETTINGS" "$TGT_SETTINGS" && echo "    no target settings.json — copied source"
    fi
  else
    cp "$TGT_SETTINGS" "$TGT_SETTINGS.bak" && echo "    backed up settings.json -> .bak"
    # TAD-owned hook events: SessionStart, PreToolUse, PostToolUse.
    # Merge: for each TAD-owned event, set target's array to source's; preserve all other
    # event keys (e.g. UserPromptSubmit custom) and the rest of the target file (permissions etc).
    SRC_HOOKS=$(jq -c '.hooks // {}' "$SRC_SETTINGS")
    if jq --argjson sh "$SRC_HOOKS" '
          .hooks = ((.hooks // {}) as $t
            | $t
            + (["SessionStart","PreToolUse","PostToolUse"]
                | map({(.): ($sh[.])})
                | add
                | with_entries(select(.value != null))))
        ' "$TGT_SETTINGS.bak" > "$TGT_SETTINGS.tmp" 2>/dev/null \
       && [ -s "$TGT_SETTINGS.tmp" ]; then
      mv "$TGT_SETTINGS.tmp" "$TGT_SETTINGS"
      echo "    merged TAD-owned hook events (preserved others)"
    else
      rm -f "$TGT_SETTINGS.tmp"
      echo "    [ERR] jq merge failed — restoring from .bak"
      cp "$TGT_SETTINGS.bak" "$TGT_SETTINGS"
      STATUS="partial"
    fi
  fi

  # --- f. PACK INSTALL (each pack install.sh in a separate subshell, cd target) ---
  echo "[f] pack install..."
  for inst in "$SRC"/.tad/capability-packs/*/install.sh; do
    [ -e "$inst" ] || continue
    pack=$(basename "$(dirname "$inst")")
    # Some pack installers don't support --force (academic-research, research-methodology):
    # they print usage + exit 1 on unknown flags. Detect support and call accordingly;
    # the no-arg form is idempotent (defaults to --agent claude-code).
    if grep -q -- '--force' "$inst"; then
      RUN_OK=$( ( cd "$target" && bash "$inst" --force ) >/dev/null 2>&1 && echo 1 || echo 0 )
    else
      RUN_OK=$( ( cd "$target" && bash "$inst" ) >/dev/null 2>&1 && echo 1 || echo 0 )
    fi
    if [ "$RUN_OK" = "1" ]; then
      PACK_OK=$((PACK_OK+1))
    else
      PACK_FAIL=$((PACK_FAIL+1))
      echo "    [WARN] pack install failed: $pack"
    fi
  done
  echo "    packs ok=$PACK_OK fail=$PACK_FAIL"

  # --- g. TOP-LEVEL .tad files (*.yaml *.md *.txt) EXCEPT sync-registry.yaml + version.txt ---
  echo "[g] top-level .tad files..."
  for f in "$SRC"/.tad/*.yaml "$SRC"/.tad/*.md "$SRC"/.tad/*.txt; do
    [ -e "$f" ] || continue
    bn=$(basename "$f")
    [ "$bn" = "sync-registry.yaml" ] && continue   # zero-touch
    [ "$bn" = "version.txt" ] && continue           # handled in step k
    cp "$f" "$target/.tad/$bn" || { echo "    [ERR] cp $bn failed"; STATUS="partial"; }
  done
  echo "    copied top-level .tad config files"

  # --- h. ROOT files ---
  echo "[h] root files..."
  for rf in tad.sh README.md INSTALLATION_GUIDE.md CHANGELOG.md; do
    if [ -f "$SRC/$rf" ]; then
      cp "$SRC/$rf" "$target/$rf" || { echo "    [ERR] cp $rf failed"; STATUS="partial"; }
    fi
  done
  if [ -f "$SRC/docs/MULTI-PLATFORM.md" ]; then
    mkdir -p "$target/docs"
    cp "$SRC/docs/MULTI-PLATFORM.md" "$target/docs/MULTI-PLATFORM.md" \
      || { echo "    [ERR] cp docs/MULTI-PLATFORM.md failed"; STATUS="partial"; }
  fi
  echo "    copied root files"

  # --- i. CLAUDE.md per strategy ---
  echo "[i] CLAUDE.md ($strategy)..."
  SRC_CLAUDE="$SRC/CLAUDE.md"
  TGT_CLAUDE="$target/CLAUDE.md"
  MARKER="<!-- TAD:PROJECT-CONTENT-BELOW -->"
  if [ "$strategy" = "overwrite" ]; then
    if [ -f "$SRC_CLAUDE" ]; then
      cp "$SRC_CLAUDE" "$TGT_CLAUDE" && CLAUDE_RESULT="overwritten"
    fi
  elif [ "$strategy" = "merge" ]; then
    if [ ! -f "$TGT_CLAUDE" ]; then
      cp "$SRC_CLAUDE" "$TGT_CLAUDE" && CLAUDE_RESULT="merge(no-target→copied)"
    elif grep -qF "$MARKER" "$TGT_CLAUDE"; then
      cp "$TGT_CLAUDE" "$TGT_CLAUDE.bak"
      {
        cat "$SRC_CLAUDE"
        echo ""
        # preserve marker line and everything below it
        awk -v m="$MARKER" 'index($0,m){p=1} p{print}' "$TGT_CLAUDE.bak"
      } > "$TGT_CLAUDE.tmp" && mv "$TGT_CLAUDE.tmp" "$TGT_CLAUDE"
      CLAUDE_RESULT="merged(marker)"
    else
      CLAUDE_RESULT="merge-NO-MARKER(untouched,WARN)"
      echo "    [WARN] merge strategy but no marker — left untouched"
    fi
  else
    CLAUDE_RESULT="unknown-strategy($strategy)"
    echo "    [WARN] unknown strategy: $strategy"
  fi
  echo "    CLAUDE.md: $CLAUDE_RESULT"

  # --- j. DEPRECATION cleanup (idempotent rm -f) ---
  echo "[j] deprecation cleanup..."
  dep_removed=0
  for df in "${DEP_FILES[@]}"; do
    tpath="$target/$df"
    if [ -e "$tpath" ]; then
      if [[ "$df" == */ ]]; then rm -rf "$tpath"; else rm -f "$tpath"; fi
      dep_removed=$((dep_removed+1))
    fi
  done
  echo "    removed $dep_removed deprecated path(s)"

  # --- k. UPDATE version ---
  echo "[k] version -> $VERSION"
  echo "$VERSION" > "$target/.tad/version.txt"

  # --- l. STRUCTURAL VERIFY GATE (WARN mode) ---
  echo "[l] structural verify (warn mode)..."
  GATE_OUT=$(TAD_RELEASE_GATE=warn bash "$SRC/.tad/hooks/lib/release-verify.sh" structural "$SRC" "$target" 2>&1)
  GATE_RC=$?
  GATE_VERDICT=$(printf '%s\n' "$GATE_OUT" | grep -E "VERDICT:" | head -1 | sed 's/^[[:space:]]*//')
  [ -z "$GATE_VERDICT" ] && GATE_VERDICT="(no verdict line, rc=$GATE_RC)"
  echo "    $GATE_VERDICT"
  # show any named drift paths
  printf '%s\n' "$GATE_OUT" | grep -E "DRIFT|missing|differ" | head -20 | sed 's/^/    /'

  echo
  echo ">>> $name DONE — version=$VERSION packs(ok/fail)=$PACK_OK/$PACK_FAIL CLAUDE=$CLAUDE_RESULT gate=[$GATE_VERDICT] status=$STATUS"
  echo
  OVERALL_LOG+="$name|$VERSION|$STATUS|$PACK_OK/$PACK_FAIL|$CLAUDE_RESULT|$GATE_VERDICT"$'\n'

done < <(parse_registry)

echo "######################################################################"
echo "## OVERALL SUMMARY (name|version|status|packs|claude|gate)"
echo "######################################################################"
printf '%s' "$OVERALL_LOG"
