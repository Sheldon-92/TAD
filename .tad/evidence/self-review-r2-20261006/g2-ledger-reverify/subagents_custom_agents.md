# subagents_custom_agents — B 类复核（2026-10-06）
探针：features list 示 multi_agent stable=true（内置 subagent 可用）；本仓 .codex/ 仅 hooks.json、无 agents/ 目录——TAD 侧 custom agents 候选仍未激活。文档复查：subagents 页（2026-10-06）载明平台已正式支持 ~/.codex/agents/ 与 .codex/agents/ 下 TOML 自定义 agent（name/description/developer_instructions 必备）——平台机制存在，但本 adapter 不供不启，限制（accepted_limitation）以 adapter 口径仍成立。current_behavior 已据此补注平台机制存在一行。
判定：限制仍成立 → 刷新（next_review 2026-11-05）。
