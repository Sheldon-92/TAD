---
dispatch_id: p1-y5-1
dispatch_history: p1-y3-1 (design) / p1-y4-fix-1 (Gate 2 revision) / p1-y4-cr-2 + p1-y4-dom-2 (Gate 2 rereview)
gate3_verdict: run-lens CONDITIONAL (p0=0) — .tad/evidence/yolo/v409-basket/p1-gate3-review-code.md (dispatch p1-y7-g3code-1)
task_type: mixed
epic: EPIC-20261031-v409-basket
phase: Phase 1 — small-fix batch (implementation, step Y5)
handoff: HANDOFF-20261031-small-fix-batch.md
role: Blake (Execution Master)
date: 2026-10-31
---

# COMPLETION-20261031 — Phase 1 小修批实施（Blake, p1-y5-1）

## 0. 激活自报（activation self-report）

经薄壳 `~/workspace/skills/tad-blake/SKILL.md` 激活，进目标仓 `/home/hatch/workspace/yun-sync/TAD` 读原件：仓根 `AGENTS.md`、`.tad/project-knowledge/principles.md`、patterns 索引、conductor-protocol step_Y5、`.tad/tasks/evidence-collection.md`、gate-canonical Gate 3 节、HANDOFF-20261031-small-fix-batch 定稿全文（含文末 Gate Rounds 与本步追加的 AC2 底座修订行）、DESIGN-20261031-ac08-baseline 全文、Gate 2 首轮与复审记录（p1-gate2-review-code/domain、p1-gate2-rereview-code/domain）。实施依据唯一认 HANDOFF 定稿；写集以其 §7 点名为界，未扩围。

## 1. Intent 回述

Phase 1 小修批四步：Step 1 票面分诊处置（五票）＋salvage fixture 的 mode_of 语义修复与双平台留证；Step 2 AC-08 检查器按 DESIGN-20261031 落地四类分类、collect-and-continue 全量报告与登记册数据化；Step 3 框架落字（surplus SKILL 落位、pack 台账小修、Gate 2 头形机械行、分段落盘纪律）；Step 4 两 workflow 脚本的运行时需求声明＋入口探针。§9.1 十八行逐行自验结果见 §6；未达行（AC1、AC3、AC8）均以实测＋归因形态显名，不静默跳过。

## 2. Step 1 — 分诊与 salvage

### 2.1 分诊表（五票逐票结论）

| 票 | 结论 | 凭据 |
|---|---|---|
| TICKET-20261028-checker-false-negative（T-1） | CLOSED（记账销账） | 收口节终局 CLOSED 在盘；实施/复核件 `.tad/evidence/yolo/distill-tickets/t1-*`；票头 Status 已改 CLOSED＋凭据根指针 |
| TICKET-20261028-handoff-creation-loadpoints（T-2） | CLOSED（记账销账） | 收口节「状态：CLOSED」；verdict 件 `t2-gate3-review.md`（PASS）；票头同上 |
| TICKET-20261028-r4-distill-text-pack（T-3） | CLOSED（记账销账） | 收口节「状态：CLOSED」；verdict 件 `t3-gate3-review.md`＋`t3-fix-gate3-review.md`；票头同上 |
| TICKET-20261028-gate2-form-enforcement（T-1b） | CLOSED（Step 3 第 4 步落地后关票，见 §4） | canonical:29／gate SKILL:91 唯一键行＋票头关票凭据行 |
| TICKET-20261028-backup-fixture-tmpfs-stat（salvage） | 已修待 Gate 验（关票留收口） | 票头 Status 行已回填：已修＋证据根指针；见 §2.2 |

### 2.2 salvage mode_of 修复

改动一处：`.tad/tests/backup-lifecycle-fixture.sh` 的 `mode_of()` 改为语义值分派——先 GNU `stat -c '%a'`、后 BSD `stat -f '%Lp'`，每路输出经纯数字形态校验（空或含非数字即弃）才采信，都不过 return 1；注释引票号。fixture 其余行逐字未动（改前快照 `fixture-pre-fix.sh` 在证据根）。

