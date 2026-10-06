#!/usr/bin/env bash
# pack-registry-driftcheck.sh — Advisory bidirectional pack/registry drift detector.
#
# Compares pack-registry.yaml (the derived index) against ground truth on disk:
#   Set A      = registry pack names
#   Set B_type = installed skills whose SKILL.md frontmatter is visible to the
#                positive pack-type probe (reference-based | deep-skill |
#                orchestration-router)
#   Set B_dir  = names in A∪C whose .agents/skills/<name>/SKILL.md exists
#   Set C      = source packs (.tad/capability-packs/*/ with a CAPABILITY.md)
# Reports (a) C\registry  (b) B_type\registry
#         (c) registry\(B_dir∪C) — the only registry-phantom drift class;
#         (r) registry-only: A∩(B_dir∪C)\B_type — registered and present as a
#             source pack and/or projection directory, but invisible to the
#             type probe; advisory only and never sets drift.
# (d) advisory WARN lines (source-only by C\B_dir / skill-only by B_type\C /
# indexed-but-no-install.sh) — never change exit.
#
# Three-layer summary: scan-packs asserts registry⊆projection on the release
# source; this driftcheck is an advisory patrol surface; the type probe alone
# cannot prove a projection is absent. Forms: P1 complete projection = no
# report; P2 projection present but type-invisible = (r); M2 source present,
# projection directory absent = (d); M1 registered with neither source nor
# projection directory = (c).
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
SKILLS_DIR="$REPO_DIR/.agents/skills"

TMP_DIR="$(mktemp -d 2>/dev/null || echo /tmp)"
A_FILE="$TMP_DIR/drift_A.$$"
B_FILE="$TMP_DIR/drift_B.$$"
BDIR_FILE="$TMP_DIR/drift_BDIR.$$"
C_FILE="$TMP_DIR/drift_C.$$"
BDIRC_FILE="$TMP_DIR/drift_BDIRC.$$"
ABC_FILE="$TMP_DIR/drift_ABC.$$"
: > "$A_FILE"; : > "$B_FILE"; : > "$BDIR_FILE"; : > "$C_FILE"

cleanup() { rm -f "$A_FILE" "$B_FILE" "$BDIR_FILE" "$C_FILE" "$BDIRC_FILE" "$ABC_FILE" 2>/dev/null || true; }
trap cleanup EXIT

# --- Set A: registry pack names ---
if [ -f "$REGISTRY" ]; then
  grep '^  - name:' "$REGISTRY" 2>/dev/null \
    | sed 's/.*name: *"//; s/".*//' \
    | LC_ALL=C sort -u > "$A_FILE"
fi

# --- Set B_type: installed capability-pack skills (positive type-frontmatter probe, NO allowlist) ---
# A skill is visible to this probe ONLY if its SKILL.md frontmatter declares
# type: reference-based | deep-skill | orchestration-router. Framework skills
# (alex/blake/gate/...) declare no pack type → naturally excluded → rot-free.
# Type-probe invisibility is not evidence that a projection directory is absent.
for skill_dir in "$SKILLS_DIR"/*/; do
  [ -f "$skill_dir/SKILL.md" ] || continue
  if grep -l '^type: \(reference-based\|deep-skill\|orchestration-router\)' "$skill_dir/SKILL.md" >/dev/null 2>&1; then
    basename "${skill_dir%/}"
  fi
done | LC_ALL=C sort -u > "$B_FILE"

# --- Set C: source packs (mirrors scan-packs' own gate exactly) ---
# C is available only when at least one source pack is present. A repo form
# that carries the registry without source-pack directories has no usable
# Set C; (c) is then judged against projection directories only.
C_AVAILABLE=0
if [ -d "$PACKS_DIR" ]; then
  for pack_dir in "$PACKS_DIR"/*/; do
    [ -f "$pack_dir/CAPABILITY.md" ] || continue
    basename "${pack_dir%/}"
  done | LC_ALL=C sort -u > "$C_FILE"
  if [ -s "$C_FILE" ]; then
    C_AVAILABLE=1
  fi
