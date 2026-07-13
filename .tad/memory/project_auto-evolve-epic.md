---
name: Auto-Evolve Epic Complete
description: TAD auto-evolve 4-phase Epic (trace v2, Reflexion, Dream upgrade, Optimize/Evolve v2) completed 2026-05-20. Key architecture decisions and research basis.
type: project
originSessionId: 72e64785-97ff-49e0-86e7-7ff3403078cf
---
Auto-Evolve Epic (EPIC-20260518) completed 2026-05-20 with 4 phases, 5 commits.

**Why:** TAD had "memory but no reflection" — project-knowledge existed but no mechanism to automatically extract improvements from execution history.

**How to apply:** The auto-evolve pipeline is now: trace events (decision-level) → dream-scanner (4-pass grep/jq, daily cron) → candidate playbooks → human approval → project-knowledge. *optimize consumes v2 traces for 9 health metrics. *evolve aggregates across projects with scope classification.

Key architecture decisions:
- **Env-var convention** for shell function extension (TRACE_* vars, not positional params beyond 3)
- **Double-parse** for v2 context fields (string-encoded JSON inside JSONL)
- **3-tier scope heuristic** (file path → slug → fallback) shared by scanner + *optimize
- **MANIFEST.yaml is future contract** — *sync does NOT consume it yet (follow-up task)
- **Reflexion per-iteration** not per-check (prevents 15× overhead for lint warnings)
- **DSPy NOT suitable** for protocol rules (MUST/VIOLATION are validators, not optimizable prompts)

Research basis: TAD Evolution notebook (45 sources), Anthropic Dreaming 4-phase model, Reflexion (Verbal RL), Three-Store Layout (org/project/working).
