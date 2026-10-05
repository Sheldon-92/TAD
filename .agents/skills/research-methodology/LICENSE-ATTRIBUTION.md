# License Attribution

This capability pack incorporates ideas and patterns from the following open-source projects:

## Research Frameworks (Apache 2.0 / MIT)

### Orchestra AI-Research-SKILLs
- Source: https://github.com/Orchestra-Research/AI-Research-SKILLs
- Influence: Two-loop architecture (inner optimization + outer synthesis), research-state.yaml state tracking pattern, dead-end registry concept
- License: Apache 2.0

### AutoResearchClaw
- Source: https://github.com/aiming-lab/AutoResearchClaw
- Influence: PIVOT/REFINE loop design, 23-stage pipeline with Gate Stages, 4-layer citation verification
- License: MIT

### DeerFlow
- Influence: Sub-agent termination conditions, structured results → lead synthesis pattern
- License: Apache 2.0

## Academic Methodology

### Theoretical Saturation (Grounded Theory)
- Source: Corbin & Strauss (1990) — Grounded Theory Research
- Influence: Saturation detection algorithm — "zero new code rate = stop"

### PRISMA 2020 Guidelines
- Source: Page et al. (2021) — PRISMA 2020
- Influence: Gate placement at human-judgment-required checkpoints

### QCE Framework (Question-Claim-Evidence)
- Influence: Output format structure requiring analytical statements with contradictory evidence

## TAD Framework Internal
- research-notebook SKILL: NotebookLM CLI integration patterns (absolute venv path, `-n` flag usage)
- research-github SKILL: GitHub-First sourcing strategy

All content in this pack is original unless explicitly attributed above.
