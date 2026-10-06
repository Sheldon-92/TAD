# Runtime Adapter Instance — OpenCode（运行时适配器实例声明）

按 `runtime-adapter-checklist.md` 六维填实。版本值＝2026-10-06 Phase 0 复测（OC-6）；能力结论均为实测（指针见 `.tad/evidence/designs/2026-10-06-p3-phase0-probes.md`）。

| 维 | 声明值 |
|---|---|
| ① 入口 | 二进制 `opencode`（grokbox `~/.opencode/bin/opencode`），版本 **1.18.33**；无头面 `opencode run --model <id> "<任务>"`。**前置条件（实测）**：stdin 必须关闭（`</dev/null`）——stdin 为不关闭的管道时进程无限阻塞、零输出（Phase 0 首跑实证）；模型须显式给定或由配置解析。 |
| ② 认证 | OpenCode Go API 凭据（`opencode auth list` 可核，凭据在 `~/.local/share/opencode/auth.json`，值不入仓）；失效信号：API 调用失败/无响应（与后端 stall 的判别靠 `--print-logs` 看 init 后是否有请求日志）。 |
| ③ 扩展来源 | 项目 `.opencode/plugins/` 自动加载（JS/TS 插件）；TAD 适配件 `.opencode/plugins/tad-hooks.ts` 由 tad.sh 单文件投影分发（preflight 分歧 FATAL／project cmp／rollback 对称，自检段 cmp 红控）。点位映射：session.created→startup-health（副作用）、experimental.session.compacting→compact 提醒 push、tool.execute.after（write/edit 名册，OC-1 实测）→post-write-sync＋output 注入（OC-4 实测达模型）、session.compacted→precompact 快照。 |
| ④ 工作区权限 | config `permission` 面存在且可编程（OC-5：官方文档＋实测 deny 生效——`edit: deny` 后 write/edit 工具自会话名册消失）；字段集与样例见件 3.5 核查表第 3 行及 `.tad/templates/runtime-permission-examples/opencode-permission.json`。另有 `external_directory` 模式对象面（grokbox 全局配置在盘实存）。 |
| ⑤ 状态与失败信号 | 退出码＋会话 stdout；事件总线（session.created/idle 等）可由插件观测。失败形态已实测：stdin 未关→无限阻塞（处置：`</dev/null`）；后端 stall→init 后无请求日志（处置：`--print-logs` 判读、按后端健康口径处置）。 |
| ⑥ 证据出口 | traces：插件调共享脚本写 `.tad/evidence/traces/<日期>.jsonl`（与 Codex 面同源同格式）；transcript：`.tad/evidence/live-regression/opencode-20261006.md`（PASS 基线）。启动注入面缺失的证据形态：触发以插桩 fixture 的 envelope 捕获为凭（Phase 1 验证件 §5）。残项：**R-OC-1**（启动上下文注入无对等面）、**R-OC-2**（无头面无 question 工具，捕获分支不注册）。 |
