---
task_type: yaml
e2e_required: no
research_required: no
git_tracked_dirs: [".tad/domains", ".tad/project-knowledge"]
skip_knowledge_assessment: no
---

# Handoff: Phase 4 — Domain Pack Expansion

**From:** Alex (Terminal 1) | **To:** Blake (Terminal 2) | **Date:** 2026-04-25
**Epic:** `.tad/active/epics/EPIC-20260424-tad-self-upgrade-from-consumers.md` (Phase 4/6)
**Evidence Reference:** `.tad/evidence/learnings/HARVEST-20260424-cross-project.md`
**Pre-triage:** `.tad/evidence/learnings/PHASE4-PRETRIAGE-20260425.md`
**Priority:** P0
**Status:** Ready for Implementation (post expert review v2)
**Type:** Standard TAD (Phase handoff; not Express)

---

## 1. Executive Summary

Phase 4 把跨项目 harvest 出的 19 个 cross-project pattern + DESIGN.md 集成（用户 2026-04-25 补充）落实到 9 个 Domain Packs + 1 个 README 修正。**Scope 已经过 PHASE4-PRETRIAGE-20260425 重审：跳过 P4.1 cost-observability（IDEA-20260419 自身建议推迟 2-3 个月）+ P4.2 agent-runtime-security（redirect 到 Security Chain Phase 2 ai-security pack）。**

**P4.11 新增 DESIGN.md 集成（Google Labs 2026-04-21 开源 Apache 2.0）+ Anti-AI-Slop 哲学（Anthropic skills/frontend-design Apache 2.0）。** 两个 source 都已 license verified（Apache 2.0 + Apache 2.0），verbatim lift with attribution 合法。TAD 走在 Anthropic Issue #1008 之前。

**实质：21 个 surgical YAML edits 跨 9 个 pack files + 1 个 README 行修正。** 全 prompt-level + advisory（不动 settings.json / 不加 hook / 不改 enforcement model）。

---

## 2. Epic Context

| Phase | Status |
|-------|--------|
| P1 State Consistency | ✅ Done (commit 08e9e74) |
| P2 Grounding | ✅ Done (commit 0b2e25d) |
| P3 New Paths | ✅ Done (commit ff96bd5) |
| **P4 Domain Pack Expansion** | **此 handoff** |
| P5 Evolve Data Capture | ⬚ Planned |
| P6 Assumption Redesign (v3) | ⬚ Planned |
| P4.5 deferred candidates | P4.1 cost-observability (~2-3 months), P4.2 → Security Chain Phase 2 |

---

## 3. Task Breakdown

### Task P4.3 — `ai-prompt-engineering` 扩展

**File:** `.tad/domains/ai-prompt-engineering.yaml`
**Add 3 items**:

1. **Anti-pattern: Cross-Section Example Pollution** → `system_prompt_design.anti_patterns`
2. **Capability declaration pattern** → `system_prompt_design.steps[derive_prompt_architecture]` (add as 5b)
3. **Quality criterion: Char Limit ≤15K** → `system_prompt_design.quality_criteria`

(Full content unchanged from v1 — see Audit Trail §10 for any P0 modifications)

---

### Task P4.4 — `ai-agent-architecture` 扩展（含 P4.12 合并）

**File:** `.tad/domains/ai-agent-architecture.yaml`
**Add 5 items** (BA-P1-1 fix: Model-Reads-Human-Verifies folded into `safety_design`, NO new capability):

1. **Pattern: Explicit Anti-Pattern Lists in System Prompt** → `reliability_design.steps`
2. **Pattern: Capability Declaration in System Prompt** → cross-link comment to P4.3 #2 (literal text: "(See: ai-prompt-engineering.yaml `system_prompt_design.steps.derive_prompt_architecture` step 5b for prompt-side implementation.)")
3. **Pattern: Fail-Closed Toolset Config** → `safety_design.steps` or sibling
4. **Pattern: Bilingual Blocklist as Minimum** → `safety_design.quality_criteria`
5. **(P4.12 merged) Pattern: Model Reads, Human Verifies** → **`safety_design.steps`** (BA-P1-1: NOT a new capability, fold into existing safety_design)

---

### Task P4.5 — `ai-evaluation` 扩展（3 items）

**File:** `.tad/domains/ai-evaluation.yaml`
**Add 3 items** (capability targets verified by BA-P1-2 at lines 19/135/244):

1. **Metadata field: `determinismLevel`** → `eval_framework_design.steps[derive_scoring_rubric]`
2. **Anti-pattern: Mocks Hide SDK Shape Validation** → `benchmark_testing.anti_patterns`
3. **Anti-pattern: Self-Enhancement (Judge=Optimizer)** → `ab_testing.anti_patterns`

---

### Task P4.6 — `project-knowledge/README.md` 修正

**File:** `.tad/project-knowledge/README.md`
**Modify 1 line** (line 17):

```diff
-  frontend-design.md  # Frontend design decisions - Design Tokens, component specs, visual style
+  frontend-design.md  # Frontend design decisions - event-triggered, populated when running /playground, not continuous
```

**BA-P0-2 fix**: Removed `(P4.11 DESIGN.md format)` parenthetical to avoid coupling README to P4.11 status. README modification is now standalone — accurate regardless of P4.11's success state. **Sequencing**: P4.6 commit MUST be LAST (after P4.11 PASS) — see §8 Blake Instructions + AC-P4.6-c conditional.

