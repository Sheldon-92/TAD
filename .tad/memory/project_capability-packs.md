---
name: Agent Capability Packs — Product Direction
description: 24 capability packs active (was 13 → 16 → 24). Latest: 8 agent-adjacent packs via NotebookLM-research pack factory 2026-06-01. Anti-slop formula, real-eval discriminative gate.
type: project
originSessionId: 46b8eb07-2d08-4480-9ac0-1034935c96f5
---
## Update (2026-06-01): 24 packs — +8 agent-adjacent via pack factory

Added rag-retrieval, agent-memory, llm-observability, ai-guardrails, data-engineering, agent-orchestration, synthetic-data, knowledge-graph (commit d18f303). Factory pattern PROVEN: NotebookLM deep research (Conductor-seq, ~401 sources) → parallel build Workflow (32 agents) → adversarial 2-reviewer+fix → REAL spot-eval. The 3 mandatory improvements below were all EXERCISED: behavioral eval caught 2 fixture-theater + review caught 1 fabricated number + 1 wrong-OWASP-code; collision detection ran; 7/8 real-verified (data-engineering honestly pending — CONTROL also passed, markers too common). NotebookLM gotcha: `--import-all` of ~45 deep-research sources times out → pivot to `research status --json` `.report` field (50KB cited synthesis) instead of importing. See [[project_tad-next-direction]].

## Status (2026-05-15): Epic COMPLETE, 13 packs active

All phases done: 6 early builds + 5 YOLO builds + validation + YAML freeze + cross-agent + template. Epic archived.

**Why:** Domain Pack YAML = informational text agents don't activate. Capability Pack = action-ready judgment rules (206% quality improvement per research).

## 13 Active Packs

| Pack | Type | Rules | Notebook |
|------|------|-------|----------|
| web-ui-design | reference-based | ~30 | fd4f9117 (73 sources) |
| product-thinking | deep-skill | 3 skills | a8f77481 (52) |
| web-backend | reference-based | 43 | 20c498da (41) |
| ai-agent-architecture | reference-based | 10 decisions | 8da09b3b (31) |
| web-frontend | reference-based | 41 | 430044a7 (299) |
| video-creation | reference-based | 25 | a62f253b (27) |
| ai-prompt-engineering | reference-based | — | 26012e7b (24) |
| research-methodology | orchestration-router | — | — |
| ai-evaluation | reference-based | 43 | ec2a0093 (~369) |
| web-testing | reference-based | 48 | c3288195 |
| code-security | reference-based | 36 | 32ffd85a |
| web-deployment | reference-based | 51 | 2b6c8428 |
| ai-tool-integration | reference-based | — | e29b32c1 |

11 Domain Pack YAMLs frozen (deprecation header + hook skip). 9 unconverted remain (hw-*, mobile-*, supply-chain).

## Cross-Model Audit (2026-05-15)

Codex (22.2/25 pack quality, 23/35 workflow) + Gemini (23/25 pack quality, 24/35 workflow).

**Anti-slop formula**: specific threshold from research > generic principle. Best packs scored 5/5 on anti-slop because they contain numbers LLMs don't know from training (n≥550, exit 183, 10-32x token cost).

**Three mandatory improvements**:
1. Behavioral eval: before/after task comparison per pack (not just install check)
2. Collision detection: scan for contradicting rules when ≥2 packs load
3. Rule Soup prevention: step4_5 max_packs=2 must be enforced at scale

## How to Apply

Build new packs: `/capability-upgrade` (5-stage). YOLO for batch builds: Conductor owns research (NotebookLM), Blake owns file creation. Pipeline research N+1 during build N.
