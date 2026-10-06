# Gate 3 CODE 路独立评审 — Epic Phase 3「运行时适配补全」（TASK-20261006-EPIC-P3-RUNTIME）

- **评审者**：Blake 评审身份，独立会话（未参与本链设计与实施）；与 SAFETY 路互不可见、未沟通。
- **判据正本**：HANDOFF `.tad/active/handoffs/HANDOFF-2026-10-06-epic-p3-runtime.md` §9.1（AC1–AC33）＋ Gate Canonical Checklist Gate 3 节。
- **对象**：COMPLETION `.tad/evidence/completions/COMPLETION-2026-10-06-epic-p3-runtime.md`（复算 18,128 B／sha256 `7df2cc45fc958944…`，与任务书锚全等）＋ PM 裁断两份（design-rulings、three-escalations-ruling）。
- **方法**：不采信自报——逐行自跑复现（哈希全表重算、runner 于 /tmp 副本复评、垫片在 /tmp 整树副本上三态＋故障注入复跑、check4 正负控 fixture 复跑、git diff 逐件审、grokbox 只读探针核日志 sha 与试点清单）。
- **总判：CONDITIONAL**（P0＝0／P1＝2／P2＝4；两处 P1 均为记录准确性问题、无实施返工；条件见文末）。

## 逐条 AC 结论（编号＝HANDOFF §9.1）

