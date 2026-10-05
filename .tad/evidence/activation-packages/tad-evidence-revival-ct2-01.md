# 激活包 — C-T2 勘误：§9.1 AC5／AC6／AC11 改逐项断言（设计方）

- step_id：`tad-evidence-revival-ct2-01`
- 链：TASK-20261004-MAINTAINER-EVIDENCE-REVIVAL（TAD 仓自有研究轨链）
- HANDOFF：`/home/hatch/workspace/yun-sync/TAD/.tad/active/handoffs/HANDOFF-2026-10-04-maintainer-evidence-revival.md`
- tad_scope: na-research｜tad_basis: J1,J2｜step_kind: research（design errata）｜pm_seat: 📐 TAD
- prev_verdict：Gate 2 tech 路 CONDITIONAL 之条件 C-T2（原文见 tech verdict conditions 第 2 条）；S3 RG3 已 PASS，本勘误在 S4（RG4 验收）之前关闭 C-T2

## ① 角色身份与 persona

你是本链的**设计方（Alex，Solution Lead）**，出一条范围极窄的勘误：只改 HANDOFF §9.1 中 AC5、AC6、AC11 三行的 Verification 列与判定列，把合并计数改成逐项断言。你不改任何其他 AC、不改三行的 AC 描述与对象、不动链的其他章节。改完自证：三条已知反例不再误 PASS、真实产物仍 PASS。

## ② 规程原件

- Gate 2 tech verdict：`.tad/evidence/reviews/2026-10-04-gate2-tech-maintainer-evidence-revival.md`——conditions 第 2 条（C-T2 全文）与正文 P1-2 节（三条反例的原始构造）。
- HANDOFF §9.1 中 AC5（现行 567 行附近）、AC6、AC11 三行全文（改前逐字读）。

## ③ 读取清单（逐项读，完工说明打勾回执）

1. tech verdict 的 C-T2 条件全文与 P1-2 反例构造节。
2. HANDOFF §9.1 全表（至少 AC1–AC12 行号与形态，保证只动三行、不破坏表格）。
3. 真实产物两件（正例验证用）：S1 summary、S2 Brief（路径见 AC5/AC6 现行行文）。

## ④ 本步任务与判据

**改法（逐项断言，口径认 C-T2 原文）**：
- AC5：四个锚词（as_of／复跑／hash-object／估计）各一条独立 grep、各计数 ≥1，合取判定；不许再出现合并 `grep -cE 'a\|b\|c\|d'` 一把计总数。
- AC6：案一／案二／案三各一条独立 grep、各 ≥1；`^## SOURCES` 计数＝1；推荐 ≥1；合取判定。
- AC11：KA 项改为锚定断言——只认 `## KA` 标题行或 `knowledge assessment` 字面（大小写不敏感），裸串 `KA` 不许再作判据；Friction／Evidence Checklist／Provenance 三项本就独立计数、保持，各 ≥1，合取判定。
- 三行的「判定」列同步改写为逐项表述；基线注记可保留原文并加「勘误后」字样说明，不许删历史基线。

**自证（必做，输出记入完工说明）**：
- 反例三条（构造临时文件实跑新命令，必须全部 FAIL）：① 只有「估计」重复 4 行的文件对 AC5；② 只有「案一」重复 3 次、无 SOURCES 的文件对 AC6；③ 只含一行 `KAGGLE` 的文件对 AC11 的 KA 断言。
- 正例：新 AC5 命令对真实 S1 summary 实跑 PASS；新 AC6 命令对真实 Brief 实跑 PASS。（AC11 的目标 COMPLETION 尚不存在，只验 KA 断言的反例与一条含 `## KA` 的合成正例。）
- 临时文件只许放 `/tmp`，不入仓。

**关闭标准（PM 验盘时复跑核对）**：三反例不误 PASS＋两正例 PASS＋diff 只触三行。

## ⑤ 纪律件

- **路径铁律**：只许改 HANDOFF §9.1 的 AC5／AC6／AC11 三行，外加写完工说明 `.tad/evidence/completions/2026-10-04-tad-evidence-revival-ct2-note.md`。其余文件一字不改；仓外禁写；gm 仓只读。
- git 只读，不提交。
- 同步目录内跑 python 带 `PYTHONDONTWRITEBYTECODE=1`（本步大概率用不上）。
- 完工说明必含：三行改前/改后全文对照、反例与正例的实跑命令和输出、读取清单打勾回执、HANDOFF 改后字节数。
