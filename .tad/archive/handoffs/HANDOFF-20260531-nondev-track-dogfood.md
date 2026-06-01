---
task_type: deliverable
pack: academic-research
rubric_ref: .claude/skills/academic-research/references/scholar-eval.md
pass_threshold: 0.75
deliverable_paths: [".tad/evidence/yolo/nondev-execution-track/dogfood/llm-judge-bias-mitigation-brief.md"]
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
---

# Deliverable Handoff — Dogfood: LLM-as-a-Judge Self-Enhancement Bias Mitigation Brief

**From:** Alex (Conductor, YOLO)
**To:** Producer (Conductor-spawned producer sub-agent — NOT Blake)
**Date:** 2026-05-31
**Task ID:** TASK-20260531-dogfood
**Epic:** EPIC-20260531-nondev-execution-track.md (Phase 3/4)

> ⚠️ Producer ≠ Judge (contract §C). The producer writes the deliverable. A SEPARATE fresh judge sub-agent scores it at Gate 3 against scholar-eval.md. Producer MUST NOT score its own work.

## Why this deliverable (dogfood rationale)
This is the Phase-3 real dogfood of the non-dev execution track. The topic is deliberately chosen to close the loop: it is a literature brief on **how to mitigate self-enhancement bias in LLM-as-a-judge evaluation** — the exact failure mode the track's judge≠producer rule (§C) defends against. It is small (literature-survey tier), needs only WebSearch (no hardware/NotebookLM), and produces a citeable research artifact ScholarEval can score.

## Deliverable to Produce
A single markdown research brief at:
`.tad/evidence/yolo/nondev-execution-track/dogfood/llm-judge-bias-mitigation-brief.md`

Scope: a focused evidence review answering **"What evidence-based techniques mitigate self-enhancement / self-preference bias when an LLM is used as an evaluator (LLM-as-a-judge)?"**

Required structure:
1. Research question + scope (1 short para)
2. Background: what self-enhancement / self-preference bias is in LLM-as-judge, with the measured magnitude where available
3. Mitigation techniques (the core): each technique with (a) what it does, (b) the evidence/source, (c) limitations
4. Synthesis: which techniques are best-supported; open gaps
5. References: numbered, with title + authors/venue + year + URL for each

## Acceptance Criteria (about the artifact)
- [ ] AC1: The brief answers the research question with ≥4 distinct mitigation techniques.
- [ ] AC2: ≥6 references, EACH a REAL, retrievable source (found via WebSearch) with a URL — zero fabricated citations (academic-research zero-hallucination rule). Every substantive claim is attributed to a numbered reference.
- [ ] AC3: At least one quantitative magnitude of the bias is reported with its source (e.g., a measured self-preference/self-enhancement rate).
- [ ] AC4: Limitations of each technique are stated (not just benefits).
- [ ] AC5: The brief has the 5-section structure above.

## Producer instructions
- Use WebSearch (and WebFetch as needed) to ground EVERY citation in a real source. Do NOT invent papers, authors, or URLs. If you cannot find a real source for a claim, drop the claim.
- Follow academic-research zero-hallucination: cite real sources only; attribute claims; report magnitudes with provenance.
- Keep it tight (literature-survey tier — quality over length; ~800-1500 words is fine).
- Do NOT write any self-assessment / "this brief is rigorous" prose into the artifact (the judge ignores self-praise; §C artifact-channel rule — but cleaner to omit it).
- Write ONLY the deliverable file. Do not score it. Do not edit gate/skill files.

## Rubric (judge applies, NOT producer)
scholar-eval.md (8-dim weighted, ≥0.75 = PASS / ≥0.60 = PARTIAL / <0.60 = FAIL). Judge spawned separately at Gate 3.
