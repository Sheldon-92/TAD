---
task_type: yaml
e2e_required: no
research_required: no
---

# Handoff: Commands/Skills 合并 + Domain Pack 自动加载修复

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-04-04
**Project:** TAD Framework
**Task ID:** TASK-20260404-001
**Handoff Version:** 3.1.0
**Epic:** N/A

---

## 🔴 Gate 2: Design Completeness

**执行时间**: 2026-04-04

### Expert Review Status

| Expert | Agent | Result | Key Findings |
|--------|-------|--------|-------------|
| code-reviewer | code-reviewer | CONDITIONAL PASS → P0 fixed | 3 P0: path references, tad.sh, internal self-refs |
| backend-architect | backend-architect | CONDITIONAL PASS → P0 fixed | 4 P0: config-workflow, skills-config, tad.sh, config.yaml bindings |

**P0 Issues — All Fixed:**
1. ✅ Missing path reference updates → Added FR5 + Phase 4 + AC9
2. ✅ tad.sh installer broken → Added to FR5 + Phase 4 + AC10
3. ✅ Internal self-references in merged SKILL.md → Added to Phase 4 step 3 + AC11
4. ✅ config.yaml command_module_binding → Added verification step in Phase 4 step 4
5. ✅ Domain Pack *discuss fallback → Added FR6 + fallback in §4.2 + AC12
6. ✅ Deprecation commit ordering → Phase 5 now commits deprecation before deletion

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 合并策略 + 路径引用更新 + deprecation 策略 |
| Components Specified | ✅ | 5 Phases 明确，每个有验证方法 |
| Functions Verified | ✅ | 均为文件操作，无函数调用 |
| Data Flow Mapped | ✅ | 无数据流，纯文件合并 |

**Gate 2 结果**: ✅ PASS

**Alex确认**: 我已验证所有设计要素，Blake可以独立根据本文档完成实现。

---

## 📋 Handoff Checklist (Blake必读)

- [ ] 阅读了所有章节
- [ ] **阅读了「📚 Project Knowledge」章节中的历史经验**
- [ ] 理解了真正意图（不只是字面需求）
- [ ] 确认可以独立使用本文档完成实现

❌ 如果任何部分不清楚，**立即返回Alex要求澄清**，不要开始实现。

---

## 1. Task Overview

### 1.1 What We're Building
合并 `.claude/commands/` 和 `.claude/skills/` 中的重复文件，消除 TAD 框架的双入口混乱问题，同时修复 Alex *discuss 模式不主动加载 Domain Pack 的缺陷。

### 1.2 Why We're Building It
**业务价值**：消除用户困惑（不知道用 `/alex` 还是 `/tad-alex`），防止未来更新再次 diverge
**用户受益**：每个命令只有一个入口，行为可预测
**成功的样子**：所有斜杠命令只通过 skills 触发，commands 目录清空，Domain Pack 在 *discuss 模式也能自动加载

### 1.3 Intent Statement

**真正要解决的问题**：
1. commands/ 和 skills/ 双入口导致维护 diverge — v2.8 Quality Chain 修复只进了 commands，skills 停留在 v2.7 精简版
2. 用户不知道选哪个命令（/alex vs /tad-alex）
3. Alex 在 *discuss 模式不主动加载 Domain Pack，导致回答缺乏专业框架支撑

**不是要做的（避免误解）**：
- ❌ 不是重新精简 skill 文件（v2.7 的精简实验已证明不安全）
- ❌ 不是重构 TAD 架构
- ❌ 不是修改 hook 或 settings.json

---

## 📚 Project Knowledge（Blake 必读）

### 步骤 1：识别相关类别
- [x] architecture - 架构决策

### 步骤 2：历史经验摘录

| 文件 | 相关记录数 | 关键提醒 |
|------|-----------|----------|
| architecture.md | 3 条 | 见下方 |
| security.md | 0 条 | 无相关历史记录 |

**⚠️ Blake 必须注意的历史教训**：

