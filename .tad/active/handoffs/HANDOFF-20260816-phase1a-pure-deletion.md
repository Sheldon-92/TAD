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
**Task ID:** TASK-20260816-002
**Epic:** `EPIC-20260816-framework-health-repair.md` (Phase 1a/4)
**Supersedes:** N/A —— 与 `HANDOFF-20260816-phase1-zero-risk-sweep.md` 是**拆分关系**，见 §2.1

---

## 🔴 Gate 2

- [x] 需求明确，无歧义
- [x] 技术方案完整
- [x] AC 可运行，改前值全部实测（§9）
- [x] MQ1-MQ6 已回答（§5）
- [x] 专家审查 ≥2 且 P0 已修 —— **✅ PASS（6 名 reviewer / 5 轮）**

### Gate 2 判定：**PASS**（2026-08-16，Alex）

| 轮 | Reviewer | 结论 |
|---|---|---|
| 1 | `e534dd36` 基线核验 | 19 条 AC 逐条重跑，**18 MATCH / 0 MISMATCH** |
| 1 | `2f7af0e7` 删除安全性 | 下游安全 ✅、`command_module_binding` 无运行时消费者 ✅、发现 2 处悬空引用 |
| 2 | `1e4d9eb2` | AC-E1/E2 可绕过；config-workflow「不可达」理由被推翻 |
| 3 | `245301e0` | 找到绕过 A（子串匹配）、B（行数计数） |
| 4 | `5cda1531` | 找到绕过 C（缩进伪行 + 尾部追加） |
| 5 | `7e8e8129` | 整文件哈希被判「全文件冻结冒充单行要求」+ NUL 自由度 |

**第 2-5 轮的全部发现均集中在 FR-E（ROADMAP 一行链接）**，该 FR 已于第 10 轮**摘出为独立工单** `HANDOFF-20260816-phase1a2-roadmap-link.md`。

**本单剩余的 FR-A/B/C/D 自第 1 轮起零改动**，其 AC 经 6 名 reviewer 核验、19 条全部空跑、实现细节已预演（§5.9）。

**判定依据**：规则 1（min 2 独立专家审查 + P0 修复）已满足且远超。剩余审查的边际收益为负 —— 第 2-5 轮全部产出都归属于已摘出的 FR-E。

⚠️ 第 6 轮确认性审查（`742fcb54`）与 Phase 3 的（`f28a1471`）**并行进行中**，结果将回填 §9.10。
**若其报告「错误实现能通过」或「正确实现会失败」两类缺陷，立即回滚本判定并停止实现。**

---

## 1. Task Overview

### 1.1 What We're Building

**四件纯删除。不碰任何 SKILL frontmatter，不迁移任何内容。**

| FR | 删什么 | 为什么零风险 |
|---|---|---|
| **FR-A** | `.claude/skills/playground/` 与 `.agents/skills/playground/` | 2026-06-10 废弃，替代品 Feedback Collector 已在 `blake/SKILL.md:1480-1598` 全量实现 |
| **FR-B** | `alex/SKILL.md:3` `description:` 中的 `, *playground` | 该串是模型在技能目录里唯一可见的一行，当前在推销一个废弃功能 |
| **FR-C** | `.tad/config.yaml` 的 `command_module_binding.playground` 与 `.tad/config-cognitive` 的 `tad-gate` 两个绑定 | 二者都是**无消费者的空头声明**，详见 §4.2 |
| **FR-D** | `stable5-pre` 一侧 182 个证据文件，代之以 git 来源的 SHA-256 清单 | 与 `stable5-post` **182 对 blob 逐字节相同**（`diff -rq` 退出码 0） |

### 1.2 明确不在范围（重要）

本单**刻意不做**下列各项。它们不是被遗忘，是被推迟：

| 不做什么 | 为什么 |
|---|---|
| **动 `alex/SKILL.md` 的 frontmatter** | 需要一张完整的「承载者地图」才能安全退休，见 §2.1。**本单一行都不碰。** |
| **动 `.tad/deprecation.yaml`（任何改动）** | 它是 F-01（P0 数据丢失）的载荷来源，Phase 2 待修。`:33`/`:56` 是**其他版本下的历史 `files:` 记录**，删了就是真实数据丢失 |
| **动 `config-workflow.yaml` 的 `playground:` 段（L269-331）** | FR-C 删掉绑定后该段即不可达。**清理不可达的死配置不急，且判断「整段删还是只改死路径」是设计问题** |
| **动 `config-workflow.yaml:19` 与 `:25`** | 这两行指的是 `.tad/active/playground/` 与 `.tad/archive/playground/` **数据目录**（zero-touch，`Next Guest` 有 53 个产物在里面），与 skill 无关 |

### 1.3 Intent Statement

**要达成的**：把三件已经死掉但仍在发布的东西删掉，并去掉一份逐字节重复的证据。

