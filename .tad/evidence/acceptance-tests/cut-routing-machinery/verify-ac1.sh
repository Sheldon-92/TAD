#!/bin/zsh
# Post-impl AC1/AC1b verification (contract HANDOFF-20260805-cut-routing-machinery.md §4)
cd "$(git rev-parse --show-toplevel)" || exit 1
OUT=.tad/evidence/acceptance-tests/cut-routing-machinery/post-impl-output.txt
{
echo "===== 实现后 AC1-AC5 $(date -u +%FT%TZ) ====="
echo
echo "--- AC1 ---"
python3 - <<'PY'
import hashlib, sys
A="Route Contract（Lite / Standard / Full 三层路由）"
CASES=[
 (".claude/skills/alex-lite/SKILL.md", True,
  {A,"执行脊柱","Scope / Risk Router（影响范围与风险）","Forbidden"},
  178, "13b0b87bb2412d81244979c47dc202a1"),
 (".claude/skills/blake-lite/SKILL.md", False,
  {A,"L0 读契约 + 准入（⚠️ BLOCKING）",
   "L0.5 契约审查复查（所有 LITE 单 ⚠️ BLOCKING）",
   "L3 独立审查（⚠️ MANDATORY——express 教训：小改不等于免审，2026-04-14 一次 15 分钟小改被审出 4 个 P0。此步不可以任何理由跳过）",
   "Scope / Risk Router（影响范围与风险）",
   "L4 Completion（append 到 LITE handoff 文件末尾）","Forbidden"},
  251, "0afa760c84d60bbbf5b018efd749cd5b"),
]
fail=0
for f, sf, touched, en, eh in CASES:
    out=[];cur=None;front=True
    for l in open(f).read().split("\n"):
        if l.startswith("## "): cur=l[3:].strip(); front=False
        if front and sf: continue
        if cur is None or cur not in touched: out.append(l)
    h=hashlib.md5("\n".join(out).encode()).hexdigest(); ok=(len(out)==en and h==eh)
    print(f"  {'OK  ' if ok else 'FAIL'} {f}  {len(out)}行(期望{en}) {h}")
    if not ok: print(f"       期望 {eh}"); fail=1
sys.exit(fail)
PY
[ $? -eq 0 ] && echo "AC1 PASS" || echo "AC1 FAIL"
echo
echo "--- AC1b ---"
python3 - <<'PY'
import hashlib,sys
fail=0
L=open("AGENTS.md").read().split("\n"); out=[];skip=False
for l in L:
    if l.startswith("## Lite / Standard / Full Routing"): skip=True; continue
    if skip and l.startswith("## "): skip=False
    if not skip: out.append(l)
h=hashlib.md5("\n".join(out).encode()).hexdigest()
ok=(len(out)==135 and h=="9862c78301ed4e7d170f036a259e1462")
print(f"  {'OK  ' if ok else 'FAIL'} AGENTS.md 非路由节 {len(out)}行(期望135) {h}")
if not ok: fail=1
L=open("INSTALLATION_GUIDE.md").read().split("\n"); out=[];skip=False
for l in L:
    if l.startswith("## Lite / Standard / Full 路由"): skip=True; continue
    if skip and l.startswith("## "): skip=False
    if not skip: out.append(l)
h=hashlib.md5("\n".join(out).encode()).hexdigest()
ok=(len(out)==140 and h=="f9b8bd543cee31341bc041cd524159b1")
print(f"  {'OK  ' if ok else 'FAIL'} INSTALLATION_GUIDE.md 非路由节 {len(out)}行(期望140) {h}")
if not ok: fail=1
EXC={
 "### 2.5 Lite 通道（用户显式选择，Alex 不自动推荐）",
 "### 2.5 Lite 通道（默认通道）",
 "`/alex-lite` → `/blake-lite`：≤5 文件、非协议契约的小任务，或额度紧张时。契约文件 `LITE-*.md`。",
 "`/alex-lite` → `/blake-lite`：**默认通道**。文件数、协议密度、是否触及协议契约均不构成升级理由；仅命中 lite skill 内的「安全停清单」时停下来问人。契约文件 `LITE-*.md`。",
}
out=[l for l in open("CLAUDE.md").read().split("\n") if l not in EXC]
h=hashlib.md5("\n".join(out).encode()).hexdigest()
ok=(len(out)==109 and h=="c358c0c0c0bcd49602b43509c77f91c6")
print(f"  {'OK  ' if ok else 'FAIL'} CLAUDE.md 除 §2.5 标题+首行 {len(out)}行(期望109) {h}")
if not ok: fail=1
TH_DROP_MARK=("- **Lite / Standard / Full routing profiles**",
              "- **Shared route contract**",
              "- **Independent depth selection**")
TH_SUB_MARK=("- **No automatic ceremony escalation**", "- **Lite channel basics (since v2.35)**")
for f in (".claude/skills/tad-help/SKILL.md",".agents/skills/tad-help/SKILL.md"):
    out=[l for l in open(f).read().split("\n")
         if not l.startswith(TH_DROP_MARK) and not l.startswith(TH_SUB_MARK)]
    h=hashlib.md5("\n".join(out).encode()).hexdigest()
    ok=(len(out)==231 and h=="dfd2ba7abd2c8a002132da9dc28218f1")
    print(f"  {'OK  ' if ok else 'FAIL'} {f} 除 5 行 {len(out)}行(期望231) {h}")
    if not ok: fail=1
sys.exit(fail)
PY
[ $? -eq 0 ] && echo "AC1b PASS" || echo "AC1b FAIL"
} > "$OUT" 2>&1
cat "$OUT"
