---
task_type: research
e2e_required: no
research_required: yes
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-05-01
**Project:** TAD Framework
**Task ID:** TASK-20260501-001
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260427-codex-cli-adaptation.md (Phase 0/3)

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-05-01 (pending expert review)

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 6-test matrix fully defined in Epic |
| Components Specified | ✅ | Each test has pass/fail criteria |
| Functions Verified | ✅ | Codex CLI v0.125.0 confirmed installed |
| Data Flow Mapped | ✅ | Test inputs → Codex → evidence artifacts |

**Gate 2 结果**: ✅ PASS (expert review complete, all P0 resolved)

---

## 📋 Handoff Checklist (Blake必读)

Blake在开始实现前，请确认：
- [ ] 阅读了所有章节
- [ ] **阅读了「📚 Project Knowledge」章节中的历史教训**
- [ ] 理解了 6 个测试的具体 PASS/FAIL 标准
- [ ] 确认 Codex CLI 可用 (`codex --version` → 0.125.0)
- [ ] 理解 4 小时时间盒（从本 handoff 开始执行时计时）

---

## 1. Task Overview

### 1.1 What We're Building
Codex CLI 全 TAD 可行性 Spike — 用 6 个测试验证 Codex 能否承担完整 TAD 工作流（Blake 模式 3 测试 + Alex 模式 3 测试），产出 SPIKE-REPORT.md 和 pivot 决策。

### 1.2 Why We're Building It
**业务价值**：Claude Code 周限额是硬顶，用户重度使用必然撞顶，撞顶后 1-3 天无法推进工作
**用户受益**：Codex 作为备用执行通道，限额撞顶时无缝切换继续
**成功的样子**：当 ≥4/6 测试 PASS 时，证明 Codex 可行，Epic 继续 Phase 1

### 1.3 Intent Statement

**真正要解决的问题**：验证 "Codex CLI 能否运行 TAD 核心流程"——不是构建适配层，只是测试可行性。

**不是要做的（避免误解）**：
- ❌ 不是构建 Codex adapter 代码（那是 Phase 1）
- ❌ 不是让 Codex 完美对等 Claude Code（接受机制差异）
- ❌ 不是自动化 spike——手动逐项执行 6 个测试

---

## 📚 Project Knowledge（Blake 必读）

### 步骤 1：识别相关类别
- [x] architecture - Spike 方法论 + 平台机制验证

### 步骤 2：历史经验摘录

| 文件 | 相关记录数 | 关键提醒 |
|------|-----------|----------|
| architecture.md | 3 条 | Spike 方法论 + 平台差异 + 时间盒纪律 |

**⚠️ Blake 必须注意的历史教训**：

1. **Spike-Driven Epic De-Risking with Light TAD** (来自 architecture.md, 2026-04-07)
   - 要点：spike 便宜才能快速失败；Pivot threshold 写进 AC；两轴 verdict（integration / accuracy）而非单一 GO/NO-GO
   - 应用：本 spike 6 测试分 Blake-axis (P0.2-P0.4) 和 Alex-axis (P0.5-P0.7)，各自可以独立 GO/NO-GO

2. **Claude Code Native Mechanism Validation** (来自 architecture.md, 2026-03-31)
   - 要点：source code reading ≠ runtime behavior；必须实际测试机制
   - 应用：Codex CLI 文档说支持的不等于实际能用的——每个测试都是对"文档声称"的实际验证

3. **Epic Architecture Pivot Through Successive Spikes** (来自 architecture.md, 2026-04-07)
   - 要点：plan for 2-3 architectural pivots as default；favor simpler architectures after mechanism surprises
   - 应用：如 ≤3/6 PASS，这不是"失败"而是"数据"——归档教训，不追沉没成本

---

## 2. Background Context

### 2.1 Previous Work
- v2.3 (2026-02-17): 删除了 Codex/Gemini 完整 runtime（过度追求机制对等 → 维护负担 → 放弃）
- v2.8.5 (current): TAD 模板/hook 脚本/Domain Pack 已成熟独立化，移植成本下降

