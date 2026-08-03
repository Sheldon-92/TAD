# Spike B — reference relative-path resolution (2026-08-03)

## Scratch fixture

The fixture has distinct Claude and Codex skill trees, each with:

```text
<platform>/skills/codex-ref-probe-20260803/SKILL.md
<platform>/skills/codex-ref-probe-20260803/references/target.md
```

`SKILL.md` declares exactly `reference: "references/target.md"`; the target
contains `SPIKE_REFERENCE_TARGET=direct-read-success`.

## Claude Code — direct Read sequence

- CLI: `Claude Code 2.1.220`.
- Exact first Read path:
  `.tad/evidence/acceptance-tests/codex-wiring-stopbleed/spike-work/.claude/skills/codex-ref-probe-20260803/SKILL.md`
- Exact second Read path (skill directory joined with the reference value):
  `.tad/evidence/acceptance-tests/codex-wiring-stopbleed/spike-work/.claude/skills/codex-ref-probe-20260803/references/target.md`
- Tool sequence observed in stream JSON: `Read(SKILL.md)` → extract `references/target.md` → `Read(references/target.md)`.
- Target output: `SPIKE_REFERENCE_TARGET=direct-read-success`.
- No Glob/Grep/Bash/find/search fallback was used in the decisive unique-name run.

The first exploratory run used the generic name `spike`, which collided with a
machine-global skill and caused a wrong-path attempt before the local fixture
was reached. It is excluded from the verdict; the unique-name rerun above is
the AC0 evidence and has the required direct-read sequence.

## Codex — direct file-reader sequence

- CLI: `codex-cli 0.146.0`.
- Exact first path:
  `.tad/evidence/acceptance-tests/codex-wiring-stopbleed/spike-work/.agents/skills/codex-ref-probe-20260803/SKILL.md`
- Exact second path (skill directory joined with the reference value):
  `.tad/evidence/acceptance-tests/codex-wiring-stopbleed/spike-work/.agents/skills/codex-ref-probe-20260803/references/target.md`
- Tool sequence observed in JSONL: `exec_command sed(SKILL.md)` → extract `references/target.md` → `exec_command sed(references/target.md)`.
- Target output: `SPIKE_REFERENCE_TARGET=direct-read-success`.
- No Glob/Grep/find/search fallback was used.

## Verdict

**PASS.** Both platforms successfully read the relative reference by joining it
to the directory containing the active skill. AC0 is satisfied; proceed with
scheme α (`references/<file>.md`) for the four full-role SKILL mirrors.
