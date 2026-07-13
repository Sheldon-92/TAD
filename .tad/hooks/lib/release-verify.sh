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
#   version-sweep <repo_root> <expected_version>
#       Dual-layer full-repo version drift detection.
#       Layer 1 (Must-Version Registry): positive-assert that ~12 identity-marker files
#         contain the expected version. ALWAYS blocking.
#       Layer 2 (Narrow Drift Sweep): grep for 2.X.Y patterns ≠ expected, excluding
#         known historical paths (archive/, evidence/, migrations/, skills/*/references/,
#         _archived/, .tad/active/ideas/, CHANGELOG table rows, metadata annotations,
#         IP addresses). ADVISORY only — never affects exit code.
#       Exit 0 = Layer 1 all PASS; exit 1 = ≥1 Layer 1 pattern missing; exit 2 = usage.
#
#   migration <repo_root> [<expected_version>]
#       Detect D (deleted) and R (renamed) files between the previous git tag and HEAD,
#       scoped to framework-managed paths (.tad/, .claude/, .codex/, .agents/, root files).
#       Cross-reference against manifest in .tad/migrations/{prev_ver}-to-{exp_ver}.yaml.
#       ZERO_TOUCH directories (from derive-sync-set.sh --zero-touch) are excluded.
#       Secondary rename detection: for each D without manifest coverage, flag if any A
#       entry shares the same basename (POSSIBLE RENAME — prefer false-positive).
#       Manifest cross-reference uses grep -F (smoke alarm, not YAML parser — see 4.2.1).
#       Exit 0 = all D/R covered (or no D/R entries); exit 1 = unmanifested removals;
#       exit 2 = usage/wiring error. The script always exits honestly — the caller
#       (publish-protocol step3d) handles warn/block downgrade via TAD_RELEASE_GATE.
#
#   parity [--fix] <repo_root>
#       Claude↔Codex dual-platform skills parity: diff -rq <repo>/.claude/skills vs
#       <repo>/.agents/skills (the Codex mirror). The invariant is FULL BYTE-PARITY with
#       .claude/skills as the SOLE source of truth (direction FIXED Claude→Codex per f428d70 AC1).
#       On exit 1 (drift), computes and prints DIRECTION:
#         claude-newer  = safe to mirror (.claude was edited, .agents is stale)
#         agents-newer (STOP) = someone edited the mirror directly — DO NOT auto-fix
#       Direction heuristic (biased to STOP): a differing/orphan .agents path that is
#       working-tree-modified, untracked, or whose last commit touches ONLY the .agents side
#       → agents-newer. When the heuristic cannot decide → agents-newer (false-positive preferred).
#       --fix: if claude-newer → rsync -a --delete Claude→Codex, re-verify to exit 0.
#              if agents-newer → REFUSE (exit 1, names offending paths, changes nothing).
#       Exit 0 = byte-identical; exit 1 = drift (each path NAMED, DIRECTION printed);
#       exit 2 = usage / missing dir.
#       NO PATCH-RELEASE DOWNGRADE: parity drift is fixed unconditionally regardless of
#       release_type — a stale mirror is never acceptable to ship. This is asymmetric vs
#       step3c/step3d which allow warn-mode on patch releases.
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
  echo "  release-verify.sh version-sweep <repo_root> <expected_version>" >&2
  echo "  release-verify.sh freshness <repo_root> [<today_yyyy_mm_dd>]" >&2
  echo "  release-verify.sh migration <repo_root> [<expected_version>]" >&2
  echo "  release-verify.sh parity [--fix] <repo_root>" >&2
  echo "  release-verify.sh platform-skills <source_root> <target_root>" >&2
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
    # FR7 (2026-06-10): "Only in target" extras are local-skill INFO, not fail.
    # The structural gate catches INCOMPLETE copies (omissions); target-side extras
    # are the T1 local-skill model working as designed.
    # Phase 1 (2026-06-17): filter out .tad-pack-meta.yaml from diff output —
    # these are generated at install time in the target and expected to differ.
    sout="$(diff -rq "$SRC/.claude/skills" "$TGT/.claude/skills" 2>&1 | grep -v '\.tad-pack-meta\.yaml')" || true
    if [ -z "$sout" ]; then
      echo "  ✅ .claude/skills identical"
    else
      local_skills="$(printf '%s\n' "$sout" | grep "^Only in $TGT" || true)"
      real_diffs="$(printf '%s\n' "$sout" | grep -v "^Only in $TGT" || true)"
      if [ -n "$local_skills" ]; then
        printf '%s\n' "$local_skills" | while IFS= read -r line; do
          echo "  ℹ️  local-skill: $line"
        done
      fi
      if [ -z "$real_diffs" ]; then
        echo "  ✅ .claude/skills identical (local-skill extras ignored)"
      else
        echo "  ❌ .claude/skills DIFF:"
        printf '%s\n' "$real_diffs" | sed 's/^/      /' | head -4
        fails=$((fails + 1))
      fi
    fi

    # .claude/workflows — dynamic workflow scripts (EPIC-20260603).
    if [ -d "$SRC/.claude/workflows" ]; then
      wout="$(diff -rq "$SRC/.claude/workflows" "$TGT/.claude/workflows" 2>&1)" || true
      if [ -z "$wout" ]; then
        echo "  ✅ .claude/workflows identical"
      else
        echo "  ❌ .claude/workflows DIFF:"
        printf '%s\n' "$wout" | sed 's/^/      /' | head -4
        fails=$((fails + 1))
      fi
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

  # ───────────────────────────── freshness ─────────────────────────────
  freshness)
    if [ $# -lt 2 ]; then usage; exit 2; fi
    FRESH_REPO="$2"
    FRESH_TODAY="${3:-}"
    bash "$SCRIPT_DIR/runtime-freshness-verify.sh" "$FRESH_REPO" $FRESH_TODAY
    ;;

  # ───────────────────────────── migration ─────────────────────────────
  migration)
    if [ $# -lt 2 ]; then usage; exit 2; fi
    REPO="$2"
    EXP_VER="${3:-}"
    if [ ! -d "$REPO" ]; then echo "ERROR: repo_root not a dir: $REPO" >&2; exit 2; fi
    if [ ! -d "$REPO/.tad" ]; then echo "ERROR: no .tad/ under repo: $REPO" >&2; exit 2; fi

    echo "========================================="
    echo "MIGRATION VERIFY (unmanifested D/R check)"
    echo "  REPO: $REPO"

    # Detect previous tag
    PREV_TAG=""
    PREV_TAG="$(git -C "$REPO" describe --tags --abbrev=0 HEAD^ 2>/dev/null)" || true
    if [ -z "$PREV_TAG" ]; then
      echo "  (no previous tag found — nothing to check; PASS)"
      echo "VERDICT: migration PASS (exit 0)"
      exit 0
    fi
    echo "  PREV_TAG: $PREV_TAG"

    # Extract prev version (strip leading 'v', normalize to 3-segment)
    PREV_VER="${PREV_TAG#v}"
    case "$PREV_VER" in
      *.*.*) ;; # already 3 segments
      *.*) PREV_VER="${PREV_VER}.0" ;;
    esac

    # Read expected version from arg or version.txt
    if [ -z "$EXP_VER" ]; then
      if [ -f "$REPO/.tad/version.txt" ]; then
        EXP_VER="$(head -1 "$REPO/.tad/version.txt" | tr -d '[:space:]')"
      fi
    fi
    if [ -z "$EXP_VER" ]; then
      echo "ERROR: cannot determine expected version (no arg and no .tad/version.txt)" >&2
      exit 2
    fi
    # Normalize to 3-segment
    case "$EXP_VER" in
      *.*.*) ;; # already 3 segments
      *.*) EXP_VER="${EXP_VER}.0" ;;
    esac
    echo "  EXPECTED: $EXP_VER"
    echo "========================================="

    # Manifest path
    MANIFEST="$REPO/.tad/migrations/${PREV_VER}-to-${EXP_VER}.yaml"

    # Collect ZERO_TOUCH dirs (reuse pattern from version mode)
    ZT_DIRS=()
    while IFS= read -r zt; do
      [ -n "$zt" ] || continue
      ZT_DIRS+=("$zt")
    done < <(bash "$DERIVE" --zero-touch "$REPO")

    # Build ZERO_TOUCH filter regex
    ZT_RE=""
    if [ "${#ZT_DIRS[@]}" -gt 0 ]; then
      ZT_ALT="$(IFS='|'; printf '%s' "${ZT_DIRS[*]}")"
      ZT_RE="^\.tad/($ZT_ALT)/"
    fi

    # Compute framework-scoped diff (D, R, A entries)
    DIFF_OUTPUT="$(git -C "$REPO" diff --name-status -M "$PREV_TAG"..HEAD -- .tad/ .claude/ .codex/ .agents/ CLAUDE.md AGENTS.md tad.sh 2>/dev/null)" || true

    # Classify entries, filtering ZERO_TOUCH
    DELETES=""
    RENAMES=""
    ADDED=""
    while IFS= read -r line; do
      [ -n "$line" ] || continue
      status="$(printf '%s' "$line" | cut -f1)"
      case "$status" in
        D)
          path="$(printf '%s' "$line" | cut -f2)"
          if [ -n "$ZT_RE" ] && printf '%s\n' "$path" | LC_ALL=C grep -qE "$ZT_RE"; then continue; fi
          DELETES="${DELETES}${path}"$'\n'
          ;;
        R*)
          from_path="$(printf '%s' "$line" | cut -f2)"
          to_path="$(printf '%s' "$line" | cut -f3)"
          if [ -n "$ZT_RE" ]; then
            if printf '%s\n' "$from_path" | LC_ALL=C grep -qE "$ZT_RE"; then continue; fi
            if printf '%s\n' "$to_path" | LC_ALL=C grep -qE "$ZT_RE"; then continue; fi
          fi
          RENAMES="${RENAMES}${from_path}	${to_path}"$'\n'
          ;;
        A)
          path="$(printf '%s' "$line" | cut -f2)"
          if [ -n "$ZT_RE" ] && printf '%s\n' "$path" | LC_ALL=C grep -qE "$ZT_RE"; then continue; fi
          ADDED="${ADDED}${path}"$'\n'
          ;;
      esac
    done <<MIG_DIFF_EOF
