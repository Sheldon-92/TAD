#!/usr/bin/env bash
# bundle-check.sh — Check JavaScript bundle sizes against thresholds
# Usage: bash scripts/bundle-check.sh [BUILD_DIR]
# Default build dir: .next (Next.js) or dist (Vite/CRA)
# Exit 0: all chunks within budget
# Exit 1: one or more chunks exceed budget
# Exit 2: no build output found

set -euo pipefail

if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
  echo "Usage: bash scripts/bundle-check.sh [BUILD_DIR]"
  echo "       Default: auto-detect (.next, dist, build)"
  echo ""
  echo "Checks JavaScript bundle size budgets:"
  echo "  Initial bundle:  ≤ 200KB gzipped"
  echo "  Per chunk:       ≤ 100KB gzipped"
  echo ""
  echo "Exit codes:"
  echo "  0  All chunks within budget"
  echo "  1  One or more chunks exceed budget"
  echo "  2  No build output found (run build first)"
  exit 0
fi

# Auto-detect build directory
BUILD_DIR="${1:-}"
if [[ -z "$BUILD_DIR" ]]; then
  if [[ -d ".next" ]]; then
    BUILD_DIR=".next"
  elif [[ -d "dist" ]]; then
    BUILD_DIR="dist"
  elif [[ -d "build" ]]; then
    BUILD_DIR="build"
  else
    echo "ERROR: No build output found."
    echo "Run your build command first (npm run build)."
    echo "Or specify the build directory: bash scripts/bundle-check.sh dist"
    exit 2
  fi
fi

echo "Checking bundle sizes in: $BUILD_DIR"
echo ""

# Threshold in bytes (gzipped)
INITIAL_THRESHOLD_BYTES=204800   # 200KB
CHUNK_THRESHOLD_BYTES=102400     # 100KB

# Find CLIENT bundle JS files only (exclude server-side bundles)
# Next.js App Router: client chunks are in .next/static/chunks/
# Vite/CRA: client assets are in dist/assets/ or build/static/js/
if [[ -d "$BUILD_DIR/static/chunks" ]]; then
  # Next.js App Router — only client chunks
  JS_FILES=$(find "$BUILD_DIR/static/chunks" -name "*.js" 2>/dev/null)
  echo "Detected: Next.js App Router (.next/static/chunks/)"
elif [[ -d "$BUILD_DIR/assets" ]]; then
  # Vite
  JS_FILES=$(find "$BUILD_DIR/assets" -name "*.js" 2>/dev/null)
  echo "Detected: Vite build (dist/assets/)"
elif [[ -d "$BUILD_DIR/static/js" ]]; then
  # Create React App
  JS_FILES=$(find "$BUILD_DIR/static/js" -name "*.js" 2>/dev/null)
  echo "Detected: Create React App (build/static/js/)"
else
  # Fallback: top-level JS only, excluding server dirs
  JS_FILES=$(find "$BUILD_DIR" -maxdepth 2 -name "*.js" \
    -not -path "*/server/*" \
    -not -path "*/node_modules/*" 2>/dev/null)
  echo "Using fallback: top-level JS files (maxdepth 2, excluding server/)"
fi

if [[ -z "$JS_FILES" ]]; then
  echo "ERROR: No client-side .js files found in $BUILD_DIR"
  echo "Build may have failed or directory is incorrect."
  echo "Run 'npm run build' first."
  exit 2
fi

FAILED=0
INITIAL_TOTAL=0
declare -a OVERSIZED_CHUNKS=()

echo "Chunk Size Analysis (gzipped):"
printf "  %-60s %10s %10s\n" "File" "Gzipped" "Status"
printf "  %-60s %10s %10s\n" "----" "-------" "------"

while IFS= read -r file; do
  if [[ ! -f "$file" ]]; then continue; fi

  # Get gzipped size — skip silently if gzip fails (corrupt file)
  GZIP_SIZE=$(gzip -c "$file" 2>/dev/null | wc -c | tr -d ' ' || echo "0")
  if [[ "$GZIP_SIZE" == "0" ]]; then
    echo "  WARNING: Could not gzip $(basename "$file") — skipping"
    continue
  fi

  # Track initial/entry chunks (heuristic — all chunks count toward total for next.js)
  BASENAME=$(basename "$file")
  if [[ "$BASENAME" == *"main"* ]] || [[ "$BASENAME" == *"page"* ]] || \
     [[ "$BASENAME" == *"_app"* ]] || [[ "$BASENAME" == framework* ]] || \
     [[ "$BASENAME" == polyfills* ]]; then
    INITIAL_TOTAL=$((INITIAL_TOTAL + GZIP_SIZE))
  fi

  # Format size using printf for decimal precision (avoids bc truncation bug)
  if [[ $GZIP_SIZE -gt 1024 ]]; then
    SIZE_KB=$(printf '%.1f' "$(echo "scale=4; $GZIP_SIZE / 1024" | bc -l)")
    SIZE_STR="${SIZE_KB}KB"
  else
    SIZE_STR="${GZIP_SIZE}B"
  fi

  # Check threshold
  STATUS="✅ OK"
  if [[ $GZIP_SIZE -gt $CHUNK_THRESHOLD_BYTES ]]; then
    STATUS="❌ OVER"
    FAILED=1
    OVERSIZED_CHUNKS+=("$file ($SIZE_STR gzipped)")
  fi

  # Trim long paths for display
  DISPLAY_PATH="${file#"$BUILD_DIR"/}"
  if [[ ${#DISPLAY_PATH} -gt 58 ]]; then
    DISPLAY_PATH="...${DISPLAY_PATH: -55}"
  fi

  printf "  %-60s %10s %10s\n" "$DISPLAY_PATH" "$SIZE_STR" "$STATUS"

done <<< "$JS_FILES"

echo ""

# Check total initial bundle
INITIAL_KB=$(printf '%.1f' "$(echo "scale=4; $INITIAL_TOTAL / 1024" | bc -l)")
INITIAL_STATUS="✅ OK"
if [[ $INITIAL_TOTAL -gt $INITIAL_THRESHOLD_BYTES ]]; then
  INITIAL_STATUS="❌ OVER"
  FAILED=1
fi

echo "Initial bundle total: ${INITIAL_KB}KB gzipped (threshold: 200KB) $INITIAL_STATUS"
echo ""

if [[ $FAILED -eq 0 ]]; then
  echo "RESULT: ✅ PASS — All chunks within size budget"
  exit 0
else
  echo "RESULT: ❌ FAIL — Bundle size budget exceeded"
  echo ""
  echo "Oversized chunks:"
  for chunk in "${OVERSIZED_CHUNKS[@]}"; do
    echo "  ❌ $chunk"
  done
  echo ""
  echo "Suggestions:"
  echo "  1. Check for large dependencies: npm run build -- --analyze"
  echo "  2. Add dynamic import() for heavy components (charts, rich text editors)"
  echo "  3. Use tree-shaking: import { specific } from 'library' not import library"
  exit 1
fi
