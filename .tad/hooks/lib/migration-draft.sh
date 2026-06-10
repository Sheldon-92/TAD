#!/usr/bin/env bash
# migration-draft.sh — Generate draft migration manifests from git tag diffs.
# Outputs schema-v1 YAML to .tad/migrations/. Drafts require human review before committing.
#
# Usage: migration-draft.sh <from_tag> <to_tag> [--output-dir <dir>]
#   from_tag:    source git tag (e.g., v2.25.0)
#   to_tag:      target git tag (e.g., v2.26.0)
#   --output-dir: output directory (default: .tad/migrations/)
#
# Exit: 0 = draft generated, 2 = usage/error
#
# BSD/macOS safe: no grep -P. LC_ALL=C on sort. Quote all path expansions.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
DERIVE="$SCRIPT_DIR/derive-sync-set.sh"

usage() {
  echo "Usage: migration-draft.sh <from_tag> <to_tag> [--output-dir <dir>]" >&2
  echo "  Generates a draft migration manifest from git diff between two tags." >&2
  echo "  Drafts require human review before committing." >&2
}

if [ $# -lt 2 ]; then usage; exit 2; fi

FROM_TAG="$1"
TO_TAG="$2"
shift 2

OUTPUT_DIR=".tad/migrations"
while [ $# -gt 0 ]; do
  case "$1" in
    --output-dir)
      if [ $# -lt 2 ]; then echo "ERROR: --output-dir requires a value" >&2; exit 2; fi
      OUTPUT_DIR="$2"
      shift 2
      ;;
    *)
      echo "ERROR: unknown argument: $1" >&2; usage; exit 2
      ;;
  esac
done

# Validate tags exist in git
if ! git rev-parse --verify "$FROM_TAG" >/dev/null 2>&1; then
  echo "ERROR: tag '$FROM_TAG' does not exist in git" >&2
  exit 2
fi
if ! git rev-parse --verify "$TO_TAG" >/dev/null 2>&1; then
  echo "ERROR: tag '$TO_TAG' does not exist in git" >&2
  exit 2
fi

# Extract versions: strip 'v' prefix
FROM_VER="${FROM_TAG#v}"
TO_VER="${TO_TAG#v}"

# Normalize to 3-segment semver (add .0 if only 2 segments)
case "$FROM_VER" in
  *.*.*) ;; # already 3 segments
  *.*) FROM_VER="${FROM_VER}.0" ;;
  *) echo "ERROR: cannot parse version from tag '$FROM_TAG'" >&2; exit 2 ;;
esac
case "$TO_VER" in
  *.*.*) ;; # already 3 segments
  *.*) TO_VER="${TO_VER}.0" ;;
  *) echo "ERROR: cannot parse version from tag '$TO_TAG'" >&2; exit 2 ;;
esac

# Output filename
OUT_FILE="$OUTPUT_DIR/${FROM_VER}-to-${TO_VER}.yaml"

# Refuse to overwrite existing manifest (FR2.11)
if [ -f "$OUT_FILE" ]; then
  echo "ERROR: manifest already exists: $OUT_FILE" >&2
  echo "Refusing to overwrite. Delete the existing file first if you want to regenerate." >&2
  exit 2
fi

# Read ZERO_TOUCH dirs from derive-sync-set.sh
ZT_DIRS=""
if [ -f "$DERIVE" ]; then
  ZT_DIRS="$(bash "$DERIVE" --zero-touch 2>/dev/null)" || true
fi

# Build a grep filter pattern for ZERO_TOUCH dirs under .tad/
# Each line from --zero-touch is a basename (e.g., "active", "archive", etc.)
ZT_FILTER=""
if [ -n "$ZT_DIRS" ]; then
  ZT_FILTER="$(printf '%s\n' "$ZT_DIRS" | sed 's|^|^\\.tad/|;s|$|/|' | paste -sd '|' -)"
fi

# Run git diff --name-status -M scoped to framework-managed paths
DIFF_OUTPUT="$(git diff --name-status -M "$FROM_TAG".."$TO_TAG" -- .tad/ .claude/ .codex/ .agents/ CLAUDE.md AGENTS.md tad.sh 2>/dev/null)" || true

# Classify entries
DELETES=""
RENAMES=""
ADDED=""
DELETE_COUNT=0
RENAME_COUNT=0
POSSIBLE_RENAME_COUNT=0

while IFS= read -r line; do
  [ -n "$line" ] || continue
  status="$(printf '%s' "$line" | cut -f1)"
  # Normalize status: R followed by digits is a rename
  case "$status" in
    D)
      path="$(printf '%s' "$line" | cut -f2)"
      # Filter out ZERO_TOUCH paths
      if [ -n "$ZT_FILTER" ] && printf '%s\n' "$path" | LC_ALL=C grep -qE "$ZT_FILTER"; then
        continue
      fi
      DELETES="${DELETES}${path}"$'\n'
      DELETE_COUNT=$((DELETE_COUNT + 1))
      ;;
    R*)
      from_path="$(printf '%s' "$line" | cut -f2)"
      to_path="$(printf '%s' "$line" | cut -f3)"
      # Filter out ZERO_TOUCH paths (both from and to)
      if [ -n "$ZT_FILTER" ]; then
        if printf '%s\n' "$from_path" | LC_ALL=C grep -qE "$ZT_FILTER"; then continue; fi
        if printf '%s\n' "$to_path" | LC_ALL=C grep -qE "$ZT_FILTER"; then continue; fi
      fi
      RENAMES="${RENAMES}${from_path}	${to_path}"$'\n'
      RENAME_COUNT=$((RENAME_COUNT + 1))
      ;;
    A)
      path="$(printf '%s' "$line" | cut -f2)"
      # Filter out ZERO_TOUCH paths
      if [ -n "$ZT_FILTER" ] && printf '%s\n' "$path" | LC_ALL=C grep -qE "$ZT_FILTER"; then
        continue
      fi
      ADDED="${ADDED}${path}"$'\n'
      ;;
  esac
