#!/usr/bin/env bash
# memory-redirect.sh — point Claude Code auto-memory at .tad/memory/ (TAD Capture layer)
# Usage: --enable | --status | --revert    (run from project root)
# DR-20260712 verdict 1. NO hooks registered — plain CLI tool (principles.md 2026-04-15).
set -euo pipefail

MODE="${1:---status}"
# Guard: must run from a TAD project root [SEC P2 run-from-root]
[ -f .tad/config.yaml ] || { echo "ERROR: run from TAD project root (.tad/config.yaml not found)"; exit 1; }
ROOT="$(pwd)"
LOCAL_SETTINGS=".claude/settings.local.json"
TARGET_DIR="$ROOT/.tad/memory"
# Claude Code derives the per-project dir by replacing '/' and ' ' with '-'
SLUG="$(printf '%s' "$ROOT" | sed 's![/ ]!-!g')"
OLD_DIR="$HOME/.claude/projects/$SLUG/memory"

status() {
  echo "project: $ROOT"
  echo "old native dir: $OLD_DIR ($(ls "$OLD_DIR" 2>/dev/null | wc -l | tr -d ' ') files)"
  echo "target dir:     $TARGET_DIR ($(ls "$TARGET_DIR" 2>/dev/null | wc -l | tr -d ' ') files)"
  echo "autoMemoryDirectory: $(jq -r '.autoMemoryDirectory // "ABSENT"' "$LOCAL_SETTINGS" 2>/dev/null || echo "no settings.local.json")"
}

enable() {
  command -v jq >/dev/null || { echo "ERROR: jq required"; exit 1; }
  # SLUG preflight: hard-verify derivation against reality [SEC P1-3]
  if [ ! -d "$OLD_DIR" ]; then
    echo "WARN: derived old dir not found: $OLD_DIR"
    echo "      (no prior memories, or slug rule mismatch — check ~/.claude/projects/ manually)"
    echo "      Proceeding with redirect only (no migration)."
  fi
  mkdir -p "$TARGET_DIR" .claude
  if [ -f "$LOCAL_SETTINGS" ]; then
    tmp="$(mktemp)"
    jq --arg d "$TARGET_DIR" '. + {autoMemoryDirectory: $d}' "$LOCAL_SETTINGS" > "$tmp" && mv "$tmp" "$LOCAL_SETTINGS"
  else
    printf '{\n  "autoMemoryDirectory": "%s"\n}\n' "$TARGET_DIR" > "$LOCAL_SETTINGS"
  fi
  if [ -d "$OLD_DIR" ]; then
    cp -n "$OLD_DIR"/*.md "$TARGET_DIR"/ 2>/dev/null || true
    # content-complete verification is AC2 (diff -rq), not here — script stays simple
  fi
  status
  echo "DONE. Verify in a NEW session (workspace trust dialog may appear once)."
}

revert() {  # [CR P1-2: falsification/rollback path]
  [ -f "$LOCAL_SETTINGS" ] || { echo "nothing to revert"; exit 0; }
  tmp="$(mktemp)"
  jq 'del(.autoMemoryDirectory)' "$LOCAL_SETTINGS" > "$tmp" && mv "$tmp" "$LOCAL_SETTINGS"
  echo "autoMemoryDirectory removed. .tad/memory/ left in place (data untouched)."
}

case "$MODE" in
  --enable) enable ;;
  --status) status ;;
  --revert) revert ;;
  *) echo "usage: memory-redirect.sh --enable|--status|--revert"; exit 1 ;;
esac
