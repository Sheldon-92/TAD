#!/usr/bin/env bash
# interrupt-resume-check.sh — 中断续跑验收脚本（Epic P2 件 2.3）
#
# 在 mktemp 隔离工作区内自建一条合成链：顺序执行至中断点 → 模拟中断 →
# 恢复程序续跑 → 逐条断言。selftest 模式同跑正路（参考恢复）与破坏路
# （无视账本全量重跑的朴素恢复），破坏路必须挂断言 1 与 3，否则脚本自判 FAIL。
#
# 中断分类表摘要（与状态图逐字同源：
# .tad/evidence/epic-p2-measurement-20261006/state-graph-gate-chain.md
# ——一处改须两处改，头注与状态图分类表同批成文）：
#   INT-1 进程中断（spawn/会话死亡）——咬合断言 1（已执行不重跑）、断言 4（Gate 证据完整）
#   INT-2 压缩中断（compact 后上下文丢失）——咬合断言 5（step_id 不变）、断言 4
#   INT-3 环境中断（VM 重启/隧道断）——咬合断言 2（未提交编辑无损）、断言 4
#   INT-4 人工停步（裁断/人闸等待）——咬合断言 3（无重复副作用）、断言 1
#
# 用法：bash interrupt-resume-check.sh [run|selftest]
#   run      只跑参考恢复（k=2、k=4 两场景），全断言 PASS 才 exit 0
#   selftest 正路＋破坏路，正路须全过、破坏路须至少断言 1/3 FAIL，才 exit 0
set -u

sha_of() {
  if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" | cut -d' ' -f1;
  else shasum -a 256 "$1" | cut -d' ' -f1; fi
}

STEP_ID="TEST-STEP-001"
NSTEPS=5

# build_ws <dir>：自建合成链工作区（账本＋未提交编辑样本）
build_ws() {
  local ws="$1"
  mkdir -p "$ws/evidence"
  printf 'step_id: %s\n' "$STEP_ID" > "$ws/ledger.txt"
  printf 'uncommitted work in progress — do not touch\n' > "$ws/uncommitted-edit.txt"
  : > "$ws/effects.log"
}

# exec_step <ws> <i>：执行第 i 步（追加效应行＋写 Gate 证据）。执行器本身无幂等
# 判断——「只续跑未完成集」是恢复程序的职责，正是本脚本要验的性质。
exec_step() {
  local ws="$1" i="$2"
  printf 'STEP-%s effect\n' "$i" >> "$ws/effects.log"
  printf 'gate evidence for step %s (step_id %s)\n' "$i" "$STEP_ID" > "$ws/evidence/step-$i.md"
}

# completed_set <ws>：已完成集＝效应行与证据文件俱在的 step 号（空格分隔）
completed_set() {
  local ws="$1" i out=""
  for i in 1 2 3 4 5; do
    if grep -qF "STEP-$i effect" "$ws/effects.log" && [ -f "$ws/evidence/step-$i.md" ]; then
      out="$out $i"
    fi
  done
  printf '%s' "$out"
}

# recover_good <ws>：参考恢复——读账本＋effects＋证据面，只续跑未完成集
recover_good() {
  local ws="$1" done_set i
  done_set=" $(completed_set "$ws") "
  for i in 1 2 3 4 5; do
    case "$done_set" in *" $i "*) : ;; *) exec_step "$ws" "$i" ;; esac
  done
}

# recover_bad <ws>：朴素恢复——无视账本全量重跑（selftest 破坏路专用）
recover_bad() {
  local ws="$1" i
  for i in 1 2 3 4 5; do exec_step "$ws" "$i"; done
}

