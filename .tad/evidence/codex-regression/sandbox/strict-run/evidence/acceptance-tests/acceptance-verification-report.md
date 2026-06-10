# Acceptance Verification Report

Task: `to_upper` strict sandbox
Handoff: `HANDOFF-inline-strict.md`

## Results

- AC1: PASS — `printf 'abc\n' | ./to_upper.sh` produced `ABC`
- AC2: PASS — empty input emitted `0` bytes and exited `0`
- AC3: PASS — `printf 'Abc 123 !?\n' | ./to_upper.sh` produced `ABC 123 !?`
- AC4: PASS — multiline input preserved line structure while uppercasing ASCII lowercase bytes
- AC5: PASS — `sh ./test_to_upper.sh` returned `PASS`

## Raw Evidence

- `evidence/acceptance-tests/to_upper-results.txt`
