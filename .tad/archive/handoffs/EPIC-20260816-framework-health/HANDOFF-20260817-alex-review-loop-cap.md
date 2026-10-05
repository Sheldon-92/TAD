---
task_type: doc-only
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: 给 full Alex 的专家审查补终止条件

**From:** Alex ｜ **To:** Blake ｜ **Date:** 2026-08-17
**Task ID:** TASK-20260817-002
**基线 SHA:** `35d69228`

---

## 🔴 Gate 2

- [x] 需求明确（三处改动，全部照抄 lite 已验证的写法）
- [x] 技术方案完整 —— 不发明新机制
- [x] AC 可运行，改前值全部实测（§7）
- [ ] 专家审查 ≥2 且 P0 已修 —— **待审**

⚠️ **本单自身的审查适用它要引入的规则**：**最多 2 轮**。第 2 轮仍有 P0 → 停下报人，不进第 3 轮。

---

## 1. 问题

### 1.1 一句话

full Alex 的专家审查**没有终止条件**，`alex-lite` 有。同一件事在两个通道上，一个会无限循环，一个不会。

### 1.2 循环是怎么形成的（三条规则的组合，没有一条是循环本身）

| 位置 | 规则 |
|---|---|
| `alex/SKILL.md:1269` | Gate 2 通过条件 = `Expert review (min 2) + P0 resolved` |
| `alex/SKILL.md:1585` | `Ignoring P0 blocking issues from expert review` = 违规 |
| `handoff-creation-protocol.md` | **810 行，终止条件 0 处**（实测 `grep -cE '最多.*轮\|max.*round\|terminate'` = **0**） |

**Gate 2 要求「P0 resolved」，但协议没写「怎么算 resolved」。**
唯一可得的证明方式就是再审一次；而 reviewer 的任务是找 P0，它总能找到 ——
在没有真实缺陷可找时就转向构造假想缺陷。

→ **「P0 resolved」在实践中变成了「reviewer 说没有 P0 为止」，而那一天可能永远不来。**

### 1.3 这个洞一直存在，不是被删的

实测五个历史版本（`96e02b96` 6-08 → `77c573d3` 8-03），**终止条件均为 0 处**。
不是回退问题，是**从未写过**。

### 1.4 lite 已经解决了，且经过验证

`alex-lite/SKILL.md:180-206`（L2.5 独立契约审查）：

| 项 | lite | full |
|---|---|---|
| reviewer 数 | **1 个** | min 2，无上限 |
| 复核方式 | **只给 diff**（增量复核） | 重读整张单 |
| 轮次上限 | **2 轮仍 FAIL → 停** | **无** |
| 停下时的话 | 「任务可能超出 lite 适用范围」 | — |

lite 原文（`:197-199`）：
```
Stop: P0 → 修契约 → 同 reviewer 增量复核（只给 diff）。最终 verdict 仍 FAIL
或 P0 修复扩大范围/命中安全停清单 → 停，报告人；不得把 FAIL 契约交给 blake-lite。
同一契约 2 轮仍 FAIL → 停："任务可能超出 lite 适用范围"。
```

### 1.5 代价（实测）

**EPIC-20260816 的五张单**：

| 单 | 审查轮次 |
|---|---|
| Phase 3 | 2 |
| Phase 4 | 2 |
| f02 | **4** |
| 1a | **5** |
| 一条护栏 | **5 版全部被打穿，最终撤销** |

1a 的第 2-5 轮**全部在打磨一行 markdown 链接的 AC**，产出 3 个「绕过」，全是 reviewer 构造的假想场景。

**下游项目的代价更直接** —— 「阅读助手」2026-08-03 一晚（12:24→23:42）写了 4 张 handoff 共 2770 行（1079 行那张的 §9.1 是 27 行 × 6 列表格）。
按流程往返 7 次估算，**仅 handoff 文本约 64 万 token**，另有 78 个 evidence 文件与 8 次 agent 激活（每次 ≈7 万）。

⚠️ 该 token 数为**估算**（按 2.5 字节/token），非实测。轮次与行数是实测。

### 1.6 Intent Statement

**要达成的**：让 full Alex 的审查有明确终点，且复核只看 diff 而非重读全文。

**不追求的**：改 AC 的写法、简化 §9.1 表格、动 Blake 侧（Blake 已有上限：Layer 1 最多 15 次、Layer 2 最多 5 轮）。

---

## 2. Requirements