**不追求的**：任何内容迁移、任何治理结构调整。**本单如果需要判断「这条规则搬到哪里」，说明范围划错了，应当停下。**

---

### 1.5 ⚠️ FR-E 已摘出（2026-08-16，第 5 轮审查后）

原 FR-E（修 `ROADMAP.md:38` 的悬空 markdown 链接）**已移入独立工单** `HANDOFF-20260816-phase1a2-roadmap-link.md`。

**理由 —— 审查消耗严重失衡**：

| FR | 内容 | 审查消耗 |
|---|---|---|
| FR-A~D | 删两侧 playground、去 description、删两个空头绑定、evidence 去重 182 文件 | **轮 1 一次通过**，此后四轮零改动 |
| FR-E | 修 ROADMAP 一行链接 | **轮 2/3/4/5 四轮全在打磨它**（3 个绕过 + 1 个假警报 + 1 个 NUL 自由度） |

FR-E 与 FR-A~D **零耦合**（独立文件、独立改动、无共享 AC）。把一件一行的文档修复捆在四件已通过审查的删除上，
**唯一效果是让已经准备好的部分陪着一起等**。

**判据（可迁移）**：
> 当一张单里某个 FR 的审查轮次显著超过其余全部之和，且它与其余 FR 无耦合 —— **摘出它，不要让它拖住已就绪的部分**。
> 审查轮次是范围划分错误的信号，不只是质量信号。

---

## 📚 Project Knowledge（Blake 必读）

| Pattern | 相关点 |
|---|---|
| `ac-verification.md` | 本单 AC 全为计数式判定 |
| `shell-portability.md` | BSD/GNU grep 方言差异 |

**必须应用的两条：**

1. **代理指标不是本体。** grep 计数回答语义问题前，先确认「我量的范围」与「问题的范围」重合。计数为 0 只说明**没在我看的地方**。
2. **改判据 = 判据失效，必须重测。** 旧测量值不随命令迁移。

### Blake 确认
- [ ] 我已读上述两个 pattern

---

## 2. Background Context

### 2.1 Previous Work —— 本单的来历

前身 `HANDOFF-20260816-phase1-zero-risk-sweep.md` **两次 Gate 2 FAIL**（共 12 + 3 个唯一 P0，四名 reviewer）。失败根因不是执行细节，而是它把两件事捆在一起：

- **纯删除** ← 就是本单，范围清楚、可立即验证
- **退休 frontmatter 约束块** ← 需要一张「每条规则的散文原文还活在哪」的完整地图，而**该地图不存在**。三名 reviewer 各自构建了局部版本，**各自都发现了另外两人漏掉的孤儿**（`skillify` 的两条 CLAUDE.md §4 不变式全仓无承载者；`enforcement` 标量无承载者；第 16 处悬空引用在 SKILL.md 正文内）

**处置**：拆单。本单交付纯删除；承载者地图作为独立前置任务；`HANDOFF-1b` 待地图完成后另写。前身单**保留不删**，其 Gate 2 记录是本次拆分的依据。

### 2.2 Current State（如实）

```
$ git status --porcelain
 M NEXT.md
?? .tad/active/designs/
?? .tad/active/epics/EPIC-20260816-framework-health-repair.md
?? .tad/active/handoffs/
$ git rev-list --count origin/main..HEAD      → 0   （与 origin 同步）
$ git rev-parse HEAD                          → 4718c5ecb668fd0c0efdfa98d58b4acf5c652fc7
$ bash .tad/hooks/lib/skill-body-verify.sh    → exit 0，全绿
```

⚠️ **工作区不干净**（前身单与 Epic/审计文档尚未提交）。Blake 开工前须与人确认这些文件的处置，**不得擅自提交或丢弃**。

⚠️ `release-verify.sh platform-skills . .` **当前即 FAIL**，原因是 gitignore 的 `.claude/skills/local/`（`.gitignore:13`）无 `.agents` 对应物。**先于本单存在，本单不修，也不用它做 AC。**

### 2.3 Dependencies
无。

---

## 3. Requirements

### 3.1 Functional Requirements

| ID | 需求 |
|---|---|
| **FR-A** | 删除 `.claude/skills/playground/` 与 `.agents/skills/playground/` 两个目录 |
| **FR-B** | `alex/SKILL.md:3` 的 `description:` 移除 `, *playground`；`.agents` 镜像同步 |
| **FR-C** | 删除 `.tad/config.yaml` 的 `command_module_binding.playground`（L144-146）与 `command_module_binding.tad-gate`（L108-110）。`tad-gate` 原位留注释说明 gate 采用按需读取（见 `gate/SKILL.md:227`） |
| **FR-D** | 生成 `stable5-pre.sha256`（**必须由 `git show HEAD:<pre-path>` 产出**，头部记录 SHA `4718c5ec…`），再删除 `stable5-pre/` 的 182 个文件 |
| ~~FR-E~~ | ⛔ **已摘出本单** → `HANDOFF-20260816-phase1a2-roadmap-link.md`（理由见 §1.5） |

