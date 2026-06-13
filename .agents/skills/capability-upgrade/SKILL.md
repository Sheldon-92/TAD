---
name: capability-upgrade
description: Capability Pack 构建/升级流程。从评估到研究到构建的完整方法论，基于 2026-05-07 web-ui-design 升级实战经验。YAML Domain Packs retired 2026-06-11; archived source available at .tad/archive/domains/.
---

# /capability-upgrade — Capability Pack 构建流程

构建 action-ready Capability Pack（菜谱）。YAML Domain Pack 源已归档至 `.tad/archive/domains/`。
基于 web-ui-design 升级的完整实战经验（119 源、3 轮研究、9 个 P0 修复）。

---

## When to Use

- 用户说"升级/重建这个 domain pack"
- 真实项目需要某个领域的能力，现有 YAML pack 不够用
- 用户想为一个新领域从零构建能力包

## What This Produces

一个独立的能力包目录（不依赖 TAD），包含：
- `CAPABILITY.md` — 主文件：入口协议 + N 个能力 × Vision/Execution/Validation
- `install.sh` — 安装到 AI agent 的 skill 目录
- `checklists/` — 可执行的质检清单
- `tools/` — CLI 工具注册表 + 选型矩阵
- `references/` — 真实案例 + awesome-list 链接
- `examples/` — 可直接使用的模板文件

---

## 流程总览（5 阶段）

```
Stage 1: 评估（30 min）
  └── 现有 pack 有什么？缺什么？这个领域的 AI agent 能做什么、不能做什么？

Stage 2: 研究（1-2 hours）— GitHub-First
  ├── Phase 0: 研究计划（问题 + 源类型 + 成功标准）
  ├── Phase 1: GitHub 精选源（awesome-list → 子页面 → 公司 repo → 工具 repo）
  ├── Phase 2: 清洗（去错误 + 去重复 + 分层）
  ├── Phase 3: 系统提问（每个 capability 一组针对性问题）
  └── Phase 4: 缺口回填（deep research 仅作补充）

Stage 3: 设计（1 hour）
  └── Capability Pack 结构设计 + 专家审查

Stage 4: 构建（2-4 hours）
  └── Blake 实现

Stage 5: 验证（1 hour）
  └── 在真实项目中试用
```

---

## Stage 1: 评估现有 Pack

### Step 1.1: 读取现有 YAML

```bash
wc -l .tad/archive/domains/2026-06-11-domain-pack-retirement/{domain}.yaml  # archived source
grep "^  [a-z_]*:$" .tad/archive/domains/2026-06-11-domain-pack-retirement/{domain}.yaml
```

记录：有几个 capability？有多少行？有具体 CLI 命令还是只有描述？

### Step 1.2: 判断 AI Agent 能力边界

对这个领域，AI coding agent：
- **能做什么？** （生成代码、跑 CLI 工具、读配置、做 post-cleanup）
- **不能做什么？** （视觉预览、真人测试、GUI-only 工具、主观审美判断）
- **现有哪些 agent 指令？** （Anthropic 官方 skill？VoltAgent subagent？Cursor rules？）

⚠️ 教训：web-ui-design 升级时漏了"Claude Code 视角"，导致推荐了 agent 用不了的 GUI 工具。
   必须在研究之前就明确边界。

### Step 1.3: 确定 Capability 列表

从现有 YAML 提取 capability 列表，问用户：
- 哪些保留？
- 哪些合并？
- 哪些新增？
- 哪些砍掉？

产出：**确认的 capability 列表**（后续研究和构建的骨架）。

---

## Stage 2: GitHub-First 深度研究

### ⚠️ 核心教训（2026-05-07 实战）

```
❌ 错误顺序：deep research → 清洗 → 加 GitHub → 补问
   结果：350 篇 SEO 文章，90% 重复，真正有用的 GitHub 源排在最后

✅ 正确顺序：研究计划 → GitHub awesome-list → 子页面 → 公司 repo → 清洗 → 提问 → deep research 补缺
   结果：119 精选源，3 轮系统提问，每轮都有 actionable 产出
```

