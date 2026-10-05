#!/usr/bin/env bash
# scan-downstream-versions.sh — downstream version ledger generator.
#
# TASK-20261004-TAD-STATE-SURFACE-CLOSEOUT, design §5 (D item).
# Scans every sibling repo under the yun-sync root that carries a .tad/
# directory, reads its .tad/version.txt, and regenerates the derived
# ledger .tad/evidence/pm/downstream-versions.md.
#
# The ledger is a DERIVED INDEX (directories are ground truth): never
# hand-edit it; re-run this script instead. Re-runs are reproducible:
# output is identical except the generated-at line.
#
# Directory names are handled byte-accurately: quoted glob expansion,
# no trimming, no normalization (the fleet contains a trailing-space
# non-ASCII name, "Pokémon ", whose version.txt is EMPTY).
#
# Usage: scan-downstream-versions.sh [--root <yun-sync-root>] [--out <path>]
#   --root defaults to the parent directory of this repo.
#   --out  defaults to <repo>/.tad/evidence/pm/downstream-versions.md.
# bash + standard tools only; no yaml, no network, no node.

set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$SCRIPT_DIR/../.." && pwd)"
ROOT="$(cd "$REPO/.." && pwd)"
OUT="$REPO/.tad/evidence/pm/downstream-versions.md"

while [ $# -gt 0 ]; do
  case "$1" in
    --root) ROOT="$2"; shift 2 ;;
    --out) OUT="$2"; shift 2 ;;
    *) echo "usage: scan-downstream-versions.sh [--root <dir>] [--out <path>]" >&2; exit 2 ;;
  esac
done

if [ ! -d "$ROOT" ]; then
  echo "ERROR: root not found: $ROOT" >&2
  exit 1
fi

CURRENT=""
if [ -f "$REPO/.tad/version.txt" ]; then
  CURRENT="$(head -n 1 "$REPO/.tad/version.txt" | tr -d '[:space:]')"
fi

tmp_rows="$(mktemp)"
tmp_dist="$(mktemp)"
trap 'rm -f "$tmp_rows" "$tmp_dist"' EXIT

total=0
n_current=0
n_missing=0
n_empty=0

for tad_dir in "$ROOT"/*/.tad; do
  [ -d "$tad_dir" ] || continue
  repo_dir="${tad_dir%/.tad}"
  name="${repo_dir##*/}"
  vf="$tad_dir/version.txt"
  total=$((total + 1))
  if [ ! -f "$vf" ]; then
    ver="MISSING"
    note="无 .tad/version.txt"
    n_missing=$((n_missing + 1))
  else
    ver="$(head -n 1 "$vf" | tr -d '[:space:]')"
    if [ -z "$ver" ]; then
      ver="EMPTY"
      note="version.txt 为空"
      n_empty=$((n_empty + 1))
    else
      note=""
      if [ -n "$CURRENT" ] && [ "$ver" = "$CURRENT" ]; then
        n_current=$((n_current + 1))
      fi
    fi
  fi
  printf '%s\n' "$ver" >> "$tmp_dist"
  printf '| %s | %s | %s |\n' "$name" "$ver" "$note" >> "$tmp_rows"
done

# Distribution over concrete versions only (ASCII strings; LC_ALL=C for
# byte-stable ordering per shell-portability rules).
dist_line="$(grep -v -e '^MISSING$' -e '^EMPTY$' "$tmp_dist" | LC_ALL=C sort | uniq -c \
  | awk '{printf "%s ×%s / ", $2, $1}' | sed 's| / $||')"

mkdir -p "$(dirname "$OUT")"
{
  printf 'generated-by: .tad/scripts/scan-downstream-versions.sh\n'
  printf 'generated-at: %s\n' "$(date +%Y-%m-%d)"
  printf 'source-of-truth: 各仓 .tad/version.txt（本文件是派生索引，禁止手改）\n'
  printf '覆盖口径：本台账覆盖范围为 yun-sync 席位仓；goal 型仓为轻量装、无 version.txt 版本面，不在扫描口径内，其缺席不构成版本缺失。\n'
  printf '\n'
  printf '# 下游仓版本台账\n'
  printf '\n'
  printf '总数：%s\n' "$total"
  printf '当前版本（%s）：%s\n' "${CURRENT:-unknown}" "$n_current"
  printf 'MISSING（无 version.txt）：%s\n' "$n_missing"
  printf 'EMPTY（version.txt 为空）：%s\n' "$n_empty"
  printf '版本分布：%s\n' "$dist_line"
  printf '明细行数：%s\n' "$total"
  printf '\n'
  printf '| 仓名 | 版本 | 备注 |\n'
  printf '|---|---|---|\n'
  LC_ALL=C sort "$tmp_rows"
} > "$OUT"

echo "wrote $OUT (total=$total current=$n_current missing=$n_missing empty=$n_empty)"
