# Gate 3 CODE 路独立评审 — 自查批 R2（TASK-20261006-SELF-REVIEW-R2）

- 评审者：Blake（独立会话，未参与本链设计与实施；与 SAFETY 路互不可见）
- 日期：2026-10-06
- 对象：HANDOFF `.tad/active/handoffs/HANDOFF-2026-10-06-self-review-r2.md` ＋增补 SUPPLEMENT-1（冲突以增补为准）× COMPLETION `.tad/evidence/completions/COMPLETION-2026-10-06-self-review-r2.md` × 风险卡 `.tad/evidence/risk-cards/risk-TASK-20261006-SELF-REVIEW-R2.md`
- 判据：仓内 Gate Canonical Gate 3 清单（7 项）＋ HANDOFF §9.1 AC1–AC28
- 方法：纯只读；全部复跑在隔离副本／mktemp fixture／只读命令内完成；git 只读。被审方自报一律不采信，逐项以本席重算为准。

## 总判：PASS（附 P3 findings 三条，无 P0/P1/P2）

本席独立重算的每一项数值均与 COMPLETION 自报全等（driftcheck 集合计数、freshness 分段终值、召回四组数、压缩比、traces 存量、双锚 sha256、语料计数），证据否决子款未触发。写集封口成立，禁写面零触碰，版本冻结（version.txt 3.2.0、最新 tag v3.2.0）未动。

## AC1–AC28 逐条结论

