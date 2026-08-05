---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: [".claude/skills", ".agents/skills", ".tad/evidence"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)

**From:** Alex | **To:** Blake | **Date:** 2026-08-04
**Task ID:** TASK-20260804-P1
**Epic:** `.tad/active/epics/EPIC-20260804-lite-as-tad-body.md` — **Phase 1 / 6**
**Handoff Version:** 2.0（R1 收敛：7 P0 + 6 P1 全部整合）
**BASE**: `31a96aae3332adc87c565d06defff808cc8bef06`（AC6 基准，编辑前不得移动）

---

## 🔴 Gate 2: Design Completeness

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 两处插入 + 一个新文件，无状态机、无脚本 |
| Components Specified | ✅ | §4 逐节规格，六态定义完整 |
| Functions Verified | ✅ | N/A — markdown 协议文件；AC 命令已由 R1 reviewer 实跑验证 |
| Data Flow Mapped | ✅ | 台账 append-only 单载体；到期提醒外挂 NEXT.md |

**Gate 2 结果**: ⬚ 待 R2 增量复核（v1 → v2 diff）

---

## 1. Task Overview

### 1.1 What We're Building

给两个 lite skill 各加一节「**约束准入**」，并建立 `.tad/evidence/audits/lite-constraint-ledger.md` 定价台账。

**新增约束前必须先给它定价**——填不出「它挡住什么 + 载体在哪」的约束，只能带期限进来，到期无人认领即出局。

### 1.2 Why We're Building It

lite 五天七次加固，**加 64 条约束、删 0 条**，协议体量 10,298 → 53,834 字符（5.2×），
干活前固定读取量 ~10K → **~74K 字符**——已追上它当初要逃离的 full 激活固定费（~60K+40K）。

**七次加固每次都是「发现漏洞 → 加约束」，从未问过「这条值不值它的每单成本」。**

### 1.3 Intent Statement

Epic 后续 phase 要砍掉大量约束。**不先立闸，砍完五天内会长回来**——这是本 Epic 唯一防止白做的东西。

**不是要做的**：
- ❌ 本单**不删除、不修改任何现有约束**（那是 P2/P3）
- ❌ 不碰 routing-contract.yaml、full skills、hooks、settings、`/tad-maintain`
- ❌ 不写脚本、不注册 hook——闸是**协议文本**，靠 agent 遵守 + 人审计

---

## 2. 关键设计决策

### 决策 1：填不出载体 → PROVISIONAL 带期限，**不硬拒**

依据 `.tad/project-knowledge/principles.md` → `Mechanical Enforcement Rejected on Single-User CLI`：
单人 CLI 用软约束 + 人审计。硬拒会被合理化绕过；**PROVISIONAL + 到期复查是自清洁的**。

### 决策 2：到期提醒挂 NEXT.md（R1 P0-1 修复）

**R1 发现**：v1 只写了"到期 → 删除"这个**结果**，没写**谁在什么时刻会看到期**。
没有触发点 = PROVISIONAL 永久豁免 = 闸是空的，且比没有闸更危险（制造自清洁的假象）。

**且 R1 指出一条我没预料的放大链**：防患式约束在提出时通常还没出过事 →
**PROVISIONAL 是主路径不是少数逃生口** → 无人复查的代价被放大。

**修法**：记 PROVISIONAL 的**同一动作**里往 NEXT.md 追加一行到期提醒。
NEXT.md 每 session 会被读到。**不扩到 `/tad-maintain`**（那会碰 full 协议文件，扩大范围）。

### 决策 3：台账 append-only，且其自身增长豁免于本闸（R1 P1 修复）

RETIRED 行保留原始理由，使"当初为什么加"可追溯，避免重新发明同一条约束。
**显式豁免**：台账自身的增长不受本节纪律约束——append-only 是为审计可追溯性，
不是要复刻协议膨胀。未来不得以"清理台账"为由擦除历史行。

### 决策 4：闸给自己定价（R1 P0-2 修复）

新增的 `## 约束准入` 节本身是一个 `## ` 节，会被 AC3 的节名提取捕获。
**选择让它给自己定价**（32 → **34** 对），而不是把它排除在外——闸付自己的通行费是正确形状。

---

## 3. 📚 Project Knowledge（Blake 必读）

