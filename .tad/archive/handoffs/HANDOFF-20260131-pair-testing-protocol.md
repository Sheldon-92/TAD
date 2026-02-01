# Handoff: Pair Testing Protocol

**Task ID**: TASK-20260131-001
**Created**: 2026-01-31
**Author**: Alex (Solution Lead)
**Priority**: P1
**Complexity**: Medium (Standard TAD)

---

## Executive Summary

将配对 E2E 测试协议集成到 TAD 框架的 Gate 3→4 流程中。Blake 在 Gate 3 通过后生成 TEST_BRIEF（技术部分），Alex 在 Gate 4 验收时补充设计意图部分并定稿，Gate 4 通过后提醒用户带 TEST_BRIEF 去 Claude Desktop 做配对 E2E 测试。测试报告回流后触发新一轮 Handoff。

## Background

用户发现与 Claude Desktop 做配对 E2E 测试非常高效：
- 解决了 E2E 测试容易拖延的问题
- Claude Desktop 能自动打开网页、截图、逐页测试
- 用户在旁补充设计意图反馈，Claude Desktop 整合为结构化报告
- 这是跨工具协作：TAD (CLI) → Claude Desktop (GUI)

已有实践验证：menu-snap 项目的 TEST_BRIEF.md 和 TEST_BRIEF_TEMPLATE.md。

## Design

### Flow Integration

```
                        TAD CLI (Terminal 1 & 2)
┌──────────────────────────────────────────────────────────┐
│  Blake: Implementation → Ralph Loop → Gate 3             │
│      ↓                                                    │
│  Blake: Generate TEST_BRIEF (technical sections)          │
│      ↓                                                    │
│  Blake → Human → Alex                                    │
│      ↓                                                    │
│  Alex: Supplement TEST_BRIEF (design sections)            │
│      ↓                                                    │
│  Alex: Gate 4 Acceptance (code review, etc.)              │
│      ↓                                                    │
│  Alex: Gate 4 Pass → Remind human for E2E pair testing   │
└──────────────────────────────────────────────────────────┘
                            ↓
                    Human takes TEST_BRIEF.md
                            ↓
┌──────────────────────────────────────────────────────────┐
│              Claude Desktop (GUI)                         │
│  Human + Claude Desktop pair E2E testing                  │
│      ↓                                                    │
│  Generate PAIR_TEST_REPORT.md (with screenshots)          │
│  Save to project directory                                │
└──────────────────────────────────────────────────────────┘
                            ↓
                    Report flows back to project
                            ↓
┌──────────────────────────────────────────────────────────┐
│  Alex activation → Auto-detect PAIR_TEST_REPORT           │
│      ↓                                                    │
│  Alex reads report → Creates new Handoffs for fixes       │
└──────────────────────────────────────────────────────────┘
```

### File Changes

#### 1. NEW: `.tad/templates/test-brief-template.md`

Adapt from menu-snap's template. Make it generic (not web-only) but with web defaults.

Template structure:
```markdown
# 配对测试简报 (Pair Testing Brief)

> 本文件由 TAD 框架生成，供配对测试 Agent（如 Claude Desktop）和产品负责人使用

## 1. 产品概述
- 产品名称、一句话描述、测试环境 URL、技术栈
- 核心用户场景（numbered list）
- 重要定位说明

## 2. 本次测试范围
- 需要测试的页面/功能（table: 序号 | 页面/功能 | 入口路径 | 重点验证）
- 不需要测试的部分

## 3. 测试账号/数据
- 测试账号信息
- 测试数据位置

## 4. 已知问题（不用重复报告）
- Table: 问题 | 状态

## 5. 特别关注点
- 开发过程中不确定的设计决策，需要产品反馈
- **此部分由 Alex 补充**

## 6. 配对测试工作流
- 标准工作流说明（逐页测试 → 记录 → 产品反馈 → 下一页 → 汇总报告）

## 7. 输出要求
- 截图技术方案（gif_creator 方案，Web 项目默认）
- 截图命名规范
- 报告格式要求（PAIR_TEST_REPORT.md）

## 8. 技术注意事项
- 截图方法对比表
- 截图保存示例
```

**Important**: Section 1, 2, 3, 4, 8 = Blake fills (technical)。Section 5 = Alex fills (design intent)。Section 6, 7 = template default (rarely needs modification)。

#### 2. MODIFY: `.claude/commands/tad-blake.md`

**Location**: `completion_protocol` section, between step4 (Gate 3) and step5 (completion report).

Add new step: `step4b_generate_test_brief`

