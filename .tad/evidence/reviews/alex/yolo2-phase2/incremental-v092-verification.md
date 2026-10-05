# Incremental Verification — v0.9.2 post-round-2 amendments

Reviewer model: ox-alpha (opencode-go/ox-alpha-free)
date: 2026-08-25

Artifact: `.tad/active/handoffs/HANDOFF-20260825-yolo2-phase2-bounded-quality-loop.md` (v0.9.2).
Scope: sanctioned incremental recheck of the two post-round-2 amendments only
(evaluation-adversarial-round2 P0 duplicate-effect identity; architecture-state-round2 P1
runner self-certification). No repair performed; design-text verification only.

## Finding A — effect fingerprint mutability

status: RESOLVED

evidence:

§4.5 (HANDOFF lines 411–430):

> ... `action-start` is legal only in `ROUND_AUTHORIZED`, before the native tool call,
> and while the action budget remains. It additionally binds round ID, normalized tool
> class/arguments, exact affected real paths, pre-state digests, intended effect or
> post-state digests, and frozen outcome ID, then mints a unique `action_nonce`. The
> runner must carry that nonce in the next native mutating call and snapshot the
> observed effect. The reducer computes effect identity only from independently
> observed results:
>
> ```text
> effect_fingerprint = sha256(canonical-json(
>   observed_affected_real_paths + observed_final_content_or_effect_digests
> ))
> ```
>
> Command spelling, outcome ID, slice ID, and success mapping are excluded, so renaming
> the same effect cannot hide duplicate verified work. An observed mutating call is
> **unauthorized** if no earlier open `action_started` matches its canonical tool
> arguments, paths, pre-state, round, action nonce and outcome, or if it violates the
> legal next action. It is **repeated verified work** if its observed effect
> fingerprint already belongs to verified history. A legitimate later edit to the same
> path has a different observed final digest and therefore a different effect; label
> changes alone grant no exception.

Required rename-replay controls are present in both gates named by the finding:

AC6 (lines 829–832): "Further red controls replay the identical observed effect while
changing only outcome ID, slice ID, success mapping, or all three; each must keep phase
candidate blocked."

AC11 (lines 896–898): checker "rejects ... direct unreceipted mutation,
effect-equivalent replay, effect replay under renamed outcome/slice/success labels ..."

This matches the required fix verbatim: identity derived solely from canonical observed
affected real paths plus observed final content/effect digests; `outcome_id`, slice ID,
and success mapping excluded from identity (they remain bound only inside the
`action_started` authorization match, which is correct — they gate legality, not
duplicate detection).

bypass attempt: Attempted three concrete evasions under the amended text.
(1) Replay identical content under renamed outcome/slice/success labels — excluded
fields make the fingerprint unchanged; explicitly blocked as repeated verified work and
as an AC6/AC11 red control.
(2) Replay "same" work at a different target path to obtain a fresh fingerprint — that
is a genuinely different observed effect by definition; additionally the delete/rewrite
of the original path would surface as unreceipted mutation via the git reconciliation
("The final git changed-path/content manifest is reconciled with the native tool trace,
so an unreceipted direct mutation cannot disappear merely because no event named it",
lines 432–434), and each new mutating call still requires a matching `action_started`
with matching pre-state (stale-pre-state replay is an explicit AC6 block).
(3) Shift the effect outside the repository — forbidden: "Non-repository external side
effects are forbidden in Phase-2 dogfood" (line 434).
No bypass found.

## Finding B — native record provenance

status: RESOLVED

evidence:

§4.4 (lines 316–318): "The selected reference-harness runner emits a native, hash-bound
record rather than trusting executor prose:" followed by the `yolo-reference-turn-v1`
record (lines 320–358) containing `"written_by": "reference-runner"`,
`"runner_version"`, `"runner_sha256"`, `"parser_version"`, `"invocation_nonce"`,
`"raw_native_output": {"host_locator": "...", "sha256": "..."}`,
`"raw_native_trace": {"host_locator": "...", "sha256": "..."}`, a `tool_policy` denying
`["Write", "Edit", "Shell", "Agent"]`, ordered `tool_calls` with `native_call_id`,
`args_sha256`, `pre_manifest_sha256`, `post_manifest_sha256`,
`observed_changed/deleted/untracked`, and `action_nonce`.

Lines 361–369: "The bounded one-harness runner is the trusted producer. It writes
records and raw native artifacts into a host-side evidence root unavailable to the
executor. The record binds runner/parser bytes, native role/session, invocation nonce,
raw output and trace hashes, and an ordered complete tool-call list. For every mutating
call it captures repository pre/post content manifests including changed, deleted, and
untracked paths. The strict probe includes a deliberate denied write attempt;
assertion-turn records must prove no side effect occurred. A JSON with `native:true`
but no matching raw artifacts and runner provenance is rejected."

Executor shell denial, §4.2 (lines 286–289): "Executor Shell/Bash and Agent spawning
are denied in strict Phase 2."

Reviewer independence, §4.4 (lines 373–376): "reviewer native identity/session distinct
from executor identity/session, bound by its own runner-produced role record".

Execution-turn binding, §4.4 (lines 381–386) + §4.5 (lines 396–398): "`round-close`
requires an execution-turn native record with that exact session ID" and one-to-one
"reconciliation of every observed side-effecting tool call to a prior policy-mode
`action_started` event"; the action nonce minted at §4.5 line 412 "must [be] carr[ied]
... in the next native mutating call".

All controls demanded by the round-2 required fix exist as negative fixtures: AC5
(lines 808–811) "session-ID mismatch, tools not disabled, accepted write attempt,
prose-only record, raw-output SHA mismatch, runner/parser/invocation provenance
mismatch, reviewer using the executor session"; AC6 (lines 830–832) "Runner/action
nonce mismatch, extra native trace call, and changed/deleted/untracked mutation by a
deterministic check also fail." Runner trustworthiness itself is gated by the §7 strict
capability probe (10 capabilities incl. native records, stable session IDs, hidden-root
denial) before any dogfood use.

bypass attempt: Attempted four self-certification routes under the amended text.
(1) Executor authors its own turn JSON with `native:true` — rejected because raw
artifacts live in "a host-side evidence root unavailable to the executor" and any
record without "matching raw artifacts and runner provenance is rejected"; the checker
also recomputes counts from canonical records and final manifests (AC6), so a forged
JSON cannot substitute for host-side bytes.
(2) Executor shells out to mutate state or fabricate evidence — Shell/Bash/Agent denied
in strict mode; assertion turn runs with write/shell tools disabled; deliberate denied
write is a probe requirement, and assertion records must prove zero side effects.
(3) Self-review / reviewer impersonation — reviewer must be a distinct native
identity/session bound by its own runner-produced role record; "reviewer using the
executor session" is an AC5 red control; alignment reviewers must be independent from
all executors since prior alignment (§4.6).
(4) Drop or reorder trace entries — the record binds an "ordered complete tool-call
list"; missing tool-trace entry and extra native trace call are both explicit AC6
blocks, and the final git manifest reconciles against the trace so silent omissions
surface as unreceipted mutation.
Residual assumption: the runner binary is trusted — this is precisely the trusted
host-side-producer fix the finding prescribed, and it is bounded by the frozen
`runner_sha256`, parser version pinning, and the §7/AC10 strict probe. No
executor-controlled self-certification path found.

incremental_verdict: PASS