| 路径 | 一行含义 |
|---|---|
| `.tad/project-knowledge/principles.md` → `Mechanical Enforcement Rejected on Single-User CLI` | 单人 CLI 用软约束 + 人审计；决策 1 的依据 |
| `.tad/project-knowledge/patterns/ac-verification.md` | AC 判别力：实现前必须 FAIL；负向 regex 会约束禁令自身措辞 |
| `.tad/evidence/journal/lite-capability-complete-2026-07-31.md` | 同一坑原始记录：禁令句含被禁子串会自踩 AC |
| `.tad/evidence/research/2026-07-30-lite-vs-full-quality-comparison.md` | 逐机制对照 + 唯一实测泄漏点；台账 HAS-CARRIER 主要来源 |
| `.tad/evidence/journal/tad-lite-channel-2026-07-30.md` | 出生实测 ~23K tokens/单，reviewer spawn ~8K 不可再减 |

---

## 4. 实现规格

### 4.1 「约束准入」节（两个 skill 各插入一份，逐字节相同）

插入位置：`## Forbidden` 节**之前**。

**六态定义必须完整出现**（R1 P1-3：v1 只在协议文本里定义了 3 态，AC 却用 6 态）：

```
## 约束准入（新增约束前必须定价）

新增或扩大任何 MUST / MANDATORY / BLOCKING / 禁止 / 不得 条目前，
必须先在 .tad/evidence/audits/lite-constraint-ledger.md 追加一行，填齐三项：

1. 每单成本 —— 读几个文件 / 写几个字段 / spawn 几次 / 几轮人机往返
2. 挡什么失败模式 —— 具体到可复现的失败，不写"提升质量"类空话；
   结尾必须附一个反引号包裹的逐字 grep 锚（例：…AC principal 缺陷穿透自审 `AC principal`）
3. 载体路径 —— journal / 研究文件 / .tad/logs/violations.log 中的真实事故位置

状态六态（取值封闭，不得自创）：
- HAS-CARRIER          三项齐全且载体已核验命中
- NO-CARRIER           已主动搜索确认无载体（P2/P3 砍除名单来源）
- PROVISIONAL: review-by {YYYY-MM-DD}   尚未核验完或载体待补，期限 = 记录日 +90 天
- SUPERSEDED           有载体但已被更高层裁定退场（载体仍填在载体路径列）
- RETIRED              已删除该约束（append-only，追加行而非擦除）
- N/A: {原因}          该节无约束条目

记 PROVISIONAL 的同一动作，必须往 NEXT.md 追加一行到期提醒
（格式：`- [ ] {YYYY-MM-DD} 台账 PROVISIONAL 到期复查：{约束摘要}`）——
无到期提醒的 PROVISIONAL 视为未过闸。到期仍无载体 → 删除该约束 + 追加 RETIRED 行。

反合理化：把"这条明显必要""先加后补""改动很小"视为**触发 PROVISIONAL 的信号，
而不是跳过闸的理由**。凡未当场翻开台账追加行的新增 MUST/BLOCKING，一律视为未过闸。

本节自身也须在台账中占一行（闸付自己的通行费）。
台账自身的增长豁免于本节纪律——append-only 是为审计可追溯，不得以"清理台账"擦除历史行。
```

⚠️ **AC1 的七个字面量不在"措辞可优化"范围内**（R1 P2-5）：
`## 约束准入` / `每单成本` / `挡什么失败模式` / `载体路径` /
`HAS-CARRIER` / `PROVISIONAL: review-by` / `RETIRED` 必须逐字出现。

### 4.2 台账 `.tad/evidence/audits/lite-constraint-ledger.md`

表头 9 列（含前导空列，markdown 表格 `cut -d'|'` 从 f2 起为数据列）：

```
| 日期 | skill | 节 | 约束摘要 | 每单成本 | 挡什么失败模式 | 载体路径 | 状态 |
```

**列填写约定**（R1 P2-3 / P2-4）：
- **节** 列填**顶层 `## ` 短节名**（= 节标题去 `## ` 后截断至首个 `（`/`(`/`——`，去尾空白）。
  同一节有多条约束 → 写多行，靠 **约束摘要** 列区分（例：节=`执行脊柱`，摘要=`L2.5 契约 reviewer`）。
- **挡什么失败模式** 列结尾必须附反引号 grep 锚（见 §4.1）。
- **N/A 行**：约束摘要 / 每单成本 / 挡什么失败模式 / 载体路径 四列一律填 `-`。
- 单元格内**不得出现** `|` 或反引号（锚除外）。

**逐节覆盖 34 对**：alex-lite 12 节 + blake-lite 20 节 + 新增 `约束准入` 节 ×2 = **34**。

**初始内容以下表为起点**（Alex 2026-08-04 审计初判）。Blake 的工作是**核验**——
两个方向都要走，**不是只走降级方向**（R1 P0-2）。

