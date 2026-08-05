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
**Task ID:** TASK-20260805-P1a
**Epic:** `.tad/active/epics/EPIC-20260804-lite-as-tad-body.md` — **Phase 1a / 7**
**Handoff Version:** 3.0（范围拆分：原 P1 = 立闸 + 存量审计 → 本单只做立闸）
**BASE**: `31a96aae3332adc87c565d06defff808cc8bef06`

---

## 🔴 Gate 2

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 两处纯插入 + 一个仅含表头的新文件；无脚本、无状态机 |
| Components Specified | ✅ | §4.1 给出协议节全文，六态定义完整 |
| Functions Verified | ✅ | N/A — markdown；8 条 AC 全部实跑验证（实现前全 FAIL + 围栏双向对照） |
| Data Flow Mapped | ✅ | 台账 append-only 单载体；到期日自带于状态列，无跨文件耦合 |
| Expert Review (min 2) | ✅ | 4 轮 / 17 P0 / code-reviewer + 对抗审查，全部 P0 已闭合 |

**Gate 2 结果**: ✅ **PASS**（R4 verdict: PASS；剩余 P1/P2 均为可选修法，已明记为接受的残余风险）
审计轨迹：`.tad/evidence/reviews/2026-08-05-gate2-audit-lite-pricing-gate.md`

**Alex 确认**: 设计要素已验证，Blake 可独立据本文档完成实现。

---

## 1. Task Overview

### 1.1 What We're Building

给两个 lite skill 各加一节「**约束准入**」+ 建立**只有表头的空台账**。

**闸对新增约束立即生效。存量 34 节的回填审计是 P1b，不在本单。**

### 1.2 Why We're Building It

lite 五天七次加固，**加 64 条约束、删 0 条**：协议体量 10,298 → 53,834 字符（5.2×），
干活前固定读取量 ~10K → **~74K 字符**——已追上它当初要逃离的 full 激活固定费（~60K+40K）。

**七次加固每次都是「发现漏洞 → 加约束」，从未问过「这条值不值它的每单成本」。**

### 1.3 为什么本单被拆小（必读）

原 P1 两轮 Gate 2 出了 **13 个 P0**，几乎全部长在「存量审计的机械核验层」。
根因：**「有没有认真找过载体」不是可 grep 的东西**——我每补一个洞就长一个新洞。

本单只保留**机械可验的那一半**：协议文本插入。判断域的那一半（载体核验）移到 P1b，
用 fresh reviewer 抽查验收，不用 grep。

**不是要做的**：
- ❌ 不填台账数据行（P1b）
- ❌ 不删改任何现有约束（P2/P3）
- ❌ 不碰 routing-contract.yaml、full skills、hooks、settings、`/tad-maintain`、NEXT.md
- ❌ 不写脚本、不注册 hook

---

## 2. 关键设计决策

### 决策 1：填不出载体 → PROVISIONAL 带期限，不硬拒

依据 `.tad/project-knowledge/principles.md` → `Mechanical Enforcement Rejected on Single-User CLI`：
单人 CLI 用软约束 + 人审计。硬拒会被合理化绕过；PROVISIONAL + 到期复查给了一条出局路径——
**但它靠"追加台账前先扫"触发，不是后台自动机制**（见决策 2）。

### 决策 2：到期扫描**自包含于台账**，且不声称自动触发（Gate2-R2 P0-E 修复）

**R2 实证推翻了我上一版的修法**：我原本让 PROVISIONAL 同时往 NEXT.md 写到期提醒，
理由是"NEXT.md 每 session 会被读到"。实查——`startup-health.sh` **只 grep 字面量 `## Blocked`**，
且 NEXT.md **不在 CLAUDE.md 的 @import 列表里**。那个钩子根本不会触发。

按我自己在上一版写的判据（"没有触发点 = 闸是空的，且比没有闸更危险，制造自清洁的假象"），
**宣称有、实际不响，是更坏的状态**。故本版：

- 到期日**本来就在**台账状态列（`PROVISIONAL: review-by {date}`）→ 扫台账即得超期清单，**零跨文件耦合**
- **诚实声明没有后台自动机制**——不宣称任何 hook / session 级触发

