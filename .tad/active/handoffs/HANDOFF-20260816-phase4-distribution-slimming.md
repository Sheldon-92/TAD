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
**Task ID:** TASK-20260816-005
**Epic:** `EPIC-20260816-framework-health-repair.md` (Phase 4/5)
**依据:** 审计 F-18、F-20
**前置:** Phase 1a 完成（其 FR-D 先减 18.6 MB）

---

## 🔴 Gate 2

- [x] 需求明确
- [x] 技术方案完整
- [x] AC 可运行，改前值全部实测（§9）
- [x] MQ1-MQ6 已回答（§5）
- [ ] 专家审查 ≥2 且 P0 已修 —— **待审**

---

## 1. Task Overview

### 1.1 What We're Building

把 `.tad/evidence/` 与 `.tad/archive/` 移出 `main` 工作树，并修正 npm 打包面。

**实测收益**：

| 状态 | tarball |
|---|---|
| 现状 | **30.19 MB** |
| 删 evidence | 12.10 MB |
| **删 evidence + archive** | **7.92 MB** ← 目标（SC3 要求 < 8 MB） |

### 1.2 为什么这件事成本极低

**关键机制**：`tad.sh:28` 的 `DOWNLOAD_URL` 指向 `archive/refs/heads/main.tar.gz` —— GitHub 的**树快照，不含 git 历史**。

因此**从 main 删除即刻生效，无需重写任何历史**。这是本单成本极低的根本原因。

**三个已验证的前提**：

1. **`evidence` 已在 `TAD_ZERO_TOUCH`**（`tad.sh:226`），从不复制进用户项目 —— 删它不影响安装
2. **运行时无任何东西读取已提交的 evidence** —— 全部 `evidence/` 引用是写入目标、对用户运行时产物的计数、或 `release-verify.sh:807` 的显式 `continue` 跳过
3. **反证**：`blake/SKILL.md:2114`、`dependency-ops/SKILL.md:70` 已在引用 evidence 路径，而因 zero-touch，**这些引用在每个已安装项目中今天就是断的，什么也没坏**

### 1.3 明确不做

| 不做 | 为什么 |
|---|---|
| **`git filter-repo` 历史重写** | 收益只及 `git clone`，而文档主推的是 `curl`。代价是废掉所有已有 clone 与 fork。**不值** |
| **删 `.tad/active/`** | 里面有研究资料（wireframe、PDF 等）。且删 evidence+archive 已达 7.92 MB < 8 MB 目标 |
| **改 `tad.sh`** | deny-list 是**推导**的，目录消失是 no-op，无需改安装器 |

### 1.4 Intent Statement

**要达成的**：让别人装 TAD 时不再下载维护者的调试记录。

**不追求的**：缩小 `.git`。git 早已按内容去重（`release-runbook` 目录 396 个 blob 引用 → 103 个唯一 blob），删工作树对 `.git` 无影响。

---

## 📚 Project Knowledge（Blake 必读）

| Pattern | 相关点 |
|---|---|
| `release-sync.md` | **本单核心** —— 镜像/发行面的既有教训 |
| `ac-verification.md` | 负控设计 |

**必须应用的一条**：
> **判断 git 内容只能用 `git show` / `git ls-tree`**，`wc -c` / `du` 会跟随符号链接或按块舍入。本单 AC 涉及体积统计，**必须用 `git archive` 实测**，不得用 `du`。

### Blake 确认
- [ ] 我已读 `release-sync.md`

---

## 2. Background Context

### 2.1 Previous Work
Phase 1a 的 FR-D 已删 `stable5-pre`（182 文件，约 18.6 MB 工作树）。本单在此基础上做整体移出。

### 2.2 Current State
```
$ git archive --format=tar HEAD | gzip -9 | wc -c   → 31659251  (30.19 MB)
$ git ls-files '.tad/evidence/*' | wc -l            → 3522
$ git ls-files '.tad/archive/*'  | wc -l            → 895
$ ls .npmignore                                     → 不存在
$ grep -cF '".tad/"' package.json                   → 1
```

### 2.3 Dependencies
Phase 1a（顺序依赖）

---

## 3. Requirements

### 3.1 Functional Requirements

