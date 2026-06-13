# Capability Pack Quality Bar (双层尺)

> EPIC-20260613-capability-pack-quality-leveling — Phase 1 产物 (1a 元设计研究 + 1b 内部金标准)
> Created: 2026-06-13 by Blake | Grounded in: Anthropic 官方 skill 文档 + 社区 awesome-skills + 内部 3 个 gold-standard 包
> 用途：用统一、**可判别**的尺量 24 个能力包的质量，为 Phase 2-5 升级批次定方向。

---

## 0. 分层归属规则 (⚠️ arch P1-3：防双重计分)

每条判据**只归属一个层**。三个度量分别测 **结构 / 深度 / 行为**，互不共享判据：

| 度量 | 层 | 测什么 | 不重复计在 |
|------|----|--------|-----------|
| Layer A | 结构（元设计） | SKILL 的"组织方式"是否符合高水平开源约定 | — |
| Layer B | 深度（领域） | 规则内容是否携带研究落地的具体阈值 | Layer A |
| discriminative | 行为 | fixture 是否接入判别式评估机制（行为可测） | — |

明确归属（防同一事实灌 3 个数）：
- **CONSUMES/PRODUCES 契约** → 归 **Layer A**（结构项 A5），**不**在 Layer B 重复计。
- **fixture 是否存在** → **Layer A** 结构项（A8）；它**启用的判别式结果** → 独立的 discriminative 列（A9 只计"是否接好线"）；审计表里的 `disc` / `有无 fixture` 列是**展示 flag**，不额外计入 Layer A/B 分。
- **specN（specific-threshold 计数）** → 只喂 **Layer B**（深度），不进 Layer A。

---

## 1. Layer A — 元设计/结构 checklist （来自 FR1 开源研究）

> 来源：Anthropic 官方《Skill authoring best practices》+《Agent Skills overview》+ engineering blog
> + anthropics/skills repo + 社区 awesome-claude-skills（见 §5 Sources）。每条带"如何验证"，可 grep / 可读。
> **满分 10；通过线 = 7/10**（低于 7 = 结构不达标）。

| # | 判据 | 高水平标准（含来源具体数字） | 如何验证（可重跑） |
|---|------|------------------------------|--------------------|
| A1 | **Frontmatter load-bearing** | YAML frontmatter 含 `name`（≤64 字符，小写/数字/连字符，禁含 "anthropic"/"claude"）+ `description`（≤1024 字符，非空，**第三人称**，写明 what+when） | `grep '^name:' && grep '^description:'`；读 description 判断 what+when |
| A2 | **渐进披露（3 级）** | metadata → SKILL.md body → 按需加载的 references/scripts/assets；SKILL 不把全部内容塞进 body | `auxFiles ≥ 1`（有 references/ 或 skills/ 等辅助文件） |
| A3 | **Body 体量纪律** | SKILL.md body **< 500 行**（Anthropic 明确阈值；超出应拆分到 references/） | `wc -l SKILL.md ≤ 550`（留 50 行缓冲） |
| A4 | **路由 / 步骤结构** | Step 0/1/2 工作流 **或** "signal → reference" 路由表（progressive disclosure 的入口） | `grep -E '^##? Step [0-9]' \|\| grep -i 'load reference\|context detection\|when to use'` |
| A5 | **接口契约** | CONSUMES/PRODUCES 或明确的 scope-boundary（"this pack NEVER touches…"） | `grep -E 'CONSUMES\|PRODUCES'` |
| A6 | **Anti-skip / 反合理化表** | 列出"agent 会用什么借口跳过"+ 逐条反驳（counter-argument） | `grep -i 'anti-skip\|anti-rationaliz\|excuse\|counter'` |
| A7 | **导航索引** | Quick Rule Index / Available datasets / ## Skills 表，让 agent 一眼看全 | `grep -i 'rule index\|## contents\|## index\|available datasets\|## skills'` |
| A8 | **Fixture 存在** | `examples/*.md` 至少一个评估 fixture | `find examples -name '*.md' \| wc -l ≥ 1` |
| A9 | **评估接好线（eval-ready）** | fixture 含 `discriminative_pattern` + `min_discriminative`（接入 §3 判别式 gate，非 fallback 的 combined 口径） | `grep '^discriminative_pattern:' examples/*.md` |
| A10 | **验证脚本** | `scripts/` 或 `tools/` 有可执行校验器（确定性操作交给代码，不"punt to Claude"） | `find scripts tools -type f` |

