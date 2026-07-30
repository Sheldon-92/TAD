---
# Quality Chain Metadata (Alex 必填)
task_type: mixed      # markdown SKILL 协议文件 + CLAUDE.md 路由 + Codex 镜像
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-07-30
**Project:** TAD Framework
**Task ID:** TASK-20260730-001
**Handoff Version:** 3.1.2 (v3 — R1 12 P0 + R2 incremental re-review findings all integrated)
**Epic:** N/A
**Supersedes:** N/A

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-07-30

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 集成面五层全覆盖：skill 入口 / CLAUDE.md 三处 / handoffs 目录 consumer 集（glob 实测）/ 蒸馏接线（声明为 follow-up）/ Codex 镜像 |
| Components Specified | ✅ | 两 SKILL 逐节规格（含哨兵块、L0.5、生命周期 mv）+ CLAUDE.md 精确 diff |
| Functions Verified | ✅ | N/A — markdown 协议文件；引用的 Agent/AskUserQuestion 为平台原生工具 |
| Data Flow Mapped | ✅ | LITE 文件单载体状态机：位置即状态（active/=pending, archive/=done），Completion 段 append |

**Gate 2 结果**: ✅ PASS（R1: 2 experts CONDITIONAL PASS，12 P0 整合；R2 增量复核: 1 STILL-BROKEN + 9 新缺陷 → v3 全部定点修复，架构零改动；见 §9.2 Audit Trail 末行）

**Alex确认**: 我已验证所有设计要素，Blake可以独立根据本文档完成实现。

---

## 📋 Handoff Checklist (Blake必读)

- [ ] 阅读了所有章节（尤其 §9.2 Audit Trail——每条 P0 修复都已编入 §4/§9.1，实现时勿回退）
- [ ] **阅读了「📚 Project Knowledge」章节中的历史经验**
- [ ] 理解了真正意图（不只是字面需求）
- [ ] 确认可以独立使用本文档完成实现

---

## 1. Task Overview

### 1.1 What We're Building

**TAD Lite 通道**：两个自包含的轻量 slash skill（`/alex-lite` + `/blake-lite`），提供设计→实现→审查→验收的极简 TAD 流程。目标：一个任务周期 token 成本较 full TAD（300K-1M）下降一个数量级，同时保留 TAD 四条不可再减的精髓。**成本目标由 AC13 dogfood 实测检验，不是纸面声明。**

### 1.2 Why We're Building It

**业务价值**：full 流程在 Claude Code / Codex / Kimi 上过度消耗额度（激活固定费 ~60K+40K + 每周期 6-12 subagent spawn）。
**用户受益**：简单任务和额度紧张时有一条可信的低成本通道。
**成功的样子**：`/alex-lite` → 一页纸计划 → 人确认 → `/blake-lite` 实现 + 1 个独立 reviewer → 人验收 → LITE 文件自动归档。全程 1 次 subagent spawn（常规路径）。

### 1.3 🆕 Intent Statement（意图声明）

**真正要解决的问题**：流程成本 + 激活固定成本两刀一起砍，保住四条精髓：
1. 出货前必有一个**非自己**的视角（fresh-context reviewer subagent，禁止自审替代）
2. 实现前必有**写下来的契约**（一页纸 LITE handoff）
3. **人在关键点拍板**（计划确认 + 最终验收）
4. **AC 可运行、真验证**

**不是要做的（避免误解）**：
- ❌ 不修改 full TAD 协议文件（alex/blake/gate SKILL.md、config、hooks 全不碰）
- ❌ 不替代或修改 *express（并存）
- ❌ 不注册 hook、不修改 settings.json / settings.local.json
- ❌ 不做 full 的自动降级——入口用户显式选择，full Alex 不自动推荐 lite（NOT_via_suggestion 对称设计，且 escalated_review 子模式同样禁止 alex-lite 主动建议）

---

## 📚 Project Knowledge（Blake 必读）

**⚠️ Blake 必须注意的历史教训**：

1. **Circular Trigger / Codex 不跟随 references** (patterns/handoff-design.md 2026-06-09)
   → 两个 lite SKILL.md **100% 自包含单文件**：零 references/、零 config 加载、零 load_when。
2. **Intent Router 5 层集成** (2026-02-16) + 本次专家审查实证
   → 集成面五层：skill 入口 / CLAUDE.md（§1+§2.5+§3 三处）/ handoffs 目录 consumer 集 / 蒸馏接线 / Codex 镜像。§4.3 的 CLAUDE.md 修改一处都不能少。
3. **Mirror parity** (patterns/release-sync.md 2026-07-12)
   → `.agents/skills/` 镜像 byte-identical（cmp 验证）。
4. **Platform Capability Assumptions Decay Fast** (2026-06-08)
   → 用户报告 Codex `$` 唤起有退化迹象；AC12 实测并记录**原始 transcript**。
5. **Claims Need Carriers** (patterns/gate-design.md 2026-06-10)
   → lite 的 completion 载体 = LITE 文件的 `## Completion` 段；本 handoff 的成本声明载体 = AC13 dogfood 实测记录。
6. **`.tad/memory/` TAD 侧只读契约** (DR-20260712)
   → 知识捕获写 `.tad/evidence/journal/lite-discoveries.md`（先 `mkdir -p`）。
7. **Validation Theater** (principles.md 2026-05-15) + **Measure Before Optimizing** (2026-03-23)
   → 结构 AC 证明文件存在，不证明通道便宜好用。AC13 dogfood 是本 handoff 的反 theater 条款，不可降级为纸面。

### Blake 确认
- [ ] 我已阅读上述历史经验

---

## 2. Background Context

### 2.1 Previous Work
- 现有轻量机制 *express / light_tad / 跳过 TAD——都骑在 full 激活上，砍不到固定成本（MQ1/MQ6）。
- express 的 `NOT_via_alex_suggestion` 三规则是入口与 escalated 子模式的设计参照。

### 2.2 Current State（实测 2026-07-30）
- `.claude/skills/` 无 alex-lite/blake-lite；CLAUDE.md 100 行，`grep -c 'alex-lite'` = 0，`grep -c 'LITE-'` = 0
- **handoffs 目录 consumer glob 实测**（arch-P0-3 要求，Alex 已跑）：

