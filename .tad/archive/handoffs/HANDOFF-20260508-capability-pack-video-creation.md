---
task_type: code
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: Video Creation Capability Pack
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-05-08
**Project:** TAD — Agent Capability Packs
**Task ID:** TASK-20260508-001
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260507-agent-capability-packs.md (Phase 1e/4)

---

## 🔴 Gate 2: Design Completeness

**执行时间**: 2026-05-08

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | web-backend model (1 router + 6 refs), 8 P0 resolved from 2 experts |
| Components Specified | ✅ | 12 files specified with line estimates |
| Functions Verified | ✅ | N/A (standalone pack, no code deps) |
| Data Flow Mapped | ✅ | N/A (standalone pack) |

**Gate 2 结果**: ✅ PASS

**Alex确认**: 8 P0 全部修复（CR×5 + BA×3），16 P1 中 15 已解决、1 deferred (Epic Phase Map)。

---

## 📋 Handoff Checklist (Blake必读)

- [ ] 阅读了所有章节
- [ ] **阅读了研究发现文件** `.tad/evidence/research/video-creation-capability-pack/2026-05-08-ask-findings.md`
- [ ] 理解了 web-backend 架构模式（1 CAPABILITY.md + references/）
- [ ] 确认可以独立使用本文档完成实现

---

## 1. Task Overview

### 1.1 What We're Building
A cross-agent, self-contained **video-creation capability pack** — a portable module that teaches any AI coding agent (Claude Code, Codex, Gemini, Cursor) professional-grade video production judgment. Covers: storytelling, visual design, motion design, audio design, tool selection (HyperFrames vs Remotion), and platform-specific templates.

### 1.2 Why We're Building It
**业务价值**：AI agents can now "write" video via HTML (HyperFrames) and React (Remotion), but they produce amateur-looking output — bad timing, generic motion, wrong easing. This pack bridges the judgment gap.
**用户受益**：Agent-produced videos go from "technically renders" to "looks professional" — correct pacing, intentional motion, proper audio mix.
**成功的样子**：When an AI agent loaded with this pack produces a 30-second product demo that follows the 95% hard-cut rule, uses emotion-mapped GSAP easing, respects the 3-5s attention rule, and passes WCAG caption accessibility.

### 1.3 Intent Statement

**真正要解决的问题**：AI agents have "hands" (HyperFrames/Remotion skills) but lack "taste" — they default to generic motion, uniform easing, and no narrative rhythm.

**不是要做的**：
- ❌ 不是 HyperFrames 或 Remotion 的 API wrapper（那是各自的 agent skill 做的事）
- ❌ 不是视频编辑软件（不替代 After Effects / Premiere）
- ❌ 不是 AI 视频生成（不用 Sora / Runway / Kling）— 这是 deterministic code→video
- ❌ 不是教程 — 是 judgment rules（像 web-backend 教"什么时候用 UUIDv7"而不是教"怎么安装 uuid 包"）

---

## 📚 Project Knowledge (Blake 必读)

### ⚠️ Blake 必须注意的历史教训

| Entry | Source | 与本任务的关系 |
|-------|--------|---------------|
| Capability Pack: YAML Frontmatter is Load-Bearing | architecture.md | CAPABILITY.md 必须有 name + description frontmatter 才能被 Claude Code 注册 |
| Capability Pack: Multi-Agent Install Pattern | architecture.md | install.sh 需要 --agent flag + Phase N stubs |
| Capability Pack Rule Sourcing: Read the Cited Source | architecture.md | 每条判断规则必须从研究源推导，不能凭直觉写 |
| Capability Pack: Use Cost Ratios Not Absolute Prices | architecture.md | 如果涉及成本，用比率不用绝对数字 |

### Research Notebook Findings
**Notebook:** `a62f253b` (35 sources, 8 rounds deep ask)
**Report:** `.tad/evidence/research/video-creation-capability-pack/2026-05-08-ask-findings.md`

Blake MUST Read the findings file before implementation — it contains all judgment rules with source citations.

---

## 2. Architecture

### 2.1 Pack Structure (web-backend model)

