# YOLO 2.0 Epic Reset Audit

**Date**: 2026-08-24  
**Mode**: Alex architecture/product reset  
**Scope**: Epic-level; no implementation or live YOLO changes

## Finding

The original Epic identified the right invariants—durable progress, independent verification, bounded rounds, honest degradation—but sequenced them incorrectly. It attempted to certify a universal kernel and adversarial JavaScript verifier before proving the user's main outcome on one real task.

Five design cycles, a 510-line Epic, a 1,171-line Phase-1 Handoff and a final `vm.Script` alias bypass show that the verification apparatus had become a larger defect surface than the first deliverable. This matches the project's prior pattern: when every local bypass creates another verifier layer, shrink or relocate the scope instead of hardening indefinitely.

## User-problem causal chain

```text
goal + constraints + decisions
  → long execution and context noise
  → compact/restart/harness switch
  → incomplete semantic recovery
  → wrong or repeated next action
  → local checks validate the wrong slice
  → final quality declines or completion is false
```

The original design was strong on the last two links but weak on semantic re-entry and paired final-quality measurement.

## Reset recommendation

- Deliver one real resume path first.
- Store goal, decisions, verified facts and risks outside model context.
- Require a recovery assertion before execution resumes.
- Use one Supervisor and one state owner; no swarm.
- Checkpoint recovery-relevant boundaries, not every turn.
- Compare resumed and uninterrupted real tasks, not only fixtures.
- Defer generic reducer/security machinery until observed failures require it.

## Independent reviews

The architecture reviewer found six misframings: proof-before-utility, adversarial-JS scope creep, bottom-up vertical slice, missing quality definition, late harness boundaries and mechanism/invariant confusion. It recommended keeping file-native recovery and existing Gates while deleting the Phase-1 bespoke verifier blocker.

The product/quality reviewer found that state replay does not prove task understanding. It required semantic re-entry, paired v1/v2 trajectories, hidden acceptance conditions, independent judging, real dogfood and explicit non-regression thresholds.

Both reviews independently converged on the same reset: preserve the direction, replace the sequence.

Final artifact review: architecture PASS / P0=0; quality PASS / P0=0. Their P1 notes were incorporated: hard vs soft recovery anchors are now explicit, paired quality runs require frozen isolated starting conditions, +15pp is a product target while CI lower bound ≥0 is the release gate, and stale historical recovery instructions were made non-authoritative.

## Capability-pack influence

- Agent architecture: Level-3 bounded orchestrator, Supervisor topology, single state owner, D1–D10 explicit decisions.
- Agent memory: separate working/episodic/semantic/procedural state; durable facts cannot live only in context; native compact is not state authority.
- Agent orchestration: long chains cross the complexity cliff; use durable bounded slices, explicit verifier and no blind retry.
- AI evaluation: evaluate outcomes over steps, report Pass@k and Pass^k, use paired baselines, repeat stochastic cases, and keep judge separate from optimizer.