**但"诚实"不等于"闭合"**（Gate2-R3 对抗审查判 P0，原话：*v1/v2 是假触发=0，v3 是真触发=0，
两者触发概率都是 0，这是同一个空洞换了更诚实的说法*）。故补两个**真会发生**的触发点：

1. **闸内自触发（永久）**：**往台账追加任何行之前，必须先跑一次超期扫描**，
   有超期行先处置再追加。这是自包含的——追加台账行是**唯一保证有人正打开着台账**的时刻，
   且扫描频率正比于它要控制的那个增长率（没人加约束 = 没东西在长 = 不扫也无害）。
2. **Epic 脚手架**：P2–P6 每次起草新 handoff 前扫一次，记入该单 Gate 2 检查表
   （R3 建议：绑定在**Epic 结构本身保证会发生 5 次**的事件上，而非"希望有人想起来"）。

- **复查默认动作 = 删除** + **出口侧反合理化钩子**（Gate2-R3 P1：
  原版只在准入侧有钩子、复查侧一句没有，是不对称的）。
  依据 `AI/Human Judgment Domain Awareness` 的 Rubber Stamp Effect。

### 决策 3：台账 append-only，且其自身增长豁免于本闸

RETIRED 行保留原始理由，使"当初为什么加"可追溯，避免重新发明同一条约束。
**显式豁免**：台账自身增长不受本节纪律约束，不得以"清理台账"擦除历史行。

### 决策 4：闸给自己定价

新增的 `## 约束准入` 节本身也须在台账占一行（P1b 填）。闸付自己的通行费是正确形状。

---

## 3. 📚 Project Knowledge（Blake 必读）

| 路径 | 一行含义 |
|---|---|
| `.tad/project-knowledge/principles.md` → `Mechanical Enforcement Rejected on Single-User CLI` | 单人 CLI 用软约束 + 人审计；决策 1/2 的依据 |
| `.tad/project-knowledge/principles.md` → `AI/Human Judgment Domain Awareness` | Rubber Stamp Effect；决策 2「默认删除」的依据 |
| `.tad/project-knowledge/patterns/ac-verification.md` | AC 判别力：实现前必须 FAIL；负向 regex 会约束禁令自身措辞 |
| `.tad/evidence/journal/lite-capability-complete-2026-07-31.md` | 同一坑原始记录：禁令句含被禁子串会自踩 AC |

---

## 4. 实现规格

### 4.1 「约束准入」节

插入位置：两个 skill 的 `## Forbidden` 节**之前**，逐字节相同。

```
## 约束准入（新增约束前必须定价）

新增或扩大任何 MUST / MANDATORY / BLOCKING / 禁止 / 不得 条目前，
必须先在 .tad/evidence/audits/lite-constraint-ledger.md 追加一行，填齐三项：

1. 每单成本 —— 读几个文件 / 写几个字段 / spawn 几次 / 几轮人机往返
2. 挡什么失败模式 —— 具体到可复现的失败，不写"提升质量"类空话；
   结尾附一个反引号包裹的逐字 grep 锚（例：…AC principal 缺陷穿透自审 `AC principal`）
3. 载体路径 —— journal / 研究文件 / .tad/logs/violations.log 中的真实事故位置

状态六态（取值封闭，不得自创）：
- HAS-CARRIER          三项齐全且载体已核验命中
- NO-CARRIER           已主动搜索确认无载体（P2/P3 砍除名单来源）
- PROVISIONAL: review-by {YYYY-MM-DD}   载体待补，期限 = 记录日 +90 天
- SUPERSEDED           有载体但已被更高层裁定退场（载体仍填载体路径列）
- RETIRED              已删除该约束（追加行，不擦除原行）
- N/A: {原因}          该节无约束条目

到期复查（追加台账行前的强制前置动作）：
往台账追加任何行之前，先跑一次超期扫描，有超期行先处置再追加——

  awk -v t="$(date +%F)" '/review-by/ {
    if (match($0, /review-by [0-9-]+/)) {
      d = substr($0, RSTART+10, 10); if (d < t) print "OVERDUE: " $0 } }' \
    .tad/evidence/audits/lite-constraint-ledger.md

（此处 awk 只比较 ISO 日期，纯 ASCII，不受本机 awk 的中文比较缺陷影响——勿改成别的写法。）

扫描结果（有/无超期）随该次追加一并写进备注列或 Completion——
否则事后无法区分"扫过、确认无超期"与"根本没扫直接追加"。

没有后台自动机制：本框架不声称任何 hook / session 级触发。触发点只有两个——
上述"追加前先扫"，以及各 Epic phase 起草新 handoff 前的人工扫描。

已知残余风险（明记，不假装已解决）：以上两个触发点都绑在"有人动台账"或
"Epic 还在跑"上。若台账长期无追加且 Epic 已结束，到期扫描退回依赖人工记忆——
而低增长正是本框架追求的稳态，即**机制在它成功时最弱**。
接受为软约束系统的固有代价，不做进一步机械化。

复查默认动作 = 删除：无新载体证据即 RETIRED，不需额外论证。

反合理化（准入侧）：把"这条明显必要""先加后补""改动很小"视为触发 PROVISIONAL 的信号，
而不是跳过闸的理由。凡未当场翻开台账追加行的新增 MUST/BLOCKING，一律视为未过闸。

反合理化（复查侧）：把"这条明显还需要""有隐性证据只是没写下来""太重要不能删"
视为跳过默认删除动作的信号，而不是保留的正当理由。保留（改判 HAS-CARRIER / SUPERSEDED）
必须附可 grep 验证的新增载体，否则一律执行 RETIRED。

本节自身也须在台账中占一行（闸付自己的通行费）。
台账自身的增长豁免于本节纪律——append-only 是为审计可追溯，不得以"清理台账"擦除历史行。
```

