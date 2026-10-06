# Gate 4 终判 — 自查批 R2（TASK-20261006-SELF-REVIEW-R2）

- 评审者：Alex（Solution Lead，独立会话，未参与本链设计与实施）
- 日期：2026-10-06
- 对象：HANDOFF `.tad/active/handoffs/HANDOFF-2026-10-06-self-review-r2.md` ＋增补 SUPPLEMENT-1 × COMPLETION `.tad/evidence/completions/COMPLETION-2026-10-06-self-review-r2.md` × Gate 3 双审（`gate3-code.md`／`gate3-safety.md`，双 PASS）× 风险卡 `risk-TASK-20261006-SELF-REVIEW-R2.md`
- 判据：仓内 Gate Canonical Gate 4 清单（功能验收含 fail-close 复算条款／质量证据／subagent 问题清零／Knowledge Assessment）＋ `gate-execution.md` Regression Replay 节
- 方法：只读；全部承重值由本席从盘上重算（命令与结果见各节），不采信 COMPLETION 与 Gate 3 自述。

## 总判：CONDITIONAL

七组功能面全部终判 PASS（逐组见下，均为本席复算值）；Gate 3 双路 P0/P1/P2 为零、P3 全部有处置。唯一条件为一项程序性验证缺口（见「过门条件」）——它不推翻任何一组的实施结论，但按 Gate 4 fail-close 条款，未补前不得判无条件 PASS。

## 过门条件（唯一）

**回归复跑（Regression Replay）引用缺失，须补跑一轮后自动销账。**

- 依据：`gate-execution.md` Gate 3 节写死——被审 HANDOFF 写集命中 `.tad/templates/**`、`.tad/tasks/**` 等面时，Gate 3 评审须引用最近一次复跑的 scores.md（捕获须基于含被审改动的树）并逐案核对。本链写集命中模板四件（knowledge-writing-rules／handoff-a-to-b／session-state-template／dispatch-risk-card）与 `.tad/tasks/handoff-creation.md`，触发成立。
- 本席核查：Gate 3 双 verdict 中「regression」提及数＝0（grep 复算）；最近一次复跑 scores（`.tad/evidence/regression-runs/20261006-first-valid-baseline/scores.md`，整轮 PASS）落盘时点 2026-10-06 12:37Z，而本链模板改动落盘 18:55Z——该轮捕获树不含本链改动，不构成合格引用。即：此项 landing Verification Method 对本链缺失/未跑。
- 销账方式：PM 收口步按样本集 README 程序补跑一轮（洁净通道捕获、运行目录新建、runner 评分落 scores.md）；**整轮 PASS 即销账、无须重审**；整轮非 PASS 则升 PM 裁断，不得径行关链。
- 定性：此缺口记于评审面（Gate 3 漏引），不记于实施面——Blake 的 §9.1 义务不含复跑编排。

## Canonical 四项

1. **功能验收**：§9.1 AC1–AC28 经 Gate 3 双路逐行复核＋本席承重值重算（下节），全行成立（AC10/AC11 按设计内分段/挂起口径，见组 2）。除上述复跑条件外无 open 阻塞。
2. **质量证据**：code review＝Gate 3 CODE 件在盘；security review＝Gate 3 SAFETY 件在盘（本链含 tad.sh 代码面，双审齐备）；performance/UX 不适用。复跑缺口已记为过门条件，不在此重复计。
3. **Subagent 问题清零**：双路 P0/P1/P2＝0。P3 共 5 条处置：CODE P3-1（证据形态建议，后续链采纳）、CODE P3-3（自检段输出未单独落盘——harness 逐字抽取覆盖＋本席亲跑 `bash -n` 与两 harness 全绿，接受并记注）、SAFETY P3-1（COMPLETION 计数 2 vs 盘面 3，PM 收口订正）、SAFETY P3-2（traces 字节口径差 3,307＝行数，不承重）——均不阻断；CODE P3-2 即下方 ②，本席已裁。
4. **Knowledge Assessment**：COMPLETION 的 KA 节非空（三项发现且逐项记落点）、D35 usage log 行在册。成立。

