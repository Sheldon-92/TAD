#!/usr/bin/env bash
# ============================================================================
# pack-eval-runner.sh — Capability Pack Behavioral Eval ASSERTION engine
# ============================================================================
# SAFETY HEADER (advisory — NEVER fail-closed):
#   - This is NOT a hook. It is a developer-run assertion tool.
#   - It NEVER blocks, denies, or gates any agent action. It only PRINTS
#     PASS/FAIL verdicts for captured agent outputs against pack fixtures.
#   - It MUST NOT use `set -e` (a parse miss on one fixture must not abort
#     a batch run). Missing files / unparseable fixtures degrade to a
#     skip/0-count, never a non-zero abort.
#   - Division of labour: this script ASSERTS (greps a captured agent
#     output for fixture markers, checks min_marker_count). The CONDUCTOR
#     drives sub-agent spawning to PRODUCE those outputs — a bash script
#     cannot spawn Claude agents. That separation is intentional.
#   - Portability: BSD/macOS-safe. No `grep -P`. The runner's OWN match
#     uses `grep -oE <pattern> | sort -u | wc -l` (NOT `grep -c`, which
#     counts lines, not distinct matches — that is the P4 lint Rule A bug).
# ============================================================================

# Intentionally NO `set -e`. See SAFETY HEADER.
set -u

# ---------------------------------------------------------------------------
# parse_min_count <fixture.md>  → prints min_marker_count (default 3)
# ---------------------------------------------------------------------------
parse_min_count() {
  fixture="$1"
  [ -f "$fixture" ] || { echo 3; return 0; }
  # Read frontmatter only (between the first two '---' lines).
  awk '
    /^---[[:space:]]*$/ { fence++; next }
    fence==1 && /^min_marker_count:/ {
      v=$0
      sub(/^min_marker_count:[[:space:]]*/, "", v)
      gsub(/[^0-9]/, "", v)
      if (v != "") { print v; found=1; exit }
    }
    fence>=2 { exit }
    END { if (!found) print 3 }
  ' "$fixture"
}

