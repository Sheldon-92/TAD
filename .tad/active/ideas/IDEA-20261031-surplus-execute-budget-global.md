---
title: surplus-execute 对 Claude Code 运行时环境的硬假设——budget 全局硬依赖＋仓根相对写盘路径，非 Claude Code workflow 运行时下 Phase 2 不可用
date: 2026-10-31
status: captured
scope: small
---

## Summary & Problem

Surplus Burn Mode 的 Phase 2 执行脚本 `.tad/workflows/claude/surplus-execute.workflow.js` 在预算循环里硬依赖 `budget` 全局（`budget.total` / `budget.remaining()` / `budget.spent()`，脚本第 96、106、152 行一带）。该全局由 Claude Code 的 Workflow 运行时提供；其他 workflow 运行时（已实测：Muse harness 的 workflow 运行时，其全局只有 args/phase/agent/parallel/pipeline/log）不提供，脚本在 Execute 阶段第一步即抛错中止。

Phase 1 的扫描脚本（surplus-scan.workflow.js）不依赖 budget，在同一 harness 实跑成功——不可用面只在 Phase 2 执行。

**同类缺陷二（写盘路径，Menu 席 2026-10-31 探针发现）**：同一脚本把全部写盘路径写成仓根相对路径（`epicPath`/`handoffPath`/`completionPath` 在脚本第 109–111 行、`report_path` 在第 244 行，均为 `.tad/active/…` 相对式），并指示子代理按此 Write。在子代理文件工具以家目录（`~`）为基准解析相对路径的 harness 里，这些写入会落到仓外（家目录下的同名相对路径），仓内则什么都收不到。与缺陷一同属「脚本对 Claude Code 运行时环境的硬假设」一类：Claude Code 子代理以项目根为工作目录，相对路径恰好成立，换个运行时即失效。本席已对脚本源码核过行号，缺陷二与源码一致。

**同类缺陷三（嵌套 workflow() 全局，Menu 席探针原文揭示、本席已核源码）**：脚本第 142 行以 `workflow({ scriptPath: '.tad/workflows/claude/yolo-epic.workflow.js' }, …)` 嵌套调用 yolo-epic 执行链；`workflow` 全局在 Muse harness 的 workflow 运行时同样不存在（探针 typeof 为 undefined）。即便缺陷一、二修好，Step 3 的嵌套执行在本类运行时仍无从调用——三处同根：脚本把 Claude Code Workflow 运行时的专有面（budget 记账、嵌套 workflow、项目根 cwd）当作了普适前提。

## Evidence（2026-10-31 实测）

- 运行：workflow-run-e50e2830263f4e349e120d70cfba7ab8（Muse harness，*surplus +2M，GM 派单预算 2M）。
- 结果：Validate 阶段通过（sidecar 46 行 fail-closed 校验全过），Execute 阶段 67ms 内失败，任何任务 agent 未启动，执行 0 件、花费 0、盘面零写入。
- 报错原文：`workflow JavaScript failed: budget is not defined`。
- 处置已定（GM 2026-10-31 裁定）：不跨 harness 重路由、不就地改脚本、不手工代跑；缺陷入本账，Phase 2 挂起——SURPLUS-PLAN-2026-10-31 的 16 条 auto-eligible 排名与 sidecar 保持有效，待本缺陷修复后由 GM 重派。
- 缺陷二、三证据：Menu 席本轮 *surplus 探针回报（2026-10-31），原文已于同日由该席直发本席、全文补附于文末附录。本席侧旁证：Phase 1 扫描在本 harness 亦须把 sources 传绝对路径锚定（子代理文件工具以 `~` 为基准），同一解析口径问题在读侧已实测存在；缺陷三已由本席核对脚本源码第 142 行属实。

## Fix direction（供立项时设计，非本票裁定）

- 消除硬依赖：budget 全局缺失时优雅降级——例如以 args 传入的预算数值为准、用 agent() 回报的用量做内部记账；或改为「已执行件数＋估算成本」的本地记账，保留 250K reserve 与三连败熔断的等价语义。
- 写盘路径锚定：脚本的一切读写路径以 args 显式传入的仓根绝对路径拼接（与 Phase 1 扫描的 sources 绝对锚定同一口径），不再假设子代理以仓根为工作目录；Report 的 report_path 与嵌套调用的 scriptPath 同理。
- 嵌套调用降级：`workflow()` 全局缺失时须有等价路径（如 conductor 侧顺序执行 yolo-epic、或脚本内联执行协议），且缺失时应在 Validate 阶段即 fail-closed 报明，不得跑到 Step 3 才炸。
- 不动的部分：sidecar fail-closed 校验、SAFETY 严格相等过滤（safety_flag === true 永不执行）、Phase 1 扫描面。
- 验收口径：在无 budget 全局的运行时（如 Muse harness）实跑一次 *surplus +小额预算，报告含执行/失败/花费且数值可对账。

## 附录：Menu 席探针原文（2026-10-31 直发本席存档）

探针为一支只读 workflow：仅做 typeof 检查、零 agent 调用、零写入、0 token；run id `workflow-run-d9c160a994304756aaa4edffc3761c8b`（Muse harness），检查七项全局 `budget / workflow / agent / parallel / pipeline / log / phase`。finalResult 逐字：

```json
{"typeof_agent":"function","typeof_budget":"undefined","typeof_log":"function","typeof_parallel":"function","typeof_phase":"function","typeof_pipeline":"function","typeof_workflow":"undefined"}
```

Menu 席结论（原文大意，逐项与其回报对齐）：本 harness workflow 运行时有 `agent／parallel／pipeline／log／phase`，没有 `budget` 全局、没有嵌套 `workflow()` 全局。execute 的预算循环首个 `budget.total` 引用即抛 ReferenceError（在任何 agent 调用之前）；其 Step 3 以 `workflow({ scriptPath: '.tad/workflows/claude/yolo-epic.workflow.js' }, …)` 嵌套调用 yolo-epic 亦无此全局可调——脚本在本 harness 结构性不可运行。Phase 1 的 scan 只用已文档化全局，故能跑（该席实跑成功，run `workflow-run-de9ef2e546bb470f8735ea5396379fd8`）。

写盘路径观察（该席原文要点）：execute 脚本内写盘与传参路径全为仓根相对字面（EPHEMERAL epic、HANDOFF、COMPLETION、嵌套 scriptPath）；本类 harness 的 workflow 子席文件工具相对路径以家目录 `~` 为基准解析（非项目根）——该席 Phase 1 实证：scan 的 sources/objectives 传仓根相对路径将扫错根，改传 `workspace/yun-sync/menu-tales/…` 前缀式才命中本仓（grok-cloud 席以绝对路径得解、musecloud 席同课）。故 execute 的相对写盘路径在本 harness 会落到仓外（`~/.tad/…`）或落空。
