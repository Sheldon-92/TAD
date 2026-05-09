# Handoff Template: Create New Domain Pack — Web Backend

**From:** Alex | **To:** Blake | **Date:** 2026-04-02

---

## 你要做什么

为 **Web Backend** 创建一个 Domain Pack — 一个 YAML 配置文件，让 TAD 能在这个领域"做事"。

"做事"不是写文字建议。是**用工具产出文件** — PDF 报告、SVG 图表、HTML 原型等可以直接发给别人用的东西。

---

## 在开始之前：读这些（全部读完再动手）

| 文件 | 为什么要读 | 读什么 |
|------|-----------|--------|
| `.tad/domains/product-definition.yaml` | 这是第一个完成的 Domain Pack，你的范本 | 看它的 capabilities 结构、steps 的四层设计、quality_criteria 怎么写 |
| `.tad/spike-v3/domain-pack-tools/pm-skills-best-practices.md` | 这是 Alex 做研究后的最佳实践文档，看它怎么从仓库提取有用信息 | 看它的结构：按 capability 分类 → 每个有步骤深度/来源清单/分析框架/质量标准 |
| `.tad/domains/tools-registry.yaml` | 现有工具清单，你要往里面加新工具 | 看每个工具条目的格式（install/verify/usage/example） |
| `.tad/domains/HOW-TO-CREATE-DOMAIN-PACK.md` | 创建流程总览 | 快速浏览，了解全貌 |

---

## Phase 1: 研究现有 Skills

### 你要做什么

搜索 GitHub 上别人已经做好的类似领域的 Skills，把他们的好东西提取出来。**不要从零开始设计 — 站在别人肩膀上。**

### 怎么搜

执行这 5 条 WebSearch（把 web-backend 替换为具体领域）：

```
1. "GitHub claude skills web-backend SKILL.md"
2. "GitHub AI agent web-backend skill prompt framework"
3. "GitHub awesome claude skills web-backend"
4. "web-backend best practices checklist framework"
5. "site:github.com web-backend SKILL.md OR CLAUDE.md"
```

### 怎么判断一个仓库值不值得深入看

| 信号 | 值得看 | 不值得看 |
|------|--------|---------|
| Stars | >50 | <10（太冷门） |
| 最近更新 | 3 个月内 | >1 年没更新 |
| SKILL.md 长度 | >100 行 | <30 行（太简单） |
| 有 examples/ 目录 | ✅ 说明有真实输出样例 | 没有（纯理论） |
| 有 template/ 目录 | ✅ 有输出模板 | 没有 |
| 步骤描述 | "搜索 G2 评论，提取 1-2 星关键词" | "做竞品分析"（太笼统） |

**目标：找到 3-5 个值得深入看的仓库。**

### 怎么从仓库里提取有用信息

用 WebFetch 读取每个仓库的核心 SKILL.md。读的时候，提取这 5 个东西：

**1. 步骤清单**
这个 skill 让 AI 做哪些具体步骤？一步一步列出来。

```
✅ 好的提取（具体）:
  "Step 1: 搜索 G2/Capterra 上竞品的 1-2 星评论
   Step 2: 提取高频抱怨关键词
   Step 3: 按频率排序，标注 3+ 次出现的为高置信度"

❌ 差的提取（笼统）:
  "做用户研究"
```

**2. 来源清单**
这个 skill 让 AI 去哪里搜索/获取数据？列出具体的网站、平台、数据库名。

```
✅ 好的提取: "G2, Capterra, Reddit, ProductHunt, Crunchbase, Google Scholar"
❌ 差的提取: "网上搜索"
```

**3. 分析框架**
这个 skill 用了什么方法来分析数据？不是"做分析"，是用什么具体的框架/模型。

```
✅ 好的提取: "April Dunford 6 步定位法: 1.替代方案 2.独特属性 3.价值 4.最佳客户 5.品类 6.趋势"
❌ 差的提取: "做定位分析"
```

**4. 质量标准**
这个 skill 怎么定义"做完了"？有什么可量化的检查项？

```
✅ 好的提取: "≥5 个竞品, 每个有功能对比(Full/Partial/None/Unknown), 来源标注置信度, 文档 15 分钟可读完"
❌ 差的提取: "分析要全面"
```

