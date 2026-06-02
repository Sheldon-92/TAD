#!/usr/bin/env bash
# sync-v2.22.0.sh — FRESH per-release sync, driven by the NEW self-deriving mechanism.
# Dir set = derive-sync-set.sh --dirs (deny-list, auto-includes codex/etc). Gate = release-verify.sh structural.
# set -u (NOT -e): continue-on-error. Run as ONE bash process (ALL mode) to avoid the eval-loop PATH bug.
set -u
SRC="/Users/sheldonzhao/01-on progress programs/TAD"
NEW_VERSION="2.22.0"
DERIVE="$SRC/.tad/hooks/lib/derive-sync-set.sh"
VERIFY="$SRC/.tad/hooks/lib/release-verify.sh"
ROOT_FILES="tad.sh README.md INSTALLATION_GUIDE.md CHANGELOG.md"
REG_PATH="$(bash "$DERIVE" --registry-only "$SRC")"   # capability-packs/pack-registry.yaml
REG_DIR="${REG_PATH%%/*}"                              # capability-packs
TOP_DENY="sync-registry.yaml"

sync_one() {
  local target="$1" strategy="$2"
  [ -d "$target/.tad" ] || { echo "  SKIP: no .tad"; return 1; }
  # 1. Framework dirs from the DERIVED set (auto-includes new dirs). registry-only for capability-packs.
  local d
  while IFS= read -r d; do
    [ -z "$d" ] && continue
    if [ "$d" = "$REG_DIR" ]; then
      mkdir -p "$target/.tad/$REG_DIR"
      cp "$SRC/.tad/$REG_PATH" "$target/.tad/$REG_PATH" 2>/dev/null || true   # registry index ONLY
    elif [ -d "$SRC/.tad/$d" ]; then
      rm -rf "$target/.tad/$d"; cp -R "$SRC/.tad/$d" "$target/.tad/$d"
    fi
  done < <(bash "$DERIVE" --dirs "$SRC")
  # 2. Top-level .tad files (deny-list: all except sync-registry)
  local f bn
  for f in "$SRC"/.tad/*; do
    [ -f "$f" ] || continue
    bn="$(basename "$f")"; [ "$bn" = "$TOP_DENY" ] && continue
    cp "$f" "$target/.tad/" 2>/dev/null || true
  done
  # 3. .claude/skills full-refresh
  rm -rf "$target/.claude/skills"; mkdir -p "$target/.claude"; cp -R "$SRC/.claude/skills" "$target/.claude/skills"
  # 4. root files
  for rf in $ROOT_FILES; do [ -f "$SRC/$rf" ] && cp "$SRC/$rf" "$target/$rf"; done
  [ -f "$SRC/docs/MULTI-PLATFORM.md" ] && { mkdir -p "$target/docs"; cp "$SRC/docs/MULTI-PLATFORM.md" "$target/docs/"; }
  # 5. CLAUDE.md per strategy
  if [ "$strategy" = "overwrite" ]; then
    [ -f "$SRC/CLAUDE.md" ] && cp "$SRC/CLAUDE.md" "$target/CLAUDE.md"
  else
    local marker='<!-- TAD:PROJECT-CONTENT-BELOW -->'
    if [ -f "$target/CLAUDE.md" ] && grep -qF "$marker" "$target/CLAUDE.md"; then
      cp "$target/CLAUDE.md" "$target/CLAUDE.md.bak"
      { cat "$SRC/CLAUDE.md"; echo ""; sed -n "/$marker/,\$p" "$target/CLAUDE.md.bak"; } > "$target/CLAUDE.md"
    else echo "  WARN: merge project lacks marker — CLAUDE.md untouched"; fi
  fi
  # 6. version.txt LAST
  echo "$NEW_VERSION" > "$target/.tad/version.txt"
  return 0
}

# Verify: the NEW structural gate (diff-r over derived paths; registry-only honored) + top-level cmp.
verify_one() {
  local target="$1" fails=0
  local v; v=$(tr -d '[:space:]' < "$target/.tad/version.txt" 2>/dev/null)
  [ "$v" = "$NEW_VERSION" ] || { echo "  ❌ version=$v"; fails=$((fails+1)); }
  # THE NEW STRUCTURAL GATE (release-time gate, run here as sync verification)
  if bash "$VERIFY" structural "$SRC" "$target" >/dev/null 2>&1; then echo "  ✅ structural gate: diff-clean"; else echo "  ❌ structural gate: DRIFT"; bash "$VERIFY" structural "$SRC" "$target" 2>&1 | grep -iE 'missing|differ|only in' | head -3; fails=$((fails+1)); fi
  # supplementary: top-level .tad files (structural gate covers dirs+skills, not top-level — P3 residual)
  for f in "$SRC"/.tad/*; do
    [ -f "$f" ] || continue; bn="$(basename "$f")"; [ "$bn" = "$TOP_DENY" ] && continue
    cmp -s "$f" "$target/.tad/$bn" || { echo "  ❌ top-level $bn differs"; fails=$((fails+1)); }
  done
  # codex auto-included (the historical omission)
  grep -q '2026-06-01' "$target/.tad/codex/codex-alex-skill.md" 2>/dev/null && echo "  ✅ codex synced (auto-included)" || echo "  ⚠️ codex check"
  echo "  → $fails failure(s)"
  return $fails
}

case "${1:-}" in
  PILOT) echo "== $3 ($2) =="; sync_one "$2" "$3"; verify_one "$2" ;;
  ALL)
    OK=0; TOTAL=0; BAD=""
    while IFS=$'\t' read -r strat path name; do
      [ -z "$path" ] && continue; TOTAL=$((TOTAL+1)); echo "== $name ($strat) =="
      sync_one "$path" "$strat"
      if verify_one "$path" | grep -q '→ 0 failure'; then OK=$((OK+1)); echo "  RESULT ✅ $name"; else BAD="$BAD $name"; echo "  RESULT ❌ $name"; verify_one "$path" | grep '❌'; fi
    done < /tmp/sync-targets.txt
    echo "===== SUMMARY: $OK/$TOTAL ====="; [ -z "$BAD" ] && echo "✅ all synced to $NEW_VERSION, structural-gate CLEAN" || echo "❌ FAILED:$BAD"
    ;;
  *) echo "usage: PILOT <path> <strategy> | ALL" ;;
esac