$DIFF_OUTPUT
MIG_DIFF_EOF

    # If no D/R entries, nothing to check
    if [ -z "$DELETES" ] && [ -z "$RENAMES" ]; then
      echo "  No D/R entries in framework-scoped diff — nothing to check."
      echo "VERDICT: migration PASS (exit 0)"
      exit 0
    fi

    # Cross-reference against manifest
    findings=0
    findings_list=""

    # Check each D entry
    while IFS= read -r d_path; do
      [ -n "$d_path" ] || continue
      covered=0
      if [ -f "$MANIFEST" ] && grep -qF "$d_path" "$MANIFEST" 2>/dev/null; then
        covered=1
      fi
      if [ "$covered" -eq 0 ]; then
        # Secondary rename detection: check if any A entry shares basename (prefer false-positive)
        is_possible_rename=0
        if [ -n "$ADDED" ]; then
          d_base="$(basename "$d_path")"
          # Build basenames of added files and grep for match (avoids pipe|while subshell bug)
          if printf '%s\n' "$ADDED" | while IFS= read -r a_path; do
            [ -n "$a_path" ] || continue; basename "$a_path"
          done | grep -qxF "$d_base"; then
            is_possible_rename=1
          fi
        fi

        if [ "$is_possible_rename" -eq 1 ]; then
          findings=$((findings + 1))
          findings_list="${findings_list}  POSSIBLE RENAME: ${d_path} (basename match in added files) [checked: ${MANIFEST}]"$'\n'
        else
          findings=$((findings + 1))
          findings_list="${findings_list}  UNMANIFESTED DELETE: ${d_path} [checked: ${MANIFEST}]"$'\n'
        fi
      fi
    done <<MIG_DEL_EOF