```yaml
step4b_generate_test_brief: |
  After Gate 3 v2 passes, Blake MUST generate TEST_BRIEF.md:

  1. Read `.tad/templates/test-brief-template.md`
  2. Fill technical sections:
     - Section 1: Product info from project (package.json, README, etc.)
     - Section 2: Test scope based on what was implemented in this task
     - Section 3: Test accounts/data from implementation knowledge
     - Section 4: Known issues discovered during implementation
     - Section 8: Technical notes (framework-specific testing tips)
  3. Leave Section 5 (特别关注点) with placeholder:
     "<!-- Alex 将补充设计意图和用户体验关注点 -->"
  4. Write to project root: `TEST_BRIEF.md`
  5. Include TEST_BRIEF.md in the "Message from Blake" to Alex:
     Add line: "Test Brief: TEST_BRIEF.md (technical sections filled, needs Alex review)"
```

**Also update** `step8_generate_message` to include test brief mention:
```
📨 Message from Blake (Terminal 2)
────────────────────────────────
Task:      {task title}
Status:    ✅ Implementation Complete - Gate 3 Passed
...existing fields...

📋 Test Brief: TEST_BRIEF.md generated (needs Alex to supplement Section 5)

Action: Please run Gate 4 (Acceptance) to verify and archive.
────────────────────────────────
```

#### 3. MODIFY: `.claude/commands/tad-alex.md`

**Change A**: Add `*test-review` command to commands section.

```yaml
test-review: Review PAIR_TEST_REPORT and create fix handoffs
```

**Change B**: Gate 4 post-pass action. After Gate 4 passes in `*accept` flow, add:

```yaml
gate4_post_pass_test_brief: |
  After Gate 4 passes:
  1. Check if TEST_BRIEF.md exists in project root
  2. If exists:
     a. Read it
     b. Supplement Section 5 (特别关注点) with design intent:
        - Design decisions that need user validation
        - UX expectations that code review can't verify
        - User scenarios that need E2E walkthrough
     c. Write updated TEST_BRIEF.md
     d. Remind human:
        "📋 TEST_BRIEF.md 已就绪（技术 + 设计部分完整）
         请将 TEST_BRIEF.md 拖入 Claude Desktop 进行配对 E2E 测试。
         测试完成后，将 PAIR_TEST_REPORT.md 保存到项目目录，
         下次启动 /alex 时我会自动检测并处理。"
  3. If not exists: skip (not all tasks need E2E testing)
```