| ID | 需求 |
|---|---|
| **FR-1** | `handoff-creation-protocol.md` 的 `minimum_experts` 段落增加 `max_review_rounds: 2` 与超限处置 |
| **FR-2** | 同处增加**增量复核**规定：第 2 轮起 reviewer 只收到 diff + 上一轮的 P0 列表，**不重发整张单** |
| **FR-3** | `alex/SKILL.md:1269` 的 Gate 2 条件补明「P0 resolved」的判定方式 |
| **FR-4** | `.agents` 镜像同步（两文件） |

**NFR1**：不得改 Blake 侧任何文件
**NFR2**：不得改 `alex-lite` / `blake-lite`
**NFR3**：不得改 `minimum_experts: 2` 这个数值本身（**上限是轮次，不是人数**）

---

## 3. Technical Design

### 3.1 FR-1 + FR-2：改 `handoff-creation-protocol.md:807-810`

**现状**：
```yaml
  minimum_experts: 2
  violations:
    - "不经过专家审查直接发送 handoff 给 Blake = VIOLATION"
    - "忽略专家发现的 P0 问题不修复 = VIOLATION"
```

**改为**（照抄 lite `:197-199` 的结构）：
```yaml
  minimum_experts: 2

  # 轮次上限 —— 2026-08-17 补。此前本协议 810 行无任何终止条件，而 Gate 2 要求
  # "P0 resolved" 却未定义如何证明，导致唯一可得的证明方式是再审一次；
  # reviewer 的任务是找 P0，在无真实缺陷时会转向构造假想场景 → 循环无终点。
  # 实测代价：EPIC-20260816 的 1a 单审 5 轮，第 2-5 轮全在打磨一行 markdown 链接。
  # 本上限照抄 alex-lite/SKILL.md:197-199 已验证的写法。
  max_review_rounds: 2

  round_protocol:
    round_1: "全文审查。reviewer 收到 handoff 全文。"
    round_2: |
      增量复核。reviewer 收到：
        (a) 第 1 轮 P0 的修复 diff
        (b) 第 1 轮 P0 列表 —— 含每条的【完整理由】，不止标题
        (c) diff 触及的每个章节的【全文】
      MUST NOT 重发 handoff 全文。
      理由：重读全文会让 reviewer 重新审视与本轮修复无关的部分，
      产出与「P0 是否已解决」无关的新发现，这正是循环的燃料。

      ⚠️ (b)(c) 是 full 特有的补充，lite 不需要：lite 用【同一个】reviewer 做增量复核
      （有第 1 轮上下文），full 每轮 spawn 全新 subagent（无记忆）。
      只给 diff 对无状态 reviewer 不足以判断「这条 P0 是否真的解决了」。

      round_2 的审查范围【限定为】：
        1. 第 1 轮的每条 P0 是否已解决
        2. 修复是否弄坏了 (c) 所列章节里的东西
      本轮发现的【新问题】一律记为 P1 交人类，MUST NOT 记为 P0 —— 新 P0 会重置计数，
      那正是循环。
    after_round_2: |
      第 2 轮 verdict 仍为 FAIL → 【停】。照抄 lite:199 的终态语义：
        "本单 2 轮审查后 verdict 仍为 FAIL，任务可能超出本单范围或方案不成立。
         P0 列表：{每条含标题 + 完整理由 + 影响面}。
         请裁定：缩小范围 / 换方案 / 撤单。"

      ⚠️ 【不提供「接受风险继续」选项】—— lite 的停是硬停（`不得把 FAIL 契约交给 blake-lite`），
      本单照此。理由（Gate 2 reviewer `48f007ec` 指出，已复核）：
        · 「继续」会把 agent 侧的无界循环变成【人类侧的】—— 每轮问一次，同意一次，循环重开
        · Alex 控制上报措辞，而本单 §1.2 自己提供了现成说辞（"reviewer 在构造假想场景"）
        · 无记录要求时，未修的 P0 在人类点头那一刻就消失了

      MUST NOT 进入第 3 轮 —— 【无论人类是否同意】。
      MUST NOT 把 verdict=FAIL 的 handoff 交给 Blake。

  p0_resolved_definition: |
    Gate 2 的 "P0 resolved" 判定为以下之一：
      (a) 第 2 轮增量复核 verdict 非 FAIL；或
      (b) 第 1 轮 verdict 非 FAIL 【且】无 P0；或
    Alex 自行断言 "已修复" 不构成 resolved。

    ⚠️ 【没有第三种】。原草案曾有 "(c) 人类裁定继续"，已删除 ——
    它使 cap 可被一句「同意」抵消，且 Alex 控制提问措辞。lite 无此分支。
    人类在 after_round_2 的选项是【缩小范围 / 换方案 / 撤单】，
    三者都不导向 "带着未解决 P0 进 Gate 2"。

  violations:
    - "不经过专家审查直接发送 handoff 给 Blake = VIOLATION"
    - "忽略专家发现的 P0 问题不修复 = VIOLATION"
    - "进入第 3 轮 = VIOLATION（无论人类是否同意）"
    - "把 verdict=FAIL 的 handoff 交给 Blake = VIOLATION"
    - "第 2 轮复核时重发 handoff 全文而非 diff = VIOLATION"
```