**Layer A 还隐含的"软"约束**（不单独计分，但负样例会暴露）：references **一级深**（不嵌套）；ref 文件 >100 行需 TOC；术语一致；无 time-sensitive 信息（用 "old patterns" 段隔离）；不给"太多选项"（给默认 + escape hatch）；脚本无 voodoo constants；路径用正斜杠（非 Windows `\`）。来源：Anthropic best-practices（§5）。

---

## 2. Layer B — 领域深度评分维度 （来自 FR2 内部金标准）

> 锚点：`web-ui-design` / `web-frontend` / `web-backend`（最成熟，含 checklist + 验证脚本 + CONSUMES/PRODUCES + production-incident 规则）= **Layer B 5 分参照**。
> ⚠️ **NFR4 判别保证**：不用"gold=5"单端锚点（可刷分）。用 **0/2/5 操作化锚点** + 一个 **可计数子维度** + 一个 **Layer B negative control**（§4）。

### 2.1 操作化锚点（0/2/5）

| 档 | 操作化定义（判别口径） |
|----|------------------------|
| **0-2** | 规则可被**前沿 LLM 无研究即复述**出来（"use sufficient sample size" / "write good tests" / "secure your API" / "cache when slow"）。通用原则，无 pack 独有信息。 |
| **5** | 规则携带**研究落地的具体数字/阈值/退出码**——LLM 单凭训练数据产不出来。对标 pack-evaluation 2026-05-15 的 specific-threshold 信号：`n≥550`、`exit code 183`、`ICC>0.92`、`10-32x token 成本比`、`50M rows offset 翻车`、`p95`、`preStop sleep`。 |
| 3-4 | 介于之间：有部分具体阈值/命名工具，但仍混入可复述的通用条目。 |

### 2.2 四个深度维度（reading-based，0/2/5 各打，取综合）

| 维度 | 0-2（浅） | 5（深） |
|------|-----------|---------|
| **B1 规则具体度** | 通用原则 | 携带研究阈值/退出码/具体数字 |
| **B2 工具时效性** | 只列工具名 | 命名 CLI + 版本 + 用法（教 agent 怎么用，非清单）；无 time-sensitive 失效信息 |
| **B3 quality_criteria 可操作化** | "要做好" | 分级 checklist（Tier 1/2/3）+ 严重度（P0/P1/P2）+ 可执行验证 |
| **B4 anti-pattern 覆盖** | 无 | 来自生产事故的失败模式 + 具体补救（如 K8s preStop、offset 翻车） |

### 2.3 可计数子维度（NFR4c — 非纯 LLM gestalt）

**specN = specific-threshold 计数**：在 SKILL.md + references/ + skills/ + checklists/ + adapters/ 上跑判别式 alternation，取**去重匹配数**：

```bash
DISC='(≥|≤|>=|<=|exit code|exit [0-9]|n ?= ?[0-9]|n ?≥|ICC|p9[0-9]|[0-9]+ ?rps|[0-9]+ ?ms|[0-9]+x|[0-9]+×|[0-9]+%|[0-9]+\.[0-9]+|[0-9]+ ?(KB|MB|GB|tokens|rows|req))'
P=.claude/skills/<pack>
# ⚠️ pack-anchored paths + parens (code-review P2-1 fix): bare '*/skills/*.md' over-matches the
# whole pack tree because packs live under .claude/skills/. Anchor to "$P/..." and wrap the -o chain.
find "$P" \( -name 'SKILL.md' -o -path "$P/references/*.md" -o -path "$P/skills/*.md" -o -path "$P/checklists/*.md" -o -path "$P/adapters/*.md" \) | xargs env LC_ALL=en_US.UTF-8 grep -hoE "$DISC" | sort -u | wc -l
# ⚠️ LC_ALL=en_US.UTF-8 REQUIRED (Batch 2 fix 2026-06-13): DISC contains multibyte ≥ ≤ × ; under
#    macOS default C/POSIX locale grep won't match them → specN wrongly returns 0 (bucket 1).
#    product-thinking surfaced this: 0 under C locale → 32 under UTF-8 (bucket 3). Always set the locale.
# specN computed 2026-06-13; ±2 drift expected from dedup — bucket-stable, NOT a regression on Gate 3 re-run.
```

specN→Layer B 桶（gold 包直接锚 5，其余按 specN 初判后 reading 微调）：specN≥60→5｜40-59→4｜25-39→3｜15-24→2｜<15→1。
⚠️ **specN 是 ONE 个输入，不是 Layer B 全部**：gold 包 web-backend specN 仅 27（深在 operationalized criteria，非 raw 数字密度），所以 gold 由 FR2 定义锚 5，specN 只对非 gold 包做初判。**单维 specN 会误排 gold**——故 Layer B 综合分带置信度，边界包在每批入口重打分（§BASELINE 可重排声明）。

---

## 3. 判别式 gate 接入（复用，不重造 — NFR3）

每个有 fixture 的包用现有 **`.tad/scripts/pack-eval-runner.sh`** 的 `discriminative_pattern` 机制做**行为分量**，**不另写评分逻辑**：

- runner 把一个**捕获的 agent 输出**对 fixture 的 `discriminative_pattern`（仅 pack 独有 marker 的 `grep -oE` alternation）做断言，PASS iff `disc_count ≥ min_discriminative`。
- combined `## Verification Command` 计数混了通用 marker，**只作 SECONDARY 上下文数**，不驱动 PASS（否则 no-pack control 也能过 = validation theater）。
- 本 Phase 的 `disc` 列 = **eval-harness 接线就绪度**（fixture 是否含 `discriminative_pattern`+`min_discriminative`，vs 退回非判别的 combined fallback）。**逐包跑新鲜 WITH/CONTROL 行为评估是 Phase 2-5 每批的 DoD**，不在基线重造。
- 判别机制本身的有效性已有实证（**引用，不重跑**）：`.tad/evidence/pack-eval/2026-05-31/` — ai-evaluation CONTROL（无 pack）disc **0/3 → FAIL**，WITH（有 pack）disc **5/3 → PASS**，证明该 gate 真能判别。