### Phase 0: 研究计划（10 分钟）

在添加任何源之前，先定义：

**0a. 研究问题**（每个 capability 1-3 个）

问题格式规则：
```
✅ "From GitHub repos: what specific CLI tools exist for {X}?"
✅ "What token/config structure does {Company} use in their {repo}?"
✅ "What tools can an AI agent run from terminal for {X}?"

❌ "What are best practices for {X}?" → 太空泛，改为 "What do {companies} actually use for {X}?"
❌ "How should we approach {X}?" → 没有锚点，改为 "What specific tools/patterns exist for {X}?"
```

**0b. 源类型优先级**

| 优先级 | 源类型 | 例子 | 为什么 |
|--------|-------|------|--------|
| 1（先加）| GitHub awesome-list | awesome-design-systems | 社区精选，工具密度最高 |
| 2 | awesome-list 子页面 | design-md/stripe/DESIGN.md | 具体品牌文件比 README 更有价值 |
| 3 | 真实公司 repo | Shopify/polaris, primer/react | 看生产代码怎么做的，不是看文章怎么说的 |
| 4 | 工具官方 repo | storybookjs/storybook | 工具的真实能力，不是博客介绍 |
| 5（最后）| deep research 文章 | 只在 Phase 4 补缺时使用 | SEO 内容农场太多，信噪比极低 |

⚠️ 教训：10 个精选 GitHub repo > 350 篇 deep research 文章。源的质量比数量重要 100 倍。

**0c. 成功标准**

"研究完成后，我应该能够：{具体决定}"

例："确定用 shadcn/ui 还是 Ark UI 作为默认推荐，基于 3+ 真实公司的选择数据。"

### Phase 1: GitHub-First 源构建（30 分钟）

**Step 1: 搜索 awesome-list**

```bash
# WebSearch
"github awesome list {topic} site:github.com"
```

每个相关的 awesome-list：
```bash
~/.tad-notebooklm-venv/bin/notebooklm source add "https://github.com/{org}/{repo}" -n <notebook_id>
sleep 2
```

**Step 2: 探索 awesome-list 子页面**

⚠️ 教训：只加 README 首页 = 只看了目录没看正文。真正的价值在子页面。

对 TOP 3 最相关的 awesome-list：
```bash
gh api "repos/{org}/{repo}/git/trees/main?recursive=1" \
  --jq '[.tree[] | select(.type == "blob" and (.path | test("\\.md$"))) | .path][:20]'
```

对每个 actionable 子页面（DESIGN.md、subagent 定义、具体工具文档）：
```bash
~/.tad-notebooklm-venv/bin/notebooklm source add \
  "https://github.com/{org}/{repo}/blob/main/{path}" -n <notebook_id>
sleep 1
```

**Step 3: 加真实公司 repo**

```bash
# WebSearch
"github {technology} design system stars:>5000"
```

加 3-5 个最相关的公司 repo。

**Step 4: 加工具官方 repo**

对 Phase 0 问题中提到的每个工具，加其 GitHub repo。

**Step 5: 加 Anthropic/Google 官方资源**（如果领域相关）

- Anthropic 的相关 SKILL.md（从 `.claude/plugins/` 读取并作为本地文件源加入）
- Google 的相关开源项目

⚠️ 教训：NotebookLM 有源数量上限（约 300）。如果 deep research 先跑了 350 篇文章，
   后面 GitHub 源就加不进去了。必须先加高价值源，再补低价值源。

### Phase 2: 清洗（10 分钟）

```bash
# 删错误源
error_ids=$(~/.tad-notebooklm-venv/bin/notebooklm source list --json -n <id> | \
  jq -r '.[] | select(.status | test("error")) | .id')
echo "$error_ids" | xargs -P5 -n1 sh -c \
  '~/.tad-notebooklm-venv/bin/notebooklm source delete "$1" -n <id> --yes 2>&1; sleep 0.3' _

# 去重复
# (按 title + domain 分组，每组保留第一个，删除其余)
```

