# Gate 3 SAFETY 路独立评审 verdict — 自查批 R2（TASK-20261006-SELF-REVIEW-R2）

**评审者**：独立评审会话（Blake 评审身份，未参与本链设计与实施）
**日期**：2026-10-06
**判据**：仓内 `.tad/gates/gate-canonical-checklist.md` Gate 3 节（§9.1 逐行＋证据纪律 E 维）＋风险卡 `.tad/evidence/risk-cards/risk-TASK-20261006-SELF-REVIEW-R2.md` ASM-1–ASM-6
**对象**：HANDOFF-2026-10-06-self-review-r2.md（54,687 B）＋SUPPLEMENT-1（11,352 B）× COMPLETION-2026-10-06-self-review-r2.md（22,457 B）
**方法声明**：本路全部结论为评审者本人复算/复跑所得，不采信被审方自报；与 CODE 路互不可见。

## 总判：PASS

无 P0/P1/P2。P3 观察 2 条（均为记录口径小疵，不构成过门条件，见文末）。

---

## ① 组 2 防刷日期（ASM-3 证伪面）— 成立

**抽核 3 条刷新条目（A 类 2＋B 类 1），证据均为当次真探针，独立复现通过：**

- `skill_loading`（A）：证据件（`g2-ledger-reverify/skill_loading.md`）引 features list 中 skill_search／skill_mcp_dependency_install stable、本机 codex-cli 0.149.0、官方 build-skills 页 2026-10-06 取读。本席在本机实跑复现：`codex --version`＝**0.149.0**；`codex features list` 中所引标志（skill_search、hooks、multi_agent、remote_compaction_v2、skill_mcp_dependency_install）**逐项 stable=true**——与证据件引值全等，探针确为当次真跑、非文档摘录拼凑。
- `hooks`（A）：同上 features 复现通过；本仓 `.codex/hooks.json` 实件结构（description＋hooks 顶层、SessionStart/PostToolUse 在册）经本席 `ls .codex/` 与证据件互证（目录内仅 hooks.json 一件，同时证伪 B 类 subagents 的负向主张）。
- `subagents_custom_agents`（B，负向复核）：「平台已文档化 custom agents、本 adapter 不供不启」与盘面一致——`.codex/` 无 agents/ 目录（本席实查）；current_behavior 补注平台机制一行、status 维持 accepted_limitation，属挂证据改文、非改文充复核。

**刷新集＝证据集**：`grep -c '| 2026-10-06 |' codex.md`＝10（A 7＋B 3）↔ g2 证据目录 A/B 件 10 份逐条对应；source 列均已改记当次出处（增补 S-2 口径，含 2026-10-06 检索日与证据件指针）；台账头 Last Updated 2026-10-06／Ledger Version 2。

**C 类 2 条挂起——日期未动、配额证据真实：**
- 两条在台账中 last_verified 仍 2026-08-03、next_review 仍 2026-09-02、runtime_version 仍 0.146.0、source 仍旧 spike 引用（`grep -c '| 2026-08-03 |'`＝2，本席复算）；与基线逐字段全等，零改动。
- 挂起证据（`context_compaction.md`／`trace_evidence_capture.md`）记当次鉴权实测真尝试：/tmp 隔离目录 `codex exec --json`（0.149.0、ChatGPT 登录态）得 turn.failed＋厂商配额原话 "try again at Oct 10th, 2026 2:24 PM"（2026-10-06T18:52Z），且明文声明旁证（PreCompact 事件在册、JSONL 五件事件）**不作刷新依据**——未以文档核对充数。
- freshness 本席复跑终值：**PASS 10／WARN 1／BLOCK 1、exit 1**，残项恰为 C 类 2 条（context_compaction BLOCK、trace_evidence_capture WARN——HANDOFF AC10 期望文「BLOCK 恰剩 2 条」为简写，真值按波动类分列，COMPLETION 记的正是精确分段值）；全链无任何一处宣称 exit 0。ASM-3 证伪信号（差集非空／文档充实测／挂起谎报全绿）逐一不出现。