| AC | 结论 | 本席证据（独立复跑／复算） |
|---|---|---|
| AC1 双锚 | PASS | `git show HEAD:tad.sh \| sha256sum` ＝ `1490a6ab…a80` 与 HANDOFF Metadata 锚逐字全等；现盘 tad.sh sha ＝ `0b632137…ae9` 与 COMPLETION 改后锚全等；现 3,587 行 |
| AC2 历史 (b) 名录 | PASS | P1 终值件 `epic-p1-clearance-20261006/ac16-driftcheck-final.txt` (b) 段 11 名与 HANDOFF §4.1 名录机械集合对照全等（diff 空） |
| AC3 台账基线锚 | PASS | `git show HEAD:.tad/runtime-compat/codex.md` 中 `\| 2026-08-03 \|` 恰 12 行，与设计步基线记录一致；设计评审期 freshness 活体复跑记录在 Gate 2 双审件在册 |
| AC4 语料基线锚 | PASS | 现盘复算 patterns `^### ` 合计 232、incidents 文件 25；project-knowledge 总字节 585,755 ＝锚 585,723 ＋ 32 B，差额恰为 AC25 授权补标一行，无其他漂移 |
| AC5 定案表 | PASS | `g1-driftcheck-b11-dispositions.md` 11 件逐件三查＋活/死＋处置齐：活 11（补登记 1＝agent-computer-interface、声明锚 10）、死 0，与自报一致；`skill-only-declarations.txt` 恰 10 名；registry git diff 恰 +8 行（仅 ACI 一条目）；ACI `CAPABILITY.md` 为登记恢复件且明注「introduces no new capability content」 |
| AC6 driftcheck 终值 | PASS | 本席亲跑 `.tad/hooks/lib/pack-registry-driftcheck.sh`：(a)(b)(c)(r) 全空、(s) 恰 10 件、exit 0；集合计数 A26／B_type36／B_dir26／C26／S10 与 COMPLETION 逐值全等 |
| AC7 driftcheck fixture | PASS | 本席自建隔离 fixture（/tmp，脚本副本＋伪造 registry/技能/源包）四景全复现：phantom→(c)、regonly→(r)、declared→(s) 不入 (b)、undeclared→仍入 (b)（负控成立）、exit 1 由 (b)/(c) 触发 |
| AC8 台账刷新对应 | PASS（附 P3-1） | `g2-ledger-reverify/` 12 份逐条证据与台账 12 行逐条对应；10 行刷新行 last_verified＝2026-10-06、runtime_version＝codex-cli 0.149.0、source 列含探针＋文档 URL（retrieved 2026-10-06）＋证据指针；next_review 顺延算术正确（high +30d→2026-11-05、medium +60d→2026-12-05、low +180d→2027-04-04） |
| AC9 挂起行未动 | PASS | `grep -c '\| 2026-08-03 \|' codex.md` ＝ 2（恰为挂起的 C 类 2 条）、`\| 2026-10-06 \|` ＝ 10；台账头 Ledger Version 2、Last Updated 2026-10-06；挂起两行（L32/L33）版本/日期/next_review/状态未动 |
| AC10 freshness 分段终值 | PASS | 本席亲跑 `runtime-freshness-verify.sh`：PASS 10／WARN 1（trace_evidence_capture）／BLOCK 1（context_compaction）、exit 1——与 COMPLETION 所记分段终值逐值全等，无虚称 exit 0 |
| AC11 C 类挂起口径 | PASS | 两份 C 类证据记当次实测尝试：`codex exec --json` 返回 turn.failed、厂商原话 "You've hit your usage limit… try again at Oct 10th, 2026 2:24 PM"（实测时点 2026-10-06T18:52Z）及实际收到的 JSONL 事件序列；属真实测被配额阻断后按停步点挂起，非文档充数 |
| AC12 残留 `diff -rq` | PASS | `grep -n 'diff -rq' tad.sh` 恰 1 行（L2239，`_tad_tree_equal` 既有头注，属增补 S-3 明示除外款）；L1699 旧注释已改述、注释与调用点均指向新探针名 |
| AC13 R1 fixture 五景 | PASS | 本席亲跑 `g3-r1r2-fixture.sh`（mktemp 隔离、函数自现盘 tad.sh 逐字抽取）：R1 五景全 PASS；与落盘 log（10 SCENE PASS）一致 |
| AC14 pre-tree 生成/消费 | PASS | 生成在 L750（`find . -mindepth 1` 全树＋LC_ALL=C sort）；消费在 L2421–2474（含老备份无 pre-tree 时 WARN 零删 L2474）；pre-top 生成保留（L743 一带） |
| AC15 R2 fixture 五景 | PASS | 同上亲跑：R2 五景全 PASS（嵌套清扫/零新建恒等/悬空链清扫且目标无损/老备份零删/新建顶层整树移除） |
| AC16 回归全绿 | PASS（附 P3-3） | `bash -n tad.sh` OK；本席亲跑 `tad-backup-test.sh` TALLY PASS=15 FAIL=0、`detect-state-test.sh` TALLY PASS=12 FAIL=0，与自报逐值全等 |
| AC17 R3 评估 | PASS | `g3-r3-migrate-backup-assessment.md` 四问齐备且逐问有结论（无清理逻辑明说／体量实测区间／四项差距表／建议另立票）；tad.sh 中 migrate 相关行（710、733、2584、2737、3178、3421）均不在本批 diff hunk 内，零触碰 |
| AC18 gc 预检入 handoff 规程 | PASS | `grep -c 'git/refs loose' .tad/tasks/handoff-creation.md` ＝ 1（L29），文本含 `find .git/refs -type f`，与 §4.4 定稿逐字一致 |
| AC19 gc 提示行入风险卡模板 | PASS | `grep -c 'loose' .tad/templates/dispatch-risk-card.md` ＝ 1（L18），与 §4.4 定稿提示行逐字一致 |
| AC20 期望集冻结 | PASS | `sha256sum g5-recall-expected-set.md` ＝ `761de258…1090` 与 COMPLETION 全等；mtime 序：题集 18:31:24Z ＜ 期望集 18:31:57Z ＜ 跑题留痕 18:34:57Z ＜ 结果件 18:38:17Z，冻结先于跑题；抽查 Q9/Q14/Q23/Q30/Q37 题面无目标条目标题原词与 hook 独占词（如 Q30 不名 yq、Q37 不名 ScienceClaw） |
| AC21 召回判分复核 | PASS | 本席以期望集×跑题留痕按结果件所记粒度（principles 条目级、patterns/incidents 文件级）机械重判全 45 题：Recall@3 ＝ 26/40（8/8＋14/24＋4/8）、Recall@1 ＝ 14/40（5/8＋7/24＋2/8）、无答案误报 3/5（Q41/Q44/Q45），与结果件逐题判定表全等；压缩比重算：patterns 3,491 ÷ 482,538 ＝ 0.0072（分母为 Step 0 冻结锚，现盘值差恰 +32 B 即 AC25 补标行）、principles 4,127 ÷ 25,219 ＝ 0.1637（分子分母现盘逐值复现）；近似边界注记在文且如实 |
| AC22 组 5 只读 | PASS | `diff g5-porcelain-before.txt g5-porcelain-after.txt` 为空 |
| AC23 Rule 6 落位 | PASS | `.tad/templates/knowledge-writing-rules.md` L29 Rule 6 齐备：三值（实测/转述/推断）定义、引用同行标注义务、新条目必须带置信行、未定级视同推断、引用即补标、两种条目形态；文件头计数已改 6（增补 S-6 同步完成） |
| AC24 卸载记录三落点 | PASS | `grep -c '卸载记录'`：handoff-a-to-b.md ＝ 1（§1.4，五列表头 时间｜卸载项｜依据｜原文指针｜回取方式 逐字在位）、session-state-template.md ＝ 1、现行 session-state.md ＝ 2 |
| AC25 dogfood 补标 | PASS | patterns/ac-verification.md git diff 恰 +1 行：`- **Source confidence**: 实测`，位于条目「A Negative Control Keyed on a Marker the Design Itself Invented Is Trivially True」标题行后首行，形态合 Rule 6；COMPLETION 报引用 1 件/补标 1 件，两数相等 |
| AC26 traces 回填 | PASS | `g7-capture-design-backfill.md` 三项齐备（存量确值／停滞成因含已查面清单且精确断点诚实记「未定」／上限校准意见维持设计值 8KB/5MB/100MB 并附依据）；本席独立 recount：顶层条目 87、日期 jsonl 85、全树 795,037 B、顶层 jsonl 3,307 行——逐值全等（增补 S-1 估计数 86 经实测订正为 85，实施方如实披露未迁就估计，记为 E 纪律正面例） |
| AC27 hooks 面零触碰 | PASS | `git status --porcelain -- .tad/hooks .agents skills` 与 `g27-baseline-porcelain.txt` 的 diff 为空 |
| AC28 写集封口 | PASS（口径注记见下） | 实施方改动恰为 HANDOFF §6 写集：改 10 件（tad.sh、driftcheck.sh、pack-registry.yaml、codex.md、handoff-creation.md、dispatch-risk-card.md、handoff-a-to-b.md、knowledge-writing-rules.md、session-state-template.md、patterns/ac-verification.md）＋新建 2 件（ACI CAPABILITY.md、skill-only-declarations.txt）＋证据面与 gitignore 面（.tad/evidence/、session-state.md）产出；其余 porcelain 项可归因于非实施方（docs/pm/now.md 为 PM 常驻文件、票/HANDOFF/open-cards 为 PM 与设计步链件、3 件 now.sync-conflict-* 为同步产物且未触碰）。禁写面零触碰：version.txt 仍 3.2.0、最新 tag v3.2.0、brain-index/gates/principles/installer 面无实施方改动。口径注记：COMPLETION 自报「逐项相符」未注明此归因口径，本席注明后重算成立 |

