# COMPLETION — Epic Phase 2「持续测量层」（TASK-20261006-EPIC-P2-MEASUREMENT）

- 执行者：Blake（Execution Master）；HANDOFF：`.tad/active/handoffs/HANDOFF-2026-10-06-epic-p2-measurement.md`（78,569 B／sha256 `e680d83a…`，开工复算与派发锚全等）。
- gate3_verdict：PASS（CODE＋SAFETY 双 CONDITIONAL 经全量补扫＋PM 定点核销账转 PASS，2026-10-06）；Gate 4：PASS
- human CHECK：CHECK 待人。
- **自报总判：PARTIAL**——10 件中 9 件全项落地；件 2.1 的首跑对照因捕获通道污染机械判 INVALID（AC7/AC8 附注记呈裁断，见下），其余 AC 全 PASS。

## 逐件结果

| 件 | 结果 | 要点与证据 |
|---|---|---|
| 2.0 证据载体补同步（前置） | ✅ | 增补 155 行（153 增量＋2 supersede），清单 13,130→13,285 行；同步 exit 0、RESULT=SYNCED、SYNCED=155、新尖 `ea54399f…`；同步后看守 NOCARRIER=9（设计预言残余形态）。记录 `.tad/evidence/epic-p2-measurement-20261006/2.0-carrier-resync.md` |
| 2.1 命名回归样本集 | ⚠️ 附注记 | 结构/runner/三案六要素/Gate 3 挂载全落地，`check` exit 0；首跑被测侧判别命中 5/5/4、must_not 全 0；对照为 fork 通道捕获（继承上下文、非裸），三案机械判 INVALID、整轮 FAIL。`.tad/regression-samples/`、`.tad/scripts/regression-replay.sh`、`.tad/evidence/regression-runs/20261006-first-run/scores.md`（含通道实况附注） |
| 2.2 状态图＋案 A 演练 | ✅ | 状态图 9 状态＋转换表＋INT-1–INT-4 分类表；演练 9 项判读（7 全恢复/1 时点性/2 软缺口已映射）。`state-graph-gate-chain.md`、`drill-p1-case-a-interrupt-recovery.md`（同证据目录） |
| 2.3 中断续跑脚本 | ✅ | `.tad/scripts/interrupt-resume-check.sh`：selftest 正路全 PASS、破坏路断言 1/3 双场景 FAIL、SELFTEST PASS exit 0；publish-ops §5 节首指针句逐字入盘 |
| 2.4 step3f 活体回归 | ✅ | publish-protocol step3e 与 step4 之间新增 step3f（本批唯一新增步，步数 11→12）；规格含三家 runtime 集、transcript 六字段、本周期口径、HARD/ADVISORY 分级、未登记即红、Phase 3 兜底全 HARD；publish-ops §2.6 镜像；AC19 fixture 两样本＋核对表在案 |
| 2.5 轨迹→评分接口 | ✅ | `.tad/evidence/designs/2026-10-06-trajectory-scoring-interface.md` 七节齐；第 6 节约束明文逐字入文；数值锚 10%/5%/20% 与 `hash(step_id) mod 5 == 0` 在盘 |
| 2.6 B2 评估 | ✅ 结论：采 | `.tad/evidence/designs/2026-10-06-b2-change-evidence-trial-evaluation.md` 五节齐；(i) 判正（中间态回退还原缺陷类）、(iv) 有可控处置；只采回退还原验证一环，试点指针＝Epic Phase 3 首链 Gate 3 前 |
| 2.7 C2 接口＋决议 | ✅ 决议：顺延 | `.tad/evidence/designs/2026-10-06-c2-failure-clustering-interface.md` 四部齐；FC-1–FC-4 按规格值域；实数：复跑 1（距阈 5）、案级 FAIL 3（距阈 1）；TREND.md 未建（禁建守） |
| 2.8 去席名化＋同病扫描 | ✅ | POINTER 首行＝`# TAD 常驻指针`、全文 📐 计数 0、第 2 行起与基线 diff 为空；同病扫描三组按 §4.8 逐字口径：G1 0 行、G3 0 行、G2 126 行逐行判读全 LEGIT，**额外 DISEASE 无、不触发停步**。`seat-name-scan.md`、`2.8-g2-verdicts.md` |
| 2.9 hop 补船＋在船断言 | ✅ | `.tad/migrations/3.0.1-to-3.0.2.yaml` 按 2.43.1 正本形补船（见附注记三）；release-verify migration 子命令在船断言（早退前）；fixture 三态全合；引擎回归 A/B/C 全合（新 hop 被实际消费、两负控 REJECT 不回归） |