### Phase 3: 系统提问（30 分钟）

每个 capability 1-3 个问题，严格遵循 Phase 0 的格式规则。

**提问模板**（按 capability 类型选择）：

工具型 capability：
```
"From the sources: what specific CLI tools and npm packages exist for {capability}?
For each tool: (1) install command, (2) test command to verify, (3) key usage command.
Only include tools an AI coding agent can run from terminal — no GUI-only tools."
```

架构型 capability：
```
"From the real company repos (Shopify, GitHub, Adobe etc.):
how do they structure their {thing}? Give specific directory layouts, config formats,
and naming conventions — extracted FROM these repos, not general advice."
```

规则型 capability：
```
"From the Anthropic SKILL and brand DESIGN.md files:
what are the specific DO and DON'T rules for {topic}?
List concrete prohibitions (NEVER X) paired with concrete alternatives (INSTEAD Y)."
```

⚠️ 教训：
- "What are best practices?" → 教科书答案，没用
- "What CLI tools can an agent actually run?" → 得到安装命令和验证命令，直接可用
- 必须在问题中写明"from the sources"，否则 NotebookLM 会用自己的知识回答而不是引用源

### Phase 4: 缺口回填（20 分钟）

Phase 3 的回答会暴露知识空白。此时：

**4a. 补充 GitHub 源**（首选）
```bash
# 搜索更细分的 awesome-list
"github awesome {specific-subtopic}"
```

**4b. Deep research 补充**（最后手段）

只有当 GitHub 源无法覆盖时才使用：
```bash
~/.tad-notebooklm-venv/bin/notebooklm source add-research "{specific_gap_query}" \
  --mode fast --import-all -n <id>
```

用 `--mode fast`（不是 deep）— 因为此时只需要填特定空白，不需要广撒网。

**4c. 二轮提问**

针对补充源的新提问，聚焦：
- 缺失的实战案例
- Claude Code 能力边界
- 工具验证（哪些真能用，哪些只是被推荐）
- 竞品 SKILL/subagent 参考

---

## Stage 3: 设计 Capability Pack

### Step 3.1: 确定结构

基于研究发现，CAPABILITY.md 遵循 **Vision → Execution → Validation** 三段式：

```markdown
## Entry Protocol
- 决策树：什么场景用哪几个 capability
- 最小可行路径：3 个核心 capability
- 提前退出规则：单组件任务跳过哪些

## Capability N: {name}
### Vision
  审美/策略方向 + 决策框架
### Execution
  通用工具（先）→ 框架特定工具（"If React:" 分支）
  每个工具：install → test → use
### Validation
  自动检查（CLI 命令）+ 人工检查（标注为"需要人工"）
```

### Step 3.2: 核心设计原则

⚠️ 全部来自实战教训：

**原则 1: 每个 section 必须有 CLI 命令**
> 没有命令的 section = 理论 = 没用。删掉。

**原则 2: 框架无关优先**
> 先列通用工具（CSS-only、multi-framework），再列 "If React:" 分支。
> 教训：BA 审查发现 9 个 capability 中 6 个绑死了 React。

**原则 3: Anti-slop 规则 = 具体禁令 + 具体替代**
> "NEVER use Inter/Roboto" 比 "avoid generic fonts" 有效 100 倍。
> 每条 "NEVER X" 必须配一条 "INSTEAD Y"。

**原则 4: 入口协议是最关键的部分**
> BA 审查发现：没有入口协议的话 agent 不知道该跑哪几个 capability。
> 决策树 + 最小路径 + 提前退出 = 3 个必须有的组件。

**原则 5: 零依赖兜底**
> 主工具可以用 npm，但必须有纯 bash/jq 的 Level 0 fallback。
> 教训：Token pipeline 假设有 Node → 非 Node 项目用不了。