done <<EOF
$DIFF_OUTPUT
EOF

# Secondary rename detection: for each D, check if any A has same basename
POSSIBLE_RENAMES=""
if [ -n "$DELETES" ] && [ -n "$ADDED" ]; then
  # Build list of added basenames
  added_basenames=""
  while IFS= read -r a_path; do
    [ -n "$a_path" ] || continue
    added_basenames="${added_basenames}$(basename "$a_path")"$'\n'
  done <<EOF2
$ADDED
EOF2

  while IFS= read -r d_path; do
    [ -n "$d_path" ] || continue
    d_base="$(basename "$d_path")"
    if printf '%s\n' "$added_basenames" | grep -qxF "$d_base"; then
      # Find the matching added path
      match=""
      while IFS= read -r a_path; do
        [ -n "$a_path" ] || continue
        if [ "$(basename "$a_path")" = "$d_base" ]; then
          match="$a_path"
          break
        fi
      done <<EOF3
$ADDED
EOF3
      POSSIBLE_RENAMES="${POSSIBLE_RENAMES}${d_path}	${match}"$'\n'
      POSSIBLE_RENAME_COUNT=$((POSSIBLE_RENAME_COUNT + 1))
    fi
  done <<EOF4
$DELETES
EOF4
fi

# Create output directory if needed
mkdir -p "$OUTPUT_DIR"

# Emit YAML
{
  printf 'schema_version: 1\n'
  printf 'from: "%s"\n' "$FROM_VER"
  printf 'to: "%s"\n' "$TO_VER"
  printf 'generated_by: "draft-script"\n'

  # Delete section
  if [ "$DELETE_COUNT" -eq 0 ]; then
    printf 'delete: []\n'
  else
    printf 'delete:\n'
    while IFS= read -r d_path; do
      [ -n "$d_path" ] || continue
      # Check if this delete has a possible rename partner
      is_possible_rename=0
      if [ -n "$POSSIBLE_RENAMES" ]; then
        if printf '%s\n' "$POSSIBLE_RENAMES" | grep -qF "$d_path	"; then
          is_possible_rename=1
        fi
      fi
      printf '  - path: "%s"\n' "$d_path"
      printf '    type: "file"\n'
      printf '    reason: "TODO: add reason"\n'
      if [ "$is_possible_rename" -eq 1 ]; then
        # Find the match
        match_path=""
        while IFS= read -r pr_line; do
          [ -n "$pr_line" ] || continue
          pr_from="$(printf '%s' "$pr_line" | cut -f1)"
          pr_to="$(printf '%s' "$pr_line" | cut -f2)"
          if [ "$pr_from" = "$d_path" ]; then
            match_path="$pr_to"
            break
          fi
        done <<PREOF
$POSSIBLE_RENAMES
PREOF
        printf '    # POSSIBLE RENAME: basename matches added file "%s"\n' "$match_path"
        printf '    # Review: if this is a rename, move to rename section instead.\n'
      fi
    done <<DEOF
$DELETES
DEOF
  fi

  # Rename section
  if [ "$RENAME_COUNT" -eq 0 ]; then
    printf 'rename: []\n'
  else
    printf 'rename:\n'
    while IFS= read -r r_line; do
      [ -n "$r_line" ] || continue
      r_from="$(printf '%s' "$r_line" | cut -f1)"
      r_to="$(printf '%s' "$r_line" | cut -f2)"
      printf '  - from: "%s"\n' "$r_from"
      printf '    to: "%s"\n' "$r_to"
      printf '    type: "file"\n'
      printf '    reason: "TODO: add reason"\n'
    done <<REOF
$RENAMES
REOF
  fi

  # Merge section (always empty in drafts)
  printf 'merge: []\n'

  # Verify section
  if [ "$DELETE_COUNT" -eq 0 ] && [ "$RENAME_COUNT" -eq 0 ]; then
    printf 'verify: []\n'
  else
    printf 'verify:\n'
    # Absent checks for deleted files
    while IFS= read -r d_path; do
      [ -n "$d_path" ] || continue
      printf '  - type: "absent"\n'
      printf '    path: "%s"\n' "$d_path"
    done <<VDEOF
$DELETES
VDEOF
    # Absent checks for rename sources
    while IFS= read -r r_line; do
      [ -n "$r_line" ] || continue
      r_from="$(printf '%s' "$r_line" | cut -f1)"
      printf '  - type: "absent"\n'
      printf '    path: "%s"\n' "$r_from"
    done <<VREOF
$RENAMES
VREOF
    # Present checks for rename targets
    while IFS= read -r r_line; do
      [ -n "$r_line" ] || continue
      r_to="$(printf '%s' "$r_line" | cut -f2)"
      printf '  - type: "present"\n'
      printf '    path: "%s"\n' "$r_to"
    done <<VR2EOF
$RENAMES
VR2EOF
  fi
} > "$OUT_FILE"

# Summary
echo "========================================="
echo "MIGRATION DRAFT: ${FROM_VER} → ${TO_VER}"
echo "========================================="
echo "  Output:           $OUT_FILE"
echo "  Deletes:          $DELETE_COUNT"
echo "  Renames:          $RENAME_COUNT"
echo "  Possible renames: $POSSIBLE_RENAME_COUNT"
echo ""
echo "This is a DRAFT. Review and commit manually."
echo "========================================="