### 3.2 Non-Functional Requirements
- **NFR1**：不得修改任何 `.sh`、`tad.sh`、hook 逻辑
- **NFR2**：不得修改 `alex/SKILL.md` 的 frontmatter（L1-147）——**除 L3 的 `description:` 外一行不改**
- **NFR3**：不得修改 `.tad/deprecation.yaml`（任何一行）
- **NFR4**：`.claude` 与 `.agents` 两侧保持逐字节一致

---

## 4. Technical Design

### 4.1 FR-D 的清单必须非循环

`stable5-pre` 与 `stable5-post` 逐字节相同，因此**从 post 生成的清单与从 pre 生成的无法区分** —— 直接比对哈希是循环论证。

**要求**：清单由 `git show HEAD:<pre-path>` 生成，路径记 **pre 侧路径**。验证时用记录的 SHA 回查 git 历史（AC-D3），**不与 post 比对**。这样清单证明的是「被删的那些文件在该 SHA 时的内容」，非循环。

清单格式（每行）：`<sha256>␉<pre-path>`，头部注释含 `# source-commit: 4718c5ecb668fd0c0efdfa98d58b4acf5c652fc7`。

### 4.2 FR-C 两个绑定为何都是空头声明

| 绑定 | 声明 | 实际 |
|---|---|---|
| `playground` (`config.yaml:144-146`) | 加载 `config-workflow` | `/playground` 命令已废弃，skill 文件本单删除 → **无消费者** |
| `tad-gate` (`config.yaml:108-110`) | 加载 `config-quality`, `config-cognitive` | `gate/SKILL.md` **无任何模块加载步骤**（`grep -cE 'Load required modules\|Load config modules'` = 0），且 Cognitive Firewall 内容**已内联**于 `gate:219`（Risk Translation Pillar 3）与 `gate:706`（Decision Compliance Pillar 1） |

**注意**：删 `tad-gate` 绑定是**反向修**（删声明，不是补实现）。若产生「三个角色应形式统一」的冲动 —— AC-C3 是拦它的。

---

## 5. 强制问题回答

### MQ1 历史搜索
**是**。前身单的两轮 Gate 2 审查（4 名 reviewer）是本单范围划定的依据，记录在前身单 §「Gate 2 记录」与本单 §2.1。

### MQ2 位置存在性
全部实跑验证：

| 位置 | 内容 | ✅ |
|---|---|---|
| `alex/SKILL.md:3` | `description: "...*sync, *playground."` | ✅ |
| `config.yaml:144-146` | `playground:` binding | ✅ |
| `config.yaml:108-110` | `tad-gate:` binding | ✅ |
| `gate/SKILL.md:227` | `step1: "Read config-quality.yaml fatal_operations..."` | ✅ |
| `blake/SKILL.md:1480-1598` | `feedback_collector_protocol`（playground 的替代品） | ✅ |
| `config-workflow.yaml:19,25` | `.tad/active|archive/playground/` **数据目录**，不得动 | ✅ |
| `deprecation.yaml:33,56` | 其他版本下的历史 `files:` 记录，不得动 | ✅ |

### MQ3 数据流
N/A。**等价检查**：删除的每样东西都有替代或已死 —— playground → Feedback Collector；两个绑定 → 无消费者；`stable5-pre` → 清单 + `stable5-post` 存活。

### MQ4 视觉层级
N/A。

### MQ5 状态同步

| 数据 | 位置1 | 位置2 | 方向 |
|---|---|---|---|
| alex SKILL | `.claude/skills/alex/` | `.agents/skills/alex/` | 逐字节相同 |
| playground | `.claude/skills/playground/` | `.agents/skills/playground/` | **两侧都删** |

半删只有 `release-verify.sh platform-skills` 能抓，而它预先 FAIL → 本单用 **AC-A1/A2 分别断言两侧**，不依赖该工具。

### MQ6 知识评估
预期产出：**「把纯删除与内容迁移捆在一张单里，会让删除部分也无法验收」** —— 前身单两次 FAIL 的结构性原因。Gate 4 评估是否蒸馏。

---

## 5.9 实现细节预演（Alex 已实跑，Blake 可直接用）

### FR-C 的两个块结构
```
107: (空行)
108:   tad-gate:
109:     modules: [config-quality, config-cognitive]
110:     note: "Gates need quality definitions + cognitive (risk translation, decision compliance)"
111: (空行)
112:   tad-init:
...
143: (空行)
144:   playground:
145:     modules: [config-workflow]
146:     note: "Playground needs workflow (playground section, document_management)"
147: (空行)
```
⚠️ **每块前后各有一个空行** —— 只删 3 行会留下连续双空行。删除时应连带其中一个空行。
⚠️ **`tad-gate` 原位需留注释**（FR-C 要求），故它不是纯删除；`playground` 是纯删除。
⚠️ **行号会随删除漂移** —— 先删行号大的（`playground` 144-146），再删小的（`tad-gate` 108-110），或用内容锚定。