1. **Judgment-Only Skill Files: 76% Reduction is Safe** (来自 architecture.md - 2026-03-31)
   - 问题：v2.7 将 Alex 从 2528→570 行，Blake 从 1052→283 行，声称"判断逻辑 only"
   - 后果：Quality Chain 系统性失效 — 约束规则被误分类为"机械逻辑"而删除
   - **⚠️ 本次任务的教训：不能用 570 行的 skill 版本覆盖 3056 行的 command 版本。必须反过来。**

2. **Claude Code Native Mechanism Validation** (来自 architecture.md - 2026-03-31)
   - 发现：Skill frontmatter 的 `allowed-tools` 不生效，per-skill hooks 未实现
   - Skills 唯一可靠的功能：prompt delivery + model override
   - **本次影响：skills 格式的优势仅在于 frontmatter（name + description），内容必须和 commands 一致**

3. **Hook Shell Portability: No grep -P on macOS** (来自 architecture.md - 2026-04-03)
   - 如果修改任何 hook 脚本，不要用 `grep -P`

### Blake 确认
- [ ] 我已阅读上述历史经验
- [ ] 我理解 skill 精简版是过时且危险的，必须用 command 完整版替换
- [ ] 我理解 frontmatter 是 skills 格式唯一的附加价值

---

## 2. Background Context

### 2.1 Previous Work
- v2.5-2.6: 只有 `.claude/commands/*.md`，一切正常
- v2.7 (03-31): 创建 `.claude/skills/*/SKILL.md` 精简版，commands 保留但不再更新
- v2.8 Quality Chain (04-03~04): 修复写入 commands，skills 未同步

### 2.2 Current State

**18 个 commands 全部在 skills 中有对应文件：**

| 类型 | 数量 | Commands | Skills | 差异 |
|------|------|----------|--------|------|
| 完全重复 | 15 | 原始内容 | command + frontmatter | ~5 行差异（仅 frontmatter） |
| 内容不同 | 3 | **最新**（v2.8 修复后） | **过时**（v2.7 精简版） | alex: 3056 vs 570, blake: 1144 vs 283, gate: 655 vs 626 |

**Domain Pack 加载问题：**
- `design_protocol.step1_5` 有 Domain Pack 加载流程 — 但只在 `*design` 阶段
- `*discuss` 模式没有 Domain Pack 加载步骤
- `*discuss` 的 `note_on_research_protocol` 提到 Cognitive Firewall 仍适用，但未提 Domain Pack
- 结果：用户在 *discuss 中讨论 AI agent 架构，Alex 没有加载 ai-agent-architecture pack

### 2.3 Dependencies
- 无外部依赖
- 下游影响：`*sync` 会将变更推送到所有注册项目

---

## 3. Requirements

### 3.1 Functional Requirements

**FR1: 合并 15 个完全重复的 commands → skills**
- 验证 diff 确认内容一致（不能只看行数）
- 确认一致后删除 commands 文件
- skills 已有 frontmatter，保留不变

**FR2: 合并 alex/blake/gate — command 内容 → skills 格式**
- 读取 command 文件（最新完整版）
- 读取 skill 文件头部的 frontmatter（`---` 块）
- 将 frontmatter + command 中 `When this command is used` 之前的自动触发条件部分 + command 主体内容 写入 skill 文件
- 删除 command 文件
- 特别注意：保留 command 中 Quality Chain Phase 2/3 新增的所有内容

**FR3: 修复 *discuss 模式的 Domain Pack 加载**
- 在 Alex 的 `discuss_path_protocol` 中增加 Domain Pack 感知
- 规则：当 *discuss 话题匹配某个 Domain Pack capability 时，Alex 应主动加载对应 pack
- 不是强制加载所有 pack — 是根据话题内容判断并加载相关的
- 这个修改写入合并后的 `skills/alex/SKILL.md`

**FR4: 更新 sync 相关配置**
- 更新 `.tad/deprecation.yaml`：添加 commands 目录文件的删除条目（版本 ≥ 2.8.1）
- 这样下次 `*sync` 到下游项目时，下游的 commands 也会被清理

