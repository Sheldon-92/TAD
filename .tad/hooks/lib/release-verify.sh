#!/usr/bin/env bash
# release-verify.sh — STABLE (written-in-stone) release verification primitives.
# Structure-AGNOSTIC: derives its path set from derive-sync-set.sh, never hardcodes a list.
#
# ============================ CONTRACT (consumed exit-code API) ============================
# The gate steps in alex/SKILL.md (publish_protocol + sync_protocol) READ these exit codes.
# A change to the exit-code meaning is a BREAKING change (per the .router.log 5-tuple lesson).
#
#   structural <src_root> <target_root>
#       For each dir from `derive-sync-set.sh --dirs <src_root>`:
#         - if the dir == the basename named by `derive-sync-set.sh --registry-only`
#           (i.e. capability-packs), diff ONLY that command's sub-path
#           (capability-packs/pack-registry.yaml) — NOT the dir tree;
#         - else diff -rq the whole dir source-vs-target.
#       Also diff -rq .claude/skills (the verbatim-synced skills path).
#       The registry-only special-case is READ from --registry-only, NEVER hardcoded here.
#       Exit 0 = every derived path byte-identical source-vs-target; exit 1 = ≥1 missing/
#       differing path (each NAMED); exit 2 = usage.
#       BYTE-IDENTITY: this gate runs AFTER the verbatim `cp -R` sync (sync-side post-copy),
#       so source==target byte-identity is the correct equality test. install.sh/tad.sh
#       edition transforms (AGENTS.md generation, frontmatter rewrites) are a P2 concern —
#       this gate diffs a VERBATIM-synced target, not an install-transformed one.
#
#   version <repo_root> <expected_version> [<old_version>]
#       grep the repo (minus .git minus the zero-touch dirs read from
#       `derive-sync-set.sh --zero-touch`) for any NON-historical stale <old> ref.
#       Version Exclusion Contract (location-precise): a <old> hit line is excluded ONLY IF
#       it is BOTH (a) in a file whose basename ∈ {README.md, INSTALLATION_GUIDE.md,
#       CHANGELOG.md} AND (b) the line matches the history-table-ROW regex
#       ^[[:space:]]*\|.*v?[0-9]+\.[0-9]+\.[0-9]+.*\|  . Every other <old> hit is REPORTED.
#       Exit 0 = zero non-historical stale; exit 1 = ≥1 stale (each NAMED file:line);
#       exit 2 = usage. If <old> is omitted, version mode is a no-op success (exit 0).
#
# Gate rule (in both protocols): exit 0 → proceed; exit 1 or 2 AND release_type ∈ {minor,
# major} → HARD BLOCK; exit 1 or 2 AND release_type == patch → advisory WARN + proceed.
# Fail-CLOSED: exit 2 (usage/parse) is treated as FAIL at the gate. The gate echoes
# `GATE: release-verify <mode> exit=<n>` on every non-zero so a wiring bug (exit 2) is
# distinguishable from a true drift (exit 1).
# ==========================================================================================
#
# BSD/macOS safe: no grep -P. LC_ALL=C on sort/comm. Quote all path expansions
# (repo path contains a space). Mirrors codex-parity-check.sh conventions.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DERIVE="$SCRIPT_DIR/derive-sync-set.sh"

usage() {
  echo "Usage:" >&2
  echo "  release-verify.sh structural <src_root> <target_root>" >&2
  echo "  release-verify.sh version <repo_root> <expected_version> [<old_version>]" >&2
}

if [ ! -f "$DERIVE" ]; then
  echo "ERROR: derive-sync-set.sh not found at $DERIVE (cannot derive paths)" >&2
  exit 2
fi

MODE="${1:-}"

