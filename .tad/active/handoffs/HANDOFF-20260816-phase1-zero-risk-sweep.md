---
task_type: mixed
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
**Date:** 2026-08-16
**Project:** TAD Framework
**Task ID:** TASK-20260816-001
**Handoff Version:** 3.1.0 — **rev2**（rev1 于 Gate 2 判 FAIL，见下）
**Epic:** `EPIC-20260816-framework-health-repair.md` (Phase 1/4)
**Supersedes:** N/A

---

## 🔴 Gate 2 记录

### rev1 — **FAIL**（2026-08-16）

两名独立 reviewer 共报 **12 个唯一 P0**。其中三条是 Alex 的**事实性错误**，两条使设计范围本身错误：

| # | rev1 的错误 | 实际 |
|---|---|---|
| 1 | 「AC 已逐条空跑，全部改前红」 | **不实签署**。AC1.2 的正文提取 `sed -n '/^---$/,$p'` 锚在第 1 行（frontmatter **开**标签），返回整个 1789 行文件。记录的基线 `0/0/0` 是用另一条命令（`sed -n '149,$p'`）测的，**改命令后未重测**。该命令实测 **3/2/2 → AC1.2 动手前就是绿的** |
| 2 | 「`constraints:` 块无消费者」 | **假**。有 **15 处 prompt 层引用**，分布在 5 个 Alex 会加载的 reference 文件；其中 `handoff-creation-protocol.md:310` 与 `:445` 是**正文指令项**。按 rev1 删除会**新造 6 个 F-04** |
| 3 | 「Alex 对 `config-cognitive` 零引用」 | **假**。`alex/SKILL.md:1145` 是 MANDATORY 块 → `references/research-decision-protocol.md:9` → `config: ".tad/config-cognitive.yaml"`。原判断只 grep 字面量，未沿 reference 下钻 |
| 4 | AC1.5c-neg 作为负控 | `grep -cE '...\|...'` 中转义管道在 ERE 是字面竖线，**对含该短语的文件返回 0 → 永不失败** |
| 5 | AC1.8 「改前通过」 | **从未跑过**。实测 `exit 2` usage 错误；补参数后因 gitignore 的 `.claude/skills/local/` 而 FAIL（与本单无关） |
| 6 | §10.4 回退判据 | **不可观测**：描述的是未来 session 行为、无反事实基线、「本应继续却停了」不可由检视区分 |

**rev1 复盘**：我在 §📚 把「数不对时，先怀疑判据，不是数据」原样抄给 Blake，然后在同一文件的 AC 表里犯了第六次 —— 且是**把已验证正确的命令改「robust」后没重测**。
**可迁移教训：改判据 = 判据失效，旧测量值不随命令迁移。**

### rev2 检查结果
- [x] 需求明确，无歧义
- [x] 技术方案完整（FR1 范围已扩，FR5 已撤出）
- [x] AC 可运行且**全部重新实测**（§9.1，改前值均用最终命令测得）
- [x] MQ1-MQ6 已回答并附证据（§5）
- [ ] 专家审查 ≥2 且 P0 已修 → **rev2 待复审**

---

## 📋 Handoff Checklist (Blake必读)

- [ ] 读完 §1-§10
- [ ] 读 `.tad/project-knowledge/patterns/ac-verification.md` 与 `shell-portability.md`
- [ ] 确认理解 §10.1 的**五条硬禁止**
- [ ] 确认理解 §9.0 的**正文提取唯一合法写法**
- [ ] 确认理解 Gate 3 **分段判定**（1a / 1b 分开给 PASS/FAIL）

---

## 1. Task Overview

### 1.1 What We're Building

**主题：清除「声称生效但从未生效」的声明，并把其中仍有价值的实质内容落到真正会被送达的地方。**

