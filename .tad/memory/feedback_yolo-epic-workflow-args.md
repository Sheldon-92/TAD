---
name: feedback_yolo-epic-workflow-args
description: "yolo-epic named Workflow doesn't receive args in this harness — use Conductor-manual fallback"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 09bcd693-8bd4-45cc-8aec-5f8028653105
---

2026-06-13: 跑 YOLO Epic 时, `Workflow({name:'yolo-epic', args:{...}})` **两次都立即 0-agent 失败** `{"error":"missing required args"}` (29ms/7ms), 无论 args 传字符串还是对象. named-workflow 的 args 没被 plumb 进脚本的 `args` 全局.

**Why**: yolo-epic 脚本读 `if(args){Object.keys(args)...}`, 但 named 调用下 args 为空.

2026-07-05 复证+扩大: surplus-scan 同样中招, 且 **scriptPath 调用 args 也传不进去** (named 和 scriptPath 两种方式都失败, 0-agent 立即 throw). 新 workaround (比 Conductor-manual 轻): **直接 Edit 持久化的 script 文件, 把必需 arg 硬编码为默认值** (如 `if (!dateStamp) dateStamp = '2026-07-05'`), 再用 scriptPath 无 args 重跑 — 一次成功 (64 candidates, 4 agents). 适用于只缺少量标量 arg 的场景; 复杂 args (大数组) 仍走 Conductor-manual.

**How to apply**: YOLO Epic 执行别死磕 yolo-epic Workflow. 2 次失败就走 yolo_execution_protocol 的 **Conductor-manual fallback**: 自己派 1 个实现 sub-agent (general-purpose, run_in_background) 按 handoff 干活 → SendMessage 续修 → 派 ≥2 独立 reviewer 审实现 → Conductor 亲手跑 AC 判 Gate 3. 效果一致且可控. 实测一次跑通 Phase 2.

**另一条铁律复证**: 11/11 §9.1 AC 全绿, 但 2 个独立 reviewer 实跑代码仍抓出 1 P0(浏览器划线无视觉反馈)+ 关键 P1(stale 门在 --save happy path 被默认值绕过). grep/count 类 AC 照不到 UX 行为缺陷和 happy-path 契约绕过 → 「不信 sub-agent 自报, Conductor 必亲验」是对的. 相关 [[project_ai-native-reading-companion]] [[project_yolo-audit-findings]].