## 逐组终判（本席复算值）

- **组 1（driftcheck (b) 11 件）PASS**：定案活 11（补登记 1＋声明锚 10）、死 0、注销 0。本席亲跑 driftcheck：(a)(b)(c)(r) 全空、(s) 恰 10 件（与声明文件逐件同名）、exit 0。
- **组 2（台账复核）PASS（分段终值口径）**：本席复算 `grep -c '| 2026-10-06 |' codex.md`＝10、`| 2026-08-03 |'`＝2（恰 C 类挂起两行、逐字段未动）；本机 `codex --version`＝0.149.0 与刷新行回填值一致。freshness 本席亲跑：PASS 10／WARN 1／BLOCK 1、exit 1——AC10 期望文「BLOCK 恰剩 C 类 2 条」为简写，真值按波动类分列 BLOCK（context_compaction）／WARN（trace_evidence_capture），两条非 PASS 恰为挂起的 C 类两条，无第三者。此读法与设计 §4.2 C 类口径及停步点 3 一致，成立；任何场合不得表述为 freshness 已清零。
- **组 3（tad.sh R1/R2/R3）PASS**：本席复算 tad.sh sha256＝`0b6321378d7ee1616542a917e3ec55e0f223b157805de85685852d8b6bad5ae9`（与 COMPLETION 改后锚全等）、3,587 行、`bash -n` 过；`grep -n 'diff -rq' tad.sh` 恰 1 行（L2239 既有头注，增补 S-3 除外款）；亲跑 fixture 收尾全 PASS、`tad-backup-test.sh` 15/15、`detect-state-test.sh` 12/12。R3 评估件四问齐、代码零改（双审 diff 审计在册）。
- **组 4（gc 预检双落点）PASS**：本席 grep 复算 handoff-creation.md 命中 1（含 `find .git/refs -type f`）、dispatch-risk-card.md 命中 1，与 §4.4 定稿逐字。本链不含 gc 执行，dogfood 以文本在位＋后续链引用义务为据——设计口径如此，接受。
- **组 5（召回基线）PASS**：四组数经双审机械重判＋本席抽核——Recall@3＝26/40（65%）、Recall@1＝14/40（35%）、无答案误报 3/5（60%）、压缩比 patterns 0.0072（本席复算分子 3,491 B；分母 482,538 为 Step 0 冻结锚，现盘差 +32 B 恰为 AC25 补标行）／principles 0.1637（分母 principles.md 25,219 B 本席复算全等）。期望集 sha256＝`761de258…1090` 本席复算全等、冻结时序（mtime 序）成立；before/after 快照本席亲跑 diff 为空。**读法钉死**：此四数是现行路由面的可复现近似（patterns/incidents 为文件级判分），不是 Agent 真实会话召回率；结果件的近似边界注记如实，本席终判只认其为「立项决策基线」用途。
- **组 6（Rule 6＋卸载记录）PASS**：本席读 knowledge-writing-rules.md 第 6 条原文——三值定义、未定级视同推断、引用同行标注、引用即补标、两种条目形态齐备，文件头计数已改 6；卸载记录三落点 grep 复算 1／1／2；dogfood 补标经 git diff 恰 +1 行（形态合 Rule 6），ac-verification.md diff 全件即此 1 行。
- **组 7（捕获回填）PASS**：本席 recount traces——顶层条目 87、日期命名 jsonl 85、全树 795,037 B、顶层 jsonl 3,307 行，与回填件逐值全等（设计步「88」已自纠且给出计数口径）；三级上限维持设计值未放宽；零落地经 g27 基线快照对照（本席亲跑 diff 为空）证实。

## ② driftcheck (s) advisory 类口径——追认

