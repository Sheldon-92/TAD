#!/bin/bash
# TAD v2.30.0 sync REPAIR — generated 2026-06-15
# Root issue: sync-v2.30.0.sh ran `install.sh --force` AFTER the skills mirror copy.
# install.sh regenerates SKILL.md from the STALE .tad/capability-packs/{pack}/ source
# (not updated by the pack-quality Epic, which edited .claude/skills directly), so it
# DOWNGRADED the freshly-mirrored upgraded .claude/skills for the 21 upgraded packs.
# .agents/skills was untouched by install.sh and is CORRECT (upgraded).
# Repair: re-mirror the authoritative source .claude/skills + .agents/skills over each
# target (NO install.sh this time), re-verify platform-skills symmetry, re-commit.
# Only framework skills present in SOURCE are touched → project-local skills preserved.
set -u
SRC="/Users/sheldonzhao/01-on progress programs/TAD"
LOG="$SRC/.tad/evidence/releases/sync-v2.30.0-repair.log"
: > "$LOG"
log(){ printf '%s\n' "$*" | tee -a "$LOG"; }

PROJECTS=(
"/Users/sheldonzhao/01-on progress programs/menu-snap"
"/Users/sheldonzhao/01-on progress programs/my-openclaw-agents"
"/Users/sheldonzhao/01-on progress programs/OpenClaw Hack"
"/Users/sheldonzhao/01-on progress programs/运动打卡小助手"
"/Users/sheldonzhao/01-on progress programs/合规ai"
"/Users/sheldonzhao/01-on progress programs/ArtForge"
"/Users/sheldonzhao/01-on progress programs/Sober Creator"
"/Users/sheldonzhao/01-on progress programs/toy"
"/Users/sheldonzhao/01-on progress programs/内存管理"
"/Users/sheldonzhao/01-on progress programs/Next Guest"
"/Users/sheldonzhao/01-on progress programs/下载md插件"
"/Users/sheldonzhao/01-on progress programs/买卖"
"/Users/sheldonzhao/01-on progress programs/Monica-website"
"/Users/sheldonzhao/Downloads/Colin声音项目"
)

SUMMARY=""
for P in "${PROJECTS[@]}"; do
  name="$(basename "$P")"
  log ""; log "════════ $name ════════"
  if [ ! -d "$P/.tad" ]; then log "SKIP: no .tad"; SUMMARY+="$name|SKIPPED"$'\n'; continue; fi
  # re-mirror source framework skills (both platforms) — overwrites install.sh's stale output.
  # Loop is over SOURCE skills only → target project-local skills are left untouched.
  for plat in .claude .agents; do
    mkdir -p "$P/$plat/skills"
    for sd in "$SRC/$plat/skills/"*/; do
      sn="$(basename "$sd")"
      rm -rf "${P:?}/$plat/skills/$sn"
      cp -R "$sd" "$P/$plat/skills/$sn"
    done
    for sf in "$SRC/$plat/skills/"*.md; do [ -f "$sf" ] && cp "$sf" "$P/$plat/skills/"; done
  done
  log "skills re-mirrored (both platforms)"
  # re-verify platform-skills symmetry
  if bash "$SRC/.tad/hooks/lib/release-verify.sh" platform-skills "$SRC" "$P" >>"$LOG" 2>&1; then
    GATE="PASS"
  else
    GATE="FAIL(exit=$?)"
  fi
  log "platform-skills: $GATE"
  # re-commit scoped to skills only
  if [ -d "$P/.git" ]; then
    (cd "$P" && git add .claude/skills .agents/skills 2>/dev/null \
      && git commit -m "fix: re-mirror upgraded TAD packs (v2.30.0 install.sh had downgraded .claude/skills)" --quiet 2>>"$LOG") \
      && g="committed" || g="nothing/failed"
  else
    g="no-repo"
  fi
  log "git: $g"
  SUMMARY+="$name|REPAIRED|platform-skills=$GATE|git=$g"$'\n'
done

log ""; log "════════ REPAIR SUMMARY ════════"
printf '%s' "$SUMMARY" | tee -a "$LOG"
