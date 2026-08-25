# DR-20260824: YOLO 2.0 Vertical-Slice-First Reset

**Date**: 2026-08-24  
**Status**: ACCEPTED — human confirmed option 1 on 2026-08-24  
**Owner**: Alex  
**Supersedes sequencing in**: `DR-20260824-yolo2-orchestration-kernel.md`

## Decision

Keep the local-first, durable, bounded Manage–Execute–Audit direction, but reverse the delivery order:

1. prove one real compact/kill/resume YOLO path first;
2. make semantic re-entry and final quality first-class outcomes;
3. harden or extract a generic kernel only from failures observed in that vertical slice;
4. add cross-harness parity after a reference harness has produced real dogfood evidence.

## Why the previous sequence is rejected

The original Epic reached five Gate-2 design cycles while remaining at 0/6 phases. Its first handoff grew to 1,171 lines and became dominated by Acorn AST traversal, VM execution boundaries, npm provenance, constructor aliases and 26 negative controls. The final P0 was another alias of an intentionally permitted `vm.Script` capability.

This is evidence of a scope error, not simply one missing check. The project knowledge rule “Verification Strength Is Bounded by the Deliverable's Determinacy” says repeated green forgeries or verifier defects should trigger scope reduction. The user outcome—goal/progress continuity and stable quality—had not yet been exercised on a real resumed YOLO task.

## Kept

- human-approved Handoff as goal authority;
- durable state outside model context;
- bounded work slices and fresh contexts;
- no blind retry and explicit `outcome_unknown`;
- independent verification and existing Gate authority;
- local files, opt-in rollout and honest harness degradation.

## Changed

- the first artifact is a real recovery vertical slice, not a universal certification contract;
- semantic recovery is co-equal with state integrity;
- outcome quality is measured against v1 through paired real tasks;
- checkpointing is selective at recovery-relevant boundaries;
- generic schemas/reducer/hash chain are deferred until real failure evidence justifies them;
- custom JavaScript sandbox and arbitrary-source proof are out of the first-release threat model.

## Consequences

- useful dogfood arrives in Phase 1 instead of Phase 5;
- the first implementation surface becomes smaller and easier to verify;
- early durability is less theoretically general, but every mechanism is tied to an observed recovery need;
- full cross-harness and adversarial hardening arrive later, with better empirical requirements;
- YOLO v1 remains the default until the paired benchmark and Gate 4 pass.

## Revisit triggers

Promote the minimal record into a stronger deterministic kernel only if dogfood shows one of these:

- checkpoint corruption or replay ambiguity;
- concurrent/stale writers;
- state size or recovery latency beyond recorded limits;
- duplicate side effects not containable with action receipts;
- multiple adapters implementing incompatible state transitions.

If TAD becomes a multi-user, cross-machine service, reassess LangGraph or Temporal rather than continuing to enlarge the file-native kernel.
