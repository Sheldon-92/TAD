---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: [".claude/skills", ".agents/skills", ".tad/evidence"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)

**From:** Alex | **To:** Blake | **Date:** 2026-08-05
**Task ID:** TASK-20260805-P1a-fix
**Epic:** `.tad/active/epics/EPIC-20260804-lite-as-tad-body.md` — **Phase 1a-fix**（P1b 前置阻塞）
**Handoff Version:** 2.0（Gate2-R1 收敛：0 P0 / 9 P1 / 4 P2 全整合）
**BASE**: `4b29dc263a5368c0b598fc1030f465fc7ebdbc10`

---

## 🔴 Gate 2

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 一节内 5 处文本 + 台账前言 1 处 + 镜像；无脚本、无状态机 |
| Components Specified | ✅ | §4 逐处给出前后原文 |
| Functions Verified | ✅ | 新命令已实测 8 场景（含 3 类假阴性 + 2 类畸形逃逸 + 假阳性回归） |
| Data Flow Mapped | ✅ | 台账表格仍 0 数据行；仅前言 1 行同步 |
| Expert Review (min 2) | ✅ | R1: code-reviewer CONDITIONAL(0P0/6P1) + 对抗 PASS(0P0/3P1)；R2: 两名均 **PASS / 0 P0**。共 12 P1 + 8 P2 全部整合 |

**Gate 2 结果**: ✅ **PASS**
- AC1 的 5 条整行模式与 §4 改动 2 规格块**逐字节相同**（cmp 验证）
- 实现前 AC1 产生 **20 条 FAIL**（每文件 10 条 × 2），判别力成立
- AC4a 期望值**实跑逐字节相同**；旧命令对同探针的命中集不同（判别力成立）
- AC4b `m=0` / AC5 `base=0, n=1` 实跑通过

**Alex 确认**: 设计要素已验证，Blake 可独立据本文档完成实现。

---

## 1. Task Overview

### 1.1 What
修复 P1a「约束准入」节里超期扫描的语义缺陷，并收窄本单引入的新权限。**5 处节内改动 + 1 处台账前言。**

### 1.2 Why
P1a 落地的扫描命令按整行 grep `review-by`，Gate 4 已独立复现两个缺陷：
**僵旗**（append-only 下已处置的行永远被报超期）、**假阳性**（摘要列写到字样即命中）。
Gate 2 审查又实测出**三类静默假阴性**（见 §2.3）——**假阴性比假阳性坏得多**：
假阳性是噪音，假阴性是"扫了等于没扫"，正是本机制立项要防的东西。

### 1.3 不做
- ❌ 不动「约束准入」节以外的任何一行（唯一例外：§4 改动 6 台账前言，AC2 已相应豁免）
- ❌ 不往台账表格写数据行（P1b）
- ❌ 不碰 routing-contract / full skills / hooks / settings / NEXT.md
- ❌ **不新增任何 MUST/BLOCKING**——本单所有条款都是对既有权限的**收窄**或缺陷修复，
  不触发定价闸自身的流程。实现中若发现"还需要加一条"→ 停，报告人。

---

## 2. 关键设计决策

### 2.1 状态列就地转移——**仅限转为终态**（Gate2 P1-5 收窄）

僵旗的根源是"原行永远保持 PROVISIONAL"。修法二选一：
- (a) 扫描端做处置感知 → 需比较**中文键**，而本机 awk 比较中文恒为真（§6.1）→ 脆
- (b) **状态列就地转移** → 扫描只看状态列，零键比较

**选 (b)，但必须收窄。** 审查实测指出：状态格一旦可写，
`PROVISIONAL: review-by 2024` → `PROVISIONAL: review-by 2027` 也成了合法书写，
**台账上不留任何痕迹**，且与"合法转终态"在文件里同形。
旧规则下续期必须新起一行（可见）——**若不收窄，本单等于把"复查默认动作 = 删除"
偷偷改成了"默认续期"**。

故：**就地转移仅限转为终态**（HAS-CARRIER / NO-CARRIER / SUPERSEDED / RETIRED），
**不得就地改写 review-by 期限**；确需展期一律新起一行并附论证；
转移时把原期限带进追加的处置行（实测：`RETIRED（原 review-by 2024-01-01）` 不含
`PROVISIONAL:` 前缀，不会被重新命中）。

### 2.2 一个被连带清除的副作用（如实记录，非缺陷）

