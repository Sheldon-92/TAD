# Runtime Adapter Instance — Codex（运行时适配器实例声明）

按 `runtime-adapter-checklist.md` 六维填实。版本值＝2026-10-06 Phase 0 复测（OC-6）。

| 维 | 声明值 |
|---|---|
| ① 入口 | 二进制 `codex`（grokbox `~/.local/bin/codex`），版本 **0.159.3**；无头面 `codex exec --sandbox workspace-write "<任务>"`，stdin 关闭；在 git 仓内运行（骨架仓已 init）。 |
| ② 认证 | ChatGPT 账号登录态（grokbox 侧既有登录）；失效信号实测（2026-10-06）：账号用量上限时首调即 exit 1，厂商原文 "You've hit your usage limit … try again at Oct 10th, 2026 10:24 AM"（原文在 `.tad/evidence/live-regression/raw/p2-codex-session.log`）。凭据不入仓。 |
| ③ 扩展来源 | `.codex/hooks.json` 由 tad.sh heredoc 生成（PLATFORM=codex），三点位：SessionStart→startup-health、PostToolUse `^apply_patch$`→post-write-sync、PostToolUse `^ask_user_question$`→askuser-capture；共享脚本为行为正本，本实例不改其面（Epic 排除项）。 |
| ④ 工作区权限 | 沙箱固定口径：全 role workspace-write（2026-09-16 用户拍板）；仓内 config.toml 仍为 draft 未激活——无仓内可落的权限声明，定案见件 3.5 核查表第 2 行。 |
| ⑤ 状态与失败信号 | 退出码＋会话头（session id/model/sandbox）＋stderr 厂商消息；失败形态已实测：限额（exit 1＋限额原文）、沙箱 bubblewrap 缺失警告（有捆绑回退，不阻塞）。无 started/done 文件面，等价信号＝进程退出＋会话日志落盘。 |
| ⑥ 证据出口 | traces：共享 hooks 写 `.tad/evidence/traces/<日期>.jsonl`（handoff_created/task_completed/evidence_created 等）；transcript：`.tad/evidence/live-regression/codex-20261006.md`（本周期基线，FAIL—配额归属，见该件第 5 字段）。 |
