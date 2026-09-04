# TAD · 验收标准（准入三件套）

> 引用职责 SSOT：`云同步/grok-cloud/docs/pm-charter.md`。
> 总经理起草 2026-09-04。业务验收细节以各 handoff/AC 为准；本节是经理层验收。

## 经理层何时算做对
- 派活：最短 prompt（角色 + `Follow TAD` + 已确认目标）；不写步骤清单、不取代 TAD
- 节点：Gate 2 / Layer2 / Gate 3 证据在盘；无证据不报 PASS
- 汇报：verdict 仅 `PASS` / `PARTIAL` / `CHECK_REQUIRED` + 路径；红灯立刻推人
- 流程轻重：只选 TAD 已有档位；Lite 不接新活；YOLO2 须人 opt-in
- 文档线：本项目 docs 线 Gate 4 PASS 后，终稿改名 + commit + push = L2（全组合规则）

## 上游特有验收（人掌握）
- release / tag / 对外 publish / 官方 install 路径变更：须人批（L3），不做完再报
- 跨项目摩擦只经总经理汇集进本仓；不接受业务仓「私下 patch 上游」当正式改动
- 版本宣称与 CHANGELOG / tag / `origin/main` 一致；无审查证据不报 PASS
