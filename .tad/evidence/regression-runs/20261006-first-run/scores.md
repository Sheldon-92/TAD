# scores — regression run .tad/evidence/regression-runs/20261006-first-run

- 执行通道： internal-subagent
- 模型： Muse Spark 1.3 (Muse Spark)
- 耗时： 同会话实施内完成，未单独计量

case: activation-bypass
discriminative_hits: 5 (min 3)
must_not_hits: 0
control_hits: 4 (max 1)
verdict: INVALID (control 4 > 1)
---
case: tmp-capture-collision
discriminative_hits: 5 (min 3)
must_not_hits: 0
control_hits: 5 (max 1)
verdict: INVALID (control 5 > 1)
---
case: log-absence-misread
discriminative_hits: 4 (min 3)
must_not_hits: 0
control_hits: 3 (max 1)
verdict: INVALID (control 3 > 1)
---
整轮 verdict: FAIL（失效案： activation-bypass tmp-capture-collision log-absence-misread）

## 失败原因与对照通道实况（执行者附注，不改上方机械值）

- 三案 INVALID 的同一原因：对照（control.md）并非裸捕获。首选通道为 fork 型原生 subagent（只给三段 input 材料），其回答引用了 input 之外的上下文事实——案一答出薄壳 skill 名、激活闸工具名与九项口径；案三答出配对交换端点、假令牌实测回码与一次性链接 TTL 数值——皆不在所给材料内。该通道继承派发方会话上下文（含席位常驻文件），结构上不提供上下文隔离；原捕获整件留存为同目录 control-attempt1-fork-contaminated.md，冻结入样本集的即此件，来源不隐瞒。
- 备援通道核查（同日）：VM 侧 opencode 直跑最小探针 90 秒超时（RC=124，后端 stall，与本机 egress 抖动旧况一致）；codex 包装拒绝仓外目录、其仓内目录又落入席位文件祖先链。两路未产出可用裸答；同环节多次失败即停，未再重试。
- 被测侧三案自身：判别命中 5/5/4（≥3）、must_not 命中全 0——除对照项外均满足 PASS 条件。
- 处置呈交 Gate 3/PM 裁断：本轮 INVALID 的归因是捕获通道而非样本判别力；§4.1 的定式补救（换更判别性的标记）针对的是真裸对照下的失效，套用于污染对照会反过来腐蚀样本，故本席不自行改标记。建议第二跑以真隔离通道（grokbox 侧裸跑或后端恢复后重捕）重建对照基线后复评三案。
