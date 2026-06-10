#!/usr/bin/env bash
# TAD v2.24.1 sync — generated per release-runbook Phase 5/6.
# Continue-on-error: set -u (NOT set -e). One broken project must not abort the rest.
set -u

TAD_SRC="/Users/sheldonzhao/01-on progress programs/TAD"
NEW_VERSION="2.24.1"
TODAY="$(date +%Y-%m-%d)"
REG="$TAD_SRC/.tad/sync-registry.yaml"
DEP="$TAD_SRC/.tad/deprecation.yaml"

cd "$TAD_SRC" || { echo "FATAL: cannot cd to TAD_SRC"; exit 1; }

# Derive framework dir set (deny-list, structure-agnostic) once.
FRAMEWORK_DIRS=$(bash .tad/hooks/lib/derive-sync-set.sh --dirs)

# Top-level .tad files to copy (yaml/md/txt) MINUS zero-touch/handled-separately.
#   exclude: sync-registry.yaml (zero-touch), version.txt (handled as last step)
TOP_FILES_EXCLUDE="sync-registry.yaml version.txt"

# Deprecation file list: all version keys (all are <= 2.24.1).
DEP_FILES=$(yq -r '.deprecations | to_entries[] | .value.files[]?' "$DEP" 2>/dev/null | sort -u)

# CLAUDE.md merge marker.
MARKER="<!-- TAD:PROJECT-CONTENT-BELOW -->"

OK_COUNT=0
SKIP_COUNT=0
WARN_COUNT=0

# Results recorded as: name|version|packs|claudemd|structural|status|notes
RESULTS_FILE="$(mktemp)"

