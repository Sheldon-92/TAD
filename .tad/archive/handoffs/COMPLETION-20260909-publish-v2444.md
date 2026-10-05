# COMPLETION-20260909-publish-v2444 — Publish v2.44.4

**Task ID**: `TASK-20260909-PUBLISH-V2444` | **Owner**: Blake | **Date**: 2026-09-09
**Handoff**: `.tad/active/handoffs/HANDOFF-20260909-release-v2444.md` (READY_FOR_BLAKE, Gate2 dual PASS P0=0)
**Mode**: publish-only (stops after GitHub Release verification; NO sync)

## Verdict: COMPLETE — v2.44.4 live

| Artifact | Value |
|---|---|
| Commit R | `83e2ff03f48b3510482192797fc7f06e634f425d` (parent `65963d6b9d5beac107d4565368f9786b292d8e3f`) |
| Remote main | `83e2ff03f48b3510482192797fc7f06e634f425d` == R ✅ |
| Tag object `v2.44.4` | `4a9d655d58315b7c52479100ea87ac00b4380cb1` → peels to R ✅ |
| Release URL | `https://github.com/Sheldon-92/TAD/releases/tag/v2.44.4` (isDraft=false) ✅ |

## Preflight (§3.0) — all PASS before P1

- `git remote get-url origin` = `https://github.com/Sheldon-92/TAD.git` ✅
- `git rev-parse HEAD` = `65963d6b9d5beac107d4565368f9786b292d8e3f` ✅
- `git ls-remote --heads origin refs/heads/main` = same SHA ✅
- `git ls-remote --tags origin refs/tags/v2.44.4` = empty ✅
- `git status --short`: dirty `NEXT.md`, `PROJECT_CONTEXT.md` (+ledger hunk), `docs/pm/now.md`, stale twins — all treated out-of-R; only `PROJECT_CONTEXT.md` reconstructed.

## Bump (§3.1–3.3)

- 12 identity files bumped 2.44.3 → 2.44.4 (tad.sh L26 only; dynamic TARGET_VERSION untouched — verified `grep -n TARGET_VERSION`).
- 3 mirrors via explicit `cp` (no parity --fix, no rsync).
- `PROJECT_CONTEXT.md`: sidecar `/tmp/tad-v2444-PROJECT_CONTEXT.md` saved pre-reconstruction; rebuilt from `HEAD` + 2 version-token lines; post-R sidecar extras restored to working tree **unstaged**.
- CHANGELOG `[2.44.4] - 2026-09-09` prepended under `[Unreleased]`; names all three Gate 4 locks (brain-index unsynced, Option A README-only, `--quarantine-pk` opt-in); no overclaim.

## Gates (§3.4) — exits recorded

| Gate | Exit | Disposition |
|---|---|---|
| parity | 0 | PASS |
| derive-sync-set --report | 0 | PASS (brain-index.md in TOP_DENY top-level note, as expected) |
| version (2.44.4/2.44.3) | 1 | **Advisory** (patch): 3 stale = `.tad/brain-index.md:100` (generated local index, TOP_DENY, historical) + `NEXT.md:9,20` (dirty planning file, out-of-R). Classified identity vs historical per release-sync.md 2026-09-04; no history falsified. |
| version-sweep (2.44.4) | 0 | Layer 1 12/12 PASS; Layer 2 advisory only |
| migration | 0 | PASS (no D/R entries) |
| tad.sh --verify-denylist | 0 | PASS (17 entries) |

## Commit R (§3.5)

- Staged via single explicit 16-pathspec `git add --` (no -A, no dirs).
- `git show --name-only --pretty=format: HEAD` = exactly the 16 pathspecs ✅
- `git rev-parse HEAD^` = `65963d6b9d5beac107d4565368f9786b292d8e3f` ✅
- Intra-file guard (Gate2-R2 P1-1): `git diff 65963d6b HEAD -- PROJECT_CONTEXT.md` = only 2 version-token lines ✅

## Publish (§3.6) — four separate invocations, no chaining, no force

- **P1** `git push origin <R>:refs/heads/main` → `65963d6b..83e2ff03` ✅
- **P2** `git tag -a v2.44.4 <R> -m ...` ✅
- **P3** `git push origin refs/tags/v2.44.4:refs/tags/v2.44.4` → `[new tag]` ✅
- **P4** `gh release create v2.44.4 --title ... --notes ...` → release URL ✅

## Post-verify (§3.7)

- `git ls-remote --heads origin refs/heads/main` == R ✅
- `git ls-remote --tags origin refs/tags/v2.44.4 refs/tags/v2.44.4^{}` = annotated `4a9d655d` + peeled R ✅
- `gh release view v2.44.4 --json tagName,isDraft,url` = v2.44.4 / false / URL ✅

## AC Table (§9.1)

| AC | Result |
|---|---|
| AC1 parity exit 0 | PASS |
| AC2 version-sweep Layer 1 exit 0 | PASS |
| AC3 CHANGELOG heading + 3 locks | PASS |
| AC4 16 paths + parent + intra-file purity | PASS |
| AC5 remote main == R | PASS |
| AC6 tag peels to R | PASS |
| AC7 release live | PASS |
| AC8 this file | PASS |

## Friction Status

| Friction | Status | Evidence |
|---|---|---|
| Dirty identity file (PROJECT_CONTEXT.md ledger hunk) | Resolved via §3.5 reconstruction + sidecar restore (unstaged) | `git diff 65963d6b HEAD -- PROJECT_CONTEXT.md` version-only |
| `version` gate exit 1 | Advisory, classified, no falsification | §Gates table above |
| gh auth / network / sandbox push approval | READY (all P1–P4 succeeded) | push/tag/release outputs |
| Layer 2 expert review | NOT_APPLICABLE_WITH_REASON: mechanical version-bump publish; handoff §7 manifest declares `blake_reviews: []`, Gate 3 = verifier exits + AC table | required_evidence manifest |

## Notes

- R contains version + CHANGELOG only; no feature code (knowledge-seam already on main as `e6e2126e` + `65963d6b`).
- No sync performed (mandate publish-only).
- Working tree still holds unrelated dirty/untracked files (NEXT, pm notes, stale twins, PROJECT_CONTEXT ledger hunk) — all unstaged, none pushed.
- Gate2 carriers: `.tad/evidence/reviews/2026-09-09-gate2-review-v2444-spec.md` (PASS P0=0), `.tad/evidence/reviews/2026-09-09-gate2-review-v2444-scope.md` (PASS P0=0); P1-1/P1-2/P1-3 controls applied (§3.5 detect + sidecar + AC4 intra-file; P2-1 mixed-reset documented in mandate recovery, not needed).
