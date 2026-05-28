---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs:
  - .tad/capability-packs/video-creation
  - .claude/skills/video-creation
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: Capability Pack Behavioral Examples Framework + Video-Creation Dogfood

**From:** Alex (Solution Lead)
**To:** Blake (Execution Master)
**Date:** 2026-05-27
**Project:** TAD framework — Capability Pack quality infrastructure
**Task ID:** TASK-20260527-002
**Handoff Version:** 1.0
**Epic:** N/A
**Supersedes:** N/A

---

## 🟢 Gate 2: Design Completeness — PASS

**Executed**: 2026-05-27 23:15

| Check | Status | Detail |
|-------|--------|--------|
| Architecture Complete | ✅ | Fixture format spec (§4) + directory convention + install.sh integration |
| Components Specified | ✅ | 6 files mapped, 2 fixtures + 1 template + 1 install.sh modification |
| Functions Verified | ✅ | install.sh read (lines 128-160), existing fixture read, directory structure confirmed |
| Data Flow Mapped | ✅ | §5 cross-references: fixture → AC → subagent → grep → marker count |
| Expert Review | ✅ | code-reviewer + product-expert both CONDITIONAL PASS; 3 P0 + 4 P1 resolved (§9.2) |
| ACs Verifiable | ✅ | 13 ACs with verification commands, all syntax-validated |

**Gate 2 result**: ✅ PASS — Blake can implement independently.

---

## 📋 Handoff Checklist (Blake 必读)

- [ ] 理解 fixture 格式（单文件 .md，含 input scenario + expected markers + grep 验证命令）
- [ ] 理解 install.sh 需要同步 examples/ 目录（与 references/ 同级）
- [ ] 理解 video-creation dogfood 是验证整个 fixture 机制能跑通的证据
- [ ] 理解不改 Ralph Loop — fixture 通过 handoff AC 执行，不嵌入 Blake SKILL

---

## 1. Task Overview

### 1.1 What We're Building

为 Capability Pack 体系增加 `examples/` 目录规范 + fixture 文件格式，让每个 pack 可以用 behavioral evidence 验证自己的规则是否生效。然后用 video-creation pack 做第一个 dogfood — 把 ViMax 升级时手动做的 pre/post 对比固化成 pack 标准 fixture。

### 1.2 Why We're Building It

**已被证实的痛点**：
1. ViMax 升级中 product-expert 在 Gate 2 标为 P0："没有 baseline 你怎么证明 improvement？"
2. YOLO audit（Codex + Gemini 独立评审）："structural checks prove files exist, not that the pack improves agent behavior"
3. html-anything 的 `example.html` 模式证明：skill 自带 ground truth 是可行的

**成功的样子**：未来任何 pack 修改的 handoff，Alex 可以写一条 AC："跑 examples/photo-to-beat-sync.md fixture，marker count ≥ 4"。Blake 用 subagent 跑 input，grep markers，出数字。不再需要每次临时发明 pre/post 对比流程。

### 1.3 Intent Statement

**真正要解决的问题**：pack 修改后缺乏 behavioral validation 手段。结构性检查（grep 文件存在、行数、frontmatter）证明文件正确，不证明规则生效。

**不是要做的**：
- ❌ 不是给 13 个现有 pack 全部回填 example（只做 video-creation dogfood）
- ❌ 不是改 Ralph Loop 或 Blake SKILL（fixture 通过 handoff AC 执行）
- ❌ 不是做 LLM-as-judge 评估系统（用 marker grep，确定性验证）
- ❌ 不是做 pack 自动测试 CI（手动 AC 触发，不是 automated pipeline）

---

## 2. 📚 Project Knowledge（Blake 必读历史教训）

1. **YOLO Epic Execution: Cross-Model Audit Findings - 2026-05-15** (architecture.md)
   - 影响本任务："Validation Theater — structural checks prove files exist correctly but do NOT prove the pack improves agent behavior"。本 handoff 正是解决这个 finding 的第一步。

