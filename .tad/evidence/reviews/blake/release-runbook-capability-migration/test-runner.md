# Independent Layer-2 Test Report — Gate 4 Return

Model provenance: `gpt-5.6-terra`; read-only test runner.

- Bash syntax passed for `behavior-fixtures.sh`, `capture-surface.sh`, `negative-fixtures.sh`, `run-forward-tests.sh`, and `verify.sh`.
- AC1–AC11 were executed individually after the Gate 4 repair; all exited `0` and printed `PASS`.
- AC6 uses `stable5-pre`/`stable5-post`: 14 targets captured, 12 reachable and 2 missing, with zero source or target mismatches.
- AC8 contains six PASS rows, all dimensions `1`, mutation count `0`; all fresh forward exits are `0` with read-only sandbox provenance.
- AC9 contains NEG-01 through NEG-10 PASS and final 10/10 PASS.
- AC9 explicitly records wrong-origin read-only ordering plus literal and symlink self-target denial.
  The fixtures extract and execute the published canonical Markdown guard blocks rather than copying
  their predicates.
- Canonical/generated `diff -rq` is clean; AC10 confirms source-carrier hashes, forbidden surfaces,
  and the six-file product boundary.
- No executable test invokes live push, tag, publish, sync, registry writes, or registered-target writes.

The initial P2 concern about AC8 not regenerating sessions was retracted: AC8 is the durable replay verifier, while `run-forward-tests.sh` is the generator executed inside the sealed stable5 AC6 window. Regeneration during replay would invalidate that window.

P0: 0
P1: 0
P2: 0
Verdict: PASS
