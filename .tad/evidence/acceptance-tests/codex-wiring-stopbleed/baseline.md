# Codex Wiring Stopbleed — pre-edit baseline

Captured before any product-file edit on 2026-08-03.

```text
BASELINE_COMMIT=e5b810d7ab1bf1a61d7ad5372a174b95b007c5e3
codex-cli=0.146.0
claude-code=2.1.220
```

## Product file fingerprints

| file | md5 | lines |
|---|---|---:|
| `.codex/hooks.json` | `ed66f9eb5bbadc7bc5dac13b086ed731` | 25 |
| `tad.sh` | `2ff37f95d09e99bc2f3affbbbc141b88` | 1853 |
| `.claude/skills/alex/SKILL.md` | `d83176b3fb7052372cea1411322d1f30` | 1920 |
| `.agents/skills/alex/SKILL.md` | `d83176b3fb7052372cea1411322d1f30` | 1920 |
| `.claude/skills/blake/SKILL.md` | `f4514a10d46cb316a44ae699b2e19e70` | 2118 |
| `.agents/skills/blake/SKILL.md` | `f4514a10d46cb316a44ae699b2e19e70` | 2118 |
| `.tad/hooks/lib/release-verify.sh` | `ef5bc186ae6a46df5ea2ebd23f4680d3` | 990 |
| `.tad/runtime-compat/codex.md` | `388cd648441ee461c8db3dee40580810` | 35 |
| `.tad/guides/hooks-platform-mapping.md` | `f71cf990e4db204f75c1c0e8318c395a` | 55 |
| `docs/CODEX-USER-GUIDE.md` | `1062c667deefeab66cb04039081010a4` | 482 |
| `INSTALLATION_GUIDE.md` | `ba687a78f2e771ebfaa1bb4b503c802d` | 143 |

The handoff names `docs/INSTALLATION_GUIDE.md`, but the repository's actual
tracked file is root-level `INSTALLATION_GUIDE.md`; that is the file used for
the matching documentation fix.

## Structural baselines

```text
platform-coupled reference declarations across .claude/.agents: 72
alex reference declarations per tree: 35 total (34 .claude/skills paths + 1 .tad path)
blake reference declarations per tree: 2
heredoc extracted hash: ed66f9eb5bbadc7bc5dac13b086ed731
release-verify.sh parity: PASS, exit 0
skill-body-verify.sh: PASS, exit 0
```

## Runtime freshness baseline

Command: `bash .tad/hooks/lib/runtime-freshness-verify.sh . 2026-08-03`.

```text
Total: 21 entries | PASS: 16 | WARN: 0 | BLOCK: 5
VERDICT: runtime freshness BLOCK
GATE: runtime-freshness exit=1
```

The five baseline BLOCK surfaces were `skill_loading`, `hooks`,
`subagents_custom_agents`, `codex_cloud`, and `ask_user_question_hook`.

## Pre-existing worktree state

Preserved without cleanup: the active codex-wiring handoff, the two old Lite
archive/Completion paths, `NEXT.md`, two project-knowledge pattern edits, and
the existing trace JSONL. These are not treated as this task's baseline product
changes.