**Change C**: Add STEP 3.7 to activation protocol (after STEP 3.6 doesn't exist for Alex, so add after STEP 3.5):

```yaml
- STEP 3.6: Pair test report detection
  action: |
    Scan project root for PAIR_TEST_REPORT*.md files.
    If found:
      1. List them with filename and creation date
      2. Use AskUserQuestion to ask:
         "检测到配对测试报告，要现在审阅并生成修复 Handoff 吗？"
         Options: "审阅报告" (review now), "稍后处理" (skip)
      3. If review now → execute *test-review flow
      4. If skip → proceed to greeting
  blocking: false
```

**Change D**: Define `*test-review` command behavior:

```yaml
test_review_protocol: |
  When *test-review is invoked:
  1. Read PAIR_TEST_REPORT.md
  2. Extract all issues (look for tables with 问题/Priority columns)
  3. Classify:
     - P0 (blocker): Create immediate handoff for Blake
     - P1 (important): Create handoff for Blake
     - P2 (nice-to-have): Add to NEXT.md as pending items
  4. For P0/P1 issues:
     - Group related issues into one handoff (avoid fragmentation)
     - Create HANDOFF-{date}-pair-test-fixes.md
     - Include screenshots/evidence references from the report
  5. Archive processed report to .tad/evidence/pair-tests/
  6. Output summary:
     "📋 测试报告已处理：
      - P0: {N} 个紧急问题 → Handoff 已创建
      - P1: {N} 个重要问题 → Handoff 已创建
      - P2: {N} 个优化项 → 已添加到 NEXT.md
      请将 Handoff 传递给 Blake (Terminal 2)"
```

#### 4. MODIFY: `.tad/config-workflow.yaml`

Add `pair_testing` section after `tad_maintain`:

```yaml
# ==================== 配对测试协议 ====================
pair_testing:
  description: "Cross-tool E2E pair testing protocol (TAD CLI → Claude Desktop)"

  brief:
    template: ".tad/templates/test-brief-template.md"
    output: "TEST_BRIEF.md"  # project root
    trigger: "Gate 3 pass (Blake generates technical sections)"
    finalize: "Gate 4 pass (Alex supplements design sections)"
    sections:
      blake_fills: [1, 2, 3, 4, 8]  # technical
      alex_fills: [5]                 # design intent
      template_default: [6, 7]        # workflow & output format

  report:
    expected_pattern: "PAIR_TEST_REPORT*.md"
    location: "project root"
    archive_to: ".tad/evidence/pair-tests/"
    auto_detect_on_alex_start: true
    issue_routing:
      P0: "Create immediate handoff"
      P1: "Create handoff"
      P2: "Add to NEXT.md"

  screenshot:
    default_method: "gif_creator"  # for Web projects
    output_dir: "e2e-screenshots/"
    naming: "{NN}-{page-name}.gif"
```

#### 5. MODIFY: `.tad/config.yaml` (master index)

Update `config-workflow.yaml` entry in `config_modules` to include `pair_testing`:

```yaml
config-workflow.yaml:
  contains:
    - document_management (handoff_lifecycle, next_md_maintenance)
    - tad_maintain
    - requirement_elicitation (research_phase)
    - socratic_inquiry_protocol
    - scenarios (new_project, bug_fix)
    - pair_testing  # NEW
```

Also add `tad-test-brief` to `command_module_binding`:

```yaml
tad-test-brief:
  modules: [config-workflow]
  note: "Test brief needs pair_testing config from workflow module"
```

#### 6. NEW: `.claude/commands/tad-test-brief.md` (standalone command)

A lightweight command for manual invocation. When called:
1. Check if TEST_BRIEF.md already exists → offer to regenerate or supplement
2. If no existing brief:
   a. Read template
   b. Ask user which sections they want to fill (or auto-fill from project context)
   c. Generate TEST_BRIEF.md
3. This command works outside Gate flow for ad-hoc testing needs

Keep this command simple (~50 lines). It's the manual fallback; the main flow is Gate-integrated.

#### 7. MODIFY: `CLAUDE.md`

Add Pair Testing rules to the existing rules:

```markdown
## N. 配对测试规则

### Gate 集成
- Gate 3 通过后：Blake 必须生成 TEST_BRIEF.md（技术部分）
- Gate 4 通过后：Alex 补充设计意图，提醒用户做配对 E2E 测试
- 报告回流后：Alex 自动检测并生成修复 Handoff

### 跨工具协作
- TEST_BRIEF.md 是 TAD (CLI) → Claude Desktop (GUI) 的桥梁
- PAIR_TEST_REPORT.md 是 Claude Desktop → TAD 的反馈通道
- 人类是两个工具之间的信息桥梁（与 Terminal 隔离规则一致）
```

#### 8. MODIFY: `.claude/commands/tad-help.md`

Add Pair Testing section:

```markdown
## Pair Testing (E2E 配对测试)

TAD 支持跨工具的配对 E2E 测试：

| 阶段 | 触发 | 产出 |
|------|------|------|
| Gate 3 后 | Blake 自动生成 | TEST_BRIEF.md（技术部分）|
| Gate 4 后 | Alex 补充并提醒 | TEST_BRIEF.md（完整版）|
| 配对测试 | 用户 + Claude Desktop | PAIR_TEST_REPORT.md |
| 报告回流 | Alex 检测报告 | 新 Handoff（修复任务）|

手动命令：`/tad-test-brief` - 独立生成测试简报
Alex 命令：`*test-review` - 审阅测试报告并生成修复 Handoff
```

## Acceptance Criteria

1. ✅ Blake Gate 3 通过后自动生成 TEST_BRIEF.md（技术 sections 填充）
2. ✅ Blake 的 "Message from Blake" 包含 TEST_BRIEF 提醒
3. ✅ Alex Gate 4 通过后补充 Section 5 并提醒用户做配对测试
4. ✅ Alex 启动时自动检测 PAIR_TEST_REPORT*.md
5. ✅ `*test-review` 命令能读取报告、分类问题、生成 Handoff
6. ✅ `/tad-test-brief` 独立命令可用
7. ✅ 模板通用但 Web 优先（截图方案默认 gif_creator）
8. ✅ config-workflow.yaml 包含 pair_testing 配置
9. ✅ CLAUDE.md 和 tad-help.md 更新

## File Lifecycle Management

### Naming Conventions

| 文件 | 命名规则 | 示例 |
|------|----------|------|
| 测试简报 | `TEST_BRIEF.md` (项目根目录，单例) | `TEST_BRIEF.md` |
| 测试简报归档 | `{date}-test-brief-{slug}.md` | `2026-01-31-test-brief-user-auth.md` |
| 测试报告 | `PAIR_TEST_REPORT.md` (Claude Desktop 生成) | `PAIR_TEST_REPORT.md` |
| 测试报告归档 | `{date}-pair-test-report-{slug}.md` | `2026-01-31-pair-test-report-user-auth.md` |
| 截图目录 | `e2e-screenshots/{NN}-{category}/` | `e2e-screenshots/01-onboarding/` |
| 截图文件 | `{NN}-{page-name}.gif` | `01-home.gif` |

### Directory Structure

```
project-root/
├── TEST_BRIEF.md              ← 当前活跃的测试简报（Blake 生成，Alex 补充）
├── PAIR_TEST_REPORT.md        ← Claude Desktop 生成的测试报告（待 Alex 处理）
├── e2e-screenshots/           ← 配对测试截图（Claude Desktop 生成）
│   ├── 01-onboarding/
│   ├── 02-menu-ocr/
│   └── ...
└── .tad/
    └── evidence/
        └── pair-tests/        ← 归档区（处理后的报告和简报）
            ├── 2026-01-31-test-brief-user-auth.md
            ├── 2026-01-31-pair-test-report-user-auth.md
            └── ...
```

### Lifecycle Flow

```
Phase 1: Generation
  Gate 3 pass → Blake creates TEST_BRIEF.md (project root)

Phase 2: Supplementation
  Alex Gate 4 → supplements Section 5 → TEST_BRIEF.md is finalized

Phase 3: Pair Testing (outside TAD)
  User takes TEST_BRIEF.md → Claude Desktop
  Claude Desktop creates: PAIR_TEST_REPORT.md + e2e-screenshots/

Phase 4: Report Review
  Alex detects PAIR_TEST_REPORT.md → *test-review
    ↓
  Processing complete:
    a. Rename & move TEST_BRIEF.md → .tad/evidence/pair-tests/{date}-test-brief-{slug}.md
    b. Rename & move PAIR_TEST_REPORT.md → .tad/evidence/pair-tests/{date}-pair-test-report-{slug}.md
    c. Move e2e-screenshots/ → .tad/evidence/pair-tests/{date}-screenshots-{slug}/
    d. Project root is clean again

Phase 5: Re-testing (if needed)
  If fixes require another round of E2E testing:
    New Gate 3 → new TEST_BRIEF.md → repeat cycle
    Previous archives remain in .tad/evidence/pair-tests/ for reference
```

### Cleanup Rules

1. **TEST_BRIEF.md 是单例**：项目根目录同时只有一个 TEST_BRIEF.md。新生成时，如果旧的还在，先归档旧的。
2. **报告处理后归档**：`*test-review` 完成后，报告和截图从项目根目录移到 `.tad/evidence/pair-tests/`。
3. **截图随报告走**：`e2e-screenshots/` 整个目录随报告一起归档。
4. **归档用 slug**：slug 从当前 handoff 的 task 名称提取（如 `user-auth`、`menu-ocr`）。
5. **tad-maintain 集成**：`/tad-maintain` 的 CHECK 模式应检查项目根目录是否有未处理的 PAIR_TEST_REPORT.md，如有则报告 WARNING。
6. **.gitignore 建议**：`e2e-screenshots/` 和 `TEST_BRIEF.md` 可选加入 .gitignore（用户项目级别决定）。

### tad-init Integration

`/tad-init` 需要创建：
```
.tad/evidence/pair-tests/    ← 新目录
```

并在 `.tad/templates/` 中包含：
```
test-brief-template.md       ← 新模板
```

### tad-maintain Integration

`/tad-maintain` CHECK 模式新增检查项：

```
PAIR TESTING
  [icon] TEST_BRIEF.md: {exists/none}
  [icon] PAIR_TEST_REPORT.md: {exists (unprocessed!)/none}
  [icon] e2e-screenshots/: {exists ({N} files)/none}
```

如果 PAIR_TEST_REPORT.md 存在但未处理 → WARNING:
```
RECOMMENDED ACTIONS
  1. Run *test-review in Alex to process pair test report
```

## Implementation Notes

- 模板基于 menu-snap 的 TEST_BRIEF_TEMPLATE.md，但需要通用化
- Section 5 的 Alex 补充是增量操作（不覆盖 Blake 已填内容）
- `*test-review` 的 P0/P1 问题应合并为一个 Handoff（避免碎片化）
- 报告归档到 `.tad/evidence/pair-tests/` 后从项目根目录移除
- 确保 `.tad/evidence/pair-tests/` 目录存在（tad-init 需要创建）
- 归档操作使用两阶段安全（先复制到目标，确认成功后再删除源文件）

## Out of Scope

- Claude Desktop 端的行为（那由 TEST_BRIEF 文档驱动，不在 TAD 控制范围）
- TTS 音频测试方案
- 具体项目的测试用例编写
