---
name: feedback_yolo-epic-workflow-args
description: "Workflow args: 2026-10-09 实测 scriptPath/内联都能收到 args 对象(claude 2.1.295); 旧结论(收不到)已过时; 按保存名调用仍未验证"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 09bcd693-8bd4-45cc-8aec-5f8028653105
---

2026-06-13: 跑 YOLO Epic 时, `Workflow({name:'yolo-epic', args:{...}})` **两次都立即 0-agent 失败** `{"error":"missing required args"}` (29ms/7ms), 无论 args 传字符串还是对象. named-workflow 的 args 没被 plumb 进脚本的 `args` 全局.

**Why**: yolo-epic 脚本读 `if(args){Object.keys(args)...}`, 但 named 调用下 args 为空.

2026-07-05 复证+扩大: surplus-scan 同样中招, 且 **scriptPath 调用 args 也传不进去** (named 和 scriptPath 两种方式都失败, 0-agent 立即 throw). 新 workaround (比 Conductor-manual 轻): **直接 Edit 持久化的 script 文件, 把必需 arg 硬编码为默认值** (如 `if (!dateStamp) dateStamp = '2026-07-05'`), 再用 scriptPath 无 args 重跑 — 一次成功 (64 candidates, 4 agents). 适用于只缺少量标量 arg 的场景; 复杂 args (大数组) 仍走 Conductor-manual.

**2026-10-09 更正(覆盖上面两段的结论)**: 在 claude 2.1.295 上用零代理探针实测, `Workflow({scriptPath, args:{...}})` 与内联 `script` 调用都把 `args` 作为**对象**注入; 嵌套 `workflow({scriptPath}, args)` 也可用. 10 个 `.tad/workflows/claude/*.workflow.js` 里 8 个已带 args 真跑成功. 仍未验证/不可用: 顶层按保存名调用; 嵌套按保存名调用报 "no workflow with that name". 硬编码 arg 的 workaround 不再需要. 注意 `pack-upgrade`/`pack-dogfood` 不传 `packs` 会落到示例默认包上真跑, 必须显式传.

**How to apply**: (仅当 Workflow 工具不可用时) YOLO Epic 执行别死磕 yolo-epic Workflow. 2 次失败就走 yolo_execution_protocol 的 **Conductor-manual fallback**: 自己派 1 个实现 sub-agent (general-purpose, run_in_background) 按 handoff 干活 → SendMessage 续修 → 派 ≥2 独立 reviewer 审实现 → Conductor 亲手跑 AC 判 Gate 3. 效果一致且可控. 实测一次跑通 Phase 2.

**另一条铁律复证**: 11/11 §9.1 AC 全绿, 但 2 个独立 reviewer 实跑代码仍抓出 1 P0(浏览器划线无视觉反馈)+ 关键 P1(stale 门在 --save happy path 被默认值绕过). grep/count 类 AC 照不到 UX 行为缺陷和 happy-path 契约绕过 → 「不信 sub-agent 自报, Conductor 必亲验」是对的. 相关 [[project_ai-native-reading-companion]] [[project_yolo-audit-findings]].
