# DR-20260609: User-Modified File Detection Method

**Status**: Accepted — AMENDED 2026-06-09 (see Amendment below; supersedes the original Decision section)
**Date**: 2026-06-09
**Epic**: EPIC-20260609-upgrade-lifecycle-system.md (Phase 1/6)
**Decided by**: Alex (via Socratic Inquiry) + Blake evidence gathering

## Context

When the migration engine deletes or renames a framework file, it must decide what
to do if the user has modified that file (added custom content, changed configurations).
Blindly deleting a user-modified file violates the "绝不误删" constraint. This DR
selects a detection method to identify user modifications before destructive operations.

## Candidates

### Option A: Release-Version Hash Registry

Maintain a registry of SHA-256 hashes for every framework file at every release version.
At migration time, compute the file's hash and compare against the registry entry for
the `from` version. Mismatch = user-modified.

### Option B: Git Tag Content Comparison

Use `git show v{from}:{path}` to retrieve the file's content at the `from` version tag,
then compare against the current file. Difference = user-modified.

### Option C: "Differs from Current Release" Simplification

Compare the current file against the `to` version's copy (the new version being installed).
If the current file differs from both the `from` and `to` versions' copies, it has been
user-modified.

### Option D: Skip Detection — Always Backup Before Delete

Instead of detecting modifications, always move files to a `.tad-backup/` directory before
deleting. User can recover manually. No detection logic needed.

## Comparison Matrix

| Dimension | Option A: Hash Registry | Option B: Git Tag Compare | Option C: Differs-from-Release | Option D: Always Backup |
|-----------|------------------------|--------------------------|-------------------------------|------------------------|
| **成本 (Cost)** | HIGH: maintain hash DB per version (~50 files × 12 versions = 600 entries) | LOW: `git show` is free, tags already exist | LOW: only needs the `to` version file (already available during install) | MINIMAL: just `mv` before `rm` |
| **精度 (Precision)** | EXACT: byte-identical hash match | EXACT: full content comparison | MODERATE: can't distinguish "user modified" from "modified by intermediate version" | N/A: no detection |
| **维护负担 (Maintenance)** | HIGH: hash DB must be generated per release, stored, versioned | LOW: tags are already maintained; no extra artifact | LOW: no extra artifact | MINIMAL: backup dir cleanup |
| **Offline support** | YES: hash DB shipped with framework | PARTIAL: requires git repo with tags (remote projects may lack packed-refs for old tags) | YES: only needs local files + incoming version | YES: no external dependency |
| **Edge cases** | Handles renamed-then-modified files if registry tracks by (version, path) | Fails if tag is missing or repo is shallow clone | False positive: file modified by a DIFFERENT version's upgrade (not user) | Over-preserves: every deleted file gets backed up even if unmodified |

## Decision

**Option D: Always Backup Before Delete** as the primary mechanism, with Option B
as an optional enhancement in Phase 3.

### Rationale

1. **Simplicity wins for v1**: The migration engine is a new system. Adding a hash
   registry or git-based detection in the first version adds complexity that delays
   the core value (declarative file cleanup). Option D provides 100% safety (no data
   loss) with zero detection logic.

2. **Backup is idempotent**: Moving to `.tad-backup/{version}/` before deleting is
   a reversible operation. Users can inspect the backup directory and recover any
   file they need. The backup directory is automatically excluded from sync (it's
   a transient artifact).

3. **Option B as Phase 3 enhancement**: When the engine matures, `git show` comparison
   can be added as an optimization — if the file matches the `from` version exactly,
   skip the backup and delete directly. This reduces backup directory clutter without
   sacrificing safety.

4. **Option A rejected for TAD's scale**: A hash registry makes sense for large
   package managers with thousands of files. TAD's framework has ~50 framework files;
   the overhead of maintaining a hash DB exceeds the benefit.

5. **Option C rejected for false-positive risk**: In a chain upgrade (A→B→C), Option C
   would flag files modified by the B→C step as "user-modified" — creating false alarms
   that erode trust in the migration engine.

### Implementation Contract (Phase 2)

```
Precondition: $path MUST have passed the Path Safety Pipeline (FR2) before reaching this point.

Before delete:
  1. mkdir -p "$(dirname ".tad-backup/{from}-to-{to}/$path")"
  2. cp -a "$path" ".tad-backup/{from}-to-{to}/$path"  # preserve metadata + directory structure
  3. Proceed with delete

Post-migration:
  Report: "Backed up {N} files to .tad-backup/{from}-to-{to}/"
  Note: backup directory is NOT auto-cleaned (user responsibility)
  Note: .tad-backup/ lives at repo root (not inside .tad/). Phase 3 should add it to
        derive-sync-set.sh TRANSIENT list to prevent accidental sync to other projects.
```

---

## Amendment 2026-06-09 — Human Override at Phase 2 Design (supersedes Decision above)

**Trigger**: Gate 4 acceptance of Phase 1 surfaced a conflict that the original DR missed:
the Epic decision record (Socratic round 2, 2026-06-09) states user-modified files →
**"跳过 + 报告（不删、不备份删）"** — in-place preservation. Option D (Always Backup
then delete) removes the file from its original location, which contradicts that
explicit human decision. Alex flagged the conflict at Phase 2 Socratic; human ruled.

**Amended Decision: Hybrid B + D with conservative degradation**

For each `delete`/`rename.from` path:
1. **Detect** via Option B (`git show v{from}:{path}` content comparison)
2. **Modified by user** (content differs) → **SKIP + REPORT** (in-place preservation,
   honors the original Epic decision)
3. **Unmodified** (content identical to `from` release) → **backup to
   `.tad-backup/{from}-to-{to}/` then delete** (Option D as second safety net)
4. **Detection unavailable** (no git repo / missing tag / shallow clone — common for
   remote tad.sh installs) → degrade to **SKIP + REPORT** for that path
   (fail-safe to the MOST conservative behavior: 宁漏删，绝不误删)

**Net effect**: a file is only ever deleted when it is PROVABLY identical to the
shipped release — and even then a backup is taken. Every other case leaves the
file in place and tells the user.

**Cost note**: remote tad.sh installs typically lack the framework git repo, so the
degradation path (skip-all + report) will be the common case there until Phase 3
ships a release-hash sidecar or equivalent. This is accepted: stale files + a report
beat any risk of deleting user work.

**Decided by**: Human (AskUserQuestion at Phase 2 design, 2026-06-09); Alex proposed the hybrid.