旧 bug 让已处置的行持续被报 OVERDUE——**噪音，但也是"这行还没交代清楚"的持续可见信号**。
修好后该信号消失：任何一次就地转移都会让该行永久静默退出扫描视野，
**扫描侧无法区分"诚实处置"与"图省事转个状态"**。
真正拦这个的从来只有纯文本的「反合理化（复查侧）」，其强度新旧约定完全一样（都零机械校验）——
故本单**未新增**洗白漏洞，但**第一次让"跳过配套处置行"零残留信号**。
Blake 须在 Completion 显式承认此项，不得只写"已知残余风险 = 低活跃期触发退化"。

### 2.3 新扫描命令（已实测 8 场景，勿改写）

```
awk -v t="$(date +%F)" '/[Pp][Rr][Oo][Vv][Ii][Ss][Ii][Oo][Nn][Aa][Ll][:：]?/ {
  if (match($0, /PROVISIONAL: review-by [0-9]{4}-[0-9]{2}-[0-9]{2}[[:space:]]*\|?[[:space:]]*$/)) {
    d = substr($0, RSTART+23, 10); if (d < t) print "OVERDUE: " $0 }
  else print "MALFORMED(须人工处置): " $0 }' {台账}
```

四处关键：
- **前置过滤大小写不敏感 + 容忍全/半角冒号**（Gate2-R2 P1-2 实证的**第四类静默漏**：
  `else` 分支只兜住"进了过滤器之后解析失败"的行，**被前置过滤滤掉的行根本到不了它**。
  `PROVISIONAL：`（全角冒号）在中文台账里是最可能的手滑——**这张表其它列全是中文，
  输入法默认全角标点**。已实测多字节全角冒号放进 awk 方括号确实工作）
- **主正则只匹配半角 `PROVISIONAL: ` 前缀** → 摘要列写到 `review-by` 字样不命中（解假阳性）；
  状态转终态后自然静默（解僵旗）
- **`[[:space:]]*\|?[[:space:]]*$`** → 容忍缺尾管道、尾管道后带 TAB
  （原 ` *\| *$` 会静默漏掉这两类）
- **`else` 分支 = 逃逸检测** → 进了过滤器却解析不了的行（状态后多一列、日期非补零、
  全角冒号、缺冒号、大小写异常）**显式报 MALFORMED 而非静默丢弃**。fail-safe：宁可吵，不可静默漏。

⚠️ **前置过滤刻意不加 `|| /review-by/`**：那会把摘要列写到 `review-by` 的合法 HAS-CARRIER 行
变成 MALFORMED——等于把假阳性以噪音形式请回来。**噪音过载也是一种失效。**

**Alex 实测（本机 2026-08-05，13 场景）**：无尾管道/正常/尾管道带 TAB → OVERDUE ✓；
状态后多一列/日期非补零/全角冒号/缺冒号/小写/处置行抄了原状态 → MALFORMED ✓；
未超期/已转终态/摘要含字样/转 N/A → 不报 ✓。

⚠️ 正则必须**字面量内联**写在 awk 程序里。经 `-v re=...` 传入会丢一层转义
（`\|` 退化为交替符），实测报 `illegal primary in regular expression`。

---

## 3. 📚 Project Knowledge（Blake 必读）

| 路径 | 一行含义 |
|---|---|
| `patterns/shell-portability.md` → `macOS /usr/bin/awk Compares Any Two CJK Strings as Equal` | §2.1 选 (b) 而非 (a) 的硬约束 |
| `patterns/ac-verification.md` → `A Fence Needs a Positive Control Too` | AC5 正向对照：修完必须证明真超期仍被抓 |
| `patterns/ac-verification.md` → `A Snapshot-Diff Scope Fence Is Valid Only Inside a Window…` | §5.0 授权集已按此吸收框架产物路径 |
| `patterns/gate-design.md` → `When Implementation Is Byte-Correct and the SPEC Is Wrong…` | 本单即该条目所述的修订单 |

---

## 4. 实现规格（改动 1–5 在两个 skill 内逐字节相同；改动 6 在台账）

### 改动 1 — RETIRED 状态说明
原文：
```
- RETIRED              已删除该约束（追加行，不擦除原行）
```
改为：
```
- RETIRED              已删除该约束（原行状态列就地转移为本值；处置理由另追加一行）
```

