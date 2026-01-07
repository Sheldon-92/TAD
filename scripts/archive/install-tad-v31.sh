#!/bin/bash

echo "========================================"
echo "TAD v3.1 全新安装脚本"
echo "Triangle Agent Development Framework"
echo "========================================"
echo ""

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 默认安装目录
INSTALL_DIR="${1:-.tad}"

echo -e "${BLUE}安装目录: ${INSTALL_DIR}${NC}"
echo ""

# 检查是否已存在
if [ -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}警告: 目录 $INSTALL_DIR 已存在${NC}"
    read -p "是否覆盖? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "安装已取消"
        exit 0
    fi
    echo "备份现有目录到 ${INSTALL_DIR}.backup.$(date +%Y%m%d_%H%M%S)"
    mv "$INSTALL_DIR" "${INSTALL_DIR}.backup.$(date +%Y%m%d_%H%M%S)"
fi

echo "开始安装 TAD v3.1..."
echo ""

# Step 1: 创建目录结构
echo -e "${YELLOW}[1/6] 创建目录结构...${NC}"
mkdir -p "$INSTALL_DIR"/{agents,archive,checklists,context,data,evidence/{patterns,failures,metrics},gates,guides,sub-agents,tasks,templates,workflows,working}

echo -e "${GREEN}✅ 目录结构创建完成${NC}"
echo ""

# Step 2: 创建版本文件
echo -e "${YELLOW}[2/6] 创建版本文件...${NC}"
echo "3.1.0" > "$INSTALL_DIR/version.txt"
echo -e "${GREEN}✅ 版本文件创建完成${NC}"
echo ""

# Step 3: 提示下载配置文件
echo -e "${YELLOW}[3/6] 配置文件${NC}"
echo ""
echo -e "${BLUE}请按照以下步骤获取配置文件：${NC}"
echo ""
echo "选项1 (推荐): 从Git仓库克隆"
echo "  git clone https://github.com/your-org/TAD.git"
echo "  cp TAD/.tad/config.yaml $INSTALL_DIR/"
echo ""
echo "选项2: 手动创建"
echo "  1. 创建 $INSTALL_DIR/config.yaml"
echo "  2. 从 TAD_V3.1_COMPREHENSIVE_UPGRADE_PLAN.md 复制配置"
echo "  3. 粘贴到 config.yaml"
echo ""
read -p "config.yaml 已放置完成? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}请先放置config.yaml后继续${NC}"
    echo "安装已暂停"
    exit 0
fi

# Step 4: 创建基础模板
echo ""
echo -e "${YELLOW}[4/6] 创建模板文件...${NC}"

# 创建handoff模板（简化版，引导用户获取完整版）
cat > "$INSTALL_DIR/templates/handoff-a-to-b.md" << 'TEMPLATE_EOF'
# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**请从TAD项目获取完整的v3.1 handoff模板**

完整模板包含：
- 强制问题回答（MQ1-5）
- Phase划分指导
- 证据收集要求
- Sub-Agent使用建议

获取方式：
1. 从 TAD 仓库: .tad/templates/handoff-a-to-b.md
2. 或从升级文档: TAD_V3.1_COMPREHENSIVE_UPGRADE_PLAN.md (第1955行)
TEMPLATE_EOF

echo -e "${GREEN}✅ 模板文件创建完成${NC}"
echo ""

# Step 5: 创建指南文档
echo -e "${YELLOW}[5/6] 创建指南文档...${NC}"

cat > "$INSTALL_DIR/guides/README.md" << 'GUIDE_EOF'
# TAD v3.1 指南文档

本目录包含使用TAD v3.1的关键指南：

## 必读文档

1. **human-quick-reference.md** - Human快速参考
   - 无需技术知识的审查指南
   - Gate 2和Phase检查说明
   - 审查技巧和常见问题

2. **evidence-collection-guide.md** - 证据收集指南
   - Alex和Blake的证据提供指南
   - 6种证据类型详解
   - 快速收集技巧

## 获取完整指南

从TAD仓库复制以下文件到本目录：
- human-quick-reference.md
- evidence-collection-guide.md

或参考：TAD_V3.1_COMPREHENSIVE_UPGRADE_PLAN.md
GUIDE_EOF

echo -e "${GREEN}✅ 指南文档创建完成${NC}"
echo ""

# Step 6: 创建指标追踪文件
echo -e "${YELLOW}[6/6] 创建指标追踪文件...${NC}"

cat > "$INSTALL_DIR/evidence/metrics/tad-v31-metrics.yaml" << 'METRICS_EOF'
# TAD v3.1 指标追踪
tracking_start_date: $(date +%Y-%m-%d)

quality_metrics:
  problem_detection:
    gate2_issues_found: 0
    phase_checkpoint_issues: 0
    total_issues_found: 0

human_engagement:
  gate2_reviews:
    completed: 0
    completion_rate: "0%"

mq_effectiveness:
  MQ1_historical_code:
    triggered: 0
    issues_caught: 0
  MQ2_function_existence:
    triggered: 0
    issues_caught: 0

learning_outcomes:
  principles_learned: []
  patterns_recognized: []

projects: []
METRICS_EOF

echo -e "${GREEN}✅ 指标追踪文件创建完成${NC}"
echo ""

# 完成提示
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}🎉 TAD v3.1 安装完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "安装位置: $INSTALL_DIR"
echo ""
echo -e "${BLUE}下一步：${NC}"
echo "1. 确保已复制完整的 config.yaml"
echo "2. 复制完整的模板文件 (handoff-a-to-b.md)"
echo "3. 复制指南文档到 $INSTALL_DIR/guides/"
echo "4. 阅读 Human快速参考: $INSTALL_DIR/guides/human-quick-reference.md"
echo ""
echo -e "${BLUE}推荐资源：${NC}"
echo "- TAD_V3.1_COMPREHENSIVE_UPGRADE_PLAN.md - 完整升级指南"
echo "- TAD_V3.1_UPGRADE_COMPLETE.md - 功能说明"
echo ""
echo "开始使用 TAD v3.1 吧！"
