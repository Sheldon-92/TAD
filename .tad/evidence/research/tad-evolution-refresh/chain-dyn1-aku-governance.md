---
seed_origin: dynamic
dynamic_index: 0
spawned_from: chain-seed1-memory (surprising sub-topic: AKUs/structured skills)
seed_question: "AKU governance/validation mechanisms, deterministic tool binding, failure modes without validators"
notebook: tad-evolution-research (37cfefa5-52b3-4a8a-a8e3-a83f32150759)
date: 2026-05-31
---

## Dynamic seed: AKU governance-as-code (HIGH TAD relevance)
- AKUs embed governance in-schema via deterministic **Validators** (shell/Python/OPA, binary pass/fail) [4,5]:
  - **Pre-execution** (permission, change-window, CI passed) [6,7]
  - **Post-execution** (service healthy, no policy violation, rollback established) [6,7]
  - **Invariant** (continuous: blast-radius / resource-budget limits) [5,7]
- **Governance constraints** (RBAC, blast-radius, human-approval gates) + **continuation paths** (success/fallback/escalation routing) [1,8,9,10].
- **Deterministic tool binding**: AKUs specify exact MCP tool/API signatures, params, auth, response format — reduces hallucinated calls [11,12].
- **Measured failure mode**: empirical study of 2,303 agent context files across 1,925 repos — governance constraints specified in **only 14.5%** of cases [13,14]; unstructured context = lower quality + higher cost.

## so_what (TERMINAL)
Direct TAD action: TAD capability packs ARE proto-AKUs but lack the pre/post/invariant validator taxonomy + deterministic tool-binding schema. The 14.5% finding is an anti-slop-grade number. Candidate Phase-5/future research → pack governance schema.
