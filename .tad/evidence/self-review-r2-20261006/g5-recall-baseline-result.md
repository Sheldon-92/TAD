# 组 5 · 索引召回率基线结果（2026-10-06 首测）

- 题集：`g5-recall-question-set.md`（sha256 `ba370858ee5f4e889f6824dbbca138c8245e202a6c31d9510cd0f799f804b2dc`）
- 期望集：`g5-recall-expected-set.md`（sha256 `761de25878da94bd11307972e1fc71aa741179d9ee5cc58efb08cf60a60b1090`，冻结时点 2026-10-06 18:32 UTC，早于跑题留痕首行）
- 跑题留痕：`g5-recall-run-trace.md`（跑题开始 2026-10-06 14:32 EDT；独立子会话，只见题面、检索只许三索引文件、禁读本体与期望集）
- 语料基线锚（Step 0 实测）：patterns 条目 232、incidents 文件 25、principles 条目 16、project-knowledge 585,723 B、brain-index 27,087 B

## 方法注记

- 抽样：principles 文档序每 2 取 1 得 8；patterns 文件名字典序展开条目流每 9 取 1 得 24；incidents 文件名字典序每 3 取 1 得 8；无答案题 5 道为出题人自拟语料外场景。题面由条目内容改写、去掉条目标题原词与 hook 独占词。
- **判分粒度（如实标注）**：principles＝条目级（brain-index Principles 表为条目级）；patterns＝**文件级**（brain-index Patterns 表与 patterns/_index.md 均为文件级索引，条目级区分超出当前路由面——题答对文件即记命中；此粒度本身是基线发现：patterns 路由面没有条目级索引）；incidents＝文件级。
- top-3 定序（增补 S-4）：索引面序 brain-index → patterns/_index → incidents/_index、面内按行序、去重取前 3；判分按跑题留痕实际返回序列。
- 命中＝期望条目 ∈ top-3；Recall@1＝期望居首位。

## 基线四组数

| 指标 | 值 |
|---|---|
| Recall@3（命中题数 / 40） | **26/40（65%）**（principles 8/8、patterns 14/24、incidents 4/8） |
| Recall@1（附值） | **14/40（35%）**（principles 5/8、patterns 7/24、incidents 2/8） |
| 无答案误报率（给出任一候选的无答案题数 / 5） | **3/5（60%）**（Q41 给 2 候选、Q44 给 1、Q45 给 3；Q42/Q43 正确无候选） |
| 压缩比 patterns 组（patterns/_index.md 字节 ÷ patterns 条目本体总字节） | 3,491 ÷ 482,538 ＝ **0.0072** |
| 压缩比 principles 组（brain-index Principles 表段字节 ÷ principles.md 字节） | 4,127 ÷ 25,219 ＝ **0.1637** |

## 逐题判定（期望 → 实得 top-3 摘要 → 判定）

| 题 | 判定 | 备注 |
|---|---|---|
| Q1–Q2 | 命中（@1） | 期望居首 |
| Q3 | 命中（@3 第 2 位） | 首位为同族 Judgment-Only 条目 |
| Q4 | 命中（@1） | |
| Q5 | 命中（@3 第 2 位） | 首位 Path Layering（近似：同 grep-c 主题族） |
| Q6 | 命中（@1） | |
| Q7 | 命中（@1） | |
| Q8 | 命中（@3 第 2 位） | |
| Q9 | **未命中** | 期望 ac-verification.md 不在 top-3（返回 pack-build-rules.md）；匹配词「workflow/invocation」未路由到该文件行 |
| Q10 | 命中（@1，文件级） | 附带 section-9-1-region-marker.md（incidents 面） |
| Q11 | **未命中** | ac-verification.md 缺席（返回 principles 条目＋handoff-design＋hook-contracts） |
| Q12 | 命中（@3 第 2 位） | |
| Q13 | 命中（@1） | |
| Q14 | **未命中** | ac-verification.md 缺席；计数类关键词全被 principles 计数条目占位 |
| Q15 | **未命中** | ac-verification.md 缺席；首位为同题干来源的 principles 复合条目 |
| Q16 | 命中（@3 第 2 位） | gate-design.md |
| Q17 | 命中（@1） | |
| Q18 | **未命中** | gate-design.md 缺席（返回 release-sync.md 等） |
| Q19 | **未命中** | handoff-design.md 缺席 |
| Q20 | 命中（@3 第 2 位） | |
| Q21 | **未命中** | handoff-design.md 缺席（返回 gate-design.md）——近似边界：两文件主题相邻 |
| Q22 | 命中（@3 第 2 位） | hook-contracts.md |
| Q23 | 命中（@3 第 2 位） | memory-and-learning.md |
| Q24 | **未命中** | pack-build-rules.md 缺席（仅返回 handoff-design.md） |
| Q25 | **未命中** | pack-build-rules.md 缺席 |
| Q26 | 命中（@1） | |
| Q27 | 命中（@1） | |
| Q28 | 命中（@3 第 2 位） | |
| Q29 | 命中（@3 第 2 位） | |
| Q30 | **未命中** | 期望 shell-portability.md 缺席；首位为 incident `yq-normalizes-once-idempotent.md`——标题词碰撞：具体事件文件比方法文件更「像」答案 |
| Q31 | 命中（@1） | |
| Q32 | 命中（@1） | |
| Q33 | 命中（@3 第 2 位） | incidents 文件级 |
| Q34 | 命中（@1） | |
| Q35 | **未命中** | gemini-cli-constraints.md 缺席（厂商名未出现在该文件索引行关键词中） |
| Q36 | **未命中** | pack-collision-detection.md 缺席 |
| Q37 | **未命中** | 零候选（匹配词 surplus/scan 在三面无命中行） |
| Q38 | 命中（@1） | |
| Q39 | **未命中** | cross-agent-parity-check.md 缺席 |
| Q40 | 命中（@3 第 3 位） | |
| Q41 | 误报（2 候选） | 语料外题被 release-sync.md 等近邻占位 |
| Q42 | 正确无候选 | |
| Q43 | 正确无候选 | |
| Q44 | 误报（1 候选） | runtime-adapter-checklist.md |
| Q45 | 误报（3 候选） | 满额误报 |

## 近似边界注记

- patterns 文件级粒度下，同一文件多条目互为近邻（如 ac-verification.md 的 Q9/Q11/Q14/Q15 连环未命中而 Q10/Q12/Q13 命中）：差异来自 brain-index Patterns 行的 hooks/keywords 覆盖——文件行关键词未覆盖到的条目主题即不可达。条目级不可达率高于文件级数字所示。
- incidents 未命中四题（Q35–Q37、Q39）共性：索引行（文件级一行）关键词稀疏，题面语义线索（厂商名、机制名）未进索引行。
- 本结果为基线：任何索引修复后的复测须同题集、同定序口径、同判分粒度重跑后才可与本组数并列比较。
