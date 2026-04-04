---
task_type: mixed
e2e_required: no
research_required: no
---

# Handoff: Documentation Overhaul — v2.5 → v2.8 Full Sync

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-04-04
**Project:** TAD Framework
**Task ID:** TASK-20260404-018
**Handoff Version:** 3.1.0

---

## 🔴 Gate 2: Design Completeness

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | File-by-file audit report with exact issues |
| Components Specified | ✅ | Before/after for each file clearly defined |
| Functions Verified | ✅ | N/A (documentation only) |
| Data Flow Mapped | ✅ | N/A |

**Gate 2 结果**: ✅ PASS

---

## 1. Task Overview

### 1.1 What We're Building
Full documentation sync from v2.5 (where docs stopped being updated) through v2.8 (current). README.md needs major rewrite, CHANGELOG.md needs count fixes, MULTI-PLATFORM.md needs update or deprecation, NEXT.md needs cleanup.

### 1.2 Why We're Building It
README.md is the project's primary entry point on GitHub. It currently claims v2.5.0 when the project is at v2.8.0 — 3 versions behind. Missing Domain Packs, Hooks, Traces, Self-Evolution, and all v2.6-2.8 features. This makes the project look abandoned or unmaintained.

### 1.3 Intent Statement

**真正要解决的问题**：让所有面向外部的文档准确反映 TAD v2.8.0 的真实能力。

**不是要做的**：
- ❌ 不是改框架代码或协议（只改文档）
- ❌ 不是翻译（保持文档原有语言，README 英文，INSTALLATION_GUIDE 中文）
- ❌ 不是重新设计文档结构（保持现有结构，更新内容）

---

## 📚 Project Knowledge（Blake 必读）

✅ 已检查所有 knowledge 文件，无与本任务直接相关的历史教训。这是纯文档更新任务。

---

## 2. Background — Audit Findings

Alex 已完成全面审计，以下是每个文件的具体问题：

### 2.1 README.md — 🔴 CRITICAL (需要大量更新)

**当前版本号**: v2.5.0（实际 v2.8.0）

**缺失的功能文档（v2.6-2.8）**:

| Version | Feature | Status in README |
|---------|---------|-----------------|
| v2.6 | 4D Protocol Pair Testing | ❌ 完全缺失 |
| v2.6 | Autoresearch Optimization Mode (Layer 0.5) | ❌ 完全缺失 |
| v2.6 | Linear Kanban Integration + Auto-Sync | ❌ 完全缺失 |
| v2.7 | Hook-Native Architecture (SessionStart, PostToolUse, PreToolUse) | ❌ 完全缺失 |
| v2.7 | Skill file 76% reduction (judgment-only residual) | ❌ 完全缺失 |
| v2.8 | Domain Packs (20 packs, 78 tools) | ❌ 完全缺失 |
| v2.8 | Execution Traces + *optimize + *evolve | ❌ 完全缺失 |
| v2.8 | Quality Gate Hooks (pre-accept, pre-gate) | ❌ 完全缺失 |
| v2.8 | Knowledge Assessment Pipeline | ❌ 完全缺失 |
| v2.8 | Domain Pack Workflow Integration | ❌ 完全缺失 |

**其他错误**:
- Skills 数量写 8（实际 9，缺 tdd-enforcement）
- 版本历史表止于 v2.5.0
- 安装结构图过时（缺 domains/, hooks/ 目录）
- 命令列表缺 *optimize, *evolve

### 2.2 CHANGELOG.md — 🟡 数据错误

- Domain Pack 数量: 写 14 → 实际 20
- 工具数量: 写 35+ → 实际 78
- 缺少 HW Domain Pack Phase（4 packs）
- 缺少 Security Domain Pack Phase（2 packs: supply-chain, code-security）
- 缺少 Knowledge Assessment Pipeline Fix
- 缺少 Domain Pack Workflow Integration

### 2.3 docs/MULTI-PLATFORM.md — 🔴 严重过时

- 版本号: v2.3.0（落后 5 个版本）
- 无 Domain Packs、Hooks、Traces 内容
- 工具数写 35+（实际 78）

### 2.4 NEXT.md — 🟡 结构问题