### 改动 2 — 扫描命令块（整块替换，含其后括号注释）
原文：
```
  awk -v t="$(date +%F)" '/review-by/ {
    if (match($0, /review-by [0-9-]+/)) {
      d = substr($0, RSTART+10, 10); if (d < t) print "OVERDUE: " $0 } }' \
    .tad/evidence/audits/lite-constraint-ledger.md

（此处 awk 只比较 ISO 日期，纯 ASCII，不受本机 awk 的中文比较缺陷影响——勿改成别的写法。）
```
改为：
```
  awk -v t="$(date +%F)" '/[Pp][Rr][Oo][Vv][Ii][Ss][Ii][Oo][Nn][Aa][Ll][:：]?/ {
    if (match($0, /PROVISIONAL: review-by [0-9]{4}-[0-9]{2}-[0-9]{2}[[:space:]]*\|?[[:space:]]*$/)) {
      d = substr($0, RSTART+23, 10); if (d < t) print "OVERDUE: " $0 }
    else print "MALFORMED(须人工处置): " $0 }' \
    .tad/evidence/audits/lite-constraint-ledger.md

（前置过滤大小写不敏感且容忍全/半角冒号：else 逃逸检测只兜住"进了过滤器后解析失败"的行，
被前置过滤滤掉的行根本到不了它——全角冒号在中文台账里是最可能的手滑。
主正则只匹配半角 PROVISIONAL: 前缀：摘要列写到 review-by 字样不假阳性，转终态后自然静默。
else 分支显式报 MALFORMED 不静默丢弃——假阴性比假阳性坏得多。
前置过滤刻意不加 || /review-by/：那会把摘要含该字样的合法行变噪音，等于请回假阳性。
状态列须为末列；正则容忍缺尾管道与尾随 TAB。正则须字面量内联，经 -v 传入会丢转义。
需 awk 支持 ERE interval 量词 {n}（macOS 2021+ / gawk / mawk 均可）；不支持时全部行报
MALFORMED——吵而不静默，方向正确但下游会误以为台账全坏。
awk 只比较 ISO 日期，纯 ASCII；中文只经 print 不参与比较——勿改成别的写法。）
```

### 改动 3 — "备注列"措辞（它自带一个自毁开关）
原文：
```
扫描结果（有/无超期）随该次追加一并写进备注列或 Completion——
否则事后无法区分"扫过、确认无超期"与"根本没扫直接追加"。
```
改为：
```
扫描结果（有/无超期）随该次追加一并写进 Completion——
否则事后无法区分"扫过、确认无超期"与"根本没扫直接追加"。
台账列序固定：状态列恒为末列，不得在其后新增列（扫描锚点依赖此不变量；
确需备注列须加在状态列之前）。
```

### 改动 4 — append-only 条款
原文：
```
本节自身也须在台账中占一行（闸付自己的通行费）。
台账自身的增长豁免于本节纪律——append-only 是为审计可追溯，不得以"清理台账"擦除历史行。
```
改为：
```
本节自身也须在台账中占一行（闸付自己的通行费）。
台账自身的增长豁免于本节纪律。可追溯性保在两处：理由三格（每单成本 / 挡什么失败模式 /
载体路径）一经写下不再改；处置时另追加一行并把原期限带进去
（**只写日期，不要重复 PROVISIONAL 字样——会触发 MALFORMED 误报**）。
状态列允许就地转移，但**仅限转为终态（HAS-CARRIER / NO-CARRIER / SUPERSEDED / RETIRED）**
——不转移会让已处置的行永远被报超期（僵旗）；`N/A` 与再发 PROVISIONAL 均不是终态，不得由此转入。
改判 HAS-CARRIER / SUPERSEDED 时，新载体写进追加的处置行，不改原行的载体路径格。
不得以"清理台账"删除历史行。
```

### 改动 5 — 出口侧反合理化钩子（补静默续期禁令）
原文末句：
```
必须附可 grep 验证的新增载体，否则一律执行 RETIRED。
```
改为：
```
必须附可 grep 验证的新增载体，否则一律执行 RETIRED。
禁止静默续期：不得就地把 review-by 改成更晚的日期——展期必须新起一行并写明理由，
使"又拖了一次"在台账上可见。
```

### 改动 6 — 台账前言（AC2 对此文件豁免）
`.tad/evidence/audits/lite-constraint-ledger.md` 原文：
```
> append-only：删除约束也追加 RETIRED 行，不擦除历史行。
```
改为：
```
> append-only：不删除历史行。状态列可就地转移为终态；处置理由另追加一行并带上原期限。
```
**理由**（Gate2 P1-6）：处置者当场打开的是台账，不是 skill。前言不同步 = 修复在实操层面落不了地。

