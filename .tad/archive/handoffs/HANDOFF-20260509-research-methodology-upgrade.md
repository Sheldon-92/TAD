---
task_type: yaml
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta:
  - field: "§5 Latency Impact"
    alex_said: "Worst-case per research item: ~20-30 min"
    actual: "Blake notes worst-case substantially exceeds 60+ min (perspective_shift chains + Auto Source Discovery + Elicit + Adaptive Seed all firing)"
    caught_by: "Blake P2-1 note in completion report"
---

# Handoff: Research Methodology Upgrade — STORM + Elicit + Auto Source + Adaptive Plan
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-05-09
**Project:** TAD Framework
**Task ID:** TASK-20260509-001
**Handoff Version:** 3.1.0
**Epic:** N/A
**Supersedes:** N/A
**Promoted from:** IDEA-20260509-research-methodology-upgrade.md (status: promoted)

---

## 🔴 Gate 2: Design Completeness

**执行时间**: 2026-05-09

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 4 directions mapped to exact insertion points; strategy interaction verified |
| Components Specified | ✅ | SKILL.md sections identified; insertion points corrected per expert review |
| Functions Verified | ✅ | Raw CLI calls verified; --no-follow/SKILL flag distinction clarified |
| Data Flow Mapped | ✅ | Per-seed loop nesting documented; latency impact estimated |

**Gate 2 结果**: ✅ PASS

**Expert Review**: 2 reviewers (code-reviewer + backend-architect), 5 P0 + 6 P1 + 5 P2 found, ALL resolved. See §9.2 Audit Trail.

**Alex确认**: 我已验证所有设计要素，Blake可以独立根据本文档完成实现。

---

## 📋 Handoff Checklist (Blake必读)

- [ ] 阅读了所有章节
- [ ] **阅读了「📚 Project Knowledge」章节中的历史经验**
- [ ] 理解了 step3_5 现有 5 策略的优先级顺序
- [ ] 理解了 research_plan_protocol Phase 4/4b 的执行流
- [ ] 确认可以独立使用本文档完成实现

---

## 1. Task Overview

Upgrade TAD's research methodology by borrowing 4 patterns from STORM, Elicit, and Deep Research into the existing NotebookLM-based research pipeline. All changes are SKILL.md protocol text — no production code, no hooks, no settings.json.

**Scope:** 2 files, ~140 lines of protocol additions
**Priority:** P1

---

## 2. Executive Summary

TAD v2.12.0's research pipeline has cross-source synthesis + dynamic depth-first chains (step3_5), but lacks:
1. Multi-perspective questioning (asking from different expert viewpoints)
2. Structured paper extraction (turning academic sources into queryable structured data)
3. External source discovery when internal gap enrichment fails
4. Adaptive research plan that dynamically expands scope based on findings

---

## 3. Requirements (from Socratic Inquiry)

| # | Requirement | Source |
|---|------------|--------|
| R1 | Add `perspective_shift` strategy to step3_5 — simulate expert viewpoints from OBJECTIVES.md stakeholders | User decision |
| R2 | Add Elicit-style structured extraction in *research-plan Phase 4 (only in *research-plan, NOT on every source add) | User decision |
| R3 | Add external WebSearch + add-smart when Phase 4b gap enrichment fails internally — max 3 sources per gap | User decision |
| R4 | Add adaptive seed generation after so_what chain completion — max 2 dynamically added seeds | User decision |

---

## 4. Technical Design

### 4.1 Direction 1: STORM Multi-Perspective Questioning (perspective_shift)

**Where:** `.claude/skills/research-notebook/SKILL.md` → step3_5 strategy selection block

**Insert position:** After the follow_thread block (block ends at line ~402) and before the gap_enrichment block (comment starts at line ~404). The new strategy becomes the content between lines 402 and 404. Existing gap_enrichment becomes #5; so_what stays #6. Also renumber existing strategy comments: `# 4. Gap enrichment` → `# 5.`; `# 5. Budget-based forced close` → `# 6.`

