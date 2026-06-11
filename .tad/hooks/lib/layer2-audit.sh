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

# ── Phase 6-A.2 (2026-04-25): Reviewer-name detection ───────────────────
# BA-P0-2: Single source of truth for Layer 2 reviewer agent types.
# Blake SKILL `gate3_v2.layer2_expert_review.hard_requirement_distinct_reviewers`
# references THIS array via prose, does NOT enumerate. Add new sub-agent types
# here when first used as Layer 2 reviewer; SKILL automatically inherits.
KNOWN_REVIEWERS_LIST="code-reviewer code-review backend-architect security-auditor performance-optimizer ux-expert-reviewer api-designer data-analyst bug-hunter test-runner spec-compliance-reviewer spec-compliance refactor-specialist devops-engineer database-expert frontend-specialist docs-writer config-manager config-manager-review"

# SUBSTITUTION_HEURISTICS: filenames that look reviewer-ish but are NOT
# external sub-agent invocations. self-review = Blake reviewing Blake (no
# second perspective). feedback-integration = synthesis doc, not review.
# gate3-verdict = Blake's own gate verdict, not external review.
SUBSTITUTION_HEURISTICS_LIST="self-review feedback-integration gate3-verdict"

# CR-P0-6 fix: word-boundary express slug detection (NOT substring).
# Defends against false-positives: "expression" / "compress" / "espresso".
# Patterns:
#   - "express"               (slug literally is "express")
#   - "*-express"             (slug ends with "-express", e.g. "phase6-express")
#   - "*-express-*"           (slug contains "-express-", e.g. "phase6-express-styling")
#   - "express-*"             (slug starts with "express-", e.g. "express-bugfix")
is_express_slug() {
  local s="$1"
  case "$s" in
    express|*-express|*-express-*|express-*) return 0 ;;
    *) return 1 ;;
  esac
}

# CR-P0-4 fix: detect distinct reviewer agent NAMES via find -print0 + read -d ''
# loop with case statement (BSD-portable, fork-free, faster than per-name grep).
# Outputs structured machine-readable lines (CR-P0-5 fix) for AC matching:
#   DISTINCT_COUNT=N
#   DISTINCT_LIST=<space-separated reviewer names>
#   SUBSTITUTIONS=<space-separated substitution names found>
#   UNKNOWN=<space-separated names not in either list>
detect_distinct_reviewers() {
  local d="$1"
  local distinct_count=0
  local distinct_list=""
  local substitutions_list=""
  local unknown_list=""
  local name
  while IFS= read -r -d '' f; do
    name="${f##*/}"
    name="${name%.md}"
    case " $KNOWN_REVIEWERS_LIST " in
      *" $name "*)
        distinct_list="$distinct_list $name"
        distinct_count=$((distinct_count + 1))
        ;;
      *)
        case " $SUBSTITUTION_HEURISTICS_LIST " in
          *" $name "*) substitutions_list="$substitutions_list $name" ;;
          *) unknown_list="$unknown_list $name" ;;
        esac
        ;;
    esac
  done < <(find -L -- "$d" -maxdepth 1 -type f -name '[!.]*.md' -print0 2>/dev/null)
  printf 'DISTINCT_COUNT=%d\n' "$distinct_count"
  printf 'DISTINCT_LIST=%s\n' "${distinct_list# }"
  printf 'SUBSTITUTIONS=%s\n' "${substitutions_list# }"
  printf 'UNKNOWN=%s\n' "${unknown_list# }"
}

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
# P6-A.2 fixture support (P1-5): LAYER2_AUDIT_REVIEW_ROOT env var lets test
# fixtures override the canonical reviews root without touching production paths.
# When unset, defaults to ".tad/evidence/reviews/blake".
review_root="${LAYER2_AUDIT_REVIEW_ROOT:-.tad/evidence/reviews/blake}"
dir="${review_root}/${slug}"
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
  # P6-A.2 (2026-04-25): Add distinct-reviewer-NAME detection on top of
  # existing min-bytes filter (CR-P1-6: layer ON TOP, not IN PLACE OF).
  # Produces structured machine-readable output for AC matching.
  reviewer_stats=$(detect_distinct_reviewers "$dir")
  printf '%s\n' "$reviewer_stats"
  distinct_count=$(printf '%s' "$reviewer_stats" | grep -E '^DISTINCT_COUNT=' | sed 's/^DISTINCT_COUNT=//')
  distinct_list=$(printf '%s' "$reviewer_stats" | grep -E '^DISTINCT_LIST=' | sed 's/^DISTINCT_LIST=//')
  substitutions_list=$(printf '%s' "$reviewer_stats" | grep -E '^SUBSTITUTIONS=' | sed 's/^SUBSTITUTIONS=//')
  unknown_list=$(printf '%s' "$reviewer_stats" | grep -E '^UNKNOWN=' | sed 's/^UNKNOWN=//')

  # Echo unknown names to stderr WARN (CR-P0-4: don't silently drop)
  if [ -n "$unknown_list" ]; then
    printf 'Layer 2 audit WARN: unknown reviewer name(s) — add to KNOWN_REVIEWERS in layer2-audit.sh if legitimate: %s\n' "$unknown_list" >&2
  fi

  # Verdict logic:
  #   ≥2 distinct      → PASS
  #   =1 distinct + express slug → PASS_EXPRESS (advisory PASS, exit 0)
  #   =1 distinct, non-express   → WARN (advisory, exit 0; structured WARN_REVIEWER_COUNT=1)
  #   =0 distinct + substitutions only → FAIL (existing path, structured WARN_REVIEWER_COUNT=0_SUBSTITUTIONS_ONLY)
  #   =0 distinct + 0 substitutions    → fall through to legacy total_found path
  if [ "${distinct_count:-0}" -ge 2 ]; then
    printf 'Layer 2 audit PASS: %d reviewer artifacts found (size-check); %d distinct reviewers found: %s\n' \
      "$qualified" "$distinct_count" "$distinct_list"
    exit 0
  elif [ "${distinct_count:-0}" -eq 1 ] && is_express_slug "$slug"; then
    printf 'Layer 2 audit PASS: 1 distinct reviewer (express path exception): %s\n' "$distinct_list"
    printf 'WARN_REVIEWER_COUNT=1_EXPRESS_OK\n'
    exit 0
  elif [ "${distinct_count:-0}" -eq 1 ]; then
    _err "Layer 2 audit WARN: 1 distinct reviewer (need ≥2 unless *express); found: ${distinct_list# }"
    printf 'WARN_REVIEWER_COUNT=1\n'
    exit 0  # advisory (per FR4: existing exit 0 preserved)
  elif [ -n "$substitutions_list" ]; then
    _err "Layer 2 audit FAIL: 0 distinct reviewers, only substitutions: ${substitutions_list# }"
    printf 'WARN_REVIEWER_COUNT=0_SUBSTITUTIONS_ONLY\n'
    exit 1
  fi
  # Distinct=0 AND substitutions=0 — preserve legacy artifacts-found message
  # (this happens when all .md files are unknown — already WARNed to stderr).
  printf 'Layer 2 audit PASS: %d reviewer artifacts found (size-check is smoke-alarm heuristic; no canonical reviewer names matched)\n' "$qualified"
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
