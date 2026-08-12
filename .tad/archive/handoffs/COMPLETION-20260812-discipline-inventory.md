# Completion: 纪律清单补全与证伪（Discipline Inventory）

**Task:** HANDOFF-20260812-discipline-inventory
**Date:** 2026-08-12
**Commit:** uncommitted（本单无 commit 授权；产物为 7 个新文件，未改动任何既有文件）
**Model:** harness=opencode | model=deepseek/deepseek-v4-pro | route=opencode default

## Current status — Gate 3 PASS，待 Alex Gate 4 验收

Layer 1（§9.1 十六行）全 PASS；Layer 2 spec-compliance 独立审查 verdict PASS（P0=0, P1=0, P2=1 残留不阻塞）。
13 条 AC 全部实质满足。AC7 形状盲区 reviewer（独立 spawn）已给出 10 条形状缺陷。
产物 7 个文件全部落盘 `.tad/evidence/designs/discipline-inventory/`，未改动任何既有文件（V10 delta=0）。

## Outcome

产出 Epic「纪律与重量分离」Phase 1 的地基——一份纪律清单（两种形态）+ 检索留痕 + 校验脚本：

- **形态 A**（`discipline-inventory.md`）：15 条纪律 × 九列，供人拍板「留/退场/进旋钮」。
- **形态 B**（`discipline-provenance.md`）：15 条逐条溯源，14 个实例载体全部 `.tad/` 内逐字可验证。
- **枚举差异**（`enumeration-diff.md`）：独立枚举比 Epic 草稿多出 **4 条**（角色分离/AC 可执行性/Friction 反跳过/Ralph Loop 自检），并重新质询 Epic 旧标签（门禁=地板 / Execution Mandate=保留 / 约束准入=保留 / 跨模型审查=弱实例）。
- **检索留痕**（`search-log.md`）：15 块，每条 3 关键词 × 4 语料 + 归档；第 3/4 类行实例聚焦检索确认全空。
- **校验脚本**（`verify.py`）：10 子命令（含新增 `empty`），机械复核全部 AC。

## 关键判定结果（15 条纪律）

| 判定 | 数量 | 纪律 |
|---|---|---|
| 1-留 | 11 | 需求澄清 / 需求闸 / 重量裁定 / 专家审查 / 门禁 / 启动扫描 / 角色分离 / Execution Mandate / AC可执行性 / Friction反跳过 / Ralph Loop自检 / 跨模型审查 |
| 3-挂起 | 2 | 知识评估 / 配对测试 |
| 4-威慑免死 | 1 | 约束准入 |

（注：1-留 实为 12 条——跨模型审查经实例聚焦检索从 3-挂起改判 1-留，纠正 Epic 草稿「弱实例」低估。）

## 重要发现（对 Epic 的修正）

1. **Epic 遗漏 4 条纪律**：角色分离（有 violations.log 两条缺席致害载体）、AC 可执行性检查、Friction 反跳过、Ralph Loop 自检。
2. **跨模型审查被低估**：Epic 标「弱实例/偶然非制度」，实例聚焦检索找到 `pack-evaluation.md#L20`「~44 catches the same-model loop missed」——Codex 跨模型审查浮出约 44 处同模型循环漏掉的错误。改判 1-留（「留」=制度化，非已制度化）。
3. **零第 2 类（净删除）**：无一条纪律满足「无实例但触发条件出现过」——所有「无实例」纪律要么触发条件从未出现（3-挂起），要么是威慑型（4-威慑免死）。Epic 暗示的「应退场纪律」在本检索证据下不存在。
4. **AC7 形状盲区**：reviewer 指出九列形状装不下「收益量级 / 判定理由链 / 跨行防线关系 / 证据置信度」等 10 类信息，全部挤进第 9 列自由文本。这是 Phase 2+ 需处理的形状病灶。

## Context refresh