| Consumer | 实际 glob | 对 LITE 行为 | 处置 |
|----------|----------|-------------|------|
| Alex 僵尸检测 (alex/SKILL.md L225) | `HANDOFF-*.md` | 隐形 | mv-on-acceptance 生命周期兜底 |
| Blake 激活规则 (blake/SKILL.md L21) | `*.md` | **会捡走 LITE** | CLAUDE.md §2.5 互斥条款 |
| Blake 启动扫描 (blake/SKILL.md L188) | `HANDOFF-*.md` | 安全 | — |
| tad-maintain (SKILL L101/L116) | 遍历目录，slug 规则只识别 HANDOFF-/COMPLETION- | 未识别类 | 生命周期兜底（accepted 即离开 active/） |
| PreCompact hook (L129) | `HANDOFF-*.md` | 隐形 | 可接受：LITE 文件自身即恢复载体（skills 内写明恢复指引） |

### 2.3 Dependencies
- 无外部依赖。AC12 需 `codex` CLI（见 §8.4）。

---

## 3. Requirements

- **FR1**: `.claude/skills/alex-lite/SKILL.md`——自包含，≤300 行（目标 ~250）
- **FR2**: `.claude/skills/blake-lite/SKILL.md`——自包含，≤300 行（目标 ~250）
- **FR3**: CLAUDE.md 三处修改（§1 豁免行 + §2.5 新块 + §3 作用域行），**新增 ≤10 行、删除 0 行**（预算从 4 行放宽：两位专家独立确认 §3/§4 冲突必须显式豁免，正确性优先于最小化；见 §11 决策）
- **FR4**: `.agents/skills/{alex-lite,blake-lite}/SKILL.md` 镜像 byte-identical
- **FR5**: 升级阀门（先判断后干活）+ 哨兵块清单 + fatal 无例外 + escalated_review 用户原话授权，写入两个 skill
- **FR6**: 知识捕获：blake-lite Completion 固定一问 → `mkdir -p` 后 append 一行到 `.tad/evidence/journal/lite-discoveries.md`
- **FR7**: LITE handoff 一页纸模板内嵌 alex-lite 正文
- **FR8**: Codex 调用路径实测（verbatim 命令 + 原始输出 transcript）记录进 `.tad/codex/README.md`
- **FR9** (新增, arch-P0-3/P0-4): LITE 文件生命周期 = 位置即状态：人验收后 blake-lite `mv` 到 `.tad/archive/handoffs/`
- **FR10** (新增, arch-P0-5): dogfood——用一个 throwaway 任务跑一次完整 lite 周期并实测成本（AC13）
- **NFR1**: 零 hook 注册、零 settings*.json 修改、零 full 协议文件修改
- **NFR2**: 纯 markdown，无脚本依赖

---

## 4. Technical Design

### 4.1 alex-lite/SKILL.md 内容规格（措辞可润色，条款不可减；⚠️ 标注处为专家审查修复点，不可回退）

```
frontmatter:
  name: alex-lite
  description: TAD Lite 设计侧——轻量任务的一页纸设计与 handoff。用户显式调用（/alex-lite）。
    适用：≤5 文件、非协议契约的小任务，或额度紧张时。复杂任务用 /alex。

## 身份
Alex-Lite（Solution Lead, Lite）。只设计不写实现代码。中文交流。
激活即就绪——不加载任何 config、不跑健康扫描、不额外主动读取 project-knowledge。
（⚠️ arch-P2-1：措辞是"不额外主动读取"——@import 是 session 常量，不归 lite 省）

## L0 适用性检查（第一步，先判断后干活 ⚠️ BLOCKING）
对照下方升级清单。命中 → 停止："此任务建议走 full TAD（/alex）：{命中原因}"

<!-- ESCALATION-LIST-BEGIN -->                       ⚠️ CR-P1-1：哨兵块，两文件逐字节相同
升级清单（命中任一 → full TAD）：
1. SAFETY 面：修改 .tad/project-knowledge/principles.md、patterns/ 中标 SAFETY 的条目、
   .tad/project-knowledge/patterns/_index.md
2. 协议契约面：.claude/skills/*/SKILL.md、.agents/skills/*/SKILL.md、CLAUDE.md、
   .tad/config*.yaml、.tad/hooks/、.claude/settings*.json（含 settings.local.json）、
   .claude/agents/、.claude/workflows/、tad.sh、.tad/active/epics/
   （⚠️ arch-P1-2/CR-P1-2：镜像、安装器、local settings、agent 定义都是契约）
3. 规模/耦合面：预计总改动 >5 个文件；或改动被下游项目消费 / 被 >3 处引用的文件
4. Fatal operations：支付/认证/批量数据删除/生产部署配置/依赖升级（lockfile、版本 pin）/
   release·publish·sync 操作/破坏性 VCS 操作（force-push、删分支、改历史）
兜底（⚠️ arch-P1-1，放最后作 catch-all）：清单未覆盖但你无法确信影响面 → 升级 full。
例外：命中第 1-3 类且用户明确坚持用 lite → escalated_review 模式（见下）。
第 4 类（fatal）无例外，必须 full。
<!-- ESCALATION-LIST-END -->

escalated_review 授权规则（⚠️ CR-P1-6/arch-P1-5：例外不是政策）：
- 仅当用户主动、明确坚持时触发；写入 handoff 时必须带用户原话：
  escalated_review: yes (用户原话: "{逐字引用}")
- alex-lite 禁止主动提供、建议或默认此选项（NOT_via_suggestion 镜像）

## L1 理解（最多 1 轮）
复述任务理解（2-3 句）。边界或 AC 不清 → 最多 1 次 AskUserQuestion（≤4 问）。
清楚就直接进 L2，不问是常态不是偷懒。

## L2 一页纸 handoff
先检查（⚠️ arch-P0-4/CR-P2-6）：
- .tad/active/handoffs/ 中已有其它 LITE-*.md（pending）→ 提示人先处理，再创建
- 目标文件名已存在 → 停，请人确认覆盖或换 slug
写 .tad/active/handoffs/LITE-{YYYYMMDD}-{HHMM}-{slug}.md（⚠️ arch-P2-5：HHMM 消同日歧义），
内嵌模板（⚠️ 无 Status 字段——位置即状态：active/=pending, archive/=done）：
  # LITE Handoff: {title}
  **Date**: {date} | **escalated_review**: no | yes (用户原话: "...")
  ## 目标（2-3 句，含"为什么"）
  ## 不做什么
  ## 文件清单（创建/修改，逐个路径）
  ## AC（每条 = 一个可运行命令 + 期望输出；禁止"功能正常"类不可验证表述）
  ## 风险与注意

## L3 STOP — 人拍板
输出计划摘要，请人确认。确认后提示：
"请由你在本 terminal（或新开 Terminal 2）输入 /blake-lite 继续。"
（⚠️ CR-P0-4：角色切换由人输入命令完成，agent 不得自行调用——同 terminal 是人的选择，
不是 agent 的行为，因此不违反 CLAUDE.md §4）
压缩后恢复（⚠️ arch-P1-7）：重读 active/ 中唯一 pending 的 LITE-*.md + 重跑 /alex-lite；
不要运行 /alex 或 /blake（会进入 full 重模式）。

## 精髓（不可妥协的四条）
1. 角色分离：alex-lite 永不写实现代码
2. 契约：没有 LITE handoff 文件就没有实现
3. 独立审查：blake-lite 的 reviewer 不可跳过
4. AC 真验证：不可运行的 AC 不许写

## Forbidden
- 写实现代码 / 自行调用 blake-lite 或用 Agent tool 实现任务 /
  加载 TAD 协议、配置或知识文件（.claude/skills/*/、.tad/config*.yaml、
  .tad/project-knowledge/、任何 references/）——读写自身 LITE 契约文件除外
  （⚠️ arch-P1-3 措辞）/
  调用设计期专家审查 subagent（escalated 的 L0.5 属 blake-lite）/ 写 session-state.md /
  主动建议或默认 escalated_review（⚠️ CR-P1-6）/
  在无用户明示坚持时设置 escalated_review: yes / EnterPlanMode（⚠️ CR-P2-5）/
  修改 LITE 契约之外的任何文件
```