---

## 4. Negative Control 证明（两个，对称 — NFR1 + NFR4b）

> ⚠️ 头号风险 = validation theater。一把尺只有当**正例能过、反例过不了**时才被证明能判别。
> 以下是**实跑输出**（脚本 + 样例在 `.tad/evidence/pack-quality/negative-controls/`），不是只出现"negative control"字样。

### 4.1 Layer A negative control — 故意劣质**结构**样例 → 必须 FAIL

样例 `negative-controls/bad-structure-SKILL.md`：无 frontmatter、1506 行单体 prose、0 辅助文件、无路由、无契约、无 anti-skip、无索引、无 fixture、Windows 路径脚本。对 §1 的 10 条判据实跑打分：

```
A1 frontmatter(name+description): FAIL
A2 progressive-disclosure(aux files): FAIL (0 aux files)
A3 body-size discipline: FAIL (1506 lines > 550)
A4 routing/steps: FAIL
A5 CONSUMES/PRODUCES: FAIL
A6 anti-skip table: FAIL
A7 navigation index: FAIL
A8 fixture present: FAIL (0 examples)
A9 discriminative_pattern wired: FAIL (no fixture)
A10 validation scripts: FAIL (Windows path scripts\helper.py; none executable)
>>> LAYER A SCORE = 0/10 → VERDICT: FAIL (pass threshold = 7/10)
```

✅ 判别成立：劣质结构 0/10 远低于通过线 7。（注：初版样例曾在 prose 里写了 "CONSUMES/PRODUCES"/"anti-skip" 字样导致 grep 误命中 2 分——已清除该 **self-leak**，与 ac-verification.md 的 self-leak 防范一致。）

### 4.2 Layer B negative control — 故意浅薄**领域**样例 → 必须 ≤2