实测要点（详 §6 AC1–AC4）：本机同 env 改后行集与基线 9 行 verdict 逐行全同（PASS=2 FAIL=7 不变）——mode 断言行在同步文件夹内**不可达**：其前置（salvage 产出 diff 文件）依赖 `git show` 读发布版 config，本仓文件夹制无 .git，分类在上游即降级、dpath 恒空，mode_of 修得再对也轮不到执行。此归因经三路实证：① 基线/改后 FAIL 详情逐行 diff（差异仅沙箱临时路径与令牌，verdict 与断言身份全同）；② AC2 测床证明 mode_of 本体已修好（GNU 真机、模拟转储型 stat、Mac BSD 三环境均返回单行纯数字）；③ 在 git 副本（字节同构的最小仓）中同一 fixture 改后跑出 9/9 PASS、mode 行即 `PASS: salvage: the diff file sits beside the backup bytes`。Mac 腿：改前基线已录（行集与 VM 基线 verdict 全同）；改后轮因同步未把改后 fixture 送达 Mac 副本（收口时复查 sha 仍为改前 be1b47a0…，与已知 grokbox→Mac 同步积压一致），按 HANDOFF §8.4 显名挂账待同步重跑，不静默跳过——重跑命令：`ssh -F /home/hatch/.ssh/config mac "cd ~/云同步/TAD && PYTHONDONTWRITEBYTECODE=1 /bin/bash .tad/tests/backup-lifecycle-fixture.sh --case salvage"` 输出落证据根 `salvage-mac-after.txt`。

## 3. Step 2 — AC-08 分类与全量报告

先锁两件已落：DESIGN §1 两数更正（157 消失、126 总行／113 PASS 落 §1，AC12 五值 0/113/126/1/1）；HANDOFF 文末「AC2 底座」修订行（捕获件四件＋scratch 重建命令原文＋残差显名）。

新 `AC-08.py`（457 行）：check() 改记录式 collect-and-continue（函数体内无 sys.exit，结算在尾部）；分类器按 DESIGN §3.5 五步（T→X 守卫→R→S 捕获集→未分类 FAIL-as-S），D12① 的 T-未枚举路由落字（证据面未枚举路径只报不判 FAIL、入 diff 集）；登记册 `scope-registry.json` 为数据文件（种子恰 3 条：2 X 豁免＋1 R 模式，字段 owner/guard/granted_by/date 齐，历史守卫行文案经 legacy_guard_line 字段保全）；旧脚本留 `AC-08.py.prev`；文本行文法与旧版逐字兼容（where 空时尾随空格亦保留）；末尾 SUMMARY（计数、类矩阵、DIFF SET、双口径 FAIL 集、KNOWN-DEVIATION 裁定＋余集）；JSON 侧车 `AC-08-report.json` 写 ROOT 证据面。脚本正文无两条种子路径字面量（grep 0/0）。

**D12② 退出码锁定（脚本头注同字落字）**：R 类 FLAG（窗口内缩减或删除）**计入 exit 1**，照 DESIGN 倾向；登记册条目 guard 字段具名轮转机制者，该模式的 FLAG 降为报告项；不留运行时裁量。

六条验收（DESIGN §7）全过，逐条输出在 `ac08-six-checks.txt`：AC1 fixture 一轮报全三处跨段不符、旧版恰 1 处即退（对照）；AC3 七子断言同轮全中（另观察到 shrink FLAG 与 T-未枚举报告）；AC4 干净重放 exit 0 全段在场、缺 baseline.json 时 exit 2＋8 行 SKIPPED 逐段点名；AC5 登记册字段齐、缺 granted_by 条目使运行判 INDETERMINATE exit 2；AC6 新旧行集 diff 差异仅限重分类行对、[class] 后缀、续跑段与 SUMMARY。

AC2 以**等价替代**达成（理由与两腿明细在 ac08-six-checks.txt）：Gate 4 时点的工作树已不可字节完备重建（ignored 捕获 55725 条中 10643 条字节源已随磁盘清理等消失），故 Leg-2 受控 fixture 记录集逐字执行 AC2 断言（分类后 FAIL 集为空、旧口径 FAIL 集恰为 E1 对 {xstate.md, runtime/grow.log}、KNOWN-DEVIATION: yes、删任一登记条目翻 no 且该路径入余集——双负控均实跑）；Leg-1 最大保真重建真实记录集重跑（报告 `ac08-rerun-report.txt`＋侧车），E1 两路径与 now.md 均被正确分类为 X/R 报告（零 FAIL/FLAG），残余 10688 FAIL 全属重建极限五类并逐类计数（ignored 无源 10627、status 行 40、non-target 符号链接形态 12、两 target 的 Gate 4 后再漂移致 excerpt 8、index 1）。旧脚本在同一 scratch 上 38 行即 fail-fast 退出（`ac08-rerun-oldscript.txt`）。

