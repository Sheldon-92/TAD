---
task_type: yaml
e2e_required: no
research_required: no
skip_knowledge_assessment: no
---

# Handoff: Research Methodology Upgrade — From "Report-Only" to "Full Research Lifecycle"

**From:** Alex | **To:** Blake | **Date:** 2026-05-05
**Type:** Standard TAD
**Priority:** P1

## 1. Executive Summary

Upgrade TAD's research methodology from a shallow "create → research → report → done" pipeline to a complete 5-step lifecycle: "create → research → curate → report(baseline) → ask loops(deep extraction) → save findings". Based on empirical evidence from menu-snap project (2026-05-05) showing 150-200x token efficiency improvement and 24x source coverage when using NotebookLM properly.

## 2. Problem Statement

Current `*research-plan` step4 treats report generation as the final step. User's real-world test proved:
- Report alone = wasting notebook's core capability (cross-source reasoning)
- No automated cleanup after deep research (30% error sources, 25% duplicates)
- No structured question methodology (ad-hoc asks vs KR-driven question tree)
- No bridge from research findings to handoff AC
- Notebooks are siloed (no cross-notebook queries for overlapping topics)

Evidence: `.tad/evidence/research/2026-05-05-notebooklm-research-session-log.md` (menu-snap, 264 lines)

## 3. Requirements (from Socratic Inquiry)

| # | Requirement | User Decision |
|---|-------------|---------------|
| R1 | Curate automation level | Fully automatic (clean error + dedup, only report results) |
| R2 | Ask question design | Alex auto-generates Question Tree from OBJECTIVES.md KRs, user confirms |
| R3 | Ask rounds | One question per KR (KR count determines rounds) |
| R4 | Research→AC bridge | Alex extracts actionable items, suggests AC entries, user confirms |
| R5 | Dedup strategy | Title exact match + same URL domain = duplicate |
| R6 | Cross-notebook | Serial query each relevant notebook, Alex synthesizes in-session |
| R7 | Source quality tiering | Tier 1 (official/academic), Tier 2 (industry), Tier 3 (community) |
| R8 | Scope | All 5 improvement directions in single handoff |

## 4. Technical Design

### 4.1 `*research-plan` step4 Upgrade (alex/SKILL.md)

Replace current step4.b-d (lines ~1045-1066) with expanded 5-phase pipeline:

```yaml
step4:
  name: "执行研究 (5-Phase Pipeline)"
  action: |
    [EXECUTION MECHANISM block stays unchanged — lines 1020-1037]

    For each confirmed research item:

    a. 确定 target notebook:
       → If existing notebook matches topic → use it
       → If no match → *research-notebook create "{topic}" (new notebook)

    b. PHASE 1 — Deep Research:
       → *research-notebook research "{question}" --mode deep
       → Wait for completion, capture source_count

    c. PHASE 2 — Auto-Curate (fully automatic, no user interaction):
       → Step 1: Delete error sources
         → notebooklm source list --json -n <id>
         → Filter sources where status != "ready"
         → For each: notebooklm source delete <source_id> -n <id> --yes
         → Delay 0.5s between deletes (rate limit protection)
         → Report: "🧹 Cleaned {N} error sources"
       → Step 2: Deduplicate (title + domain match)
         → Group sources by (lowercase title, URL domain)
         → For each group with count > 1: keep first, delete rest
         → Delay 0.5s between deletes
         → Report: "🔄 Removed {N} duplicates, {M} unique sources remain"
       → Step 3: Source quality tiering
         → For each remaining source, classify by URL pattern:
           Tier 1 (🏛️): .gov, .edu, .org (official), arxiv.org, pubmed, WHO, FDA, Apple developer docs
           Tier 2 (📰): medium.com, dev.to, blog.*, docs.* (vendor), stackoverflow
           Tier 3 (💬): reddit.com, forum.*, community.*, twitter/x
           Unknown (❓): everything else
         → Store tier in conversation context (not persisted to REGISTRY — tier is ephemeral judgment)
         → Report: "📊 Source quality: {T1} Tier 1, {T2} Tier 2, {T3} Tier 3"

    d. PHASE 3 — Baseline Report:
       → *research-notebook report "{topic} comprehensive analysis"
       → Save to .tad/evidence/research/{slug}/{date}-report.md
       → Report: "📄 Baseline report saved. This is orientation, not the final deliverable."

    e. PHASE 4 — Question Tree + Ask Loops:
       → Step 1: Generate Question Tree from OBJECTIVES.md
         → If OBJECTIVES.md not found in project root:
           → Display: "No OBJECTIVES.md found — skipping Question Tree + AC Bridge (Phase 4-5)."
           → SKIP Phase 4 and Phase 5 entirely. Phase 3 report is the final deliverable.
           → Proceed to step4 post-processing (step d "After ALL items complete")
         → Read OBJECTIVES.md KRs aligned with this research item
         → For each KR with status ⬚/🔄, generate 1-3 targeted questions depending on KR breadth:
           (KRs with status ✅ → skip, 0 questions. Broad KRs → up to 3 sub-questions.)
           Format: "KR: {KR description} → Q: {specific question this notebook can answer}"
         → Display Question Tree to user:
           "📋 Question Tree (based on {N} KRs):"
           | # | KR | Question | Priority |
         → AskUserQuestion: "这些问题对吗？"
           Options: "确认执行" / "我要调整" / "加自定义问题" / "跳过 ask"
       → Step 2: Execute ask loops (sequential, with 1s delay between asks)
         → For each confirmed question:
           → If cross-notebook query needed (topic spans multiple notebooks):
             → Identify relevant notebooks from REGISTRY (LLM semantic match)
             → If REGISTRY has only 1 active notebook → skip cross-notebook, use single ask
             → Save current active_notebook from REGISTRY before loop
             → For each relevant notebook:
               → ~/.tad-notebooklm-venv/bin/notebooklm ask "{question}" -n <notebook_id>
               → (Use -n flag ONLY — do NOT call `notebooklm use`. -n is stateless per-command override.
                  `use` mutates global active notebook state which leaks across loop iterations.)
               → sleep 1
             → After loop: restore active_notebook in REGISTRY.yaml to saved value
             → Alex synthesizes answers from all notebooks in conversation
             → Note which notebook contributed what (for traceability)
           → Else (single notebook):
             → ~/.tad-notebooklm-venv/bin/notebooklm ask "{question}" -n <id>
           → For important questions (tied to ⬚ KR): prefer Tier 1 sources
             → ~/.tad-notebooklm-venv/bin/notebooklm ask "{question} — prioritize official/academic sources" -n <id>
           → sleep 1 between consecutive ask calls (rate limit protection)
       → Step 3: Save findings
         → Write all ask results to .tad/evidence/research/{slug}/{date}-ask-findings.md
         → Format: per-question sections with KR reference, answer summary, source citations

    f. PHASE 5 — Extract Actionable Items (Research→AC Bridge):
       → Step 1: From all ask answers, extract engineering-actionable items
         → Format: "Based on {KR}, research shows: {finding} → Suggested AC: {concrete acceptance criterion}"
         → Example: "KR1 sesame recall: 担担面 → sesame paste mapping → AC: allergen-rules must contain dandan→sesame rule"
       → Step 2: Display extracted ACs to user
         → AskUserQuestion: "研究提取了 {N} 个可执行项。哪些要写入下一个 handoff 的 AC？"
           Options: "全部采纳" / "逐条确认" / "只保存，不写 AC"
       → Step 3: If adopted, write to .tad/evidence/research/{slug}/{date}-extracted-acs.md
         → These ACs are READY TO COPY into a future handoff's §9 Acceptance Criteria
       → Report: "✅ Research complete. {N} actionable items extracted, {M} adopted as future ACs."
```

### 4.2 `*research-notebook curate` Upgrade (research-notebook/SKILL.md)

Add two new sub-steps to the existing curate command (insert BEFORE Step 2):

```yaml
Step 1b: Auto-clean error sources (NEW — fully automatic)
  → ~/.tad-notebooklm-venv/bin/notebooklm source list --json -n <notebook_id>
  → Parse JSON: each source object has an `id` field (server-side UUID string).
    Filter sources where `status` field contains "error" (explicit error state only).
    Do NOT delete sources with status "preparing" or "processing" — these may complete successfully.
  → For each error source:
    → ~/.tad-notebooklm-venv/bin/notebooklm source delete <source.id> -n <notebook_id> --yes
    → sleep 0.5 (rate limit protection — empirically required per menu-snap test)
  → Report: "🧹 Cleaned {N} error sources ({M} remaining)"
  → If N == 0: "✅ No error sources found"
  → ⚠️ DEFENSIVE: If `source list --json` output structure is unexpected (no `id` field,
    different JSON shape), STOP and report: "source list JSON format changed — manual curate needed"

Step 1c: Auto-deduplicate (NEW — fully automatic)
  → From remaining sources, group by (lowercase(title), extract_domain(url))
  → extract_domain: parse URL to domain only (e.g., "arxiv.org", "developer.apple.com")
    → Sources without URL (type=text/file) → skip dedup (unique by definition)
  → For each group with count > 1:
    → Keep the FIRST source (by add date), delete rest
    → ~/.tad-notebooklm-venv/bin/notebooklm source delete <source.id> -n <notebook_id> --yes
    → sleep 0.5
  → Report: "🔄 Removed {N} duplicates ({M} unique sources remain)"
  → If N == 0: "✅ No duplicates found"
```

