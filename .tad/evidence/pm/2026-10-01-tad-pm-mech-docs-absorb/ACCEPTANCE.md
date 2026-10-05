# ACCEPTANCE — TASK-20261001-TAD-PM-MECH-DOCS-ABSORB

Scope: compare the landed TAD PM docs with the six FILTER `yes` rows. This is a task-level docs checklist, not a formal Gate 3/4 verdict.

| FILTER yes row | Result | Carrier / evidence |
| --- | --- | --- |
| Model routing / charter / human-operating pointers; old defaults no longer current | PASS | `docs/pm/intent.md`: four absolute shared pointers; 2026-09-13 list labeled historical; no duplicate routing table or local `docs/model-routing.md`. All four pointer targets exist. |
| Open-run card is disk + same-body 1:1 + stamp in order | PASS | `docs/pm/auth.md`: card on disk, same full body in PM↔human 1:1, then matching stamp, then wrapper. Shared HO §3.7b and `open-run-card.md` pointers resolve. |
| Restate non-empty with human-understood trace; discuss output is not Blake basis | PASS | `docs/pm/auth.md`: existing non-empty file and “理解对了” trace required; discuss/research/restatement/open-card cannot supply `handoff_path`, which must point to `HANDOFF-*.md`. HO §3.7d/§3.10 and `restate.md` pointers resolve. |
| No naked WAIT at closeout | PASS | `docs/pm/acceptance.md`: require a candidate task name or HOLD reason plus unlocker; empty candidate/WAIT is rejected. `docs/pm/now.md` and segment status carry a reasoned HOLD with GM as unlocker. |
| Finish / ask / look goes PM↔human 1:1; no group-only ask | PASS | `docs/pm/acceptance.md`: finish, ask, and look are 1:1; group channel is limited to policy and activation notices; “群里只发要拍” is forbidden. |
| Explicit KA and dual-write completion or no-project-memory branch | PASS | `docs/pm/acceptance.md`: explicit KA tick or “无新发现”; if project memory exists, separate disk and private-brain ticks with pointers are required; otherwise “本刀无项目记忆”. Existing `docs/pm/ops-knowledge.md` is linked. |

## Verification performed

- Confirmed all eight named shared source/template paths exist and are readable.
- Ran doc-level `grep -Fq` checks for the four intent pointers, four template pointers, historical label, open-run order, restate trace, discuss boundary, no-WAIT rule, group-ask ban, KA, and no-memory branch; all passed.
- `docs/pm/now.md` is 2 lines. Confirmed `docs/model-routing.md` was not created.
- Read the edited PM docs and local diff; no tests or code checks apply to this docs-only task.

## Limits

- `chat_sent` and any private-brain write are claims represented by the supplied disk card/stamp or future closeout pointers; this task did not independently inspect chat UI or private brain.
- No formal TAD Gate 3/4 was run or claimed.
- The current worktree contains other dirty/deleted paths outside this task. They were not edited here, and their origin is not attributed because no clean-tree baseline was captured before work.
