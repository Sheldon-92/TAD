---
gate: 2
reviewer: Reviewer 2 — Safety & Blast Radius (independent)
handoff: .tad/active/handoffs/HANDOFF-20260909-release-v2444.md
design: .tad/evidence/designs/2026-09-09-release-v2444-scope.md
date: 2026-09-09
channel: cursor
model: cursor-grok-4.6
route: unknown
scope: dirty-tree isolation, HEAD reconstruction, no-force, scoped refspecs, no &&, recovery, origin identity, feature-Gate4 vs release mandate, blast radius
counts: {P0: 0, P1: 3, P2: 2}
verdict: PASS
---

Model: harness=cursor | model=cursor-grok-4.6 | route=unknown

# Gate 2 Review — Reviewer 2 (Safety & Blast Radius) — HANDOFF-20260909-release-v2444

Independent read-only review. No implementation, no push/tag/force, no scope broadening.

## Scope of this review

Mandate Consequence / Blast / Recovery / Forbidden; §3.0; §3.5 reconstruction; §3.6 P1–P4; §8.4 Friction; §10. Cross-checked against design pointer and `publish-ops.md` §§4–5. Local git identity files checked as required.

## Independent git facts (this review)

| Check | Observed |
|---|---|
| `remote.origin.url` | `https://github.com/Sheldon-92/TAD.git` — matches mandate Target / origin allow-list |
| `.git/refs/heads/main` | `65963d6b9d5beac107d4565368f9786b292d8e3f` |
| `.git/refs/remotes/origin/main` | `65963d6b9d5beac107d4565368f9786b292d8e3f` |

Design-time binding in the handoff and design pointer matches these files. Blake must still CAS with `git ls-remote` immediately before P1; local tracking is not remote proof.

## Method

1. Full read of `HANDOFF-20260909-release-v2444.md`.
2. Full read of `.tad/evidence/designs/2026-09-09-release-v2444-scope.md`.
3. Read `publish-ops.md` §§4–5 (no force, no `&&`, ls-remote recovery).
4. Read `.git/config` `remote.origin.url` and the two `main` ref files named above.
5. Did **not** implement, mutate remotes, or read unrelated source trees.

---

## 1. Critical Issues (P0)

**None.**

Controls for public blast (one commit R, one annotated tag, one GitHub Release, no sync) are written into the Execution Mandate and the P1–P4 command shapes. Dirty-tree absorption is forbidden with an explicit reconstruction rule and a pre-push reset-if-wrong-tree guard. Origin identity, remote-ahead STOP, and tag-collision STOP are present. Feature-task Gate 4 “do not push” is explicitly not a ban on this release.

---

## 2. Recommendations (P1)

### P1-1 Intra-file dirty absorption is not caught by AC4 filename-only evidence

**Risk:** `NEXT.md`, `docs/pm/now.md`, and stale active twins are outside the 16 pathspecs and will not enter R if Blake follows `git add -- <paths>`. The load-bearing failure mode is **`PROJECT_CONTEXT.md` (and any other dirty identity file)**: extra ledger hunks live *inside* a pathspec that *must* be staged.

§3.5 reconstruction and Forbidden (“Staging a dirty identity file that contains non-version hunks”) are the right controls. Recovery/`git show --stat` and AC4 (`git show --name-only` equals 16 paths; parent `65963d6b`) only prove **which files** are in R, not that those files contain **version/CHANGELOG edits only**. A mixed `PROJECT_CONTEXT.md` still yields 16 names and would be a successful public push of working-tree noise.

§8.4 says absorbing noise → AC4 FAIL, but AC4’s Verification Method as written would not fail.

**Recommendation (do not broaden scope; Blake procedure only):** Before P1, inspect `git show R -- PROJECT_CONTEXT.md` (and any other reconstructed identity file) and confirm the diff vs `65963d6b` is the mandated version-line edits only. If not, reset R locally and do not push. Treat this as part of the existing pre-push guard, not a new file in R.

### P1-2 Reconstruction write-back can destroy dirty identity hunks locally

**Risk:** AC Conflict Matrix claims byte-preservation of the dirty working tree. §3.5 step 3 writes the reconstructed (HEAD + version-only) bytes **to the same path** before `git add -- <path>`. That protects R but **overwrites** uncommitted ledger/noise in `PROJECT_CONTEXT.md` unless those hunks are copied aside first.

This is local operator data loss, not a remote blast. It is still a safety hole relative to the mandate’s own preservation claim.

**Recommendation:** For each dirty identity path, copy the current working-tree file to a non-repo sidecar (or `git stash push -- <path>` after saving extras) **before** reconstructing from `HEAD`. Restore extras after R exists. Do not stash the whole tree in a way that could later `stash pop` into the index of R.