- "## Recently Completed" 节出现 2 次（约 line 15 和 line 62），需要合并
- 已完成项太多，需要归档旧的到 docs/HISTORY.md

### 2.5 INSTALLATION_GUIDE.md — ⚠️ 微调

- 副标题 "Three-Layer Quality Defense" 是 v2.7 术语，v2.8 强调 "Self-Evolving Framework"

---

## 3. Requirements

### 3.1 File-by-File Requirements

**README.md**:
- FR1: 版本号更新到 v2.8.0
- FR2: "What's New" 节扩展覆盖 v2.6, v2.7, v2.8
- FR3: 版本历史表扩展到 v2.8
- FR4: Domain Packs 作为主要功能介绍（20 packs, 5 chains: Web/Mobile/AI/HW/Security）
- FR5: Hook Architecture 介绍
- FR6: Self-Evolution (*optimize, *evolve) 介绍
- FR7: 安装结构图更新（加 domains/, hooks/）
- FR8: Skills 数量 8 → 9
- FR9: 命令列表更新（加 *optimize, *evolve, *status）
- FR10: 保持英文，保持现有 README 风格

**CHANGELOG.md**:
- FR11: Domain Pack 数量 14 → 20
- FR12: 工具数量 35+ → 78
- FR13: 追加 HW Domain Pack 条目（4 packs）
- FR14: 追加 Security Domain Pack 条目（2 packs + tools-registry）
- FR15: 追加 Knowledge Assessment Pipeline Fix 条目
- FR16: 追加 Domain Pack Workflow Integration 条目

**docs/MULTI-PLATFORM.md**:
- FR17: 版本号 v2.3.0 → v2.8.0
- FR18: 更新功能描述（加 Domain Packs, Hooks, Traces）
- FR19: 工具数 35+ → 78

**NEXT.md**:
- FR20: 合并重复的 "Recently Completed" 节
- FR21: 归档 2026-03-25 之前的已完成项到尾部或 docs/HISTORY.md
- FR22: 确保 In Progress 节反映当前状态

**INSTALLATION_GUIDE.md**:
- FR23: 副标题微调为 "Self-Evolving Framework"

### 3.2 Non-Functional Requirements
- NFR1: 不改变文档的整体结构和风格
- NFR2: README 保持英文
- NFR3: 数字必须来自实际文件（wc -l, file count），禁止估算

---

## 4. Technical Design

### 4.1 README.md 更新策略

**保持不动的部分**:
- 项目 logo/header 格式
- "Getting Started" 安装步骤（如果还准确）
- "Contributing" / "License" 节

**需要重写的部分**:
- Version header
- "What's New" → 扩展为 "What's New in v2.8" + "Version History"
- Feature overview 节

**新增的部分**:
- "Domain Packs" 节 — 20 packs across 5 chains
- "Hook Architecture" 节 — 3 hook types
- "Self-Evolution" 节 — traces → optimize → evolve

**获取准确数据的命令**:
```bash
# Domain Pack 数量
ls .tad/domains/*.yaml | grep -v tools-registry | wc -l  # 应该是 20

# 工具数量
wc -l .tad/domains/tools-registry.yaml  # 1911 lines

# Skills 数量
ls .tad/skills/*/SKILL.md | wc -l  # 应该是 9

# 安装目录结构
ls -d .tad/*/  # 获取最新目录结构
```

### 4.2 CHANGELOG.md 更新策略

在现有 v2.8.0 条目中更新数据：
- "14 packs" → "20 packs (Web 6 + Mobile 4 + AI 4 + HW 4 + Security 2)"
- "35+ tools" → "78 tools"
- 追加新增功能条目

### 4.3 NEXT.md 清理策略

1. 合并两个 "Recently Completed" 节
2. 保留最近 2 周的已完成项
3. 更老的移到文件末尾或 docs/HISTORY.md

---

## 5. 强制问题回答

### MQ1: 历史代码搜索
- [x] 是 — 需要参考 README.md, CHANGELOG.md 的现有结构
- **决定**: ✅ 保持现有结构，更新内容

### MQ2-MQ5: N/A — 纯文档任务

---

## 6. Implementation Steps

### Phase 1: 数据采集 (10 min)

#### 交付物
- [ ] 准确的 pack 数量、工具数量、skills 数量、目录结构

