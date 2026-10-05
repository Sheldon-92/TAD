# COMPLETION — maintainer-evidence 分支复活研究链（S4 收口）

| 项 | 内容 |
|---|---|
| chain | TASK-20261004-MAINTAINER-EVIDENCE-REVIVAL |
| handoff | `.tad/active/handoffs/HANDOFF-2026-10-04-maintainer-evidence-revival.md` |
| 完成步 | S4（tad-evidence-revival-s4-01） |
| 执行会话 | afe84e51-6a08-41ad-acbc-290cc499a346 |
| 日期 | 2026-10-04 |
| 模板 | `.tad/templates/completion-report.md`（Build 轨模板；本链为研究轨，强制节按 HANDOFF FR11 适配，Gate 3 双审位由 RG3 独立评审承担，研究轨无 Gate 3） |

## 链程摘要

| 步 | 产物 | verdict/状态 |
|---|---|---|
| S0（PM） | HANDOFF 定稿＋开链记录（`.tad/evidence/phase3-first-chain.md`） | Gate 2 双审 CONDITIONAL，PM 合并裁定 CONDITIONAL PASS；六条件 C-T1/C-T2/C-T4 已销账，fit C1 作废留痕，fit C2 销账，C-T3 首算毕（第二算待 PM 收口验盘） |
| S1 盘点 | `.tad/evidence/research/maintainer-evidence-revival/inventory-manifest.jsonl`（13,082 行）＋`inventory-summary.md` | PM 验盘 PASS（四锚复算全等） |
| S2 三案 Brief | `.tad/evidence/research/maintainer-evidence-revival/decision-brief.md` | PM 验盘 PASS（数字断言逐项相等） |
| S3 RG3 | `.tad/evidence/reviews/rg3-critic-maintainer-evidence-revival.md` | verdict **PASS**（Ratings ADEQUATE；Critic 独立会话） |
| S4 收口 | `.tad/evidence/reviews/rg4-synthesis-maintainer-evidence-revival.md`＋本文件 | RG4 rubric overall 0.875；AC 终核 11/12 PASS，AC10 待 PM 写入锚行后终核 |

**四锚（全链唯一数字源，S1 实测）**：TOTAL_NOCARRIER=8706（46,878,109 B）／TOTAL_STALE=5（18,755 B）／TOTAL_CARRIED=4355（65,863,779 B）／TOTAL_BRANCH_ONLY=16（另 gitlink 1 件单独注记，不入四类）。

**推荐结论（S2 Brief，RG3 PASS）**：案一——恢复 maintainer-evidence 分支同步，并把同步脚本化、加分支新鲜度看守；置信度中高。采纳与否归 PM 裁定（见 RG4 §6 待裁清单）。

## KA

本链候选知识三条，逐条给出覆盖核查与建议落点；落点终定归 PM（RG4 §6 第 7 项）。

1. **忽略树盲视（git status 对整树忽略目录结构性失明）** — 已有覆盖，不新立条目。`.tad/project-knowledge/patterns/ac-verification.md` 已有同题条目（git status 对 `.tad/evidence/`、`.tad/archive/` 这类 whole-tree-ignored 目录结构性不可见，状态干净只证明非忽略面干净）。本链是该条目的又一实证：载体停摆约四周、8,706 件（46.9 MB）无 git 载体，靠 status 观察完全无感，只能显式盘上枚举发现。建议落点：PM 定夺是否在该条目 grounded-in 追加本链 HANDOFF 与 S1 summary 作为第二实例。
2. **git 路径集差集的非 ASCII 转义伪差（quotepath 伪差集）** — 新知识，建议新立条目。git 默认输出对非 ASCII 路径加引号转义（core.quotepath），与 `find` 明文路径做 comm 差集会双边误计：本链 12 条 CJK 路径双边各虚高 12，同一时点旧基线 8,708/2,248 与安全口径 8,696 即此伪差。现有 `patterns/shell-portability.md` 有 CJK collation 家族条目（comm/sort/awk/uniq），但无此机理。建议落点：`patterns/shell-portability.md` 新增条目——路径集运算必须 `git ls-tree -z` 与 `find -print0` 成对 NUL 管线、分支集只取 blob、gitlink（mode 160000）单独注记。最终落点由 PM 定。
3. **AC 断言逐项化（合并 alternation 计数可误 PASS）** — 原则已有覆盖，建议补实例。`patterns/ac-verification.md` 已有「多词存在性须 per-term 断言、never a combined grep -cE tally」条目（记的是合并计数按行计的误 FAIL 方向）；`principles.md` 亦有「全局计数下限测不出 must-cover 丢失」（2026-06-01）。本链补上镜像方向的实证：合并计数＋阈值在单锚词重复时误 PASS，裸子串 KA 误命中 KAGGLE——C-T2 勘误已把 AC5/AC6/AC11 改为逐项合取＋锚定断言，并经 PM 三反例（仅估计×4／仅案一×3／KAGGLE 文）全拦、两正例全过复核关闭。建议落点：PM 定夺是否在该条目追加本链实例（误 PASS 方向＋裸子串碰撞）。

## Friction