### 4.2 blake-lite/SKILL.md 内容规格

```
frontmatter:
  name: blake-lite
  description: TAD Lite 实现侧——按 LITE handoff 实现 + AC 自验 + 独立 reviewer + 归档。
    用户显式调用（/blake-lite）。

## 身份
Blake-Lite（Execution Master, Lite）。只按 LITE handoff 实现。中文交流。激活即就绪。

## L0 读契约 + 准入（⚠️ BLOCKING，白名单 CR-P0-6）
1. 定位：用户指定路径，或 .tad/active/handoffs/ 中 basename 匹配 LITE-*.md、
   按文件名日期时间排序最新的一个。多个候选无法唯一确定 → 停，列出全部，请人指定。
2. 准入白名单：basename 必须匹配 LITE-*.md。
   - 在 active/ 且**已有** `## Completion` 段 → 待验收态（L4 与 L5 之间）：
     跳至 L5 输出 Completion 摘要等人验收，**不得重跑实现**（⚠️ R2 ND-3：
     此分支同时是压缩后恢复的落点——否则恢复指引会撞上拒绝分支形成死路）
   - HANDOFF-*.md → 拒绝："full handoff 请走 /blake"
   - EPIC-*/COMPLETION-*/其它任何文件 → 拒绝，说明应走的通道
   - 无 LITE 文件 → 停："请先用 /alex-lite 生成计划"（口头需求不是契约）
3. 适用性复查（⚠️ CR-P0-3 三分支；清单 = 下方哨兵块，与 alex-lite 逐字节相同）：
   - 命中第 4 类 fatal operations → 无条件停止，"必须走 full TAD"
     （escalated_review 不构成例外）
   - 命中第 1-3 类且无 escalated_review: yes → 停止，建议转 full
   - 命中第 1-3 类且有 escalated_review: yes → 检查用户原话记录；
     无原话 → 停，请人确认（⚠️ CR-P1-6）；有 → 进 L0.5
   - 未命中 → 直接进 L1

<!-- ESCALATION-LIST-BEGIN -->
（与 §4.1 哨兵块内容逐字节相同——Blake 实现时直接复制，AC9 用 diff 机械验证）
<!-- ESCALATION-LIST-END -->

## L0.5 升级审查前置（仅当 escalated_review: yes ⚠️ BLOCKING，CR-P0-2）
spawn 1 个 code-reviewer subagent 审 LITE handoff 设计本身：
"Read {LITE handoff 路径}。这是敏感文件任务走 lite 的升级审查：目标/文件清单/AC
 是否覆盖敏感面（哨兵清单第 1-3 类的具体命中项）？输出 P0/P1/P2 + verdict。"
verdict FAIL 或有 P0 → 停，报告人回 /alex-lite 修订，不得进 L1。
（L3 的实现后 reviewer 照常执行；L0.5 + L3 合计 = escalated 的 2 个 reviewer）

## L1 实现
按文件清单实现。纪律（⚠️ CR-P1-5/P2-4）：
- 任何清单外改动必须在 Completion 的"改动文件"中标注 [清单外]
- 总改动文件数（含清单外）>5 → 停，报告人（scope 膨胀 = 设计漏判信号）
- 发现 handoff 目标/AC 本身有错 → 停，报告人回 /alex-lite 修订（不自行改契约）

## L2 AC 自验
逐条运行 AC 命令，记录原始输出。FAIL → 修复后重跑。全绿进 L3。
合法出口（⚠️ CR-P1-3）：某条 AC 客观无法通过（环境/前提缺失，非实现缺陷）→ 停，
报告人 "AC{n} BLOCKED: {原因}"，请人裁定降级或回 /alex-lite 修订。
禁止：自行放宽 AC、跳过该条、以"等价验证"替换。

## L3 独立审查（⚠️ MANDATORY——express 教训：小改不等于免审，2026-04-14 一次
15 分钟小改被审出 4 个 P0。此步不可以任何理由跳过）
spawn 1 个 code-reviewer subagent（Agent tool），prompt（⚠️ CR-P0-1/arch-P1-6 修正版）：
  "Read {LITE handoff 路径}。改动文件清单见 handoff §文件清单。
   用 `git status --short` 确认实际改动集；
   已跟踪文件用 `git diff HEAD -- {清单路径}` 看 diff；
   新建文件直接 Read 全文。禁止仅凭 `git diff` 判断——新建文件不出现在 git diff 中。
   发现清单外的改动 hunk → 报 P0 scope-violation。
   改动集以 handoff §文件清单为准；与本任务无关的仓库既有未提交项**忽略**，
   不计 scope-violation（⚠️ R2 ND-5：仓库常有会话既有脏文件，reviewer 无基线会误报）。
   对照 handoff 检查：(1) spec 符合性 (2) 代码质量（bug/边界/安全）。
   输出 P0（必修）/P1（应修）/P2（建议）+ verdict PASS/CONDITIONAL/FAIL"
（⚠️ CR-P1-4：禁止把实现过程的推理/结论塞进 prompt——reviewer 必须独立判断）
P0 → 修复 → 重跑受影响 AC → Completion 记录修复说明。
P0 修复若改动了 reviewer 未见过的文件 → 追加同 reviewer 增量复核（只给 fix 部分，
成本 ≈1/5 首轮）（⚠️ CR-P2-3）。