2. **Capability Pack Quality Bar: Anti-Slop Metrics - 2026-05-15** (architecture.md)
   - 影响本任务：fixture 的 expected markers 必须是 pack-specific 的（不能用任何 AI 都会输出的通用词）。Anti-slop 标准同样适用于 fixture marker 设计。

3. **Capability Pack: Architecture Spectrum - 2026-05-08** (architecture.md)
   - 影响本任务：video-creation 是 reference-based pack。fixture 测试的是 reference 规则是否被 agent 应用，不是代码是否执行。

4. **Capability Pack: Design and Build Rules - 2026-05-07** (architecture.md)
   - 影响本任务："Research findings = what to COVER, not what to SAY"。Fixture markers 应检测 pack 规则是否被引用，不是规则的字面复制。

---

## 3. 🔧 Pack References

无 — 本任务是 pack 基础设施，不涉及特定领域 pack 能力。

---

## 4. Fixture 格式规范

### 4.1 目录结构

```
.tad/capability-packs/{pack-name}/
├── CAPABILITY.md
├── install.sh
├── references/
│   ├── storytelling.md
│   └── ...
└── examples/                    ← NEW
    └── {scenario-slug}.md       ← fixture file
```

安装后镜像到 `.claude/skills/{pack-name}/examples/`。

### 4.2 Fixture 文件格式

```markdown
---
name: {scenario-slug}
description: "{one-line: what this fixture tests}"
pack: {pack-name}
tests_rules:
  - "{Quick Rule Index entry name 1}"
  - "{Quick Rule Index entry name 2}"
min_marker_count: {N}
---

# Fixture: {Scenario Title}

## Input Scenario

"{User task description — exactly what a user would say to trigger this pack}"

## Expected Markers

When an AI agent processes the Input Scenario using this pack, the output MUST
contain these markers (grep-verifiable keywords/phrases):

1. **{Marker name}**: {description of what to look for}
   grep pattern: `{regex}`
2. **{Marker name}**: {description}
   grep pattern: `{regex}`
...

## Verification Command

```bash
grep -ocE '{pattern1}|{pattern2}|...' {output_file} | sort -u | wc -l | tr -d ' '
# Expected: ≥ {min_marker_count}
```

## Anti-Slop Check

These markers MUST NOT be generic (any AI would output them without the pack):
- ✅ "first_frame" (pack-specific decomposition concept)
- ❌ "video" (too generic, any video task mentions this)
```

### 4.3 Fixture 设计规则

1. **Markers 必须来自 pack 规则**：每个 marker 对应 SKILL.md Quick Rule Index 的一条规则
2. **Anti-slop**：如果一个 marker 在没有 pack 的情况下也会出现，它不是有效 marker
3. **min_marker_count ≥ 3**：至少 3 个 pack-specific markers 才构成有效 behavioral evidence
4. **≥1 structural marker**：至少 1 个 marker 必须验证输出结构（如 "per-photo table with first_frame/last_frame columns"），而非仅验证词汇出现。Structural marker 区分「agent 应用了规则」vs「agent 只是提到了规则名称」。在 Expected Markers 列表中用 `[structural]` 标注
5. **Input Scenario 必须是用户会说的话**：不是技术描述，是自然语言任务
6. **何时必须添加 fixture**：新 pack 或新 capability 添加到 pack 时，MUST 至少有 1 个 fixture。修改现有规则时，SHOULD 更新 fixture markers（如果 Quick Rule Index 名变了，tests_rules 必须同步更新）

---

## 5. Cross-References

| 现有机制 | 关联方式 |
|---------|---------|
| ViMax fixture (photo-to-beat-sync-fixture.md) | 本规范是对 ViMax fixture 的泛化 — 格式一致但加了 frontmatter + anti-slop check |
| Blake AC verification | Fixture 通过 handoff AC 执行 — Alex 写 AC "跑 fixture X, marker ≥ N"，Blake 按 AC 做 |
| install.sh | 需要修改：增加 examples/ 目录复制逻辑 |
| YOLO audit recommendation | 本 handoff 实现 "mandatory behavioral eval per pack" 的 MVP |

