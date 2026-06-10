# TAD Codex CLI 使用指南

**适用版本**: TAD v2.28.0+ | Codex CLI 0.137+

---

## 这是什么

TAD (Triangle Agent Development) 是一套让 AI 写代码更靠谱的方法论框架。核心思想很简单：

**AI 做事很快但容易跑偏，人类在三个关键点把关就能避免 80% 的返工。**

这三个点是：需求确认、优先级决策、最终验收。TAD 把这三个点做成了强制检查站（Gate），中间的设计、实现、测试全部由 AI 驱动。

### TAD 在 Codex 上的定位

Codex 是 TAD 的一等公民运行时（和 Claude Code 平级）。两个平台共享同一套 SKILL 文件、同一套质量门禁、同一套协议。区别只在平台机制层：

| | Claude Code | Codex CLI |
|---|---|---|
| 角色激活 | `/alex` `/blake` | `$alex` `$blake` |
| Skill 目录 | `.claude/skills/` | `.agents/skills/` |
| 配置 | `.claude/settings.json` | `.codex/hooks.json` |
| 子 agent | `Agent tool` | 内置 subagent |

---

## 安装

### 一行命令（推荐）

```bash
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/tad.sh | bash -s -- --platform codex --yes
```

这会安装：
- `.tad/` — 框架核心（配置、模板、钩子、migration 引擎、12 个历史 manifest）
- `.agents/skills/` — Alex/Blake 角色 + 25 个 capability packs
- `.codex/hooks.json` — 生命周期钩子
- `AGENTS.md` — 角色路由文件
- `tad.sh` — 升级脚本（以后升级也用它）

### 双平台（同时用 Claude Code + Codex）

```bash
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/tad.sh | bash -s -- --platform both --yes
```

### 交互式安装（可选 packs）

```bash
npx github:Sheldon-92/TAD
# 交互式选择平台 + capability packs
```

### 验证安装

```bash
cat .tad/version.txt                    # 应显示 2.28.0
ls .agents/skills/ | head -5            # 应看到 alex/ blake/ 等目录
test -f .codex/hooks.json && echo OK    # 应显示 OK
test -f .tad/hooks/lib/migration-engine.sh && echo OK  # Migration 引擎
```

### 升级

同一条安装命令即可升级。v2.28.0 起，升级会自动通过 migration 引擎清理旧版本的废弃文件，不再留垃圾。

---

## 快速开始

### 1. 激活角色

在 Codex CLI 中输入：

```
$alex    → 激活 Alex（Solution Lead — 负责设计和验收）
$blake   → 激活 Blake（Execution Master — 负责实现和测试）
```

### 2. 典型工作流

```
你: $alex
你: 我想给应用加一个用户登录功能

Alex: [Socratic 提问 3-5 轮，澄清需求]
Alex: [创建技术设计 + Handoff 文档]
Alex: "Handoff 已准备好，请切换到 Blake 执行。"

你: $blake
你: 执行登录功能的 handoff

Blake: [读取 handoff，实现代码]
Blake: [运行 Gate 3 质量检查：build + test + 专家审查]
Blake: [生成完工报告]

你: $alex
你: Blake 完成了，这是完工报告

Alex: [审查完工报告，执行 Gate 4 业务验收]
Alex: "验收通过，已归档。"
```

### 3. 什么时候用 TAD，什么时候不用

**用 TAD**（走完整流程）：
- 新功能（预计改 3+ 个文件）
- 架构变更
- 多模块重构
- 复杂需求

**跳过 TAD**（直接让 Codex 干）：
- 单文件 bug 修复
- 改配置（.env、依赖版本）
- 文档更新
- 紧急热修复

---

## Alex 命令速查

所有命令用 `*` 前缀（在 Codex 中输入 `*命令名`）。

### 常用命令

| 命令 | 用途 | 什么时候用 |
|------|------|-----------|
| `*analyze` | 需求分析（3-5 轮提问） | 开始一个新功能 |
| `*design` | 技术设计 | 需求确认后 |
| `*handoff` | 生成交接文档给 Blake | 设计完成后 |
| `*accept` | 验收 Blake 的实现并归档 | Blake 完成后 |
| `*bug` | 快速 bug 诊断 | 发现 bug 时 |
| `*discuss` | 自由讨论（不产出 handoff） | 讨论方向/策略 |
| `*idea` | 记录灵感 | 想到好点子时 |
| `*status` | 全景视图（Epic/Handoff/Idea） | 想看项目全貌 |

### 研究类

| 命令 | 用途 |
|------|------|
| `*research-plan` | 基于目标生成研究计划 |
| `*research-review` | 研究组合审查 |
| `*learn` | 苏格拉底式学习（通过提问理解概念） |

### 框架管理

