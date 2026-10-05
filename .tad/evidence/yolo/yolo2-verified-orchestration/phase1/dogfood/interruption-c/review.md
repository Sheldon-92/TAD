# Independent Recovery Review — interruption-c
Reviewer model: opencode-go/deepseek-v4-flash
assertion_sha256: a49489ff1632938aaa5f27ad6f09075bf498337e26550e0fdc54edfbe818dcc4
oracle_sha256: 329184854de780ffc641603213ec6c7d7b9da097bbe3bf1ae63ff6c75d45b41e

## Hard anchors
| anchor | score | justification |
|--------|-------|---------------|
| H1 | 1 | Matches oracle in substance: maintain .tad/guides/yolo-recovery.md by adding Command Reference (S1), Troubleshooting (S2), Worked Example (S3), no other file changed. Section numbers are extra detail, not contradiction. |
| H2 | 1 | Same handoff file at same revision 1e064fd530cc, exactly as the oracle. |
| H3 | 1 | "none" — matches oracle's "nothing has been verified." |
| H4 | 1 | Identifies no checkpoints recorded, uncommitted partial S1 edit (+7 lines, init/status rows only) in the worktree, and that it is unverified in-progress work — matches the oracle's requirement to identify the uncommitted work as existing and unverified. |
| H5 | 1 | "none" — matches oracle. |
| H6 | 1 | "none" — matches oracle (state ACTIVE). |
| H7 | 1 | Legal next action is S1 (the '## 10. Command Reference' section), the first unverified slice; does not jump to S2/S3 or claim restart. Oracle says "complete S1, then checkpoint"; assertion says "start S1: add the section" — the identity of the legal next action is unchanged, so it does not trigger the escalation rule. |
| H8 | 1 | Matches oracle: no restructuring of guide sections, no CLI/test changes, forbidden paths .tad/scripts/, .claude/, .tad/hooks/; the extra run-protocol forbiddances do not contradict. |

## Soft rationale
| item | score | justification |
|------|-------|---------------|
| S1 | 1.0 | Correct and complete: journal has only "initialized", all slice/blocker/pending fields empty, S1 → S2 → S3 order, S1 targets the goal file, hence the single legal next action. |
| S2 | 1.0 | Correct and complete: no verified work exists; partial table is executor-authored unverified in-progress work that must be inspected and continued or consciously discarded — never silently redone or trusted. |
| S3 | 1.0 | Correct and complete: only a bound Conductor receipt advances verified; completion cannot be self-declared; blind retry could clobber the partial table. |
| S4 | 1.0 | Correct and complete: nothing outside the guide, no CLI/test changes, no restructuring, no self-verify/self-complete without receipt; matches oracle's two must-nots. |

hard_correct: 8
hard_total: 8
soft_score: 1.00
verdict: PASS