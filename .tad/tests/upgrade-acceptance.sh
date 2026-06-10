#!/usr/bin/env bash
# upgrade-acceptance.sh — Post-sync per-project acceptance verifier
# Validates that a target project is correctly synced/migrated to the expected version.
#
# Usage: bash upgrade-acceptance.sh --target <dir> --expected-version <ver> \
#          [--snapshot <pre-sync-snapshot-dir>] \
#          [--expect-migration-from <old-ver>]
#
# Checks:
#   1. version.txt matches --expected-version
#   2. ZERO_TOUCH directories byte-identical to --snapshot (SKIP if --snapshot not provided)
#   3. No stale deprecated files remain (reads deprecation.yaml)
#   4. Migration report exists in .tad-backup/ (SKIP if --expect-migration-from not provided)
#
# Exit codes: 0=all pass (including skipped), 1=any verification failure, 2=usage error
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
DERIVE="$SCRIPT_DIR/../hooks/lib/derive-sync-set.sh"
DEPRECATION_YAML="$SCRIPT_DIR/../deprecation.yaml"

# Colors (if terminal supports)
RED="" GREEN="" YELLOW="" RESET=""
if [ -t 1 ]; then
  RED=$'\033[31m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'; RESET=$'\033[0m'
fi

# ══════════════════════════════════════════════════════════════
# Argument parsing
# ══════════════════════════════════════════════════════════════
TARGET="" EXPECTED_VERSION="" SNAPSHOT="" EXPECT_MIGRATION_FROM=""

usage() {
  cat >&2 <<'EOF'
Usage: bash upgrade-acceptance.sh --target <dir> --expected-version <ver> \
         [--snapshot <pre-sync-snapshot-dir>] \
         [--expect-migration-from <old-ver>]

Checks:
  1. version.txt matches --expected-version
  2. ZERO_TOUCH directories byte-identical to --snapshot (SKIP if no --snapshot)
  3. No stale deprecated files remain
  4. Migration report exists (SKIP if no --expect-migration-from)

Exit: 0=all pass, 1=any fail, 2=usage error
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --target) TARGET="$2"; shift 2 ;;
    --expected-version) EXPECTED_VERSION="$2"; shift 2 ;;
    --snapshot) SNAPSHOT="$2"; shift 2 ;;
    --expect-migration-from) EXPECT_MIGRATION_FROM="$2"; shift 2 ;;
    --help|-h) usage; exit 0 ;;
    *) printf 'ERROR: unknown argument: %s\n' "$1" >&2; usage; exit 2 ;;
  esac
done

if [ -z "$TARGET" ] || [ -z "$EXPECTED_VERSION" ]; then
  printf 'ERROR: --target and --expected-version are required\n' >&2
  usage
  exit 2
fi

if [ ! -d "$TARGET" ]; then
  printf 'ERROR: --target is not a directory: %s\n' "$TARGET" >&2
  exit 2
fi

if [ -n "$SNAPSHOT" ] && [ ! -d "$SNAPSHOT" ]; then
  printf 'ERROR: --snapshot is not a directory: %s\n' "$SNAPSHOT" >&2
  exit 2
fi

# ══════════════════════════════════════════════════════════════
# Result tracking
# ══════════════════════════════════════════════════════════════
PASS_COUNT=0 FAIL_COUNT=0 SKIP_COUNT=0

report_pass() { printf '  %s: %sPASS%s\n' "$1" "$GREEN" "$RESET"; PASS_COUNT=$((PASS_COUNT + 1)); }
report_fail() { printf '  %s: %sFAIL%s — %s\n' "$1" "$RED" "$RESET" "$2"; FAIL_COUNT=$((FAIL_COUNT + 1)); }
report_skip() { printf '  %s: %sSKIP%s — %s\n' "$1" "$YELLOW" "$RESET" "$2"; SKIP_COUNT=$((SKIP_COUNT + 1)); }

# ══════════════════════════════════════════════════════════════
# Check 1: version.txt match
# ══════════════════════════════════════════════════════════════
check_version() {
  local version_file="$TARGET/.tad/version.txt"
  if [ ! -f "$version_file" ]; then
    report_fail "version.txt" "file not found at $version_file"
    return
  fi
  local actual
  actual="$(head -1 "$version_file" | tr -d '[:space:]')"
  if [ "$actual" = "$EXPECTED_VERSION" ]; then
    report_pass "version ($actual)"
  else
    report_fail "version" "expected=$EXPECTED_VERSION actual=$actual"
  fi
}