| 类 | 内容 | 性质 |
|---|---|---|
| **1a** | 删 playground（两侧 + 三处失效指针）；evidence 去重；删 `tad-gate` 绑定 | **纯删除**，无消费者 |
| **1b** | 删 `constraints:`/`migration:` frontmatter + 实质内容落正文 + 改写 15 处交叉引用 | **首次生效**（这些约束从未送达过模型） |

### 1.2 Why We're Building It

审计 `.tad/active/designs/AUDIT-20260816-framework-health.md`：

- **F-04**：`alex/SKILL.md` frontmatter 的约束块自称 `enforcement: prompt-level-only`，实测**被 harness 剥离且无脚本读取**。3 条禁令只存在于此，从未生效
- **F-16**：`playground` 废弃两个月，仍写在 `alex/SKILL.md:3` 的技能发现字符串里，16 KB 文件照常发布
- **F-19**：`stable5-pre`/`stable5-post` 182 对文件逐字节相同
- **F-15（仅 Gate 一侧）**：`config.yaml:109` 声明 `tad-gate` 加载两个模块，而 gate 从无加载步骤 —— 且内容**已内联**（`gate:219`、`gate:706`），绑定是多余声明

### 1.3 Intent Statement

**要达成的**：让「声明存在的约束」与「实际生效的约束」重合。

**不追求的**：形式统一。Gate 的修法（删绑定）与 Alex/Blake 不同，依据是**证据**不是对称性。

**明确排除**：给 Alex/Blake 加载 `config-cognitive`（原 FR5）**已撤出本单**，理由见 §3.1 FR5 与审计 F-36。

---

## 📚 Project Knowledge（Blake 必读）

| Pattern | 为什么相关 |
|---|---|
| `ac-verification.md` | 本单 AC 全为计数式判定，**判据比数据窄**是本仓反复踩的坑 |
| `shell-portability.md` | BSD/GNU grep 差异、zsh 分词 |

**必须应用的三条**：

1. **「数不对时，先怀疑判据，不是数据」** —— rev1 就是死在这条上（见 Gate 2 记录）。**每条 AC 结果与预期不符时，先验命令本身。**
2. **BSD grep 会把模式中间的 `$` 当锚点** → 含特殊字符时用 `grep -cF`。
3. **判断 git 内容只能用 `git show` / `git ls-tree`**，`wc -c`/`open()` 跟随符号链接。

### Blake 确认
- [ ] 我已读上述两个 pattern，并理解三条如何作用于本单

---

## 2. Background Context

### 2.1 Previous Work
上一单 `HANDOFF-20260816-trace-relative-path` 已 Gate 4 归档（`6a85b8e8`）。本单是 Epic Phase 1/4，无前置 Phase。

### 2.2 Current State
- 工作区干净，main 与 origin 同步
- `bash .tad/hooks/lib/skill-body-verify.sh` → **exit 0，全绿**（回归守卫）
- `bash .tad/hooks/lib/release-verify.sh platform-skills . .` → **FAIL**，原因是 gitignore 的 `.claude/skills/local/`（`.gitignore:13`）无 `.agents` 对应物。**这是先于本单存在的状态，不是本单造成的，也不由本单修复**（见 §9.0）

### 2.3 Dependencies
无外部依赖。

---

## 3. Requirements

### 3.1 Functional Requirements