**FR5: 更新所有引用 `.claude/commands/` 的活跃文件 (Expert Review P0)**
- 合并后全项目 grep `.claude/commands/` — 更新所有活跃文件中的路径引用
- 已知必须更新的文件：
  - `.tad/config-workflow.yaml` — 2 处路径引用 (`command_file`, `command`)
  - `.tad/skills-config.yaml` — location 字段
  - `tad.sh` — 安装脚本的 copy 逻辑（从 commands/ 改为 skills/）
  - `.tad/config.yaml` — `command_module_binding` 键名验证（`tad-alex` vs `alex`）
  - 合并后的 SKILL.md 内部自引用（如 `.claude/commands/playground.md` → `.claude/skills/playground/SKILL.md`）
  - `ROADMAP.md` — `.claude/commands/` 链接
  - `INSTALLATION_GUIDE.md` — `.claude/commands/` 引用
- Blake 必须执行完整 grep 扫描，不能只依赖上述列表

**FR6: Domain Pack *discuss fallback (Expert Review P1)**
- 当 SessionStart additionalContext 中没有 Domain Pack 信息时（如 hook 失败），静默跳过，不报错

### 3.2 Non-Functional Requirements
- NFR1: 合并后 `/alex`、`/blake`、`/gate` 的行为必须和合并前 `/tad-alex`、`/tad-blake`、`/tad-gate` 完全一致
- NFR2: 不能丢失任何 v2.8 Quality Chain 修复内容
- NFR3: `grep -r '.claude/commands/' .tad/ .claude/ tad.sh` 在活跃文件中返回 0 结果（archive/backup 除外）

---

## 4. Technical Design

### 4.1 合并策略

**15 个完全重复的：**
```
验证流程（每个文件）：
1. diff .claude/commands/{name}.md .claude/skills/{name}/SKILL.md
2. 确认差异仅为 frontmatter（前 3-4 行 ---/name/description/---）
3. 如果有其他差异 → STOP，报告差异，不要删除
4. 确认无差异 → 删除 .claude/commands/{name}.md
```

**3 个内容不同的（alex/blake/gate）：**
```
合并流程（每个文件）：
1. 读取 .claude/skills/{name}/SKILL.md → 提取 frontmatter 块（--- 到 ---）
2. 读取 .claude/commands/tad-{name}.md → 提取全部内容
3. 组合：frontmatter + 空行 + command 完整内容 → 写入 .claude/skills/{name}/SKILL.md
4. 验证：新 SKILL.md 包含所有 Quality Chain 关键标记（见验证清单）
5. 删除 .claude/commands/tad-{name}.md
```

### 4.2 Domain Pack *discuss 加载设计

在合并后的 `skills/alex/SKILL.md` 中，修改 `discuss_path_protocol.behavior` 部分：

```yaml
discuss_path_protocol:
  behavior:
    # 新增：Domain Pack 感知
    domain_pack_awareness:
      trigger: "话题内容匹配 Domain Pack capability 时"
      action: |
        在首次回答 *discuss 话题之前：
        1. 从 SessionStart additionalContext 中读取所有 Domain Pack 的 capabilities 列表
        2. 判断当前话题是否匹配某个 pack 的 capability
           匹配条件：话题关键词与 capability 名称或描述有语义相关性
        3. 如果匹配：
           a. Read 对应的 .tad/domains/{pack-name}.yaml
           b. 输出: "🔧 Loaded Domain Pack: {pack-name} — using {capability} framework"
           c. 用 pack 的质量标准和反模式指导后续讨论
        4. 如果不匹配：正常讨论，不加载
      fallback: |
        如果 SessionStart additionalContext 中没有 Domain Pack 信息
        （hook 未运行、项目无 .tad/domains/、或 context 被压缩）：
        → 静默跳过，不报错，正常进入 *discuss
        不要尝试手动扫描 .tad/domains/ 目录作为 fallback — 那是 hook 的职责
      note: |
        这不是流程要求 — 是知识质量保证。
        没有 pack 的分析 = 没有专业框架支撑的泛泛建议。
        *discuss 不需要走 AskUserQuestion 确认（不同于 *design 的 step1_5）
        匹配是 LLM 语义判断，不是精确字符串匹配。
```

