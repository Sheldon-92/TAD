dispatch_id: r4-p4-impl-2

# REPLAY 2026-10-27 — 第二轮回放：v1 案例 × P4-2/P4-4 落盘文本

记法：`.tad/eval/judge-cases/INDEX.md` 回放记法＋`METHOD.md` 第 2、3 节。
冻结正本：`.tad/evidence/yolo/r4-batch/phase4-replay-freeze.md`（Step 7a 落盘，
dispatch_id: r4-p4-impl-1；冻结时刻 2026-10-28T01:19:05Z）。conductor 核验行：
`.tad/evidence/journal/conductor-r4-batch-2026-10-27.md`（2026-10-28T01:21:03Z，
bundle sha256 独立复算与冻结记录、实施回报抄录三方逐字一致）后另派本步（Step 7b）。
本文件 §1–§3 为冻结三件，逐字以冻结记录所载为准；§4 起为判者返回后由记录者
（Blake，dispatch r4-p4-impl-2）按冻结的匹配规则填写，不改冻结节。

- bundle 本体：`.tad/eval/judge-cases/replays/BUNDLE-2026-10-27-p4-landed.md`
- bundle sha256：`1d87597cde8738549fe8e235737d8e87268c3573bede0e45ecb0631d95b2e984`
  （本步开跑前记录者复算，与冻结记录所记逐字一致，未触发 H1）
- 隔离如实标注：判者隔离＝prompt 层：判者为同机同文件系统的 fresh subagent，仅以派发指令限定其输入为 bundle 本体；非文件系统级隔离、非技术强制。

## 1. 判读规则 — frozen（逐字引冻结记录「冻结件 1」）

- 判者为未参与建集与本 phase 实施的 fresh spawn，按 blind 形态执行：判者只收到 bundle 本体（落盘 §2/§4 文本逐字＋两案冻结输入快照＋两对照文件路径），不收到 INDEX、案卷全文、来源结论件、本冻结记录与 REPLAY 文件。
- 判者逐个 artifact 输出两行：`observed-defect`（其自述的 location＋scenario，或 none）与 `landed-finding`（至少一条落盘规则按字面产生 finding 时，引落盘条目＋location＋scenario；否则 none）。
- 匹配规则（记录者机械套用，引文为据）：某案记 `caught` ⇔ 判者的 landed-finding 非 none，且其 location＋scenario 与该案「期望抓获」在实质上指向同一缺陷（同一产物位置、同一因果场景）；landed-finding 为 none 或指向另一缺陷 ⇒ `missed`。对照记 `false-alarm` ⇔ 判者对该对照产出 landed-finding 非 none；否则该对照记 no-false-alarm（不入逐案行，计入汇总分母 M）。
- 汇总只报计数＋案号：B 层 `caught n/N`、`false-alarm m/M`；A/B 分层按 METHOD.md 第 3 节；禁百分比、禁排名。
- 判者产出畸形补救：逐 artifact 两行格式不齐（缺行、spawn 失败）时，记录者以同一 bundle、同一冻结重派判者至多一次，失败产出原文入 REPLAY 附记；第二次仍畸形，本轮记 `failed run`（只记事实与失败原文、不报计数），停步上报。

## 2. 案例输入哈希集 — frozen（逐字引冻结记录「冻结件 2」）

- JC-01 案卷 sha256: `7b4d956b6ec22d93295c2050ed3e74acafc841b29660825291bbecaff717b50c`
- JC-02 案卷 sha256: `16dd03c1cda1ea224e5915095b562efef0e62d27021df26fd2f311904638c6b2`
- CTL-01 来源件 sha256: `33f05f4e89b4e8207c2d9b7d132a419c96d8bb834fc29cfc74478d5d6506b0b8`
- CTL-02 来源件 sha256: `a7825688102c064cc7cd85645dce1f023b017112674011e01d3913e8fe241a2b`

四件经本步记录者复算与冻结集逐项全等（`recomputed`，见 COMPLETION Claims vs Records）。

## 3. 目标版本标识 — frozen（逐字引冻结记录「冻结件 3」）

- 被测目标：P4-2 乙 2 引用纪律与 P4-4 甲 1 空否决的落盘文本（`.tad/templates/review-contract.md` §2／§4，实施后版本）。
- before（实施前现行版，Step 0 基线）：`.tad/templates/review-contract.md` sha256: `dd7e54d5088702237a5204ad5b82dd795edb1d1747aed5c788a54568dab23af3`
- after（实施后落盘版，7a 复算）：`.tad/templates/review-contract.md` sha256: `183df8b3c8e50fe221cfc2b89f648d6ebe220c035dcde99d5f9ee5528775d8e5`
- 更正注记（Step 7a 内、冻结检查点停步前，同段留痕）：after 初算值曾为 `db7d9882…`，系 C8 抽查句以「同行尾随」形态落盘时的中间值；该句随即按 AC16 行集守卫口径（additions-only 子序列）改以「续行」形态重落——句文本与 §5 内位置不变，§2/§4 一字未动，bundle 内 §2/§4 与最终文件逐字复核为 True、bundle sha256 不变。after 以本行最终落盘值为准。
- 草案版（首轮回放所测，设计正本）：`.tad/evidence/yolo/r4-batch/phase1-design.md` sha256: `7fea097c50be76c0171b7e7a3613bbcc91b2aa39b647dc5e89a7eaf347abe37f`

