# 完工说明 — tad-phase3-anchor-design-01（锚链设计步：首链 HANDOFF 创建）

- 步：EPIC-20261004-tad-full-implementation Phase 3 批 1 · 📐 TAD 席首链设计步
- 执行者：Alex（Solution Lead），Muse 原生 subagent（channel=internal-subagent，env=@MuseVM）
- 日期：2026-10-04
- 产出：HANDOFF 正本一件（见 §2）；本说明一件。未调 precheck、未产 stamp/claim、未填任何 Gate 2 结论。

## 1. §3 必读原件打勾回执

- [x] TAD 仓 `AGENTS.md`（全文）＋ `.tad/project-knowledge/principles.md`（全文）＋ `.tad/project-knowledge/patterns/_index.md`（全文）；命中条目全文读：`ac-verification.md`（AC realism／dry-run／ignored-tree blindness 三条直接用于 §9.1 与 Project Knowledge 节）；release-sync.md、research-methodology.md 经 `_index.md` 索引摘要＋census 交叉核用，未逐字全文读（索引摘要已含本链所需口径，如实标注）
- [x] TAD 仓 `.tad/tasks/handoff-creation.md`（全文）与 HANDOFF 模板原件 `.tad/templates/handoff-a-to-b.md`（全文）；研究轨模板头并读：`research-charter.md`、`research-decision-brief.md`、`research-critic-review.md`、`research-quality-rubric.md`
- [x] TAD 仓 `.tad/active/TICKET-20261004-maintainer-evidence-branch-revival.md`（全文）
- [x] TAD 仓 `.tad/evidence/phase3-census.md` D35/D36/D44 行＋ `.tad/evidence/phase3-inflight-chains.md`（全文，本链为第 8 行，判定「不适用／未开链」）
- [x] gm 仓 `.tad/active/handoffs/HANDOFF-gm-phase3.md` §4.3（verdict 路名与字段：认硬拦 v2 §4.2 全字段＋reviewed_at、tech/fit 路名）、§6.2(e)；gm 设计 `.tad/evidence/designs/2026-10-04-gm-phase3-design.md` §4.3（首链与 first-chain 证据件口径）、§2.3（precheck 首跑：exit 0＋claim 路径、禁 bypass 绕 §2f）
- [x] gm 台账 `.tad/active/epics/tad-full-implementation/phase3-rollout-ledger.md` procedure 修订第 6 条 F-2 全文（RG3 verdict＋Decision Brief＋RG4 记录＋`研究轨收口:` 锚行四件）＋ C-P3-4 定论操作定义（挣得条件、等价五条边界）
- [x] TAD 仓 `.tad/gates/research-gate-canonical-checklist.md`（全文，RG1–RG4 判据原件）
- [x] TAD 仓 `.tad/evidence/pm/2026-10-04-tad-self-review-r1.md`（全文，P3 节为本链源头）

另读（包外但成文必需，均只读）：批 1 开跑卡 `gm/docs/pm/open-cards/2026-10-04-gm-phase3-mt3-batch1-start-card.md`（tad_basis J1,J2 出处）、gm HANDOFF §6.2(b) 前置事实行（stage＝quiz-pending、TAD-POINTER 已在盘）。

## 2. 产出物 1：HANDOFF 正本

- 路径：`/home/hatch/workspace/yun-sync/TAD/.tad/active/handoffs/HANDOFF-2026-10-04-maintainer-evidence-revival.md`
- 字节数：**50,588 B**（写后 `wc -c` 实测；无 sync-conflict 文件）
- 章节清单：frontmatter Quality Chain Metadata（task_type: research／research_required: yes／e2e_required: no／skip_knowledge_assessment: no）→ Handoff 头（task_id／pm_seat 等）→ 头五键（task_id／tad_scope: na-research＋依据／tad_basis: J1,J2／step_kind: research／pm_seat: 📐 TAD）→ 文档勾选清单（读/验/办）→ Gate 2 节（tech/fit 双路记录位留空＋字段位＋合并裁定位）→ Handoff Checklist → §1 Task Overview（1.1–1.3 含 Intent 与理解确认）→ Project Knowledge（3 条历史教训）→ §2 Background（2.1 先行件／2.2 亲验基线表／2.3 依赖）→ §3 Requirements（3.1 FR1–FR11／3.2 NFR1–NFR4／3.3 RG1 立项／3.4 RG2 计划）→ §4 Technical Design（4.1 数据流／4.2 S1 盘点规格／4.3 三案框架／4.4 落点／4.5 D35 字段口径／4.6 F-2 四件落点）→ §5 MQ1–MQ5（全带实跑证据）→ §6 Implementation Steps（S0 前置门／S1–S4／Micro-Task Rules）→ §7 File Structure（7.1 创建 9 件／7.2 修改 2 件／7.3 明示不改／7.4 Grounded Against）→ §8 Testing（8.1 复跑／8.2 抽查／8.3 Edge／8.4 Friction 五类／8.5 Feedback）→ §9 Acceptance → §9.1 AC 表 12 行 → §9.2 Expert Review Status（双审 Open）→ §10 Important Notes → §11 Learning Content（研究轨 vs Build 轨取舍）
- §9.1 口径：12 行每行恰一种合法 Verification Method（command 为主，AC7 为 rubric-spawn）；pre-impl 三行（AC1/AC2/AC3）已附 2026-10-04 实跑原始输出（TICKET_PRESENT／8713ea4e／8708＋2248）；post-impl 行在未实施基线上已验以正确理由失败（MANIFEST_ABSENT／FIRSTCHAIN_ABSENT／usage log 解析得 0 0 0），已写入 Verified Output 列。

