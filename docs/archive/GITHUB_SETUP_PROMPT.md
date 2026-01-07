# TAD GitHub发布与远程安装配置Prompt

## 给配置Agent的指令

```
你是TAD配置管理Agent。现在需要将TAD框架发布到GitHub并配置远程一键安装功能。

GitHub仓库：https://github.com/Sheldon-92/TAD.git

## 任务1：推送到GitHub

执行以下Git操作：

1. 初始化Git（如果还没有）
```bash
cd /Users/sheldonzhao/programs/TAD
git init
```

2. 配置远程仓库
```bash
git remote add origin https://github.com/Sheldon-92/TAD.git
# 或如果已存在，更新远程URL
git remote set-url origin https://github.com/Sheldon-92/TAD.git
```

3. 创建.gitignore文件
```bash
cat > .gitignore << 'EOF'
.DS_Store
.tad/working/
.tad/context/PROJECT.md
.tad/context/REQUIREMENTS.md
.tad/context/ARCHITECTURE.md
.tad/context/DECISIONS.md
node_modules/
*.log
*.tmp
EOF
```

4. 提交所有文件
```bash
git add .
git commit -m "TAD Framework v1.0 - Triangle Agent Development

Features:
- Simplified 3-party collaboration (Human + Agent A + Agent B)
- 6 predefined scenarios for common development tasks
- Integration with 16 real Claude Code sub-agents
- Claude Code CLI automatic recognition via .claude folder
- Clean configuration without BMAD complexity

Usage:
See INSTALLATION_GUIDE.md for installation instructions"
```

5. 推送到GitHub
```bash
git branch -M main
git push -u origin main
```

## 任务2：创建一键安装脚本

创建文件：install.sh

```bash
#!/bin/bash

# TAD Framework Quick Installer
# Usage: curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/install.sh | bash

echo "🚀 Installing TAD Framework v1.0..."

# Check if in a git repository
if [ -d ".git" ]; then
    echo "✅ Git repository detected"
else
    echo "⚠️  Not a git repository. Initializing..."
    git init
fi

# Check if TAD already exists
if [ -d ".tad" ]; then
    echo "⚠️  TAD already exists in this project."
    read -p "Do you want to reinstall? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
    rm -rf .tad .claude
fi

# Download TAD from GitHub
echo "📥 Downloading TAD Framework..."
curl -sSL https://github.com/Sheldon-92/TAD/archive/refs/heads/main.tar.gz | tar -xz

# Move files to correct locations
echo "📦 Installing TAD files..."
mv TAD-main/.tad ./
mv TAD-main/.claude ./
cp TAD-main/WORKFLOW_PLAYBOOK.md ./
cp TAD-main/CLAUDE_CODE_SUBAGENTS.md ./
cp TAD-main/README.md ./.tad/
cp TAD-main/CONFIG_AGENT_PROMPT.md ./.tad/

# Clean up
rm -rf TAD-main

# Update .gitignore
if ! grep -q ".tad/working/" .gitignore 2>/dev/null; then
    echo "📝 Updating .gitignore..."
    cat >> .gitignore << 'EOF'

# TAD Framework
.tad/working/
.tad/context/*.md
!.tad/context/.gitkeep
EOF
fi

# Create initial directories
mkdir -p .tad/context
mkdir -p .tad/working
touch .tad/context/.gitkeep
touch .tad/working/.gitkeep

echo "✅ TAD Framework installed successfully!"
echo ""
echo "Next steps:"
echo "1. Open project with Claude Code: claude ."
echo "2. Run /tad-status to verify installation"
echo "3. Run /tad-init to initialize project"
echo "4. Start with /tad-scenario [scenario_name]"
echo ""
echo "Available scenarios:"
echo "  - new_project"
echo "  - add_feature"
echo "  - bug_fix"
echo "  - performance"
echo "  - refactoring"
echo "  - deployment"
echo ""
echo "Documentation: https://github.com/Sheldon-92/TAD"
```

## 任务3：创建README更新

更新README.md，添加快速安装部分：

```markdown
## 🚀 Quick Installation

### One-line installer (Recommended)
```bash
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/install.sh | bash
```

### Manual installation
```bash
git clone https://github.com/Sheldon-92/TAD.git .tad-temp
cp -r .tad-temp/.tad ./
cp -r .tad-temp/.claude ./
cp .tad-temp/*.md ./
rm -rf .tad-temp
```

### NPM installation (Coming soon)
```bash
npm install -g tad-framework
tad init
```
```

## 任务4：创建GitHub Release

1. 推送所有更改后，在GitHub上创建Release：

```bash
# 创建标签
git tag -a v1.0.0 -m "TAD Framework v1.0.0 - Initial release"
git push origin v1.0.0
```

2. 在GitHub网页上：
   - 访问 https://github.com/Sheldon-92/TAD/releases/new
   - 选择标签 v1.0.0
   - 标题：TAD Framework v1.0.0
   - 描述：
   ```
   # TAD Framework v1.0.0

   Triangle Agent Development - Simplified human-AI collaboration framework for Claude Code.

   ## Features
   - ✅ 3-party collaboration model (Human + Agent A + Agent B)
   - ✅ 6 predefined development scenarios
   - ✅ 16 real Claude Code sub-agents integration
   - ✅ Automatic recognition by Claude Code CLI
   - ✅ One-line installation script

   ## Installation
   ```bash
   curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/install.sh | bash
   ```

   ## What's New
   - Initial release of TAD framework
   - Simplified from BMAD to 3-party collaboration
   - Claude Code CLI integration via .claude folder
   - Single config.yaml for all settings
   - Complete documentation and examples

   ## Documentation
   - [Installation Guide](INSTALLATION_GUIDE.md)
   - [Workflow Playbook](WORKFLOW_PLAYBOOK.md)
   - [Configuration Guide](CONFIG_AGENT_PROMPT.md)
   ```

## 任务5：验证远程安装

在一个新目录测试安装：

```bash
# 创建测试项目
mkdir /tmp/test-tad
cd /tmp/test-tad

# 运行远程安装
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/install.sh | bash

# 验证安装
ls -la .tad/
ls -la .claude/

# 清理测试
cd ~
rm -rf /tmp/test-tad
```

## 输出报告

完成后报告：

✅ Git仓库已初始化
✅ 推送到 https://github.com/Sheldon-92/TAD.git
✅ install.sh 脚本已创建
✅ README.md 已更新快速安装说明
✅ GitHub Release v1.0.0 已创建
✅ 一键安装命令可用：
   curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/install.sh | bash

用户现在可以在任何项目中一行命令安装TAD框架。

立即执行这些任务。
```