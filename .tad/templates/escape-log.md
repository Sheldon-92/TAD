# Escape log

A defect found after Gate 4, in a result that was already accepted, is one line here. The writer records; the rule table below names the gate, so nobody has to judge it.

Writers: Cora, when a defect in an accepted result is reported to her (before she triages the fix); direct `/alex *bug` step2, when the bug is in an archived handoff or a completed Epic. Reader: distillation (conductor epic_completion 3b and `distillation-loop-protocol.md`): lines dated since the last distillation are candidates under the variabilize test.

Live file: `.tad/evidence/escape-log.md` (gitignored evidence dir; the writer creates it from this template on first use).

| date | defect | found by | gate that should have caught it | pointer | class |
|---|---|---|---|---|---|

Rule for column 4 (first match wins):

| The defect is... | Gate |
|---|---|
| shown by a §9.1 command or a listed real_path | `Gate 3` |
| a path or case the handoff did not list | `Gate 2` |
| a mismatch with `## Requirement` / Result contract that a real use would show | `Gate 4` |
| the requirement itself wrong or missing | `Gate 1` |
| none of the above | `unclear` (the fix's designer fills it later) |

甲 2 触发指针（与上表同读）：记录或读到一条 escape 条目、其 scenario 的因果事实指向「项目常设项未入该链 §9.1 致逃逸 Gate 3」者，按设计正本 `.tad/evidence/yolo/r4-batch/phase1-design.md` §5 处理——把该条目复制一行入最近一份蒸馏报告的 carry／下一设计议题清单，并点名甲 2 重议。判据以 scenario 的因果事实为准；`class` 字面只作检索辅助，不得以字面不合为由漏触发，也不得仅凭字面套用。
