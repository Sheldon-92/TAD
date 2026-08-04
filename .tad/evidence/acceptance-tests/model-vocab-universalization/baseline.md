# Model Vocabulary Universalization — pre-edit baseline

Date: 2026-08-03 (America/New_York)
Handoff: `HANDOFF-20260803-model-vocabulary-universalization.md`

## Immutable baseline commit

The tracked pre-edit worktree was frozen before any product-file edit:

```text
BASELINE_COMMIT=39ba1c1c0fc1a92b373331d23553794dd54da135
```

This commit records the pre-existing tracked dirty state. Pre-existing
untracked handoffs, archived records, spike evidence/cache directories, and
trace JSONL remain outside this task's implementation baseline and are
preserved unchanged. Every product path in handoff §2 was tracked at the
baseline commit.

## §C governance set (pre-registered, live-derived)

Command used:

```sh
git grep -l 'AskUserQuestion' -- '.claude/skills/*/SKILL.md' | LC_ALL=C sort
```

Expected set (11 elements; equality is checked by AC3):

```text
.claude/skills/agent-computer-interface/SKILL.md
.claude/skills/alex-lite/SKILL.md
.claude/skills/alex/SKILL.md
.claude/skills/blake/SKILL.md
.claude/skills/playground/SKILL.md
.claude/skills/research-github/SKILL.md
.claude/skills/research-notebook/SKILL.md
.claude/skills/save-skill/SKILL.md
.claude/skills/tad-maintain/SKILL.md
.claude/skills/tad-test-brief/SKILL.md
.claude/skills/tad/SKILL.md
```

If the live derivation differs from this set, execution must stop and return
the discrepancy to Alex; the governance set must not be edited locally.

## Safety sentinel baseline

The `ESCALATION-LIST` block was measured before edits. All four lite files
returned the same MD5:

```text
4c55bcb6563f24dc78449fb19ff76067
```

Files: `.claude/skills/alex-lite/SKILL.md`, `.agents/skills/alex-lite/SKILL.md`,
`.claude/skills/blake-lite/SKILL.md`, `.agents/skills/blake-lite/SKILL.md`.

## Baseline probes

| Probe | Baseline |
|---|---|
| Legacy strong-tier phrase (`强档定义：opus / fable 级`) | 1 in each of 4 lite files |
| New capability-tier phrase (`按能力档位判定，不按 SKU`) | 0 in each of 4 lite files |
| Lite `Model: harness=` rows | 0 in each of 4 lite files |
| Full reviewer `REQUIRED OUTPUT` rows | 0 in Blake SKILL, Alex handoff protocol, workflow template (and mirrors) |
| Bad `Codex: ask_user_question` comments | 5 files in each active tree (10 total) |
| `ask_user_question_hook` status | `accepted_limitation` |
| Sonnet hard-coding locations | acceptance protocol, config-agents, eval/judge README |

## Scope baseline

The line-set baseline for AC8 is the immutable commit above. Registered
product edits are limited to the §2 file manifest; the `.agents` tree is
updated only by `release-verify.sh parity --fix`, and `.claude/workflows` is
single-sided because no `.agents/workflows` mirror exists.
