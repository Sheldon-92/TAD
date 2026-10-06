# COMPLETION — TASK-20261006-EPIC-P3-RUNTIME（Epic Phase 3 运行时适配补全）

- **Task ID**: TASK-20261006-EPIC-P3-RUNTIME
- **Handoff**: [HANDOFF-2026-10-06-epic-p3-runtime.md](../active/handoffs/HANDOFF-2026-10-06-epic-p3-runtime.md)（sha256 `2c77e39f…35b64`，开工复算全等）
- **Executor**: Blake（Execution Master）— 续跑席（前任在 Phase 0 因 grokbox 隧道中断停步、零实施写入；本席自 Phase 0 重采基线起全程执行）
- **Date**: 2026-10-06
- **gate3_verdict**: （留空，待 Gate 3 独立双审回填）
- **Human visual check**: CHECK 待人（注册表三家 hooks 面与实测 transcript 已备人眼抽查；本席不自报视觉 PASS）
- **版本口径**：本链零升版动作；`.tad/version.txt` sha 与 Phase 0 基线全等（`b2f44d3b…`，AC33）；发版与下游刷新按 2026-10-06 用户新规冻结至 Epic 全完后统一发版。

## 0. 范围声明与前置事实（如实记）

- **风险卡补落一事**：开工核对时风险卡 `.tad/evidence/risk-cards/risk-TASK-20261006-EPIC-P3-RUNTIME.md` 不在盘（前任同症），系 PM 按 Alex 草案补落后本席续跑；三条 ASM 全程自监（见 §6）。
- **Gate 2**：fit/tech 双审文件在盘且双 PASS（fit P2=4、tech P2=5，无 P0/P1），PM 裁断 D-1–D-5 在盘，D-5 五分支预授权全程有效——本链全部 OC 分支均落在预授权内，未触发停步报 PM 的设计问题。

## 1. 逐件结果（§4 件 3.1–3.5＋承接 A–D）

| 件 | 结果 | 证据指针 |
|---|---|---|
| 3.1 适配层本体 | OpenCode 插件＋Cursor hooks.json＋两垫片落盘；tad.sh 两投影族（preflight/投影/写后校验/回滚＋created 旗）＋verify 两 cmp 块接入；12/12 投影 fixture、垫片四态 fixture、骨架实装＋自检 91 路径、双向触发 trace、ASM-1 故障负控、漂移红控全过 | designs/2026-10-06-p3-phase1-adapter-verification.md |
| 3.2 Codex 侧零代码 | 零新增零改动（版本复测入 OC-6；能力面回填入 3.4 实例） | Phase 0 记录 OC-6/OC-7 关联项 |
| 3.3 三家真机基线 | OpenCode **PASS**、Cursor **PASS**、Codex **FAIL（厂商配额，见 §5-①）**；字段表落盘；raw/ 六件回收 | live-regression/{opencode,cursor,codex}-20261006.md、20261006-field-checklist.md、raw/ |
| 3.4 适配清单＋三实例 | 清单（六维＋义务句＋残项总册）＋三实例（逐维有值）＋_index 登记＋AGENTS.md 两行回写（diff 已验仅该两行） | patterns/runtime-adapter-checklist.md、runtime-adapter-instance-{codex,opencode,cursor}.md |
| 3.5 F1 声明面 | 核查表五行全落（逐行带证据指针，含两条判断正本行号）＋Cursor/OpenCode 两样例（inert、字段集与令牌形态经官方文档互证） | designs/2026-10-06-f1-permission-declaration-surfaces.md、templates/runtime-permission-examples/ |
| 承接 A | 洁净基线全流程跑完：判别力成立（对照 0/1/0）；被测侧三案达 PASS 线（5/7/6、must_not 全 0）；**机械整轮未 PASS、销账行未回填**——卡点在样本集冻结 control 面，须 PM 裁断（§5-②） | regression-runs/20261006-first-valid-baseline/（scores.md＋执行者附注） |
| 承接 B | 试点完成：16 路径比对面 apply（安装器＋逐件置入腿）→复合 rollback→还原清单与 before 逐行全等；四维 (i)(iii)(iv) 不翻负、(ii) 待回填态；结论行「试点成立（(ii) 待确认）：维持『采』，转常设与否报 PM 裁」 | designs/2026-10-06-b2-rollback-trial-pilot-result.md |
| 承接 C | C-a 五种形态实测 ✔；C-b 三锚两件真源落盘（注释 5 行＋check4 段）＋check4 /tmp fixture 正负控复跑 PASS/FAIL 符合 P2 裁定口径 | state-surface-check.sh、publish-ops.md §3.1、Phase 3 实施记录（本文件 §3 AC27–29） |
| 承接 D | D-a step4 删「Push only」＋来历注记；D-b step5 tag 在位断言（本地/远端/指向＋RED 处置）；§6 镜像指针段；与承接 C 的 §3.1 改动分开 diff 可判 | publish-protocol.md step4/step5、publish-ops.md §6 |

