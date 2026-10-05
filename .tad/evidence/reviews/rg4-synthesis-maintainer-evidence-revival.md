# RG4 综合记录 — maintainer-evidence 分支复活研究链

| 项 | 内容 |
|---|---|
| chain | TASK-20261004-MAINTAINER-EVIDENCE-REVIVAL |
| step | S4（tad-evidence-revival-s4-01） |
| 角色 | Alex 侧综合（RG4） |
| 执行会话 | afe84e51-6a08-41ad-acbc-290cc499a346 |
| 日期 | 2026-10-04 |
| 上游 | HANDOFF：`.tad/active/handoffs/HANDOFF-2026-10-04-maintainer-evidence-revival.md`；RG3 verdict：`.tad/evidence/reviews/rg3-critic-maintainer-evidence-revival.md`（PASS）；Brief：`.tad/evidence/research/maintainer-evidence-revival/decision-brief.md` |

## 1. 结论先行

本链四锚经三方独立重算全等、四问全部得答：盘上 `.tad/evidence/` 与 `.tad/archive/` 共 13,066 件中 8,706 件无任何 git 载体、5 件内容过期，推荐案一（恢复 maintainer-evidence 分支同步＋脚本化＋分支新鲜度看守，置信度中高）经 RG3 独立评审 PASS，rubric overall＝0.875。研究轨收口材料齐备；载体采纳与看守参数属 PM 裁定，本记录只列待裁清单（§6），不代裁。

## 2. Quality Rubric 评分

rubric 原件：`.tad/templates/research-quality-rubric.md`。评分对象＝本链研究发现（S1 盘点＋S2 Brief 的综合）。RG4 复核后确认 RG3 独立评分成立，逐项如下：

| 维度 | 评分 | 一句话理由 |
|---|---|---|
| citation_accuracy | 1.0 | Brief SOURCES 表覆盖全部承重主张且带定位，RG3 逐项对原件抽验（四锚、F-18 查证、SC3 措辞、principles 读单）全部一致。 |
| factual_accuracy | 1.0 | 四锚经 S1 自报、PM 复算、RG3 全量独立重算三方全等（8706/5/4355/16，manifest 行数 13,082＝四类和），无编造数值；票面估计只作对照、不入结论（NFR2 口径诚实）。 |
| completeness | 0.5 | Q1/Q3/Q4 全覆盖；Q2 对推荐案的保证深度止于「过程＋检出」，看守规格（阈值/周期/责任人）未定——深度缺口，与 RG3 评分一致。 |
| source_quality | 1.0 | 承重主张全部 Tier-1（仓内规程原件、git 盘上实测、票与宪章原文），无 Tier-2/3 充数。 |
| efficiency（advisory，不入聚合） | 信号密度高 | 四步产物无填充节；S1 悬空项（AC8 首轮）如实标注未凑数。 |

**overall ＝ mean(1.0, 1.0, 0.5, 1.0) ＝ 0.875**（≥0.6，不触发 WARN；factual/citation 均 ≥0.5，不触发 floor 规则）。总评：RESEARCH PASS，可收口。

## 3. RG4 判据四项复核

| 判据 | 结果 | 依据 |
|---|---|---|
| 结论先行（Brief 结论第一句 ≤3 句） | ✓ | Brief「结论（推荐）」节首段 2 句即给出推荐案与理由；本记录 §1 同守此式。 |
| 置信度＋未知项声明在位 | ✓ | Brief 置信度＝中高，唯一未证前提明示（关键件直读需求不频繁）；未知项 6 条逐条状态，其中 #2 已被 RG3 以 `git ls-remote` 实查关闭，其余 5 条如实悬置。 |
| 反方案例章节存在 | ✓ | RG3 verdict「最强反例搜寻」6 例逐一裁定；「Charter 覆盖缺口」独立成节。 |
| Provenance 表齐 | ✓ | Brief SOURCES 表；COMPLETION `.tad/evidence/completions/COMPLETION-2026-10-04-maintainer-evidence-revival.md` 的 Provenance 节逐件列生成方式。本链未改 Local Wiki 语料（`research/canon/lint.sh` 的治理对象），该项不适用本链产物。 |
| human CHECK | CHECK 待人 | 见 §5。 |

## 4. AC 终核表（AC1–AC12）

终核执行者＝本 S4 会话，2026-10-04 实跑；断言口径以 HANDOFF §9.1（C-T2 勘误后）为准。