### 改动 7 — 镜像
`bash .tad/hooks/lib/release-verify.sh parity --fix .`（不得手工 cp）

---

## 5. Acceptance Criteria

> 开工前先跑 §5.0，再逐条确认 AC1–AC9 全 FAIL（结果记入 Completion）。

### 5.0 开工前快照

```bash
S=.tad/evidence/acceptance-tests/pricing-gate-scan-fix
BASE=4b29dc263a5368c0b598fc1030f465fc7ebdbc10
mkdir -p "$S"
# 授权集定义一次，AC7/AC8 共用。已吸收：P1a 实测踩到的框架产物 + 本单要改的台账
# + traces(跨午夜新文件) + memory(native 随时可写)
cat > "$S/allow.txt" <<'ALLOWEOF'
^(\.claude/skills/(alex|blake)-lite/SKILL\.md|\.agents/skills/(alex|blake)-lite/SKILL\.md|\.tad/evidence/audits/lite-constraint-ledger\.md|\.tad/evidence/acceptance-tests/pricing-gate-scan-fix/.*|\.tad/evidence/journal/.*|\.tad/evidence/reviews/.*|\.tad/evidence/decisions/.*|\.tad/evidence/traces/.*|\.tad/evidence/ralph-loops/.*|\.tad/memory/.*|\.tad/active/handoffs/.*|\.tad/archive/handoffs/.*)$
ALLOWEOF
# ⚠️ 快照须在所有"实现前的框架步骤"跑完之后再拍（P1a 教训：ralph state 早于快照即误报）
git diff --name-only "$BASE" | LC_ALL=C sort > "$S/tracked-before.txt"
git -c core.quotePath=false status --porcelain --untracked-files=all \
  | grep '^??' | cut -c4- | LC_ALL=C sort > "$S/untracked-before.txt"
```

- **AC1** 落地命令**整行逐字**等于 §2.3/§4 改动 2，旧命令特征串已清除
  ⚠️ AC4/AC5 内联运行的是规格里的命令。**只有本条把"落地文本 == 规格文本"钉死，
  它们才是在验交付物。** 故用 `grep -Fxq`（整行精确），并**必须包含台账路径那一行**
  （Gate2 P1-3 实证：只钉前两行时，路径写错一个字母 → 扫一个不存在的文件 → 永远无超期，
  而 AC4/5/6/9 全都看不见）。
  ```bash
  for f in .claude/skills/alex-lite/SKILL.md .claude/skills/blake-lite/SKILL.md; do
    grep -Fxq '  awk -v t="$(date +%F)" '"'"'/[Pp][Rr][Oo][Vv][Ii][Ss][Ii][Oo][Nn][Aa][Ll][:：]?/ {' "$f" || echo "AC1 FAIL 命令第1行(前置过滤) [$f]"
    grep -Fxq '    if (match($0, /PROVISIONAL: review-by [0-9]{4}-[0-9]{2}-[0-9]{2}[[:space:]]*\|?[[:space:]]*$/)) {' "$f" || echo "AC1 FAIL 命令第2行 [$f]"
    grep -Fxq '      d = substr($0, RSTART+23, 10); if (d < t) print "OVERDUE: " $0 }' "$f" || echo "AC1 FAIL 命令第3行 [$f]"
    grep -Fxq '    else print "MALFORMED(须人工处置): " $0 }'"'"' \' "$f" || echo "AC1 FAIL 逃逸检测行 [$f]"
    grep -Fxq '    .tad/evidence/audits/lite-constraint-ledger.md' "$f" || echo "AC1 FAIL 台账路径行 [$f]"
    grep -Fq '仅限转为终态（HAS-CARRIER / NO-CARRIER / SUPERSEDED / RETIRED）' "$f" \
      || echo "AC1 FAIL 终态枚举缺失 [$f]"   # 只写"仅限转为终态"不够：落地文本里该词此前从未定义
    grep -Fq '禁止静默续期' "$f" || echo "AC1 FAIL 静默续期禁令 [$f]"
    grep -Fq '状态列恒为末列' "$f" || echo "AC1 FAIL 列序不变量 [$f]"
    grep -Fq '不要重复 PROVISIONAL 字样' "$f" || echo "AC1 FAIL 处置行踩雷提示缺失 [$f]"
    grep -Fq 'RSTART+10' "$f" && echo "AC1 FAIL 旧偏移残留 [$f]"
    grep -Fq '写进备注列' "$f" && echo "AC1 FAIL 旧备注列措辞残留 [$f]"
  done
  ```
  期望：无输出