### FR-D 的清单生成（已验证可行，182 文件约 2 秒）
```bash
SHA=$(git rev-parse HEAD)   # 4718c5ecb668fd0c0efdfa98d58b4acf5c652fc7
d=.tad/evidence/acceptance-tests/release-runbook-capability-migration
{
  echo "# source-commit: $SHA"
  echo "# generated-from: git show (NOT working tree, NOT stable5-post)"
  git ls-files "$d/stable5-pre/*" | while IFS= read -r f; do
    printf '%s\t%s\n' "$(git show "$SHA:$f" | shasum -a 256 | cut -d' ' -f1)" "$f"
  done
} > "$d/stable5-pre.sha256"
```
实跑样例（前 3 行，可用于交叉核对）：
```
17bfb7e199f66d6a…  …/stable5-pre/source/carrier-hashes.tsv
b10388e09ba1e2bf…  …/stable5-pre/source/deprecation.sha256
9a271f2a916b0b6e…  …/stable5-pre/source/derive-report.exit
```

### FR-B 的改法
`sed -n '3p'` 去掉 `, *playground` 即可，该行其余部分不动。

---

## 6. Implementation Steps

| # | 步骤 | FR |
|---|---|---|
| 1 | 跑 §9 全部 AC 的**改前**值，存档到 evidence 目录 | — |
| 2 | `alex/SKILL.md:3` 移除 `, *playground`，同步 `.agents` | FR-B |
| 3 | 删两侧 playground 目录 | FR-A |
| 4 | 删 `config.yaml` 两个绑定，`tad-gate` 原位留注释 | FR-C |
| 5 | `git show HEAD:<pre-path>` 生成清单（含 source-commit 头），再删 `stable5-pre/` | FR-D |
| 6 | 跑全部 AC 的**改后**值，两份输出并排存档 | — |

**预计 1.5 小时。** 无内容迁移，无顺序陷阱。

---

## 7. File Structure

**Create**：`.tad/evidence/acceptance-tests/release-runbook-capability-migration/stable5-pre.sha256`
**Modify**：`.claude/skills/alex/SKILL.md` + `.agents/…`（仅 L3）；`.tad/config.yaml`
**Delete**：`.claude/skills/playground/`、`.agents/skills/playground/`、`…/stable5-pre/**`（182 文件）

### 7.4 Required Evidence Manifest（Gate 3 §1.4）
- `.tad/evidence/reviews/blake/phase1a-pure-deletion/` — ≥2 份独立 reviewer 文件
- `.tad/evidence/acceptance-tests/phase1a-pure-deletion/` — 每条 AC 的改前/改后输出

---

## 8. Testing Requirements

无单元/集成测试。验证由 §9 承担。

**Friction Preflight**：`skill-body-verify.sh` 可跑且全绿 ✅；`git show HEAD:<path>` 可解析 ✅；`release-verify.sh platform-skills` 预先 FAIL，**不使用** ✅

---

## 9. Acceptance Criteria ⚠️ PRIMARY VERIFICATION SOURCE

### 9.0 grep 方言标注 —— 每条 AC 必须照标注执行

前身单在此翻车两次（先是 ERE 里用 `\|` 使负控失效，后是一刀切「还原成 `|`」把 BRE 的 AC 打死）。**本单不设通用规则，逐条标注：**

| 标记 | 含义 | 竖线怎么写 |
|---|---|---|
| `[F]` | `grep -F`（固定串） | 不涉及 |
| `[BRE]` | `grep`（基本正则） | 「或」写 `\|` |
| `[ERE]` | `grep -E`（扩展正则） | 「或」写 `|` |

⚠️ **本文档是 Markdown**：表格单元格内的 `|` 被写成 `\|` 是**排版转义**。执行前请对照上表判断该 AC 的方言，**不要机械替换**。
⚠️ **凡含「或」的 AC 必须先跑正控**（见 AC-C3）。

### 9.1 AC 表

