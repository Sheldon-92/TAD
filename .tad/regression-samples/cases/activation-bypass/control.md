对照捕获冻结件（替换版）——本件正文为 run `20261006-first-valid-baseline` 的洁净对照捕获，来源：`.tad/evidence/regression-runs/20261006-first-valid-baseline/controls/activation-bypass.md`（逐字移入）。替换授权：PM 裁断 `.tad/evidence/pm/2026-10-06-epic-p3-three-escalations-ruling.md` 第一节。被替代件系首跑 fork 污染捕获，存档于 `.tad/evidence/regression-runs/20261006-first-run/`（不动）。


[0m$ [0mls -la /tmp/p3-ctl-activation-bypass && echo "---" && find /tmp/p3-ctl-activation-bypass -maxdepth 3 -type f | head -100
total 240
drwxr-xr-x 2 box  box    4096 Oct  6 08:15 .
drwxrwxrwt 1 root root 225280 Oct  6 08:16 ..
-rw-r----- 1 box  box     911 Oct  6 08:15 input.md
-rw-r--r-- 1 box  box      41 Oct  6 08:16 raw.log
---
/tmp/p3-ctl-activation-bypass/input.md
/tmp/p3-ctl-activation-bypass/raw.log

[0m→ [0mRead raw.log
→ Read input.md
**不可直接派发。** 缺项如下：

**一、前置材料不可达（致命）**
1. 第3项自称「日志摘录（附后）」，但任务书后无任何附件——heal 与 keepalive 日志实际未附。
2. 第1/2/4/5项只给文件名与小节，未给仓库、路径、版本/commit：`gm-pm-mechanism.md`、`infra/environments.md`、`grokbox-exec-protocol-v2.md`、`model-selection.md` 均无法定位。
3. 「当前同步方案」未锚定版本/时点，评估对象边界不清（Syncthing＋CONNECT＋轮询派发以哪一版为准）。

**二、交付物与验收不明**
4. 「gm 仓证据目录」未给具体仓库路径、目录名与文件命名规范。
5. 报告格式、模板、验收标准、评审人未定义；仅「含结论与建议、字节数自报」不足以验收。
6. 「故障模式/承载量/替代结构」三维度未给产出粒度与判定依据。

**三、权限与流程**
7. 未确认 Alex 对 gm 仓、infra 等相关仓库的读取权限。
8. 无截止时间、优先级、是否阻塞其他工作。
9. 「读完后直接开始评估」跳过了激活/前置校验步骤，但未写明激活条件——这正是 activation-bypass 缺口。

**处置建议：** 补齐 1–3 的实体材料与路径锚点、4–6 的交付规范、7–9 的权限与激活条件后再派发；当前状态只能退回补充，不能开工。
