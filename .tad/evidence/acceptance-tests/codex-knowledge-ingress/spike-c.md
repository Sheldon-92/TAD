# Spike C — Codex hook envelope

Date: 2026-08-03
Verdict: **PASS — honest no-delivery mapping**

## Setup

The probe used a fresh trusted scratch repository at
`.tad/evidence/acceptance-tests/codex-knowledge-ingress/spike-work` with an
initial commit `f6ef686`. It used the isolated
`.tad/evidence/acceptance-tests/codex-knowledge-ingress/spike-codex-home` as
`CODEX_HOME`; no credentials were copied into that directory.

The scratch `.codex/hooks.json` registered capture commands for
`SessionStart` (`startup|resume|compact`) and `PostToolUse` (`apply_patch`).
The capture command would have written one event file containing stdin, sorted
environment, and argv. That fixture shape is setup evidence only; it is not a
claim that Codex delivered it.

## Real probe

Command:

```sh
env CODEX_HOME="$SPIKE_ROOT/spike-codex-home" \
  codex exec --cd "$SPIKE_ROOT/spike-work" --ephemeral --json \
  --color never --sandbox workspace-write \
  'Use apply_patch exactly once ...'
```

Observed result: the Codex 0.146.0 process started a thread but never reached
a turn. The Responses WebSocket and HTTPS fallback both returned HTTP 401
`Missing bearer or basic authentication`. The command returned exit 1. No
capture event file and no target patch were produced.

Therefore stdin, env, argv, and a SessionStart compact discriminator were not
observed. There is no honest shape to normalize for this run. In particular,
the fixture JSON and the handoff's protocol descriptions are not substituted
for a delivered event.

## Event-by-event observation

| Event target | stdin | env | argv | delivered fields |
|---|---|---|---|---|
| `SessionStart` (`startup\|resume\|compact`) | no stdin observed by a hook | no hook env observed | no hook argv observed | no `source`/compact field observed |
| `PostToolUse` (`apply_patch`) | no stdin observed by a hook | no hook env observed | no hook argv observed | no tool/file fields observed |

The “no stdin” cells are an observation that the capture process was never
invoked in the authenticated probe, not an inferred empty payload.

## Mapping

| Question | Real observation |
|---|---|
| Hook delivery | none; authentication stopped the session |
| Three channels | no stdin/env/argv payload was delivered to the probe |
| SessionStart compact field | not measurable in this run |
| `HOOK_SOURCE` equivalent | no delivered equivalent; must remain empty when absent |

This is the handoff-authorized “unsupported/no delivery” outcome, so the spike
passes with the limitation preserved for the implementation and later
fixtures.
