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
SRC="$(git rev-parse --show-toplevel)"
LOG="$SRC/.tad/evidence/releases/sync-v2.30.0-repair.log"
: > "$LOG"
log(){ printf '%s\n' "$*" | tee -a "$LOG"; }

PROJECTS=(
"/path/to/menu-snap"
"/path/to/my-openclaw-agents"
"/path/to/OpenClaw Hack"
"/path/to/运动打卡小助手"
"/path/to/合规ai"
"/path/to/ArtForge"
"/path/to/Sober Creator"
"/path/to/toy"
"/path/to/内存管理"
"/path/to/Next Guest"
"/path/to/下载md插件"
"/path/to/买卖"
"/path/to/Monica-website"
"/path/to/Downloads/Colin声音项目"
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
