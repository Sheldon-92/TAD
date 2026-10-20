# Escape log

A defect found after Gate 4, in a result that was already accepted, is one line here. The writer records; the rule table below names the gate, so nobody has to judge it.

Writers: Cora, when a defect in an accepted result is reported to her (before she triages the fix); direct `/alex *bug` step2, when the bug is in an archived handoff or a completed Epic. Reader: distillation (conductor epic_completion 3b and `distillation-loop-protocol.md`): lines dated since the last distillation are candidates under the variabilize test.

Live file: `.tad/evidence/escape-log.md` (gitignored evidence dir; the writer creates it from this template on first use).

| date | defect | found by | gate that should have caught it | pointer |
|---|---|---|---|---|

Rule for column 4 (first match wins):

| The defect is... | Gate |
|---|---|
| shown by a §9.1 command or a listed real_path | `Gate 3` |
| a path or case the handoff did not list | `Gate 2` |
| a mismatch with `## Requirement` / Result contract that a real use would show | `Gate 4` |
| the requirement itself wrong or missing | `Gate 1` |
| none of the above | `unclear` (the fix's designer fills it later) |
