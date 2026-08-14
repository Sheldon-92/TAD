project_context_update:
  trigger: "*accept 命令执行时"
  file: "PROJECT_CONTEXT.md"

  update_actions:
    - section: "Current State"
      action: "更新版本、功能状态、已知问题"

    - section: "Recent Decisions"
      action: "如果本次有重大决策，添加到列表"
      max_items: 5
      overflow: "最旧的移到 docs/DECISIONS.md"

    - section: "Timeline"
      action: "添加本次里程碑"
      max_weeks: 3
      overflow: "压缩成周摘要移到 docs/HISTORY.md"

    - section: "Next Direction"
      action: "根据完成情况更新"

  aging_rules:
    decisions:
      keep_recent: 5
      archive_to: "docs/DECISIONS.md"
      archive_format: "压缩成 1 行摘要"

    timeline:
      keep_recent: "3 weeks"
      archive_to: "docs/HISTORY.md"
      archive_format: "压缩成周摘要"

  max_length: 150 lines
  if_exceeded: "强制触发老化归档"