**TRACK line update:** Change existing TRACK line (line ~343) to:
```
TRACK: current_depth = 1 (after Step 3); new_citations_this_round;
       prev_zero_citation_rounds = 0; strategies_used: [] (append strategy name each round)
```

**Strategy logic:**
```
# 4. Perspective shift — break tunnel vision when same strategy repeats
ELIF current_depth >= 2 AND current_depth < max_depth AND last_strategy_repeated AND NOT conflict AND NOT gap:
  → strategy = "perspective_shift"
  → Guard: if strategies_used[-1] == "perspective_shift" → skip (prevent consecutive perspective_shifts)
  → Derive 2-3 expert perspectives from project context:
      If OBJECTIVES.md exists:
        → Extract stakeholder roles implied by KR descriptions
        → Example: KR about "user retention" → PM perspective; KR about "latency" → SRE perspective
        → Example: KR about "cold-start latency to <2s" → perspective_role="SRE", perspective_focus="latency, reliability, observability"
      Elif .tad/domains/ has loaded packs:
        → Use reviewer persona from the most relevant Domain Pack
      Else:
        → Use 3 generic perspectives:
          - engineer → perspective_focus="implementation feasibility, technical debt, performance"
          - end-user → perspective_focus="usability, onboarding friction, error recovery"
          - skeptic → perspective_focus="assumptions being made, missing counter-evidence, claims without data"
  → Select the perspective LEAST represented in prior rounds
  → Build self-contained follow-up (embed perspective identity):
    "作为一个{perspective_role}（关注{perspective_focus}），关于'{topic}'，
     我最关心的问题是什么？现有发现中哪些对{perspective_role}最重要，哪些被忽略了？"
  → Execute: ~/.tad-notebooklm-venv/bin/notebooklm ask "{follow_up}" -n <notebook_id>
    (same -n flag rule and fail-fast rule as contradiction above)
  → Count new citations; update saturation counter:
      If new_citations == 0: prev_zero_citation_rounds += 1; else: prev_zero_citation_rounds = 0
  → Append "perspective_shift" to strategies_used
  → sleep 1; increment current_depth; append round to chain .md; loop back to step 3.5.
```

**Trigger condition `last_strategy_repeated`:** Check `strategies_used[-1] == strategies_used[-2]` (last two rounds used the SAME strategy name). Any repeated strategy triggers perspective_shift — not just follow_thread. Guard above prevents perspective_shift from triggering itself consecutively.

**⚠️ Critical guard (`current_depth < max_depth`):** Without this, perspective_shift could fire at depth 4 (max_depth) and push depth to 5, bypassing so_what. The guard ensures so_what is always reachable at max_depth.

**Priority order update (full list after change):**
1. saturated (hard stop)
2. contradiction (cross-source conflict)
3. follow_thread (chase surprising findings)
4. **perspective_shift (NEW — break tunnel vision)**
5. gap_enrichment (standalone only)
6. so_what (budget-forced close, TERMINAL)

### 4.2 Direction 2: Elicit Structured Paper Extraction

**Where:** `.claude/skills/alex/SKILL.md` → research_plan_protocol, new Phase 4.5 between Phase 4 (ask loops) and Phase 5 (Extract Actionable Items)

**Trigger:** Only inside *research-plan, only for notebooks that contain academic sources (arxiv, scholar, .edu).