| ID | 需求 |
|---|---|
| **FR-A** | 创建 orphan 分支 `maintainer-evidence`，完整保留当前 `.tad/evidence/` 与 `.tad/archive/`，**推送到 origin** |
| **FR-B** | 从 main 索引移除二者：`git rm -r --cached`，并加入 `.gitignore` |
| **FR-C** | 创建 `.npmignore` 排除 `.tad/evidence/`、`.tad/archive/`，**或**收窄 `package.json` 的 `files`（二选一，见 §4.2） |
| **FR-D** | 在 `.tad/evidence/README.md`（新建或追加）写明内容已移至 orphan 分支及取回方式 |

### 3.2 Non-Functional Requirements
- **NFR1**：不得重写 git 历史（不用 `filter-repo` / `rebase` / `--amend` 触碰旧 commit）
- **NFR2**：不得改 `tad.sh`
- **NFR3**：`.tad/active/`、`.tad/project-knowledge/` 等其余 zero-touch 目录**不动**
- **NFR4**：orphan 分支必须**先推送成功**，才能从 main 删除（顺序不可颠倒）

---

## 4. Technical Design

### 4.1 顺序（NFR4，不可颠倒）

```
FR-A 建 orphan 分支并推送  →  验证可从远端取回  →  FR-B 从 main 删除
```

**理由**：若先删后建，中途失败会导致内容只存在于本地 reflog。

### 4.2 FR-C 二选一 —— 需人裁定

| 方案 | 做法 | 代价 |
|---|---|---|
| **A** | 新建 `.npmignore` 列排除项 | 多一个文件；npm 优先用它而非 `.gitignore` |
| **B** | 改 `package.json` 的 `files`，把裸 `".tad/"` 换成显式子目录白名单 | 需列出全部要发布的 `.tad` 子目录，将来新增目录易漏 |

⚠️ **Blake 不得自选**，实现前须人裁定。

**注**：审计 F-20 标为 `[推断]` —— `npm pack --dry-run` 因本机 npm 缓存 root 权限报 EPERM 未能实测。**AC-C2 必须补上这一步实测**，不得沿用推断。

### 4.3 brain-index 的影响

`.tad/brain-index.md` 的 Evidence 表会因目录消失而变空。**实测当前该表已为 0 行**（`grep -c '^| evidence/'` → 0），故无实际变化。**不需要改动它**，但 completion 应记录此项已核对。

---

## 5. 强制问题回答

### MQ1 历史搜索
**是**。F-18/F-20 来自 2026-08-16 发行重量审计。审计已更正一处：**「18.62 MB 纯重复」只对工作树/tarball 成立，对 `.git` 不成立**（git 早已去重）。本单收益均以 tarball 计。

### MQ2 位置存在性

| 位置 | 内容 | ✅ |
|---|---|---|
| `tad.sh:28` | `DOWNLOAD_URL=".../main.tar.gz"`（树快照，无历史） | ✅ |
| `tad.sh:226` | `evidence` 在 `TAD_ZERO_TOUCH` | ✅ |
| `release-verify.sh:807` | `evidence/*` 显式 `continue` 跳过 | ✅ |
| `package.json` `files` | 含裸 `".tad/"` | ✅ |
| `.tad/brain-index.md` | Evidence 表当前 0 行 | ✅ |

### MQ3 数据流
N/A。**等价检查**：移出后「安装仍成功」由 AC-N1 断言；「内容可取回」由 AC-A2 断言。

### MQ4 视觉层级
N/A。

### MQ5 状态同步

| 数据 | main | orphan 分支 |
|---|---|---|
| `.tad/evidence/` | 移除 | **完整保留** |
| `.tad/archive/` | 移除 | **完整保留** |

**不同步的后果**：若 orphan 推送失败而 main 已删 → 内容仅存本地。**NFR4 与 AC-A2 防这个。**

### MQ6 知识评估
预期产出：**「发行体积的杠杆点取决于分发机制」** —— 本仓主推 `curl | tar` 拉树快照，故删工作树即刻生效、无需重写历史；若主推 `git clone` 则结论相反。

---

## 6. Implementation Steps