---

## 6. Files to Modify / Create

| # | 文件 | 操作 | 行数预算 | 备注 |
|---|------|------|---------|------|
| 1 | `.tad/capability-packs/video-creation/examples/photo-to-beat-sync.md` | CREATE | ≤ 60 | 从 ViMax fixture 改造为标准格式（montage 场景，4 pattern 全触发） |
| 2 | `.tad/capability-packs/video-creation/examples/single-clip-narration.md` | CREATE | ≤ 50 | 第二个 fixture — 简单单镜头叙事场景（只触发 Pattern 1+2，不触发 3+4）|
| 3 | `.claude/skills/video-creation/examples/photo-to-beat-sync.md` | CREATE | ≤ 60 | 与文件 1 byte-identical |
| 4 | `.claude/skills/video-creation/examples/single-clip-narration.md` | CREATE | ≤ 50 | 与文件 2 byte-identical |
| 5 | `.tad/capability-packs/video-creation/install.sh` | MODIFY | +8 行 | 增加 examples/ 目录复制逻辑 + 空目录诊断 |
| 6 | `.tad/templates/pack-example-fixture.md` | CREATE | ≤ 40 | Fixture 文件模板（未来 pack 用） |

**Grounded Against** (Alex step1c 实际 Read 过的源文件):
- `.tad/capability-packs/video-creation/install.sh` (lines 128-160, read at 2026-05-27 22:45)
- `.tad/evidence/handoffs/HANDOFF-20260527-vimax-pattern-upgrade-video-creation/photo-to-beat-sync-fixture.md` (head 20, read at 2026-05-27 22:45)
- `.tad/capability-packs/video-creation/` directory listing (read at 2026-05-27 22:45)

---

## 7. Implementation Steps

### Step 1: 创建 fixture 模板

创建 `.tad/templates/pack-example-fixture.md`，内容参照 §4.2 格式规范。这是未来所有 pack fixture 的基础模板。

### Step 2: 创建 video-creation dogfood fixtures（2 个）

**Fixture A: photo-to-beat-sync.md**（montage 场景，4 pattern 全触发）

基于现有 ViMax fixture 改造成标准格式：
- 添加 YAML frontmatter（name, description, pack, tests_rules, min_marker_count: 4）
- 保持 Input Scenario（"3 张人像照片做 6 秒卡点视频"）
- markers 含 ≥1 structural marker（如 "per-photo decomposition table with first_frame/last_frame" — 标注 `[structural]`）
- 添加 Anti-Slop Check + Verification Command
- 放到 `.tad/capability-packs/video-creation/examples/photo-to-beat-sync.md`

**Fixture B: single-clip-narration.md**（简单场景，只触发 Pattern 1+2）

用于验证 fixture 格式在不同场景下的判别力：
- Input: "我有一段 30 秒的产品演示画面，需要加旁白和字幕"
- Expected: Pattern 2 触发（narrative 意图），Pattern 1 部分触发（如果涉及 AI 生成）
- NOT expected: Pattern 3（无多角度角色）、Pattern 4（单镜头无 scene 切换）
- min_marker_count: 3
- 放到 `.tad/capability-packs/video-creation/examples/single-clip-narration.md`

两个 fixture 验证不同的判别能力 — Fixture A 验证"规则全触发"，Fixture B 验证"规则正确不触发"。

### Step 3: 修改 install.sh 增加 examples/ 复制

在 install.sh 的 `install_claude_code()` 函数中，`# Copy all references` 块之后添加 examples/ 复制逻辑：

```bash
# Copy all examples (behavioral eval fixtures)
if [[ -d "${SCRIPT_DIR}/examples" ]]; then
  mkdir -p "${TARGET_DIR}/examples"
  local found_examples=0
  for ex_file in "${SCRIPT_DIR}/examples/"*.md; do
    [[ -f "$ex_file" ]] || continue
    filename="$(basename "$ex_file")"
    cp "$ex_file" "${TARGET_DIR}/examples/${filename}"
    echo "✅  examples/${filename}"
    found_examples=1
  done
  if [[ "$found_examples" -eq 0 ]]; then
    echo "ℹ️   examples/: directory exists but contains no .md files"
  fi
fi
```

