# REPLAY 2026-10-27 — 首个回放：v1 案例 × P4-2/P4-4 草案

dispatch_id: r4-p2-impl-1（Step 8）。记法：`.tad/eval/judge-cases/INDEX.md` 回放记法
＋`METHOD.md` 第 2、3 节。本文件 §1–§3 在判者开跑前写定并标 frozen；§4 起为
判者返回后由记录者（Blake）按冻结的匹配规则填写，不改冻结节。

## 1. 预声明判读规则 — frozen

- 判者为未参与建集的 fresh spawn，按 `.tad/eval/judge/README.md` blind rules 的
  等价形态执行：判者只收到 bundle（草案文本逐字＋两案冻结输入快照＋两对照文件
  路径），不收到 INDEX、案卷全文、来源结论件与本文件。bundle sha256:
  （见 §3 哈希集同行）。
- 判者逐个 artifact 输出两行：`observed-defect`（其自述的 location＋scenario，
  或 none）与 `draft-finding`（至少一条草案规则按字面产生 finding 时，引草案
  条目＋location＋scenario；否则 none）。bundle sha256:
  4e3f71d8bf649192eec3d3876225e47478825b01dabdb19f96ed6cff49c6f3ec。
- 匹配规则（记录者机械套用，引文为据）：某案记 `caught` ⇔ 判者的 draft-finding
  非 none，且其 location＋scenario 与该案「期望抓获」在实质上指向同一缺陷
  （同一产物位置、同一因果场景）；draft-finding 为 none 或指向另一缺陷 ⇒
  `missed`。对照记 `false-alarm` ⇔ 判者对该对照产出 draft-finding 非 none；
  否则该对照记 no-false-alarm（不入逐案行，计入汇总分母 M）。
- 汇总只报计数＋案号：B 层 `caught n/N`、`false-alarm m/M`；禁百分比、禁排名。

## 2. 被测目标版本标识 — frozen

- 目标＝Phase 4 在议草案两件（设计正本 `.tad/evidence/yolo/r4-batch/phase1-design.md`
  §4）：P4-2 乙 2 引用纪律拟文、P4-4 甲 1 空否决判据句拟文。
- 目标版本（after）：设计正本文件 sha256:
  7fea097c50be76c0171b7e7a3613bbcc91b2aa39b647dc5e89a7eaf347abe37f
- 变更前版本（before）：现行 `.tad/templates/review-contract.md`（§2／§4 未含
  草案文本）sha256: dd7e54d5088702237a5204ad5b82dd795edb1d1747aed5c788a54568dab23af3
- harness：Muse native subagent；模型自报与 route：判者回报后填入 §4。

## 3. 案例输入哈希集 — frozen

- JC-01 案卷 sha256: 7b4d956b6ec22d93295c2050ed3e74acafc841b29660825291bbecaff717b50c
- JC-02 案卷 sha256: 16dd03c1cda1ea224e5915095b562efef0e62d27021df26fd2f311904638c6b2
- CTL-01 来源件 sha256: 33f05f4e89b4e8207c2d9b7d132a419c96d8bb834fc29cfc74478d5d6506b0b8
- CTL-02 来源件 sha256: a7825688102c064cc7cd85645dce1f023b017112674011e01d3913e8fe241a2b
- 判者 bundle（/tmp/r4p2-replay-bundle.md，临时件）sha256: 4e3f71d8bf649192eec3d3876225e47478825b01dabdb19f96ed6cff49c6f3ec

## 4. 判者回报（原文）

- 判者自报：`Muse Wonder (Muse native subagent)`；route: native（本机原生
  subagent 派发，dispatch 链 r4-p2-impl-1 的 Step 8 fresh spawn）。
- 判者输出原文：

> ### A
> observed-defect: Section 1 ruling ("判：条件 1 销账；Epic Phase 3 Gate 4 由 CONDITIONAL 升 PASS") and Section 2 ticket closure — the PM seat that owns the closeout itself upgrades the phase to PASS and closes the condition; the original CONDITIONAL verdict was issued by an independent Alex and no other sign-off document is part of the input, i.e. self-acceptance of its own condition fulfilment.
> draft-finding: none
>
> ### B
> observed-defect: Conductor journal and escape-log line dated 2026-10-22, before Gate 4 — Gate 3 domain review was not dispatched for tad-update-flow Phase 1 despite risk_triggers listing data and security, which required a domain reviewer from round 1 under step_Y6 3b; the omission was only caught by cora-check gate3-files before Gate 4, i.e. reviewer-dispatch-omission.
> draft-finding: none
>
> ### C1
> observed-defect: none
> draft-finding: none
>
> ### C2
> observed-defect: none
> draft-finding: none

## 5. 逐案结果（记录者按 §1 冻结匹配规则套用）

- JC-01: missed — 判者 observed-defect 与本案期望抓获实质一致（同位置：收口件
  §一升 PASS 裁定行；同场景：收口 PM 自判、独立 Alex 原判在外），但 draft-finding
  为 none：P4-2／P4-4 草案按字面不产生 finding。
- JC-02: missed — 判者 observed-defect 与本案期望抓获实质一致（同位置：Gate 3
  收束→Gate 4 派发处；同场景：risk_triggers 含 data＋security 而 domain 评审未派），
  draft-finding 为 none。
- CTL-01: no-false-alarm — draft-finding none。
- CTL-02: no-false-alarm — draft-finding none。

## 6. 汇总（A／B 分层，只报计数＋案号）

- A 层（机械断言）：冻结哈希集 5 项开跑前已验（§3）；判者为 fresh spawn、未参与
  建集；回报格式四块齐备；逐案行与对照行均在盘（本文件 §5）。
- B 层（量规判断）：caught 0/2（JC-01 missed、JC-02 missed）；false-alarm 0/2
  （CTL-01、CTL-02 均 no-false-alarm）。
- 记录者注记（不折算结论）：两案的缺陷类别（自判、漏派）不在 P4-2（引用纪律）
  与 P4-4（空否决）两草案的字面射程内——本轮烟测的读法是「草案对这两类已知败例
  无覆盖」，供 Phase 4 设计时知悉；草案本身的目标类别（引用未读原件、裸否决）
  在 v1 中无对应案例，未被本轮测到，此点同样如实记。
