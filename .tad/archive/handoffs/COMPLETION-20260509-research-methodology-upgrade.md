---
handoff_slug: research-methodology-upgrade
completed_by: Blake
completion_date: 2026-05-09
gate3_status: PASS
gate4_status: pending
---

# Completion Report: Research Methodology Upgrade

## Executive Summary

All 14 ACs pass. 4 research methodology upgrades implemented: perspective_shift strategy (#4 of 6), Phase 4.5 Elicit paper extraction, Phase 4b step 3c Auto Source Discovery, Phase 4 Step 2.5 Adaptive Seed Generation. code-reviewer P1-1 (tunnel detection off-by-one) and backend-architect P1-1/P1-2 (step 3c probe ambiguity + dynamic_seeds_added compact-recovery) all fixed.

---

## AC Verification

| AC | Description | Result |
|----|-------------|--------|
| AC1 | perspective_shift in step3_5 ≥3 | 4 ✅ |
| AC2 | 3-tier perspective fallback | Tier 1/2/3 blocks present ✅ |
| AC3 | Tunnel detection (strategies_used[-1] == [-2]) | present ✅ |
| AC4 | PHASE 4.5 exists | 1 ✅ |
| AC5 | Phase 4.5 ONLY inside *research-plan | 1 ✅ |
| AC6 | 5 academic source filters | all 5 on same line ✅ |
| AC7 | Auto Source after fast+deep fail | 2 ✅ |
| AC8 | Max URLs: 3 hard cap | 1 ✅ |
| AC9 | source-preprocessor.sh integration | 1 ✅ |
| AC10 | MAX_DYNAMIC_SEEDS: 2 | 1 ✅ |
| AC11 | AskUserQuestion in Adaptive Seed | present ✅ |
| AC12 | Append to end of queue | 2 ✅ |
| AC13 | 6-strategy priority list updated | 2 ✅ |
| AC14 | Only 2 SKILL.md files changed | confirmed ✅ |

---

## Layer 2 Expert Review

| Reviewer | Verdict | P0 | P1 | P2 |
|----------|---------|----|----|-----|
| code-reviewer | PASS (after fix) | 0 | 1→0 | 3 |
| backend-architect | PASS (after fixes) | 0 | 2→0 | 3 |

**code-reviewer P1-1 (fixed)**: tunnel detection `current_depth >= 2` off-by-one → changed to `current_depth >= 3 AND len(strategies_used) >= 2`.

**backend-architect P1-1 (fixed)**: Step 3c "most recently added" probe targets wrong source after 3-URL loop → changed to source-ID-based verify_import_quality HELPER call.

**backend-architect P1-2 (fixed)**: dynamic_seeds_added not compact-recoverable → added seed_origin field to chain frontmatter + recovery grep pattern.

---

## Knowledge Assessment

**是否有新发现？** ✅ Yes

**Written to**: `.tad/project-knowledge/architecture.md`
- `### LLM Protocol Index-Access Guards: Off-by-One in Array-Based Tunnel Detection — 2026-05-09`

---

## Files Changed

| File | Action |
|------|--------|
| `.claude/skills/research-notebook/SKILL.md` | perspective_shift strategy + TRACK update + strategies_used tracking |
| `.claude/skills/alex/SKILL.md` | Phase 4b step 3c + Phase 4 Step 2.5 + Phase 4.5 |

**Commit**: `253dd96` — 5 files changed, 197 insertions, 82 deletions

---

## Notes for Alex Gate 4

1. P2-1 (backend-architect): worst-case latency substantially exceeds handoff's "~20-30 min" estimate. The user message before Phase 4 now says "~4-8 min per research item" (from previous handoff). Consider adding a worst-case callout.
2. P2-2 (backend-architect): gap_enrichment lacks consecutive-firing guard — design asymmetry intentional (each gap may surface new content), but worth documenting.
3. P2-3 (backend-architect): evidence directory split between {notebook_topic}/ (chains) and {slug}/ (other) — compatible, not blocking.
