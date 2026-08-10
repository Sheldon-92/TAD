# Acceptance Verification Report — Lite Authority Model v2 / Gate 4 Repair-2

**Task:** FULL-RETIRE-P3B-LITE-AUTHORITY-V2
**Mandate:** revision 2
**Repair base:** `c851046dc41b65f89dbe0acfbb51cc198d016c81`
**Recorded tip:** `80413f8f2c4b48d0e2e9f23d98d52e9bdc541a5e`
**Technical verdict:** GATE 3 PASS
**Push:** NOT PERFORMED

## AC1–AC12

| AC | Result | Exact evidence |
|---|---|---|
| AC1 | PASS | `inventory_paths=13`; exact live-path set and dispositions |
| AC2 | PASS | accepted mandate, lifecycle, exact binding, transaction, and CAS anchors |
| AC3 | PASS | obsolete approval fields absent; closed prompt classifier and observability present |
| AC4 | PASS | handoff-owned transaction, exact ref/MWS/self-target guards, replay and recovery |
| AC5 | PASS | Claude/Codex/Lite routing aligned; release progressive-load maximum retained |
| AC6 | PASS | `mirror_pairs=5` byte-identical |
| AC7 | PASS | 30-row independent semantic oracle; closed-world JSONL keys; recomputed-digest unknown-key rejection; controls `2/2`; probes `10/10` |
| AC8 | PASS | Lite core `52,198≤52,200`; entry `8,469≤9,500`; refs `15,873≤17,400` bytes |
| AC9 | PASS | overdue scan empty; supersession disposition and mandate carrier present |
| AC10 | PASS | repair-2 recorded-window four-plane endpoint equality `4/4`; transient command absence not claimed |
| AC11 | PASS | three post-commit independent reviews each final P0=0, P1=0, P2=0 |
| AC12 | PASS | `--all` passed 3/3 deterministic runs; full `c851046..80413f8` range exact, linear, non-merge, per-commit §5.5 scoped; push not performed |

Raw output carrier: `verification-results.txt` (SHA-256
`1e6520ef5bfd6c7573d59a26833ad6d2d77ab3ebb907a215cbbf21967a080f47`). Each recorded run has
SHA-256 `95801ca6e75ae75275a458e6508ef61e9e92df48994041fa89995b5cd03520d9` and ends `RESULT: PASS`.

## Repair-2 authority result

- Human impact radius is exact target/path/consequence/external reach and bounded impact; technical
  commit/retry/reviewer/evidence cardinality remains agent-owned.
- Local history is task-scoped append-only. The complete ordered repair-2 list is one commit,
  `80413f8f2c4b48d0e2e9f23d98d52e9bdc541a5e`, with 32 explicit §5.5 paths.
- Revision-1 commit `c851046` remains historical protocol-deviation evidence and was not
  retroactively authorized.
- Closed-world JSONL rejects unknown, missing, mistyped, and misplaced keys. The recomputed-digest
  unknown-key mutation is independently rejected with digest
  `7976031d902bcc2caf5f9285b7beb9a34092f1b5b2559b3d961965b23220931d`.
- `avoidable_runtime_prompt_count=0`.

## Zero-touch proof

Manifest SHA-256: `a330b817725fe3ed45d755afbefc0044273d2747e970555dac44aa481ad01ee7`.

| Plane | Repair-2 pre/post SHA-256 | Result |
|---|---|---|
| tracked worktree | `724e72ef09bbd2a7f130ce0a8462a5ed99b2a6f2e31c7eff375d98e4b4013ca0` | PASS |
| untracked + ignored | `92baae9f053e310c15174df2c6e9f2c6deca3b168d7af85e84afa47d800f8424` | PASS |
| cached index | `d8cb067455062592044a905d9c538d251382575e6cf475ec93d220f81cb13981` | PASS |
| 14 registered targets | `f71f13995690a18943a5f0526945c20e1dfd00a761f204a12513c0510bb2df40` | PASS |

Controls carrier SHA-256:
`31cdbb4b9e858bcb5349e65c0b86c98d8d17eef0538cd945920fa3f952fc349b`; positive controls `2/2`,
mutation probes `10/10`.

These are persistent endpoint comparisons for the recorded repair window. They do not claim continuous
observation or prove that a transient external command could never have run. The execution record
contains no push, tag, publish, sync, registry/registered-target write, dependency/deploy/payment/
credential mutation, destructive data change, or history rewrite.

## Independent reviews

- Spec compliance: PASS, P0=0, P1=0, P2=0.
- Implementation/architecture: PASS, P0=0, P1=0, P2=0.
- Security/least authority: PASS, P0=0, P1=0, P2=0.

The spec and security reviewers' only pre-commit P1 was the expected empty history range; both closed it
after `80413f8` was recorded and `--check history` passed. No implementation defect remained.
