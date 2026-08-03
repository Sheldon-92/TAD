# TAD 在后脚手架时代的评估

> **日期**: 2026-07-27
> **触发**: Anthropic 为 Opus 5 / Fable 5 世代削减 Claude Code 系统提示 ~80%，公开理由为"信任模型判断"。
> 由此产生的问题：TAD 是否过重？应如何迭代？
> **研究者**: Alex (Agent A)，`*discuss` 路径
> **状态**: 结论已出。对抗审查部分降级（见 §8）。

---

## 0. 一句话结论

**TAD 的门禁与角色分离有实证支持，应保留；TAD 不是成本问题的来源（实测比不用 TAD 更便宜）；真正该砍的是内部自我重复、对原生能力的禁令、和已失效的文档；唯一有硬证据支持的强化点是"验收标准必须写清楚谁来判"。**

---

## 1. 研究问题

原始问题有三层，逐层澄清：

1. Anthropic 删掉 80% 系统提示，这对 TAD 意味着什么？
2. TAD 是否太重、太耗 token，该不该瘦身？
3. （用户中途澄清，取代前两问）**TAD 里什么重要、什么不重要，什么该保留强化、什么该砍掉。目标不是瘦身。**

第 3 问是本研究实际回答的问题。

---

## 2. 方法与数据源

### 2.1 一手实测

| 数据源 | 规模 |
|---|---|
| Claude Code 会话记录（含完整 token usage） | 36 个项目，**85,017 轮**，含 `cache_creation` / `cache_read` / `output` |
| TAD 仓库结构 | 4,830 tracked files，658M |
| 跨项目 TAD 安装 | **30 个项目**，版本 1.5 → 2.34 |
| 归档产物 | 520 handoff · 68 Epic · 6 取消（取消率 1.1%）|
| 审查证据（全屋智能化） | 184 份 review 文件 / 54 个完成任务 |
| TAD trace | 2,936 events（2026-04-02 → 07-14）|

### 2.2 既有内部研究（本次复用）

- `.tad/evidence/research/gate-roi-measurement-2026-07.md` — 门禁收益测量（**本次研究一度遗漏，由 Codex 对抗审查指出**）
- `.tad/evidence/research/claude-native-capabilities/` — 112 机制清单 + 与原生能力的重叠矩阵（2026-07-12）

### 2.3 外部证据

WebSearch / WebFetch 多轮；arXiv 原文 PDF 直读；Codex CLI 对抗审查。
NotebookLM 因账号路由错误（RPC status 5）不可用；Gemini CLI 因免费层停止支持不可用。

---

## 3. 外部证据（四组，互相冲突）

### 组 A — 支持"减少过程规定"

- Anthropic 将 Claude Code 系统提示从 **800 tokens 削减至 164 tokens**，性能无损失（2026-07-02 公布）。
- 团队原话（Simon Willison 炉边对话，2026-07-21）：
  - **"移除例子极其有帮助，因为模型比我们给的例子更有创造力"**
  - **"减少'不要做这个'的指令，因为那对 Claude 是很强的冲动"**
  - Cat Wu：很多指令只有 **"90% 正确"**，边缘情况会害人（他们的例子：要求"总是验证前端改动"，但小文案更新不需要）
- 官方 Fable 5 提示指南：**"为旧模型开发的 skill 往往对 Fable 5 过度规定，会降低输出质量"**
- Context rot 实证：18 个前沿模型，输入变长时准确率非均匀下降 **30-50%**，远在上限之前。机制包含 softmax 稀释——**早期定义的安全约束的注意力权重被逐渐摊薄**。

### 组 B — 支持"强制验证"，反驳组 A 的过度推广

**arXiv 2604.17025（CAAF, Zhang 2026），n=20/条件，两个独立领域（汽车安全 / 制药反应器）：**

| 条件 | 正确率 |
|---|---|
| Opus 4 + 高强度思考，无外部断言 | **0%**（20/20 违反同一约束，零方差）|
| 同一个 Opus 4 + 真实工具调用的确定性断言 | **100%** |
| Haiku 4.5（弱模型）+ 完整脚手架 | **100%** |
| Haiku 4.5 + 断言但缺状态锁定 | **0%**（震荡至 max_iters，20/20）|
| 朴素反思循环（错误追加进 prompt 重试） | **0/20 收敛**，在两约束边界间无限震荡 |

