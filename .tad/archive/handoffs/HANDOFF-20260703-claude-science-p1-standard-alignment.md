---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: [".claude/skills"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-07-03
**Project:** TAD Framework
**Task ID:** TASK-20260703-001
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260703-claude-science-skill-architecture.md (Phase 1/4)

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-07-03

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 27 Pack SKILL.md frontmatter audit + fix, no architecture change |
| Components Specified | ✅ | Each Pack's name/description fields per Anthropic standard |
| Functions Verified | ✅ | No new functions — modifying existing YAML frontmatter only |
| Data Flow Mapped | ✅ | Frontmatter feeds Claude Code platform skill discovery (description-based) |

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
Audit and update all 27 Capability Pack SKILL.md frontmatter (name + description fields) to comply with Anthropic's open SKILL.md standard. Also update .agents/skills/ and .tad/capability-packs/ parity copies.

### 1.2 Why We're Building It
**业务价值**：TAD's Capability Packs become cross-platform compatible — usable in Claude Code, Claude API, Cursor, Gemini CLI, Windsurf, and any platform that supports the Anthropic SKILL.md standard.
**用户受益**：Pack descriptions become better discovery signals for Phase 2's semantic matching upgrade.
**成功的样子**：All 27 Packs pass Anthropic standard validation, and Claude Code platform skill discovery still routes correctly.

### 1.3 Intent Statement

**真正要解决的问题**：TAD's Pack frontmatter is inconsistent — some descriptions have Chinese, some include inline keyword lists, some are too vague. Standardizing to Anthropic's open format opens cross-platform use and prepares for Phase 2's description-based discovery.

**不是要做的（避免误解）**：
- ❌ 不是修改 SKILL.md body content (instructions, references/, scripts)
- ❌ 不是修改非 Pack 的 TAD framework skills (alex, blake, gate, tad, etc.)
- ❌ 不是改 intent router 逻辑 (that's Phase 2)
- ❌ 不是改 pack-registry.yaml keywords (that's Phase 2)

---

## 2. Scope

### 2.1 Target: 27 Capability Packs

The following skills are Capability Packs (domain expertise, not TAD framework tools):

1. academic-research
2. agent-computer-interface
3. agent-memory
4. agent-orchestration
5. agent-skill-evolution
6. ai-agent-architecture
7. ai-evaluation
8. ai-guardrails
9. ai-podcast-production
10. ai-prompt-engineering
11. ai-tool-integration
12. ai-voice-production
13. code-security
14. data-engineering
15. knowledge-graph
16. llm-observability
17. ml-training
18. product-thinking
19. rag-retrieval
20. reading-companion
21. synthetic-data
22. video-creation
23. web-backend
24. web-deployment
25. web-frontend
26. web-testing
27. web-ui-design

**NOT in scope** (TAD framework skills, not Packs):
alex, blake, gate, tad, tad-elicit, tad-handoff, tad-help, tad-init, tad-maintain, tad-parallel, capability-upgrade, knowledge-audit, release-runbook, research-github, research-notebook, surplus, playground

---

## 3. Technical Design

### 3.1 Anthropic Standard Specification

Per https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview:

**`name` field requirements:**
- Maximum 64 characters
- Must contain ONLY lowercase letters, numbers, and hyphens (`[a-z0-9-]`)
- Cannot contain XML tags
- Cannot contain reserved words: "anthropic", "claude"

**`description` field requirements:**
- Must be non-empty
- Maximum 1024 characters
- Cannot contain XML tags
- Should include BOTH "what it does" AND "when to use it"
- Should be written in third person ("Processes...", not "I can help you...")
- Should be specific, not vague ("Helps with documents" is bad)

### 3.2 Current State Pre-Audit

Expert review verified the current state of all 27 Packs:

**Name compliance**: All 27 names ALREADY comply (lowercase+hyphens, ≤64 chars, no reserved words). No name changes needed — verify only, don't rewrite.

**Description compliance gaps** (8 Packs missing "when to use" clause):

| Pack | name OK | has "when to use" | has Chinese | Action needed |
|------|---------|-------------------|-------------|---------------|
| academic-research | ✅ | ❌ | ✅ (inline "Activates on: 学术...") | Rewrite: English only, add "Use for" |
| ai-agent-architecture | ✅ | ❌ | ❌ | Add "Use for" clause |
| ai-podcast-production | ✅ | ❌ | ❌ | Add "Use for" clause |
| ai-voice-production | ✅ | ❌ | ❌ | Add "Use for" clause |
| ml-training | ✅ | ❌ | ❌ | Add "Use for" clause |
| product-thinking | ✅ | ❌ | ❌ | Add "Use for" clause |
| video-creation | ✅ | ❌ | ❌ | Add "Use for" clause |
| web-frontend | ✅ | ❌ | ❌ | Add "Use for" clause |

The remaining 19 Packs already have compliant "Use for..." or "Use when..." clauses. Blake should still verify each and reformat if structure doesn't match the pattern in §3.3.

**Inline keyword lists**: `academic-research` has "Activates on: 学术, academic, 论文..." — convert activation keywords to English and integrate into a natural "Use for" sentence.

**Description length**: All descriptions are well under 1024 chars (longest ~714 chars). No truncation risk.

### 3.3 Description Rewriting Guidelines

When rewriting descriptions, follow this pattern (from Anthropic best practices):

```
{What it does — one sentence, third person, specific.}
{Covers: key topics or capabilities, comma-separated.}
{Use for: specific trigger scenarios when this pack should load.}
```

Example (before):
```yaml
description: "AI podcast production judgment for coding agents — script writing with Codex review, large-chunk TTS generation, dual-BGM music arrangement with envelope follower ducking, show notes, Colab deployment"
```

Example (after):
```yaml
description: "AI podcast production judgment for coding agents. Covers script writing, large-chunk TTS generation, dual-BGM music arrangement with envelope follower ducking, show notes, and Colab deployment. Use for any AI-assisted podcast or audio content production task."
```

### 3.4 Regression Test Design

**Context**: Intent router step4_5 matches on `keywords` from pack-registry.yaml — those are NOT being changed by this Phase, so step4_5 has zero regression risk. The real regression surface is Claude Code's platform-level skill discovery, which uses the `description` field from SKILL.md frontmatter to decide when to trigger a skill. Since we ARE changing descriptions, this is what we must verify.

**Test method** (structural, executable by Blake):

1. **Before changes**: Capture baseline descriptions:
   ```bash
   for d in .claude/skills/*/SKILL.md; do echo "=== $(basename $(dirname $d)) ==="; head -5 "$d" | grep '^description:'; done > /tmp/desc-before.txt
   ```

2. **After changes**: Capture updated descriptions:
   ```bash
   for d in .claude/skills/*/SKILL.md; do echo "=== $(basename $(dirname $d)) ==="; head -5 "$d" | grep '^description:'; done > /tmp/desc-after.txt
   ```

3. **Semantic preservation check**: For each of the 8 rewritten Packs, verify the new description still contains the key domain terms that would trigger matching. Check with:
   ```bash
   # For each rewritten pack, grep for its core domain terms in the new description
   # e.g., academic-research must contain: "literature review" or "citation" or "academic"
   # e.g., ml-training must contain: "fine-tuning" or "LoRA" or "GPU" or "training"
   ```

4. **Pass criteria**: Every rewritten description retains ≥1 core domain term from the original. No description is emptied or made vague (e.g., "Helps with things").

**Test coverage**: Focus on the 8 Packs being rewritten (§3.2 table). The 19 already-compliant Packs get only structural validation (AC1+AC2).

---

## 8. Implementation Requirements

### 8.1 Implementation Steps

**Layer 1 (per Ralph Loop):**
1. Read all 27 Pack SKILL.md files, verify name compliance (expect all PASS)
2. For each of the 8 non-compliant Packs (§3.2 table): rewrite description per §3.3 pattern
3. For the 19 already-compliant Packs: verify structure matches §3.3 pattern, minor reformat if needed
4. Update .agents/skills/ parity copies (copy updated SKILL.md to .agents/skills/{pack}/)
5. Update .tad/capability-packs/{pack}/CAPABILITY.md frontmatter to match (name + description only)
6. Run regression test per §3.4

**Layer 2 (expert review):**
Standard code-reviewer on the changes.

### 8.2 Key Constraints
- ONLY modify YAML frontmatter (name + description lines). Do NOT touch SKILL.md body.
- If a description references Chinese keywords for discovery ("学术, 论文"), convert to English equivalents in the description.
- Preserve any description content that describes "when to use it" — just reformat to standard structure.
- `keywords` field in frontmatter: keep as-is. It is NOT part of the Anthropic standard and is used by pack-registry.yaml matching. Will be addressed in Phase 2.

### 8.3 Three-Copy Parity
Each Pack has three copies of name/description:
1. `.claude/skills/{pack}/SKILL.md` — PRIMARY (edit this first)
2. `.agents/skills/{pack}/SKILL.md` — Codex parity (copy from #1)
3. `.tad/capability-packs/{pack}/CAPABILITY.md` — Pack registry source (update frontmatter to match #1)

After updating all three, run `bash .tad/scripts/scan-packs.sh` if it exists to regenerate pack-registry.yaml descriptions. If scan-packs.sh doesn't exist, manually verify pack-registry.yaml is not stale (add Decision D6 note in completion report).

### 8.4 Friction Preflight
No special dependencies, auth, or tools needed. Standard file editing.

---

## 9. Acceptance Criteria (Blake's Implementation Targets)

- [ ] **AC1**: All 27 Pack `name` fields pass: `echo "$name" | grep -qE '^[a-z0-9-]{1,64}$' && ! echo "$name" | grep -qE 'anthropic|claude'`
- [ ] **AC2**: All 27 Pack `description` fields pass: non-empty, ≤1024 chars, no XML tags
- [ ] **AC3**: All 27 descriptions follow pattern: third-person, includes "what + when to use", specific not vague
- [ ] **AC4**: Regression test per §3.4: all 8 rewritten descriptions retain core domain terms (semantic preservation check PASS)
- [ ] **AC5**: Three-copy parity: after updating .claude/skills/{pack}/SKILL.md, copy to .agents/skills/{pack}/SKILL.md and update .tad/capability-packs/{pack}/CAPABILITY.md frontmatter. Verify with `diff -q` that .claude and .agents copies are byte-identical for all 27 Packs.
- [ ] **AC6**: Audit report created at `.tad/evidence/acceptance-tests/claude-science-p1/audit-report.md` with before/after for each of the 27 Packs

---

## 10. File Manifest

| File | Action | Purpose |
|------|--------|---------|
| .claude/skills/{27-packs}/SKILL.md | MODIFY | Standardize name/description frontmatter |
| .agents/skills/{27-packs}/SKILL.md | MODIFY | Codex parity copies |
| .tad/capability-packs/{27-packs}/CAPABILITY.md | MODIFY | Pack registry source parity |
| .tad/evidence/acceptance-tests/claude-science-p1/audit-report.md | CREATE | Before/after audit for all 27 |
| .tad/evidence/acceptance-tests/claude-science-p1/regression-test.md | CREATE | Semantic preservation check results |

---

## 📚 Project Knowledge

### ⚠️ Blake 必须注意的历史教训

- **YAML Frontmatter is Load-Bearing** (patterns/pack-build-rules.md) — Without `name:` + `description:` frontmatter, install succeeds silently but skill never activates. Relevant because we're modifying frontmatter — any format error = invisible breakage.
- **Domain Pack Keyword Curation** (patterns/pack-build-rules.md) — Strict uniqueness + threshold 1 = 100% accuracy. Include hyphen AND space variants. Relevant because description changes could affect keyword matching.
- **Deny-List Must Be Applied at EVERY Copy Granularity** (principles.md) — .agents/skills/ parity must be maintained. Every .claude/skills/ change must be mirrored.

---

## 11. Decision Summary

| # | Decision | Rationale |
|---|----------|-----------|
| D1 | Convert activation keywords to English in description | They serve as semantic anchors for discovery; reformat from Chinese to English equivalents |
| D2 | Standardize all descriptions to English | Cross-platform compatibility; Chinese keywords converted to English equivalents |
| D3 | Don't touch SKILL.md body or keywords field | Scope discipline — only name + description frontmatter this Phase; keywords field addressed in Phase 2 |
| D4 | Semantic preservation test (not step4_5 regression) | step4_5 reads keywords (unchanged), so testing it is vacuous. Real risk is Claude Code platform description matching — test via domain-term preservation check |
| D5 | Include CAPABILITY.md in three-copy parity | CAPABILITY.md has same name/description frontmatter; leaving it stale creates drift. pack-registry.yaml regenerated via scan-packs.sh if available |
| D6 | 27 Packs (not 25) | Expert review confirmed video-creation and web-ui-design are Capability Packs by structure and content |

### Expert Review Audit Trail

| Reviewer | Findings | P0 | P1 | P2 | Resolution |
|----------|----------|----|----|-----|------------|
| code-reviewer | 13 findings | 2 | 6 | 5 | P0-1: Pack count fixed 25→27. P0-2: Regression test redesigned. P1s integrated (CAPABILITY.md, capability-upgrade ref removed, pre-audit table added, section numbering, keywords decision). P2s accepted as-is or deferred. |
| spec-compliance reviewer | 8 findings | 1 | 4 | 3 | P0-1: video-creation added. P1s integrated (web-ui-design resolved, CAPABILITY.md added, regression test redesigned, pre-audit table added). P2s accepted. |