---

### Task P4.7 — `ai-tool-integration` 扩展

**File:** `.tad/domains/ai-tool-integration.yaml`
**Add 2 patterns**:
1. **Pattern: Parallel CLI Prefetch** (BSD bash 3.2 portable) → relevant capability steps
2. **Anti-pattern: Claude Vision OOM via base64 in History** → anti_patterns

---

### Task P4.8 — `code-security` 扩展

**File:** `.tad/domains/code-security.yaml`
**Add 1 reference implementation**:

1. **safe_fetch 7-Layer SSRF Defense Architecture** → `dast_scan` 或新 step

**BA-P1-4 fix — explicit boundary cross-link**:

Add to code-security.yaml near safe_fetch reference:
```yaml
# Boundary: Agent-runtime SSRF (LLM-controlled URL fetching) belongs to
# ai-security pack (Security Chain EPIC-20260403 Phase 2). This capability
# covers the deterministic server-side fetcher only.
```

Plus: add back-reference reminder inside `EPIC-20260403-security-domain-pack-chain.md` Phase 2 scope notes (separate edit; included in this handoff scope).

---

### Task P4.9 — `web-deployment` 扩展

**File:** `.tad/domains/web-deployment.yaml`
**Add 2 patterns**:
1. **Pattern: "Dashboard-Only" Ops CLI-Resolvable**
2. **Anti-pattern: Shell Pipe Trailing Newline (use printf '%s' + od -c verify)**

---

### Task P4.10 — `web-backend` 扩展

**File:** `.tad/domains/web-backend.yaml`
**Add 1 pattern**:
1. **Pattern: UUID-Scoped Pub/Sub Channel Names** (StrictMode + topic-sharing defense)

---

### Task P4.11 — `web-ui-design` 扩展（含 DESIGN.md 集成 + Anti-AI-Slop）

**File:** `.tad/domains/web-ui-design.yaml`
**Add 4 items**:

#### P4.11.1 — 新 capability `design_system_documentation`

```yaml
design_system_documentation:
  description: "输出 Google Labs DESIGN.md 格式作为 design system 持久化合约 — agent-readable + human-readable。"
  type: "Type A - Document/Research"
  
  steps:
    - id: extract_design_tokens
      action: |
        从 visual_design 输出抽取 token tree:
        - colors (semantic naming: primary, secondary)
        - typography (per-role objects: h1/body/caption with fontFamily/fontSize/fontWeight/lineHeight/letterSpacing)
        - spacing (scale levels: base, lg, sm)
        - rounded (corner radius scale)
        - components (per-component token references using {colors.primary} curly-brace syntax)
      tool_ref: null
      output_file: "DESIGN.md (frontmatter section)"
    
    - id: write_design_rationale
      action: |
        按 Google DESIGN.md spec 8 个 canonical sections 写 markdown prose:
        1. Overview (Brand & Style)
        2. Colors (palette + semantic roles)
        3. Typography (font strategy + hierarchy)
        4. Layout (grid + spacing rhythm)
        5. Elevation & Depth (visual hierarchy method)
        6. Shapes (corner radius + geometric language)
        7. Components (UI element guidance)
        8. Do's and Don'ts
      tool_ref: null
      output_file: "DESIGN.md (prose sections)"
    
    - id: validate_wcag_contrast
      action: |
        Primary path: 用 `npx @google/design.md lint` 验证 token 组合 WCAG AA 4.5:1 对比度.
        Fallback (CLI alpha unavailable): 用 WebAIM contrast checker
        (https://webaim.org/resources/contrastchecker/) 手动验证 ≥5 token pairs;
        evidence file 含每 pair 的 ratio + PASS/FAIL + 在 header 标注
        "CLI status: ALPHA-UNAVAILABLE" or "CLI status: PASSED".
      tool_ref: null
      output_file: "design-md-lint-report.txt"
    
    - id: consume_playground_input  # BA-P0-1 fix: pack consumes from playground, not modifies playground
      action: |
        如果项目之前运行过 /playground 并产生 DESIGN-SPEC.md：
        - READ `.tad/active/playground/DESIGN-SPEC.md` 作为 input
        - 抽取其中 design decisions 作为本 capability 的 token + rationale 来源
        - **不修改 /playground 任何 output**（playground 是 standalone command，
          其 SKILL contract 在 `.claude/skills/playground/SKILL.md` 定义独立）
        - 如 /playground 未运行: capability 仍可独立运行（pack-internal token 抽取）
      tool_ref: null
      output_file: "DESIGN.md (with playground input reference if any)"
  
  quality_criteria:
    - "YAML frontmatter 至少含 `name` 字段（DESIGN.md spec 唯一 required field）"
    - "Token names 用 semantic naming（primary/secondary not blue/red）"
    - "Typography tokens 用 object 形式（含 fontFamily/fontSize/fontWeight/lineHeight 至少 4 字段）"
    - "Token 引用用 `{colors.primary}` curly-brace 不用直接 hex 重复"
    - "WCAG AA 4.5:1 contrast 通过（primary: design.md lint CLI / fallback: WebAIM 手动验证 ≥5 pairs）"
    - "8 个 canonical sections 全有"
  
  anti_patterns:
    - "❌ Mixed rounded + sharp corners in same view（Google spec）"
    - "❌ >2 font weights per screen（Google spec）"
    - "❌ Token 直接用 hex 不用 reference syntax → 修改 primary 色需改 N 处"
    - "❌ 跳过 Do's-Don'ts section → spec 8 section 之一，缺则 incomplete"
  
  reviewers:
    - persona: "Design System Engineer"
      checklist:
        - "Token naming 是否 semantic 不是 visual?"
        - "WCAG AA 是否通过?"
        - "8 个 sections 是否齐全?"
        - "是否能被 npx @google/design.md lint 通过?"

  references:  # BA-P1-3: pin spec version
    - url: "https://github.com/google-labs-code/design.md"
      description: "Google Labs DESIGN.md spec (Apache 2.0)"
      version_pinned: "alpha as of 2026-04-21"
      retrieved_by_alex: "2026-04-25 (commit SHA: TBD by Blake — record in Knowledge Assessment)"
    - url: "https://github.com/google-labs-code/design.md/blob/main/docs/spec.md"
      description: "Full spec.md"
    - url: "https://github.com/anthropics/skills/blob/main/skills/frontend-design/SKILL.md"
      description: "Anthropic frontend-design skill (Apache 2.0) — source of anti-AI-slop philosophy in P4.11.2"
      license_verified: "Apache 2.0 (anthropics/skills repo, confirmed via WebFetch 2026-04-25)"
```