**HAS-CARRIER 初判（需逐条核验；核不过 → 改判 PROVISIONAL）**

| 约束摘要 | 载体路径 | grep 锚 |
|---|---|---|
| L2.5 契约 reviewer / L3 实现 reviewer | `.tad/evidence/research/2026-07-30-lite-vs-full-quality-comparison.md` | `AC principal` |
| L2.25 AC 空跑 | 同上 | `AC principal` |
| Lite Repair Loop 熔断 | `.tad/evidence/journal/lite-core-closure-2026-07-31.md` | `S3` |
| Honest Partial / 七态状态词 | `.tad/evidence/research/2026-07-30-lite-vs-full-quality-comparison.md` | `目标共定义` |
| 跨角色请求消歧 | `.tad/logs/violations.log` | `2026-08-02` |
| L1 目标锚 | `.tad/evidence/research/2026-07-30-lite-vs-full-quality-comparison.md` | `目标共定义` |
| L0.5 机械复查 | `.tad/evidence/journal/lite-core-closure-2026-07-31.md` | `加粗` |

⚠️ **跨角色请求消歧 一行需特别核验**（R1 P1-5）：violations.log 的 2026-08-02 条目记的是
"Alex 直接写实现"，未必等同于"跨角色请求消歧失效"。**若失败模式与载体不匹配，
如实改判 PROVISIONAL，不要为了凑齐 HAS-CARRIER 而牵强对应。**

**NO-CARRIER 初判（需主动搜索反证，见 AC8）**

| 约束摘要 | 初判理由 |
|---|---|
| Route Contract R0–R3 全套（17 字段 RouteDecision / revision 链 / 11 状态机 / Standard profile 两个 json / escalated_review / 额度出口话术） | 08-01 那单的 5 条 journal discovery 全是验证 harness 的坑，无一条是"路由挡住了什么" |
| Reviewer 档位规则 | 有载体（2026-08-02 flash-审-flash），但用户 2026-08-04 裁定不要档位强制 → 状态记 `SUPERSEDED`，载体仍填载体路径列 |
| Model 行捕获纪律 | 主消费者是档位规则；档位退场后仅剩审计留痕 |
| Lite Progress 6 个边界 | 载体为压缩恢复（真实），但"6 个边界是否过量"无证据 → `PROVISIONAL` |

---

## 5. Acceptance Criteria

> 全部 9 条在实现前必须 **FAIL**。Blake 开工前先逐条跑一遍确认全 FAIL（判别力自检），
> 结果记入 Completion。任何一条实现前就 PASS = 该 AC 无效，停，报告 Alex。

- **AC1** 两个 skill 均含约束准入节与七个字面量
  ```
  for f in .claude/skills/alex-lite/SKILL.md .claude/skills/blake-lite/SKILL.md; do
    for s in '## 约束准入' '每单成本' '挡什么失败模式' '载体路径' 'HAS-CARRIER' 'PROVISIONAL: review-by' 'RETIRED'; do
      grep -Fq "$s" "$f" || echo "AC1 FAIL [$f] $s"
    done
  done
  ```
  期望：无输出

- **AC2** 台账表头逐字正确
  `grep -Fq '| 日期 | skill | 节 | 约束摘要 | 每单成本 | 挡什么失败模式 | 载体路径 | 状态 |' .tad/evidence/audits/lite-constraint-ledger.md`
  期望：exit 0

- **AC3** 逐节覆盖 34 对，**锚定「节」列**（R1 P0-1/P0-2/P1-2/P1-4）
  ```
  LEDGER=.tad/evidence/audits/lite-constraint-ledger.md
  rows=$(cut -d'|' -f3,4 "$LEDGER" \
         | sed 's/^[[:space:]]*//; s/[[:space:]]*|[[:space:]]*/|/; s/[[:space:]]*$//')
  out=$(for f in alex-lite blake-lite; do
    grep '^## ' .claude/skills/$f/SKILL.md \
    | sed 's/^## //; s/（.*//; s/(.*//; s/——.*//; s/[[:space:]]*$//' \
    | while IFS= read -r sec; do
        printf '%s\n' "$rows" | grep -Fxq "$f|$sec" || echo "MISSING [$f] $sec"
      done
  done)
  [ -z "$out" ] && echo "AC3 PASS" || { printf '%s\n' "$out"; echo "AC3 FAIL"; }
  ```
  期望：`AC3 PASS`（34 对全覆盖，含两个 `约束准入` 节）

