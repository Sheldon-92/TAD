#!/usr/bin/env bash
# P7 verify.sh（rev5 新增）—— AC1 / AC3 / AC4 / AC10 / AC13 的**冻结判定器**。
#
# Gate 2 第四轮 P1-6：12 条 AC 里只有 3 条有冻结执行体，其余由**被审查方自己写判定脚本**。
# 而 rev3 把承重移到 AC1 —— 恰好是没有判定器的那一类。前三轮 23 个 P0 的共同签名是
# 「AC 全绿纪律已死」；判定器作者就是被判定方时，这个签名必然重现。
# → AC1/AC3/AC4/AC10/AC13 的判定器由 Alex 写、随契约 commit、受 AC12 哈希保护。
#
# 用法：bash verify.sh <AC编号|all>
#   AC3 需要 Blake 落盘的可达性记录：$EV/reachability.tsv（每行首字段 = 被搬走的约束行原文）
set -uo pipefail
DONE=0; trap '[ "$DONE" = 1 ] || { echo "RESULT=FAIL (verify.sh 中途退出)"; exit 1; }' EXIT
R="/Users/sheldonzhao/01-on progress programs/TAD"
EV="$R/.tad/evidence/acceptance-tests/lazy-by-floor"
HB="$R/.tad/active/handoffs/HANDOFF-20260818-lazy-by-floor"
T0=$(LC_ALL=C cat "$EV/t0.txt" 2>/dev/null || echo "")
WHAT="${1:-all}"; ERR=0
fail(){ echo "  !! $*"; ERR=$((ERR+1)); }
ok(){ echo "  ok $*"; }

# §6 写权限白名单（编号即全集；AC10 用）
ALLOW='^(\.tad/discipline-floor-budget\.md|\.claude/skills/alex/|\.agents/skills/alex/|\.tad/evidence/acceptance-tests/lazy-by-floor/|\.tad/archive/handoffs/COMPLETION-20260818-lazy-by-floor\.md|\.tad/active/epics/EPIC-20260813-alex-blake-lightening\.md|\.tad/evidence/(traces|decisions)/[^/]*\.jsonl)'

ac1(){ echo "== AC1 义务型祈使句常驻（承重）"
  bash "$HB.resident.sh" > "$EV/.rs" || { fail "resident.sh 报错"; return; }
  : > "$EV/ac1-hits.tsv"; local miss=0 n=0
  while IFS=$'\t' read -r name kind sent; do
    [ "$kind" = "义务" ] || continue; n=$((n+1))
    local found=""
    while IFS= read -r f; do
      [ -n "$f" ] || continue
      local ln; ln=$(LC_ALL=C command grep -nF -e "$sent" "$R/$f" 2>/dev/null | LC_ALL=C head -1 | LC_ALL=C cut -d: -f1)
      [ -n "$ln" ] && { found="${f}:${ln}"; break; }
    done < "$EV/.rs"
    if [ -n "$found" ]; then printf '%s\t%s\n' "$name" "$found" >> "$EV/ac1-hits.tsv"
    else printf '%s\tMISS\n' "$name" >> "$EV/ac1-hits.tsv"; miss=$((miss+1)); fi
  done < <(LC_ALL=C awk -F'\t' '!/^#/ && NF>=3{print $1"\t"$2"\t"$3}' "$HB.obligations.tsv")
  rm -f "$EV/.rs"
  [ "$miss" -eq 0 ] && ok "29 条义务祈使句全部在常驻层命中（$n 条已查）" \
                    || fail "AC1: ${miss}/${n} 条义务祈使句在常驻层缺失（见 ac1-hits.tsv）"
}

ac3(){ echo "== AC3 约束行集有分母"
  bash "$HB.step0.sh" --constraint-set > "$EV/.now" || { fail "--constraint-set 报错"; return; }
  LC_ALL=C comm -23 "$EV/constraint-lines-base.txt" "$EV/.now" > "$EV/.gone"; rm -f "$EV/.now"
  local g; g=$(command grep -c . "$EV/.gone" || true)
  if [ "${g:-0}" -eq 0 ]; then ok "无约束行离开分母，无需记录"; rm -f "$EV/.gone"; return; fi
  [ -f "$EV/reachability.tsv" ] || { fail "AC3: ${g} 行离开分母但没有 reachability.tsv"; return; }
  local bad=0
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    local c; c=$(LC_ALL=C command grep -cF -e "$line" "$EV/reachability.tsv" || true)
    [ "${c:-0}" -eq 1 ] || { fail "记录中出现 ${c} 次（须恰好 1）：$(printf '%s' "$line" | LC_ALL=C cut -c1-50)…"; bad=$((bad+1)); }
  done < "$EV/.gone"
  [ "$bad" -eq 0 ] && ok "${g} 行离开分母，均有且仅有 1 条可达性记录"
  rm -f "$EV/.gone"
}