**5. 反模式（常见错误）**
这个 skill 警告了哪些常见错误？

```
✅ 好的提取: "❌ 不问'你会不会用'（用户总说会）→ 要问'你上次遇到这个问题怎么解决的'"
❌ 差的提取: "避免犯错"
```

### 怎么整合成参考文档

把所有仓库的提取结果合并。按你的 Domain Pack 要覆盖的 capability 分组。

```markdown
# web-backend Skills Best Practices

## 来源
| 仓库 | Stars | 特点 |
|------|-------|------|

## Capability 1: {name}

**最佳步骤设计**（来自 {repo}）:
{具体步骤抄过来}

**最佳分析框架**（来自 {repo}）:
{框架名 + 具体怎么用}

**最佳质量标准**（来自 {repo}）:
{可量化的标准}

**反模式**:
- ❌ {错误 1}（来自 {repo}）
- ❌ {错误 2}

## Capability 2: {name}
{同样格式}
```

**写入**：`.tad/spike-v3/domain-pack-tools/web-backend-skills-best-practices.md`

### Phase 1 自检

完成后问自己：
- [ ] 我研究了 ≥3 个仓库吗？
- [ ] 每个仓库我都提取了 5 个维度（步骤/来源/框架/标准/反模式）吗？
- [ ] 提取的内容是具体的（有网站名、有框架名、有数字）还是笼统的（"做分析"）？
- [ ] 如果我把提取内容给一个不了解这个领域的人看，他能按照这些步骤做吗？

**如果提取内容太笼统 → 回去重新读 SKILL.md，这次读得更仔细。**

---

## Phase 2: 研究可用工具

### 你要做什么

找到这个领域可以用的 CLI 命令行工具和 MCP 服务器。Domain Pack 的价值 = 让 Claude 用工具做出东西，如果没有工具，Domain Pack 就只是另一个 prompt 文件。

### 先列需求

对每个 capability，想一想它需要什么类型的工具：

| 我需要做什么 | 我需要什么工具 | registry 里有吗 |
|-------------|--------------|----------------|
| 搜索网页 | web_scraping | ✅ 有 jina-reader |
| 生成 PDF | pdf_generation | ✅ 有 typst |
| 画图表 | data_chart | ✅ 有 matplotlib |
| {这个领域特有的} | {?} | ❌ 需要找 |

**先检查 tools-registry.yaml 里已有的工具能不能复用。** 只有 registry 里没有的才需要搜索新工具。

### 怎么搜索新工具

```
"MCP server {工具类型} Claude Code 2026"
"{工具名} CLI command line"
"GitHub {工具名} mcp"
```

### 怎么判断一个工具值不值得用

| 标准 | 好 | 不好 |
|------|-----|------|
| 在 Claude Code 里能跑 | `bash` 命令直接用或 MCP 可连接 | 需要 GUI 交互/需要浏览器 |
| 安装简单 | `brew install X` 或 `npx X` | 需要编译/需要 Docker/需要注册 |
| 免费额度 | 无限或 >100 次/月 | <10 次/月（Figma 免费版只有 6 次） |
| 输出格式 | 文件（PDF/SVG/PNG/MD） | 只在网页上显示 |
| 有 CLI 模式 | 命令行调用 + 参数 | 只有 GUI |

### 怎么测试工具

**至少测 2 个新工具。** 测法：

```bash
# 1. 安装
brew install {tool}  # 或 npm install -g {tool}

# 2. 验证
{tool} --version

# 3. 用一个简单输入跑一次
echo '{minimal input}' | {tool} > output.{ext}

# 4. 检查输出
ls -la output.{ext}  # 文件大小 > 0？
cat output.{ext}      # 内容合理？
```

**记录**：安装命令 + 测试命令 + 输出文件大小 + 成功/失败

### 怎么写 tools-registry 条目

**重要原则：写到 Claude 看了就能用的程度。Claude 可能从来没见过这个工具。**

