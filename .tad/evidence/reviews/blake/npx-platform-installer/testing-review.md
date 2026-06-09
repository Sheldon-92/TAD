# Testing Review: npx-platform-installer

**Date:** 2026-06-07
**Reviewer:** Blake (test-runner equivalent — project has no test framework)

## Context

This project (`package.json` → `"test": "echo \"No tests yet\""`) has no automated test suite. Testing was performed via:
1. Shell syntax validation (`bash -n`) for all 27 modified .sh files
2. Node.js syntax validation (`node --check`) for bin/tad-install.mjs
3. 13-AC automated verification battery using mktemp target directories
4. Manual integration tests for edge cases (prefix matching, deprecation ordering)

## Test Results

### Syntax Validation
- tad.sh: PASS
- bin/tad-install.mjs: PASS
- 25 pack install.sh files: ALL PASS

### Functional Verification (AC Battery)
- 13/13 ACs: ALL PASS
- Each AC tested against actual `copy_framework_files` execution
- Platform scoping (claude-code vs codex) verified with real file-system diffs

### Edge Cases Tested
- `is_denied` prefix boundary: `.claude/skills/alex` denies `alex` but NOT `alex-utils` ✅
- Deprecation ordering: AGENTS.md survives deprecation + re-copy ✅
- Pack selection: `--packs web-frontend,web-backend` includes selected, excludes others ✅
- Empty platform deny (claude-code): no exclusions, full copy ✅

## Coverage Assessment

| Component | Coverage | Notes |
|-----------|----------|-------|
| tad.sh arg parsing | High | All flags tested (--platform, --packs, --yes, unknown) |
| Platform YAML parsing | High | Both platforms parsed, empty lists handled |
| is_denied() | High | Exact match, prefix with boundary, non-match |
| is_pack_skill() | Medium | grep -F fixed string matching verified |
| copy_framework_files | High | Full codex + claude-code installs verified |
| verify_install_complete | High | Pass case + forced-failure case |
| bin/tad-install.mjs | Medium | Validation tested; interactive mode structural |

## Verdict

**PASS** — All critical paths verified. No test framework available for unit-level coverage percentage, but functional coverage through AC battery is comprehensive.