**Protocol text:**
```
f_5. PHASE 4.5 — Structured Paper Extraction (Elicit-style):
   Trigger: ONLY inside *research-plan (never standalone *research-notebook ask)
   → Step 1: Identify academic sources in current notebook
     → ~/.tad-notebooklm-venv/bin/notebooklm source list --json -n <id>
     → Filter sources where url contains "arxiv.org" OR "scholar" OR ".edu" OR "acm.org" OR "ieee.org"
     → If 0 academic sources → skip Phase 4.5 entirely
   → Step 2: For each academic source (max 5 papers per research item):
     → Ask structured extraction question:
       ~/.tad-notebooklm-venv/bin/notebooklm ask \
         "For the paper from {source_url}, extract in structured format:
          1. Research Question (one sentence)
          2. Methodology (one sentence)
          3. Key Findings (list: finding + metric + value where available)
          4. Stated Limitations (list)
          5. Baselines Compared (list)
          6. Publication Year (if identifiable from source URL or content)" \
         -n <id>
       (Raw CLI call — NOT *research-notebook ask — intentional: avoids nested step3_5 loop.
        --no-follow is a SKILL protocol flag, NOT a raw CLI flag — do NOT pass it here.)
     → sleep 1
   → Step 3: Save all extractions to
     .tad/evidence/research/{slug}/{date}-paper-extractions.md
     Format: one section per paper, structured fields as returned
   → Report: "📄 Extracted structured data from {N} academic papers"
```

### 4.3 Direction 3: Auto Source Discovery (WebSearch + add-smart)

**Where:** `.claude/skills/alex/SKILL.md` → research_plan_protocol Phase 4b, insert as step 3c between existing step 3b (deep research fallback) and step 4 (zero-source check).

**Insert after line ~1198 (after the deep research fallback block), before step 4:**
```
3c. External source discovery (WebSearch + add-smart):
    Trigger: AFTER step 3 fast research AND step 3b deep research fallback (if triggered)
             AND net new usable sources still == 0
    → Report: "🌐 Internal enrichment found 0 sources. Searching externally..."
    → WebSearch "{gap_noun_phrases} {broader_topic}" (1 search query)
    → From results, select top 3 URLs (prefer: official docs > GitHub > blog posts)
      Max URLs: 3 (hard cap per user decision)
    → For each URL:
      → Check if URL already exists in notebook sources (dedup):
        → source_urls=$(~/.tad-notebooklm-venv/bin/notebooklm source list --json -n <id> | jq -r '.[].url // empty')
        → If URL already in source_urls → skip
      → Preprocess if needed:
        → If URL matches bilibili/youtube/substack/medium handler patterns:
          bash .tad/cross-model/source-preprocessor.sh "$url"
          → exit 0 → use .md output path; exit 10 → use original URL
        → Else: use URL directly
      → ~/.tad-notebooklm-venv/bin/notebooklm source add "$processed_url_or_path" -n <id>
      → sleep 2
    → Post-import quality probe (per architecture.md "False Success" pattern):
      For each newly added source:
        → Wait 15s for indexing
        → probe=$(~/.tad-notebooklm-venv/bin/notebooklm ask \
            "In one sentence, what is the main topic of the most recently added source?" -n <id>)
        → If probe contains "not from your sources" OR "I don't have" OR is empty:
          → Mark source as failed import; do NOT count toward net new
    → Re-count sources (excluding failed imports). If net new > 0:
      → Report: "🌐 Added {N} external sources (quality-verified). Re-asking..."
      → Proceed to step 5 (lightweight re-curate), then step 6 (re-ask)
    → If net new still == 0:
      → Report: "⚠️ External search also found 0 usable sources for Q{N}."
      → Proceed to step 4 (zero-source check → skip re-ask)
```

**Key constraint:** This runs ONLY after both fast AND deep internal enrichment fail. It's the last resort, not the first. After adding sources, a quality probe verifies actual content was indexed (not just `status: ready` — see architecture.md "False Success" entry).

### 4.4 Direction 4: Adaptive Research Plan (Dynamic Seed Generation)

**Where:** `.claude/skills/alex/SKILL.md` → research_plan_protocol Phase 4, WITHIN the Step 2 per-seed loop, after Phase 4b completes for the current seed.

**Insert after the Phase 4b complete block (after line ~1226, `When no gap signal: skip PHASE 4b entirely, proceed normally`), before Step 3 (line ~1228, save findings). This ensures Adaptive Seed analysis runs AFTER both the ask chain AND gap enrichment for each question — not before Phase 4b.**