**原则 6: 品牌值做参考，中性值做默认**
> references/ 里放 Stripe 的 #533afd，examples/ 里放中性色。
> 教训：starter-tokens.json 用了品牌色会有商标风险。

**原则 7: Phase 1 = 一个平台，设计留接口**
> 先做 Claude Code 版（1M context 够用），接口预留给 Codex/Cursor。
> 教训：install.sh 同时适配 4 个平台 → 3 个路径是错的。

### Step 3.3: 专家审查

调 ≥3 个专家并行审查 handoff 草稿（≥3 lens，**含 fact-API lens** — 与 Gate 2 §2.4 一致）：

- **code-reviewer**: AC 可验证性、文件结构一致性、grep 命令正确性
- **backend-architect**: 架构合理性、跨平台兼容、范围评估、遗漏项
- **fact-API lens**: 对版本敏感断言（API 名/版本号/弃用/metric 类型）用 WebSearch 核对当前原始文档；跨模型（Codex/Gemini）补 same-model 事实盲点。任何 refute 先独立 validate 再修。

⚠️ 常见 P0（从 web-ui-design 审查中提取）：
- 框架绑定但声称框架无关
- AC grep 命令在现有文件中有预匹配（AC self-leak）
- 工具数量不一致（"18 tools" vs "14 FULLY_CLI"）
- 缺入口协议 / 缺 LICENSE 归属 / 缺版本文件
- CAPABILITY.md 太长（>2000 行需考虑按需加载设计）

---

## Stage 4: 构建

Blake 执行 handoff。关键注意：
- 边实现边用 NotebookLM 查不确定的问题
- 每个 Execution section 写完后自测 CLI 命令能否跑通
- install.sh 必须有 `--dry-run` 模式
- 零 TAD 术语（grep 验证）

---

## Gate 2 — 双层质量尺（⚠️ MANDATORY build/validation deliverable）

> **每个新建或升级的能力包，在 Stage 4 收尾 / Stage 5 验收前，必须通过 `.tad/evidence/pack-quality/QUALITY-BAR.md` 的双层尺。**
> QUALITY-BAR.md 是**唯一权威基准**（canonical bar）——以下只内联强制清单摘要，完整判据/锚点/负样例口径以 QUALITY-BAR.md §1 / §2 / §4 为准，不在此重复。
> 任一项不达标 = Gate 2 不通过 = 不得标 accepted。

### 2.1 Layer A — 元设计/结构 checklist（QUALITY-BAR.md §1，满分 10，**通过线 7/10**）

逐条 grep/读验证（口径见 QUALITY-BAR.md §1 的"如何验证"列）：

- [ ] **A1 Frontmatter**：`name`（≤64 字符，小写/数字/连字符，禁含 "anthropic"/"claude"）+ `description`（≤1024 字符，第三人称，写明 what+when）
- [ ] **A2 渐进披露**：metadata → SKILL.md body → 按需加载的 `references/`/`scripts/`/`assets/`（≥1 辅助文件）
- [ ] **A3 Body 体量纪律**：SKILL.md body **< 500 行**（超出拆分到 `references/`）
- [ ] **A4 路由/步骤结构**：Step 0/1/2 工作流 **或** signal→reference 路由表
- [ ] **A5 接口契约**：CONSUMES/PRODUCES 或明确 scope-boundary
- [ ] **A6 Anti-skip / 反合理化表**：列出 agent 跳步借口 + 逐条反驳
- [ ] **A7 导航索引**：Quick Rule Index / ## Contents / Available datasets / ## Skills 表
- [ ] **A8 Fixture 存在**：`examples/*.md` ≥ 1 个评估 fixture，含 **pack-specific `discriminative_pattern`**
- [ ] **A9 评估接好线**：fixture 含 `discriminative_pattern` + `min_discriminative`（接 §2.3 判别式 gate）
- [ ] **A10 验证脚本**：`scripts/` 或 `tools/` 有可执行校验器，**路径用正斜杠（无 Windows `\`）**

### 2.2 Layer B — 领域深度（QUALITY-BAR.md §2，0/2/5 锚点）

- [ ] 规则携带**研究落地的具体数字/阈值/退出码 + 来源**（如 `n≥550`、`exit code 183`、`p95`、`50M rows offset 翻车`），**NOT** 前沿 LLM 无研究即可复述的通用规则（"write good tests" / "secure your API"）。
- [ ] specN（specific-threshold 去重计数，跑 QUALITY-BAR.md §2.3 的命令，注意 `LC_ALL=en_US.UTF-8`）落在目标桶；gold 锚 5，非 gold 按 specN 初判 + reading 微调。

### 2.3 行为判别式评估（QUALITY-BAR.md §3，复用 `.tad/scripts/pack-eval-runner.sh`）

- [ ] 跑**新鲜 WITH / CONTROL 行为评估**：**no-pack CONTROL 输出 FAIL**（`disc < min_discriminative`），**WITH-PACK 输出 PASS**（`disc ≥ min_discriminative`）。
- [ ] 用 fixture 的 `discriminative_pattern`（仅 pack 独有 marker）断言，**不**用 combined `## Verification Command` 计数驱动 PASS（混入通用 marker = validation theater）。
- [ ] negative control 必须 FAIL（对称证明尺能判别，见 QUALITY-BAR.md §4）。

