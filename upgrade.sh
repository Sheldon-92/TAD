#!/bin/bash

# TAD Framework Smart Upgrade Script
# 只更新框架文件，保留用户工作内容

set -e

echo ""
echo "======================================"
echo "TAD Framework Smart Upgrade"
echo "======================================"
echo ""

# 检查是否在项目目录
if [ ! -d ".tad" ]; then
    echo "❌ Error: Not in a TAD project directory"
    echo "Please run this script from your project root"
    exit 1
fi

# 显示当前版本
CURRENT_VERSION="unknown"
if [ -f ".tad/version.txt" ]; then
    CURRENT_VERSION=$(cat .tad/version.txt)
fi
echo "📌 Current version: $CURRENT_VERSION"

# 确认升级
echo ""
echo "This will upgrade TAD framework files while preserving:"
echo "  ✅ .tad/active/handoffs/"
echo "  ✅ .tad/working/"
echo "  ✅ .tad/context/"
echo "  ✅ .tad/learnings/"
echo "  ✅ .tad/evidence/"
echo ""
read -p "Continue? (y/n): " -n 1 -r < /dev/tty
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Upgrade cancelled"
    exit 0
fi

echo ""
echo "📥 Downloading latest TAD Framework..."
curl -sSL https://github.com/Sheldon-92/TAD/archive/refs/heads/main.tar.gz | tar -xz

echo "📦 Updating framework files..."

# 更新配置文件（框架核心）
echo "  → config.yaml, skills-config.yaml"
cp TAD-main/.tad/config.yaml .tad/
cp TAD-main/.tad/skills-config.yaml .tad/ 2>/dev/null || true

# 更新命令文件
echo "  → /alex, /blake, /gate, /tad-* commands"
cp TAD-main/.claude/commands/tad-*.md .claude/commands/

# 更新模板（框架模板，不是用户文档）
echo "  → templates/"
cp -r TAD-main/.tad/templates/* .tad/templates/ 2>/dev/null || true

# 更新任务定义
echo "  → tasks/"
cp -r TAD-main/.tad/tasks/* .tad/tasks/ 2>/dev/null || true

# 更新 CLAUDE.md（项目规则）
echo "  → CLAUDE.md"
cp TAD-main/CLAUDE.md ./ 2>/dev/null || true

# 删除废弃的文件
echo "  → Removing deprecated files"
rm -f .tad/agents/agent-a-architect*.md 2>/dev/null || true
rm -f .tad/agents/agent-b-executor*.md 2>/dev/null || true
rm -f .tad/config-v1.1.yaml 2>/dev/null || true
rm -f .tad/config-v1.0.yaml 2>/dev/null || true

# 更新版本号
echo "1.4" > .tad/version.txt

# 清理
rm -rf TAD-main

echo ""
echo "======================================"
echo "✅ Upgrade Complete!"
echo "======================================"
echo ""
echo "📋 Updated:"
echo "  • Framework configurations"
echo "  • Slash commands (/alex, /blake, etc.)"
echo "  • Templates and tasks"
echo "  • CLAUDE.md rules"
echo ""
echo "📋 Preserved:"
echo "  • Your handoffs in .tad/active/handoffs/"
echo "  • Your work context in .tad/working/"
echo "  • Your learnings in .tad/learnings/"
echo "  • All evidence and project data"
echo ""
echo "🎯 Next steps:"
echo "  1. Restart Claude Code"
echo "  2. Run /alex to verify upgrade"
echo ""
