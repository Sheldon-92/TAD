#!/usr/bin/env bash
# AC11 五份负控（逐条单独跑，任一绿 = 该 AC 永真 → 停下退回 Alex）
set -uo pipefail
R="$(git rev-parse --show-toplevel)"
EV="$R/.tad/evidence/acceptance-tests/lazy-by-floor"
HB="$R/.tad/active/handoffs/HANDOFF-20260818-lazy-by-floor"
A1="$R/.claude/skills/alex/SKILL.md"; A2="$R/.agents/skills/alex/SKILL.md"
T0=$(cat "$EV/t0.txt"); RED=0; NC="$EV/negative-controls"; mkdir -p "$NC"
OK(){ echo "NC OK: $1"; }; BAD(){ echo "NC FAIL: $1"; RED=1; }

# (a) 摘掉一个模块名 → AC2 拦（measure.sh 常驻层双向 comm）
cp "$A1" "$NC/nc-a.bak"
LC_ALL=C sed -i '' 's/config-quality/config-qualitx/' "$A1"
if bash "$HB.measure.sh" X > "$NC/nc-a-measure.log" 2>&1 && LC_ALL=C command grep -q 'RESULT=PASS' "$NC/nc-a-measure.log"; then BAD "AC2 未拦模块摘除（绿=永真）"
else OK "AC2 模块摘除 (red via measure.sh)"; fi
cp "$NC/nc-a.bak" "$A1"; cmp -s "$A1" "$NC/nc-a.bak" || { echo "FATAL: (a) 恢复失败"; exit 2; }

# (b) 搬走一条约束（分母=constraint-lines-base.txt 内的行）不写记录 → AC3 拦
cp "$A1" "$NC/nc-b.bak"
python3 - <<'PY2'
import io
import subprocess as _sp
R = _sp.run(["git","rev-parse","--show-toplevel"],capture_output=True,text=True).stdout.strip()
EV = f"{R}/.tad/evidence/acceptance-tests/lazy-by-floor"
A1 = f"{R}/.claude/skills/alex/SKILL.md"
base = io.open(f"{EV}/constraint-lines-base.txt", encoding="utf-8").read().split("\n")
target = next(l for l in base if l and ".tad/config-workflow" not in l)
s = io.open(A1, encoding="utf-8").read()
assert s.count(target) == 1, f"target count {s.count(target)}: {target!r}"
io.open(A1, "w", encoding="utf-8").write(s.replace(target, ""))
print("removed:", target[:60])
PY2
if bash "$HB.verify.sh" AC3 > "$NC/nc-b-verify.log" 2>&1 && LC_ALL=C command grep -q 'RESULT=PASS' "$NC/nc-b-verify.log"; then BAD "AC3 未拦约束搬移（绿=永真）"
else OK "AC3 约束搬移 (red via verify AC3)"; fi
cp "$NC/nc-b.bak" "$A1"; cmp -s "$A1" "$NC/nc-b.bak" || { echo "FATAL: (b) 恢复失败"; exit 2; }

# (c) 删空 Forbidden 块内条目但留注释锚点 → AC4(a) 拦
cp "$A1" "$NC/nc-c.bak"
python3 - <<'PY'
import io
p = R + "/.claude/skills/alex/SKILL.md"
s = io.open(p, encoding="utf-8").read()
start = s.index("# Forbidden actions (will trigger VIOLATION)")
end = s.index("# Triple-Question KA: Draft-then-Confirm Rule (2026-06-03)")
seg = s[start:end]
keep = "\n".join(l for l in seg.split("\n") if l.startswith("#") or not l.strip())
s = s[:start] + keep + "\n" + s[end:]
io.open(p, "w", encoding="utf-8").write(s)
PY
if bash "$HB.verify.sh" AC4 > "$NC/nc-c-verify.log" 2>&1 && LC_ALL=C command grep -q 'RESULT=PASS' "$NC/nc-c-verify.log"; then BAD "AC4 未拦 Forbidden 清空（绿=永真）"
else OK "AC4 Forbidden 清空 (red via verify AC4)"; fi
cp "$NC/nc-c.bak" "$A1"; cmp -s "$A1" "$NC/nc-c.bak" || { echo "FATAL: (c) 恢复失败"; exit 2; }