## 2. OC 逐项回填（Phase 0，判读正本 designs/2026-10-06-p3-phase0-probes.md）

| OC | 结论 | 分支影响 |
|---|---|---|
| OC-1 | 写类名册＝{write, edit}；无头面无 question 工具→**R-OC-2 成立** | 插件四处理器形态定版 |
| OC-2 | **分支 A 成立**：CLI 触发项目 hooks.json、直编 payload 与共享链 envelope 直接相容（垫片 stdin 直通、无需 jq 归一）；信任批准为部署前置（记入 Cursor 实例） | 条件件零新建 |
| OC-3 | sessionStart canary 被复述，注入对等成立 | — |
| OC-4 | output 追加被复述→§4.1 注入支**启用** | 插件 compacting/写后注入支激活 |
| OC-5 | permission 面存在（官方页＋行为实测）→opencode 样例**建** | 件 3.5 第五行「建」 |
| OC-6 | OpenCode 1.18.33／Cursor Agent 2026.10.01-e373342／Codex 0.159.3／Node v20.19.2 | 与设计步全等，无版本漂移分支 |
| OC-7 | Cursor 形 envelope 直调 precompact exit 0→直调成立 | 条件件 cursor-precompact.sh **不建** |

## 3. AC1–AC33 逐条实测值（§9.1；self 口径，Gate 3 独立复核为准）

