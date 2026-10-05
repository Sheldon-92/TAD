# Independent Verification — f02-guarded-deletion (2026-08-17)

**Reviewer**: independent verifier (Layer 2, separate subagent — handoff §10.3 requires the
four sandbox scenarios be run by an independent agent; self-review is forbidden)
**Object**: `tad.sh` `apply_deprecations()` + `.tad/hooks/lib/migration-engine.sh`
**Baseline**: `cd70cf26`
**Method**: everything executed, nothing taken on the implementer's word

## Snapshot identity (verified by Blake after the fact)

The verifier pinned its work to its own `/tmp/f02-mine/snap2` copy. Blake compared that copy
against the frozen delivery byte-for-byte:

| | snap2 | delivered |
|---|---|---|
| `tad.sh` sha256 | `5a747e71…11d2` | `5a747e71…11d2` ✅ |
| `tad.sh` git blob | `a6ea84eb…` | `a6ea84eb…` ✅ |

`cmp` reports identical. (The `e91c53fc…` value quoted in the verifier's report is neither the
sha256 nor the local blob — an artifact of its own hashing step. The physical comparison above
is what establishes that its verdict applies to the delivered bytes.)

## Verdict timeline

| Round | Verdict | Findings |
|---|---|---|
| R1 | CONDITIONAL | four scenarios all PASS; **P1** refused-entry backup copy leaks into un-gitignored `.tad-backup/`; **P2** same-version rerun blocked by "backup already exists" |
| **R2** | ✅ **PASS** | P1 closed at the root; no P0, no residual P1; P2 disposition accepted |

## R1: four scenarios (independent runs)

| Scenario | AC | Result |
|---|---|---|
| 1 normal deprecated file | AC-3 | ✅ deleted=1, rc=0 |
| 2 symlinked dir → outside file | AC-4 | ✅ `REJECT: symlink component` → refused; outside file survived |
| 3 zero-touch subtree | AC-5 | ✅ `REJECT: ZERO_TOUCH` → refused; memory survived |
| 4 mixed manifest, REAL install, ERR trap armed | AC-6 | ✅ exit **0** · refusal visible · normal file deleted · count=1 · install ran to "TAD v2.42.0 Ready!" — **the P0 (one refusal destroying the install) does not occur** |

Also: AC-1b/1b2 (4 guard functions resolve to `migration-engine.sh` under `extdebug`,
space-safe via `cut -d' ' -f3-`), AC-N2c fixtures 22/22, engine diff = BASH_SOURCE guard only.

**Script audit**: no false-green defects found in Blake's harnesses; both carry execution
self-checks (`SCENARIO_INVALID` on crash / `Applying deprecations` reachability) that close the
two false-green modes Blake had hit earlier.

## Discrimination tests (proving the suite is not always-green)

| Perturbation | Expected | Result |
|---|---|---|
| `guarded_remove` → bare `rm -rf` shim | AC-4/AC-5 red | ✅ both red (outside file + memory deleted) |
| remove `load_zero_touch` block (empty `ZT_LIST`) | AC-5 red | ✅ red — silent fail-open regression is caught |
| baseline `cd70cf26` (bare `rm -rf`) | scenarios red | ✅ S2 deletes outside file, S3 deletes memory |
| authority unreadable | fail-closed | ✅ rc=0 + warn + nothing deleted |
| manifest contains `..` | refused pre-backup | ✅ refused, normal entries still deleted, no backup bloat |

## R2: fixes re-verified

1. **P1 backup-copy leak — closed at the root.** Reproduced the original `git add -n .` path:
   after a real install `.tad-backup/2.42.0-to-2.42.0/` holds only the *accepted* entry's backup;
   the refused `.tad/memory/note.md` copy is gone, original intact. `backup_preexisted` gate
   correct — pre-existing backups untouched.
2. **`./`-family closed.** `./` `.//` `.` `..` all rejected; no nested `.tad-backup`;
   same-batch normal entries still deleted. **Zero collateral: ran the predicate over the
   repo's current real manifest (92 entries — more than the 82 Blake measured) → 0 rejections**;
   `..foo` / `...` / `.foo` / `a/.hidden` / `.tad/.gitkeep` all pass.
3. **Discrimination preserved** after the fixes (rm-shim and empty-ZT_LIST still go red).

## Extra adversarial tests (beyond Blake's suite)

- **`.tad-backup` → outside-project symlink, attacking the `find -depth -delete` rollback**:
  variant ① outside path pre-exists → `backup_preexisted=1` blocks the rollback, outside data
  intact; variant ② outside path absent → find has nothing to delete, outside dir intact.
  Leaf symlink rollback deletes only the link, not the target. **No symlink-transiting
  rollback-deletion path found.**
- `apply_deprecations` contains no bare `rm` (only `find -depth -delete`) — AC-2/AC-2b semantics hold.
- Blake's `p1-fix-verification.sh` re-run independently: **12/12 PASS, 0 FAIL**.

## P2 disposition: accepted (conditional on documentation)

Same-version rerun + recreated file hits `do_backup`'s "backup already exists". Accepted because:
① normal upgrades change the version → different backup namespace → not triggered;
② the refusal is visible and the direction is safe (nothing deleted, existing backup preserved);
③ "never overwrite an existing backup" is the engine's core backup-safety semantic (SA-P1-1) —
carving out an exception for deprecations would weaken the engine contract.
**Condition: must be written into the completion report as a known limitation** — done
(§Notes item 2).

## Verdict: ✅ **PASS**