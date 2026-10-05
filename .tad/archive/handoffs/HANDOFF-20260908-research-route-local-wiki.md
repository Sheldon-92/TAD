---
task_type: mixed
e2e_required: no
research_required: no
skip_knowledge_assessment: no
feedback_required: false
gate4_delta: []
---

# Handoff: Clean TAD Upstream Research-Routing Entry Pointers (Local Wiki Primary, NotebookLM Fallback)

**From:** Alex (Solution Lead)  
**To:** Blake (Execution Master)  
**Date:** 2026-09-08  
**Task ID:** TASK-20260908-research-route-local-wiki  
**Priority:** P1  
**Version:** 3.0 (rev3)  
**Status:** Gate2-PASS-Round3 (rev3 R2-1–R2-4 verified CLOSED per gate2-synthesis-round3.md; 3 Round3 carriers on disk; Blake releasable pending Human dispatch — Alex does not call Blake)  

---

## Gate 1 / Confirmed Intent

### 1. 任务背景与核心意图
2026-08-30，TAD 框架正式通过 Local Wiki 调研框架验收（commit `3ee3915d` / `f967276f`，`PROJECT_CONTEXT.md` 记录 Gate 4 PASS）。Local Wiki 确立了以文件为真理源（file-is-truth）的 `raw → canon → wiki` 三层单向流动架构，并通过 Iron Rule（所有 wiki claim 必须携带 `raw_refs` 与 `locator: p.X | para Y | timestamp`，由 `research/canon/lint.sh` 6 条规则机械拦截）实现无外部云依赖的确定性调研积累。

虽然 `.tad/config-workflow.yaml` 中已将调研回退链配置为：
```yaml
fallback_chains:
  research:
    primary: local_wiki
    secondary: notebooklm_research  # fallback when local_wiki unavailable
    tertiary: claude_websearch
```
但 TAD 框架的大量入口指针、命令说明、技能主体、Blake 实现前知识检索（1_5b）、包升级描述、工具速查卡片以及顶层治理文档中，依然残留着旧的“NotebookLM 为默认/主路径”的历史表述。

### 2. 核心目标与硬性边界
- **核心目标**：系统性清查并修正 TAD 上游所有调研路由入口指针，将 `*research` Standard/Deep 的主路径统一规范为 **Local Wiki + Iron Rule**，将 NotebookLM 明确降级为**仅在 Local Wiki 缺失时的 fallback**。
- **硬性边界**：
  1. ❌ **严禁完全移除 NotebookLM fallback**：保留完整的 NotebookLM CLI 兼容层、配置、脚本与 fallback 路由逻辑；
  2. ❌ **严禁修改 GM 组织与章程文件（`docs/pm/`）**：本仓库不存在 `docs/pm-charter.md`（已机械核验不存在）；`docs/pm/` 下已有他线在飞改动（`M docs/pm/intent.md` 与 `M docs/pm/now.md`），Blake 在执行前必须执行 Step 0 抓取双写基线快照（`mkdir -p .tad/evidence/reviews/alex/research-route-local-wiki && git status --porcelain docs/pm/ | tee /tmp/row06.baseline > .tad/evidence/reviews/alex/research-route-local-wiki/row06.baseline`），严禁对 `docs/pm/` 产生任何新增 diff（R2-1 / ROW-06 机械拦截）；
  3. ❌ **`research/` 目录严格只读（除 dry 验证脚本外）**：本次任务中 `research/` 目录及其内容对 Blake 严格为 **READ-ONLY**。除运行只读校验脚本（`research/canon/lint.sh` 与 `python3 research/scripts/search.py`）外，Blake **严禁**运行任何写入型脚本（如 `ingest.sh` 或 `generate.py`），严禁产生任何 `research/` 下的新文件或 diff。规范文本中提及的 `ingest.sh` 与 `generate.py` 均为未来 Agent 开展调研时的协议规范指令，非 Blake 本次实现的执行指令。任何 `research/` 下的写入改动均属越界，Gate 3 直接判 FAIL（R2-2）；
  4. ❌ **Alex 不写实现代码，不调用 Blake**：本阶段只完成详尽的 Handoff rev3 规范编制并就绪于 Gate 2 重验（Ready-for-Gate2-rereview），不声称 Gate 2 PASS（留待独立会话复审），不启动 Blake 实现。

**Gate 1 结果**：✅ PASS（需求清晰，边界明确，意图确认）。

---

## ✅ Gate 2: Design Completeness (Alex)

**状态**: ✅ **Gate2 PASS (Round3 轻量确认完成：R2-1–R2-4 全部 CLOSED，双视角独立复验 PASS；carriers 见下表 gate2-synthesis-round3.md；Blake 可放行待 Human 触发——Alex 不直接调用 Blake)**  
*(Round1 CONDITIONAL → rev2 修复 → Round2 CONDITIONAL [gate2-synthesis-round2.md] → rev3 闭环 R2-1–R2-4 → Round3 PASS [gate2-synthesis-round3.md]：ROW-06 基线双写与防空跑已验证、§8 严禁写入一行已收敛、§2.2 活跃旁路与条目6路径已处置、"8处" 笔误与行号漂移已消除。)*

### Gate 2 评审历程与证据载体 (carriers on disk ✅)

| 阶段 | 载体路径 | 说明 |
|---|---|---|
| Leg-1 (v1.0) | `.tad/evidence/reviews/alex/research-route-local-wiki/leg1-spec-compliance-review.md` | OpenCode 独立会话 `ses_f7d967a75ffecEeXhvbiib85Ar`：Spec-compliance 视角 |
| Leg-2 (v1.0) | `.tad/evidence/reviews/alex/research-route-local-wiki/leg2-blast-radius-review.md` | OpenCode 独立会话 `ses_f7d967a57ffeC5lR9VX2CLYcWr`：Blast-radius / Safety 视角 |
| Synthesis (v1.0) | `.tad/evidence/reviews/alex/research-route-local-wiki/gate2-synthesis.md` | Alex 收敛裁定：CONDITIONAL，列出 P0-A/P0-B 及 P1-1 至 P1-8 |
| Rev2 Update | `.tad/active/handoffs/HANDOFF-20260908-research-route-local-wiki.md` | 彻底消除 P0-A/B，闭环 P1-1~8，标记为 Ready-for-Gate2-rereview |
| Leg-1 Round2 (rev2) | `.tad/evidence/reviews/alex/research-route-local-wiki/leg1-spec-compliance-review-round2.md` | OpenCode 独立会话 `ses_f7d89b6a6ffe0Rnrd8FPeEIm6j`：E1–E7 重跑，CONDITIONAL（P0-A PARTIAL 基线可操作性；P1-6 "8/9" 笔误） |
| Leg-2 Round2 (rev2) | `.tad/evidence/reviews/alex/research-route-local-wiki/leg2-blast-radius-review-round2.md` | OpenCode 独立会话 `ses_f7d89b689ffeookyt2kIDyyzhg`：消费者/安全视角，CONDITIONAL（R2-2 §8 软化一行修复；R2-3 三处活跃旁路 + 条目6路径；N1 /tmp 生命周期） |
| Synthesis Round2 | `.tad/evidence/reviews/alex/research-route-local-wiki/gate2-synthesis-round2.md` | Alex 收敛裁定：CONDITIONAL，Blake 未放行；列出遗留项 R2-1–R2-4 |
| Rev3 Update | `.tad/active/handoffs/HANDOFF-20260908-research-route-local-wiki.md` (本文) | 彻底闭环 Round 2 遗留项 R2-1 至 R2-4（ROW-06 基线生命周期双写与防空跑、§8 严禁写入一行收敛、§2.2 补齐 3 处活跃旁路与历史排除、更正 item-6 路径与行号漂移），就绪于 Gate 2 Round 3 重验（Ready-for-Gate2-rereview） |
| Leg-1 Round3 (rev3) | `.tad/evidence/reviews/alex/research-route-local-wiki/leg1-spec-compliance-review-round3.md` | OpenCode 独立子智能体 `ses_f7d7b9aedffee7fOLEotMEVQu0`：R2-1–R2-4 重跑，PASS（4/4 CLOSED） |
| Leg-2 Round3 (rev3) | `.tad/evidence/reviews/alex/research-route-local-wiki/leg2-blast-radius-review-round3.md` | OpenCode 独立子智能体 `ses_f7d7b9ad2ffe6UJPZfdzUoc0r1`：安全/ blast-radius 5 检查，PASS（5/5 CLOSED） |
| Synthesis Round3 | `.tad/evidence/reviews/alex/research-route-local-wiki/gate2-synthesis-round3.md` | Alex 收敛裁定：Gate 2 PASS，R2-1–R2-4 全部 CLOSED；Blake 可放行待 Human 触发；含 Knowledge Assessment |