| AC | 实测值 | 判定 |
|---|---|---|
| AC1 | OC-1–OC-7 逐项方法/命令/指针/结论/分支影响全落 Phase 0 记录（11,764 B） | PASS (self) |
| AC2 | 名册 {write, edit} 与 R-OC-2 结论均注记于插件文件头（含版本 1.18.33、日期 2026-10-06） | PASS (self) |
| AC3 | startup-health 以同一 envelope 仪表化实跑捕获成功＋exit 0（见 Phase 1 验证件 §8 注记①：trace 产生者为 post-write-sync，非 startup-health） | PASS (self，附注记) |
| AC4 | OC-4 分支启用；canary `CANARY_OC4_7f3a` 被模型复述（骨架 OC-4 记录在案） | PASS (self) |
| AC5 | 两家 post-write 均落 handoff_created trace（12:12/12:13Z）＋session-state.md 更新 | PASS (self) |
| AC6 | OC-7 直调 exit 0 成立、条件件不建；preCompact 实测事件触发 post_compact trace（12:13:52Z，transcript 在案） | PASS (self) |
| AC7 | 两共享脚本 chmod -x 后 OpenCode -p / Cursor -p 两家均正常完成（exit 0、回复产出） | PASS (self) |
| AC8 | 落盘三条目覆盖 §4.2 形态表四行职责（含 sessionStart 的 post-compact 指引职责）；提问事件条目按 R-CU-1 缺席（设计内形态，Phase 1 验证件 §8 注记②） | PASS (self，附注记) |
| AC9 | failClosed 全仓 grep 0 命中（新建面）；新文件无非空 additional_context 硬失败路径 | PASS (self) |
| AC10 | 投影 fixture 12/12＋漂移红控（exit 1＋文件未动）；投影走 copy_framework_files 共享链路 | PASS (self) |
| AC11 | 两投影 rollback fixture PASS（装后回滚→文件不存在）；状态三值以 cmp/存在性断言实测 | PASS (self) |
| AC12 | jq 校验 exit 0×2；timeout 30/10/10 逐值对 §4.2；matcher 字面 `Write` | PASS (self) |
| AC13 | 两垫片 fixture：additionalContext 逐字转码为 additional_context；垃圾/空/失败三态恒 `{}`＋exit 0；`bash -n` 双过 | PASS (self) |
| AC14 | 分工注记在两垫片文件头逐字在位（垫片＝转码层／共享脚本＝业务单一实现） | PASS (self) |
| AC15 | 三份 transcript＋字段表落盘；步骤字段（session_id 掩码/版本/触发/trace/退出码/产物清单）逐份在位 | PASS (self) |
| AC16 | verdict：OpenCode PASS／Cursor PASS／Codex FAIL——FAIL 归属厂商配额而非机制（§5-①），本条以「三份基线成件＋归属在案」计 | 部分成立（如实记，见 §5-①） |
| AC17 | 字段表 12 字段逐格有值或缺失标注（三家×四组的缺失格均标注＋原因，见字段表注记） | PASS (self) |
| AC18 | raw/ 回收六件（任务书逐字文本＋三家会话日志＋安装日志＋触发 trace）在盘 | PASS (self) |
| AC19 | **整轮未 PASS、销账行未回填**（机械判 INVALID，卡点在样本集冻结 control 面）；实质测量成立（对照 0/1/0、被测 5/7/6、must_not 全 0） | 未成立（升级 PM 裁断，见 §5-②） |
| AC20 | 试点记录在盘：16 路径比对面＋四腿规程逐字（before/apply/rollback/比对）＋墙钟双口径（稳态 8s／首次约 25min） | PASS (self) |
| AC21 | 四维回填：(i)(iii)(iv) 终判＋(ii) 待回填态（Gate 3 分母未发生，允许的中间态） | PASS (self，(ii) 中间态) |
| AC22 | 结论行与四维判读一致：「试点成立（(ii) 待确认）…」＋(ii) 翻负自动改判规则在行内 | PASS (self) |
| AC23 | 清单落盘；「实例未立，不许接线」义务句 grep 命中；残项总册四项状态与实例/Phase 0 互指 | PASS (self) |
| AC24 | 三实例逐维有值（各自六维节齐）；版本号＝OC-6 复测值 | PASS (self) |
| AC25 | 核查表五行逐行有证据指针（仓内路径＋行号／官方 URL＋抓取日期） | PASS (self) |
| AC26 | 两样例在盘、jq exit 0、tad.sh 引用 grep 0；字段集经官方文档互证（核查表行 3 注明形态与出处） | PASS (self) |
| AC27 | 形态实测：3.1.0 全号版面在仓 4 件、裸号版面在仓 search-*.json 1 件；其余三形态仓内无实例，各注「无 X」 | PASS (self) |
| AC28 | OLD_PAT 上方注释 5 行落 state-surface-check.sh（diff 仅注释行）；publish-ops §3.1 check4 段在位 | PASS (self) |
| AC29 | /tmp fixture 正负控：全号面 check4 PASS、裸号面 check4 FAIL，与 P2 裁定口径一致 | PASS (self) |
| AC30 | publish-protocol step4 选项行 grep「Push only」0 命中＋来历注记在位 | PASS (self) |
| AC31 | step5 tag 在位断言段在位（本地/远端/指向三要素＋RED 处置＋补打留行形态） | PASS (self) |
| AC32 | git status 变更集 ⊆ §7 写集∪链务自产件（本席写入面逐项对位，见 §4）；新/改 .sh `bash -n` 全过；新 JSON jq 全过；tad.sh 自检段随三次实装 exit 0；state-surface 全套复跑 PASS；release-verify structural：源树↔新装目标唯一差异＝目标自产 genesis.yaml（设计内，非漂移）；scan-packs exit 0 且 registry 内容零变化 | PASS (self) |
| AC33 | version.txt sha `b2f44d3b…` 与 Phase 0 基线全等；本链零 bump、零升版表述 | PASS (self) |

## 4. 自报字节/sha（交付件，sha 取前 16 位）