ac4(){ echo "== AC4 地板护栏（块级）"
  [ -n "$T0" ] || { fail "无 t0.txt"; return; }
  # (a) blocks.tsv 常驻=是：块内行集**只增不减** → comm -23 <T0块> <现块> 必须为空
  local a=0
  while IFS=$'\t' read -r name res sa ea; do
    [ "$res" = "是" ] || continue
    local carrier; carrier=$(LC_ALL=C awk -F'\t' -v k="$name" '$1==k{print $2; exit}' "$EV/floor-anchors.tsv")
    [ -n "$carrier" ] || carrier=$(LC_ALL=C awk -F'\t' -v k="$name" '!/^#/ && $1==k{print $5; exit}' "$HB.blocks.tsv")
    [ -n "$carrier" ] || { fail "[$name] 无法确定载体"; a=$((a+1)); continue; }
    extract(){ LC_ALL=C awk -v s="$1" -v e="$2" 'index($0,s)==1&&length($0)==length(s){f=1} f{print} f&&e!="<EOF>"&&NR>1&&index($0,e)==1&&length($0)==length(e){exit}' ; }
    local t0b nowb
    t0b=$(git -C "$R" show "${T0}:${carrier}" 2>/dev/null | LC_ALL=C awk -v sa="$sa" -v ea="$ea" '
      $0==sa{f=1} f&&$0==ea&&NR>1{exit} f{print}' | LC_ALL=C sort -u)
    nowb=$(LC_ALL=C awk -v sa="$sa" -v ea="$ea" '$0==sa{f=1} f&&$0==ea&&NR>1{exit} f{print}' "$R/$carrier" | LC_ALL=C sort -u)
    local lost; lost=$(LC_ALL=C comm -23 <(printf '%s\n' "$t0b") <(printf '%s\n' "$nowb") | command grep -c . || true)
    [ "${lost:-0}" -eq 0 ] || { fail "[$name] 块内丢失 ${lost} 行（允许新增，禁止删除）"; a=$((a+1)); }
  done < <(LC_ALL=C awk -F'\t' '!/^#/ && NF>=4{print $1"\t"$2"\t"$3"\t"$4}' "$HB.blocks.tsv")
  [ "$a" -eq 0 ] && ok "(a) 常驻块内行集只增不减"
  # (b) 非常驻载体 + AGENTS.md 逐字未变
  local b=0
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    git -C "$R" diff --quiet "$T0" -- "$f" || { fail "(b) $f 相对 T0 已变"; b=$((b+1)); }
  done < <({ LC_ALL=C awk -F'\t' 'NF>=2{print $2}' "$EV/floor-anchors.tsv"; echo "AGENTS.md"; } \
           | LC_ALL=C command grep -vE '^(\.claude/skills/alex/|\.tad/config-workflow\.yaml)' | LC_ALL=C sort -u)
  [ "$b" -eq 0 ] && ok "(b) gate/blake/blake-lite/AGENTS.md 逐字未变"
}

ac10(){ echo "== AC10 围栏"
  [ -n "$T0" ] || { fail "无 t0.txt"; return; }
  { git -C "$R" -c core.quotePath=false diff --name-only "$T0" -- .; \
    git -C "$R" -c core.quotePath=false ls-files --others --exclude-standard; } \
    | LC_ALL=C sort -u > "$EV/.chg"
  local out; out=$(LC_ALL=C command grep -vE "$ALLOW" "$EV/.chg" | LC_ALL=C command grep -vxF -f "$EV/fence-baseline.txt" || true)
  rm -f "$EV/.chg"
  [ -z "$out" ] && ok "改动集全在 §6 白名单内" || { fail "越界改动："; printf '%s\n' "$out" | LC_ALL=C sed 's/^/     /'; }
}

ac13(){ echo "== AC13 skill-body-verify（仓库既有的 body/reference 边界门）"
  local o; o=$(bash "$R/.tad/hooks/lib/skill-body-verify.sh" 2>&1) || true
  printf '%s\n' "$o" | LC_ALL=C command grep -q 'ALL CHECKS PASSED' \
    && ok "skill-body-verify 全绿" \
    || { fail "skill-body-verify 未通过："; printf '%s\n' "$o" | LC_ALL=C command grep -E 'FAIL|MISSING' | LC_ALL=C head -8 | LC_ALL=C sed 's/^/     /'; }
}

acref(){ echo "== §6.2 references 强制行只增不减（rev5：此前 0 覆盖的高危写面）"
  local bad=0
  while IFS=$'\t' read -r f n0; do
    [ -n "$f" ] || continue
    if [ ! -f "$R/$f" ]; then fail "reference 文件被删：$f"; bad=$((bad+1)); continue; fi
    local n1; n1=$(LC_ALL=C command grep -ciE 'MUST|MANDATORY|VIOLATION|BLOCKING|forbidden|NEVER|不得|必须|禁止' "$R/$f" || true)
    [ "${n1:-0}" -ge "${n0:-0}" ] || { fail "$f 强制行 ${n0} → ${n1}"; bad=$((bad+1)); }
  done < "$EV/references-constraint-base.tsv"
  [ "$bad" -eq 0 ] && ok "references/** 强制行数无一减少"
}

case "$WHAT" in
  AC1) ac1;; AC3) ac3;; AC4) ac4;; AC10) ac10;; AC13) ac13;; REF) acref;;
  all) ac1; ac3; ac4; ac10; ac13; acref;;
  *) echo "用法：bash verify.sh [AC1|AC3|AC4|AC10|AC13|all]"; exit 2;;
esac
DONE=1; trap - EXIT
[ "$ERR" -eq 0 ] && echo "RESULT=PASS" || { echo "RESULT=FAIL (${ERR} 项)"; exit 1; }
