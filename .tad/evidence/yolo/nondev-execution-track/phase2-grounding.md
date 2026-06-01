# Phase 2 Grounding — Templates + Gate 3/4 branches + producer routing

> Conductor (Alex) measured ground truth before the implementer touches core SKILLs. Per file-as-source-of-truth.

## CONSTRAINT-TOKEN BASELINES (smoke-alarm invariant: must NOT decrease after Phase 2)
Measured 2026-05-31 on HEAD:
- `gate/SKILL.md`: `grep -cE 'MUST NOT|VIOLATION|MANDATORY|forbidden_implementations|BLOCKING'` = **23**
- `alex/SKILL.md`: `grep -cE 'MUST NOT|VIOLATION|MANDATORY|forbidden_implementations'` = **127**
- `blake/SKILL.md`: `grep -cE 'MUST NOT|VIOLATION|MANDATORY|forbidden_implementations'` = **49**

Rule: counts may INCREASE (the deliverable branch legitimately adds judge≠producer VIOLATION lines) but MUST NOT decrease (no existing constraint removed). The real invariant is the byte-identity of the ORIGINAL fenced blocks (below).

## gate/SKILL.md structure (total 660 lines)
- `## Gate 3:` header at line **94** (prose, outside fence). Fence opens at line **95** (```yaml).
- Gate 3 fenced block: **95–338** (per Phase-1 grounding + reviewer cross-check). The guard line for the Gate 3 deliverable branch goes between line 94 (header) and line 95 (fence open).
- `## Gate 4` block follows (~341 onward, through ~610 per reviewer). Implementer MUST re-confirm Gate 4 fence boundaries live before editing.
- `*-testing-review-*` references at lines 127, 135, 139, 226 (code path — leave untouched in the original block).
- `types:` enum (reviewer cited ~381) — add `rubric-eval` as a DISTINCT entry; do NOT alias to testing-review.

## Byte-safety mechanism (contract §B.1, §B.7, §E — v2.1)
- Gate 3 + Gate 4 deliverable branches are **additive SIBLING sections** (each own ```yaml fence) placed AFTER the respective existing block, selected by ONE guard line added to each gate's PROSE header (outside the fence). NOT an ELSE-wrap (that would re-indent → byte change).
- Byte-check (offset-aware, the guard line shifts the block down by 1): `diff <(git show HEAD:.claude/skills/gate/SKILL.md | sed -n '95,338p') <(sed -n '96,339p' .claude/skills/gate/SKILL.md)` MUST be empty. Robust alternative = content-anchored awk fence-body extraction (contract §B.1).

## Templates to copy-from
- `.tad/templates/handoff-a-to-b.md` → basis for `deliverable-handoff.md`
- `.tad/templates/completion-report.md` → basis for `deliverable-completion.md` (KEEP `gate3_verdict:` marker verbatim — post-write-sync.sh allowlist pass|fail|partial)

## alex/SKILL.md Touchpoint-0 (contract §F.7)
- Add additive classification rule near the handoff-drafting/template-selection step (after intent_router + adaptive_complexity). Reviewer noted the real template-selection step is ~line 2598, NOT 496 (496 is the router). Implementer MUST locate the actual template-selection / handoff_creation step1 and add the deliverable classification there. Additive only — do not change existing routing.

## Authoritative spec
Contract §F (phase1-architecture-contract.md) is the design-complete edit plan. Implementer follows §F.1–§F.8 verbatim. No new design decisions.