CODE P3-2 请求追认，本席**裁定追认 (s) 类为定案口径**，HANDOFF §4.1「使其归 (r)」的文字自本判起被本裁定取代。判据：(r) 的定义要求 registry 在册，skill-only 件按其形态本无源包、无 registry 条目，字面归 (r) 不可行，除非伪造 registry 条目——那是以造假登记换口径整齐，不取。(s) 的集合构造经双路独立 fixture 验证为保守方向：(b)＝B_type＼(A∪S) 仍捕获未声明件（负控成立）；(c) 的计算完全不引用 S，声明无从掩盖 phantom（SAFETY 路 phantom-declared 景实证仍入 (c)）；已声明但无投影者落 (d) WARN 不静默消失。口径诚实、判别力不减、异常面不缩。后续 driftcheck 文档与引用处应以 (s) 为 skill-only 的正式类名。

## ③ 开放票 TASK-20260916-CODEX-LEDGER-REVERIFY——保留待补测，不关票

对回该票 Done criteria 原文逐条判读：

- 「6 BLOCK 清零（真实重验后刷新），`runtime-freshness-verify.sh` 对当日日期 `exit 0`」——**未达**：本席亲跑 freshness 为 BLOCK 1／WARN 1、exit 1；12 条中 2 条（context_compaction、trace_evidence_capture）last_verified 仍为 2026-08-03、未经真实重验。
- 「Gate 4 验收该单时 waiver 自动失效（AC21 回归 PASS）」——该验收以该单 Done criteria 达成为前提，前提未成，waiver 不失效、不触发。

关票的两条捷径均被票面自带纪律堵死：空 bump 日期为票面明禁；以本批「分段终值」顶替 exit 0 则无票面依据（分段口径是 R2 批内的判读口径，不修订该票 Done criteria）。**建议（归 PM 执行）**：票保持 OPEN，范围收窄为 C 类 2 条；在厂商配额恢复时点（挂起证据所记原文：Oct 10th, 2026 2:24 PM）之后以鉴权 Codex 会话补测两条，两条真实重验且当日 freshness exit 0 时，PM 按该票自身 Gate 4 验收关票、waiver 随之失效。本批已刷新的 10 条无须重做。

## ④ 残项总清点（逐项有着落）

1. 组 2 C 类补测 → 开放票 TASK-20260916（范围已收窄，触发日 2026-10-10），见 ③。
2. 借 4（原文索引结构）决策点 → 组 5 基线已落，决策输入齐备：弱面在 patterns 条目级不可达（14/24）与 incidents（4/8），指向索引粒度而非必然指向三层重构；立项与否归 PM 于下一自查批 intake 判断，本链不欠。
3. traces 停滞成因 → 回填结论「未定」＋已查面清单在册；后续载体为 HANDOFF §4.7 的 Codex 一轨试点建议（30 天观察窗），PM 若立项，其第一步须在 Codex 轨上回答停滞断点；未立项期间 traces 停滞为已记录的接受状态，非静默缺口。
4. R3（`.tad-migrate-backup.*` 治理）→ 评估件建议另立票，归 PM 立项。
5. 回归复跑条件 → 本 verdict 过门条件，PM 收口步执行、整轮 PASS 自动销账。
6. COMPLETION AC28 行计数订正（sync-conflict 2→3）→ PM 收口顺手订正（SAFETY P3-1）。
7. 组 5 索引改进候选（patterns 条目级索引、incidents 关键词补强）→ 与第 2 项同一次 PM 决策，不单独立项。

## gate4_delta

- 对实施面：无——本席重算的全部承重值与盘面一致，无自报不符条目。
- 对评审面：Gate 3 双路漏引 Regression Replay（见过门条件），记一笔；不影响双路对其余判据的复核效力。

human CHECK 记「CHECK 待人」。

（纪律注记：本席按本步只读纪律未更新 session-state，链收口回写归 PM 收口点。）