| 文件 | 字节 | sha256(16) |
|---|---|---|
| tad.sh | 136,578 | 947a8614f838ac80 |
| .opencode/plugins/tad-hooks.ts | 5,708 | 7c165c015c4b602c |
| .cursor/hooks.json | 353 | c76af436374740c1 |
| .tad/hooks/lib/cursor-session-start.sh | 1,600 | dd7bd2993052bbcf |
| .tad/hooks/lib/cursor-post-write.sh | 1,511 | 77fb61866392bf27 |
| patterns/runtime-adapter-checklist.md | 5,071 | 6d4cdbca4d0198dd |
| patterns/runtime-adapter-instance-codex.md | 1,876 | 3f533a69b0d2f552 |
| patterns/runtime-adapter-instance-opencode.md | 2,622 | 727d547e8b7aec3b |
| patterns/runtime-adapter-instance-cursor.md | 2,549 | 3f22741321069620 |
| templates/runtime-permission-examples/cursor-cli.json | 281 | 833f43ebce72d066 |
| templates/runtime-permission-examples/opencode-permission.json | 233 | de56c5cd34fb5886 |
| AGENTS.md（仅 Known Gaps 两行） | 14,013 | 4264d739e3f0f1e1 |
| .tad/hooks/lib/state-surface-check.sh（仅注释） | 12,231 | f89c266fb15f8606 |
| .agents/skills/alex/references/publish-protocol.md | 17,667 | 81248b0a8d5645cf |
| .agents/skills/release-runbook/references/publish-ops.md | 11,098 | 0c2692517ce4c98d |
| patterns/_index.md（一行登记） | 2,601 | 391bf98fa8cca107 |
| evidence/designs/2026-10-06-p3-phase0-probes.md | 11,764 | e67cf03e0ac9813f |
| evidence/designs/2026-10-06-p3-phase1-adapter-verification.md | 6,900 | baef6ee38c00d75e |
| evidence/designs/2026-10-06-f1-permission-declaration-surfaces.md | 4,443 | 460e6af2e03fa6fb |
| evidence/designs/2026-10-06-b2-rollback-trial-pilot-result.md | 6,550 | e114a669e907e866 |
| live-regression/{opencode,cursor,codex}-20261006.md | 1,983／1,990／1,366 | 2049f016／1ec03b04／ddd373bd |
| live-regression/20261006-field-checklist.md | 1,515 | a2f99d68dbed38b2 |
| regression-runs/20261006-first-valid-baseline/scores.md | 3,091 | bf19f3f57aa0f374 |

（本 COMPLETION 自身字节/sha 见同目录实施完工说明。）

## 5. 未竟与升级（如实记，不粉饰）

- **① Codex step3f PASS 基线未取得**：grokbox 侧 Codex 账号达用量上限（厂商原文 "try again at Oct 10th, 2026 10:24 AM"，在 raw 日志内），本轮零触发痕；非机制失败、非新残项；**待 2026-10-10 配额恢复后由 PM 派补跑**，补跑 PASS 后回填 codex transcript 与字段表。
- **② 承接 A 销账卡在样本集冻结面**：runner 自样本集冻结 `cases/*/control.md`（其文件头自注来源＝首跑 fork 污染捕获，按样本格式定义本不合规）复算判 INVALID；该面属 §7 FORBIDDEN，本席无权替换。**所需 PM 裁断：授权以本轮洁净对照（regression-runs/…/controls/，命中 0/1/0）替换样本集三件 control.md**；裁准后同 runner 复评即可整轮机械 PASS，再回填销账行（三步指针在 scores.md 附注）。首跑裁断件本轮未动（sha 与基线全等）。
- **③ 承接 B (ii) 维**：终值待 Gate 3 双审工时发生后回填（本链 Gate 4 前），回填后复核试点结论行。
- **④ session-state 索引未更新**：`.tad/active/session-state.md` 不在 §7 写集内，本席未动；本链索引行请 PM 收口时补记。
- **⑤ CF-7 infra 清单知会素材**：VM 面 Cursor/opencode CLI 版本与 grokbox 在册版本不同步之观察，由 PM 按 §10 清单转 infra 席（本席未动 infra 清单）。

## 6. ASM 自监（风险卡三条）