### 2.2 Current State
- Codex CLI v0.125.0 已安装
- Epic 已创建，Phase 0 尚未启动
- 9 项 Socratic-phase 决策已记录在 Epic "Decisions Made So Far"

### 2.3 Dependencies
- Codex CLI 已安装并可正常 auth
- `.tad/archive/handoffs/HANDOFF-20260427-tad-cleanup-linear-and-hook.md` 存在（Blake-1/2 测试材料）
- `.tad/active/ideas/IDEA-20260403-hook-timeout-config.md` 存在（Alex-2 测试输入）

---

## 3. Requirements

### 3.1 Functional Requirements
- FR1: 执行 6 个测试（P0.2–P0.7），每个测试产出明确的 PASS/FAIL 判定
- FR2: 产出 SPIKE-REPORT.md 包含所有测试结果 + pivot 决策
- FR3: 遵守 4 小时时间盒硬上限

### 3.2 Non-Functional Requirements
- NFR1: 每个测试的 evidence 保存到 `.tad/evidence/spikes/SPIKE-20260501-codex-cli-feasibility/`
- NFR2: 测试记录要足够详细，Phase 1 能据此决定 adapter 设计

---

## 4. Technical Design

### 4.1 Test Matrix

```
┌──────────────────────────────────────────────────────────────┐
│  Test ID  │ Mode   │ What                                    │
├───────────┼────────┼─────────────────────────────────────────┤
│  P0.2     │ Blake  │ Paraphrase a real handoff               │
│  P0.3     │ Blake  │ Edit 1 file + run audit script          │
│  P0.4     │ Blake  │ Generate completion report               │
│  P0.5     │ Alex   │ Socratic-equivalent dialog              │
│  P0.6     │ Alex   │ Draft a handoff from idea               │
│  P0.7     │ Alex   │ Run sub-agent review (or manual equiv)  │
└──────────────────────────────────────────────────────────────┘
```

### 4.2 Execution Order
1. P0.1-pre: Pre-flight mechanism probe (unscored, 5 min)
2. P0.2 → P0.3 → P0.4 (Blake tests, sequential, **MUST be same Codex session** — context retention is under test)
3. P0.5 → P0.6 → P0.7 (Alex tests, sequential, new session OK — Alex tests are independent)
4. SPIKE-REPORT.md (write-up)

---

## 5. Not In Scope (明确不做)
- ❌ Codex adapter 代码编写（Phase 1）
- ❌ Gemini 测试（scope out per Epic decision）
- ❌ Codex MCP 集成测试（风险接受，Phase 1 需要再补）
- ❌ 自动化测试脚本（手动执行即可）

---

## 6. Implementation Steps

### Task P0.1-pre: Pre-Flight Mechanism Probe (5 min, unscored)

**目标**: 验证 Codex 基础文件访问能力，确定可用的调用模式

**执行步骤**:
1. 从 TAD 项目根目录启动 Codex:
   ```bash
   cd "/Users/sheldonzhao/01-on progress programs/TAD"
   codex --full-auto -c model="o4-mini" "Read ./CLAUDE.md and tell me the first heading"
   ```
2. 如果成功 → 记录 "mechanism: file access OK in interactive mode"
3. 如果失败 → 尝试 `codex exec -m o4-mini "Read ./CLAUDE.md and tell me the first heading"`
4. 记录哪种模式可用 + 准确的调用命令

**输出**: `evidence/P0.1-pre-invocation-pattern.md` — 包含:
- 验证可用的 Codex 调用命令（后续测试统一使用此命令）
- 文件访问是否正常
- 如文件访问失败 → 是 MECHANISM FAILURE（不是 Codex 理解能力问题），spike 仍可继续但需改为 paste 文件内容方式

