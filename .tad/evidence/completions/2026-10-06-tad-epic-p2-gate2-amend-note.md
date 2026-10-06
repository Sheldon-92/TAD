# 增补完工说明 — Epic Phase 2 HANDOFF Gate 2 条件增补（Alex，2026-10-06）

- 对象：`.tad/active/handoffs/HANDOFF-2026-10-06-epic-p2-measurement.md`
- 判据：PM 合并裁定 `.tad/evidence/pm/2026-10-06-epic-p2-gate2-merged-ruling.md`（条件 B1–B4）
- 开工对锚：76,370 B／sha256 `ff8eda17a1131e339b04e6cb59afc00f575d8e4472e6ad13ec631933a40b071a`（复算全等）
- **修订后锚：78,569 B／sha256 `e680d83ad8d22d9ee08eb3cfc8bbdf044428c0861f4d8bc1733d78736554de2d`**

## 逐项定位

- **B1（§4.1 对位段）**：§4.1「复跑程序」段后、「Gate 3 挂载」段前新增一段「与 Epic 判据字面的对位（PM 合并裁定 2026-10-06 确认口径）」（修订后 L199 起）。按裁定原文落三点：复跑＝对已捕获案卷一条命令全量重评（`regression-replay.sh score <运行目录>`）；捕获编排（按通道 spawn）不在样本集辖区；点名与 Epic 字面「一条命令可全量复跑」的距离，Gate 3/4 按此口径判读。
- **B2（§4.0 步骤 3 真值更正）**：步骤 3 整段按实盘真值重写——两件旧行真值 (stale-content, synced) 与 (no-carrier, synced)，明示不存在 carried 类旧行；`supersedes` 字段改逐件按被代旧行实际标识填（`"stale-content/synced"`／`"no-carrier/synced"`）；理由句更正为惰性源于 outcome≠pending（两旧行 class 恰在队列类集内）；备选句更正为「就地改写须连 outcome 一并改＝改账非记账」。§9.2（L410 一带）「就地改 carried 行 class」同步更正为「就地改写旧行」。全件 `"carried-row"` 残留＝0；§2 MQ-3 的类别×outcome 全量计数为真实统计，未动。
- **B3（增量集排除账本件）**：§4.0 步骤 1 的集 A 定义明文再剔账本两件（`execution-manifest.jsonl`、`branch-disposition.tsv` 永不入增量集，附先例与自陈旧机理两句理由），与步骤 6 的残余预期对齐；AC1 判据同步改为「增补行 path 集与增量集逐件相等（增量集＝A−B，A 已明文剔除账本两件，账本两件不出现在增补行中）」。
- **B4（两处）**：§9 首行「9 件全落」→「10 件全落」；§4.8 改法段后新增「两层衔接（注记）」段（修订后 L281 起）：源侧去席名只管发布源模板不带具体席名，席位侧本地件署名仍按 S8 C4 既有口径，两层互不相干。

## 纪律自报

只写上述 HANDOFF 一件与本说明一件；仓外零写、git 只读/零写。改动均为定点文本修订，未动机制、写集与 AC 编号体系（§9.1 仍为 AC1–AC30 共 30 行，复核计数全等）。四项条件可供 PM 定点核销账。