### 4.3 Source Quality Tiering (in curate output)

Add to curate Step 3 output table:

```yaml
Step 3 (UPDATED): Output curation report with quality tier
  | # | Source | Type | Tier | Added | Age-Stale | Content-Stale | Suggestion |
  Tier column values: 🏛️ T1 / 📰 T2 / 💬 T3 / ❓ Unknown
  
  Tier classification rules (by URL pattern):
    tier1_patterns: [".gov", ".edu", "arxiv.org", "pubmed", ".who.int", "fda.gov",
                     "developer.apple.com", "developers.google.com", "docs.anthropic.com",
                     "owasp.org", "w3.org", "ietf.org"]
    tier2_patterns: ["medium.com", "dev.to", "stackoverflow.com", "docs.*", "blog.*",
                     ".readthedocs.io", "github.com/*/wiki"]
    tier3_patterns: ["reddit.com", "x.com", "twitter.com", "forum.*", "community.*",
                     "news.ycombinator.com"]
    unknown: everything else
```

### 4.4 Cross-Notebook Query (in *research-plan step4.e.Step2)

Already specified inline in step4.e above. Key design points:
- Serial execution (query notebook A, then notebook B, then synthesize)
- Alex does synthesis in conversation context (not a tool)
- Traceability: note which notebook contributed which answer
- Trigger: LLM semantic match against REGISTRY topics

### 4.5 Tool Quick Reference Update

Update `.tad/guides/tool-quick-reference-alex.md` research-notebook table to reflect new methodology:

Add row:
```
| `*research-notebook curate` (upgraded) | Auto-clean errors + dedup + tier | After every deep research |
```

Update *research-plan summary to mention 5-phase pipeline.

## 5. Acceptance Criteria

- [ ] AC1: `*research-plan` step4 contains "PHASE 1" through "PHASE 5" labels
- [ ] AC2: `*research-plan` step4 contains "Question Tree" and "OBJECTIVES.md KRs"
- [ ] AC3: `*research-plan` step4 contains "Research→AC Bridge" or "Extract Actionable Items"
- [ ] AC4: `*research-notebook curate` contains "Step 1b" (error clean) and "Step 1c" (dedup)
- [ ] AC5: curate contains "sleep 0.5" rate limit protection
- [ ] AC6: curate Step 3 output table contains "Tier" column
- [ ] AC7: curate tier classification contains "tier1_patterns" with at least ".gov" and ".edu"
- [ ] AC8: step4 cross-notebook query mentions "serial" execution and "synthesize" in conversation
- [ ] AC9: tool-quick-reference-alex.md updated with curate upgrade mention

## 6. Files to Modify

| File | Change |
|------|--------|
| `.claude/skills/alex/SKILL.md` | Replace step4.b-d with 5-phase pipeline (~lines 1045-1066) |
| `.claude/skills/research-notebook/SKILL.md` | Add Step 1b + 1c to curate; update Step 3 table (~lines 248-288) |
| `.tad/guides/tool-quick-reference-alex.md` | Add curate upgrade row + 5-phase mention |

**Grounded Against** (Alex step1c):
- .claude/skills/alex/SKILL.md (lines 1017-1066, read at 2026-05-05)
- .claude/skills/research-notebook/SKILL.md (lines 244-288, read at 2026-05-05)
- .tad/guides/tool-quick-reference-alex.md (created earlier today, read at 2026-05-05)

## 7. Expert Review Status

| Expert | Status | Findings |
|--------|--------|----------|
| code-reviewer | Pending | |
| backend-architect | Pending | |

## 8. Important Notes

- The 5-phase pipeline is based on empirical data (menu-snap 2026-05-05), not theoretical design
- Phase 2 (curate) must include 0.5s delay between deletes — without it, NotebookLM API rate-limits all deletions to failure
- Phase 4 Question Tree is derived from OBJECTIVES.md — if project has no OBJECTIVES.md, skip Phase 4-5 and fall through to existing report-only behavior
- Phase 5 (AC extraction) saves to evidence files, NOT directly to handoffs — human controls what enters handoff AC
- Cross-notebook is serial by design (NotebookLM API is stateful per-notebook `use` command)

## 9. Spec Compliance Checklist