- **ASM-1**（弱对等面污染共享逻辑）：全程成立——零共享脚本行为改动（state-surface-check.sh 仅注释）；故障负控实证新面 fail-open 不拖垮宿主。
- **ASM-2**（Cursor 面烧穿）：未烧穿——信任前置经 OC-2 捕获为部署事实（非静默失效）；payload 形状以真捕获为准、垫片恒 exit 0；触发面全程 grokbox 骨架仓，真实下游仓零触碰。
- **ASM-3**（真机面纪律）：真机写入面如实列明：grokbox `/home/box/p3-skeleton-tad`、`/home/box/p3-skeleton-pilot{,-before}`、`/home/box/p3-struct-target`、`/home/box/p3-src-tad`、`/home/box/p3-src-final`、`/home/box/p3-probe-logs/` 与 grokbox /tmp 的 p3 前缀临时件；VM 面仅 TAD 仓 §7 写集＋/tmp/p3-* 临时件。仓外零生产写入。

## Knowledge Assessment

- **新发现 1**：`opencode run` 在 stdin 为不关闭管道时无限阻塞（空目录复现，`</dev/null` 即解）——无头调用规程级知识，已记 Phase 0 记录；建议 PM 考虑入 ops-knowledge（本席写集外，未自改）。
- **新发现 2**：原生 Muse spawn 面使「裸跑对照」在 VM 面不可得（注入层不可剥离）——对照实验须在无注入面（远端裸 CLI）执行，已记 scores.md 附注，是承接 A 方法论的实质增量。
- **新发现 3**：安装器对合并管理面与 project-knowledge 面不强制同步（resolve=local）——分发件的「装上」与「逐件置入」是两条腿，试点规程与 Phase 1 验证均已按此形态留痕。
- 其余结论（版本面、payload 形状）均已落入三实例与 Phase 0 记录，不另立 pattern。

## Friction Status

- 隧道中断致前任停步与本席重采基线（+1 行状态差异归因明确）；骨架基线含探针残留，试点首轮被自家 FATAL 拦截后校正——流程内摩擦，均已留痕销解，无未决摩擦。

## Evidence Checklist

- [x] Phase 0 记录件（OC 全清账＋基线锚）
- [x] Phase 1 验证件（12/12 fixture＋骨架实装＋触发实测＋负控/红控）
- [x] live-regression 三份 transcript＋字段表＋raw/ 六件
- [x] regression-runs 洁净基线运行目录（scores.md＋附注）
- [x] F1 核查表＋两样例
- [x] 试点记录（四维＋规程＋结论行）
- [x] 本 COMPLETION＋实施完工说明（同目录）

## Provenance

- 实施者：Blake（Muse 原生 subagent 通道，muse-spark-1.3）；设计与判据：HANDOFF-2026-10-06-epic-p3-runtime（Alex）＋PM 裁断 D-1–D-5；前任 Blake 于 Phase 0 中断（零实施写入），其本地基线暂存已失、由本席重采（Phase 0 记录 §0 注明）。git 动作：本席零 git 写（提交/发版归 PM 收口）。

## 追记（2026-10-06，Blake 续办席）— §5-② 承接 A 销账续办

依 PM 裁断 `.tad/evidence/pm/2026-10-06-epic-p3-three-escalations-ruling.md` 第一节执行本续办（裁断后同日）：

- **替换**：样本集三件 `cases/*/control.md` 以本轮洁净对照（`regression-runs/20261006-first-valid-baseline/controls/`，正文逐字移入＋文件头注明本轮 run id `20261006-first-valid-baseline`、裁断路径、被替代件出处）替换。sha256(16) 旧→新：activation-bypass `fb98173d54d7de1b`→`ec5d4bdfb3d01efa`（2,304 B）；tmp-capture-collision `288213ca3b91c320`→`227e11827eca1344`（1,448 B）；log-absence-misread `29b21f0862c68b65`→`f49c13c6db13b6a0`（1,896 B）。被替代的首跑 fork 污染捕获存档 `regression-runs/20261006-first-run/` 未动。
- **复评**：同 runner（`.tad/scripts/regression-replay.sh score`，同参数）全量重评，`check` 结构校验 PASS；三案判别命中 5/7/6、must_not 全 0、对照命中 0/1/0，逐案 PASS、**整轮 verdict PASS**（exit 0）。复评输出在 `regression-runs/20261006-first-valid-baseline/scores.md`（4,449 B／sha256(16) `fef5487b9b346f9b`；首轮执行者附注逐字保全＋续办附注在内）。
- **销账**：销账行已以新增一行回填首跑裁断件 `.tad/evidence/pm/2026-10-06-epic-p2-first-run-ruling.md` 尾部第 9 行（该文件仅此一行新增，新 sha256(16) `0ca68988d0488497`）。§3 AC19 与 §1 承接 A 行的「未成立／销账行未回填」自此销账：件 2.1 首个有效基线跑成立。
- 本追记不改上方正文与 §3/§5 的历史记述；头部 `gate3_verdict` 仍留空，待 Gate 3 独立双审回填。

