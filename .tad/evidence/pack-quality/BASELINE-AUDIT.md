# Baseline Audit — 24 packs

> EPIC-20260613-capability-pack-quality-leveling — Phase 1 产物 (1c 基线审计)
> Created: 2026-06-13 by Blake | 尺：`QUALITY-BAR.md`（Layer A 结构 /10 + Layer B 深度 0/5 + discriminative 行为）
> 方法可重跑：评分脚本逻辑见 §方法（与 QUALITY-BAR §1/§2 判据一一对应）。

---

## ⚠️ 关键纠偏（MQ1 实读 vs handoff 假设）

handoff §2.1 + Alex 消息说"**无 fixture 的那 1 个包**"。逐包实扫发现 **24 个目标包里有 2 个无 fixture**：`ml-training` 和 `ai-podcast-production`。（"26 fixtures 跨 23 包"把第 25 个非目标包 `research-methodology` 误算进"23"，故漏数 1 个。）§4.2 规则"无 fixture → LOW + 自动进 Batch 1"对**两个**包对称适用。

---

## 1. 质量分布表（24 包，弱→强按综合分排序）

> 综合分 comp = Layer A(0-10) + Layer B(0-5)×2，范围 0-20。**置信度**：无 fixture=LOW（分仅来自两个软层，无客观行为分量）；gold 锚点=HIGH；其余 single-reviewer specN-informed=MED。
> `disc` = eval-harness 接线就绪（含 discriminative_pattern 的 fixture 数 / fixture 总数），**N/A=无 fixture**（非新鲜行为评估——那是 Phase 2-5 DoD）。

| pack | Layer A 结构(/10) | Layer B 深度(/5) | discriminative | 有无 fixture | 置信度 | 综合档 | 主要 gap |
|------|:---:|:---:|:---:|:---:|:---:|:---:|------|
| ml-training | 6 | 1 | N/A | ❌ 无 | **LOW** | **8** | 结构 floor：**无 references / 无 fixture / 无 scripts**，深度最低(specN8)；全包仅 SKILL.md 112 行 |
| data-engineering | 8 | 1 | 1/1 | ✅ | MED | 10 | 领域深度最低(specN8)，规则偏通用原则，无验证脚本 |
| agent-memory | 8 | 2 | 1/1 | ✅ | MED | 12 | 深度偏浅(specN16)，无验证脚本 |
| agent-orchestration | 8 | 2 | 1/1 | ✅ | MED | 12 | 深度偏浅(specN16)，无验证脚本 |
| knowledge-graph | 8 | 2 | 1/1 | ✅ | MED | 12 | 深度偏浅(specN16)，无验证脚本 |
| ai-tool-integration | 8 | 2 | 1/1 | ✅ | MED | 12 | 深度偏浅(specN20)，references 杂(1594行)需聚焦 |
| llm-observability | 8 | 2 | 1/1 | ✅ | MED | 12 | 深度中下(specN22)，无验证脚本 |
| ai-podcast-production | 7 | 3 | N/A | ❌ 无 | **LOW** | **13** | **无 fixture（行为不可测）**；有 cross-cutting 规则但缺 eval 脚手架 |
| product-thinking | 7 | 3 | 1/2 | ✅ | MED | 13 | 内容深(2492行/deep-skill)但**结构缺 CONSUMES/PRODUCES + anti-skip + 导航索引** |
| code-security | 8 | 3 | 1/1 | ✅ | MED | 14 | 中等深度；部分规则复述通用安全知识，无验证脚本 |
| synthetic-data | 8 | 3 | 1/1 | ✅ | MED | 14 | 中等深度(specN35)，无验证脚本 |
| web-testing | 8 | 3 | 1/1 | ✅ | MED | 14 | 中等深度；部分规则复述通用测试知识(AAA/co-location)，无验证脚本 |
| ai-agent-architecture | 7 | 4 | 1/1 | ✅ | MED | 15 | 深度扎实(specN50)但**无导航索引 + 无 Step 路由结构** |
| ai-evaluation | 8 | 4 | 1/1 | ✅ | MED | 16 | 深度好(specN56)，缺验证脚本，离 gold 一步 |
| ai-guardrails | 8 | 4 | 1/1 | ✅ | MED | 16 | 深度好(specN44)，缺验证脚本 |
| web-ui-design | 6 | 5 | 1/1 | ✅ | **HIGH** | 16 | **GOLD(深度)**，但**结构 gap：body 1202 行违反 <500 单体化 + 无 anti-skip + 无 index** |
| ai-voice-production | 9 | 4 | 1/1 | ✅ | MED | 17 | 强；深度(specN43)可再向 gold 收口 |
| ai-prompt-engineering | 8 | 5 | 1/2 | ✅ | MED | 18 | 深度满(specN73)但 **body 489 行近上限 + 无 anti-skip** |
| rag-retrieval | 8 | 5 | 1/1 | ✅ | MED | 18 | 深度满(specN61)，缺验证脚本，近 gold |
| web-deployment | 8 | 5 | 1/1 | ✅ | MED | 18 | 深度满(specN60)，缺验证脚本，近 gold |
| academic-research | 9 | 5 | 1/1 | ✅ | MED | 19 | 很强(specN137/18 refs/4 scripts)；唯缺 anti-skip 表 |
| video-creation | 9 | 5 | 2/2 | ✅ | MED | 19 | 很强(specN101/2 fixtures)；近 gold |
| web-frontend | 9 | 5 | 1/1 | ✅ | **HIGH** | 19 | **GOLD（参照）** |
| web-backend | 10 | 5 | 1/1 | ✅ | **HIGH** | 20 | **GOLD（参照，满分标杆）** |

