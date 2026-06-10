# Phase 5 Grounding — *publish 门禁 + 历史 Migration 回溯生成

## Current State

### release-verify.sh (.tad/hooks/lib/)
- Existing modes: `structural` (source-vs-target byte identity) and `freshness` (runtime ledger staleness)
- Exit codes: 0=pass, 1=violation, 2=usage/wiring error
- Called by: *publish protocol, *sync protocol (step3.d2)
- New mode needed: `migration` — detect file deletions/renames between tags without corresponding manifest

### *publish protocol (.claude/skills/alex/references/publish-protocol.md)
- Currently calls release-verify.sh structural
- Phase 5 adds: also call migration mode before push

### DR-1 (backfill depth): .tad/decisions/DR-20260609-migration-backfill-depth.md
- Backfill scope: v2.19.0 → v2.27.0 (13 tag pairs in scope)
- Pre-v2.19: clean reinstall (no manifest needed)
- One manifest already exists: 2.26.0-to-2.27.0.yaml

### Git tags available
- v2.19.0 through v2.27.0 (use `git tag -l 'v*' | sort -V`)
- Each manifest covers {from}-to-{to} with explicit delete/rename entries

### Key Constraints
1. Migration mode checks: `git diff --name-status v{prev}..v{current} -- .tad/ .claude/` for D (deleted) and R (renamed) files
2. For each D/R: check if a manifest exists covering that version pair with that path
3. If files deleted/renamed but no manifest → WARN (or BLOCK depending on gate mode)
4. Historical manifests: mechanically generated from `git diff --name-status` between adjacent tags
5. Manual review needed: some deletions are intentional (deprecation.yaml handled), some are renames
6. Generation script outputs draft manifests for human review, not final production files
7. Scope to `git ls-files` (not raw FS walk — principles: 88% noise lesson)
8. Prefer false-positive (over-report possible rename) over false-negative (miss a deletion)

### What to implement
1. **release-verify.sh migration mode**: New `migration` argument, checks if pending release has unmanifested file removals
2. **migration-draft.sh**: Script to generate draft manifests from tag diffs (helper for future releases)
3. **Historical manifests**: Generate for v2.19.0→v2.19.1, v2.19.1→v2.20.0, ..., v2.25.0→v2.26.0 (v2.26→v2.27 already exists)
4. **publish-protocol.md update**: Add migration gate call
5. **Fixture**: Test the migration gate (construct "deleted file without manifest" → verify gate catches it)

### What NOT to do
- ❌ Don't implement the actual blocking behavior yet (Phase 6 does the "real block" activation)
- ❌ Don't modify migration-engine.sh
- ❌ Don't run historical manifests against real projects (Phase 6)
- ❌ Don't modify tad.sh