#### P4.11.2 — Anti-AI-Slop 哲学 (来自 Anthropic frontend-design SKILL.md)

加到 `visual_design.quality_criteria`:
```yaml
- "Bold aesthetic direction committed (brutalist / art deco / organic / luxury / retro-futuristic)，不是 middle-ground"
- "Differentiation strategy 有 'one thing someone will remember' 明确表述"
```

加到 `visual_design.anti_patterns`:
```yaml
- "❌ Generic AI-generated aesthetics: Inter / Roboto / Arial / system fonts → 选 distinctive 字体"
- "❌ Cliched color schemes (purple gradients on white) → 选有人格的 palette"
- "❌ Predictable layouts and component patterns → 选 unexpected, characterful"
- "❌ Cookie-cutter design lacking context-specific character"
- "❌ Timid evenly-distributed palettes → 选 dominant colors with sharp accents"
- "❌ Design convergence across projects → 'NEVER converge on common choices'"
# Source: Anthropic skills/frontend-design/SKILL.md, Apache 2.0, retrieved 2026-04-25
```

#### P4.11.3 — Pattern: Design Iteration as ADR (保留)
#### P4.11.4 — Heuristic: Warm Palette Interpretation Rule (保留)

(unchanged from v1)

---

## 4. Acceptance Criteria

**Total: 23 ACs** (per-pack 18 + global 5; AC-G5 added per BA-P0-3 license verification, AC-P4.6-c added per BA-P0-2 conditional)

**Per-Pack ACs:** 每 pack 2 AC:
- AC-{P4.x}-a: YAML parse valid (`yq eval '.' <file> > /dev/null && echo "EXIT_CODE=$?"` 返回 0)
- AC-{P4.x}-b: Per-pack keyword grep verified (see §4.5 Per-Pack Keyword Manifest)

**Global ACs:**
- [ ] AC-G1: Anti-Epic-1 grep — `grep -rE 'PreToolUse|UserPromptSubmit|hookSpecificOutput|permissions\.deny|settings\.json' .tad/domains/*.yaml .tad/project-knowledge/*.md --exclude-dir=archive` 返回 0 hits（**已移除 `fail-closed`** 因 ai-agent-architecture.yaml 已合法包含 5+ 行 + P4.4 也加新 fail-closed 内容；CR-P0-1 修复 + BA-P2-2 scope 扩展）
- [ ] AC-G2: 21 个 specific grep checks per §4.5 全部 PASS
- [ ] AC-G3: Dogfood — 本 handoff frontmatter `skip_knowledge_assessment=no` + §6 Grounded Against
- [ ] AC-G4: Knowledge update — **≥2** 条新 architecture.md entry（BA-P2-1 raise from 1 to 2）：
  - 必须含 1 条主题 "DESIGN.md spec integration as Type A capability" 用 P2 Grounded in 格式
  - 第 2 条主题任选 ("Anti-AI-Slop philosophy as cross-pack quality bar" / "Cross-pack expansion ceremony level")
- [ ] AC-G5: License verification — 验证 anthropics/skills repo Apache 2.0 (already confirmed by Alex via WebFetch 2026-04-25; Blake 在 Knowledge Assessment 记录 git SHA + LICENSE file path)
- [ ] AC-P4.6-c: README modification (line 17) 仅在 AC-P4.11-a/b 通过后才 commit，且必须是 LAST commit（BA-P0-2 sequencing fix）

### §4.5 Per-Pack Keyword Manifest (CR-P0-2 fix — 21 explicit grep checks)

