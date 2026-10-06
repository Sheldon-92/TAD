# context_compaction — C 类挂起（2026-10-06）
须鉴权会话实测（PreCompact 投递测量）。当次尝试：/tmp 隔离目录 `codex exec --json -s read-only`（codex-cli 0.149.0、ChatGPT 登录态）——JSONL 流返回 turn.failed，厂商原话："You've hit your usage limit. ... try again at Oct 10th, 2026 2:24 PM."（2026-10-06T18:52Z 实测）。配额未恢复 → 按 HANDOFF 停步点挂起：本条 last_verified/next_review 不动，不以文档核对充数。
旁证（不作刷新依据）：hooks 文档确认 PreCompact 为现行事件；features list 示 remote_compaction_v2 stable=true。