**Codex CLI 已验证的正确语法**:
- 交互模式 (多轮): `codex --full-auto -c model="o4-mini"`
- 非交互模式 (单次): `codex exec -m o4-mini "prompt"`
- 工作目录: 必须从 TAD 项目根启动 (或用 `-C "/Users/sheldonzhao/01-on progress programs/TAD"`)
- 指令注入: `cat file.md | codex --full-auto "based on the instructions above, do X"` (stdin pipe)
- 已存储的 Blake prompt: `~/.codex/prompts/tad_blake.md` (可用)

---

### Task P0.2: Blake-1 — Handoff Paraphrase Test

**目标**: 让 Codex 读取一个真实 handoff，验证其理解能力

**执行步骤**:
1. 从 TAD 项目根启动 Codex session，注入 Blake SKILL 作为指令:
   ```bash
   cat .claude/skills/blake/SKILL.md | codex --full-auto -c model="o4-mini" \
     "Based on the instructions piped above, you are Blake. Read .tad/archive/handoffs/HANDOFF-20260427-tad-cleanup-linear-and-hook.md and summarize: (a) how many files to modify, (b) what's the main change, (c) what are the acceptance criteria"
   ```
   如果 stdin pipe 方式失败，备选方法:
   ```bash
   codex --full-auto -c model="o4-mini" \
     "Read ~/.codex/prompts/tad_blake.md as your instructions, then read .tad/archive/handoffs/HANDOFF-20260427-tad-cleanup-linear-and-hook.md and summarize: (a) files count, (b) main change, (c) acceptance criteria"
   ```
2. 记录 Codex 输出 + 使用的调用命令

**PASS 标准**: Codex 准确说出 ≥3/4 of: 文件数量、主要变更内容、关键 AC、优先级
**FAIL 标准**: 无法读取文件 OR 回答明显错误（文件数偏差 >50%，主题方向错误）

**Evidence**: 保存 Codex session 输出到 `evidence/P0.2-blake-paraphrase.md`

---

### Task P0.3: Blake-2 — File Edit + Script Run Test

**目标**: 验证 Codex 能执行 TAD 常规操作（编辑文件 + 运行 shell 脚本）

**⚠️ 此测试考察两项独立能力**: (a) 文件创建/编辑, (b) shell 脚本执行 + 输出解读。两项都 PASS 才算测试 PASS。如果只有一项成功，记录为 Key Discovery（"Codex can {X} but not {Y}"）并整体判 FAIL。

**执行步骤**:
1. **必须在 P0.2 同一 session 中继续**（测试 context retention across tasks）
2. 给 Codex 任务 (a): "Create directory `.tad/evidence/spikes/SPIKE-20260501-codex-cli-feasibility/` if it doesn't exist, then create file `codex-test-edit.md` inside it with heading '# Codex Edit Test' and a line 'Created by Codex CLI on 2026-05-01.'"
3. 给 Codex 任务 (b): "Run `bash .tad/hooks/lib/layer2-audit.sh compact-recovery` and explain what the exit code means in the context of TAD's Layer 2 expert review system"
   - 预期: 脚本会检查 `.tad/evidence/reviews/blake/compact-recovery/` 下的 reviewer 文件。exit code 含义: 0=通过, 1=缺失, 2=slug 无效。Codex 不需要知道这些——看它能否从输出推断。

**PASS 标准**: (a) 文件创建成功且内容正确 AND (b) 脚本运行且 Codex 对 exit code 解释方向合理（不需要完美，但方向对即可）
**FAIL 标准**: (a) 或 (b) 任一不可用（记录哪一个失败）

**Evidence**: 保存到 `evidence/P0.3-blake-edit-and-script.md`（明确标注 (a) 和 (b) 各自结果）

---

### Task P0.4: Blake-3 — Completion Report Generation Test

**目标**: 验证 Codex 能按模板生成结构化文档 + 测试跨任务 context retention

**⚠️ Session 要求**: P0.4 **必须**在 P0.2/P0.3 同一 session 中执行（不得新开 session）。这是刻意的——如果 Codex 在同一 session 中丢失了 P0.2/P0.3 的上下文，本身就是一个 Key Discovery（context window limitation）。