论文结论：**"前沿推理在没有外部确定性基础时，会更僵硬地锁死在局部吸引子上，不是更少。可靠性差距是架构性的，不是推理预算的函数。"**

⚠️ 注意第 4 行：**光有确定性断言不够，缺过程/状态脚手架同样是 0%。** 这条反驳"判断全给模型、验证全给代码"的干净二分。

**arXiv 2512.20798（ODCV-Bench）**：40 个多步场景、持久化 bash 环境、12 个 SOTA 模型，结果导向的约束违反率 **1.3% – 71.4%**，其中 **9/12 在 30-50% 之间**。

### 组 C — 限定组 B 的适用范围

- 形式方法立场论文：**"并非所有需求都能在目标形式模型内被形式验证。涉及不可观测属性、定性设计意图、或模型外部现象的需求会被丢弃。"**
- WorkBench：Fable 5 完成 98% 任务，非预期有害行为从 GPT-4 的 26% 降到 **1.9%**——模型确实在变安全，CAAF 的"越强越糟"不能无限外推。
- **CAAF 测的是 Opus 4，不是 Fable 5**（论文 2026-05-04），早于 Fable 5 世代。

### 组 D — 削弱"人在环自动有价值"

- **自动化偏见**：人的监督在时间压力、高负荷、或长期无错运行后退化为橡皮图章。
- 临床实证：医生在 **6%** 的案例中推翻自己**正确**的判断，转而听从错误的软件建议。
- 乳腺 X 光前瞻研究：放射科医生**无论经验高低**都被 AI 建议显著锚定；AI 给错时医生准确率显著下降。
- 人在环有效的**条件**：时间预算够真正审查 · 推理透明可评估 · 激励支持监督而非速度。

### 组 E — Anthropic 自己的 harness 研究（决定性）

Anthropic 在削减系统提示的**同时**，其长时运行应用 harness **保留**了：

| 保留组件 | TAD 对应 | 保留理由（原文）|
|---|---|---|
| Planner Agent | Alex | "没有 planner，generator 会 under-scope——拿到原始 prompt 就开始建，做出的应用功能远不如 planner 的" |
| Evaluator Agent | Gate 3 Layer 2 | "当任务超出当前模型能可靠独立解决的范围时，evaluator 仍有价值" |
| File Handoffs | handoff 文档 | "通信通过文件：一个 agent 写，另一个读并回应" |
| Grading Criteria | rubric | 4 个可测标准，把主观判断变成具体评估 |
| Sprint Contracts | §9.1 AC | 实现前协商定义什么算成功 |

激进简化的结果，原文：**"不可能复制原来的性能。而且变得难以判断 harness 设计的哪些部分是真正承重的。"**

方法论，原文：**"每次移除一个组件，检查它对最终结果的影响。harness 里每个组件都编码了一个关于模型自己做不到什么的假设——这些假设值得压力测试。"**

> **"删 80% 系统提示"与"保留 planner/evaluator/handoff/grading"是同时为真的两件事。**
> 前者删的是**过程规定**（怎么做），后者保留的是**结构与验证**。混淆这两者是本研究前期的主要错误。

---

## 4. 内部测量结果

### 4.1 成本侧（此前从未测量）

全部 36 个项目、85,017 轮真实对话：

```
cache_read   16,566M tokens   $24,849   54%
cache_write     797M tokens   $14,944   33%
output           78M tokens    $5,866   13%
─────────────────────────────────────────────
总计                          $45,661
```

**按项目**：全屋智能化 $15,198 · voice-studio $6,706 · TAD $3,508 · photos management $3,455 · Next Guest $2,000 · my-openclaw-agents $1,882

**关键对照 — 加载 TAD 协议 vs 未加载：**

| 组 | 会话数 | 总轮数 | 每轮读取 | **每千轮成本** |
|---|---|---|---|---|
| 加载了 TAD 协议 | 43 | 32,457 | 222,395 | **$620** |
| 未加载 | 70 | 24,498 | 193,542 | **$684** |

> **TAD 会话每千轮比非 TAD 会话便宜 $64。** 协议使上下文增大 15%，但单位产出成本更低。

