---
task_type: doc-only
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: yes
gate4_delta: []
---

# Handoff: 修 ROADMAP.md 的悬空 playground 链接

**From:** Alex ｜ **To:** Blake ｜ **Date:** 2026-08-16
**Task ID:** TASK-20260816-007
**Epic:** `EPIC-20260816-framework-health-repair.md` (Phase 1a-2/5)
**依据:** 审计 F-16 的附带发现（第 1 轮 reviewer `2f7af0e7` 报告）
**前置:** `HANDOFF-20260816-phase1a-pure-deletion.md`（本单在其之后执行 —— 链接指向的文件由它删除）

---

## 🔴 Gate 2

- [x] 需求明确（单行改动）
- [x] AC 可运行，改前值实测
- [x] 已经历 5 轮外部审查（本单的 AC 是其产物，见 §5）
- [ ] 专家审查 ≥2 —— **待审**（本单为新拆分，需独立确认）

---

## 1. Task Overview

### 1.1 一句话

`ROADMAP.md` 第 38 行有一个指向 `.claude/skills/playground/SKILL.md` 的 markdown 链接。**该文件由 Phase 1a 删除**，链接随即悬空（人点击即 404）。去掉链接包装，保留文字。

### 1.2 改动

```diff
-| Design Playground v2 (standalone command) | Direction | **Deprecated 2026-06-10** | [/playground](./.claude/skills/playground/SKILL.md) |
+| Design Playground v2 (standalone command) | Direction | **Deprecated 2026-06-10** | /playground |
```

**就这一行。** 该行本就标着 `Deprecated 2026-06-10`，语义不变，只是不再链到一个不存在的文件。

### 1.3 为什么单独成单

本项原为 `HANDOFF-1a` 的 FR-E。1a 的其余四个 FR 在**第 1 轮审查一次通过**，而 FR-E 独自消耗了**第 2/3/4/5 共四轮**（3 个绕过 + 1 个假警报 + 1 个 NUL 自由度）。二者零耦合，故摘出，避免拖住已就绪的删除工作。

---

## 2. Requirements

| ID | 需求 |
|---|---|
| **FR-1** | `ROADMAP.md:38` 去掉 `[/playground](./.claude/skills/playground/SKILL.md)` 的链接包装，保留 `/playground` 文字，**该行其余部分逐字节不变** |

**NFR1**：本次对 `ROADMAP.md` 的改动**只能是第 38 行的一行替换**，不得触及任何其他行。
**NFR2**：不得改动任何其他文件。

---

## 3. Implementation Steps

| # | 步骤 |
|---|---|
| 1 | 跑 §5 全部 AC 的改前值并存档 |
| 2 | 改第 38 行（建议 `sed -i '' '38s\|\[/playground\](\./\.claude/skills/playground/SKILL\.md)\|/playground\|' ROADMAP.md`） |
| 3 | **在提交前**跑 AC-3（它读未提交的 `git diff`） |
| 4 | 跑全部 AC 改后值 |

**预计 15 分钟。**

---

## 4. File Structure

**Modify**：`ROADMAP.md`（仅第 38 行）
**Evidence**：`.tad/evidence/acceptance-tests/phase1a2-roadmap-link/` — AC 改前/改后输出

---

## 5. Acceptance Criteria

> 本节的 AC 是 **5 轮外部审查**的产物。每一条都对应一个被实际构造出来的绕过或假警报，
> 轻易简化会让已封死的攻击面复活。演进史见 §6。

### 5.0 方言
`[F]`=`grep -F` ｜ `[sh]`=bash 执行 ｜ `[git]`=git
⚠️ 表格内 `\|` 为 Markdown 排版转义，按方言还原。

### 5.1 AC 表

| AC | 方言 | 命令 | 期望 | 改前实测 |
|---|---|---|---|---|
| **AC-1** | `[F]` | `grep -cF 'skills/playground' ROADMAP.md` | `0` | **1** 🔴 |
| **AC-2** | `[sh]` | **整行精确相等**（非子串）：<br>`EXPECT='\| Design Playground v2 (standalone command) \| Direction \| **Deprecated 2026-06-10** \| /playground \|'`<br>`[ "$(sed -n '38p' ROADMAP.md)" = "$EXPECT" ]` | **true** | **false** 🔴 |
| **AC-3** | `[git]` | **diff 形状断言**（**提交前执行**）：对 `git diff -U0 -- ROADMAP.md` 同时满足<br>① `grep -cE '^@@'` == **1**<br>② `grep -cE '^\+[^+]'` == **1**<br>③ `grep -cE '^-[^-]'` == **1**<br>④ `grep -E '^@@'` 输出 == **`@@ -38 +38 @@`** | 四项全中 | 未改动时全为 `0` 🔴 |
| **AC-4** | `[sh]` | **第 38 行字节级校验**（AC-2 经 `$(…)` 比较会静默丢弃 NUL）：<br>`sed -n '38p' ROADMAP.md \| shasum -a 256 \| cut -c1-16` | 记录实际值并人工复核该行可见内容正确 | — |
| **AC-N1** | `[git]` | **负控 NFR2**：`git diff --name-only \| grep -vcE '^ROADMAP\.md$'` | `0`（无其他文件被改） | — |

### 5.2 这些 AC 封死了什么（勿简化）

| 绕过 | 被谁挡住 |
|---|---|
| 路径写成 `skills//playground`（双斜杠仍可解析）+ 行尾加第 5 列 | **AC-2**（整行精确相等） |
| 删掉另一表格行、文末补垃圾行以保持行数 | **AC-3**（hunk 数 == 1） |
| 文末追加**行首带空格**的伪表格行，把链接恢复成 Active | **AC-3**（会产生第 2 个 hunk） |
| 删掉散文/标题/整个 Archive 段 | **AC-3**（加删行数各 == 1） |
| 第 38 行内插入 NUL 字节 | **AC-4** |

⚠️ **AC-3 曾是 `sed '38d' \| shasum`（整文件哈希），已废弃** —— 它是「全文件冻结冒充单行要求」：
实测正确实现 FR-1 后再改第 41 行状态即 FAIL（`92f1a5e9…` → `028f4530…`），而 FR-1 本身是对的。
diff 形状断言既封死上述全部绕过，又不冻结无关内容。

---

## 6. Important Notes

### 6.1 硬禁止

1. **不得修改 `ROADMAP.md` 的任何其他行。** `:41` 另有一行 `| Iterate on Playground based on user feedback | Idea | Pending | — |` —— 它没有悬空链接，**本单不动**。若判断必须同批改，**停下上报**。
2. **不得在同一次改动中触碰其他文件。** AC-N1 拦这个。
3. **AC-3 必须在提交 `ROADMAP.md` 之前执行**（它读工作区 diff）。若已提交，改用 `git diff -U0 <起始SHA>..HEAD -- ROADMAP.md`。

### 6.2 Learning Content

**判据（可迁移）**：
> 当一张单里某个 FR 的审查轮次显著超过其余全部之和，且它与其余 FR 无耦合 —— **摘出它**。
> **审查轮次是范围划分错误的信号，不只是质量信号。**

**第二条**：
> 为堵绕过而不断加强约束，可能走到「约束范围远超要求范围」。
> 到那一步，正确的动作**不是继续收紧，而是换一个直接表达意图的判据**
> （此处：从「文件其余部分不变」换成「本次改动只能是第 38 行的一行替换」）。
