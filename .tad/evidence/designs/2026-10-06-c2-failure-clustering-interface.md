# C2 失败聚类接口定义＋顺延决议（Epic P2 件 2.7 — 只出接口与决议，不落实现）

设计输入：MQ-6 判断正本 §C2（`.tad/evidence/pm/2026-10-06-tad-sweep-proposal-judgment.md`）＋notes-02 第 2 条（失败聚类为样本集复跑的第二阶段）。本表即件 2.5 标签集 failure-class 的值域（`.tad/evidence/designs/2026-10-06-trajectory-scoring-interface.md` 第 2 节占位引用本表）。

## 一、输入接口

数据源＝件 2.1 复跑记录（`.tad/evidence/regression-runs/<运行目录>/scores.md` 与 outputs）。逐字段引用 scores.md 的既有字段名，不另立字段名：

| 输入字段 | scores.md 中的形态 | 聚类侧用法 |
|---|---|---|
| `case` | 逐案评分行首字段 | 趋势行与归类的最小单位键 |
| `verdict` | 逐案 verdict（PASS/FAIL/INVALID） | 案级结果计数 |
| 判别标记命中数 | `discriminative_hits` | FC-3 判读信号之一 |
| `must_not` 命中 | `must_not_hits` | FC-1/FC-2 判读信号 |
| 失败原因 | scores.md 附注节 | 归类主依据 |
| 执行通道/模型 | scores.md 头部「执行通道」「模型」列 | 趋势行 channel/model 字段 |
| 耗时 | scores.md 头部「耗时」列 | 趋势分析备用，不入趋势行 |

聚类侧只读不写复跑面：不读改 scores、不重跑样本、不改案级 verdict；输入缺字段的记录只许登记为不可归类并注明缺项。

## 二、失败分类表 v0（FC-1–FC-4）

| 类 | 定义 | 一例 |
|---|---|---|
| FC-1 判据缺陷 | AC/判分规则本身错或不可照行——被测行为没错，错在判据 | 判分 pattern 与规程原文矛盾，照判据答对反而被判 FAIL |
| FC-2 执行缺陷 | 被测行为偏离规程——判据无误，行为错 | 回答给出共用固定路径捕获命令（案二 must_not 形态） |
| FC-3 样本失效 | 样本无判别力，含 control 命中超线——测不出差异，与被测行为无关 | control 的判别命中 > control_max_hits，该案标 INVALID |
| FC-4 环境缺陷 | 通道/工具/同步面故障致测不出——运行未真正发生 | 捕获通道 stall 超时，复跑产不出回答 |

一案可同入多类；分类只贴标签与计数，不改案级 verdict。

## 三、趋势行格式

一行一复跑一案，字段序写死：

```
date | tad_version | channel | model | case | verdict | fail_class(无失败填 -) | run_dir
```

载体落点预定 `.tad/evidence/regression-runs/TREND.md`（append-only），**达激活阈才建**——本链不建此文件。

## 四、激活判读框架与本链决议

- **激活条件（写死）**：累积已评分复跑数 ≥6 **或** 累积案级 FAIL 数 ≥4，先到者触发全量聚类实现（含趋势载体建置与逐跑归类）的立项评估；未达阈期间，复跑记录只归档、不归类。
- **当期实数**：累积已评分复跑数 ＝ **1**（件 2.1 首跑，`.tad/evidence/regression-runs/20261006-first-run/scores.md`）；累积案级 FAIL 数 ＝ **3**（首跑三案 verdict 均非 PASS——均为 INVALID，归因 FC-3 样本失效面（对照捕获通道污染）兼 FC-4 环境面，详见首跑 scores.md 附注；距 FAIL 阈值差 1，但三案上限决定单轮不可能以 FAIL 路径触发，复跑数路径为唯一现实触发）。
- **决议：顺延。** 两项均未达阈（1 < 6；3 < 4）；单轮数据无聚类与趋势可言，强行建载体只产出空转统计面——与判断正本「第二阶段、样本集复跑产生数据后才有聚类可言」的时序一致。
- **下一判读时点**：每次复跑收口时，由执行者对表复核两项计数；任一达阈，在该次复跑的 scores.md 中注明「C2 激活阈值已达」并报 PM 另行立项。
- **与纠正台账分工**：台账记单条纠正，本载体记评测失败归因，两者不互替（提案 C2 原义）。
