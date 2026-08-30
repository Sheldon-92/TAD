---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
cancel_reason: scope-change
cancel_rationale: "Gate 2 发现 carrier map 与约束承载关系不准确，当前约束引用也已继续演化，原方案不可直接执行，后续须基于当前 skill 重新设计。"
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-08-16
**Project:** TAD Framework
**Task ID:** TASK-20260816-003
**Epic:** `EPIC-20260816-framework-health-repair.md` (Phase 1b/5)
**依据:** `.tad/active/designs/CARRIER-MAP-alex-constraints.md`（前置产物，必读）
**前置:** `HANDOFF-20260816-phase1a-pure-deletion.md` 必须先完成并提交

---

## 🔴 Gate 2

- [x] 需求明确
- [x] 技术方案完整（基于承载者地图，范围已精确界定）
- [x] AC 可运行，改前值全部实测（§9）
- [x] MQ1-MQ6 已回答（§5）
- [ ] 专家审查 ≥2 且 P0 已修 —— **待审**

---

## 1. Task Overview

### 1.1 What We're Building

退休 `alex/SKILL.md` frontmatter 的 `constraints:` + `migration:` 块（L6-146）。

**它是一层从未送达模型的声明层**（运行时实测：`deny_ref` / `source_baseline` / `enforcement` 在模型收到的内容里计数均为 0），**且无任何脚本读取**。

**但不能直接删** —— 里面有 4 条规则全仓找不到第二处承载。本单先补上它们，再删。

### 1.2 承载者地图的结论（决定本单范围）

对 `constraints:` 块的 31 条规则逐条查证（方法与三轮失败史见地图 §1）：

| 类别 | 条数 | 处置 |
|---|---|---|
| **有承载**（原文在正文或 references 中存活，位置多数**优于** frontmatter） | **26** | 只删索引，不搬内容 |
| **真孤儿**（全仓无第二处） | **4** | **必须先写入正文** |
| **半孤儿**（定义在 frontmatter，8 处引用在 references） | **1** | 需人裁定处置方式，见 §4.3 |

### 1.3 四条孤儿

| # | 规则 | 语义 | 为什么要紧 |
|---|---|---|---|
| **O1** | `deny.hook_scripts` | 不得创建/修改 `.tad/hooks/*.sh` | Alex 不写实现代码的具体面 |
| **O2** | `deny.tool_blocking` | 不得阻断 Write/Edit/Read 工具 | 防「hook 拒绝一切」事故（`principles.md` 2026-04-15 有实例） |
| **O3** | `skillify.create_directly` | Alex 不得直接创建 `.claude/skills/{slug}/SKILL.md` | **CLAUDE.md §4「Alex 不写实现代码」的编码** |
| **O4** | `skillify.call_from: blake` | 不得从 Blake 终端调用 | **CLAUDE.md §4 Terminal 隔离的编码** |

⚠️ **O3/O4 是框架核心不变式。** 前身单曾把 `skillify` 判为「已覆盖，只核对」，依据是它在正文出现 9 次 —— **那 9 次全是 `*harvest` 的命令描述和路径字符串，没有一条是禁令**。

### 1.4 Intent Statement

**要达成的**：删掉一层不生效的声明，同时保证它曾声明的每一条规则都有真实、会送达的承载者。

**不追求的**：把 26 条有承载的规则也搬进正文。**那会制造重复，且它们现在的位置更好**（与所治理的步骤同处一地，按需加载，常驻成本为零）。

---

## 📚 Project Knowledge（Blake 必读）

| Pattern | 相关点 |
|---|---|
| `ac-verification.md` | 本单 AC 全为计数式判定 |
| `shell-portability.md` | BSD/GNU grep 方言 |

**必须应用的两条**：

1. **代理指标不是本体。** 本单的承载者地图是这条教训的直接产物 —— 它迭代了四轮，前三轮判据都比问题窄（漏 references / 命中≠承载 / 禁令措辞不止 `MUST NOT`）。**Blake 若要判断「某规则有无承载」，必须用地图 §1 的判据并人眼确认。**
2. **改判据 = 判据失效，必须重测。**

### Blake 确认
- [ ] 我已读 `CARRIER-MAP-alex-constraints.md` 全文，特别是 §1 的方法与失败史

