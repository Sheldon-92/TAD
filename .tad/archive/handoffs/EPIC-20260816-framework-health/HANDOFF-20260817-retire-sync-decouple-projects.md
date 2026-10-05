---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: 退休 `*sync`，解除 TAD 与 14 个项目的关联

**From:** Alex ｜ **To:** Blake ｜ **Date:** 2026-08-17
**Task ID:** TASK-20260817-003
**基线 SHA:** `0566ee4d`

---

## 🔴 Gate 2

- [x] 需求明确（人已裁定范围，见 §1.2）
- [x] 技术方案完整
- [x] AC 可运行，改前值全部实测（§7）
- [ ] 专家审查 ≥2 且 P0 已修 —— **待审**（`max_review_rounds: 2`）

---

## 1. Task Overview

### 1.1 一句话

**TAD 不再持有、不再跟踪、不再同步任何下游项目。** 删注册表、退休 `*sync` / `*sync-add` / `*sync-list` 三个命令。

### 1.2 人的裁定（2026-08-17）

> **「我的 14 个项目，是否升级，有我自己手动决定，跟 TAD 项目无关，TAD 项目不要再关联着 14 个项目。」**

在三个选项（只清空注册表 / 连命令一起退休 / 只改文档口径）中，**人选择「连 `*sync` 命令一起退休」**。

**这改变了 TAD 的定位**：从「一个管理 N 个下游安装的分发中心」变成「一个自己管好自己的框架仓库」。
用户想装到某个项目，自己跑 `tad.sh`。

### 1.3 为什么这件事现在做得动

实测：**`tad.sh`（安装器）不读注册表** —— 唯一提及是 `:245` 的
`TAD_TOP_DENY="sync-registry.yaml"`，即把它列为「永不复制进目标项目」的保护项。

→ **删注册表不影响任何人的安装。** 耦合全在 Alex 的 `*sync` 命令一侧。

### 1.4 ⚠️ 一个会坏的东西（必须同批处理）

`.tad/hooks/lib/harvest-scan.sh` **依赖注册表**：
```
:3   # Derives project list from sync-registry.yaml (never hardcodes paths).
:10  REGISTRY="$ROOT/.tad/sync-registry.yaml"
:13  echo "ERROR: sync-registry.yaml not found at $REGISTRY" >&2
```
注册表一删，它会**报错退出**。§4.3 给了处置方案。

### 1.5 Intent Statement

**要达成的**：TAD 仓库里不再有任何「哪些项目装了我」的记录，也不再有批量推送的能力。

**不追求的**：改 `tad.sh` 的安装逻辑（它本来就与注册表无关）、删除历史记录中的项目名。

---

## 2. Requirements

| ID | 需求 |
|---|---|
| **FR-1** | 删除 `.tad/sync-registry.yaml`（14 条项目记录） |
| **FR-2** | 删除三个协议文件（两侧）：`sync-protocol.md`（245 行）、`sync-add-protocol.md`（41 行）、`sync-list-protocol.md`（15 行） |
| **FR-3** | 从 `alex/SKILL.md` 移除三个协议注册块（`sync_protocol` / `sync_add_protocol` / `sync_list_protocol`），**原位留退休注释** |
| **FR-4** | `alex/SKILL.md:3` 的 `description` 移除 `*sync` |
| **FR-5** | `CLAUDE.md` 移除 `*sync` 的三处提及（§2 表格行 + §2.5 lite 条款中的相关表述） |
| **FR-6** | 处置 `harvest-scan.sh` 对注册表的依赖（§4.3，**方案需人裁定或按 §4.3 默认**） |
| **FR-7** | `release-runbook/references/sync-ops.md`（186 行，两侧）：删除或改为「已退休」桩 —— 见 §4.4 |
| **FR-8** | `.agents` 镜像同步 |

**NFR1**：不得改 `tad.sh` 的任何安装逻辑
**NFR2**：不得改 `derive-sync-set.sh`（它只把注册表名列为 `TOP_DENY`，与项目列表无关）
**NFR3**：不得删除历史记录（`.tad/decisions/`、`CHANGELOG.md`、审计报告）中的项目名 —— **那是决策轨迹**
**NFR4**：`*publish` 命令**保留** —— 它是发布到 GitHub，与下游项目无关

---

## 3. ⚠️ 这张单会缩小 TAD 的能力，先确认这是想要的

删除后**不再可能**：
- 一条命令把新版推给多个项目
- 查询「哪些项目装了 TAD、装的哪个版本」
- `*sync-add` 注册新项目

**保留**：`tad.sh` 的单项目安装/升级、`*publish` 的 GitHub 发布。

人已在 §1.2 明确裁定接受。**Blake 无需再确认，但若实现中发现第四类能力也被连带删除，须停下上报。**

---

## 4. Technical Design

### 4.1 删除顺序

```
FR-2/FR-7 删协议文件 → FR-3/FR-4/FR-5 摘引用 → FR-6 修 harvest → FR-1 删注册表 → FR-8 镜像
```
**注册表最后删** —— 这样 `harvest-scan.sh` 的处置（FR-6）可以在真实数据下验证。