## Gate 3 订正追记（2026-10-06，CODE CONDITIONAL 两 P1＋P2 相关）

依 Gate 3 CODE 路 verdict `.tad/evidence/reviews/epic-p3-runtime-20261006/gate3-code.md`（CONDITIONAL，P1＝2／P2 相关 1 项）的条件 1 执行本记录级订正：只在尾部追记，上方原文一字未改；无实施返工。

### 1. 编号映射注记（P1-1）

§3 自述编号与 HANDOFF §9.1 同号行不对位，对位关系如下（左＝本文件 §3 编号，右＝§9.1 对应判据行）：

| §3 编号 | §9.1 对应行 |
|---|---|
| AC1 | 无此行——Phase 0 探活清账行，是 §9.1 全部行的前置证据面，非判据行 |
| AC2 | AC1＋AC2（插件正本/文件头注记＋名册对位，合并自述） |
| AC3 | AC3 前段（startup-health 触发实测；trace 产生者注记同在此行） |
| AC4 | AC4 的前置（OC-4 注入支启用结论）；AC4 判据本体（compacting push 实测）记述在 §1 件 3.1 行与 Phase 1 验证件 §5 |
| AC5 | AC3 后段（post-write-sync 副作用）＋AC15（点位触发记述）交界行；其 trace 类型记述勘正见本追记第 2 项 |
| AC6 | AC11（preCompact 落位） |
| AC7 | AC7 的前置事实（共享脚本可执行位＋两家会话可用性）；AC7 判据本体（故障注入 fail-open 负控）记述在 §1 件 3.1 行与 Phase 1 验证件负控段 |
| AC8 | AC8（形态差注记在 Phase 1 验证件 §8 注记②） |
| AC9 | AC8 后段（failClosed 零命中）＋AC13（fail-open 口径） |
| AC10 | AC5＋AC12（两投影族 install/cmp 与漂移红控） |
| AC11 | AC5＋AC12（rollback 路） |
| AC12 | AC8（结构细值：timeout／matcher） |
| AC13 | AC9（转码三态）＋AC13（故障注入下同断言） |
| AC14 | 无此行——§4.2 垫片分工形态纪律，无对应 AC 判据行（属 AC9 的证据面） |
| AC15 | AC14（三份 transcript 在盘＋6 字段） |
| AC16 | AC14（结果＋定性字段）与 AC15 交界（verdict 归属行） |
| AC17 | AC14（核对表部分；12 字段为 step3f 6 字段的展开记述） |
| AC18 | AC15（raw/ 原始件指针在盘） |
| AC19 | AC17＋AC18＋AC19（承接 A 三行合并自述；AC19 销账已由前一追记完成） |
| AC20 | AC20 |
| AC21 | AC21 |
| AC22 | AC22 |
| AC23 | AC23 |
| AC24 | AC24 |
| AC25 | AC26（核查表定案） |
| AC26 | AC27（样例落位） |
| AC27 | 无此行——承接 C 锚 3 的前置形态实测，其判据行是 AC29 |
| AC28 | AC28 |
| AC29 | AC29 |
| AC30 | AC30 |
| AC31 | AC31 |
| AC32 | AC32（并含 AC6 的自检 exit 0 实测） |
| AC33 | AC33 |

反向注记——§9.1 中在 §3 无同号对应行者，其实质记述所在：AC6（tad.sh 自检 cmp 行＋L519 注记）→§3-AC32、§4 tad.sh 行与 Phase 1 验证件；AC10（OC-2 探活分支）→§2 OC-2 行；AC16（隔离面断言）→§6 ASM-3 与 §1 件 3.3 行；AC17（承接 A 捕获纪律）→scores.md 附注与 §1 承接 A 行；AC25（Known Gaps 处置）→§1 件 3.4 行与 §4 AGENTS.md 行。