## 4. Step 3 — 框架落字三件＋T-1b

- **G4-F3（AC7）**：surplus SKILL 的 throw 句已拆出 Budget guard 条、独立成条（加同风格标签 `Ledger mode limit`，句子本体逐字未动，grep 计数 =1）。一处显名：AC7 梗概语「Budget guard 条正文止于 circuit-breaker semantics」未字面达成——「marks totals estimated…」从句仍留在 Budget guard 条内，因为 AMEND2 §6 第 12 项 (i) 原文的增句对象只有 throw 句、D5 的拆出对象也只有该句；按 AC7 的 Expected Evidence（独立成条＋条内不再含该句）已达成，此口径差留 Gate 3 判。
- **pack 台账（AC5/AC6）**：头注 STATUS SEMANTICS 落词表——新增 `no-discriminative-power`（验过、无干净 delta）、`verified` 降格表述为 `verified-discriminative` 并写明语义＝单 fixture 存在性证据、`verified-in-use` 预留等级（真实任务回放＋触发率证据，本 Phase 不产生）、`deregistered` 一条。行处置：9 行 verified→verified-discriminative（注释未动）；web-backend、data-engineering 改 `no-discriminative-power`（原注释保留）；补 agent-computer-interface（pending，fixture: fixture-browser-task）与 ai-podcast-production（pending，fixture: full-episode-production）两行，状态与盘面 fixture 事实相符；ml-training 行不删、状态改注 deregistered 并引票号。三计数实测 3／9／26。
- **registry 摘注册（AC8，PARTIAL）**：scan-packs.sh 表头模板注释改为裁定文本（字段留作元数据、Phase 2 兼容检查待办已裁、引 TICKET-20261031-pack-triage、无 consumer TBD）；ml-training 源包整目录移 `.tad/capability-packs-retired/ml-training/`（移前移后聚合哈希同值 cd55b7f8…，字节保留）；再生条目 26→25，与 v4.0.8 克隆 registry 的条目名 diff 仅 ml-training 一项（无再生附带漂移）；ml-training 活引用普查：仅 registry 本体与本批 HANDOFF 散文，其余 61 件全为 archive/evidence/worktree 历史件、不回指。driftcheck 改后 (a)/(c) 仍空、exit 仍 1 且由 (b) 驱动，但 (b)/(d) 新增 ml-training 一项——根因是 Gate 2 基线前提「ml-training 未装为 skill」与盘面不符：`.agents/skills/ml-training/` 是完整装载投影（SKILL.md＋examples/references/scripts），源包摘注册后投影机械地浮现为未注册已装 skill；driftcheck 正常工作、恰好抓到本次状态变更。三条处置（声明 skill-only／投影一并退役／修订 AC8 期望）均在本步写集外，留 Gate 3／conductor 裁，明细在 `pack-ledger-diff.txt`。
- **T-1b 机械行（AC9/AC18）**：canonical Gate 2 节（L29）与 gate SKILL Gate 2 派生块（L91）各增恰一行 `handoff-header-form` 机械行（核心含三核验点：首行 `---`、`dispatch_id` 在 front matter 内、§9.1 形态 A；及新合同适用面与存量豁免）；归一化作用域 diff 为空；未跑 drift-check.sh。**本 handoff 首行与 front matter 形态已按新机械行自核**：头形命令输出 first=`---`、dispatch_line=2、frontmatter_close=23、header-form: PASS，§9.1 形态 A 表头计数 =1（命令原文在 HANDOFF §9.1 AC9 行，输出值在此落字）。T-1b 已关票：票头 Status=CLOSED＋关票凭据行（指 Gate 2 首轮 p1-gate2-review-code/domain 与复审 p1-gate2-rereview-code §3／-domain 记录、两处唯一键行位），票面历史正文未动。
- **分段落盘纪律（AC13）**：`.tad/tasks/evidence-collection.md` 新增「Segmented Write Discipline（分段落盘纪律）」节：>约 8KB 证据类文件分段落盘、每段验字节、回执自报总字节数与章节清单、收尾自查无截断标记，四要件齐（grep「分段」=3、8KB 门槛行在盘）。本 COMPLETION 即按此节分段落盘。