### 4.2 FR-3 的原位注释（照 Phase 1a 的 `tad-gate` 先例）

```yaml
# *sync / *sync-add / *sync-list 已于 2026-08-17 退休（人裁定）。
#   理由：TAD 不再持有下游项目清单——是否升级由各项目自行决定。
#   安装/升级请在目标项目内直接运行 tad.sh。
#   历史协议见 git history: git show 0566ee4d:.claude/skills/alex/references/sync-protocol.md
```

### 4.3 FR-6：`harvest-scan.sh` 的处置

它从注册表推导项目列表，用于跨项目扫描 harvest 候选。注册表没了它会 `exit 1`。

| 方案 | 做法 | 代价 |
|---|---|---|
| **A（默认）** | 改为：注册表不存在时**优雅跳过**（打印一行说明，exit 0），而非报错 | harvest 的跨项目扫描能力静默失效 |
| **B** | 一并退休 `harvest-scan.sh` | 若 `*harvest` 还在用它，会连带坏掉 |

⚠️ **Blake 须先查 `*harvest` 是否依赖它**：`grep -rn 'harvest-scan' .claude/skills/`。
- 若无人调用 → 采 **B**
- 若有调用 → 采 **A**，并在 completion 记录「跨项目 harvest 已失效」

### 4.4 FR-7：`release-runbook/references/sync-ops.md`

186 行，属 `release-runbook` skill。**Blake 须先确认它是否被 `*publish` 引用**：
- 仅被 `*sync` 引用 → 删除
- 也被 `*publish` 引用 → **只删其中依赖注册表的部分**，保留其余（NFR4 要求 `*publish` 存活）

---

## 5. 强制问题回答

### MQ1 历史搜索
**是**。`*sync` 与注册表引入于 `.tad/config.yaml:341-342` 记录的版本；审计 S-01/F-32 曾建议「恢复交付」，**该建议随本单作废**。

### MQ2 位置存在性

| 位置 | 内容 | ✅ |
|---|---|---|
| `.tad/sync-registry.yaml` | 14 条 `^  - path:` | ✅ 实测 14 |
| `alex/SKILL.md:1537-1547` | 三个协议注册块 | ✅ |
| `alex/SKILL.md:3` | description 含 `*sync` | ✅ |
| `tad.sh:245` | `TAD_TOP_DENY="sync-registry.yaml"` —— **仅此一处，不读内容** | ✅ |
| `harvest-scan.sh:10,13` | 读注册表，缺失即 `exit 1` | ✅ |
| `derive-sync-set.sh:77` | `TOP_DENY="sync-registry.yaml"` —— 只用文件名 | ✅ |

### MQ3 数据流
**改前**：`*sync` → 读注册表 14 条路径 → 逐个 `cp` 框架文件进目标项目
**改后**：**该数据流整条消失**。用户在目标项目内运行 `tad.sh`，TAD 仓库不知道目标存在。

### MQ4 视觉层级
N/A。

### MQ5 状态同步
`.claude` / `.agents` 两侧的 4 个文件（3 个 sync 协议 + sync-ops）与 `alex/SKILL.md` 须同步删改。
不同步 → `skill-body-verify.sh` FAIL。

### MQ6 知识评估
预期产出：**「框架不该持有它被安装在哪里的清单」** —— 那使框架对下游产生了它无权承担的责任，
也让「批量推送」这个高风险能力常驻。分发的正确形态是**目标项目主动拉取**。

---

## 6. Implementation Steps

| # | 步骤 | FR |
|---|---|---|
| 1 | 跑 §7 全部 AC 改前值，存档 | — |
| 2 | 查 `harvest-scan` 与 `sync-ops` 的调用方，定 §4.3/§4.4 方案 | FR-6, FR-7 |
| 3 | 删三个 sync 协议文件（两侧） | FR-2 |
| 4 | 摘 SKILL.md 注册块 + description + CLAUDE.md | FR-3,4,5 |
| 5 | 按步骤 2 的结论处置 harvest-scan 与 sync-ops | FR-6, FR-7 |
| 6 | **最后**删注册表 | FR-1 |
| 7 | 同步 `.agents`，跑全部 AC | FR-8 |

**预计 2 小时。**

---

## 7. Acceptance Criteria

### 7.0 方言
`[F]`=`grep -F` ｜ `[BRE]`=`grep` ｜ `[ERE]`=`grep -E` ｜ `[sh]`=bash ｜ `[git]`=git

