#!/usr/bin/env python3
# 断言式精确替换 — TASK-20260805-P1a-fix（等价于 Edit 语义：每处 old 恰好 1 次，缺/多即失败）
# 因 Edit 分类器临时不可用，改用本脚本执行；替换内容与 HANDOFF §4 逐字一致。
import sys

SKILLS = [".claude/skills/alex-lite/SKILL.md", ".claude/skills/blake-lite/SKILL.md"]

C1_OLD = "- RETIRED              已删除该约束（追加行，不擦除原行）"
C1_NEW = "- RETIRED              已删除该约束（原行状态列就地转移为本值；处置理由另追加一行）"

C2_OLD = """  awk -v t="$(date +%F)" '/review-by/ {
    if (match($0, /review-by [0-9-]+/)) {
      d = substr($0, RSTART+10, 10); if (d < t) print "OVERDUE: " $0 } }' \\
    .tad/evidence/audits/lite-constraint-ledger.md

（此处 awk 只比较 ISO 日期，纯 ASCII，不受本机 awk 的中文比较缺陷影响——勿改成别的写法。）"""

C2_NEW = """  awk -v t="$(date +%F)" '/[Pp][Rr][Oo][Vv][Ii][Ss][Ii][Oo][Nn][Aa][Ll][:：]?/ {
    if (match($0, /PROVISIONAL: review-by [0-9]{4}-[0-9]{2}-[0-9]{2}[[:space:]]*\\|?[[:space:]]*$/)) {
      d = substr($0, RSTART+23, 10); if (d < t) print "OVERDUE: " $0 }
    else print "MALFORMED(须人工处置): " $0 }' \\
    .tad/evidence/audits/lite-constraint-ledger.md

（前置过滤大小写不敏感且容忍全/半角冒号：else 逃逸检测只兜住"进了过滤器后解析失败"的行，
被前置过滤滤掉的行根本到不了它——全角冒号在中文台账里是最可能的手滑。
主正则只匹配半角 PROVISIONAL: 前缀：摘要列写到 review-by 字样不假阳性，转终态后自然静默。
else 分支显式报 MALFORMED 不静默丢弃——假阴性比假阳性坏得多。
前置过滤刻意不加 || /review-by/：那会把摘要含该字样的合法行变噪音，等于请回假阳性。
状态列须为末列；正则容忍缺尾管道与尾随 TAB。正则须字面量内联，经 -v 传入会丢转义。
需 awk 支持 ERE interval 量词 {n}（macOS 2021+ / gawk / mawk 均可）；不支持时全部行报
MALFORMED——吵而不静默，方向正确但下游会误以为台账全坏。
awk 只比较 ISO 日期，纯 ASCII；中文只经 print 不参与比较——勿改成别的写法。）"""

C3_OLD = """扫描结果（有/无超期）随该次追加一并写进备注列或 Completion——
否则事后无法区分"扫过、确认无超期"与"根本没扫直接追加"。"""

C3_NEW = """扫描结果（有/无超期）随该次追加一并写进 Completion——
否则事后无法区分"扫过、确认无超期"与"根本没扫直接追加"。
台账列序固定：状态列恒为末列，不得在其后新增列（扫描锚点依赖此不变量；
确需备注列须加在状态列之前）。"""

C4_OLD = "台账自身的增长豁免于本节纪律——append-only 是为审计可追溯，不得以\"清理台账\"擦除历史行。"
C4_NEW = """台账自身的增长豁免于本节纪律。可追溯性保在两处：理由三格（每单成本 / 挡什么失败模式 /
载体路径）一经写下不再改；处置时另追加一行并把原期限带进去
（**只写日期，不要重复 PROVISIONAL 字样——会触发 MALFORMED 误报**）。
状态列允许就地转移，但**仅限转为终态（HAS-CARRIER / NO-CARRIER / SUPERSEDED / RETIRED）**
——不转移会让已处置的行永远被报超期（僵旗）；`N/A` 与再发 PROVISIONAL 均不是终态，不得由此转入。
改判 HAS-CARRIER / SUPERSEDED 时，新载体写进追加的处置行，不改原行的载体路径格。
不得以\"清理台账\"删除历史行。"""

C5_OLD = "必须附可 grep 验证的新增载体，否则一律执行 RETIRED。"
C5_NEW = """必须附可 grep 验证的新增载体，否则一律执行 RETIRED。
禁止静默续期：不得就地把 review-by 改成更晚的日期——展期必须新起一行并写明理由，
使"又拖了一次"在台账上可见。"""

LEDGER = ".tad/evidence/audits/lite-constraint-ledger.md"
L_OLD = "> append-only：删除约束也追加 RETIRED 行，不擦除历史行。"
L_NEW = "> append-only：不删除历史行。状态列可就地转移为终态；处置理由另追加一行并带上原期限。"

CHANGES = [C1_OLD, C2_OLD, C3_OLD, C4_OLD, C5_OLD]

def apply(path, old, new, label):
    with open(path, encoding="utf-8") as f:
        content = f.read()
    n = content.count(old)
    if n != 1:
        print(f"ABORT {label} in {path}: 命中 {n} 次（期望恰好 1 次）")
        sys.exit(1)
    with open(path, "w", encoding="utf-8") as f:
        f.write(content.replace(old, new))
    print(f"ok {label} -> {path}")

for sk in SKILLS:
    for i, old in enumerate(CHANGES, 1):
        apply(sk, old, [C1_NEW, C2_NEW, C3_NEW, C4_NEW, C5_NEW][i - 1], f"改动{i}")

apply(LEDGER, L_OLD, L_NEW, "改动6")
print("全部替换完成")
