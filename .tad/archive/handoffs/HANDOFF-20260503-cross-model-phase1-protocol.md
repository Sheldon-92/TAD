---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: [".claude/skills", ".tad/config-workflow.yaml"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: Cross-Model Orchestration — Phase 1 Protocol Design + Integration
**From:** Alex (Agent A) | **To:** Blake (Agent B)
**Date:** 2026-05-03
**Project:** TAD Framework
**Epic:** EPIC-20260503-cross-model-orchestration.md (Phase 1/2)
**Priority:** P1

---

## 🔴 Gate 2: Design Completeness

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 4 个交付物：skill 文件 + 注册表 + 集成点 + 通用能力注册 |
| Components Specified | ✅ | 影响文件全部列出（§6） |
| Functions Verified | ✅ | NotebookLM CLI 命令来自 Phase 0b spike 验证 |
| Data Flow Mapped | ✅ | Notebook lifecycle: create → curate → query → archive |

**Gate 2 结果**: ✅ PASS

---

## 1. Task Overview

**目标**：将 Phase 0/0b spike 验证通过的跨模型能力正式集成到 TAD 框架中。

**两个交付维度**：
1. **NotebookLM 研究能力**（P0 — 所有工作的基础）：独立 skill + notebook 生命周期管理 + 自然集成点
2. **跨模型通用能力注册**（P1 — Codex Image-2 等）：capability catalog 注册机制，不绑定特定步骤

**核心设计原则**：
- NotebookLM 是**知识资产**（有状态，持续存在），不是无状态工具调用
- 能力不绑定特定工作流步骤——需要时调用，不需要时不调用
- 协议固定、能力可插拔

---

## 2. 交付物 A：`*research-notebook` Skill（NotebookLM 集成）

### 2.1 Skill 文件结构

创建 `.claude/skills/research-notebook/SKILL.md`，包含以下子命令：

```yaml
commands:
  create: "创建新 notebook → 添加初始源 → 注册到 registry"
  add: "向现有 notebook 添加源（web URL / YouTube / PDF path）"
  ask: "查询 notebook（跨源推理）"
  list: "列出所有注册的 notebooks + 状态 + 源数量（含云端同步检查）"
  sync: "同步 REGISTRY.yaml 与 NotebookLM 云端状态（BA-P0-1）"
  curate: "维护 notebook：检查源新鲜度、建议删除/替换过时源"
  archive: "归档 notebook：导出查询历史 → 更新 registry → 标记 archived"
  use: "切换当前活跃 notebook（session-scoped override）"

preflight:
  description: "每个子命令执行前的可用性检查（CR-P2-1）"
  checks:
    - "notebooklm CLI 是否可用（which notebooklm）"
    - "auth 是否有效（~/.notebooklm/storage_state.json 存在且未过期）"
  on_fail: "提示用户运行 bash .tad/cross-model/setup-notebooklm.sh"
```

### 2.2 `*research-notebook create` 流程

```
用户: *research-notebook create "AI Agent Security"
  ↓
Step 1: 创建 NotebookLM notebook
  → notebooklm create "AI Agent Security"
  → notebooklm use <notebook_id>
  ↓
Step 2: 引导添加源（AskUserQuestion）
  → "你想添加哪些类型的源？"
  → Options: "我提供 URL 列表" / "帮我搜索相关 YouTube 视频" / "两者都要" / "稍后添加"
  ↓
Step 3: 如果用户选 "帮我搜索 YouTube"：
  → WebSearch 搜索 "{topic} conference talk / official channel 2026"
  → 展示找到的视频列表（带标题+时长）
  → 用户选择要添加的视频
  → notebooklm source add <url>（逐个添加）
  ↓
Step 4: 如果用户提供 URL 列表：
  → 逐个 notebooklm source add <url>
  → 报告每个的成功/失败状态
  ↓
Step 5: 注册到 registry
  → 更新 .tad/research-notebooks/REGISTRY.yaml
  → 记录 notebook_id, 课题, 源列表, 创建日期, 状态
  ↓
Step 6: 确认
  → "✅ Notebook 'AI Agent Security' 已创建，{N} 个源已添加。
     用 *research-notebook ask 'your question' 查询。"
```

### 2.3 `*research-notebook ask` 流程

```
用户: *research-notebook ask "哪些 bash 命令应该被 deny？"
  ↓
Step 1: 检查活跃 notebook
  → 读 REGISTRY.yaml 找当前 active notebook
  → 如果无 active → AskUserQuestion 选择一个 / 创建新的
  ↓
Step 2: 激活正确 notebook
  → notebooklm use <notebook_id>
  ↓
Step 3: 执行查询
  → notebooklm ask "问题内容"
  → 捕获输出 + wall-clock 时间
  ↓
Step 4: 返回结果
  → 输出查询结果到用户
  → 如果是 Alex *discuss 内调用：结果直接融入讨论上下文
```

### 2.4 `*research-notebook sync` 流程（BA-P0-1）

```
Step 1: 读 REGISTRY.yaml 所有 active/dormant notebooks
Step 2: 对每个 notebook，调用 notebooklm list（或等效 CLI 命令）获取云端状态
Step 3: 对比：
  - 本地有、云端无 → 标记 ⚠️ "云端已删除，REGISTRY 过时"
  - 云端源数量 ≠ 本地记录 → 标记 ⚠️ "源有变更（web UI 操作）"
  - 一致 → ✅
Step 4: 输出同步报告 + AskUserQuestion：
  - "更新 REGISTRY 以匹配云端" / "保持本地状态" / "逐个确认"
Step 5: 按用户选择更新 REGISTRY.yaml
```

`*research-notebook list` 命令每次执行时自动触发轻量 sync（只检查 notebook 存在性，不逐源对比）。完整同步用 `*research-notebook sync`。

### 2.5 `*research-notebook curate` 流程

```
Step 1: 读 REGISTRY.yaml 中选定 notebook 的源列表 + 添加日期
Step 2: 检查每个源：
  - 添加超过 90 天 → 标记 ⚠️ 可能过时
  - URL 不可达（如果能检测）→ 标记 ❌ 失效
  - 同类型源超过 5 个 → 建议精简（质量 > 数量）
Step 3: 输出策展报告：
  | # | 源 | 类型 | 添加日期 | 状态 | 建议 |
  |---|-----|------|---------|------|------|
Step 4: AskUserQuestion：按建议执行还是手动决定
Step 5: 执行删除/替换（如果用户确认）
```

### 2.5 Notebook 生命周期管理

**Registry 文件**: `.tad/research-notebooks/REGISTRY.yaml`

```yaml
notebooks:
  - id: "notebook_abc123"
    topic: "AI Agent Security"
    created: "2026-05-03"
    status: active        # active / dormant / archived
    last_queried: "2026-05-03"
    source_count: 15
    sources:
      - url: "https://youtube.com/watch?v=xxx"
        type: youtube
        added: "2026-05-03"
        title: "RSAC: Security Risks of AI Agents"
      - url: "https://owasp.org/..."
        type: web
        added: "2026-05-03"
        title: "OWASP LLM Top 10"
    notes: "Phase 0b spike notebook，含 6 个 video-exclusive 攻击技术发现"

active_notebook: "notebook_abc123"   # 当前默认查询目标
```

**生命周期规则**（阈值可配置，见 config-workflow.yaml `research_notebook` 节 — BA-P1-1）：

| 状态 | 条件 | 处理 |
|------|------|------|
| active | 最近 N 天内查询过（默认 30，可配置） | 正常可用 |
| dormant | N-M 天未查询（默认 30-90，可配置） | `*research-notebook list` 标记 💤，建议 curate 或 archive |
| archived | 用户执行 `archive` | registry 保留条目（status: archived），notebook 可保留在 NotebookLM 账户中 |

config-workflow.yaml 中的配置节（Blake 需创建）：
```yaml
research_notebook:
  dormant_after_days: 30
  archive_suggest_after_days: 90
  max_sources_per_notebook: 20
  source_stale_after_days: 90
```

**源上限**：每个 notebook ≤ `max_sources_per_notebook`（默认 20）。超过时 `add` 命令提示用户先 `curate` 精简。

**跨课题处理**：不同课题各建各的 notebook。交叉源可以重复添加（冗余但清晰，避免跨 notebook 依赖）。

---

## 3. 交付物 B：自然集成点（建议触发，不强制）

### 3.1 Alex `*discuss` 集成

在 `discuss_path_protocol.behavior.domain_pack_awareness` 之后添加：

```yaml
research_notebook_awareness:
  trigger: "话题内容涉及研究密集型课题时"
  action: |
    检查 .tad/research-notebooks/REGISTRY.yaml：
    1. 如果存在匹配课题的 active notebook：
       → 输出: "📚 Found existing notebook: '{topic}' ({source_count} sources). 
         Use *research-notebook ask to query it."
    2. 如果不存在匹配 notebook 但课题需要多源深度研究：
       → 建议: "This topic might benefit from a research notebook. 
         Use *research-notebook create '{topic}' to build a multi-source knowledge base."
    3. 这是建议不是强制——用户可以忽略继续用 WebSearch
  note: "匹配是 LLM 语义判断，不是精确字符串匹配"
```

### 3.2 Alex `research_decision_protocol` 集成

在 `step2_research` 中添加可选步骤：

```yaml
step2_5_notebook_check:
  name: "Check Research Notebook (optional)"
  action: |
    Before executing Landscape Search (WebSearch ×N):
    1. Check REGISTRY.yaml for a notebook matching this decision's domain
    2. If found → query it first: notebooklm ask "{decision question}"
    3. Use notebook answer as SUPPLEMENT to WebSearch, not replacement
       (notebook = curated deep knowledge; WebSearch = current broad coverage)
    4. If not found → skip, proceed with standard WebSearch flow
  blocking: false
```

### 3.3 Integration 约束

- 所有集成点都是**建议**，不是强制——用户或 Alex 可以忽略
- NotebookLM 查询结果是**补充** WebSearch，不是替代
- 不在 Blake 的实现流程中自动触发（研究是 Alex 领域）
- 不在 Gate 3/4 中自动触发（gates 检查质量不做研究）

---

## 4. 交付物 C：跨模型通用能力注册（Capability Catalog）

### 4.1 Capability Catalog 文件

创建 `.tad/cross-model/capabilities.yaml`：

```yaml
# Cross-Model Capability Catalog
# 协议固定、能力可插拔。新能力出现 → 添加条目 → TAD 立刻可用。
version: 1.0.0
last_updated: 2026-05-03

capabilities:
  codex_image_gen:
    platform: codex
    cli_command: 'codex exec --full-auto "Generate image: {prompt}. Save the image."'
    description: "GPT Image-2 图片生成（UI mockup、架构图、图表、icon）"
    output_location: "~/.codex/generated_images/ → 复制到项目目录"
    verified: true
    spike_ref: "SPIKE-20260503-phase0/spike-c-results.md"
    use_when: "需要生成图片、图表、UI mockup、架构图"
    dont_use_when: "需要照片级真实感 / 需要精确像素控制"
    fallback: "Mermaid / PlantUML / draw.io（手动）"
    budget: "GPT Plus 额度，≤20/month recommended"
    latency: "~120s per image"

  notebooklm_research:
    platform: notebooklm
    cli_command: 'notebooklm ask "{question}"'
    description: "多源跨媒体深度研究（YouTube + PDF + 网页语料库跨源推理）"
    verified: true
    spike_ref: "SPIKE-20260503-notebooklm/SPIKE-REPORT.md"
    use_when: "研究密集型课题，需要跨源综合 + 视频内容 + 引用"
    dont_use_when: "快速事实查询（用 WebSearch）/ 实时数据（NotebookLM 不抓实时 web）"
    fallback: "WebSearch ×5-8（Claude 迭代搜索）"
    setup_required: true
    setup_ref: "*research-notebook create"
    latency: "23-43s per query"

  gemini_research:
    platform: gemini
    cli_command: 'gemini -p "{question}"'
    description: "Google Search Grounding 实时研究（减少幻觉 ~40%）"
    verified: true
    spike_ref: "SPIKE-20260503-cross-model-orchestration/SPIKE-REPORT.md"
    use_when: "需要实时 web 信息 + 事实核查"
    dont_use_when: "需要深度跨源综合（用 NotebookLM）/ 需要写文件（Gemini -p 只读）"
    fallback: "WebSearch（Claude 内置）"
    status: "DEFER — 需对称 prompt 重测（Phase 0 Spike B）"
    latency: "~61s per query"

  # 未来能力预留位（发现后填入）
  # gemini_veo_video:
  #   platform: gemini
  #   status: "未验证"
  # gemini_lyria_audio:
  #   platform: gemini
  #   status: "未验证"
  # codex_web_search:
  #   platform: codex
  #   status: "未验证"
```

### 4.2 Catalog 使用规则

- **已验证 (verified: true)**：可在 TAD 工作流中直接使用
- **DEFER**：已知限制，等条件满足后重测
- **注释掉的条目**：已知存在但未验证，等 spike 后激活
- **新能力发现**：直接添加条目，不需要改 SKILL 或 config — 这就是"可插拔"
- **Fallback 链定义在 config-workflow.yaml**（不在 capabilities.yaml 中 — BA-P1-2 分离 catalog 和 orchestration）

### 4.3 Fallback 链（写入 config-workflow.yaml，不写入 capabilities.yaml — BA-P1-2）

Blake 在 config-workflow.yaml 的 `research_notebook` 配置节中添加 `fallback_chains` 子节：

```yaml
# config-workflow.yaml → research_notebook → fallback_chains
fallback_chains:
  research:
    primary: notebooklm_research
    secondary: gemini_research       # DEFER 状态，暂跳过
    tertiary: claude_websearch
  image_generation:
    primary: codex_image_gen
    secondary: manual_mermaid
  code_review:
    primary: claude_code_reviewer
```

capabilities.yaml 保持纯 catalog（每个能力的元数据），不含路由逻辑。

---

## 5. 交付物 D：Auth 持久化脚本

Phase 0b 发现 `notebooklm login` 的 auth 路径不匹配（browser_profile vs storage_state.json）。
创建一个一次性 setup 脚本：

**文件**: `.tad/cross-model/setup-notebooklm.sh`

```bash
#!/bin/bash
# NotebookLM one-time auth setup for TAD
# Usage: bash .tad/cross-model/setup-notebooklm.sh

set -e

VENV_PATH="${HOME}/.tad-notebooklm-venv"

echo "=== NotebookLM TAD Setup ==="

# Step 1: Create persistent venv (not /tmp — survives reboot)
if [ ! -d "$VENV_PATH" ]; then
    python3 -m venv "$VENV_PATH"
    echo "Created venv at $VENV_PATH"
fi

source "$VENV_PATH/bin/activate"

# Step 2: Install
pip install -q "notebooklm-py[browser]==0.1.1"  # pin version per global CLAUDE.md safety rule (CR-P1-2)
playwright install chromium 2>/dev/null

# Step 3: Login (interactive — needs user)
echo ""
echo "Opening browser for Google login..."
echo "Complete the login, then press Enter in this terminal."
notebooklm login

# Step 4: Export session
python3 -c "
from playwright.sync_api import sync_playwright
import json, os
profile = os.path.expanduser('~/.notebooklm/browser_profile')
out = os.path.expanduser('~/.notebooklm/storage_state.json')
with sync_playwright() as p:
    ctx = p.chromium.launch_persistent_context(profile, headless=True)
    json.dump(ctx.storage_state(), open(out,'w'))
    ctx.close()
print('Session exported to ~/.notebooklm/storage_state.json')
"

echo ""
echo "=== Setup Complete ==="
echo "Use: source $VENV_PATH/bin/activate && notebooklm ask 'your question'"
```

---

## 6. Files to Create / Modify

| Action | File | Purpose |
|--------|------|---------|
| CREATE | `.claude/skills/research-notebook/SKILL.md` | 独立 skill：create/add/ask/list/curate/archive |
| CREATE | `.tad/research-notebooks/REGISTRY.yaml` | Notebook 注册表（初始为空模板） |
| CREATE | `.tad/cross-model/capabilities.yaml` | 跨模型能力目录 |
| CREATE | `.tad/cross-model/setup-notebooklm.sh` | Auth 持久化脚本 |
| MODIFY | `.claude/skills/alex/SKILL.md` | 添加 research_notebook_awareness + step2_5 |
| MODIFY | `.tad/config-workflow.yaml` | 添加 research_notebook 配置节 |

**Grounded Against** (Alex step1c):
- `.claude/skills/alex/SKILL.md` (head 50 read — discuss_path_protocol + research_decision_protocol 存在)
- `.tad/config-workflow.yaml` (head 50 read — document_management 节存在)
- NotebookLM CLI 命令来自 Phase 0b spike 验证结果 (SPIKE-REPORT.md)
- No `.claude/skills/research-notebook/` dir exists yet (new)
- No `.tad/research-notebooks/` dir exists yet (new)
- No `.tad/cross-model/` dir exists yet (new)

---

## 9. Acceptance Criteria

| AC# | Criteria | Verification |
|-----|----------|-------------|
| AC1 | SKILL.md 存在且包含 6 个子命令（create/add/ask/list/curate/archive） | `grep -c "create\|add\|ask\|list\|curate\|archive" SKILL.md` ≥6 |
| AC2 | REGISTRY.yaml 模板存在 | `test -f .tad/research-notebooks/REGISTRY.yaml` |
| AC3 | capabilities.yaml 存在且包含 ≥2 个 verified 能力 | `grep -c "verified: true" capabilities.yaml` ≥2 |
| AC4 | setup-notebooklm.sh 存在且可执行 | `test -x .tad/cross-model/setup-notebooklm.sh` |
| AC5 | Alex SKILL.md 包含 research_notebook_awareness | `grep -c "research_notebook_awareness" .claude/skills/alex/SKILL.md` ≥1 |
| AC6 | Alex SKILL.md 包含 step2_5_notebook_check | `grep -c "step2_5_notebook_check\|notebook_check" .claude/skills/alex/SKILL.md` ≥1 |
| AC7 | config-workflow.yaml 包含 research_notebook 配置 | `grep -c "research_notebook" .tad/config-workflow.yaml` ≥1 |
| AC8 | capabilities.yaml 包含 fallback_chains | `grep -c "fallback_chains" .tad/cross-model/capabilities.yaml` ≥1 |
| AC9 | Notebook 生命周期规则节在 SKILL.md 中定义 | `grep -c "## Notebook Lifecycle\|lifecycle_rules\|生命周期规则" SKILL.md` ≥1 |
| AC10 | Phase 0b spike notebook (AI Agent Security) 已注册到 REGISTRY.yaml | `grep -c "AI Agent Security" REGISTRY.yaml` ≥1 |

---

## 9.1 Spec Compliance Checklist

| AC# | Verification Method | Expected | Verified Output |
|-----|--------------------|-----------|----|
| AC1 | `grep -cE "create\|add\|ask\|list\|curate\|archive" .claude/skills/research-notebook/SKILL.md` | ≥6 | (post-impl) |
| AC2 | `test -f .tad/research-notebooks/REGISTRY.yaml && echo EXISTS` | EXISTS | (post-impl) |
| AC3 | `grep -c "verified: true" .tad/cross-model/capabilities.yaml` | ≥2 | (post-impl) |
| AC4 | `test -x .tad/cross-model/setup-notebooklm.sh && echo EXECUTABLE` | EXECUTABLE | (post-impl) |
| AC5 | `grep -c "research_notebook_awareness" .claude/skills/alex/SKILL.md` | ≥1 | (post-impl) |
| AC6 | `grep -cE "step2_5_notebook_check\|notebook_check" .claude/skills/alex/SKILL.md` | ≥1 | (post-impl) |
| AC7 | `grep -c "research_notebook" .tad/config-workflow.yaml` | ≥1 | (post-impl) |
| AC8 | `grep -c "fallback_chains" .tad/cross-model/capabilities.yaml` | ≥1 | (post-impl) |
| AC9 | `grep -cE "## Notebook Lifecycle\|lifecycle_rules\|生命周期规则" .claude/skills/research-notebook/SKILL.md` | ≥1 | (post-impl) |
| AC10 | `grep -c "AI Agent Security" .tad/research-notebooks/REGISTRY.yaml` | ≥1 | (post-impl) |

**AC Dry-Run Log** (Alex step1d at 2026-05-03):
- AC1-AC10: ✅ all post-impl-verifiable (new files created by Blake), syntax-validated

---

## 9.2 Expert Review

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| backend-architect | P0-1: REGISTRY 无云端同步机制 | §2.4 新增 `sync` 子命令 + `list` 自动轻量同步 | Resolved |
| backend-architect | P1-1: 30/90 天阈值应可配置 | §2.6 阈值移到 config-workflow.yaml | Resolved |
| backend-architect | P1-2: capabilities.yaml 混了 catalog + orchestration | §4.3 fallback_chains 移到 config-workflow.yaml | Resolved |
| code-reviewer | P0-1: AC9 grep 太宽松会误命中 | §9 + §9.1 AC9 改为匹配 lifecycle section header | Resolved |
| code-reviewer | P1-1: setup 脚本未 pin 版本 | §5 改为 `notebooklm-py[browser]==0.1.1` | Resolved |
| code-reviewer | P2-1: SKILL 缺 pre-flight 检查 | §2.1 新增 `preflight` 节 | Resolved |
| backend-architect | P2-1: active_notebook singleton 限制 | §2.1 新增 `use` 子命令（session-scoped override） | Resolved |

---

## 10. Important Notes

### 10.1 SKILL.md 是判断层，不是机械逻辑
`*research-notebook` 的 SKILL.md 定义工作流和规则，但具体的 CLI 命令执行用 Bash tool。SKILL 不需要包含 bash 脚本——它指导 Alex/Blake 什么时候做什么。

### 10.2 REGISTRY.yaml 是本地注册表，不是 NotebookLM 的数据
REGISTRY.yaml 记录的是"TAD 知道哪些 notebook 存在"。实际的 notebook 数据在 NotebookLM 云端。如果用户在 NotebookLM web UI 删了一个 notebook，REGISTRY 不会自动更新——`*research-notebook list` 应该在发现不一致时提示用户。

### 10.3 Auth 会过期
NotebookLM session 会过期。setup 脚本需要偶尔重新运行。SKILL.md 应该在 auth 失败时提示用户运行 `bash .tad/cross-model/setup-notebooklm.sh`。

### 10.4 Codex Image-2 不需要 SKILL
Codex Image-2 在 capabilities.yaml 中注册就够了。不需要单独的 SKILL 文件——任何 agent 需要图片时查 capabilities.yaml 找到命令直接执行。这是"能力可插拔"的体现。

### 10.5 不改 Blake SKILL
这个 Phase 不修改 Blake SKILL。NotebookLM 研究是 Alex 领域（设计/研究阶段），不是 Blake 领域（实现阶段）。Blake 在实现时如果需要研究，可以用 WebSearch（已有能力）。

---

## 📚 Project Knowledge

### ⚠️ Blake 必须注意的历史教训

- **Standalone Agent Command Pattern (architecture.md, 2026-02-08)**: 独立命令有自己的 persona + workflow + output，通过 output 文件集成到主系统。*research-notebook 应遵循此模式。
- **Aggregation Layer: Coexist Don't Replace (architecture.md, 2026-02-16)**: REGISTRY.yaml 是聚合层，引用 NotebookLM 云端数据，不复制。
- **NotebookLM CLI Auth Path Mismatch (architecture.md, 2026-05-03)**: `notebooklm login` 存 browser_profile，CLI 读 storage_state.json，需要 Playwright 导出。setup 脚本已处理。
- **YouTube Source Strategy (architecture.md, 2026-05-03)**: 用有字幕的视频（会议/官方频道），8/8 成功。无字幕视频静默失败。

### Required Evidence Manifest
```yaml
skill_file: ".claude/skills/research-notebook/SKILL.md"
registry: ".tad/research-notebooks/REGISTRY.yaml"
capabilities: ".tad/cross-model/capabilities.yaml"
setup_script: ".tad/cross-model/setup-notebooklm.sh"
completion: ".tad/active/handoffs/COMPLETION-20260503-cross-model-phase1-protocol.md"
```

---

## 11. Decision Summary

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | NotebookLM 集成形态 | 纯集成到 *discuss / 纯独立 skill / 两层设计 | 两层设计（独立 skill + 集成建议） | 独立 skill 保证灵活性，集成点保证可发现性 |
| 2 | Codex Image-2 集成形态 | 绑定 *publish / 独立 skill / capability catalog 注册 | capability catalog 注册 | 用户明确不要绑定特定步骤，注册即可调用 |
| 3 | Notebook 管理方式 | 无管理 / 简单列表 / 完整生命周期 | 完整生命周期 (active/dormant/archived) | 用户要求维护+清理+归档能力 |
| 4 | 跨课题处理 | 共享 notebook / 各建各的 | 各建各的 + 允许冗余源 | 清晰 > 节省，避免跨 notebook 依赖 |
| 5 | Blake SKILL 是否修改 | 加研究能力 / 不改 | 不改 | 研究是 Alex 领域，Blake 有 WebSearch 已够用 |
