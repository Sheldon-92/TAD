# Gate 3 SAFETY 评审 — Epic Phase 2「持续测量层」实施（TASK-20261006-EPIC-P2-MEASUREMENT）

- 评审路：SAFETY（独立会话，只审不改）；判据链：票 TICKET-20261006-epic-p2-measurement、Epic Phase 2 节、HANDOFF-2026-10-06-epic-p2-measurement（78,569 B／sha256 `e680d83a…`，本路复算全等）、PM 裁断三件（design-rulings／gate2-merged-ruling／first-run-ruling）、COMPLETION-2026-10-06-epic-p2-measurement（12,317 B／sha256 `93f02cc6…`，本路复算全等）。
- **结论：CONDITIONAL（P0＝0／P1＝1／P2＝2）**。唯一关闭条件为 P1 一项（件 2.8 扫描覆盖面补扫或 PM 裁断接受现状），余面全过。

## ① 红线 — 全过

- **git 写围栏**：本地 main＝`526f1df3` 与远端 main 逐值相等（本链零新提交、未推送）；maintainer-evidence 本地尖 `ea54399f` 恰在旧尖 `459ab78f` 之上前移一笔脚本自产提交、远端该分支仍为 `459ab78f`（未推送）——与 D-2 裁断的围栏形态（只写该分支 ref＋blob、不动工作树与其他 ref、不推送）逐项吻合。
- **清单只增不改**：execution-manifest.jsonl 13,130→13,285 行；前 13,130 行中 `appended_at_epic_p2` 标记 0 个、尾 155 行全带标记且经脚本回写为 synced；两件陈旧文件的旧行（L3261 stale-content/synced、L3486 no-carrier/synced）原样在盘，supersede 行以追加形态落尾；新行 sha 与新尖分支 blob sha 逐值相等（`0e512a68…`、`8f2b0e2f…` 本路 ls-tree 复核）；FORBIDDEN 的 branch-disposition.tsv mtime 停在 2026-10-04、本链未触。
- **版本零改动**：`.tad/version.txt`＝3.0.2、不在 git diff 内；AGENTS.md、`.gitignore` 同样零 diff（AC30 成立）。
- **下游零触碰**：抽查 tech-radar 仓在实施窗口（06:33–07:10Z）内无文件改动；写集总表与 porcelain 均无下游/gm 路径。

## ② 写集边界 — 过（附 P1）

tracked 面 diff 与 §7 写集逐项对应且全为纯增：publish-protocol +52（仅 step3f 新增＋step3d 断言句）、publish-ops +8（§2.4 指针／§2.6 镜像／§5 指针句）、release-verify.sh +20（单 hunk、仅 migration 子命令内在船断言、位于早退之前）、gate-execution.md +8（仅 Regression Replay 小节块）。CREATE 面逐件在盘（样本集、两脚本、hop yaml、三 designs、证据目录、首跑目录、COMPLETION）。diff 中的旧链 HANDOFF/COMPLETION 删除群与 docs/pm 五件改动，经核与 `.tad/archive/` 迁档副本及 PM 自维护面归因一致（AC29 附归因成立），非本链写。同病扫描判出额外 DISEASE 为无、未扩写集——就其已扫面成立；覆盖面问题见 P1。

## ③ 效度面 — 过

对照污染实证本路独立复核成立：案三 control.md 答出 input.md 中不存在的事实——配对交换端点 `POST /extension/authorize`、假令牌实测回 401 日志零行、配对链接 TTL 300 秒（input 仅有 device_ttl=90d 与症状/日志摘录）——非裸捕获无疑。三案 control_hits 4/5/3 机械判 INVALID 与冻结规则一致；PM first-run 裁断的适用恰当（效度问题归通道、不重判不改规则、有效基线跑顺延 Phase 3 前置）。被测侧结果（判别 5/5/4、must_not 全 0）如实与整轮 FAIL 并列记录，AC7/AC8 自报 FAIL 未掩盖、附注亦未夸大（明示「除对照项外满足其余条件」，无一处把轮次写成 PASS）。

## ④ 条文保真 — 全过