| # | 步骤 | FR |
|---|---|---|
| 1 | 跑 §9 全部 AC 改前值，存档 | — |
| 2 | 建 orphan 分支 `maintainer-evidence`，提交完整 evidence+archive，**推送 origin** | FR-A |
| 3 | **验证**：从远端 `git show maintainer-evidence:<某文件>` 可读 | FR-A |
| 4 | main 上 `git rm -r --cached` 二者 + 更新 `.gitignore` | FR-B |
| 5 | 按人裁定结果实施 FR-C | FR-C |
| 6 | 写 `.tad/evidence/README.md` 说明取回方式 | FR-D |
| 7 | 跑全部 AC 改后值 + 沙箱安装负控 | — |

**预计 2 小时。**

---

## 7. File Structure

**Create**：`.npmignore`（若选方案 A）、`.tad/evidence/README.md`
**Modify**：`.gitignore`、`package.json`（若选方案 B）
**Remove from index**：`.tad/evidence/**`（3522 文件）、`.tad/archive/**`（895 文件）
**New branch**：`maintainer-evidence`（orphan）

### 7.4 Required Evidence Manifest
- `.tad/evidence/reviews/blake/phase4-distribution-slimming/` — ≥2 份独立 reviewer 文件
  ⚠️ **注意**：本单会把 `.tad/evidence/` 移出 main。reviewer 证据文件应在**移出前**产出并单独保留副本，或改存于 `.tad/active/`，**由 Blake 在实现前与 Alex 确认存放位置**
- 沙箱安装测试输出

---

## 8. Testing Requirements

### 8.1 沙箱安装负控（AC-N1）

在 `mktemp -d` 中用**当前工作树作为源**模拟安装（不走网络），断言 `verify_install_complete` 通过 —— 证明移除 evidence/archive 未破坏安装。

⚠️ 若因 F-33（安装器无本地源模式）无法执行，**记为 BLOCKED 并上报**，不得跳过、不得以「理论上不影响」替代。

### 8.4 Friction Preflight
- `git archive` 可用 ✅
- **`npm pack --dry-run` 当前报 EPERM**（本机 npm 缓存 root 权限）→ AC-C2 需先修复该环境问题，或用 `npm pack --dry-run --cache <临时目录>` 绕过

---

## 9. Acceptance Criteria

### 9.0 方言标注
`[F]`=`grep -F` ｜ `[BRE]`=`grep` ｜ `[ERE]`=`grep -E` ｜ `[git]`=git ｜ `[sh]`=执行
⚠️ 表格内 `\|` / `｜` 为 Markdown 排版转义，**按标注还原**。

### 9.1 AC 表

| AC | 方言 | 命令 | 期望 | 改前实测 |
|---|---|---|---|---|
| **AC-A1** | `[git]` | `git rev-parse --verify maintainer-evidence >/dev/null 2>&1; echo $?` | `0` | 分支不存在 🔴 |
| **AC-A2** | `[git]` | **可取回性**：`git show maintainer-evidence:.tad/evidence/acceptance-tests/release-runbook-capability-migration/stable5-post/targets/01/name.txt \| head -1` | 非空 | 分支不存在 🔴 |
| **AC-A3** | `[git]` | **已推送**：`git rev-parse maintainer-evidence` == `git rev-parse origin/maintainer-evidence` | 相等 | 不存在 🔴 |
| **AC-B1** | `[git]` | `git ls-files '.tad/evidence/*' \| wc -l` | `0` | **3522** 🔴 |
| **AC-B2** | `[git]` | `git ls-files '.tad/archive/*' \| wc -l` | `0` | **895** 🔴 |
| **AC-B3** | `[git]` | **主目标**：`git archive --format=tar HEAD \| gzip -9 \| wc -c` | **< 8,388,608** | **31,659,251** 🔴 |
| **AC-C1** | `[F]` | 方案 A：`ls .npmignore \| wc -l` = 1；方案 B：`grep -cF '".tad/"' package.json` = 0 | 按裁定 | A:0 / B:1 🔴 |
| **AC-C2** | `[sh]` | **实测（不得沿用推断）**：`npm pack --dry-run` 输出中 `.tad/evidence/` 条目数 | `0` | **未实测**（EPERM）🔴 |
| **AC-D1** | `[F]` | `ls .tad/evidence/README.md \| wc -l` 且含 `maintainer-evidence` 字样 | `1` | 需核对 |
| **AC-N1** | `[sh]` | **负控**：沙箱安装后 `verify_install_complete` 通过 | 通过 | — |
| **AC-N2** | `[git]` | **负控 NFR1（未重写历史）**：`git rev-parse 4718c5ec` 仍解析成功，且 `git log --oneline \| tail -1` 的首个 commit 哈希不变 | 不变 | — |
| **AC-N3** | `[git]` | **负控 NFR2**：`git diff --name-only <起始SHA>..HEAD \| grep -cE '^tad\.sh$'` | `0` | — |
| **AC-N4** | `[git]` | **负控 NFR3 —— 路径集合哈希**（**不是**计数：计数抓不住「删了 A 又加了 B」）：<br>`git ls-files '.tad/project-knowledge/*' \| shasum -a 256 \| cut -c1-16` | **仍为 `843aa189cb906ba1`** | **843aa189cb906ba1** ✅ |
| **AC-N5** | `[git]` | **负控 NFR3 —— 同上**（研究资料须存活）：<br>`git ls-files '.tad/active/*' \| shasum -a 256 \| cut -c1-16` | **仍为 `64db5ae93701edfa`** | **64db5ae93701edfa** ✅ |