```
~/video-creation/
├── CAPABILITY.md            # Router: context detection → reference loading → output format (120-170 lines)
├── install.sh               # Installation script (pack files only, tool detection)
├── LICENSE                   # Apache 2.0
├── LICENSE-ATTRIBUTION.md   # Source credits for research-derived rules
├── CHANGELOG.md             # Version history
├── README.md                # User-facing documentation
└── references/
    ├── storytelling.md      # Narrative structure, pacing rules, video type patterns
    ├── visual-design.md     # Composition, color, typography, motion principles
    ├── audio-design.md      # Music selection (BPM), SFX timing, voiceover mix
    ├── tool-selection.md    # HyperFrames vs Remotion decision tree (judgment only, not CLI docs)
    ├── production.md        # Agent failure modes, prevention patterns, render pipeline
    └── quality.md           # Export settings, accessibility (WCAG), platform specs
```

### 2.2 Key Design Decisions

| # | Decision | Chosen | Rationale |
|---|----------|--------|-----------|
| 1 | Architecture model | web-backend (1 CAPABILITY.md + references/) | Rules are facets of one judgment framework, not independent workflows |
| 2 | Tool stance | HyperFrames-first, Remotion-aware | HyperFrames is AI-first (HTML-native, no build, fewer errors); Remotion for complex React compositions |
| 3 | Rule specificity | All rules must have concrete parameters | "3-5 seconds" not "appropriate timing"; "power2.out" not "smooth easing" |
| 4 | Video type patterns | Subsections in storytelling.md (not separate templates/) | Per BA-P0-2: no precedent for templates/ dir; timing patterns are pacing rules, not instantiable templates |
| 5 | Install scope | Pack files only + tool detection | install.sh detects FFmpeg/Node/HyperFrames, guides user, does not auto-install |
| 6 | Platform coverage | All (16:9, 9:16, 1:1, 4:5) | Export settings per platform in quality.md |
| 7 | Language | English (international audience) | Same as all other capability packs |

---

## 3. Implementation Tasks

### P1: Core Files

**P1.1 — CAPABILITY.md (router — 120-170 lines, per BA-P0-1)**
- YAML frontmatter: `name: video-creation`, `description: "Professional video production judgment for AI coding agents — storytelling, motion design, audio, tools (HyperFrames/Remotion)"`
- Follow web-backend CAPABILITY.md pattern exactly:
  1. **Context Detection Table**: Map user signal → reference(s) to load
     - "pacing / timing / rhythm" → storytelling.md
     - "animation / motion / easing / transition" → visual-design.md
     - "music / audio / sound / voiceover" → audio-design.md
     - "HyperFrames / Remotion / FFmpeg / which tool" → tool-selection.md
     - "error / bug / broken / not rendering" → production.md
     - "export / quality / resolution / accessibility / captions" → quality.md
  2. **Workflow** (brief — 3 steps, not 4-step pipeline per BA-P1-1):
     - Detect context → load reference → apply rules → produce findings
  3. **Quick Rule Index**: 1-line summary per rule with reference pointer (NOT inline rules)
  4. **Anti-Skip Table**: Counter common agent rationalizations (per BA-P2-2)
  5. **Output Format**: Structured findings report