| AC | 结论 | 独立实测值（非自报） |
|---|---|---|
| AC1 | PASS | 插件在盘（5,708 B／sha16 `7c165c015c4b602c`，与 COMPLETION §4 自报全等）；文件头含名册＋实测日期 2026-10-06＋版本 1.18.33；通读全文无 TAD 业务逻辑（仅 envelope 合成、调共享脚本、output 追加、extractContext 转码）。 |
| AC2 | PASS | 插件 `WRITE_TOOLS=["write","edit"]` 与 OC-1 实测名册逐名相等；`QUESTION_TOOLS=[]`、question 分支不注册；R-OC-2 在 OpenCode 实例 ⑥ 与清单残项总册双登记。 |
| AC3 | PASS（附注记①） | post-write 触发有盘上实证：骨架 session-state `Last File Written`＝Cursor 探针 handoff、`Hook Last Touched 2026-10-06T12:08:39Z`；Phase 2 两家 trace 行（evidence_created 12:12:04Z／12:12:51Z）在仓 raw 件；session.created 接线以仪表化 envelope 捕获为证（probed 强度，记录已披露）。注记见「设计字面判读」其一。 |
| AC4 | PASS（probed） | 插件 compacting 支代码审通过（调 startup-health `source:"compact"`、extractContext 后 push out.context、全吞错）；处理器级 fixture 在 Phase 1 记录 §5；无头面无法强触发真 compaction，强度披露属实。 |
| AC5 | PASS | 两投影族函数在 tad.sh 在盘（preflight/project/rollback ×2，行 2473–2555）；骨架实装日志（仓 raw 件与 grokbox 原件 sha 同为 `ccda15b5…fc`）含两行 Projected＋`Self-check passed: 91 derived paths`；漂移红控日志 sha `211d1d2a…db` 与记录全等；rollback 路径另经承接 B 试点实操（见 AC20）。 |
| AC6 | PASS | tad.sh 自检段含两 cmp 块（行 1535 起）；旧句 `do NOT add lifecycle hooks` 全文 grep 0 命中，L519 邻域注记已改写为 v3.2 落地形态；自检 exit 0 见实装日志。 |
| AC7 | PASS | 负控日志 grokbox sha `a48b84a7…b` 与记录全等；日志尾实见写文件成功＋DONE（会话未阻塞）。 |
| AC8 | PASS（附注记②） | hooks.json：jq 验 `version=1`、三事件键齐（sessionStart/postToolUse/preCompact）、timeout 30/10/10、`"failClosed"` 全文 0 命中、matcher 字面 `Write`。注记见「设计字面判读」其二。 |
| AC9 | PASS（自跑复现） | /tmp 整树副本实跑两垫片：sessionStart 载荷→`{"additional_context":"TAD v3.1.0 | …"}` exit 0；postWrite handoff 路径→提醒全文转码＋副本 traces 落真实 `handoff_created` 行 exit 0；空输入→`{}` exit 0。 |
| AC10 | PASS | OC-2 日志 grokbox sha `7f28f2ee…3ac` 与记录全等；分支 A 结论与日志对位；R-CU-2 在清单残项总册与 Cursor 实例均记「未成立＋成立条件」，与分支 A 一致。 |
| AC11 | PASS（probed） | preCompact 条目直调共享脚本在 hooks.json 在盘；OC-7 以 Cursor 形 envelope 直调 exit 0、快照落盘形态正确（Phase 0 记录）；CLI 内 live-fired 未观测已如实标注。 |
| AC12 | PASS | 同 AC5 口径对 `.cursor/hooks.json`：投影日志、漂移红控、试点 rollback 实操三面互证。 |
| AC13 | PASS（自跑复现） | /tmp 副本内容级故障注入：共享脚本输出垃圾→垫片 `{}`＋exit 0；共享脚本 exit 1→垫片 `{}`＋exit 0（两垫片同断言）。 |
| AC14 | PASS | 三份 transcript 在盘、6 字段逐项齐（字段核对表在盘）；版本＝OC-6 复测值；执行日期 2026-10-06 ≥ v3.1.0 发布日（发版提交 `9acf585d` 日期复算 2026-10-06）。 |
| AC15 | PASS | 两份 PASS transcript 逐点位记触发归属（FIRED／残项编号／probed 强度）；raw 指针逐个 `test -f` 在盘；OpenCode 会话 raw 日志全文复核与 transcript 宣称逐项对位（激活行、alpha→beta、writenote、review、closeout、FINISHED）；Codex 未触发点位如实记零触发＋配额归属。 |
| AC16 | PASS | 三份 transcript 均记骨架仓路径 `/home/box/p3-skeleton-tad` 并引 §4.0 断言；ASM-3 真机写面清单与 grokbox 探针所见目录集（p3-skeleton-*/p3-src-*/p3-probe-logs）一致；下游真实仓零写无反证。 |
| AC17 | PASS | scores.md 附注记明：对照＝中性空目录裸跑（捕获原文可见 `/tmp/p3-ctl-<案>` 仅含 input.md）、被测＝骨架仓正常激活；未用 fork/续接声明在盘；第一试弱激活捕获留存 `outputs-attempt1-framing-weak/` 未删（诚实留痕）；通道/模型/耗时三字段在盘。 |
| AC18 | PASS（自跑复现） | /tmp 副本同 runner 复评：`check` PASS；判别命中 5/7/6、must_not 全 0、对照命中 0/1/0、逐案 PASS、整轮 verdict PASS、exit 0——与 scores.md 机械值逐值一致。runner 本体 git diff 0 行（冻结判分零改）。 |
| AC19 | PASS | 经 PM 裁断（three-escalations §一）授权后回填：裁断件现 9 行，销账行为尾行（第 9 行），含运行目录指针＋整轮 PASS＋命中数 5/7/6、must_not 0、对照 0/1/0；替换三件 control.md 正文经逐字比对＝运行目录洁净对照的字节级后缀（仅裁断要求的文件头在前），新 sha/字节（2,304／1,448／1,896 B；`ec5d4bdf…`／`227e1182…`／`f49c13c6…`）与追记全等；首跑存档目录未动。因 evidence 面被 .gitignore 排除，「仅一行」以行数结构＋内容连贯性核定（非 git diff），此点如实声明。 |
| AC20 | PASS | 试点记录在盘：16 路径比对面、规程四步逐字、日志指针 sha 经 grokbox 复算全等（pilot.log `17ab52ef…71a4`）；before 清单 6 件 MODIFY 哈希与 Phase 0 基线锚逐值全等、10 件 CREATE 全 ABSENT；after 清单与 before **逐行全等**（两文件 sha 同为 `1888e01d…72fd`，diff 0 行，本席 grokbox 亲跑）；试点执行 12:28Z、记录 mtime 12:29:56Z，早于 Gate 3 评审件（SAFETY 件 12:42:12Z）。 |
| AC21 | PASS（中间态） | (i)(iii)(iv) 终判在盘且与 §4.5 写死判据对位；(ii) 为待回填态（双口径分子在盘、分母未发生），与 AC21 两段判读及 PM 裁断 §三（PM 于 Gate 3 后回填）一致；Gate 4 前须终值在盘。 |
| AC22 | PASS | 结论行「试点成立（(ii) 待确认）：维持『采』…」与四维判读逻辑对位，行内含 (ii) 翻负自动改判规则；COMPLETION §1 含结论行指针与原文摘录。 |
| AC23 | PASS | 清单六维齐，每维含声明项＋合格判据＋证据出口＋机制映射；义务句 grep 命中（「实例未立不许接线」）；`_index.md` diff 恰 +1 行登记。 |
| AC24 | PASS | 三实例逐维（①–⑥）全有值；版本＝OC-6 复测值（1.18.33／2026.10.01-e373342／0.159.3）；残项格带编号（R-OC-1／R-OC-2／R-CU-1／R-CU-2 未成立），无空格。 |
| AC25 | PASS | AGENTS.md diff 仅 Known Gaps 两行：P2 关闭形态＋残项逐项点名（R-OC-1／R-OC-2／R-CU-1＋实例指针）、P4 基线落地＋Codex 挂账点名；无整段删除；版本标记行不在 diff 内（diff 全文已审）。 |
| AC26 | PASS | 核查表五行逐行齐（载体／可声明?／字段集／定案／证据指针）；行 1 指针（判断正本 L41）本席亲核原文在位；行 3 指针 OC-5 实测在 Phase 0 记录。 |
| AC27 | PASS | 两样例在盘、jq 结构验过；cursor 字段集 ⊆ 文档确证集（permissions/approvalMode/sandbox）；opencode 样例存否与 OC-5「有面」结论对位；`grep runtime-permission-examples tad.sh` 0 命中（inert 成立）。 |
| AC28 | PASS（附 P2-3） | state-surface-check.sh git diff 仅 +5 注释行、OLD_PAT 逻辑行零改；publish-ops §3.1 注记行在盘且含更新规则＋正负控句。 |
| AC29 | PASS（自跑复现） | /tmp fixture 复跑：裸 `Version 3.1` 样本→check4 FAIL（1 line）；全号 `Version 3.1.0` 样本→check4 PASS。与 P2 裁定口径一致。 |
| AC30 | PASS | publish-protocol git diff：step4「Push only」选项行删除、`grep -c 'Push only'`＝0；Push + Tag／Abort 两选项与来历注记（v3.0.1/v3.0.2 漏 tag＋PREV 推导）在盘。 |
| AC31 | PASS | step5 新增 tag 断言段：本地在位／远端在位／指向发版提交三要素＋RED 处置（不得写完工、当场补打、发版记录留行）在盘；publish-ops §6 尾部镜像指针段在盘。 |
| AC32 | PASS | 写集封口：git status 全量分类——已跟踪变更中属本链者恰 §7 七件 MODIFY＋三件 control.md（PM 裁断授权）＋销账行一件；EPIC／docs/pm 五件／12 件 handoff 删除与旧票卡均在 Phase 0 基线快照内（非本链写入）；新增未跟踪件 ⊆ §7 CREATE∪链务件，条件件 cursor-precompact.sh 未建（与 OC-7 分支一致）。新/改 .sh `bash -n` 全过（tad.sh／两垫片／state-surface）；新 JSON `jq` 全过；state-surface 全套本席复跑 PASS（check7 WARN 为 brain-index 年龄 advisory，非本链）；scan-packs 本席复跑 exit 0 且 registry 字节零变化（git status 无 M）；tad.sh 自检 exit 0 以实装日志为据。release-verify structural 未自跑（须写目标，超出只读界），以试点记录分诊 3＋实装自检行互证采信。 |
| AC33 | PASS | `.tad/version.txt` 全 sha `b2f44d3b6e29f8b1b73ea4735f006affc4d198e1fd9c7d50e736159b1ef636c6` 与 Phase 0 基线锚逐字全等；git HEAD 仍为 `7e407b7c`（实施期零提交）；COMPLETION 无 bump 记录且明记零升版口径。 |