**RP3 走查三问（答案只来自台账状态值列）**：① 哪些包是 verified-discriminative？——ai-evaluation、code-security、rag-retrieval、agent-memory、llm-observability、ai-guardrails、agent-orchestration、synthetic-data、knowledge-graph，共 9 个。② web-backend 与 data-engineering 是什么状态、读者当如何用？——no-discriminative-power：已做行为评测但对照同过、无干净 delta，不得按已验证使用；先收紧 fixture 判别标记才可重验。③ ml-training 与新补两行各是什么状态？——ml-training 为 deregistered（摘注册、行留史）；agent-computer-interface、ai-podcast-production 为 pending（有 fixture、尚无通过记录）。

## 5. Step 4 — 运行时需求声明与入口探针

- **声明（AC16）**：两脚本头部各加 `runtime-requirements:` 声明段（全局名＋类别＋缺失后果）：surplus-execute 声明 agent（hard）、phase（hard）、budget（facade）、workflow（facade）；surplus-scan 从简同构、只声明 agent/phase 为 hard 并注记不需 budget/workflow。surplus SKILL 补探针口径一条（与 G4-F3 同文件串行落字）。三计数实测 1／1／1。
- **探针段（D13）**：两脚本入口各加存在性探针（只读 typeof、从不调用被探全局、零 agent 零 token）：硬需求缺失→throw 点名该全局；facade 覆盖项缺失→各一行降级注记续行。execute 探针位于 phase('Validate') 之前（缺 phase 时也能干净点名），scan 探针位于首个 log 行之前。
- **副本运行（AC17，RP2）**：改后 surplus-execute 逐字复制入证据根（`surplus-execute-copy.workflow.js`），原件跑前/跑后与副本三方 sha256 同值 df0f5804…；按 invocation-specs Probe C 形态以副本启动（mini fixture 两行＋绝对 repo_root、无 budget_total）：run workflow-run-0869dfc9848c4aa4b727c30a191127e9 在 Validate 内以 budget_total 缺失 throw 终止，agent 调用 0、token 0——探针报告（硬需求在场行＋budget/workflow 两行降级注记）在任何 agent 活动之前已发出，且 budget 缺失未触发探针红灯（终止点是既有的参数检查、非运行时需求失败）。本 harness 不把 workflow log() 行持久化到可读文件/事件表（已查运行目录与 runtime.events），探针行以字节一致副本的代码序＋启动记录互证，Gate 3 可一次启动现场复看。两脚本 wrapped-body 语法检（node --check）均 OK。证据：`probe-copy-run.txt`。
- **缺项 fixture（AC17）**：探针段逐字抽出（1091 字节）入 /tmp 测床（测床不入仓），在 log 在场、agent/phase 皆缺的运行时描述下以 node 运行：throw 点名 `agent`（"missing hard runtime requirement: agent"），红灯成立。证据：`probe-missing-agent.txt`。

## 6. §9.1 十八行逐行实测