| AC | Verification Method | Expected Evidence |
|----|--------------------|--------------------|
| AC1 | `grep -c "PHASE [1-5]" .claude/skills/alex/SKILL.md` | ≥ 5 |
| AC2 | `grep -c "Question Tree" .claude/skills/alex/SKILL.md` | ≥ 1 |
| AC3 | `grep -cE "Research.*AC Bridge\|Extract Actionable" .claude/skills/alex/SKILL.md` | ≥ 1 |
| AC4 | `grep -c "Step 1[bc]" .claude/skills/research-notebook/SKILL.md` | ≥ 2 |
| AC5 | `grep -c "sleep 0.5" .claude/skills/research-notebook/SKILL.md` | ≥ 1 |
| AC6 | `grep -c "Tier" .claude/skills/research-notebook/SKILL.md` | ≥ 3 |
| AC7 | `grep -c "tier1_patterns" .claude/skills/research-notebook/SKILL.md` | ≥ 1 |
| AC8 | `grep -cE "serial\|synthesize" .claude/skills/alex/SKILL.md` | ≥ 1 |
| AC9 | `grep -c "curate" .tad/guides/tool-quick-reference-alex.md` | ≥ 1 |

## 10. Decision Summary

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | Curate automation | Full-auto / Semi-auto / Manual | Full-auto | Error sources and exact-title duplicates have no ambiguity — safe to auto-delete |
| 2 | Question design | User-specified / Auto-generated / Mixed | Auto-generated (user confirms) | KR-driven questions ensure research is goal-aligned, user confirmation preserves control |
| 3 | Ask rounds | Fixed 3 / KR-driven / User-decides | KR-driven | Each KR deserves at least 1 targeted question; real-world test showed 3 was enough for 3 KRs |
| 4 | Research→AC | Auto-write / Suggest+confirm / Save-only | Suggest+confirm | Research findings need human judgment to become engineering requirements |
| 5 | Dedup strategy | Title-only / Title+domain / LLM-semantic | Title+domain | Balances accuracy vs complexity; same title + same domain = definite duplicate |
| 6 | Cross-notebook | Serial+synthesize / Merge notebooks / Skip | Serial+synthesize | NotebookLM API doesn't support cross-notebook queries natively; serial is simplest reliable approach |

## 11. Blake Instructions

- This is a YAML/protocol text upgrade — no runtime code, no hooks, no scripts
- The §4 Technical Design section contains the exact text to insert/replace
- For alex/SKILL.md: replace lines ~1039-1066 (from "For each confirmed research item:" through step4.d) with the new 5-phase content from §4.1
- For research-notebook/SKILL.md: insert Step 1b + 1c BEFORE existing Step 2 (~line 248), update Step 3 table format
- Keep the EXECUTION MECHANISM block (lines 1020-1037) unchanged — it was just added in v2.10.2
- Apply fix → Layer 1 grep ACs → Layer 2 expert review → done

## §9.2 Expert Review Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|--------------------|--------|
| code-reviewer | P0-1: AC10 redundant with AC1 | AC10 dropped from §5 + §9 | Resolved |
| code-reviewer | P0-2: `use` + `-n` redundant, state leak | §4.1 step4.e.Step2: removed `use`, `-n` only + active_notebook restore | Resolved |
| code-reviewer | P0-3: No OBJECTIVES.md guard in step4.e | §4.1 step4.e.Step1: explicit guard added | Resolved |
| code-reviewer | P0-4: Bare `notebooklm` in §4.2 | §4.2: all CLI paths changed to `~/.tad-notebooklm-venv/bin/notebooklm` | Resolved |
| backend-architect | P0-1: Cross-notebook state mutation (same as CR P0-2) | Same fix — `-n` only, no `use` | Resolved |
| backend-architect | P0-2: Missing OBJECTIVES.md guard (same as CR P0-3) | Same fix — explicit guard in step4.e | Resolved |
| backend-architect | P0-3: source_id field name unspecified | §4.2 Step 1b: specified `id` field + defensive fallback | Resolved |
| code-reviewer | P1-1: Dedup duplicated between step4.c and curate 1c | Deferred — step4.c references curate for cleanup, keeps tiering inline | Open |
| code-reviewer | P1-4: No rate limit in ask loops | §4.1 step4.e.Step2: added `sleep 1` between asks | Resolved |
| backend-architect | P1-1: 1 question per KR too rigid | §4.1 step4.e.Step1: changed to 1-3 questions per KR breadth, skip ✅ KRs | Resolved |
| backend-architect | P1-3: AC extraction as YAML not MD | Deferred to follow-up — v1 uses MD, future upgrade to YAML | Open |
| backend-architect | P1-4: Session context overflow >10 items | Deferred to follow-up — circuit breaker for large plans | Open |