## 设计字面与实测出入判读（任务书点名两处）

**其一 — AC3 的 trace 产生者归属：可接受形态差（设计字面错、实施对），非实施缺陷。**
AC3 字面把「traces 当日行新增」挂在 startup-health 名下。源码级复核：`startup-health.sh` 全文 trace/record_trace 命中 0——它只产 stdout 健康 JSON，**从不写 trace**；trace 由 post-write-sync 经 `record_trace` 产生（源码行 296/307/318/353/357 在案）。实施方未改共享脚本（写集纪律），在 Phase 1 验证件 §8 注记①点名此出入，并以仪表化 envelope 捕获证 session.created 接线、以骨架 trace 证 post-write 触发——判读应以实测形态为准。AC3 的实质要求（两点位触发有盘上实证）成立。建议 Gate 4/收口时在 HANDOFF 勘误注记中订正该括注，避免下游按字面误读。

**其二 — AC8「四条目」实落三条目：可接受形态差（设计内部文义不一致），非实施缺陷。**
§9.1 AC8 写「四条目」，但 §4.2 形态表第四行明写提问捕获「不设条目」（R-CU-1，文档确证 Cursor 无提问工具事件）；AC8 括注本身也只列三事件＋垫片路径。实落三条目与 §4.2（更具体的形态正本）、残项总册、Cursor 实例三面一致。若按 AC8 字面强凑第四条，只会造出无事件可挂的空条目。故判形态差成立、实施无缺陷。

## Findings

**P0**：无。