| AC | 结果 | 实测摘要 |
|---|---|---|
| AC1 | 未达（归因形态） | 改后行集 9 行 verdict 与基线逐行全同（PASS=2 FAIL=7）；mode 行在同步文件夹内不可达（上游 git 依赖降级致 dpath 恒空，见 §2.2 三路实证）；基线 2 PASS 行保持；文本差异仅 2 行 FAIL 详情内的沙箱路径/令牌 |
| AC2 | PASS | 测床三环境（GNU 真机／模拟转储型 stat／Mac BSD）对 chmod 600/644 均返回单行纯数字且与 chmod 值相等（`ac2-modeof-testbed.txt`、`salvage-mac-modeof-testbed.txt`） |
| AC3 | PARTIAL | Mac 改前基线在盘且 verdict 与 VM 基线全同；改后轮待同步送达（收口复查 Mac fixture sha 仍为改前值），重跑命令已记 §2.2；mode 翻转的函数级证据由 Mac 测床＋git 副本 9/9 承担 |
| AC4 | PASS | `--case all` 改前/改后各 57 行断言 verdict 逐行全同（PASS=41 FAIL=16 两轮一致），非 salvage 段无回退 |
| AC5 | PASS | 三值实测 3（≥2）／9／26：头注含 no-discriminative-power 与 verified-discriminative 分级语义；packs 段作用域计数合 |
| AC6 | PASS | 两补行各一行，状态 pending 且注 fixture 名，与盘面 examples fixture 相符 |
| AC7 | PASS（梗概语口径差显名） | grep 计数 =1；throw 句独立成条；Budget guard 条内不再含该句（Expected Evidence 三项全合）；「止于 circuit-breaker semantics」梗概语与 AMEND2 12(i) 原文的张力见 §4 |
| AC8 | PARTIAL | registry 注释为裁定文本（含已裁＋票号、无 consumer TBD）✓；再生条目 25 ✓；retired 件在盘且字节聚合哈希同值 ✓；driftcheck (a)/(c) 空 ✓、exit 1 由 (b) 驱动 ✓；但 (b)/(d) 新增 ml-training 一项（基线前提与盘面不符，见 §4 与 pack-ledger-diff.txt），处置留 Gate 3 |
| AC9 | PASS | canonical:29／SKILL:91 各恰一行唯一键；归一化作用域 diff 空；活样本头形 PASS（first=---、dispatch 2、close 23）；形态 A 表头计数 =1 |
| AC10 | PASS | 三票 Status 行均含 CLOSED 与 `.tad/evidence/yolo/distill-tickets/` 指针（grep 计数 3/3）；关前已逐票核收口节与凭据相符 |
| AC11 | PASS | salvage 票头 Status 行在 `grep -A2` 窗口内：含「已修」＋证据根与 salvage-vm-after.txt 指针 |
| AC12 | PASS | 五值实测 0／113／126／1／1（157 归零、126 与 113 均落 DESIGN §1 作用域内） |
| AC13 | PASS | evidence-collection 新增分段落盘节：分段／每段验字节／回执总字节数与章节清单／尾无截断标记四要件同节齐；grep「分段」=3、~8KB 门槛行在盘 |
| AC14 | PASS | check() 体 sys.exit awk 输出恰为 `check-body sys.exit: none`；scope-registry.json 与 AC-08.py.prev 在盘；种子恰 3 条、字段走查齐（owner/guard/granted_by/date） |
| AC15 | PASS（AC2 等价替代显名） | DESIGN §7 六条逐条输出在 `ac08-six-checks.txt`；删登记双负控翻转成立；AC2 以 Leg-2 fixture 全称判定＋Leg-1 真实记录集分类互证达成等价替代 |
| AC16 | PASS | 两脚本 runtime-requirements 计数各 1（≥1）；SKILL「探针」计数 1（探针口径一条已落） |
| AC17 | PASS | 副本运行探针报告先于任何 agent 活动（agent 0／token 0、Validate 内止）；budget 缺失只降级不红灯；缺 agent 测床红灯点名 agent（`probe-copy-run.txt`、`probe-missing-agent.txt`） |
| AC18 | PASS | T-1b 票头 Status 含 CLOSED；关票凭据行同时指 Gate 2 首轮＋复审记录与 canonical／SKILL 唯一键行位；除票头两行外票面未动 |

未达/部分达成汇总（不掩饰）：AC1 未达（环境归因，修法本体由 AC2＋git 副本证明）；AC3 部分（Mac 改后轮待同步）；AC8 部分（driftcheck (b)/(d) 新增 ml-training，处置三选一留 Gate 3／conductor）；AC7 梗概语口径差一条（Expected Evidence 已达成）。四项均不阻断本 Phase 其余交付，出口分别记于 §2.2、§4 与本表。

## 7. Knowledge Assessment

- 本步直接消费的仓内知识：DESIGN-20261031 的分类设计（§3.5 决策程序与 §3.6 登记册治理是 AC-08 改造的承重输入，按其原文落地未改判）；HANDOFF 的 D1–D16 决策（含 D12② 的倾向在本步锁死并双落字）；Gate 2 双审记录（AC9 留痕与 AC5 post-impl 判定按复审件 §3 对单）；shell-portability pattern（mode_of 的 BSD/GNU 分派形态与之同构）；Copy-execution protocol（RP2 副本运行逐字执行）。
- 新学到并已回写的事实：① 同步文件夹（无 .git）内 fixture 的 git 依赖段会整体降级，断言失败签名可能来自上游不可达而非被测函数本体——归因须先分清断言可达性；② GNU `stat -f` 的危险形态是「退出码随环境变」而非单纯转储，输出形态校验比退出码分派稳健；③ pack 基线前提（ml-training 未装 skill）与盘面不符一例：台账注释是史迹不是事实源，处置前须以盘面复核前提。

## 8. Friction Status

- Mac 同步积压：改后 fixture 在本步约两小时窗口内未送达 Mac 副本（AC3 改后轮挂起，出口＝同步到达后按 §2.2 命令重跑，收口或 Gate 3 顺手即可，不需新派发）。
- 本 harness 的 workflow log() 行不持久化：RP2 的探针行只能以代码序＋启动记录互证（probe-copy-run.txt 已显名），与 Claude Code 面的可观察性差距属环境事实、非脚本问题。
- AC-08 记录集的字节完备重建不可能（捕获后 12 天的清理与漂移）：AC2 的等价替代形态（fixture 全称＋真实集分类互证）建议由 Gate 3 明确认可或另立口径，避免后续链重演争议。
- 其余无摩擦：写集内文件均可达、命令口径与基线一致、无 HALT 触发。

