---
title: Research Methodology Upgrade — STORM + Deep Research + Elicit Patterns
date: 2026-05-09
status: promoted
scope: medium
promoted_to: "Handoff (via *analyze — 2026-05-09)"
---

## Summary & Problem

TAD's NotebookLM-based research (v2.12.0) has cross-source synthesis + dynamic depth-first questioning, but lacks capabilities that competing tools (STORM, Deep Research, Elicit) already have. Four concrete patterns can be borrowed to significantly upgrade research quality.

## Four Upgrade Directions

### 1. STORM Multi-Perspective Questioning (Priority: HIGH, Effort: LOW)

**Source**: STORM (Stanford, arxiv 2402.14207)
**What**: Instead of asking from one angle, simulate 3-5 expert personas with different viewpoints. Each persona asks questions from their expertise.
**Example**: Topic "multi-agent security" →
- Security expert: "What attack surfaces are unique to multi-agent?"
- Performance engineer: "At what scale does inter-agent communication become a bottleneck?"
- Product manager: "Can users perceive the latency from multi-agent coordination?"
**Implementation**: Add `perspective_shift` as 5th strategy in step3_5 dynamic ask protocol. After 2 rounds on same angle → auto-switch perspective. Perspectives derived from Domain Pack reviewer personas or OBJECTIVES.md stakeholders.
**Effort**: ~30 lines in SKILL.md ask protocol.

### 2. Elicit Structured Paper Extraction (Priority: HIGH, Effort: LOW)

**Source**: Elicit (elicit.com)
**What**: After importing an academic paper, auto-extract structured fields: research question, methodology, key quantitative findings (with numbers), stated limitations, compared baselines. Format as YAML.
**Implementation**: Add post-import ask template for `arxiv_pdf` and `scholar` source types. After source add succeeds, run:
```
ask "For this paper, extract in YAML format:
  research_question: ...
  methodology: ...
  key_findings: [{finding, metric, value}]
  limitations: [...]
  baselines_compared: [...]"
```
Save extracted YAML to chain .md or separate `{paper-id}-extraction.yaml`.
**Effort**: ~20 lines template + storage logic.

### 3. Deep Research Auto Source Discovery (Priority: HIGH, Effort: MEDIUM)

**Source**: Gemini Deep Research / ChatGPT Deep Research
**What**: When dynamic follow-up hits a gap ("sources do not contain X"), automatically search for new sources via WebSearch → add-smart → re-ask. Current behavior: Phase 4b does fast research within NotebookLM. Upgrade: ALSO search externally and import new sources.
**Implementation**: In step3_5 gap_enrichment strategy:
1. Existing: `source add-research --mode fast` (NotebookLM internal search)
2. NEW: `WebSearch "{gap topic}" → pick top 2-3 URLs → add-smart each → re-ask`
**Key difference from current**: current gap enrichment only searches NotebookLM's own database. This adds external web discovery into the loop.
**Effort**: ~50 lines — WebSearch + add-smart integration in SKILL.md.

### 4. Deep Research Adaptive Research Plan (Priority: MEDIUM, Effort: MEDIUM)

**Source**: Gemini Deep Research
**What**: Research plan adjusts dynamically as findings reveal new sub-topics. Currently *research-plan seeds are fixed at Phase 0. Upgrade: after each chain's so-what completes, check if findings reveal a new seed question → dynamically append to seed list → open new chain.
**Implementation**:
- After so-what chain completion, Alex analyzes: "Did this chain reveal a sub-topic not covered by existing seeds?"
- If yes → generate new seed question → append to active seed list → open new chain
- Max total chains: 5 (prevent unbounded growth)
- New seeds inherit context from prior chains (cross-pollination)
**Effort**: ~40 lines in SKILL.md research-plan step4 + seed management.

## Open Questions

- Should perspective_shift personas be derived from Domain Packs (reviewer roles) or manually specified?
- Should structured extraction run on ALL papers or only when inside *research-plan?
- Auto source discovery: rate limit? Max sources added per gap? Cost control for add-smart API calls (twitterapi.io credits)?
- Adaptive plan: how to prevent seed explosion? Quality gate for new seeds?

## References

- STORM: https://arxiv.org/abs/2402.14207
- Elicit: https://elicit.com
- Gemini Deep Research: https://blog.google/products/gemini/google-gemini-deep-research/
- Current implementation: .claude/skills/research-notebook/SKILL.md step3_5
- Current research-plan: .claude/skills/alex/SKILL.md research_plan_protocol