#### 步骤
1. 运行 §4.1 中的验证命令
2. 记录所有数字作为后续更新的 source of truth

### Phase 2: README.md 重写 (30-45 min)

#### 交付物
- [ ] README.md 更新到 v2.8.0，覆盖所有缺失功能

#### 步骤
1. 读取现有 README.md 完整内容
2. 更新版本号和 header
3. 扩展 "What's New" 覆盖 v2.6-2.8
4. 添加 Domain Packs 功能节
5. 添加 Hook Architecture 节
6. 添加 Self-Evolution 节
7. 更新安装结构图
8. 更新命令列表和 skills 数量
9. 扩展版本历史表

### Phase 3: CHANGELOG.md 修正 (15 min)

#### 交付物
- [ ] CHANGELOG.md 数据准确，新增条目完整

#### 步骤
1. 修正 pack 数量 14→20
2. 修正工具数量 35+→78
3. 追加 HW, Security pack 条目
4. 追加 Knowledge Assessment Fix, Domain Pack Integration 条目

### Phase 4: MULTI-PLATFORM.md 更新 (15 min)

#### 交付物
- [ ] docs/MULTI-PLATFORM.md 版本和内容更新

#### 步骤
1. 版本号 v2.3.0 → v2.8.0
2. 更新功能描述
3. 修正工具数量

### Phase 5: NEXT.md + INSTALLATION_GUIDE.md 清理 (10 min)

#### 交付物
- [ ] NEXT.md 合并重复节、归档旧项
- [ ] INSTALLATION_GUIDE.md 副标题微调

---

## 7. File Structure

### 7.1 Files to Modify
```
README.md                    # Major rewrite (v2.5→v2.8 feature coverage)
CHANGELOG.md                 # Data fixes + new entries
docs/MULTI-PLATFORM.md       # Version + feature update
NEXT.md                      # Structure cleanup
INSTALLATION_GUIDE.md        # Minor subtitle fix
```

### 7.2 Files Verified Current (no changes needed)
```
PROJECT_CONTEXT.md           # Already updated to v2.8.0 this session
CLAUDE.md                    # Framework rules current
.tad/config.yaml             # v2.8.0 correct
tad.sh                       # v2.8 correct
```

---

## 8. Testing Requirements

### 8.1 数据准确性
- 所有数字（pack count, tool count, skill count）来自实际文件统计
- 版本号在所有文件中一致（2.8.0 或 2.8）

### 8.2 结构完整性
- README.md 有 v2.6, v2.7, v2.8 功能介绍
- CHANGELOG.md 有 HW + Security pack 条目
- NEXT.md 只有一个 "Recently Completed" 节

---

## 9. Acceptance Criteria

- [ ] AC1: README.md 版本号 = v2.8.0
- [ ] AC2: README.md 覆盖 v2.6 (4D Protocol, Autoresearch, Linear), v2.7 (Hooks), v2.8 (Domain Packs, Traces, Self-Evolution)
- [ ] AC3: README.md Domain Packs 节存在，pack 数量正确
- [ ] AC4: README.md 版本历史表包含 v2.6, v2.7, v2.8
- [ ] AC5: README.md 命令列表包含 *optimize, *evolve
- [ ] AC6: CHANGELOG.md pack 数量 = 20，工具数量 = 78
- [ ] AC7: CHANGELOG.md 有 HW + Security pack 条目
- [ ] AC8: docs/MULTI-PLATFORM.md 版本号 = v2.8.0
- [ ] AC9: NEXT.md 只有一个 "Recently Completed" 节
- [ ] AC10: INSTALLATION_GUIDE.md 副标题含 "Self-Evolving"
- [ ] AC11: 所有数字来自实际文件统计（grep/wc -l 验证）

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ README.md 是英文，不要写中文
- ⚠️ 数字必须来自实际文件，不要从本 handoff 的审计报告直接复制（审计时间点的数字可能已变）
- ⚠️ 不要删除 README.md 的现有结构（如 Contributing, License），只更新和追加

### 10.2 Known Constraints
- 42 个未 commit 文件需要在文档更新后一起 commit
- README.md 风格参考：保持现有 markdown 格式和 heading 层级

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-04-04
**Version**: 3.1.0