### P1-3 Detect-then-reconstruct is implied, not commanded

§3.5 applies reconstruction to “any of the 16 files whose working tree differs from HEAD by more than the mandated version/CHANGELOG edits,” then shows a single 16-path `git add --` block. A copy-paste of that add without a prior `git diff HEAD -- <path>` check is the most likely way to skip reconstruction.

§3.0.5 says treat unexpected dirty files as out of R; it does not give the detect command for identity files that *are* in R.

**Recommendation:** Immediately before the 16-path `git add`, run `git diff HEAD --` on those 16 paths (or `git status --short` filtered to them). Reconstruct every path that is dirty; never `git add` a mixed identity file.

---

## 3. Suggestions (P2)

### P2-1 Specify reset flavor if R is wrong

Recovery: “If `git show --stat R` lists any file outside the 16 pathspecs: reset R locally before any push.” Prefer `git reset --soft HEAD~1` (or mixed) so unrelated dirty files that were never staged stay in the working tree. Avoid `git reset --hard` unless the reconstructed identity files were snapshotted (P1-2).

### P2-2 Local `.git/config` `hooksPath` is a foreign absolute path

`hooksPath = /Users/sheldonzhao/云同步/TAD/.git/hooks` is not a remote-force hazard. On this host it may mean commit/push hooks do not run. Mandate + `publish-ops` already require explicit detect-only gates and ls-remote CAS; do not treat missing hooks as permission to skip those. Out of R; no config edit in this publish.

---

## Findings vs focus areas

| Focus | Verdict | Evidence |
|---|---|---|
| Dirty tree not absorbed (`NEXT.md`, `PROJECT_CONTEXT` extra hunks, stale active twins, `docs/pm/now.md`) | Control present | Blast radius; Forbidden; §5 OUT; §3.5 16 pathspecs exclude NEXT/pm/twins |
| HEAD reconstruction before `git add` of dirty identity files | Control present; verification weak | §3.5 steps 1–4; P1-1/P1-2/P1-3 |
| No `--force`, `--tags`, unscoped refspec | PASS | Forbidden; P1 ` <commit_R>:refs/heads/main `; P3 `refs/tags/v2.44.4:refs/tags/v2.44.4`; matches `publish-ops` §4 |
| No `&&` across push/tag | PASS | §3.6 “four separate commands”; Forbidden; §10; `publish-ops` §4 “combined shell chain” |
| Remote-ahead / tag collision STOP | PASS | Recovery policy; §3.0.3–3.0.4; §3.6 re-read ls-remote before P1; `publish-ops` §5 classify, never blind retry |
| Origin identity guard | PASS | §3.0.1 + checklist; config URL is `https://github.com/Sheldon-92/TAD.git` |
| Feature Gate 4 “do not push” ≠ block this release | PASS | §10: that boundary was TASK-20260908-KNOWLEDGE-SEAM-ISOLATION; this mandate authorizes tag `v2.44.4`. Design pointer: feature already on `origin/main` |
| Blast radius: one commit R, one tag, gh release, no sync | PASS | Consequence + Blast; Outcome steps 4–7; design Publish/Safety/Out of scope; `publish-ops` §6 sync only if mandate names it — this mandate names **none** |

### P1–P4 vs `publish-ops` §§4–5

Handoff P1–P3 match publish-ops steps 1–3 (exact commit to `refs/heads/main`, annotated tag on that commit, tag-only refspec). P4 `gh release create` is in-mandate and not chained with push/tag. Recovery uses the same `ls-remote --heads` / `ls-remote --tags` + peel pattern; completed vs not-started vs unknown classification is stated. No `--force`.

### Tip / origin (this review)

Local `main` and `origin/main` files both bind `65963d6b9d5beac107d4565368f9786b292d8e3f`. Origin URL is Sheldon-92/TAD. Blake still STOP if live `ls-remote` disagrees or if `refs/tags/v2.44.4` is non-empty.

---

## 4. Overall Assessment

**PASS**

P0 = 0. The publish transaction is bounded to one identity+CHANGELOG commit R on `65963d6b`, one annotated tag `v2.44.4`, one public GitHub Release, and no sync. Force, unscoped tags, chained push/tag, origin mismatch, remote-ahead, and tag collision are STOP/Forbidden. Dirty-tree isolation is designed; remaining gaps are verification and local preservation of extra hunks (P1), not missing remote-safety controls.

Gate 2 READY_FOR_BLAKE still requires the paired Spec reviewer carrier also `PASS` with P0=0, then a human status change and **当 Blake**. This reviewer does not start Blake.
