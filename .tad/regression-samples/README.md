# 命名回归样本集（Regression Samples）— 规矩正本

把真实失败例固化为可复跑评测：固定输入、判别标记、对照与运行记录分离。来源裁定：MQ-6 判断正本 §C1＋Epic EPIC-20261006 Phase 2 件 2.1；形态依据 notes-02 第 1 条「先手做 2–3 例样本验证形态，工具后选」。

## 样本格式

```
.tad/regression-samples/
  README.md            # 本文件（规矩正本）
  cases/<case>/
    input.md           # 固定输入全文（复刻件，文件头明示源事件指针）
    case.md            # 六要素正本
    control.md         # 冻结对照输出（样本创建时以裸 spawn 只给 input 捕获）
```

六要素在 case.md 的落法（runner `check` 逐项验）：①固定输入→`input.md` 全文，case.md 只引用；②允许工具→case.md「允许工具」行，逐案写死；③判分规则→case.md「判分规则」节＋文末机器可读评分块；④版本→frontmatter `sample_version` 与 `source_incident_date`；⑤轨迹→「原始轨迹」节（记录原文逐字摘录＋出处）与「期望轨迹」节；⑥证据路径→frontmatter `evidence_paths`。

机器可读评分块（case.md 文末 HTML 注释，runner 以 sed 提取，格式写死）：

```
<!-- replay-scoring
discriminative_pattern: '<grep -oE alternation，只含判别性标记>'
min_discriminative: 3
must_not_pattern: '<grep -oE alternation，命中任一即否决>'
control_max_hits: 1
-->
```

标记取材纪律：只收「无规程上下文的同等模型不会自发说出」的命名规则/阈值/结构词，不收领域通用词；每案判分规则节逐标记写明为何判别性。must_not 须为非空字面 pattern，取结论式断言形、避开否定嵌入。

## 评分与通过线

- hit 定义：`grep -oE` 字面命中；判别命中数＝distinct 命中数（去重计数）。
- 案 PASS ⇔ 判别命中 ≥ `min_discriminative`（=3；每案判别标记全集 ≥4 个）**且** must_not 命中数 = 0。
- 对照判别力：runner 复算 control 的判别命中，须 ≤ `control_max_hits`（=1）该案才算有判别力；control 命中 ≥2 → 该案标 **INVALID**（样本失效），整轮判读为 FAIL 并注明失效案——修样本（换更判别性的标记）后重跑，不许放宽通过线掩盖失效。
- 整轮 PASS ⇔ 3/3 案 PASS 且 0 案 INVALID。

## 复跑程序

一次复跑 = 建运行目录 `.tad/evidence/regression-runs/<YYYYMMDD>-<触发事由>/` → 对每案以正常激活形态 spawn 执行 input.md、输出落 `outputs/<case>.md` → 跑 `bash .tad/scripts/regression-replay.sh score <运行目录> [通道] [模型] [耗时]` → 产出/更新运行目录内 `scores.md`（逐案：判别命中数、must_not 命中、control 命中、PASS/FAIL；整轮 verdict；执行通道、模型、耗时、失败原因）。

runner 只做结构校验（`check`）与评分（`score`），不自带 spawn——通道无关是刻意边界，捕获方式由执行者所在通道决定并在 scores.md 记明。「复跑」的判读口径（PM 合并裁定 2026-10-06）：对**已捕获案卷**一条命令全量重评即复跑；新一轮捕获属执行者按所在通道的编排动作，不在样本集辖区。

## 增长规则

- 新失败案入册条件：已有关账链的复盘/根因件点名该失败形态；入册即补齐六要素与冻结 control。
- 通过线数值（min_discriminative=3、control_max_hits=1）改动须经 PM 裁断，并在本节留一行变更记录（日期＋裁断指针＋改动值）。
- 变更记录：（暂无）