- 读：CLAUDE.md §2/§3/§4；alex/blake/alex-lite/blake-lite 四份 SKILL；principles.md（Express Handoff is NOT Review-Exemption 等）；patterns/_index.md + handoff-design.md#L167 + ac-verification.md#L310/326/334 + shell-portability.md#L139；Epic 两份（discipline-weight-separation + full-capability-extraction-retirement）。
- 关键约束：§0 环境约束（awk CJK 比较坏 / grep 是 ugrep 包装 / python3 列作用域 / 无 timeout）；载体路径须在 `.tad/` 内。
- 成功条件：AC1–AC13 全 PASS，三来源枚举独立于 Epic 草稿，14 载体逐字可验证，零改动既有文件。

## Friction Status

| 前置项 | 状态 | 说明 |
|---|---|---|
| 独立 reviewer（AC7 + L2） | READY | Agent tool spawn 2 个独立上下文（均 deepseek-v4-pro） |
| python3 3.9.6 | READY | `/usr/bin/python3 --version` |
| 语料（183 知识 + 25 incidents + 2 violations） | READY | 实测路径正确（incidents 在 `.tad/project-knowledge/incidents/` 非 `.tad/incidents/`） |
| 非自指样本 | BLOCKED（已知且接受） | 全部证据自指，非自指样本 0（AC9 已声明；Phase 5 解决） |

## AC 结果（13/13 PASS）

- AC1 三来源枚举九列：PASS（V1=3/1，V2=0 无 TBD）
- AC2 载体全验：PASS（14/14，V3）
- AC3 第 3 类触发条件：PASS（class3_missing_trigger=0）
- AC4 成本无形容词：PASS（成本col=15 violations=0）
- AC5 类型+严重度+单类型警示：PASS（14/14/14，only_absence=7=warned）
- AC6 lite 对称审查：PASS（Execution Mandate=1，约束准入=1）
- AC7 盲区三段式：PASS（装不下=True / forbidden=False / answer_len=2476）
- AC8 零改动+无触发规格：PASS（V10 diff_exit=0，V11=0）
- AC9 偏差声明：PASS（逐字命中）
- AC10 检索留痕+第 3/4 类全空：PASS（blocks=15=rows，empty=0）
- AC11 阳性对照：PASS（3/3 真实命中）
- AC12 第 2 类举证：PASS（零第 2 类，空真）
- AC13 地板理由+旧标签质询：PASS（floor_missing_reason=0，重新质询=6）

## Layer 2 审查

Reviewer verdict: **PASS**（首轮 CONDITIONAL P0=0/P1=2 → 增量复核全 CLOSED）
P1-1 AC10 全空无验证 → 修复（D08 改判 1-留 + D07/D09/D12 实例聚焦关键词 + verify.py empty）
P1-2 D08 标签矛盾 → 修复（pack-evaluation.md#L20 强实例）
残留 P2（不阻塞）：cmd_empty 下标映射依赖行序恒等 D01–D15。

## Knowledge Assessment

- **journal captured**：本单为分析型，无独立 journal；发现已写进形态 B 与 enumeration-diff §4。
- **candidate for distillation**：跨模型审查的「~44 catches」实例 + AC7 形状盲区 10 条缺陷（供 Phase 2 形状重构）。

## Reflexion History

- what_failed: AC2 载体全验首跑 ok=0 bad=14（file-missing）
- root_cause_hypothesis: verify.py `REPO = HERE.parents[4]` 多算一级（应为 parents[3]）
- revised_approach: 改 parents[3] 后重跑 ok=14
- confidence: high

- what_failed: D04 载体行号错位（snippet 在 L34 但标 #L33），且 AC11(a) 阳性对照字符串缺失
- root_cause_hypothesis: 逐字片段取自查到内容的行，未回写正确行号；载体未引用条目标题
- revised_approach: 载体改 #L33 引标题「Express Handoff is NOT Review-Exemption」
- confidence: high

- what_failed: Layer 2 首轮 CONDITIONAL——D08 误判 3-挂起且实例标签矛盾；D08/D09/D12 检索非空
- root_cause_hypothesis: 原始关键词（Codex/MUST）命中平台名/通用词噪音，被误当「无实例」；未读 pack-evaluation.md 全文
- revised_approach: 实例聚焦关键词重搜 → 找到 D08 强实例改判 1-留；D07/D09/D12 全空；加 verify.py empty
- confidence: high