## L4 Completion（append 到 LITE handoff 文件末尾）
  ## Completion ({date})
  **Commit**: {hash 或 uncommitted}
  - 改动文件：{列表，清单外标 [清单外]}
  - AC 结果：逐条 ✅/❌/BLOCKED + 实际输出摘要
  - Reviewer: {verdict}, P0={n}(fixed), P1={n}, 摘录关键发现原文
  - 意外发现：无 / 一行描述
若有意外发现 → mkdir -p .tad/evidence/journal/ 后 append 一行：
  "- {date} [{slug}] {一行发现}" >> .tad/evidence/journal/lite-discoveries.md
（此文件的蒸馏消费接线是 full TAD 侧的 follow-up，见主 handoff §10.2）

## L5 STOP — 人验收 + 归档
输出 Completion 摘要，等人验收。
人验收通过后（⚠️ FR9/arch-P0-3）：mkdir -p .tad/archive/handoffs/ 并
mv 该 LITE 文件到 .tad/archive/handoffs/（位置即状态：离开 active/ = done）。
是否 git commit 由人决定——blake-lite 不主动 commit。
压缩后恢复（⚠️ arch-P1-7）：重读 active/ 中唯一 pending 的 LITE-*.md + 重跑 /blake-lite；
不要运行 /alex 或 /blake。

## Forbidden
- 跳过 L3 reviewer（任何理由，包括"改动很小"）/
  以自审、自我复核替代 subagent spawn（⚠️ CR-P1-4）/
  修改 handoff 的目标或 AC / escalated_review: yes 却跳过 L0.5 直接进 L1（⚠️ CR-P0-2）/
  命中升级清单却不按 L0 step3 三分支处理 /
  git commit 或 push（人验收后由人决定）（⚠️ CR-P1-5）/
  人验收前归档或移动 handoff 文件 / 写 .tad/project-knowledge/（蒸馏归 full TAD）/
  修改 settings*.json 或注册 hook / 写 session-state.md /
  写 .tad/memory/（native 管辖）/ EnterPlanMode /
  加载 TAD 协议、配置或知识文件（读写 LITE 契约文件与 lite-discoveries journal 除外）
```

### 4.3 CLAUDE.md 精确修改（⚠️ CR-P0-4/arch-P0-1 修正版；新增 ≤10 行、删除 0 行）

**位置 1 — §1 末尾（"豁免：`/tad-maintain` CHECK/SYNC 模式。"之后加 1 行）**：
```
豁免 2：`LITE-*.md`（TAD Lite 通道，见 §2.5）→ 本节规则不适用，含"跳过 Gate/不通过 Blake"禁令。
```

**位置 2 — §2 末尾新增块（§2.5，6 行）**。⚠️ R2 ND-4 插入位置精确化：插在 §2 最后一行
（"研究工具排除…"行）**之后**、`## 3` 标题**之前**——勿插在表格正下方，否则 §2 尾部
四行散文（跳过 TAD/Adaptive Complexity/Epic/研究工具排除）会被吞进 2.5 标题下语义改写：
```
### 2.5 Lite 通道（用户显式选择，Alex 不自动推荐）
`/alex-lite` → `/blake-lite`：≤5 文件、非协议契约的小任务，或额度紧张时。契约文件 `LITE-*.md`。
豁免：§1 handoff 规则、§3 规则 0-5 对 Lite 不适用，代之以内置约束——一页纸契约 +
实现后强制 1 个 fresh reviewer（禁自审替代）+ 人两次拍板 + AC 可运行 + 验收即归档。
方向互斥：full `/blake`、`/alex` 一律忽略 `LITE-*.md`；`/blake-lite` 只接受 `LITE-*.md`。
Terminal：lite 下角色切换由**人输入命令**完成（可同 terminal）；agent 仍禁止自行调用另一角色。
```

**位置 3 — §3 末尾加 1 行**：
```
规则 0-5 适用于 full 通道；Lite 通道的等价约束见 §2.5 与 lite skills 内置条款。
```

（§4 不修改——terminal 隔离对 full 通道原样保留；lite 的合规性由 §2.5 Terminal 行 +
alex-lite L3 "由人输入命令" 措辞共同达成。）

### 4.4 Codex 镜像 + 调用实测（FR4/FR8）
1. 复制两个 SKILL.md 到 `.agents/skills/{name}/SKILL.md`（byte-identical，cmp 验证）
2. Smoke test：实际执行调用尝试（如 `$alex-lite` 经 codex exec），**保存 verbatim 命令 + 原始输出**
3. 结果写入 `.tad/codex/README.md` 新增小节 "Lite skills 调用方式"：成功 → 记录可用方式；
   失败 → 记录 BLOCKED 原因 + fallback（如 `cat .agents/skills/alex-lite/SKILL.md | codex exec ...`）
4. full $alex/$blake 退化是独立任务，本 handoff 不修。
   ⚠️ arch-P2-6：它属协议类诊断，**不得**用作 AC13 的 dogfood 任务（会当天违反阀门）

### 4.5 Dogfood 设计（FR10/AC13，⚠️ arch-P0-5 反 validation-theater 条款）
- 任务：throwaway——在 `.tad/evidence/acceptance-tests/tad-lite-channel/dogfood/` 下
  创建一个 2 文件小工件（如 note.md + checklist.md，内容任意但 AC 可验证）
- Blake 按两个 SKILL 文件逐步执行完整 lite 周期（L0→L5，含真实 spawn L3 reviewer）
- 记录到 completion report：
  (a) alex-lite 阶段产出（LITE 文件路径 + 大小）
  (b) blake-lite 阶段成本：L3 reviewer 的 subagent_tokens **实测值** + 主流程**估算值**
      ——completion 必须如实区分标注两者（⚠️ R2：证伪阈值作用在含估算的总量上，
      勿把估算当实测引用）
  (c) reviewer verdict 原文
  (d) 周期总成本估算 vs 45K 目标：若 >90K（2×）→ **设计声明证伪**，在 completion 中
      明确标注 "COST CLAIM FALSIFIED"，交 Alex Gate 4 裁定修订（修设计不是修 AC）
- dogfood 的验收 = **真实人拍板**（⚠️ R2 ND-2：不得模拟验收——模拟即违反 blake-lite
  Forbidden"人验收前归档"，等于让 dogfood 亲手示范绕过精髓 3）：Blake 在 dogfood 的
  L5 停下请用户确认（这顺带验证了"人拍板"环节本身），用户确认后 mv 归档到 archive/

---

## 5. 强制问题回答（Evidence Required）