| ID | 需求 | 类 |
|---|---|---|
| **FR1** | 删除 `alex/SKILL.md` frontmatter 的 `constraints:` 与 `migration:` 块；**同时改写 `.claude/skills/alex/references/` 中 15 处 `constraints.*` 交叉引用**（5 个文件，其中 `handoff-creation-protocol.md:310`/`:445` 是正文指令项）。`constraints_schema: "v0.2"` 一并删除（它 schematize 的东西已不存在） | 1b |
| **FR2** | 将实质内容写入 alex 正文，**范围见 §4.2（已精确界定，不是全量搬运）** | 1b |
| **FR3** | `alex/SKILL.md:3` 的 `description:` 移除 `, *playground` | 1a |
| **FR4** | 删除 `.claude/skills/playground/` 与 `.agents/skills/playground/`；**同时清理三处因此失效的指针**：`config-workflow.yaml:279`（死路径）、`config.yaml` 的 `playground:` command binding、`deprecation.yaml:127-131` 的 `note:` 事实性错误。**不得向 `deprecation.yaml` 新增任何 `files:` 条目** | 1a |
| ~~FR5~~ | ~~给 Alex/Blake 补 `config-cognitive`~~ → **⛔ 已撤出本单**（人裁定 2026-08-16）。它不是一致性修正：该模块含 `research_first: blocking: true` + 强制 ≥3 次 WebSearch，与 `CLAUDE.md §2`「研究工具排除」冲突；且 `discipline-floor.md:20-21` 将两条纪律均标为**待判**，解除条件是循环触发实测。归入独立工作包 | — |
| **FR6** | 删除 `.tad/config.yaml` 的 `command_module_binding.tad-gate` 条目，原位留注释指向 `gate/SKILL.md:227` | 1a |
| **FR7** | 删除 `stable5-pre` 一侧 182 文件，代之以 SHA-256 清单。**清单必须由 `git show HEAD:<path>` 生成**（不是工作树），并在头部记录删除前的 commit SHA | 1a |
| **FR8** | `.claude` 与 `.agents` 两侧保持逐字节一致 | 1a+1b |

### 3.2 Non-Functional Requirements
- **NFR1**：正文新增用**明文祈使句**，禁止 `deny_extra:` 风格压缩 YAML
- **NFR2**：不得改任何 `.sh`、不得改 `tad.sh`、不得改 hook 逻辑
- **NFR3**：**不得增加正文的停顿条件数量**（见 AC1.10）

---

## 4. Technical Design

### 4.1 结构与去向

```
alex/SKILL.md frontmatter (L1-146，正文从 L148 起)
├── name / description                        ← 保留（description 改一处，FR3）
├── constraints_schema: "v0.2"                ← 删（FR1）
├── constraints:
│   ├── deny:              (L9-20)   全局禁令 ── 正文无对应 ⇒ 必须搬（FR2-a）
│   ├── cross_model:       (L22-34)  ── 正文 L704-709 已有散文版 ⇒ 只核对不重写（FR2-c）
│   └── section_overrides: (L36-129)
│       ├── deny_ref:      9 处，锚点全错 ⇒ 直接删，不考古
│       └── deny_extra:    按 key 分三类，见 §4.2
└── migration:             (L131-145) 纯考古 ⇒ 直接删（FR1）
```

### 4.2 FR2 的精确范围（rev2 收窄的关键）

rev1 写「把全部 `deny_extra` 搬进正文」是**过度施工**。实测正文已有 **3 个 `forbidden_implementations:` 块**，多数 key 已有散文覆盖：

| key | 正文出现次数 | 处置 |
|---|---|---|
| `cross_model_awareness` | 2 | **核对**（正文 L704-709 已有 4 条 MUST NOT，含 DR-20260531 豁免） |
| `express_path` | 2 | **核对** |
| `experiment_path` | 2 | **核对** |
| `skillify` | 9 | **核对** |
| `skip_knowledge_assessment` | 1 | **核对** |
| `cancel_protocol` | 1 | **核对** |
| **`step0_graph`** | **0** | **必须写入** |
| **`step1d_ac_dryrun`** | **0** | **必须写入** |
| **`gate4_delta`** | **0** | **必须写入** |
| `step1c_grounding` | 0 | `inherits_global: true`，靠全局 `deny:` 兜底 ⇒ 由 FR2-a 覆盖 |
| `step1c_lsp` | 0 | 同上 |

**FR2 拆成三件：**

