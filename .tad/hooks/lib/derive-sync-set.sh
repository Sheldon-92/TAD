#!/usr/bin/env bash
# derive-sync-set.sh — SOLE source of truth for the release/sync DENY_LIST,
# the zero-touch subset, and the capability-packs registry-only sub-rule.
#
# Replaces the brittle hardcoded 14-dir allow-list with a DENY-LIST derivation:
#   SYNC_DIRS = { ls -d .tad/*/ } - DENY_LIST
# A new framework dir is therefore auto-included with ZERO list edits (bias-to-sync),
# and a main-only dir is excluded by adding it to the ONE DENY_LIST constant below.
#
# ============================ CONTRACT (consumed API) ============================
# Usage: derive-sync-set.sh [--dirs|--report|--zero-touch|--transient|--registry-only] [<root=.>]
#   --dirs          (default) one SYNC dir basename per line, LC_ALL=C sorted.
#                   CONSUMED FORMAT (breaking change if altered): one ASCII basename
#                   per line, NO trailing slash, NO path prefix, LC_ALL=C sort order.
#                   Read by: release-verify.sh structural + the per-release generator.
#   --zero-touch    the 10 category-A "preserve target's own" dir names, LC_ALL=C sorted.
#                   Read by: release-verify.sh version (the version-scope exclusion set).
#                   This is the ONE authoritative zero-touch source — NOT re-hardcoded.
#   --transient     the category-C transient / main-only dir names, LC_ALL=C sorted.
#                   Together with --zero-touch this is the PUBLIC interface to the full
#                   DENY_LIST (zero-touch ∪ transient). Read by: tad.sh --verify-denylist
#                   (drift-check compares its inline DENY_LIST against these two flags —
#                   NO awk-scraping of internal variable names).
#   --registry-only the single sub-path rule line: capability-packs/pack-registry.yaml
#                   Read by: release-verify.sh structural + the per-release generator
#                   (they diff/sync ONLY this file for that dir, never the dir tree).
#                   The registry-only special-case lives HERE ALONE — consumers READ it.
#   --report        three labelled sections (ZERO-TOUCH / FRAMEWORK-SYNC / TRANSIENT)
#                   + the special-case notes. Emitted by the release gate EVERY run so a
#                   newly-included dir is auditable (bias-to-sync + REPORT the synced set).
# Exit: 0 normal; 2 bad flag / missing root. (Never exit 1 — this command has no drift.)
#
# ----- P2 embeddability (NFR4) -----
# EMBEDDABLE-VERBATIM into a standalone installer (tad.sh on a fresh machine where
# .tad/hooks/lib/ does not yet exist and cannot be sourced): the DENY_LIST constant
# plus the derivation pipeline
#     ls -d "$root"/.tad/*/ | sed 's|.*/.tad/||;s|/$||' | grep -vxE "$DENY_RE" | LC_ALL=C sort
# REPO-CONTEXT-ONLY (NOT embeddable as-is): anything that reads sibling .tad/ dirs to
# classify them (the --report sections). Keep the constant block + pipeline copy-pasteable
# so P2 either curl-fetches+sources this lib OR inlines the SAME block — never a 2nd copy.
# =================================================================================
#
# BSD/macOS safe: no grep -P. LC_ALL=C on every sort. Quote all path expansions
# (repo path contains a space: "01-on progress programs").
set -euo pipefail

# ───────────────────── SINGLE SOURCE OF TRUTH (hand-maintained) ─────────────────────
# DENY_LIST = category-A (zero-touch, 10) + category-C (transient/main-only, 5) = 15 dirs.
# A dir NOT in this list defaults to SYNC (framework) — the bias-to-sync escape from the
# omission disease. To make a new dir main-only, ADD its basename here (the user's escape hatch).
#
# Category A — zero-touch (preserve each target's own copy; NEVER sync, 10 dirs):
ZERO_TOUCH="project-knowledge
active
archive
evidence
pair-testing
decisions
github-registry
research-notebooks
skill-library
skillify-candidates"
# Category C — transient / main-only (do NOT sync; not part of the framework surface):
TRANSIENT="working
spike-v3
reports
checklists
domains"

# DENY_LIST = A ∪ C (the full set excluded from SYNC).
DENY_LIST="$ZERO_TOUCH
$TRANSIENT"

# Top-level deny (a FILE, not a dir — excluded from top-level config copy):
TOP_DENY="sync-registry.yaml"

# The ONE dir with a sub-path rule: sync/diff ONLY its registry index, never the tree.
REGISTRY_ONLY="capability-packs"
REGISTRY_FILE="pack-registry.yaml"

# Build the whole-line alternation for grep -vxE from DENY_LIST (bare pipe, no backslash).
# (EMBEDDABLE: this RE + the pipeline below are the copy-pasteable derivation block.)
DENY_RE="$(printf '%s' "$DENY_LIST" | LC_ALL=C sort -u | paste -sd '|' -)"

# ───────────────────────────────── derivation ─────────────────────────────────
MODE="${1:---dirs}"
ROOT="${2:-.}"

if [ ! -d "$ROOT/.tad" ]; then
  echo "ERROR: no .tad/ under root: $ROOT" >&2
  exit 2
fi

emit_dirs() {
  # ls the .tad/ subdirs → basename (strip path prefix + trailing slash) → drop DENY members → sort.
  ls -d "$ROOT"/.tad/*/ 2>/dev/null \
    | sed 's|.*/\.tad/||;s|/$||' \
    | grep -vxE "$DENY_RE" \
    | LC_ALL=C sort
}

case "$MODE" in
  --dirs)
    emit_dirs
    ;;
  --zero-touch)
    printf '%s\n' "$ZERO_TOUCH" | LC_ALL=C sort
    ;;
  --transient)
    printf '%s\n' "$TRANSIENT" | LC_ALL=C sort
    ;;
  --registry-only)
    printf '%s/%s\n' "$REGISTRY_ONLY" "$REGISTRY_FILE"
    ;;
  --report)
    echo "=== RELEASE SYNC SET (derived from $ROOT/.tad/ — bias-to-sync, REPORTED each run) ==="
    echo ""
    echo "--- A. ZERO-TOUCH (preserve target's own — NEVER sync) ---"
    printf '%s\n' "$ZERO_TOUCH" | LC_ALL=C sort | sed 's/^/  /'
    echo "  (+ top-level file: $TOP_DENY)"
    echo ""
    echo "--- B. FRAMEWORK-SYNC (derived = live dirs MINUS deny-list — the auto-included set) ---"
    emit_dirs | sed 's/^/  /'
    echo ""
    echo "--- C. TRANSIENT / MAIN-ONLY (do NOT sync) ---"
    printf '%s\n' "$TRANSIENT" | LC_ALL=C sort | sed 's/^/  /'
    echo ""
    echo "--- Special-case notes ---"
    echo "  * $REGISTRY_ONLY → sync/diff ONLY $REGISTRY_ONLY/$REGISTRY_FILE (registry index), never the pack tree."
    echo "  * per-release one-shot scripts → write to .tad/evidence/releases/ (zero-touch ⇒ not in the synced set)."
    ;;
  *)
    echo "Usage: derive-sync-set.sh [--dirs|--report|--zero-touch|--transient|--registry-only] [<root=.>]" >&2
    exit 2
    ;;
esac
