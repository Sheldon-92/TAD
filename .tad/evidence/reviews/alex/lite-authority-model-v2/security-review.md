# Gate 2 Security Review — Lite Authority Model v2

**Reviewer:** independent security reviewer (`/root/phase3b_security_review`)  
**Review round:** initial, before repair  
**Verdict:** FAIL  
**Counts:** P0=0, P1=3, P2=2

## Findings

### P1-SEC-1 — Accepted-mandate cross-field invariant was not closed

The draft schema permitted contradictory states such as `status=accepted` with
`acceptance.decision=pending` or an empty decision timestamp, and the fixture set did not reject them.

Required repair: define the full accepted-state invariant and reject malformed, mismatched, duplicate,
superseded, and expired mandates before mutation.

### P1-SEC-2 — No transaction-level single-writer replacement

Per-command atomic approval claims were removed without a transaction-level CAS/single-writer rule or a
concurrent-resume fixture. Two executors could both believe they owned launch.

Required repair: persist monotonic transaction state in the sole LITE handoff; use an exclusive
compare/re-read/write transition; make losers reconcile without mutation; cover concurrent and stale
resume cases.

### P1-SEC-3 — Target/consequence bindings were not exact enough

The mandate did not require exact remote/ref/path/MWS/account/credential/financial bindings even though
its consequence vocabulary authorizes those effects. Separate class and target lists risked accidental
Cartesian-product authority.

Required repair: bind every consequence to declared target IDs and exact origin/ref/pathspec/MWS,
environment, payer/payee/currency/amount, or account/credential/owner operation as applicable.

### P2-SEC-1 — Missing unlisted local-commit negative

Required repair: prove that absent `local_commit` authority leaves work uncommitted without creating a
new prompt.

### P2-SEC-2 — Missing archive-before-acceptance negative

Required repair: prove that Gate success with pending final business acceptance waits without archive
and without a fake archive-confirmation prompt.

## Repair Mapping

| Finding | Repaired in |
|---|---|
| P1-SEC-1 | design contract §2; handoff P2/P3, AC2; lifecycle fixtures in contract §7 |
| P1-SEC-2 | design contract §4; handoff §3.2/transaction section/P3/P4; CAS/replay fixtures |
| P1-SEC-3 | design contract §2; handoff accepted mandate, P3/P4; target/ref/MWS/financial/credential fixtures |
| P2-SEC-1 | `unlisted-local-commit` fixture |
| P2-SEC-2 | `archive-before-acceptance` and `archive-after-acceptance` fixtures |

## Incremental Re-review

**Reviewer model:** harness=codex, model=GPT-5, route=unknown  
**Final verdict:** PASS  
**Counts:** P0=0, P1=0, P2=0

The reviewer confirmed every initial finding CLOSED:

- accepted-state status/decision/timestamp/source/revision and lifecycle cases are fail-closed;
- exact root/origin/ref/pathspec/MWS/environment/account/credential/financial bindings prevent
  Cartesian-product authority;
- versioned handoff state, exclusive compare/re-read/write, CAS contention, pre-state drift,
  completed replay, and duplicate IDs close the single-writer/replay boundary;
- missing `local_commit` leaves work uncommitted without prompting;
- pending final business acceptance does not archive, while acceptance archives without a second
  archive prompt.

No new material regression was supported. The reviewer noted that the CAS implementation still had to
use a real atomic primitive and pass its scratch probe; the subsequent architecture repair makes that
primitive and crash behavior explicit.