```
✅ 好的条目:
  name: typst
  install: "brew install typst"
  verify: "typst --version"
  usage: |
    1. 创建 .typ 文件（Typst 标记语言）
    2. 运行: typst compile input.typ output.pdf
    3. 输出: PDF 文件
  example: |
    // report.typ
    #set page(paper: "a4")
    = Title
    Some text here.
    #table(
      columns: (1fr, 1fr),
      [Header 1], [Header 2],
      [Data 1], [Data 2],
    )
    
    命令: typst compile report.typ report.pdf
    输出: report.pdf (约 30KB)

❌ 差的条目:
  name: typst
  install: "brew install typst"
  usage: "用 typst 生成 PDF"
  （Claude: "typst 是什么？怎么写输入文件？命令格式是什么？"）
```

**写入**：更新 `.tad/domains/tools-registry.yaml`

### Phase 2 自检

- [ ] 每个 capability 有 ≥1 个工具？
- [ ] 新工具至少测了 2 个？
- [ ] 每个新工具条目有 install + verify + usage + example？
- [ ] example 是否具体到 Claude 复制粘贴就能跑？

---

## Phase 3: 写 domain.yaml

### 你要做什么

把 Phase 1 的研究成果 + Phase 2 的工具 → 组合成一个 YAML 配置文件。

**⚠️ 这是最容易出错的阶段。** 最常见的问题是"步骤太浅" — 只有搜索和生成，没有分析。

### domain.yaml 骨架

```yaml
domain: {domain-name}
version: 1.0.0
requires_registry: ">=1"
description: "{一句话描述}"

output_dir: ".tad/active/research/{project}/"

capabilities:

  {capability_name}:
    description: "{做什么}"
    steps:
      - id: {step_id}
        action: "{具体做什么}"
        tool_ref: {registry_key}
        output_file: "{文件名}"
    quality_criteria:
      - "{标准}"
    anti_patterns:
      - "❌ {错误}"
    reviewers:
      - persona: "{视角}"
        checklist:
          - "{检查项}"

output_structure: |
  .tad/active/research/{project}/
  ├── ...

gates:
  gate2_design:
    checklist: [...]
  gate4_acceptance:
    checklist: [...]
```

### ⚠️ 最关键的规则：每个 capability 必须有四层 steps

```
Layer 1: 搜索 — 去哪找数据
Layer 2: 分析 — 数据意味着什么（So What）
Layer 3: 推导 — 所以该怎么做（Therefore）
Layer 4: 生成 — 用工具产出文件
```

**怎么判断你写的步骤够不够深：**

```
❌ 太浅（只有 Layer 1 + 4）:
  step 1: WebSearch 搜索竞品
  step 2: 用 Typst 生成报告
  → 产出物 = 搜索结果拼接，没有分析

⚠️ 有点深度但不够（有 Layer 1 + 2 + 4，缺 3）:
  step 1: WebSearch 搜索竞品
  step 2: 对比功能和定价
  step 3: 用 Typst 生成报告
  → 产出物 = 有对比表格，但没有"所以我们应该怎么做"的结论

✅ 够深（四层都有）:
  step 1: WebSearch 搜索 5+ 竞品（Layer 1: 搜索）
  step 2: 对每个竞品分析：为什么能活、用户不满什么、没做什么（Layer 2: 分析）
  step 3: 基于分析推导：市场空白在哪、我们的定位应该是什么（Layer 3: 推导）
  step 4: 用 D2 画定位图 + Typst 生成报告（Layer 4: 生成）
  → 产出物 = 有分析深度的报告，有可执行的结论
```

### 怎么写分析步骤（Layer 2）

**不要自己编分析问题。** 回到 Phase 1 的研究文档，找你提取的"最佳分析框架"，直接用。

```
Phase 1 你提取了:
  "product-on-purpose 的竞品分析 7 步法"
  
转化为 domain.yaml step:
  - id: deep_analyze
    action: |
      对每个竞品回答（来源: product-on-purpose 竞品分析框架）：
      1. 定义分析范围（功能/定位/定价）
      2. 功能矩阵用 Full/Partial/None/Unknown 评级
      3. 2x2 定位图（选两个有意义的维度）
      4. 诚实评估竞品优势（"respect drives better strategy"）
      5. 标注信息置信度（来自官网=High / 来自推测=Low）
      每个回答必须有证据（URL 或截图描述）。
```