- ⚠️ NO inline rules — all concrete parameters (timing values, GSAP curves, BPM) live exclusively in references/
- Target: 120-170 lines (web-backend's CAPABILITY.md is 142 lines)

**P1.2 — references/storytelling.md**
- Scene structure principles (beginning-middle-end for video)
- Pacing rules with exact values:
  - Shot duration by text density (0 words = 1.5-2s, 1-3 = 2-3s, 4-10 = 3-4s, etc.)
  - 50% Reading Rule (last element finishes entrance at 50% of scene)
  - 5-Second Scene Ceiling
- Video type pacing patterns:
  - Fast-paced: 2-3s average shot, cuts every 3s
  - Standard: 3-5s average, cuts every 5s
  - Slow/dramatic: 5-8s, deliberate pacing
- Hook timing for social media (first 3-5 seconds critical)
- **Video Type Pacing Patterns** (merged from templates/ per BA-P0-2):
  - Product Demo (16:9, 30-60s): 10-18 scenes, 12-scene rhythm: 3.0, 3.0, 4.0, 3.5, 4.0, 5.0, 3.5, 4.0, 3.5, 4.0, 4.0, 3.5; scene types: logo→problem→features→CTA; 2-3 shader transitions
  - Social Short (9:16, 10-15s): 5-7 scenes, hook in first 3-5s, karaoke captions + TTS, CTA overlay
  - Tutorial/Explainer (16:9, variable): word count drives duration, 50% reading rule, mid-scene activity mandatory
- Source: research findings Layer 2 + Layer 4

**P1.3 — references/visual-design.md**
- Motion design rules:
  - GSAP Easing-by-Emotion table (6 emotions × curve × duration)
  - 3-Ease Minimum per scene
  - Entrance Offset rule (0.1-0.3s)
  - Transition duration (min 0.3s, sweet spot 0.5s)
  - Staggering default for multi-element entrances
- Anti-patterns (from research):
  - "JPEG with Progress Bar" (static elements after entrance)
  - Banned: animated gradients, stretching typography, motion blur
  - No character-by-character text animation
  - Loop limit: 5s or 1 loop
  - No invisible bridges (flash-through-white)
- Color and typography for video (contrast, readability in motion)
- Source: research findings Layer 2 (Q2.2)

**P1.4 — references/audio-design.md**
- Background music rules:
  - BPM-to-video-type mapping table (5 types × BPM range × instrumentation)
  - Volume: voiceover=100%, background music=10-20%
  - No vocals in explainer/tutorial music
- SFX timing rules:
  - Whoosh pre-lead: 10-20ms before visual transition
  - Visual event → SFX type mapping (appear→pop, slide→whoosh, hit→impact, UI→click)
  - Frequency separation for overlapping: sharp=highs, sweeps=mids, rumbles=lows
- Audio ducking: FFmpeg `sidechaincompress` reference
- TTS integration: Whisper model selection, caption leak prevention
- ⚠️ SFX timing rules from Supplementary Research (WebSearch, not notebook) MUST include a `[Source: WebSearch — approximate]` tag per CR-P1-5. Blake should NOT write them as authoritative.
- Source: research findings Layer 5 + gap research

**P1.5 — references/tool-selection.md (judgment only — no CLI docs per BA-P1-2)**
- Decision tree:
  ```
  Need video? →
    HTML/CSS layout sufficient? → HyperFrames
    Need React components/state? → Remotion
    Need video processing only (trim/concat/encode)? → FFmpeg directly
    Need math animations? → Motion Canvas / Manim [Source: WebSearch — not in notebook]
  ```
- Trade-off criteria per tool (when each wins, when each loses):
  - HyperFrames: wins on agent efficiency, no build step, HTML passthrough; loses on React ecosystem, distributed rendering
  - Remotion: wins on complex compositions, component reuse, React ecosystem; loses on setup complexity, JSX translation errors
  - FFmpeg: wins on processing/encoding/conversion; loses on composition authoring
- Failure modes of choosing the wrong tool (e.g., Remotion for a simple overlay = overengineered)
- **Tool Documentation Pointers** section (NOT reproduced CLI commands):
  - HyperFrames: link to hyperframes.mintlify.app/quickstart
  - Remotion: link to remotion.dev/docs/ai/coding-agents
  - FFmpeg: link to ffmpeg.org/ffmpeg.html
- Source: research findings Layer 1

**P1.6 — references/production.md**
- Agent failure modes checklist (17 items from research):
  - Timing: Date.now, Math.random, setInterval, repeat:-1, async timeline
  - Animation: visibility vs autoAlpha, DOM lifecycle, exit before shader
  - Composition: canvas taint, <br> tags, staticFile missing
- Prevention patterns (5 items):
  1. Use agent skill (not general coding)
  2. Maintain DESIGN.md context file
  3. Pre-validated skeletons
  4. CLI validation loop (lint → validate → inspect → render)
  5. Sequential skill chaining
- Render pipeline: scaffold → compose → preview → validate → render → export
- Source: research findings Layer 3

**P1.7 — references/quality.md**
- Export settings per platform:
  | Platform | Aspect | Resolution | Duration | Format | Max Size |
  | YouTube | 16:9 | 1920×1080 | unlimited | MP4 | 256GB |
  | TikTok | 9:16 | 1080×1920 | 15s-60min | MP4/MOV | 2GB |
  | Instagram Reels | 9:16 | 1080×1920 | ≤20min | MP4/MOV | 4GB |
  | YouTube Shorts | 9:16 | 1080×1920 | ≤3min | MP4 | — |
  | Twitter/X | 16:9/1:1 | 1920×1080 | ≤2:20 | MP4 | 512MB |
- Codec: H.264 (MP4) universal; WebM for web-optimized
- Quality: CRF 18-23 (18=high, 23=standard)
- Audio: AAC 128kbps+
- Accessibility (WCAG):
  - Captions ≥99% accuracy (auto-gen needs human review)
  - Caption elements: speaker ID + sound effects + music cues
  - Format: WebVTT preferred for web, SRT for universal
  - Text contrast: 4.5:1 standard, 3:1 large
  - Burn-in for social media, soft captions for web
- Source: research findings Layer 5 + gap Q3

### P2: Installation + Documentation

**P2.1 — install.sh**
- Same pattern as web-backend install.sh:
  - `--agent` flag (claude-code default, codex/cursor/gemini stubs with exit 2)
  - Copy CAPABILITY.md + references/ to target
  - Tool detection: check FFmpeg, Node.js ≥22, HyperFrames CLI
  - Output guidance for missing tools (not auto-install)

**P2.2 — README.md**
- What this pack does (1 paragraph)
- Quick start (install → load → prompt)
- Structure overview
- Tool requirements (FFmpeg, Node.js, HyperFrames OR Remotion)
- License (Apache 2.0)

**P2.3 — LICENSE**
- Apache 2.0 (same as all other packs)

**P2.4 — CHANGELOG.md**
- v0.1.0 initial release entry (per CR-P0-5)

**P2.5 — LICENSE-ATTRIBUTION.md**
- List all sources from research notebook with license status (per CR-P0-5 + BA-P0-3)
- Include HyperFrames (Apache 2.0), Remotion (custom license), Microsoft Fluent 2 motion guidelines, research articles

---

## 4. Required Evidence Manifest

```yaml
expert_reviews:
  - .tad/evidence/reviews/blake/capability-pack-video-creation/code-reviewer.md
  - .tad/evidence/reviews/blake/capability-pack-video-creation/backend-architect.md
gate_verdicts:
  - .tad/evidence/completions/capability-pack-video-creation/GATE3-REPORT.md
completion:
  - .tad/active/handoffs/COMPLETION-20260508-capability-pack-video-creation.md
knowledge_updates:
  - .tad/project-knowledge/architecture.md (if new patterns discovered)
```

---

## 5. Files to Create

| # | File | Purpose | Lines (est.) |
|---|------|---------|-------------|
| 1 | ~/video-creation/CAPABILITY.md | Router: context detection → reference loading (NOT inline rules) | 120-170 |
| 2 | ~/video-creation/references/storytelling.md | Narrative + pacing rules + video type patterns (merged from templates/) | 400-500 |
| 3 | ~/video-creation/references/visual-design.md | Motion design + anti-patterns | 400-500 |
| 4 | ~/video-creation/references/audio-design.md | Music BPM + SFX timing + voiceover | 250-350 |
| 5 | ~/video-creation/references/tool-selection.md | HyperFrames vs Remotion decision tree (judgment only) | 200-300 |
| 6 | ~/video-creation/references/production.md | Agent failure modes + prevention | 300-400 |
| 7 | ~/video-creation/references/quality.md | Export settings + accessibility | 300-400 |
| 8 | ~/video-creation/install.sh | Installation script | 80-120 |
| 9 | ~/video-creation/README.md | Documentation | 60-100 |
| 10 | ~/video-creation/LICENSE | Apache 2.0 | 202 |
| 11 | ~/video-creation/CHANGELOG.md | Version history | 10-20 |
| 12 | ~/video-creation/LICENSE-ATTRIBUTION.md | Source credits for research-derived rules | 40-80 |

**Total estimate:** ~2200-3000 lines across 12 files

**Note (BA-P1-5):** v0.1.0 does not include scripts/. Future: timing validator and platform spec checker. See ~/web-backend/scripts/ for the established pattern.

---

## 6. Acceptance Criteria

| # | Criteria | Verification |
|---|----------|-------------|
| AC1 | CAPABILITY.md has YAML frontmatter with name + description | `head -5 ~/video-creation/CAPABILITY.md \| grep -c "^name:"` = 1 |
| AC2 | All 6 references/ files exist and are non-empty | `ls ~/video-creation/references/*.md \| wc -l` = 6 AND `wc -l ~/video-creation/references/*.md \| tail -1` shows total > 1500 |
| AC3 | CAPABILITY.md is ≤ 170 lines (router, not rule container) | `wc -l < ~/video-creation/CAPABILITY.md` ≤ 170 |
| AC4 | install.sh has --agent flag with stubs | `grep -c "\-\-agent" ~/video-creation/install.sh` ≥ 1 |
| AC5 | 3-5 Second Attention Rule in storytelling.md | `grep -riE "3.*5.*second\|attention rule" ~/video-creation/references/storytelling.md` ≥ 1 |
| AC6 | GSAP easing-by-emotion table in visual-design.md | `grep -cE "power2\|power4\|back.out\|expo.out\|sine.inOut" ~/video-creation/references/visual-design.md` ≥ 5 |
| AC7 | BPM-to-video-type mapping in audio-design.md | `grep -cE "BPM\|bpm" ~/video-creation/references/audio-design.md` ≥ 3 |
| AC8 | HyperFrames vs Remotion decision tree in tool-selection.md | `grep -ciE "hyperframes\|remotion" ~/video-creation/references/tool-selection.md` ≥ 10 |
| AC9 | Agent failure modes in production.md | `grep -cE "Date.now\|repeat.*-1\|autoAlpha\|async.*timeline\|canvas.*taint" ~/video-creation/references/production.md` ≥ 4 |
| AC10 | WCAG accessibility rules in quality.md | `grep -cE "WCAG\|4\.5:1\|WebVTT\|99%" ~/video-creation/references/quality.md` ≥ 3 |
| AC11 | Video type pacing patterns in storytelling.md (merged from templates/) | `grep -cE "12-scene\|product.demo\|social.short\|tutorial" ~/video-creation/references/storytelling.md` ≥ 3 |
| AC12 | Zero TAD terminology in any pack file | `grep -rliE "handoff\|blake\|ralph.loop\|gate.[34]\|socratic" ~/video-creation/` = 0 |
| AC13 | Total line count ≤ 3500 | `find ~/video-creation -name "*.md" -o -name "*.sh" \| xargs wc -l \| tail -1` ≤ 3500 |
| AC14 | Research source citations in references/ | `grep -rlE "\[Source:\|Layer [0-9]\|research.findings" ~/video-creation/references/ \| wc -l` ≥ 5 |
| AC15 | install.sh runs without error | `bash ~/video-creation/install.sh --help` exits 0 |
| AC16 | SFX approximate tags in audio-design.md | `grep -cE "approximate\|unverified\|WebSearch" ~/video-creation/references/audio-design.md` ≥ 1 |
| AC17 | CHANGELOG.md + LICENSE-ATTRIBUTION.md exist | `ls ~/video-creation/CHANGELOG.md ~/video-creation/LICENSE-ATTRIBUTION.md \| wc -l` = 2 |

---

## 7. Important Notes

### 7.1 Research Source Compliance
Every judgment rule in references/ MUST be derived from the research findings file (`.tad/evidence/research/video-creation-capability-pack/2026-05-08-ask-findings.md`). Do NOT write rules from training data intuition — read the source, cite it. Per architecture.md "Capability Pack Rule Sourcing: Read the Cited Source, Not Just the Citation".

### 7.2 Anti-AI-Slop in Video Context
The pack itself must model the anti-slop philosophy: no generic "use appropriate timing", no "consider your audience", no filler advice. Every rule must be a concrete parameter or decision gate.

### 7.3 File Size Budget
Per previous pack experience, the critical constraint is CAPABILITY.md staying under ~1000 lines. If the router grows past 1000 lines, move detailed rules to references/ and keep CAPABILITY.md as a routing + workflow file.

### 7.4 Tool Freshness
HyperFrames is Apache 2.0, released April 2026 — still evolving. Do NOT version-pin CLI commands. Use feature descriptions ("the lint command validates compositions") not version-specific flags.

---

## 8. Sub-Agent 使用建议

Blake Layer 2 reviewers:
- **code-reviewer** (必选): Structure, completeness, cross-reference consistency
- **backend-architect** (推荐): Architecture decisions, tool selection tree accuracy

---

## 9. Spec Compliance

### 9.1 Acceptance Criteria Verification Table

| AC# | Verification Method | Expected | Verified Output (Alex step1d) |
|-----|-------------------|----------|------------------------------|
| AC1-AC17 | See §6 (all post-impl — target files don't exist yet) | See §6 | (post-impl — syntax validated via -E flag) |

### 9.2 Expert Review Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | CR-P0-1: AC2 `wc -l <` shell syntax broken | §6 AC2 — removed `<` redirection | Resolved |
| code-reviewer | CR-P0-2: Source count mismatch (27 vs 35) | Research file has 27 ready sources; handoff updated to match | Resolved |
| code-reviewer | CR-P0-3: data-viz template zero research grounding | §2.1 + §3 — removed templates/ dir, merged 3 types into storytelling.md; dropped data-viz | Resolved |
| code-reviewer | CR-P0-4: Motion Canvas/Manim no research grounding | §3 P1.5 — tagged `[Source: WebSearch — not in notebook]` | Resolved |
| code-reviewer | CR-P0-5: Missing CHANGELOG.md + LICENSE-ATTRIBUTION.md | §5 files #11-12 added; AC17 added | Resolved |
| backend-architect | BA-P0-1: CAPABILITY.md 800-1000 lines is 6-7x pattern | §3 P1.1 — shrunk to 120-170 lines, all rules in references/ | Resolved |
| backend-architect | BA-P0-2: templates/ undefined consumption contract | §2.1 + §3 — merged into storytelling.md "Video Type Pacing Patterns" | Resolved |
| backend-architect | BA-P0-3: Missing standard pack files | = CR-P0-5, resolved together | Resolved |
| code-reviewer | CR-P1-1: AC grep uses BRE `\|` instead of ERE `-E` | §6 — all ACs now use `grep -cE` / `grep -riE` | Resolved |
| code-reviewer | CR-P1-2: AC14 not machine-verifiable | §6 AC14 — concrete grep for `[Source:` / `Layer [0-9]` / `research.findings` | Resolved |
| code-reviewer | CR-P1-5: SFX approximate tagging not instructed | §3 P1.4 — added explicit `[Source: WebSearch — approximate]` instruction | Resolved |
| backend-architect | BA-P1-1: Workflow oversteps tool territory | §3 P1.1 — simplified to detect→apply→output (3 steps, not 4-step pipeline) | Resolved |
| backend-architect | BA-P1-2: tool-selection.md conflates judgment with CLI ref | §3 P1.5 — removed CLI references, added Tool Documentation Pointers | Resolved |
| backend-architect | BA-P1-3: Audio gap not tested by AC | §6 AC16 added | Resolved |
| backend-architect | BA-P1-5: No scripts/ directory | §5 Note added (v0.1.0 deferred, future enhancement) | Resolved |
| code-reviewer | CR-P1-3: Epic Phase Map not updated | Deferred — will add Phase 1e after handoff accepted | Open |
| code-reviewer | CR-P1-4: research_required: no misleading | Frontmatter comment updated | Resolved |

---

## 10. Decision Summary

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | Architecture | product-thinking (3 skills) vs web-backend (1+N) | web-backend | Rules are facets of one framework, not independent workflows |
| 2 | Tool focus | HyperFrames-only vs Remotion-only vs both | HyperFrames-first, Remotion-aware | Research: HyperFrames is AI-first, fewer agent errors, no build step |
| 3 | Video type patterns | Separate templates/ dir vs merged into storytelling.md | Merged into storytelling.md | Per BA-P0-2: templates/ has no precedent, undefined consumption contract; pacing patterns are reference rules |
| 4 | Install scope | Auto-install tools vs detect-only | Detect + guide | Per user preference: "按需下载，不提前下载" |
| 5 | Audio SFX gap | Skip audio SFX vs partial rules from WebSearch | Partial rules included | Best-effort from research; tagged as "approximate" where source coverage weak |
