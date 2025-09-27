# TAD Installation & Usage Guide

## 方式1：Git安装（推荐）

### Step 1: 在新项目中克隆TAD
```bash
# 在你的新项目根目录
git clone https://github.com/[your-username]/TAD.git .tad-temp

# 复制必要文件
cp -r .tad-temp/.tad ./
cp -r .tad-temp/.claude ./
cp .tad-temp/WORKFLOW_PLAYBOOK.md ./
cp .tad-temp/CLAUDE_CODE_SUBAGENTS.md ./
cp .tad-temp/README.md ./.tad/

# 清理临时文件
rm -rf .tad-temp

# 添加到.gitignore（避免提交TAD框架文件）
echo ".tad/working/" >> .gitignore
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

## 方式2：NPM包安装（未来）

```bash
# 未来可以发布为npm包
npm install -g tad-framework
tad init
```

## 方式3：直接下载

### 从GitHub下载TAD压缩包
1. 访问 https://github.com/[your-username]/TAD
2. Download ZIP
3. 解压到项目目录
4. 确保`.claude`和`.tad`文件夹在项目根目录

## Claude Code配置说明

### `.claude`文件夹结构
```
.claude/
├── settings.json       # TAD框架识别配置
├── commands/          # TAD命令定义
│   ├── tad-init.md   # 初始化命令
│   ├── tad-status.md # 状态检查命令
│   └── tad-scenario.md # 场景执行命令
└── agents/           # （可选）额外agent配置
```

### 关键配置文件

#### `.claude/settings.json`
- 告诉Claude Code这是TAD项目
- 定义可用命令
- 指定自动加载的文件
- 配置agent激活方式

#### `.tad/config.yaml`
- TAD核心配置
- 定义6个场景工作流
- 配置16个真实sub-agents
- 设置文档结构

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
```markdown
# 在Claude Code中
/tad-status

# 应该返回：
✅ TAD Framework v2.0 installed
✅ Configuration valid
✅ 6 scenarios available
✅ 16 sub-agents configured
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
│   ├── settings.json     # 框架识别
│   └── commands/         # 命令定义
├── .tad/                 # TAD核心文件
│   ├── config.yaml       # 主配置
│   ├── agents/           # Agent定义
│   ├── context/          # 项目文档模板
│   └── working/          # 工作文档模板
├── WORKFLOW_PLAYBOOK.md  # 6个场景说明
├── CLAUDE_CODE_SUBAGENTS.md # Sub-agents列表
├── README.md             # TAD介绍
├── INSTALLATION_GUIDE.md # 本文档
└── CONFIG_AGENT_PROMPT.md # 配置管理指南
```

## 发布到GitHub

```bash
# 在TAD目录
git init
git add .
git commit -m "TAD Framework v2.0"
git remote add origin https://github.com/[your-username]/TAD.git
git push -u origin main

# 创建Release
# 在GitHub上创建v2.0 release，附带安装说明
```

## 总结

通过`.claude`文件夹配置，TAD可以：
1. **被Claude Code自动识别**
2. **提供专用命令**（/tad-init等）
3. **自动加载核心文件**
4. **简化Agent激活流程**

这样任何新项目只要安装TAD，Claude Code就能立即识别并使用TAD方法论。