# HANDOFF SUPPLEMENT-1 — HANDOFF-2026-10-06-self-review-r3 增补

- 增补对象：`/home/hatch/workspace/yun-sync/TAD/.tad/active/handoffs/HANDOFF-2026-10-06-self-review-r3.md`（正本，本增补不直接改动正本；实施以「正本＋本增补」合并形态为准，冲突处以本增补为准，限于下列点名行/段）
- 依据：PM 合并裁定 `.tad/evidence/pm/2026-10-06-r3-gate2-merged-ruling.md`（条件 C1/C2 核销＋F-T3 升为 PM 指令）；Gate 2 tech 评审 `.tad/evidence/reviews/self-review-r3-20261006/gate2-tech.md`（F-T1/F-T2/F-T3）；fit 评审同目录 `gate2-fit.md`（PASS）
- 性质：Gate 2 增补。办三项：C1（F-T1）AC 命令改形＋dry-run 证据、C2（F-T2）§4.1.3 聚合句、F-T3「受治锚缺失」分支升格落字
- 日期：2026-10-06（dry-run 均于本日实跑）

## 应用清单（Blake/PM 落字时逐项对）

| # | 落点 | 动作 |
|---|---|---|
| S1-a | §9.1 表 AC-G2-1 行（正本 L905） | Verification Method 单元格内第二个 grep 模式改形——整行改后逐字文本见 §S1.1 |
| S1-b | §9.1 表 AC-G2-5 行（正本 L909） | 计数模式改形——整行改后逐字文本见 §S1.2 |
| S1-c | §9.1 表 AC-G3-3 行（正本 L912） | Expected 单元格内复核提示规范化——整行改后逐字文本见 §S1.3 |
| S2 | §4.1.3 判读分支表末行之后 | 新增一段正文（聚合粒度）——逐字稿见 §S2 |
| S3-a | §6 Phase 2 交付物清单＋实施步骤 | 新增交付物一行＋实施步骤第 5 步——逐字稿见 §S3.1 |
| S3-b | §8.3 第一条 bullet | 整条替换——改后逐字文本见 §S3.2 |
| S3-c | §9.1 表末（AC-X-2 行之后、§9.2 之前） | 新增注记 blockquote 一行（不新增 AC 编号）——逐字稿见 §S3.3 |

---

## S1 · C1（tech F-T1）：两行模式改形＋一处提示规范化

改法规格照评审件：行首位置用括号类 `^[|]` 断言字面管道符，组内 alternation 用裸 `|`。改后模式**不含任何 `\|`**，故 §9.1 表首注的「抽出执行时还原 `\|`→`|`」规则对该模式是空操作——字面读法与还原读法给出同一命令、同一计数（§S1.4 dry-run 实证）。落盘注意：改后模式在表格单元格内以源文件原始字节存（反引号内 `|` 不转义）；抽取执行以源文件字节为准。

### S1.1 AC-G2-1 行改后逐字文本（整行替换正本 L905）

| AC-G2-1 | 子集两件与 R2 源逐字派生（无题面改写） | post-impl-verifiable | `grep -E '^- Q(3[3-9]\|4[0-5])：' .tad/evidence/self-review-r2-20261006/g5-recall-question-set.md \| cmp - .tad/evidence/self-review-r3-20261006/g2-borrow4-trial/questions-subset-13.md; grep -E '^[|] Q(3[3-9]|4[0-5]) ' .tad/evidence/self-review-r2-20261006/g5-recall-expected-set.md \| cmp - .tad/evidence/self-review-r3-20261006/g2-borrow4-trial/expected-subset-13.md` | 两 cmp 均无输出（逐字相同）；子集文件不含题面以外的添加行 | (post-impl) |

变更点仅一处：第二个 grep 的模式由 `^\| Q(3[3-9]\|4[0-5]) ` 改为 `^[|] Q(3[3-9]|4[0-5]) `。第一个 cmp 与单元格分隔的 `\|`（命令管道）维持原样——前者在表首注还原规则下实测得 13（§S1.4），后者是 markdown 转义的命令管道符、还原后即 shell 管道，均无恙。

### S1.2 AC-G2-5 行改后逐字文本（整行替换正本 L909）