## AC 逐条实测（AC1–AC30）

| AC | 判读 | 实测值/指针 |
|---|---|---|
| AC1 | PASS | 清单 13,285 = 13,130＋155；增补 path 集与 Phase 0 增量集逐件相等（集定义 `phase0-sets.json`、草案 `2.0-append-draft.jsonl`）；账本两件不在增补行；字段齐 |
| AC2 | PASS | 同步 exit 0、RESULT=SYNCED、SYNCED=155 = 增补 pending 行数（`2.0-sync-output.txt`） |
| AC3 | PASS（附注记一） | 「每 path 最新行对新尖」与「每行对其自记尖」两读法 mismatch 均 0；朴素读法（全部 synced 行对新尖）mismatch=2，恰为两件陈旧文件的被代旧行——摩擦源为 Gate 2 落定的 supersede 追加形态与 AC3 字面在重复 path 上的不兼容，事实全貌与两读法记录在 `2.0-carrier-resync.md`，呈 Gate 3 裁断 |
| AC4 | PASS | 同步后复跑看守新行 VERDICT=OK、TIP_AGE_DAYS=0（`2.0-freshness-after.txt`，判读时点＝本件完成时点） |
| AC5 | PASS | `regression-replay.sh check` exit 0（终验复跑同值，CHECK PASS） |
| AC6 | PASS | 三案评分块在盘：min_discriminative: 3、control_max_hits: 1、判别分支 5/7/6（≥4）；README 含样本格式/评分与通过线/复跑程序/增长规则四节 |
| AC7 | **FAIL（附注记二）** | runner 复算三案冻结 control 的判别 distinct 命中 = 4/5/3，均 > 1。归因：control 非裸捕获（fork 通道继承上下文），非样本判别力问题；见附注记二与 scores.md 附注 |
| AC8 | **FAIL（附注记二）** | scores.md 在盘且含通道/模型/耗时/失败原因列，runner 重跑与 scores 一致；但逐案 verdict 为 INVALID、整轮 FAIL——同 AC7 归因。被测侧三案自身（判别 5/5/4、must_not 0）满足 PASS 的其余全部条件 |
| AC9 | PASS | gate-execution Gate 3 节含 Regression Replay（测量层）块：触发五面（skills/tasks/gates/templates/模型路由）与判读句齐。句面以 §4.1「文案要点（实施时逐字以此为准）」的定稿为准（「整轮非 PASS 时 Gate 3 不得 PASS，除非 PM 裁断记录在案」），AC 表的行文为其转述 |
| AC10 | PASS | 负控：以案一 control 充当 test 输出跑 score → 案一判 FAIL（INVALID）、整轮非 PASS（`2.1-ac10-negative-control.txt`） |
| AC11 | PASS | 状态图 9 状态；进入/退出证据指针逐个 test -f 在盘（终验扫）；INT 表四行各有「对应 2.3 断言」列值 |
| AC12 | PASS | 演练记录五部齐（演练点定义/读取清单/逐项判读表/丢失清单/复盘/映射表）；丢失 3 项：L1/L2 已映射、L3 明示未映射＋理由 |
| AC13 | PASS | `bash -n` 过；selftest 正路 exit 0、两场景各 5 条 ASSERT 全 PASS（`2.3-selftest-output.txt`、终验 `phase4-selftest-rerun.txt`） |
| AC14 | PASS | 破坏路：断言 1 与断言 3 在 k=2/k=4 两场景各 FAIL、selftest 整体 exit 0（两路预期均满足） |
| AC15 | PASS | 脚本头注含 INT-1–INT-4 四类名，与状态图分类表逐名一致（同批成文） |
| AC16 | PASS | publish-ops §5 节首指针句 grep 命中（含脚本命令与状态图路径，与 §4.3 定稿逐字一致） |
| AC17 | PASS | step3f 行号序 step3e(L215) < step3f(L237) < step4；三家 runtime 集、transcript 六字段、本周期口径、HARD/ADVISORY 判法、未登记即红句、Phase 3 兜底全 HARD 句全在盘 |
| AC18 | PASS | publish-ops §2.6 在盘：含判读口径一句，明示 step3f 为正本 |
| AC19 | PASS | fixture 两样本＋核对表（`2.4-transcript-fixture-check.md`）：齐者判合规；缺者逐项点名缺 ②harness 名与版本、⑥原始输出指针 |
| AC20 | PASS | 接口文档七节齐；约束句「Gate PASS 不得直接当奖励信号」grep 命中；10%、5%、20% 三数值锚在盘 |
| AC21 | PASS | 评估五节齐，每节 ≥1 仓内证据路径；结论「采」∈{采，不采，缓}；结论节逐字复述判定规则并逐项标 (i)/(iv) 满足 |
| AC22 | PASS | 接口四部齐；分类表 4 类；阈值 ≥6、≥4 在盘；决议节复跑数 1 与首跑实数一致 |
| AC23 | PASS | POINTER 首行逐字 `# TAD 常驻指针`；全文 📐 计数 = 0；第 2 行起与 Phase 0 基线 diff 为空 |
| AC24 | PASS | 扫描记录含三组命令原文、原始输出文件、G2 逐行判读附表（126 行 DISEASE/LEGIT＋类目依据）；额外 DISEASE 处置状态明示：无、不触发停步。【追记（2026-10-06，Gate 3 关闭步）：上文 126 行系窄执行集口径——原扫描实执集只是 §4.8 规定集（754 文件）的子集，本行原表述就 G2 覆盖面不确，特此更正留痕。已按 PM 裁断（`.tad/evidence/pm/2026-10-06-epic-p2-gate3-ruling.md`，取 (b) 补跑）按规定集全量补扫：G2 全量 1,098 行，补扫集 972 行逐行判读全 LEGIT、无额外 DISEASE、不触发停步；补扫记录 `.tad/evidence/epic-p2-measurement-20261006/seat-name-scan-rescan.md`，逐行附表 `2.8-rescan-g2-verdicts.md`，原始输出 `2.8-rescan-g2.txt`。】 |
| AC25 | PASS（附注记三） | 补船文件字段集与前例同构（schema_version/from/to/generated_by/note/delete/rename），from/to 正确、delete/rename 空、note 含追溯 provenance 句 |
| AC26 | PASS | fixture 三态：无 hop→exit 1 含 `MISSING HOP:`；合规 hop→exit 0；to 改错→exit 1 含 `MALFORMED HOP:`（`2.9-fixture-three-states.txt`） |
| AC27 | PASS | 引擎回归：3.0.1 genesis 副本经新 hop 升级 exit 0、输出不含 `genesis-anchored`；版本不符 REJECT、中段缺 hop REJECT（`2.9-engine-regression.txt`） |
| AC28 | PASS | step3d 含在船断言句与全类型 HARD BLOCK 分支句；§2.4 含断言指针句；publish-protocol 步数 11→12（仅 +step3f） |
| AC29 | PASS（附归因） | porcelain 变更集 ⊆ §7 写集 ∪ 本链自产件（票/HANDOFF/本证据目录/regression-runs/designs/completions/p2 开跑卡）∪ 批前既存脏面（旧链迁档删除群、docs/pm PM 自维护面、往链开跑卡存量——均非本链写）；全部改动 .sh 过 `bash -n`；scan-packs 断言 exit 0（`phase4-scan-packs.txt`） |
| AC30 | PASS | `.tad/version.txt` = 3.0.2，与 Phase 0 基线逐字一致；本链零 bump 记录 |

