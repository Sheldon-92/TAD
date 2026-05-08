# Research Methodology Capability Pack

> Unified 5-phase research pipeline for AI agents — from question to QCE-structured report with extracted ACs.

---

## What This Does

Transforms "研究 X" into a structured, evidence-grounded research process:

```
Plan → Source → Curate → Analyze → Output
 H1        |       H2              H3
(you approve    (you review     (you approve
 the plan)      source quality)  deliverables)
```

**Why not just use WebSearch?** WebSearch finds answers. This pack builds understanding — cross-source synthesis, saturation detection, contradiction mapping, and actionable AC extraction. Takes 30-120 minutes per session.

---

## Quick Start

### 1. Install

```bash
bash install.sh --agent=claude-code
```

### 2. Use

Simply say in Claude Code:
```
研究一下 [your topic]
# or
研究 [topic] 并告诉我应该用哪个方案
# or
Research [topic] and give me a recommendation
```

The pack activates automatically via keyword routing (no need to say "use research-methodology").

### 3. Checkpoints

The pack pauses at 3 human gates:
- **H1** (after PLAN): You approve the question tree and source strategy
- **H2** (after CURATE): You review source quality distribution
- **H3** (after OUTPUT): You approve the final QCE report and ACs

---

## Architecture

```
CAPABILITY.md           Orchestration router + Step 0 + phase state machine
references/
  planning.md           Question decomposition + problem tree
  sourcing.md           GitHub-First strategy + source priority matrix  
  quality-control.md    Tier criteria + saturation algorithm + anti-hallucination
  analysis.md           Ask loop + CRAG + PIVOT/REFINE decision tree
  output.md             QCE format + AC extraction rules
CONVENTIONS.md          Decision heuristics (when to use, how to judge)
checklists/
  research-quality.md   Per-session quality checklist
scripts/
  saturation-check.sh   Reads research-state.yaml → SATURATED/DIMINISHING/CONTINUE
  source-quality.sh     Reads research-state.yaml → PASS/FAIL + T1 ratio
```

---

## What You Get

### QCE Report
A structured analytical document (not a summary):

```markdown
## Question: What should we use for X?

### Claim 1: Approach Y is superior for [context] because...
**Evidence:** [specific citation from specific source]
**Contradictory evidence:** [sources that disagree and why]
**Confidence:** high / medium / low

### Claim 2: ...

## Extracted ACs
- AC1: [concrete, measurable criterion] [Source: Claim 1]
- AC2: ...
```

### Session Artifacts
Stored in `.research/` (gitignored):
- `research-state.yaml` — session progress
- `sessions/{id}/report.md` — QCE report
- `sessions/{id}/acs.md` — extracted ACs
- `dead-ends.yaml` — registry of failed research angles

---

## Requirements

- Claude Code with this pack installed
- NotebookLM CLI (for FULL MODE): `~/.tad-notebooklm-venv/bin/notebooklm`
  - Install: `bash .tad/cross-model/setup-notebooklm.sh`
  - Pack works without it (DEGRADED MODE: WebSearch only)
- `awk`, `bash` (macOS/Linux standard)

---

## State Recovery

If research was interrupted, the pack automatically detects the incomplete session and asks:
- **Resume** → continues from last completed phase
- **Archive and start fresh** → saves prior session, starts new
- **Cancel** → returns to standby

Sessions > 7 days old get a stale-detection warning.

---

## License

Apache 2.0 — see LICENSE. Attribution: see LICENSE-ATTRIBUTION.md.
