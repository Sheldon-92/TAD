#!/usr/bin/env bash
# regression-replay.sh — 命名回归样本集 runner（Epic P2 件 2.1）
#
# 只做结构校验与评分，不自带 spawn（通道无关是刻意边界：捕获由执行者按
# 所在通道编排，方式记入 scores.md）。判分口径正本＝
# .tad/regression-samples/README.md；每案机器可读评分块在各 case.md 的
# <!-- replay-scoring --> 注释内，本脚本以 sed 提取后按字面执行：
#   判别命中＝grep -oE 判别 pattern 的 distinct 命中数；
#   案 PASS ⇔ distinct 命中 ≥ min_discriminative 且 must_not 命中数 = 0；
#   control distinct 命中 > control_max_hits → 该案 INVALID、整轮 FAIL。
#
# 用法：
#   regression-replay.sh check
#     结构校验：三案 input.md/case.md/control.md 齐；case.md 六要素落法齐
#     （frontmatter 三键、允许工具行、判分规则/原始轨迹/期望轨迹三节、
#     评分块可提取、判别 pattern 分支 ≥4）。全过 exit 0。
#   regression-replay.sh score <run-dir> [channel] [model] [duration]
#     对 <run-dir>/outputs/<case>.md 全量评分，逐案打印评分行并把
#     scores.md 写入 <run-dir>（含整轮 verdict 与通道/模型/耗时列）。
set -u

SAMPLES_DIR="$(cd "$(dirname "$0")/../regression-samples" && pwd)"
CASES="activation-bypass tmp-capture-collision log-absence-misread"

extract() { # extract <case.md> <key>
  sed -n "s/^[[:space:]]*$2:[[:space:]]*'\{0,1\}\(.*\)'\{0,1\}[[:space:]]*$/\1/p" "$1" | head -1
}
extract_pat() { # extract_pat <case.md> <key> — value is single-quoted
  sed -n "s/^[[:space:]]*$2:[[:space:]]*'\(.*\)'[[:space:]]*$/\1/p" "$1" | head -1
}
distinct_hits() { # distinct_hits <pattern> <file>
  grep -oE -- "$1" "$2" 2>/dev/null | sort -u | wc -l | tr -d ' '
}
total_hits() { # total_hits <pattern> <file>
  grep -oE -- "$1" "$2" 2>/dev/null | wc -l | tr -d ' '
}
branch_count() { # branch_count <pattern> — top-level | 数 +1
  printf '%s' "$1" | awk -F'|' '{print NF}'
}

MODE="${1:-}"
case "$MODE" in
  check)
    rc=0
    for c in $CASES; do
      d="$SAMPLES_DIR/cases/$c"
      for f in input.md case.md control.md; do
        [ -s "$d/$f" ] || { echo "CHECK FAIL: cases/$c/$f missing or empty"; rc=1; }
      done
      [ -f "$d/case.md" ] || continue
      grep -q '^sample_version: 1' "$d/case.md" || { echo "CHECK FAIL: $c frontmatter sample_version"; rc=1; }
      grep -q '^source_incident_date:' "$d/case.md" || { echo "CHECK FAIL: $c frontmatter source_incident_date"; rc=1; }
      grep -q '^evidence_paths:' "$d/case.md" || { echo "CHECK FAIL: $c frontmatter evidence_paths"; rc=1; }
      grep -q '^允许工具：' "$d/case.md" || { echo "CHECK FAIL: $c 允许工具行"; rc=1; }
      for s in '## 判分规则' '## 原始轨迹' '## 期望轨迹' '## 固定输入' '## 场景'; do
        grep -q "^$s" "$d/case.md" || { echo "CHECK FAIL: $c missing section $s"; rc=1; }
      done
      pat="$(extract_pat "$d/case.md" discriminative_pattern)"
      [ -n "$pat" ] || { echo "CHECK FAIL: $c scoring block unparsable"; rc=1; continue; }
      nb="$(branch_count "$pat")"
      [ "$nb" -ge 4 ] || { echo "CHECK FAIL: $c discriminative branches=$nb (<4)"; rc=1; }
      [ "$(extract "$d/case.md" min_discriminative)" = "3" ] || { echo "CHECK FAIL: $c min_discriminative != 3"; rc=1; }
      [ "$(extract "$d/case.md" control_max_hits)" = "1" ] || { echo "CHECK FAIL: $c control_max_hits != 1"; rc=1; }
      [ -n "$(extract_pat "$d/case.md" must_not_pattern)" ] || { echo "CHECK FAIL: $c must_not_pattern empty"; rc=1; }
    done
    [ "$rc" -eq 0 ] && echo "CHECK PASS: structure complete (3 cases)"
    exit "$rc"
    ;;
  score)
    RUN_DIR="${2:-}"; [ -n "$RUN_DIR" ] && [ -d "$RUN_DIR" ] || { echo "usage: regression-replay.sh score <run-dir> [channel] [model] [duration]" >&2; exit 2; }
    CH="${3:-unspecified}"; MO="${4:-unspecified}"; DU="${5:-unspecified}"
    OUT="$RUN_DIR/scores.md"
    {
      echo "# scores — regression run $RUN_DIR"
      echo
      echo "- 执行通道： $CH"
      echo "- 模型： $MO"
      echo "- 耗时： $DU"
      echo
    } > "$OUT"
    all_pass=1; invalid=""
    for c in $CASES; do
      cm="$SAMPLES_DIR/cases/$c/case.md"
      pat="$(extract_pat "$cm" discriminative_pattern)"
      mnp="$(extract_pat "$cm" must_not_pattern)"
      mind="$(extract "$cm" min_discriminative)"; cmax="$(extract "$cm" control_max_hits)"
      ans="$RUN_DIR/outputs/$c.md"
      dh="$(distinct_hits "$pat" "$ans")"
      mnh="$(total_hits "$mnp" "$ans")"
      ch="$(distinct_hits "$pat" "$SAMPLES_DIR/cases/$c/control.md")"
      verdict="PASS"
      if [ "$ch" -gt "$cmax" ]; then verdict="INVALID (control $ch > $cmax)"; invalid="$invalid $c"; all_pass=0;
      elif [ "$dh" -lt "$mind" ] || [ "$mnh" -ne 0 ]; then verdict="FAIL"; all_pass=0; fi
      {
        echo "case: $c"
        echo "discriminative_hits: $dh (min $mind)"
        echo "must_not_hits: $mnh"
        echo "control_hits: $ch (max $cmax)"
        echo "verdict: $verdict"
        echo "---"
      } | tee -a "$OUT"
    done
    if [ "$all_pass" -eq 1 ]; then echo "整轮 verdict: PASS" | tee -a "$OUT"; else echo "整轮 verdict: FAIL（失效案：${invalid:-无，案级 FAIL}）" | tee -a "$OUT"; fi
    [ "$all_pass" -eq 1 ]
    ;;
  *) echo "usage: regression-replay.sh [check|score <run-dir> [channel] [model] [duration]]" >&2; exit 2 ;;
esac