| AC | 命令 | 期望 | 改前实测 |
|---|---|---|---|
| **AC-1** | `[F]` `ls .tad/sync-registry.yaml 2>/dev/null \| wc -l` | `0` | **1** 🔴 |
| **AC-2** | `[BRE]` 三个协议文件均不存在（两侧共 6 个）：`ls .claude/skills/alex/references/sync*.md .agents/skills/alex/references/sync*.md 2>/dev/null \| wc -l` | `0` | **6** 🔴 |
| **AC-3** | `[ERE]` `grep -cE '^(sync_protocol\|sync_add_protocol\|sync_list_protocol):' .claude/skills/alex/SKILL.md` | `0` | **3** 🔴 |
| **AC-3b** | `[F]` **原位留注释**：`grep -cF '*sync / *sync-add / *sync-list 已于 2026-08-17 退休' .claude/skills/alex/SKILL.md` | `≥1` | **0** 🔴 |
| **AC-4** | `[F]` `sed -n '3p' .claude/skills/alex/SKILL.md \| grep -cF '*sync'` | `0` | **1** 🔴 |
| **AC-5** | `[F]` `grep -cF '*sync' CLAUDE.md` | `0` | **3** 🔴 |
| **AC-6** | `[sh]` **`harvest-scan.sh` 在注册表缺失时不报错**：`bash .tad/hooks/lib/harvest-scan.sh >/dev/null 2>&1; echo $?` | `0`（若采 §4.3 方案 B 则文件不存在，本 AC 改为 `ls` = 0） | 需 Blake 先定方案 |
| **AC-7** | `[F]` 全仓活代码不再读注册表内容：`git ls-files -z \| xargs -0 grep -ln 'sync-registry' \| grep -vcE '\.tad/(evidence\|archive\|decisions)/\|CHANGELOG\|AUDIT\|HANDOFF\|\.gitignore\|derive-sync-set\|tad\.sh'` | `0` | **需 Blake 取基线** |
| **AC-N1** | `[F]` **负控 NFR1**：`git diff --name-only 0566ee4d..HEAD \| grep -cE '^tad\.sh$'` | `0` | — |
| **AC-N2** | `[F]` **负控 NFR4 —— `*publish` 存活**：`grep -cF '*publish' .claude/skills/alex/SKILL.md` | **仍 `≥1`** | **8** ✅ |
| **AC-N2b** | `[sh]` **`*publish` 的协议文件仍在**：`ls .claude/skills/alex/references/publish-protocol.md \| wc -l` | **`1`** | **1** ✅ |
| **AC-N3** | `[F]` **负控 NFR3 —— 历史记录未被删**：`ls .tad/decisions/DR-20260601-self-deriving-release-sync.md \| wc -l` | **`1`** | **1** ✅ |
| **AC-N4** | `[BRE]` **负控 NFR2**：`grep -c 'TOP_DENY="sync-registry.yaml"' .tad/hooks/lib/derive-sync-set.sh` | **仍 `1`** | **1** ✅ |
| **AC-N5** | `[sh]` **负控 —— 镜像一致**：`bash .tad/hooks/lib/skill-body-verify.sh; echo $?` | `0` | **0** ✅ |
| **AC-N6** | `[sh]` **负控 —— 安装器仍可用**：`bash -n tad.sh; echo $?` | `0` | **0** ✅ |

⚠️ **AC-6 与 AC-7 需 Blake 在步骤 2 定案后补齐基线** —— 出单时无法预判 §4.3/§4.4 的选择。
**不得因基线为空而跳过。**

### 7.2 Expert Review Status
**待审。⚠️ `max_review_rounds: 2`。**

---

## 8. Important Notes

### 8.1 五条硬禁止

1. **禁止改 `tad.sh` 的安装逻辑。** 它与注册表无关。AC-N1 拦这个。
2. **禁止删 `*publish`。** 它发布到 GitHub，与下游项目无关。AC-N2/N2b 拦这个。
3. **禁止删历史记录中的项目名**（`.tad/decisions/`、`CHANGELOG.md`、审计报告）—— 那是决策轨迹。AC-N3 拦这个。
4. **禁止在未确认调用方的情况下删 `harvest-scan.sh` 或 `sync-ops.md`。** 先查 §4.3/§4.4。
5. **禁止把注册表放到最先删。** 顺序见 §4.1 —— 否则 `harvest-scan.sh` 的处置无法在真实数据下验证。

### 8.2 遇到以下必须停下上报
- 发现第四类能力被连带删除（§3 只列了三类）
- `*publish` 因删 `sync-ops.md` 而失效
- `harvest-scan.sh` 的调用方比预期多

### 8.3 Sub-Agent 建议
- 删除前调独立 subagent 做一次全仓引用扫描，确认没有遗漏的消费者

---

## 9. Learning Content

### 9.1 框架不该持有它被安装在哪里的清单

TAD 维护了一份 14 个项目的注册表，并据此提供「一键推送到所有项目」的能力。

**问题不在实现，在定位**：
- 它让 TAD 对下游产生了**它无权承担的责任** —— 本 Epic 里多次出现「不能 publish，会把缺陷推给 14 个项目」的约束
- 那 14 条记录**从未被验证过准确性** —— 审计实测发现 2 个路径已不存在、1 个版本记录错误
- 「批量推送」是个高风险能力，却因为注册表存在而常驻

**可迁移判据**：
> 分发的正确形态是**目标主动拉取**，不是**源主动推送**。
> 源持有目标清单时，它就必须为目标的状态负责 —— 而它既无法验证那份清单，也无权决定目标何时升级。
