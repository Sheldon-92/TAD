# scores — regression run .tad/evidence/regression-runs/20261006-first-valid-baseline

- 执行通道： grokbox-opencode-run（隔离面洁净进程，§4.4）
- 模型： opencode-go/deepseek-v4.1-flash
- 耗时： 三轮捕获合计约5分钟

case: activation-bypass
discriminative_hits: 5 (min 3)
must_not_hits: 0
control_hits: 0 (max 1)
verdict: PASS
---
case: tmp-capture-collision
discriminative_hits: 7 (min 3)
must_not_hits: 0
control_hits: 1 (max 1)
verdict: PASS
---
case: log-absence-misread
discriminative_hits: 6 (min 3)
must_not_hits: 0
control_hits: 0 (max 1)
verdict: PASS
---
整轮 verdict: PASS
## 执行者附注（不改上方机械值）— 捕获纪律、洁净对照实测与 INVALID 归因

- **捕获纪律（AC17）**：对照与被测均为洁净上下文新进程，未用 fork/续接。通道＝grokbox 隔离面 `opencode run`（OpenCode 1.18.33，模型 opencode-go/deepseek-v4.1-flash）：对照在中性空目录（仅含该案 input.md，无任何 TAD 文件）裸跑；被测在骨架仓 `/home/box/p3-skeleton-tad` 内以正常激活形态跑（先读 AGENTS.md 并按本仓知识索引查既有记录规程后再答）。捕获原文（去 ANSI）落本目录 `controls/`（对照）与 `outputs/`（被测）。
- **被测捕获两试留痕**：第一试的激活提示过弱（仅「可按需查阅本仓文件」），log-absence-misread 被测答对了结论但未用本仓纪律词汇（判别命中 0），其余两案 4/5；第一试三件留存于 `outputs-attempt1-framing-weak/`。第二试统一改用完整激活形态（读 AGENTS.md＋按知识索引查既有记录），三案被测判别命中 5/7/6、must_not 全 0——被测侧三案均达 PASS 线。
- **洁净对照实测（同 runner 判分法复算）**：本轮新捕对照的判别命中为 activation-bypass 0、tmp-capture-collision 1、log-absence-misread 0——全部 ≤ control_max_hits=1，样本判别力在洁净对照下成立。
- **机械 INVALID 的归因**：上方 control_hits 4/5/3 不是本轮对照的值，而是 runner 从样本集 `cases/*/control.md` 复算的值。该三件冻结 control 文件头自注其来源为首跑 fork 污染捕获（与 `20261006-first-run/control-attempt1-fork-contaminated.md` 同源），按样本格式定义（control 须为「裸 spawn 只给 input」的捕获）本不合规；但样本集属本链写集外禁改面（HANDOFF §7 FORBIDDEN：冻结判分面只用不改），本席无权径行替换。
- **处置**：按 HANDOFF §4.4 第 4 步，整轮机械 verdict 非 PASS（INVALID）⇒ **不回填**首跑裁断销账行。本轮材料（洁净对照三件＋被测三件＋本附注）即报 PM 另裁的呈报面：所需裁断＝授权以本轮洁净对照替换样本集三件 control.md（样本集修订），替换后以同一 runner 复评即可机械销账（被测与洁净对照数值均已在盘，预期整轮 PASS）。放宽通过线不在选项内。

## 续办附注（2026-10-06，Blake 续办席）— 冻结对照替换、复评与销账

- **替换执行**：依 PM 裁断 `.tad/evidence/pm/2026-10-06-epic-p3-three-escalations-ruling.md` 第一节，样本集三件 `cases/*/control.md` 已以本运行目录 `controls/` 的洁净对照替换（正文逐字移入＋裁断要求的文件头，注明本轮 run id、裁断路径与被替代件出处）：activation-bypass sha256 `fb98173d…`→`ec5d4bdf…`；tmp-capture-collision `288213ca…`→`227e1182…`；log-absence-misread `29b21f08…`→`f49c13c6…`。被替代的首跑 fork 污染捕获存档 `.tad/evidence/regression-runs/20261006-first-run/` 未动。
- **复评**：替换后以同一 runner（`bash .tad/scripts/regression-replay.sh score`，通道/模型/耗时参数与首轮一致）对本运行目录全量重评，上方机械值即复评结果——三案 PASS、整轮 verdict PASS（exit 0）；runner `check` 结构校验同轮 PASS。对照命中 0/1/0 与首轮执行者复算值一致。
- **附注保全说明**：上方「执行者附注」为首轮执行者原文，runner 复评重写本文件时由本席逐字回附；其所称「上方 control_hits 4/5/3」指替换前的原机械值，现已由复评值（0/1/0）取代，归因结论不变。
- **销账**：整轮机械 PASS 成立，销账行已以新增一行回填首跑裁断件 `.tad/evidence/pm/2026-10-06-epic-p2-first-run-ruling.md` 尾部（第 9 行，该文件其余行未动）。
