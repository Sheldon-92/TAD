---
name: Execution-Review Persona Separation
description: Domain personas HARM execution (limit creativity) but HELP review (provide specialized lens). Critical design principle for Domain Pack.
type: feedback
---

Nuanced principle for Domain Pack and agent design:

**Execution phase**: Provide domain CONTEXT ("this project is PCB design") but NOT persona CONSTRAINTS ("you are a hardware expert, think only from hardware perspective"). Context activates relevant knowledge; constraints limit cross-domain creativity. Give tools + workflow + standards, not knowledge boundaries.

**Review phase**: Domain-specific reviewer personas ADD value — intentionally narrow lens ("only check safety issues") catches things a generalist misses. Constraint IS the feature here.

**Key distinction**: Context vs Constraint
- ✅ "This project involves PCB design" = context (activates knowledge, helps quality)
- ❌ "You are a PCB expert, only think about hardware" = constraint (narrows vision, may miss software solutions)
- ✅ "Check this design ONLY for safety issues" = review constraint (intentionally narrow = valuable)

**Role personas ARE valid**: Alex as "Solution Lead" and Blake as "Execution Master" define behavioral roles (who does what), not knowledge constraints (what to think about). Role ≠ Domain.

**Why:** LLMs already have comprehensive domain knowledge. Personas that limit knowledge scope during execution are counterproductive. But personas that define a specific REVIEW LENS during quality gates add genuine value through adversarial narrowing.

**How to apply:** Domain Pack = domain context + tools + workflow + standards + review personas. Never add domain persona constraints to the executing agent (Alex/Blake). Save specialized personas for Gate reviewers only.