## ② 组 1 声明锚与 (s) 段不掩盖异常 — 成立

**脚本集合代数复核（读修订后 `pack-registry-driftcheck.sh` 全文）**：(b)＝B_type\(A∪S)；(s)＝(B_type\A)∩S——只有「type 可见 ∧ 已装 ∧ 已声明」者才列 (s)；(c)＝A\(B_dir∪C) 的计算**完全不引用 S**，声明无从影响 phantom 判定；声明了但无 type 可见投影的名 → (d) stale-declaration WARN，不静默消失。

**负控 fixture 判别力：本席自建隔离 fixture 六景复跑（/tmp，已清）**——phantom-pack（登记有、投影源包皆无）→(c)；regonly（登记＋源包、type 不可见）→(r)；declared-one→(s) 且不入 (b)；undeclared-one（未声明同形态）→**(b)**（声明为承重件、非全局放行）；declared-ghost（已声明、无技能）→(d) stale WARN 而非列 (s)；**关键掩盖测试 phantom-declared（登记＋声明、双无）→仍入 (c)**——声明锚无法掩盖应入 (b)/(c) 的异常，判别力成立（较被审方四景多覆盖此二景）。

**活仓终值本席复跑**：(a)(b)(c)(r) 全空、(s) 恰声明 10 件、Set A 26／B_type 36／B_dir 26／C 26／S 10、exit 0。定案表（`g1-driftcheck-b11-dispositions.md`）11 件三查齐：活 11（补登记 1＋声明锚 10）、**死 0、注销 0**——ASM-4 的悬空引用证伪臂无对象（无任何件被移除）；消费查抽证：agent-computer-interface 在 AGENTS.md pack 指针表 L141 实存、hw-firmware 在 brain-index 在册；registry 补登记 diff 恰 +8 行／−0（本席 git diff 复算）；声明文件 10 名与 (s) 段逐件全等。
注记：以新设 (s) 段替代 HANDOFF 分支文字的「归 (r)」属已披露的语义对齐（(r) 定义要求 registry 在册，字面不可行），理由记定案表，非静默偏离。

## ③ 组 3 ASM-1／ASM-2＋隔离纪律 — 成立

- **ASM-1 基线身份由提交对象证明**：`git show HEAD:tad.sh | sha256sum`＝`1490a6abdc5842…`、3,523 行，与 Metadata 锚逐字全等——开工基线就是锚定版本，非自报。改后 sha `0b632137…` 与 COMPLETION 记行全等。
- **diff 恰在两区内**：`git diff HEAD -U0 -- tad.sh` 共 10 处 hunk，逐一落点——backup_existing 内 +7 行（R2 pre-tree 生成，≈L739 区）；L1699 注释改述＋verify_install_complete 调用点（R1 区）；`_tad_tree_equal` 相邻 +22 行（R1 探针定义，增补 S-5 明示扩入 R1 写集）；rollback_on_failure 消费区（R2，≈L2388–2410 区）。**两区外 hunk 数＝0**；`grep -n 'diff -rq' tad.sh` 恰余 1 行（L2239 既有头注，增补 S-3 除外款）——ASM-1/ASM-2 证伪信号均不出现。fixture 日志在盘：R1 五景＋R2 五景全 PASS；COMPLETION Reflexion 对两处自抓失败（r2-4 判别位置、AC12 计数自撞）的披露与最终日志形态相容。
- **隔离纪律零真实仓运行痕迹**：仓根无 `.tad.backup.*`／`.tad-migrate-backup.*` 产物、`$HOME/.tad-backups` 目录不存在——本链从未对真实仓运行 tad.sh（fixture 均在 /tmp 骨架，Provenance 在册）。

## ④ 组 5 ASM-5 — 成立