case "$MODE" in
  # ───────────────────────────── structural ─────────────────────────────
  structural)
    if [ $# -ne 3 ]; then usage; exit 2; fi
    SRC="$2"
    TGT="$3"
    if [ ! -d "$SRC/.tad" ]; then echo "ERROR: no .tad/ under src: $SRC" >&2; exit 2; fi
    if [ ! -d "$TGT/.tad" ]; then echo "ERROR: no .tad/ under target: $TGT" >&2; exit 2; fi

    echo "========================================="
    echo "STRUCTURAL VERIFY (diff -rq over derived paths)"
    echo "  SRC:    $SRC"
    echo "  TARGET: $TGT"
    echo "========================================="

    # READ the registry-only sub-rule (single source of truth — do NOT hardcode the basename).
    REG_PATH="$(bash "$DERIVE" --registry-only "$SRC")"      # e.g. capability-packs/pack-registry.yaml
    REG_DIR="${REG_PATH%%/*}"                                 # e.g. capability-packs

    fails=0
    # Derive the SYNC dir set from the SOLE source of truth.
    while IFS= read -r d; do
      [ -n "$d" ] || continue
      if [ "$d" = "$REG_DIR" ]; then
        # registry-only sub-path rule: diff ONLY the registry index file, never the dir tree.
        src_f="$SRC/.tad/$REG_PATH"
        tgt_f="$TGT/.tad/$REG_PATH"
        out="$(diff -rq "$src_f" "$tgt_f" 2>&1)" || true
        if [ -z "$out" ]; then
          echo "  ✅ .tad/$REG_PATH identical"
        else
          echo "  ❌ .tad/$REG_PATH DIFF:"
          printf '%s\n' "$out" | sed 's/^/      /' | head -4
          fails=$((fails + 1))
        fi
        continue
      fi
      out="$(diff -rq "$SRC/.tad/$d" "$TGT/.tad/$d" 2>&1)" || true
      if [ -z "$out" ]; then
        echo "  ✅ .tad/$d identical"
      else
        echo "  ❌ .tad/$d DIFF:"
        printf '%s\n' "$out" | sed 's/^/      /' | head -4
        fails=$((fails + 1))
      fi
    done < <(bash "$DERIVE" --dirs "$SRC")

    # .claude/skills — verbatim-synced framework skills path.
    sout="$(diff -rq "$SRC/.claude/skills" "$TGT/.claude/skills" 2>&1)" || true
    if [ -z "$sout" ]; then
      echo "  ✅ .claude/skills identical"
    else
      echo "  ❌ .claude/skills DIFF:"
      printf '%s\n' "$sout" | sed 's/^/      /' | head -4
      fails=$((fails + 1))
    fi

    echo "-----------------------------------------"
    if [ "$fails" -eq 0 ]; then
      echo "VERDICT: structural PASS (exit 0)"
      exit 0
    else
      echo "VERDICT: structural FAIL — $fails differing/missing path(s) (exit 1)"
      exit 1
    fi
    ;;

  # ───────────────────────────── version ─────────────────────────────
  version)
    if [ $# -lt 3 ] || [ $# -gt 4 ]; then usage; exit 2; fi
    REPO="$2"
    NEW="$3"
    OLD="${4:-}"
    if [ ! -d "$REPO" ]; then echo "ERROR: repo_root not a dir: $REPO" >&2; exit 2; fi

    echo "========================================="
    echo "VERSION VERIFY (grep zero non-historical stale)"
    echo "  REPO:     $REPO"
    echo "  EXPECTED: $NEW"
    echo "  OLD:      ${OLD:-<none — no-op>}"
    echo "========================================="

    if [ -z "$OLD" ]; then
      echo "  (no <old_version> given — nothing to detect; PASS)"
      echo "VERDICT: version PASS (exit 0)"
      exit 0
    fi

    # Build the grep scope: repo minus .git minus the zero-touch dirs (READ from --zero-touch).
    # --exclude-dir takes basenames; .git + each category-A dir name.
    EXCLUDES=(--exclude-dir=.git)
    while IFS= read -r zt; do
      [ -n "$zt" ] || continue
      EXCLUDES+=(--exclude-dir="$zt")
    done < <(bash "$DERIVE" --zero-touch "$REPO")

    # grep -rn for the literal OLD ref. -F = fixed string (a version is not a regex).
    # || true: zero matches is success, not an error under set -e.
    hits="$(LC_ALL=C grep -rnF "$OLD" "$REPO" "${EXCLUDES[@]}" 2>/dev/null)" || true

    # Apply the Version Exclusion Contract line-by-line (fail-CLOSED: any non-excludable hit is reported).
    # A hit = file:line:content . Exclude ONLY IF basename ∈ allow-list AND content matches history-row regex.
    survivors=0
    survivor_list=""
    if [ -n "$hits" ]; then
      while IFS= read -r hit; do
        [ -n "$hit" ] || continue
        file="${hit%%:*}"
        rest="${hit#*:}"            # line:content
        content="${rest#*:}"        # content (everything after line number)
        base="$(basename "$file")"
        excluded=0
        case "$base" in
          README.md|INSTALLATION_GUIDE.md|CHANGELOG.md)
            # history-table-ROW: leading optional-space |, a semver token, a closing |.
            if printf '%s' "$content" | LC_ALL=C grep -qE '^[[:space:]]*\|.*v?[0-9]+\.[0-9]+\.[0-9]+.*\|'; then
              excluded=1
            fi
            ;;
        esac
        if [ "$excluded" -eq 0 ]; then
          survivors=$((survivors + 1))
          survivor_list="${survivor_list}  ❌ STALE: ${hit}"$'\n'
        fi
      done <<EOF
$hits
EOF
    fi

    if [ "$survivors" -eq 0 ]; then
      echo "  ✅ zero non-historical stale '$OLD' refs"
      echo "VERDICT: version PASS (exit 0)"
      exit 0
    else
      printf '%s' "$survivor_list"
      echo "VERDICT: version FAIL — $survivors stale ref(s) (exit 1)"
      exit 1
    fi
    ;;

  *)
    usage
    exit 2
    ;;
esac
