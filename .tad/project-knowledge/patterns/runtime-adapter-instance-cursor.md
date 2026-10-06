# Runtime Adapter Instance — Cursor（运行时适配器实例声明）

按 `runtime-adapter-checklist.md` 六维填实。版本值＝2026-10-06 Phase 0 复测（OC-6）；能力结论均为实测（指针见 `.tad/evidence/designs/2026-10-06-p3-phase0-probes.md` OC-2/OC-3/OC-7）。

| 维 | 声明值 |
|---|---|
| ① 入口 | 二进制 `agent`（grokbox `~/.local/bin/agent`），版本 **2026.10.01-e373342**；无头面 `agent -p --trust "<任务>"`，stdin 关闭。前置条件（实测）：新工作区无头运行须 `--trust`（或 `-f`/`--yolo`），否则 exit 1 并提示信任确认。IDE/cloud agents 面共用同一 hooks.json 装载点位（文档确证）。 |
| ② 认证 | Cursor 账号登录态（grokbox 侧既有登录；hook payload 含账号邮箱字段——证据转录时须剔除，不入仓）；失效信号：未登录/未信任时 CLI 直接报错退出（exit 1 文本提示），无静默挂起形态。 |
| ③ 扩展来源 | 项目 `.cursor/hooks.json`（version:1）为装载点位，CLI 无头面**实测触发**（OC-2 分支 A）；TAD 接线由 tad.sh 单文件投影分发（preflight 分歧 FATAL／project cmp／rollback 对称）。点位映射：sessionStart→`cursor-session-start.sh` 垫片转码注入（OC-3 实测达模型）、postToolUse（matcher Write）→`cursor-post-write.sh` 垫片转码、preCompact→直调 precompact-session-snapshot（OC-7 实测 envelope 兼容）；全部条目不设 failClosed（缺省 false）。 |
| ④ 工作区权限 | 项目 `.cursor/cli.json` 为可编程声明面（文档确证）：`permissions.allow/deny`（精确字符串）、`approvalMode`、`sandbox.mode/networkAccess`；TAD 样例（inert，不随安装器分发）见 `.tad/templates/runtime-permission-examples/cursor-cli.json`，定案见件 3.5 核查表第 4 行（PM 裁断 D-4：样例 inert）。 |
| ⑤ 状态与失败信号 | 退出码（0 正常／1 前置失败如未信任）＋会话 stdout；hook 侧信号＝payload 字段集（conversation_id/session_id/hook_event_name/cursor_version/workspace_roots，OC-2 实测样本在 Phase 0 记录件）。失败形态已实测：未信任 exit 1（处置：`--trust`）。 |
| ⑥ 证据出口 | traces：垫片调共享脚本写 `.tad/evidence/traces/<日期>.jsonl`（同源同格式）；transcript：`.tad/evidence/live-regression/cursor-20261006.md`（PASS 基线）。残项：**R-CU-1**（无提问工具事件，捕获无落点）；**R-CU-2 未成立**（CLI 触发项目 hooks 已实测，分支 B 不发生）。 |
