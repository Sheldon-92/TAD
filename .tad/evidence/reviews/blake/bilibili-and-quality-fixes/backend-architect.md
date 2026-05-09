# Architecture Review: bilibili-and-quality-fixes
**Reviewer**: backend-architect sub-agent
**Date**: 2026-05-09
**Verdict**: PASS — P0=0, P1=0, P2=2

## Summary

4-phase ordering is correct. Timeout budget (60s) is realistic. No downstream consumers of method: field. Quality probe 4a fall-through design is correct.

## Q1: 4-Phase Ordering
B站 API fails fast (~1-2s) even on non-China IPs (returns code=62002 immediately). Cost of B failing first ≈ 1-2s; benefit when it succeeds = 200ms total instead of 10s+ yt-dlp. Expected-value-positive. CORRECT.

## Q2: 60s Timeout Budget
Worst case (no cookies): A ~10s + B ~10s + C ~10s + D ~25s = 55s. 60s = 5s margin. REALISTIC.
If TAD_BILIBILI_BROWSER set: may exceed 60s, but user accepts higher latency as opt-in.

## Q3: Downstream Consumers
No script parses `method:` field from bilibili output. Frontmatter is human-inspection-only. NO BREAKAGE.

## Q4: Quality Probe 4a
`.content_length // .char_count // ""` → empty string when both absent → fall-through to 4b (LLM probe). Safe fail-open design. NO REGRESSION.

## P2 Advisory

**P2-1**: `method:` field now has 5 variants but no `# CONTRACT:` block declaring them as "audit-trail-only, no stability guarantee". Recommend adding per `.router.log` lesson (architecture.md 2026-04-27).

**P2-2**: SKILL.md Step 4a uses natural-language "is a non-empty integer AND < 500" — recommend adding explicit bash snippet to reduce translation risk when different agents implement this path.
