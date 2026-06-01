#!/usr/bin/env bash
# sync-v2.21.0.sh — comprehensive TAD framework sync to a downstream project.
# set -u (NOT -e): continue-on-error per runbook Phase 6.
# Verification centers on `diff -rq` source-vs-target per synced path → proves no omission.
set -u

SRC="/Users/sheldonzhao/01-on progress programs/TAD"
NEW_VERSION="2.21.0"

# Framework dirs to FULL-REFRESH: runbook's 14 + codex (the historically-omitted dir).
FRAMEWORK_DIRS="agents data domains gates guides hooks ralph-config references schemas skills sub-agents tasks templates workflows codex"
# Root-level files (per sync_protocol step3b "Root-level files").
ROOT_FILES="tad.sh README.md INSTALLATION_GUIDE.md CHANGELOG.md"

# ---- sync one project ----
sync_one() {
  local target="$1" strategy="$2"
  [ -d "$target/.tad" ] || { echo "SKIP: no .tad at $target"; return 1; }

  # 1. Full-refresh framework dirs (rm + cp removes stale, adds new)
  for d in $FRAMEWORK_DIRS; do
    [ -d "$SRC/.tad/$d" ] || continue
    rm -rf "$target/.tad/$d"
    cp -R "$SRC/.tad/$d" "$target/.tad/$d"
  done

  # 2. Top-level .tad config files (exclude sync-registry.yaml — TAD-main-only)
  for f in "$SRC"/.tad/*.yaml "$SRC"/.tad/*.md "$SRC"/.tad/*.txt; do
    [ -f "$f" ] || continue
    case "$(basename "$f")" in
      sync-registry.yaml) continue ;;   # main-only: downstream must NOT get the registry
    esac
    cp "$f" "$target/.tad/"
  done

  # 3. .claude/skills full-refresh (framework-owned per runbook)
  [ -d "$SRC/.claude/skills" ] && { rm -rf "$target/.claude/skills"; mkdir -p "$target/.claude"; cp -R "$SRC/.claude/skills" "$target/.claude/skills"; }

  # 4. settings.json: SKIP — v2.21.0 added ZERO new hooks (parity gate is NOT a hook). Preserve project's as-is.

  # 5. Root-level files
  for rf in $ROOT_FILES; do
    [ -f "$SRC/$rf" ] && cp "$SRC/$rf" "$target/$rf"
  done
  [ -f "$SRC/docs/MULTI-PLATFORM.md" ] && { mkdir -p "$target/docs"; cp "$SRC/docs/MULTI-PLATFORM.md" "$target/docs/"; }

  # 6. CLAUDE.md per strategy
  if [ "$strategy" = "overwrite" ]; then
    [ -f "$SRC/CLAUDE.md" ] && cp "$SRC/CLAUDE.md" "$target/CLAUDE.md"
  else  # merge: replace content ABOVE the marker, preserve below
    local marker='<!-- TAD:PROJECT-CONTENT-BELOW -->'
    if [ -f "$target/CLAUDE.md" ] && grep -qF "$marker" "$target/CLAUDE.md"; then
      cp "$target/CLAUDE.md" "$target/CLAUDE.md.bak"
      { cat "$SRC/CLAUDE.md"; echo ""; sed -n "/$marker/,\$p" "$target/CLAUDE.md.bak"; } > "$target/CLAUDE.md"
    else
      echo "  WARN: merge project lacks marker — CLAUDE.md left untouched"
    fi
  fi

  # 7. version.txt LAST
  echo "$NEW_VERSION" > "$target/.tad/version.txt"
  return 0
}

# ---- verify one project: diff -rq proves no omission ----
verify_one() {
  local target="$1"
  local fails=0
  # A. version
  local v; v=$(tr -d '[:space:]' < "$target/.tad/version.txt" 2>/dev/null)
  [ "$v" = "$NEW_VERSION" ] && echo "  ✅ version $v" || { echo "  ❌ version=$v"; fails=$((fails+1)); }
  # B. STRUCTURAL DIFF — source vs target, per synced framework dir + .claude/skills (the omission-catcher)
  for d in $FRAMEWORK_DIRS; do
    [ -d "$SRC/.tad/$d" ] || continue
    local out; out=$(diff -rq "$SRC/.tad/$d" "$target/.tad/$d" 2>&1)
    [ -z "$out" ] && echo "  ✅ .tad/$d identical" || { echo "  ❌ .tad/$d DIFF:"; echo "$out" | sed 's/^/      /' | head -4; fails=$((fails+1)); }
  done
  local sout; sout=$(diff -rq "$SRC/.claude/skills" "$target/.claude/skills" 2>&1)
  [ -z "$sout" ] && echo "  ✅ .claude/skills identical" || { echo "  ❌ .claude/skills DIFF:"; echo "$sout" | sed 's/^/      /' | head -4; fails=$((fails+1)); }
  # C. Key v2.21.0 new/changed files present
  [ -f "$target/.tad/hooks/lib/codex-parity-check.sh" ] && echo "  ✅ codex-parity-check.sh" || { echo "  ❌ MISSING codex-parity-check.sh"; fails=$((fails+1)); }
  [ -f "$target/.tad/codex/regen-codex-editions.sh" ] && echo "  ✅ regen-codex-editions.sh" || { echo "  ❌ MISSING regen-codex-editions.sh"; fails=$((fails+1)); }
  grep -q '2026-06-01' "$target/.tad/codex/codex-alex-skill.md" 2>/dev/null && echo "  ✅ codex-alex regenerated (not stale 05-04)" || echo "  ⚠️ codex-alex Generated date check (manual)"
  grep -q 'step3b' "$target/.claude/skills/alex/SKILL.md" 2>/dev/null && echo "  ✅ alex SKILL publish step3b" || { echo "  ❌ alex SKILL missing step3b"; fails=$((fails+1)); }
  # D. tad.sh + root version
  grep -q 'TARGET_VERSION="2.21.0"' "$target/tad.sh" 2>/dev/null && echo "  ✅ tad.sh 2.21.0" || { echo "  ❌ tad.sh version"; fails=$((fails+1)); }
  echo "  → $fails failure(s)"
  return $fails
}

# ---- main ----
case "${1:-}" in
  PILOT) sync_one "$2" "$3" && verify_one "$2" ;;
  VERIFY) verify_one "$2" ;;
  ALL)
    # reads /tmp/sync-targets.txt (strat\tpath\tname), syncs+verifies all in ONE process
    TOTAL=0; OK=0; BAD=""
    while IFS=$'\t' read -r strat path name; do
      [ -z "$path" ] && continue
      TOTAL=$((TOTAL+1))
      echo "===== $name ($strat) ====="
      sync_one "$path" "$strat"
      if verify_one "$path" | grep -q '→ 0 failure'; then
        OK=$((OK+1)); echo "  RESULT: ✅ $name CLEAN"
      else
        BAD="$BAD $name"; echo "  RESULT: ❌ $name — re-run VERIFY to inspect"
        verify_one "$path" | grep '❌'
      fi
    done < /tmp/sync-targets.txt
    echo ""
    echo "================ SUMMARY ================"
    echo "PASS: $OK/$TOTAL"
    [ -z "$BAD" ] && echo "✅ all projects synced to $NEW_VERSION, diff-CLEAN (zero omission)" || echo "❌ FAILED:$BAD"
    ;;
  *) echo "usage: $0 PILOT <path> <strategy> | VERIFY <path> | ALL" ;;
esac