**成本的真正驱动是轮数**，稳定在 **≈ $0.7 / 轮**，且无上限：

```
4,788 轮 → $3,173      856 轮 → $591
3,902 轮 → $2,870      788 轮 → $688
```

协议体积是二阶因素（+15% 每轮读取量）；**轮数是一阶因素**。

**上下文饱和**：全屋智能化峰值 **844K tokens**（1M 窗口的 84%），4 个会话峰值 >600K；TAD 自身最高 573K。同样装 TAD，差别来自任务而非协议。

### 4.2 收益侧（复用 2026-07-12 测量）

方法严谨性值得记录：全 census 189 个 COMPLETION，每 7 取 1 = 27 样本；**catch-agnostic 抽样**；**分类前预注册**决策规则；零 catch 行保留为 `none`；证据薄的一律向下归类（故意 bias against gates）。

- 预注册规则：`net-positive iff NC% ≥ 25% AND P01 ≥ 10`
- 实测：**NC% ≈ 59%**（27 个样本中 16-17 个的反事实是"坏掉发布"或"静默劣化"）
- 其中 GR-09 单次抓 23 个缺陷（反事实 = broken-ship），GR-14 抓 11 个（同样 broken-ship）
- **结论：net-positive**
- ⚠️ 报告明确声明：**成本侧未测量**（本研究 §4.1 补上）

### 4.3 AI 互审的实际强度

全屋智能化 54 个完成任务、184 份审查文件：

- **平均每任务 3.4 份审查证据**（≈ 协议规定的下限：code-reviewer + 1 专家 + spec-compliance）
- **P0 提及 670 次 · P1 提及 614 次**
- 抽样内容具体到并发竞态条件分析，非走过场

> 修正：SKILL 文本中 `reviewer`/`judge`/`rubric` 等词出现 327 次，但**实际执行只有 3.4 次/任务**。把文本提及数当执行次数是方法错误。

### 4.4 结构与债务

- `alex/SKILL.md` 101KB（~25K tokens），`blake` 117KB（~29K），`gate` 52KB（~13K）
- **alex 86% 是 YAML，blake 91%**
- 每会话自动加载 34KB（CLAUDE.md + @import），此部分健康
- 112 个机制，其中 **12 处 TAD 内部自我重复**（知识检查 ×3、僵尸检测 ×2、专家审查扇出 ×3、状态持久化 ×2、Reflexion 记录 ×2、研究 preflight ×3、版本检查 ×2、同步机制两代并存）
- **5 处文档描述不存在的系统**：`/tad` 入口停在 v2.5.0（实际 2.34.0）且含 5 个已不存在的命令 · ROADMAP 把 2026-06-10 废弃的 `/playground` 标为 "Stable" · `session-state.md` 指向已归档任务 · CLAUDE.md 声明 8 个 @import 知识文件其中 **5 个不存在** · 12 个空目录
- 30 个项目版本从 1.5 散到 2.34（sync 事实失效）；`project-knowledge` 计数含 25 条来自 README 的举例，需扣除后才是真实积累

---

## 5. 案例：验收标准可执行性的自然对照

**全屋智能化项目，同一操作者、同一周、同一 TAD 版本（2.34.0）、三个 handoff：**

| Handoff | 验收标准的"验证方法" | 规模 | 结果 |
|---|---|---|---|
| `action-integrity-f1-f4-integrated` | `` `ssh homeserver 'test -f /srv/toolbox/CONTRACT.md && ...'` ``，六列表格，区分 pre-impl / post-impl verifiable | **62KB · 875行 · 38 文件 · 20 AC** | **✅ 完成** |
| `f2-mode-layer` | 「改 json 重调验」「dispatch 日志见端口调 F1」「查 snapshot.json + 顺序」 | 21KB · 23 文件 · 11 AC | **❌ 卡 7 天** |
| `aroma-diffuser-levels` | 表头标准，内容为「（pre-impl 已验，见 Dry-Run Log）」 | 22KB · 19 文件 · 15 AC | **❌ 卡 5 天** |

> **最大的 handoff 做完了，两个小的卡住了。变量不是规模，是验收标准能否被机器判定。**

对应的三个症状（用户报告，全部命中）：