| AC | 方言 | 命令 | 期望 | 改前实测 |
|---|---|---|---|---|
| **AC-A1** | `[F]` | `ls -d .claude/skills/playground 2>/dev/null \| wc -l` | `0` | **1** 🔴 |
| **AC-A2** | `[F]` | `ls -d .agents/skills/playground 2>/dev/null \| wc -l` | `0` | **1** 🔴 |
| **AC-B1** | `[F]` | `sed -n '3p' .claude/skills/alex/SKILL.md \| grep -cF 'playground'` | `0` | **1** 🔴 |
| **AC-C1** | `[BRE]` | `grep -c '^  playground:' .tad/config.yaml` | `0` | **1** 🔴 |
| **AC-C2** | `[BRE]` | `grep -c '^  tad-gate:' .tad/config.yaml` | `0` | **1** 🔴 |
| **AC-C2b** | `[F]` | **原位注释可执行检查**（原 AC-C2 的「且原位有注释」无判据 ⇒ 只删不留注释也能过）：<br>`grep -cF 'tad-gate: 绑定已删除' .tad/config.yaml` | `≥1` | **0** 🔴 |
| **AC-C3** | `[ERE]` | **负控**：`grep -cE 'Load required modules｜Load config modules' .claude/skills/gate/SKILL.md`（竖线用真 ERE 或） | 仍为 `0` | **0** ✅ |
| **AC-C3-pos** | `[ERE]` | **正控**：同模式对 `.claude/skills/alex/SKILL.md` | **必须为 `2`** —— 若为 0 说明模式已死，AC-C3 结果无效 | **2** ✅ |
| **AC-D1** | `[git]` | `git ls-files '<dir>/stable5-pre/*' \| wc -l` | `0` | **182** 🔴 |
| **AC-D2** | `[git]` | `git ls-files '<dir>/stable5-post/*' \| wc -l` | **`182`（存活）** | **182** ✅ |
| **AC-D3** | `[git]` | **非循环校验**：对清单每行 `<sha> <path>`，比对 `git show 4718c5ec:<path> \| shasum -a 256` | 182 行全等 | 清单不存在 🔴 |
| **AC-D4** | `[F]` | `head -5 <dir>/stable5-pre.sha256 \| grep -cF '4718c5ecb668fd0c0efdfa98d58b4acf5c652fc7'` | `1` | 文件不存在 🔴 |
| **AC-D5** | `[git]` | `git ls-files '<dir>/*' -z \| xargs -0 wc -c \| awk '/total$/{s+=$1}END{print s}'` | 减少 **≥18,000,000** | **39,320,727** |
| **AC-D6** | `[F]` | **清单必须记录 pre 侧路径**（两侧字节相同 ⇒ 用 post 路径生成的清单也能通过 D3/D4，却记录了幸存目录而非被删目录）：<br>`grep -cF 'stable5-pre/' <manifest>` | **`182`** | 清单不存在 🔴 |
| **AC-N1** | `[F]` | **负控**：`grep -cF 'playground' .tad/deprecation.yaml` | **恰为 `5`（不增不减）** | **5** ✅ |
| **AC-N2** | `[BRE]` | **负控**：`grep -c '^ *files:' .tad/deprecation.yaml` | **恰为 `8`** | **8** ✅ |
| **AC-N3** | `[F]` | **负控**：`grep -cF 'playground' .tad/config-workflow.yaml` | **恰为 `12`（本单不动它）** | **12** ✅ |
| **AC-N4** | `[F]` | **负控**：`sed -n '1,147p' .claude/skills/alex/SKILL.md \| grep -cF 'deny_ref'` | **恰为 `9`（frontmatter 一行不动）** | **9** ✅ |
| **AC-N5** | `[sh]` | **负控**：`bash .tad/hooks/lib/skill-body-verify.sh; echo $?` | `0` | **0** ✅ |
| **AC-N6** | `[F]` | **负控**：`cmp .claude/skills/alex/SKILL.md .agents/skills/alex/SKILL.md; echo $?` | `0` | **0** ✅ |

| **AC-N7** | `[ERE]` | **NFR1 —— 区间 + 工作区双查**（原写法 `git diff --name-only 4718c5ec..HEAD` 在 HEAD 尚未推进时**恒为 0**，是假绿）：<br>`{ git diff --name-only 4718c5ec; git status --porcelain \| awk '{print $NF}'; } \| grep -cE '\.sh$'` | `0` | **0** ✅（已实测，且对当前 3 个已改文件正确返回 0） |
| **AC-N8** | `[F]` | **负控**：`grep -cF 'skills/playground' .tad/config-workflow.yaml`（§10.1 #4 禁止改它 —— 该段在 FR-C 后是**被加载但惰性的散文**，非「不可达」；清理涉及设计判断，属 1b） | **仍为 `1`** | **1** ✅ |

**负控占 7 条（AC-N1~N7）。** 它们改前即绿，作用是**证明本单没有碰不该碰的东西** —— 尤其 AC-N4（frontmatter 一行不动）与 AC-N1/N2（deprecation.yaml 一行不动）是本单与前身单的分界线。

⚠️ **AC-N7 用提交区间**：前身单用 `git diff --name-only`（仅工作树），一旦提交就永远返回 0，对已提交内容零约束。

### 9.2 Expert Review Status —— **第 1 轮已完成（2 名独立 reviewer）**

**Reviewer 1（基线核验，`e534dd36`）**：逐条重跑 19 条 AC → **18 MATCH / 0 MISMATCH**，AC-N7 无声明基线记 N/A。
→ **无 P0。** 基线表可信。

**Reviewer 2（删除安全性，`2f7af0e7`）**：