---

## 5. 强制问题回答

### MQ1: 历史代码搜索
- [x] 否 → 跳过（纯 TAD 框架文件操作）

### MQ2: 函数存在性验证
- 无函数调用，纯文件操作

### MQ3-MQ5: 不适用（无数据流、无 UI、无状态同步）

---

## 6. Implementation Steps

### Phase 1: 验证 15 个完全重复的 commands（预计 15 分钟）

#### 实施步骤
1. 对每个文件运行 diff 验证：
   ```
   tad.md ↔ tad/SKILL.md
   tad-init.md ↔ tad-init/SKILL.md
   tad-maintain.md ↔ tad-maintain/SKILL.md
   tad-status.md ↔ tad-status/SKILL.md
   tad-elicit.md ↔ tad-elicit/SKILL.md
   tad-handoff.md ↔ tad-handoff/SKILL.md
   tad-scenario.md ↔ tad-scenario/SKILL.md
   tad-parallel.md ↔ tad-parallel/SKILL.md
   tad-test-brief.md ↔ tad-test-brief/SKILL.md
   tad-help.md ↔ tad-help/SKILL.md
   playground.md ↔ playground/SKILL.md
   coordinator.md ↔ coordinator/SKILL.md
   product.md ↔ product/SKILL.md
   research.md ↔ research/SKILL.md
   knowledge-audit.md ↔ knowledge-audit/SKILL.md
   ```
2. 对于每个文件，去掉 SKILL.md 的 frontmatter 后 diff
3. 如果 diff 为空（仅 frontmatter 差异）→ 记录为"可安全删除"
4. 如果有内容差异 → **STOP**，记录差异内容，不删除
5. 输出验证报告表格

#### 验证方法
- 每个 diff 结果记录到验证报告
- 0 个意外差异 = Phase 1 Pass

#### Phase 1 完成证据
- [ ] 15 个 diff 结果表格
- [ ] 每个标记为"一致"或"有差异"（含差异内容）

---

### Phase 2: 合并 alex/blake/gate（预计 30 分钟）

#### 实施步骤

**每个文件按以下流程：**

1. 读取 skill frontmatter：
   ```
   .claude/skills/alex/SKILL.md → 提取 lines 1-4 (--- block)
   .claude/skills/blake/SKILL.md → 提取 lines 1-4
   .claude/skills/gate/SKILL.md → 提取 lines 1-4
   ```

2. 读取 command 完整内容：
   ```
   .claude/commands/tad-alex.md → 全部内容
   .claude/commands/tad-blake.md → 全部内容
   .claude/commands/tad-gate.md → 全部内容
   ```

3. 组合写入：`frontmatter + "\n" + command内容` → 覆盖 SKILL.md

4. **关键验证**（每个文件必须通过）：

   **alex SKILL.md 必须包含：**
   - [ ] `handoff_creation_protocol` 的 `step0_5` (Context Refresh)
   - [ ] `step1a` (Domain Pack Injection)
   - [ ] `step1b` (Frontmatter Validation)
   - [ ] `acceptance_protocol.step4` 中的 AC 逐条对照表
   - [ ] `acceptance_protocol.step4b` (Evidence Completeness Check)
   - [ ] `accept_command.step0_git_check`
   - [ ] `accept_command.step0b_evidence_check`
   - [ ] 所有 `# ⚠️ ANTI-RATIONALIZATION` 注释（至少 5 处）
   - [ ] `optimize_protocol` (*optimize command)
   - [ ] `evolve_protocol` (*evolve command)
   - [ ] `domain_pack_awareness` in discuss_path_protocol (Phase 3 新增)

   **blake SKILL.md 必须包含：**
   - [ ] `EXECUTION CHECKLIST` 或等效的约束规则
   - [ ] `layer2_expert_review` 强制要求
   - [ ] `research_compliance` 强制要求
   - [ ] `e2e_compliance` 强制要求
   - [ ] `circuit_breaker` 和 `escalation` 规则
   - [ ] `# ⚠️ ANTI-RATIONALIZATION` 注释

   **gate SKILL.md 必须包含：**
   - [ ] `Knowledge_Assessment` (Gate 3 + Gate 4)
   - [ ] `Acceptance_Verification` check
   - [ ] `Git_Commit_Verification` check
   - [ ] `Risk_Translation` (Cognitive Firewall)

