TAD 常驻指针：先读本仓.tad/TAD-POINTER.md，再按其所指原件开工。

## 目标：上游方法库（GitHub `Sheldon-92/TAD`）：维护/发布 TAD 框架本身（有益摩擦、三角模型、安装与升级），不是业务应用仓。
## 不要什么：
- release / tag / 对外 publish / 官方 install 路径变更须人批（L3），不做完再报（source: docs/pm/acceptance.md 上游特有验收）
- 不接受业务仓「私下 patch 上游」当正式改动（source: docs/pm/acceptance.md；docs/pm/auth.md 硬禁区）
- Lite 冻结、不接新活；YOLO2 须人 opt-in（source: docs/pm/status.md；acceptance 流程轻重）
## 什么算好：[验收口径](acceptance.md)
## 老板拍过的先例：
- 当前对外 Latest **v2.44.5**（2026-09-11：Verification Method fail-close、pack loader 按需指针 + 14 pack 冻结、KEEP11 Knife1 CLI/SHA 刷新；v2.44.4 知识缝隔离；v2.44.1 PM Bridge 可选三行 + 门面清理）
- 默认通道 full；Lite 冻结
- Gate1 门面一揽子（2026-09-04）：各建 Release、诚实标题、hybrid c、旧 Release 不动、仅 README+package+repo meta+Releases、Express
- **历史模型先例（2026-09-13；不作当前默认）**：OpenCode 上 Alex/*discuss=deepseek-v4.1-flash、Blake=muse-spark-1.3-contributor；Cursor 讨论=grok-4.6-medium、Alex=grok-4.6-low、Blake=composer-2.5；Codex Alex=gpt-5.6-sol、Blake=gpt-5.6-luna；当时 Gemini 冻结至约 2026-10-04。此记录仅保留历史背景。
- **当前共享路由与职责 SSOT（只保留指针，不复制模型表）**：路由 `/home/box/云同步/grok-cloud/docs/model-routing.md`；经理职责 `/home/box/云同步/grok-cloud/docs/pm-charter.md`；PM 操作规则 `/home/box/云同步/grok-cloud/docs/pm/human-operating.md`。Codex 临时偏好锁 `/home/box/云同步/gm/ops/codex-prefer-temp-2026-10-01.md`，按其到期与复检条件执行，不将临时偏好固化为 TAD 默认。TAD 不维护第二份 `docs/model-routing.md`。
## 今日目标：TBD（门面清理 TASK-20260904-FACADE 已 Gate4 ACCEPTED；等你点名下一目标）