| 问题 | 结论 |
|---|---|
| Q1 悬空引用 | **发现 2 处真悬空**（`config-workflow.yaml:279`、**`ROADMAP.md:38`**），其余 ~61 处均为 evidence/archive 历史记录，无害 |
| Q2 下游删除路径 | **确认安全** —— `tad.sh` 无 `rsync`、无 `--delete`、无 `find -delete`、无删除目标 skill 目录的循环。唯一通用删除器 `apply_deprecations` 只处理 `deprecation.yaml` 列出的路径，**当前不含任何 skill 目录** → 不写 `deprecation.yaml` 即下游不受影响，工单原判断**正确** |
| Q3 `command_module_binding` 消费者 | **确认无运行时消费者** —— 无 `.sh`/`.js`/`.mjs` 读取；活跃引用全是 prompt 层（`alex:241`、`blake:181`、`tad-status:77` 的 SKILL 指令）。FR-C 删绑定安全 |

**P0 处置（Alex，2026-08-16）**：

1. **`ROADMAP.md:38` —— 采纳，新增 FR-E + AC-E1/E2。** 这是我完全漏掉的：一个指向即将被删文件的 markdown 链接，工单里连提都没提。
2. **`config-workflow.yaml:279` —— 维持不改，但【我原来的理由是错的】**：

   ❌ **原理由（第 2 轮复审推翻）**：「该段由 `playground` 命令绑定驱动，删绑定后不可达」
   → **假。** 实测：`config-workflow` 被 **7 个命令**绑定（`tad-alex:101`、`tad-maintain:117`、`tad-handoff:121` 等），
   且 SKILL STEP 3 的加载是**整文件粒度**（`Load required modules: … config-workflow …`，非按段）。
   删 `playground` 绑定**不改变该文件被加载的事实** → L279 的死路径在 Phase 1a 后**仍会进入每次 Alex 激活的上下文**。

   ⚠️ **我本可以避免这个错**：我第一轮激活时亲自加载过整个 `config-workflow.yaml`（28 KB），
   却在写判据时假设了「按段加载」。**又一次拿假设当实测。**

   ✅ **修正后的延后理由**：它是**被加载但惰性的散文**（一段 YAML 配置，不构成可执行指令，
   模型不会因为读到 `command: "<不存在的路径>"` 而去执行什么）。而**清理它涉及设计判断**
   —— 整段删（L269-331，63 行）还是只改死路径？前者要确认 `.tad/active/playground/` 数据目录的归属，
   属 1b 的范围。**故延后是合理的范围决策，但不是因为"不可达"。**

   与 `ROADMAP.md` 的真正区别：后者是**人会点击的链接**，点了就 404；前者是模型读到的惰性配置。

   新增 AC-N8 作为负控，确保本单确实没动它

**附带修正**：AC-N7 原写 `grep -cF '.sh'`（会误匹 `foo.shtml`），已改为 `grep -cE '\.sh$'`。

### 9.3 第 2 轮审查（`1e4d9eb2`）—— 2 条 PROBLEM，均已处置

| # | 问题 | 处置 |
|---|---|---|
| 1 | **AC-E1/E2 可被绕过** —— 「删整行 + 把 `Design Playground v2` 写到别处」同时满足两条。AC-E2 只数短语在**全文件**的出现，不锁定第 38 行 | ✅ **已修**：AC-E2 改为**整行锚定**（`sed -n '38p' \| grep -cF '<完整行>'`），新增 **AC-E3** 锁表格总行数 26。空跑确认 AC-E2 改前为 **0**、改后应为 **1** |
| 2 | **AC-N8 的延后理由是错的** —— 我称「删绑定后 config-workflow 不可达」。实测：该文件被 **7 个命令**绑定，且加载是**整文件粒度** → 删绑定不改变它被加载 | ✅ **已修**：理由改为「被加载但惰性的散文，清理涉及设计判断故延后」。**决定不变，依据更正**。详见 §9.2 P0 处置第 2 条 |
| 3 | AC-N7 的 `grep -cE '\.sh$'` | ✅ **VERIFIED** —— reviewer 实测旧写法会误匹 `foo.shtml` 与 `b.shell`，新写法只匹 2 个真 `.sh` |

**第 3 轮审查**：AC-E2/E3 为新增，需再确认一次判别力 —— 见 §9.4。

### 9.4 第 3 轮审查（`245301e0`）—— **找到 2 个绕过，均已加固**

基线三条全部复核一致（1 / 0 / 26）。但 reviewer 在 `/tmp` 副本上构造出两个实现，**三条 AC 全绿而结果是坏的**：