```
Step 2.5: Adaptive Seed Generation (after each seed's chain + Phase 4b completes)
  MAX_DYNAMIC_SEEDS: 2  # hard cap — prevents unbounded growth (total, not per-level)
  TRACK: dynamic_seeds_added = 0 (initialized at Phase 4 entry)

  After each seed question's ask chain (step3_5) AND Phase 4b gap enrichment completes:
  → Read the chain's so_what round (or final round if saturated early)
  → Analyze: "Did this chain reveal a sub-topic NOT covered by any existing or pending seed?"
    Detection signals:
      - Answer mentions a concept/tool/framework not in any seed question
      - Answer explicitly says "this area needs further investigation"
      - Chain surfaced a surprising finding (from step3_5 surprising dimension) that opens a new thread
  → If new sub-topic detected AND dynamic_seeds_added < MAX_DYNAMIC_SEEDS:
    a. Generate new seed question following question format rules (specificity anchor mandatory):
       Format: "Based on chain finding '{surprising_finding}': {specific question with anchor}"
    b. AskUserQuestion: "研究中发现了新的子话题。要追加一个新的研究问题吗？"
       question: "Chain '{original_seed}' revealed: '{finding_summary}'. 追加新问题？"
       Options:
         - "追加: {generated_question} (Recommended)" → append to seed list, dynamic_seeds_added += 1
         - "跳过这个发现" → continue to next seed
         - "自定义问题" → user types their own, dynamic_seeds_added += 1
    c. New seed inherits notebook context (same -n flag, same Phase 4 execution)
       In cross-notebook mode: dynamic seeds undergo the same notebook relevance check as original seeds
    d. New seed executes after all original seeds complete (append to end of queue, not insert)
    e. Dynamic seeds receive full Phase 4b treatment (gap detection + auto-enrichment + auto source discovery)
    f. Adaptive Seed check does NOT run for dynamically-added seeds (prevents meta-seed generation)
       Queue is flat — all dynamic seeds append to end regardless of which seed spawned them
  → If dynamic_seeds_added >= MAX_DYNAMIC_SEEDS:
    → Report: "📋 Dynamic seed cap reached (2/2). Remaining findings saved for reference."
    → Continue without adding more seeds
```

---

## 5. Data Flow

```
*research-plan entry
  → Phase 0: Research Plan
  → Phase 1: GitHub-First Sourcing
  → Phase 2: Auto-Curate
  → Phase 3: Baseline Report
  → Phase 4: Seed Questions + Dynamic Ask
    → FOR EACH seed (original + dynamic):
      → step3_5 chain (4 rounds max)
        → Round strategy selection:
          1. saturated → stop
          2. contradiction → cross-source resolve
          3. follow_thread → chase finding
          4. perspective_shift (NEW) → OBJECTIVES stakeholder angle
          5. gap_enrichment → internal source add (standalone only)
          6. so_what → terminal close
      → Phase 4b: Gap enrichment per question
        → fast research → deep research fallback
        → Auto Source Discovery (NEW) → WebSearch + quality-probed add (max 3 URLs)
      → Adaptive Seed Check (NEW, max 2 total, original seeds only — not recursive)
    → Step 3: Save findings
  → Phase 4.5: Elicit Paper Extraction (NEW, once per notebook, academic sources only)
  → Phase 5: Extract Actionable Items
```

**Latency Impact:** Worst-case per research item: ~20-30 min (vs baseline ~8 min). All 4 new features firing maximally roughly doubles worst-case. User is informed via Phase 4 entry message.

---

## 6. Files to Modify

| # | File | Change Type | Lines Added (est.) |
|---|------|-------------|-------------------|
| 1 | `.claude/skills/research-notebook/SKILL.md` | Insert perspective_shift strategy in step3_5 | ~30 |
| 2 | `.claude/skills/alex/SKILL.md` | Insert Elicit Phase 4.5 + Auto Source 3c + Adaptive Seed 2.5 + priority order comment update | ~110 |

**Total:** ~140 lines of protocol text additions across 2 files.

