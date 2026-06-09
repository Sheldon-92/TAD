# DR-20260609: deprecation.yaml Disposition — Relationship to Migration Manifest

**Status**: Accepted
**Date**: 2026-06-09
**Epic**: EPIC-20260609-upgrade-lifecycle-system.md (Phase 1/6)
**Decided by**: Alex (via Socratic Inquiry) + Blake evidence gathering

## Context

TAD has two mechanisms that delete files during upgrades:

1. **`deprecation.yaml`** (existing, since v2.3.0): A YAML registry of files to delete
   per version. Consumed by `apply_deprecations()` in tad.sh (L676-737).

2. **Migration manifest** (new, this Epic): A per-version-pair YAML manifest declaring
   delete, rename, merge, and verify operations.

Both mechanisms handle "remove files that no longer belong in the framework." This DR
decides their relationship: absorb, supersede, or coexist.

## Current apply_deprecations Analysis

**Call site**: tad.sh:474 — runs during upgrade, AFTER core framework file copy,
BEFORE platform-specific root file copy (ordering documented at tad.sh:476-479).

**Version comparator**: Uses `version_le()` (tad.sh:740-745) which calls `sort -V`.
Note: tad.sh:721 comment says "lexicographic is fine for semver with fixed digits"
which is misleading — the actual implementation uses `sort -V` (correct). This comment
should be corrected in Phase 3 when tad.sh is modified to integrate the migration engine.

**Path safety**: `rm -rf -- "$target"` (tad.sh:726) takes the YAML value with:
- `--` end-of-options protection (prevents leading-dash injection)
- NO prefix validation (could delete outside `.tad/`)
- NO symlink check (rm through symlink escapes repo)
- NO realpath containment check
- NO ZERO_TOUCH directory protection

**Scope**: 6 version entries (v2.3.0 through v2.26.0), ~50 file paths total.

**Failure history**: v2.8.1 entry was a no-op because tad.sh didn't process
deprecation.yaml until v2.8.2, requiring the v2.8.2 entry to re-list the same
files (documented in deprecation.yaml notes).

## Decision: **Absorb** (吸收)

The migration manifest **absorbs** deprecation.yaml's responsibility. All future
file deletion declarations go into migration manifests exclusively. deprecation.yaml
is frozen at its current state (v2.26.0 last entry) and will not receive new entries.

### Rationale

1. **Single authority for destructive operations**: Having two mechanisms that both
   delete files creates ambiguity about which is authoritative. "Which file do I check
   to know what gets deleted in v2.28.0?" should have exactly one answer.

2. **Path safety upgrade**: deprecation.yaml's `apply_deprecations` has NO path
   validation — `rm -rf -- "$target"` directly uses the YAML value (tad.sh:724-726).
   The migration manifest schema includes a five-step path safety pipeline (FR2).
   Absorbing deprecation.yaml into the manifest system automatically upgrades all
   future deletions to use the safer pipeline.

3. **Richer operations**: deprecation.yaml only supports deletion. The migration
   manifest supports delete, rename, merge, and verify — a strict superset.
   Maintaining both means rename/merge/verify go in manifests while delete goes
   in... both? That's confusing.

4. **Verifiability**: deprecation.yaml has no verify section. The manifest's verify
   section serves as both a post-operation check and an idempotency oracle.
   Absorbing deletion into manifests gains automatic verification.

### Execution Order Contract

When tad.sh integrates the migration engine (Phase 3):

```
Current order (preserved):
  1. Copy framework files (core)
  2. apply_deprecations()     ← FROZEN: only processes ≤ v2.26.0 entries
  3. Copy root files (platform-specific)
  4. [NEW] Run migration engine  ← processes manifest for current upgrade pair

Key constraint: apply_deprecations runs BEFORE migration engine.
This means v2.26.0 and earlier deprecations are handled by the legacy code,
and v2.27.0+ operations are handled by the new engine.
There is NO overlap period — the cutover is at v2.27.0.
```

### Comparator Consistency

Both `apply_deprecations` (via `version_le` → `sort -V`) and the migration engine's
chain resolver MUST use `sort -V` for version comparison. They already agree on this
(the migration schema FR4 specifies `sort -V`), preventing version ordering
discrepancies.

Phase 3 note: when touching tad.sh's `apply_deprecations` vicinity, correct the
misleading comment at L721 ("lexicographic is fine for semver with fixed digits" →
actual implementation uses `sort -V`).

### deprecation.yaml Freeze

- **Last entry**: v2.26.0 (cross-platform unification cleanup, 2026-06-08)
- **New entries**: FORBIDDEN — all future file deletions go into migration manifests
- **File disposition**: deprecation.yaml remains in the repo (not deleted) because
  `apply_deprecations` still needs to process its entries for projects upgrading from
  pre-v2.27.0 versions. It becomes a read-only historical artifact.
- **Future cleanup (Phase 6)**: Once the minimum supported version exceeds v2.26.0
  (all projects past the last deprecation entry), deprecation.yaml and
  `apply_deprecations()` can be removed entirely.

## Alternatives Considered

| Alternative | Pros | Cons | Why Not |
|-------------|------|------|---------|
| **Absorb (chosen)** | Single authority; path safety upgrade; richer operations | Requires Phase 3 integration of engine into tad.sh | Best long-term architecture |
| Supersede (delete deprecation.yaml now) | Clean break | Breaks projects upgrading from pre-v2.27.0 (apply_deprecations would have no file to read) | Unsafe — existing consumers depend on it |
| Coexist (both active) | No migration needed | Two deletion authorities = ambiguity; deprecation.yaml remains unsafe; doubles maintenance | Violates "single source of truth" principle |