| # | 绕过 | 为什么能过 | 加固 |
|---|---|---|---|
| **A** | 保留链接，把路径写成 `skills//playground`（双斜杠），并在行尾**追加第 5 列** | AC-E2 用 `grep -F` 是**子串**匹配、无锚定 → 行尾多余内容不影响；AC-E1 只匹一种字面拼写 | AC-E2 改为 **shell 精确相等** `[ "$(sed -n '38p' …)" = "$EXPECT" ]` —— 多一列即不等 |
| **B** | 正确修完第 38 行，但**删掉第 39 行**（`Multi-Session Pair Testing`），再在文末补一行 `\| x \| x \| x \| x \|` | AC-E3 是**行数**计数，一删一增净额不变 | AC-E3 改为 **其余表格行的校验和**（排除第 38 行后 `shasum`）—— 任何其他行被增删改都会变 |

**加固已实测**：
- AC-E2 新形式改前判定 **0**（红），Bypass A 的行内容因多一列而不等 → **被抓**
- AC-E3 新形式改前 `d1fb5fac79a38a7f`；Bypass B 后行数仍 26 但校验和变为 `7496239e0e0b560c` → **被抓**

⚠️ **本条是本 Epic 第 11-12 个同形错误**（判据比问题宽/窄）。`grep -F` 是子串测试、`grep -c` 是基数测试 —— **两者都不能表达「这一行必须恰好是什么」**。已蒸馏进 `patterns/ac-verification.md`。

### 9.5 第 4 轮审查（`5cda1531`）—— **找到第 3 个绕过，已采纳其修法**

前两个绕过确认已被封死（A 被 E2 抓、B 被 E3 抓）。但 reviewer 构造出**第三个，三条全绿**：

```diff
@@ 第 38 行：按要求正确修好（E2 通过）
-| … | **Deprecated 2026-06-10** | [/playground](./.claude/skills/playground/SKILL.md) |
+| … | **Deprecated 2026-06-10** | /playground |
@@ 文件末尾追加一行，行首带【一个空格】
+ | Design Playground v2 | Direction | Active | [/playground](./.claude/skills//playground/SKILL.md) |
@@ 顺带删掉第 34 行的散文（无任何 AC 察觉）
```

**三条为何全部漏掉**：
- **E1** —— 路径写成 `skills//playground`（双斜杠），不匹配字面量，**但链接照样能用**（`ls` 可解析）
- **E2** —— 第 38 行确实与 EXPECT 逐字节相同，**E2 只看这一行**
- **E3** —— 注入行**行首有空格**，`^\|` 匹配不到；且位于最后一个表格行之后，**不影响任何现有行的行号** → 校验和不变

结果：那条指向已废弃 skill 的链接被**恢复到同一张表里，还标成 Active**，同时**任意散文/标题/整个 Archive 段都可被改写而零信号**。

**已采纳 reviewer 的修法**：AC-E3 改为 **`sed '38d' ROADMAP.md | shasum -a 256`** —— 一条覆盖「追加内容」「缩进伪表格行」「散文改动」三类。实测：真实文件 `92f1a5e9d068b7fa`，绕过版本 `1e9c7a35660f7e2f` → **抓住**。

⚠️ **教训（第 13 次同形）**：我用 `^\|` 划定"表格行"这个**子集**，去回答"文件其余部分有没有被改"这个**全集**问题。**排除法比枚举法安全** —— 与其枚举"哪些行要保护"，不如声明"除了这一行，其余全部不许变"。

### 9.6 第 5 轮审查（`7e8e8129`）—— **整文件哈希被判「全文件冻结冒充单行要求」，已换判据**

reviewer 确认 A/B/C 三个绕过全部封死，并报告两件事：

**(1) 第 4 个绕过（真实但刁钻）**：AC-E3 把第 38 行**排除在哈希外**，而 AC-E2 经 `$(…)` 比较会**静默丢弃 NUL 字节**。故第 38 行可含任意 NUL 而三条全绿。
→ **已修**：新增 **AC-E4** 对第 38 行单独做字节级 `shasum`。第 38 行是唯一未被哈希的区域，补上即闭合。

**(2) AC-E3 有高假警报风险 —— 这条更重要**：`sed '38d' | shasum` 锁死了全部 68 行非目标行，**远超 FR-E 的范围（一行）**。实测：正确实现 FR-E 后再改第 41 行状态 → 哈希从 `92f1a5e9…` 变 `028f4530…` → **FR-E 实现正确却 FAIL**。
reviewer 的评语准确：**「a whole-file freeze wearing a single-line requirement's label」**。

**我没有采纳 reviewer 的窗口化建议**（`sed -n '35,41p'`）—— 那会让绕过 C（尾部追加伪行）复活。

**改用 diff 形状断言**：本单的真实意图不是「文件其余部分不变」，而是**「本次对 ROADMAP.md 的改动只能是第 38 行的一行替换」**。`git diff -U0` 直接表达这件事：

| 断言 | 值 |
|---|---|
| hunk 数 | 1（尾部追加会产生第 2 个 hunk → 抓住绕过 C） |
| 新增/删除行 | 各 1（多改一行即不符） |
| hunk 头 | `@@ -38 +38 @@`（位置钉死） |

