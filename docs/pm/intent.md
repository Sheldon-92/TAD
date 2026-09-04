## 目标：上游方法库（GitHub `Sheldon-92/TAD`）：维护/发布 TAD 框架本身（有益摩擦、三角模型、安装与升级），不是业务应用仓。
## 不要什么：
- release / tag / 对外 publish / 官方 install 路径变更须人批（L3），不做完再报（source: docs/pm/acceptance.md 上游特有验收）
- 不接受业务仓「私下 patch 上游」当正式改动（source: docs/pm/acceptance.md；docs/pm/auth.md 硬禁区）
- Lite 冻结、不接新活；YOLO2 须人 opt-in（source: docs/pm/status.md；acceptance 流程轻重）
## 什么算好：[验收口径](acceptance.md)
## 老板拍过的先例：
- 当前对外 Latest **v2.44.1**（PM Bridge 可选三行 + 门面清理：hybrid 命名、补丁诚实 README、补发 v2.44.0/v2.44.1 Release）
- 默认通道 full；Lite 冻结
- Gate1 门面一揽子（2026-09-04）：各建 Release、诚实标题、hybrid c、旧 Release 不动、仅 README+package+repo meta+Releases、Express
## 今日目标：TBD（门面清理 TASK-20260904-FACADE 已 Gate4 ACCEPTED；等你点名下一目标）