| 症状 | 机制 |
|---|---|
| 反复返工 | 「查 snapshot.json + 顺序」每次判定标准漂移，这次过下次不过 |
| 转圈不出结果 | 无可执行判据 → agent 不知道何时算"够了" |
| 卡在等人 | 判不了就上抛 → 但抛给人的是"这样算对吗"（验证题），人也答不上 |

Ralph Loop 状态文件佐证：`layer1_retries` 0-2、`layer2_rounds` 0-1、`consecutive_same_error` **全为 0** —— **不是循环震荡**，是缺少终止判据。任务经历 `design_issue → 退回 Alex → R1 → implementation_issue → reflection_count 4`。

**已有工具为何未拦截**：`.tad/hooks/lib/verify-ac-commands.sh`（158 行，被 alex SKILL 引用）的规则是：

```
Rule A (WARN) — grep -c 管道接 sort -u | wc -l
Rule B (WARN) — grep -E 引号内字面量 \|
Rule D (INFO) — sentinel 自泄漏
```

**它检查"已有命令写得对不对"，不检查"有没有命令"。** 验证方法写成自然语言时，§9.1 区域内零命令，linter 无火可报，静默通过。

> 这在 TAD 自身场景内独立复现了 CAAF 的核心发现（缺确定性边界 → 反思循环不收敛），且**非外推**。

---

## 6. 结论：优化清单

判据：**这个机制有没有证据说明它在起作用。**

### 6.1 保留，不要动

| 机制 | 支撑证据 |
|---|---|
| 四道门禁 | 内部 ROI 测量 NC% 59%（预注册阈值 25%）|
| Alex/Blake 分离 | Anthropic harness 研究保留 planner + evaluator；激进简化失败 |
| Handoff 文件传递 | 同上（"一个 agent 写文件，另一个读"）|
| AI 互审 Layer 2 | 670 P0 / 614 P1；3.4 次/任务已是协议下限，无冗余空间 |
| 反合理化登记（AR-001..005）| 每条对应真实事故；AR-001 那次专家审查抓到 4 个 P0 |
| 苏格拉底提问 | Anthropic 的 planner 保留理由与之同构 |

### 6.2 该砍

| 砍什么 | 理由 |
|---|---|
| **12 处内部自我重复** | 与模型能力无关，纯累积熵。零收益、纯维护成本 |
| **禁用原生的三条禁令**（`/code-review`、`/deep-research`、`EnterPlanMode`）| 成本双份：禁令每 session 注入，被禁能力每 session 存在。且 `/code-review ultra` 已是多 agent 云审查，强于自建链 |
| **5 处失效文档 + 12 个空目录** | 正在向模型描述一个不存在的系统 |
| **sync 推送机制** | 30 个项目版本 1.5→2.34，事实上已废弃 |

### 6.3 该强化（唯一有硬证据的一条）

**验收标准必须声明"谁来判"，且每种判定方式有强制配套：**

| 判定方 | 强制要求 |
|---|---|
| **机器** | 必须有可执行命令（现有 linter 查语法，缺"查存在性"这一条规则）|
| **AI** | 必须指明参照物（对照哪个文件的哪一节）|
| **人** | 必须指明呈现形式，且必须是**选择题不是验证题** |

第三条的正确形态在 `voice-studio` 已存在：`splice-feedback-v7.json` 逐个列出 39 个切点，verdict 为 `early` / `rough`，人只需选不需写判据。
错误形态是当前的 Gate 4"人类确认"：给一份 completion report 问"通过吗"——组 D 的自动化偏见证据表明这必然退化为橡皮图章。

**方法论参照**（Anthropic 原话）：**"每次移除一个组件，检查它对最终结果的影响。"** 不要一次性重写。

### 6.4 不是问题的（澄清误判）

- **协议体积不是成本问题**：TAD 会话 $620/千轮 < 非 TAD $684/千轮
- **成本驱动是轮数**（≈$0.7/轮，无上限），不是协议
- **AI 互审不冗余**：实际 3.4 次/任务，已是下限

---

## 7. 本研究被推翻的假设（完整记录）

九次错误判断，全部由用户、用户自己的数据、或独立模型纠正，**无一次由研究者自我发现**：

