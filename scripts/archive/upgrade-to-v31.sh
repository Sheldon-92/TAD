#!/bin/bash

echo "========================================"
echo "TAD v3.1 升级脚本"
echo "从 v3.0 升级到 v3.1"
echo "========================================"
echo ""

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 检查是否在TAD项目根目录
if [ ! -d ".tad" ]; then
    echo -e "${RED}错误: 当前目录不是TAD项目根目录${NC}"
    echo "请在TAD项目根目录运行此脚本"
    exit 1
fi

# 检查当前版本
if [ ! -f ".tad/version.txt" ]; then
    echo -e "${YELLOW}警告: 未找到version.txt，假设为v3.0${NC}"
    CURRENT_VERSION="3.0"
else
    CURRENT_VERSION=$(cat .tad/version.txt)
fi

echo -e "${BLUE}当前版本: ${CURRENT_VERSION}${NC}"
echo -e "${BLUE}目标版本: 3.1.0${NC}"
echo ""

# 确认升级
read -p "确认开始升级? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "升级已取消"
    exit 0
fi

echo ""
echo "开始升级..."
echo ""

# Step 1: 备份
echo -e "${YELLOW}[1/5] 备份现有配置...${NC}"
BACKUP_DIR=".backup/v3.0-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

cp .tad/config.yaml "$BACKUP_DIR/" 2>/dev/null
cp .tad/templates/handoff-a-to-b.md "$BACKUP_DIR/" 2>/dev/null
cp .tad/version.txt "$BACKUP_DIR/" 2>/dev/null

echo -e "${GREEN}✅ 备份完成: $BACKUP_DIR${NC}"
echo ""

# Step 2: 创建必要目录
echo -e "${YELLOW}[2/5] 创建目录结构...${NC}"
mkdir -p .tad/guides
mkdir -p .tad/evidence/patterns
mkdir -p .tad/evidence/failures
mkdir -p .tad/evidence/metrics

echo -e "${GREEN}✅ 目录创建完成${NC}"
echo ""

# Step 3: 检查v3.1升级计划文档
echo -e "${YELLOW}[3/5] 检查升级文档...${NC}"
if [ ! -f "TAD_V3.1_COMPREHENSIVE_UPGRADE_PLAN.md" ]; then
    echo -e "${RED}错误: 未找到 TAD_V3.1_COMPREHENSIVE_UPGRADE_PLAN.md${NC}"
    echo "请确保该文件存在于项目根目录"
    exit 1
fi
echo -e "${GREEN}✅ 升级文档已找到${NC}"
echo ""

# Step 4: 提示手动更新config.yaml
echo -e "${YELLOW}[4/5] 配置文件更新${NC}"
echo ""
echo -e "${BLUE}重要提示：${NC}"
echo "config.yaml 包含v3.1的完整配置（716行新增内容）"
echo "请按照以下步骤手动更新："
echo ""
echo "1. 打开 TAD_V3.1_COMPREHENSIVE_UPGRADE_PLAN.md"
echo "2. 找到 '第五部分：配置文件完整更新' (第1195行)"
echo "3. 复制完整的v3.1配置到 .tad/config.yaml 末尾"
echo ""
echo "或者，如果已经更新了config.yaml，请继续..."
echo ""
read -p "config.yaml 已经更新? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}请先更新config.yaml后再继续${NC}"
    exit 0
fi

# Step 5: 验证升级
echo ""
echo -e "${YELLOW}[5/5] 验证升级...${NC}"

if [ -f "./verify-v31-upgrade.sh" ]; then
    chmod +x ./verify-v31-upgrade.sh
    ./verify-v31-upgrade.sh
    VERIFY_RESULT=$?
    
    if [ $VERIFY_RESULT -eq 0 ]; then
        echo ""
        echo -e "${GREEN}========================================${NC}"
        echo -e "${GREEN}🎉 升级成功完成！${NC}"
        echo -e "${GREEN}========================================${NC}"
        echo ""
        echo "下一步："
        echo "1. 查看升级报告: cat TAD_V3.1_UPGRADE_COMPLETE.md"
        echo "2. 阅读Human指南: cat .tad/guides/human-quick-reference.md"
        echo "3. 开始试点项目测试v3.1功能"
    else
        echo -e "${RED}验证失败，请检查错误信息${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}验证脚本未找到，跳过验证${NC}"
    echo "请手动检查升级是否成功"
fi

echo ""
echo "升级日志已保存到备份目录: $BACKUP_DIR"
