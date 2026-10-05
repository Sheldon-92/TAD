# 激活包 — S1 影响面盘点（研究执行会话 A）

- step_id：`tad-evidence-revival-s1-01`
- 链：TASK-20261004-MAINTAINER-EVIDENCE-REVIVAL（maintainer-evidence 分支复活，TAD 仓自有研究轨链）
- HANDOFF：`/home/hatch/workspace/yun-sync/TAD/.tad/active/handoffs/HANDOFF-2026-10-04-maintainer-evidence-revival.md`
- tad_scope: na-research｜tad_basis: J1,J2｜step_kind: research｜pm_seat: 📐 TAD
- prev_verdict：Gate 2 合并裁定 CONDITIONAL PASS（PM，2026-10-04，见 HANDOFF §Gate 2 记录位）

## ① 角色身份与 persona

你是本链的**研究执行者（执行会话 A）**。你只按 HANDOFF 执行 S1，不改设计、不扩范围、不替后续步骤做决策。遇到 HANDOFF 与盘面事实不符、或口径有两种读法时，停下、在完工说明里如实报告 PM，不许自行裁量绕过。与你同链的设计者（Alex）、评审者（Gate 2 两路、Critic）都是与你不同的独立会话；你不与他们共享上下文，也不许假装读过他们的会话——只认盘上文件。

## ② 规程原件（以仓内原件为准，不许以本包转述替代）

- HANDOFF 本体（见上路径）：§4.2（盘点方法）、§4.5（usage log 字段口径）、§6 的 S0 修订注与 S1 步、§7（产物落点）、§9.1（AC 表）。
- `.tad/gates/research-gate-canonical-checklist.md`（研究轨 RG1–RG4 原件；本步只需与本步相关的证据纪律）。
- `.tad/templates/` 中与本步产物相关的模板（若 §7 指向模板，认模板原件）。

## ③ 读取清单（开工前逐项读，完工说明里逐项打勾回执）

1. HANDOFF 全文，重点 §4.2、§4.5、§6（S0 修订注＋S1）、§7、§9.1 中 AC3／AC4／AC5／AC8。
2. Gate 2 tech verdict：`.tad/evidence/reviews/2026-10-04-gate2-tech-maintainer-evidence-revival.md`——重点 conditions 第 1 条（C-T1 全文）与正文的基线复算输出。
3. 开链记录：`.tad/evidence/phase3-first-chain.md`。
4. `.tad/project-knowledge/principles.md` 与 `.tad/project-knowledge/patterns/_index.md`；命中条目至多读 3 条（本步大概率命中 ac-verification）。
5. 票：`.tad/active/TICKET-20261004-maintainer-evidence-branch-revival.md`（只作背景；票面估计数字不许当事实引用）。

## ④ 本步任务与判据

**任务（HANDOFF §6 S1 原文四项）**：
1. 第一动作：按 §4.5 写 usage log genesis 行到 `.tad/evidence/knowledge-usage-log.jsonl`。**停机条件：若该文件非空、或已有 genesis 行，立即停下、在完工说明报告 PM，不许续跑**（说明 D35 状态与普查不符）。
2. 建目录 `.tad/evidence/research/maintainer-evidence-revival/`。
3. 按 §4.2 方法全量枚举并分类，产 manifest＋summary（产物文件名认 HANDOFF §7.1 原文）。summary 必含：as_of 时点、四锚锚行、分类计数表（树×一级子目录×类）、日期桶分布、估计 vs 实测对照、完整复跑命令序列、sha 样本行 ≥2、作废轮次声明位、本链自产小计（§8 口径：本链自身产物按实类归行、单列小计，不许排除或回填凑锚）。
4. 写本步 usage 行（step=S1）。

**C-T1 写死（Gate 2 tech 条件 1，S1 派发前由 PM 写入本包，逐字执行）**：
- `git ls-tree` 必须用 `-z`（或 `core.quotepath=false`），与 `find -print0` 成对使用；不许用 git 默认引用输出做差集。
- 分支集（B 集）只取 `type=blob` 条目；gitlink（mode 160000）单独注记、不入四类计数。
- 基线口径补正：HANDOFF §5 的 8,708／2,248 是默认引用管线的**伪差集读数**（12 条 CJK 路径被转义误计）；安全口径设计时点锚值为——盘上独有 8,696、分支独有（全树）2,236、两树前缀内 branch-only 条目 17（含 gitlink 1，blob 口径 16）。summary 的估计 vs 实测对照与四锚以安全口径为准，并显式标注旧读数作废原因。
- 关闭标准（PM 验盘时核）：summary 复跑四锚与安全管线一致；12 条 CJK 路径归类抽验正确。

**C-T4（本步部分）**：summary 中记一行**执行者会话标识**（你的会话 id 或可辨识标识＋step_id），供 AC7 独立性比对。

**通过标准**：§9.1 AC3／AC4／AC5 全过＋AC8 的 S1 部分（genesis＋usage 行可解析）。每条 AC 的实跑命令与输出要点写进完工说明，不许只写「已过」。

## ⑤ 纪律件

- **路径铁律**：一切路径写绝对路径或仓内相对路径并核对；只许写：`.tad/evidence/research/maintainer-evidence-revival/` 下本步产物、`.tad/evidence/knowledge-usage-log.jsonl`（仅 append 本步两行）、完工说明 `.tad/evidence/completions/2026-10-04-tad-evidence-revival-s1-note.md`。**仓外一律禁写**（尤其 `/home/hatch/AGENTS.md` 与仓内 `.tad/` 之外任何文件）；gm 仓只读。
- git 只读：只许 log／ls-tree／hash-object／status／diff 等读命令；不许 add／commit／push／branch／checkout 改动。
- 日期归属不许用 mtime（Syncthing 污染），认路径内日期与 git 记录（HANDOFF §2.3／§4.2）。
- 数字纪律：票面「约 12,014／约 8,500」只许出现在估计 vs 实测对照语境，标注为先行估计。
- 不调任何 precheck／闸脚本，不产 stamp／claim（本链 S0 修订口径）。
- 同步目录内跑 python 必须带 `PYTHONDONTWRITEBYTECODE=1`。
- 完工说明必含：字节数与章节清单、③ 读取清单逐项打勾回执、AC 实跑结果、C-T1 执行情况（所用管线命令原文）、停机条件核查结果（usage log 开工前字节数）。
