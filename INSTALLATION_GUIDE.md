# TAD Installation & Usage Guide

**Version 2.2.1 - Beneficial Friction for AI-Assisted Development**

## 方式1：一键安装（推荐）

```bash
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/tad.sh | bash
```

这个脚本会自动：
- **检测平台**：自动检测 Claude Code、Codex CLI、Gemini CLI
- **全新安装**：创建完整 TAD 结构（`.tad/`, `.claude/`, `CLAUDE.md`）
- **多平台配置**：为检测到的每个平台生成配置文件
- **升级**：检测当前版本并原地升级
- **保留数据**：你的 handoffs、learnings、evidence 不会被覆盖
- **失败回滚**：出错时自动恢复备份

## 方式2：Git安装

### Step 1: 在新项目中克隆TAD
```bash
# 在你的新项目根目录
git clone https://github.com/Sheldon-92/TAD.git .tad-temp

# 复制必要文件
cp -r .tad-temp/.tad ./
cp -r .tad-temp/.claude ./
cp .tad-temp/CLAUDE.md ./

# 清理临时文件
rm -rf .tad-temp

# 添加到.gitignore（避免提交工作文件）
echo ".tad/active/" >> .gitignore
```

### Step 2: 用Claude Code打开项目
```bash
# 在项目目录
claude .
# 或使用 Claude Code UI 打开文件夹
```

### Step 3: Claude Code自动识别TAD
当Claude Code检测到`.claude/settings.json`，会：
1. 自动加载TAD配置
2. 显示TAD可用提示
3. 提供TAD命令（如/tad-init）

### Step 4: 激活TAD Agents
```markdown
# 在Claude Code中开两个对话

# 对话1 - Agent A
You are Agent A. Read .tad/agents/agent-a-architect.md

# 对话2 - Agent B
You are Agent B. Read .tad/agents/agent-b-executor.md
```

## 方式3：直接下载

### 从GitHub下载TAD压缩包
1. 访问 https://github.com/Sheldon-92/TAD
2. Download ZIP
3. 解压到项目目录
4. 确保`.claude`和`.tad`文件夹在项目根目录

## Claude Code配置说明

### `.claude`文件夹结构
```
.claude/
├── settings.json       # TAD框架识别配置
├── commands/           # TAD命令定义
│   ├── tad-alex.md     # /alex - Solution Lead
│   ├── tad-blake.md    # /blake - Execution Master (with Ralph Loop)
│   ├── tad-gate.md     # /gate - Quality gates v2
│   └── ...
└── skills/             # Agent skills
    └── code-review/    # Code review checklist
```

### `.tad`文件夹结构 (v2.2.1)
```
.tad/
├── config.yaml           # TAD核心配置
├── version.txt           # 版本号 (2.2.1)
├── skills/               # 平台无关技能 (8 P0 skills)
│   ├── testing/SKILL.md
│   ├── code-review/SKILL.md
│   ├── security-audit/SKILL.md
│   ├── performance/SKILL.md
│   ├── ux-review/SKILL.md
│   ├── architecture/SKILL.md
│   ├── api-design/SKILL.md
│   └── debugging/SKILL.md
├── ralph-config/         # Ralph Loop配置
│   ├── loop-config.yaml
│   └── expert-criteria.yaml
├── templates/            # 文档模板 (handoff, completion, output formats)
├── active/handoffs/      # 当前进行中的handoffs
├── archive/handoffs/     # 已完成的handoffs
├── evidence/reviews/     # Gate证据文件
└── project-knowledge/    # 项目特定知识
```

### 关键配置文件

#### `.tad/config.yaml`
- TAD核心配置
- Gate 3/4 v2定义
- 专家subagent配置

#### `.tad/ralph-config/loop-config.yaml`
- Layer 1自检配置（build/test/lint/tsc）
- Layer 2专家审查配置
- 断路器和升级阈值
- 状态持久化设置

## 工作流程

### 1. 新项目启动
```bash
# 创建新项目
mkdir my-new-project
cd my-new-project

# 安装TAD（选择上述任一方式）
# ...

# 用Claude Code打开
claude .

# Claude会自动识别TAD并提示：
# "TAD framework detected. Use '/tad-init' to initialize."
```

### 2. 初始化TAD
```markdown
# 在Claude Code中运行
/tad-init

# 系统会：
- 创建项目结构
- 复制必要文件
- 生成初始文档
```

### 3. 开始开发
```markdown
# 激活Agents（两个终端/对话）
# 陈述需求
# 自动进入对应场景工作流
```