### 6.1 Implementation Order

1. **research-notebook/SKILL.md** — perspective_shift strategy (Direction 1)
   - Insert after follow_thread block (~line 402)
   - Update priority order comment at top of step3_5
   - Update TRACK line to include `strategies_used_per_round: []` for tunnel detection

2. **alex/SKILL.md** — 3 changes in research_plan_protocol:
   a. Phase 4b step 3c: Auto Source Discovery (Direction 3) — insert after step 3b (~line 1198)
   b. Phase 4 Step 2.5: Adaptive Seed (Direction 4) — insert after Phase 4b complete block (~line 1226), before Step 3 (~line 1228)
   c. Phase 4.5: Elicit Extraction (Direction 2) — insert between Phase 4 Step 3 and Phase 5 (~line 1232)

### Grounded Against (Alex step1c):
- .claude/skills/research-notebook/SKILL.md (head 50 + lines 270-432, read at 2026-05-09)
- .claude/skills/alex/SKILL.md (lines 1125-1234, read at 2026-05-09)

---

## 7. Acceptance Criteria

| # | Criterion | Verification |
|---|-----------|-------------|
| AC1 | perspective_shift strategy exists in step3_5 between follow_thread and gap_enrichment | `grep -c "perspective_shift" .claude/skills/research-notebook/SKILL.md` returns ≥3 |
| AC2 | perspective_shift derives perspectives from OBJECTIVES.md first, Domain Pack second, generic third | Read step3_5 perspective_shift block; verify 3-tier fallback order |
| AC3 | perspective_shift triggers only when last 2 rounds used same strategy (tunnel detection) | Read trigger condition; verify `last_two_strategies_same_angle` logic present |
| AC4 | Elicit extraction Phase 4.5 exists between Phase 4 and Phase 5 | `grep -c "PHASE 4.5" .claude/skills/alex/SKILL.md` returns ≥1 |
| AC5 | Elicit only runs inside *research-plan (never standalone ask) | Read Phase 4.5 trigger; verify "ONLY inside *research-plan" present |
| AC6 | Elicit filters for academic sources (arxiv, scholar, .edu, acm, ieee) | Read Phase 4.5 Step 1 filter; verify all 5 patterns |
| AC7 | Auto Source Discovery (step 3c) runs AFTER both fast and deep internal enrichment fail | Read Phase 4b step 3c trigger; verify "net new usable sources still == 0" precondition |
| AC8 | Auto Source Discovery max 3 URLs per gap (hard cap) | `grep -c "Max URLs: 3" .claude/skills/alex/SKILL.md` returns ≥1 |
| AC9 | Auto Source Discovery includes source-preprocessor.sh for bilibili/youtube/etc | Read step 3c; verify preprocessor integration present |
| AC10 | Adaptive Seed max 2 dynamic seeds (MAX_DYNAMIC_SEEDS: 2) | `grep "MAX_DYNAMIC_SEEDS.*2" .claude/skills/alex/SKILL.md` returns ≥1 |
| AC11 | Adaptive Seed uses AskUserQuestion to confirm each new seed (not auto-add) | Read Step 2.5; verify AskUserQuestion present |
| AC12 | Adaptive Seed new seeds execute after all original seeds (append, not insert) | Read Step 2.5 step d; verify "append to end of queue" |
| AC13 | step3_5 priority order comment updated to reflect 6-strategy list | Read top of step3_5; verify numbered list includes perspective_shift at #4 |
| AC14 | No changes to settings.json, hooks, or any file outside the 2 listed | `git diff --name-only` shows only 2 files |

---

## 8. Required Evidence Manifest

```yaml
expert_reviews:
  - .tad/evidence/reviews/blake/research-methodology-upgrade/code-reviewer.md
  - .tad/evidence/reviews/blake/research-methodology-upgrade/backend-architect.md
gate_verdicts:
  - .tad/evidence/completions/research-methodology-upgrade/GATE3-REPORT.md
completion:
  - .tad/active/handoffs/COMPLETION-20260509-research-methodology-upgrade.md
knowledge_updates:
  - .tad/project-knowledge/architecture.md  # if new discovery
```

