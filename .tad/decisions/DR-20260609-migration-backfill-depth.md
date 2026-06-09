# DR-20260609: Migration Manifest Backfill Depth

**Status**: Accepted
**Date**: 2026-06-09
**Epic**: EPIC-20260609-upgrade-lifecycle-system.md (Phase 1/6)
**Decided by**: Alex (via Socratic Inquiry) + Blake evidence gathering

## Context

TAD has 46 git tags from v1.0.0 to v2.27.0, yielding 45 adjacent version pairs.
Building manifests for all 45 pairs is impractical and unnecessary — early versions
had fundamentally different structures. This DR decides the backfill starting point:
from which version pair do we begin creating migration manifests?

## Evidence

- Source: git tag -l | sort -V (46 tags, see .tad/evidence/research/2026-06-09-migration-schema-evidence.md §1)
- Source: .tad/sync-registry.yaml (all 14 registered projects at v2.27.0 as of 2026-06-09)
- Source: .tad/project-knowledge/principles.md line 72 (tad.sh stuck at v2.19.1 due to hardcoded version-string list bug)
- Source: .tad/deprecation.yaml (earliest deprecation entry v2.3.0; apply_deprecations mechanism broken until v2.8.2)
- Source: git tag gap analysis (v1.4.1→v2.0.0 is a major structural break; no .tad/ directory in v1.x)

## Decision

**Backfill starting point: v2.19.0 → v2.19.1** (the oldest adjacent pair from which
migration manifests will be created).

### Rationale

1. **v1.x → v2.0 is a clean reinstall**: The v1.x structure is fundamentally different
   (no `.tad/` directory). File-level migration is meaningless; users must clean reinstall.
   Manifest for this transition: out of scope.

2. **v2.0 through v2.18 are pre-sync era**: Before v2.19.0, there was no systematic
   remote sync mechanism. Projects at these versions were never "upgraded in place" —
   they were manually reinstalled or left behind. Building manifests for these pairs
   has zero practical consumers.

3. **v2.19.1 is the known-furthest-back stuck version**: The hardcoded version-string
   bug in tad.sh caused TARGET_VERSION to be stuck at v2.19.1 for downstream projects.
   This means v2.19.1 is the oldest version a remote project could have been "frozen" at
   due to a TAD bug (not user choice). Any project frozen before v2.19.1 was frozen by
   user inaction, not TAD failure.

4. **14 registered projects are all current**: All known projects are at v2.27.0.
   The manifests are a safety net for future upgrades and unknown non-registered projects,
   not for immediate use.

### Backfill Scope

| Range | Pair Count | Status |
|-------|-----------|--------|
| v1.0.0 → v2.18.0 | ~25 pairs | OUT OF SCOPE (clean reinstall zone) |
| v2.19.0 → v2.27.0 | 13 pairs (1 delivered in Phase 1, 12 for Phase 5) | IN SCOPE |
| v2.27.0 → future | ongoing | Created per-release as part of publish SOP |

### Pre-v2.19 Upgrade Path

Users at versions before v2.19.0 are directed to perform a clean reinstall:
`tad.sh --yes` from a fresh source. The migration engine should detect
`from < v2.19.0` and emit: "Version too old for incremental migration. Please
perform a clean reinstall."

## Alternatives Considered

| Alternative | Pros | Cons | Why Not |
|-------------|------|------|---------|
| Backfill from v2.0.0 | Complete coverage | ~25 extra manifests with zero consumers; pre-sync versions have no upgrade path | No practical value |
| Backfill from v2.8.2 (apply_deprecations introduction) | Covers deprecation-aware era | Misses v2.19.1 stuck-version window | Insufficient — v2.19.1 is the evidence-based boundary |
| Backfill from v2.24.0 (first deny-list sync) | Minimal effort | Leaves v2.19-v2.23 unserviced | Too aggressive — v2.19.1 projects exist |
| **v2.19.0 (chosen)** | Evidence-based; covers stuck-version window | ~12 manifests to create | Best balance of coverage and effort |