### 怎么写推导步骤（Layer 3）

推导 = 从分析得出结论。关键：结论必须基于数据，不是直觉。

```
✅ 好的推导步骤:
  - id: derive_positioning
    action: |
      基于竞品深度分析，回答：
      1. 所有竞品都没做好的事是什么？（空白）
      2. 有多少用户在抱怨这件事？（空白大小）
      3. 我们能做好吗？别人为什么没做？（可行性）
      如果没有明确空白 → 输出 "⚠️ 差异化证据不足"
    quality: "每个结论必须引用分析中的具体数据"

❌ 差的推导步骤:
  - id: derive_positioning
    action: "基于分析写定位"
    （太笼统，Claude 会写出"我们更好更快更便宜"这种空话）
```

### 怎么写 quality_criteria

```
✅ 好的标准（可验证）:
  - "≥5 个竞品（含直接+间接+替代方案）"
  - "每条痛点有用户原话引用 + URL"
  - "定价有推导过程（不是编的）"
  - "找不到数据 → 标注 [INSUFFICIENT DATA]，不编造"

❌ 差的标准（不可验证）:
  - "分析要全面"
  - "数据要可靠"
  - "结论要有说服力"
  （这些标准没人能判断"够不够全面"）
```

### 怎么判断"编造"

这是最大的质量问题。Claude 会自信地写出看起来很真实但完全是编的内容。

```
什么是编造:
  - 定价 "$199" 但没有任何推导依据 → 编造
  - "市场规模 $5B" 但没有来源 URL → 编造
  - 用户引言 "I love this product because..." 但没有来源 → 编造
  - 竞品功能对比全是 "Full" 但没有实际验证 → 编造

什么不是编造:
  - "基于 PetPace $299 和 FitBark $99，我们推导价格区间 $129-179" → 有推导链
  - "市场规模 $4.5B (来源: Grand View Research 2025)" → 有来源
  - "Reddit 用户 u/petlover: 'My FitBark battery dies every 2 days'" → 有原文引用
  - 功能标注 "Unknown" 而不是猜一个 → 诚实

quality_criteria 里必须写: "编造数据 = FAIL。不确定的标注 [UNVALIDATED]。"
```

### Phase 3 自检

- [ ] 每个 capability 有 ≥4 个 steps？
- [ ] 每个 capability 有 analyze 步骤（Layer 2）？
- [ ] 每个 capability 有 derive 步骤（Layer 3）？
- [ ] analyze 步骤的内容来自 Phase 1 研究（不是我自己编的）？
- [ ] quality_criteria 是可验证的（有数字、有具体要求）？
- [ ] 有"编造=FAIL"的明确标准？
- [ ] 所有 tool_ref 在 registry 里有对应条目？
- [ ] YAML 语法正确（用 `python3 -c "import yaml; yaml.safe_load(open('file'))"` 验证）？

---

## Phase 4: E2E 测试

### 你要做什么

用一个虚拟项目跑一遍完整的 Domain Pack，看产出物质量。

### 选测试议题

选一个该领域的**具体项目**（不能太抽象）：

```
✅ 好的测试议题: "AI 驱动的宠物健康监测项链"（具体、有公开数据可搜索）
❌ 差的测试议题: "一个 IoT 产品"（太抽象，搜不到具体数据）
```

### 怎么跑

用 Agent tool spawn 测试 agent。每个 capability 一个 agent：

```
Agent({
  prompt: "你在做 '{测试议题}' 的 {capability_name}。
  读取 .tad/domains/web-backend.yaml 的 {capability} 部分，按 steps 逐步执行。
  工具使用方法看 .tad/domains/tools-registry.yaml。
  产出文件写入 .tad/active/research/{test-project}/。
  使用真实 WebSearch（不要编造数据）。"
})
```

### 怎么判断产出物质量

跑完后检查每个文件，用这 7 个维度评分：