| 命令 | 用途 |
|------|------|
| `*publish` | 推送 TAD 更新到 GitHub |
| `*sync` | 同步 TAD 到注册项目 |
| `*dream` | 整合项目知识（去重+合并） |
| `*optimize` | 分析执行轨迹，提出改进 |

---

## Blake 命令速查

| 命令 | 用途 | 什么时候用 |
|------|------|-----------|
| `*develop` | 启动 Ralph Loop（自动 Layer 1 + Layer 2） | 收到 handoff 后 |
| `*layer1` | 只跑 Layer 1（build/test/lint） | 快速自检 |
| `*layer2` | 只跑 Layer 2（专家审查） | 需要代码审查 |
| `*gate 3` | 执行 Gate 3（技术质量门） | 实现完成后 |
| `*complete` | 生成完工报告 | Gate 3 通过后 |
| `*ralph-status` | 检查 Ralph Loop 状态 | 查看进度 |

---

## 质量门禁系统

TAD 有 4 个质量门（Gate），确保每一步都有人检查：

```
Gate 1: 需求清晰吗？         ← Alex 负责
Gate 2: 设计完整吗？         ← Alex 负责（含专家审查）
Gate 3: 代码质量过关吗？     ← Blake 负责（含 build/test + 专家审查）
Gate 4: 业务需求满足了吗？   ← Alex 负责（人类确认）
```

### Gate 3 的两层检查

**Layer 1（自检）**：Blake 自己跑 build、test、lint。最多重试 15 次。

**Layer 2（专家审查）**：Blake 调用 AI 子 agent 做代码审查：
- `spec-compliance-reviewer` — 对照 handoff 逐条验证
- `code-reviewer` — 代码质量、安全、性能
- `test-runner` / `security-auditor`（按需）

---

## Capability Packs（能力包）

TAD 内置 25 个 capability pack，为不同领域提供专业知识：

### Web 开发
- `web-frontend` — React/Vue 前端工程
- `web-backend` — API 设计、数据库、安全
- `web-ui-design` — UI 设计 + anti-slop 规则
- `web-testing` — 单元/E2E/性能/可访问性测试
- `web-deployment` — CI/CD、Docker、监控

### AI/ML
- `ai-prompt-engineering` — 提示词设计+测试+CI/CD
- `ai-evaluation` — LLM 评测、红队测试
- `ai-guardrails` — 安全护栏、注入防御
- `ai-agent-architecture` — Agent 系统设计决策
- `ai-tool-integration` — MCP 服务器、CLI 工具集成

### 移动端
- `mobile-development` — React Native/Swift
- `mobile-ui-design` — iOS HIG / Material Design
- `mobile-testing` — 设备兼容性、性能
- `mobile-release` — App Store 发布

### 硬件
- `hw-circuit-design` — PCB 电路设计
- `hw-firmware` — ESP32 固件开发
- `hw-enclosure` — 外壳 3D 设计
- `hw-testing` — 硬件测试流程

### 研究/安全
- `research-methodology` — 系统性研究方法论
- `academic-research` — 学术文献综述
- `code-security` — SAST/DAST/Secret 扫描
- `supply-chain-security` — 依赖审计

Packs 按需加载 — Alex 在设计阶段根据任务关键词自动识别需要哪些 pack。

---

## 项目知识系统

TAD 自动积累项目经验到 `.tad/project-knowledge/`：

```
.tad/project-knowledge/
├── principles.md        # 第一层：方法论原则（不轻易改）
├── patterns/            # 第二层：可复用模式
│   ├── _index.md        # 模式索引
│   ├── gate-design.md   # 门禁设计经验
│   ├── shell-portability.md  # Shell 兼容性
│   └── ...
├── architecture.md      # 架构决策
├── code-quality.md      # 代码质量发现
├── security.md          # 安全经验
└── frontend-design.md   # 前端设计
```

每次 Gate 通过后，agent 评估："这次有什么值得记住的？" 有就写入对应文件。下次做类似任务时自动读取，避免重复踩坑。

---

## Migration 引擎（v2.28.0 新增）

升级 TAD 时，migration 引擎自动处理版本间的文件变更：

```
升级流程（自动的，你不需要操心）:
1. 下载新版本
2. 复制框架文件
3. ⭐ Migration 引擎介入:
   - 删除旧版本废弃的文件（有备份）
   - 重命名被移动的文件
   - 合并 CLAUDE.md（你写的内容不会丢）
   - 验证升级完整性
4. 完成

你修改过的框架文件？跳过不动 + 报告告诉你。
恶意 manifest？五步安全流水线拦截。
跑两次？幂等，第二次自动跳过。
```

---

## 与 Claude Code 的差异