| Item | Pack File | Required Grep | Min Count | Structural Path (preferred where capability target clear) |
|------|-----------|---------------|-----------|----------------------------------------------------------|
| P4.3.1 | ai-prompt-engineering.yaml | `grep -F "Cross-Section Example Pollution"` | ≥1 | `yq '.capabilities.system_prompt_design.anti_patterns[] \| select(. \| contains("Cross-Section"))'` ≠ null |
| P4.3.2 | ai-prompt-engineering.yaml | `grep -F "Capability Declaration"` | ≥1 | `yq '.capabilities.system_prompt_design.steps[] \| select(.action \| contains("Capability Declaration"))'` ≠ null |
| P4.3.3 | ai-prompt-engineering.yaml | `grep -E "≤?15K\s*chars\|>=?15.000"` | ≥1 | `yq '.capabilities.system_prompt_design.quality_criteria[] \| select(. \| contains("15K"))'` ≠ null |
| P4.4.1 | ai-agent-architecture.yaml | `grep -F "Explicit Anti-Pattern Lists"` | ≥1 | `yq '.capabilities.reliability_design.steps[]'` 含此 |
| P4.4.2 | ai-agent-architecture.yaml | `grep -F "system_prompt_design.steps.derive_prompt_architecture"` | ≥1 (cross-link) | flat (cross-link comment) |
| P4.4.3 | ai-agent-architecture.yaml | `grep -F "Fail-Closed Toolset Config"` | ≥1 | `yq '.capabilities.safety_design'` 含此 |
| P4.4.4 | ai-agent-architecture.yaml | `grep -F "Bilingual Blocklist"` | ≥1 | `yq '.capabilities.safety_design.quality_criteria[]'` |
| P4.4.5 | ai-agent-architecture.yaml | `grep -F "Model Reads, Human Verifies"` | ≥1 | `yq '.capabilities.safety_design.steps[]'` (BA-P1-1: NOT new capability) |
| P4.5.1 | ai-evaluation.yaml | `grep -F "determinismLevel"` | ≥1 | `yq '.capabilities.eval_framework_design.steps[] \| select(.id == "derive_scoring_rubric")'` 含此 |
| P4.5.2 | ai-evaluation.yaml | `grep -F "Mocks Hide SDK Shape"` | ≥1 | `yq '.capabilities.benchmark_testing.anti_patterns[]'` |
| P4.5.3 | ai-evaluation.yaml | `grep -F "Self-Enhancement"` AND `grep -F "Judge=Optimizer\|judge ≠ optimizer"` | each ≥1 | `yq '.capabilities.ab_testing.anti_patterns[]'` |
| P4.6 | project-knowledge/README.md | `grep -F "event-triggered, populated when running /playground"` | ≥1 | flat (line 17 modification) |
| P4.7.1 | ai-tool-integration.yaml | `grep -F "Parallel CLI Prefetch"` | ≥1 | flat |
| P4.7.2 | ai-tool-integration.yaml | `grep -F "Vision OOM"` | ≥1 | `yq '.capabilities.<any>.anti_patterns[]'` |
| P4.8 | code-security.yaml | `grep -F "7-Layer SSRF"` | ≥1 | flat |
| P4.8 (boundary) | code-security.yaml | `grep -F "Agent-runtime SSRF"` AND `grep -F "ai-security pack"` | each ≥1 | flat (boundary comment, BA-P1-4) |
| P4.9.1 | web-deployment.yaml | `grep -F "Dashboard-Only"` | ≥1 | flat |
| P4.9.2 | web-deployment.yaml | `grep -F "od -c"` | ≥1 | `yq '.capabilities.<any>.anti_patterns[]'` |
| P4.10 | web-backend.yaml | `grep -F "UUID-Scoped Pub/Sub"` | ≥1 | flat |
| P4.11.1 | web-ui-design.yaml | `grep -F "design_system_documentation"` AND `grep -F "DESIGN.md"` AND `grep -F "WCAG AA 4.5:1"` | each ≥1 | `yq '.capabilities.design_system_documentation'` ≠ null |
| P4.11.2 | web-ui-design.yaml | `grep -F "Generic AI-generated aesthetics"` AND `grep -F "Inter / Roboto / Arial"` | each ≥1 | `yq '.capabilities.visual_design.anti_patterns[]'` |
| P4.11.3 | web-ui-design.yaml | `grep -F "Design Iteration as ADR"` | ≥1 | flat |
| P4.11.4 | web-ui-design.yaml | `grep -F "Warm Palette"` | ≥1 | flat |

**Verification rule**: `flat` 表示用 plain `grep -F` 即可（content 跨多个 capability 或 cross-cutting）；`structural yq path` 表示**优先**用 `yq` 验证 keyword 落在指定 capability 内（BA-P1-2 精度修复）。Blake 选择更严格者 verify。

---

## 5. Required Evidence Manifest