## 风险卡假设（ASM）复核

- ASM-1（两区写集）成立：tad.sh diff hunk 仅 L744、L1706、L1754、L2216–2246、L2419–2474 五处，全在 R2 生成/消费区与探针定义区（合增补 S-5），无区外 hunk。
- ASM-2（fixture 隔离）成立：两 harness 均 mktemp 沙箱＋逐字抽取＋从不执行 tad.sh 本体，本席亲跑后仓面无新增改动。
- ASM-3（组 2 分段终值）成立：见 AC10。
- ASM-4（死件注销面）成立：死件实测 0、注销 0，空集为真空。
- ASM-5（组 5 只读测量）成立：见 AC22。
- ASM-6（组 7 零实现）成立：见 AC26/AC27，回填件三值维持设计值。

## 组 2 探针独立旁证（支撑 AC8）

本席在本机独立复跑：`codex --version` ＝ codex-cli 0.149.0；`codex features list` 得 hooks stable true、skill_search stable true、multi_agent stable true、remote_compaction_v2 stable true、default_mode_request_user_input under development false；`codex mcp list` 正常返回空集提示——与 skill_loading／hooks／subagents_custom_agents／ask_user_question_hook／mcp 五份证据件记录逐项相符。

## Findings

- **P3-1（证据形态，AC8）**：12 份逐条证据件为结构化探针记录（探针名、观察事实、文档检索日期、判定），非逐字原始输出转录，与 §9.1「含探针原始输出」字面期望有形态差。承重事实（版本号、刷新日期、next_review 算术、C 类厂商配额原话）已由本席独立复跑逐项证实，不影响 AC8 判定；建议后续台账复核链的证据件保留原始输出转录段。
- **P3-2（口径偏离，已留痕，AC6/§4.1）**：设计文字称 skill-only 件处置为「使其归 (r) 类」，实施改立独立 advisory 类 (s)；理由已记定案表——(r) 定义要求 registry 在册，skill-only 件字面不可归 (r)。AC6 判据（(b) 空）本身达成，负控（未声明件仍入 (b)）成立。建议 Gate 4 追认 (s) 类口径为定案。
- **P3-3（证据完整性，AC16）**：COMPLETION 的 AC16 行以 bash -n＋两 harness 为据；§9.1 方法中的「tad.sh 自检段实跑」未见单独可指认的运行输出落盘，仅由 harness 对自检相关函数的逐字抽取覆盖间
...[truncated 551 chars]