- **AC2** 改动限于「约束准入」节内——节外内容与 BASE 逐字节相同
  ⚠️ 本条是**否定断言**，实现前必然 PASS，单独无判别力——这是性质非缺陷。
  意义来自配对：**AC1 证明改动发生了，AC2 证明改动没溢出。**
  ⚠️ 本条只覆盖两个 skill；台账（改动 6）不在其范围，由 AC6 单独覆盖。
  ```bash
  S=.tad/evidence/acceptance-tests/pricing-gate-scan-fix
  BASE=4b29dc263a5368c0b598fc1030f465fc7ebdbc10
  strip() { a=$(grep -c '^## 约束准入' "$1"); b=$(grep -c '^## Forbidden' "$1")
            { [ "$a" -eq 1 ] && [ "$b" -eq 1 ]; } || { echo "STRIP-FAIL 锚点非唯一 $1" >&2; return 1; }
            x=$(grep -n '^## 约束准入' "$1"|cut -d: -f1); y=$(grep -n '^## Forbidden' "$1"|cut -d: -f1)
            [ "$x" -lt "$y" ] || { echo "STRIP-FAIL 顺序错 $1" >&2; return 1; }
            sed "${x},$((y-1))d" "$1"; }
  ok=0
  for f in alex-lite blake-lite; do
    git show "$BASE:.claude/skills/$f/SKILL.md" > "$S/base-$f.md"
    strip "$S/base-$f.md" > "$S/base-strip-$f.md" || continue
    strip ".claude/skills/$f/SKILL.md" > "$S/cur-strip-$f.md" || continue
    cmp "$S/base-strip-$f.md" "$S/cur-strip-$f.md" || echo "AC2 FAIL 节外内容被改动 [$f]"
    ok=$((ok+1))
  done
  [ "$ok" -eq 2 ] || echo "AC2 FAIL 只跑了 $ok/2 个 skill（AC 未真正执行）"
  ```
  期望：无输出
  ⚠️ `STRIP-FAIL` 必须走 **stderr**（Gate2 P1-2 实证：走 stdout 会被重定向吞进产物文件，
  屏幕全空 → **"AC 没跑"和"AC 通过"完全同形**，正是本单要修的病的同型）。
  `ok` 计数是该分支的自证：AC 必须证明自己真的跑了两遍。

- **AC3** 两 skill 的「约束准入」节逐字节相同且仍在 `## Forbidden` 之前
  ```bash
  S=.tad/evidence/acceptance-tests/pricing-gate-scan-fix
  rm -f "$S/sec-alex-lite.txt" "$S/sec-blake-lite.txt"   # 勿用 glob：zsh 无匹配即报错
  for f in alex-lite blake-lite; do SK=.claude/skills/$f/SKILL.md
    a=$(grep -n '^## 约束准入' "$SK"|cut -d: -f1); b=$(grep -n '^## Forbidden' "$SK"|cut -d: -f1)
    { [ -n "$a" ] && [ -n "$b" ] && [ "$a" -lt "$b" ]; } || { echo "AC3 FAIL 位置 [$f] a=$a b=$b"; continue; }
    sed -n "$a,$((b-1))p" "$SK" > "$S/sec-$f.txt"; done
  cmp "$S/sec-alex-lite.txt" "$S/sec-blake-lite.txt" 2>/dev/null || echo "AC3 FAIL 两节不一致或缺失"
  [ -s "$S/sec-alex-lite.txt" ] || echo "AC3 FAIL 节为空 (alex)"
  [ -s "$S/sec-blake-lite.txt" ] || echo "AC3 FAIL 节为空 (blake)"
  ```
  期望：无输出

> ⚠️ **两个缺陷由不同东西修好，AC 必须分开断言**：
> **假阳性 / 三类假阴性 / 畸形逃逸** = 命令级 → 可用新旧命令对照证明判别力。
> **僵旗** = 约定级 → 由「就地转移」条款（AC1）修；拿老约定数据喂新命令**仍会命中，
> 且那是正确行为**（那种数据在新约定下不该存在）。混成一个断言是错的。

