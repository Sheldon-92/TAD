#!/bin/bash
# TAD v2.29.1 sync — generated 2026-06-11 per release-runbook Phase 5
# Patch release: structural gate is advisory (WARN not BLOCK).
# Added: platform-skills parity check (Pack System Unification Phase 3).
set -u
SRC="/Users/sheldonzhao/01-on progress programs/TAD"
NEW="2.29.1"
LOG="$SRC/.tad/evidence/releases/sync-v2.29.1.log"
: > "$LOG"
log(){ printf '%s\n' "$*" | tee -a "$LOG"; }

DIRS="$(bash "$SRC/.tad/hooks/lib/derive-sync-set.sh" --dirs "$SRC")"
bash "$SRC/.tad/hooks/lib/derive-sync-set.sh" --report "$SRC" >> "$LOG" 2>&1

PROJECTS=(
"/Users/sheldonzhao/01-on progress programs/menu-snap|overwrite"
"/Users/sheldonzhao/01-on progress programs/my-openclaw-agents|merge"
"/Users/sheldonzhao/01-on progress programs/OpenClaw Hack|overwrite"
"/Users/sheldonzhao/01-on progress programs/运动打卡小助手|overwrite"
"/Users/sheldonzhao/01-on progress programs/合规ai|overwrite"
"/Users/sheldonzhao/01-on progress programs/ArtForge|overwrite"
"/Users/sheldonzhao/01-on progress programs/Sober Creator|overwrite"
"/Users/sheldonzhao/01-on progress programs/toy|merge"
"/Users/sheldonzhao/01-on progress programs/内存管理|merge"
"/Users/sheldonzhao/01-on progress programs/Next Guest|overwrite"
"/Users/sheldonzhao/01-on progress programs/下载md插件|overwrite"
"/Users/sheldonzhao/01-on progress programs/买卖|overwrite"
"/Users/sheldonzhao/01-on progress programs/Monica-website|overwrite"
"/Users/sheldonzhao/Downloads/Colin声音项目|overwrite"
)