- **FR2-a**：全局 `deny:`（5 类：hook 注册 / settings.json / hook 脚本 / exit code / never_block）写入正文。**这是唯一没有正文承载者的块**，且两个 `inherits_global` 的 key 依赖它。
- **FR2-b**：`step0_graph` / `step1d_ac_dryrun` / `gate4_delta` 三条写入正文明文祈使句。
- **FR2-c**：其余 6 个 key **只做覆盖核对**，正文已覆盖则不动；发现缺口才补，并在 completion 中逐条列出核对结论。

**内容来源**（`deny_ref` 指向错误，**不要用**）：

```bash
A=697c616ee281f3ab3c604bfd31041e6da9b73f35   # 2026-06-02，实测 6145 行
git show "$A:.claude/skills/alex/SKILL.md" | sed -n '2915,2918p'   # step0_graph
git show "$A:.claude/skills/alex/SKILL.md" | sed -n '3095,3102p'   # step1d_ac_dryrun
git show "$A:.claude/skills/alex/SKILL.md" | sed -n '4159,4164p'   # gate4_delta
```

三者原文均为 `forbidden_implementations:` 下的明文 `MUST NOT`，内容是**反机械化**规则。与现存 `deny_extra` 同源。冲突时以 `deny_extra` 为准并在 completion 记录。

### 4.3 FR1 的交叉引用（rev1 完全遗漏）

删除 `constraints:` 会让下列引用悬空。**必须同批改写**：

| 文件 | 行 | 性质 |
|---|---|---|
| `handoff-creation-protocol.md` | 308, **310**, 342, 443, **445**, 519 | **310/445 是正文指令项**：`- "MUST NOT register hooks or modify settings — see constraints.deny (global)"` |
| `acceptance-protocol.md` | 315, 360, 361 | 注释 |
| `express-path-protocol.md` | 53, 54 | 注释 |
| `cancel-protocol.md` | 103, 108 | 注释 |
| `experiment-path-protocol.md` | 109, 110 | 注释 |

改写方向：把 "see constraints.deny (global)" 改为指向 FR2-a 在正文中的新落点。**两侧镜像同步。**

### 4.4 AR-001 anchor —— 安全但必须验证

`skill-body-verify.sh:140` 用 `grep -cF "NOT_via_alex_auto: true"` 对**整个文件**计数。该串在 L24（frontmatter，将删）与 **L701（正文，保留）** 各一处 → 删后剩 1，检查通过。**Blake 必须实跑验证（AC1.9）。**

### 4.5 FR6 的理由（比 rev1 更强）
Gate 已把 Cognitive Firewall 内容**内联**（`gate:219` Risk Translation Pillar 3、`:706` Decision Compliance Pillar 1）。绑定是多余声明，删除即零风险。**不是「零引用」，是「已内联」。**

---

## 5. 强制问题回答（Evidence Required）

### MQ1: 历史代码搜索
**是**。祖先定位：

```bash
git log --format='%H %ad' --date=short -- .claude/skills/alex/SKILL.md | while read -r h d; do
  n=$(git show "$h:.claude/skills/alex/SKILL.md" 2>/dev/null | wc -l | tr -d ' ')
  [ "$n" = "6145" ] && echo "命中: $h $d"
done
# → 697c616ee281f3ab3c604bfd31041e6da9b73f35 2026-06-02
```

### MQ2: 位置存在性验证
rev1 的 10 处引用经两名 reviewer 独立复核**全部正确**。rev2 新增引用同样逐个实跑：

| 位置 | 内容 | 验证 |
|---|---|---|
| `alex/SKILL.md:1145` | `# ⚠️ MANDATORY: Research & Decision Protocol (Cognitive Firewall - Pillar 1 & 2)` | ✅ |
| `alex/SKILL.md:701` | `NOT_via_alex_auto: true  # Alex NEVER auto-invokes...` | ✅ |
| `alex/SKILL.md:704-709` | `forbidden_implementations:` + 4 条 MUST NOT | ✅ |
| `handoff-creation-protocol.md:310, :445` | `- "MUST NOT register hooks... see constraints.deny (global)"` | ✅ |
| `gate/SKILL.md:227` | `step1: "Read config-quality.yaml fatal_operations..."` | ✅ |
| `config-workflow.yaml:279` | `command: ".claude/skills/playground/SKILL.md"` | ✅ |
| `discipline-floor.md:20-21` | 研究先行/技术决策透明 = **待判** | ✅ |