### MQ1 历史代码搜索
**是**——找到 *express / light_tad / 跳过 TAD。**不复用**（都骑在 full 激活上）；express 的 NOT_via_suggestion 设计复用为入口 + escalated 子模式的参照。

### MQ2 函数存在性
N/A——markdown 协议文件。引用的 Agent tool / AskUserQuestion 为平台原生。

### MQ3 数据流 / MQ4 视觉层级
N/A。

### MQ5 状态同步
LITE 文件唯一载体，**位置即状态**：`active/` = pending，`archive/` = done（v2 修订：删除易失真的 Status 头字段，mv-on-acceptance 是状态转移操作）。`## Completion` 段存在性 = 实现完成标志（blake-lite L0 准入检查读它）。无第二存储。

### MQ6 技术调研
| 候选 | 优点 | 缺点 | 采用 |
|------|------|------|------|
| 扩展 *express | 复用现有 | 砍不到激活固定成本 | ❌ |
| light_tad 加强 | 零新文件 | 同上 + 改 full 协议 = 契约风险 | ❌ |
| 独立自包含 lite skills | 两刀全砍 + Codex 可移植 | 集成面五层需逐层处理（专家审查已逐层覆盖） | ✅ |

---

## 6. Implementation Steps

### Micro-Tasks

| # | File | Operation | Verification | Est. |
|---|------|-----------|--------------|------|
| 1 | .claude/skills/alex-lite/SKILL.md | 按 §4.1 规格创建（含哨兵块） | AC1-AC3,AC5,AC16 | 25m |
| 2 | .claude/skills/blake-lite/SKILL.md | 按 §4.2 规格创建（哨兵块从 #1 逐字节复制） | AC1,AC2,AC4-AC6,AC9,AC17 | 30m |
| 3 | CLAUDE.md | §4.3 三处修改 | AC7,AC14 | 10m |
| 4 | .agents/skills/{两个}/SKILL.md | byte-identical 镜像 | AC8 | 5m |
| 5 | Codex smoke test + .tad/codex/README.md | §4.4（verbatim + transcript） | AC12 | 10m |
| 6 | Dogfood 完整 lite 周期 + 成本实测 | §4.5 | AC13 | 30m |
| 7 | 全量 AC 自验 + 范围检查 | §9.1 逐行 | AC10,AC11,AC15 | 15m |

---

## 7. File Structure

### 7.1 Files to Create
```
.claude/skills/alex-lite/SKILL.md
.claude/skills/blake-lite/SKILL.md
.agents/skills/alex-lite/SKILL.md
.agents/skills/blake-lite/SKILL.md
.tad/codex/README.md 内新增小节（文件不存在则创建整个文件）
.tad/evidence/acceptance-tests/tad-lite-channel/dogfood/*（AC13 产物）
```

### 7.2 Files to Modify
```
CLAUDE.md    # §1 +1 行、§2.5 +6 行、§3 +1 行；总新增 ≤10、删除 0
```

### 7.3 Grounded Against (Alex step1c + 专家审查后补充验证)
- CLAUDE.md（全文 100 行；§1 L9 / §2 表 L22 / §3 L34-39 / §4 L44 插入点与冲突点逐行核实——含 code-reviewer 独立核实 ✓）
- .claude/skills/alex/SKILL.md L222/L225（僵尸检测 glob `HANDOFF-*.md`，grep 实测 2026-07-30）
- .claude/skills/blake/SKILL.md L21（`*.md` glob）/ L188（`HANDOFF-*.md`）（grep 实测）
- .claude/skills/tad-maintain/SKILL.md L101/L110/L116（遍历 + slug 前缀规则）（grep 实测）
- .tad/hooks/precompact-session-snapshot.sh L129（`HANDOFF-*.md`）（grep 实测）
- .claude/skills/alex/references/express-path-protocol.md（head 15，NOT_via_suggestion 参照）
- .agents/skills/ 目录结构（60 条目，{skill}/SKILL.md 布局）
- 四个新 skill 目录（new — will be created，absent 已验证）

---

## 8. Testing Requirements

### 8.4 Friction Preflight
| Friction Point | Required Step | Expected Fix Path | Allowed Substitute | Gate Impact |
|----------------|---------------|-------------------|--------------------|-------------|
| codex CLI 不可用/auth 过期 | AC12 smoke test | `command -v codex` 预检；auth 过期请求用户重登 | README 记录 "BLOCKED: {原因}"，AC12 记 DEGRADED_WITH_APPROVAL | AC12 单项降级不阻塞其余 |
| L3 reviewer subagent quota 耗尽（dogfood 中） | AC13 | 等待/换时段重试 | honest_partial：AC13 记 BLOCKED + 原因，不得跳过 reviewer 假装完成 | AC13 未完成 → Gate 3 不得 PASS（可 PARTIAL 上报人裁定） |

### 8.5 Feedback Collection
N/A。

---

## 9. Acceptance Criteria

- [ ] FR1-FR10 全部实现并有 §9.1 逐行证据
- [ ] Layer 2 审查通过（本 handoff 走 full 流程）
- [ ] Human 验证"这是我期望的 lite 通道"

## 9.1 Spec Compliance Checklist ⚠️ PRIMARY VERIFICATION SOURCE

