# TAD Installation & Usage Guide

**Version 2.0.0 - Ralph Loop Fusion**

## 方式1：一键安装（推荐）

```bash
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/tad.sh | bash
```

这个脚本会自动：
- **全新安装**：创建完整 TAD 结构（`.tad/`, `.claude/`, `CLAUDE.md`）
- **升级**：检测当前版本并原地升级
- **保留数据**：你的 handoffs、learnings、evidence 不会被覆盖

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

### `.tad`文件夹结构 (v2.0)
```
.tad/
├── config.yaml           # TAD核心配置
├── ralph-config/         # Ralph Loop配置 (NEW)
│   ├── loop-config.yaml  # Layer 1/2设置
│   └── expert-criteria.yaml # 专家通过条件
├── schemas/              # JSON Schema验证 (NEW)
├── active/handoffs/      # 当前进行中的handoffs
├── archive/handoffs/     # 已完成的handoffs
├── evidence/
│   ├── reviews/          # Gate证据文件
│   └── ralph-loops/      # Ralph迭代证据 (NEW)
├── project-knowledge/    # 项目特定知识
└── templates/            # 文档模板
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
- [ ] `.tad/agents/` 包含两个agent文件
- [ ] `WORKFLOW_PLAYBOOK.md` 可访问
- [ ] `CLAUDE_CODE_SUBAGENTS.md` 可访问

### 测试命令
```bash
# 检查版本
cat .tad/version.txt
# 应该返回: 2.0

# 验证Ralph Loop配置
ls .tad/ralph-config/
# 应该返回: expert-criteria.yaml  loop-config.yaml

# 验证Schema
ls .tad/schemas/
# 应该返回: expert-criteria.schema.json  loop-config.schema.json
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
│   └── skills/            # 技能定义
├── .tad/                  # TAD核心文件
│   ├── config.yaml        # 主配置
│   ├── ralph-config/      # Ralph Loop配置 (v2.0)
│   ├── schemas/           # JSON Schema验证 (v2.0)
│   ├── templates/         # 文档模板
│   └── project-knowledge/ # 项目知识
├── docs/
│   ├── RALPH-LOOP.md      # Ralph Loop文档 (v2.0)
│   └── MIGRATION-v2.md    # 迁移指南 (v2.0)
├── README.md              # TAD介绍
├── INSTALLATION_GUIDE.md  # 本文档
├── CHANGELOG.md           # 版本历史
└── tad.sh                 # 一键安装/升级脚本
```

## 升级现有项目

```bash
# 从任何v1.x版本升级到v2.0
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/tad.sh | bash

# 脚本会自动：
# - 检测当前版本
# - 保留你的handoffs、learnings、evidence
# - 添加Ralph Loop配置
# - 更新Gate定义
```

## 快速开始 (v2.0)

```bash
# 1. 安装TAD
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/tad.sh | bash

# 2. 打开两个Terminal
# Terminal 1: /alex (设计与规划)
# Terminal 2: /blake (实现与Ralph Loop)

# 3. 开始协作
# Terminal 1 (Alex): 创建handoff
# Terminal 2 (Blake): *develop 自动进入Ralph Loop
```

## 总结

TAD v2.0 核心特性：
1. **Ralph Loop** - 自动质量循环直到专家批准
2. **Gate重构** - Gate 3扩展（技术质量），Gate 4简化（业务验收）
3. **分层超时** - 根据变更规模自动调整（3-20分钟）
4. **状态持久化** - 崩溃恢复，支持checkpoint/resume

任何新项目只要安装TAD，Claude Code就能立即识别并使用TAD方法论。