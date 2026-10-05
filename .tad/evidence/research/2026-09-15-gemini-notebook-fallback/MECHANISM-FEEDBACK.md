# TAD Research 机制试用反馈（RG1–RG4 试点）

> 试点：Gemini Notebook / TAD fallback 链（2026-09-15）。题目真实、走完 RG1→RG4。
> 总评：**机制骨架成立，RG3 是唯一在无人参与时仍稳定产出增量的闸**；最大问题是①人闸在自动化试点里无法诚实触发、②RG3 检查 RG4 才产出的 artifact（顺序 bug）、③降级路径下"轮次/饱和"引擎语义悬空。

---

## 一句话结论
RG1 的"问题 not 题目"与 RG3 的独立挑刺是**真卡住东西**的；RG2 的分级与 Phase 0c 对"决策型研究"偏形式；RG4 把三件异质的事捆在一个闸里导致边界不清。三处结构性要改：**charter/close/RG4 的人闸需要"预授权试点模式"**、**SOURCES.md 的归属前移**、**补一个"Critic 触发的补研轮"**。

---

## 逐闸反馈

### RG1 Charter —— 顺，但人闸是硬停顿
- **顺**：强制"决策问题（问题 not 题目）+ 服务哪个决策 + 够深验收线 + scope-out"确实在开头就压住了漫游。`search.py` 已有研究检查作为必填项是好的强制函数。
- **像形式**：`charter_authorization` 是一个硬停；模板只有自由文本"授权"栏，没有选项、没有"试点/预授权"通道。一次性试点里只能自决并标注——这本身是**审计诚实性风险**（要么停死跑不完，要么偷偷自决）。
- **要改**：①给 charter 增加"pre-authorized rehearsal/trial"模式（对齐 TAD 既有的 YOLO/预授权惯例），要求把授权来源写成书面出处；②`search.py` 命中噪声大（匹配到无关的 migrated 文件），建议 charter 的"已有研究检查"要求**精确主题命中**而非全文命中。
- **缺模板**：RG1/RG3/RG4 都有模板，**RG2 没有** `research-plan.md` 模板（见下）。

### RG2 Plan —— 分级合理，但对"决策型"偏形式
- **顺**：问题树 ≥3 + specificity/decision anchor + `comparison` 默认档 + 停止规则，结构清楚。
- **像形式**：RG2 定义 = "Phase 0 计划 + step2/step3 确认 + Phase 0class + Phase 0c challenge"，但这些都是引擎/人机交互件。`comparison` 档下 `run_adversarial_challenge=off`，于是 RG2 实际只剩"写计划"——而**决策型研究恰恰最需要 plan-challenge**。把最锋利的对抗步骤按 effort 档关掉，方向可疑。
- **要改**：①补 `.tad/templates/research-plan.md`；②考虑让 effort 档只控制 `run_dynamic_seeds`（深度），而 **plan/findings challenge 由 RG3 统一承担**，不再按 comparison/complex 关断。

### Rounds（引擎阶段）—— 降级路径下语义悬空
- **顺**：`ROUND-n.md` 的"本轮发现 / 还缺什么 / 新冒出的问题"很有效——本轮 R2 自然挖出"更名打断登录"这个决定性事实。
- **像形式 / 悬空**：wrapper 的 `rounds:` 直接绑定引擎 Phase 4/4b/2.5 + "Local Wiki 3-signal saturation"，而这些**全部假设 NotebookLM notebook 引擎在线**。本次实际降级到 WebSearch，Phase 4b（gap 检测/auto-enrich）、dynamic seeds 全 N/A，"轮次"退化为手动。停止规则里的"Local Wiki 3-signal saturation"在降级路径**不可用**。
- **要改**：为降级路径定义**独立的"轮"与停止语义**（例：一轮=一组子问题的新增证据；停止=charter AC 全绿或新来源边际为 0）。

### RG3 Critic —— 最强闸，但触发方式与顺序有坑
- **顺**：独立 session 真抓到硬伤：`SOURCES.md` 缺失（AC6 未达）、0.3.4 结论的**跨代际外推**、升级迁移面被低估、漏掉 typosquat 与 0.8.2 Android backend 两个角度。它**直接改变了 verdict 的边界条件**——这是机制的核心价值证明。
- **要改（顺序 bug，最重要）**：charter AC6 = "每条 load-bearing 在 `SOURCES.md` 可追溯"，而 `SOURCES.md` 由 **RG4** 产出。RG3 在 RG4 之前运行，却检查一个尚不存在的 artifact → Critic 必判 citation_accuracy ≤0.5。**这是"一个闸检查另一个闸拥有的产物"的结构缺陷。**
  - 修法 A：RG3 前先产 `SOURCES.md` 草稿（把 provenance 维护平移到每轮），RG4 只做定稿；
  - 修法 B：把 AC6 划给 RG4 自检，RG3 只查"引用是否可解析/来源是否真实"，不要求文件存在。
