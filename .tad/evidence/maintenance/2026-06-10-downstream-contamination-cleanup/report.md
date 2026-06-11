# Downstream Contamination Cleanup — 2026-06-10

## Problem
A pre-deny-list sync (circa 2026-03, before the 2026-06-01 self-deriving-release-sync Epic
made `archive/`, `evidence/`, `active/`, `project-knowledge/` zero-touch) copied the TAD
source repo's own `.tad/archive/` and `.tad/evidence/` into all 14 registered downstream
projects. Each project carried an identical stale snapshot: 533 archive + 1,304 evidence
files (~16.4 MB), dated 2026-01-26 → 2026-03-23. This inflated disk (~230 MB total) and
contaminated audits (downstream "TAD usage" numbers reflected the source repo's history,
not the project's own).

## Method (Verify-Before-Delete)
1. **Read-only audit** (`/tmp/tad-contamination-audit.sh`): for every file under each
   project's `.tad/archive/` and `.tad/evidence/`, flag CONTAMINATED only if the same
   relative path exists in the TAD source AND content is byte-identical (`cmp -s`).
   Project-own files (different content or no source counterpart) untouched.
2. **Safety exclusions**: 406 zero-byte files excluded (empty-file identity proves nothing).
3. **Git check**: contaminated files mostly NOT git-tracked downstream (overlap 5–81 per
   project); tracked ones will show as deletions in downstream `git status`, committable
   at leisure.
4. **Quarantine move (not delete)**: moved to `~/tad-contamination-quarantine/{project}/`
   preserving relative paths. Empty dirs pruned; canonical `archive/handoffs` and
   `evidence/traces` recreated.

## Result
- Moved: **25,312 files (290 MB on disk), 1,808 per project × 14, 0 errors**
- Post-audit: remaining IDENTICAL = exactly the 29 zero-byte exclusions per project, 0 MB
- Project-own records verified unchanged (e.g. menu-snap 238 archive + 581 evidence own
  files before and after; toy 109 + 287; Next Guest 44 + 76)

## Per-project own-record counts (true TAD usage, post-cleanup)
| Project | archive own | evidence own |
|---|---|---|
| menu-snap | 238 | 581 |
| toy | 109 | 287 |
| my-openclaw-agents | 122 | 320 |
| Next Guest | 44 | 76 |
| 买卖 | 10 | 98 |
| 下载md插件 | 8 | 41 |
| Colin声音项目 | 31 | 18 |
| 合规ai | 0 | 30 |
| Sober Creator | 8 | 10 |
| OpenClaw Hack | 10 | 8 |
| Monica-website | 1 | 5 |
| 内存管理 | 1 | 1 |
| ArtForge | 0 | 1 |
| 运动打卡小助手 | 0 | 1 |

## Follow-ups
- [ ] Human: spot-check quarantine, then `rm -rf ~/tad-contamination-quarantine` to reclaim 290 MB
- [ ] Downstream repos with tracked deletions (menu-snap 81, 合规ai 64, toy 18, Next Guest 5):
      commit the deletions on next visit
- Recurrence prevention already in place: deny-list sync (2026-06-01) marks archive/evidence
  zero-touch; this cleanup removed only the pre-fix residue.

## Manifests
`manifests/{project}__{archive|evidence}.txt.gz` — full file lists (newline-delimited),
28 manifests covering all moved files.