## 附注记（呈 Gate 3／PM 裁断，不自改判读）

- **注记一（AC3）**：见 AC3 行。supersede 形态经 Gate 2 裁定落定，与 AC3 字面在重复 path 上有读法分歧；事实与两替代读法（均 mismatch=0）已全录。
- **注记二（AC7/AC8）**：首跑对照的捕获通道在本环境无真隔离形态（fork 必继承上下文；VM opencode 后端当日 stall、最小探针 RC=124；codex 包装目录受限）。三案 INVALID 的机械值照录不改；归因在捕获通道而非样本。§4.1 定式补救（换判别标记）针对真裸对照失效，套用于污染对照会腐蚀样本，故不自行执行。建议：第二跑以真隔离通道（grokbox 侧裸跑或后端恢复后重捕）重建对照基线后复评；三案是否接受以「被测侧 PASS＋对照基线顺延」收口，请 PM 裁断。
- **注记三（AC25）**：§4.9 括号内的字段列（from/to/date/delete/rename/note）与在船前例 2.43.1 件实际写法冲突——按 Gate 2 合并裁定的形态锚（以 2.43.1 件实际写法为准）与引擎实测（note 置于 rename 节后被解析器 REJECT）改按正本形落盘（schema_version/引号版号/generated_by/note 块在前/delete/rename 在后、无 date 字段），与 AC25 的字段集逐项一致；在船断言的 from/to 解析已同步剥引号。此偏离显式登记，请 Gate 3 按裁定锚判读。

