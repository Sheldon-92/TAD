#!/usr/bin/env bash
# gate-exercise.sh — Gate interception exercise (proves migration gate can block)
# Creates a temporary git repo state with an unmanifested delete, runs
# release-verify.sh migration mode, verifies it correctly exits 1.
#
# Usage: bash gate-exercise.sh [--source <tad-repo-root>]
#   Default --source: auto-detect from script location (../../..)
#
# Exit codes: 0=gate correctly blocked (PASS), 1=gate failed to catch (FAIL), 2=usage error
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"

# Colors (if terminal supports)
RED="" GREEN="" RESET=""
if [ -t 1 ]; then RED=$'\033[31m'; GREEN=$'\033[32m'; RESET=$'\033[0m'; fi

# ══════════════════════════════════════════════════════════════
# Argument parsing
# ══════════════════════════════════════════════════════════════
SOURCE=""

while [ $# -gt 0 ]; do
  case "$1" in
    --source) SOURCE="$2"; shift 2 ;;
    --help|-h)
      printf 'Usage: bash gate-exercise.sh [--source <tad-repo-root>]\n'
      exit 0
      ;;
    *) printf 'ERROR: unknown argument: %s\n' "$1" >&2; exit 2 ;;
  esac
done

# Auto-detect source root from script location
if [ -z "$SOURCE" ]; then
  SOURCE="$(cd "$SCRIPT_DIR/../.." && pwd -P)"
fi

if [ ! -d "$SOURCE/.tad/hooks/lib" ]; then
  printf 'ERROR: source root does not contain .tad/hooks/lib/: %s\n' "$SOURCE" >&2
  exit 2
fi

DERIVE_SRC="$SOURCE/.tad/hooks/lib/derive-sync-set.sh"
VERIFIER_SRC="$SOURCE/.tad/hooks/lib/release-verify.sh"

if [ ! -f "$DERIVE_SRC" ]; then
  printf 'ERROR: derive-sync-set.sh not found at %s\n' "$DERIVE_SRC" >&2
  exit 2
fi
if [ ! -f "$VERIFIER_SRC" ]; then
  printf 'ERROR: release-verify.sh not found at %s\n' "$VERIFIER_SRC" >&2
  exit 2
fi

# ══════════════════════════════════════════════════════════════
# Create temp dir with trap cleanup on EXIT
# ══════════════════════════════════════════════════════════════
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

printf '=== Gate Interception Exercise ===\n'
printf '  Source: %s\n' "$SOURCE"
printf '  Temp dir: %s\n\n' "$TMP_DIR"

# ══════════════════════════════════════════════════════════════
# Step 1: Initialize git repo in temp dir
# ══════════════════════════════════════════════════════════════
cd "$TMP_DIR"
git init -q
git config user.email "gate-exercise@test.com"
git config user.name "Gate Exercise"

# Create .tad structure needed for derive-sync-set.sh to work
# (it needs .tad/ and various subdirs to emit the sync set)
mkdir -p .tad/hooks/lib
mkdir -p .tad/migrations
mkdir -p .tad/tests
mkdir -p .tad/templates
mkdir -p .tad/capability-packs
mkdir -p .tad/codex
mkdir -p .tad/cross-model
mkdir -p .tad/active
mkdir -p .tad/archive
mkdir -p .tad/evidence
mkdir -p .tad/project-knowledge
mkdir -p .tad/decisions
mkdir -p .tad/pair-testing
mkdir -p .tad/github-registry
mkdir -p .tad/research-notebooks
mkdir -p .tad/skillify-candidates

# Copy derive-sync-set.sh and release-verify.sh into temp repo
cp "$DERIVE_SRC" .tad/hooks/lib/derive-sync-set.sh
cp "$VERIFIER_SRC" .tad/hooks/lib/release-verify.sh

# ══════════════════════════════════════════════════════════════
# Step 2: Create v0.1.0 tag with a framework file
# ══════════════════════════════════════════════════════════════
mkdir -p .claude/skills
printf 'test skill content' > .claude/skills/test-file.md
printf '0.1.0\n' > .tad/version.txt
git add -A
git commit -q -m "v0.1.0"
git tag "v0.1.0"

# ══════════════════════════════════════════════════════════════
# Step 3: Remove the file, bump to v0.2.0, commit and tag — NO manifest
# ══════════════════════════════════════════════════════════════
rm -f .claude/skills/test-file.md
printf '0.2.0\n' > .tad/version.txt
git add -A
git commit -q -m "v0.2.0 - removed test-file without manifest"
git tag "v0.2.0"

# ══════════════════════════════════════════════════════════════
# Step 4: Run release-verify.sh migration mode
# ══════════════════════════════════════════════════════════════
printf 'Running: release-verify.sh migration "%s" "0.2.0"\n\n' "$TMP_DIR"

local_verifier="$TMP_DIR/.tad/hooks/lib/release-verify.sh"
gate_rc=0
gate_output="$(bash "$local_verifier" migration "$TMP_DIR" "0.2.0" 2>&1)" || gate_rc=$?

# ══════════════════════════════════════════════════════════════
# Step 5: Assert gate correctly blocked
# ══════════════════════════════════════════════════════════════
printf '%s\n' "--- Gate Output ---"
printf '%s\n' "$gate_output"
printf '%s\n\n' "--- End Gate Output (exit code: $gate_rc) ---"

# Assertion 1: exit code must be 1
if [ "$gate_rc" -ne 1 ]; then
  printf '%sFAIL%s: gate exit code was %d, expected 1\n' "$RED" "$RESET" "$gate_rc"
  printf 'The migration gate did NOT block the unmanifested delete.\n'
  exit 1
fi

# Assertion 2: output must contain "UNMANIFESTED DELETE"
if ! printf '%s' "$gate_output" | grep -q 'UNMANIFESTED DELETE'; then
  printf '%sFAIL%s: gate output does not contain "UNMANIFESTED DELETE"\n' "$RED" "$RESET"
  printf 'The gate exited 1 but for the wrong reason.\n'
  exit 1
fi

# ══════════════════════════════════════════════════════════════
# PASS — gate correctly intercepted the unmanifested delete
# ══════════════════════════════════════════════════════════════
printf '%sPASS%s: Migration gate correctly blocked unmanifested delete (exit 1)\n' "$GREEN" "$RESET"
printf '  Gate detected: UNMANIFESTED DELETE of .claude/skills/test-file.md\n'
printf '  Proof: gate exit code = 1, output contains "UNMANIFESTED DELETE"\n'
exit 0