### MQ3: 数据流完整性
N/A。**等价检查**：frontmatter 删除的每项实质内容在正文有落点或已有覆盖 —— 由 AC1.2c 逐条核对（§4.2 三类分别处置）。

### MQ4: 视觉层级
N/A。

### MQ5: 状态同步

| 数据 | 位置1 | 位置2 | 时机 | 方向 |
|---|---|---|---|---|
| alex SKILL + references | `.claude/skills/alex/` | `.agents/skills/alex/` | 每次改动后 | 必须逐字节相同 |
| playground | `.claude/skills/playground/` | `.agents/skills/playground/` | 删除时 | 两侧都删 |

**不同步的后果**：`skill-body-verify.sh` FAIL（对 alex/blake）；**playground 的半删只有 `release-verify.sh platform-skills` 能抓**，而它因 `local/` 预先失败 → 故本单用 **AC1.4b 直接断言两侧缺席**，不依赖那个工具。

### MQ6: 知识评估
预期产出两条：
1. **「验证器确认文件存在 ≠ 确认送达模型」** —— `skill-body-verify.sh` 长期报 AR-001 anchor OK，而该 anchor 位于被剥离的 frontmatter
2. **「改判据 = 判据失效」** —— rev1 的翻车（见 Gate 2 记录）

---

## 6. Implementation Steps

### Phase 1a：纯删除（预计 1.5 小时）

| # | 步骤 | FR |
|---|---|---|
| 1a-0 | 跑 §9.1 全部 AC 的**改前**值并存档 | — |
| 1a-1 | `alex/SKILL.md:3` 移除 `, *playground` | FR3 |
| 1a-2 | 删两侧 playground 目录 | FR4 |
| 1a-3 | 清理三处失效指针（`config-workflow.yaml:279`、`config.yaml` playground 绑定、`deprecation.yaml` 的 `note:`） | FR4 |
| 1a-4 | 删 `config.yaml` 的 `tad-gate` 绑定 + 留注释 | FR6 |
| 1a-5 | 用 `git show HEAD:<path>` 生成 SHA-256 清单（含删除前 SHA），再删 `stable5-pre` | FR7 |
| 1a-6 | 同步 `.agents` 镜像；跑 1a 类全部 AC | FR8 |

**⚠️ 1a 完成后必须单独提交**，使 1b 可独立回退。

### Phase 1b：首次生效（预计 2.5 小时）

| # | 步骤 | FR |
|---|---|---|
| 1b-1 | 按 §4.2 取回三条原文，与 `deny_extra` 核对 | FR2-b |
| 1b-2 | 写入全局 `deny:`（FR2-a）与三条禁令（FR2-b）到正文 | FR2 |
| 1b-3 | 对其余 6 个 key 做覆盖核对，逐条记录结论（FR2-c） | FR2 |
| 1b-4 | 改写 15 处交叉引用，指向新落点 | FR1 |
| 1b-5 | 删除 frontmatter 的 `constraints:`/`migration:`/`constraints_schema:` | FR1 |
| 1b-6 | 同步 `.agents`；跑全部 AC | FR8 |

**顺序不可颠倒**：1b-4 必须在 1b-5 之前，否则交叉引用会有一段时间指向已删块。

---

## 7. File Structure

### 7.1 Create
- `.tad/evidence/acceptance-tests/release-runbook-capability-migration/stable5-pre.sha256`

### 7.2 Modify
- `.claude/skills/alex/SKILL.md` + `.agents/skills/alex/SKILL.md`
- `.claude/skills/alex/references/{handoff-creation,acceptance,express-path,cancel,experiment-path}-protocol.md` + `.agents` 对应 5 个
- `.tad/config.yaml`、`.tad/config-workflow.yaml`、`.tad/deprecation.yaml`（**仅 `note:` 文本**）

