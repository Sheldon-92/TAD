---
task_type: code
e2e_required: no
research_required: no
git_tracked_dirs: [".claude/workflows", ".claude/skills/alex"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-06-03
**Project:** TAD Framework
**Task ID:** TASK-20260603-002
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260603-dynamic-workflow-integration.md (Phase 2/5)

---

## Gate 2: Design Completeness

| Check Item | Status | Note |
|-----------|--------|------|
| Architecture Complete | OK | Tournament pattern validated by experiment (7 agents, 322K tokens, 30% richer output) |
| Components Specified | OK | 1 workflow file + 2 SKILL.md edits |
| Functions Verified | OK | Workflow API (agent/parallel/pipeline/schema) verified in P0+P1 |
| Data Flow Mapped | OK | competitors → pairwise judges → synthesizer → merged design |

**Gate 2 Result**: PASS

---

## 1. Task Overview

Create a reusable Tournament workflow for TAD design decisions. When facing important design choices with multiple valid approaches, this workflow spawns N competing agents (each designing from different prior art), evaluates pairwise with a rubric, and synthesizes a merged design taking the best ideas from all competitors.

**Why now:** Tournament experiment (2026-06-03) proved the pattern produces ~30% richer designs than single-agent. The value comes from extracting best sub-ideas from losers and merging into the winner — something a single agent never does.

---

## 2. Requirements

### Functional
- FR1: Create `.claude/workflows/tournament-design.workflow.js` — parameterized tournament workflow
- FR2: Default mode: 2 competitors + 1 pairwise judge + 1 synthesizer = 4 agents (~200-220K tokens)
- FR3: Deep mode: 3 competitors + 3 pairwise judges + 1 synthesizer = 7 agents (~320K tokens, validated by experiment)
- FR4: Integrate into alex/SKILL.md `design_protocol` as optional step (human chooses whether to use)
- FR5: Also available as standalone `*tournament` command (not tied to *design flow)
- FR6: Workflow accepts custom rubric via args (or uses a sensible default rubric)

### Non-Functional
- NFR1: args handling MUST use the Object.keys workaround pattern (see gate-review.workflow.js lines 97-111) — workflow runtime does not reliably support dot-access on args objects. This works for ALL value types (strings, arrays, nested objects). `args[keys[i]]` returns the original value, no additional JSON parsing needed.
- NFR2: All variables returned by agent() that are used later MUST be named `result` not `report`/`synthesis` to avoid the "declared but never read" TS diagnostic
- NFR3: Human always decides: Alex SUGGESTS tournament, human DECIDES. Tournament MUST NOT auto-activate.
- NFR4: Failure handling: Standard mode 1 competitor fails → abort, fall back to single-agent design. Deep mode 1 fails → degrade to standard (2 competitors, 1 judge). Deep mode 2+ fail → abort.

---

## 3. Technical Design

### Workflow args interface

```
args: {
  task: string,           // What to design (required)
  prior_art: string[],    // Sources for each competitor (REQUIRED — one per competitor)
  rubric: {               // Scoring dimensions (optional, defaults provided)
    dimensions: string[], // e.g. ["cross_platform", "expressiveness", "migration_cost", "principle_alignment"]
    weights: number[]     // e.g. [1, 1, 1, 1] — equal weight by default
  },
  mode: "standard" | "deep",  // 2 or 3 competitors (default: "standard")
  context_files: string[]     // Additional files competitors should read (optional)
}
```

### Workflow phases

**Phase 1: Setup**
- Parse args (Object.keys workaround — works for all value types including arrays and nested objects, no additional parsing needed)
- Validate: prior_art is required and must have >= 2 entries (one per competitor). If missing or < 2: abort with error message.
- If mode not specified: default to "standard" (2 competitors)
- Optional: `models` array (e.g. `["opus", "sonnet"]`) to assign different model tiers to competitors for diversity. Default: all inherit parent model.

**Phase 2: Compete**
- Spawn N competitors in parallel
- Each competitor gets: task description + ONE prior art source + context files + rubric
- Each returns a structured design via DESIGN_SCHEMA

**Phase 3: Judge**
- Standard mode (2 competitors): 1 direct judge compares both. Returns 1 JUDGE_SCHEMA result (the 2 competitors form 1 pair). Same schema as deep mode.
- Deep mode (3 competitors): 3 pairwise judges (A vs B, B vs C, A vs C). Each returns 1 JUDGE_SCHEMA result.
- Judge uses rubric dimensions with 0-10 scores
- Judge also notes "what the loser did better" (key to merger quality)
- Deep mode tiebreaker: derive win-record (count wins per competitor). If tie: sum of rubric scores across all pairwise matches. If still tied: competitor with highest single-dimension score is base for synthesis.
- Synthesizer receives ALL JUDGE_SCHEMA results regardless of mode (1 in standard, 3 in deep). Standard mode has 1 loser; deep mode has 2 losers. Synthesizer handles both cardinalities.

**Phase 4: Synthesize**
- Takes tournament winner as base
- Grafts best ideas from losers (identified by judges)
- Produces merged design that no single competitor would have created
- Returns MERGED_DESIGN_SCHEMA

### Schema definitions

Blake should define these schemas in the workflow file:

**DESIGN_SCHEMA** — what each competitor produces:
- approach_name, prior_art_reference
- design_content (the actual design as string)
- tradeoffs (array of strings)
- key_innovation (what makes this approach unique)

**JUDGE_SCHEMA** — what each judge produces:
- winner, loser
- scores (per rubric dimension, 0-10 for each design)
- decisive_factor
- what_loser_did_better (critical for merger)

**MERGED_DESIGN_SCHEMA** — final output:
- tournament_winner
- win_record
- best_ideas_from_losers (array)
- merged_design (the actual merged content)
- ideas_grafted_from_losers_count (number — objectively verifiable: how many sub-ideas from losers survived into the merge)

### Alex SKILL.md integration points

**1. design_protocol (add tournament option after step1_5b):**
```yaml
step1_5c:
  name: "Tournament Option"
  trigger: "After pack loading, for Full or Standard TAD depth"
  action: |
    If user chose Full TAD or Standard TAD:
    AskUserQuestion:
      "This design has multiple valid approaches. Want to explore them via tournament?"
      Options:
        - "Tournament — 2 competing designs + judge + merge (Recommended for ambiguous decisions)"
        - "Deep tournament — 3 competitors + pairwise (for high-stakes architecture)"
        - "Skip — single-agent design (faster, sufficient for clear requirements)"
    If user picks tournament/deep:
      Invoke Workflow({name: 'tournament-design', args: {task, mode, ...}})
      Use merged_design as input for the rest of *design
    If skip: continue normal *design flow
```

**2. Standalone *tournament command (add to Alex commands list):**
```yaml
tournament: "Run tournament design exploration — N agents compete, judge selects, synthesizer merges best ideas"
```
Route to: invoke Workflow with args from user's task description.

---

## 4. Files to Create / Modify

| File | Action | Scope |
|------|--------|-------|
| `.claude/workflows/tournament-design.workflow.js` | CREATE | Full workflow script (~200 lines) |
| `.claude/skills/alex/SKILL.md` | MODIFY | Add step1_5c to design_protocol + *tournament command |

**Grounded Against** (Alex step1c):
- .claude/workflows/gate-review.workflow.js (read 2026-06-03 — args workaround pattern at lines 97-111)
- .claude/skills/alex/SKILL.md line 2355 (design_protocol step1_5b — insertion point for step1_5c)
- .claude/skills/alex/SKILL.md line 115 (commands list — insertion point for *tournament)
- .tad/evidence/research/2026-06-03-tournament-declarative-constraints-result.md (tournament experiment output — reference implementation)

---

## 5. Acceptance Criteria

| AC | Requirement | Verification Method | Expected Evidence |
|----|------------|--------------------|--------------------|
| AC1 | Workflow exists and parses | `node -c .claude/workflows/tournament-design.workflow.js` | Exit 0, no syntax errors |
| AC2 | Standard mode: 4 agents | Run workflow with `mode: "standard"`, count agents in output | agent_count == 4 |
| AC3 | Deep mode: 7 agents | Run workflow with `mode: "deep"`, count agents in output | agent_count == 7 |
| AC4 | Args workaround used | `grep 'Object.keys' .claude/workflows/tournament-design.workflow.js` | >= 1 match |
| AC5 | Merged design has losers' ideas | Output includes `best_ideas_from_losers` array with >= 1 item | Array non-empty |
| AC6 | Alex SKILL.md has step1_5c | `grep 'step1_5c' .claude/skills/alex/SKILL.md` | >= 1 match |
| AC7 | *tournament in commands list | `grep 'tournament:' .claude/skills/alex/SKILL.md` | >= 1 match |
| AC8 | Human choice preserved | step1_5c uses AskUserQuestion, not auto-activate | grep confirms AskUserQuestion |
| AC9 | Default rubric works | Run workflow WITHOUT rubric arg, verify it generates default dimensions | Output has scores |

---

## 6. Important Notes

### 6.1 Reference implementation
Today's tournament experiment script is the primary reference:
`.tad/evidence/research/2026-06-03-tournament-declarative-constraints-result.md`

The workflow in that experiment was inline (not saved). Blake should extract the pattern but make it parameterized.

### 6.2 Known workflow runtime quirks
- `args` object does NOT support dot-access reliably. Use `Object.keys(args)` loop pattern from gate-review.workflow.js
- Variables assigned from `await agent()` that are returned MUST be named to avoid TS "unused" warnings
- `parallel()` returns nulls for failed agents — always `.filter(Boolean)`
- `pipeline()` is preferred over chained `parallel()` when no barrier is needed

### 6.3 What NOT to do
- DO NOT auto-activate tournament in *design (human must choose via AskUserQuestion)
- DO NOT hardcode prior art sources (parameterize via args, auto-detect if absent)
- DO NOT use `judgment_ref` or `forbidden_implementations` literal strings in the workflow file (learned from declarative-constraints P0 review)

---

## 7. Project Knowledge

### Blake must note:
- **Tournament value is in the MERGER, not the winner** — today's experiment proved the merged design was 30% richer because it grafted best ideas from losers. The "what_loser_did_better" field in JUDGE_SCHEMA is the critical enabler.
- **Single-model convergence risk** — all competitors use Claude, so they may produce similar designs. Mitigation: assign different prior art sources to each competitor to force divergent starting points.

---

## 8. Expert Review Status

| Expert | Findings | Status |
|--------|----------|--------|
| (pending — Blake side Gate 3 Layer 2) | — | — |

---

## 9. Decision Summary

| # | Decision | Options | Chosen | Rationale |
|---|----------|---------|--------|-----------|
| 1 | Default competitor count | 2 / 3 / configurable | Default 2, upgradable to 3 | Cost: 140K vs 320K tokens. User can choose deep mode when stakes are high |
| 2 | Integration point | *design only / standalone only / both | Both | *design for natural flow, standalone for ad-hoc use |
| 3 | Auto-activate? | Yes / No | No (AskUserQuestion) | TAD principle: Alex SUGGESTS, human DECIDES |

Tournament evidence: `.tad/evidence/research/2026-06-03-tournament-declarative-constraints-result.md`

---

## 10. Required Evidence Manifest

```yaml
expert_reviews:
  - path: .tad/evidence/reviews/blake/tournament-workflow-p2/code-review.md
    required: true
  - path: .tad/evidence/reviews/blake/tournament-workflow-p2/spec-compliance.md
    required: true
gate_verdicts:
  - path: .tad/evidence/reviews/blake/tournament-workflow-p2/gate3-verdict.md
    required: true
completion:
  - path: .tad/active/handoffs/COMPLETION-20260603-tournament-workflow-p2.md
    required: true
```
