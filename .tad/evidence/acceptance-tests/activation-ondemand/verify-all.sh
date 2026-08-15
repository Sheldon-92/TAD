#!/usr/bin/env bash
# P3 verify-all —— AC1-AC10（AC11 负控在 negative-controls/run.sh）
# AC 红 = exit != 0 且末行 RESULT=FAIL；TAB 分隔，禁 #/:/ 切分
set -uo pipefail
R="$(git rev-parse --show-toplevel)"
EV="$R/.tad/evidence/acceptance-tests/activation-ondemand"
HB=".tad/active/handoffs/HANDOFF-20260817-activation-ondemand"
A1="$R/.claude/skills/alex/SKILL.md"; A2="$R/.agents/skills/alex/SKILL.md"
T0=$(cat "$EV/t0.txt")
PASS=0; FAIL=0; DONE=0
ac_pass(){ PASS=$((PASS+1)); echo "  AC OK: $1"; }
ac_fail(){ FAIL=$((FAIL+1)); echo "  AC FAIL: $1"; }
trap 'DONE=1' EXIT

echo "== AC1: pins 7 条 OLD=0 / NEW=1（两文件，grep -cFx 字面）"
for f in "$A1" "$A2"; do
  while IFS=$'\t' read -r id old new; do
    [ -n "${id:-}" ] || continue
    co=$(LC_ALL=C command grep -cFx -e "$old" "$f" || true)
    cn=$(LC_ALL=C command grep -cFx -e "$new" "$f" || true)
    if [ "$co" -ne 0 ] || [ "$cn" -ne 1 ]; then ac_fail "AC1 ${f} pin ${id} old=${co} new=${cn}"; fi
  done < "$R/$HB.pins.tsv"
done
ac_pass "AC1"

echo "== AC2: 冻结补集（两文件，diff 过滤残余 0 行）"
for f in .claude/skills/alex/SKILL.md .agents/skills/alex/SKILL.md; do
  rem=$(diff <(git -C "$R" show "${T0}:${f}") "$R/$f" \
    | LC_ALL=C command grep -vE '^[0-9]+(,[0-9]+)?[acd][0-9]+(,[0-9]+)?$' \
    | LC_ALL=C command grep -vx -e '---' \
    | LC_ALL=C sed -e 's/^< //' -e 's/^> //' \
    | LC_ALL=C command grep -vxF -f "$EV/olds.txt" \
    | LC_ALL=C command grep -vxF -f "$EV/news.txt" || true)
  if [ -n "$rem" ]; then ac_fail "AC2 ${f} 残余 ${#rem} 行"; printf '%s\n' "$rem" | head -5; else ac_pass "AC2 ${f}"; fi
done

echo "== AC3: session-state 逐字行仍在（两文件）"
SS="Read .tad/active/session-state.md (if exists)."
for f in "$A1" "$A2"; do
  n=$(LC_ALL=C command grep -cF -e "$SS" "$f" || true)
  [ "$n" -ge 1 ] || ac_fail "AC3 ${f} (count ${n})"
done
ac_pass "AC3"

echo "== AC4: 行为负控（注入 GHSA-FAKE → adv=YES；改回 → adv=none）"
NC="$EV/negative-controls"
cp "$R/.tad/dependencies/scan-results.yaml" "$NC/scan-results.yaml.bak"
CMD2=$(LC_ALL=C command grep -F 'scan-results.yaml' "$R/$HB.pins.tsv" | head -1 | LC_ALL=C cut -f3)
CMD2=$(printf '%s' "$CMD2" | LC_ALL=C sed -n 's/.*`\(.*\)`.*/\1/p')
CMD2=$(printf '%s' "$CMD2" | LC_ALL=C sed -e "s|\.tad/dependencies/scan-results\.yaml|'${NC}/scan-results-injected.yaml'|")
INJ="$NC/scan-results-injected.yaml"
cp "$R/.tad/dependencies/scan-results.yaml" "$INJ"
python3 - "$INJ" <<'PY'
import sys
p = sys.argv[1]
lines = open(p, encoding="utf-8").read().split("\n")
out = []; in_gh = False; done = False
for i, l in enumerate(lines):
    out.append(l)
    if l.strip() == "- dependency: gh": in_gh = True
    if in_gh and not done and l.startswith("    security_advisories: []"):
        out[-1] = "    security_advisories:"
        out.append('      - id: "GHSA-FAKE-0001"')
        done = True
open(p, "w", encoding="utf-8").write("\n".join(out))
assert done, "gh advisory line not found"
PY
diff "$R/.tad/dependencies/scan-results.yaml" "$INJ" > "$NC/ac4-inject-diff.txt" || true
(cd "$R" && eval "${CMD2}") > "$NC/ac4-inject-out.txt" 2>&1
LC_ALL=C command grep -q 'adv=YES' "$NC/ac4-inject-out.txt" || ac_fail "AC4 注入后应 adv=YES"
python3 - "$INJ" <<'PY'
import sys
p = sys.argv[1]
s = open(p, encoding="utf-8").read()
s = s.replace("    security_advisories:\n      - id: \"GHSA-FAKE-0001\"", "    security_advisories: []")
open(p, "w", encoding="utf-8").write(s)
assert "GHSA-FAKE-0001" not in s
PY
(cd "$R" && eval "${CMD2}") > "$NC/ac4-restore-out.txt" 2>&1
LC_ALL=C command grep -q 'adv=none' "$NC/ac4-restore-out.txt" || ac_fail "AC4 改回后应 adv=none"
rm -f "$INJ"
ac_pass "AC4"

