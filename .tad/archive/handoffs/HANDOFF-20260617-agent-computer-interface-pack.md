---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: [".claude/skills/agent-computer-interface"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-06-17
**Project:** TAD Framework
**Task ID:** TASK-20260617-002
**Handoff Version:** 3.1.0
**Epic:** N/A

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-06-17

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Reference-based pack, 5-layer model clear |
| Components Specified | ✅ | SKILL.md + 6 references + 2 scripts + fixture |
| Functions Verified | ✅ | Pack follows established 24-pack pattern |
| Data Flow Mapped | ✅ | capability-detect.sh → SKILL.md router → reference rules |

**Gate 2 结果**: ✅ PASS

**Alex确认**: 我已验证所有设计要素，Blake可以独立根据本文档完成实现。

---

## 📋 Handoff Checklist (Blake必读)

Blake在开始实现前，请确认：
- [ ] 阅读了所有章节
- [ ] **阅读了「📚 Project Knowledge」章节中的历史经验**
- [ ] 所有"强制问题回答（MQ）"都有证据
- [ ] 理解了真正意图（不只是字面需求）
- [ ] 每个Phase的交付物和证据要求都清楚
- [ ] 确认可以独立使用本文档完成实现

❌ 如果任何部分不清楚，**立即返回Alex要求澄清**，不要开始实现。

---

## 1. Task Overview

### 1.1 What We're Building
TAD 第 25 个能力包：`agent-computer-interface`。教 AI agent 系统性地发现、选择和使用浏览器控制、网页抓取、桌面 GUI 操控等工具。基于五层架构模型（引擎→数据→混合→Agent→桌面），核心是判断规则而非工具教程。

### 1.2 Why We're Building It
**业务价值**：Agent 经常不知道自己有哪些工具可用——例如 Claude in Chrome 已装好但 agent 绕了 10+ 分钟尝试 Playwright、Puppeteer、Docker 等无效路径才发现。这个包消除"tool awareness 断裂"。
**用户受益**：装上包后 agent 在遇到浏览器/计算机任务时，第一步就检测可用工具并选择正确路径，弯路减少 50%+。
**成功的样子**：当用户说"帮我下载 Kaggle 数据"，agent 立即检测到 Claude in Chrome 可用并直接使用，而不是去装 Playwright。

### 1.3 Intent Statement

**真正要解决的问题**：Agent 缺乏对自身工具能力的系统性认知。不是单个工具不会用，而是不知道该用哪个、当前环境有哪个。

**不是要做的（避免误解）**：
- ❌ 不是写一个浏览器自动化框架
- ❌ 不是教 agent 如何写 Playwright/Puppeteer 测试代码
- ❌ 不是做一个通用的 MCP server
- ❌ 不是复制各工具的官方文档

**Blake请确认理解**：
```
在开始实现前，请用你自己的话回答：
1. 这个功能解决什么问题？
2. 用户会如何使用？
3. 成功的标准是什么？
```

---

## 📚 Project Knowledge（Blake 必读）

**⚠️ Blake 必须注意的历史教训：**

1. **Pack Architecture Spectrum** (pack-build-rules.md) — Judgment rules → reference-based pattern (thin SKILL.md router + references/*.md). 本包应用 reference-based 架构。
2. **YAML Frontmatter is Load-Bearing** (pack-build-rules.md) — SKILL.md 必须有 `name:` + `description:` YAML frontmatter，否则 Claude Code 不注册。
3. **Cross-Cutting Rules Layer** (pack-build-rules.md) — 跨引用的不变规则放 SKILL.md body，2-3 条上限。本包有 3 条跨层规则。
4. **Research Provenance Rules** (pack-build-rules.md) — 规则必须引用原始来源，不是从训练数据推断。本包规则来源 = NotebookLM notebook c0143736 (14 sources)。
5. **Sync downgrade bug** (pack-build-rules.md) — install.sh 必须从 `.claude/skills/` 单一来源复制，不从 `.tad/capability-packs/` 重新生成。
6. **Behavioral-Eval Gate Must Run on SEPARATE Discriminative Field** (pack-evaluation.md) — fixture 必须有 discriminative_pattern，不能用通用词。

**Blake 必须 Read 的文件**:
- `.tad/project-knowledge/patterns/pack-build-rules.md`
- `.tad/project-knowledge/patterns/pack-evaluation.md`

---

## 2. Technical Design

### 2.1 Architecture: Reference-Based Pack

```
.claude/skills/agent-computer-interface/
├── SKILL.md                          # ~300 lines: frontmatter + cross-cutting rules + context router
├── references/
│   ├── browser-engine-rules.md       # L1: Playwright, Puppeteer, Selenium
│   ├── data-extraction-rules.md      # L2: Firecrawl, Crawl4AI, Stagehand extract
│   ├── hybrid-framework-rules.md     # L3: Stagehand v3 SDK, Browser MCP
│   ├── autonomous-agent-rules.md     # L4: Browser Use, Skyvern, Open Operator (含认证/域隔离安全规则)
│   ├── desktop-control-rules.md      # L5: Computer Use, Fazm, UFO (含必须的安全章节: 用户确认门/视觉注入/沙盒)
│   └── claude-code-tools-rules.md    # Claude Code 专属: Claude in Chrome / Playwright MCP / DevTools MCP
├── scripts/
│   ├── capability-detect.sh          # 扫描 CLI 工具 + 进程检测（仅 Tier 2+3; Tier 1 MCP 由 SKILL.md 指导 agent 用 ToolSearch）
│   └── tool-health-check.sh          # 验证工具健康状态（硬编码工具白名单防注入, 24h 文件缓存）
├── examples/
│   └── fixture-browser-task.md       # 行为评估 fixture (discriminative)
└── (install.sh 位于 .tad/capability-packs/agent-computer-interface/install.sh — 单源复制)
```

### 2.2 SKILL.md 设计

**Frontmatter:**
```yaml
---
name: agent-computer-interface
description: "Agent computer & browser control capability pack. Gives AI agents the judgment rules for detecting available tools, selecting the right automation layer (engine/data/hybrid/agent/desktop), configuring browser and computer control tools, and handling fallback chains. Covers Playwright, Browser Use, Stagehand, Firecrawl, Claude in Chrome, Computer Use, and 15+ tools across 5 layers. Use for any browser automation, web scraping, desktop control, or tool selection task."
keywords: ["browser", "automation", "浏览器", "自动化", "scraping", "抓取", "computer use", "desktop", "GUI", "Playwright", "Puppeteer", "Browser Use", "Stagehand", "Firecrawl", "Crawl4AI", "Chrome", "MCP", "控制", "操控"]
type: reference-based
---
```

**Interface Contract:**
```
CONSUMES: User browser/computer/scraping task description + current environment context
PRODUCES: Tool selection decision + applied judgment rules + capability detection results + configuration guidance
```

**Cross-Cutting Rule 1: Capability Detection First (Two-Tier)**
> Before any browser/computer task, detect available tools via TWO mechanisms:
> - **Tier 1 (MCP — agent-side)**: Use ToolSearch to scan for `mcp__claude-in-chrome__*`, `mcp__playwright__*`, `mcp__chrome-devtools__*` and other browser MCP tools. This runs in the agent's runtime, NOT in a shell script.
> - **Tier 2+3 (CLI + Process — shell-side)**: Run `scripts/capability-detect.sh` which checks CLI tools (`command -v playwright` etc.) and browser extension state (`pgrep -f` for `--chrome` flag, current user only).
> Combine both tiers' results before selecting a tool. NEVER start installing a new tool before checking what's already available.

**Cross-Cutting Rule 2: Layer Match — Five-Layer Selection**
> Match task characteristics to the correct layer, then select a tool within that layer:

| Task Signal | Layer | First Choice |
|-------------|-------|-------------|
| Deterministic, known pages, CI/CD, testing | L1 Engine | Playwright CLI (not MCP — 4x cheaper) |
| Web page → clean markdown/JSON for LLM | L2 Data | Firecrawl (hosted) / Crawl4AI (local) |
| Deterministic code + AI flexibility mixed | L3 Hybrid | Stagehand v3 act/extract/observe |
| Open-ended multi-step autonomous browsing | L4 Agent | Browser Use (89.1% WebVoyager benchmark) |
| Cross-app desktop GUI automation | L5 Desktop | Claude Computer Use (beta, security risks) |

**Cross-Cutting Rule 3: Fallback Chain + Token Cost + Security Level**
> If the first-choice tool is unavailable, degrade down the chain with explicit user notification. Two constraints:
> - **Token cost**: Playwright MCP ~13.6k token schema tax (one-time) + per-page snapshot cost; Claude in Chrome ~10k tokens/page (per-page); Playwright CLI 4x fewer tokens than MCP (per-session). Separate one-time vs per-page vs per-session costs in comparisons.
> - **Security escalation gate**: Fallback from a lower layer to a higher layer (e.g., L1 sandboxed Playwright → L5 full desktop Computer Use) is a PERMISSION ESCALATION. MUST require explicit user confirmation via AskUserQuestion before escalating. Silent degradation within the same layer is OK; cross-layer upward fallback is NOT silent.
> Format: "⚠️ {preferred_tool} 不可用 ({reason}). 降级到 {fallback_tool}." (same layer) or "⚠️ {preferred_tool} 不可用. 替代方案 {fallback_tool} 需要更高权限（{reason}）——确认使用？" (cross-layer up)

**Step 0: Capability Detection**
Run `bash scripts/capability-detect.sh` → parse JSON output → announce available tools.

**Step 1: Context Detection → Route to Reference**

| User Signal | Reference to Load |
|-------------|-------------------|
| "browser", "navigate", "click", "automate page" | `claude-code-tools-rules.md` (Claude Code env) or `browser-engine-rules.md` (general) |
| "scrape", "crawl", "extract data", "抓取" | `data-extraction-rules.md` |
| "Stagehand", "hybrid", "act/extract" | `hybrid-framework-rules.md` |
| "autonomous", "multi-step", "自主浏览" | `autonomous-agent-rules.md` |
| "desktop", "GUI", "Computer Use", "桌面" | `desktop-control-rules.md` |
| "Claude in Chrome", "Playwright MCP", "DevTools" | `claude-code-tools-rules.md` |

**Step 2: Apply Rules** from loaded reference.

### 2.3 Reference File Design (易变层)

每个 reference 文件结构:
```markdown
# {Layer Name} Rules
last_verified: 2026-06-17

## Tools in This Layer
| Tool | License | Stars/Status | Primary Use | Token Cost (type) |
|------|---------|-------------|-------------|-------------------|
(Token Cost 必须标注类型: one-time schema / per-page / per-session)

## Decision Rules
### Rule N: {Title}
> {One-line blockquote summary}
{Detailed explanation with source citation}

## Security Considerations (MANDATORY for L4 and L5)
For L4 (autonomous-agent-rules.md):
- Domain scoping: restrict navigation to user-approved domains
- Credential entry: require user confirmation before typing passwords
- Session isolation: each autonomous browsing session in clean context

For L5 (desktop-control-rules.md) — 3 mandatory sections:
- User-confirmation gate: destructive/credential actions MUST prompt user first
- Visual prompt injection mitigation: warn about screenshots containing adversarial text
- Sandboxing recommendation: prefer Docker/VM isolation per Anthropic Computer Use guidance

## Configuration Guide
{How to install/configure each tool — CLI commands, MCP setup, flags}
(API key placeholders MUST use obviously-fake values: YOUR_API_KEY_HERE, with .env/.gitignore warnings)

## Example Usage
{Concrete code/command examples for common tasks}

## Fallback Chain
{If tool X unavailable → try Y → try Z → report to user}
(Cross-layer upward fallback requires explicit user confirmation — see Cross-Cutting Rule 3)
```

### 2.4 capability-detect.sh 设计

```bash
#!/bin/bash
# Detect available browser/computer control tools (Tier 2: CLI + Tier 3: process)
# Tier 1 (MCP) is handled by the agent via ToolSearch — NOT in this script.
# Output: JSON summary
# Security: only checks current user processes (pgrep, not ps aux)
# Performance: builds JSON in one jq pass, no per-tool subprocess

# Hardcoded allowlist — prevents command injection if called with untrusted input
ALLOWED_TOOLS="playwright puppeteer firecrawl crawl4ai stagehand browser-use"

DETECTED=""
for tool in $ALLOWED_TOOLS; do
  command -v "$tool" >/dev/null 2>&1 && DETECTED="$DETECTED\"$tool\":\"cli\","
done

# Tier 3: Extension/flag detection (current user only, no ps aux)
pgrep -fq "claude.*--chrome" 2>/dev/null && DETECTED="$DETECTED\"claude-in-chrome\":\"extension\","

# Build JSON in one pass
DETECTED="${DETECTED%,}"  # strip trailing comma
echo "{$DETECTED}" | jq .
```

### 2.5 tool-health-check.sh 设计

检查每个 reference 的 `last_verified` 日期，如果超过 90 天则输出 WARNING。
对每个已安装工具跑简单版本检查（`tool --version`），失败则标记 STALE。
输出格式: `OK: {tool} v{version}` 或 `STALE: {tool} last_verified {date} ({N} days ago)` 或 `BROKEN: {tool} command not found`。

### 2.6 Behavioral Eval Fixture

```yaml
---
pack: agent-computer-interface
scenario: "User asks: help me download data from a website that requires login"
discriminative_pattern: "capability.detect\\.sh|ToolSearch.*mcp__claude-in-chrome|L[1-5].*Engine|L[1-5].*Agent|pgrep|security.escalation|Cross-Cutting.Rule"
min_discriminative: 4
expected_behavior: "Agent should first detect available tools (ToolSearch + capability-detect.sh), identify login requirement points to Claude in Chrome (if available) or suggest auth setup, NOT start installing Playwright from scratch"
---
```

### 2.7 Update Mechanism

- `last_verified` header in each reference: Blake sets to build date
- `tool-health-check.sh`: agent can run on demand or at session start
- Tool failure → automatic fallback + "⚠️" announcement
- SKILL.md body (5-layer model, decision tree) = **stable layer** — rarely changes
- references/ (tool versions, stars, specific commands) = **volatile layer** — updated per pack-upgrade cycle

### 2.8 Research Sources for Rule Content

所有规则必须从以下已验证来源派生（不可从训练数据推断）：

- **NotebookLM Notebook**: c0143736-a6f1-4ff3-aa61-95ebee84c812 (14 sources)
- **Decision Brief**: `.tad/evidence/research/agent-computer-control/2026-06-17-decision-brief.md`
- **Raw Ask Results**: `.tad/evidence/research/agent-computer-control/2026-06-17-raw-ask-results.md`
- **Open Source Repos for Reference** (Blake 可克隆借鉴):
  - `browser-use/browser-use` — Agent 循环设计、DOM 解析策略
  - `browserbase/stagehand` — act/extract/observe 原语、CDP 直连架构
  - `anthropics/anthropic-quickstarts` — Computer Use 参考实现
  - `nicepkg/aide` 或 `nicepkg/browser-use` — 其他实现参考
- **WebSearch 验证**: 所有数字型 claim（star 数、benchmark 分数、token 消耗量）在研究中已 WebSearch 验证

Blake 可以且应该随时查询 NotebookLM notebook 获取更多细节：
```bash
~/.tad-notebooklm-venv/bin/notebooklm ask "<question>" -n c0143736-a6f1-4ff3-aa61-95ebee84c812
```

---

## 3-8. (Standard sections — abbreviated for capability pack task)

### §3 Functional Requirements

| FR | Description |
|----|-------------|
| FR1 | SKILL.md with YAML frontmatter, 3 cross-cutting rules, context router |
| FR2 | 6 reference files covering L1-L5 + Claude Code specific tools |
| FR3 | capability-detect.sh scanning 3 tiers (MCP/CLI/extension) |
| FR4 | tool-health-check.sh with last_verified + version probes |
| FR5 | Behavioral eval fixture with discriminative_pattern |
| FR6 | install.sh (single-source copy from .claude/skills/, NOT regenerate) |
| FR7 | .agents/skills/ mirror for Codex parity |

### §8.4 Friction Preflight

| Prerequisite | Expected Status | Fix Path |
|-------------|----------------|----------|
| NotebookLM CLI | READY (verified in this session) | `bash .tad/cross-model/setup-notebooklm.sh` |
| jq (for capability-detect.sh) | READY (macOS default) | `brew install jq` |
| pack-registry.yaml | READY | Standard TAD file |

### §8.5 Feedback Collection
feedback_required: false
(This is a judgment rules pack, not a visual artifact.)

---

## 9. Acceptance Criteria (Blake 验证清单)

### §9.1 AC List

- [ ] **AC1**: SKILL.md 存在且有正确 YAML frontmatter (`name: agent-computer-interface`, `description:` 含关键词, `keywords:` 含中英文, `type: reference-based`)
- [ ] **AC2**: SKILL.md body 包含 3 条 Cross-Cutting Rules（能力检测优先 / 层级匹配 / Fallback Chain + Token 成本）
- [ ] **AC3**: SKILL.md Step 1 context router 覆盖 ≥6 种用户信号 → 对应 reference
- [ ] **AC4**: 6 个 reference 文件都存在且各含 ≥5 条判断规则，每条规则引用研究来源
- [ ] **AC5**: `scripts/capability-detect.sh` 可执行，输出 JSON 格式，检测 ≥3 种工具类型
- [ ] **AC6**: `scripts/tool-health-check.sh` 可执行，对已安装工具输出 OK/STALE/BROKEN 状态
- [ ] **AC7**: `examples/fixture-browser-task.md` 存在且含 `discriminative_pattern` + `min_discriminative`
- [ ] **AC8**: `.tad/capability-packs/agent-computer-interface/install.sh` 存在且使用单源复制（从 `.claude/skills/` 复制到目标，不重新生成 SKILL.md）
- [ ] **AC9**: `.agents/skills/agent-computer-interface/SKILL.md` 与 `.claude/skills/` 版本 byte-identical
- [ ] **AC10**: Reference 文件中的具体数字（star 数、benchmark 分数、token 消耗量）与研究 raw-ask-results 一致或已通过 WebSearch 更新

---

## 10. Implementation Hints

1. 从 `web-backend` 和 `ai-tool-integration` 包的结构复制模板，修改内容
2. 参考 `.tad/evidence/research/agent-computer-control/2026-06-17-raw-ask-results.md` 中的分类表格作为 reference 文件的骨架
3. 用 NotebookLM ask 补充每个层级的具体规则（`~/.tad-notebooklm-venv/bin/notebooklm ask "..." -n c0143736`）
4. capability-detect.sh 可以参考现有 hook 脚本（`.tad/hooks/lib/`）的 shell 规范
5. 克隆 `browser-use` 和 `stagehand` 的 README/docs 提取使用模式和决策规则

---

## 11. Decision Summary

| # | Decision | Chosen | Rationale |
|---|----------|--------|-----------|
| D1 | Pack scope | 宽版 (L1-L5 全覆盖) | 五层模型天然组织知识；窄版覆盖不了 Claude Code 跨层工具 |
| D2 | Architecture | Reference-based | 判断规则包标准模式（per pack-build-rules Pattern） |
| D3 | Update strategy | 分层: 稳定(SKILL.md) + 易变(references/) | 领域变化极快，工具清单需要独立更新 |
| D4 | Depth | 判断规则 + 配置指南 + 示例 | 用户要求完整深度，不是只教选择 |
| D5 | 能力检测 | Two-tier: agent ToolSearch (MCP) + shell script (CLI/process) | MCP 无法从 shell 检测（P0-1 fix），拆分为 agent-side + shell-side |

---

## 12. Expert Review Audit Trail

**Review Date**: 2026-06-17
**Experts**: code-reviewer, security-auditor, performance-optimizer (3 distinct)
**Evidence**: `.tad/evidence/handoff-reviews/`

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | P0-1: capability-detect.sh 不能从 shell 调 ToolSearch | §2.2 Rule 1 + §2.4 拆分为 Two-Tier | ✅ Fixed |
| code-reviewer | P0-2: install.sh 位置错误 | §2.1 目录结构 + AC8 | ✅ Fixed |
| security-auditor | P0-1: ps aux 泄露其他用户进程 | §2.4 改用 pgrep -f | ✅ Fixed |
| security-auditor | P0-2: L5 零安全规则 | §2.3 reference 模板加 mandatory security section | ✅ Fixed |
| code-reviewer | P1-1: 缺 CONSUMES/PRODUCES | §2.2 加接口契约 | ✅ Fixed |
| code-reviewer | P1-3: ps grep fragile | §2.4 改用 pgrep + 降为 heuristic | ✅ Fixed |
| code-reviewer | P1-4: fixture 通用词可能假阳 | §2.6 收紧 discriminative_pattern + min=4 | ✅ Fixed |
| security-auditor | P1-4: fallback 跨层升级无确认 | §2.2 Rule 3 加 security escalation gate | ✅ Fixed |
| security-auditor | P1-1: 配置指南 API key 暴露风险 | §2.3 reference 模板加 fake-value 要求 | ✅ Fixed |
| security-auditor | P1-2: tool-health-check 命令注入 | §2.1 + §2.5 硬编码白名单 | ✅ Fixed |
| security-auditor | P1-3: L4 缺认证/域隔离规则 | §2.3 reference 模板加 L4 security section | ✅ Fixed |
| performance-optimizer | P1-1: jq O(N) subprocess | §2.4 单次 JSON 构建 | ✅ Fixed |
| performance-optimizer | P1-2: ps aux expensive | §2.4 pgrep 替代 | ✅ Fixed |
| performance-optimizer | P1-3: token cost 三类未区分 | §2.2 Rule 3 + §2.3 模板加 cost type | ✅ Fixed |
| performance-optimizer | P1-4: health-check 无缓存 | §2.5 加 24h 文件缓存 | ✅ Fixed |
| code-reviewer | P1-2: §3-8 缩写过度 | Blake 参照现有 gold packs 展开 | Noted |
| code-reviewer | P2-1~P2-5 | 5 items deferred (LICENSE, Version header, threshold config, AC4 grep, LC_ALL) | Deferred |

**Gate 2 Post-Review**: ✅ PASS — All 4 P0s resolved, 13/14 P1s resolved, 5 P2s deferred to Blake discretion.