### 2.4 对抗审查（≥3 lens，含 fact-API lens — QUALITY-BAR.md §6）

- [ ] ≥3 个审查 lens，**必须含一个 fact-API lens**：对版本敏感断言（API 名/版本号/弃用/metric 类型）用 **WebSearch 核对当前原始文档**（primary docs）。
- [ ] 跨模型（Codex/Gemini）对抗审查覆盖 same-model 的事实/API 盲点。
- [ ] **任何 refute 先独立 validate 再修**——NEVER 盲信 reviewer 的 P0（reviewer 自身约 2/N 会错）；validate 后属实才改。

---

## Stage 5: 验证

在真实项目中使用能力包，对比有包 vs 无包的产出质量。

**⚠️ 前置门槛：Stage 5 验收前必须先过 Gate 2（双层质量尺，见上）。** Gate 2 不通过则阻塞验收。

验证清单：
- [ ] **Gate 2 通过**：Layer A ≥7/10 + Layer B 达标 + 行为判别式 CONTROL FAIL / WITH PASS + ≥3-lens 对抗审查（含 fact-API lens）
- [ ] Agent 读了 CAPABILITY.md 后知道该跑哪几个 capability（入口协议有效）
- [ ] Agent 产出的 UI 不是 AI slop（anti-slop 规则生效）
- [ ] CLI 工具实际跑通了（不只是写在文档里）
- [ ] 不用 Node 的项目也能用（Level 0 fallback 有效）

---

## 快速参考：每个阶段的关键产出

| 阶段 | 时间 | 关键产出 | 失败信号 |
|------|------|---------|---------|
| 评估 | 30min | 确认的 capability 列表 + AI 能力边界 | 列了 capability 但不知道 agent 能不能做 |
| 研究 | 1-2h | NotebookLM notebook (50-120 精选源) + 研究发现文件 | 源 >200 且大部分是文章 = 比例失衡 |
| 设计 | 1h | Handoff 草稿 + 2 个专家审查通过 | 没有入口协议 / 没有 CLI 命令 / 框架绑定 |
| 构建 | 2-4h | 完整能力包目录 (≤5000 行) + **通过 Gate 2 双层尺** | 任何 section 没有 CLI 命令 = 和 YAML 一样；Gate 2 任一项不达标 |
| 验证 | 1h | 真实项目对比结果（Gate 2 前置通过） | "有包 vs 无包"看不出差别；行为判别式 CONTROL 未 FAIL |

---

## 已完成的升级

| 领域 | 状态 | Notebook | 源数 | 产出 |
|------|------|----------|------|------|
| web-ui-design | Phase 1 构建中 | fd4f9117 | 119 | ~/web-ui-design-capability/ |

（后续升级在此追加）