| AC | 终态 | 终核依据（实跑输出/出处） |
|---|---|---|
| AC1 | PASS | `test -f` 票在盘，输出 `TICKET_PRESENT`（本会话复跑）。 |
| AC2 | PASS | `git log -1 --format=%h maintainer-evidence` 复跑输出 `8713ea4e`（本会话二次复验，与链内各步一致）。 |
| AC3 | PASS | 设计时基线命令复跑 exit 0，两计数均为正整数：8734 / 2248。注：盘侧数较设计时 8708 增 26，为设计后盘上新增文件（本链自身产物等）在该（已知有 CJK 引用伪差的）默认管线下的计入；AC 判据为正整数＋exit 0，满足。权威口径以 S1 安全管线四锚为准。 |
| AC4 | PASS | 本会话复跑 manifest 全量 `Counter`：no-carrier 8706 / stale 5 / carried 4355 / branch-only 16 / 合计 13082，与 summary 四锚逐一相等（继 PM、RG3 后第三次独立重算全等）。 |
| AC5 | PASS | C-T2 勘误后逐项断言（全路径版）本会话实跑：`as_of` 4、`复跑` 4、`hash-object` 5、`估计` 3，链 exit 0，与 PM C-T2 验盘值逐一相等。 |
| AC6 | PASS | C-T2 勘误后逐项断言（全路径版）本会话实跑：`案一` 14、`案二` 15、`案三` 10、`^## SOURCES` 1、`推荐` 6，链 exit 0，与 PM C-T2 验盘值逐一相等。 |
| AC7 | PASS | RG3 verdict 在盘（`.tad/evidence/reviews/rg3-critic-maintainer-evidence-revival.md`，verdict PASS）；三会话 ID 互异本会话实查：S1 `449e8e64-b7e3-44e1-8097-9dc03d8b9cb6`（summary）、S2 `208ee03a-98d3-4065-b1fc-5ca7ab3b40c8`（Brief 头）、Critic `c6175ab3-d36c-4575-a180-495e5f7cfae4`（RG3 verdict 头）；Critic 非 S1/S2 执行者，独立性成立（C-T4 已由 PM 终核关闭）。 |
| AC8 | PASS | 本步 append S4 行后终核（命令与阈值见 COMPLETION Evidence Checklist）：genesis ≥1、含链 ID 行 ≥3、含 handoff 路径行 ≥2，实测值在 S4 完工说明回执；append 前四行（genesis/S1/S2/S3）逐行可解析，S4 行同格式。 |
| AC9 | PASS | 本记录自身：含 rubric 评分节（§2，`citation_accuracy`／评分／rubric 计数 ≥1）且含 `CHECK` 与「待人」（§3、§5）。 |
| AC10 | 待 PM 项 | 锚行文本建议稿已随 S4 完工说明提交；锚行由 PM 写入 `.tad/evidence/phase3-first-chain.md` 后由 PM 终核（判据：`研究轨收口:` 起首行恰 1 行——盘上现有注释行以 `<!--` 起首，不入该计数）。本记录不冒充已过。 |
| AC11 | PASS | COMPLETION 写毕后本会话自跑 C-T2 勘误后逐项断言：`knowledge assessment\|^## KA`、`friction`、`evidence checklist`、`provenance` 四计数均 ≥1（实测值在 S4 完工说明回执）。 |
| AC12 | PASS | `git diff --exit-code -- .gitignore` 本会话复跑 exit 0；AC2 分支尖复验 `8713ea4e`（同上）；本链实际写面逐件列于 COMPLETION Provenance，与 HANDOFF §7.1/§7.2 一致，无 §7.3 禁改面写入。 |

悬空项仅 AC10 一条，且为按设计留给 PM 的动作（锚行写入），非执行缺陷。

## 5. human CHECK 记录位

**CHECK 待人。** 待检要点（供检查者逐项过目）：

1. Brief 推荐案一（恢复分支同步＋脚本化＋分支新鲜度看守）是否符合维护者对证据仓的实际使用预期——尤其「关键件在主仓直读」的需求频率（推荐唯一未证前提）。
2. 主仓 .tad/evidence 两树现有 3 件 tracked 例外件（R1）的存在是否与预期一致（Brief 附带发现，PM 已实查属实）。
3. 四锚数字（8706/5/4355/16）与「约四周停摆」的时间线叙述是否与维护者记忆相符。
4. §6 待裁清单的处置方向（采纳/看守参数/branch-only 与 gitlink 去向）由 PM 裁定后，是否还需人拍板方可立执行链。

## 6. PM 裁定位与待 PM 裁事项清单

本记录与 COMPLETION 均只做综合与终核，**不裁定**下列事项；裁定位在 PM 收口：

1. **载体采纳**：是否采纳案一（或改采案二/案三）。
2. **新鲜度看守参数**（RG3 弱点 1，PM S3 验盘已定处置：S4 裁定中明定并指定落盘位置）：看守阈值、复算周期、责任人三项。
3. **推荐前提重议触发**（RG3 弱点 2）：当 usage log 攒出「主仓关键件高频直读」证据时，PM 须重议本推荐。
4. **branch-only 16 件＋gitlink 1 件去向**（RG3 弱点 3，PM S3 验盘已定处置）：列为后续恢复执行链设计的强制首步，逐件给保留/弃置意见后才许动载体；不在本链 scope 内处置。
5. **收口锚行写入**（AC10/FR10）：锚行文本建议稿见 S4 完工说明；写入与 AC10 终核归 PM。
6. **C-T3 第二算**：Gate 2 两 verdict 文件 sha256/字节（tech `0e6c8601…` 13,547 B；fit `c42b0c33…` 16,564 B）按 Gate 2 条件总账绑定 S4 收口验盘由 PM 执行。
7. **KA 落点终定**：COMPLETION KA 节三条候选的建议落点由 PM 终定后落 project-knowledge。

## 7. 收口件清单

| 件 | 路径 | 状态 |
|---|---|---|
| F-2 件一 RG3 verdict | `.tad/evidence/reviews/rg3-critic-maintainer-evidence-revival.md` | PASS 在盘 |
| F-2 件二 Brief | `.tad/evidence/research/maintainer-evidence-revival/decision-brief.md` | 在盘 |
| F-2 件三 RG4 记录 | 本文件 | 本步产 |
| F-2 件四 证据日志锚行 | `.tad/evidence/phase3-first-chain.md` | 待 PM 写入（建议稿已提交） |
| COMPLETION | `.tad/evidence/completions/COMPLETION-2026-10-04-maintainer-evidence-revival.md` | 本步产 |