echo "== AC5: 纪律不流失（五类计数 == Step 0 基线）"
for k in MUST MANDATORY VIOLATION forbidden 不得; do
  for f in .claude/skills/alex/SKILL.md .agents/skills/alex/SKILL.md; do
    want=$(LC_ALL=C command grep -F "${f}|${k}|" "$EV/discipline-baseline.txt" | head -1 | LC_ALL=C cut -d'|' -f3)
    got=$(LC_ALL=C command grep -cF -e "$k" "$R/$f" || true)
    [ "$got" = "${want:-x}" ] || ac_fail "AC5 ${f} ${k}: baseline=${want} got=${got}"
  done
done
ac_pass "AC5"

echo "== AC6: 逐源断言（rev3 —— 限定激活块，机械取块不硬编码行号，块行数 >=200）"
ACTBLK(){ LC_ALL=C awk '/^activation-instructions:/{f=1;next} /^[a-zA-Z_][a-zA-Z0-9_-]*:$/{if(f)exit} f{print}' "$1"; }
for f in "$A1" "$A2"; do
  lines=$(ACTBLK "$f" | LC_ALL=C command grep -c .)
  [ "${lines:-0}" -ge 200 ] || ac_fail "AC6 ${f} 激活块行数 ${lines} < 200"
  for src in NEXT.md PROJECT_CONTEXT.md \
             .tad/research-notebooks/REGISTRY.yaml .tad/dependencies/scan-results.yaml \
             .tad/dependencies/REGISTRY.yaml OBJECTIVES.md .tad/github-registry/scan-log.yaml ROADMAP.md; do
    n=$(ACTBLK "$f" | LC_ALL=C command grep -cF -e "Read ${src}" || true)
    [ "$n" -eq 0 ] || ac_fail "AC6 ${f} 块内 Read ${src} = ${n}"
  done
done
ac_pass "AC6"

echo "== AC7: 7 条命令可跑（实跑落盘，exit 0 且输出非空）"
mkdir -p "$EV/cmd-runs"; P3DEP="gh"
while IFS=$'\t' read -r id old new; do
  [ -n "${id:-}" ] || continue
  cmd=$(printf '%s' "$new" | LC_ALL=C sed -n 's/.*`\(.*\)`.*/\1/p')
  [ -n "$cmd" ] || { ac_fail "AC7 pin ${id} 无命令"; continue; }
  if [ "$id" = "3" ]; then
    p2out=$(cat "$EV/cmd-runs/2.out")
    P3DEP=$(printf '%s\n' "$p2out" | LC_ALL=C command grep -v '^last_scan:' | LC_ALL=C command grep -m1 -oE '^[^ ]+' || echo gh)
    cmd=$(printf '%s' "$cmd" | LC_ALL=C sed "s|{上一步输出的依赖名}|${P3DEP}|g")
  fi
  (cd "$R" && eval "${cmd}") > "$EV/cmd-runs/${id}.out" 2>&1
  rc=$?
  echo "${rc}" > "$EV/cmd-runs/${id}.rc"
  [ "$rc" -eq 0 ] || ac_fail "AC7 pin ${id} exit ${rc}"
  [ -s "$EV/cmd-runs/${id}.out" ] || ac_fail "AC7 pin ${id} 输出为空"
done < "$R/$HB.pins.tsv"
ac_pass "AC7"

echo "== AC8: parity（cmp -s 两文件）"
cmp -s "$A1" "$A2" && ac_pass "AC8" || ac_fail "AC8"

echo "== AC9: 围栏（改动集 − §5 四项 − Step0 基线 为空）"
{ git -C "$R" -c core.quotePath=false diff --name-only HEAD -- .; \
  git -C "$R" -c core.quotePath=false ls-files --others --exclude-standard; } \
  | LC_ALL=C sort -u > "$EV/fence-current.txt"
extra=$(LC_ALL=C comm -13 "$EV/fence-baseline.txt" "$EV/fence-current.txt" \
  | LC_ALL=C command grep -vxE '(\.claude/skills/alex/SKILL\.md|\.agents/skills/alex/SKILL\.md)' \
  | LC_ALL=C command grep -vx -e '' || true)
extra=$(printf '%s\n' "$extra" | LC_ALL=C command grep -v '^\.tad/evidence/acceptance-tests/activation-ondemand/' || true)
extra=$(printf '%s\n' "$extra" | LC_ALL=C command grep -v '^\.tad/archive/handoffs/COMPLETION-20260817-activation-ondemand\.md$' || true)
if [ -n "$extra" ]; then ac_fail "AC9 越界: $extra"; else ac_pass "AC9"; fi

echo "== AC10: 契约与配套未变（git diff --quiet T0）"
git -C "$R" diff --quiet "${T0}" -- "$HB.md" "$HB.step0.sh" "$HB.pins.tsv" \
  && ac_pass "AC10" || ac_fail "AC10 契约文件被改动"

echo "RESULT=$([ "$FAIL" -eq 0 ] && echo PASS || echo FAIL)"
exit "$FAIL"
