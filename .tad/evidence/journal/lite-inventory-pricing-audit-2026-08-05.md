# Journal: lite-inventory-pricing-audit (2026-08-05)

- **「围栏锚常量」与「活文档」的冲突形态（P1b-1 的 AC3(d) 案例）**：契约 AC3(d) 把 Epic 文件的 md5 钉成常量，但 Epic 是 Alex 侧的活文档（untracked、随 Gate 收尾持续更新）。handoff 定稿（16:21:25）后 27 秒 Epic 被更新（16:21:52，收尾段：成本结算/1b-1 Ready）→ 常量过期 → AC3 verbatim 跑 FAIL。处理：预实现判别力自检时发现 → 只读溯源（mtime 差 27 秒 + 内容连贯非破坏 + P1b 判定文件常量仍命中）→ AskUserQuestion 用户裁定「更新常量后继续」→ 验证脚本用新锚，偏离记入 Completion。教训：**锚定 untracked 活文档的 md5 常量，应预期其漂移；判别力自检（预实现 AC 跑一遍）是捕获「锚过期 vs 真破坏」的最佳时机**——比实现后才发现成本低一个量级。AC3(d) 的 (d1)/(d2) 双钉中 P1b 判定文件命中、Epic 漂移，也证明逐文件归因优于整体 FAIL。

- **验证脚本与契约常量的分离纪律（本单实践）**：预实现/实现后脚本里按用户裁定更新 AC3(d) 锚（1acdc51e…→67c977e5…），但 handoff 文件本身不动（§7 不自行改规格）。偏离通过 pre-impl-output.txt 头注 + Completion 携带。code-reviewer 独立重建 AC 常量（防回显验证：HEAD+契约文本 python3 重建 md5 命中常量）确认「常量=目标，非实现回显」——这条手法值得固化：AC 的 md5 常量必须能从契约文本独立重建，否则验证退化为自指。

- **旧正则负向控制（判别力增强形态）**：code-reviewer 用同一探针矩阵跑旧正则 → 0 MALFORMED（bug 前提复现）→ 证明探针有判别力。这补上了「新正则 90 MALFORMED/372 静默」单侧的不足——单侧数字只能证明行为，双侧对照才能证明探针本身不瞎。与 pricing-gate-scan-fix 的「AC4a 新旧命中集对比」同族：**凡修复类 AC，尽量跑旧实现作负向控制**。
