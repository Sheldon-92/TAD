# COMPLETION — 按地板表懒加载（P7，Epic 最后一刀）

**Handoff**: `HANDOFF-20260818-lazy-by-floor.md`（rev5）｜**Blake**: 2026-08-18
**T0**: `08043c4`（基线已 commit，step0.sh 拒绝重跑 = 设计如此）
**Evidence**: `.tad/evidence/acceptance-tests/lazy-by-floor/`
**Commits**: `03c8aa3`（S0）· `649ffc5`（S2）

## 交付物（§6 写权限 1-5）

| 产物 | 位置 |
|---|---|
| 预算表（S0） | `.tad/discipline-floor-budget.md`（常驻 9 项 20,081 B ≈ 5K tokens，下限） |
| 29 条义务祈使句（S0） | `.claude`/`.agents` 两个 `alex/SKILL.md` 尾部「义务型祈使句」段，**原文逐字**（非 load_when 指针），可 grep -F 命中 |
| 6 个模式专属块外置（S2） | `test_review_protocol` / `my_templates` / `release_duties` / `project_context_update` / `next_md_rules` / `knowledge_bootstrap` → `references/{...}.md`，原位替换为 `reference:`+`load_when:` 存根 |
| 34 存根压缩（S2） | 删 24 行 `# Extracted ...` 重复注释（保留 adaptive_complexity_protocol 的——位于复杂度判定常驻块内，AC4(a) 只增不减） |
| 镜像 | `.agents` 与 `.claude` 逐字同步（AC9 + AC13 mirror 双验） |

## AC 结果（verify.sh all：RESULT=PASS，exit=0）

- **AC1（承重）**：29/29 义务祈使句常驻层命中（`ac1-hits.tsv`，全在 `alex/SKILL.md`）
- **AC2**：两个模块集（STEP 3 正文 4 / binding 5）双向 comm 零丢失；`config-cognitive` 已暗模块照旧 WARN 打印（契约 §3.0 另开单）
- **AC3**：`step0.sh --constraint-set` 现集（163 行）⊇ 分母 137 行，无约束行离开分母 → 无需 reachability 记录（本单 0 约束行外置）
- **AC4(a)(b)**：14 个常驻块（9 地板 + 5 护栏）块内行集只增不减；gate/blake/blake-lite/AGENTS.md 逐字未变
- **AC5**：`fatal_operations:` / `release_management:` 两段零 diff
- **AC6**：34 存根 load_when 压缩前后 34/34 SAME（`stub-loadwhen-diff.tsv`，键=上层键+路径）；6 个新建存根的触发词定义点落盘（`ac6-trigger-points.tsv`，全在 SKILL.md commands/激活协议区）
- **AC7**：TOTAL_STATIC **256,313 → 250,924 B（−5,389，严格下降）**；TOTAL 262,172 → 256,783；扫描命令 5 条逐字不变实跑
- **AC8**：fresh subagent ×2 只喂 12 文件（md5 落盘 `readback-files-md5.tsv`）；首次 Q2/Q4 缺键（模型波动，未答祈使句清单）→ 复跑四题全键命中（逐字引用祈使句原文=AC1 承重生效的直接证据）
- **AC9/AC13**：镜像逐字一致；skill-body-verify 全绿（7 marker 全在 body、3 reference 未重建、load_when 非循环烟雾过）
- **AC10**：改动集全在 §6 白名单
- **AC12**：契约 + 7 配套 + 11 基线 vs T0 零 diff
- **references 行集**：只增不减（外置 6 新文件 0 约束行，基线未动）
- **AC11 五负控全红**（`negative-controls/run.sh`）：(a) 模块摘除→AC2 (b) 分母约束行搬移→AC3 (c) Forbidden 块条目清空→AC4(a) (d) fatal_operations 外置→AC5 (e) 祈使句写进新建 OBLIGATIONS.md→AC1 保持红
- **逐类计数烟感**：12 行差异全部为新增（祈使句用词），零减少

## 过程记录

- **Step 0 第一次跑即红** = 设计如此（基线已 commit，`step0.sh` 拒绝重跑防"按降级树重新冻结"；用户预告知）。
- **S2 范围判定**：rev5 契约 S2 未枚举"模式专属块"；按护栏反推——AC13 禁 7 marker 外置、§5 禁约束本体外置、AC4(a) 禁常驻块行删除 → 外置对象 = 0 约束行、非 marker、非常驻块、触发明确的 6 个模式挂钩块；`harvest_protocol`/`my_gates`/`success_patterns`/`interaction` 等因含 forbidden/约束行**不动**；`on_start` 无触发语义**不动**。
- **负控脚本两处自错已修**：(a) sed 目标写错（模块行无 `.tad/` 前缀）→ 改为 `config-quality→config-qualitx`；(b) 删祈使句当 AC3 负控失败——分母是 T0 冻结 137 行、不含 S0 新增祈使句 → 改为删分母内的真实约束行。
- **AC8 一次波动**：模型输出可复现性弱（契约 §10.3 明示），复跑全中——如实记录未掩盖。

## Friction Status

| 项 | 状态 | 处置 |
|---|---|---|
| step0.sh 拒绝重跑 | 设计如此 | 基线冻结在 T0，AC12 守哈希 |
| AC3 负控靶点（祈使句不在分母） | RESOLVED | 改删分母内约束行 |
| AC2 负控 sed 目标错误 | RESOLVED | 修正替换串 |
| AC8 首次缺键 | 模型波动 | 复跑全中，落盘两次记录 |
| BLOCKED 项 | 无 | — |

## 未做（按契约 §5）

S1（config-workflow 段外置）已砍未做；principles.md 索引化已删未做；blake/gate/blake-lite/AGENTS.md 未动；`fatal_operations:`/`release_management:` 未动；任何约束本体未外置（含唯一禁止型「跨模型审查」）；未新增常驻层成员；未改扫描命令；未改地板表任何格；未发布。

## 遗留 Follow-ups（人域）

1. **Gate 4**：Alex 独立复算 → 用户决定 commit/push（P1a/P2a/P2b/P3 未推送 commit 同批）。
2. **另开单（契约 §3.0）**：`config-cognitive` 从不加载（研究先行/技术决策透明/致命操作人审三条已暗）+ references 83 条强制行 82 条无常驻副本——同一病（约束够不着 agent）一起治；每次 measure 已打印已暗模块。
3. **SC1 ≤15K 收口**：本单交付「能不能安全地搬」这个能力（地板 20,081 B ≈ 5K tokens 已实测），收口留给后续单。
4. **契约 §10.6 敞口**：AC6/AC8/AC11 仍由 Blake 自觉执行——本单已全落盘（diff/定义点/readback md5/负控日志），供 Gate 4 复算。