fi

# --- Set B_dir: registered/source names with an installed SKILL.md ---
# This is intentionally scoped to A∪C: it answers whether a name already in
# the registry/source universe has a projection directory, regardless of the
# type probe.
LC_ALL=C sort -u "$A_FILE" "$C_FILE" | while IFS= read -r pack_name; do
  [ -n "$pack_name" ] || continue
  if [ -f "$SKILLS_DIR/$pack_name/SKILL.md" ]; then
    printf '%s\n' "$pack_name"
  fi
done | LC_ALL=C sort -u > "$BDIR_FILE"

# B_dir ∪ C
LC_ALL=C sort -u "$BDIR_FILE" "$C_FILE" > "$BDIRC_FILE"
# A ∩ (B_dir ∪ C), the starting set for (r)
LC_ALL=C comm -12 "$A_FILE" "$BDIRC_FILE" > "$ABC_FILE"

# --- Differences (comm over LC_ALL=C sort-ed lists) ---
# comm -23 X Y → lines only in X (X minus Y)
c_minus_reg="$(LC_ALL=C comm -23 "$C_FILE" "$A_FILE")"       # (a) source pack not indexed
b_minus_reg="$(LC_ALL=C comm -23 "$B_FILE" "$A_FILE")"       # (b) type-visible installed skill not indexed
reg_minus_bdir_c="$(LC_ALL=C comm -23 "$A_FILE" "$BDIRC_FILE")" # (c) neither projection dir nor source
registry_only="$(LC_ALL=C comm -23 "$ABC_FILE" "$B_FILE")"   # (r) present but type-probe invisible

echo "=== pack-registry drift-check (advisory) ==="
echo "registry: $REGISTRY"
echo "Set A (registry names): $(wc -l < "$A_FILE" | tr -d ' ')"
echo "Set B_type (type-probed installed pack skills): $(wc -l < "$B_FILE" | tr -d ' ')"
echo "Set B_dir (registered/source names with installed SKILL.md): $(wc -l < "$BDIR_FILE" | tr -d ' ')"
echo "Set C (source packs): $(wc -l < "$C_FILE" | tr -d ' ')"
if [ "$C_AVAILABLE" -eq 0 ]; then
  echo "Set C unavailable in this repo form — (c) judged against projection dirs only"
fi
echo ""

drift=0

echo "(a) source pack NOT in registry (C\\registry):"
if [ -n "$c_minus_reg" ]; then echo "$c_minus_reg" | sed 's/^/    /'; drift=1; else echo "    (none)"; fi

echo "(b) installed pack skill NOT in registry (B_type\\registry):"
if [ -n "$b_minus_reg" ]; then echo "$b_minus_reg" | sed 's/^/    /'; drift=1; else echo "    (none)"; fi

echo "(c) registry entry with neither projection directory nor source pack (registry\\(B_dir∪C), true phantom):"
if [ -n "$reg_minus_bdir_c" ]; then echo "$reg_minus_bdir_c" | sed 's/^/    /'; drift=1; else echo "    (none)"; fi

echo "(r) registry-only (registered and present, type-probe invisible; advisory — never drift):"
if [ -n "$registry_only" ]; then echo "$registry_only" | sed 's/^/    /'; else echo "    (none)"; fi

# --- (d) advisory WARN — never changes exit ---
c_without_skill="$(LC_ALL=C comm -23 "$C_FILE" "$BDIR_FILE")"  # source pack with no projection directory
skill_without_c="$(LC_ALL=C comm -13 "$C_FILE" "$B_FILE")"  # type-visible installed skill with no source pack
echo ""
echo "(d) advisory WARN (informational — does NOT affect exit code):"
if [ -n "$c_without_skill" ]; then
  echo "$c_without_skill" | while IFS= read -r p; do
    [ -n "$p" ] && echo "    WARN: source pack '$p' has no installed .agents/skills/$p/SKILL.md (source-only)"
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
