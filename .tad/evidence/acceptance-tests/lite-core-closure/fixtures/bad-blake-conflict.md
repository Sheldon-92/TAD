# BAD BLAKE FIXTURE — keeps GATE PASS wording but removes no-evidence bar, state chain, and PARTIAL-GO exclusivity

## Lite Progress

Fields: Phase, repair_round, same_error_count, verdict, Evidence, Next Action.

## Lite Technical Gate

We run a gate and report GATE PASS when things look fine.
PARTIAL-GO can be used whenever some ACs are not finished yet, including ordinary
implementation failure or missing evidence, at the executor's discretion.

## Repair

If something fails we just keep fixing it until it works.