⚠️ **以下 14 个字面量不在"措辞可优化"范围内**，必须逐字出现（AC1 逐条断言）：
`## 约束准入` / `每单成本` / `挡什么失败模式` / `载体路径` /
`HAS-CARRIER` / `NO-CARRIER` / `PROVISIONAL: review-by` / `SUPERSEDED` / `RETIRED` /
`追加台账行前的强制前置动作` / `没有后台自动机制` / `复查默认动作 = 删除` /
`反合理化（准入侧）` / `反合理化（复查侧）`

### 4.2 空台账 `.tad/evidence/audits/lite-constraint-ledger.md`

全文如下（**表头 + 说明，无数据行**——数据行是 P1b）：

```
# Lite 约束定价台账

> 由 Epic `EPIC-20260804-lite-as-tad-body` P1a 建立。
> 新增约束的定价规则见 alex-lite / blake-lite 的「约束准入」节。
> append-only：删除约束也追加 RETIRED 行，不擦除历史行。
> 存量 34 节的回填审计由 P1b 完成。

| 日期 | skill | 节 | 约束摘要 | 每单成本 | 挡什么失败模式 | 载体路径 | 状态 |
|---|---|---|---|---|---|---|---|
```

分隔行必须逐字为 `|---|---|---|---|---|---|---|---|`（8 列，无对齐冒号、无填充空格）。

---

## 5. Acceptance Criteria

> 全 7 条在实现前必须 FAIL。Blake 开工**前**先跑一遍确认全 FAIL，结果记入 Completion。
> 任一条实现前就 PASS = 该 AC 无效，停，报告 Alex。
>
> **AC5/AC6 需要开工前快照**，务必先执行 §5.0。

### 5.0 开工前快照（先做，否则 AC5/AC6 无法判定）

```bash
S=.tad/evidence/acceptance-tests/lite-pricing-gate-protocol
BASE=31a96aae3332adc87c565d06defff808cc8bef06
mkdir -p "$S"; rm -f "$S/sec-alex-lite.txt" "$S/sec-blake-lite.txt"
# ↑ 逐个列名而非 glob：zsh 对无匹配的 glob 直接报错，`rm -f` 压不住（本机实测）

# 授权集：定义一次，AC5/AC6 共用。
# （Gate2-R3 P0-1/P0-3 根因：两份分叉的名单——git add 会把路径从 untracked 挪进 tracked，
#   而 §7 要求的 COMPLETION 报告当时还不存在，两份名单都没覆盖。）
cat > "$S/allow.txt" <<'ALLOWEOF'
^(\.claude/skills/(alex|blake)-lite/SKILL\.md|\.agents/skills/(alex|blake)-lite/SKILL\.md|\.tad/evidence/audits/lite-constraint-ledger\.md|\.tad/evidence/acceptance-tests/lite-pricing-gate-protocol/.*|\.tad/evidence/journal/.*|\.tad/evidence/reviews/.*|\.tad/archive/handoffs/.*)$
ALLOWEOF

git diff --name-only "$BASE" | LC_ALL=C sort > "$S/tracked-before.txt"
git -c core.quotePath=false status --porcelain --untracked-files=all \
  | grep '^??' | cut -c4- | LC_ALL=C sort > "$S/untracked-before.txt"

# 预存在脏 tracked 文件的内容基线（AC5b 用；差分围栏看不见对它们的后续改动）
if [ -s "$S/tracked-before.txt" ]; then
  git diff "$BASE" -- $(tr '\n' ' ' < "$S/tracked-before.txt") | shasum > "$S/tracked-before.sha"
else : > "$S/tracked-before.sha"; fi
```