- **快照 diff 本席自跑为空**：`diff g5-porcelain-before.txt g5-porcelain-after.txt` 零差异（全量 diff 为空，强于判据的机制面过滤口径）；快照内仅 PM 面文件（docs/pm、票、handoffs 目录），机制面路径零出现。
- **期望集冻结时序成立**：期望集 sha256 本席复算＝`761de25878da94bd…` 与冻结记行全等；时点序由文件 mtime 与件内记录双证（题集/期望集 18:31Z → before 快照 18:32Z → 跑题留痕 18:34Z → 结果件 18:38Z，冻结在跑题之前）。
- 结果件诚实度抽核：逐题表反推四组数全等（命中 26/40＝principles 8/8＋patterns 14/24＋incidents 4/8；Recall@1 14/40；误报 3/5；压缩比 3,491/482,538＝0.0072、4,127/25,219＝0.1637 本席复算合）；patterns 文件级判分粒度与近似边界在结果件明示，未把近似值表述为真实召回率。

## ⑤ 组 7 零落地＋负证据纪律 — 成立

- **零落地（AC27 快照对照本席复跑）**：现行 `git status --porcelain -- .tad/hooks .agents/skills` 与 Step 2 出口基线快照 `g27-baseline-porcelain.txt` diff 为空（基线仅含组 1 的 driftcheck.sh 一行改动，Step 2 后该两面零新增）。
- **回填数字对盘复算全等**：traces 顶层条目 87（日期 jsonl 85＋test-fixtures 1＋per-handoff 目录 1）、全树 795,037 B、顶层 jsonl 3,307 行——本席逐项复算一致；设计步「88 件」错误由回填件自纠并给出计数口径定义。三级上限校准＝**维持设计值**（8 KB／5 MB／100 MB，未放宽），依据为实测 p95 313 B／最大 849 B，符合 ASM-6「校准不放宽超两倍」的约束面；停滞成因结论记「未定」＋已查面清单（写手在册、接线在册、通道迁移面），不冒充定论。
- **全链负证据纪律总览**：组 5 如实报误报率 60% 与 14 题未命中逐题名；组 2 以分段 BLOCK 收口不凑绿；组 1 的负控含「未声明仍入 (b)」；禁写面（brain-index、principles、`.tad/gates/`、version.txt）git status 零触碰、version.txt 仍 3.2.0 本席复核。

## ASM 逐条证伪面结论

| ASM | 结论 | 依据（本席复核点） |
|---|---|---|
| ASM-1 基线锚恒定＋两区 | 成立（未证伪） | HEAD 对象 sha＝锚；10 hunk 全在两区（含 S-5 扩区） |
| ASM-2 组 3 行为不变 | 成立 | fixture 十景日志在盘且全 PASS；两处自抓失败已披露并修正 |
| ASM-3 日期必有当次实测 | 成立 | 抽 3 条探针本机复现；刷新集＝证据集＝10；C 类日期逐字段未动 |
| ASM-4 注销不误伤 | 成立 | 注销集＝∅；声明锚掩盖面经六景 fixture 证伪测试不成立 |
| ASM-5 组 5 机制面零改动 | 成立 | before/after 快照全量 diff 空（本席自跑） |
| ASM-6 组 7 零落地＋设计有顶 | 成立 | 基线快照对照 diff 空；上限维持设计值、停写条款在设计文本 |

## Findings

- **P3-1（记录计数小疵）**：COMPLETION AC28 行记 `docs/pm/now.sync-conflict` 「两件」，盘面实为三件（…-142419／…-142522／…-143444）。三件均为 PM 面同步冲突件、非本链写集、本链零触碰与「不代合」的实质处置成立，仅自报计数差一；建议 PM 收口时顺手订正，不阻断本门。
- **P3-2（回填件字节口径差）**：`g7-capture-design-backfill.md` 记顶层 jsonl 合计 791,480 B，本席 `cat traces/*.jsonl` 实测 794,787 B，差 3,307 恰为行数（疑计字节口径不含换行）；文件数、行数、全树总量（795,037 B）逐值全等，且该数不承重于上限校准结论（校准依据为单行 p95／最大值），记录备查。

P0/P1/P2：无。

**Gate 3 SAFETY 路结论：PASS。**