# ---------------------------------------------------------------------------
# parse_pack <fixture.md> → prints pack name (frontmatter `pack:` or dir)
# ---------------------------------------------------------------------------
parse_pack() {
  fixture="$1"
  pk=""
  if [ -f "$fixture" ]; then
    pk=$(awk '
      /^---[[:space:]]*$/ { fence++; next }
      fence==1 && /^pack:/ {
        v=$0; sub(/^pack:[[:space:]]*/, "", v); gsub(/["'"'"']/, "", v)
        gsub(/[[:space:]]+$/, "", v); print v; exit
      }
      fence>=2 { exit }
    ' "$fixture")
  fi
  if [ -z "$pk" ]; then
    # Fallback: derive from path .claude/skills/<pack>/examples/<name>.md
    pk=$(printf '%s\n' "$fixture" | sed -n 's#.*/skills/\([^/]*\)/examples/.*#\1#p')
  fi
  [ -z "$pk" ] && pk="unknown"
  printf '%s' "$pk"
}

# ---------------------------------------------------------------------------
# parse_name <fixture.md> → prints fixture name (frontmatter `name:` or base)
# ---------------------------------------------------------------------------
parse_name() {
  fixture="$1"
  nm=""
  if [ -f "$fixture" ]; then
    nm=$(awk '
      /^---[[:space:]]*$/ { fence++; next }
      fence==1 && /^name:/ {
        v=$0; sub(/^name:[[:space:]]*/, "", v); gsub(/["'"'"']/, "", v)
        gsub(/[[:space:]]+$/, "", v); print v; exit
      }
      fence>=2 { exit }
    ' "$fixture")
  fi
  if [ -z "$nm" ]; then
    nm=$(basename "$fixture" .md)
  fi
  printf '%s' "$nm"
}

# ---------------------------------------------------------------------------
# parse_pattern <fixture.md> → prints the grep -oE '...' pattern from the
# bash block under '## Verification Command'. Returns "" if not found.
# ---------------------------------------------------------------------------
parse_pattern() {
  fixture="$1"
  [ -f "$fixture" ] || { printf ''; return 0; }
  awk '
    /^##[[:space:]]+Verification Command/ { invc=1; next }
    invc && /^##[[:space:]]/ { invc=0 }
    invc && /grep -oE/ {
      line=$0
      # Strip everything up to and including the first quote after grep -oE.
      sub(/.*grep -oE[[:space:]]+'"'"'/, "", line)
      # Strip from the closing quote onward.
      sub(/'"'"'.*/, "", line)
      print line
      exit
    }
  ' "$fixture"
}

# ---------------------------------------------------------------------------
# assert_one <fixture.md> <output-file> → prints verdict line, returns 0 PASS
# / 1 FAIL / 2 skipped (no output). NEVER aborts the caller.
# ---------------------------------------------------------------------------
assert_one() {
  fixture="$1"
  output="$2"
  pack=$(parse_pack "$fixture")
  name=$(parse_name "$fixture")
  min=$(parse_min_count "$fixture")
  pattern=$(parse_pattern "$fixture")

  if [ -z "$pattern" ]; then
    printf 'PACK %s FIXTURE %s: no verification pattern → SKIP (bad fixture)\n' "$pack" "$name"
    return 2
  fi
  if [ ! -f "$output" ]; then
    printf 'PACK %s FIXTURE %s: no output captured → SKIP\n' "$pack" "$name"
    return 2
  fi

  # The runner's OWN match: grep -oE ... | sort -u | wc -l (NOT grep -c).
  actual=$(grep -oE "$pattern" "$output" 2>/dev/null | sort -u | wc -l | tr -d ' ')
  [ -z "$actual" ] && actual=0

  if [ "$actual" -ge "$min" ] 2>/dev/null; then
    printf 'PACK %s FIXTURE %s: %s/%s → PASS\n' "$pack" "$name" "$actual" "$min"
    return 0
  else
    printf 'PACK %s FIXTURE %s: %s/%s → FAIL\n' "$pack" "$name" "$actual" "$min"
    return 1
  fi
}

# ---------------------------------------------------------------------------
# run_all <outputs-dir> → iterate every fixture, match captured output by
# fixture basename, emit results table + summary.
# ---------------------------------------------------------------------------
run_all() {
  outdir="$1"
  pass=0; fail=0; skip=0
  printf '%s\n' "=== Pack Behavioral Eval — batch (--all) ==="
  printf '%s\n' "outputs dir: $outdir"
  printf '%s\n' "-------------------------------------------------------------"

  # Glob; if no fixtures, nullglob-style guard.
  found_any=0
  for fixture in .claude/skills/*/examples/*.md; do
    [ -f "$fixture" ] || continue
    found_any=1
    base=$(basename "$fixture" .md)
    output="$outdir/$base.md"
    line=$(assert_one "$fixture" "$output")
    rc=$?
    printf '%s\n' "$line"
    case "$rc" in
      0) pass=$((pass+1)) ;;
      1) fail=$((fail+1)) ;;
      *) skip=$((skip+1)) ;;
    esac
  done

  if [ "$found_any" -eq 0 ]; then
    printf '%s\n' "(no fixtures found under .claude/skills/*/examples/)"
  fi
  printf '%s\n' "-------------------------------------------------------------"
  printf '%s pass / %s fail / %s skipped (no output captured)\n' "$pass" "$fail" "$skip"
  return 0
}

# ---------------------------------------------------------------------------
# Dispatch
# ---------------------------------------------------------------------------
usage() {
  cat <<'USAGE'
pack-eval-runner.sh — capability pack behavioral eval ASSERTION engine (advisory)

Usage:
  pack-eval-runner.sh <fixture.md> <agent-output-file>
      Assert one captured output against one fixture.
      Prints: PACK <pack> FIXTURE <name>: <actual>/<min> → PASS|FAIL

  pack-eval-runner.sh --all <outputs-dir>
      Iterate every .claude/skills/*/examples/*.md fixture, match a captured
      output at <outputs-dir>/<fixture-basename>.md, run each assertion, and
      print a results table + summary (P pass / F fail / S skipped).

Notes:
  - Advisory only. Never fail-closed. Not a hook.
  - Run from the TAD repo root (paths are relative to .claude/skills/).
USAGE
}

main() {
  if [ "$#" -lt 1 ]; then
    usage
    return 0
  fi
  case "$1" in
    --all)
      if [ "$#" -lt 2 ]; then
        printf 'error: --all requires <outputs-dir>\n' >&2
        usage
        return 0
      fi
      run_all "$2"
      ;;
    -h|--help)
      usage
      ;;
    *)
      if [ "$#" -lt 2 ]; then
        printf 'error: single-fixture mode requires <fixture.md> <agent-output-file>\n' >&2
        usage
        return 0
      fi
      assert_one "$1" "$2"
      # Map verdict rc to 0 for advisory mode (never fail-closed at exit).
      return 0
      ;;
  esac
  return 0
}

main "$@"