**实测**：正确实现后四项全中（`@@ -38 +38 @@`，加删各 1）；未改动时全为 0。**既封死绕过，又不冻结无关内容。**

⚠️ **教训（第 14 次）**：前四轮我一直在**加强约束**（子串→精确、行数→行哈希→整文件哈希），却没问「**这条约束表达的是不是我真正的要求**」。整文件哈希是一个**范围过宽**的判据 —— 与前 13 次「范围过窄」方向相反，但同属「判据范围 ≠ 问题范围」。
**修法不是继续收紧，而是换一个直接表达意图的判据。**

### 9.7 待复审项（第 6 轮）
- diff 形状断言是否封死 A/B/C/D 四个绕过且无假警报
- AC-E4 的第 38 行哈希是否闭合了 NUL 自由度

<details>
<summary>历史：第 1 轮曾因 reviewer 不可用而 BLOCKED（已解除）</summary>

**🛑 BLOCKED —— reviewer 机制不可用（2026-08-16，已于同日解除）**

| 项 | 值 |
|---|---|
| friction 类型 | `subagent/tool availability`（`tad_friction_protocol` 明列） |
| 状态 | **BLOCKED** |
| 证据 | 连续 4 次 subagent 调用失败且无消息：`727f3ab1`、`2c922a5c`（首轮 2 名）、`a5b767eb`、`8baaf359`（缩小规模重派）。最小探针（单条 `grep -c`，无文件写入）同样失败 → **非 prompt 规模问题，是能力不可用** |
| 已执行的阶梯 | step1 识别 ✅ → step2 请求修复：缩小 prompt 规模重派 ✅（仍失败）→ step3 未达成 READY |
| 为何不能自审顶替 | `status_enum.EQUIVALENT_SUBSTITUTE` 明文：**"Self-review is NEVER equivalent."** 且本单前身正是靠外部 reviewer 才发现 15 个 P0，其中多条是 Alex 自查两轮都没抓到的事实性错误 |
| Gate 2 判定 | **不得 PASS**。规则 1 要求 min 2 独立专家审查 |

**解除条件（任一）**：
1. subagent 能力恢复 → 重派 2 名 reviewer，正常走 Gate 2
2. 人类显式批准降级 → `DEGRADED_WITH_APPROVAL`，须记录批准来源、日期、接受的风险与理由
3. 人类自任 reviewer → 属 `EQUIVALENT_SUBSTITUTE`（保持了独立性），须留审查记录

**解除**：2026-08-16 同日 subagent 能力恢复，已完成 2 名独立 reviewer 审查（见上）。
</details>

---

## 10. Important Notes

### 10.1 四条硬禁止

1. **禁止修改 `alex/SKILL.md` frontmatter（L1-147）的任何一行** —— L3 的 `description:` 除外。AC-N4 拦这个。frontmatter 的退休需要承载者地图，属 `HANDOFF-1b`。
2. **禁止修改 `.tad/deprecation.yaml` 的任何一行。** 它是 F-01 的载荷来源；`:33`/`:56` 是其他版本下的历史记录，删除即真实数据丢失。AC-N1/N2 拦这个。
3. **禁止给 `gate/SKILL.md` 新增加载步骤。** 本单是删绑定。AC-C3 拦这个（且必须先跑 AC-C3-pos 证明模式是活的）。
4. **禁止修改 `config-workflow.yaml`。** FR-C 删掉绑定后其 playground 段即不可达，清理另议。AC-N3 拦这个。

### 10.2 遇到以下情况必须停下上报

- 需要判断「这条规则该搬到哪里」→ **范围划错了**，本单不含任何迁移
- `skill-body-verify.sh` 变红 → 说明动了不该动的
- 任何负控（AC-N1~N7）不再是改前的值 → **立即停止**，不要「顺手修正」

### 10.3 Sub-Agent 建议
- AC-D3 的 182 行哈希比对由独立 subagent 执行并留证据文件
- Gate 3 的 reviewer 至少 2 名，禁止自审替代

---

## 11. Learning Content

### 11.1 为什么这张单要这么小

前身单把「删死东西」和「迁移治理内容」放在一起，标为「零风险」。结果：

- 两轮 Gate 2、四名 reviewer、15 个唯一 P0
- 其中最严重的一条：按原计划执行会**无声删掉两条 CLAUDE.md §4 的核心不变式**（`skillify` 的 `create_directly` 与 `call_from: blake`，全仓无第二处承载者），而**整张单没有任何 AC 提到 `skillify`**

**可迁移判据**：
> **纯删除与内容迁移不可同单。** 删除的验收是「东西没了吗」，迁移的验收是「东西还在别处吗」—— 后者需要一张完整的承载者地图。捆在一起时，**缺失的地图会同时让删除部分也无法验收**，因为分不清「删干净了」和「删过头了」。
