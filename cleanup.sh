#!/bin/bash

# TAD错误安装清理脚本
echo "🧹 清理TAD错误安装的文件..."

# 要删除的TAD文档文件
FILES_TO_REMOVE=(
    "CLAUDE_CODE_SUBAGENTS.md"
    "CONFIG_AGENT_PROMPT.md"
    "COMPREHENSIVE_TEST_REPORT.md"
    "DEPLOYMENT.md"
    "DEPLOYMENT_PLAN.md"
    "IMPLEMENTATION_GUIDE.md"
    "MVP_PLAN.md"
    "OPTIMIZATION_REQUIREMENTS.md"
    "WORKFLOW_PLAYBOOK.md"
    "TAD_CONFIG_FIX_REPORT.md"
    "TAD_CONFIGURATION_DESIGN.md"
    "SCENARIO_EXECUTION_EXAMPLE.md"
    "GITHUB_PUBLISH_REPORT.md"
    "GITHUB_RELEASE_DESCRIPTION.md"
    "FINAL_COMPLETION_REPORT.md"
    "RELEASE_NOTES.md"
    "TRANSFORMATION_COMPLETE.md"
    "TRANSFORMATION_GUIDE.md"
    "PROJECT_STATUS.md"
    "AGENT_CONFIG_UPDATE_PROMPT.md"
    "GITHUB_SETUP_PROMPT.md"
    "INSTALLATION_GUIDE.md"
    # 不要删除项目自己的README.md
)

# 删除这些文件
for file in "${FILES_TO_REMOVE[@]}"; do
    if [ -f "$file" ]; then
        echo "删除: $file"
        rm "$file"
    fi
done

echo "✅ 清理完成！"