| 方面 | Claude Code | Codex CLI |
|------|-------------|-----------|
| 角色激活 | `/alex` `/blake`（slash command） | `$alex` `$blake`（skill 引用） |
| Workflow 工具 | `.claude/workflows/*.workflow.js` | 不支持（用 Alex *analyze 替代） |
| MCP 服务器 | `.claude/settings.json` 配置 | `.codex/config.toml`（待激活） |
| 上下文压缩 | 自动 + session-state.md | 自动 + `/compact` |
| 权限模型 | settings.json allowlist | Codex sandbox profiles |
| sub-agent | `Agent tool` + `subagent_type` | 内置 default/worker/explorer |

**共享的（完全一样）**：Gates 1-4、Handoff 协议、Layer 2 审查、Ralph Loop、Knowledge Assessment、Completion Report 格式。

---

## 常见场景

### 场景 1: 新功能开发

```
$alex
→ *analyze（需求分析 3-5 轮）
→ *design（技术设计）
→ *handoff（生成交接文档，含专家审查）

$blake
→ *develop（Ralph Loop: 实现 → 自检 → 专家审查）
→ *gate 3（技术质量门）
→ *complete（完工报告）

$alex
→ *accept（验收 + 归档）
```

### 场景 2: Bug 修复

```
$alex
→ *bug（快速诊断 → express handoff）

$blake
→ 执行修复 → *gate 3 → *complete

$alex
→ *accept
```

### 场景 3: 纯讨论（不产出代码）

```
$alex
→ *discuss（自由讨论产品方向、技术选型等）
→ 结束时不会生成 handoff
```

### 场景 4: 大型 Epic（多阶段项目）

```
$alex
→ *analyze → 评估复杂度 → 建议拆分为 Epic
→ 定义多个 Phase，每个 Phase 一个 Handoff
→ 逐 Phase 交给 Blake 执行
→ 也可以用 YOLO 模式自动驱动全部 Phase
```

---

## 文件结构速查

```
你的项目/
├── .agents/skills/          # Codex 的 skill 目录
│   ├── alex/SKILL.md        # Alex 角色定义
│   ├── blake/SKILL.md       # Blake 角色定义
│   └── {pack}/SKILL.md      # Capability packs
├── .codex/
│   └── hooks.json           # Codex 生命周期钩子
├── .tad/
│   ├── config.yaml          # TAD 配置
│   ├── version.txt          # 当前版本号
│   ├── active/              # 进行中的工作
│   │   ├── handoffs/        # 活跃的 handoff
│   │   ├── epics/           # 活跃的 Epic
│   │   └── ideas/           # 灵感记录
│   ├── archive/             # 已完成的工作
│   ├── evidence/            # 审查证据
│   ├── project-knowledge/   # 项目知识库（自动积累）
│   ├── hooks/lib/           # 框架脚本
│   │   ├── migration-engine.sh   # 升级引擎
│   │   ├── release-verify.sh     # 发版门禁
│   │   └── derive-sync-set.sh    # 同步集推导
│   ├── migrations/          # 版本迁移 manifest
│   └── templates/           # 文档模板
├── AGENTS.md                # 角色路由（Codex 读这个）
├── CLAUDE.md                # 框架规则（Claude Code 读这个）
└── tad.sh                   # 安装/升级脚本
```

---

## 故障排除

### "$alex 没反应"
确认 `.agents/skills/alex/SKILL.md` 存在。如果不存在，重新安装：
```bash
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/tad.sh | bash -s -- --platform codex --yes
```

### "Gate 3 失败 — 没有 evidence 文件"
Blake 必须调用子 agent 做代码审查才能通过 Gate 3。检查 `.tad/evidence/reviews/` 目录。

### "Handoff 创建了但 Blake 看不到"
TAD 要求两个终端（或两次对话）：Terminal 1 = Alex，Terminal 2 = Blake。人类是两者之间的唯一桥梁，需要手动把 handoff 路径告诉 Blake。

### "升级后旧文件还在"
v2.28.0 之前的升级不会自动清理旧文件。首次升级到 2.28.0+ 后，后续升级会自动通过 migration 引擎处理。如果仍有残留，运行：
```bash
bash .tad/hooks/lib/migration-engine.sh --from <旧版本> --to 2.28.0 --target . --source <tad源目录>
```

### "Capability pack 没加载"
Packs 按需加载 — 只有当任务关键词匹配时才会激活。可以在 `$alex` 的 `*design` 阶段手动指定。

---

## 更多资源

- [README](../README.md) — 项目总览
- [CHANGELOG](../CHANGELOG.md) — 版本变更历史
- [Multi-Platform Guide](MULTI-PLATFORM.md) — 双平台技术细节
- [Ralph Loop Guide](RALPH-LOOP.md) — Blake 的迭代质量循环
- [Installation Guide](../INSTALLATION_GUIDE.md) — 详细安装选项