### 7.3 Delete
- `.claude/skills/playground/`、`.agents/skills/playground/`
- `.tad/evidence/.../stable5-pre/**`（182 文件）

### 7.4 Required Evidence Manifest（Gate 3 §1.4 ls-check）
- `.tad/evidence/reviews/blake/phase1-zero-risk-sweep/` — ≥2 份独立 reviewer 文件
- `.tad/evidence/acceptance-tests/phase1-zero-risk-sweep/` — 每条 AC 的改前/改后输出

---

## 8. Testing Requirements

无单元/集成测试。验证全部由 §9.1 承担。

### 8.4 Friction Preflight
- `skill-body-verify.sh` 可跑、当前全绿 ✅
- `release-verify.sh platform-skills . .` **当前即 FAIL**（`local/` 原因）→ 本单**不使用它做 AC**，改用直接断言
- `git show 697c616e:...` 可解析 ✅

---

## 9. Acceptance Criteria

### 9.0 ⚠️ 正文提取的唯一合法写法

**rev1 死在这里。** 本文件所有「正文」计数必须用：

```bash
B(){ awk 'NR>1 && /^---$/{f=1;next} f' "$1"; }
```

**禁止** `sed -n '/^---$/,$p'`（锚在第 1 行 = frontmatter 开标签，返回整个文件）。
**禁止**硬编码行号（FR1 删 145 行后全部漂移）。

自检：改前 `B .claude/skills/alex/SKILL.md | wc -l` = **1640**（1789 − 145 frontmatter − 1 开标签 − 3 个被 awk 跳过的 `---`）。

### 9.0b ⚠️ 表格中的 `\|` 是 Markdown 转义，**跑之前必须还原成 `|`**

§9.1 是 Markdown 表格，单元格内的竖线必须写成 `\|`。**但在 ERE 里 `\|` 是「字面竖线」，不是「或」** —— 直接复制粘贴会让模式匹配不到任何东西，且**静默返回 0**，看起来像通过。

rev1 的 AC1.5c-neg 就是这样变成一个永远不会失败的负控（reviewer P0-4）。

**受影响的 AC**：AC1.1e、AC1.2-couple、AC1.4e、AC1.5、AC1.6-neg、AC1.7 系列、AC1.8、AC1.10、AC1.12。

**Blake 的义务**：每条含 `|` 的 AC，跑之前先用**正控**证明模式是活的。本单已给出一个范例（AC1.6-neg 的正控：对 `alex/SKILL.md` 应返回 **2**，若返回 0 说明管道没还原）。

已逐条试跑确认（管道还原后）：`AC1.1d=145`、`AC1.1e=12`、`AC1.2-couple=0/0/0`、`AC1.5=15`、`AC1.6=1`、`AC1.6-neg 正控=2`、`AC1.10=26`。

### 9.1 Spec Compliance Checklist ⚠️ PRIMARY VERIFICATION SOURCE

**所有改前值均以本表最终命令重新实测（2026-08-16 rev2）。**

