# Phase 3 Grounding — 双调用方接入（tad.sh + *sync）

## Current State (Alex Read at 2026-06-10)

### tad.sh (1310 lines)
- **Upgrade flow**: detect_state → backup_existing → download source → copy_framework_files → apply_deprecations → verify_install_complete → validate_generated_configs
- **apply_deprecations** (L676-737): Reads .tad/deprecation.yaml, deletes files for versions ≤ current. Uses simple line parser. Per DR-3: frozen for ≤v2.26.0, engine handles v2.27.0+
- **version_le** (L740-745): `sort -V` based, already used by apply_deprecations. Engine has its own copy (same semantics)
- **L721 comment bug**: Says "lexicographic is fine for semver" but actually uses sort -V (via version_le) — carry-forward from Phase 2
- **detect_state** (L823+): Returns fresh/current/v2.0/v1.8/v1.6/v1.4/old based on version.txt
- **copy_framework_files** (L386-556): Deny-list derived dirs + top-level files, platform-aware skills, deprecation cleanup, verify_install_complete
- **main flow** (L850+): Handles fresh/upgrade/reinstall paths
- **--yes flag**: Already exists for non-interactive mode (L51)
- **derive_framework_dirs / derive_framework_top_files**: Deny-list derivation already embedded (L201-232)
- **TAD_DENY_LIST** (L193): Combined zero-touch + transient. Does NOT include `.tad-backup/` (exists at repo root, not under `.tad/`)

### migration-engine.sh (~450 lines, .tad/hooks/lib/)
- CLI: `bash migration-engine.sh --from <ver> --to <ver> --target <dir> --source <dir> [--dry-run]`
- Reads manifests from `$source/.tad/migrations/{from}-to-{to}.yaml`
- Chain resolution: scans migrations/ dir, builds version chain via sort -V
- Exit codes: 0=success, 1=execution failure, 2=refuse (manifest invalid/chain gap/etc)
- Creates `.tad-backup/{from}-to-{to}/` under target with backed-up files
- TSV report: `$target/.tad-backup/{from}-to-{to}/MIGRATION-REPORT.tsv`

### sync-protocol.md (Alex reference)
- step3.b: Copy framework files (mirrors tad.sh copy_framework_files)
- step3.c: Deprecation cleanup (reads deprecation.yaml)
- step3.d: Verification (version.txt + CLAUDE.md check)
- step3.d2: release-verify.sh structural gate
- Currently no migration engine call

### Key Constraints
1. tad.sh runs via `curl | bash` on FRESH machines — migration-engine.sh NOT available at that point (it's IN the tarball). Engine can only run AFTER copy_framework_files extracts it.
2. *sync runs from the TAD source repo — engine IS available locally
3. `.tad-backup/` at project root — outside `.tad/*/` derive-sync-set scope. *sync must explicitly skip it (add to TRANSIENT or handle in copy_framework_files)
4. Both callers must use the SAME engine — zero dual-implementation
5. Engine needs `--source` (TAD repo with git tags for detection) and `--target` (project being upgraded)
6. Old version for `--from`: read from target's `.tad/version.txt` BEFORE copy overwrites it
7. New version for `--to`: read from source's `.tad/version.txt`

### Integration Points

**tad.sh integration sequence**:
```
1. detect_state → get old_version from .tad/version.txt
2. backup_existing
3. download source to tmp
4. copy_framework_files (now engine.sh is available at .tad/hooks/lib/)
5. ⭐ NEW: call migration-engine.sh --from $old_version --to $new_version --target . --source $tmp_src
   - Must capture old_version BEFORE step 4 (copy overwrites version.txt)
   - Engine available AFTER step 4 (extracted from source)
   - On exit 2 (manifest invalid/chain gap): suggest clean reinstall (non-fatal for tad.sh — the copy already happened)
   - On exit 0/already-applied: continue
   - On exit 1: warn but continue (fail-fast already stopped mid-way; backup exists for recovery)
6. apply_deprecations (still runs for ≤v2.26.0 entries)
7. verify_install_complete
```

**sync integration sequence** (per project):
```
1. Read target project's .tad/version.txt → old_version
2. Copy framework files (existing step3.b)
3. ⭐ NEW: call migration-engine.sh --from $old_version --to $current_version --target $project_path --source $TAD_SOURCE
   - Same exit code handling as tad.sh
4. Deprecation cleanup (existing step3.c)
5. Verification (existing step3.d/d2)
```

### Phase 3 carry-forwards
- `.tad-backup/` exclusion: Need to add to derive-sync-set.sh TRANSIENT list (affects both tad.sh inline copy and the lib) — OR handle in sync-protocol.md explicitly
- tad.sh:721 comment fix: "lexicographic" → "sort -V"

### Existing manifests
- `.tad/migrations/2.26.0-to-2.27.0.yaml` (3 delete + 4 verify) — the only manifest currently
- Future manifests will be generated in Phase 5

### Non-interactive mode
- tad.sh already has `--yes`/`AUTO_YES` for non-TTY
- migration-engine.sh has no interactive prompts (fully automatic)
- No new interactive prompts needed for integration

### What NOT to do (Phase 3 scope)
- ❌ Don't modify migration-engine.sh logic (only if interface gaps found)
- ❌ Don't generate historical manifests (Phase 5)
- ❌ Don't implement merge execution (Phase 4)
- ❌ Don't do real project upgrades (Phase 6)