> 管道转义注：表格内 `\|` 提取运行时还原为 `|`。

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d) |
|---|---------------------|-------------------|--------------------|--------------------|-------------------------------|
| AC1 | 两 skill 存在且 ≤300 行（机械判定，CR-P2-1） | post-impl | `for f in .claude/skills/alex-lite/SKILL.md .claude/skills/blake-lite/SKILL.md; do n=$(wc -l < "$f"); [ "$n" -le 300 ] && echo "$f OK $n" \|\| echo "$f FAIL $n"; done` | 两行均 OK | (post-impl；基线：目录 absent ✅) |
| AC2 | 无运行时加载指令（CR-P0-5，R2 修正为可裁定规则） | post-impl | `grep -nE '(Read\|读取\|加载).*(references/\|\.tad/config)' <每文件>; grep -nE '^\s*load_when:' <每文件>` | load_when 命中 = 0；第一条 grep 的**每条**命中行必须位于 `## Forbidden` 段内或以 禁止/不得 开头（即禁令文本）——存在任何不满足此条件的命中 → FAIL | (post-impl；R2 裁定规则替代不可判定的"0 行 + 例外"矛盾写法) |
| AC3 | 升级清单四类锚点两文件齐全（CR-P1-7） | post-impl | `for f in <两文件>; do for k in SAFETY 协议契约 '>5' fatal; do printf '%s %s %s\n' "$f" "$k" "$(grep -ci -- "$k" "$f")"; done; done` | 8 行全部 ≥1 | (post-impl) |
| AC4 | 强制 reviewer 条款真实存在（CR-P1-7/arch-P2-4） | post-impl | `grep -c 'code-reviewer' <blake-lite>; grep -Fc 'MANDATORY' <blake-lite>; grep -Fc '不可以任何理由跳过' <blake-lite>` | 三个计数各 ≥1（`;` 分隔，FAIL 可见不截断） | (post-impl) |
| AC5 | escalated_review 双侧存在 + 用户原话锚点 | post-impl | `grep -c 'escalated_review' <两文件各查>; grep -Fc '用户原话' <两文件各查>` | 四个计数各 ≥1 | (post-impl) |
| AC6 | 知识捕获 + mkdir 防呆 | post-impl | `grep -c 'lite-discoveries' <blake-lite>; grep -c 'mkdir -p .tad/evidence/journal' <blake-lite>` | 各 ≥1 | (post-impl；journal absent 基线 ✅——文件由首次发现创建) |
| AC7 | CLAUDE.md 三处修改落位 + 互斥条款 | post-impl | `grep -c 'alex-lite' CLAUDE.md; grep -c 'LITE-' CLAUDE.md; grep -c '忽略.*LITE' CLAUDE.md; grep -c '2\.5' CLAUDE.md` | ≥1 / ≥3 / ≥1 / ≥1（⚠️ R2 ND-1：§2.5 仅 1 行含 alex-lite，期望 ≥2 算术上不可过，已改 ≥1） | (post-impl；基线 0/0 ✅ 已 dry-run) |
| AC8 | Codex 镜像 byte-identical | post-impl | `cmp <claude侧> <agents侧>`（两对）`; echo $?` | 均 0 | (post-impl) |
| AC9 | 哨兵块两文件逐字节相同（CR-P1-1 机械化） | post-impl | `diff <(sed -n '/ESCALATION-LIST-BEGIN/,/ESCALATION-LIST-END/p' <alex-lite>) <(sed -n '/ESCALATION-LIST-BEGIN/,/ESCALATION-LIST-END/p' <blake-lite>); echo $?` + `sed -n ... <alex-lite> \| wc -l` | diff 退出 0 **且**提取行数 >4（防两侧空匹配） | (post-impl；sed 语法 dry-run ✅) |
| AC10 | 零 hook/settings/full 协议/安装器修改（CR-P0-7 修正） | post-impl | `git status --porcelain \| awk '{print $NF}' \| grep -cE 'settings(\.local)?\.json\|\.tad/hooks/\|\.tad/config[^/]*\.yaml\|skills/(alex\|blake\|gate)/\|^tad\.sh$'` | 0（porcelain 覆盖 untracked/staged/unstaged） | (post-impl；语法 dry-run ✅) |
| AC11 | 改动范围 = 允许集（CR-P1-8 修正） | post-impl | `git status --porcelain \| awk '{print $NF}' \| grep -vE 'skills/(alex\|blake)-lite/\|^CLAUDE\.md$\|\.tad/codex/README\.md\|\.tad/evidence/(reviews\|acceptance-tests\|traces\|decisions\|journal)/\|handoffs/(HANDOFF\|COMPLETION\|LITE)-20260730\|\.tad/active/session-state\.md\|research-notebooks/REGISTRY\.yaml\|evidence/research/'` | 空输出（允许集 = §7 + Evidence Manifest 产物 + hook 落盘 jsonl + 本 handoff + 会话既有未提交项） | (post-impl；语法 dry-run ✅) |
| AC12 | Codex 调用实测 + transcript（arch-P0-5 强化） | post-impl | `grep -c 'alex-lite' .tad/codex/README.md 2>/dev/null \|\| echo MISSING`；completion 中含 verbatim 命令 + 原始输出块 | ≥1 且 completion 有 transcript；BLOCKED 需含原因 | (post-impl；friction §8.4) |
| AC13 | Dogfood 完整周期 + 实测成本（arch-P0-5 ⚠️ BLOCKING 反 theater） | post-impl | 按 §4.5 执行；completion 含 (a)-(d) 四项记录；`ls .tad/archive/handoffs/LITE-*dogfood*` 验证生命周期走通 | 周期完成 + reviewer 真实 spawn（subagent_tokens 数字）+ 成本 vs 45K 结论；>90K → 标注 COST CLAIM FALSIFIED | (post-impl) |
| AC14 | CLAUDE.md 最小 diff（CR-P1-9，R2 ND-7 注） | post-impl | `git diff --numstat CLAUDE.md` | 新增 ≤10（**含空行**；预期恰为 10 新增/0 删除：8 行正文 + 2 空行），删除 0 | (post-impl；基线未修改 ✅) |
| AC15 | 无脚本依赖（NFR2） | post-impl | `grep -nE '\.sh[^a-zA-Z]\|bash \|python ' <两文件>`（R2 ND-9：BSD grep 的 `\b` 不可靠，见 patterns/shell-portability） | 命中处逐行人工复核均为示例/禁令文本，无运行时依赖（mkdir/mv/git 为 shell 内建操作指引，允许） | (post-impl) |
| AC16 | FR7 模板内嵌 | post-impl | `grep -c '# LITE Handoff' <alex-lite>; grep -c '## 不做什么' <alex-lite>; grep -c '## 文件清单' <alex-lite>; grep -c '## AC' <alex-lite>` | 各 ≥1 | (post-impl) |
| AC17 | FR9 生命周期 mv 指令存在 | post-impl | `grep -c 'archive/handoffs' <blake-lite>` | ≥1 | (post-impl) |

**AC Dry-Run Log** (Alex step1d v1 实跑 2026-07-30 + v2 修订说明):
- v1 基线全部有效（CLAUDE.md greps=0、四目录 absent、journal absent）
- v2 新增/修订 AC 均为 post-impl；grep -E / sed / awk / porcelain 语法均为标准用法已 syntax-validate；AC11 允许集含会话既有未提交项（REGISTRY.yaml + evidence/research，git status 实测可见）
- AC13 无法 pre-impl dry-run（需真实周期）——这是设计使然的实测条款，不是遗漏

## Required Evidence Manifest