5. 验证通过后删除 command 文件

#### Phase 2 完成证据
- [ ] 3 个合并后的 SKILL.md 文件
- [ ] 每个文件的验证清单全部 ✅
- [ ] grep 验证关键标记存在

---

### Phase 3: Domain Pack *discuss 加载修复（预计 15 分钟）

#### 实施步骤
1. 在 Phase 2 合并后的 `skills/alex/SKILL.md` 中
2. 找到 `discuss_path_protocol.behavior` 部分
3. 在 `allowed` 列表之后、`forbidden` 之前，插入 `domain_pack_awareness` 块（见 §4.2 设计）
4. 验证插入位置正确，不破坏 YAML 结构

#### 验证方法
- 搜索 `domain_pack_awareness` 确认存在
- 搜索 `discuss_path_protocol` 确认结构完整

---

### Phase 4: 全项目路径引用更新（预计 20 分钟）

⚠️ **此 Phase 是 Expert Review P0 修复 — 不可跳过**

#### 实施步骤

1. **全项目扫描**：
   ```bash
   grep -r '.claude/commands/' .tad/ .claude/ tad.sh ROADMAP.md INSTALLATION_GUIDE.md \
     --include='*.md' --include='*.yaml' --include='*.sh' --include='*.json' \
     | grep -v '.tad/archive/' | grep -v '.tad/config-backup' | grep -v '.tad.backup'
   ```
   记录所有命中位置。

2. **逐文件更新**（已知列表 + grep 发现的其他文件）：

   | 文件 | 当前引用 | 更新为 |
   |------|---------|--------|
   | `.tad/config-workflow.yaml` | `command_file: ".claude/commands/tad-maintain.md"` | `command_file: ".claude/skills/tad-maintain/SKILL.md"` |
   | `.tad/config-workflow.yaml` | `command: ".claude/commands/playground.md"` | `command: ".claude/skills/playground/SKILL.md"` |
   | `.tad/skills-config.yaml` | `location: ".claude/commands/"` | `location: ".claude/skills/"` |
   | `tad.sh` | `cp "$src"/.claude/commands/*.md .claude/commands/` | 更新为复制 `.claude/skills/` 目录结构 |
   | `tad.sh` | `mkdir -p .claude/commands` | 移除或改为 `mkdir -p .claude/skills` |
   | `.tad/config.yaml` | `command_module_binding` 下的 `tad-alex` 键 | 验证 skill 加载机制是否依赖此键名；如果依赖则添加 `alex` 别名 |
   | `ROADMAP.md` | `.claude/commands/tad-*.md` 链接 | 更新为 `.claude/skills/*/SKILL.md` |
   | `INSTALLATION_GUIDE.md` | `.claude/commands/` 引用 | 更新为 `.claude/skills/` |
   | 合并后的 `skills/alex/SKILL.md` | 内部 `.claude/commands/playground.md` 引用 | `.claude/skills/playground/SKILL.md` |

3. **SKILL.md 内部自引用清理**：
   对每个合并后的 SKILL.md 执行：
   ```bash
   grep '.claude/commands/' .claude/skills/alex/SKILL.md
   grep '.claude/commands/' .claude/skills/blake/SKILL.md
   grep '.claude/commands/' .claude/skills/gate/SKILL.md
   ```
   将所有命中替换为对应的 skills 路径。

4. **config.yaml command_module_binding 验证**：
   - 读取 skill 文件中的 activation 逻辑，确认是否引用 `command_module_binding.tad-alex` 
   - 如果是 → 保留现有键名不改（skill 内部按名字查找）
   - 如果不是 → 可选择重命名键（但不阻塞）