| # | 摩擦点 | 状态 |
|---|---|---|
| F1 | S1 写 genesis 行漏尾换行，首行与次行粘连，AC8 首跑解析失败；S1 执行者当步逐字节修复、重跑通过。 | 已关闭（PM S1 验盘留痕接受，不返工） |
| F2 | AC8 在 S1 步只能部分达标（当时仅 genesis＋S1 两行，阈值需全链行齐）；S1 如实标注未凑数。 | 已关闭（S4 append 后终核 PASS，见 RG4 §4） |
| F3 | 本链设计时承担的 Phase 3 锚链角色在开链前被上层口径变更取消，HANDOFF 经 PM 以 S0 修订注改版（GM 等价登记条件作废留痕）。 | 已关闭（设计前提变更已在 HANDOFF 内留痕，不影响本链四问） |
| F4 | RG3 三条弱点的处置未定：看守规格（阈值/周期/责任人）、推荐前提重议触发、branch-only 16 件＋gitlink 1 件去向。 | 待 PM 裁定（RG4 §6 第 2/3/4 项；不阻塞研究收口，阻塞后续执行链开工） |
| F5 | 收口锚行（AC10）按设计归 PM 写入，S4 只提交建议稿；锚行未入盘前 AC10 悬空。 | 待 PM 动作（建议稿见 S4 完工说明） |
| F6 | C-T2 勘误源于 AC 断言写法缺陷（合并计数）；勘误、复跑、关闭均在本链内完成，未外溢。 | 已关闭（勘误 note＋PM C-T2 验盘在盘） |

## Evidence Checklist

- [x] F-2 件一：RG3 verdict — `.tad/evidence/reviews/rg3-critic-maintainer-evidence-revival.md`（PASS）
- [x] F-2 件二：Decision Brief — `.tad/evidence/research/maintainer-evidence-revival/decision-brief.md`
- [x] F-2 件三：RG4 记录 — `.tad/evidence/reviews/rg4-synthesis-maintainer-evidence-revival.md`（含 rubric 评分、AC 终核表、CHECK 待人、待 PM 裁清单）
- [ ] F-2 件四：证据日志锚行 — `.tad/evidence/phase3-first-chain.md`（待 PM 写入；建议稿见 S4 完工说明）
- [x] S1 盘点产物：`inventory-manifest.jsonl`＋`inventory-summary.md`（四锚三方重算全等）
- [x] AC 终核：AC1–AC9、AC11、AC12 PASS（RG4 §4 逐条依据）；AC10 待 PM 项
- [x] usage log：genesis＋S1/S2/S3/S4 行齐，逐行可解析（`.tad/evidence/knowledge-usage-log.jsonl`）
- [x] Gate 2 双 verdict 在盘：`.tad/evidence/reviews/2026-10-04-gate2-tech-maintainer-evidence-revival.md`、`.tad/evidence/reviews/2026-10-04-gate2-fit-maintainer-evidence-revival.md`
- [x] PM 验盘四件在盘：`.tad/evidence/pm/2026-10-04-evidence-revival-s1-pm-verify.md`、`-s2-`、`-s3-`、`-ct2-pm-verify.md`

## Provenance

| 产物 | 生成方式 |
|---|---|
| inventory-manifest.jsonl / inventory-summary.md | S1 执行会话 449e8e64-b7e3-44e1-8097-9dc03d8b9cb6 按 C-T1 安全管线（`git ls-tree -rz` 只取 blob＋`find -print0`＋逐件 `git hash-object` 比对）全量实测生成 |
| decision-brief.md | S2 执行会话 208ee03a-98d3-4065-b1fc-5ca7ab3b40c8 按 HANDOFF §4.3 框架成文，数字全部引 S1 summary 四锚与 §4.4 派生量 |
| rg3-critic verdict | S3 Critic 独立会话 c6175ab3-d36c-4575-a180-495e5f7cfae4 独立重算＋抽查＋反例搜寻后裁定，与 S1/S2 会话互异 |
| Gate 2 tech/fit verdicts | 设计评审两路独立会话（b36ef433…/c7afba9b…）对 HANDOFF 设计版评审，PM 合并裁定回填 HANDOFF |
| rg4-synthesis 记录 / 本 COMPLETION | 本 S4 会话 afe84e51-6a08-41ad-acbc-290cc499a346 综合上游产物并实跑 AC 终核生成 |
| knowledge-usage-log.jsonl 各行 | genesis 由 PM 开链写入；S1/S2/S3/S4 行由各步执行者按 HANDOFF §4.5 格式 append，自验逐行可解析 |
| phase3-first-chain.md | PM 创建并续写（开链记录、条件销账、步序）；锚行待 PM 写入 |
| PM 验盘四件 | PM 对 S1/S2/S3/C-T2 逐项盘上验后落盘 |

**本链实际写面（AC12 对照 HANDOFF §7.1/§7.2）**：§7.1 新建件全部在盘（锚行所在 phase3-first-chain.md 由 PM 创建，锚行待 PM 补写）；§7.2 仅 knowledge-usage-log.jsonl 被 append（票状态行回填归 PM，本链执行者未动票）；§7.3 禁改面（.gitignore、maintainer-evidence 分支、两树既有件、本体规程与模板、gm 仓、docs/pm 保留集、session-state.md）零写入——`.gitignore` diff exit 0、分支尖复验仍为 8713ea4e。