**P1-1 — COMPLETION §3 编号与 HANDOFF §9.1 不对位（可追溯性缺陷）。**
COMPLETION §3 自称「§9.1 逐条」，但其 AC1–AC18、AC25–AC27 与 §9.1 同号行不是同一判据：如其 AC1 实为 Phase 0 记录行（§9.1 无此行）、其 AC16 实为 verdict 归属行（§9.1 AC16 为隔离面断言）、其 AC25/26/27 依次为 §9.1 AC26/27 与一段形态实测（§9.1 无此行）；§9.1 的 AC6、AC10、AC16、AC17 在其表中无同号对应（实质散见于其 §1/§2/§5 与 scores.md 附注）。本席逐行重映射后，33 行实质全部可核且全部通过，故不构成任何 AC 的 FAIL；但完工件与判据原件编号脱钩，迫使评审方重建映射，属证据形态缺陷，须在收口前以勘误/映射注记订正。

**P1-2 — trace 记述两处不准确（证据准确性）。**
(a) COMPLETION §3 其 AC5 称「两家 post-write 均落 handoff_created trace（12:12/12:13Z）」——盘上该时段的触发日志行（仓 raw `trigger-traces-20261006.jsonl`）类型为 `evidence_created`（Phase 2 写 `.tad/evidence/p2-writenote.md` 所致），非 handoff_created；两份 transcript 第 5 字段的记述（evidence_created）才是对的。(b) Phase 1 验证件 §4 称骨架 traces「新增 handoff_created 行／增至 2 行」——该载体现已不存在：骨架 `traces/2026-10-06.jsonl` 现仅含上述 2 行 evidence_created，Phase 1 的 handoff_created 行无存活载体可复核（骨架在相位间多次重建，行已佚）。底层性质（两家 post-write 真触发）有独立强证据（骨架 session-state 元数据、Phase 2 trace 行、本席垫片复跑实产 handoff_created 行），故不推翻 AC3/AC15；但两处书面记述按盘面复算不成立，须订正并在后续链中把触发 trace 随手抄入仓内证据（Phase 2 已如此做，Phase 1 未做）。

**P2-1** — Phase 1 验证件记插件 5,715 B，终态实值 5,708 B（COMPLETION §4 与盘面一致）；7 B 差无任何记录说明（疑为验证后微调），证据一致性小疵。

**P2-2** — 三处触发为 probed 强度（AC3 启动点、AC4 compacting、AC11 preCompact live-fired 未观测）：均已在记录与 transcript 中如实披露，且无头面无法强触发 compaction 属真实边界；仅注记，不构成条件。

**P2-3** — 承接 C 锚 1 注释实落 5 行，§4.8 字面为三行；内容覆盖三要点（维护点／更新规则／转义不可见＋publish-ops 指针），形态差，不构成条件。

**P2-4** — Phase 0/1 与试点的原始日志仅存 grokbox `/home/box/p3-probe-logs/`，以 sha 在记录中引用——本席逐个复算所引 sha 全部与 grokbox 文件全等（oc1-tools `af8e9f20…`、oc2-hooks `7f28f2ee…`、phase1-install `ccda15b5…`、p1-opencode `8a78c815…`、p1-drift `211d1d2a…`、pilot 三件 `17ab52ef…`／`a0b59ee7…`／`1888e01d…`）；但仓外单点存储的耐久性弱于 Phase 2 的入仓 raw 集，建议收口补抄入仓。

（附带观察，非本链缺陷：PM three-escalations 裁断 §一所引存档路径作「eval-runs/2026-10-06-first-run/」，实际路径为 `.tad/evidence/regression-runs/20261006-first-run/`；实施方文件头用的是真路径，无误。）

## 总判与条件

**CONDITIONAL。** 实施实质经独立复核全项成立：33 行 AC 无一行 FAIL；承重断言（runner 复评、control 替换逐字性、试点清单逐行全等、垫片三态与故障注入、check4 正负控、写集封口、版本锚）均经本席自跑复现与自报逐值一致；COMPLETION §4 字节/sha 全表与盘面逐值全等。两处设计字面出入均判可接受形态差。

转为无条件 PASS 的条件（均为记录级、无实施返工，Gate 4 前完成即可）：
1. COMPLETION 追记或勘误注记：订正 P1-2(a) 的 trace 类型记述，并给 §3 编号 ↔ §9.1 编号的映射注记（P1-1）；P1-2(b) 在 Phase 1 验证件尾以追记声明该 trace 载体已佚、结论改以存活证据（session-state 元数据＋Phase 2 trace 行）为据。
2. 既有挂账维持 PM 裁断口径，不属本门条件：Codex step3f PASS 基线待 2026-10-10 配额恢复后补跑回填；承接 B (ii) 维由 PM 于 Gate 3 工时发生后回填终值并复核试点结论行。

- 本评审文件字节/sha：以落盘后外部复算为准，数值随交付回执给出（自报口径：本席落盘后实测）。