| # | 维度 | 怎么判断 PASS | 怎么判断 FAIL |
|---|------|-------------|-------------|
| 1 | 搜索真实性 | 有 ≥5 个不同来源的 URL | 没有 URL，或 URL 是编的 |
| 2 | 用户细分 | 识别了 ≥3 个不同群体，每个有数据支撑 | 笼统的"目标用户是所有人" |
| 3 | 分析深度 | 有"So What"（数据意味着什么） | 只是数据罗列 |
| 4 | 推导链 | 结论←分析←数据，可追溯 | 结论凭空出现 |
| 5 | 诚实度 | 不确定标了 [UNVALIDATED] | 不确定的当事实写 |
| 6 | 零编造 | 所有数字/引言/定价有来源 | 出现编造的数据 |
| 7 | 文件可用 | PDF/SVG/PNG 文件生成，>0 bytes | 文件缺失或损坏 |

**≥5/7 PASS = 质量达标。<5/7 → 进入 Phase 5 迭代。**

### 清理

测试完删除 `.tad/active/research/{test-project}/`。

---

## Phase 5: 迭代（几乎一定需要）

> 根据经验，第一版几乎一定需要迭代。Product Definition 迭代了一轮后质量显著提升。**不要跳过这步。**

### 怎么诊断问题

对 Phase 4 中 FAIL 的维度，用这个对照表找原因：

| FAIL 的维度 | 最可能的原因 | 怎么修 |
|------------|-------------|--------|
| 搜索不真实 | queries 模板太笼统 | 在 step 里写更具体的搜索词 |
| 没有用户细分 | 缺少 segment 步骤 | 在搜索后加 segment_users 分析步骤 |
| 分析太浅 | 缺少 analyze 步骤 | 加分析步骤，用 Phase 1 研究的框架 |
| 没有推导 | 缺少 derive 步骤 | 加推导步骤，要求结论引用数据 |
| 编造数据 | 缺少 verify 步骤 | 加 verify_claims 步骤，审查每个 claim |
| 文件没生成 | 工具配置错误 | 检查 tool_ref 和 registry 条目 |

### 修改 → 重跑 → 对比

1. 修改 domain.yaml（加步骤/强化标准）
2. **用同一个测试议题重跑**
3. 对比 v1 和 v2：

```markdown
| 维度 | v1 | v2 | 改善 |
|------|----|----|------|
| 用户细分 | 无 | 3 群体 + 置信度 | PASS |
| ... | ... | ... | ... |
```

**v2 的 PASS 维度 ≥ v1 的 FAIL 数量 × 80% → 迭代成功。**

---

## Phase 6: 同步

1. 确认 tools-registry.yaml 已更新
2. 测试 hook 检测：`echo '{"session_id":"test","cwd":"'$(pwd)'"}' | bash .tad/hooks/startup-health.sh`
3. 输出应包含新 domain 名

---

## 最终交付物

| # | 文件 | 检查 |
|---|------|------|
| 1 | `.tad/spike-v3/domain-pack-tools/web-backend-skills-best-practices.md` | ≥3 仓库 × 5 维度 |
| 2 | `.tad/spike-v3/domain-pack-tools/web-backend-tool-research.md` | ≥2 工具实测 |
| 3 | `.tad/domains/tools-registry.yaml` 更新 | 新工具有完整条目 |
| 4 | `.tad/domains/web-backend.yaml` | 四层 steps + 质量标准 |
| 5 | E2E 测试结果 | ≥5/7 维度 PASS |
| 6 | v1→v2 对比（如果迭代了） | 改善可见 |

## Acceptance Criteria

- [ ] AC1: Skills 研究 ≥3 仓库，每个 5 维度提取（具体不笼统）
- [ ] AC2: 工具研究 ≥2 实测，registry 条目有完整 example
- [ ] AC3: domain.yaml 每个 capability 有四层 steps
- [ ] AC4: 分析步骤基于 Phase 1 研究（不是自编）
- [ ] AC5: quality_criteria 全部可量化 + 含"编造=FAIL"
- [ ] AC6: E2E 测试 ≥5/7 PASS
- [ ] AC7: 如果 <5/7 → 迭代后 ≥5/7
- [ ] AC8: Hook 检测到新 domain
- [ ] AC9: 现有 TAD 功能不受影响

---

## Alex 的领域补充：Web Backend 特定指引

### 范围定义