5. **config 文件注释更新**：
   `.tad/config.yaml` 和 `.tad/config-agents.yaml` 中的 `loaded_by` 注释引用 `tad-alex.md` 格式 → 更新为 `skills/alex/SKILL.md`

#### 验证方法
```bash
# 最终验证 — 排除 archive/backup 后应返回 0 结果
grep -r '.claude/commands/' .tad/ .claude/ tad.sh ROADMAP.md INSTALLATION_GUIDE.md \
  --include='*.md' --include='*.yaml' --include='*.sh' --include='*.json' \
  | grep -v '.tad/archive/' | grep -v '.tad/config-backup' | grep -v '.tad.backup' \
  | grep -v '.tad/config-full-backup'
```

#### Phase 4 完成证据
- [ ] grep 扫描结果（更新前 vs 更新后）
- [ ] 每个文件的具体修改记录
- [ ] 最终 grep 验证返回 0 结果

---

### Phase 5: 删除 commands + 更新 deprecation（预计 10 分钟）

#### 实施步骤
1. 先更新 `.tad/deprecation.yaml`（在删除之前提交，确保 deprecation 记录先于删除）：
   ```yaml
   - version: "2.8.1"
     files:
       - ".claude/commands/tad-alex.md"
       - ".claude/commands/tad-blake.md"
       - ".claude/commands/tad-gate.md"
       - ".claude/commands/tad.md"
       - ".claude/commands/tad-init.md"
       - ".claude/commands/tad-maintain.md"
       - ".claude/commands/tad-status.md"
       - ".claude/commands/tad-elicit.md"
       - ".claude/commands/tad-handoff.md"
       - ".claude/commands/tad-scenario.md"
       - ".claude/commands/tad-parallel.md"
       - ".claude/commands/tad-test-brief.md"
       - ".claude/commands/tad-help.md"
       - ".claude/commands/playground.md"
       - ".claude/commands/coordinator.md"
       - ".claude/commands/product.md"
       - ".claude/commands/research.md"
       - ".claude/commands/knowledge-audit.md"
   ```
2. 更新 `.tad/version.txt` → 2.8.1
3. Git commit: "chore: add commands deprecation for v2.8.1"
4. Phase 1 验证通过的 15 个 commands → 删除
5. Phase 2 验证通过的 3 个 commands → 删除
6. 在 `.claude/commands/` 中放置 `README.md`：
   ```
   Commands have been consolidated into .claude/skills/ as of v2.8.1.
   See .tad/deprecation.yaml for details.
   ```
7. Git commit: "refactor: consolidate commands into skills (v2.8.1)"

#### 验证方法
- `.claude/commands/` 只剩 README.md
- `cat .tad/version.txt` 应显示 2.8.1
- `.tad/deprecation.yaml` 包含新条目
- git log 显示两个独立的 commit（deprecation 先于删除）

---

## 7. File Structure

### 7.1 Files to Modify
```
.claude/skills/alex/SKILL.md       # 用 tad-alex.md 内容替换 + 加 domain_pack_awareness
.claude/skills/blake/SKILL.md      # 用 tad-blake.md 内容替换
.claude/skills/gate/SKILL.md       # 用 tad-gate.md 内容替换
.tad/deprecation.yaml              # 添加 commands 删除条目
.tad/version.txt                   # 2.8.0 → 2.8.1
.tad/config-workflow.yaml           # 2 处 .claude/commands/ 路径 (P0)
.tad/skills-config.yaml             # location 字段 (P0)
.tad/config.yaml                    # command_module_binding 验证/更新 (P0)
tad.sh                              # 安装脚本 copy 逻辑 (P0)
ROADMAP.md                          # .claude/commands/ 链接 (P1)
INSTALLATION_GUIDE.md               # .claude/commands/ 引用 (P1)
```