---

## 2. Background Context

### 2.1 Previous Work

前身 `HANDOFF-20260816-phase1-zero-risk-sweep.md` **两次 Gate 2 FAIL**（4 名 reviewer，15 个唯一 P0）。根因：把纯删除与退休声明层捆在一起，且**缺少承载者地图**。已拆分：纯删除 → `HANDOFF-1a`；本单 → 1b，以地图为前置。

### 2.2 Current State
- `HANDOFF-1a` 必须先完成并提交（本单的 AC 基线假定 1a 已落地）
- `bash .tad/hooks/lib/skill-body-verify.sh` → exit 0

### 2.3 Dependencies
`HANDOFF-1a`（顺序依赖，非内容依赖）

---

## 3. Requirements

### 3.1 Functional Requirements

| ID | 需求 |
|---|---|
| **FR-1** | 将 O1-O4 四条孤儿以**明文祈使句**写入 `alex/SKILL.md` 正文。措辞须与祖先原文语义一致（取回方式见 §4.2） |
| **FR-2** | 处置半孤儿 `enforcement: prompt-level-only` —— 二选一，需人裁定，见 §4.3 |
| **FR-3** | 改写 **16 处**悬空引用（6 个文件，含 `SKILL.md:703`），使其不再指向被删的块 |
| **FR-4** | 删除 frontmatter 的 `constraints:`（L6-129）、`migration:`（L131-146）、`constraints_schema:`（L4） |
| **FR-5** | `.claude` 与 `.agents` 两侧逐字节一致（SKILL.md + 5 个 reference 文件） |

### 3.2 Non-Functional Requirements
- **NFR1**：新增内容用明文祈使句，禁止 `deny_extra:` 风格的压缩 YAML
- **NFR2**：**不得搬运 26 条已有承载的规则** —— 会制造重复
- **NFR3**：不得改任何 `.sh` / `tad.sh` / hook
- **NFR4**：**不得增加正文的停顿条件数量**（见 AC-N4）

---

## 4. Technical Design

### 4.1 执行顺序（不可颠倒）

```
FR-1 写孤儿入正文  →  FR-3 改 16 处引用（指向新落点）  →  FR-4 删 frontmatter
```

**理由**：FR-3 要把引用指向 FR-1 创建的落点；FR-4 一旦先执行，FR-1 的内容来源（`deny_extra` 索引）就没了。

### 4.2 孤儿原文的取回

**不要用 `deny_ref`** —— 9 个锚点全部指向无关内容（已验证）。

**用 `migration.provenance.old_line`**，在祖先 `697c616e`（2026-06-02，实测 6145 行）解析：

```bash
A=697c616ee281f3ab3c604bfd31041e6da9b73f35
git show "$A:.claude/skills/alex/SKILL.md" | sed -n '2878,2884p'   # step1c_grounding（含 O1/O2 的全局形式）
git show "$A:.claude/skills/alex/SKILL.md" | sed -n '4232,4245p'   # skillify（含 O3/O4）
```

⚠️ **`deny_extra` 是有损索引**：祖先 `gate4_delta` 有 5 条，`deny_extra` 只编码 2 条。
**规则：祖先原文权威，`deny_extra` 只是查找清单。** 冲突时以祖先为准并在 completion 记录。

### 4.3 半孤儿 `enforcement: prompt-level-only` —— ✅ 人已裁定：方案 B

⚠️ **2026-08-17 实测推翻了本单起草时的假设**：

| | 起草时写的 | 实测 |
|---|---|---|
| 会悬空的引用数 | 8 处 | **4 处** |
| 已自足的写法 | 未提及 | **已有 2 处**且工作良好 |

**四处会悬空的**（形如 `# See constraints.enforcement (global)`）：
```
acceptance-protocol.md:360
cancel-protocol.md:103
experiment-path-protocol.md:109
express-path-protocol.md:53
```

**两处已自足的**（`handoff-creation-protocol.md:271` 与 `:450`）——**直接作为模板**：
```yaml
enforcement: "prompt-level-only"  # ⚠️ NOT a hook, NOT in settings.json, NOT a tool block
```

**✅ 裁定（人，2026-08-17）：方案 B —— 把那 4 处改成与已有 2 处相同的自足写法。**

