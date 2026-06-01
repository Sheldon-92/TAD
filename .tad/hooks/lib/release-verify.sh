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
#       grep the repo for any NON-historical stale <old> ref.
#
#       SCOPE (P1-1 fix — both reviewers' load-bearing condition):
#         - If <repo_root> is inside a git work tree, scope the search to GIT-TRACKED files
#           (`git -C <repo> ls-files`). This structurally excludes gitignored ephemeral trees
#           (`.claude/worktrees/agent-*/`, `.tad.backup.*/`, `codex-tad-bundle/`, node_modules)
#           that the raw FS-walk picked up (~88% noise on a real prior-version dry run). The
#           zero-touch dirs (read from `derive-sync-set.sh --zero-touch`) are then filtered
#           OUT of that tracked set by path-prefix (`.tad/<zero-touch>/`), since git tracks
#           them but they must never gate a release.
#         - If NOT a git repo, fall back to the FS-walk (`grep -rnF`) with --exclude-dir for
#           .git + the zero-touch basenames AND the known ephemeral/backup globs.
#
#       Version Exclusion Contract (location-precise; a hit is EXCLUDED only if it is provably
#       historical — fail toward FALSE-POSITIVE, never false-negative, so a live ref is never
#       silently shipped). A <old> hit line is excluded ONLY IF its file basename ∈
#       {README.md, INSTALLATION_GUIDE.md, CHANGELOG.md, NEXT.md, PROJECT_CONTEXT.md, HISTORY.md}
#       AND the line matches one of these HISTORICAL forms:
#         (a) VERSION-LABEL table row — the semver is the LEADING cell:
#               ^[[:space:]]*\|[[:space:]]*\*{0,2}v?[0-9]+\.[0-9]+\.[0-9]+\*{0,2}[[:space:]]*\|
#             This is a version-history row (`| **vX.Y.Z** | desc |`). It does NOT match a
#             live install snippet in a table whose first cell is a label
#             (`| Install | pip install tad==9.9.9 |`) — the semver there is in a LATER cell,
#             so that line is still CAUGHT (P1-2 false-negative closed).
#         (b) CHANGELOG SECTION heading: ^[[:space:]]*#{1,6}[[:space:]]*\[?v?[0-9]+\.[0-9]+\.[0-9]+
#         (c) HISTORICAL-STATUS prose marker (a line recording a PAST release event):
#               case-insensitive PUBLISHED|SYNCED|RELEASED|DONE|retired|archived|deprecated
#             — these words mark a recorded historical event, not a bumpable live ref.
#       Every other <old> hit is REPORTED. Residual over-report (FALSE-POSITIVE) is ACCEPTED:
#       e.g. a historical sub-bullet ("pushed main + tags vX.Y.Z (sha)") with no status
#       marker is still reported — the operator eyeballs it; we never widen the marker set to
#       the point of risking a live-ref miss.
#       Exit 0 = zero non-historical stale; exit 1 = ≥1 stale (each NAMED file:line);
#       exit 2 = usage. If <old> is omitted, version mode is a no-op success (exit 0).
#
#       P2 FORWARD NOTE (arch P1-3 — do NOT implement here): when tad.sh inlines a 2nd copy
#       of derive-sync-set.sh's DENY_LIST, P2 MUST add a release-time assertion that tad.sh's
#       inlined deny-list == derive-sync-set.sh's DENY_LIST, so the "no stale list" thesis is
#       not reintroduced at the installer layer.
#
# Gate rule (in both protocols) — exit 1 (DRIFT) and exit 2 (WIRING) are handled SEPARATELY
# (cr-P1-3 / arch-P1-2 fix). `TAD_RELEASE_GATE=warn` (shadow cutover) downgrades ONLY drift:
#   exit 0                                  → proceed.
#   exit 2 (usage/wiring/parse)             → ALWAYS HARD BLOCK. warn does NOT apply — a
#                                             wiring bug is not drift, and the shadow run is
#                                             precisely when the wiring is least battle-tested,
#                                             so it must surface, not be masked.
#   exit 1 (real drift) AND minor|major:
#       TAD_RELEASE_GATE=warn               → advisory WARN + proceed (shadow cutover only).
#       else                                → HARD BLOCK.
#   exit 1 (real drift) AND patch           → advisory WARN + proceed (regardless of env).
# Fail-CLOSED on exit 2. The gate echoes `GATE: release-verify <mode> exit=<n>` on every
# non-zero so a wiring bug (exit 2) is distinguishable from a true drift (exit 1) — and the
# warn branch in the SKILL gate steps MUST key off that exit code, never the combined `1 or 2`.
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

    # Collect the zero-touch basenames once (READ from --zero-touch; single source of truth).
    ZT_DIRS=()
    while IFS= read -r zt; do
      [ -n "$zt" ] || continue
      ZT_DIRS+=("$zt")
    done < <(bash "$DERIVE" --zero-touch "$REPO")

    # Build a path-prefix filter regex for zero-touch dirs: (^|/)\.tad/(active|archive|...)/
    ZT_RE=""
    if [ "${#ZT_DIRS[@]}" -gt 0 ]; then
      ZT_ALT="$(IFS='|'; printf '%s' "${ZT_DIRS[*]}")"
      ZT_RE="(^|/)\.tad/($ZT_ALT)/"
    fi

    # ── SCOPE (P1-1 fix) ──────────────────────────────────────────────────────────────
    # Prefer GIT-TRACKED files when in a git work tree — structurally drops gitignored
    # ephemeral trees (.claude/worktrees/agent-*, .tad.backup.*, codex-tad-bundle, node_modules)
    # that the raw FS-walk pulled in (~88% noise). Then filter zero-touch dirs out by prefix.
    hits=""
    if git -C "$REPO" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      # NUL-delimited tracked file list → grep each. -I skips binary. -F literal version.
      tracked_hits="$(git -C "$REPO" ls-files -z 2>/dev/null \
        | (cd "$REPO" && LC_ALL=C xargs -0 grep -InF "$OLD" 2>/dev/null))" || true
      if [ -n "$ZT_RE" ]; then
        hits="$(printf '%s\n' "$tracked_hits" | LC_ALL=C grep -vE "$ZT_RE")" || true
      else
        hits="$tracked_hits"
      fi
    else
      # Non-git fallback: FS-walk minus .git, zero-touch basenames, AND ephemeral/backup trees.
      EXCLUDES=(--exclude-dir=.git --exclude-dir='.tad.backup.*' --exclude-dir=worktrees \
                --exclude-dir=codex-tad-bundle --exclude-dir=node_modules)
      for zt in "${ZT_DIRS[@]}"; do
        EXCLUDES+=(--exclude-dir="$zt")
      done
      hits="$(LC_ALL=C grep -rInF "$OLD" "$REPO" "${EXCLUDES[@]}" 2>/dev/null)" || true
    fi

    # Apply the Version Exclusion Contract line-by-line (fail-CLOSED: any non-excludable hit is
    # reported; we EXCLUDE only provably-historical lines, biased to FALSE-POSITIVE — see header).
    # A hit = file:line:content . Exclude ONLY IF basename ∈ allow-list AND line is a historical form.
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
          README.md|INSTALLATION_GUIDE.md|CHANGELOG.md|NEXT.md|PROJECT_CONTEXT.md|HISTORY.md)
            # (a) VERSION-LABEL table row — semver is the LEADING cell (a version-history row).
            #     A live install snippet (`| Install | pip install tad==X |`) has a NON-semver
            #     first cell → NOT matched here → still CAUGHT (P1-2 false-negative closed).
            if printf '%s' "$content" | LC_ALL=C grep -qE '^[[:space:]]*\|[[:space:]]*\*{0,2}v?[0-9]+\.[0-9]+\.[0-9]+\*{0,2}[[:space:]]*\|'; then
              excluded=1
            # (b) CHANGELOG SECTION heading: `## [X.Y.Z] - ...`.
            elif printf '%s' "$content" | LC_ALL=C grep -qE '^[[:space:]]*#{1,6}[[:space:]]*\[?v?[0-9]+\.[0-9]+\.[0-9]+'; then
              excluded=1
            # (c) HISTORICAL-STATUS prose marker — a line recording a PAST release event.
            elif printf '%s' "$content" | LC_ALL=C grep -qiE '(PUBLISHED|SYNCED|RELEASED|DONE|retired|archived|deprecated)'; then
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
