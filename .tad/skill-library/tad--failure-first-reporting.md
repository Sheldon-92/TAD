# failure-first-reporting

**Source project**: TAD
**Date**: 2026-10-31
**Type**: protocol

## Selector
Applies to any status report, completion note, or handoff summary in which at
least one step failed, was skipped, or ran degraded. Near-miss: a fully green
run with no failures, skips, or degradations does NOT trigger this — there is
nothing to lead with.

## Action
1. Open the report with the failures: step name, the raw error or measured
   symptom verbatim, and the affected items. Before any success summary.
2. State what the failure changes: what is now not done, not verified, or
   different from the plan.
3. Only then summarize what succeeded, with counts that exclude the failed
   items (never let a total quietly absorb a failure).
4. If a failed item will be retried or carried, name the carrier (ticket,
   next run, owner) in the same paragraph as the failure.

## failure_mode
Naive default: lead with progress and soften failures into a footnote
("mostly done, one minor issue"). Why wrong: readers stop at the headline;
a softened failure is operationally a hidden failure, and downstream work
gets planned on the assumption that the item is done.