理由：
- 正文是**常驻成本**，方案 A 会给每次激活加一条声明
- 仓内已有 2 处自足写法，选 B 使**全仓 6 处统一**；选 A 反而会造成两种写法共存
- 自足写法本身信息量更大（明写"不是 hook、不在 settings.json、不阻塞工具"），
  优于一个需要跳转的 `See constraints.enforcement`

### 4.4 16 处悬空引用的分布

| 文件 | 处数 | 备注 |
|---|---|---|
| `references/handoff-creation-protocol.md` | 6 | `:310`、`:445` 是**正文指令项**，非注释 |
| `references/acceptance-protocol.md` | 3 | |
| `references/express-path-protocol.md` | 2 | |
| `references/cancel-protocol.md` | 2 | |
| `references/experiment-path-protocol.md` | 2 | |
| **`SKILL.md:703`** | **1** | **在正文内，前身单遗漏** |

`.agents` 镜像同样 16 处 → 两侧合计 32。

**特殊情况**：`handoff-creation-protocol.md:308`/`:443` 含 `(inherits_global)` —— 这是**闭世界断言**（「本节除全局外无额外禁令」），正文无对应词汇。改写时须显式声明该断言被**丢弃**，不是重指，并在 completion 记录。

---

## 5. 强制问题回答

### MQ1 历史搜索
**是**。祖先定位与三轮失败史见 `CARRIER-MAP-alex-constraints.md` §1、§5。

### MQ2 位置存在性

| 位置 | 内容 | ✅ |
|---|---|---|
| `alex/SKILL.md:4,6-146` | `constraints_schema` / `constraints:` / `migration:` | ✅ |
| `alex/SKILL.md:703` | 第 16 处悬空引用（正文内） | ✅ |
| `alex/SKILL.md:701` | AR-001 anchor（正文，FR-4 后须存活） | ✅ |
| `handoff-creation-protocol.md:310,:445` | 正文指令项形式的悬空引用 | ✅ |
| 祖先 `697c616e` | 6145 行，`provenance.old_line` 可解析 | ✅ |

### MQ3 数据流
N/A。**等价检查**：31 条规则中 26 条已有承载（地图 §2-§4 逐条列出）、4 条由 FR-1 补齐、1 条由 FR-2 处置。**无遗漏由 AC-1c 核对。**

### MQ4 视觉层级
N/A。

### MQ5 状态同步

| 数据 | 位置1 | 位置2 |
|---|---|---|
| alex SKILL.md | `.claude/skills/alex/` | `.agents/skills/alex/` |
| 5 个 reference 文件 | 同上 | 同上 |

不同步 → `skill-body-verify.sh` FAIL（对 SKILL.md 与 references 目录均有 `diff -qr`）。

### MQ6 知识评估
预期产出：**「退休声明层前必须先做承载者地图」** —— 含该图四轮迭代的判据演进。已具备进 `patterns/ac-verification.md` 的资格。

---

## 6. Implementation Steps

| # | 步骤 | FR |
|---|---|---|
| 1 | 跑 §9 全部 AC 改前值，存档 | — |
| 2 | 按 §4.2 取回 O1-O4 祖先原文，与 `deny_extra` 核对并记录差异 | FR-1 |
| 3 | 写 O1-O4 入正文（明文祈使句） | FR-1 |
| 4 | 按人裁定结果处置 `enforcement` 标量 | FR-2 |
| 5 | 改写 16 处引用（含 `SKILL.md:703`），`(inherits_global)` 断言显式记为丢弃 | FR-3 |
| 6 | 删 frontmatter 三块 | FR-4 |
| 7 | 同步 `.agents`，跑全部 AC 改后值 | FR-5 |

**预计 3 小时。**

---

## 7. File Structure

**Modify**：
- `.claude/skills/alex/SKILL.md` + `.agents/skills/alex/SKILL.md`
- `.claude/skills/alex/references/{handoff-creation,acceptance,express-path,cancel,experiment-path}-protocol.md` + `.agents` 对应 5 个

### 7.4 Required Evidence Manifest
- `.tad/evidence/reviews/blake/phase1b-retire-frontmatter/` — ≥2 份独立 reviewer 文件
- `.tad/evidence/acceptance-tests/phase1b-retire-frontmatter/` — 每条 AC 改前/改后输出 + 步骤 2 的原文核对记录