### rev3 缺陷闭环对照表 (Clearing Round2 Remainders R2-1–R2-4)

| 编号 | 遗留项来源 | 缺陷现象 | rev3 修复措施与位置 |
|---|---|---|---|
| **R2-1** | P0-A remainder (Leg-1 blocking, Leg-2 N1) | ROW-06 在 Blake 启动前或重启后因缺少 `/tmp/row06.baseline` 导致 exit 2 报错，且 `/tmp` 易失存在生命周期隐患 | 明确 Step 0 双写基线机制（`/tmp` + `.tad/evidence/reviews/alex/research-route-local-wiki/row06.baseline`）；ROW-06 增加 `BASELINE_PENDING` 守卫逻辑（§1.2、§1.3、§5 AC8、§6 ROW-06、§7、§8） |
| **R2-2** | P1-7 remainder (Leg-2 partial) | §8 消息使用 "in write mode" 软化限定词，但 `generate.py` 无 dry 模式，重开歧义 | 将 §8 条目 4 严格对齐 §1.3："research/ is STRICTLY READ-ONLY: run only research/canon/lint.sh and research/scripts/search.py; do NOT run ingest.sh or generate.py in any mode;" |
| **R2-3** | P1-6 remainder (Leg-2 partial) | 条目 6 路径错误（根目录不存在 `pack-upgrade.workflow.js`）；且 3 处活跃旁路（tool-quick-ref-alex、capabilities.yaml、research-methodology）及历史噪点未显式 disposition | 条目 6 路径修正为 `.claude/workflows/pack-upgrade.workflow.js`；§2.2 扩充条目 10-14 完整 disposition 3 处活跃旁路、历史不可篡改记录与独立命名空间；§4.5 明确 File 21 内部 fallback 标注说明 |
| **R2-4** | 笔误与行号漂移 (Leg-1 & Leg-2 P2) | §2.2 宣称 "8 处" 但实际列出 9 项；`academic-research/SKILL.md` 行号由 159/162/167 漂移至 175/178/183 | 全文修正计数笔误；§2.1 与 §4.6 将行号改为基于 grep 动态锚定（Line ~175/178/183） |

### 历史 rev2 缺陷闭环对照表（参考保留）

| 编号 | 问题级别 | 原缺陷摘要 | rev2 修复措施与位置 |
|---|---|---|---|
| **P0-A** | 阻塞 | ROW-06 误报 false-FAIL（`docs/pm/` 审前已有两行脏状态），且 `docs/pm-charter.md` 文件不存在导致空洞断言 | §1.3、§5 AC8 及 §6 ROW-06 改为基线相对比对（记录 `/tmp/row06.baseline` 并断言零新增变动），且明确排除并断言 `docs/pm-charter.md` 不存在 |
| **P0-B** | 阻塞 | §5 漏掉 `learn-path-protocol.md`（且标号误写为 "Cat 5"），§6 缺少对应验证行 | §5 更正为 "AC 5 (Alex Reference Protocols)" 并显式补齐 `learn-path-protocol.md`（Step 3_5）；§6 新增 ROW-08 双镜像 grep 验证 |
| **P1-1** | 重要 | "26 files" 宣称与 §4 实际枚举 28/29 文件不符 | 全文（§2, §4, §5, §8）统一重新核算为精确的 **29 个文件**（12 对双平台镜像共 24 文件，加 5 个单例文件） |
| **P1-2** | 重要 | §4 File 27&28 遗漏 `.agents/skills/research-github/SKILL.md` 镜像；未 disposition academic-research 根包；前言 lines 3/11 未行级锚定 | 拆分为 File 27（CAPABILITY 单例）与 File 28&29（research-github 镜像对）；明确行号 3/11 替换；标注 `.tad/capability-packs/academic-research/SKILL.md` 为 out-of-scope |
| **P1-3** | 重要 | ROW-05 仅比对 2 对镜像，低于 AC7 宣称的 12 对 | 重写 ROW-05 为包含全部 12 对镜像的 Bash 循环比对脚本，确保 100% 覆盖 |
| **P1-4** | 重要 | AC1 宣称 "AGENTS.md 保持对齐" 不可测且无对应 ROW | 删除模糊子句，澄清经 grep 核验 AGENTS.md 本无陈旧指针，并维持 0 命中状态 |
| **P1-5** | 重要 | File 21 未点名 `tool-quick-reference-alex.md:169` 的陈旧表格行 | §4.5 File 21 增加对第 169 行 `*research-github notebook` 表格行的显式重写规格 |
| **P1-6** | 重要 | 概念泛化搜索命中部份文件缺乏显式边界说明 | 增加 §2.2 显式排除清单（Out-of-Scope List），逐一给出排除清单文件的可达性与豁免理由（rev3 扩充并精确核验至 14 项） |
| **P1-7** | 重要 | `research/` 写入权限模糊（规范指令含 `ingest.sh`/`generate.py`） | §1.3、§4.2 及 §5 AC2 显式规定 `research/` 目录在本次任务中严格 READ-ONLY，禁止 Blake 运行写操作 |
| **P1-8** | 重要 | AC3（Step 3.8 扫描）与 AC6（Blake 工具卡）缺少 §6 对应 ROW | §6 新增 ROW-04b（Blake 工具卡）、ROW-09（Step 3.8 扫描）与 ROW-10（Alex positive 模式检查） |

### Gate 2 预检自查清单 (rev3)

| 检查项 | 预检状态 | 详细说明 |
|---|---|---|
| Architecture Complete | ✅ READY | §3 完整定义 Local Wiki 为 Primary、NotebookLM 为 Fallback、WebSearch 为 Tertiary 的三级路由架构与降级判定标准 |
| Components Specified | ✅ READY | §2 与 §4 穷尽清查 6 大类别共 29 个文件的具体修改点、行号范围及替换范式 |
| Functions Verified | ✅ READY | 验证 `research/canon/lint.sh`、`research/scripts/generate.py`、`research/scripts/search.py` 均实际存在且可用 |
| Data Flow Mapped | ✅ READY | 明确 Alex 意图路由 → Local Wiki 检索/编译 → 降级探测 → Blake 1_5b 检索的闭环数据流 |
| Expert Review Complete | ✅ PASS (Round3) | rev3 R2-1–R2-4 全部 CLOSED，双视角独立复验 PASS（carriers：leg1/leg2/synthesis-round3.md on disk）；Gate 2 PASS；Blake 可放行待 Human 触发 |

---

## 1. Task Overview / Intent Statement

