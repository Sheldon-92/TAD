# Idea: Structured Feedback Collector — HTML-based Human Judgment Interface

**ID:** IDEA-20260610-structured-feedback-collector
**Date:** 2026-06-10
**Status:** captured
**Scope:** large

---

## Summary & Problem

AI can produce artifacts fast (code, pages, audio, video, brands) but cannot judge whether the output is "good" in non-code domains — that judgment lives entirely in the human. The current feedback channel is broken: natural language descriptions are ambiguous ("the title feels wrong"), and there's no structured way for non-technical users to point at specific elements and say what to change. This idea proposes that AI should generate both the artifact AND a structured feedback interface (HTML) alongside it. The human fills out the interface, exports JSON, and the AI precisely applies the feedback in the next iteration.

## Core Mechanism

Three-layer model:
1. **Layer 1 — Generate artifact**: AI produces the deliverable (page, audio, video, brand asset)
2. **Layer 2 — Generate feedback interface**: AI decomposes the artifact into reviewable atomic elements, each with structured options + free-form input. Renders as an HTML page.
3. **Layer 3 — Feedback → next iteration**: Human fills out the interface, exports JSON. AI parses and applies changes precisely (not full regeneration — targeted edits only).

## Proven Pattern (Colin Voice Project)

Three working implementations already exist in `/Users/sheldonzhao/Downloads/Colin声音项目/`:
- **Voice segment evaluate** (`evaluate_v3.html`): per-segment card, inline audio, OK/Redo + comment → `EP04_v3_eval.json`
- **BGM annotate** (`bgm/annotate.html`): per-clip card, AI-analyzed features (energy/tone/rhythm/mood), multi-select usage tags + comment → `bgm_annotation.json`
- **Reference library annotate** (`ref-library/annotate.html`): per-audio card with transcript, selection-based annotation

Common abstraction: `[previewable atomic element] + [AI pre-analysis] + [structured options] + [free input] → JSON`

## Two Application Layers in TAD

### Frontend Page Feedback (Heavy Scenario)
- Blake generates page → injects overlay script
- User clicks any element → feedback panel (edit text / adjust style / delete / move / free comment)
- All annotations saved as `feedback.json` with CSS selector → element mapping
- Alex reads JSON → precise handoff for next iteration
- Solves the exact pain point: user's friend saw Blake's page but had no efficient way to relay fine-grained feedback

### General Non-Code Artifact Feedback (Universal Scenario)
- AI identifies task type (podcast / video / brand / design) → auto-determines reviewable dimensions
- Generates HTML feedback page decomposed along those dimensions
- Video example: timeline → per-10s segments → subtitles, effects, sound, music, pacing per segment
- Adaptive granularity: coarse in early rounds (overall direction), fine in later rounds (per-element polish)
- User's feedback patterns inform future dimension selection (if user never edits music → stop showing music controls)

## Open Questions

- Frontend overlay: inject at Blake's build step, or as a post-processing step? (Chrome extension vs inline script)
- How does dimension auto-decomposition work across domains? Fixed template per domain type, or fully LLM-inferred?
- Granularity control: who decides when to zoom in (round 1 = coarse, round 3 = fine)? Human or AI?
- How does this relate to existing Playground? Replace, extend, or coexist?
- JSON schema: one universal schema with domain-specific extensions, or per-domain schemas?
- Integration with TAD Gate 4: does this become a formal part of business acceptance?

## Inspiration Sources

- **Windsurf element reference**: click on any web element → reference it in feedback (single-medium, web-only)
- **Colin voice project**: three working HTML feedback prototypes (multi-medium, manually designed)
- **Insight**: the bottleneck in human-AI creative collaboration is not production speed — it's feedback precision

## Notes

- Key insight from discussion: "AI's real product is not the artifact it generates, but the feedback loop itself. The artifact is just a snapshot in that loop."
- Second key insight: "The quality of Layer 2 (feedback interface) determines the ceiling of the entire system. Wrong decomposition dimensions → human has judgment but no channel to express it."
- Third key insight: "Unlike code (where AC is convergent — tests pass/fail), creative AC is divergent and emergent — humans discover their own standards through iteration."
- Discussed 2026-06-10 in Alex *discuss session. User validated from first-hand Colin project experience + friend's TAD onboarding pain.

## Research Findings (2026-06-10)

NotebookLM deep research completed: 66 sources, 6 rounds of cross-source analysis.
Full report + findings: `.tad/evidence/research/structured-feedback-collector/`
Notebook: `8c456e11-9ef3-4d28-8b06-6efd2cbf0639` (active, queryable)

**Core reframe (2026-06-10 discuss conclusion):**
大厂把反馈机制锁进固定 GUI，每改一次粒度都是产品迭代。TAD 的优势是命令行——生成任何 HTML 界面都是零成本的一次性产物。所谓"自适应粒度"不是技术难题，就是再生成一个不同粒度的 HTML。核心原则：**见机行事**——人和 agent 共享这个概念，按情况即时生成合适的反馈界面，不需要预设固定框架。不与大厂竞争产品，只关心 TAD 方法论如何形成完整的交付闭环。

**Thariq Shihipar "Unreasonable Effectiveness of HTML" 对比 (2026-05-08):**
Anthropic Claude Code 负责人 Thariq 发文主张 HTML 替代 Markdown 作为 AI 输出格式。他列了六种用法（specs/code review/设计/报告/自定义编辑界面/数据摄入），其中第五种"Custom Editing Interfaces"提到了反馈闭环："The trick is always to end with an export: a 'copy as JSON' or 'copy as prompt' button."
**关键区别：** Thariq 的论点是"HTML 是更好的 AI→人类呈现格式"（output upgrade）。我们的论点是"AI 必须为自己的产出物生成可评价的界面，因为只有人类能判断好不好"（人类→AI 判断回流）。他验证了媒介（Anthropic 官方认可 HTML），但我们的方向是他没有展开的那一层——反馈界面不是"更好的输出"，而是 AI 交付闭环的核心机制。
Source: https://claude.com/blog/using-claude-code-the-unreasonable-effectiveness-of-html

**Key discoveries:**
1. Every major AI creative tool is aware of the problem, but each solves it ONLY for their own medium (v0=DOM, Runway=pixel masks, ElevenLabs=timestamps). No cross-media universal system exists.
2. Adaptive granularity (coarse→fine across iterations) is a recognized unsolved problem in both industry and academia.
3. Narrix proved cross-medium metaphor transfer works (DAW→text), but failed on: causal coherence, A/B comparison, long-content scaling.
4. Cognitive load research: no magic number, but key is progressive disclosure + confidence-based prioritization + phase-adaptive structured/free-text ratio.
5. Industry trend is convergent (Figma Weave, ElevenLabs 3.0, CapCut infinite canvas all solving the same problem). Window is months not years. Moat is NOT in UI patterns but in spec-driven workflow integration.
6. TAD integration (Gate 4 + feedback JSON protocol) is genuine differentiation — aligns with Google Antigravity's "Review-Driven Development" concept.

---

**Status Values**: captured → evaluated → promoted → archived
**Promoted To**: (filled by *idea promote)
