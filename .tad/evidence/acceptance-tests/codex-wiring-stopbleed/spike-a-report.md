# Spike A — Codex hooks schema (2026-08-03)

## Environment and isolation

- CLI: `codex-cli 0.146.0` (`codex --version`).
- Scratch Git repository: `.tad/evidence/acceptance-tests/codex-wiring-stopbleed/spike-work/`.
- Scratch repository initial commit: `c28ec2c spike: establish trusted scratch repository`.
- Scratch `CODEX_HOME`: `.tad/evidence/acceptance-tests/codex-wiring-stopbleed/spike-codex-home/`.
- Scratch config declares the scratch repository `trust_level = "trusted"`; the real `~/.codex` state/trust SQLite files were not used.

## Old schema — branch (i)

Command (same minimal session used for the candidate):

```text
env CODEX_HOME="$scratch_home" codex exec --cd "$scratch_repo" --ephemeral --json --color never --sandbox read-only 'Do not use any tools or write files. Reply with exactly SPIKE_SESSION_OK.'
```

Captured Codex session transcript (combined stream, exact error payload):

```text
{"type":"item.completed","item":{"id":"item_0","type":"error","message":"failed to parse hooks config /Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/acceptance-tests/codex-wiring-stopbleed/spike-work/.codex/hooks.json: unknown field `SessionStart`, expected `description` or `hooks` at line 2 column 16"}}
{"type":"turn.started"}
{"type":"item.completed","item":{"id":"item_1","type":"agent_message","text":"SPIKE_SESSION_OK"}}
{"type":"turn.completed","usage":{"output_tokens":8,"reasoning_output_tokens":0}}
SPIKE_EXIT=0
```

This satisfies AC1 branch (i): the real session contains the transcript's
`unknown field` + hooks-config parse signature. The model turn still completed;
the warning is a configuration parse failure, not a session/auth failure.

## Candidate schema — branch (ii) / AC2 evidence

The scratch candidate was:

```json
{
  "description": "TAD Codex lifecycle hooks spike",
  "hooks": {
    "SessionStart": [{"matcher":"startup|resume","hooks":[{"type":"command","command":"bash .tad/hooks/startup-health.sh","timeout":30},{"type":"command","command":"bash .tad/hooks/notebook-dormant-sync.sh","timeout":30}]}],
    "PostToolUse": [{"matcher":"^apply_patch$","hooks":[{"type":"command","command":"bash .tad/hooks/post-write-sync.sh","timeout":10}]},{"matcher":"^ask_user_question$","hooks":[{"type":"command","command":"bash .tad/hooks/lib/askuser-capture.sh","timeout":10}]}]
  }
}
```

The same command returned no hooks parse error and completed with
`SPIKE_SESSION_OK` (`SPIKE_EXIT=0`). A separate, explicitly marked contrast run
using `--dangerously-bypass-hook-trust` showed the candidate was loadable: both
scratch SessionStart commands ran and appended:

```text
SessionStart-startup-health
SessionStart-notebook-sync
```

The bypass flag was used only as the handoff-authorized contrast, never as the
normal acceptance path. The normal old-schema run already proves the parse
warning branch; the normal candidate run proves the warning is gone.

## Verdict

**PASS.** Codex 0.146.0 rejects the old top-level event-array shape and accepts
the `{description, hooks}` top-level shape. Proceed with the measured candidate;
do not invent a fallback schema.
