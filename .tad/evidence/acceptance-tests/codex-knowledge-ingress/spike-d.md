# Spike D — PreCompact delivery

Date: 2026-08-03
Verdict: **PASS — honest no-delivery mapping; no wiring branch selected**

## Setup

The same fresh scratch repository was used. The PreCompact probe was added to
the scratch hook configuration and committed as `d12b425`. It captures stdin,
sorted environment, and argv only when a real `PreCompact` event is delivered.

## Real probe

Command:

```sh
env CODEX_HOME="$SPIKE_ROOT/spike-codex-home" \
  codex exec --cd "$SPIKE_ROOT/spike-work" --ephemeral --json \
  --color never --sandbox workspace-write \
  'Run a minimal authenticated probe only; do not make any repository changes.'
```

Observed result: Codex 0.146.0 repeatedly returned HTTP 401
`Missing bearer or basic authentication` while reconnecting. It never
established an authenticated turn. The PreCompact capture directory remained
empty; no `PreCompact` event was delivered and no compaction trigger was
observed.

The CLI help surface was inspected only to determine how to invoke the
non-interactive probe. That inspection is not evidence of a runtime event and
is not used to claim that PreCompact is unsupported.

## Mapping

This run cannot distinguish “the surface has no event” from “the event was not
reached because authentication failed.” Accordingly, this task does not wire a
PreCompact consumer and does not mark the runtime ledger as verified from
documentation. The limitation is recorded as:

```text
Spike D: no authenticated Codex delivery; PreCompact fire unmeasured;
no wiring; no docs-only verified claim; re-probe required when a trusted
authenticated scratch session is available.
```

No snapshot or ledger state is presented as a successful trigger. This is the
handoff-authorized no-delivery PASS path, with “fire unmeasured” kept explicit.
