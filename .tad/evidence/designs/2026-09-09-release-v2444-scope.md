# Design pointer — Patch release v2.44.4 (knowledge-seam)

**Date:** 2026-09-09  
**Author:** Alex (Solution Lead), channel=cursor, model=cursor-grok-4.6-medium  
**Handoff:** `.tad/active/handoffs/HANDOFF-20260909-release-v2444.md`  
**Type:** publish-only patch (no downstream sync)

## Intent

Ship a public patch tag so installers pulling `v2.44.4` / `main` receive the already-accepted knowledge-seam work. Feature work is **already on `origin/main`**; this release is version identity + CHANGELOG + tag + GitHub Release only.

## Locked human decisions (this prompt)

| Decision | Lock |
|---|---|
| SemVer | PATCH `2.44.3` → `2.44.4` |
| Payload | knowledge-seam isolation (already committed) |
| brain-index | **not** synced (`TOP_DENY` / `TAD_TOP_DENY`) |
| Fresh install `project-knowledge/` | Option A: README-only + empty `patterns/` + `incidents/` |
| Quarantine | opt-in `tad.sh --quarantine-pk` only; never auto on `update` |
| Staging | strict pathspec; do not absorb dirty NEXT / PROJECT_CONTEXT noise / stale active twins |
| Publish | commit R → push `main` → annotated tag `v2.44.4` → tag push → `gh release` |
| Safety | no `--force`; no `--tags`; no `&&` / `;` across push/tag |

## Evidence already accepted (do not re-implement)

- Gate 4 PASS: `.tad/evidence/reviews/2026-09-09-gate4-acceptance-knowledge-seam-isolation.md`
- Archive twin: `.tad/archive/handoffs/GATE4-20260908-knowledge-seam-isolation.md`
- Handoff/Completion archives: `.tad/archive/handoffs/{HANDOFF,COMPLETION}-20260908-knowledge-seam-isolation.md`
- Design: `.tad/evidence/designs/2026-09-08-upstream-knowledge-seam-and-isolation-design.md`

## Git facts recorded at design time (local refs)

| Ref | SHA |
|---|---|
| `refs/heads/main` | `65963d6b9d5beac107d4565368f9786b292d8e3f` |
| `refs/remotes/origin/main` | `65963d6b9d5beac107d4565368f9786b292d8e3f` |
| Prior release commit (peeled `v2.44.3`) | `b9b28bf4667df8fc1aee8ce74cbfa5be304286ce` |
| Annotated tag object `v2.44.3` | `d6120fb26f0ca3e3d83dec541c7b871824bb1b5f` |

Stack `v2.44.3..HEAD` (reflog, after amend):

1. `e6e2126e` — `feat(TAD): knowledge-seam isolation + opt-in quarantine [Gate 3 PASS]`
2. `65963d6b` — `docs: record implementation commit hash in COMPLETION`

Blake must re-verify with `git ls-remote` immediately before push (design-time local refs are not a substitute for remote CAS).

## Out of scope

Feature edits, dirty-tree absorption, force-push, downstream `*sync`, re-opening knowledge-seam design locks.