### 1.1 What We're Building
对 TAD 上游框架中 6 大类别的调研路由入口指针进行系统性清理，消除所有将 NotebookLM 视为主路径或默认路径的陈旧表述，建立“Local Wiki + Iron Rule 为主、NotebookLM 为 fallback、WebSearch 为降级兜底”的全局一致视图。

### 1.2 Why We're Building It
- **解决认知偏差与工具割裂**：避免 Agent 在执行需求调研或知识检索时，因陈旧 prompt 默认寻找云端 NotebookLM 导致超时、状态泄漏或无谓外部依赖，使真正经过形式化验证的 Local Wiki 成为默认反射。
- **加速检索与执行确定性**：Local Wiki 是本地 Markdown 文件体系，Blake 检索（1_5b）时无需等待 20-40 秒的云端 API 延迟，毫秒级即可获得带精确行号与来源（`raw_refs`）的扎实验据。

### 1.3 Intent Statement（意图声明）

**真正要解决的问题**：
把 TAD 框架内所有告诉 Agent“深度调研默认去用 NotebookLM”的地方，统一改为“默认走 Local Wiki + Iron Rule；仅当 Local Wiki 缺失时回退至 NotebookLM”。

**不是要做的（避免误解）**：
- ❌ **不是删除 NotebookLM**（NotebookLM 仍然作为 secondary fallback 存在，`setup-notebooklm.sh`、`REGISTRY.yaml`、CLI 访问限制等完整保留）；
- ❌ **不是修改 GM 组织与章程文件（`docs/pm/`）**：本仓库不存在 `docs/pm-charter.md`（已机械核验不存在）；`docs/pm/` 下已有他线在飞改动（`M docs/pm/intent.md` 与 `M docs/pm/now.md`），Blake 在执行前必须执行 Step 0 抓取双写基线快照（`mkdir -p .tad/evidence/reviews/alex/research-route-local-wiki && git status --porcelain docs/pm/ | tee /tmp/row06.baseline > .tad/evidence/reviews/alex/research-route-local-wiki/row06.baseline`），严禁对 `docs/pm/` 产生任何新增 diff（R2-1 / ROW-06 机械拦截）；
- ❌ **不是重构 Local Wiki 本身，且 `research/` 目录严格只读（除 dry 验证脚本外）**：本次任务中 `research/` 目录及其内容对 Blake 严格为 **READ-ONLY**。除运行只读校验脚本（`research/canon/lint.sh` 与 `python3 research/scripts/search.py`）外，Blake **严禁**运行任何写入型脚本（如 `ingest.sh` 或 `generate.py`），严禁产生任何 `research/` 下的新文件或 diff。规范文本中提及的 `ingest.sh` 与 `generate.py` 均为未来 Agent 开展调研时的协议规范指令，非 Blake 本次实现的执行指令。任何 `research/` 下的写入改动均属越界，Gate 3 直接判 FAIL（R2-2）；
- ❌ **不是由 Alex 直接动手修改被清理的文件**（由 Blake 在独立终端按本 handoff 执行）。

**Blake 请确认理解**：
```
在开始实现前，请用你自己的话回答：
1. 为什么这次要把 Standard/Deep 的主路径从 NotebookLM 切换为 Local Wiki？
2. NotebookLM 的角色变成了什么？在什么条件下才会触发？
3. 本次修改涉及哪 6 大类、共 29 个文件？有哪些文件和目录绝对不能修改或写入？
4. 如何执行 ROW-06 基线防污染校验？

只有 Human 确认你的理解正确后，才能在 Blake 终端开始实现。
```

---

## 📚 Project Knowledge / Capability Pack References

### Blake 必读历史教训与原则
1. **Local Wiki Research Framework (PROJECT_CONTEXT.md:34 & research/CLAUDE.md)**：
   - 规则：File is truth. Cloud is optional. `raw → canon → wiki` 单向流动。
   - Iron Rule：Every wiki claim MUST have `raw_refs` with `locator: p.X | para Y | timestamp`。
   - 检索优先：`python3 research/scripts/search.py query "<question>"`，不盲目全量加载。
2. **Circular Trigger & SKILL Body Safety (principles.md:103, alex/SKILL.md:680)**：
   - `research_unified_protocol` 必须保留在 SKILL 主体中，不能移至 references，否则会导致循环触发失效。
3. **Platform Parity (.claude 与 .agents 对齐)**：
   - 所有在 `.claude/skills/` 下做的改动，必须 1:1 同步反映至 `.agents/skills/` 镜像，保持双平台一致性。
   - **程序性防脆提示（P2-1）**：ROW-05 校验 12 对双平台镜像，Blake 必须在同一步中原子化修改双镜像，不可遗漏单侧，否则 `diff -u` 将直接退出非零。
4. **Anti-Rationalization (AR-002: small edit = low risk)**：
   - 即使是文档或注释指针的修改，也涉及提示词契约。Blake 修改时必须精确对齐行文，不得顺手删除未授权的代码或安全校验。

---

## 2. Comprehensive Inventory of Stale Pointers（清理清单总览）

### 2.1 核心清理清单（6 大类、29 个文件）
经全库详尽排查，共定位 6 大类别、29 个核心文件（包含 12 对双平台镜像共 24 个文件，加 5 个单例文件；其中 1 个文件为 Verify-and-Hold 状态）及相应陈旧指针：

| 类别编号 | 类别名称 | 目标文件 | 镜像 / 属性 | 现存陈旧指针与问题现象 |
|---|---|---|---|---|
| **Cat A** | 顶层治理文档 (2) | `CLAUDE.md` | 单例 | `CLAUDE.md:44` 宣称“用 `*research` 统一入口（默认走 NotebookLM 持久知识库）” |
| | | `research/CLAUDE.md` | 单例 (Verify-and-Hold) | Line 41 现已写明 Primary: `local_wiki`, NotebookLM fallback；Blake 需核验并保持字节稳定（P2-4） |
| **Cat B** | Alex 技能主体 (2) | `.claude/skills/alex/SKILL.md`<br>`.agents/skills/alex/SKILL.md` | 镜像对 1 | L115 宣称无 quick-ref 无法调用 NotebookLM；L397/475/682 宣称 `defaults to NotebookLM`；L709 preflight 仅测 NotebookLM；L748-860 `standard_execution` 仍以 `1_find_notebook` 起步；L280-295 Step 3.8 仅扫 REGISTRY.yaml |
| **Cat C** | Alex 协议引用文件 (12) | `alex/references/research-plan-protocol.md` | 镜像对 2 | Step 1/4 仍以 NotebookLM 为默认执行机制 |
| | | `alex/references/handoff-creation-protocol.md` | 镜像对 3 | Step 0_5b 仅找 REGISTRY.yaml |
| | | `alex/references/discuss-path-protocol.md` | 镜像对 4 | `research_notebook_awareness` 仅提示建 notebook |
| | | `alex/references/research-decision-protocol.md` | 镜像对 5 | `step2_5` 仅查 notebooklm |
| | | `alex/references/research-review-protocol.md` | 镜像对 6 | 仅审查云端 notebook 资产 |
| | | `alex/references/learn-path-protocol.md` | 镜像对 7 | Step 3_5 仅支持 notebook 生成 quiz（P0-B 闭环） |
| **Cat D** | Blake 技能与引用 (4) | `blake/SKILL.md` | 镜像对 8 | Line 587/598 `1_5b_notebook_check` 在编码前仅查询 NotebookLM（等待 20-40s），完全忽略 Local Wiki；`1_5c` 调研任务默认调用 notebooklm |
| | | `blake/references/notebooklm-access.md` | 镜像对 9 | 缺少关于 Local Wiki 作为首选本地资产不受云端白名单限制的前言说明 |
| **Cat E** | 工具速查手册 (2) | `.tad/guides/tool-quick-reference-alex.md` | 单例 | External-CLI 与 TAD Research Commands 章节将 `*research-notebook` 列为第一调研工具；L169 表格行未标注 fallback；缺少 Local Wiki 核心命令套件 |
| | | `.tad/guides/tool-quick-reference-blake.md` | 单例 | 缺少 Local Wiki 查询说明，NotebookLM 章节未标记为 Fallback |
| **Cat F** | 能力包升级与衍生协议 (7) | `capability-upgrade/references/legacy-pack-research.md` | 镜像对 10 | 叙述预设 NotebookLM 为包升级唯一调研来源 |
| | | `academic-research/SKILL.md` | 镜像对 11 | Line ~175/178/183 工具映射表（按 grep 'Semantic recall across sources\|Research notebook portfolio' 动态锚定）将语义召回绑定为 NotebookLM (R2-4) |
| | | `.tad/capability-packs/academic-research/CAPABILITY.md` | 单例 | 仍强调 NotebookLM 作为核心交付物 |
| | | `research-github/SKILL.md` | 镜像对 12 | Frontmatter lines 3/11 依然宣称 deep-research NotebookLM notebooks；需扩展 lines 189-200 的 LOCAL-WIKI SHIM（P1-2/P2-3） |