## 3. 设计裁量点清单（请 PM 与 Gate 2 评审逐条挑）

1. **tad_basis 沿 J1,J2**：取批 1 开工卡的 basis（该卡 headed 本席整批工作）；若锚链应有专属 basis，请 PM 裁。
2. **S1 双口径展开**：票面只说「盘点」，我设计为路径差集＋同路径内容 sha 差集双口径，并把分支集先按两树前缀过滤——依据是定稿前实测：分支树 6,596 件含 `.agents/` 等两树外路径，且路径同在不等于内容同（只做路径差集会漏 stale-content 类且 branch-only 计数虚高）。请 tech 路重点核此展开是否过重。
3. **Gate 2 verdict 文件名日期写死 2026-10-04**：按日期前置命名惯例取设计日；若双审跨日完成，文件名与落盘日不符，须 PM 裁改名（并同步 HANDOFF §Gate 2 记录位）或接受。
4. **RG3/RG4 文件名用无日期 slug 式**（`rg3-critic-maintainer-evidence-revival.md` 等）：reviews 目录通行日期前置式；改 slug 式是为使 F-2 锚行与 AC grep 的路径稳定。请 fit 路核。
5. **COMPLETION 落 `.tad/evidence/completions/`**：近年本仓惯例（R1 链 COMPLETION 亦在此）；模板旧例在 `.tad/active/handoffs/`。已按惯例取前者，请核。
6. **D35 usage log 字段口径为本链自定**：仓内 grep（tasks/templates/gates/docs）无格式原件；我定 genesis/usage 两式 JSON、chain 与 handoff 双字段冗余以保 GM A7 可解析，并要求 genesis 为全文件第一行。此口径未过任何原件背书，请 PM 决定是否提请 GM 收编为全仓口径。
7. **第三案为「分级混合载体」**（包内授权自拟）：关键件走主仓例外、批量件走分支同步、一册统管；「关键件」判据留 S2 定义、RG3 把关，本步未先定。
8. **§9.1 的 grep 锚词即产物字面约束**：如 summary 须含 `as_of/复跑/hash-object/估计`、Brief 须含 `案一/案二/案三` 与 `## SOURCES`、COMPLETION 须含 KA/Friction/Evidence Checklist/Provenance 节名——产物作者须照锚词写。请评审确认不过苛。
9. **first-chain.md 创建与锚行写入归 PM**：执行者只提交锚行全文，写或授权代写由 PM 在 S4 派发时明示（该件是 PM 的 precheck 记录件，不让执行者擅自动）。
10. **Gate 2 记录位未转写硬拦 v2 §4.2 字段全集**：只留 tech/fit 两表＋reviewed_at 明列，字段全集以 gm §4.3 所认原件为准（不转写＝不走样，但评审落盘时须自查全集）。请 fit 路确认此留空形态可接受。
11. **轮次预算（NFR4）由我定**：S1 一轮、S2 一轮＋RG3 后至多一轮修订；出处是 RG2「有界轮次＋停止规则」的要求，具体数值无原件依据。

## 4. Provenance

- 激活包：`.tad/evidence/activation-packages/tad-phase3-anchor-design-01.md`（step_id=tad-phase3-anchor-design-01）＋激活壳 `~/workspace/skills/tad-alex/SKILL.md`。
- 基线实测（2026-10-04，Alex 本会话亲跑，仓根 `/home/hatch/workspace/yun-sync/TAD`）：分支尖 `8713ea4e`（2026-09-06 14:42 -0400）；分支树 6,596 件；盘上两树 13,056 件；全树口径差集 盘上独有 8,708／分支独有 2,248；usage log 0 B／0 行；`.gitignore:122/:123` 两行在位（未改动）；post-impl AC 失败形态四例已验（manifest/first-chain 缺失、usage 计数 0、gitignore diff exit 0）。
- 写面：仅本说明与 HANDOFF 两路径；gm 仓只读；未调 precheck、未产 stamp/claim、未动保留集与 session-state。