| AC-G2-5 | 实验报告齐备且判读机械套用 §4.2.4 | post-impl-verifiable | path-check `.tad/evidence/self-review-r3-20261006/g2-borrow4-trial/experiment-report.md`；`grep -cE '^[|] Q(3[3-9]|4[0-5]) ' <该文件>` | 逐题行 13；含三项指标行与判读行（建议立项／关闭记因／INVALID 三选一且与数值自洽，Gate 4 复算） | (post-impl) |

变更点仅一处：计数模式由 `^\| Q(3[3-9]\|4[0-5]) ` 改为 `^[|] Q(3[3-9]|4[0-5]) `。

### S1.3 AC-G3-3 行改后逐字文本（整行替换正本 L912；F-T1 条件汇总的同轮规范化项）

| AC-G3-3 | freshness 双分支增量断言（钉死日期复算） | post-impl-verifiable | `bash .tad/hooks/lib/runtime-freshness-verify.sh . 2026-10-06` | exit 1（残差所致，非本批）；汇总行 `Total: 31 entries \| PASS: 29 \| WARN: 1 \| BLOCK: 1`；且 `BLOCK`/`WARN` 输出行中含 `[opencode]`/`[cursor]` 者为 0 条（以 `grep -E '^(BLOCK|WARN)'` 管道复核） | (post-impl) |

变更点仅一处：Expected 单元格内复核提示由 `grep -E '^(BLOCK\|WARN)'` 改为 `grep -E '^(BLOCK|WARN)'`。原形在字面读法下 `\|` 被 grep -E 解作字面管道符、对真实输出零命中（§S1.4 实证），会使「含 [opencode]/[cursor] 者为 0 条」成为空转断言；改后形不含 `\|`，两读法同果。

### S1.4 dry-run 证据（2026-10-06，仓根执行；命令与输出原样）

源文件：`.tad/evidence/self-review-r2-20261006/g5-recall-question-set.md`（54 行）、`.tad/evidence/self-review-r2-20261006/g5-recall-expected-set.md`（52 行）。

```
$ grep -E '^\| Q(3[3-9]\|4[0-5]) ' .tad/evidence/self-review-r2-20261006/g5-recall-expected-set.md | wc -l
0
$ grep -E '^| Q(3[3-9]|4[0-5]) ' .tad/evidence/self-review-r2-20261006/g5-recall-expected-set.md | wc -l
52
$ grep -E '^[|] Q(3[3-9]|4[0-5]) ' .tad/evidence/self-review-r2-20261006/g5-recall-expected-set.md | wc -l
13
$ grep -cE '^[|] Q(3[3-9]|4[0-5]) ' .tad/evidence/self-review-r2-20261006/g5-recall-expected-set.md
13
$ zsh -c "grep -cE '^[|] Q(3[3-9]|4[0-5]) ' .tad/evidence/self-review-r2-20261006/g5-recall-expected-set.md"
13
$ grep -E '^- Q(3[3-9]\|4[0-5])：' .tad/evidence/self-review-r2-20261006/g5-recall-question-set.md | wc -l
0
$ grep -E '^- Q(3[3-9]|4[0-5])：' .tad/evidence/self-review-r2-20261006/g5-recall-question-set.md | wc -l
13
```

旧形两读法 0／52 与评审 F-T1 实测逐值相同（证伪复现）；改后括号类形在期望集得 **13**（`grep -cE` 形态同为 13、zsh 下复跑同为 13），AC-G2-1 第一个 cmp 的还原读法得 **13**（该行不改的依据）。

改后 AC-G2-1 整命令形态代跑（子集以改后命令自身抽取充当，验证命令形态可执行、cmp 语义成立）：

```
$ grep -E '^- Q(3[3-9]|4[0-5])：' .tad/evidence/self-review-r2-20261006/g5-recall-question-set.md | cmp - <抽取产物 questions-subset-13.md>
（无输出）cmp exit=0
$ grep -E '^[|] Q(3[3-9]|4[0-5]) ' .tad/evidence/self-review-r2-20261006/g5-recall-expected-set.md | cmp - <抽取产物 expected-subset-13.md>
（无输出）cmp exit=0
$ wc -l questions-subset-13.md expected-subset-13.md
13 / 13
```

S1.3 规范化代跑（对当日活仓 freshness 输出，即 §9.1 P-3 基线输出，Total 12）：