**执行步骤**:
1. 在同一 session 中给 Codex 任务: "Read `.tad/templates/completion-report.md`. Based on the test results from P0.2 (handoff paraphrase) and P0.3 (file edit + script run) that we just did, generate a mock completion report for a hypothetical 'codex-spike-test' handoff. Fill all template sections."
2. 比对输出与模板结构
3. 额外观察: Codex 是否记得 P0.2/P0.3 的结果？如果它编造了结果（而非引用实际执行的内容），记录为 context retention 问题。

**PASS 标准**: ≥80% 模板字段对齐（section headers present, Evidence Checklist structure followed, Knowledge Assessment section exists）AND 引用的 P0.2/P0.3 结果与实际一致
**FAIL 标准**: <50% 模板对齐 OR 关键 section 缺失 OR 完全编造了不存在的测试结果

**Evidence**: 保存 Codex 生成的 completion report 到 `evidence/P0.4-blake-completion-report.md`

---

### Task P0.5: Alex-1 — Socratic Dialog Test

**目标**: 验证 Codex 能在多轮对话中做需求澄清

**Codex 多轮对话机制**:
- **交互模式** (`codex --full-auto -c model="o4-mini"`): 启动后进入 TUI，支持多轮交互
- 如果交互模式不支持真正的多轮 → 备选: 手动链式调用 `codex exec` 多次，每次带上上轮 context

**"澄清轮"定义**: Codex 主动提出一个问题或假设，等待（或请求）用户输入后再继续。如果 Codex 单次输出中包含 ≥3 个编号问题且暂停等待回答，也算达标。

**执行步骤**:
1. **新 Codex session**（Alex 测试与 Blake 测试独立），注入 Alex SKILL 核心部分:
   ```bash
   cat .claude/skills/alex/SKILL.md | head -200 | codex --full-auto -c model="o4-mini" \
     "Based on the instructions above, you are Alex (Solution Lead). A user says: '我想给 TAD hooks 加一个超时配置，让 hook 脚本不会无限等待'. Perform Socratic inquiry: ask 3-5 clarifying questions before designing anything."
   ```
2. 观察 Codex 是否进行澄清（自由对话形式，不需要 AskUserQuestion 结构化）
3. 如果 Codex 一次性输出了多个问题（非交互式）:
   - 回答这些问题，观察 Codex 是否基于回答进一步追问
   - 如果可以追问 → 算"多轮"
   - 如果回答后直接给方案 → 仍可能 PASS（见下）
4. 最后要求: "Now summarize the requirements based on our discussion"

**PASS 标准** (任一满足):
- 强 PASS: 3+ 轮真正交互式澄清 + 最终总结涵盖问题定义、边界、验收标准
- 弱 PASS: 单次输出 ≥3 个结构化澄清问题 + 回答后产出涵盖三要素的需求总结（多轮能力弱但 Socratic 意图理解正确）
**FAIL 标准**: 直接跳到方案不做任何澄清 OR 无法理解"Socratic inquiry"指令含义 OR 需求总结缺失三要素中 ≥2 个

**Evidence**: 保存完整对话记录到 `evidence/P0.5-alex-socratic.md`（标注是强 PASS 还是弱 PASS）

---

### Task P0.6: Alex-2 — Handoff Draft Test

**目标**: 验证 Codex 能按 handoff 模板起草文档

**执行步骤**:
1. 基于 P0.5 的需求澄清结果
2. 给 Codex: "Now read `.tad/templates/handoff-a-to-b.md` and draft a handoff for the hook timeout feature. Fill all sections."
3. 比对输出与模板结构

**PASS 标准**: 模板结构正确 + 关键字段填充（Task Overview, Requirements, Implementation Steps, Acceptance Criteria）
**FAIL 标准**: 模板结构严重偏差 OR 关键 section 完全空白

**Evidence**: 保存到 `evidence/P0.6-alex-handoff-draft.md`

---

### Task P0.7: Alex-3 — Sub-Agent Review Test

**目标**: 验证 Codex 能调用子 agent 做评审（或手动顺序模拟可接受）