---

## 8. Testing Requirements

无单元测试。**Friction Preflight**：`skill-body-verify.sh` 可跑 ✅；`git show 697c616e:...` 可解析 ✅

---

## 9. Acceptance Criteria

### 9.0 方言标注（逐条，不设通用规则）

`[F]`=`grep -F` ｜ `[BRE]`=`grep`（「或」写 `\|`）｜ `[ERE]`=`grep -E`（「或」写 `|`）

⚠️ 表格内的 `\|` 可能是 Markdown 排版转义，**按标注判断，不要机械替换**。含「或」的 AC 必须先跑正控。

**正文提取的唯一合法写法**：
```bash
B(){ awk 'NR>1 && /^---$/{f=1;next} f' "$1"; }
```
禁止 `sed -n '/^---$/,$p'`（锚在第 1 行，返回整个文件）。

**禁令语义全集**（判断「有无承载」必须用全集，不止 `MUST NOT`）：
```bash
P='MUST NOT|forbidden|禁止|不得|VIOLATION|never '
```

### 9.1 AC 表

| AC | 方言 | 命令 | 期望 | 改前实测 |
|---|---|---|---|---|
| **AC-1a** | `[ERE]` | O1：`B alex/SKILL.md \| grep -iE "$P" \| grep -ciE 'hooks/\*\.sh｜hook script'` | `≥1` | **0** 🔴 |
| **AC-1b** | `[ERE]` | O2：同法，模式 `never block.*(Write｜Edit｜Read)｜block.*(Write, Edit, Read)`（**须能与「某检查不阻塞流程」区分** —— 见 §9.2） | `≥1` | **0** 🔴 |
| **AC-1c** | `[ERE]` | O3：同法，模式 `create_directly｜skills/\{slug\}` | `≥1` | **0** 🔴 |
| **AC-1d** | `[ERE]` | O4：同法，模式 `call_from｜blake terminal｜Blake 终端` | `≥1` | **0** 🔴 |
| **AC-1e** | — | **逐条核对**：地图 §2-§4 的 31 条规则，每条在正文/references 有承载者且记录行号；差异记入 completion | 无遗漏 | — |
| **AC-2** | — | `enforcement` 按人裁定方案落地（A 或 B），completion 记录采用哪个及理由 | 已落地 | 未裁定 🔴 |
| **AC-3a** | `[BRE]` | `grep -rc 'constraints\.deny\|constraints\.section_overrides\|constraints\.enforcement' .claude/skills/alex/references/` 求和 | `0` | **15** 🔴 |
| **AC-3b** | `[BRE]` | `B .claude/skills/alex/SKILL.md \| grep -c 'constraints\.'` | `0` | **1** 🔴 |
| **AC-3c** | `[BRE]` | `.agents` 侧同 AC-3a | `0` | **15** 🔴 |
| **AC-4a** | `[F]` | `grep -cF 'deny_ref' .claude/skills/alex/SKILL.md` | `0` | **9** 🔴 |
| **AC-4b** | `[F]` | `grep -cF 'source_baseline' …` | `0` | **1** 🔴 |
| **AC-4c** | `[F]` | `grep -cF 'constraints_schema' …` | `0` | **1** 🔴 |
| **AC-4d** | `[BRE]` | frontmatter 行数：`awk 'NR==1{next} /^---$/{exit} {n++} END{print n}' …` | `≤5` | **145** 🔴 |
| **AC-N1** | `[F]` | **负控**：`grep -cF 'NOT_via_alex_auto: true' .claude/skills/alex/SKILL.md` | **`≥1`**（L701 正文那份须存活） | **2** ✅ |
| **AC-N2** | `[sh]` | **负控**：`bash .tad/hooks/lib/skill-body-verify.sh; echo $?` | `0` | **0** ✅ |
| **AC-N3** | `[F]` | **负控**：`cmp .claude/skills/alex/SKILL.md .agents/skills/alex/SKILL.md; echo $?`，5 个 reference 同法 | 全 `0` | **0** ✅ |
| **AC-N4** | `[ERE]` | **负控 NFR4**：`B alex/SKILL.md \| grep -cE 'AskUserQuestion｜STOP｜BLOCKING'` | **`≤26`** | **26** ✅ |
| **AC-N5** | `[ERE]` | **负控 NFR2（防重复）**：正文中不得出现 references 已有的禁令原句 —— 抽查 5 条已承载规则，正文计数须为 `0` | `0` | **0** ✅ |
| **AC-N6** | `[git]` | **负控 NFR3**：`git diff --name-only <1a提交SHA>..HEAD \| grep -cE '\.sh$'`（**用提交区间 + 行尾锚定**） | `0` | — |

