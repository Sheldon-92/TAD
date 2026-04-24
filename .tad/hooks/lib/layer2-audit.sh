#!/usr/bin/env bash
# layer2-audit.sh — Layer 2 reviewer-artifact presence check (smoke alarm)
# Called by Alex acceptance_protocol.step4c as a non-blocking, non-hook tool.
# Usage:  bash .tad/hooks/lib/layer2-audit.sh <handoff-slug>
# Exit:   0 PASS | 1 FAIL (stderr red) | 2 usage/slug-invalid
# No PreToolUse hook registration. No dep-guard. Pure bash + stat + find.

set -euo pipefail
IFS=$'\n\t'

# ── ANSI color selection ────────────────────────────────────────────────
_red=""; _reset=""
if [ -z "${NO_COLOR:-}" ] && [ -t 2 ]; then
  _red=$'\033[31m'; _reset=$'\033[0m'
fi

_err() { printf '%s%s%s\n' "$_red" "$*" "$_reset" >&2; }

# ── Runtime stat flavor detection ───────────────────────────────────────
# GNU stat supports --version; BSD (macOS) does not.
if stat --version >/dev/null 2>&1; then
  _file_size() { stat -c%s -- "$1" 2>/dev/null || echo 0; }
else
  _file_size() { stat -f%z -- "$1" 2>/dev/null || echo 0; }
fi

# ── Arg parse + slug whitelist ─────────────────────────────────────────
if [ $# -ne 1 ]; then
  _err "usage: $(basename -- "$0") <slug>"
  exit 2
fi
slug_raw="$1"
slug_disp="${slug_raw:0:64}"  # truncate for stderr display (anti-DoS)

# Strict whitelist: ^[A-Za-z0-9_]([A-Za-z0-9_-]*[A-Za-z0-9_])?$
# - anchored both ends
# - first/last char must be [A-Za-z0-9_] (disallows leading/trailing dash → prevents argv-flag injection)
# - empty / single "-" rejected
if ! [[ "$slug_raw" =~ ^[A-Za-z0-9_]([A-Za-z0-9_-]*[A-Za-z0-9_])?$ ]]; then
  _err "Layer 2 audit FAIL: invalid slug '${slug_disp}' (size-check is smoke-alarm heuristic; see AC2 whitelist)"
  exit 2
fi
slug="$slug_raw"

# ── Slug truncation fallback (P1.3, 2026-04-24) ────────────────────────
# When the exact slug dir is missing/empty, try up to 2 levels of trailing
# "-segment" truncation. Precedent: toy 2026-04-23 loop-mpr121-da7280 vs
# -integration FN fired twice in 8 days. Bounded to 2 attempts — anything
# further is not canonicalization, it's guessing.
# Single-segment slug (no '-') OR empty truncation → skip fallback (CR-P1-3).

_has_review_md() {
  # True if dir exists and contains ≥1 non-dotfile .md file.
  [ -d "$1" ] || return 1
  local first_match
  first_match=$(find -L -- "$1" -maxdepth 1 -type f -name '[!.]*.md' -print -quit 2>/dev/null || true)
  [ -n "$first_match" ]
}

if ! _has_review_md ".tad/evidence/reviews/blake/${slug}"; then
  slug_try1="${slug%-*}"
  if [ "$slug_try1" = "$slug" ] || [ -z "$slug_try1" ]; then
    # Single-segment slug OR truncation collapsed to empty — do not recurse.
    :
  elif _has_review_md ".tad/evidence/reviews/blake/${slug_try1}"; then
    printf "Layer 2 audit WARN: exact slug '%s' not found; matched truncated '%s' — consider canonicalizing slug.\n" \
      "$slug" "$slug_try1" >&2
    slug="$slug_try1"
  else
    slug_try2="${slug_try1%-*}"
    if [ -n "$slug_try2" ] && [ "$slug_try2" != "$slug_try1" ] \
       && _has_review_md ".tad/evidence/reviews/blake/${slug_try2}"; then
      printf "Layer 2 audit WARN: exact slug '%s' not found; matched doubly-truncated '%s'\n" \
        "$slug" "$slug_try2" >&2
      slug="$slug_try2"
    fi
    # else: fall through to original FAIL path below.
  fi
fi

# ── Target dir check ────────────────────────────────────────────────────
dir=".tad/evidence/reviews/blake/${slug}"
if [ ! -d "$dir" ]; then
  _err "Layer 2 audit FAIL: directory missing: ${dir} (size-check is smoke-alarm heuristic — Blake may have skipped Layer 2)"
  exit 1
fi

# ── Enumerate candidate .md files (exclude dotfiles, follow symlinks) ──
# maxdepth 1 — don't recurse into subdirs. -L follows symlinks to their targets.
# Names starting with '.' excluded by find -name '[!.]*.md'.
min_bytes=200
qualified=0
total_found=0
had_small=0
had_symlink_small=0

while IFS= read -r -d '' f; do
  total_found=$((total_found + 1))
  sz=$(_file_size "$f")
  if [ "$sz" -ge "$min_bytes" ]; then
    qualified=$((qualified + 1))
  else
    had_small=1
    # distinguish symlinked target
    if [ -L "$f" ]; then
      had_symlink_small=1
    fi
  fi
done < <(find -L -- "$dir" -maxdepth 1 -type f -name '[!.]*.md' -print0 2>/dev/null)

# ── Verdict ─────────────────────────────────────────────────────────────
if [ "$qualified" -ge 1 ]; then
  # PASS: stdout only, stderr MUST be empty
  printf 'Layer 2 audit PASS: %d reviewer artifacts found\n' "$qualified"
  exit 0
fi

# FAIL paths (order matters for precise error)
if [ "$total_found" -eq 0 ]; then
  # Check if any dotfile-only md files exist (edge case e)
  if find -L -- "$dir" -maxdepth 1 -type f -name '.*.md' -print -quit 2>/dev/null | grep -q .; then
    _err "Layer 2 audit FAIL: only dotfiles in ${dir} (hidden reviewer files don't count; size-check is smoke-alarm heuristic)"
  else
    _err "Layer 2 audit FAIL: no .md files in ${dir} (size-check is smoke-alarm heuristic)"
  fi
  exit 1
fi

# total_found >= 1 but qualified == 0 → had small files
if [ "$had_symlink_small" = 1 ]; then
  _err "Layer 2 audit FAIL: symlinked target too small in ${dir} (< ${min_bytes}B; size-check is smoke-alarm heuristic)"
else
  _err "Layer 2 audit FAIL: all ${total_found} .md file(s) in ${dir} under ${min_bytes}B (size-check is smoke-alarm heuristic)"
fi
exit 1