⚠️ **用差分而非绝对清单**：仓库现有 3 个已脏 tracked 与 **800+** 个 untracked 文件
（确切数以快照当时实测为准，本设计是差分不依赖绝对值），
均与本单无关（Gate2-R2 P0-B/P0-C）。绝对清单断言必然误报，**Blake 不得代人提交或清理它们**。

⚠️ **已知盲区（Gate2-R3 P1-1，如实记录）**：`comm -13` 只检出**新增路径**，
对已在 before 集里的文件的**后续修改**不可见。
- **tracked 侧（3 个）已由 AC5b 内容哈希完全覆盖**——这三个正是 `NEXT.md`、
  `patterns/ac-verification.md`、`patterns/gate-design.md`，即"善意的 Blake 最可能顺手去动"的文件，
  而 §1.3 明令禁止碰 NEXT.md。
- **untracked 侧（约 848 个）为已知盲区**，逐个哈希不成比例；靠 §6.5 纪律
  + Completion 里的 porcelain 全文人审兜底。**不隐瞒、不假装覆盖。**

⚠️ 快照文件会把**自己**列进 untracked-before（shell 先创建重定向目标再跑 `git status`）——
无害，因为 `$S/.*` 在授权集内。**勿"修正"此现象。**

- **AC1** 两个 skill 均含约束准入节与全部 14 个字面量
  ```bash
  for f in .claude/skills/alex-lite/SKILL.md .claude/skills/blake-lite/SKILL.md; do
    for s in '## 约束准入' '每单成本' '挡什么失败模式' '载体路径' 'HAS-CARRIER' 'NO-CARRIER' \
             'PROVISIONAL: review-by' 'SUPERSEDED' 'RETIRED' '追加台账行前的强制前置动作' \
             '没有后台自动机制' '复查默认动作 = 删除' '反合理化（准入侧）' '反合理化（复查侧）'; do
      grep -Fq "$s" "$f" || echo "AC1 FAIL [$f] $s"
    done
  done
  ```
  期望：无输出（实现前应 28 条 FAIL）

- **AC2** 约束准入节的**位置正确**且两 skill **逐字节相同**
  （Gate2-R3 P0-2：原版用 `sed '$d'` 截尾——缺少结尾锚点时会静默吃掉一行真内容，
  且**没有任何 AC 校验插入位置**，"位置放错但两边对称"可以全绿通过）
  ```bash
  S=.tad/evidence/acceptance-tests/lite-pricing-gate-protocol
  rm -f "$S/sec-alex-lite.txt" "$S/sec-blake-lite.txt"   # 勿用 glob：zsh 无匹配即报错
  for f in alex-lite blake-lite; do
    SK=.claude/skills/$f/SKILL.md
    a=$(grep -n '^## 约束准入' "$SK" | cut -d: -f1)
    b=$(grep -n '^## Forbidden' "$SK" | cut -d: -f1)
    { [ -n "$a" ] && [ -n "$b" ] && [ "$a" -lt "$b" ]; } \
      || { echo "AC2 FAIL 位置 [$f] a=$a b=$b"; continue; }
    sed -n "$a,$((b-1))p" "$SK" > "$S/sec-$f.txt"
  done
  cmp "$S/sec-alex-lite.txt" "$S/sec-blake-lite.txt" 2>/dev/null \
    || echo "AC2 FAIL: 两 skill 的约束准入节不一致或缺失"
  [ -s "$S/sec-alex-lite.txt" ] || echo "AC2 FAIL: 节为空 (alex)"
  [ -s "$S/sec-blake-lite.txt" ] || echo "AC2 FAIL: 节为空 (blake)"
  ```
  期望：无输出
  ⚠️ 本条只做**两 skill 互比**，不比对 §4.1 规格原文——"两边一致但都错"由 AC1 的
  14 个字面量兜底（Gate2-R3 P2-3 残余，已知并接受）

