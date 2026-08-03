model=codex/gpt-5/native
verdict: PASS

[执行实证] `bash -n` verifier + AC1–AC9: all exited `0`.

[执行实证] AC1–AC9 all passed, including AC7 shim/scratch mutation/root restoration.

[执行实证] AC8 report contains model identity, `## 执行证据`, `toy-defect.sh`, raw `NOT_READY`, and finding label `执行实证`.

[执行实证] Scratch toy evidence records initial commit `c7b19bf ac8: add toy execution contract`.

[阅读推断] No P0/P1 findings.

## 执行证据

- `bash -n <verifier and AC scripts>` — every command reported `exit 0`.
- `bash AC-01-execution-probe.sh` — `PASS: AC1 execution probe obligation` `[exit=0]`
- `bash AC-02-reviewer-tier.sh` — `PASS: AC2 reviewer tier rules and placement` `[exit=0]`
- `bash AC-03-cross-role-disambiguation.sh` — `PASS: AC3 cross-role disambiguation and redlines` `[exit=0]`
- `bash AC-04-mirror-parity.sh` — `PASS: AC4 mirror parity` `[exit=0]`
- `bash AC-05-sentinel-preservation.sh` — `PASS: AC5 sentinel preservation` `[exit=0]`
- `bash AC-06-verifier-model-field.sh` — `PASS: AC6 verifier required_fields includes model` `[exit=0]`
- `bash AC-07-verifier-behavior.sh` — `PASS: AC7 verifier shim PASS + scratch mutation FAIL + root restore byte-identical` `[exit=0]`
- `bash AC-08-behavioral-probe.sh` — `PASS: AC8 behavioral execution probe report` `[exit=0]`
- `bash AC-09-reviewer-model-carriers.sh` — `PASS: AC9 reviewer model carriers` `[exit=0]`
- Standalone verifier — `RESULT: PASS (state-flow)`
