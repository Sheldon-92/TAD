# Independent Forward-Test Scoring

Scorer: independent read-only `luna_scout` session.

- Initial scoring found case 2 gate-order noncompliance: the output placed the derived sync-set report
  after the version gate.
- The publish reference was repaired to make the normative sequence explicit and prohibit reordering.
- After the AC6 harness repairs and external-state stabilization, all six cases were regenerated in
  fresh `--ephemeral --sandbox read-only` sessions inside the passing `stable5` pre/post window.
- Final independent rescoring returned all six dimensions `1`, mutation count `0`, and verdict `PASS`
  for every case 1–6.

Final result: 6/6 cases; 6/6 rubric dimensions per case; live mutation count 0.