- **AC4a** 命令级八场景（一张探针跑全）
  ```bash
  S=.tad/evidence/acceptance-tests/pricing-gate-scan-fix
  cat > "$S/probe-cmd.md" <<'PEOF'
| 日期 | skill | 节 | 约束摘要 | 每单成本 | 挡什么失败模式 | 载体路径 | 状态 |
|---|---|---|---|---|---|---|---|
| A1 | a | 身份 | 甲 | 低 | X | p1 | PROVISIONAL: review-by 2024-01-01
| A2 | a | 精髓 | 乙 | 低 | Y | p2 | PROVISIONAL: review-by 2024-02-02 |
| A3 | a | Forbidden | 丙 | 低 | Z | p3 | PROVISIONAL: review-by 2027-01-01 |
| A4 | a | L1 实现 | 丁 | 低 | W | p4 | RETIRED |
| A5 | a | L2 AC 自验 | 戊(原 review-by 2020-01-01) | 低 | V | p5 | HAS-CARRIER |
| A6 | a | L3 独立审查 | 己 | 低 | U | p6 | PROVISIONAL: review-by 2024-03-03 | 备注 |
| A8 | a | Forbidden | 辛 | 低 | S | p8 | PROVISIONAL: review-by 2026-7-1 |
| B1 | a | 身份 | 甲 | 低 | X | p1 | PROVISIONAL： review-by 2024-01-01 |
| B2 | a | 身份 | 甲 | 低 | X | p1 | PROVISIONAL review-by 2024-01-01 |
| B3 | a | 身份 | 甲 | 低 | X | p1 | Provisional: review-by 2024-01-01 |
| B9 | a | L3 独立审查 | 己 | 低 | U | p6 | N/A: 无约束条目 |
PEOF
  printf '| A7 | a | L1 实现 | 庚 | 低 | T | p7 | PROVISIONAL: review-by 2024-04-04 |\t\n' >> "$S/probe-cmd.md"
  out=$(awk -v t="$(date +%F)" '/[Pp][Rr][Oo][Vv][Ii][Ss][Ii][Oo][Nn][Aa][Ll][:：]?/ {
    if (match($0, /PROVISIONAL: review-by [0-9]{4}-[0-9]{2}-[0-9]{2}[[:space:]]*\|?[[:space:]]*$/)) {
      d = substr($0, RSTART+23, 10); if (d < t) print "OVERDUE=" $2 }
    else print "MALFORMED=" $2 }' "$S/probe-cmd.md")
  exp='OVERDUE=A1
OVERDUE=A2
MALFORMED=A6
MALFORMED=A8
MALFORMED=B1
MALFORMED=B2
MALFORMED=B3
OVERDUE=A7'
  [ "$out" = "$exp" ] || { echo "AC4a FAIL 实际输出："; printf '%s\n' "$out"; }
  ```
  期望：无输出
  - **OVERDUE**：A1 无尾管道 / A2 正常 / A7 尾管道带 TAB —— 三类原假阴性已抓
  - **MALFORMED**：A6 状态后多一列 / A8 日期非补零 / **B1 全角冒号 / B2 缺冒号 / B3 大小写**
    —— 后三类是逃逸检测**前置过滤**的盲区（Gate2-R2 P1-2），拓宽过滤后转为显式报出
  - **不出现**：A3 未超期 / A4 已转终态 / A5 摘要含 review-by 字样 / **B9 转 N/A**
  ⚠️ 用 `=` 而非空格分隔（Gate2-R2 P1-1 实证：原稿 `exp` 每行多一个空格，
  `print "X " $2` 只出 1 个 → `[ "$out" = "$exp" ]` 恒假、AC4a 恒 FAIL）
  ⚠️ **同探针必须用 BASE 版旧命令跑一次留证**：旧命令的命中集应与新命令**不同**
  （证明探针有判别力而非恒成立）

