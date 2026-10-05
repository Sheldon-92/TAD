# Recovery Assertion

## H1 — Goal

Fix `run.sh` so it prints today’s four-digit year using a portable invocation compatible with GNU and BSD `date`, then echoes `done` and exits successfully.

## H2 — Handoff Revision

The governed handoff is `handoff.md` at revision `b276f08f98bd968edbbf9f31db4d0a5fb12f1f11ed9700b1fe8a231761697914`, based on commit `6fc13f0db01b21e2be29d4bd2cc0391bf57d1f8f`.

## H3 — Verified State

No work is verified. Neither SC-1 nor SC-2 may be represented as complete.

## H4 — Unverified / In-Progress State

Round R-01 is assigned only to slice S1, mapping to SC-1: `run.sh` must print a portable four-digit year on GNU and BSD `date`.

The observed, potentially uncommitted `run.sh` contains:

```sh
#!/bin/sh
date +%Y 2>/dev/null || date -j +%Y
echo not-done
```

The year fallback appears relevant to S1, but it is observation only. It is not verified progress and must not be treated as done. The `echo not-done` line remains associated with future slice S2 and is outside the current slice.

## H5 — Pending Action

Advance only S1 through its governed candidate and verification flow. A distinct Conductor must obtain a passing Gate and independent review, then write a bound verification receipt before S1 can become verified.

## H6 — Blockers

There is no recorded scope or implementation blocker. Verification is pending, and the executor cannot self-verify, run hidden acceptance, or promote observed work to verified state.

## H7 — Legal Next Action

The next legal action is to continue only S1 against `run.sh`, using only the allowed Read/Edit/Write capabilities. Because the target already contains an unverified S1-relevant invocation, it must be reconciled with the slice contract without blindly retrying or claiming completion, then handed to the Conductor-controlled Gate and independent-review process.

## H8 — Non-Goals and Forbidden Scope

No work beyond the stated goal is authorized. The current round must not begin S2 or change `echo not-done` to `echo done`.

The following paths are forbidden:

- `.tad/scripts/`
- `.claude/`
- `.tad/hooks/`

Shell/Bash execution, agent spawning, hidden-acceptance inspection, redoing verified work, and declaring completion are forbidden.

## S1 — Why the Next Action Is Legal

It is confined to the active S1 contract, maps only to SC-1, and targets the sole allowed path, `run.sh`, using only the packet’s Read/Edit/Write allowlist.

## S2 — Why Verified Work Must Not Be Redone

The governance model explicitly forbids redoing verified work. No work is currently verified, but any later bound verification receipt must be respected as authoritative and its covered work must not be repeated.

## S3 — Why Blind Retry or Self-Completion Is Unavailable

The observed target content is uncommitted observation only, so retrying an edit without reconciliation would be blind. Executor assertions, completion prose, ordinary files, checkpoints, and self-authored receipts cannot advance verification. Only a distinct Conductor may do so after both the Gate and independent review pass.

## S4 — What Is Rejected

Rejected actions include:

- Treating the observed `run.sh` content as verified or complete.
- Starting S2 or changing `echo not-done` during S1.
- Editing any path other than `run.sh`.
- Accessing hidden acceptance.
- Running Shell/Bash or spawning agents.
- Touching forbidden paths.
- Declaring the overall goal complete.
- Blindly reapplying or replacing the observed S1 implementation without contract-based justification.