$DELETES
MIG_DEL_EOF

    # Check each R entry
    while IFS= read -r r_line; do
      [ -n "$r_line" ] || continue
      r_from="$(printf '%s' "$r_line" | cut -f1)"
      covered=0
      if [ -f "$MANIFEST" ] && grep -qF "$r_from" "$MANIFEST" 2>/dev/null; then
        covered=1
      fi
      if [ "$covered" -eq 0 ]; then
        findings=$((findings + 1))
        findings_list="${findings_list}  UNMANIFESTED RENAME: ${r_from} [checked: ${MANIFEST}]"$'\n'
      fi
    done <<MIG_REN_EOF
$RENAMES
MIG_REN_EOF

    if [ "$findings" -eq 0 ]; then
      echo "  All D/R entries covered by manifest."
      echo "VERDICT: migration PASS (exit 0)"
      exit 0
    else
      printf '%s' "$findings_list"
      echo "VERDICT: migration FAIL — $findings unmanifested removal(s) (exit 1)"
      exit 1
    fi
    ;;

  # ───────────────────────────── parity ─────────────────────────────
  parity)
    FIX_MODE=false
    if [ "${2:-}" = "--fix" ]; then FIX_MODE=true; shift; fi
    if [ $# -ne 2 ]; then usage; exit 2; fi
    REPO="$(cd "$2" && pwd -P)" || { echo "ERROR: cannot resolve repo path: $2" >&2; exit 2; }
    CLAUDE_SKILLS="$REPO/.claude/skills"
    AGENTS_SKILLS="$REPO/.agents/skills"
    if [ ! -d "$CLAUDE_SKILLS" ]; then echo "ERROR: no .claude/skills under repo: $REPO" >&2; exit 2; fi
    if [ ! -d "$AGENTS_SKILLS" ]; then echo "ERROR: no .agents/skills under repo: $REPO (Codex mirror missing)" >&2; exit 2; fi

    echo "========================================="
    echo "PARITY VERIFY (.claude/skills <-> .agents/skills byte-identity)"
    echo "  REPO: $REPO"
    if $FIX_MODE; then echo "  MODE: --fix (will attempt auto-fix if claude-newer)"; fi
    echo "========================================="

    # local/ = machine-local skills (save-skill), gitignored, never mirrored — DR: NEXT.md parity-tool bugfix item
    pout="$(diff -rq -x local "$CLAUDE_SKILLS" "$AGENTS_SKILLS" 2>&1)" || true
    if [ -z "$pout" ]; then
      echo "  ✅ .claude/skills <-> .agents/skills byte-identical"
      echo "VERDICT: parity PASS (exit 0)"
      exit 0
    fi

    printf '%s\n' "$pout" | sed 's/^/  ❌ /'

    # DIRECTION heuristic — DEFAULT STOP, promote to claude-newer only when proven safe.
    # FR2: "When the heuristic cannot decide → agents-newer (STOP) (false-positive preferred)."
    # Non-git repo, parse failure, ambiguous commit history → all stay at default STOP.
    DIRECTION="agents-newer (STOP)"
    is_git=false
    if cd "$REPO" && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then is_git=true; fi

    if $is_git; then
      # Try to PROVE claude-newer: every differing path must pass ALL checks.
      # Any single path that fails → stays at default STOP (break immediately).
      all_claude_newer=true
      while IFS= read -r line; do
        apath=""
        case "$line" in
          "Only in $AGENTS_SKILLS"*)
            # Orphan on .agents side → agents-newer
            all_claude_newer=false
            echo "  ⚠️  orphan on .agents side: ${line#Only in }"
            break
            ;;
          "Only in $CLAUDE_SKILLS"*)
            # Orphan on .claude side → this path is claude-newer, continue checking others
            continue
            ;;
          "Files "*"differ")
            apath="$(printf '%s\n' "$line" | sed -n "s|.*and \($AGENTS_SKILLS[^ ]*\) differ|\1|p")"
            ;; # [^ ]* assumes no spaces in skill filenames (convention-enforced)
        esac
        if [ -z "$apath" ]; then all_claude_newer=false; echo "  ⚠️  unparseable diff line — cannot prove direction"; break; fi

        relpath="${apath#$REPO/}"

        # Check 1: .agents path has uncommitted changes → agents-newer
        gstatus="$(cd "$REPO" && git status --porcelain -- "$relpath" 2>/dev/null)" || true
        if [ -n "$gstatus" ]; then
          # Also check .claude counterpart — if .claude has uncommitted changes
          # but .agents does NOT, that's claude-newer
          cpath="${apath/$AGENTS_SKILLS/$CLAUDE_SKILLS}"
          crelpath="${cpath#$REPO/}"
          cstatus="$(cd "$REPO" && git status --porcelain -- "$crelpath" 2>/dev/null)" || true
          if [ -n "$cstatus" ] && [ -z "$gstatus" ]; then
            continue  # .claude dirty, .agents clean → this path is claude-newer
          fi
          if [ -n "$gstatus" ] && [ -z "$cstatus" ]; then
            all_claude_newer=false
            echo "  ⚠️  $relpath has uncommitted changes on .agents side"
            break
          fi
          # Both dirty or unable to determine → STOP
          all_claude_newer=false
          echo "  ⚠️  $relpath: both sides have uncommitted changes — cannot determine direction"
          break
        fi

        # Check 2: .claude counterpart has uncommitted changes → claude-newer (positive proof)
        cpath="${apath/$AGENTS_SKILLS/$CLAUDE_SKILLS}"
        crelpath="${cpath#$REPO/}"
        cstatus="$(cd "$REPO" && git status --porcelain -- "$crelpath" 2>/dev/null)" || true
        if [ -n "$cstatus" ]; then
          continue  # .claude is dirty, .agents is clean → this path is claude-newer
        fi

        # Check 3: last commit analysis — only promote if .agents commit == .claude commit
        # (same mirror commit) or .claude commit is strictly newer
        alast="$(cd "$REPO" && git log -1 --format=%H -- "$relpath" 2>/dev/null)" || true
        clast="$(cd "$REPO" && git log -1 --format=%H -- "$crelpath" 2>/dev/null)" || true
        if [ -z "$alast" ] || [ -z "$clast" ]; then
          all_claude_newer=false
          echo "  ⚠️  $relpath: no git history for one side — cannot determine direction"
          break
        fi
        if [ "$alast" = "$clast" ]; then
          continue  # same last commit → likely imperfect sync, .claude is SOT
        fi
        # Different commits — check if .agents commit touches only .agents (independent edit)
        afiles="$(cd "$REPO" && git diff-tree --no-commit-id --name-only -r "$alast" 2>/dev/null)" || true
        if printf '%s\n' "$afiles" | grep -q -- "^\.agents/" && ! printf '%s\n' "$afiles" | grep -q -- "^\.claude/"; then
          all_claude_newer=false
          echo "  ⚠️  $relpath last commit ($alast) touches only .agents side"
          break
        fi
        # .agents commit also touches .claude → likely a bulk sync, treat as claude-newer
      done <<PARITY_EOF