## 看守差归因（§4.0 口径）

- 件 2.0 销账时点（2026-10-06T06:36:56Z）：NOCARRIER=9、STALE=0。
- 链末复跑（2026-10-06T07:04:43Z）：NOCARRIER=41、STALE=1、CARRIED=13226、VERDICT=OK。
- 差归因：NOCARRIER +32 全为 2.0 同步后本链自产证据件（epic-p2 证据目录后续件、regression-runs、designs 三件、reviews 后续件等；本 COMPLETION 与实施完工说明落盘后将再 +2，同形态），属预期、待下轮补同步；STALE=1 点名 `.tad/evidence/pm/evidence-freshness-log.md`——看守自家日志在同步后被后续看守运行追加（自引用），非内容过期。

## CF-7 观察项登记

更早两段 hop 缺口（`.tad/migrations/` 在船清单中无 2.43.1-to-3.0.0 与 3.0.0-to-3.0.1 两件）——按 §4.9 本链不补，登记观察：自该两版 genesis 锚定的下游副本升级时将走 genesis 锚定零操作通过或 chain-gap REJECT，处置归 PM 后续裁断。

## 过程自报（诚实记录）

- 同病扫描首轮误以转述口径分组（G2/G3 定义与 §4.8 逐字不符），落记录前自查抓出并按原文重跑，判读全出自重跑（`seat-name-scan.md` 内有执行注记）。
- Phase 4 首轮 version detect-only 误以两参数调用得 no-op PASS，已按 Phase 0 三参数同法重跑：25→27 hits，增量恰为本链两处新文本的史述引用（publish-protocol:264、publish-ops:117，均 §3.1 口径下的历史叙述面、非 live 身份面），归因在案（`phase4-minor-detect.txt`）。
- state-surface 终验 PASS（check7 brain-index 龄 20d 为 advisory WARN，非本链辖面，归 Epic Phase 4）；driftcheck (b) 类 11 件与 Phase 1 收口存量逐件同名、本链零新增（`phase4-driftcheck.txt`）。
