# Idea: Linear Kanban for Human Time/Energy Management

**ID:** IDEA-20260325-linear-kanban-for-human
**Date:** 2026-03-25
**Status:** promoted
**Scope:** medium

---

## Summary & Problem

Add Linear as a cross-project kanban board for the human (not for Alex/Blake). Purpose: help the human allocate time and energy across multiple projects (TAD, menu-snap, research, etc.). The granularity is "feature/work block" level — NOT handoff-level (handoffs are already in TAD's execution layer).

## Key Decisions Made During Discussion

- **Tool**: Linear (developer-friendly, API + CLI, free tier sufficient)
- **Granularity**: Feature/work block level (e.g., "menu-snap Anthony redesign", not individual handoffs)
- **Workflow**: Human picks issue from Linear → enters TAD for execution → marks Done in Linear when complete
- **Linear does NOT replace**: NEXT.md (per-project tasks), ROADMAP.md (strategy), Handoffs (execution details)
- **Linear IS for**: Cross-project priority, time block planning, progress tracking — human decision-making layer

## Open Questions

- Linear workspace structure: one workspace with multiple projects? Or simpler flat list?
- Sync with TAD: manual (human updates Linear) or semi-auto (Alex outputs Linear-friendly summaries)?
- What about non-TAD tasks (research, learning, personal)? Same Linear workspace?
- Do we need Cycles (weekly planning) or is a simple backlog + kanban enough?

## Notes

- Pain points: cross-project priority unclear, too many tasks across projects, want time block planning, want progress visibility
- Linear chosen over Notion (too heavy), GitHub Projects (too basic)
- TAD integration should be lightweight — Linear is the human's tool, not the framework's tool

---

**Status Values**: captured → evaluated → promoted → archived
**Promoted To**: Handoff (via *analyze — 2026-03-25)