注意：用 `if [[ -d ... ]]` 包裹，确保没有 examples/ 的 pack 不报错（向后兼容）。空目录有诊断输出（CR-P0-1 fix）。

### Step 4: 验证 install.sh examples/ 复制逻辑

不要手动 cp — 用修改后的 install.sh 来同步（同时验证 install.sh 修改是否正确）：

```bash
# 重新运行 install.sh 让它自动复制 examples/
bash .tad/capability-packs/video-creation/install.sh --force

# 验证两边 examples/ 一致
diff -rq .tad/capability-packs/video-creation/examples/ \
         .claude/skills/video-creation/examples/
# 应输出为空
```

### Step 5: 跑 dogfood — 验证两个 fixture 机制

**Dogfood A**：用 Task subagent 跑 Fixture A 的 Input Scenario（photo-to-beat-sync），capture output 到 `dogfood-output-A.md`，然后跑 Fixture A 的 Verification Command。验证 4 个 ViMax pattern markers 全出现。

**Dogfood B**：用 Task subagent 跑 Fixture B 的 Input Scenario（single-clip-narration），capture output 到 `dogfood-output-B.md`，然后跑 Fixture B 的 Verification Command。验证 Pattern 1+2 markers 出现，Pattern 3+4 markers 不出现（判别力验证）。

两个 dogfood 证明：fixture 格式可执行 + marker grep 可靠 + 框架能区分不同场景。

### Step 6: Layer 1 自检

- fixture 文件格式符合 §4.2 规范
- install.sh 修改不破坏现有安装流程（`bash install.sh --check` 仍正常）
- 两边 examples/ byte-identical
- fixture frontmatter 完整（5 required fields）

### Step 7: Commit

```
feat(capability-packs): add behavioral examples framework + video-creation dogfood

- New: examples/ directory convention for capability packs
- New: pack-example-fixture.md template for future packs
- New: video-creation/examples/photo-to-beat-sync.md (dogfood fixture)
- Modified: install.sh to copy examples/ alongside references/
- Fixture format: single .md with frontmatter + markers + grep verification
```

---

## 8. Required Evidence Manifest

| Evidence | Path | Format |
|----------|------|--------|
| Fixture A (capability-packs/) | `.tad/capability-packs/video-creation/examples/photo-to-beat-sync.md` | Markdown, ≤ 60 lines |
| Fixture B (capability-packs/) | `.tad/capability-packs/video-creation/examples/single-clip-narration.md` | Markdown, ≤ 50 lines |
| Fixtures (skills/, mirror) | `.claude/skills/video-creation/examples/*.md` | byte-identical to above |
| Template | `.tad/templates/pack-example-fixture.md` | Markdown, ≤ 40 lines |
| install.sh modified | `.tad/capability-packs/video-creation/install.sh` | +examples/ copy + diagnostic |
| Dogfood output A | `.tad/evidence/handoffs/HANDOFF-20260527-pack-behavioral-examples/dogfood-output-A.md` | Subagent response (photo-to-beat-sync) |
| Dogfood output B | `.tad/evidence/handoffs/HANDOFF-20260527-pack-behavioral-examples/dogfood-output-B.md` | Subagent response (single-clip-narration) |
| Completion report | `.tad/active/handoffs/COMPLETION-20260527-pack-behavioral-examples.md` | Standard template |
| Layer 2 reviews | `.tad/evidence/reviews/blake/pack-behavioral-examples/*.md` | Per-reviewer |

---

## 9. Acceptance Criteria

### 9.1 Spec Compliance Checklist