> ⚠️ **为何用路径集合哈希而非文件计数**：计数只能抓「净删除」，抓不住「删一个再加一个」。
> 本单的风险正是「为了达标把不该删的目录也删了」，而实现者可能同时新建文件（如 evidence README）掩盖净额。
> 哈希锁的是**具体哪些路径**，不是有几个。
> 同一课的另一处应用见 1a 的 AC-E3（整文件哈希 vs 只管 `^\|` 的行）。
>
> ⚠️ **基线时效**：两个哈希取自本单起草时。若 Phase 1a/1b/3 在本单之前落地并改动了这两个目录的**文件集合**（新增/删除，非内容修改），Blake 须**重新取基线并在 completion 记录**，不得直接判 FAIL。
| **AC-N6** | `[sh]` | **负控**：`bash .tad/hooks/lib/release-verify.sh` 全项通过 | 通过 | — |

⚠️ **AC-B3 是本单唯一的主目标**，其余均为「达成方式正确」与「没伤到别的」。

### 9.2 Expert Review Status
**待审。**

---

## 10. Important Notes

### 10.1 五条硬禁止

1. **禁止重写 git 历史。** 不用 `filter-repo` / `rebase` / `--amend` 触碰旧 commit。AC-N2 拦这个。
2. **禁止在 orphan 分支推送成功前从 main 删除。** 顺序见 §4.1。AC-A3 拦这个。
3. **禁止删 `.tad/active/` 或 `.tad/project-knowledge/`。** 前者有研究资料，且删 evidence+archive 已达标（7.92 MB）。AC-N4/N5 拦这个。
4. **禁止改 `tad.sh`。** deny-list 是推导的，目录消失是 no-op。AC-N3 拦这个。
5. **禁止以「理论上不影响安装」替代沙箱验证。** 若 AC-N1 无法执行，记 BLOCKED 上报。

### 10.2 遇到以下必须停下上报
- orphan 分支推送失败
- AC-N1 因 F-33 无法执行
- 移除后 `release-verify.sh` 变红

### 10.3 Sub-Agent 建议
- AC-N1 的沙箱安装由独立 subagent 执行并留完整输出
- 移除操作前调 `code-reviewer` 确认 `.gitignore` 规则不会误伤

---

## 11. Learning Content

### 11.1 发行体积的杠杆点取决于分发机制

**朴素做法**：仓库大 → 重写历史瘦身。

**为什么不对**：本仓主推 `curl … main.tar.gz | tar -xz`，拉的是**树快照，不含历史**。所以：
- **删工作树 = 立刻生效**，30.19 MB → 7.92 MB，零历史风险
- **重写历史 = 只帮到 `git clone` 用户**，代价是废掉所有已有 clone 与 fork

**可迁移判据**：
> 优化发行体积前，先确认**用户实际怎么拿到它**。tarball 分发看工作树，clone 分发才看 `.git`。**搞错了会做一件代价极高、收益为零的事。**
