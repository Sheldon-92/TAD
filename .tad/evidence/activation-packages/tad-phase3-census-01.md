# 激活包 — tad-phase3-census-01（Phase 3 批 1 · 程序步 (a) 普查）

## 1. 角色激活

- 加载激活壳：`tad-alex`（`~/workspace/skills/tad-alex/SKILL.md`，按壳内指引进仓读原件）
- 你是：Alex（Solution Lead）——需求澄清、普查、设计、HANDOFF、Gate 4 验收
- 角色分离：Alex 不写实现代码；本步是普查取证步，只产两份普查件与一份完工说明，不改任何规程、本体文件或代码

## 2. 工作定位

- 工作仓：/home/hatch/workspace/yun-sync/TAD（下称 TAD 仓；只写此仓）
- 依据仓（只读）：/home/hatch/workspace/yun-sync/gm（下称 gm 仓；本步一切依据原件在此，禁写）
- Epic：EPIC-20261004-tad-full-implementation Phase 3（MT3 批 1），gm 仓 `.tad/active/epics/tad-full-implementation/`
- 本步：MT3 程序步 (a) 普查（HANDOFF-gm-phase3 §6.2 (a)）；本步无 Gate 判定，产出供 PM 验盘与 GM A2/A9 验收
- 上一步结论：Phase 3 Gate 2 双路 CONDITIONAL 已关闭、MT1 台账已建、MT2 C-P3-4 定论 (b) 已落字（gm 台账尾节）；批 1 开工卡 step_id=gm-phase3-mt3-batch1-01
- 登记前形态（C-P3-4 定论）：本步不调 precheck、不产 stamp/claim，以本激活包＋任务书纪律运行

## 3. 必读原件清单（读完逐项打勾再开工；勾选留痕随完工说明交回）

- [ ] TAD 仓 `AGENTS.md`
- [ ] TAD 仓 `.tad/project-knowledge/principles.md`
- [ ] TAD 仓 `.tad/project-knowledge/patterns/_index.md`（命中条目至多读 3 条全文）
- [ ] gm 仓 `.tad/evidence/designs/2026-10-04-gm-phase3-design.md` 的 §1（本席基线行）、§3.3（SC1 判法）、§4.1（普查表式 44 行四列）、§5.1（A2/A9 判据）
- [ ] gm 仓 `.tad/evidence/2026-10-04-tad-docsystem-gap-ledger.md`（44 件 D01–D44 原典清单与逐件说明）
- [ ] gm 仓 `.tad/active/epics/tad-full-implementation/phase3-rollout-ledger.md` 的「📐 TAD（批 1）」节、procedure 修订节（C-T1 勘误 operative 口径）、C-P3-4 定论节
- [ ] gm 仓 `.tad/active/handoffs/HANDOFF-gm-phase3.md` 的 §3.1（FR1/FR4）、§4.1（落点锚点）、§6.2 (a)
- [ ] TAD 仓 `.tad/active/session-state.md` 与 `.tad/active/handoffs/` 目录清单（只列名，内容按普查需要选读）

## 4. 任务本体

- 目标（一句话）：把 TAD 仓 44 件文档系统产物的盘上真态逐件查清落表，并把本仓在飞链逐链按新规/旧规判清，为本席 Phase 3 后续各步与 GM 验收提供唯一事实底。
- 实施依据：以 §3 所列原件为准；原件之间冲突时停下、在完工说明里报冲突，不许自择口径。
- 普查表头部记 PM 已核的 (b) 登记确认事实（原文写入，不改述）：scope-privileges.json `projects.TAD.enabled_at`＝2026-10-04（GM 已登记）；seat-onboarding 键名＝「📐 TAD」；本席 stage＝quiz-pending、graduated＝false；本仓无 `docs/pm/wake-sentences.md`，常驻入口首读文件＝`docs/pm/intent.md`（席位启动序 wake-sentences → intent → now，本仓以 intent 为首读）。

## 5. 产出与证据（落盘路径逐件写死，全部绝对路径）

- 产出物 1：`/home/hatch/workspace/yun-sync/TAD/.tad/evidence/phase3-census.md`——按设计 §4.1 表式：44 行全列（D01–D44 一件不缺）、两态判定（按 §4.1 口径）、逐行证据路径（盘上实查所得；无件写「盘上无」）。每行判定必须有盘上实查支撑（ls/wc/grep 级证据），不许抄设计 §1 基线行充数；与基线行不符处在行内备注标明差异。
- 产出物 2：`/home/hatch/workspace/yun-sync/TAD/.tad/evidence/phase3-inflight-chains.md`——按 HANDOFF §4.1：一链一行，按设计 §3.3 机械判法＋台账 C-T1 勘误 operative 口径判定（§2f 分界＝固定日 2026-10-04；日期权威认链首步 claim ts）。PM 提供的链清单线索（须逐条盘上核实、不得照抄）：① 自查 R1 第一批链 TASK-20261004-TAD-STATE-SURFACE-CLOSEOUT 已于 2026-10-04 收口（Gate 4 PASS、COMPLETION 在盘、六笔本地提交未 push），全程原生 subagent 无 stamp/claim；② `.tad/active/TICKET-20261004-maintainer-evidence-branch-revival.md` OPEN 未开链；③ TASK-20260916-CODEX-LEDGER-REVERIFY 挂起未收口；④ `.tad/active/handoffs/` 内其余未归档 HANDOFF 逐件列状态。
- 产出物 3（完工说明）：`/home/hatch/workspace/yun-sync/TAD/.tad/evidence/completions/2026-10-04-tad-phase3-census-note.md`——含：§3 必读打勾回执（逐项勾销）、两产出物的字节数与行数、44 行判定分布计数、与设计基线行的差异清单、冲突/存疑清单（无则明写无）、Provenance（本步命令与查盘范围）。

## 6. 纪律件

- 只写 §5 三个路径；gm 仓只读；TAD 仓其余文件一律不碰（尤其：不改 `.tad/` 本体规程、不动 `docs/pm/` 保留集 NEXT.md 与四件、不动 `.tad/active/session-state.md`）。
- 不调 precheck、不写 stamp、不产 claim（登记前形态，撞 §2d 属预期外动作，禁行）。
- 判定只认盘上实查；查不到写「盘上无」，不许推断补齐、不许把文件存在当内容达标（两态判定按 §4.1 的内容口径）。
- 同名文件一律绝对路径：本步涉及的 gm 仓与 TAD 仓同名文件（如 AGENTS.md、session-state.md）逐个写全路径再读，读错仓即停下报告。
- 在同步目录跑 python 须带 PYTHONDONTWRITEBYTECODE=1。

## 7. PM 验收方式（派发时先讲明）

- PM 按设计 §5.1 A2（44 行全列、两态判定、每行证据路径或「盘上无」）与 A9（在飞链逐链判定与依据）验盘，另抽查任意 5 行回盘复核；自报数字不采信，以盘上字节与行数为准。
- 完工回执须含：三件产出路径＋各自字节数、44 行判定分布、差异与存疑一句话清单。