```yaml
required_evidence:
  expert_reviews:      # Alex 侧 pre-handoff（已完成，v2 已整合）
    - .tad/evidence/reviews/2026-07-30-code-review-tad-lite-handoff.md   # ✅ 已存在
    - .tad/evidence/reviews/2026-07-30-arch-review-tad-lite-handoff.md   # ✅ 已存在
  blake_reviews:       # Blake Gate 3 Layer 2
    - .tad/evidence/reviews/blake/tad-lite-channel/code-review.md
    - .tad/evidence/reviews/blake/tad-lite-channel/spec-compliance.md
  completion:
    - .tad/active/handoffs/COMPLETION-20260730-tad-lite-channel.md
  dogfood:
    - .tad/evidence/acceptance-tests/tad-lite-channel/dogfood/           # AC13 产物 + 成本记录在 completion
  gate_verdicts:
    - completion 报告内 Gate 3 verdict 段
  knowledge_updates:
    - Gate 3 KA 有发现 → .tad/project-knowledge/ 相应文件；无则 completion 说明
```

---

## 9.2 Expert Review Status (Alex 必填)

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | P0-1: reviewer prompt 用 git diff 看不到新建文件 → 必然假 PASS | §4.2 L3 prompt 修正版（status --short + diff HEAD + Read 新文件 + 明示禁令） | Resolved |
| code-reviewer | P0-2: escalated "实现前先审" 写在 L3 时序不可能 | §4.2 新增 L0.5 BLOCKING 步骤 + Forbidden "跳过 L0.5" | Resolved |
| code-reviewer | P0-3: escalated_review 成 fatal 通行证，与 alex-lite 矛盾 | §4.2 L0 step3 三分支（fatal 无条件停） | Resolved |
| code-reviewer | P0-4: CLAUDE.md §1/§3/§4 与 lite 明文冲突 | §4.3 三处修改（§1 豁免覆盖禁令句 + §2.5 块 + §3 作用域行；§4 不改，改 alex-lite L3 措辞） | Resolved |
| code-reviewer | P0-5: AC2 self-leak + config-.* 假阴性 | §9.1 AC2 改运行时加载指令 pattern + 禁令文本不计声明 | Resolved |
| code-reviewer | P0-6: handoff 定位黑名单可绕过 + 最新未定义 + 无状态检查 | §4.2 L0 白名单准入 + Completion 段检查 + 多候选请人指定；文件名加 HHMM | Resolved |
| code-reviewer | P0-7: AC10 diff --name-only 真空通过 + settings.local 漏配 | §9.1 AC10 改 git status --porcelain + settings(\.local)? pattern | Resolved |
| backend-architect | arch-P0-1: CLAUDE.md 修改不完整（§3/§4 冲突） | 同 CR-P0-4 → §4.3 consolidated 方案 | Resolved |
| backend-architect | arch-P0-2: 反向无守卫（full 会捡走 LITE） | §4.3 §2.5 方向互斥条款 + AC7 互斥 grep；Blake L21 `*.md` glob 已实测坐实 | Resolved |
| backend-architect | arch-P0-3: LITE 生命周期未定义 = 僵尸生成器 + 成本税 | FR9 + §4.2 L5 mv-on-acceptance + AC17；consumer glob 实测表 §2.2 | Resolved |
| backend-architect | arch-P0-4: 最新选择器歧义 + Status 头失真 | 同 CR-P0-6 + MQ5 改"位置即状态"（删 Status 字段）+ HHMM 文件名 | Resolved |
| backend-architect | arch-P0-5: 零 AC 验证核心声明 = validation theater | FR10 + §4.5 dogfood 设计 + AC13（BLOCKING，>2× → 证伪标注）+ AC12 强化 transcript | Resolved |
| code-reviewer | P1-1: 清单未内嵌 + AC9 不可运行 | §4.1/§4.2 哨兵块 + AC9 sed diff + 非空断言 | Resolved |
| code-reviewer | P1-3: AC 卡住无合法出口 | §4.2 L2 BLOCKED 出口 | Resolved |
| code-reviewer | P1-4: 自审可替代 subagent | §4.2 Forbidden 两条新禁令 | Resolved |
| code-reviewer | P1-5: blake-lite scope 兜底缺失 + Forbidden 漏项 | §4.2 L1 纪律改写 + Forbidden 补 commit/push/归档/project-knowledge | Resolved |
| code-reviewer | P1-6: escalated 可自我授权 | 用户原话字段 + 双侧禁令/检查（§4.1/§4.2） | Resolved |
| code-reviewer | P1-7: AC3/4/5 token 存在性检查失真 | §9.1 AC3/AC4/AC5 分类别锚点重写 | Resolved |
| code-reviewer | P1-8: AC11 被必要产物假 FAIL | §9.1 AC11 允许集重写 | Resolved |
| code-reviewer | P1-9: FR7/NFR2/行数无 AC 载体 | AC14/AC15/AC16 新增 | Resolved |
| backend-architect | arch-P1-1: 阀门 fail-open | 哨兵块兜底 catch-all 条款（未覆盖+不确信 → full） | Resolved |
| backend-architect | arch-P1-2 + CR-P1-2: 清单漏网类别 | 哨兵块四类扩充（镜像/tad.sh/settings.local/agents/workflows/epics/依赖升级/release 操作/VCS 破坏/耦合条款） | Resolved |
| backend-architect | arch-P1-3: "禁止 Read .tad/" 自相矛盾 | §4.1/§4.2 Forbidden 措辞改"禁加载协议/配置/知识文件，契约与 journal 除外"；AC2 配套 | Resolved |
| backend-architect | arch-P1-4: lite-discoveries write-only | §10.2 声明蒸馏接线为必需 follow-up handoff；mkdir -p 补齐 | Resolved (接线 Deferred → follow-up) |
| backend-architect | arch-P1-5: escalated 政策/例外二义 | §11 决策行修齐为"例外"，与 §4.1 一致 | Resolved |
| backend-architect | arch-P1-6: reviewer git diff 无界 | §4.2 L3 scoped diff + 清单外 hunk 报 P0 | Resolved |
| backend-architect | arch-P1-7: lite 无压缩恢复路径 | §4.1 L3 / §4.2 L5 恢复指引（重读唯一 pending LITE，勿跑 full） | Resolved |
| both | P2 批量采纳: AC1 机械判定 / AC12 2>/dev/null / round-2 增量复核 / 阈值对齐总数>5 / EnterPlanMode 禁令 / 重名检查 / HHMM 文件名 / "不额外主动读取"措辞 / dogfood 必须 throwaway | 各对应 §4/§9.1 段落 | Resolved |
| backend-architect | arch-P2-2 部分: AC9 哨兵 diff | 已采纳（同 CR-P1-1） | Resolved |
| code-reviewer (R2 增量复核) | 11/12 P0 FIXED 确认；CR-P0-5 STILL-BROKEN（AC2 pattern 仍误伤禁令文本 + Expected 自相矛盾）；9 项修复引入的新缺陷：ND-1 AC7 期望算术不可过 / ND-2 dogfood 违 Forbidden / ND-3 待验收态死路 / ND-4 §2.5 插入位置歧义 / ND-5 reviewer 误报既有脏文件 / ND-6 哨兵批注打爆 AC9 / ND-7 预算零余量 / ND-8 §10.2 自相矛盾 / ND-9 grep 脆性 ×2 | v3 全部修复：AC2 裁定规则重写、AC7 ≥1、AC14 含空行注、AC3 -ci、AC15 pattern、§4.2 L0 第四分支、L3 prompt 基线豁免、§4.3 位置+预算精确化、§4.5 真实人拍板+实测/估算区分、§10.1 剥离规则、§10.2 残余清单 | Resolved |