### 2.2 Explicit Out-of-Scope List & Reachability Rationale (排除清单与可达性论证 - P1-6, P2-2, R2-3 & R2-4)
经对全库 `1_find_notebook`、`research_notebook_awareness`、`REGISTRY.yaml`、`*research-notebook` 等概念词条的全面排查（全库共计 600+ 处广义引用），除纳入 §2.1 修改范围的 29 个文件外，以下 14 项文件/场景经评审明确**排除在本次修改范围之外**（提供明确可达性、架构分层与历史不可篡改性论证）：

1. `.claude/skills/alex/references/adaptive-complexity-protocol.md:171-195`：此处检查 REGISTRY.yaml 与 notebooklm-cli 刷新策略，仅用于复杂度评估时的外部环境健康感知；并未定义默认调研路由，可达性不受影响，**Out of Scope**；
2. `.claude/skills/alex/references/status-panoramic-protocol.md`：用于全景状态报告中读取已注册云端笔记本资产，属于被动资产盘点而非决策入口，**Out of Scope**；
3. `.claude/skills/research-notebook/SKILL.md` 及镜像：这是 NotebookLM 引擎本身的实现文件。按 Hard Boundary 1，NotebookLM 作为 secondary fallback 必须完整保留，**Out of Scope**；
4. `.claude/skills/alex-lite/SKILL.md:408`：TAD Lite 实验通道已于 2026-08-13 冻结，不接受任何新工作与架构升级，**Out of Scope**；
5. `.claude/skills/alex/references/deps-protocol.md:132`：管理 `notebooklm-cli` 依赖项的豁免规则，属于包依赖治理，与用户调研路由无关，**Out of Scope**；
6. `.claude/workflows/pack-upgrade.workflow.js`（R2-3 路径更正）：内部自动化包升级脚本，非 Agent 交互路由入口，**Out of Scope**；
7. `.tad/guides/nondev-execution-track.md:290`（P2-2）：历史 Conductor 侧非开发人员执行指南，记录特定历史流程，非 Agent 活跃调研路由，**Out of Scope**；
8. `.tad/capability-packs/academic-research/SKILL.md`（P1-2）：该路径为 capability-packs 安装源模板文件，其活跃映射已被镜像对 11 (`.claude/skills/academic-research/SKILL.md` 与 `.agents/skills/...`) 覆盖，按照 TAD 能力包同步架构，该分发文件由专门的 pack 升级流程处理，**Out of Scope**；
9. `research-github/SKILL.md` lines 232-242（Step 6/7 创建 notebook）：保留作为本地 canon 生成后的可选云端 fallback，**无需删除**；
10. `.tad/guides/tool-quick-reference-alex.md:19-20` 与 `:149-160`（R2-3 活跃表面处置）：该文件已作为 File 21 纳入本次范围。其第 19-20 行（NotebookLM CLI registry 指针）与第 149-160 行（`*research-notebook` 常用子命令速查表）作为云端 Fallback CLI 的合法操作参考在原位保留；§4.5 规范已通过在章节顶部明确注明 `Fallback Research CLI` 并增补 Local Wiki Primary 套件来完成路由纠偏，无需将子命令明细表格误删或越界重构；
11. `.tad/cross-model/capabilities.yaml:39-63`（R2-3 活跃表面处置）：这是跨模型调度层对底层 CLI 工具参数、RPC 端点与延迟指标的基础声明，不承担向 Agent 推荐默认调研路径的路由职责（Agent 路由统一由 `CLAUDE.md`、`alex/SKILL.md` 与 `.tad/config-workflow.yaml` SSOT 管辖），**Out of Scope**；
12. `.tad/capability-packs/research-methodology/CAPABILITY.md:253`（R2-3 活跃表面处置）：此处声明该能力包的关键词优先级是 research-notebook 与 research-github 的严格超集，属于能力包动态加载器的匹配规则，并非调研路由入口，**Out of Scope**；
13. `CHANGELOG.md` 及历史记忆文件（`README.md`、`NEXT.md`、`.tad/memory/*` 等）（R2-3 历史噪点归口）：属于框架历史版本日志与过去的会话记忆捕获，具有不可篡改性（Immutable History），**Out of Scope**；
14. `dependency-ops/SKILL.md`（引用 `.tad/dependencies/REGISTRY.yaml`）（R2-3 命名空间隔离）：该处为 TAD 自身项目依赖注册表，与调研笔记本注册表（`.tad/research-notebooks/REGISTRY.yaml`）为完全独立的命名空间（Distinct Namespace），属于词条重名误碰，**Out of Scope**。

---

## 3. Architecture & Routing Specifications（架构与路由规范）

### 3.1 调研三级回退阶梯（SSOT 映射）
所有调研场景严格遵循 `.tad/config-workflow.yaml` 所定义的层级：
1. **Primary: Local Wiki (`local_wiki`)**
   - 触发条件：存在 `research/` 目录且 `research/canon/lint.sh` 可执行。
   - 机制：`raw/` 沉淀原始语料 → `canon/` 提炼 12 字段事实（受 `_topics.yaml` 与 `_questions.yaml` 约束）→ `wiki/` 综合回答（强制遵循 Iron Rule 校验 raw_refs 与 locator）→ `lint.sh` 形式化验证 → `generate.py` 生成索引。
   - 检索方式：优先运行 `python3 research/scripts/search.py query "<query>" --scope wiki`。
2. **Secondary: NotebookLM (`notebooklm_research`)**
   - 触发条件：`research/` 目录缺失，或用户显式要求针对海量 YouTube/多源 PDF 开展云端综合分析，且 `test -x ~/.tad-notebooklm-venv/bin/notebooklm` 成立。
   - 机制：通过受控的 `*research-notebook` 命令与云端交互，结果保存至 `.tad/evidence/research/`。
3. **Tertiary: WebSearch (`claude_websearch`)**
   - 触发条件：Local Wiki 与 NotebookLM 均不可用，或仅进行 `--quick` 单点事实查询。

### 3.2 Blake 1_5b 检索协议革新（Zero-Latency & File-Truth）
原 `1_5b_notebook_check` 重构为 `1_5b_research_check`：
- **第一步（Local Wiki 优先）**：
  1. 检查当前 handoff §5 是否引用了 `research/wiki/...` 或 `research/canon/...`；
  2. 若无显式引用，调用 `python3 research/scripts/search.py query "{handoff_task_summary}" --scope wiki --json`；
  3. 若命中相关 wiki，直接读取并展示关键结论与 `raw_refs`，耗时 < 1 秒，无网络依赖；