**执行步骤**:
1. 尝试方法 A: 让 Codex 调用 sub-agent 做 code review
   - 指令: "Review the handoff draft you just created. Act as a code-reviewer expert and identify P0/P1/P2 issues."
2. 如方法 A 不可行（Codex 没有 Agent tool），尝试方法 B:
   - 新开 Codex session，paste P0.6 的 handoff 草稿
   - 给 system prompt 角色: "You are a senior code reviewer. Review this handoff for completeness and issues."
   - 再开另一个 session 给 backend-architect 角色做第二轮 review
3. 记录哪种方法可行

**PASS 标准**: 至少一种方法可行 + review 输出有结构（P0/P1/P2 分类 或 等效质量反馈）
**FAIL 标准**: 两种方法都不可行 OR review 输出质量太低（只有 "looks good" 级别）

**Evidence**: 保存到 `evidence/P0.7-alex-sub-agent-review.md`

---

### Task P0.8: SPIKE-REPORT.md

**执行步骤**:
1. 创建 `.tad/evidence/spikes/SPIKE-20260501-codex-cli-feasibility/SPIKE-REPORT.md`
2. 填写 6 测试结果表
3. 写 pivot 决策

**模板**:
```markdown
# SPIKE-REPORT: Codex CLI TAD Feasibility
Date: 2026-05-01
Epic: EPIC-20260427-codex-cli-adaptation (Phase 0)
Codex Version: 0.125.0
Time Budget: 4h | Actual: {actual_time}

## Test Results

| Test | Mode | Result | Key Finding |
|------|------|--------|-------------|
| P0.2 | Blake | PASS/FAIL | {finding} |
| P0.3 | Blake | PASS/FAIL | {finding} |
| P0.4 | Blake | PASS/FAIL | {finding} |
| P0.5 | Alex  | PASS/FAIL | {finding} |
| P0.6 | Alex  | PASS/FAIL | {finding} |
| P0.7 | Alex  | PASS/FAIL | {finding} |

Score: {N}/6

## Blake-Axis Verdict
{Blake 3 tests summary: GO / PARTIAL / NO-GO}

## Alex-Axis Verdict
{Alex 3 tests summary: GO / PARTIAL / NO-GO}

## Pivot Decision (Two-Dimensional)

**Primary rule** (both axes must meet threshold):
- CONTINUE → Blake-axis ≥2/3 PASS **AND** Alex-axis ≥2/3 PASS
- STOP → Either axis <2/3 PASS AND no partial path viable
- PARTIAL → One axis GO, other axis NO-GO → **user decides** (e.g., "Phase 1 Blake-only")

**Aggregate 4/6 is informational only** — a 4/6 where all 3 Alex tests fail is NOT a valid CONTINUE.

| Blake-Axis | Alex-Axis | Decision |
|------------|-----------|----------|
| ≥2/3 | ≥2/3 | CONTINUE |
| ≥2/3 | <2/3 | PARTIAL — user decides Blake-only Phase 1? |
| <2/3 | ≥2/3 | PARTIAL — unlikely but user decides |
| <2/3 | <2/3 | STOP |

**Decision**: {CONTINUE / STOP / PARTIAL — with user justification}

## Key Discoveries
1. {discovery}
2. {discovery}

## Recommendations for Phase 1 (if CONTINUE)
- {recommendation}
```

---

## 7. Files to Create

| File | Purpose |
|------|---------|
| `.tad/evidence/spikes/SPIKE-20260501-codex-cli-feasibility/` | Evidence directory |
| `evidence/P0.2-blake-paraphrase.md` | Blake handoff paraphrase test |
| `evidence/P0.3-blake-edit-and-script.md` | Blake file edit + script test |
| `evidence/P0.4-blake-completion-report.md` | Blake completion report test |
| `evidence/P0.5-alex-socratic.md` | Alex Socratic dialog test |
| `evidence/P0.6-alex-handoff-draft.md` | Alex handoff draft test |
| `evidence/P0.7-alex-sub-agent-review.md` | Alex sub-agent review test |
| `evidence/SPIKE-REPORT.md` | Final spike report with pivot decision |