### Experts Selected
1. **code-reviewer** — always required；SKILL 规格一致性、AC 可运行性、协议逻辑洞
2. **backend-architect** — 路由爆炸半径、consumer 集、生命周期、成本模型完整性

### Overall Assessment (post-integration)
- code-reviewer: CONDITIONAL PASS → **7 P0 全部 Resolved**，9 P1 中 8 Resolved / arch-P1-4 接线部分 Deferred（声明为 follow-up）
- backend-architect: CONDITIONAL PASS → **5 P0 全部 Resolved**（含 glob 实测取证），7 P1 全部 Resolved
- code-reviewer R2 增量复核: FAIL（严格口径：1 STILL-BROKEN + 2 阻塞级新缺陷）→ **v3 定点修复全部 R2 findings**（均为措辞/命令级，§4 设计骨架/§2.5 方案/哨兵机制/AC13 条款零改动）。R2 明示修复后无需第三轮完整复核，五处定点回看即可——v3 已逐处对应
- 审查证据：`.tad/evidence/reviews/2026-07-30-{code-review,arch-review}-tad-lite-handoff.md`（R2 结论已录入上表）

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ 本 handoff 自身走 full TAD（协议契约类），Blake 正常 Ralph Loop + Gate 3
- ⚠️ CLAUDE.md 新增 ≤10 行 / 删除 0（AC14 硬门）——每行都是全体 session 的持续成本
- ⚠️ 两 SKILL 禁止运行时加载指令（AC2 定义的 pattern）；**作为禁令出现的路径字样是允许的**，不要为了 AC 变绿删掉禁令本身（CR-P0-5 的二阶陷阱）
- ⚠️ 哨兵块必须逐字节相同（从 alex-lite 复制到 blake-lite，AC9 机械验证）
- ⚠️ 保留勿丢（CR-P2-7 点名的三处好设计）：L3 标题内嵌的证据型反合理化措辞（2026-04-14 案例）、L0 先判断硬顺序、journal 改道尊重 memory 只读契约
- ⚠️ 哨兵块剥离规则（R2 ND-6）：§4.1/§4.2 哨兵块内外的 `⚠️ CR-*/arch-*/R2 *` 批注全部是**本 handoff 的元信息**——写入 SKILL 文件时两侧一并剥离，`<!-- ESCALATION-LIST-BEGIN/END -->` 行必须是**裸标记**（行尾不得挂批注），否则 AC9 的 sed 提取 diff 必非 0

### 10.2 Known Constraints
- *express 零修改；`.tad/memory/` 只读
- 行数硬上限 300/文件（lite 的存在理由）
- **必需 follow-up handoff（本次不做，arch-P1-4）**：将 `*accept` 蒸馏循环接线读取 `.tad/evidence/journal/lite-discoveries.md`（改 full 协议文件，需单独 full 流程）。在此之前该文件是待蒸馏缓冲区。
- 已知残余风险（有意取舍，非实现缺陷；R2 复核确认后显式记录）：
  (a) full Blake L21 `*.md` glob 的互斥守卫仅为 CLAUDE.md 散文层（NFR1 禁改 blake/SKILL.md）——观察期内如发生 full 捡走 LITE，再立项改 glob
  (b) 遗弃态 LITE（设计后未实现/实现后未验收）对僵尸检测/tad-maintain/PreCompact 三方隐形，仅靠 alex-lite L2 的 pending 提示半自曝——lite 任务周期短，成真问题再立项

### 10.3 Sub-Agent 使用建议
- [x] Layer 2 常规审查：code-reviewer + spec-compliance-reviewer
- [x] AC13 dogfood 中 L3 reviewer 为真实 spawn（其 subagent_tokens 即成本证据）

---

## 11. Decision Summary

| 决策 | 选择 | 理由 | 轮次 |
|------|------|------|------|
| 命名 | alex-lite / blake-lite | 用户指定 | 用户消息 |
| 架构 | 两命令 + 单 terminal 默认可隔离 | 独立视角来源 = 干净上下文（reviewer subagent），非窗口边界 | R1+讨论修订 |
| 质量线 | 实现后 1 个 fresh reviewer | 历史证据：实现后审查产出最高 | R1+R3 |
| 敏感文件 | **例外**准入（用户原话授权）+ L0.5 前置设计审 + L3 = 2 reviewer；fatal 无例外 | 专家审查修正：例外≠政策（arch-P1-5），时序修正（CR-P0-2） | R2+审查整合 |
| express | 并存不动 | 分工，跑数据再议 | R2 |
| 交付范围 | 三件套 + Codex 镜像 + smoke test | 多平台额度诉求 + $ 退化迹象 | R2+用户补充 |
| 知识捕获 | journal 一行 append；蒸馏接线 = follow-up handoff | 保复利闭环意图；接线动 full 协议不塞本次 | 补丁+arch-P1-4 |
| 漂移防线 | LITE- 前缀审计 + 先判断硬顺序 + 阀门 catch-all 兜底 | AR-001 系统级防护 + fail-closed 方向修正（arch-P1-1） | 补丁+审查整合 |
| CLAUDE.md 预算 | 4 行 → ≤10 行 | 两位专家独立确认 §3/§4 冲突必须显式豁免；正确性 > 最小化；AC14 承载 | 审查整合 |
| 生命周期 | mv-on-acceptance，位置即状态 | 一个机制同时解决僵尸/选择器歧义/Status 失真/启动扫描成本税（arch-P0-3/4 折叠） | 审查整合 |
| 成本验证 | AC13 dogfood 实测，>2× 即证伪标注 | Measure Before Optimizing + 反 validation theater（arch-P0-5） | 审查整合 |

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-07-30
**Version**: 3.1.2 (v3 — R1: 12 P0 + 15 P1 + 9 P2；R2: 1 residual P0 + 9 ND all fixed)
**Status**: Expert Review Complete — Ready for Implementation