| # | 错误判断 | 纠正来源 | 纠正内容 |
|---|---|---|---|
| 1 | "327 处 AI 互审 = 冗余，该砍" | 实测 | 实际执行 3.4 次/任务，是下限；把文本提及数当执行次数 |
| 2 | "流程强制性该放松" | 用户 + 官方文档 | 官方在**加强**结果验证；过程规定与结果验证是两件事 |
| 3 | "零启动项目 = 启动成本过高的信号" | 用户 | 是精力分配，非 TAD 问题 |
| 4 | "两个朋友的案例是对照实验" | 用户 | 平台/预算/配置/任务四个变量同时变，无法归因 |
| 5 | "feedback 数据躺在临时 worktree 里有风险" | 自查 | main 分支内 tracked，路径过滤写错 |
| 6 | "协议加载 67K 是成本大头" | 实测 | cache_read 占 54%，且 TAD 会话单位成本更低 |
| 7 | "全屋智能化卡住 = Ralph Loop 震荡" | 状态文件 | 重试计数全为 0，非震荡 |
| 8 | "卡住 = 任务范围过大" | 自然对照 | 最大的 handoff 做完了，小的卡住 |
| 9 | "judgment 给模型 / verification 给代码"这个干净二分 | Codex 对抗审查 | CAAF 自身 ablation 反驳：断言 + 缺状态锁定 = 0%。过程脚手架仍必需 |

**failure_mode（本研究最重要的方法论产出）**：
> 朴素默认：拿到一个支持某结论的证据，立即推广为架构级判断。为什么错：每次推广都配有表格、数字和证据链，外观上与严谨分析无异，因此**自我审查无法发现**。九次纠正全部来自外部。这正是"模型越强，其错误越像正确"的直接证据，也是门禁与人桥存在的理由。

---

## 8. 局限

1. **对抗审查部分降级**：Gemini CLI 认证失效（免费层停止支持）；NotebookLM RPC status 5（账号路由）。仅 Codex 完成一轮挑战，且该挑战推翻了本研究的核心综合（见 §7 #9），其余结论未经第二模型独立挑战。
2. **CAAF 是单篇非同行评审 arXiv 预印本**，单作者、无独立复现、基准为两个合成工程问题、无 TAD 基线、无真实软件开发基准。ODCV-Bench 为独立佐证但非同一实验。
3. **CAAF 测 Opus 4，非 Fable 5**；组 C 的 WorkBench 数据显示新世代有害行为已降至 1.9%。
4. **成本对照非随机**：TAD 组与非 TAD 组的任务类型未控制；非 TAD 组含大量小型快速会话（读取量低至 9K），可能压低其均值也可能抬高其单位成本。此对照证明"TAD 不显著更贵"，不证明"TAD 更省"。
5. **§5 的自然对照 n=3**，同一操作者单项目单周。方向清晰但样本极小。
6. **优化清单中的"该砍"项均未做移除实验**。按 Anthropic 方法论，应逐个移除并测量，而非批量执行。

---

## 9. 来源

**一手**
- Prompting Claude Fable 5 — https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5
- Anthropic — Harness design for long-running apps — https://www.anthropic.com/engineering/harness-design-long-running-apps
- Cat Wu & Thariq Shihipar 炉边对话（Simon Willison, 2026-07-21）— https://simonwillison.net/2026/Jul/21/cat-and-thariq/

**学术**
- Zhang, T. (2026). *Harness as an Asset: Enforcing Determinism via CAAF*. arXiv:2604.17025
- *A Benchmark for Evaluating Outcome-Driven Constraint Violations in Autonomous AI Agents* (ODCV-Bench). arXiv:2512.20798
- *Position: Trustworthy AI Agents Require the Integration of LLMs and Formal Methods*

**二手**
- Anthropic cut Claude Code's system prompt by ~80% — https://enterprisedna.co/resources/ai-pulse/ai-pulse-2026-07-25-anthropic-cut-claude-code-s-system-prompt-by-80-for-the-opus/
- Claude Opus 5 context engineering: what to delete — https://charlesjones.dev/blog/claude-opus-5-context-engineering-what-to-delete

**内部**
- `.tad/evidence/research/gate-roi-measurement-2026-07.md`
- `.tad/evidence/research/claude-native-capabilities/`（overlap-matrix · tad-mechanism-inventory · harness-introspection）
- `voice-studio/docs/text-music-matching-guide.md`（"维度 × 谁判"表）