SUMMARY=""
for entry in "${PROJECTS[@]}"; do
  P="${entry%%|*}"; STRAT="${entry##*|}"
  name="$(basename "$P")"
  log ""; log "════════ $name ($STRAT) ════════"
  # 0. validation
  if [ ! -d "$P/.tad" ]; then log "SKIP: no .tad at $P"; SUMMARY+="$name|SKIPPED-no-tad"$'\n'; continue; fi
  OLD_V="$(tr -d '[:space:]' < "$P/.tad/version.txt" 2>/dev/null || echo unknown)"
  log "old version: $OLD_V"

  # a. CLAUDE.md
  if [ "$STRAT" = "overwrite" ]; then
    cp "$SRC/CLAUDE.md" "$P/CLAUDE.md"; log "CLAUDE.md: overwritten"
  else
    if grep -q '<!-- TAD:PROJECT-CONTENT-BELOW -->' "$P/CLAUDE.md" 2>/dev/null; then
      cp "$P/CLAUDE.md" "$P/CLAUDE.md.bak"
      { cat "$SRC/CLAUDE.md"; printf '\n'; awk '/<!-- TAD:PROJECT-CONTENT-BELOW -->/,0' "$P/CLAUDE.md.bak"; } > "$P/CLAUDE.md"
      log "CLAUDE.md: merged (head replaced, project content preserved)"
    else
      log "CLAUDE.md: WARN merge marker missing — left untouched"
    fi
  fi

  # b. framework: top-level .tad files (deny: sync-registry.yaml)
  for f in "$SRC/.tad/"*.yaml "$SRC/.tad/"*.md "$SRC/.tad/"*.txt; do
    [ -f "$f" ] || continue
    b="$(basename "$f")"
    [ "$b" = "sync-registry.yaml" ] && continue
    cp "$f" "$P/.tad/$b"
  done
  # derived framework dirs: full refresh
  while IFS= read -r d; do
    [ -n "$d" ] || continue
    rm -rf "$P/.tad/$d"
    cp -R "$SRC/.tad/$d" "$P/.tad/$d"
  done <<< "$DIRS"
  # capability-packs: registry index ONLY
  mkdir -p "$P/.tad/capability-packs"
  cp "$SRC/.tad/capability-packs/pack-registry.yaml" "$P/.tad/capability-packs/pack-registry.yaml"
  # skills: per-skill refresh BOTH platforms (local skills survive)
  for plat in .claude .agents; do
    mkdir -p "$P/$plat/skills"
    for sd in "$SRC/$plat/skills/"*/; do
      sn="$(basename "$sd")"
      rm -rf "${P:?}/$plat/skills/$sn"
      cp -R "$sd" "$P/$plat/skills/$sn"
    done
    for sf in "$SRC/$plat/skills/"*.md; do [ -f "$sf" ] && cp "$sf" "$P/$plat/skills/"; done
  done
  # settings.json: hooks-merge (preserve project extras); copy if absent
  if [ -f "$P/.claude/settings.json" ]; then
    if jq -s '.[1] as $t | .[0] as $s | $t + {hooks: (($t.hooks // {}) + ($s.hooks // {}))}' \
        "$SRC/.claude/settings.json" "$P/.claude/settings.json" > "$P/.claude/settings.json.tmp" 2>>"$LOG"; then
      mv "$P/.claude/settings.json.tmp" "$P/.claude/settings.json"; log "settings.json: hooks merged"
    else
      rm -f "$P/.claude/settings.json.tmp"; log "settings.json: WARN jq merge failed — untouched"
    fi
  else
    mkdir -p "$P/.claude"; cp "$SRC/.claude/settings.json" "$P/.claude/settings.json"; log "settings.json: copied (was absent)"
  fi
  # workflows
  mkdir -p "$P/.claude/workflows"
  cp "$SRC/.claude/workflows/"*.workflow.js "$P/.claude/workflows/" 2>/dev/null
  # root files
  for rf in tad.sh README.md INSTALLATION_GUIDE.md CHANGELOG.md; do cp "$SRC/$rf" "$P/$rf"; done
  mkdir -p "$P/docs"; cp "$SRC/docs/MULTI-PLATFORM.md" "$P/docs/MULTI-PLATFORM.md"
  log "framework copy: done"

  # d2. structural gate (patch = advisory WARN, not BLOCK)
  if bash "$SRC/.tad/hooks/lib/release-verify.sh" structural "$SRC" "$P" >> "$LOG" 2>&1; then
    GATE="PASS"
  else
    ec=$?
    if [ "$ec" = "2" ]; then
      GATE="FAIL(exit=2-wiring)"
      log "GATE: release-verify structural exit=2 — HARD BLOCK (wiring error)"
      SUMMARY+="$name|GATE-BLOCKED(wiring)"$'\n'
      continue
    fi
    GATE="WARN(exit=$ec)"
    log "GATE: release-verify structural exit=$ec — advisory WARN (patch release)"
  fi
  log "structural gate: $GATE"

  # b2. pack installs (each isolated; --force with no-arg fallback)
  ok=0; fail=0
  for pk in "$SRC/.tad/capability-packs/"*/; do
    [ -f "$pk/install.sh" ] || continue
    pn="$(basename "$pk")"
    if (cd "$P" && bash "$pk/install.sh" --force >/dev/null 2>&1); then ok=$((ok+1))
    elif (cd "$P" && bash "$pk/install.sh" >/dev/null 2>&1); then ok=$((ok+1))
    else fail=$((fail+1)); log "  pack WARN: $pn install failed"; fi
  done
  log "packs: $ok ok, $fail failed"

  # e. platform-skills parity check (new in v2.29.1 — Pack System Unification Phase 3)
  if bash "$SRC/.tad/hooks/lib/release-verify.sh" platform-skills "$SRC" "$P" >> "$LOG" 2>&1; then
    PLAT_GATE="PASS"
  else
    pec=$?
    PLAT_GATE="WARN(exit=$pec)"
    log "GATE: release-verify platform-skills exit=$pec — advisory (patch)"
  fi
  log "platform-skills: $PLAT_GATE"

  # b3. migration engine (non-blocking)
  bash "$SRC/.tad/hooks/lib/migration-engine.sh" --from "$OLD_V" --to "$NEW" --target "$P" --source "$SRC" >> "$LOG" 2>&1
  log "migration engine exit: $? (non-blocking)"

  # c. deprecation cleanup for OLD_V < v <= NEW
  while IFS= read -r depv; do
    [ -n "$depv" ] || continue
    while IFS= read -r df; do
      [ -n "$df" ] && [ "$df" != "null" ] || continue
      if [ -e "$P/$df" ]; then rm -rf "${P:?}/$df"; log "  deprecated removed: $df (≤$depv)"; fi
    done < <(yq -r ".deprecations.\"$depv\".files[]?" "$SRC/.tad/deprecation.yaml" 2>/dev/null)
  done < <(yq -r '.deprecations | keys[]' "$SRC/.tad/deprecation.yaml" 2>/dev/null | awk -v old="$OLD_V" -v new="$NEW" '
    function v(s,a){split(s,a,".");return a[1]*1000000+a[2]*1000+a[3]}
    v($0,x)>v(old,y) && v($0,x)<=v(new,z)')

  # d. verify version
  V_NOW="$(tr -d '[:space:]' < "$P/.tad/version.txt")"
  [ "$V_NOW" = "$NEW" ] && log "version.txt: $NEW ✓" || log "version.txt: WARN got $V_NOW"

  # commit (scoped paths only)
  if [ -d "$P/.git" ]; then
    (cd "$P" && git add -- .tad/*.yaml .tad/*.md .tad/*.txt \
        $(printf '.tad/%s ' $DIRS) \
        .tad/capability-packs/pack-registry.yaml \
        .claude/skills/ .agents/skills/ .claude/settings.json .claude/workflows/ \
        CLAUDE.md CLAUDE.md.bak tad.sh README.md INSTALLATION_GUIDE.md CHANGELOG.md \
        docs/MULTI-PLATFORM.md 2>/dev/null
     git -C "$P" commit -m "chore: sync TAD v$NEW" --quiet 2>>"$LOG") \
      && log "git: committed" || log "git: nothing to commit / commit failed (see log)"
  else
    log "git: no repo, skipped"
  fi
  SUMMARY+="$name|SYNCED|gate=$GATE|plat=$PLAT_GATE|packs=$ok/$((ok+fail))"$'\n'
done

log ""; log "════════ SUMMARY ════════"
printf '%s' "$SUMMARY" | tee -a "$LOG"