All paths above are relative to `.tad/evidence/spikes/SPIKE-20260501-codex-cli-feasibility/`.

**Completion report (absolute path, NOT relative to evidence dir)**:
| `.tad/active/handoffs/COMPLETION-20260501-codex-spike-phase0.md` | Blake completion report (TAD convention) |

**Grounded Against** (Alex step1c):
- `.tad/archive/handoffs/HANDOFF-20260427-tad-cleanup-linear-and-hook.md` (head 50, confirmed exists for Blake-1/2)
- `.tad/active/ideas/IDEA-20260403-hook-timeout-config.md` (full read, confirmed small scope for Alex-2)
- `.tad/templates/completion-report.md` (template for P0.4 test)
- Codex CLI: `codex --version` → 0.125.0 confirmed

---

## 8. Testing Checklist

- [ ] Each of 6 tests has clear PASS/FAIL recorded
- [ ] Evidence files saved for all 6 tests
- [ ] SPIKE-REPORT.md contains pivot decision
- [ ] Time box respected (4h from start)

---

## 9. Acceptance Criteria

| AC# | Requirement | Verification |
|-----|-------------|-------------|
| AC1 | Evidence directory created | `ls .tad/evidence/spikes/SPIKE-20260501-codex-cli-feasibility/` returns ≥7 files |
| AC2 | All 6 tests executed | SPIKE-REPORT.md test results table has 6 rows, each PASS or FAIL |
| AC3 | Pivot decision documented | SPIKE-REPORT.md "Pivot Decision" section has explicit CONTINUE/STOP/PARTIAL |
| AC4 | Time box respected | SPIKE-REPORT.md "Actual" time ≤ 4h |
| AC5 | Blake-axis verdict present | SPIKE-REPORT.md has "Blake-Axis Verdict" with GO/PARTIAL/NO-GO |
| AC6 | Alex-axis verdict present | SPIKE-REPORT.md has "Alex-Axis Verdict" with GO/PARTIAL/NO-GO |
| AC7 | Key discoveries recorded | SPIKE-REPORT.md "Key Discoveries" has ≥1 entry |
| AC8 | Completion report written | COMPLETION-20260501-codex-spike-phase0.md exists |

### 9.1 Spec Compliance Checklist

| AC# | Verification Method | Expected Evidence | Verified Output (Alex step1d) |
|-----|--------------------|--------------------|-------------------------------|
| AC1 | `ls .tad/evidence/spikes/SPIKE-20260501-codex-cli-feasibility/ \| wc -l` | ≥7 | (post-impl — Blake runs at Gate 3 v2 Layer 1) |
| AC2 | `grep -c 'PASS\|FAIL' .tad/evidence/spikes/SPIKE-20260501-codex-cli-feasibility/SPIKE-REPORT.md` | ≥6 | (post-impl — Blake runs at Gate 3 v2 Layer 1) |
| AC3 | `grep -c 'CONTINUE\|STOP\|PARTIAL' .tad/evidence/spikes/SPIKE-20260501-codex-cli-feasibility/SPIKE-REPORT.md` | ≥1 | (post-impl — syntax-validated: grep -c with alternation is valid POSIX) |
| AC4 | Manual: read "Actual" field in SPIKE-REPORT.md | ≤ 4h | (post-impl) |
| AC5 | `grep -c 'Blake-Axis Verdict' .tad/evidence/spikes/SPIKE-20260501-codex-cli-feasibility/SPIKE-REPORT.md` | 1 | (post-impl — syntax-validated) |
| AC6 | `grep -c 'Alex-Axis Verdict' .tad/evidence/spikes/SPIKE-20260501-codex-cli-feasibility/SPIKE-REPORT.md` | 1 | (post-impl — syntax-validated) |
| AC7 | `grep -c 'Key Discoveries' .tad/evidence/spikes/SPIKE-20260501-codex-cli-feasibility/SPIKE-REPORT.md` | 1 | (post-impl — syntax-validated) |
| AC8 | `test -f .tad/active/handoffs/COMPLETION-20260501-codex-spike-phase0.md && echo exists` | exists | (post-impl) |

