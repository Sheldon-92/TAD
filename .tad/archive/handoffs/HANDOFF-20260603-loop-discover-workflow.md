---
task_type: code
e2e_required: no
research_required: no
git_tracked_dirs: [".claude/workflows"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-06-03
**Project:** TAD Framework
**Task ID:** TASK-20260603-005
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260603-dynamic-workflow-integration.md (Phase 5 — supplemental)

---

## Gate 2: Design Completeness

| Check Item | Status | Note |
|-----------|--------|------|
| Architecture Complete | OK | Loop-until-done pattern from Thariq article, parameterized for any discovery task |
| Components Specified | OK | 1 workflow file + SKILL.md integration for *optimize and *dream |
| Functions Verified | OK | Workflow loop API proven (budget.remaining() + while loop in docs) |
| Data Flow Mapped | OK | finder agent → dedup against seen set → stop when K dry rounds → return all findings |

**Gate 2 Result**: PASS

---

## 1. Task Overview

Create a reusable "loop until done" workflow for discovery tasks where the amount of work is unknown upfront. Instead of running a fixed N passes, the workflow spawns finder agents in rounds until K consecutive rounds produce zero new findings, then stops. Findings are deduplicated across rounds.

**Why now:** TAD's *optimize and *dream currently use fixed iteration counts. Real discovery is long-tail: the first 3 rounds find 80%, round 4-5 find the remaining 20%, round 6+ is usually empty. Fixed counts either miss the tail (too few) or waste tokens (too many). Loop-until-done with "K dry rounds = stop" is the correct stopping condition.

---

## 2. Requirements

### Functional
- FR1: Create `.claude/workflows/loop-discover.workflow.js` — parameterized loop-until-done workflow
- FR2: Accepts any finder prompt + dedup key function + stop condition (K dry rounds, default 2)
- FR3: Each round spawns a finder agent with clean context (no cross-round contamination)
- FR4: Dedup: findings from round N are checked against all findings from rounds 1..N-1 using a key function
- FR5: Stops when K consecutive rounds return 0 new (deduplicated) findings
- FR6: Returns all unique findings + round-by-round stats
- FR7: Respects budget.remaining() — stops if budget exhausted (guard against infinite loops)
- FR8: Integrate into alex/SKILL.md: *optimize and *dream can invoke this workflow

### Non-Functional
- NFR1: Object.keys workaround for args (same as P1-P3)
- NFR2: Each finder agent gets the SAME prompt (consistency across rounds) plus a "previously found" context to avoid re-discovering known items
- NFR3: Max rounds hard cap: 10 (circuit breaker regardless of stop condition)
- NFR4: Compatible with /loop — workflow can be re-invoked periodically; findings persist to disk between invocations

---

## 3. Technical Design

### Workflow args interface

```
args: {
  finder_prompt: string,    // What to search for (required)
  schema: object,           // JSON schema for each finding (required)
  dedup_key: string | string[],  // Field name(s) for dedup. String = single field (e.g., "title"). Array = composite key (e.g., ["file_path", "line_number"] → joined with "::")
  dry_rounds_to_stop: number, // K consecutive empty rounds to stop (default: 2)
  max_rounds: number,       // Hard cap (default: 10)
  context_files: string[],  // Files the finder should read (optional)
  output_path: string,      // Where to persist findings (optional — for /loop re-invocation)
  previous_findings_path: string  // Load prior findings for cross-session dedup (optional)
}
```

### Core loop logic

```javascript
phase('Discover')

// Load previous findings via agent (workflow runtime has no direct file I/O)
let allFindings = []
if (args.previous_findings_path) {
  const prior = await agent(
    'Read the file at ' + args.previous_findings_path + '. Parse it as JSON array. Return the parsed array. If file does not exist, return empty array [].',
    { label: 'load-prior', schema: { type: 'array', items: args.schema }, model: 'haiku' }
  )
  if (prior) { for (let i = 0; i < prior.length; i++) { allFindings.push(prior[i]) } }
}

// dedup_key can be string (single field) or array of strings (composite key)
function getKey(finding, dk) {
  if (typeof dk === 'string') return String(finding[dk] || '')
  // Composite key: join multiple fields
  let parts = []
  for (let i = 0; i < dk.length; i++) { parts.push(String(finding[dk[i]] || '')) }
  return parts.join('::')
}

let seen = new Set(allFindings.map(function(f) { return getKey(f, dedup_key) }))
let dryRounds = 0
let round = 0
let roundStats = []
const MAX_PREVIOUSLY_SHOWN = 50  // Cap prompt injection to prevent context overflow

while (dryRounds < dry_rounds_to_stop && round < max_rounds) {
  // Budget guard (defensive — budget may be undefined when no target set)
  if (typeof budget !== 'undefined' && budget && budget.total && budget.remaining() < 30000) {
    log('Budget low (' + budget.remaining() + ' remaining). Stopping.')
    break
  }

  round++
  log('Round ' + round + ': spawning finder agent')

  // Show at most MAX_PREVIOUSLY_SHOWN prior findings in prompt (dedup Set still has all)
  const shownPrior = allFindings.slice(-MAX_PREVIOUSLY_SHOWN)
  const priorText = shownPrior.length > 0
    ? '\n\nALREADY FOUND (do not re-discover — ' + allFindings.length + ' total, showing last ' + shownPrior.length + '):\n' +
      shownPrior.map(function(f) { return '- ' + getKey(f, dedup_key) }).join('\n')
    : ''

  const findings = await agent(
    args.finder_prompt + priorText,
    { label: 'round-' + round, phase: 'Discover', schema: { type: 'array', items: args.schema } }
  )

  // Dedup (filter nulls + missing keys + already seen)
  const validFindings = (findings && findings.length) ? findings : []
  const newFindings = validFindings.filter(function(f) {
    var k = getKey(f, dedup_key)
    return k && k !== '' && !seen.has(k)
  })

  if (newFindings.length === 0) {
    dryRounds++
    log('Round ' + round + ': 0 new findings (dry round ' + dryRounds + '/' + dry_rounds_to_stop + ')')
  } else {
    dryRounds = 0
    newFindings.forEach(function(f) { seen.add(getKey(f, dedup_key)); allFindings.push(f) })
    log('Round ' + round + ': ' + newFindings.length + ' new findings (total: ' + allFindings.length + ')')
  }

  roundStats.push({ round: round, new_count: newFindings.length, cumulative: allFindings.length })
}

phase('Complete')
var stoppedReason = dryRounds >= dry_rounds_to_stop ? 'dry_rounds' : round >= max_rounds ? 'max_rounds' : 'budget'
log('Loop complete: ' + allFindings.length + ' findings in ' + round + ' rounds. Stopped: ' + stoppedReason)

return {
  total_findings: allFindings.length,
  rounds_executed: round,
  stopped_reason: stoppedReason,
  findings: allFindings,
  round_stats: roundStats
}
```

**NOTE on file I/O**: Workflow runtime cannot read/write files directly. Loading previous findings uses a haiku agent. Persisting findings to disk is the Conductor's responsibility after receiving the return value.

### /loop compatibility

For cross-session persistence:
- First run: `output_path` not set → findings returned in result only
- With /loop: set `output_path: ".tad/evidence/loop-discover/{slug}.json"` + `previous_findings_path` to same file
- Conductor writes result to output_path after workflow returns
- Next /loop invocation reads previous_findings_path → dedup includes all prior sessions

### SKILL.md integration

*optimize and *dream can invoke this workflow instead of their current fixed-iteration logic:

```yaml
# In *optimize step1_read_traces (currently reads traces then runs fixed analysis):
# NEW: if loop-discover workflow available:
optimize_workflow_option: |
  Workflow({name: 'loop-discover', args: {
    finder_prompt: "Find improvement proposals from TAD execution traces in .tad/evidence/traces/",
    schema: PROPOSAL_SCHEMA,
    dedup_key: "proposal_id",
    dry_rounds_to_stop: 2,
    context_files: [".tad/evidence/traces/"]
  }})
```

---

## 4. Files to Create / Modify

| File | Action | Scope |
|------|--------|-------|
| `.claude/workflows/loop-discover.workflow.js` | CREATE | ~150-200 lines: parameterized loop-until-done |
| `.claude/skills/alex/SKILL.md` | MODIFY | *optimize + *dream: add workflow invocation option |

**Grounded Against** (Alex step1c, read 2026-06-03):
- .claude/workflows/epic-audit.workflow.js (reference for args workaround + schema usage)
- .claude/skills/alex/SKILL.md optimize_protocol (current fixed-iteration *optimize)
- .claude/skills/alex/SKILL.md dream_protocol (current fixed-iteration *dream)

---

## 5. Acceptance Criteria

| AC | Requirement | Verification Method | Expected Evidence |
|----|------------|--------------------|--------------------|
| AC1 | Workflow exists and parses | `node -c .claude/workflows/loop-discover.workflow.js` | Exit 0 |
| AC2 | Loop stops on dry rounds | Run with a finder that returns empty → stops after K rounds | stopped_reason == 'dry_rounds' |
| AC3 | Dedup works | Run with finder returning same item twice → total_findings == 1 | Deduplicated |
| AC4 | Max rounds cap | Run with max_rounds: 3 → stops at 3 even if still finding | rounds_executed <= 3 |
| AC5 | Budget guard | grep for `budget.remaining` in workflow | >= 1 match |
| AC6 | Args workaround | `grep 'Object.keys' .claude/workflows/loop-discover.workflow.js` | >= 1 match |
| AC7 | SKILL.md integration | `grep 'loop-discover' .claude/skills/alex/SKILL.md` | >= 1 match |
| AC8 | SAFETY unchanged | `grep -c 'NOT_via_alex_auto\|forbidden_implementations' .claude/skills/alex/SKILL.md` | == 20 |
| AC9 | Round stats in output | Return schema includes round_stats array | Present |

---

## 6. Important Notes

### 6.1 Key design choices
- **"Previously found" in prompt, not exclusion filter**: The finder receives the list of already-found items in its prompt context, so it can look for DIFFERENT things. This is better than excluding results post-hoc (which would re-discover the same items every round, wasting tokens).
- **Dedup by key, not by content**: Using a single field (dedup_key) for dedup is simpler and more reliable than fuzzy content matching. The caller chooses which field is the identity key.
- **Budget guard before loop, not after**: Check budget BEFORE spawning the next finder, not after receiving results. This prevents starting a round that can't complete.

### 6.2 What NOT to do
- DO NOT use hardcoded finder prompts — the workflow is a GENERIC loop, the finder prompt comes from args
- DO NOT persist findings to disk inside the workflow — return them; the Conductor decides where to write
- DO NOT add `forbidden_implementations` or `NOT_via_alex_auto` strings in the workflow file
- DO NOT remove the max_rounds hard cap (prevents infinite loops if the finder always returns something)

---

## 7. Decision Summary

| # | Decision | Options | Chosen | Rationale |
|---|----------|---------|--------|-----------|
| 1 | Stop condition | Fixed N / K dry rounds / Budget-only | K dry rounds + budget guard + max cap | Thariq article recommends loop-until-done; triple guard prevents runaway |
| 2 | Dedup mechanism | Key-based / Content hash / LLM judgment | Key-based (dedup_key field) | Simplest, deterministic, caller chooses the key |
| 3 | /loop compat | Built-in persistence / External / None | External via args (output_path + previous_findings_path) | Workflow stays stateless; persistence is Conductor's job |

---

## 8. Required Evidence Manifest

```yaml
expert_reviews:
  - path: .tad/evidence/reviews/blake/loop-discover/code-review.md
    required: true
  - path: .tad/evidence/reviews/blake/loop-discover/spec-compliance.md
    required: true
gate_verdicts:
  - path: .tad/evidence/reviews/blake/loop-discover/gate3-verdict.md
    required: true
completion:
  - path: .tad/active/handoffs/COMPLETION-20260603-loop-discover-workflow.md
    required: true
```