### 2. trace 记述勘正（P1-2）

- **(a) §3-AC5 记述勘正**：§3-AC5 称「两家 post-write 均落 handoff_created trace（12:12/12:13Z）」系记述错误。盘面实况（本追记落笔时复核）：仓内 raw 件 `.tad/evidence/live-regression/raw/trigger-traces-20261006.jsonl` 该时段仅两行——`2026-10-06T12:12:04Z` 与 `2026-10-06T12:12:51Z`，类型同为 `evidence_created`（触发文件 `.tad/evidence/p2-writenote.md`，Phase 2 两家写证据笔记所致），非 handoff_created。正确出处以两份 transcript 第 5 字段（result/定性）的记述为准：`.tad/evidence/live-regression/opencode-20261006.md` 记 12:12:04Z `evidence_created`、`.tad/evidence/live-regression/cursor-20261006.md` 记 12:12:51Z `evidence_created`，与盘面逐值一致。
- **(b) Phase 1 验证件所称骨架 handoff_created 行已无存活载体**：Phase 1 验证件 `.tad/evidence/designs/2026-10-06-p3-phase1-adapter-verification.md` 记骨架 `.tad/evidence/traces/2026-10-06.jsonl`「新增 handoff_created 行」「增至 2 行」。该载体现况（本追记落笔时经 grokbox 只读复核 `/home/box/p3-skeleton-tad/.tad/evidence/traces/2026-10-06.jsonl`）：现仅含上述两行 `evidence_created`，与仓内 raw 抄件逐字相同；Phase 1 所述 handoff_created 行已无存活载体可复核（骨架在相位间多次重建，行已佚）。两家 post-write 真触发的结论改以存活证据为据：骨架 session-state 元数据（`Last File Written`／`Hook Last Touched`）、Phase 2 两行 trace、两垫片的实测转码与 Gate 3 CODE 路自跑复跑实产 handoff_created 行（见 CODE verdict AC3/AC9 行）。

### 3. 插件字节差异事实注记（P2-1 相关）

Phase 1 验证件记 `.opencode/plugins/tad-hooks.ts` 为 5,715 B；终态实值 5,708 B（COMPLETION §4 自报，本追记落笔时现盘复算 5,708 B／sha256(16) `7c165c015c4b602c`，全等）。7 B 差异在全部在盘记录中无任何说明，其产生时点与内容无从考证——**成因未考**，不在此推测。

### 4. gate3_verdict 回填（本追记末尾）

- **gate3_verdict**: CODE=CONDITIONAL（订正中）／SAFETY=PASS
- 本追记即 CODE 条件 1 的订正执行件；订正完成后由 PM 核销，CODE 转 PASS。头部原 `gate3_verdict` 留空行按「不许改原文」纪律未动，以本行回填为准。

---

## Gate 4 终判与收口追记（PM，2026-10-06）

- Gate 4 verdict：CONDITIONAL（`.tad/evidence/reviews/epic-p3-runtime-20261006/gate4-alex.md`，16,194 B／sha 87fb39ba…）。转 PASS 两条件：① Codex PASS 基线补跑（排 2026-10-10 配额恢复后，挂账维持）；② 承接 B (ii) 经 PM 裁口径终判——已由 `.tad/evidence/pm/2026-10-06-epic-p3-carryB-ruling.md` 销账（口径写死：分子＝稳态周期、分母＝派发至 verdict 落盘时点差；(ii) 不翻负、试点成立终定、转常设准并附下链复核义务）。条件 ① 落地后自动升 PASS，无须重审。
- Gate 3 终态：SAFETY PASS＋CODE CONDITIONAL 经订正追记 PM 核销 → Gate 3 PASS。
- delta 2 闭环：Gate 3 CODE 条件 1 落点偏差已在 Phase 1 验证件尾补指针行（见该文件尾）。
- session-state 索引行由 PM 收口补记（`.tad/active/session-state.md` 尾）。
- human CHECK 记「CHECK 待人」。