- **第二步（NotebookLM 回退）**：
  仅当 Local Wiki 无匹配且存在 `.tad/research-notebooks/REGISTRY.yaml` 时，尝试检索 active notebook。

---

## 4. Detailed Implementation Specifications（详细实现规格）

### 4.1 Category A: 顶层治理文档 (Files 1-2)

#### File 1: `CLAUDE.md` (单例)
- **定位**: 第 44 行。
- **现存内容**:
  ```markdown
  研究工具排除：遇到研究型任务时，不要 invoke `/deep-research` skill 或 spawn generic Agent 做 web search。用 `*research` 统一入口（默认走 NotebookLM 持久知识库）。
  ```
- **修改规格**:
  将括号内表述修改为：
  ```markdown
  用 `*research` 统一入口（主路径为 Local Wiki + Iron Rule 本地持久知识库；无 Local Wiki 时 fallback 至 NotebookLM）。
  ```

#### File 2: `research/CLAUDE.md` (单例，Verify-and-Hold - P2-4)
- **定位**: 第 41 行。
- **现存内容**:
  ```markdown
  Primary: `local_wiki`. NotebookLM is **fallback only** when `~/.tad-notebooklm-venv` missing. `research-github` writes canon, not notebook. Details: `research/canon/README.md`.
  ```
- **修改规格**:
  该文件在 2026-08-30 Local Wiki 验收时已提前合规。Blake 仅需校验其内容，**保持字节稳定（Verify-and-Hold）**，无需引入无谓改动。

---

### 4.2 Category B: Alex 技能主体 (Files 3-4, 镜像对 1)

#### File 3 & 4: `.claude/skills/alex/SKILL.md` & `.agents/skills/alex/SKILL.md`（双平台同步）
1. **Tool Quick Reference 提示 (Line ~115)**:
   - 旧: `Without this file, Alex cannot invoke NotebookLM, Codex, Gemini, or research commands.`
   - 新: `Without this file, Alex cannot invoke Local Wiki, NotebookLM, Codex, Gemini, or research commands.`
2. **Step 3.8 扫描重构 (Line ~280-295)**:
   - 旧逻辑：直接读取 `.tad/research-notebooks/REGISTRY.yaml`。
   - 新逻辑：
     1. 首先探测 Local Wiki 状态（检查 `research/canon/_index.md` 与 `research/wiki/index.md`）；
     2. 若 Local Wiki 存在，统计 canon 词条数与覆盖 topic，输出: `📚 Local Wiki: {canon_count} entries across {topics_count} topics ✅`；
     3. 其次（作为次要资产/归档）检查 `REGISTRY.yaml`，若有 active notebooks 则简要输出，无则静默；
     4. 目标对齐优先对标 Local Wiki topics，其次对标 notebook topics。
3. **Global Skill Exclusion 提示 (Line ~397)**:
   - 旧: `tad_replacement: "*research (unified — Quick/Standard/Deep, defaults to NotebookLM)"`
   - 新: `tad_replacement: "*research (unified — Quick/Standard/Deep, primary: Local Wiki + Iron Rule; fallback: NotebookLM)"`
4. **Commands Table (Line ~475)**:
   - 旧: `research: "Unified research — Quick/Standard/Deep, defaults to NotebookLM Standard"`
   - 新: `research: "Unified research — Quick/Standard/Deep, primary: Local Wiki Standard (Iron Rule); fallback: NotebookLM"`
5. **Unified Research Protocol (Line ~682-750)**:
   - *(注：P1-7 范围约束 — 本段中出现的 `ingest.sh` 与 `generate.py` 均为规范指令，本次修改仅改动 prompt 文本本身，`research/` 目录严格只读，Blake 严禁执行写脚本。)*
   - 描述更新：明确 `primary: Standard (Local Wiki + Iron Rule); fallback: NotebookLM`。
   - `preflight` 结构调整：
     ```yaml
     preflight:
       check: "test -d research/canon && test -f research/canon/lint.sh"
       on_pass: "Use Local Wiki research engine (primary)"
       on_fail: |
         Check NotebookLM fallback: test -x ~/.tad-notebooklm-venv/bin/notebooklm
         If NotebookLM available → run NotebookLM fallback path.
         If both unavailable → degrade to WebSearch.
     ```
   - `standard_execution` 步骤重写：
     - `1_check_wiki`: 运行 `python3 research/scripts/search.py query "{topic}" --scope wiki` 或检查 `research/canon/_index.md`。若已有成熟页面且满足需求，直接采纳。
     - `2_ingest_and_compile_if_needed`: 若知识库无匹配，执行 Local Wiki 编译流：抓取 3+ raw (`research/scripts/ingest.sh`) → 编写 12 字段 canon 词条 → 编译 wiki 页面（携带严格 raw_refs 及 locator）→ 跑 `research/canon/lint.sh`（6 规则必过）→ 运行 `research/scripts/generate.py`。
     - `3_fallback_notebooklm`: 仅当 `research/` 目录缺失或损坏时，调用原 NotebookLM 创建与查询流。
6. **Handoff 中的调研引用 (Line ~1076-1090)**:
   - 在 `research_citation_in_handoff` 中，新增对 Local Wiki 的第一引用顺位：
     ```markdown
     ### Research Findings (Local Wiki)
     - Topic: '{topic}' | Wiki Page: '{wiki_page}'
     - Key Carriers: [raw_ref + locator]
     ```
     原 NotebookLM 引用保留作为 Fallback。

---

### 4.3 Category C: Alex 协议引用文件 (Files 5-16, 镜像对 2-7)

#### File 5 & 6: `research-plan-protocol.md`（双平台同步，镜像对 2）
- **定位**: Step 1 与 Step 4。
- **修改规格**:
  - Step 1 (Gap Analysis): 优先检查 `research/canon/_topics.yaml` 与已有 wiki 页面是否覆盖 KR 目标，未覆盖的方列为 Gap。
  - Step 4 (Execution): 落实顶部注记中的 `LOCAL-WIKI DEEP EXTENSION`，将 Phase 1-4 的默认执行体明确为：
    - Phase 1: `research/scripts/ingest.sh` 抓取 raw；
    - Phase 2: `research/canon/` 录入规范词条；
    - Phase 3: 形式化编译 wiki；
    - Phase 4: 运行 `bash research/canon/lint.sh` 执行 6 大 Iron Rule 拦截。
  - 将 `*research-notebook` 命令段落加上明确的 `Fallback Execution (when Local Wiki absent)` 保护层。

#### File 7 & 8: `handoff-creation-protocol.md`（双平台同步，镜像对 3）
- **定位**: Step 0_5b。
- **修改规格**:
  - 旧逻辑：直接读 `REGISTRY.yaml` 查找 notebook。
  - 新逻辑：
    1. 优先在 `research/canon/_index.md` 或通过 `search.py` 检索是否有与 handoff 相关的已编译 wiki；
    2. 若找到相关 wiki，提取结论与 raw_refs 注入 handoff §📚 Project Knowledge 与 §5 Research Evidence；
    3. 仅当 Local Wiki 无命中时，才回退到 `REGISTRY.yaml` 检索 NotebookLM。

#### File 9 & 10: `discuss-path-protocol.md`（双平台同步，镜像对 4）
- **定位**: `research_notebook_awareness`。
- **修改规格**:
  - 更名为 `research_knowledge_awareness`。
  - 讨论中探测到技术方案讨论时，第一顺位建议：“已在 Local Wiki 检索到相关实践 / 要在 Local Wiki 编译一个研究课题吗？”；
  - 提供 `*research --standard` 推荐选项；仅在 Local Wiki 不在项目时提供 NotebookLM 备选。