**AC Dry-Run Log** (Alex step1d at 2026-05-01):
- AC1-AC8: ✅ post-impl-verifiable, all verification commands syntax-validated (grep -c with `\|` alternation is POSIX-compatible, no `-P` flag), deferred to Gate 3

### 9.2 Expert Review Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | CR-P0-1: Codex CLI invocation syntax vague | §6 P0.1-pre + P0.2 step1 (exact commands documented) | Resolved |
| code-reviewer | CR-P0-2: No pre-flight mechanism check | §6 Task P0.1-pre added | Resolved |
| code-reviewer | CR-P0-3: P0.5 PASS/FAIL criteria subjective | §6 P0.5 (multi-turn definition + strong/weak PASS) | Resolved |
| code-reviewer | CR-P0-4: Completion report path inconsistency | §7 (explicit absolute path, separated from relative) | Resolved |
| backend-architect | BA-P0-1: P0.3 conflates two capabilities | §6 P0.3 (explicit dual-capability scoring note) | Resolved |
| backend-architect | BA-P0-2: 4/6 threshold axis-blind | §6 P0.8 SPIKE-REPORT template (two-dimensional pivot) | Resolved |
| backend-architect | BA-P0-3: P0.4 session dependency unclear | §6 P0.4 + §4.2 + §10.2 (same-session mandate) | Resolved |
| code-reviewer | P1-1: AC2 grep overly permissive | Acknowledged — Blake uses table-row-specific grep | Open (P1) |
| backend-architect | P1-1: No multi-file coordinated edit test | Acknowledged — P0.3 partially covers; Phase 1 spike if needed | Open (P1) |
| backend-architect | P1-3: Time box 4h tight | §10.1 already has 3.5h STOP rule; acceptable for spike | Deferred |

---

## 10. Important Notes

### 10.1 Time Box Discipline
- 4h starts when Blake begins executing P0.2
- If hitting 3.5h and not done: STOP current test, write SPIKE-REPORT with what you have
- Incomplete tests count as FAIL for pivot threshold calculation

### 10.2 Codex Session Management
- **Blake tests (P0.2-P0.4): MUST use same session** (context retention is under test)
- **Alex tests (P0.5-P0.7): MAY use separate sessions** (each tests an independent capability)
- **Always launch from TAD project root**: `cd "/Users/sheldonzhao/01-on progress programs/TAD"`
- Record the exact Codex invocation command used for each test
- If Codex errors out, record the error as part of evidence (errors are data)

### 10.3 v2.3 Lesson Reminder
- v2.3 tried to make Codex = Claude Code → failed due to mechanism gap
- This spike accepts mechanism differences: no AskUserQuestion, no Agent tool, no hooks
- PASS means "usable with workarounds", not "identical to Claude Code"

---

## 11. Decision Summary

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | Alex-2 test material | Fake requirement / Existing idea / Free choice | IDEA-20260403-hook-timeout-config | Small scope, well-defined, real project relevance |
| 2 | Time box start | From handoff receipt / Including install / Flexible | From Blake execution start | Codex already installed; design time shouldn't count against spike budget |

---

## Required Evidence Manifest

```yaml
required_evidence:
  expert_reviews:
    - .tad/evidence/reviews/blake/codex-spike-phase0/code-reviewer.md
  gate_verdicts:
    - .tad/evidence/spikes/SPIKE-20260501-codex-cli-feasibility/SPIKE-REPORT.md
  completion:
    - .tad/active/handoffs/COMPLETION-20260501-codex-spike-phase0.md
  blake_reviews:
    - .tad/evidence/reviews/blake/codex-spike-phase0/self-review.md
  knowledge_updates:
    - .tad/project-knowledge/architecture.md (if discoveries warrant)
```