## 验证安装

### 检查清单
- [ ] `.claude/settings.json` 存在
- [ ] `.tad/config.yaml` 存在
- [ ] `.tad/version.txt` 显示 2.2.1
- [ ] `.tad/skills/` 包含 8 个技能目录
- [ ] `.claude/commands/tad-maintain.md` 存在

### 测试命令
```bash
# 检查版本
cat .tad/version.txt
# 应该返回: 2.2.1

# 验证技能系统
ls .tad/skills/
# 应该返回: api-design  architecture  code-review  debugging  performance  security-audit  testing  ux-review

# 验证 /tad-maintain 命令
cat .claude/commands/tad-maintain.md | head -1
# 应该返回: # TAD Maintain Command

# 验证Ralph Loop配置
ls .tad/ralph-config/
# 应该返回: expert-criteria.yaml  loop-config.yaml
```

## 常见问题

### Q: Claude Code没有识别TAD？
A: 检查`.claude/settings.json`是否存在且格式正确

### Q: 命令不可用？
A: 确保`.claude/commands/`目录包含命令定义文件

### Q: Sub-agents调用失败？
A: 验证使用的是真实的Claude Code sub-agents，参考`CLAUDE_CODE_SUBAGENTS.md`

### Q: 如何更新TAD版本？
A: 从GitHub拉取最新版本，覆盖`.tad/`和`.claude/`目录

## GitHub Repository Structure

```
TAD/
├── .claude/               # Claude Code配置
│   ├── settings.json      # 框架识别
│   ├── commands/          # 命令定义 (/alex, /blake, /gate...)
│   └── skills/            # Claude增强技能
├── .tad/                  # TAD核心文件
│   ├── config.yaml        # 主配置
│   ├── skills/            # 平台无关技能 (8 P0 skills)
│   ├── ralph-config/      # Ralph Loop配置
│   ├── templates/         # 文档模板
│   └── project-knowledge/ # 项目知识
├── docs/
│   ├── MULTI-PLATFORM.md  # 多平台指南 (v2.1 NEW)
│   ├── RALPH-LOOP.md      # Ralph Loop文档
│   └── MIGRATION-v2.md    # 迁移指南
├── README.md              # TAD介绍
├── INSTALLATION_GUIDE.md  # 本文档
├── CHANGELOG.md           # 版本历史
└── tad.sh                 # 一键安装/升级脚本 (多平台支持)
```

## 升级现有项目

```bash
# 从任何旧版本升级到v2.2.1
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/tad.sh | bash

# 脚本会自动：
# - 检测当前版本
# - 检测已安装的AI CLI工具 (Claude/Codex/Gemini)
# - 保留你的handoffs、learnings、evidence
# - 安装8个P0技能文件
# - 为检测到的平台生成配置
```

## 快速开始 (v2.1)

```bash
# 1. 安装TAD
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/tad.sh | bash

# 2. 根据检测到的平台使用相应命令：

# Claude Code:
# Terminal 1: /alex (设计与规划)
# Terminal 2: /blake (实现与Ralph Loop)

# Codex CLI:
# /prompts:tad_alex (设计与规划)
# /prompts:tad_blake (实现)

# Gemini CLI:
# /tad-alex (设计与规划)
# /tad-blake (实现)

# 3. 开始协作
# Alex: 创建handoff
# Blake: *develop 自动进入质量循环
```

## 多平台使用

| 平台 | 项目指令 | 命令格式 | 技能执行 |
|------|----------|----------|----------|
| Claude Code | `CLAUDE.md` | `/alex`, `/blake` | subagent |
| Codex CLI | `AGENTS.md` | `/prompts:tad_alex` | self-check |
| Gemini CLI | `GEMINI.md` | `/tad-alex` | self-check |

**技能执行差异**：
- **Claude Code**: 调用原生 subagent 进行深度审查
- **Codex/Gemini**: 读取 `.tad/skills/` 中的 SKILL.md，按 checklist 自检

## 总结

TAD v2.2.1 核心特性：
1. **Beneficial Friction** - AI 做执行，人类守护价值（三个关键摩擦点）
2. **配对测试协议** - 跨工具 E2E 测试（TAD CLI → Claude Desktop）
3. **自适应复杂度** - 根据任务规模自动建议流程深度
4. **Ralph Loop** - 自动质量循环直到专家批准
5. **多平台支持** - Claude Code、Codex CLI、Gemini CLI

任何新项目只要安装TAD，Claude Code、Codex CLI 或 Gemini CLI 都能立即识别并使用TAD方法论。