#### File 11 & 12: `research-decision-protocol.md`（双平台同步，镜像对 5）
- **定位**: `step2_5_notebook_check`。
- **修改规格**:
  - 更名为 `step2_5_research_check`；
  - 优先通过 `python3 research/scripts/search.py query "<decision question>" --scope wiki` 检索 Local Wiki；
  - 若 Local Wiki 存在匹配，作为 Landscape Search 的权威本地基线；若不存在，才检查 `REGISTRY.yaml`。

#### File 13 & 14: `research-review-protocol.md`（双平台同步，镜像对 6）
- **定位**: `*research status` 命令流程。
- **修改规格**:
  - 将资产审查分为两部分：
    1. **Part 1 (Primary - Local Wiki)**: 审查 `research/canon/` 词条健康度、`wiki/` 覆盖面、`lint.sh` 状态及未编译 raw 语料；
    2. **Part 2 (Secondary - NotebookLM)**: 列出云端/本地注册表中的 NotebookLM 笔记本状态。

#### File 15 & 16: `learn-path-protocol.md`（双平台同步，镜像对 7 - P0-B 闭环）
- **定位**: Step 3_5。
- **修改规格**:
  - 学习测评（Quiz/Flashcards）新增支持直接基于 Local Wiki `research/wiki/` 页面生成；NotebookLM 作为备用回退。

---

### 4.4 Category D: Blake 技能与引用 (Files 17-20, 镜像对 8-9)

#### File 17 & 18: `blake/SKILL.md`（双平台同步，镜像对 8）
- **定位**: `1_5b_notebook_check` (Lines 587, 598-632)。
- **修改规格**:
  - 将 Line 587 的调用指针及 Line 598 的定义重命名为 `1_5b_research_check`（语义升级：全面涵盖 Local Wiki 与 NotebookLM）；
  - **实现逻辑变更**:
    ```yaml
    1_5b_research_check:
      description: "Check for relevant research from Local Wiki (primary) or NotebookLM (fallback) before implementation"
      action: |
        0. P1-1 early-exit: If task_type == "research" → SKIP (handled by 1_5c).
        1. Check handoff §5 Research Evidence:
           a. If Local Wiki references present (`research/wiki/...`, `research/canon/...`):
              → Read referenced wiki pages directly
              → Note key patterns and locators in context
              → Announce: "📚 Found Local Wiki research: {wiki_page} ({citable_claims} claims)"
              → Proceed to implementation (Zero latency, local truth)
        2. If no explicit reference in handoff, probe Local Wiki:
           → If test -d research/wiki:
             Run: python3 research/scripts/search.py query "{handoff_task_summary}" --scope wiki --json 2>/dev/null
             If matches found → inspect top match, note findings
        3. Fallback: If Local Wiki absent or yielded no match:
           → Check .tad/research-notebooks/REGISTRY.yaml
           → If relevant notebook found → run *research-notebook ask --notebook {id}
        4. Skip silently when neither source has relevant data.
    ```
- **定位**: `1_5c_research_task_detection` (Lines 634-718)。
- **修改规格**:
  - 当 `task_type == "research"` 时，明确 Blake 构建研究交付物的标准首选是运行 Local Wiki 工具链（`research/scripts/ingest.sh` + 编写 canon + 运行 `research/canon/lint.sh` 确保 6 规则 PASS）；NotebookLM 仅作为受限辅助。

#### File 19 & 20: `blake/references/notebooklm-access.md`（双平台同步，镜像对 9）
- **定位**: 顶部描述与适用范围。
- **修改规格**:
  - 增加显式前言说明：“本协议仅规范 Blake 对云端 NotebookLM 的受限回退访问。对于项目内的首选知识源 Local Wiki，Blake 享有常规本地文件系统读写与 `research/scripts/` 运行权限，不受本白名单约束。”

---

### 4.5 Category E: 工具速查手册 (Files 21-22, 单例)

#### File 21: `.tad/guides/tool-quick-reference-alex.md` (单例)
- **定位**: `## External CLI Tools` 及 `## TAD Research Commands`。
- **修改规格**:
  - 在 External CLI Tools 顶部明确注明：`NotebookLM is fallback only; Local Wiki is primary.`；
  - 在 TAD Research Commands 中，增加 **Local Wiki Research Suite (Primary)**：
    | Command / Script | Purpose | When to use |
    |---|---|---|
    | `python3 research/scripts/search.py query "<q>"` | Local Wiki 语义与关键词检索 | 调研前知识排查 |
    | `bash research/scripts/ingest.sh <url>` | 摄取原始语料到 `research/raw/` | 收集一手材料 |
    | `bash research/canon/lint.sh` | 机械检查 6 大 Iron Rule | Canon 词条合规校验 |
    | `python3 research/scripts/generate.py` | 纯函数生成 index 与目录 | 词条编译更新 |
    | `*research --standard "<topic>"` | 启动标准 Local Wiki 调研 | 常规方案调研 |
    | `*research --deep "<topic>"` | 启动深度 Local Wiki 调研（含对抗） | 架构与全景调研 |
  - 将 `*research-notebook` 归类至 `NotebookLM (Fallback Research CLI)`；
  - **P1-5 闭环（Line ~169 表格行点名重写）**：
    - 旧: `| *research-github notebook <domain> | Create NotebookLM notebook from registry entries | Deep study |`
    - 新: `| *research-github notebook <domain> | Create NotebookLM fallback notebook from registry entries | Deep study (cloud fallback) |`
  - **R2-3 闭环（Line ~19-20 及 ~149-160 Fallback 归类确认）**：
    - Line ~19-20 NotebookLM CLI Registry 指针保留并明确为 fallback 适用；
    - Line ~149 `*research-notebook` 小节标题显式标记为 `(Fallback Research CLI)`，其下 19 命令速查表作为 fallback 参考保留，不作过度破坏。

#### File 22: `.tad/guides/tool-quick-reference-blake.md` (单例)
- **定位**: `## NotebookLM (Blake-limited)`。
- **修改规格**:
  - 新增 `## Local Wiki Research Lookup (Primary)` 章节：
    - 说明 Blake 在实现前通过 `research/scripts/search.py` 或直接读取 `research/wiki/` 获取即时一手设计约束；
  - 将原 NotebookLM 章节标题更新为 `## NotebookLM (Fallback, Blake-limited)`。

---

### 4.6 Category F: 能力包升级与衍生协议 (Files 23-29)

#### File 23 & 24: `capability-upgrade/references/legacy-pack-research.md`（双平台同步，镜像对 10）
- **定位**: 顶部。
- **修改规格**:
  - 增加架构演进声明 Banner：
    ```markdown
    > ⚠️ ARCHITECTURE UPDATE (2026-09-08):
    > Capability Pack 升级与构建的调研地基已全面演进为 Local Wiki (`research/`)。
    > 本文档中所有关于 NotebookLM source add/ask 的操作指导，作为历史存档与云端 fallback 机制保留。
    > 编写新包或升级老包时，应优先产出 `research/canon/` 与 `research/wiki/` 词条，并通过 `research/canon/lint.sh` 形式化验证。
    ```

#### File 25 & 26: `academic-research/SKILL.md`（双平台同步，镜像对 11 - R2-4 行号漂移动态锚定）
- **定位**: 工具映射表（按 grep 'Semantic recall across sources\|Research notebook portfolio' 动态锚定，当前位于第 ~175、178、183 行）。
- **修改规格**:
  - 将 `Semantic recall across sources`（Line ~175）的首选工具更新为 `Local Wiki via search.py & canon lookup`，NotebookLM 标注为 `(cloud fallback)`；
  - 将 `Research notebook portfolio`（Line ~178）顺位调整为 `Local Wiki (research/canon/_index.md)` 为主，`.tad/research-notebooks/REGISTRY.yaml` 为辅；
  - Line ~183 涉及 cross-source synthesis ingest 建议时补充 Local Wiki 首选说明。

