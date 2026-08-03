# Spike E — platform signal observation

Date: 2026-08-03
Verdict: **PASS — honest empty harness-signal set**

## Non-injection observations

The controlling shell was inspected without setting `CLAUDECODE`, any
`CODEX_SANDBOX*` variable, or `TAD_PLATFORM`. The signal filter produced no
lines. The installed CLI versions were observed as:

```text
claude --version -> 2.1.220 (Claude Code)
codex --version  -> codex-cli 0.146.0
```

These are executable availability observations, not harness signals. A real
Codex exec probe was attempted in Spike C/D, but authentication failed before
hook delivery. A Claude print probe was not allowed to spend beyond the
configured USD 0.05 budget and exited before creating a model turn with
`Exceeded USD budget (0.05)`. No model session therefore exposed a child-tool
environment to inspect.

## Nested case

Claude→Codex inheritance/cleaning was not observed because neither side
provided an authenticated model turn. Codex→Claude reverse nesting was not
claimed or inferred. The evidence deliberately does not turn the handoff's
candidate variables into measured variables.

## Oracle

The measured harness-variable name set for this environment is the empty set:

```text
{}
```

`TAD_PLATFORM` remains an explicit user override, not part of the measured
harness-signal set. Any implementation-side automatic signal reads must be
set-equal to `{}` unless a later authenticated spike supplies new evidence.
The no-signal fallback remains observable and is tested separately.
