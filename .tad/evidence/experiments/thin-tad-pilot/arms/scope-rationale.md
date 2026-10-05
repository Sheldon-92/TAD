# Scope rationale — baseline applicable closure (independent review pending)

## Comparison boundary (fairness layer 1)
Start AFTER the task goal is fixed: only the execute → review → deliver
stages are compared. User-requirement exploration and Epic design costs are
excluded from per-run accounting. Results here must NOT be extrapolated to
full-lifecycle savings. Roles, independent-review opportunity, tool
permissions, user inputs, and resource caps are identical in both arms.

## Applicable set (13 files, frozen in baseline.json)
- `.agents/skills/blake/SKILL.md` + its 2 `references/` files: the execution
  contract under test (Ralph Loop, Layer 1/2, friction protocol).
- `.agents/skills/gate/SKILL.md`: Gate 3/4 acceptance behavior.
- `.tad/config-{agents,execution,quality,platform}.yaml`: agent binding,
  execution, quality-gate, and platform behavior for the compared stages.
- `.tad/ralph-config/{loop-config,expert-criteria}.yaml`: loop mechanics and
  expert pass criteria.
- `.tad/templates/completion-report.md`, `handoff-b-to-a.md`: delivery
  record shapes.
- `.codex/hooks.json`: hook manifest (behavior itself is runtime; listed as
  unresolved below, not frozen as proven behavior).

## Referenced but out of compare (resolved exclusions, with reason)
- `alex/` skill tree + design/socratic/research protocols: design-stage
  material, excluded by the layer-1 boundary above. Still listed here so the
  exclusion is auditable.
- `.tad/capability-packs/pack-registry.yaml`, `pack-collisions.yaml`:
  runtime pack choice; both arms load the same task-generic knowledge, so
  pack selection is not a compared variable.
- `.tad/project-knowledge/principles.md` + `patterns/`: task-generic
  knowledge, equal in both arms (the candidate re-organizes access per §4 of
  candidate.md but does not remove authority).
- `.tad/templates/output-formats/*`, `.tad/schemas/*`: review-format detail
  and config schemas — supporting, not compared.
- `.tad/hooks/lib/*` scripts, evidence dirs, logs, archives: runtime
  behavior and state, not frozen rule text.
- `.tad/config-cognitive.yaml`, `config-workflow.yaml`, `config.yaml`,
  `skills-config.yaml`: adjacent configs outside the compared stages.

## Unresolved (kept open, must NOT be called "fully measured TAD" in P2)
1. Runtime pack-detection outcome per task (static revision cannot enumerate
   which packs a harness will load).
2. Notebook REGISTRY / LSP provisioning runtime lookups.
3. Human-escalation decision points (human-gated by construction).
4. Hook side effects (manifest frozen; behavior is runtime).
5. What the P2 harness ACTUALLY loads (fidelity): verify-arms asserts the
   disclaimer is present; P1 exposes, P2 must verify. If this closure cannot
   be approved as fair, readiness = adapter-ineligible and P2 does not start.

## Hash equality vs fairness
Equal recomputed hashes prove the frozen text is intact. They do NOT prove
the scope choice is fair — that judgment belongs to the independent reviewer
(arms/scope-approval.json), who must reject an unfair-but-intact closure.