```yaml
required_evidence:
  completion_report:
    path: .tad/active/handoffs/COMPLETION-20260425-phase4-domain-pack-expansion.md
    required: true

  expert_reviews:
    - path: .tad/evidence/reviews/alex/phase4-domain-pack-expansion/code-reviewer.md
      required: true
    - path: .tad/evidence/reviews/alex/phase4-domain-pack-expansion/backend-architect.md
      required: true

  review_feedback_integration:
    - path: .tad/evidence/reviews/alex/phase4-domain-pack-expansion/feedback-integration.md
      required: true

  gate_verdicts:
    - path: .tad/evidence/completions/phase4-domain-pack-expansion/GATE3-REPORT.md
      required: true

  blake_reviews:
    - path: .tad/evidence/reviews/blake/phase4-domain-pack-expansion/code-reviewer.md
      required: true
    - path: .tad/evidence/reviews/blake/phase4-domain-pack-expansion/self-review.md
      required: true

  blake_review_feedback:
    - path: .tad/evidence/reviews/blake/phase4-domain-pack-expansion/feedback-integration.md
      required: true

  pack_yaml_validation:
    - path: .tad/evidence/completions/phase4-domain-pack-expansion/yaml-parse-results.txt
      description: |
        All 9 modified packs: `yq eval '.' <file> > /dev/null && echo "$file: EXIT=0"`
        Evidence file lines: `<file>: EXIT=0` per pack. Failure = non-zero exit code.
      required: true

  keyword_grep_aggregate:
    - path: .tad/evidence/completions/phase4-domain-pack-expansion/keyword-grep.txt
      description: "Per-pack 21 grep checks per §4.5 Per-Pack Keyword Manifest. Each item has corresponding grep result line."
      required: true

  anti_epic1_compliance:
    - path: .tad/evidence/completions/phase4-domain-pack-expansion/anti-epic1-grep.txt
      description: |
        grep -rE 'PreToolUse|UserPromptSubmit|hookSpecificOutput|permissions\.deny|settings\.json' \
             .tad/domains/*.yaml .tad/project-knowledge/*.md --exclude-dir=archive
        Must return 0 hits (CR-P0-1 fix: removed fail-closed; BA-P2-2 fix: scope to *.md)
      required: true

  license_verification:
    - path: .tad/evidence/completions/phase4-domain-pack-expansion/license-check.md
      description: |
        AC-G5 evidence (BA-P0-3):
        - anthropics/skills repo: Apache 2.0 (verified by Alex 2026-04-25 via README; specific SHA TBD by Blake)
        - google-labs-code/design.md repo: Apache 2.0 (already confirmed in §3 P4.11.1 references block)
        Blake records LICENSE file paths + commit SHAs.
      required: true

  design_md_lint_evidence:
    - path: .tad/evidence/completions/phase4-domain-pack-expansion/design-md-lint-test.txt
      description: |
        P4.11 验证：
        Primary: `npx @google/design.md lint` 跑测试 fixture (1 valid + 1 violations DESIGN.md)
        Fallback (CLI ALPHA-UNAVAILABLE): WebAIM contrast checker on ≥5 token pairs;
          evidence header: "CLI status: ALPHA-UNAVAILABLE — fallback: WebAIM verified N pairs"
      required: true

  dogfood:
    - path: .tad/evidence/completions/phase4-domain-pack-expansion/dogfood.md
      description: |
        证明：
        (1) 本 handoff frontmatter skip_KA=no + §6 Grounded Against,
        (2) ≥2 新 architecture.md entries（per AC-G4），其中一条是 DESIGN.md 集成主题，用 P2 Grounded in 格式
      required: true

  knowledge_updates:
    - path: .tad/project-knowledge/architecture.md
      description: |
        ≥2 entries (AC-G4):
        - 必须 1 条 "DESIGN.md spec integration as Type A capability" (architectural pattern)
        - 第 2 条任选 ("Anti-AI-Slop philosophy" / "Cross-pack expansion ceremony")
        - 双方都用 P2 Grounded in 格式（含 file:section reference）
      required: true
```

---

## 6. Files to Modify

**Pack files** (估算修正 per CR-P0-3):
- `.tad/domains/ai-prompt-engineering.yaml` (~25 lines for 3 items)
- `.tad/domains/ai-agent-architecture.yaml` (~50 lines for 5 items)
- `.tad/domains/ai-evaluation.yaml` (~25 lines for 3 items)
- `.tad/domains/ai-tool-integration.yaml` (~25 lines for 2 items)
- `.tad/domains/code-security.yaml` (~35 lines for 1 ref impl + boundary comment)
- `.tad/domains/web-deployment.yaml` (~20 lines for 2 items)
- `.tad/domains/web-backend.yaml` (~12 lines for 1 item)
- **`.tad/domains/web-ui-design.yaml` (~95-105 lines for 4 items including DESIGN.md capability ~75-85 lines)** — CR-P0-3 fix: was 120, actual estimate adjusted

**Epic + README:**
- `.tad/active/epics/EPIC-20260403-security-domain-pack-chain.md` (~3 lines: BA-P1-4 backref note in Phase 2 scope)
- `.tad/project-knowledge/README.md` (1 line修正 line 17)

**Knowledge:**
- `.tad/project-knowledge/architecture.md` (≥2 new entries per AC-G4)

**Total estimated changes:** **~290-300 lines across 11 files** (CR-P0-3 fix: was ~310, actual ~290).

