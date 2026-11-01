# checkpoint-before-long-batch

**Source project**: TAD
**Date**: 2026-10-31
**Type**: protocol

## Selector
Applies before starting a batch job expected to run longer than one session
or to touch more than ~50 items (migration waves, bulk rescans, fleet-wide
updates). Near-miss: a single-file edit or a sub-5-minute script run does NOT
trigger this — checkpoint overhead would exceed the work itself.

## Action
1. Write a checkpoint manifest next to the job's evidence: job id, item list
   (or the query that regenerates it), per-item state field, the resume
   command, and the output paths.
2. Update the manifest after each item completes, not at the end — state is
   written by the step that changes it.
3. On restart, read the manifest first; resume from the first non-done item;
   never re-run done items "to be safe".
4. Close the manifest with a final line: total / done / failed counts that
   sum to the item list length.

## failure_mode
Naive default: run the batch in one pass and reconstruct state from memory
or logs after a crash, timeout, or compaction. Why wrong: reconstruction
guesses — done items get re-run (double writes, duplicate sends) and failed
items get silently skipped, and neither error is visible in the final count.