# ══════════════════════════════════════════════════════════════
# Check 2: ZERO_TOUCH diff (requires --snapshot)
# ══════════════════════════════════════════════════════════════
check_zero_touch() {
  if [ -z "$SNAPSHOT" ]; then
    report_skip "ZERO_TOUCH diff" "no --snapshot provided"
    return
  fi

  if [ ! -f "$DERIVE" ]; then
    report_fail "ZERO_TOUCH diff" "derive-sync-set.sh not found at $DERIVE"
    return
  fi

  local zt_dirs failed=0
  zt_dirs="$(bash "$DERIVE" --zero-touch "$TARGET" 2>/dev/null)" || {
    report_fail "ZERO_TOUCH diff" "derive-sync-set.sh --zero-touch failed"
    return
  }

  while IFS= read -r dir; do
    [ -n "$dir" ] || continue
    local src_dir="$SNAPSHOT/.tad/$dir"
    local tgt_dir="$TARGET/.tad/$dir"

    if [ ! -d "$src_dir" ] && [ ! -d "$tgt_dir" ]; then
      continue  # Both absent is fine
    fi
    if [ ! -d "$src_dir" ] || [ ! -d "$tgt_dir" ]; then
      printf '    %s: one side missing (snapshot=%s target=%s)\n' "$dir" \
        "$([ -d "$src_dir" ] && echo "exists" || echo "MISSING")" \
        "$([ -d "$tgt_dir" ] && echo "exists" || echo "MISSING")"
      failed=1
      continue
    fi

    local diffs
    diffs="$(diff -rq "$src_dir" "$tgt_dir" 2>/dev/null)" || true
    if [ -n "$diffs" ]; then
      printf '    %s: differs\n' "$dir"
      printf '%s\n' "$diffs" | head -5 | sed 's/^/      /'
      failed=1
    fi
  done <<< "$zt_dirs"

  if [ "$failed" -eq 0 ]; then
    report_pass "ZERO_TOUCH directories byte-identical"
  else
    report_fail "ZERO_TOUCH diff" "one or more ZERO_TOUCH directories differ from snapshot"
  fi
}

# ══════════════════════════════════════════════════════════════
# Check 3: No stale deprecated files
# ══════════════════════════════════════════════════════════════
check_deprecated() {
  if [ ! -f "$DEPRECATION_YAML" ]; then
    report_skip "deprecated files" "deprecation.yaml not found at $DEPRECATION_YAML"
    return
  fi

  # Parse deprecated file paths from deprecation.yaml using awk state machine
  local deprecated_paths
  deprecated_paths="$(awk '
    /^  "[0-9]/ { in_version=1; next }
    /^    files:/ { in_files=1; next }
    in_files && /^      - / {
      sub(/^      - /, "")
      gsub(/"/, "")
      gsub(/'\''/, "")
      print
      next
    }
    in_files && !/^      / { in_files=0 }
  ' "$DEPRECATION_YAML")"

  local stale_found=0
  while IFS= read -r fpath; do
    [ -n "$fpath" ] || continue
    # Trim whitespace
    fpath="$(printf '%s' "$fpath" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    [ -n "$fpath" ] || continue

    local full_path="$TARGET/$fpath"
    # Directory entries end with /
    if printf '%s' "$fpath" | grep -q '/$'; then
      if [ -d "$full_path" ]; then
        printf '    stale dir: %s\n' "$fpath"
        stale_found=1
      fi
    else
      if [ -f "$full_path" ]; then
        printf '    stale file: %s\n' "$fpath"
        stale_found=1
      fi
    fi
  done <<< "$deprecated_paths"

  if [ "$stale_found" -eq 0 ]; then
    report_pass "deprecated files absent"
  else
    report_fail "deprecated files" "stale deprecated files found in target"
  fi
}

# ══════════════════════════════════════════════════════════════
# Check 4: Migration report (requires --expect-migration-from)
# ══════════════════════════════════════════════════════════════
check_migration_report() {
  if [ -z "$EXPECT_MIGRATION_FROM" ]; then
    report_skip "migration report" "no --expect-migration-from provided"
    return
  fi

  local report_dir="$TARGET/.tad-backup/${EXPECT_MIGRATION_FROM}-to-${EXPECTED_VERSION}"
  local report_file="$report_dir/MIGRATION-REPORT.tsv"

  if [ -f "$report_file" ]; then
    report_pass "migration report exists ($report_file)"
  else
    report_fail "migration report" "expected at $report_file but not found"
  fi
}

# ══════════════════════════════════════════════════════════════
# Run all checks
# ══════════════════════════════════════════════════════════════
printf '=== TAD Upgrade Acceptance Verification ===\n'
printf '  Target: %s\n' "$TARGET"
printf '  Expected version: %s\n' "$EXPECTED_VERSION"
[ -n "$SNAPSHOT" ] && printf '  Snapshot: %s\n' "$SNAPSHOT"
[ -n "$EXPECT_MIGRATION_FROM" ] && printf '  Expect migration from: %s\n' "$EXPECT_MIGRATION_FROM"
printf '\n'

check_version
check_zero_touch
check_deprecated
check_migration_report

# ══════════════════════════════════════════════════════════════
# Summary verdict
# ══════════════════════════════════════════════════════════════
printf '\n=== Summary ===\n'
printf '  PASS: %d  FAIL: %d  SKIP: %d\n' "$PASS_COUNT" "$FAIL_COUNT" "$SKIP_COUNT"

if [ "$FAIL_COUNT" -gt 0 ]; then
  printf '\n%sVERDICT: FAIL%s\n' "$RED" "$RESET"
  exit 1
fi

printf '\n%sVERDICT: PASS%s\n' "$GREEN" "$RESET"
exit 0
