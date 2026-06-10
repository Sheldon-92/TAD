# Phase 6 Grounding — 回归与验收

## Scope
Final acceptance: fixture full run + 14-project real upgrade + gate拦截演练 + KA.

## Current State
- 22 fixtures exist (18 engine + 1 AC17 + 3 migration gate) — all pass
- 12 historical manifests + 1 existing = 13 total in .tad/migrations/
- migration-engine.sh: ~500 lines, delete/rename/merge/verify execution
- release-verify.sh: structural + freshness + migration modes
- tad.sh: integrated with call_migration_engine()
- sync-protocol.md: step3.b3 migration engine call

## What Phase 6 Must Verify (from Epic AC)
1. fixture suite全部 PASS
2. 14/14 注册项目升级后 diff -rq 双向验证 PASS，ZERO_TOUCH byte-identical
3. 旧 tag (v2.19.0) → current 链式升级 fixture PASS
4. 门禁演练：故意删文件不写manifest → 验证真实阻断
5. Gate 4 Knowledge Assessment

## Key Constraints
- 14-project real upgrade needs *sync (Alex command) — YOLO workflow CAN'T run *sync
- Alternative: write a verification script that Blake implements, then human runs *sync + script
- Gate拦截演练: can be done in a temp dir (create git state with unmanifested delete)
- Chain upgrade fixture: extend run-fixtures.sh with a v2.19.0→current chain test

## Implementation Approach
1. **Verification script**: `.tad/tests/upgrade-acceptance.sh` — runs after *sync, verifies:
   - ZERO_TOUCH dirs byte-identical (diff -rq on project-knowledge/, active/, archive/)
   - version.txt matches expected
   - No stale deprecated files remain
   - Migration report exists in .tad-backup/
2. **Chain fixture**: F-chain in run-fixtures.sh — v0.1.0→v0.3.0 with full manifest chain
3. **Gate拦截演练**: Script that creates temp git state, deletes file, verifies gate catches it
4. **Evidence collection**: Store all outputs in .tad/evidence/acceptance-tests/upgrade-lifecycle/

## What NOT to do
- ❌ Don't actually run *sync (that's human + Alex Terminal 1)
- ❌ Don't modify engine or gate logic (Phase 2-5 scope)
- ❌ Don't generate new manifests