- **AC4b** 约定级（僵旗）：按新约定就地转终态后的行，新命令静默
  ```bash
  S=.tad/evidence/acceptance-tests/pricing-gate-scan-fix
  cat > "$S/probe-zombie.md" <<'PEOF'
| 日期 | skill | 节 | 约束摘要 | 每单成本 | 挡什么失败模式 | 载体路径 | 状态 |
|---|---|---|---|---|---|---|---|
| 2026-08-05 | a | 精髓 | 乙 | 低 | Y | p2 | RETIRED |
| 2026-08-06 | a | 精髓 | 乙(处置记录，原 review-by 2025-01-01) | 低 | Y | p2 | RETIRED |
PEOF
  n=$(awk -v t="$(date +%F)" '/[Pp][Rr][Oo][Vv][Ii][Ss][Ii][Oo][Nn][Aa][Ll][:：]?/ {
    if (match($0, /PROVISIONAL: review-by [0-9]{4}-[0-9]{2}-[0-9]{2}[[:space:]]*\|?[[:space:]]*$/)) {
      d = substr($0, RSTART+23, 10); if (d < t) print $0 } else print $0 }' "$S/probe-zombie.md" | wc -l | tr -d ' ')
  [ "$n" -eq 0 ] || echo "AC4b FAIL 僵旗未消除或处置行被误报：$n（期望 0）"
  ```
  期望：无输出。**真正的保障是 AC1 的 `仅限转为终态` 条款**——
  没有它，处置者仍会留下 PROVISIONAL 原行，而那种行被命中是正确的。
  本条同时验证：处置行里保留"原 review-by"字样**不会**被重新命中。

- **AC5** 正向对照：真超期必须仍被抓，且基线纯净
  ⚠️ 基线取 AC4b 的探针（Gate2 P1-1 实证：原稿引用了一个**任何 AC 都没创建过**的
  `probe-ledger.md`，照抄会 `cp` 报错并把正向对照退化成"单行文件里抓一行"的平凡断言）
  ```bash
  S=.tad/evidence/acceptance-tests/pricing-gate-scan-fix
  SCAN='/[Pp][Rr][Oo][Vv][Ii][Ss][Ii][Oo][Nn][Aa][Ll][:：]?/ { if (match($0, /PROVISIONAL: review-by [0-9]{4}-[0-9]{2}-[0-9]{2}[[:space:]]*\|?[[:space:]]*$/)) { d = substr($0, RSTART+23, 10); if (d < t) print $0 } }'
  base=$(awk -v t="$(date +%F)" "$SCAN" "$S/probe-zombie.md" | wc -l | tr -d ' ')
  [ "$base" -eq 0 ] || echo "AC5 FAIL 基线不纯净：$base（期望 0）"
  cp "$S/probe-zombie.md" "$S/probe-positive.md"
  printf '| 2026-08-07 | a | L2 AC 自验 | 戊 | 低 | V | p5 | PROVISIONAL: review-by 2024-06-01 |\n' >> "$S/probe-positive.md"
  n=$(awk -v t="$(date +%F)" "$SCAN" "$S/probe-positive.md" | wc -l | tr -d ' ')
  [ "$n" -eq 1 ] || echo "AC5 FAIL 真超期未被抓或多报：$n（期望 1）"
  ```
  期望：无输出
  ⚠️ 此处 `-v t=` 只传日期（纯 ASCII，安全）；**扫描正则仍是字面量**，
  经 shell 变量 `$SCAN` 传的是 awk **程序体**不是正则，转义不受影响（已实测）

- **AC6** 台账：表格仍 0 数据行，且前言已同步为新约定
  ⚠️ 本条不可砍。审查曾建议砍（理由：台账不在授权集，AC7 会抓）——
  但改动 6 已把台账**纳入**授权集，AC7 不再覆盖它，本条成为唯一防线。
  ```bash
  L=.tad/evidence/audits/lite-constraint-ledger.md
  n=$(grep -cE '^\|[^-]' "$L"); [ "$n" -eq 1 ] || echo "AC6 FAIL 表格数据行=$((n-1))，应为 0"
  grep -Fq '状态列可就地转移为终态' "$L" || echo "AC6 FAIL 前言未同步"
  grep -Fq '删除约束也追加 RETIRED 行' "$L" && echo "AC6 FAIL 旧前言残留"
  ```
  期望：无输出

- **AC7** tracked 围栏（快照差分，授权集共用）
  ```bash
  S=.tad/evidence/acceptance-tests/pricing-gate-scan-fix
  BASE=4b29dc263a5368c0b598fc1030f465fc7ebdbc10
  ALLOW=$(cat "$S/allow.txt")
  git diff --name-only "$BASE" | LC_ALL=C sort > "$S/tracked-after.txt"
  comm -13 "$S/tracked-before.txt" "$S/tracked-after.txt" | grep -vE "$ALLOW"
  ```
  期望：无输出