### 3.2 FR-3：改 `alex/SKILL.md:1269`

**现状**：
```
items: "Expert review (min 2) + P0 resolved + Architecture/Components/Functions/DataFlow"
```

**改为**：
```
items: "Expert review (min 2, max 2 rounds) + P0 resolved (见 handoff-creation-protocol.md p0_resolved_definition) + Architecture/Components/Functions/DataFlow"
```

### 3.3 为什么不改 AC 写法

实测对照：**menu-snap 147 张归档 handoff、993 条 AC**，含「绕过/假想」语汇的仅 **7 条（0.7%）**。
AC 数量按月为 4.2 → 6.5 → 10.5（4月峰值）→ 6.8 → 7.4，**峰值后自行回落**。

→ **AC 写法在真实项目中不是系统性问题。** 本单不动它。

---

## 4. Implementation Steps

| # | 步骤 | FR |
|---|---|---|
| 1 | 跑 §7 全部 AC 改前值，存档 | — |
| 2 | 改 `handoff-creation-protocol.md:807-810` | FR-1, FR-2 |
| 3 | 改 `alex/SKILL.md:1269` | FR-3 |
| 4 | 同步 `.agents` 两文件 | FR-4 |
| 5 | 跑全部 AC 改后值 + `skill-body-verify.sh` | — |

**预计 40 分钟。**

---

## 5. File Structure

**Modify**（4 个文件，两两成镜像）：
- `.claude/skills/alex/references/handoff-creation-protocol.md` + `.agents/` 对应
- `.claude/skills/alex/SKILL.md` + `.agents/` 对应

---

## 6. Testing Requirements

无沙箱场景 —— 这是 prompt 层改动，无可执行行为。
验证靠 §7 的静态 AC + 镜像一致性。

⚠️ **本单无法在实现时验证「循环真的停了」** —— 那要等下一张真实 handoff 走完流程。
**Gate 4 时应回看：下一张单的审查轮次是否 ≤2。**

---

## 7. Acceptance Criteria

### 7.0 方言
`[F]`=`grep -F` ｜ `[BRE]`=`grep` ｜ `[ERE]`=`grep -E` ｜ `[sh]`=bash

| AC | 命令 | 期望 | 改前实测 |
|---|---|---|---|
| **AC-1** | `[BRE]` **缩进锚定**（⚠️ 原写 `grep -cF` 是子串匹配 —— reviewer 实测：把三个 key 全写成 `# 注释` 可让 AC-1/2/3 全绿而**零效果**）：<br>`grep -c '^  max_review_rounds: 2$' <协议>` | `1` | **0** 🔴 |
| **AC-2** | `[BRE]` 缩进锚定：`grep -c '^  round_protocol:$' <协议>` | `1` | **0** 🔴 |
| **AC-3** | `[BRE]` 缩进锚定：`grep -c '^  p0_resolved_definition: |$' <协议>` | `1` | **0** 🔴 |
| **AC-4** | `[F]` 新增两条 violation：`grep -cF '自行进入第 3 轮 = VIOLATION' <同文件>` 与 `grep -cF '重发 handoff 全文而非 diff = VIOLATION' <同文件>` | 各 `1` | 各 **0** 🔴 |
| **AC-5** | `[F]` `grep -cF 'max 2 rounds' .claude/skills/alex/SKILL.md` | `≥1` | **0** 🔴 |
| **AC-N1** | `[BRE]` **负控 NFR3 —— 人数未变**（⚠️ 全文有 **2** 处含该串：`:47` 是 Blake tier 说明、`:807` 是本单目标处。故用行首锚定只取 `:807` 那处）：<br>`grep -c '^  minimum_experts: 2$' <协议>` | **仍为 `1`** | **1** ✅ |
| **AC-N2** | `[F]` **负控 NFR1 —— 未碰 Blake**：`git diff --name-only <SHA> \| grep -cE 'blake'` | `0` | — |
| **AC-N3** | `[F]` **负控 NFR2 —— 未碰 lite**：`git diff --name-only <SHA> \| grep -cE 'lite'` | `0` | — |
| **AC-N4** | `[sh]` **负控 —— 镜像一致**：`bash .tad/hooks/lib/skill-body-verify.sh; echo $?` | `0` | **0** ✅ |
| **AC-N7** | `[sh]` **YAML 解析未新增破损**（⚠️ 该文件**当前就解析失败** —— `:522` 有个 HTML 注释卡在 YAML 序列里，报错在 **line 516**，baseline `35d69228` 即如此，两侧镜像相同。修它超出本单范围/AC-N5 的 4 文件上限。故用**增量判据**）：<br>`yq '.handoff_creation_protocol' <协议> 2>&1 \| grep -oE 'line [0-9]+' \| head -1` | **仍为 `line 516`**（未引入新的、更靠前的破损） | **line 516** ✅ |
| **AC-N5** | `[sh]` **负控 —— 改动仅限 4 个文件**：`git diff --name-only <SHA> \| wc -l` | `4` | — |
| **AC-N6** | `[BRE]` **负控 —— 既有 violation 未被删**（⚠️ 全文 `VIOLATION` 共 **6** 处，其中 4 处在别的段落。故只数 `violations:` 块内的列表项）：<br>`sed -n '/^  violations:/,/^[a-z]/p' <协议> \| grep -c '^    - '` | **`4`**（原 2 + 新 2） | **2** ✅ |