## 9. Evidence Checklist（Required Evidence Manifest 对单，证据根 `.tad/evidence/yolo/v409-basket/`）

- [x] salvage-vm-after.txt（＋基线 salvage-vm-baseline.txt、salvage-vm-all-baseline.txt、salvage-vm-all-after.txt、改前快照 fixture-pre-fix.sh）
- [x] salvage-mac-baseline.txt
- [ ] salvage-mac-after.txt —— 待同步送达后重跑（见 §2.2），本步唯一缺件
- [x] ac2-modeof-testbed.txt、salvage-mac-modeof-testbed.txt
- [x] ac08-rerun-report.txt、AC-08-report.json（侧车副本）、ac08-rerun-oldscript.txt
- [x] ac08-six-checks.txt
- [x] pack-ledger-diff.txt（台账与 registry 改前/改后对照、driftcheck 基线 delta 对账、ml-training 引用普查）
- [x] probe-copy-run.txt、surplus-execute-copy.workflow.js（sha256 对账行在 probe-copy-run.txt）
- [x] probe-missing-agent.txt
- 本文件分段落盘回执：总字节数与章节清单见 §10 末行（收尾自查后回填）。

## 10. Provenance

实施者：Blake（原生 subagent，dispatch_id p1-y5-1），2026-10-31。写集与 HANDOFF §7 点名逐件对应：五票票头、fixture mode_of 一处、DESIGN §1 一句、HANDOFF 文末 AC2 底座修订行、AC-08.py 本体＋scope-registry.json 新增＋AC-08.py.prev 留置、surplus SKILL 两处（串行）、behavioral-eval-status.yaml、scan-packs.sh 一行＋pack-registry.yaml（仅再生产出）、ml-training 源包移置 retired、canonical 与 gate SKILL 各一行、evidence-collection 一节、两 workflow 脚本各两段（声明＋探针）、本 COMPLETION 与证据根诸件。仓外工件（不入仓）：Leg-1 scratch `~/workspace/vm-local/ac08-scratch-p1/`、Leg-2 fixture `~/workspace/vm-local/ac08-fixture-p1/`、builder/overlay 脚本与探针测床（/tmp 与 vm-local），路径均在证据件内记明、可复跑。未派任何 subagent；未给自己的活写 verdict（front matter `gate3_verdict:` 留空）；未跑 drift-check.sh；未动 `.claude/` 投影与检查器容忍面。

## Knowledge Usage

- `.tad/active/DESIGN-20261031-ac08-baseline.md`（§3 分类/§3.5 程序/§3.6 登记册/§4 报告形态/§7 六条）——AC-08 改造的规格单源，逐节对回落地。
- `HANDOFF-20261031-small-fix-batch.md` D1–D16 与 §9.1——写集、修法与判据的唯一依据；D11 两锁（§1 更正、AC2 底座）先行落字后动工。
- Gate 2 复审件 `p1-gate2-rereview-code.md` §3——AC9 复审留痕与 AC5 post-impl 判定的对单据。
- `AMEND2-20261031-gate3.md` §6 第 12 项 (i) 与 `GATE4-20261031.md` FIX 对单——G4-F3 拆句的对象与逐字原文。
- invocation-specs.md Probe A–D 形态——RP2 副本运行的调用口径（Probe C：Validate 内止、零 agent）。
- patterns: shell-portability（stat 双形态分派）、gate-design consumer-tolerance（T-1b 生产侧修复与存量容忍的边界）、evidence-collection 分段纪律（本步新增节，且本文件即按其落盘）。

<!-- 分段落盘回执（evidence-collection 分段纪律第 3 项）：本文件共 4 段落盘、每段验字节通过、尾检无截断标记（grep '[truncated' = 0）；总字节数 TOTAL_BYTES=23275（等宽回填，替换不改变总长）；章节清单：front matter／§0 激活自报／§1 Intent 回述／§2 Step 1 分诊与 salvage／§3 Step 2 AC-08／§4 Step 3 落字与 T-1b／§5 Step 4 探针／§6 §9.1 十八行／§7 Knowledge Assessment／§8 Friction Status／§9 Evidence Checklist／§10 Provenance／Knowledge Usage -->
