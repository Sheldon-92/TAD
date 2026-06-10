# Phase 4 Grounding — Merge 能力 + Marker 标准化

## Current State (Alex Read at 2026-06-10)

### migration-engine.sh merge handling (current)
- Lines 291, 355, 391: Parser recognizes merge section entries (path, strategy, marker, on_missing_marker)
- Line ~391+: Validates merge paths through the safety pipeline
- **Current execution**: merge entries output `merge manual-required <path>` and do NOT execute (Phase 2 design)
- Fixture F8 tests this: merge entry → TSV shows `manual-required` + file untouched

### Schema v1 merge specification (.tad/evidence/designs/migration-manifest-schema-v1.md L159-193)
- Fields: path (required), strategy (required), marker (required), on_missing_marker (required)
- Only valid strategy: `"tad-head-marker"`
- Only valid on_missing_marker: `"skip_and_report"`
- Marker: `<!-- TAD:PROJECT-CONTENT-BELOW -->`
- Shape is FROZEN — Phase 4 implements execution but MUST NOT change field semantics

### Existing marker usage
- sync-protocol.md L86: Uses `<!-- TAD:PROJECT-CONTENT-BELOW -->` for CLAUDE.md merge during *sync
- The marker convention already exists in the *sync protocol (strategy: everything ABOVE marker = TAD head, everything BELOW = user content)

### Example manifest entry (2.26.0-to-2.27.0.yaml has no merge entries)
Would look like:
```yaml
merge:
  - path: "CLAUDE.md"
    strategy: "tad-head-marker"
    marker: "<!-- TAD:PROJECT-CONTENT-BELOW -->"
    on_missing_marker: "skip_and_report"
```

### 3 Legacy projects needing marker
From NEXT.md: my-openclaw-agents / toy / 内存管理 — these have CLAUDE.md without the TAD marker, so *sync's merge strategy skips them with a warning.

### Key Constraints
1. Engine merge execution must be ATOMIC: read target → split at marker → replace head → write back
2. If marker NOT found → skip_and_report (don't overwrite user content!)
3. Merge needs the SOURCE version of the file (from $source path) to get the new "head" content
4. Merge executes AFTER delete and rename (FR6 ordering: rename → delete → merge → verify)
5. Backup before merge (same as delete: backup to .tad-backup/{from}-to-{to}/{path})
6. Dry-run: output "would-merge" but don't write
7. Idempotent: if head content already matches source → no-op (report `already-current`)
8. TSV status for merge: `done` / `skipped-no-marker` / `already-current` / `manual-required` (fallback for unknown strategy)
9. The 3 legacy project fixes require adding the marker to their CLAUDE.md files — this is a *sync operation, NOT an engine operation

### What to implement
1. **migration-engine.sh**: Replace `manual-required` output with actual merge execution for strategy=`tad-head-marker`
2. **Marker documentation**: Write a brief guide section in the schema doc or a standalone .tad/guides/ file
3. **Fixture**: Add merge execution fixture (F16 or extend F8)
4. **Legacy fix**: Add marker to 3 projects' CLAUDE.md (via *sync or manual — document the approach)

### What NOT to do
- ❌ Don't change merge schema fields
- ❌ Don't implement strategies other than tad-head-marker
- ❌ Don't change the parser (it already accepts merge entries correctly)
- ❌ Don't modify other projects' files from this repo (describe how to fix them)