# (d) 外置 fatal_operations: → AC5 拦（git diff --quiet T0）
cp "$R/.tad/config-cognitive.yaml" "$NC/nc-d.bak"
python3 - <<'PY'
import io
p = R + "/.tad/config-cognitive.yaml"
s = io.open(p, encoding="utf-8").read()
i = s.index("fatal_operations:")
seg_end = s.index("\n", s.index("\n", i) + 40) if "\n\n" in s[i:] else len(s)
s = s[:i] + "fatal_operations: []\n# 外置测试" + s[seg_end:]
io.open(p, "w", encoding="utf-8").write(s)
PY
if git -C "$R" diff --quiet "$T0" -- .tad/config-cognitive.yaml .tad/config-execution.yaml; then BAD "AC5 未拦 fatal_operations 外置（绿=永真）"
else OK "AC5 fatal_operations 外置 (red via git diff)"; fi
cp "$NC/nc-d.bak" "$R/.tad/config-cognitive.yaml"; git diff --quiet "$T0" -- .tad/config-cognitive.yaml .tad/config-execution.yaml || { echo "FATAL: (d) 恢复失败"; exit 2; }

# (e) 29 条祈使句写进新建 alex/OBLIGATIONS.md、从 SKILL.md 移除 → AC1 保持红
cp "$A1" "$NC/nc-e.bak"; cp "$A2" "$NC/nc-e.bak2"
python3 - <<'PY'
import io
import subprocess as _sp
R = _sp.run(["git","rev-parse","--show-toplevel"],capture_output=True,text=True).stdout.strip()
ob = f"{R}/.tad/active/handoffs/HANDOFF-20260818-lazy-by-floor.obligations.tsv"
sents = [l.rstrip("\n").split("\t")[2] for l in io.open(ob, encoding="utf-8")
         if l.strip() and not l.startswith("#") and l.split("\t")[1] == "义务"]
out = "# OBLIGATIONS（负控 (e)：不在 resident.sh 输出 = 不在常驻层）\n\n" + "\n".join(sents) + "\n"
io.open(f"{R}/.claude/skills/alex/OBLIGATIONS.md", "w", encoding="utf-8").write(out)
io.open(f"{R}/.agents/skills/alex/OBLIGATIONS.md", "w", encoding="utf-8").write(out)
for p in (f"{R}/.claude/skills/alex/SKILL.md", f"{R}/.agents/skills/alex/SKILL.md"):
    s = io.open(p, encoding="utf-8").read()
    start = s.index("## ⚠️ 义务型祈使句")
    end = s.index("## ", start + 1) if "## " in s[start+1:] else len(s)
    s = s[:start] + s[end:]
    io.open(p, "w", encoding="utf-8").write(s)
PY
if bash "$HB.verify.sh" AC1 > "$NC/nc-e-verify.log" 2>&1 && LC_ALL=C command grep -q 'RESULT=PASS' "$NC/nc-e-verify.log"; then BAD "AC1 未拦 OBLIGATIONS.md 路径（绿=永真）"
else OK "AC1 OBLIGATIONS.md 新文件 (red via AC1)"; fi
rm -f "$R/.claude/skills/alex/OBLIGATIONS.md" "$R/.agents/skills/alex/OBLIGATIONS.md"
cp "$NC/nc-e.bak" "$A1"; cp "$NC/nc-e.bak2" "$A2"
cmp -s "$A1" "$NC/nc-e.bak" && cmp -s "$A2" "$NC/nc-e.bak2" || { echo "FATAL: (e) 恢复失败"; exit 2; }

[ "$RED" -eq 0 ] && echo "ALL NEGATIVE CONTROLS RED — OK" || { echo "NEGATIVE CONTROL FAILURES PRESENT"; exit 1; }