---

## 9. Spec Compliance

### 9.1 Spec Compliance Checklist

| # | AC | Verification Method | Expected Evidence | Verified Output |
|---|-----|-------------------|-------------------|-----------------|
| AC1 | perspective_shift in step3_5 | `grep -c "perspective_shift" .claude/skills/research-notebook/SKILL.md` | ≥3 | (post-impl) |
| AC4 | Phase 4.5 exists | `grep -c "PHASE 4.5" .claude/skills/alex/SKILL.md` | ≥1 | (post-impl) |
| AC10 | MAX_DYNAMIC_SEEDS | `grep "MAX_DYNAMIC_SEEDS.*2" .claude/skills/alex/SKILL.md` | ≥1 | (post-impl) |
| AC14 | Only 2 files changed | `git diff --name-only` | 2 lines | (post-impl) |

### 9.2 Expert Review Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | CR-P0-1: `--no-follow` is SKILL flag not CLI flag — Elicit comment misleading | §4.2 Step 2 comment + §10.1 rewritten | Resolved |
| code-reviewer | CR-P0-2: Line number imprecision for insertion point | §4.1 insertion description rewritten | Resolved |
| code-reviewer | CR-P0-3: perspective_shift missing fail-fast rule reference | §4.1 strategy logic — added `(same -n flag rule and fail-fast rule as contradiction above)` | Resolved |
| code-reviewer | CR-P0-4: `source add` raw CLI lacks quality probe (add-smart has it) | §4.3 step 3c — added post-import quality probe block | Resolved |
| backend-architect | BA-P0-1: `--no-follow` comment misleading (same as CR-P0-1) | §4.2 + §10.1 | Resolved |
| backend-architect | BA-P0-2: perspective_shift lacks `current_depth < max_depth` guard — depth overflow | §4.1 — added `AND current_depth < max_depth` to trigger + critical guard note | Resolved |
| backend-architect | BA-P0-3: Adaptive Seed placement ambiguity — should be after Phase 4b not after line ~1177 | §4.4 — insertion point changed to after Phase 4b (~line 1226); clarified ordering rules (e/f) | Resolved |
| code-reviewer | CR-P1-1: Adaptive Seed insertion ~1177 wrong (same as BA-P0-3) | §4.4 + §6.1 | Resolved |
| code-reviewer | CR-P1-2: Tunnel detection should check ANY repeated strategy not just follow_thread | §4.1 — renamed to `last_strategy_repeated`, checks any same-strategy pair + self-loop guard | Resolved |
| code-reviewer | CR-P1-3: TRACK line update not specified | §4.1 — added exact TRACK line with `strategies_used: []` | Resolved |
| code-reviewer | CR-P1-4: AC8 grep too broad | §7 AC8 — tightened to exact `"Max URLs: 3"` | Resolved |
| code-reviewer | CR-P1-5: Data flow diagram missing per-question vs per-notebook nesting | §5 — rewritten with FOR EACH loop and nesting | Resolved |
| backend-architect | BA-P1-1: perspective_shift self-loop (consecutive perspective_shifts) | §4.1 — added guard: skip if `strategies_used[-1] == "perspective_shift"` | Resolved |
| backend-architect | BA-P1-2: Step 3c cleanup duplication — should use step 5 not inline | §4.3 — changed to "Proceed to step 5 (lightweight re-curate), then step 6 (re-ask)" | Resolved |
| backend-architect | BA-P1-5: Renumber existing strategy comments after insertion | §4.1 insertion description — added explicit renumber instruction | Resolved |
| code-reviewer | CR-P2-1: Add perspective_focus examples per tier | §4.1 — added concrete examples for OBJECTIVES.md + generic tiers | Resolved |
| code-reviewer | CR-P2-2: §9.1 only lists 4 of 14 ACs | Deferred — Blake's Layer 1 runs all 14 at Gate 3 |
| code-reviewer | CR-P2-3: Elicit schema missing Publication Year | §4.2 — added field 6: Publication Year | Resolved |
| code-reviewer | CR-P2-4: Dynamic seed nesting behavior underspecified | §4.4 — added rules (e) Phase 4b applies to dynamic seeds, (f) Adaptive Seed does NOT run for dynamic seeds | Resolved |
| backend-architect | BA-P2-1: Latency impact estimate missing | §5 — added Latency Impact note (~20-30 min worst case) | Resolved |
| backend-architect | BA-P2-2: Cross-notebook clarification for dynamic seeds | §4.4 rule (c) — added cross-notebook note | Resolved |
| backend-architect | BA-P2-3: AC8 grep overcounts (same as CR-P1-4) | §7 AC8 | Resolved |