| AC | 类 | 命令 | 期望 | 改前实测 |
|---|---|---|---|---|
| **AC1.1** | 1b | `grep -c 'deny_ref' .claude/skills/alex/SKILL.md` | `0` | **9** 🔴 |
| **AC1.1b** | 1b | `grep -c 'source_baseline' …` | `0` | **1** 🔴 |
| **AC1.1c** | 1b | `grep -c 'constraints_schema' …` | `0` | **1** 🔴 |
| **AC1.1d** | 1b | `awk 'NR==1{next} /^---$/{exit} {n++} END{print n}' …`（frontmatter 行数） | `≤5` | **145** 🔴 |
| **AC1.1e** | 1b | `grep -cE '^constraints:\|enforcement: prompt-level-only\|deny_extra\|^  migration:' …` | `0` | **>0** 🔴 |
| **AC1.2** | 1b | 对三个 key 各跑：`B alex/SKILL.md \| grep -cF '<key>'` | 各 `≥1` | **0 / 0 / 0** 🔴 |
| **AC1.2-couple** | 1b | 对三个 key 各跑：`B alex/SKILL.md \| grep -c "MUST NOT.*<key>\|<key>.*MUST NOT"` | 各 `≥1` | **0 / 0 / 0** 🔴 |
| **AC1.2b** | 1b | `B alex/SKILL.md \| grep -c 'MUST NOT'` | **≥20**（净增 ≥8） | **12** 🔴 |
| **AC1.2c** | 1b | §4.2 三类逐条核对：FR2-a 全局 deny 5 类落地；FR2-b 三条落地；FR2-c 六个 key 核对结论逐条列于 completion | 无遗漏 | — |
| **AC1.3** | 1a | `sed -n '3p' … \| grep -c 'playground'` | `0` | **1** 🔴 |
| **AC1.4** | 1a | `ls -d .claude/skills/playground 2>/dev/null \| wc -l` | `0` | **1** 🔴 |
| **AC1.4b** | 1a | `ls -d .agents/skills/playground 2>/dev/null \| wc -l` | `0` | **1** 🔴 |
| **AC1.4c** | 1a | `grep -c '.claude/skills/playground/SKILL.md' .tad/config-workflow.yaml` | `0` | **1** 🔴 |
| **AC1.4d** | 1a | `grep -c '^  playground:' .tad/config.yaml` | `0` | **1** 🔴 |
| **AC1.4e** | 1a | `grep -c 'playground' .tad/deprecation.yaml` | **`≤5`**（可减不可增；`files:` 条目数必须不变） | **5** |
| **AC1.5** | 1b | `grep -rc 'constraints\.deny\|constraints\.section_overrides\|constraints\.enforcement' .claude/skills/alex/references/` 求和 | `0` | **15** 🔴 |
| **AC1.6** | 1a | `grep -c 'tad-gate:' .tad/config.yaml` | `0`，且原位有注释 | **1** 🔴 |
| **AC1.6-neg** | 1a | `grep -cE 'Load required modules\|Load config modules' .claude/skills/gate/SKILL.md`（**未转义管道**） | 仍为 `0` | **0** ✅ |
| **AC1.7a** | 1a | `git ls-files '<dir>/stable5-post/*' \| wc -l` | **182**（存活） | **182** ✅ |
| **AC1.7b** | 1a | `git ls-files '<dir>/stable5-pre/*' \| wc -l` | `0` | **182** 🔴 |
| **AC1.7c** | 1a | `wc -l < <dir>/stable5-pre.sha256` | **182** | 文件不存在 🔴 |
| **AC1.7d** | 1a | 清单哈希 == `stable5-post` 实测哈希（排序后逐行比对） | 全等 | — |
| **AC1.7e** | 1a | 清单头部含删除前 commit SHA | 有 | — |
| **AC1.8** | 1a | `git ls-files '<dir>/*' -z \| xargs -0 wc -c \| awk '/total$/{s+=$1}END{print s}'` | 减少 **≥18,000,000** | **39,320,727** |
| **AC1.9** | 1a+1b | `bash .tad/hooks/lib/skill-body-verify.sh; echo $?` | `0` | **0** ✅ |
| **AC1.10** | 1b | `B alex/SKILL.md \| grep -cE 'AskUserQuestion\|STOP\|BLOCKING'` | **≤26**（不得增加） | **26** ✅ |
| **AC1.11** | 1a+1b | `cmp .claude/skills/alex/SKILL.md .agents/skills/alex/SKILL.md; echo $?`，5 个 reference 文件同法 | 全 `0` | **0** ✅ |
| **AC1.12** | 1a+1b | `git diff --name-only \| grep -c '\.sh$'`（NFR2） | `0` | — |