- **要改（独立性）**：wrapper 没规定 Critic **怎么**起。本次用 opencode 的 fresh Task subagent（与 Research Lead 同模型、不同 session）。跨模型（Codex/Gemini）本机无 Gemini、Codex 可用但未被 wrapper 要求。建议 wrapper 按 harness 写明默认起法（Claude=Task；Codex=显式子代理提示；opencode=Task).
- **要改（预算外补研）**：Critic 判 CONDITIONAL 后会要求**新证据**（本次：去核验 0.3.4 源码）。但 wrapper 视"轮次在 RG3 前已闭合"，**没有命名"Critic 触发的补研轮"**。建议显式加一个**有界补研轮（verification round）**，计入轮次预算，允许 RG3 打回一次再收。

### RG4 Verdict + Sources + Landing —— 三件异质事被捆在一起
- **顺**："verdict-first ≤3 句 + SOURCES.md（结论→来源→检索日期）"契约清楚，逼着把结论前置、把 provenance 落地。
- **像形式 / 边界不清**：RG4 同时管 (a) VERDICT.md、(b) SOURCES.md、(c) "Local Wiki canon/wiki landing（lint.sh PASS）+ human CHECK"。这三件事的可授权性不同：(c) 是**写 tracked `research/`** 的动作，需要单独授权，而本试点写 scope 限 evidence 目录 → (c) 无法执行，RG4 无法整闸"PASS"。
- **要改**：把 RG4 拆成 **process artifacts（VERDICT/SOURCES，恒做）** 与 **durable landing（Local Wiki，条件执行）** 两段；landing 单独作为一个人闸。
- **模板陈旧**：`research-decision-brief.md` 带 `Notebook:` 字段与 "Q5 WebSearch" 痕迹（NotebookLM 时代产物），且**没有"改动边界/哪些不动"一节**——而这对"改名类决策"恰是核心。建议按 RG4 契约更新：去掉 notebook 字段，增"change-scope"表。

---

## 横向结构问题（三处必须改）

1. **人闸在自动化试点里无法诚实触发（最大流程洞）**。wrapper 声明恰好 3 个人决策点（`charter_authorization`、`close_shortlist`、`material_pivot`），但一次性试跑中三处都得自决。要么停死（跑不完），要么自决（审计风险）。→ 需要一个**书面预授权试点模式**，把授权出处写进 artifact。
2. **RG3↔RG4 的 artifact 归属错位**（见上，AC6/SOURCES.md）。这是一个确定性的、可复现的机制 bug。
3. **降级路径没有一等公民语义**。wrapper/引擎假设 NotebookLM 在线；`local_wiki → notebooklm → websearch` 降级链一旦走到第三级，轮次/饱和/补研全部悬空，但 wrapper 未定义降级态。→ 显式定义降级态的执行与停止语义。

## 试点真实走通的降级链（机制未预期到的现场证据）
`local_wiki`（`search.py` 无本主题命中）→ `notebooklm_research`（本机 `~/.tad-notebooklm-venv` **不存在** → 不可用）→ `claude_websearch`（WebSearch/WebFetch，全程实际执行）。
→ 副产品：本次是这条链"第一次真正走到第三级并跑完"，也顺带证明**二级层在本机处于未部署态**。这与 findings 的 pin 风险叠加：即便部署，pin 的 0.3.4 也落在更名受影响区间。

## 未验证 / 保留
- `local_wiki` 作为 primary 的**饱和/停止信号**未被测（无命中，未进入 canon 循环）。
- RG3 的**跨模型**独立性未测（无 Gemini；Codex 未用于 findings challenge）。
- Local Wiki landing（`lint.sh`/`generate.py`）未执行（写 scope 限制）。

## 对机制的最小可落地改动清单
1. wrapper 增 `trial_mode`（书面预授权来源字段）。
2. `SOURCES.md` 归属前移（每轮维护草稿，RG4 定稿）或 AC6 改挂 RG4。
3. 增**有界 verification round**，允许 RG3 打回一次。
4. 补 `.tad/templates/research-plan.md`。
5. 拆分 RG4：process artifacts vs durable landing（landing 独立人闸）。
6. 显式定义**降级路径**的轮次/停止语义。
7. harness 默认 Critic 起法写进 wrapper（Claude/Codex/opencode）。