$pout
PARITY_EOF

      if $all_claude_newer; then
        DIRECTION="claude-newer"
      fi
    else
      echo "  ⚠️  not a git repository — cannot determine direction (default: STOP)"
    fi

    echo "DIRECTION: $DIRECTION"

    if $FIX_MODE; then
      if [ "$DIRECTION" = "claude-newer" ]; then
        echo "  🔧 Auto-fixing: rsync Claude→Codex..."
        # local/ = machine-local skills (save-skill), gitignored, never mirrored — DR: NEXT.md parity-tool bugfix item
        rsync -a --delete --exclude=/local/ "$CLAUDE_SKILLS/" "$AGENTS_SKILLS/"
        # Re-verify
        reverify="$(diff -rq -x local "$CLAUDE_SKILLS" "$AGENTS_SKILLS" 2>&1)" || true
        if [ -z "$reverify" ]; then
          echo "  ✅ Fix successful — .agents/skills now matches .claude/skills"
          echo "VERDICT: parity FIX-PASS (exit 0)"
          exit 0
        else
          echo "  ❌ Fix FAILED — still divergent after rsync" >&2
          printf '%s\n' "$reverify" | sed 's/^/  /'
          echo "VERDICT: parity FIX-FAIL (exit 1)"
          exit 1
        fi
      else
        echo "  🛑 REFUSED: direction is $DIRECTION — cannot auto-fix."
        echo "  Someone edited .agents/skills directly. Investigate before mirroring."
        echo "VERDICT: parity FIX-REFUSED (exit 1)"
        exit 1
      fi
    fi

    echo "VERDICT: parity FAIL — Codex mirror drift (exit 1)"
    echo "  FIX: run 'release-verify.sh parity --fix \"$REPO\"' if direction is claude-newer"
    exit 1
    ;;

  # ───────────────────────── version-sweep ─────────────────────────
  # Full-repo version drift detection. Dual-layer:
  #   Layer 1 (Must-Version Registry): positive-assert that specific files contain the
  #     expected version string. ALWAYS blocking. Exit 1 = stale identity marker.
  #   Layer 2 (Narrow Drift Sweep): grep for 2.X.Y patterns not equal to expected,
  #     excluding known historical paths. ADVISORY only — never affects exit code.
  # Exit 0 = Layer 1 all PASS (regardless of Layer 2 hits).
  # Exit 1 = ≥1 Layer 1 pattern missing.
  # Exit 2 = usage/wiring error.
  version-sweep)
    if [ $# -ne 3 ]; then
      echo "Usage: release-verify.sh version-sweep <repo_root> <expected_version>" >&2
      exit 2
    fi
    REPO="$2"
    VER="$3"
    if [ ! -d "$REPO" ]; then echo "ERROR: repo_root not a dir: $REPO" >&2; exit 2; fi
    if ! printf '%s' "$VER" | LC_ALL=C grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
      echo "ERROR: expected_version must be semver (got: '$VER')" >&2
      exit 2
    fi
    # Escape dots for ERE patterns (P0 fix: 2.33.0 → 2\.33\.0)
    VER_RE="${VER//./\\.}"

    echo "========================================="
    echo "VERSION-SWEEP (dual-layer version drift detection)"
    echo "  REPO:     $REPO"
    echo "  EXPECTED: $VER"
    echo "========================================="

    # ── Layer 1: Must-Version Registry ──────────────────────────────────────────
    echo ""
    echo "  ── Layer 1: Must-Version Registry ──"

    MUST_VERSION_PATTERNS=(
      ".tad/version.txt|^${VER_RE}$"
      ".tad/config.yaml|version: ${VER_RE}"
      ".tad/config.yaml|# TAD Configuration v${VER_RE}"
      "README.md|Version ${VER_RE}"
      "INSTALLATION_GUIDE.md|Version ${VER_RE}"
      ".claude/skills/tad-help/SKILL.md|Version: v${VER_RE}"
      ".claude/skills/alex/SKILL.md|<!-- TAD v${VER_RE} Framework -->"
      ".claude/skills/blake/SKILL.md|<!-- TAD v${VER_RE} Framework -->"
      "tad.sh|TARGET_VERSION=\"${VER_RE}\""
      "package.json|\"version\": \"${VER_RE}\""
      "PROJECT_CONTEXT.md|Version.*: ${VER_RE}"
      "docs/MULTI-PLATFORM.md|Version.*: ${VER_RE}"
    )

    l1_fails=0
    l1_pass=0
    l1_warn=0
    for entry in "${MUST_VERSION_PATTERNS[@]}"; do
      file="${entry%%|*}"
      pattern="${entry#*|}"
      filepath="$REPO/$file"
      if [ ! -f "$filepath" ]; then
        printf '  ⚠️  %-45s FILE MISSING\n' "$file"
        l1_warn=$((l1_warn + 1))
      elif grep -qE "$pattern" "$filepath" 2>/dev/null; then
        printf '  ✅ %-45s %s\n' "$file" "$VER"
        l1_pass=$((l1_pass + 1))
      else
        printf '  ❌ %-45s MISSING "%s"  [BLOCKING]\n' "$file" "$pattern"
        l1_fails=$((l1_fails + 1))
      fi
    done

    if [ "$l1_fails" -eq 0 ]; then
      echo "  Layer 1 verdict: PASS ($l1_pass verified, $l1_warn warnings)"
    else
      echo "  Layer 1 verdict: FAIL ($l1_fails stale, $l1_pass passed, $l1_warn warnings)"
    fi

    # ── Layer 2: Narrow Drift Sweep (advisory) ─────────────────────────────────
    echo ""
    echo "  ── Layer 2: Drift Sweep (advisory) ──"

    l2_hits=0
    l2_output=""

    if git -C "$REPO" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      # Get all tracked text files, grep for 2.X.Y patterns (left-anchored: non-digit before 2)
      raw_hits="$(git -C "$REPO" ls-files -z 2>/dev/null \
        | (cd "$REPO" && LC_ALL=C xargs -0 grep -InE '(^|[^0-9])2\.[0-9]+\.[0-9]+' 2>/dev/null))" || true

      if [ -n "$raw_hits" ]; then
        while IFS= read -r hit; do
          [ -n "$hit" ] || continue
          file="${hit%%:*}"
          rest="${hit#*:}"
          lineno="${rest%%:*}"
          content="${rest#*:}"

          # Exclusion (a): path-based deny list
          case "$file" in
            archive/*|*/archive/*|evidence/*|*/evidence/*|migrations/*|*/migrations/*) continue ;;
            node_modules/*|*/node_modules/*) continue ;;
            package-lock.json) continue ;;
            */skills/*/references/*) continue ;;
            *_archived/*|_archived/*) continue ;;
            .tad/active/ideas/*) continue ;;
          esac

          # Exclusion (b): CHANGELOG table rows
          case "$file" in
            CHANGELOG.md|*/CHANGELOG.md)
              if printf '%s' "$content" | LC_ALL=C grep -qE '^\s*\|'; then continue; fi
              ;;
          esac

          # Exclusion (c): metadata version annotations
          if printf '%s' "$content" | LC_ALL=C grep -qE '(added_in|deprecated_in|since_version):'; then
            continue
          fi

          # Exclusion (d): IP address filtering (digit or dot adjacent to match)
          if printf '%s' "$content" | LC_ALL=C grep -qE '[0-9]\.2\.[0-9]+\.[0-9]+|2\.[0-9]+\.[0-9]+\.[0-9]'; then
            continue
          fi

          # Exclusion (e): lines that contain the EXPECTED version are not drift
          if printf '%s' "$content" | grep -qF "$VER"; then
            continue
          fi

          # This is a Layer 2 hit (cap output at 20 for bounded memory)
          l2_hits=$((l2_hits + 1))
          if [ "$l2_hits" -le 20 ]; then
            l2_output="${l2_output}  ⚠️  ${file}:${lineno}: $(printf '%s' "$content" | head -c 100)"$'\n'
          fi
        done <<VERSION_SWEEP_EOF
