#!/usr/bin/env bash
# verify-deploy-hardening.sh — deterministic GitHub Actions hardening checker.
#
# Greps .github/workflows/*.yml|*.yaml for the deterministic hardening violations the
# web-deployment pack treats as P0/P1, so the agent does not "punt to Claude" what code
# can decide. Emits findings in the same [P0]/[P1] format as the pack's Step 1 output.
#
# Checks:
#   [P0] uses: pinned to a tag/branch instead of a 40-char commit SHA   (CI2, CI9)
#   [P0] actions/upload-artifact|download-artifact @v3 or @v2 (dead since 2025-01-30) (CI11)
#   [P1] workflow missing a top-level `permissions:` block             (CI10 excessive-permissions)
#   [P1] container image referenced by `:latest` tag (non-deterministic) (Cross-Cutting: immutable)
#
# Usage:
#   scripts/verify-deploy-hardening.sh [DIR]        # default DIR=.github/workflows
# Exit codes: 0 = clean, 1 = P1 findings only, 2 = P0 findings present, 3 = no workflows found.

set -euo pipefail

DIR="${1:-.github/workflows}"

if [ ! -d "$DIR" ]; then
  echo "[INFO] no workflow directory at '$DIR' — nothing to check."
  exit 3
fi

# Collect workflow files (portable: no mapfile, works on macOS bash 3.2).
files=""
for ext in yml yaml; do
  for f in "$DIR"/*."$ext"; do
    [ -e "$f" ] || continue
    files="$files$f
"
  done
done

if [ -z "$files" ]; then
  echo "[INFO] no .yml/.yaml workflows found under '$DIR' — nothing to check."
  exit 3
fi

p0=0
p1=0

while IFS= read -r f; do
  [ -n "$f" ] || continue

  # --- [P0] unpinned uses: (tag/branch ref, not a 40-char SHA) ---
  # Match lines like:  - uses: actions/checkout@v4   /   uses: owner/repo@main
  # A pinned ref is exactly 40 lowercase hex chars after '@'. Anything else is unpinned.
  # Skip local (./...) and docker:// composite references.
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    line="${line#*:}"          # drop the leading "<lineno>:" added by grep -n
    ref="${line#*@}"           # everything after the first '@'
    ref="${ref%%[[:space:]]*}" # strip trailing comment/space
    ref="${ref%%#*}"
    case "$line" in
      *"uses:"*"./"*|*"uses:"*"docker://"*) continue ;;
    esac
    # 40-char hex (any case — GitHub canonicalizes to lowercase, but accept a
    # hand-typed uppercase SHA rather than false-flag it) => pinned => OK. Otherwise flag.
    if printf '%s' "$ref" | grep -qE '^[0-9A-Fa-f]{40}$'; then
      continue
    fi
    action="$(printf '%s' "$line" | sed 's/^[[:space:]-]*uses:[[:space:]]*//')"
    echo "[P0] $f: unpinned action '$action' — pin to a 40-char commit SHA (CI2; CVE-2025-30066/CI9). Re-resolve via scripts/find-action-sha.sh"
    p0=$((p0 + 1))
  done <<EOF
$(grep -nE '^[[:space:]-]*uses:[[:space:]]*[^[:space:]]+@[^[:space:]]+' "$f" 2>/dev/null || true)
EOF

  # --- [P0] dead artifact action majors (@v3 / @v2) ---
  if grep -qE 'actions/(upload|download)-artifact@v[23]([^0-9]|$)' "$f" 2>/dev/null; then
    echo "[P0] $f: actions/upload|download-artifact @v2/@v3 — dead since 2025-01-30 (job FAILS). Migrate to @v4 (CI11)."
    p0=$((p0 + 1))
  fi

  # --- [P1] missing top-level permissions block ---
  # A top-level key starts at column 0. Look for a line beginning with 'permissions:'.
  if ! grep -qE '^permissions:' "$f" 2>/dev/null; then
    echo "[P1] $f: no top-level 'permissions:' block — declare least privilege (start 'permissions: {}', widen per job) (CI10)."
    p1=$((p1 + 1))
  fi

  # --- [P1] :latest image tags (non-deterministic deploy) ---
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    line="${line#*:}"          # drop the leading "<lineno>:" added by grep -n
    echo "[P1] $f: container image pinned to ':latest' — non-deterministic, breaks immutable-deploy/rollback. Pin a digest or SHA tag: $(printf '%s' "$line" | sed 's/^[[:space:]]*//')"
    p1=$((p1 + 1))
  done <<EOF
$(grep -nE '(image:|FROM )[[:space:]]*[^[:space:]]+:latest([^0-9A-Za-z._-]|$)' "$f" 2>/dev/null || true)
EOF

done <<EOF
$files
EOF

echo "----"
echo "Summary: $p0 P0, $p1 P1 finding(s) across workflows in '$DIR'."

if [ "$p0" -gt 0 ]; then
  exit 2
elif [ "$p1" -gt 0 ]; then
  exit 1
fi
echo "[OK] no deploy-hardening violations detected."
exit 0