#### File 27: `.tad/capability-packs/academic-research/CAPABILITY.md` (单例，无镜像 - P1-2)
- **修改规格**:
  - 明确 `*research-github` 的第一产出是本地 `research/raw/github/` 与 `research/canon/` 词条（按 2026-08-28 本地 shim），将 NotebookLM 描述更新为可选云端 fallback。

#### File 28 & 29: `.claude/skills/research-github/SKILL.md` & `.agents/skills/research-github/SKILL.md`（双平台同步，镜像对 12 - P1-2 / P2-3）
- **定位**: Frontmatter lines 3, 11 以及执行协议 lines 189-200。
- **修改规格**:
  - **Line 3 (frontmatter description 行级锚定)**:
    - 旧: `description: GitHub Awesome-List Registry — discover, browse, and create deep-research notebooks from GitHub repos. 6 c...`
    - 新: `description: GitHub Awesome-List Registry — discover, browse, ingest raw GitHub repos and compile Local Wiki canon entries (with NotebookLM deep-research fallback).`
  - **Line 11 (Usage 行级锚定)**:
    - 旧: `then create deep-research NotebookLM notebooks`
    - 新: `then ingest raw GitHub repos and compile Local Wiki canon entries (with NotebookLM deep-research fallback)`
  - **Lines 189-200 (LOCAL-WIKI SHIM 扩展)**:
    - 维持并强化 2026-08-28 已引入的 LOCAL-WIKI SHIM，明确本地 `research/raw/github/` 与 `research/canon/` 词条编译为第一交付物；
  - **Lines 232-242 (Step 6/7 创建 notebook)**:
    - 保留作为次要可选的云端 fallback，注明仅在用户显式指定或需要跨仓库云端问答时执行。

---

## 5. Acceptance Criteria (验收标准)

- [ ] **AC 1 (Root Docs Alignment - P1-4)**: `CLAUDE.md:44` 移除“默认走 NotebookLM”，更新为“主路径为 Local Wiki + Iron Rule 本地持久知识库；无 Local Wiki 时 fallback 至 NotebookLM”。确认 `AGENTS.md` 维持无陈旧 NotebookLM 默认指针状态（经 grep 核验为 0 命中）。
- [ ] **AC 2 (Alex Skill Primary Path - P1-7)**: `.claude/skills/alex/SKILL.md` 与 `.agents/skills/alex/SKILL.md` 中：
  - `global_skill_exclusion.excluded_skills` 的 `tad_replacement` 明确 Local Wiki 为主、NotebookLM 为 fallback；
  - `commands.research` 与 `research_unified_protocol` 明确 Standard 默认走 Local Wiki + Iron Rule；
  - `preflight` 具备 Local Wiki 检测优先能力，缺失时才检测并 fallback 到 NotebookLM；
  - `standard_execution` 步骤体现 `check_wiki → ingest_and_compile → fallback_notebooklm` 顺序；
  - `research/` 目录严格保持 READ-ONLY，未执行任何写入动作。
- [ ] **AC 3 (Alex Research Scan Step 3.8)**: Alex 启动协议中的 Step 3.8 优先扫描并上报 Local Wiki 资产（canon 词条数与覆盖 topic），仅在存在 REGISTRY 时次要报告 NotebookLM 资产。
- [ ] **AC 4 (Blake 1_5b Research Lookup)**: `.claude/skills/blake/SKILL.md` 与 `.agents/skills/blake/SKILL.md` 中，`1_5b` 检索第一步为检查 Local Wiki 引用与运行 `search.py` 检索本地 wiki，完全消除强制等待 NotebookLM 20-40s 的阻塞痛点，NotebookLM 仅作为 fallback。
- [ ] **AC 5 (Alex Reference Protocols - P0-B)**: 包含全部 6 个核心协议文件：`research-plan-protocol.md`、`handoff-creation-protocol.md`、`discuss-path-protocol.md`、`research-decision-protocol.md`、`research-review-protocol.md`、`learn-path-protocol.md`（Step 3_5 学习测评 Quiz/Flashcards 生成支持 Local Wiki 作为首选，NotebookLM 作为备用），均完成主路径指向 Local Wiki 的改造。
- [ ] **AC 6 (Tool Quick Reference Guides - P1-5)**: `tool-quick-reference-alex.md`（含 L169 表格行）与 `tool-quick-reference-blake.md` 均新增 Local Wiki 命令集为主力调研工具，NotebookLM 明确归类为 Fallback。
- [ ] **AC 7 (Dual-Platform Parity - P1-3)**: `.claude/skills/` 与 `.agents/skills/` 对应的全部 **12 对**核心技能与引用文件保持 100% 内容与逻辑对齐。
- [ ] **AC 8 (Fallback & Charter Preservation - P0-A & R2-1)**:
  - NotebookLM 核心功能（`setup-notebooklm.sh`、`REGISTRY.yaml`、受控命令集）未被删除；
  - GM 组织与章程文件（`docs/pm/`）零新改动（Blake 在动手修改任何文件前必须执行 Step 0 双写基线快照至 `/tmp/row06.baseline` 与 `.tad/evidence/reviews/alex/research-route-local-wiki/row06.baseline`；实现后通过 ROW-06 断言与基线完全吻合、零新增 diff；确认 `docs/pm-charter.md` 不存在且未被创建）。

---

## 6. Spec Compliance Checklist (§9.1 机械比对表)

| 检查行号 | 验证项 | 验证命令 / 方法 | 期望证据 |
|---|---|---|---|
| ROW-01 | CLAUDE.md 入口指针 | `grep -n "默认走 NotebookLM" CLAUDE.md` | 输出为空（原陈旧表述已消除） |
| ROW-02 | Alex Skill 描述更新 | `grep -n "defaults to NotebookLM" .claude/skills/alex/SKILL.md .agents/skills/alex/SKILL.md` | 输出为空 |
| ROW-03 | Blake 1_5b 检索协议 | `grep -n "1_5b_research_check" .claude/skills/blake/SKILL.md .agents/skills/blake/SKILL.md` | 双文件均命中新协议节点 |
| ROW-04 | Tool Quick Ref Alex 覆盖 | `grep -n "Local Wiki Research Suite" .tad/guides/tool-quick-reference-alex.md` | 命中该章节 |
| ROW-04b | Tool Quick Ref Blake 覆盖 (P1-8) | `grep -n "Local Wiki Research Lookup (Primary)" .tad/guides/tool-quick-reference-blake.md` | 命中该章节 |
| ROW-05 | 12 对双平台镜像全量对齐 (P1-3) | `for f in alex/SKILL.md blake/SKILL.md alex/references/research-plan-protocol.md alex/references/handoff-creation-protocol.md alex/references/discuss-path-protocol.md alex/references/research-decision-protocol.md alex/references/research-review-protocol.md alex/references/learn-path-protocol.md blake/references/notebooklm-access.md capability-upgrade/references/legacy-pack-research.md academic-research/SKILL.md research-github/SKILL.md; do diff -u ".claude/skills/$f" ".agents/skills/$f" \|\| exit 1; done` | diff 循环退出码为 0（全部 12 对镜像 100% 一致） |
| ROW-06 | GM Charter 零新增变动 (P0-A & R2-1) | `BFILE=$([ -f .tad/evidence/reviews/alex/research-route-local-wiki/row06.baseline ] && echo .tad/evidence/reviews/alex/research-route-local-wiki/row06.baseline \|\| echo /tmp/row06.baseline); if [ ! -f "$BFILE" ]; then echo "BASELINE_PENDING: Blake must run Step 0 before edits"; exit 2; fi; git status --porcelain docs/pm/ \| diff -u "$BFILE" - && test ! -e docs/pm-charter.md` | diff 退出码为 0（与事前双写基线完全吻合，零新增或变动行），且 `docs/pm-charter.md` 确认不存在；若基线未初始化则明确报 BASELINE_PENDING 退出 2 |
| ROW-07 | NotebookLM 完整保留 | `test -f .tad/cross-model/setup-notebooklm.sh && test -f .tad/research-notebooks/REGISTRY.yaml` | 退出码为 0 |
| ROW-08 | Learn-Path 协议更新 (P0-B) | `grep -n "Local Wiki" .claude/skills/alex/references/learn-path-protocol.md .agents/skills/alex/references/learn-path-protocol.md` | 双文件均命中 Local Wiki 生成逻辑 |
| ROW-09 | Alex Step 3.8 扫描更新 (P1-8) | `grep -n "Local Wiki:.*canon_count" .claude/skills/alex/SKILL.md .agents/skills/alex/SKILL.md` | 双文件均命中 Local Wiki 资产扫描行 |
| ROW-10 | Alex 正向模式验证 (P1-8) | `grep -n "primary: Local Wiki" .claude/skills/alex/SKILL.md .agents/skills/alex/SKILL.md && grep -n "1_check_wiki" .claude/skills/alex/SKILL.md .agents/skills/alex/SKILL.md` | 双文件均命中 positive 模式（4 处以上） |