- step3f 与 §4.4 定稿逐项全合：runtime 集 {codex, opencode, cursor}、transcript 六字段、本周期口径（执行日期 ≥ 上一版发布日）、HARD/ADVISORY baseline-flip 分级、未登记即红句、Phase 3 兜底全 HARD 句、判读归属句、Phase 3 衔接句齐备，位置在 step3e 与 step4 之间。
- 件 2.5 约束句「Gate PASS 不得直接当奖励信号」整节与 §4.5 第 6 条定稿逐字全等（接口文档 L45），数值锚 10%/5%/20% 与 `hash(step_id) mod 5 == 0` 在盘。
- publish-ops §5 节首指针句与 §4.3 定稿逐字一致；§2.6 镜像明示 step3f 为正本；§2.4 在船断言指针在盘。
- POINTER 首行逐字 `# TAD 常驻指针`、全文 📐 计数 0、第 2 行起与改前快照（`2.8-pointer-before.md`）diff 为空，本路实跑确认。
- hop 补船件与 2.43.1 前例同构（schema_version/from/to/generated_by/note/delete/rename），note 含追溯补船 provenance 句；step3d 在船断言句与「MISSING/MALFORMED → 全 release 类型 HARD BLOCK」分支句在盘（publish-protocol L208–209）。

## ⑤ 评估件纪律 — 过

件 2.6 五节齐、判定规则逐字复述且 (i) 判正／(iv) 有可控处置逐项标注，结论「采」只取回退还原验证一环且明示「不建试验脚本、不动发版清单」——本链无 B2 实现落盘，试点仅以指针形态指向 Phase 3 首链，属评估记录本分。件 2.7 四部齐、FC-1–FC-4 值域与趋势行字段序写死；激活阈值 ≥6／≥4 与 §4.7 定稿逐字一致；决议「顺延」所据实数（复跑 1、案级 FAIL 3）与首跑 scores.md 一致；`.tad/evidence/regression-runs/TREND.md` 实测不存在（禁建守）。

## ⑥ 证据纪律 — 过（证据否决未触发）

自报关键值逐项复算全等：HANDOFF 锚、COMPLETION 字节/sha、清单行数与增补构成、新尖 sha、同步后看守行（2026-10-06T06:36:56Z NOCARRIER=9／STALE=0／VERDICT=OK）与链末行（07:04:43Z NOCARRIER=41／STALE=1）在 freshness 日志原文在盘、差归因（+32 本链自产、STALE=1 为日志自引用）与盘面构成相符；2.3 selftest 输出正路 ASSERT PASS 与破坏路断言 1/3 FAIL 并存在盘。过程自报（扫描首轮口径误自查重跑、detect 首轮两参数假绿重跑）均在记录内明示，属正面样本。

## 问题清单

- **P1（关闭条件）件 2.8 同病扫描覆盖面未按 §4.8 定稿全量执行**：定稿扫描集 S 为六树全文件（`.tad/templates/`、`.tad/tasks/`、`.tad/gates/`、`.tad/project-knowledge/`、`.tad/scripts/`、`.tad/hooks/`、`.agents/skills/`）加顶层件；扫描记录实执 S 为其中子集（G2 原始输出仅及 templates、skills/alex、skills/blake、tad.sh、AGENTS.md 等），G2 判读只覆盖 126 行——本路自跑 G2 于未扫面得约 967 行同形态标题行未判读（tasks/gates/project-knowledge/scripts/hooks 约 280 行、skills 其余部分约 687 行）。缓解事实（本路自跑）：G1（本病原串）与 G3（种子项目名组）于**完整定稿 S 集**均 0 命中，具体席名原串与种子项目名在全集绝迹；残余风险仅限非种子名单的具体名出现在标题自指位。关闭方式二选一：(a) 收口前补扫未覆盖面的 G2 并逐行判读、补记扫描记录；或 (b) PM 裁断接受现状（G1/G3 全集零命中＋G2 已判读 126 行全 LEGIT）并留痕。COMPLETION AC24「三组按 §4.8 逐字口径」的表述就覆盖面而言不准确，随关闭方式一并更正口径。
- **P2-1**：件 2.0 的 AC3 字面与 Gate 2 落定的 supersede 追加形态在重复 path 上有读法分歧（注记一）。本路复核事实面无误（旧行未动、新行与分支 blob 逐值相等、两替代读法 mismatch 均 0），接受注记；建议后续 AC 文案对重复 path 按「每 path 最新行」写死。非关闭条件。
- **P2-2**：记录措辞两处弱项——扫描记录把实执子集标注为「扫描集 S（§4.8 定稿）」、scores.md 耗时字段为「未单独计量」。均不影响判读，随 P1 关闭时顺手订正即可。非关闭条件。

- 自报行：正文 7627 B／sha256 `2f6dbc5a3b286211c16c7db6220beb8a770dcfc4b2d0b54beb1cd7c545b4d869`（Gate 3 SAFETY 评审者，落盘后以 head -c 复算自验）