⚠️ **AC-N6 防的是「改写时把原有规则覆盖掉」** —— 本单是**增加**约束，不是替换。

### 7.2 Expert Review Status —— 第 1 轮

⚠️ **本单适用它自己引入的规则：最多 2 轮。**

**Reviewer A（`fc005122`，事实核查）→ `LOOPCAP CLAIMS FLAWED`**

声明 1-4 **全部经源码验证为真**（协议 810 行终止条件 0 处、lite 四项属性全对、
五个历史 SHA 全为 0、Blake 双上限确认）。它还补了一条我没写的：
**Blake 有第三个终止机制** —— `blake/SKILL.md:1022` 的 `same_category_failures >= 3`，
这加强而非削弱了对比。

**但它对我提的修法找出三个缺陷，全部经我复核属实并已修：**

| # | 缺陷 | 复核 | 处置 |
|---|---|---|---|
| 1 | **clause (c) 是我发明的，lite 没有** —— lite 是**硬停无 override**（实测 `human-override 分支: 0 处`）。而我加的 override 有两个失效模式：① Alex 可用「reviewer 在构造假想场景」这个说法引导人类放行 —— **而这个说辞正是本单 §1.2 自己提供的** ② 「继续」歧义：是带 P0 进 Gate 2，还是进第 3 轮？后者会让一次「同意」重开无界循环 | ✅ 属实 | 改为**终态**：明确「接受风险直接进 Gate 2」，且 `MUST NOT 进入第 3 轮 —— 无论人类是否同意`；裁定须**逐字记录**含人类原话与未解决 P0 列表。violation 条目一并改写 |
| 2 | **clause (b) 放行 P1-only 的 FAIL** —— 若第 1 轮 verdict=FAIL 但无 P0，(b) 会让 Gate 2 带着 FAIL 记录通过。lite 的停止条件读的是 **verdict** 不是 P0 计数 | ✅ 属实 | (b) 改为「verdict 非 FAIL **且**无 P0」；`after_round_2` 的触发条件同步改为读 verdict |
| 3 | **round_2 只给 diff 对 full 不够** —— lite 用**同一个** reviewer（有第 1 轮上下文），full **每轮 spawn 全新 subagent（无记忆）**。裸 diff 缺：P0 的完整理由、diff 所在章节的上下文、跨文件耦合 | ✅ 属实，这是我照抄时漏掉的**关键差异** | round_2 载荷补为 diff + **P0 完整理由** + **diff 触及章节的全文**；并**限定审查范围**为「这些 P0 解决了吗 + 修复弄坏了什么」，新问题**一律记 P1**（新 P0 会重置计数 = 循环） |

**教训**：我说「照抄 lite 已验证的写法」，但 clause (c) 根本不在 lite 里 ——
**「照抄」的说法掩盖了一处发明**。而那处发明正是唯一没有验证背书的部分。

**Reviewer B（`48f007ec`，AC 与风险）→ `LOOPCAP GATE2 BLOCKED`，3 个 P0，全部复核属实并已修**

