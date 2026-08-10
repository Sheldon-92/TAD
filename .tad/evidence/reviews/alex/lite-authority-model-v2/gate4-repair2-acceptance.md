# Gate 4 Acceptance — Lite Authority Model v2 / Repair-2

**Task:** FULL-RETIRE-P3B-LITE-AUTHORITY-V2
**Epic:** EPIC-20260809-full-capability-extraction-retirement, Phase 3b/8
**Date:** 2026-08-10
**Accepter:** Alex (Gate 4 v2, business acceptance)
**Blake Gate 3:** PASS at `80413f8f2c4b48d0e2e9f23d98d52e9bdc541a5e`, P0=0, P1=0, P2=0
**Verdict:** ✅ **PASS** — human accepted 2026-08-10

## Prerequisite (step2)

Gate 3 v2 confirmed via `.tad/evidence/reviews/blake/lite-authority-model-v2/gate3-verdict.md`:
GATE PASS, mandate revision 2, repair range `c851046..80413f8`, P0/P1/P2 = 0.

## step7.B — Independent recompute (AR-005 mandatory)

Alex re-derived every quantitative AC from raw evidence rather than accepting Blake's summary.
Commands were run directly against the repository, not read out of `verification-results.txt`.

| Quantity | Blake reported | Alex recomputed | Source of Alex's number | Match |
|---|---|---|---|---|
| repair-2 commit range | `c851046..80413f8`, 1 commit | 1 commit, `80413f8` | `git rev-list --reverse c851046..HEAD` | ✅ |
| merge commits in range | 0 | 0 | `git rev-list --merges c851046..HEAD \| wc -l` | ✅ |
| commit path count | 32 | 32 | `git diff-tree --no-commit-id --name-only -r c851046..HEAD \| sort -u \| wc -l` | ✅ |
| paths outside §5.5 | 0 | 0 (empty set) | `comm -23 <committed> <§5.5 allow-list>` | ✅ |
| Lite core bytes | 52,198 / 52,200 | 52,198 | `wc -c` on canonical alex-lite + blake-lite SKILL.md | ✅ |
| release entry bytes | 8,469 / 9,500 | 8,469 | `wc -c` release-runbook/SKILL.md | ✅ |
| release refs bytes | 15,873 / 17,400 | 15,873 | `wc -c` publish-ops.md + sync-ops.md | ✅ |
| fixtures | 30 | 30 | `wc -l authority-fixtures.jsonl` | ✅ |
| inventory_paths | 13 | 13 | `awk -F'\t' '$1=="live"{print $2}' \| sort -u \| wc -l` | ✅ |
| mirror pairs | 5 byte-identical | 5/5 identical | `cmp` on each `.claude` ↔ `.agents` pair | ✅ |
| zero-touch planes | 4/4 equal | 4/4 equal | `shasum -a 256` on repair2 pre/post ×4 | ✅ |
| ledger overdue | 0 | 0 (no rows) | SKILL's exact `awk` overdue scan | ✅ |
| independent reviews | 3 PASS, 0/0/0 | 4 carriers on disk, all PASS 0/0/0 | direct read of each review file | ✅ |
| `verification-results.txt` SHA | `1e6520ef…` | `1e6520ef5bfd6c7573d59a26833ad6d2d77ab3ebb907a215cbbf21967a080f47` | `shasum -a 256` | ✅ |
| per-run SHA | `95801ca6…` | `95801ca6e75ae75275a458e6508ef61e9e92df48994041fa89995b5cd03520d9` | `shasum -a 256` on run 3/3 slice | ✅ |

Repair-2 zero-touch hashes recomputed by Alex, matching `acceptance-verification-report.md` exactly:

| Plane | SHA-256 (pre == post) |
|---|---|
| tracked worktree | `724e72ef09bbd2a7f130ce0a8462a5ed99b2a6f2e31c7eff375d98e4b4013ca0` |
| untracked + ignored | `92baae9f053e310c15174df2c6e9f2c6deca3b168d7af85e84afa47d800f8424` |
| cached index | `d8cb067455062592044a905d9c538d251382575e6cf475ec93d220f81cb13981` |
| 14 registered targets | `f71f13995690a18943a5f0526945c20e1dfd00a761f204a12513c0510bb2df40` |

## Alex's own execution (not Blake's recorded output)

- **Fresh full replay.** Alex ran `verify-authority-model-v2.sh --all` directly: exit 0,
  `RESULT: PASS`, zero `FAIL` lines, and output **byte-identical** to the recorded run 3/3
  (`diff` empty).
- **Alex-authored adversarial probes.** The prior Gate 4 round reproduced an AC7 false PASS
  (fixture rows self-declaring outcomes, guarded only by schema + digest). To confirm the repair,
  Alex built four probes of his own, sourced the verifier's functions, and ran them against
  copies in `/tmp` (repository untouched, HEAD unchanged):

  | Probe | Mutation | Result |
  |---|---|---|
  | A | `unlisted-consequence.expected_result`: `BOUNDARY_CHANGE before mutation` → `ALLOW` | REJECTED ✅ |
  | B | inject unknown key `injected_grant` into a valid row | REJECTED ✅ |
  | C | place optional `control: positive` on a row not permitted to carry it | REJECTED ✅ |
  | D | `target-scope-change.human_prompt`: `true` → `false` | REJECTED ✅ |

  The unmutated fixture was accepted. The oracle is a 30-row **literal heredoc table inside the
  verifier** (`write_expected_outcome_oracle`, L124–L156) byte-compared against the normalized
  fixture — genuinely independent of the data under test. **The AC7 false PASS is repaired.**

## AC1–AC12 (step4)

