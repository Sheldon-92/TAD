---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: [".claude/skills/alex/references"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-07-03
**Project:** TAD Framework
**Task ID:** TASK-20260703-002
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260703-claude-science-skill-architecture.md (Phase 2/4)

---

## 🔴 Gate 2: Design Completeness

**执行时间**: 2026-07-03

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Protocol text change in step4_5 (keywords → description matching) |
| Components Specified | ✅ | 3 lines of step4_5 to change + 10-case eval fixture |
| Functions Verified | ✅ | pack-registry.yaml already has description field (Phase 1 updated) |
| Data Flow Mapped | ✅ | pack-registry.yaml.description → LLM semantic match → pack load |

**Gate 2 结果**: ✅ PASS

---

## 📋 Handoff Checklist (Blake必读)

- [ ] 阅读了所有章节
- [ ] **阅读了「📚 Project Knowledge」章节中的历史经验**
- [ ] 理解了真正意图（不只是字面需求）
- [ ] 确认可以独立使用本文档完成实现

---

## 1. Task Overview

### 1.1 What We're Building
Change intent router step4_5 from keyword-list matching to description-based semantic matching. Create a discriminative eval to verify ≥80% accuracy.

### 1.2 Why We're Building It
**业务价值**：Pack discovery becomes more accurate — descriptions carry richer semantic signal than keyword lists (e.g., "RAG pipeline design" matches rag-retrieval's description naturally, whereas it requires explicit keywords like "RAG", "检索增强" in the current system).
**成功的样子**：10 real task descriptions → ≥8 correctly matched to the right Pack.

### 1.3 Intent Statement

**真正要解决的问题**：step4_5 currently matches on a curated keyword list per Pack. This requires manual keyword maintenance and misses tasks that use different vocabulary. Descriptions (standardized in Phase 1) are richer semantic signals that the LLM can match more naturally.

**不是要做的**：
- ❌ 不是改 step1_5b in *design (it has its own AskUserQuestion confirmation flow)
- ❌ 不是改 Blake's 1_5a pack detection (independent, intentional)
- ❌ 不是删 pack-registry.yaml (it still has consumes/produces/type metadata)
- ❌ 不是删 keywords field (keep for backward compat, just not used for matching in step4_5)

---

## 2. Technical Design

### 2.1 Current step4_5 (lines to change)

In `.claude/skills/alex/references/intent-router-protocol.md`, step4_5 action steps 2 and 4:

**Current (lines ~122-131):**
```yaml
2. Read pack-registry.yaml → extract all pack entries with keywords

4. Match user input keywords against available packs' keywords lists
   (LLM semantic match, same mechanism as step1_5b)
```

**New:**
```yaml
2. Read pack-registry.yaml → extract all pack entries with descriptions

4. Match user input against available packs' description fields
   (LLM semantic match — compare task description against each pack's
    description to find the most relevant packs)
```

### 2.2 Ranking change

**Current (line ~155):**
```yaml
If >2 packs match, select 2 with highest keyword overlap count.
Break ties by pack order in pack-registry.yaml (earlier = higher priority).
```

**New:**
```yaml
If >2 packs match, select 2 whose descriptions have the highest topical
overlap with the user's stated task (prefer packs where the description's
core domain directly addresses the user's request over packs with
incidental term overlap).
Break ties by pack order in pack-registry.yaml (earlier = higher priority).
```

### 2.3 What stays the same

- Tier 1/2/3 availability check (step 3) — unchanged
- max_packs: 2 — unchanged
- Collision check (step 5b) — unchanged
- skip_if rules — unchanged
- does_NOT_write_to_handoff — unchanged
- Step 5 (load matched pack SKILL.md) — unchanged

### 2.5 Intentional mechanism divergence from step1_5b

After this change, step4_5 and step1_5b use DIFFERENT matching mechanisms:
- **step4_5** (this change): description-only matching — lightweight, silent, fires on every user input
- **step1_5b** (unchanged): keywords+description dual-field matching — richer, with AskUserQuestion confirmation flow

The `(same mechanism as step1_5b)` clause is INTENTIONALLY removed from step4_5 step 4. This is not accidental.

Also update the step4_5 `note:` block (lines 164-168) to state: "step4_5 matches on pack descriptions only; step1_5b matches on keywords+descriptions (different mechanism, intentional)."

Blake's 1_5a in blake/SKILL.md uses keyword matching independently — this is also intentional (Alex and Blake may load different packs for the same task, catching what the other missed).

### 2.4 Also update: .agents/skills/ parity

The same protocol file exists at `.agents/skills/alex/references/intent-router-protocol.md`. Apply the same text changes there.

---

## 3. Discriminative Eval

### 3.1 Eval Fixture (10 real task descriptions)

| # | Task Description | Expected Pack | Type | Why |
|---|-----------------|---------------|------|-----|
| 1 | "I need to build a RAG pipeline with vector search and reranking" | rag-retrieval | direct | Core RAG terminology |
| 2 | "Help me set up GitHub Actions CI/CD with Docker deployment" | web-deployment | direct | CI/CD + deployment |
| 3 | "Write a systematic literature review following PRISMA guidelines" | academic-research | direct | PRISMA + literature review |
| 4 | "Design a multi-agent system with supervisor topology" | agent-orchestration | direct | Multi-agent + topology |
| 5 | "Scan my Node.js app for OWASP vulnerabilities" | code-security | direct | OWASP + vulnerability scanning |
| 6 | "Create a synthetic instruction dataset for fine-tuning" | synthetic-data | direct | Synthetic data + fine-tuning |
| 7 | "Set up distributed tracing for my LLM application" | llm-observability | direct | LLM tracing |
| 8 | "Build a knowledge graph from unstructured documents" | knowledge-graph | direct | Knowledge graph construction |
| 9 | "Help me find relevant papers from medical databases and synthesize findings" | academic-research | indirect | Avoids keyword "PRISMA"/"systematic review"; description's "literature review" + "PubMed" matches |
| 10 | "My AI chatbot keeps hallucinating, I need to monitor its outputs in production" | llm-observability | indirect | Avoids keyword "tracing"/"分布式追踪"; description's "drift detection" + "groundedness" matches |
| 11 | "I want to train my own model on a cloud GPU with LoRA" | ml-training | indirect | Uses natural language; description's "LoRA" + "cloud GPU" matches |
| 12 | "Help me write a birthday card for my mom" | (none) | negative | Should NOT match any pack — silent skip |

### 3.2 Eval Method

Since step4_5 is LLM-internal reasoning (not a script), the eval is a **manual structured test**:

1. Blake reads step4_5 protocol + all 27 pack descriptions from pack-registry.yaml
2. For each of the 10 task descriptions, Blake applies step4_5 logic:
   - Which pack(s) would the LLM semantic match select?
   - Record the matched pack(s)
3. Compare actual matches vs expected matches
4. Calculate accuracy: correct_matches / 10

**Pass criteria**: ≥ 10/12 correct (83%). Cases 9-11 (indirect) are the discriminative ones — if description matching fails on those but keywords would have also failed, it's still a PASS but note the gap. Case 12 (negative) passes if NO pack is loaded.

**False positive check**: For each task, if a WRONG pack was also loaded (alongside the correct one), record it but don't count as failure (max_packs=2 means 2 loads are normal if both are relevant).

### 3.3 Eval Output

Create `.tad/eval/pack-discovery-eval.md` with the fixture and results table.

---

## 8. Implementation Steps

**Layer 1:**
1. Read current intent-router-protocol.md step4_5
2. Change step 2: "keywords" → "descriptions"
3. Change step 4: keyword matching → description matching
4. Change ranking_when_over_limit: keyword overlap count → semantic relevance
5. Update .agents/skills/ parity copy
6. Run discriminative eval (10 cases)

**Layer 2:**
Standard code-reviewer on the protocol changes.

### 8.2 Key Constraints
- ONLY modify step4_5 text. Do NOT touch step1_5b, step2, or other steps.
- Do NOT delete the keywords field from pack-registry.yaml.
- Do NOT modify pack-registry.yaml content (only step4_5 reads it differently).
- Preserve all existing step4_5 sub-steps that don't mention keywords (tier check, collision check, skip_if, etc.).

### 8.4 Friction Preflight
No special dependencies. Standard text editing.

---

## 9. Acceptance Criteria

- [ ] **AC1**: step4_5 step 2 reads "descriptions" not "keywords" from pack-registry.yaml
- [ ] **AC2**: step4_5 step 4 matches user input against "description fields" not "keywords lists"
- [ ] **AC3**: ranking_when_over_limit uses "semantic relevance" not "keyword overlap count"
- [ ] **AC4**: Validation eval achieves ≥10/12 correct matches (8 direct + 3 indirect + 1 negative)
- [ ] **AC5**: .agents/skills/ parity maintained for intent-router-protocol.md
- [ ] **AC6**: Eval fixture + results saved at `.tad/eval/pack-discovery-eval.md`

---

## 10. File Manifest

| File | Action | Purpose |
|------|--------|---------|
| .claude/skills/alex/references/intent-router-protocol.md | MODIFY | step4_5 keywords → description matching |
| .agents/skills/alex/references/intent-router-protocol.md | MODIFY | Parity copy |
| .tad/eval/pack-discovery-eval.md | CREATE | Discriminative eval fixture + results |

---

## 📚 Project Knowledge

### ⚠️ Blake 必须注意的历史教训

- **Domain Pack Keyword Curation** (patterns/pack-build-rules.md) — Strict uniqueness + threshold 1 = 100% accuracy. This was for KEYWORDS; descriptions are inherently less unique (multiple packs may have overlapping descriptions). The max_packs=2 limit mitigates this, but Blake should watch for false positives.
- **Deny-List Must Be Applied at EVERY Copy Granularity** (principles.md) — .agents/skills/ parity. The protocol file must be updated in both locations.

---

## 11. Decision Summary

| # | Decision | Rationale |
|---|----------|-----------|
| D1 | Match on description, not keywords | Descriptions carry richer semantic signal (Phase 1 standardized them) |
| D2 | Keep pack-registry.yaml | It has consumes/produces/type metadata for step1_5b |
| D3 | Keep keywords field | Backward compat; not deleted, just not used for step4_5 matching |
| D4 | 10-case manual eval | step4_5 is LLM-internal reasoning; no script-based test possible |
| D5 | 83% accuracy gate | ≥10/12 correct is the minimum bar; below this, Phase 2 fails |
| D6 | step4_5 description-only (not dual-field like step1_5b) | step4_5 is silent and lightweight — description alone provides sufficient signal without keyword maintenance. step1_5b retains dual-field matching as part of its richer confirmation flow. Blake's 1_5a keeps keyword-only matching for independent coverage (intentional asymmetry). |
| D7 | keywords field kept for 5 other consumers | scan-collisions.sh, step1_5b, Blake 1_5a, step1_5b ranking, scan-packs.sh all use keywords. Removing them would require updating 4 protocol files + 1 script — deferred. |