# --- Iterate projects from registry ---
NUM=$(yq -r '.projects | length' "$REG")
for i in $(seq 0 $((NUM-1))); do
  P_PATH=$(yq -r ".projects[$i].path" "$REG")
  P_NAME=$(yq -r ".projects[$i].name" "$REG")
  P_STRAT=$(yq -r ".projects[$i].claude_md_strategy" "$REG")

  echo ""
  echo "════════════════════════════════════════════════════════════"
  echo "PROJECT: $P_NAME  ($P_STRAT)"
  echo "PATH: $P_PATH"
  echo "════════════════════════════════════════════════════════════"

  NOTES=""

  # 1. PATH VALIDATION
  RP=$(realpath "$P_PATH" 2>/dev/null || echo "")
  case "$RP" in
    "$HOME"/*) : ;;
    *) echo "  SKIP: realpath not under \$HOME ($RP)"; SKIP_COUNT=$((SKIP_COUNT+1));
       echo "$P_NAME|-|-|-|-|SKIPPED|not under \$HOME" >> "$RESULTS_FILE"; continue ;;
  esac
  if [ ! -d "$P_PATH/.tad" ]; then
    echo "  SKIP: $P_PATH/.tad does not exist"; SKIP_COUNT=$((SKIP_COUNT+1));
    echo "$P_NAME|-|-|-|-|SKIPPED|.tad missing" >> "$RESULTS_FILE"; continue
  fi

  # 2. FRAMEWORK DIRS
  echo "  [2] Framework dirs..."
  while IFS= read -r d; do
    [ -z "$d" ] && continue
    if [ "$d" = "capability-packs" ]; then
      # registry index ONLY — never the pack tree
      mkdir -p "$P_PATH/.tad/capability-packs"
      cp "$TAD_SRC/.tad/capability-packs/pack-registry.yaml" "$P_PATH/.tad/capability-packs/pack-registry.yaml" 2>/dev/null \
        && echo "      capability-packs/pack-registry.yaml ✓" \
        || echo "      capability-packs/pack-registry.yaml ✗"
      continue
    fi
    if [ -d "$TAD_SRC/.tad/$d" ]; then
      rm -rf "$P_PATH/.tad/$d"
      cp -R "$TAD_SRC/.tad/$d" "$P_PATH/.tad/$d" && echo "      $d ✓" || echo "      $d ✗"
    fi
  done <<< "$FRAMEWORK_DIRS"

  # 2b. Top-level .tad config files
  echo "  [2b] Top-level .tad files..."
  for f in "$TAD_SRC"/.tad/*.yaml "$TAD_SRC"/.tad/*.md "$TAD_SRC"/.tad/*.txt; do
    [ -e "$f" ] || continue
    bn=$(basename "$f")
    skip=0
    for ex in $TOP_FILES_EXCLUDE; do [ "$bn" = "$ex" ] && skip=1; done
    [ "$skip" = "1" ] && continue
    cp "$f" "$P_PATH/.tad/$bn"
  done

  # 2c. .claude/skills/* (full refresh per skill dir)
  echo "  [2c] .claude/skills..."
  mkdir -p "$P_PATH/.claude/skills"
  for sk in "$TAD_SRC"/.claude/skills/*/; do
    [ -d "$sk" ] || continue
    skn=$(basename "$sk")
    rm -rf "$P_PATH/.claude/skills/$skn"
    cp -R "$sk" "$P_PATH/.claude/skills/$skn"
  done

  # 2d. .claude/workflows
  if [ -d "$TAD_SRC/.claude/workflows" ]; then
    echo "  [2d] .claude/workflows..."
    mkdir -p "$P_PATH/.claude/workflows"
    cp "$TAD_SRC"/.claude/workflows/* "$P_PATH/.claude/workflows/" 2>/dev/null
  fi

  # 2e. .claude/settings.json JSON MERGE (preserve project-specific hooks)
  echo "  [2e] settings.json merge..."
  SRC_S="$TAD_SRC/.claude/settings.json"
  TGT_S="$P_PATH/.claude/settings.json"
  if [ -f "$TGT_S" ]; then
    cp "$TGT_S" "$TGT_S.bak-$NEW_VERSION"
    SRC_HOOKS=$(jq -c '.hooks' "$SRC_S")
    # Merge: for each event in source hooks, REPLACE target's TAD-owned entries but keep
    # target entries whose hook commands do NOT reference .tad/hooks/ (project-specific).
    # Strategy: per event, target_nonTAD ++ source_all.
    TMP=$(mktemp)
    jq --argjson sh "$SRC_HOOKS" '
      .hooks as $th |
      ($sh | keys) as $events |
      reduce $events[] as $e (.;
        .hooks[$e] = (
          (($th[$e] // [])
            | map(select(
                ([.. | .command? // empty] | map(test("\\.tad/hooks/")) | any) | not
              ))
          ) + ($sh[$e])
        )
      )
    ' "$TGT_S" > "$TMP" 2>/dev/null
    if [ -s "$TMP" ] && jq -e . "$TMP" >/dev/null 2>&1; then
      mv "$TMP" "$TGT_S"; echo "      settings.json merged ✓"
    else
      rm -f "$TMP"; echo "      settings.json merge FAILED — left untouched ✗"; NOTES="$NOTES;settings-merge-fail"
    fi
  else
    mkdir -p "$P_PATH/.claude"
    cp "$SRC_S" "$TGT_S"; echo "      settings.json created (no prior) ✓"
  fi

  # 2f. tad.sh + root docs
  echo "  [2f] tad.sh + root docs..."
  cp "$TAD_SRC/tad.sh" "$P_PATH/tad.sh" 2>/dev/null && chmod +x "$P_PATH/tad.sh" 2>/dev/null
  for doc in README.md INSTALLATION_GUIDE.md CHANGELOG.md; do
    [ -f "$TAD_SRC/$doc" ] && cp "$TAD_SRC/$doc" "$P_PATH/$doc"
  done

  # 3. Pack install.sh --force (with no-arg fallback)
  echo "  [3] Pack install.sh..."
  PACK_OK=0; PACK_FAIL=0
  for pd in "$TAD_SRC"/.tad/capability-packs/*/; do
    [ -f "$pd/install.sh" ] || continue
    pn=$(basename "$pd")
    ( cd "$P_PATH" && bash "$pd/install.sh" --force ) >/dev/null 2>&1
    rc=$?
    if [ $rc -ne 0 ]; then
      # fallback to no-arg form (academic-research + research-methodology reject --force)
      ( cd "$P_PATH" && bash "$pd/install.sh" ) >/dev/null 2>&1
      rc=$?
    fi
    if [ $rc -eq 0 ]; then PACK_OK=$((PACK_OK+1)); else PACK_FAIL=$((PACK_FAIL+1)); echo "      pack FAIL: $pn (rc=$rc)"; fi
  done
  echo "      packs ok=$PACK_OK fail=$PACK_FAIL"
  PACKS_RESULT="${PACK_OK}ok/${PACK_FAIL}f"

  # 4. Deprecation cleanup (explicit rm -f)
  echo "  [4] Deprecation cleanup..."
  DEP_DEL=0
  while IFS= read -r df; do
    [ -z "$df" ] && continue
    tgt="$P_PATH/$df"
    if [ -e "$tgt" ]; then rm -rf "$tgt" && DEP_DEL=$((DEP_DEL+1)); fi
  done <<< "$DEP_FILES"
  echo "      deleted $DEP_DEL deprecated path(s)"

  # 5. CLAUDE.md per strategy
  echo "  [5] CLAUDE.md ($P_STRAT)..."
  CLAUDEMD_RESULT="?"
  SRC_CMD="$TAD_SRC/CLAUDE.md"
  TGT_CMD="$P_PATH/CLAUDE.md"
  if [ "$P_STRAT" = "overwrite" ]; then
    cp "$SRC_CMD" "$TGT_CMD" && CLAUDEMD_RESULT="overwritten" && echo "      overwritten ✓"
  else
    # merge
    if [ -f "$TGT_CMD" ] && grep -q "$MARKER" "$TGT_CMD"; then
      # replace everything above marker with source content + marker + preserved below
      below=$(awk -v m="$MARKER" 'f{print} $0 ~ m {f=1; print}' "$TGT_CMD")
      { cat "$SRC_CMD"; echo ""; echo "$below"; } > "$TGT_CMD.new" && mv "$TGT_CMD.new" "$TGT_CMD"
      CLAUDEMD_RESULT="merged"; echo "      merged ✓"
    else
      CLAUDEMD_RESULT="WARN-no-marker"; WARN_COUNT=$((WARN_COUNT+1))
      echo "      WARN: no marker — CLAUDE.md left untouched"
      NOTES="$NOTES;claudemd-no-marker"
    fi
  fi

  # 6. Structural verify (shadow mode: warn)
  echo "  [6] Structural verify (warn mode)..."
  STRUCT_OUT=$(TAD_RELEASE_GATE=warn bash "$TAD_SRC/.tad/hooks/lib/release-verify.sh" structural "$TAD_SRC" "$P_PATH" 2>&1)
  STRUCT_RC=$?
  if [ $STRUCT_RC -eq 0 ]; then STRUCT_RESULT="PASS"; else STRUCT_RESULT="warn(rc=$STRUCT_RC)"; fi
  echo "$STRUCT_OUT" | tail -8

  # 7. version.txt (last step)
  echo "  [7] version.txt -> $NEW_VERSION"
  echo "$NEW_VERSION" > "$P_PATH/.tad/version.txt"

  OK_COUNT=$((OK_COUNT+1))
  FINAL_VER=$(cat "$P_PATH/.tad/version.txt" | tr -d '[:space:]')
  echo "$P_NAME|$FINAL_VER|$PACKS_RESULT|$CLAUDEMD_RESULT|$STRUCT_RESULT|OK|$NOTES" >> "$RESULTS_FILE"
done

echo ""
echo "############################################################"
echo "SYNC SUMMARY  (synced ok=$OK_COUNT, skipped=$SKIP_COUNT, warned=$WARN_COUNT)"
echo "############################################################"
printf "%-22s | %-7s | %-9s | %-15s | %-12s | %-8s\n" "PROJECT" "VERSION" "PACKS" "CLAUDE.md" "STRUCTURAL" "STATUS"
echo "--------------------------------------------------------------------------------------------"
while IFS='|' read -r n v p c s st notes; do
  printf "%-22s | %-7s | %-9s | %-15s | %-12s | %-8s\n" "$n" "$v" "$p" "$c" "$s" "$st"
done < "$RESULTS_FILE"
echo ""
echo "RESULTS_FILE=$RESULTS_FILE"
rm -f "$RESULTS_FILE"