| AC | Requirement | Blake status | Evidence present | Alex verdict |
|---|---|---|---|---|
| AC1 | Exact 13-path live-surface closure | ✅ | `live-surface-inventory.tsv` | PASS (recomputed 13) |
| AC2 | Lite mandate/classifier semantics | ✅ | `--check lite-core` | PASS |
| AC3 | No fake runtime approval questions | ✅ | `--check prompt-closure` | PASS |
| AC4 | Release transaction / recovery model | ✅ | `--check release` | PASS |
| AC5 | Routing + knowledge alignment, refs max 3 | ✅ | `--check routing` | PASS |
| AC6 | Five canonical/mirror pairs byte-identical | ✅ | `cmp` ×5 | PASS (recomputed 5/5) |
| AC7 | 30 fixtures, closed schema, 2/2 controls, 10/10 probes | ✅ | `authority-fixtures.jsonl` + oracle | PASS (+ 4/4 Alex probes) |
| AC8 | Lite ≤52,200 / entry ≤9,500 / refs ≤17,400 | ✅ | `wc -c` | PASS (52,198 — see Δ1) |
| AC9 | Ledger overdue clean, entries priced | ✅ | `lite-constraint-ledger.md` | PASS (recomputed 0) |
| AC10 | Four-plane recorded-window endpoint equality | ✅ | repair2 snapshots ×8 | PASS (recomputed 4/4) |
| AC11 | Three independent reviews PASS, 0/0/0 | ✅ | 3 review files + verdict | PASS (read directly) |
| AC12 | Replayable evidence, append-only §5.5-scoped history | ✅ | git range + `--all` 3/3 | PASS (recomputed) |

**No AC unmet. P0 = 0, P1 = 0.**

## step4b — Evidence completeness

All `required_evidence` paths in handoff §9 exist. Frontmatter `e2e_required: no`,
`research_required: no` — no E2E or research artifact required.

## step4c — Layer 2 audit (smoke alarm, non-blocking)

```
⚠️ LAYER 2 TIER UNDER-MET
DISTINCT_COUNT=1 < tier threshold 2 for task_type=mixed (Tier 1).
```

`layer2-audit.sh` exit 0, but `KNOWN_REVIEWERS` does not recognize `implementation-reviewer` or
`security-reviewer`, reporting them as `UNKNOWN` and counting only `spec-compliance-reviewer`.
**Alex verified the carriers directly on disk**: all three reviews plus `gate3-verdict.md` exist,
are substantive, and each reports final PASS with P0=P1=P2=0. The under-count is a naming-registry
gap in the audit script, not a missing review. Fixing that hook surface is explicitly out of scope
per this handoff and remains an open follow-up.

## step6 — Human decision

Presented to the human with three findings (see below). Human accepted:
**"通过，按 *accept 归档"**. Budget headroom (Δ1) deferred: **"先不决定，Phase 3c 撞到再说"**.
Archive commit scope authorized by the human, with Alex's stated concern recorded below.

## Findings

**Δ1 — Lite core budget has 2 bytes of headroom (non-blocking, deferred by human).**
Pre-implementation baseline was 47,398 bytes against a 52,200 cap (~4,800 bytes of allowance);
repair-2 lands at 52,198, consuming 99.96%. AC8 passes. Forward risk: the next edit to either Lite
SKILL in Phases 3c–8 breaks AC8. Recorded as `gate4_delta` on the handoff. Human decision: defer
until Phase 3c actually hits it.

**Δ2 — Completion's historical body carries repair-1-era numbers (P2, documentation).**
`COMPLETION-*.md` `## AC results` states `mutation probes=9/9`, `Lite core 52,034`, and cites
`c851046` for AC12; `## Zero-touch hashes` lists the original-window hashes
(`478776…`/`92baae…`/`eaecc4…`/`48af79…`); `## Commit path list (40)` describes the initial
implementation commit. **Each is accurate as a repair-1 record**, and line 24 declares
"The body below preserves the original implementation and repair-1 historical record."
The authoritative repair-2 carrier `acceptance-verification-report.md` holds the correct current
values (10/10, 52,198, `c851046..80413f8`, repair-2 hashes) — Alex verified every one. The residual
risk is per-section: these headings carry no local "superseded" marker, so a future reader of the
archived record can mistake them for current values. Not blocking; recorded here so the archive
carries the correction.

**Δ3 — Layer 2 audit naming-registry gap (P2, out of scope).** See step4c. Follow-up.

## step7 — Knowledge Assessment (branch_3: `skip_knowledge_assessment: no`)

**A. Blake's claims verified.** Completion states knowledge was captured as a dated amendment in
`.tad/project-knowledge/patterns/gate-design.md`. Confirmed present and substantive:
`### Accepted Execution Mandate Is Lite's Permission Carrier…` (L204) plus
`#### Amendment — Human Blast Radius Is an Effect Boundary, Not a Technical Counter` (L229),
both with a filled `failure_mode` and real `Grounded in` carriers.

**B. Raw recompute.** Done — see step7.B table above. No mismatch.

**C. Alex's own discovery.** Yes. Written to
`.tad/project-knowledge/patterns/ac-verification.md`:
*"A Fixture Matrix Whose Rows Carry Their Own `expected_result` Is Self-Certifying — a Schema +
Digest Gate Proves Integrity, Not Correctness - 2026-08-10"* (L2 pattern). This generalizes the
AC7 false PASS found at Gate 4 and the shape of its repair, and prescribes the four-probe check
Alex used to confirm it. No `patterns/_index.md` change needed — the index is one line per file
and `ac-verification.md` is already listed.

## Outward actions

**None performed.** No push, tag, publish, sync, registry write, or registered-target write.
Phase 3c (live Lite-only release dogfood) remains the first phase that performs real outward
mutation and is unblocked by this acceptance.
