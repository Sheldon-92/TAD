#!/usr/bin/env bash
# pack-registry-driftcheck.sh — Advisory bidirectional pack/registry drift detector.
#
# Compares pack-registry.yaml (the derived index) against ground truth on disk:
#   Set A = registry pack names
#   Set B = installed CAPABILITY-PACK skills (positive type-frontmatter probe — NO allowlist)
#   Set C = source packs (.tad/capability-packs/*/ with a CAPABILITY.md)
# Reports (a) C\registry  (b) B\registry  (c) registry\(B∪C); exit 1 if any non-empty.
# (d) advisory WARN lines (source-only / skill-only / indexed-but-no-install.sh) — never change exit.
#
# ⚠️ SAFETY / forbidden (architecture.md 2026-04-15 "Mechanical Enforcement Rejected on
#    Single-User CLI"): this script is a SMOKE ALARM, NOT a fire suppressor.
#    - MUST NOT be registered as a blocking hook (PreToolUse / SessionStart gate).
#    - MUST NOT be added to settings.json `permissions.deny`.
#    - MUST NOT fail-closed or abort a session (no `set -e`); advisory exit code ONLY.
#    - exit 1 = "registry/pack desync to review", NEVER a tool-call/session blocker.
#    BSD-safe shell only (no grep -P / .*? / \d). `comm` over LC_ALL=C sort-ed lists.

shopt -s nullglob

# Resolve TAD root from this script's location (.tad/hooks/lib/ → up 3)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TAD_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
REPO_DIR="$(cd "$TAD_DIR/.." && pwd)"

REGISTRY="$TAD_DIR/capability-packs/pack-registry.yaml"
PACKS_DIR="$TAD_DIR/capability-packs"
SKILLS_DIR="$REPO_DIR/.claude/skills"

TMP_DIR="$(mktemp -d 2>/dev/null || echo /tmp)"
A_FILE="$TMP_DIR/drift_A.$$"
B_FILE="$TMP_DIR/drift_B.$$"
C_FILE="$TMP_DIR/drift_C.$$"
BC_FILE="$TMP_DIR/drift_BC.$$"
: > "$A_FILE"; : > "$B_FILE"; : > "$C_FILE"

cleanup() { rm -f "$A_FILE" "$B_FILE" "$C_FILE" "$BC_FILE" 2>/dev/null || true; }
trap cleanup EXIT

# --- Set A: registry pack names ---
if [ -f "$REGISTRY" ]; then
  grep '^  - name:' "$REGISTRY" 2>/dev/null \
    | sed 's/.*name: *"//; s/".*//' \
    | LC_ALL=C sort -u > "$A_FILE"
fi

# --- Set B: installed capability-pack skills (positive type-frontmatter probe, NO allowlist) ---
# A skill is a capability pack ONLY if its SKILL.md frontmatter declares
# type: reference-based | deep-skill | orchestration-router. Framework skills
# (alex/blake/gate/...) declare no pack type → naturally excluded → rot-free.
for skill_dir in "$SKILLS_DIR"/*/; do
  [ -f "$skill_dir/SKILL.md" ] || continue
  if grep -l '^type: \(reference-based\|deep-skill\|orchestration-router\)' "$skill_dir/SKILL.md" >/dev/null 2>&1; then
    basename "${skill_dir%/}"
  fi
done | LC_ALL=C sort -u > "$B_FILE"

# --- Set C: source packs (mirrors scan-packs' own gate exactly) ---
for pack_dir in "$PACKS_DIR"/*/; do
  [ -f "$pack_dir/CAPABILITY.md" ] || continue
  basename "${pack_dir%/}"
done | LC_ALL=C sort -u > "$C_FILE"

# B ∪ C
LC_ALL=C sort -u "$B_FILE" "$C_FILE" > "$BC_FILE"

# --- Differences (comm over LC_ALL=C sort-ed lists) ---
# comm -23 X Y → lines only in X (X minus Y)
c_minus_reg="$(LC_ALL=C comm -23 "$C_FILE" "$A_FILE")"   # (a) source pack not indexed
b_minus_reg="$(LC_ALL=C comm -23 "$B_FILE" "$A_FILE")"   # (b) installed skill not indexed
reg_minus_bc="$(LC_ALL=C comm -23 "$A_FILE" "$BC_FILE")" # (c) registry entry w/ neither src nor skill (true phantom)

echo "=== pack-registry drift-check (advisory) ==="
echo "registry: $REGISTRY"
echo "Set A (registry names): $(wc -l < "$A_FILE" | tr -d ' ')"
echo "Set B (installed pack skills): $(wc -l < "$B_FILE" | tr -d ' ')"
echo "Set C (source packs): $(wc -l < "$C_FILE" | tr -d ' ')"
echo ""

drift=0

echo "(a) source pack NOT in registry (C\\registry):"
if [ -n "$c_minus_reg" ]; then echo "$c_minus_reg" | sed 's/^/    /'; drift=1; else echo "    (none)"; fi

echo "(b) installed pack skill NOT in registry (B\\registry):"
if [ -n "$b_minus_reg" ]; then echo "$b_minus_reg" | sed 's/^/    /'; drift=1; else echo "    (none)"; fi

echo "(c) registry entry with neither source nor skill (registry\\(B∪C), true phantom):"
if [ -n "$reg_minus_bc" ]; then echo "$reg_minus_bc" | sed 's/^/    /'; drift=1; else echo "    (none)"; fi

# --- (d) advisory WARN — never changes exit ---
c_without_skill="$(LC_ALL=C comm -23 "$C_FILE" "$B_FILE")"  # source pack with no installed skill
skill_without_c="$(LC_ALL=C comm -13 "$C_FILE" "$B_FILE")"  # installed skill with no source pack
echo ""
echo "(d) advisory WARN (informational — does NOT affect exit code):"
if [ -n "$c_without_skill" ]; then
  echo "$c_without_skill" | while IFS= read -r p; do
    [ -n "$p" ] && echo "    WARN: source pack '$p' has no installed .claude/skills/$p/SKILL.md (source-only)"
  done
fi
if [ -n "$skill_without_c" ]; then
  echo "$skill_without_c" | while IFS= read -r p; do
    [ -n "$p" ] && echo "    WARN: installed skill '$p' has no source pack .tad/capability-packs/$p/ (skill-only)"
  done
fi
# indexed-but-no-install.sh (source pack present but missing install.sh → not *sync-portable)
for pack_dir in "$PACKS_DIR"/*/; do
  [ -f "$pack_dir/CAPABILITY.md" ] || continue
  if [ ! -f "$pack_dir/install.sh" ]; then
    echo "    WARN: source pack '$(basename "${pack_dir%/}")' has CAPABILITY.md but no install.sh (not *sync-portable)"
  fi
done
if [ -z "$c_without_skill" ] && [ -z "$skill_without_c" ]; then
  # still may have printed install.sh warnings above; print a neutral note only if truly clean
  :
fi

echo ""
if [ "$drift" -eq 1 ]; then
  echo "RESULT: DRIFT DETECTED (advisory) — review (a)/(b)/(c) above. NOT a session/release blocker."
  exit 1
else
  echo "RESULT: clean — registry in sync with source packs and installed pack skills."
  exit 0
fi