---

## 10. Important Notes

### 10.1 Critical Constraints

- **Raw CLI vs SKILL command:** Elicit extraction and perspective_shift ask calls MUST use raw CLI (`~/.tad-notebooklm-venv/bin/notebooklm ask`), NOT the `*research-notebook ask` SKILL command. Raw CLI bypasses step3_5 entirely. Note: `--no-follow` is a SKILL protocol flag parsed in Step 0 of `*research-notebook ask` — it is NOT a raw CLI flag and must NOT be passed to the binary. See architecture.md "Expert Reviewer Premise Check: Raw CLI vs SKILL Command Distinction — 2026-05-09".
- **-n flag only, never `use`:** All notebook operations in loops must use `-n <id>` flag, never `notebooklm use`. See architecture.md "NotebookLM CLI State Management — 2026-05-05".
- **Source preprocessor for external sources:** Auto Source Discovery must route URLs through source-preprocessor.sh for bilibili/youtube/substack/medium. See architecture.md "NotebookLM Source Import: 'False Success' More Dangerous Than Failure — 2026-05-09".

### 10.2 Anti-Patterns

- ⚠️ Do NOT make perspective_shift trigger on every round — only when tunnel detection fires (2+ same-angle rounds)
- ⚠️ Do NOT run Elicit extraction on every source add globally — only inside *research-plan
- ⚠️ Do NOT skip the AskUserQuestion in Adaptive Seed — user must confirm each dynamic seed
- ⚠️ Do NOT insert dynamic seeds mid-queue — append to end only

---

## 📚 Project Knowledge

### ⚠️ Blake 必须注意的历史教训

| Entry | Source | Relevance |
|-------|--------|-----------|
| Dynamic Research Chain: Saturation Counter Must Be Explicitly Persisted | architecture.md | perspective_shift adds a new strategy that must update saturation counters correctly |
| Expert Reviewer Premise Check: Raw CLI vs SKILL Command Distinction | architecture.md | Elicit extraction uses raw CLI, must NOT trigger step3_5 |
| NotebookLM CLI State Management: -n Flag vs use Command | architecture.md | All loop operations use -n only |
| NotebookLM Source Import: False Success More Dangerous Than Failure | architecture.md | Auto Source Discovery imports external URLs — verify quality |
| Multi-Phase Handler Fallback: Fast-Fail Before Slow-Fail | architecture.md | Auto Source Discovery is last resort after fast + deep fail |

---

## 11. Decision Summary

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | Scope | 2 HIGH only / 3 HIGH / all 4 | All 4 | User chose comprehensive upgrade |
| 2 | Elicit trigger | Always on source add / *research-plan only / user confirm | *research-plan only | Avoid ~23s overhead per source add |
| 3 | Auto Source max URLs | 3 / 5 / unlimited | 3 per gap | Balance quality and speed |
| 4 | Adaptive Seed max | 1 / 2 / 3 | 2 | Prevent seed explosion while allowing depth |
| 5 | STORM perspective source | Domain Pack reviewers / OBJECTIVES.md / fixed 5 | OBJECTIVES.md stakeholders | Most contextually relevant to research goals |