本步记录者复算：现行 review-contract.md sha256 与 after 值逐字全等（`recomputed`）。

## 4. 判者回报（原文）

- 判者：fresh subagent spawn（记录者本派发内 spawn，未参与建集与本 phase 实施）；
  route: Muse native subagent。判者回报完成于 2026-10-28T01:26:17Z，晚于冻结时刻
  （01:19:05Z）与 conductor 核验行（01:21:03Z）。回报格式四块齐备、逐 artifact
  两行齐，未触发畸形补救。
- 判者输出原文：

> ### Artifact A
> observed-defect: §一 step3f bullet of the ruling — scenario: the rerun evidence cited for clearing Gate 4 condition 1 shows the write-time hook did not trigger under default trust and interactive trust review was not tested, yet the ruling reclassifies both as out of scope and upgrades Phase 3 Gate 4 to PASS
> landed-finding: none
>
> ### Artifact B
> observed-defect: conductor journal lines 1–2 and the 2026-10-22 escape-log row — scenario: risk_triggers listed data+security, so a Gate 3 domain reviewer was required from round 1 (step_Y6 3b), but no domain review was dispatched and Gate 4 (p1-y7-1) was already listed before the gate3-files pre-check caught the missing phase1-impl-review-domain.md
> landed-finding: none
>
> ### Artifact C1
> observed-defect: P0-1 and the appendix P1-3–P1-7 in phase2-gate2-review-risk.md — scenario: the Gate 2 P0-1 carries class but no repeat_of field, and P1-3–P1-7 are recorded only as summary transcriptions (要旨/旁证) without location, scenario, blocks, checked or kind, while the header counts 1 P0 and 7 P1
> landed-finding: §2 "A finding" — Gate 2 P0s also carry `repeat_of:` (else empty) and each P0 and P1 carries location, scenario, blocks, checked and kind: P0-1 in phase2-gate2-review-risk.md lacks repeat_of, and appendix P1-3–P1-7 lack the required finding fields as recorded in the file
>
> ### Artifact C2
> observed-defect: none
> landed-finding: none

## 5. 逐案结果（记录者按 §1 冻结匹配规则机械套用）

- JC-01: missed — 判者 landed-finding 为 none，按冻结规则记 missed。判者
  observed-defect 指向该裁定 §一 step3f 证据处置面（两保留点被裁定重分类为
  非条件未竟项、同件升 PASS），与本案期望抓获同属该收口裁定件；但 caught 的
  判据是 landed-finding 非 none 且同指，本案不成立。
- JC-02: missed — 判者 observed-defect 与本案期望抓获实质一致（同位置：
  conductor 台账与 escape-log 2026-10-22 行；同场景：risk_triggers 含
  data＋security、domain 评审按 step_Y6 3b 应自 round 1 派而未派、Gate 4 前
  才被 gate3-files 查出），但 landed-finding 为 none：落盘 §2/§4 按字面
  不产生 finding。
- CTL-01: false-alarm — 判者对该对照产出 landed-finding 非 none（引落盘 §2
  「A finding」的 `repeat_of:` 与逐 finding 字段要求，指向对照来源件
  phase2-gate2-review-risk.md 的 P0-1 与附记 P1-3–P1-7 的记录形态），按
  冻结规则记 false-alarm。
- CTL-02: no-false-alarm — landed-finding none，observed-defect none。

## 6. 汇总（A／B 分层，只报计数＋案号）

- A 层（机械断言）：bundle 本体 sha256 本步开跑前复算＝冻结记录所记＝conductor
  journal 核验行所记，三方一致；冻结输入四件 sha256 复算与冻结集全等；
  review-contract 现行 sha256 与冻结 after 值全等；冻结时刻（01:19:05Z）与
  conductor 核验（01:21:03Z）均早于判者开跑；判者为 fresh spawn、只收到
  bundle 本体；回报四块齐备、逐 artifact 两行齐（本文件 §4）。
- B 层（量规判断）：caught 0/2（JC-01 missed、JC-02 missed）；false-alarm 1/2
  （CTL-01 false-alarm、CTL-02 no-false-alarm）。
- 诚实注记一（射程外，逐字承冻结记录「判读口径注记」）：两案缺陷类别
  （`self-acceptance`、`reviewer-dispatch-omission`）不在 P4-2/P4-4 字面射程内
  （首轮 REPLAY 注记已明），本轮 caught 0/2 读作「落盘文本对两类已知败例
  无覆盖」，与首轮（caught 0/2）并列即回归结论的全部。
- 诚实注记二（未测类别）：两落盘文本的目标类别（引用未读原件、裸否决）在 v1
  无对应案例、本轮同样未被测到，如实记明。
- 记录者事实注记（不改判读）：本轮 false-alarm 1/2 与首轮 0/2 不同——判者对
  CTL-01 的 landed-finding 依据是落盘 §2 的逐 finding 字段要求（含 Gate 2 P0
  的 `repeat_of:`），该字段要求文本是本轮被测的落盘版新增面；对照来源件的
  记录形态（附记转录行）按其字面被判不合。此为按冻结规则机械套用的结果，
  原样记录，其判读含义留 Gate 4 与考题集 v2 开集时处置，记录者不临场改读。