- **AC3** 空台账存在、表头与分隔行逐字正确、**且无数据行**
  ```bash
  L=.tad/evidence/audits/lite-constraint-ledger.md
  [ -s "$L" ] || { echo "AC3 FAIL: ledger missing/empty"; exit 1; }
  grep -Fq '| 日期 | skill | 节 | 约束摘要 | 每单成本 | 挡什么失败模式 | 载体路径 | 状态 |' "$L" || echo "AC3 FAIL: 表头"
  grep -Fxq '|---|---|---|---|---|---|---|---|' "$L" || echo "AC3 FAIL: 分隔行"
  n=$(grep -cE '^\|[^-]' "$L"); [ "$n" -eq 1 ] || echo "AC3 FAIL: 应仅表头 1 行，实为 $n"
  ```
  期望：无输出
  （`^\|[^-]` 而非 `^| `：后者漏掉无空格写法 `|2026-08-05|alex-lite|…`，Gate2-R3 P2-1 实测）

- **AC4** 两个 skill 为纯插入：恰好 2 行、零删除、有新增
  ```bash
  git diff --numstat 31a96aae3332adc87c565d06defff808cc8bef06 \
    -- .claude/skills/alex-lite/SKILL.md .claude/skills/blake-lite/SKILL.md \
  | awk 'BEGIN{n=0} {n++; if($2!="0") bad=1; if($1+0==0) bad=1} END{if(n!=2||bad) print "AC4 FAIL"}'
  ```
  期望：无输出

- **AC5** tracked 围栏：BASE 以来**新增**的改动文件全在授权集内
  ```bash
  S=.tad/evidence/acceptance-tests/lite-pricing-gate-protocol
  BASE=31a96aae3332adc87c565d06defff808cc8bef06
  ALLOW=$(cat "$S/allow.txt")
  git diff --name-only "$BASE" | LC_ALL=C sort > "$S/tracked-after.txt"
  comm -13 "$S/tracked-before.txt" "$S/tracked-after.txt" | grep -vE "$ALLOW"
  ```
  期望：无输出
  ⚠️ 授权集必须是 AC5/AC6 **共用**的那一份——`git add` 会把台账从 untracked 挪进 tracked，
  两份分叉的名单会让"按 §6.5 正常提交"直接踩 FAIL（Gate2-R3 P0-1 实证）

- **AC5b** 预存在脏 tracked 文件（3 个）内容未被改动（补差分围栏的盲区）
  ```bash
  S=.tad/evidence/acceptance-tests/lite-pricing-gate-protocol
  BASE=31a96aae3332adc87c565d06defff808cc8bef06
  if [ -s "$S/tracked-before.txt" ]; then
    git diff "$BASE" -- $(tr '\n' ' ' < "$S/tracked-before.txt") | shasum > "$S/tracked-after.sha"
  else : > "$S/tracked-after.sha"; fi
  cmp -s "$S/tracked-before.sha" "$S/tracked-after.sha" || echo "AC5b FAIL: 预存在脏文件被改动"
  ```
  期望：无输出

- **AC6** untracked 围栏：新增的未跟踪文件全在授权集内
  （`git diff` 完全看不见未跟踪文件，故必须单独一条）
  ```bash
  S=.tad/evidence/acceptance-tests/lite-pricing-gate-protocol
  ALLOW=$(cat "$S/allow.txt")
  git -c core.quotePath=false status --porcelain --untracked-files=all \
    | grep '^??' | cut -c4- | LC_ALL=C sort > "$S/untracked-after.txt"
  comm -13 "$S/untracked-before.txt" "$S/untracked-after.txt" | grep -vE "$ALLOW"
  ```
  期望：无输出
  （`core.quotePath=false`：默认 true 时非 ASCII 文件名会被转义成 `"\346…"` 从而绕过
  授权集正则导致误判，Gate2-R3 P2-5）