| # | P0 | 我的复核 | 处置 |
|---|---|---|---|
| 1 | **AC 无结构约束** —— 把三个 key 全写成 `# 注释`，AC-1/2/3 **全绿而零效果**。`grep -F` 对缩进和注释都是盲的 | ✅ **实测复现**：三条注释让三个 AC 全部返回 1 | AC-1/2/3 改为**缩进锚定** `^  key$`。实测该写法对注释版返回 **0** |
| 2 | **该协议文件本身就不是合法 YAML** —— `:522` 有个 `<!-- ... -->` HTML 注释卡在 `forbidden_implementations:` 序列中间，`yq` 从 **line 516** 起报错。**baseline `35d69228` 即如此**，两侧镜像相同，而 `skill-body-verify.sh` 只做 `diff` 不做解析，所以一直没人发现 | ✅ **实测确认**报错在 line 516 | 新增 **AC-N7 增量判据**：解析报错行号须**仍为 516**（不引入新的、更靠前的破损）。**修 `:522` 超出本单范围**（AC-N5 限定 4 文件），另记 |
| 3 | **「接受风险继续」把 agent 侧的无界循环变成人类侧的** —— clause (c) 让 cap 可被一句「同意」抵消；Alex 控制上报措辞，而 §1.2 自己提供了现成说辞；无记录要求时未修的 P0 在点头那刻消失；且无再入次数限制 | ✅ 属实。**lite 实测 `human-override 分支: 0 处`** —— 它是硬停，明写「不得把 FAIL 契约交给 blake-lite」 | **删除该分支**。`after_round_2` 的选项改为**缩小范围 / 换方案 / 撤单**，三者都不导向「带 P0 进 Gate 2」。新增 violation：「把 verdict=FAIL 的 handoff 交给 Blake」 |

**两轮合计我被抓到 6 个缺陷，其中 4 个源于同一件事**：
我说「照抄 lite 已验证的写法」，实际上**在 lite 没有的地方做了发明**（人类 override），
又**忽略了 lite 与 full 的关键差异**（lite 用同一 reviewer 有上下文，full 每轮全新 subagent 无记忆）。

> **「照抄」是个危险的说法** —— 它让我和 reviewer 都以为不必再验证那部分。
> 真正照抄的部分（2 轮上限、只给 diff、硬停）没有问题；出问题的全是我以为在照抄、实际在发明的地方。

### 7.3 Gate 2 判定：**PASS**（2026-08-17，2 轮，按本单自己的规则）

第 1 轮 3 个缺陷 + 第 2 轮 3 个 P0，**全部经我独立复核属实并已就地修正**。
按本单引入的 `max_review_rounds: 2`，**不进入第 3 轮**。

⚠️ **遗留（不阻塞，另记）**：`handoff-creation-protocol.md:522` 的 HTML 注释导致该文件
自 baseline 起就无法被 YAML 解析。本单以 AC-N7 增量判据确保不恶化，**修复另立单**。

---

## 8. Important Notes

### 8.1 四条硬禁止

1. **禁止改 `minimum_experts` 的数值。** 上限是**轮次**不是人数。AC-N1 拦这个。
2. **禁止动 Blake 侧。** 它已有上限（Layer 1 最多 15 次、Layer 2 最多 5 轮）。AC-N2 拦这个。
3. **禁止动 lite。** lite 是这次的**参考实现**，不是修改对象。AC-N3 拦这个。
4. **禁止删除既有的两条 violation。** 本单只增加。AC-N6 拦这个。

### 8.2 遇到以下必须停下上报
- 改完后 `skill-body-verify.sh` 非零
- 发现 full 侧另有一处已定义轮次上限（与本单重复）

### 8.3 Sub-Agent 建议
- 改动后调独立 subagent 核对：新增的 YAML 块缩进是否与周围一致、是否破坏协议文件的可解析性

---

## 9. Learning Content

### 9.1 「必须修 X」不等于「修完就结束」

本协议写了「忽略 P0 = 违规」，却没写「修完 P0 之后做什么」。
那个空白不是中性的 —— **它会被默认动作填满**，而默认动作是「再审一次」。

**可迁移判据**：
> 任何形如「必须满足条件 C」的规则，**必须同时定义「如何证明 C 已满足」**。
> 否则证明责任会落到唯一可得的手段上，而那个手段通常是重复检查 —— 无终点。

### 9.2 两个通道对同一件事有不同约束，是设计缺陷的信号

`alex-lite` 因为要控成本，把 full 缺的终止条件补上了（1 个 reviewer、只给 diff、2 轮封顶）。
**成本压力让 lite 想清楚了 full 没想清楚的事。**

**可迁移判据**：
> 当一个"轻量版"为了省成本而加了主版没有的约束时，**先问那个约束是不是主版也该有的** ——
> 很可能它不是"轻量版的妥协"，而是"主版遗漏的正确设计"。