```
$ bash .tad/hooks/lib/runtime-freshness-verify.sh . 2026-10-06        # exit 1（基线残差）
$ grep -cE '^(BLOCK\|WARN)' <freshness 输出>
0
$ grep -E '^(BLOCK|WARN)' <freshness 输出>
BLOCK [codex] context_compaction: high-volatility stale (64 days > 30)
BLOCK [codex] context_compaction: next_review overdue (2026-09-02 < 2026-10-06, high-volatility)
WARN  [codex] trace_evidence_capture: medium-volatility stale (64 days > 60)
WARN  [codex] trace_evidence_capture: next_review overdue (2026-09-02 < 2026-10-06)
$ grep -E '^(BLOCK|WARN)' <freshness 输出> | grep -c '\[opencode\]\|\[cursor\]'
0
```

原提示形零命中（复核空转）证伪复现；改后形命中全部 4 条 BLOCK/WARN 行、其中含 `[opencode]`/`[cursor]` 者 0 条——与 AC-G3-3 期望形态一致（post-impl 时总量断言 Total 31 另由主命令核，本代跑只验提示命令本身）。

---

## S2 · C2（tech F-T2）：§4.1.3 增补聚合句

**落点**：§4.1.3「判读分支」表末行（「登记豁免串在块中不存在」行）之后、`#### 4.1.4` 标题之前，新增一段正文。

**逐字稿**：

> **聚合粒度（承重）**：check8 对每一配对至多调用一次 `fail()`；豁免遮蔽后多个旧文模式同时命中时聚合为一条 FAIL，文案并列全部命中的模式字面与配对号。逐模式分别调用 `fail()` 的实现不符合本节语义——与 AC-G1-2「FAIL 行恰 1 条」对齐（neg 树事故原文三模式全中，聚合后仍恰一条）。

---

## S3 · F-T3 落字：「受治锚缺失」分支升为实施 Phase 2 必跑一次

### S3.1 §6 Phase 2 两处

（a）交付物清单在现有第二项（`g1-fixtures/` 五树…）之后新增一行，逐字稿：

> - [] `g1-fixture-anchor-missing.log`（受治锚缺失分支必跑一次的命令与输出，见实施步骤 5；临时树跑毕删除、日志留存）

（b）实施步骤在现有第 4 步之后新增第 5 步，逐字稿：

> 5. **受治锚缺失分支必跑一次**（SUPPLEMENT-1 升格，原 §8.3「可选临时树」作废）：自 neg 树 `cp -R` 派生临时树 `.tad/evidence/self-review-r3-20261006/g1-fixtures/anchor-missing/`，删去其 `AGENTS.md` 中以 `> **Runtime status` 起首的锚点行整行，以 runner 同法实跑 `bash .tad/hooks/lib/state-surface-check.sh --repo <临时树绝对路径>`；期望退出 1 且 FAIL check8 文案含字面 `governed surface anchor missing`。命令与输出全量落 `g1-fixture-anchor-missing.log` 并记入 COMPLETION；临时树跑毕删除，不进固定五树、不计入 AC-G1-2..6。

### S3.2 §8.3 第一条 bullet 整条替换，改后逐字文本

> - check8 抽取锚被改名/删除 → 不可判分支必须红（undecidable 树覆盖事实源锚缺失一半；受治锚缺失分支已升格为实施 Phase 2 必跑一次——§6 Phase 2 步骤 5 的临时树实跑，输出记入 COMPLETION，Gate 3 据 `g1-fixture-anchor-missing.log` 核对；不进固定五树）。

### S3.3 §9.1 AC 侧注记行（不新增编号）

**落点**：§9.1 表末行（AC-X-2 行）之后、`## 9.2` 标题之前，新增 blockquote 一段，逐字稿：

> > **注记（SUPPLEMENT-1 / F-T3）**：受治锚缺失分支（check8 `governed surface anchor missing`）不设独立 AC 编号——验证载体为 §6 Phase 2 步骤 5 的必跑临时树与 `g1-fixture-anchor-missing.log`（退出 1＋文案含该字面）；Gate 3 评审 AC-G1-* 时一并核对该日志。

---

## 与正本的关系

- 本增补只点名上列 7 个落点；正本其余文本、判据数值与范围一字不动。
- tech 评审转 PASS 的另一手续——回填正本 §9.2 Audit Trail——由 PM 核销时办理，不在本增补落字范围。
- fit F-3（COMPLETION 回填 runner 汇总退出码）属实施步要求，与本增补无涉，照 PM 裁定第 5 条在实施步执行。
