# Epic: {title}

**Epic ID**: EPIC-{YYYYMMDD}-{slug}
**Created**: {date}
**Owner**: Alex
**Budget**: estimate {N} subagent dispatches in all: {per phase}
**Depth**: {level} — Risk: {reversible | one-way}; blast radius: {what is affected}

---

## Objective
{1-3 sentences: what this epic delivers when all phases complete}

## Requirement
{One line per block, in the human's words (requirement-clarification method). Gate 1: he confirmed this playback.}
- **{block}**: {his words}
- **Not wanted**: {what he does not want}
- **Done check**: {how each deliverable is judged done / not done}
playback confirmed: "{his words}"

### Q→A log
- {block}{n}: {question} → {his answer, in his words}

### Assumptions (not asked; Gate 4 lists them)
- {what was not asked, and what is assumed}

## Result contract

What the human gets: {the result, in his words}
Not wanted: {what is out}
Premise: {what must be true for this to be worth doing}

### Decisions for the human (settled before "continue")
- {decision} → {his answer, or "none"}

## Success Criteria
- [ ] {measurable outcome 1}
- [ ] {measurable outcome 2}

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 1 | {phase_name} | ⬚ Planned | — | {what it delivers} |
| 2 | {phase_name} | ⬚ Planned | — | {what it delivers} |
| 3 | {phase_name} | ⬚ Planned | — | {what it delivers} |

### Phase Dependencies
{optional: which phases depend on which, or "All phases are sequential"}

### Derived Status
Status and progress are computed from the Phase Map:
- **Status**: If all ⬚ → Planning | If any 🔄 or ✅ → In Progress | If all ✅ Done → Complete
- **Progress**: Count of ✅ Done / Total phases
- Status `✅ Closed — PARTIAL` exists for a phase whose gate verdict was PARTIAL and which the human accepted as is. A phase closed PARTIAL counts as closed, not as done: progress is `<done> done, <partial> closed PARTIAL / <total>`, and the Epic is Complete only when every phase is ✅ Done.
- If every phase is ✅ Done or ✅ Closed — PARTIAL and at least one is closed PARTIAL, the Epic's Status is `Closed — PARTIAL`, not Complete.

---

## Phase Details

### Phase 1: {phase_name}

**Status:** ⬚ Planned
**Execution:** pending

#### Scope
{2-3 sentences: what this Phase does. Explicitly state what is NOT in scope.}

#### Input
{What is available when this Phase starts: prior Phase outputs, existing code/systems, external resources}

#### Output
{What this Phase delivers when complete: new files, new capabilities, user-visible changes}

#### Acceptance Criteria
- [ ] EAC1 {specific, verifiable condition 1}
- [ ] EAC2 {specific, verifiable condition 2}
- [ ] EAC3 {specific, verifiable condition 3}

#### Files Likely Affected
- {path/to/file} (CREATE / MODIFY)

#### Dependencies
{Which Phase this depends on, or "None (can execute independently)"}

#### Notes
{Risks, open decisions, things to watch for}

### Phase 2: {phase_name}

**Status:** ⬚ Planned
**Execution:** pending

#### Scope
{2-3 sentences: what this Phase does. Explicitly state what is NOT in scope.}

#### Input
{What is available when this Phase starts: Phase 1 outputs, existing code/systems}

#### Output
{What this Phase delivers when complete: new files, new capabilities, user-visible changes}

#### Acceptance Criteria
- [ ] EAC1 {specific, verifiable condition 1}
- [ ] EAC2 {specific, verifiable condition 2}
- [ ] EAC3 {specific, verifiable condition 3}

#### Files Likely Affected
- {path/to/file} (CREATE / MODIFY)

#### Dependencies
Phase 1

#### Notes
{Risks, open decisions, things to watch for}

---

## Context for Next Phase
{Alex updates this section after each *accept, providing context
so the next phase can start without re-explaining everything}

### Completed Work Summary
- Phase 1: {1-line summary of what was done}

### Decisions Made So Far
- {key decision 1 and rationale}

### Known Issues / Carry-forward
- {issue or learning from previous phases that affects upcoming work}

### Next Phase Scope
{brief description of what the next phase should cover}

---

## Notes
{any observations, pivots, or adjustments during the epic}