### 9.2 ⚠️ AC-1b 的正控要求（本单最易翻车处）

`tool_blocking` 在 references 里有 **5 处**关键字命中，**经人眼确认全部是噪音**（说的是「某检查不阻塞流程」，如 `NEVER blocks — single-user CLI principle`），与「不得阻断 Write/Edit/Read 工具调用」语义不同。

**因此 AC-1b 的模式必须能区分二者。** Blake 须：
1. 先对 references 跑该模式 → **必须返回 0**（证明不会误把噪音当承载）
2. 再对改后的正文跑 → 必须 `≥1`

**若步骤 1 返回非 0，说明模式太宽，AC-1b 无效，须重设计。**

### 9.3 Expert Review Status —— 第 1 轮

**Reviewer A（`09438365`，承载者地图准确性）→ `1B MAP FLAWED`**
**Reviewer B（`34044966`，AC 与风险）→ `1B GATE2 BLOCKED`**

---

#### 🔴 A 的核心发现：地图是循环论证，实际有 **5 个孤儿**不是 4 个

**G1 `hook_registration` 被我判为「有承载」，依据是 `handoff-creation-protocol.md:310` 与 `:445`。**
实测那两行逐字是：
```
- "MUST NOT register hooks or modify settings — see constraints.deny (global)"
```
**它们本身就是指向被删块的悬空指针** —— 而同一张单的 FR-3 把它们算作待改的 16 处之一。
**用一个待删的指针去证明"内容有别处承载"，是循环论证。**

真正的候选全部**带范围限定**（实测）：
- `SKILL.md:750-751` —— `for friction enforcement in Phase 1`
- `handoff-creation-protocol.md:523` —— 只针对 `verify-ac-commands.sh` 一个脚本

→ **无条件的全局禁令没有承载者。G1 是第 5 个孤儿；G2 `settings_modification` 同病，仅条件承载。**
→ 连带 §5.3 的 `inherits_global` 恢复推论也不成立。

#### A 的其余四条（全部经我复核属实）

| # | 发现 | 复核 |
|---|---|---|
| 1 | `skillify.auto_invoke` 引的承载者 `body:1372` 说的是 **`*harvest`** 不是 skillify | ✅ 属实 |
| 2 | 悬空引用在 **`:702`** 不是 `:703`（我在四处引用了错误行号） | ✅ 属实 |
| 3 | 祖先 skillify 有 **5** 条 `MUST NOT`，`deny_extra` 只编码 4 —— **缺的那条本身也无承载**，是第 6 个潜在孤儿 | ✅ 实测 5 条 |
| 4 | O4 的「全仓无第二处承载」**说过头了** —— `hcp:719` 有 `在同一个 terminal 调用 /blake = VIOLATION` 泛化承载 Terminal 隔离 | ✅ 属实 |

**另有一条 A 主动提出、我未曾注意的**：`*skillify` 命令**在 `alex/SKILL.md` 中已不存在**
（实测 `grep -c '\*skillify'` = **0**，只剩 `*harvest`）。
→ **O3/O4 管的是一个已经退休的命令。** 这不使写入它们变得错误，但我在 §1.3 称其为
「框架核心不变式，需常驻重述」的论证**建立在一个已退休的命令上**。

---

#### 🔴 B 的三个 P0（全部经我复核属实）