- **AC7** 新内容到达 `.agents/` 镜像且字节一致
  ```bash
  for f in alex-lite blake-lite; do
    grep -Fq '## 约束准入' .agents/skills/$f/SKILL.md || echo "AC7 FAIL AGENTS-MISSING $f"
    cmp -s .claude/skills/$f/SKILL.md .agents/skills/$f/SKILL.md || echo "AC7 FAIL DIFF $f"
  done
  bash .tad/hooks/lib/release-verify.sh parity .
  ```
  期望：无 FAIL 输出；parity 判定行贴进 Completion 作为 provenance

---

## 6. 风险与注意

1. ⚠️ **本机 `/usr/bin/awk` 无法比较中文字符串**（Gate2-R1 实测）：
   `awk 'BEGIN{a="身份"; b="精髓"; print (a==b)}'` → **1**。含 >127 字节的串被当作数值 0，
   **任意两个不同中文串都相等**。`-v` / `ENVIRON` / 字面量 / `(x "")` 强转全部受影响。
   **禁止用 awk 做任何字符串相等判断**——用 `grep -Fx` / `cmp`。
   AC4 里仅剩的 awk 只做 `$1`/`$2` 数值比较，安全。

2. **含反引号的 AC 建议存成 `.sh` 再 `bash` 执行**（Gate2-R2 P2-B 的操作性观察），
   把脚本与输出一并贴进 Completion。

3. **AC 自踩措辞**：新节含 `MUST` `禁止` 等词，任何全文计数类 AC 会被自己撑爆。
   本单已用 AC4 纯插入断言替代计数断言——**不要在实现中反向引入计数类自检**。

4. **`.agents/` 只能经 `bash .tad/hooks/lib/release-verify.sh parity --fix .` 生成**，
   不得手工 cp（canonical-first 纪律）。

5. **提交范围**：只 `git add` `$S/allow.txt` 里的路径，**禁止 `git add -A`**。
   仓库有 3 个已脏 tracked + 约 848 个 untracked 与本单无关，**不得代为提交或清理**。
   `git push` 禁止。

5b. **围栏必须双向自测**（Gate2-R3 点名的 positive-control 纪律）：
   除了"种一个禁区文件确认被抓"（负向），还必须"创建台账并 `git add` 后确认 AC5 保持静默"（正向）。
   **只测负向会漏掉授权集写漏的那一类缺陷**——R3 的 P0-1/P0-3 正是这么漏的。

6. **不要顺手修**核验中发现的其它问题——记进 Completion 的 follow-up。
   已知候选（本单不做）：awk/CJK 发现值得进 `patterns/shell-portability.md`。

7. **本单命中升级清单第 2 类**（`.claude/skills/*/SKILL.md`）→ 走 full。
   Epic 明确记录的「刻意的最后几次 full 使用」之一。

---

## 7. Definition of Done

AC1–AC7 全 PASS（含开工前全 FAIL 判别力自检）+ Layer 2 ≥2 distinct reviewers +
Gate 3 PASS + Completion 落盘（含本 phase 实际 token 消耗）。

`git commit` 允许（仅授权集），**`git push` 禁止**。

---

## 8. Gate 2 审计（4 轮，v1–v4）

完整轨迹见 `.tad/evidence/reviews/2026-08-05-gate2-audit-lite-pricing-gate.md`
（4 轮 / 17 P0 / 两名 reviewer 的原始判据与实证）。作废的 v2 契约在
`.tad/archive/handoffs/withdrawn/HANDOFF-20260804-lite-pricing-gate.md`。

**Blake 只需记住两条教训**（都是为了不让缺陷在实现阶段复活）：

1. **同一缺陷家族会连跳**：AC4/AC5 的"无可运行命令 → 空输入即假 PASS → 未绑定变量恒 FAIL"
   跳了三次。**修一类缺陷时必须横向扫同一批兄弟**，否则病灶原地转移。
2. **围栏要双向测**：只测"拦得住违规"会漏掉"放不过合法交付"——
   Gate2-R3 的两个 P0 正是这么漏的（见 §6.5b）。