### 7.2 Files to Delete
```
.claude/commands/tad-alex.md
.claude/commands/tad-blake.md
.claude/commands/tad-gate.md
.claude/commands/tad.md
.claude/commands/tad-init.md
.claude/commands/tad-maintain.md
.claude/commands/tad-status.md
.claude/commands/tad-elicit.md
.claude/commands/tad-handoff.md
.claude/commands/tad-scenario.md
.claude/commands/tad-parallel.md
.claude/commands/tad-test-brief.md
.claude/commands/tad-help.md
.claude/commands/playground.md
.claude/commands/coordinator.md
.claude/commands/product.md
.claude/commands/research.md
.claude/commands/knowledge-audit.md
```

---

## 8. Testing Requirements

### 8.1 验证测试
- 合并后执行 `/alex` → 应正常激活 Alex persona
- 确认 `/tad-alex` 不再存在（或报错"未找到命令"）
- 在 *discuss 中讨论 AI agent 话题 → Alex 应主动加载 ai-agent-architecture pack

### 8.2 回归测试
- 合并后的 alex SKILL.md 中 grep 所有 ANTI-RATIONALIZATION 标记
- 合并后的 blake SKILL.md 中 grep EXECUTION CHECKLIST 标记
- 确认 Quality Chain Phase 2/3/4 的所有关键内容都存在

### 8.3 Edge Cases
- 如果某个"完全重复"的 command 实际有微小差异 → Phase 1 会捕获，不删除
- `.claude/commands/` 目录删空后 Git 不会追踪空目录 — 这是预期行为

---

## 9. Acceptance Criteria

- [ ] AC1: 18 个 command 文件全部删除
- [ ] AC2: alex/blake/gate SKILL.md 包含 command 的完整内容（通过 Phase 2 验证清单）
- [ ] AC3: 15 个完全重复的 command 删除前已通过 diff 验证
- [ ] AC4: alex SKILL.md 包含 `domain_pack_awareness` 在 discuss_path_protocol 中
- [ ] AC5: `.tad/deprecation.yaml` 更新了 18 个文件的删除条目
- [ ] AC6: `.tad/version.txt` 更新为 2.8.1
- [ ] AC7: 合并后 `/alex` 可正常激活（功能验证）
- [ ] AC8: 无 Quality Chain 内容丢失（grep 验证关键标记）
- [ ] AC9: `grep -r '.claude/commands/' .tad/ .claude/ tad.sh` 在活跃文件中返回 0 结果（archive/backup 除外）(P0)
- [ ] AC10: `tad.sh` 安装脚本更新为从 `.claude/skills/` 复制（P0）
- [ ] AC11: 合并后 SKILL.md 内部无 `.claude/commands/` 自引用（P0）
- [ ] AC12: `domain_pack_awareness` 包含 fallback（SessionStart 无 pack 信息时静默跳过）(P1)

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ **绝对不能用 skill 精简版覆盖 command 完整版** — 这会回退 Quality Chain Phase 2/3 的修复
- ⚠️ Phase 1 的 diff 验证必须实际执行，不能跳过 — "看起来一样" ≠ 实际一样
- ⚠️ 合并 alex/blake/gate 后的验证清单是 BLOCKING — 任何一项未通过则不能删除 command

### 10.2 Known Constraints
- Skills 的 frontmatter 只支持 name 和 description 字段（allowed-tools 不生效）
- `.claude/commands/` 清空后，下游项目的 commands 需要通过 `*sync` + deprecation 清理

### 10.3 Sub-Agent使用建议
- [ ] **code-reviewer** — Phase 2 合并后验证内容完整性
- [ ] **test-runner** — 不需要（无代码测试）

---

## 11. Decision Rationale

### 为什么 command 内容 → skill，而不是反过来

| 方案 | 优点 | 缺点 | 为什么没选 |
|------|------|------|-----------|
| ✅ command → skill | 保留 v2.8 最新内容 | skill 文件变大 | ✅ 选中 |
| ❌ skill → command | 文件更小 | **丢失 Quality Chain 修复** | 会回退到 v2.7 失效状态 |
| ❌ 重新精简 | 更小、更优雅 | v2.7 已证明精简不安全 | 风险太高 |

**权衡分析**：文件大小 vs 内容完整性 — 当前优先级：完整性 >> 大小

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-04-04
**Version**: 3.1.0
