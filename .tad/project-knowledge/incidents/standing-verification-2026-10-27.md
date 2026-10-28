# 常设验证运行记录（standing verification）— 2026-10-27

本件为借4 常设验证的成文记录。件首逐字全载借4 限定四条（与常设路由文件 `.tad/project-knowledge/incidents/routing.md` 定稿逐字同）：

本件只在 incidents 语料面验证过（单轮、13 题预注册子集、文件级粒度）；常设形态同限于此面，不证明可扩展到其它知识面。
本件为纯文本结构路由，无向量后端；ChromaDB 许可证检查仍挂账，不在本件内解决，也不在本件名义下引入后端。
patterns 面条目级粒度不在本件范围；本件不收 patterns 条目。
引用本件的验证结论时须连同上述限定一并引用。

**过线判定行：过线（PASS）。Recall@3 = 8/8 ≥ 6/8（判据一过线）；误报 = 0 ≤ 3（判据二过线）。按设计不采信为规则有效性证明，仅作静态形态下检索可达之观察。**

## 运行要素

- 被测文件冻结：`.tad/evidence/yolo/r4-batch/phase5-routing-freeze.md`（冻结记录，冻结子集哈希与三面 sha 登记在案）。
- 计分时 routing.md sha256 复验值：`cc31ecfd7ad44f73df8ce49ca229e32f494e0130a06a9be8c9dce7e05cce2343`，与冻结记录值全等（同轮复验 brain-index `32dbb18370a9d43019a7eab51dcea0a1cbc079edae1a5fac563f09df23f2dae5`、patterns `_index.md` `daaef5e1f10557cc1a859def0a06b09633d74a42966a99ef6a3551fca66b3876`，三面全等）。
- 答题者（runner）：与出题、计分相分离的 fresh 裸上下文（dispatch_id: r4-p5-runner-1），喂入恰四件：题面 `questions-subset-13.md` 内容、routing.md 本体、`.tad/brain-index.md`、`.tad/project-knowledge/patterns/_index.md` 本体，附返回协议（逐题恰返 3 候选、无答案题 0–3、逐题检索路径一句、末尾自签）。
- 原始返回逐字附卷：`.tad/evidence/yolo/r4-batch/phase5-runner-returns.md`。
- 计分基准：`expected-subset-13.md`（只读，冻结子集 hash `04acb2a7…` 与冻结记录对账一致）。
- 判据：试验预注册线（设计 §3.3，经 Gate 2 双镜头有条件过门确认）——Recall@3（Q33–Q40）≥ 6/8 过线；误报（Q41–Q45 返非空的题数）≤ 3 过线。运行中未改线。

## 逐题计分表（复算式：命中 = 期望文件 ∈ 返回 top-3；命中位 = 期望文件在返回序列中的位置）

| 题 | 期望文件 | 返回集（按序，stem） | 结果 |
|---|---|---|---|
| Q33 | academic-research-pack-pilot | academic-research-pack-pilot, scoring-rubrics-need-methodology-review, pack-value-non-monotonic | 命中 @1 |
| Q34 | claude-md-routing-label-conflicts | claude-md-routing-label-conflicts, ac-grep-count-reference-pack, ac-verification-command-bug | 命中 @1 |
| Q35 | gemini-cli-constraints | gemini-cli-constraints, codex-agents-md-auto-load, cross-agent-parity-check | 命中 @1 |
| Q36 | pack-collision-detection | pack-collision-detection, pack-value-non-monotonic, pack-value-cross-vendor | 命中 @1 |
| Q37 | scienceclaw-skill-decoupling | scienceclaw-skill-decoupling, progressive-disclosure-extract, embedded-copy-drift-check | 命中 @1 |
| Q38 | alex-role-decay-direct-execution | alex-role-decay-direct-execution, codex-agents-md-auto-load, progressive-disclosure-extract | 命中 @1 |
| Q39 | cross-agent-parity-check | cross-agent-parity-check, codex-edition-parity, ac-grep-count-reference-pack | 命中 @1 |
| Q40 | pack-value-cross-vendor | pack-value-cross-vendor, pack-value-non-monotonic, scoring-rubrics-need-methodology-review | 命中 @1 |
| Q41 | 无答案（语料外） | 空集 | 无误报 |
| Q42 | 无答案（语料外） | 空集 | 无误报 |
| Q43 | 无答案（语料外） | 空集 | 无误报 |
| Q44 | 无答案（语料外） | 空集 | 无误报 |
| Q45 | 无答案（语料外） | 空集 | 无误报 |

- Recall@3 = 命中题数 / 8 = 8/8 = 1.0 ≥ 6/8 → 判据一过线。（附记：8 个命中全部位于返回第 1 位，实测强于 Top-3 口径。）
- 误报 = Q41–Q45 中返回非空的题数 = 0 ≤ 3 → 判据二过线。
- runner 协议核查：回答题逐题恰返 3 候选、无答案题返 0；逐题附检索路径一句；末尾自签完整（实读清单＋禁区未开声明）。无协议事故，未触发重跑。

## holdout 处置

- holdout 基数实数：**0**。试验后（2026-10-06 之后）incidents 零新增：routing.md 的 stem 集（25 件）与在盘 incident 文件的 stem 集全等，试验子集 stem 已在 routing 25 件 stem 集合之内（两集合差空集为空，非空判据不触发本轮不取 fallback 之外的题集）。按设计预注册 fallback，本轮验证题面取冻结的 13 题，不将未来新 incident 凑数补齐、不造题；后续新增 incident 优先留作下一轮 holdout。

## runner 自签原文（与原始返回件同文，此处复载供计分记录自足）

我实际用文件工具读过的文件清单（仅此两件）：
- `/home/hatch/workspace/yun-sync/TAD/.tad/brain-index.md`
- `/home/hatch/workspace/yun-sync/TAD/.tad/project-knowledge/patterns/_index.md`

其余输入（题面 13 题、第三面 routing.md 全文）均为任务消息中直接给定的文本，未经文件读取。

我声明：未打开任何 incident 原件正文，未打开 incidents 的 `_index.md`，未打开任何 expected 答案件、试验记录件、合同、冻结记录、评审件或回报件，未打开任何其他文件，未列目录，未联网，未使用任何搜索工具在仓库里找答案。

## 载体与判读边界

- 本记录按 C3 常设验证三段成文（冻结→运行→计分）；本次运行与未来每轮常设验证同属常设复查安排（此安排出于 C3 常设验证本身的设计，不出于件首任何一条限定），验证结果不自动修订被测文件。
- 依件首限定中「本件只在 incidents 语料面验证过、常设形态同限于此面」一条，本记录只证明：在冻结的静态形态下，索引对本轮题面的检索可达（8/8 命中、0 误报）；不构成对索引规则内容的 endorse，也不构成机制合规论证。
- 计分者：Phase 5 实施乙段 Blake（dispatch_id: r4-p5-impl-b-1），按 expected 机械复算；复算式与原始返回、冻结记录、expected 路径均在盘可核。