- **AC8** untracked 围栏
  ```bash
  S=.tad/evidence/acceptance-tests/pricing-gate-scan-fix
  ALLOW=$(cat "$S/allow.txt")
  git -c core.quotePath=false status --porcelain --untracked-files=all \
    | grep '^??' | cut -c4- | LC_ALL=C sort > "$S/untracked-after.txt"
  comm -13 "$S/untracked-before.txt" "$S/untracked-after.txt" | grep -vE "$ALLOW"
  ```
  期望：无输出
  ⚠️ **AC7/AC8 须双向自测**：负向（禁区种文件被抓）+ **正向**（按 §6 正常 `git add`
  授权集后仍静默）。只测负向会漏掉"围栏挡住合法交付"那一类（P1a 实测教训）。

- **AC9** `.agents/` 镜像含新命令且与 `.claude/` 字节一致
  ```bash
  for f in alex-lite blake-lite; do
    grep -Fq 'MALFORMED(须人工处置)' .agents/skills/$f/SKILL.md || echo "AC9 FAIL AGENTS-MISSING $f"
    cmp -s .claude/skills/$f/SKILL.md .agents/skills/$f/SKILL.md || echo "AC9 FAIL DIFF $f"
  done
  bash .tad/hooks/lib/release-verify.sh parity .
  ```
  期望：无 FAIL；parity 判定行贴进 Completion

---

## 6. 风险与注意

1. ⚠️ **本机 `/usr/bin/awk` 中文串比较恒为真** —— §2.1 选 (b) 的原因。
   新命令的 awk 只做 ASCII 日期比较，**不得**改写成任何需要比较中文（节名/摘要）的形式。
2. ⚠️ **正则必须字面量内联**，经 `-v` 传入会丢转义（实测 `illegal primary`）。
3. **AC1 的模式含正则元字符**，必须 `grep -F`（定长串）而非 `grep -E`。
4. **含反引号/单引号嵌套的 AC 建议存成 `.sh` 再 `bash` 执行**，脚本与输出一并贴进 Completion。
5. **`.agents/` 只能经 `parity --fix` 生成**，不得手工 cp。
6. **提交只 add `$S/allow.txt` 内的路径，禁止 `git add -A`**；`git push` 禁止。
   仓库有 3 个已脏 tracked + 800+ untracked 与本单无关，**不得代为提交或清理**。
7. **本单不新增约束**——发现"还需要加一条 MUST"→ 停，报告人（那要走定价闸自己的流程）。
8. 命中升级清单第 2 类（`.claude/skills/*/SKILL.md`）→ 走 full。

---

## 7. Definition of Done

AC1–AC9 全 PASS（含开工前全 FAIL 自检 + AC4a 旧命令判别力留证 + 围栏双向自测）
+ Layer 2 ≥2 distinct reviewers + Gate 3 PASS
+ Completion 落盘，**须含 §2.2 的显式承认**（就地转移清除了"噪音=留痕"副作用，
且无 AC 校验"转移必须配套追加行"）+ 本 phase 实际 token。

`git commit` 允许（仅授权集），**`git push` 禁止**。

---

## 8. Gate 2 审计（R1，两名 reviewer）

**0 P0 / 9 P1 / 4 P2，全部整合。** 最重要的三条：

| 来源 | 发现 | 本单处置 |
|---|---|---|
| code-reviewer P1-4 | 原修法**用一类假阳性换来三类假阴性**（状态后多一列 / 无尾管道 / 尾管道带 TAB），而假阴性正是立项理由 | §2.3 新正则 + **逃逸检测 else 分支** + 改动 3 列序不变量 |
| code-reviewer P1-5 | 就地转移使 `PROVISIONAL→PROVISIONAL(新期限)` 合法且无痕，**把"默认删除"偷偷改成"默认续期"** | §2.1 收窄为仅限终态 + 改动 5 静默续期禁令 |
| code-reviewer P1-6 | 台账**前言**仍写旧规则，而处置者当场看的是台账不是 skill → 修复实操落不了地 | 改动 6 + 台账纳入授权集 + AC6 相应加强 |

对抗审查判 **PASS**，并驳回了"整个删掉到期机制"的选项，理由：
*两个语义 bug 是"命令写错"，不是"机制无法可靠触发"的新证据，**两者是不同的失效轴***；
在修订单里否决一个已过闸接受的设计决策属 scope creep。**采纳。**

其提出的日落方案已转入 Epic P1b（见 Epic「Phase 1b」段）：
把本节自己那行台账的状态设为 `PROVISIONAL`，载体条件 = "扫描机制在窗口内至少真实拦下一次超期"——
**让这套机制用它自己的规则审判自己**。