| # | P0 | 实测 |
|---|---|---|
| **a** | **AC-N6 的占位符导致假 PASS** —— 命令写 `git diff --name-only <1a提交SHA>..HEAD`，SHA 全单未定义。**未填时 git 求值 `..HEAD` 返回 0，正好等于期望值** | ✅ **实测**：空占位符 → **0**（假 PASS）；真实区间 `01c4bf22..HEAD` → **262**。这是 NFR3 唯一的守卫，且是安全相关的负控 |
| **b** | **无 AC 证明 frontmatter 块真的没了**，只证明几个子 key 不见了。部分删除（留下 `constraints:` 裸键带小 body）可通过 AC-4a/b/c/d | ✅ **实测**：裸键检查当前返回 **2**，而现有 AC 查不到这一层 |
| **c** | **AC-N5 不可执行** —— 「抽查 5 条已承载规则」无规则名、无模式、无方言，改前值 `0` **不可复现**。而 NFR2 与硬禁止 #1 全靠它 | ✅ 属实。且抽 5/26 本身就留下 21 条无守卫 |

**B 另指出**：§9.1 未随 §4.3 的方案 B 裁定更新 —— AC-2 仍写「A 或 B / 未裁定 🔴」，
§10.1 #4 仍禁止选择，且**无 AC 验证方案 B 要达成的「全仓 6 处统一」**
（实测自足写法当前 **2** 处，改后须为 **6**）。

---

### 9.4 Gate 2 判定：**FAIL**（2026-08-17，第 1 轮）

⚠️ **这次 FAIL 与本 Epic 以往的不同**：以往是 AC 判据有缺陷，**这次是前置产物本身错了**。

`CARRIER-MAP-alex-constraints.md` 的「26 条有承载 / 4 条孤儿」结论**不成立** ——
至少 5 个孤儿，可能 6 个；且其中一条的「有承载」判定是**循环论证**。

**照本单原样实施，会静默删除 G1/G2 两条无条件的全局禁令**（不得注册 hook、不得改 settings.json），
只留下两条带范围限定的替代品。**这正是本单存在的理由所要防止的事。**

**→ 必须先重做承载者地图（用不把悬空指针算作承载的判据），再重出本单。**
按 `max_review_rounds: 2`，本单**不进入第 2 轮** —— 因为要改的不是 AC，是前置输入。

---

## 10. Important Notes

### 10.1 五条硬禁止

1. **禁止搬运 26 条已有承载的规则。** 它们现在的位置更好。AC-N5 拦这个。
2. **禁止用 `deny_ref` 取原文** —— 9 个锚点全部指向无关内容。用 `provenance.old_line`。
3. **禁止在 FR-1/FR-3 完成前删 frontmatter**（顺序 §4.1）。否则原文来源消失、引用悬空。
4. **禁止自选 `enforcement` 的处置方案** —— §4.3 未决，须人裁定。
5. **禁止增加正文停顿条件。** 本单迁移的是「禁止做 X」，不是「停下问人」。AC-N4 拦这个。

### 10.2 遇到以下必须停下上报
- AC-1b 的正控（对 references 返回 0）不成立 → 模式无效
- 祖先原文与 `deny_extra` 冲突且无法判断哪个是当前意图
- 任何负控（AC-N1~N6）不再是改前值

### 10.3 Sub-Agent 建议
- **AC-1e 的 31 条逐条核对由独立 subagent 执行**，禁止自审
- FR-1 写完后调 `code-reviewer` 单独审新增段落：首次生效的约束，措辞歧义直接变行为偏差

---

## 11. Learning Content

### 11.1 退休一个声明层，必须先做承载者地图

**朴素做法**：这块没人读、没送达 → 直接删。

**为什么不够**：「没人读」和「内容没别处存」是两回事。31 条规则里 26 条在别处活着（且位置更好），4 条只活在这里 —— **其中 2 条是 CLAUDE.md §4 的核心不变式**。不做图就删，等于静默移除框架的两条基本约束。

**为什么图难做**：它迭代了四轮，前三轮判据都比问题窄 ——
1. 只搜正文（漏 references）
2. 关键字命中即算承载（`exit_codes` 的 16 处全是普通 bash 退出码）
3. 只认 `MUST NOT`（漏 `forbidden interpretation` / `禁止`）

**可迁移判据**：
> **退休声明层前先做承载者地图。** 逐条问「原文还活在哪」，判据须覆盖**禁令语义全集**，命中后**人眼确认语义对应**。
> 缺图时删除与迁移互相污染 —— 分不清「删干净了」和「删过头了」。
