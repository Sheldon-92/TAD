# ask_user_question_hook — B 类复核（2026-10-06）
探针：hooks 文档（2026-10-06）事件全集（PreToolUse/PermissionRequest/PostToolUse/PreCompact/PostCompact/UserPromptSubmit/SubagentStop/Stop/SessionStart/SubagentStart/SessionEnd/Interrupt）中无 AskUserQuestion 等价工具；features list 中 default_mode_request_user_input 为 under development/false。本仓保留映射（^ask_user_question$ → askuser-capture.sh）仍可能不触发，证据完整性缺口如旧。
判定：限制仍成立 → 刷新（next_review 2026-11-05）。