**观察**：3 个 gold 里 `web-frontend`(19)/`web-backend`(20) 结构+深度双高；`web-ui-design` 深度满分但结构被单体 body 拉低到 16——**深度 gold ≠ 结构 gold**，是个真实发现（见 §3 gold 备注）。

---

## 2. 批次分组（弱→强）

> 3 个 gold（web-backend / web-frontend / web-ui-design）**不进升级批**——它们**是尺/参照**，不是升级对象（web-ui-design 的结构 gap 另列 §3 可选精修项）。
> 共 **21 个升级候选**，分 **4 批**（**不硬钉 6/6/6/6**，按实际 gap 切，允许不均匀 7/5/5/4 — arch S4 + principles "never pin a count"）。
> ⚠️ 无 fixture 的 `ml-training` + `ai-podcast-production` **自动进 Batch 1**（P0-2：缺 fixture 本身就是该批必补的 Phase-2 交付物）。

| 批次 | packs | 共同 gap 主题 |
|------|-------|--------------|
| **批次 1**（7，最弱 + 无 fixture） | ml-training\*, data-engineering, ai-podcast-production\*, agent-memory, agent-orchestration, knowledge-graph, ai-tool-integration | 领域深度最浅(LB1-2) + 缺 eval 脚手架 / 缺 fixture（\*=无 fixture 强制入此批）。ml-training 还需从零补 references+scripts。 |
| **批次 2**（5，中浅 + 结构补强） | llm-observability, product-thinking, code-security, synthetic-data, web-testing | 中等深度 + 结构补强：product-thinking 补契约/索引/anti-skip；code-security/web-testing 把"复述通用知识"的规则换成研究阈值。 |
| **批次 3**（5，扎实，向 gold 收口） | ai-agent-architecture, ai-evaluation, ai-guardrails, ai-voice-production, ai-prompt-engineering | 深度扎实；补 anti-skip / 导航索引 / 验证脚本，工具时效收口到 gold；ai-prompt 拆 body(489→拆 references)。 |
| **批次 4**（4，近 gold，最后一抬） | rag-retrieval, web-deployment, academic-research, video-creation | 接近 gold；补验证脚本 + anti-skip 表 + 单体化精修，即可达标。 |