- **AC4** 每个 HAS-CARRIER 行的载体存在且 grep 锚命中
  ⚠️ **前置断言不可省**（自审实测：无它则台账不存在时空输出即假 PASS）
  ```
  [ -s "$LEDGER" ] || { echo "AC4 FAIL: ledger missing/empty"; exit 1; }
  cut -d'|' -f7,8,9 "$LEDGER" | grep -F 'HAS-CARRIER' | while IFS='|' read -r why path st; do
    kw=$(printf '%s' "$why" | sed -n 's/.*`\([^`]*\)`.*/\1/p')
    p=$(printf '%s' "$path" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
    [ -n "$kw" ] || { echo "AC4 FAIL no-anchor: $p"; continue; }
    [ -f "$p" ] || { echo "AC4 FAIL no-file: $p"; continue; }
    grep -Fq "$kw" "$p" || echo "AC4 FAIL no-keyword [$kw] in $p"
  done
  ```
  期望：无输出

- **AC5** 状态列词汇封闭
  ⚠️ **前置断言不可省**（同 AC4）
  ```
  [ -s "$LEDGER" ] || { echo "AC5 FAIL: ledger missing/empty"; exit 1; }
  cut -d'|' -f9 "$LEDGER" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//' \
  | grep -vx '状态' | grep -vx -- '---' \
  | grep -vxE 'HAS-CARRIER|NO-CARRIER|SUPERSEDED|RETIRED|PROVISIONAL: review-by [0-9]{4}-[0-9]{2}-[0-9]{2}|N/A: .+'
  ```
  期望：无输出

- **AC6a** 两个 skill 为纯插入：恰好 2 行、零删除、有新增
  ```
  git diff --numstat 31a96aae3332adc87c565d06defff808cc8bef06 \
    -- .claude/skills/alex-lite/SKILL.md .claude/skills/blake-lite/SKILL.md \
  | awk 'BEGIN{n=0} {n++; if($2!="0") bad=1; if($1+0==0) bad=1} END{if(n!=2||bad) print "AC6a FAIL"}'
  ```
  期望：无输出

- **AC6b** 范围围栏：BASE 以来未触碰授权集之外的文件
  ```
  git diff --name-only 31a96aae3332adc87c565d06defff808cc8bef06 \
  | grep -vE '^(\.claude/skills/(alex|blake)-lite/SKILL\.md|\.agents/skills/(alex|blake)-lite/SKILL\.md|\.tad/evidence/audits/lite-constraint-ledger\.md|\.tad/active/handoffs/HANDOFF-20260804-lite-pricing-gate\.md|\.tad/active/epics/EPIC-20260804-lite-as-tad-body\.md|NEXT\.md|\.tad/evidence/journal/.*)$'
  ```
  期望：无输出。**并在 Completion 附 `git status --porcelain` 全文**（捕获未提交改动）

- **AC7** 新内容确实到达 `.agents/` 镜像且字节一致（R1 P1-1）
  ```
  for f in alex-lite blake-lite; do
    grep -Fq '## 约束准入' .agents/skills/$f/SKILL.md || echo "AC7 FAIL AGENTS-MISSING $f"
    cmp -s .claude/skills/$f/SKILL.md .agents/skills/$f/SKILL.md || echo "AC7 FAIL DIFF $f"
  done
  bash .tad/hooks/lib/release-verify.sh parity .
  ```
  期望：无 FAIL 输出；parity 判定行贴进 Completion 作为 provenance 证据

- **AC8** NO-CARRIER 的对称求证（R1 P0-2 新增）
  每一行 NO-CARRIER，Completion 必须附一次**主动反证搜索**记录：
  搜索命令（建议 `grep -ril '{关键词}' .tad/evidence/ .tad/logs/`）+ 实际输出 + 结论。
  期望：NO-CARRIER 行数 == 反证搜索记录条数；**无记录的 NO-CARRIER 不得成立**

---

## 6. 风险与注意

1. ⚠️ **本机 `/usr/bin/awk` 无法比较中文字符串**（R1 P2-1，实测）：
   `awk 'BEGIN{a="身份"; b="精髓"; print (a==b)}'` → **1**。含 >127 字节的串被当作数值 0，
   **任意两个不同中文串都相等**。`-v` / `ENVIRON` / 字面量 / `(x "")` 强转全部受影响。
   **禁止用 awk 做任何列的字符串相等判断**——用 `grep -Fx`。
   AC6a 里仅剩的 awk 只做 `$1`/`$2` 数值比较，安全。

2. **AC 自踩措辞**：新节含 `MUST` `禁止` 等词，任何全文计数类 AC 会被自己撑爆。
   本单已用 AC6a 纯插入断言替代计数断言——**不要在实现中反向引入计数类自检**。

3. **`.agents/` 只能经 `bash .tad/hooks/lib/release-verify.sh parity --fix .` 生成**，
   不得手工 cp（canonical-first 纪律）。

4. **提交范围**：只 `git add` AC6b 授权集里的路径，**禁止 `git add -A`**
   （仓库有大量与本单无关的未提交项）。`git push` 禁止。

5. **不要顺手修**核验中发现的其它问题——记进 Completion 的 follow-up，
   由 Epic P2/P3 处理（Epic 执行约束第 3 条：一次一件）。
   已知 follow-up 候选：R1 P2-1 的 awk/CJK 发现值得进 `patterns/shell-portability.md`（本单不做）。

6. **本单命中升级清单第 2 类**（`.claude/skills/*/SKILL.md`）→ 走 full。
   Epic 明确记录的「刻意的最后几次 full 使用」之一，不绕过、不造特例。

---

## 7. Definition of Done

AC1–AC8 全 PASS（含开工前的全 FAIL 判别力自检）+ Layer 2 ≥2 distinct reviewers +
Gate 3 PASS + Completion 落盘（含本 phase 实际 token 消耗，Epic 执行约束第 5 条）。

`git commit` 允许（仅 AC6b 授权集），**`git push` 禁止**。

---

## 8. R1 Audit Trail

R1 两名 reviewer（code-reviewer + bug-hunter）共 **7 P0 / 6 P1**，全部整合：

| 编号 | 问题 | 修法 |
|---|---|---|
| P0-1(bh) | PROVISIONAL 到期无触发点 → 闸是空的 | 决策 2：同一动作挂 NEXT.md |
| P0-2(bh) | NO-CARRIER 无对称求证义务，而 P2 据此删除 | 新增 AC8 主动反证搜索 |
| P0-1(cr) | AC3 grep 整行未锚定「节」列 → 2 行台账可假称 34 节全覆盖 | AC3 改 `cut -f3,4` + `grep -Fxq` |
| P0-2(cr) | 新节自身被计入 → 34 vs 32，正确实现反而 FAIL | 决策 4：闸给自己定价，改 34 |
| P0-3(cr) | AC6 空输出即 PASS；commit 后 HEAD 移动再次 PASS；无范围围栏 | 拆 AC6a/AC6b + 钉死 BASE sha |
| P0-4(cr) | AC4/AC5a 无可运行命令，且无 grep 锚约定 | §4.1 反引号锚约定 + 两条一行命令 |
| P0-5(cr) | §4.2 的 `HAS-CARRIER but SUPERSEDED` 不在 AC5 封闭集内 | 状态记 `SUPERSEDED`，载体留在载体路径列 |
| P1(bh) | 缺命名化反合理化钩子 | §4.1 反合理化段 |
| P1(bh) | 台账自身增长治理豁免未言明 | 决策 3 |
| P1-1(cr) | AC7 实现前即 PASS | 增加"新内容到达镜像"断言 |
| P1-2(cr) | AC3 `miss=0` 死代码，块恒 exit 0 | 改 `out=$(...)` 捕获 |
| P1-3(cr) | 协议文本 3 态 vs AC 6 态，无判别规则 | §4.1 六态完整定义 |
| P1-5(cr) | 载体是目录且 violations.log 路径错 | 改 `.tad/logs/violations.log` + 警告失败模式可能不匹配 |
| P1-6(cr) | §6 脏文件清单过期 | 改为"只 add AC6b 授权集" |

**Alex 自审补漏（v2 落盘后实测，非 reviewer 提出）**：
按 R1 建议逐条空跑 v2 的 9 条 AC 确认实现前全 FAIL 时，发现 **AC4/AC5 在台账不存在时
空输出即假 PASS**——我把 R1 刚在 AC6/AC7 抓到的「空跑漏洞」原样复制进了新写的 AC4/AC5。
已加 `[ -s "$LEDGER" ]` 前置断言。**教训：修复某个缺陷类时，必须横向扫同一批新写的
兄弟 AC，否则病灶原地转移。**

**未整合（判为 Epic 层，非本单）**：R1 建议在 Epic P4 实测里加一项——
测「添加一条新约束平均花多少 token」，把闸自身的边际单价纳入 SC2。
理由充分（引 TAD 自身 `Measure Before Optimizing` 原则），已记入 Epic 待办，本单不扩范围。
