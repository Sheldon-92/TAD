# Changelog

## [1.0.0] - 2026-05-08

### Added
- CAPABILITY.md: Unified 5-phase research orchestration router (PLAN→SOURCE→CURATE→ANALYZE→OUTPUT)
- references/planning.md: Question decomposition + problem tree + success criteria patterns
- references/sourcing.md: GitHub-First source strategy + source type priority matrix
- references/quality-control.md: T1/T2/T3 tier criteria + saturation detection + 4-layer anti-hallucination
- references/analysis.md: Ask loop patterns + CRAG gap detection + PIVOT/REFINE decision tree
- references/output.md: QCE format spec + AC extraction rules
- CONVENTIONS.md: Research methodology conventions + decision heuristics
- checklists/research-quality.md: Per-session quality checklist
- scripts/saturation-check.sh: Compute new-finding rate from research-state.yaml
- scripts/source-quality.sh: T1 ratio validation from research-state.yaml
- install.sh: Multi-agent installer (Claude Code implemented; Codex/Cursor/Gemini stubbed)
- README.md: Quick start guide + architecture overview

### Research Basis
- NotebookLM notebook 81af517d (20 sources, 5 ask rounds, 2026-05-07)
- Key inputs: Orchestra (state-tracking), AutoResearchClaw (PIVOT/REFINE), PRISMA (gates), QCE (output)