$raw_hits
VERSION_SWEEP_EOF
      fi
    else
      echo "  (not a git repo — Layer 2 skipped)"
    fi

    if [ "$l2_hits" -eq 0 ]; then
      echo "  Layer 2 hits: 0 (clean)"
    else
      printf '%s' "$l2_output"
      if [ "$l2_hits" -gt 20 ]; then
        echo "  ... and $((l2_hits - 20)) more (truncated)"
      fi
      echo "  Layer 2 hits: $l2_hits (advisory only, not blocking)"
    fi

    # ── Final verdict ──────────────────────────────────────────────────────────
    echo ""
    echo "-----------------------------------------"
    if [ "$l1_fails" -eq 0 ]; then
      echo "VERDICT: version-sweep PASS (exit 0)"
      exit 0
    else
      echo "VERDICT: version-sweep FAIL — $l1_fails Layer 1 stale ref(s) (exit 1)"
      exit 1
    fi
    ;;

  # ───────────────────────── platform-skills ─────────────────────────
  # Post-sync/install verifier: framework-owned skills must be byte-symmetric
  # between .claude/skills and .agents/skills in the TARGET project.
  # Framework-owned = skill dir present in SOURCE .claude/skills/ or .agents/skills/.
  # Target-only extras = local-skill INFO (FR7).
  # Exit 0 = symmetric; exit 1 = drift/missing; exit 2 = usage.
  platform-skills)
    if [ $# -ne 3 ]; then usage; exit 2; fi
    SRC="$2"
    TGT="$3"

    echo "========================================="
    echo "PLATFORM-SKILLS VERIFY (framework-owned skill symmetry)"
    echo "  SOURCE: $SRC"
    echo "  TARGET: $TGT"
    echo "========================================="

    # Derive framework-owned skill set from source (union of .claude + .agents basenames)
    fw_skills=""
    if [ -d "$SRC/.claude/skills" ]; then
      for d in "$SRC/.claude/skills"/*/; do
        [ -d "$d" ] || continue
        name="$(basename "$d")"
        fw_skills="$fw_skills $name"
      done
    fi
    if [ -d "$SRC/.agents/skills" ]; then
      for d in "$SRC/.agents/skills"/*/; do
        [ -d "$d" ] || continue
        name="$(basename "$d")"
        case " $fw_skills " in
          *" $name "*) ;; # already in set
          *) fw_skills="$fw_skills $name" ;;
        esac
      done
    fi

    if [ -z "$fw_skills" ]; then
      echo "WARNING: no framework-owned skills found in source"
      echo "VERDICT: platform-skills PASS (nothing to verify, exit 0)"
      exit 0
    fi

    # Source precondition: source .claude and .agents must be symmetric
    src_fails=0
    for skill in $fw_skills; do
      has_claude=false
      has_agents=false
      [ -d "$SRC/.claude/skills/$skill" ] && has_claude=true
      [ -d "$SRC/.agents/skills/$skill" ] && has_agents=true

      if [ "$has_claude" = true ] && [ "$has_agents" = true ]; then
        sout="$(diff -rq "$SRC/.claude/skills/$skill" "$SRC/.agents/skills/$skill" 2>&1)" || true
        if [ -n "$sout" ]; then
          echo "  ❌ SOURCE PRECONDITION: $skill differs between .claude and .agents in source"
          printf '%s\n' "$sout" | sed 's/^/      /' | head -4
          src_fails=$((src_fails + 1))
        fi
      elif [ "$has_claude" = true ] && [ "$has_agents" = false ]; then
        echo "  ❌ SOURCE PRECONDITION: $skill exists in source .claude but missing from .agents"
        src_fails=$((src_fails + 1))
      elif [ "$has_claude" = false ] && [ "$has_agents" = true ]; then
        echo "  ❌ SOURCE PRECONDITION: $skill exists in source .agents but missing from .claude"
        src_fails=$((src_fails + 1))
      fi
    done
    if [ "$src_fails" -gt 0 ]; then
      echo "VERDICT: platform-skills FAIL — $src_fails source precondition error(s) (exit 1)"
      exit 1
    fi

    fails=0
    infos=0
    checked=0

    # Collect target-side skill basenames for local-skill detection
    tgt_skills=""
    for platform in .claude .agents; do
      if [ -d "$TGT/$platform/skills" ]; then
        for d in "$TGT/$platform/skills"/*/; do
          [ -d "$d" ] || continue
          name="$(basename "$d")"
          case " $tgt_skills " in
            *" $name "*) ;;
            *) tgt_skills="$tgt_skills $name" ;;
          esac
        done
      fi
    done

    # Check framework-owned skills in target
    for skill in $fw_skills; do
      checked=$((checked + 1))
      claude_dir="$TGT/.claude/skills/$skill"
      agents_dir="$TGT/.agents/skills/$skill"

      if [ ! -d "$claude_dir" ] && [ ! -d "$agents_dir" ]; then
        echo "  ❌ MISSING: $skill — absent from both .claude and .agents in target"
        fails=$((fails + 1))
        continue
      fi
      if [ ! -d "$claude_dir" ]; then
        echo "  ❌ MISSING: $skill — absent from .claude/skills in target"
        fails=$((fails + 1))
        continue
      fi
      if [ ! -d "$agents_dir" ]; then
        echo "  ❌ MISSING: $skill — absent from .agents/skills in target"
        fails=$((fails + 1))
        continue
      fi

      out="$(diff -rq "$claude_dir" "$agents_dir" 2>&1)" || true
      if [ -z "$out" ]; then
        echo "  ✅ $skill symmetric"
      else
        echo "  ❌ DRIFT: $skill — .claude and .agents differ in target"
        printf '%s\n' "$out" | sed 's/^/      /' | head -4
        fails=$((fails + 1))
      fi
    done

    # Report target-only local skills as INFO
    for skill in $tgt_skills; do
      case " $fw_skills " in
        *" $skill "*) ;; # framework-owned, already checked
        *)
          echo "  ℹ️  local-skill: $skill (target-only, not framework-owned)"
          infos=$((infos + 1))
          ;;
      esac
    done

    echo "-----------------------------------------"
    echo "Checked: $checked framework-owned skills"
    if [ "$infos" -gt 0 ]; then
      echo "Local-only: $infos (INFO, not blocking)"
    fi
    if [ "$fails" -eq 0 ]; then
      echo "VERDICT: platform-skills PASS (exit 0)"
      exit 0
    else
      echo "VERDICT: platform-skills FAIL — $fails missing/drifted skill(s) (exit 1)"
      exit 1
    fi
    ;;

  *)
    usage
    exit 2
    ;;
esac