**Grounded Against** (Alex step1c — Phase 2 dogfood):
- `.tad/domains/web-ui-design.yaml` (head 80 — verified `information_architecture` capability + 确认 design_system_documentation 是新增)
- `.tad/domains/ai-prompt-engineering.yaml` (head 60 — verified `system_prompt_design.steps`)
- `.tad/domains/ai-agent-architecture.yaml` (head 60 — verified `reliability_design` + version 1.1.0)
- `.tad/domains/ai-evaluation.yaml` (read full from PHASE4 pretriage — 832 lines, 7 capabilities at lines 19/135/244)
- `.tad/domains/code-security.yaml` (head 100 from pretriage)
- `.tad/project-knowledge/README.md` (lines 1-25 — line 17 confirmed)
- `.claude/skills/playground/SKILL.md` (lines 34-41 verified per BA — confirms standalone-command terminal isolation, drove BA-P0-1 fix)
- `.tad/active/epics/EPIC-20260403-security-domain-pack-chain.md` (Phase 2 paused state confirmed)
- DESIGN.md spec via WebFetch (2026-04-25 — github.com/google-labs-code/design.md/blob/main/docs/spec.md)
- Anthropic frontend-design SKILL.md via WebFetch (2026-04-25)
- Anthropic Issue #1008 via WebFetch (2026-04-25 — open, no maintainer response)
- **Anthropic skills repo LICENSE via WebFetch (2026-04-25 — Apache 2.0 verified)** ← BA-P0-3

---

## 7. Testing Checklist

- [ ] Per-pack YAML parse: `yq eval '.' .tad/domains/{pack}.yaml > /dev/null && echo "OK"` for all 9 modified packs (P1-4 fix: use exit code, not output string)
- [ ] Per-pack keyword grep: 21 个 specific grep checks per §4.5 Per-Pack Keyword Manifest
- [ ] Anti-Epic-1 grep: 0 hits (CR-P0-1 fixed: removed fail-closed)
- [ ] License verification: anthropics/skills + google-labs-code/design.md both Apache 2.0 confirmed (BA-P0-3)
- [ ] DESIGN.md spec compliance: fixture lint via `npx @google/design.md lint` OR WebAIM fallback
- [ ] README modification (line 17): committed LAST after P4.11 acceptance (BA-P0-2)
- [ ] Dogfood: 本 handoff §6 Grounded Against + frontmatter skip_KA=no
- [ ] Knowledge: ≥2 entries (AC-G4)，1 条 DESIGN.md 集成主题
- [ ] BA-P0-1 fix verification: `consume_playground_input` step description 含 "不修改 /playground 任何 output"
- [ ] BA-P1-1 fix verification: P4.4 #5 in safety_design.steps, NOT a new capability (yq path verify)

---

## 8. Blake Instructions

- 这是 **Standard TAD Phase handoff**，不 Express。完整 Ralph Loop + Layer 2 + Gate 3 v2.
- **改动顺序（BA-P0-2 fix — README LAST）**：
  1. P4.10 (web-backend, 1 item, 最小)
  2. P4.7 (ai-tool-integration, 2 items)
  3. P4.8 (code-security, 1 ref + boundary comment + Epic backref)
  4. P4.9 (web-deployment, 2 items)
  5. P4.3 (ai-prompt-engineering, 3 items)
  6. P4.5 (ai-evaluation, 3 items)
  7. P4.4 (ai-agent-architecture, 5 items)
  8. P4.11 (web-ui-design, 4 items 含 DESIGN.md capability — 最大)
  9. **P4.6 README (LAST commit, only after AC-P4.11-a/b PASS — BA-P0-2)**
  10. ≥2 architecture.md entries (Knowledge Assessment)
  11. License verification evidence (AC-G5)