**Web Backend Pack 做服务端：API + 数据库 + 认证 + 服务端逻辑。**
- ✅ API 设计（RESTful / GraphQL、端点定义、版本管理）
- ✅ 数据库设计（Schema、关系、迁移、索引）
- ✅ 认证授权（Auth 方案、JWT/OAuth、角色权限）
- ✅ 服务端逻辑（业务逻辑、数据验证、错误处理）
- ✅ API 文档（OpenAPI spec 自动生成）
- ✅ 数据库种子/迁移脚本
- ❌ 前端代码（web-frontend pack）
- ❌ UI 设计（web-ui-design pack）
- ❌ E2E 测试（web-testing pack）
- ❌ 部署（web-deployment pack）

### 建议的 Capabilities

| Capability | 做什么 | 关键产出 | 工具 |
|-----------|--------|---------|------|
| `api_design` | API 端点设计 + OpenAPI spec | openapi.yaml + 路由代码 | OpenAPI CLI, Swagger |
| `database_design` | Schema 设计 + 关系建模 + 迁移 | Schema 文件 + 迁移脚本 + ER 图 | Prisma CLI, Supabase CLI, D2 |
| `authentication` | Auth 方案选型 + 实现 | Auth 中间件 + 配置 | Supabase Auth, NextAuth |
| `business_logic` | 核心业务逻辑实现 | 服务层代码 + 验证逻辑 | Write (内置) |
| `api_documentation` | 自动生成 API 文档 | 可浏览的 API 文档 | Swagger UI, Redoc |
| `data_seeding` | 种子数据 + 测试数据 | seed 脚本 + fixture 文件 | Prisma seed, Faker |
| `error_handling` | 统一错误处理 + 日志 | 错误中间件 + 日志配置 | Write (内置) |

### Phase 1 搜索关键词

```
"GitHub claude skills backend API database SKILL.md"
"GitHub claude skills REST API design OpenAPI"
"GitHub cursor rules backend Node.js TypeScript"
"GitHub AI agent database schema design automation"
"GitHub awesome claude skills backend supabase prisma"
"API design best practices REST GraphQL 2026"
"database schema design checklist normalization"
"backend code review security best practices"
"GitHub claude skills authentication authorization"
```

### Phase 2 工具搜索提示

| 类别 | 工具 | 说明 | registry 里有？ |
|------|------|------|----------------|
| ORM/数据库 | Prisma CLI | `npx prisma generate/migrate/seed` | ❌ 需新增 |
| BaaS | Supabase CLI | `npx supabase init/start/db push` | ❌ 需新增 |
| API spec | openapi-generator | 从 OpenAPI spec 生成代码 | ❌ 需新增 |
| API 文档 | swagger-cli | 验证 + 预览 OpenAPI spec | ❌ 需新增 |
| ER 图 | D2 | 数据库关系图（已有） | ✅ 已有 |
| 测试数据 | Faker.js | 生成假数据 | ❌ 需新增 |
| 类型生成 | prisma-zod-generator | Schema → Zod 验证 | ❌ 需新增 |
| HTTP 测试 | httpie / curl | API 端点测试 | ✅ 内置 |

**注意**：D2（ER 图）、typst（文档）、jina-reader（搜索）已在 registry。重点搜 **数据库和 API 特有工具**。

### 和其他 Pack 的衔接

```
上游 — Web Frontend 产出:
├── API 调用代码 → 知道前端需要什么端点
├── TypeScript 接口 → API 契约定义
└── 状态管理需求 → 知道数据结构

下游 — Web Testing 输入:
├── API 端点列表 → 测试对象
├── 数据库 Schema → 数据验证规则
└── Auth 配置 → 权限测试场景
```

### 测试议题建议

**"Todo App 的后端 API"**（延续前面的 Todo 议题，验证全链路衔接）：
1. 设计 REST API（CRUD + Auth）
2. Prisma Schema（User + Todo + Category）
3. Supabase 项目初始化
4. OpenAPI spec 生成
5. 种子数据脚本

### ⚠️ 产出是代码 + 配置 + 文档

和 Frontend 类似，Backend 产出可以自动验证：
- `npx prisma validate` → Schema 正确
- `npx prisma generate` → 类型生成成功
- `swagger-cli validate openapi.yaml` → API spec 合法
- `curl localhost:3000/api/todos` → API 返回正确格式

