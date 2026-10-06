# PM 合并裁定 — Epic Phase 2 Gate 2（2026-10-06）

- 对象：HANDOFF-2026-10-06-epic-p2-measurement（76,370 B／sha256 `ff8eda17…`）
- fit 路 CONDITIONAL（正文 8,727 B／sha256 `4c86cadd…`）；tech 路 CONDITIONAL（正文 11,961 B／sha256 `5c160a94…`）
- **合并裁定：CONDITIONAL PASS**，下述四项增补销账后转 PASS。

## 设计内裁断 · PM 落定（两路均表态主案成立）

1. 件 2.0 陈旧行处置＝**追加 supersede 行**（备选「就地改 class」经 tech 路源码核验不成立：两件旧行均非 carried 类、只改 class 不翻 outcome 不入队）。
2. 件 2.9 在船断言＝**寄生 release-verify 机器面**（MANIFEST 算出后、早退 PASS 之前）；仅 prose 断言句是已失败一次的形态，不采。

## 增补条件（交原设计 Alex 定点修订 HANDOFF）

- **B1（源 fit C1）**：§4.1 增补对位段，点名与 Epic 判据字面「一条命令可全量复跑」的距离并写明解释口径：本样本集的「复跑」＝对已捕获案卷一条命令全量重评（runner 一条命令评全集），捕获编排（按通道 spawn）不在样本集辖区。此口径经本裁定确认，Gate 3/4 按此判读。
- **B2（源 tech P1-1）**：§4.0 步骤 3 理由句与 `supersedes` 字段按实盘真值更正——两件旧行真值为 stale-content/synced 与 no-carrier/synced，不存在 carried 行；惰性来源是 outcome≠pending。
- **B3（源 tech P1-2）**：增量集定义明文排除账本件本身（`execution-manifest.jsonl`、`branch-disposition.tsv` 不入增量集），AC1 集相等判据同步对齐。
- **B4（源 fit P2 两处）**：§9 首行「9 件」改「10 件」；§4.8 增补一句衔接——源侧去席名与 S8 C4 席位侧署名是两层：源模板不带名、席位侧本地件如何署名仍按 C4 既有口径，两不相干。

tech 路 P2 注记（must_not 字面化由 Gate 3 判读时验非空、MQ-1 约数表述、L360/361 标签差）为非条件，记 Gate 3 判读备忘。

## PM 定点核销账（2026-10-06）

增补完工说明（2,684 B）到盘；HANDOFF 修订后 78,569 B／sha256 `e680d83a…` PM 复算全等；B1 对位段（L199 起）、B2 真值重写（"carried-row" 残留 0）、B3 集定义与 AC1 对齐、B4 件数与两层衔接段（L281 起）逐项定位与裁定相符。**四项条件全销，Gate 2 转 PASS。**