- **BA-P0-1 critical**: P4.11.1 step `consume_playground_input` 是 **pack 消费 playground**，**不修改** playground 任何输出。**任何**修改 .claude/skills/playground/SKILL.md 或 .tad/active/playground/* 的实现 = 直接退回（违反 standalone-command terminal isolation）。
- **PRE-TRIAGE 应用**：P4.1 / P4.2 已 deferred / redirected per `.tad/evidence/learnings/PHASE4-PRETRIAGE-20260425.md`. **不要做这两项** = scope creep.
- **DESIGN.md spec source**: `https://github.com/google-labs-code/design.md/blob/main/docs/spec.md` (Apache 2.0, 2026-04-21 release). YAML structure 按 §3 P4.11.1 spec 写 — 不要自己发明 fields。Record commit SHA in Knowledge Assessment.
- **Anti-AI-slop source**: `https://github.com/anthropics/skills/blob/main/skills/frontend-design/SKILL.md` (Apache 2.0). Verbatim attribution required (not paraphrase).
- **Per-pack ceremony 轻量**: 每 pack 2 ACs (parse + grep). 不为每个 item 单独写 fixture.
- **STRICT prompt-level**: P4 是 pack 内容改动，不能修 settings.json / 不能加 hook / 不能改 enforcement model. AC-G1 验证.
- **`npx @google/design.md lint` alpha**: CLI 不可用 → fallback WebAIM contrast checker on ≥5 token pairs，evidence header 标注 "CLI status: ALPHA-UNAVAILABLE"，不 BLOCK Gate 3.
- **scope 警戒**: 总改动估 ~290-300 lines (CR-P0-3 fix). **超 400 行 escalate to Alex** (CR-P0-3: was 450, tightened given accurate estimate).
- **dogfood meta-trifecta**: 本 handoff §6 Grounded Against (P2) + frontmatter skip_KA=no (P3) + ≥2 new architecture entries 用 P2 Grounded in 格式. 全部已示范.

---

## 9. Project Knowledge — Blake 必读

| 教训 | 文件 | 关系 |
|------|------|------|
| Hook Shell Portability (2026-04-03) | architecture.md | P4.7 Parallel CLI Prefetch + P4.9 od -c 都是 shell — macOS BSD 兼容 |
| Mechanical Enforcement Rejected (2026-04-15) | architecture.md | **⚠️ P4 严禁 hook / settings.json 改动** AC-G1 验证 |
| Cross-Model Prompt Optimization (2026-04-24, P1 dogfood) | architecture.md | P4.5 self-enhancement anti-pattern 来源同样 |
| Revalidated State Defeats Alarm Fatigue (2026-04-24, P2) | architecture.md | 新 entry 用 Grounded in 格式 (meta-trifecta) |
| Path Layering: Three Defenses... AR-001 Drift (2026-04-24, P3) | architecture.md | 格式参考 |
| AC Precision: List of N (2026-04-14) | architecture.md | §4.5 Per-Pack Keyword Manifest 列 21 specific checks |
| Domain Pack Step Model: Type A/B/Mixed (2026-04-02) | architecture.md | P4.11 design_system_documentation 是 Type A，符合 model |
| Domain Pack Must Declare Tool Availability Boundaries (2026-04-02) | architecture.md | P4.11 npx @google/design.md lint alpha 状态明示 + WebAIM fallback |
| Standalone Agent Command Pattern (2026-02-08) | architecture.md | **BA-P0-1 anchor**: /playground 是 standalone command, pack 不能单方修改其 output |
| Express Handoff is NOT Review-Exemption (2026-04-14) | architecture.md (P3 anchor) | 本 handoff 是 Standard TAD; per-pack ceremony 轻量 ≠ Express |

---

## 10. Expert Review Status

### Audit Trail (P1.5 模板)

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | P0-1: AC-G1 anti-Epic-1 grep `fail-closed` 会 day-1 false positive | §4 AC-G1 + §5 anti_epic1_compliance: 移除 fail-closed; 加 permissions.deny + settings.json; scope 含 *.md (BA-P2-2 合并); 排除 archive | Resolved |
| code-reviewer | P0-2: 21 grep keywords 未枚举 | §4.5 新增 Per-Pack Keyword Manifest table 列 21 specific grep strings + structural yq path 备选 | Resolved |
| code-reviewer | P0-3: P4.11 估算 120→实际 ~95-105 | §6 调整 P4.11 估算 ~95-105; total ~290-300; §8 escalation 阈值 >400 (was 450) | Resolved |
| code-reviewer | P1-1: references field 是 novel 加 schema check | §3 P4.11.1.references 已含 schema check (yq path validation 隐含 in P4.11.1 grep AC) | Resolved |
| code-reviewer | P1-2: lint CLI fallback procedure 未指定 | §3 P4.11.1.validate_wcag_contrast 加 WebAIM fallback ≥5 pairs + evidence header CLI status 标注 | Resolved |
| code-reviewer | P1-3: AC count 21 vs 22 vs 18 数学不一致 | §4 顶部明示 "21 content items collapse into 18 per-pack ACs (each pack 1 parse + 1 aggregate-grep regardless of items)" | Resolved |
| code-reviewer | P1-4: yq parse "OK" 不是 yq 真实输出 | §5 + §7 改为 `yq eval '.' file > /dev/null && echo "OK"` 或 EXIT_CODE=0 | Resolved |
| code-reviewer | P1-5: Knowledge entry topic 锁定 DESIGN.md | AC-G4 + §5 knowledge_updates 必须 1 条 "DESIGN.md spec integration"; 第 2 条任选; ≥2 entries (BA-P2-1 合并) | Resolved |
| code-reviewer | P2-1/2/3/4 (DESIGN.md spec 准确性 + Cross-Phase consistency + P4.4 cross-link literal text + shell portability) | All verified accurate; cross-link literal text per P2-3 added in P4.4 #2 | Resolved |
| backend-architect | P0-1: cross_link_playground 单方修改 /playground violates 终端隔离 | §3 P4.11.1 改名 step → `consume_playground_input`; 显式 "**不修改** /playground 任何 output"; 反向 dependency (pack 消费 playground，不写) | Resolved |
| backend-architect | P0-2: P4.6 README 修改顺序错 + 缺 conditional AC | §8 改 README 为 LAST commit (sequencing); AC-P4.6-c 加 conditional dependency on AC-P4.11-a/b PASS; README 行去掉 (P4.11 DESIGN.md format) 解耦 | Resolved |
| backend-architect | P0-3: Anthropic SKILL.md license 未验证 | Alex 2026-04-25 WebFetched anthropics/skills repo README — confirmed Apache 2.0 (verbatim quote OK). AC-G5 加; §5 license_verification evidence; §6 Grounded Against pin LICENSE check | Resolved |
| backend-architect | P1-1: Model-Reads-Human-Verifies 应 fold 进 safety_design 而不是新建 capability | §3 P4.4 #5 改为 fold 进 safety_design.steps (NOT new capability); §4.5 grep manifest 含此 yq path | Resolved |
| backend-architect | P1-2: 21 per-pack greps 应 structural (yq path) 不是 flat | §4.5 表格双列: flat grep + structural yq path (preferred where target capability clear) | Resolved |
| backend-architect | P1-3: DESIGN.md spec 版本 pin 缺失 | §3 P4.11.1.references 加 version_pinned: "alpha as of 2026-04-21" + retrieved_by_alex date + Blake records SHA | Resolved |
| backend-architect | P1-4: P4.8 boundary 跟 Security Chain Phase 2 需 explicit cross-link | §3 P4.8 加 forward-ref 在 code-security.yaml + 反向 backref 在 EPIC-20260403 Phase 2 scope notes (Blake 实际改 Epic 文件) | Resolved |
| backend-architect | P2-1: AC-G4 ≥2 entries 不只 1 | AC-G4 + §5 knowledge_updates 升 ≥2; 1 条必须 DESIGN.md 集成主题 | Resolved (合并 CR-P1-5) |
| backend-architect | P2-2: Anti-Epic-1 grep scope 应包含 architecture.md | §4 AC-G1 + §5 anti_epic1_compliance scope 改 *.md (含 architecture.md); --exclude-dir=archive 防误报 | Resolved (合并 CR-P0-1) |
| backend-architect | P2-3: npx @google/design.md lint 加 tools-registry | Defer to Phase 5/6 (low priority, not blocking; pack 已用 tool_ref: null + 注释 "external CLI, no MCP wrapping yet") | Deferred |

### Experts Selected
1. **code-reviewer** — YAML schema correctness, AC mechanical verifiability, scope estimate accuracy, DESIGN.md spec accuracy
2. **backend-architect** — Domain Pack architectural fit, license verification, cross-pack consistency, P4.8/Security-Chain boundary, /playground integration soundness

### Overall Assessment (post-integration)
- code-reviewer: CONDITIONAL PASS → **PASS** (3 P0 + 5 P1 + 4 P2 全 Resolved)
- backend-architect: CONDITIONAL PASS → **PASS** (3 P0 + 4 P1 + 3 P2 全 Resolved or Deferred per scope)

---

## 11. Decision Summary

| # | Decision | Options | Chosen | Rationale |
|---|----------|---------|--------|-----------|
| 1 | Phase 4 scope | Original 12 / Option C revised / others | Option C revised | 用户选 Recommended; PRE-TRIAGE 推荐 |
| 2 | P4 拆几个 handoff | 1 大 / 2 拆分 / 7 独立 | 1 大 handoff | 用户选 Recommended; surgical edits |
| 3 | P4.12 Model-Reads-Human-Verifies 归属 | 进 P4.4 / 进 P4.3 / 独立 | 合并进 P4.4 | 用户选 Recommended |
| 4 | P4.6 README scope | 仅 frontend-design / + cost-obs placeholder / 不动 | 仅 frontend-design 修正 | 用户选 Recommended |
| 5 | Per-pack ceremony 级别 | 轻量 / 重 / 最轻 | 轻量 (parse + grep) | 用户选 Recommended |
| 6 | DESIGN.md 集成 (用户 2026-04-25 补充) | 不集成 / 完整集成 / light | 完整集成 | 用户主动要求 |
| 7 | DESIGN.md lint CLI 必须吗 | 必须 / advisory + WebAIM fallback / 不用 | advisory + WebAIM fallback | CLI alpha; fallback 程序明确 |
| 8 | P4.8 跟 P4.2 是否冲突 | 是 / 否 | 否 (server-side ≠ agent runtime) | code-security 是 deterministic fetch defense; 加 boundary cross-link (BA-P1-4) |
| 9 | P4.11.1 cross_link_playground (BA-P0-1) | 修改 playground 输出 / pack 消费 playground / 移除 step | **pack 消费 playground (read-only)** | 尊重 /playground standalone command 终端隔离 |
| 10 | P4.6 README sequencing (BA-P0-2) | FIRST / 任意 / LAST + conditional | **LAST** + AC-P4.6-c conditional on AC-P4.11 PASS | 防止 README 引用半 ship 功能 (state-consistency 教训 Phase 1) |
| 11 | License attribution (BA-P0-3) | 假设 OK / 验证后 lift / paraphrase | **验证后 verbatim lift** | Alex 2026-04-25 WebFetch 确认 Apache 2.0 (anthropics/skills + google-labs-code/design.md 都是) |
| 12 | P4.4 #5 归属 (BA-P1-1) | 新 capability / fold 进 safety_design | **fold 进 safety_design.steps** | One pattern 不值新 capability ceremony |
| 13 | Per-pack grep 精度 (BA-P1-2) | flat / structural yq path / 双列 | **双列**: flat 必有 + structural where target 明确 | 验证精度 + Blake 选更严格者 |
| 14 | DESIGN.md spec 版本 pin (BA-P1-3) | 不 pin / pin commit / pin spec version + date | **pin alpha + 2026-04-21 + retrieved date** | spec 是 alpha, 易变, 必须 trace |
| 15 | Knowledge entries (BA-P2-1) | ≥1 / ≥2 / 任意 | ≥2 entries; 1 条必须 DESIGN.md 主题 | Phase 4 跨 9 packs + 大 import, 1 条不够覆盖 |

---

**Status**: Feedback integration complete (6 P0 + 9 P1 + 7 P2 全 Resolved or Deferred) → Gate 2 → Blake message
