---
task_type: mixed
e2e_required: no
research_required: yes
git_tracked_dirs: [".claude/skills/alex", ".tad/project-knowledge"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: *dream — Knowledge Consolidation Command

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-05-14
**Project:** TAD Framework
**Task ID:** TASK-20260514-dream
**Handoff Version:** 3.1.0

---

## 1. Task Overview

Implement `*dream` — a new Alex command that automatically consolidates TAD's project-knowledge files. Inspired by Anthropic's Dreams API (2026-05-06) and the dream-skill open-source implementation.

**Problem:** TAD's `.tad/project-knowledge/architecture.md` has grown to 119 entries / 1118 lines (~30K tokens). Every session loads this via @import, causing slow startup, knowledge drowning, and quality degradation (12 stale file refs, contradictions between old and new entries).

**Solution:** A 4-phase consolidation command (Orient → Gather Signal → Consolidate → Prune & Index) that produces a candidate version for human review, never modifying originals directly.

## 2. Research Foundation

Full research report: `.tad/evidence/research/dreaming-knowledge-consolidation/2026-05-14-ask-findings.md`

Key sources: Anthropic Dreams API docs, grandamenium/dream-skill (GitHub), Mem0 conflict resolution, LLM knowledge base patterns.

Adversarial challenge (Phase 0c + Phase 4c): 2 rounds each with Codex + Gemini. 5 unresolved design risks flagged — all addressed in this handoff's design decisions.

## 3. Requirements

### Functional Requirements

**FR1:** `*dream` command added to Alex SKILL.md with full protocol definition
**FR2:** 4-phase execution: Orient → Gather Signal → Consolidate → Prune & Index
**FR3:** Processes `.tad/project-knowledge/*.md` files EXCEPT README.md (structural doc, no Foundational/Accumulated boundary)
**FR4:** Produces candidate files (`.tad/active/dream-candidates/`) — originals never modified
**FR5:** Human review gate before promotion (AskUserQuestion per file)
**FR6:** Backup originals before promotion (`.tad/archive/knowledge-snapshots/{date}/`)
**FR7:** Safety validator: MUST/MANDATORY/VIOLATION/BLOCKING keyword count preserved

### Non-Functional Requirements

**NFR1:** Single-session execution (no background jobs)
**NFR2:** Works without external dependencies (no Mem0, no Dreams API — pure LLM + shell)
**NFR3:** Rollback: `*dream --rollback` restores from latest snapshot

## 4. Technical Design

### 4.1 Phase 1: Orient
- Read each `.tad/project-knowledge/*.md` file
- For each: count entries (### headers), count lines, extract entry titles + dates
- Output: orientation report (file → entry count → line count → newest/oldest entry)

### 4.2 Phase 2: Gather Signal
- Scan `.tad/archive/handoffs/` last 10 completed handoffs
- Extract Knowledge Assessment sections for new discoveries
- Scan for entries that reference files no longer on disk (stale refs)
- Identify AMENDED/superseded pairs

### 4.3 Phase 3: Consolidate (LLM-driven, per-file)
For each knowledge file:
- **Dedup & Merge (deterministic criteria):** Merge when ANY of: (a) explicit AMENDED+ORIGINAL pair, (b) identical `### Title` prefix (e.g., two "Hook Performance" entries), (c) same Context field referencing same handoff. For each proposed merge, output a merge plan (pair + rationale) for human review via AskUserQuestion BEFORE executing. Keep most recent date, union Action items, union Grounded-in paths.
- **Contradiction Resolution:**
  - Entries with MUST/MANDATORY/VIOLATION/BLOCKING → NEVER auto-resolve. Flag for human.
  - Other entries → newest wins (with provenance note: "Supersedes: {old title}")
- **Stale Ref Cleanup:** Entries where ALL "Grounded in" paths are missing → mark as "[STALE — referenced files no longer exist]"
- **Temporal Normalization:** Relative dates → absolute (already done in most entries)

### 4.4 Phase 4: Summarize & Rebuild (NO demotion — BA-P0-2 fix)
- **No demotion to details/ directory.** @import does not follow links — demoted entries become unreachable "knowledge graveyard." Reduction achieved through merges + stale cleanup + in-place summarization only.
- Verbose entries (>20 lines): LLM summarizes Discovery+Action to ≤8 lines while preserving all MUST/MANDATORY/VIOLATION keywords verbatim. Original full text appended as HTML comment `<!-- FULL: ... -->` for rollback auditability.
- Stale entries (ALL Grounded-in paths missing): remove from main file, archive to `.tad/archive/knowledge-snapshots/{date}/stale-entries.md`
- Target: ≤50% line reduction for files >500 lines (architecture.md). Files <100 lines: no reduction target (CR-P2-2).
- Rebuild each file with Foundational section (untouched) + Accumulated Learnings (consolidated)

### 4.5 Safety Validator (`dream-validator.sh`)
```
# Before/after comparison:
# 1. Count MUST/MANDATORY/VIOLATION/BLOCKING keywords — after ≥ before
# 2. Count ### entry headers — after can be fewer (merges) but not zero
# 3. Every "Grounded in" path in candidate that still references a real file — must exist on disk
# 4. No entry from Foundational section was modified (diff check on section boundary)
```

### 4.6 Promotion & Rollback
- `*dream` default: generate candidates only
- `*dream --promote`: backup originals → move candidates to replace originals
- `*dream --rollback`: restore from `.tad/archive/knowledge-snapshots/{date}/`

## 5. Design Decisions (from Challenge Layer)

| # | Risk (from Codex/Gemini challenge) | Design Decision |
|---|-----|-----|
| 1 | grep validator too primitive | Validator checks keyword COUNT + Foundational section byte-diff + Grounded-in path existence. Not just string count. |
| 2 | newest-wins architectural drift | Safety entries (MUST/MANDATORY/VIOLATION) → human-must-decide. Only non-safety entries use newest-wins. |
| 3 | Human review cost too high | Auto-approve: stale ref removal, date normalization. Flag for human: merges, contradictions, safety entries. Mid-process gate between Phase 2→3 shows merge plan before execution (BA-P1-1). |
| 4 | <200 line cap arbitrary | No hard cap. ≤50% target for files >500 lines only. No demotion to details/ — reduction via merges + stale cleanup + in-place summarization (BA-P0-2). |
| 6 | Demotion creates knowledge graveyard | REMOVED demotion entirely. @import does not follow links — demoted entries become unreachable. Verbose entries summarized in-place with full text in HTML comment. (BA-P0-2) |
| 7 | Terminal isolation for Alex file I/O | *dream is analytical transformation like *optimize (reads → proposes → human approves). Same precedent as *optimize writing PROPOSAL YAML. (BA-P0-4) |
| 8 | Merge criteria non-deterministic | Replaced "70% topic overlap" with 3 deterministic rules (AMENDED pair / identical title prefix / same handoff Context). Merge plan shown to human BEFORE execution. (BA-P0-1) |
| 5 | Baseline stats possibly inaccurate | Blake must re-verify baseline (grep -c) as AC1 before any consolidation. |

## 6. Files to Modify / Create

| # | File | Action | Purpose |
|---|------|--------|---------|
| 1 | `.claude/skills/alex/SKILL.md` | MODIFY | Add `*dream` command entry, `dream_protocol` section, `enters_standby` entry, `on_start` greeting line, Quick Reference entry |
| 2 | `.tad/hooks/lib/dream-validator.sh` | CREATE | Safety validator script |
| 3 | `.tad/active/dream-candidates/` | CREATE dir | Temporary candidate files |
| 4 | `.tad/archive/knowledge-snapshots/` | CREATE dir | Rollback snapshots |
| 5 | `CLAUDE.md` | MODIFY | Add `*dream` row to §2 routing table (跳过 TAD 场景 or new row) |

**Terminal Isolation Note (BA-P0-4):** `*dream` is an analytical transformation command like `*optimize` — reads knowledge files, produces candidates via LLM judgment, writes proposals. This is within Alex's scope (same precedent as *optimize writing PROPOSAL YAML). It does NOT write implementation code.

## 7. Acceptance Criteria

- [ ] **AC1:** Baseline verification — `grep -c '^### ' .tad/project-knowledge/architecture.md` matches research finding (119 ± 2)
- [ ] **AC2:** `*dream` protocol added to Alex SKILL.md with 4 phases documented
- [ ] **AC3:** dream-validator.sh exists and passes on a test pair (original + candidate)
- [ ] **AC4:** Running `*dream` on architecture.md produces candidate with ≤50% line count of original
- [ ] **AC5:** MUST/MANDATORY/VIOLATION/BLOCKING count in candidate ≥ count in original
- [ ] **AC6:** 12 stale file refs identified and marked/removed in candidate
- [ ] **AC7:** Foundational section (before "## Accumulated Learnings") is byte-identical in candidate
- [ ] **AC8:** `*dream --rollback` successfully restores from snapshot
- [ ] **AC9:** At least 1 merge demonstrated (e.g., AMENDED+ORIGINAL pair → single entry)

## 8. Required Evidence Manifest

```yaml
expert_reviews:
  - .tad/evidence/reviews/blake/dream-knowledge-consolidation/code-reviewer.md
  - .tad/evidence/reviews/blake/dream-knowledge-consolidation/backend-architect.md
gate_verdicts:
  - .tad/evidence/completions/dream-knowledge-consolidation/GATE3-REPORT.md
completion:
  - .tad/active/handoffs/COMPLETION-20260514-dream-knowledge-consolidation.md
knowledge_updates:
  - .tad/project-knowledge/architecture.md (if new discovery)
```

## 9. Spec Compliance Checklist

| AC | Verification Method | Expected Evidence |
|----|-------|--------|
| AC1 | `grep -c '^### ' .tad/project-knowledge/architecture.md` | 117-121 |
| AC2 | `grep -c 'dream_protocol' .claude/skills/alex/SKILL.md` | ≥1 |
| AC3 | `test -x .tad/hooks/lib/dream-validator.sh` | exit 0 |
| AC4 | `echo "scale=0; $(wc -l < candidate.md) * 100 / $(wc -l < original.md)" \| bc` | ≤50 (for files >500 lines) |
| AC5 | `grep -co 'MUST\|MANDATORY\|VIOLATION\|BLOCKING' original.md candidate.md` | candidate ≥ original |
| AC6 | `bash .tad/hooks/lib/dream-validator.sh --stale-only original.md` then verify candidate has 0 | stale count → 0 in candidate |
| AC7 | `diff <(sed -n '1,/^## Accumulated/p' original) <(sed -n '1,/^## Accumulated/p' candidate)` | empty diff (note: heading line included in boundary) |
| AC8 | `*dream --rollback` then `diff original.md .tad/project-knowledge/architecture.md` | empty diff (restored) |
| AC9 | `grep -c 'Supersedes:' candidate.md` | ≥1 (at least 1 merge with provenance) |

## 9.2 Expert Review Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | CR-P0-1: grep `-coE` with `\|` silently returns 0 | §9 AC5: removed `-E`, use BRE `grep -co` | Resolved |
| code-reviewer | CR-P0-2: Missing 4 files in §6 (standby, greeting, Quick Ref, CLAUDE.md) | §6 File #1 expanded + File #5 added | Resolved |
| code-reviewer | CR-P0-3: README.md has no Foundational/Accumulated boundary | FR3: excluded README.md | Resolved |
| code-reviewer | CR-P1-3: Validator "Grounded in" ALL vs ANY contradiction | §4.3 + §4.5: aligned to "ALL paths missing = stale" | Resolved |
| backend-architect | BA-P0-1: Phase 3 merge "70% overlap" non-deterministic | §4.3: 3 deterministic merge rules + plan review gate | Resolved |
| backend-architect | BA-P0-2: Demotion to details/ = knowledge graveyard | §4.4: removed demotion entirely, in-place summarization only | Resolved |
| backend-architect | BA-P0-3: 4/9 ACs missing verification methods | §9: added AC4, AC6, AC8, AC9 verification commands | Resolved |
| backend-architect | BA-P0-4: Terminal isolation for Alex file I/O | §6: added Terminal Isolation Note (analytical like *optimize) | Resolved |
| backend-architect | BA-P1-1: Missing mid-process gate between Phase 2→3 | §4.3 merge plan + AskUserQuestion before execution | Resolved |
| backend-architect | BA-P1-2: 50% + 15-line demote too aggressive | §4.4: ≤50% only for >500 line files, demote removed, threshold 20 lines | Resolved |
| backend-architect | BA-P1-4: Keyword COUNT not CONTEXT | §10.2: entries with safety keywords excluded from auto-merge entirely | Deferred to P1-4 (Blake judgment) |
| code-reviewer | CR-P1-5: --rollback error handling | Deferred to Blake implementation (document edge cases in protocol) | Deferred |

## 10. Important Notes

### 10.1 Blake 必须在开始前 Read 的文件
- `.tad/evidence/research/dreaming-knowledge-consolidation/2026-05-14-ask-findings.md` (完整研究报告)
- `.tad/evidence/research/dreaming-knowledge-consolidation/challenge-log.md` (challenge 结果)

### 10.2 安全红线
- **永远不直接修改** project-knowledge 原始文件 — 只生成 candidate
- Foundational section 是"宪法"— byte-identical 保护
- MUST/MANDATORY/VIOLATION/BLOCKING 是安全关键词 — 合并时人类决定

## 📚 Project Knowledge

### Research Notebook Findings
Notebook: 'TAD Evolution' (45 + 4 = 49 sources)
Key findings:
- Dreams API: input store + sessions → new store (original untouched)
- dream-skill 4-phase: Orient → Gather Signal → Consolidate → Prune & Index
- Mem0: ADD-only + temporal retrieval; Mem0g: write-time conflict detection
- Controlled forgetting is an open research problem — TAD uses "human gate" approach

### Blake 必须注意的历史教训
- "Mechanical Enforcement Rejected" (architecture.md 2026-04-15): TAD 用软提醒不用机械拦截 — `*dream` 的 validator 是 advisory 不是 blocker
- "Judgment-Only Skill Files: 76% Reduction Was NOT Safe — AMENDED" (architecture.md 2026-04-04): 精简必须保留 constraint rules — validator 检查 MUST/MANDATORY 计数
- "AC Verification Commands Need Pre-Ship Smoke Test" (architecture.md 2026-04-25): §9.1 verification commands 需要 dry-run

## 11. Decision Summary

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | Modification model | In-place edit / Candidate file | Candidate file | Dreams API pattern; safety; rollback |
| 2 | Contradiction resolution | Always-newest / Human-always / Hybrid | Hybrid (safety→human, others→newest) | Challenge C4 risk; AR-001 pattern |
| 3 | Pruning threshold | Hard cap (<200) / Dynamic (≤50%) | Dynamic (≤50%) | Challenge C6 feedback |
| 4 | Scope | architecture.md only / All knowledge files | All knowledge files | User choice in Socratic Q2 |
| 5 | Validator approach | Semantic LLM check / grep count / Both | grep count + Foundational byte-diff | Practical for MVP; LLM check adds cost |