### 2.1 边界包说明（arch P1-1 — 单 LLM 在决策边界最易错，自证理由近零成本兜底）

- **ai-tool-integration（comp12 → Batch 1）vs llm-observability（comp12 → Batch 2）**：同分；ai-tool-integration specN20 + references 1594 行偏杂（深度更需补、更接近"浅"），llm-observability specN22 + references 661 行更聚焦 → 后者归补强批。可重排。
- **knowledge-graph（comp12 → Batch 1）**：specN16 < llm-observability specN22，深度更弱 → 进最弱批。
- **product-thinking（comp13 → Batch 2 而非 1）**：综合分低主要因**结构**3 项缺（A5/A6/A7），但其领域内容(2492行 deep-skill)不算最浅 → 归"结构补强批"，不与真·浅深度包同批。
- **ai-prompt-engineering（comp18 → Batch 3 而非 4）**：分数近 Batch 4，但 gap 是**结构精修**（body 近上限 + 无 anti-skip）非深度，与 Batch 3 主题一致 → 归 3。
- **web-deployment（comp18 → Batch 4）**：LB5 近 gold，gap 只剩验证脚本 → 归最后一抬批。

### 2.2 批次可重排声明（arch P1-1）

批次成员是 **advisory**，直到该批开工前都可重排。本基线由**单 reviewer** + specN 初判，置信度多为 MED——**误排在每批入口重新打分时纠正，不在 Phase 1 冻结**。Layer B specN 是 noisy 单维（已知会误排 gold，故 gold 由定义锚 5）；边界包的最终归属以**每批入口的重打分 + 行为评估**为准。

---

## 3. Gold 结构精修（可选，不占升级批）

`web-ui-design` 是深度 gold（Layer B 5/5）但结构有真实 gap：**SKILL.md body 1202 行**（违反 Anthropic <500 行 + 渐进披露）、无 anti-skip 表、无导航索引。建议一个独立小项把 body 拆进 references/（不改深度内容），使其结构也达 gold。**优先级低于 4 批升级**。

---

## 4. 方法（可重跑）

- **Layer A(/10)**：对 §QUALITY-BAR §1 的 A1-A10 逐条 grep/wc（frontmatter、aux 文件、body≤550、路由、CONSUMES/PRODUCES、anti-skip、索引、fixture、discriminative_pattern 接线、验证脚本）。
- **Layer B(0/2/5)**：specN（specific-threshold 去重计数，跨 SKILL+references+skills+checklists+adapters，命令见 QUALITY-BAR §2.3 — 用 pack-anchored path + parens，避免 `*/skills/*.md` 过度匹配整树；±2 drift 属正常，bucket-stable）初判桶（≥60→5/40→4/25→3/15→2/<15→1），3 gold 包定义锚 5，product-thinking 因 deep-skill 架构 specN 低估手动校正为 3。
- ⚠️ **Layer 2 P2 备注（移交 Phase 2 批次入口）**：(1) specN 单维理论上可被低价值数字噪音灌高 → 每批入口重打分须记录"reading 判断 vs specN 桶"分歧的至少一例，证明 gestalt 层是活的；(2) Layer A 是 grep 形，能拒绝意外垃圾但对"故意塞 magic token + 空内容"判别弱 → Layer A≥7 不可单独当质量信号，深度归 Layer B、行为归 §3 判别 gate（§0 已如此分层）。
- **discriminative**：含 `discriminative_pattern` 的 fixture 计数（接线就绪度），复用 `pack-eval-runner.sh`，不重造。
- 负样例验证见 `QUALITY-BAR.md §4`（Layer A 劣质结构 0/10 FAIL；Layer B 浅薄内容 specN0 → 1/5 FAIL）。

---

## 5. 回填动作

批次成员已回写 `EPIC-20260613-capability-pack-quality-leveling.md` 的 Phase 2-5（见该文件 Phase Map）。