| # | AC | Verification Method | Expected |
|---|----|---------------------|----------|
| AC1 | Fixture A (photo-to-beat-sync) 存在于两个位置 | `test -f .tad/capability-packs/video-creation/examples/photo-to-beat-sync.md && test -f .claude/skills/video-creation/examples/photo-to-beat-sync.md && echo OK` | OK |
| AC2 | Fixture B (single-clip-narration) 存在于两个位置 | `test -f .tad/capability-packs/video-creation/examples/single-clip-narration.md && test -f .claude/skills/video-creation/examples/single-clip-narration.md && echo OK` | OK |
| AC3 | 两边 examples/ 目录内容 byte-identical | `diff -rq .tad/capability-packs/video-creation/examples/ .claude/skills/video-creation/examples/` | (empty) |
| AC4 | Fixture A 有 5 个 frontmatter fields | `head -10 .tad/capability-packs/video-creation/examples/photo-to-beat-sync.md \| grep -cE '^(name\|description\|pack\|tests_rules\|min_marker_count):'` | 5 |
| AC5 | Fixture A min_marker_count ≥ 3 | `awk '/^min_marker_count:/{print $2; exit}' .tad/capability-packs/video-creation/examples/photo-to-beat-sync.md` | ≥ 3 |
| AC6 | Fixture A 有 ≥1 structural marker (标注 `[structural]`) | `grep -c '\[structural\]' .tad/capability-packs/video-creation/examples/photo-to-beat-sync.md` | ≥ 1 |
| AC7 | Fixture A 有 Anti-Slop Check + Verification Command sections | `grep -cE '## Anti-Slop Check\|## Verification Command' .tad/capability-packs/video-creation/examples/photo-to-beat-sync.md` | 2 |
| AC8 | Fixture B min_marker_count ≥ 3 | `awk '/^min_marker_count:/{print $2; exit}' .tad/capability-packs/video-creation/examples/single-clip-narration.md` | ≥ 3 |
| AC9 | install.sh 含 examples 复制逻辑 + 空目录诊断 | `grep -cE 'examples\|found_examples' .tad/capability-packs/video-creation/install.sh` | ≥ 4 |
| AC10 | install.sh --check 仍正常 | `bash .tad/capability-packs/video-creation/install.sh --check 2>&1 \| grep -c 'prerequisites'` | ≥ 1 |
| AC11 | Template 文件存在 | `test -f .tad/templates/pack-example-fixture.md && echo OK` | OK |
| AC12 | Dogfood A: subagent output marker count ≥ fixture A min_marker_count | 跑 Fixture A Verification Command 对 dogfood-output-A.md | ≥ min_marker_count |
| AC13 | Dogfood B: subagent output marker count ≥ fixture B min_marker_count | 跑 Fixture B Verification Command 对 dogfood-output-B.md | ≥ min_marker_count |

### 9.2 Expert Review Status

Reviewers: 2 (code-reviewer + product-expert), both returned CONDITIONAL PASS. All P0 + key P1 integrated.

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | P0-1: install.sh 空 examples/ 目录无诊断输出 | §7 Step 3 — 加 found_examples flag + ℹ️ 诊断行 | Resolved |
| code-reviewer | P1-1: Step 4 和 Step 3 重复（手动 cp vs install.sh） | §7 Step 4 — 改为用 install.sh --force 验证 | Resolved |
| code-reviewer | P1-2: min_marker_count 应与 grep 可检测数量一致 | §7 Step 2 — 明确 min_marker_count: 4 对应 4 个 ViMax pattern signals | Resolved |
| product-expert | P0-1: Marker grep 只证明词存在，不证明行为变化 | §4.3 规则 4 — 新增 ≥1 structural marker 要求 + `[structural]` 标注 + AC6 | Resolved |
| product-expert | P0-2: 单个 fixture 不能验证框架判别力 | §6 文件 2+4, §7 Step 2 Fixture B — 新增 single-clip-narration fixture | Resolved |
| product-expert | P1-1: tests_rules 与 Quick Rule Index 可能不同步 | §4.3 规则 6 — 新增"修改规则时 SHOULD 更新 fixture markers" | Resolved |
| product-expert | P1-2: Blake SKILL 应提及 examples/ 存在 | §10.2 — 加注释说明。不在本 handoff 修改 Blake SKILL（scope 控制），future consideration | Deferred |
| product-expert | P1-3: Anti-slop check 无强制力 | §9.1 AC6 — 新增 structural marker AC 作为强制 | Resolved |
| product-expert | P1-4: 缺"何时添加 fixture"指南 | §4.3 规则 6 — 新增"新 pack/capability MUST 有 ≥1 fixture" | Resolved |
| product-expert | P2-1: 无 output_path convention | Deferred — MVP 用 dogfood-output-{A/B}.md | Deferred |
| product-expert | P2-2: 无 negative fixture concept | Deferred — Fixture B 部分覆盖（不触发 Pattern 3+4） | Deferred |
| code-reviewer | P2-1: AC8 负向检查不如正向断言 | §9.1 AC10 — 改为正向 grep "prerequisites" | Resolved |