> **ROW-06 Step 0 (Blake pre-implementation mandatory command):**
> ```bash
> mkdir -p .tad/evidence/reviews/alex/research-route-local-wiki && git status --porcelain docs/pm/ | tee /tmp/row06.baseline > .tad/evidence/reviews/alex/research-route-local-wiki/row06.baseline
> ```
> 此命令在 Blake 动手修改任何文件前必须首先运行，建立 `/tmp` 与持久化证据目录的双写基线，彻底防范容器或机器重启导致基线丢失（R2-1 / N1）。

---

## 7. Friction Preflight (§8.4)

| 依赖项 / 前提条件 | 状态 | 说明与修复路径 |
|---|---|---|
| Python 3 及 YAML 运行库 | READY | 系统已安装 Python 3，支持运行 `research/scripts/search.py` 及 `lint.sh` |
| Local Wiki 基础设施 | READY | `research/canon/lint.sh` 与 `generate.py` 已就绪且测试绿灯 |
| 双平台文件系统权限 | READY | `.claude/` 与 `.agents/` 均具备正常写入权限 |
| 外部沙箱与审批摩擦 | READY | 本任务为文件内指针与文档规范重构，无外部网络及危险系统指令调用 |
| 工作区基线隔离 (R2-1) | READY | `docs/pm/` 预先建立双写快照文件 `/tmp/row06.baseline` 与 `.tad/evidence/reviews/alex/research-route-local-wiki/row06.baseline`，确保与他线并发修改隔离且持久化 |

---

## 8. Handoff Message to Blake & Plain-Language Summary

### 📨 Message to Blake (Agent B - Execution Master)
```
Task: Clean TAD upstream research-routing entry pointers (Local Wiki primary, NotebookLM fallback)
Handoff: .tad/active/handoffs/HANDOFF-20260908-research-route-local-wiki.md
Priority: P1
Version: 3.0 (rev3)
Scope: 6 categories across 29 files (12 mirror pairs = 24 files + 5 singletons; exactly 29 files)
Key Constraints:
1. Local Wiki + Iron Rule is PRIMARY; NotebookLM is strictly secondary FALLBACK;
2. Do NOT remove NotebookLM fallback capability (ROW-07);
3. Do NOT modify docs/pm/ beyond pre-recorded baseline (ROW-06 Step 0: run 'mkdir -p .tad/evidence/reviews/alex/research-route-local-wiki && git status --porcelain docs/pm/ | tee /tmp/row06.baseline > .tad/evidence/reviews/alex/research-route-local-wiki/row06.baseline' before first edit); confirm docs/pm-charter.md does not exist;
3b. Constrain all edits and git operations strictly to the 29 listed files; do NOT format, normalize, or touch any other dirty path in the working tree (full-tree has pre-existing dirt across ~228 entries);
4. research/ is STRICTLY READ-ONLY: run only research/canon/lint.sh and research/scripts/search.py; do NOT run ingest.sh or generate.py in any mode;
5. Maintain 100% parity across all 12 .claude/ and .agents/ mirror pairs (ROW-05).
Status: Gate2-PASS-Round3 (R2-1–R2-4 verified CLOSED per gate2-synthesis-round3.md; Blake releasable pending Human dispatch).
```

### 🗣️ 人话版说明（Plain-Language Summary）
1. **这件事改完后体验有何不同？**  
   以后当你在 TAD 中运行 `*research`，或者 Blake 在实现功能前自动检索已有研究（1_5b）时，系统不再像以前那样傻傻去连云端的 Google NotebookLM（等待 20-40 秒还可能报会话过期），而是**默认秒级检索本地的 Local Wiki**。只有当本地完全没有 Local Wiki 目录或本地没有相应材料时，才会无缝回退到 NotebookLM。
2. **为什么走这条路而不是其他路？**  
   Local Wiki 在 8 月底就已经形式化验收通过，它具备以本地 Markdown 为唯一真理源、带严格段落行号溯源（Iron Rule）的确定性优势。但框架里很多陈旧的 prompt、速查卡和技能说明还停留在过去，依然把 NotebookLM 当成唯一主角。这次重构就是让 TAD 的“言行合一”，把入口指针彻底对齐到现代架构。
3. **本次 rev3 修复了什么？**  
   根据 Gate 2 Round 2 双审判（Spec-compliance 与 Blast-radius 视角）及收敛裁定（`gate2-synthesis-round2.md`），rev3 彻底闭环了 4 项遗留点（R2-1 至 R2-4）：
   - **R2-1 (ROW-06 可操作性与生命周期)**：规范了 Step 0 双写基线机制（同时写入 `/tmp/row06.baseline` 与持久证据目录），ROW-06 脚本增加基线防空跑守卫（`BASELINE_PENDING` exit 2）；
   - **R2-2 (§8 写入权限严格对齐)**：将 §8 中的 "in write mode" 软化表述彻底修正为与 §1.3 完全一致的严禁以任何模式运行 `ingest.sh` 与 `generate.py`，只读运行仅限 `lint.sh` 与 `search.py`；
   - **R2-3 (§2.2 活跃旁路处置与条目 6 路径更正)**：更正条目 6 路径为 `.claude/workflows/pack-upgrade.workflow.js`；显式处置了 `tool-quick-reference-alex.md:19-20/:149-160`（明确作为 File 21 内部 fallback 标注保留）、`capabilities.yaml`（跨模型底层参数注册）、`research-methodology`（包加载超集声明）以及历史不可篡改/独立命名空间归口；
   - **R2-4 (笔误修复与行号动态锚定)**：消除 "8 处" 统计笔误，与扩充后的 14 项排除条目准确对齐；修正 `academic-research/SKILL.md` 工具映射表行号漂移，改为基于 grep 模式动态锚定（Line ~175/178/183）。
4. **接下来需要做什么？**  
   Alex 已将 rev3 就绪标记为 `Ready-for-Gate2-rereview`。按 TAD 规则，Alex 不得擅自宣称 Gate 2 PASS，更不能放行 Blake 实现。接下来由评审机制执行轻量 Round 3 确认（核验 4 处修改点行文并重跑 ROW-06 守卫校验），确认无误后方可推进。
