# Lite 约束定价台账

> 由 Epic `EPIC-20260804-lite-as-tad-body` P1a 建立。
> 新增约束的定价规则见 alex-lite / blake-lite 的「约束准入」节。
> append-only：不删除历史行。状态列可就地转移为终态；处置理由另追加一行并带上原期限。
> P1b-2 已完成 7 条 DEEP 约束的载体判定（见 P1b-deep-verdicts.md）；整批回填已取消，
> 台账随 P2/P3/P5 自然生长——砍除时写该行，新增约束时由闸强制写一行。

| 日期 | skill | 节 | 约束摘要 | 每单成本 | 挡什么失败模式 | 载体路径 | 状态 |
|---|---|---|---|---|---|---|---|
| 2026-08-05 | alex-lite | ### Reviewer 档位规则 | 生产关键单 reviewer 须强档；alias-mapped 时三选一 | 每单 1 次档位判定 + alias 环境下 1 轮人机往返 | flash 审 flash 系统性盲区：只读审查 GATE PASS 而执行探针盲审 FAIL P0×1+P1×6 `flash 审 flash` | .tad/evidence/research/2026-08-02-model-diversity-audit-results.md | SUPERSEDED |
| 2026-08-05 | blake-lite | ### Reviewer 档位规则 | 生产关键单 reviewer 须强档；alias-mapped 时三选一 | 每单 1 次档位判定 + alias 环境下 1 轮人机往返 | flash 审 flash 系统性盲区：只读审查 GATE PASS 而执行探针盲审 FAIL P0×1+P1×6 `flash 审 flash` | .tad/evidence/research/2026-08-02-model-diversity-audit-results.md | SUPERSEDED |
| 2026-08-05 | 两侧 | 处置说明 | 上两行已由 HANDOFF-20260805-cut-routing-machinery 整节删除 | — | 用户 2026-08-04 裁定「兼容各种模型和 harness，不用非要调用强档」；载体真实存在，删是知情取舍不是无依据 | .tad/archive/handoffs/HANDOFF-20260805-cut-routing-machinery.md | SUPERSEDED |
| 2026-08-06 | alex-lite | ## Forbidden | 「修改 LITE 契约之外的任何文件」绝对禁止 → 三项例外（台账/project-knowledge/epics）；与「Knowledge Closeout」自相矛盾已修 | 每单 0 次额外读/写（净放宽） | P5-C2 现场：Alex 无法更新 Epic 被迫启 full（固定读取量 3.56×）；例外仅覆盖协议自身要求 Alex 写入的三条路径，SAFETY 面仍须停问人 `Knowledge Closeout` `修改 LITE 契约之外的任何文件` | .tad/active/handoffs/HANDOFF-20260806-lite-takes-over-full.md | SUPERSEDED |
| 2026-08-06 | 两侧 | ## Forbidden | 工具编排文档按需读取但 ≤2 个且须点名具体路径（不得写目录名），明确排除 references/ | 契约/Completion 多 1 行 | 一次读整个 `.tad/guides/`（12 文件 / 71,624 chars）等于把开销搬回来 `按需读取工具编排文档` | .tad/active/handoffs/HANDOFF-20260806-lite-full-parity.md | HAS-CARRIER |
| 2026-08-06 | alex-lite | ## Forbidden | 「除设计期契约 reviewer 外不得 spawn 任何 subagent」+「写 session-state.md」+ references 例外收窄 → 由 P5b 整节替换退场（用户 2026-08-06 裁定不限制 subagent 使用，spawn 限制历来只存在于 alex 侧） | 每单 0 次额外读/写（净放宽） | 用户裁定把 full 独占能力交给 lite；能力 3 边界：审查环节 1 个 reviewer 两个 skill 已写明 `除设计期契约 reviewer 外不得 spawn 任何 subagent` | .tad/active/handoffs/HANDOFF-20260806-lite-full-parity.md | SUPERSEDED |
| 2026-08-06 | blake-lite | ## Forbidden | 「git commit 或 push（人验收后由人决定）」+ references 例外收窄 → 由 P5b 整节替换退场（人明确授权后 commit 可行；push 仍须先停下问人） | 每单 0 次额外读/写（净放宽） | 用户裁定把 full 独占能力交给 lite；push 不可逆且直达下游，独立于安全停清单仍须停问人 `git commit 或 push（人验收后由人决定）` | .tad/active/handoffs/HANDOFF-20260806-lite-full-parity.md | SUPERSEDED |
| 2026-08-10 | 两侧 + release-runbook | 处置说明 | 逐命令、逐 retry/rollback、普通 push 与 archive confirmation 的 blanket stop-and-ask 由 Authority Model v2 accepted mandate + transaction CAS 取代 | 每单净减少 N 个技术审批往返；保留 1 次 contract/mandate 决策与 1 次最终业务验收 | 旧模型把人不具备判断力的 CLI 选择包装成授权，形成 rubber-stamping 且无法表达 transaction replay `current human approval` | .tad/decisions/DR-20260809-lite-authority-model-v2.md | SUPERSEDED |
| 2026-08-10 | 两侧 + release-runbook | Execution Mandate admission/classifier | mutation 前验证唯一 accepted mandate、exact target/consequence binding、闭集 boundary reason 与 handoff-owned CAS | 每单新增 1 个结构化 field group + 每次 mutation 只读 re-check/CAS；运行时技术审批往返为 0 | 阻止无 carrier 权限扩张、target 逃逸、stale/concurrent replay 与把技术 block 降级成人工背书 `accepted Execution Mandate` | .tad/evidence/designs/full-capability-extraction/authority-model-v2-contract.md | HAS-CARRIER |
| 2026-08-10 | blake（Layer 1 自检） | 2_layer1_loop | §9.1 未声明任何可运行技术命令时，Layer 1 判定通过**并必须留下可见记录**（不得静默跳过） | 每单 1 次记录写入；换掉的是非 JS 项目上 15 轮不可能成功的重试 | 四条硬编码 JS 命令在 Python/Go/文档项目上结构性不可能成功 → Layer 1 空转满 15 轮再熔断；若把零命令实现成静默跳过，则质量链直接失去 Layer 1 这一层 `零命令` | .claude/skills/blake/SKILL.md:903-918（缺陷代码本体，grep 可验）+ NEXT.md:15 ②a 记录 + LITE-20260810-1820-layer1-ac-driven-compat.md | HAS-CARRIER |