---

## 10. Important Notes

### 10.1 向后兼容

install.sh 的 examples/ 复制用 `if [[ -d ... ]]` 包裹。没有 examples/ 的 pack（现有 12 个）不受影响。

### 10.2 不改 Blake SKILL

Fixture 通过 handoff AC 触发（Alex 写 "跑 fixture X, marker ≥ N" 作为 AC），不嵌入 Ralph Loop Layer 1。这是 MVP — 未来如果 fixture 证明有价值，可以考虑自动化。

### 10.3 Anti-Patterns

- ⚠️ 不要用通用词作为 marker（"video"、"animation"、"design" 等 — 没有 pack 也会出现）
- ⚠️ 不要把 fixture 写成测试脚本 — 它是 markdown 文档，grep 是验证手段
- ⚠️ 不要修改现有 ViMax fixture — 那是 ViMax handoff 的 evidence，本 handoff 创建独立的标准格式 fixture

---

## 11. Decision Summary

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | 验证方式 | (a) Marker grep / (b) LLM judge / (c) Exact diff / (d) 混合 | (a) Marker grep | 确定性验证，可复现，不依赖 LLM 判断 |
| 2 | 回填策略 | (a) 全部回填 / (b) 只要求新的 / (c) 挑 3 个核心 | (b) 只要求新的 | 当前 scope 做框架 + 1 dogfood，不做大规模回填 |
| 3 | 执行时机 | (a) 嵌入 Layer 1 / (b) handoff AC / (c) 独立命令 | (b) handoff AC | MVP — 不改 Blake SKILL，通过 AC 驱动 |
| 4 | 文件格式 | (a) 单文件 fixture / (b) input/output 对 / (c) YAML | (a) 单文件 fixture | 与 ViMax fixture 一致，紧凑，自包含 |
| 5 | Dogfood pack | video-creation | — | 刚做完 ViMax 升级，有现成的 fixture 可改造 |

---

## 12. Open Questions for Blake

1. 如果 install.sh 修改后 `--check` 模式报错 → 修复 install.sh，不要跳过
2. 如果 dogfood subagent 的 marker count < min_marker_count → escalate，可能是 SKILL.md 路由问题（不是 fixture 问题）
3. 如果 examples/ 目录在 `*sync` 时没有被自动传播到下游项目 → 这是预期的（tad.sh 只 sync references/），记录在 completion report 中

---

## 13. References

- **html-anything 研究**：notebook `d7022a6e-8de5-4e52-8f7c-1518cd4f6d76` (19 sources)
- **研究发现**：`.tad/evidence/research/html-anything/2026-05-27-deep-ask-findings.md`
- **ViMax fixture 先例**：`.tad/evidence/handoffs/HANDOFF-20260527-vimax-pattern-upgrade-video-creation/photo-to-beat-sync-fixture.md`
- **YOLO audit 建议**：`.tad/project-knowledge/architecture.md` → "YOLO Epic Execution: Cross-Model Audit Findings"
- **Idea 文件**：`.tad/active/ideas/IDEA-20260527-pack-behavioral-examples.md`

---

**Alex 确认**：设计完成，待 expert review 后填 Gate 2。
