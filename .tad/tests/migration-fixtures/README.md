# Migration Engine Fixture Harness

14 E2E test cases for `migration-engine.sh`, plus 1 inline AC17 test.

## Usage

```bash
bash .tad/tests/migration-fixtures/run-fixtures.sh
```

Expected output: `ALL FIXTURES PASS (14/14)`

## Fixture List

| # | Name | Category | What It Tests |
|---|------|----------|---------------|
| F1 | normal-upgrade | Happy path | Delete + backup + verify assertions |
| F2 | idempotent-rerun | Idempotency | Second run = already-applied via oracle |
| F3 | user-modified-mixed | Detection | Modified=skip, unmodified=delete (mixed manifest) |
| F4 | detection-unavailable | Degradation | No git → skip all + contrast with git source |
| F5 | chain-upgrade+gap | Chain | Multi-manifest chain + gap = exit 2 |
| F6 | malicious-zero-touch ×3 | Security | (a) exact (b) case-variant (c) rename-into-zt |
| F7 | malicious-path ×4 | Security | (a) traversal (b) mid-symlink (c) leaf-symlink (d) colon |
| F8 | dry-run+merge | Dry-run | Zero writes + merge = manual-required |
| F9 | dir-delete dual-branch | Dir detection | Clean dir deleted, dir with user files preserved |
| F10 | delete-only-no-verify | Oracle guard | No verify section → must execute (no vacuous skip) |
| F11 | zt-authority-unavailable | Authority | derive-sync-set.sh missing → exit 2 fail-closed |
| F12 | rm-site-recheck | TOCTOU | Parent is symlink → guarded_remove rejects |
| F13 | mid-chain-malformed | Chain safety | Valid #1 + invalid #2 → exit 2, #1 also not executed |
| F14 | backup-collision | Backup safety | Pre-existing backup → refuse overwrite |

## Adding New Fixtures

1. Write a `test_fN()` function in `run-fixtures.sh`
2. Use `create_source`, `add_version`, `write_manifest`, `create_target` helpers
3. All fixtures run in `mktemp -d` sandboxes (auto-cleaned)
4. Assert via `diff -rq` / TSV grep / exit codes — never grep human-readable output