**负控说明**：AC1.6-neg / AC1.7a / AC1.9 / AC1.10 / AC1.11 改前即绿，作用是**防止修复破坏已正确的东西**。
⚠️ **AC1.6-neg 的正控证明**：`grep -cE 'Load required modules|Load config modules' .claude/skills/alex/SKILL.md` → **2**（证明模式是活的）。rev1 用了转义管道，对该文件返回 0 → 已修。

### 9.2 Expert Review Status
rev1：2 名 reviewer，12 个唯一 P0 → **Gate 2 FAIL**。
rev2：**待复审**。

---

## 10. Important Notes

### 10.1 五条硬禁止

1. **禁止向 `.tad/deprecation.yaml` 新增任何 `files:` 条目。** 它是 F-01（P0 数据丢失）的载荷来源，Phase 2 待修。**允许**修正 `:127-131` 的 `note:` 事实性错误（不新增条目）。
2. **禁止给 `gate/SKILL.md` 新增加载步骤。** 本单对 gate 是删绑定。AC1.6-neg 拦这个。
3. **禁止在改写 15 处交叉引用前删除 `constraints:` 块**（顺序：1b-4 → 1b-5）。否则会新造 6 个「指令指向不存在的块」—— 正是本单要修的缺陷。
4. **禁止给 Alex/Blake 加载 `config-cognitive`。** 原 FR5 已撤出。该模块含 `research_first: blocking: true` + 强制 WebSearch，与 `CLAUDE.md §2` 冲突，且两条纪律在 `discipline-floor.md:20-21` 为**待判**。
5. **禁止把新的停顿条件写进正文。** AC1.10 钉死：`AskUserQuestion|STOP|BLOCKING` 计数不得超过 26。本单迁移的是「禁止做 X」类规则，不是「停下问人」类。

### 10.2 Known Constraints
- 不得改 `.sh` / `tad.sh` / hook 逻辑（NFR2，AC1.12）
- `release-verify.sh platform-skills` 因 `.claude/skills/local/` 预先 FAIL —— **不是本单造成，也不由本单修**

### 10.3 Sub-Agent 使用建议
- **1b-2 完成后**调 `code-reviewer` 单独审新写入的正文段：首次生效的约束，措辞歧义直接变行为偏差
- **AC1.2c 的逐条核对**由独立 subagent 做，禁止自审

### 10.4 分段 Gate 与回退（rev2 改为机械可测）

rev1 的判据（「本应继续却停下来问人」）经专家审查判定**不可观测**：描述的是未来 session 行为、无反事实基线、观察量不可由检视区分。**已替换为：**

> **AC1.10** —— 正文停顿条件计数 `≤26`（基线实测 26）。**超过即视为 1b 引入了非预期的停顿行为，回退 1b、保留 1a。**

配套要求：
- **1a 必须先单独提交**（步骤 1a-6 后），使 1b 可独立 `git revert`
- **Gate 3 分段判定**：1a 与 1b 各自给 PASS/FAIL，不得合并

---

## 11. Learning Content

### 11.1 一致性缺陷有两个修法方向

**朴素做法**：不一致就统一。

**为什么不够**：`config.yaml` 的绑定是**声明**，不是证据。该补还是该删，取决于**哪一侧有真实消费者**。Gate 的内容已内联 → 删声明。Alex/Blake 有活指针 → 本应补，**但补的东西本身带着未经裁定的纪律，所以先停下**。

**rev1 在这条上错了两次**：先是没区分声明与证据，后是查证据只查了一层（grep 字面量，没沿 reference 下钻）。

**可迁移判据**：
1. 修一致性前，先问「哪一侧有活消费者」——不是「哪一侧更规整」
2. 查「有无引用」必须**沿引用链下钻**，只 grep 字面量会漏掉一层间接
3. **改判据 = 判据失效，必须重测。旧测量值不随命令迁移。**