样例 `negative-controls/shallow-depth.md`：6 条全可被 LLM 无研究复述的通用规则。实跑 specN：

```
specific-threshold count (counted sub-dimension NFR4c): 0
Every rule restatable by a frontier LLM with NO research (0/2/5 anchor: 0-2 band).
>>> LAYER B SCORE = 1/5 → VERDICT: FAIL (must be ≤2; got 1 ✓ ≤2 confirms the rubric flags shallow content)
```

✅ 判别成立：浅薄内容 specN=0、Layer B 1/5 ≤ 2，与 NFR1 对称。

---

## 5. Sources (NFR2 固定锚点 — Gate 3 在此重跑核对)

> 元设计研究 findings 的 source URL + 检索日期。持久化 NotebookLM：
> **notebook_id `b29b362d-2364-40d0-968b-41bf265a1225`**（"Capability Pack Meta-Design"，6 sources，已注册 REGISTRY.yaml id=`capability-pack-meta-design`）。

| # | Source | URL | 检索日期 | 提供的判据 |
|---|--------|-----|---------|-----------|
| S1 | Anthropic — Skill authoring best practices | https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices | 2026-06-13 | A1(name≤64/desc≤1024,第三人称)、A3(body<500行)、references 一级深、ref>100行需TOC、≥3 evals、测 Haiku/Sonnet/Opus、no voodoo constants、no Windows path、no time-sensitive、给默认+escape hatch |
| S2 | Anthropic — Agent Skills overview | https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview | 2026-06-13 | 3 级渐进披露（metadata→body→references）、SKILL.md 必备 frontmatter 才注册、scripts/references/assets 目录约定 |
| S3 | Anthropic Engineering — Equipping agents for the real world with Agent Skills | https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills | 2026-06-13 | 渐进披露设计原则、composability（unbounded context / mutually-exclusive paths）、scripts vs prose 选择、eval-first |
| S4 | anthropics/skills（官方 repo） | https://github.com/anthropics/skills | 2026-06-13 | 官方 skill 目录结构实例（SKILL.md + scripts/ + references/） |
| S5 | travisvn/awesome-claude-skills（社区） | https://github.com/travisvn/awesome-claude-skills | 2026-06-13 | 社区 SKILL.md 约定共识、/skill-name 调用、169 skills 跨 13 类目录 |
| S6 | ComposioHQ/awesome-claude-skills（社区） | https://github.com/ComposioHQ/awesome-claude-skills | 2026-06-13 | 社区约定佐证、agnix linter（156 rules 校验 SKILL.md）= 结构可机检的旁证 |

本地一等来源（直接读，非 web）：Anthropic 官方 `frontend-design` SKILL（`~/.claude/plugins/.../frontend-design/skills/frontend-design/SKILL.md`，2026-06-13 读）——精简 frontmatter(name+desc+license) + 正负框架（commit to direction + NEVER generic）的范例；内部 gold `web-ui-design`/`web-frontend`/`web-backend` 的 SKILL.md（2026-06-13 读）。

---

## 6. ⚠️ Phase 2-5 DoD 备注（arch S3 前置 — 跨模型对抗审查）

后续每个升级批次的 Definition-of-Done 必须包含**跨模型对抗审查**（Codex/Gemini），因为 same-model 自审对**事实/API 正确性**有系统盲点（pack-evaluation 2026-06-01：全 Claude loop 漏掉 ~44 个类名/弃用 API/metric 类型错误，Codex 全抓到）。但：

- **NEVER 盲信 reviewer 的 P0**——对版本敏感断言（API 名/版本号/弃用/metric 类型）**先查当前原始文档**（WebSearch）再改。
- 预算 reviewer **自身约 2/N 会错**（同篇实证：Codex 2 个 headline P0 是 Codex 自己错了，pack 是对的）。
- verify 阶段必须**独立核查**，不能信前一 reviewer 的 verdict，否则传播其错误。

升级 DoD 还须（per principles YOLO 审计 2026-05-15）：每包 **3-5 个 before/after 行为评估** + 固定 rubric，跑新鲜 WITH/CONTROL（§3 的 pack-eval-runner.sh），negative control 必须 FAIL，才能标 accepted。