# run_scenario <k> <good|bad>：跑一幕并逐条断言；stdout 逐条 ASSERT，返回 0/1
run_scenario() {
  local k="$1" mode="$2"
  local ws; ws="$(mktemp -d)"
  build_ws "$ws"
  local i
  for i in $(seq 1 "$k"); do exec_step "$ws" "$i"; done
  # 模拟中断：执行进程在此直接消失，工作区原样保留（含未提交编辑）
  local edit_sha_before; edit_sha_before="$(sha_of "$ws/uncommitted-edit.txt")"
  local snap="$ws/.evidence-snapshot"
  : > "$snap"
  for i in $(seq 1 "$k"); do printf '%s %s\n' "$i" "$(sha_of "$ws/evidence/step-$i.md")" >> "$snap"; done
  local id_before; id_before="$(sed -n 's/^step_id: //p' "$ws/ledger.txt")"
  if [ "$mode" = good ]; then recover_good "$ws"; else recover_bad "$ws"; fi
  local fails=0
  # 断言 1：已执行工具不重跑——中断前已完成 step 的效应行各恰 1 行
  local a1=0 cnt
  for i in $(seq 1 "$k"); do
    cnt="$(grep -c "STEP-$i effect" "$ws/effects.log")"
    [ "$cnt" -eq 1 ] || a1=1
  done
  report 1 "$a1" "$k" "$mode"; fails=$((fails + a1))
  # 断言 2：未提交编辑无损
  local a2=0; [ "$(sha_of "$ws/uncommitted-edit.txt")" = "$edit_sha_before" ] || a2=1
  report 2 "$a2" "$k" "$mode"; fails=$((fails + a2))
  # 断言 3：无重复副作用——效应总行数 = 5 且 step 键无重复
  local a3=0 total uniq
  total="$(wc -l < "$ws/effects.log" | tr -d ' ')"
  uniq="$(sort -u "$ws/effects.log" | wc -l | tr -d ' ')"
  { [ "$total" -eq "$NSTEPS" ] && [ "$uniq" -eq "$NSTEPS" ]; } || a3=1
  report 3 "$a3" "$k" "$mode"; fails=$((fails + a3))
  # 断言 4：Gate 证据完整——全部 step 证据在盘，且已完成集哈希与恢复前快照一致
  local a4=0 si ss
  for i in 1 2 3 4 5; do [ -f "$ws/evidence/step-$i.md" ] || a4=1; done
  while read -r si ss; do
    [ "$(sha_of "$ws/evidence/step-$si.md")" = "$ss" ] || a4=1
  done < "$snap"
  report 4 "$a4" "$k" "$mode"; fails=$((fails + a4))
  # 断言 5：step_id 不变
  local a5=0; [ "$(sed -n 's/^step_id: //p' "$ws/ledger.txt")" = "$id_before" ] || a5=1
  report 5 "$a5" "$k" "$mode"; fails=$((fails + a5))
  rm -rf "$ws"
  [ "$fails" -eq 0 ]
}

report() { # report <n> <failflag> <k> <mode>
  if [ "$2" -eq 0 ]; then printf 'ASSERT %s PASS (k=%s %s)\n' "$1" "$3" "$4";
  else printf 'ASSERT %s FAIL (k=%s %s)\n' "$1" "$3" "$4"; fi
}

MODE="${1:-run}"
case "$MODE" in
  run)
    ok=0
    for k in 2 4; do run_scenario "$k" good || ok=1; done
    exit "$ok"
    ;;
  selftest)
    ok=0
    for k in 2 4; do
      if run_scenario "$k" good; then :; else echo "SELFTEST FAIL: good path must pass (k=$k)"; ok=1; fi
      out="$(run_scenario "$k" bad)"; rc=$?
      printf '%s\n' "$out"
      if [ "$rc" -eq 0 ]; then echo "SELFTEST FAIL: bad path must not pass (k=$k)"; ok=1; fi
      printf '%s' "$out" | grep -q "ASSERT 1 FAIL" || { echo "SELFTEST FAIL: bad path must fail assert 1 (k=$k)"; ok=1; }
      printf '%s' "$out" | grep -q "ASSERT 3 FAIL" || { echo "SELFTEST FAIL: bad path must fail assert 3 (k=$k)"; ok=1; }
    done
    [ "$ok" -eq 0 ] && echo "SELFTEST PASS"
    exit "$ok"
    ;;
  *) echo "usage: interrupt-resume-check.sh [run|selftest]" >&2; exit 2 ;;
esac
