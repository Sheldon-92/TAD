# Expert Review: code-reviewer
## Handoff: HANDOFF-20260617-installer-audit-fixes.md

**Reviewer**: code-reviewer
**Date**: 2026-06-17
**Verdict**: CONDITIONAL PASS
**Sections Reviewed**: §2 (Bug Details & Fix Specifications), §3 (Implementation Order), §9 (Acceptance Criteria), §10 (not present -- notes inline), §11 (Decision Summary). Cross-referenced with: tad.sh (lines 50-68 arg parsing, 679-714 call_migration_engine, 887-917 detect_state, 922-1022 main, 1084-1136 install path, 1200-1223 upgrade path, 1260-1320 migrate path), bin/tad-install.mjs, package.json, CLAUDE.md, README.md, INSTALLATION_GUIDE.md, .tad/hooks/lib/migration-engine.sh (lines 717-776 execute_merge_entry), CHANGELOG.md, existing sync scripts, .claude/skills/alex/references/.

---

## Critical Issues (P0)

### P0-1: Marker name conflicts with established codebase convention -- will break downstream projects

**Location**: Bug 2 fix specification (line 87 of handoff), AC3

**Issue**: The handoff proposes using `<!-- TAD:FRAMEWORK-END -->` as the CLAUDE.md merge marker. However, the codebase already has an established, deployed marker convention using `<!-- TAD:PROJECT-CONTENT-BELOW -->`:

- `CHANGELOG.md` line 75 documents it as the merge execution marker
- `README.md` line 71 describes it in the v2.29.0 feature description
- `NEXT.md` line 43 lists 3 downstream projects that still need this exact marker added
- `.tad/evidence/releases/sync-v2.24.0.sh` line 221 uses it in production sync logic
- `.tad/evidence/releases/sync-v2.24.1.sh` line 25 uses it
- `.tad/evidence/releases/sync-v2.29.1.sh` lines 46/48 use it with `grep -q` and `awk` for actual merge
- `.tad/evidence/acceptance-tests/upgrade-lifecycle/README.md` lines 47/55 reference it

Downstream projects that already have `<!-- TAD:PROJECT-CONTENT-BELOW -->` installed will NOT be recognized by the new `merge_claude_md()` function because it greps for a different marker string. Those projects will fall through to the "No marker (legacy)" branch, get their CLAUDE.md backed up and overwritten -- exactly the data loss Bug 2 is supposed to prevent.

**Fix**: Replace `<!-- TAD:FRAMEWORK-END -->` with `<!-- TAD:PROJECT-CONTENT-BELOW -->` throughout the handoff. This is a string substitution in the marker definition, the `merge_claude_md()` function, AC3, and any documentation.

### P0-2: Handoff proposes new merge function while a battle-tested `execute_merge_entry()` already exists in migration-engine.sh

**Location**: Bug 2 fix specification (lines 92-118 of handoff)

**Issue**: `.tad/hooks/lib/migration-engine.sh` lines 717-776 already implements `execute_merge_entry()` with:
- `grep -F` for marker detection (fixed string, no regex injection risk)
- Idempotency checking (compares head content before writing, skips if already current)
- Proper handling of missing marker, missing source, missing target
- `mktemp` for atomic writes (not writing directly to the target)
- Dry-run support
- Proper 3-value exit codes (0=success, 1=error, 2=skip)
- Minimum marker length validation (rejects markers < 10 chars)

The proposed `merge_claude_md()` function:
- Uses `sed -n "/${marker}/,\$p"` which has BSD/GNU portability concerns (the `\$` in double quotes, the regex delimiter `/` if marker ever contains `/`)
- Has NO idempotency checking -- runs the full merge even if CLAUDE.md is already up to date
- Writes directly to CLAUDE.md with no atomic write -- a crash mid-write loses both old and new content
- Has no dry-run support
- Has no marker length validation

The migration engine is already called on upgrade (tad.sh line 1205) and migrate (line 1284) paths. CLAUDE.md merge could be added to the v2.31.0+ migration manifest as a `merge` entry. This would be zero new code in tad.sh.

This violates the project principle "Never Hand-Write What an Existing Tool Already Does" (principles.md, 2026-05-28).

**Fix**: Either (a) add a CLAUDE.md merge entry to the migration manifest for the relevant version transition, leveraging `execute_merge_entry()` automatically, or (b) if a standalone function is truly needed (e.g., for fresh-to-upgrade transitions not covered by the manifest chain), extract the merge logic from `execute_merge_entry()` rather than writing new, inferior code.

### P0-3: `--force` does not distinguish "same version" from "installed newer" -- enables silent downgrade

**Location**: Bug 3 fix specification (lines 150-161 of handoff)

**Issue**: `detect_state()` returns `"current"` in TWO cases (tad.sh lines 895-900):
1. `"$ver" = "$TARGET_VERSION"` -- same version (line 895-896)
2. `_tad_ver_cmp "$ver" "$TARGET_VERSION" == 1` -- installed is NEWER (line 899-900, comment: "never downgrade")

Both cases set `ACTION="none"`. The handoff's `--force` fix blindly converts `ACTION="none"` to `ACTION="upgrade"`. When the installed version is NEWER than target (e.g., user has v2.32.0, runs an older tad.sh that targets v2.31.0), `--force` will downgrade the installation. The `ACTION="none"` at line 900 exists specifically to prevent this ("never downgrade" comment), but `--force` bypasses it without checking.

**Fix**: In the `--force` block, add version comparison to refuse or explicitly warn about downgrade:
```bash
if [ "$FORCE" = "1" ]; then
    if [ -f ".tad/version.txt" ] && [ "$(_tad_ver_cmp "$(cat .tad/version.txt)" "$TARGET_VERSION")" = "1" ]; then
        log_warn "Installed version is NEWER than target. Use upgrade to v${TARGET_VERSION}? This is a DOWNGRADE."
        # Either refuse or require explicit --downgrade flag
    else
        log_info "Force reinstall requested (same version)"
        ACTION="upgrade"
    fi
fi
```

---

## Recommendations (P1)

### P1-1: Bug 4 scope is incomplete -- curl commands in skill references are not listed

**Location**: Bug 4 fix specification, AC9

**Issue**: The handoff lists "README.md, INSTALLATION_GUIDE.md, tad-help skill" for curl --yes fixes. Actual grep reveals additional locations:
- `.claude/skills/alex/references/sync-protocol.md` line 32: `curl -sSL ... | bash` (no --yes)
- `.claude/skills/alex/references/publish-protocol.md` line 31: `curl -sSL ... | bash` (no --yes)
- `INSTALLATION_GUIDE.md` already has partial coverage: line 22 has `--yes`, but lines 10, 17, 65 do NOT
- `README.md` lines 79, 101, 130 all lack `--yes`

Blake needs the complete list to satisfy AC9 ("all documents").

**Fix**: Add the alex/references/ files to the explicit scope. Note that INSTALLATION_GUIDE.md needs targeted fixes (not blanket), since line 22 already demonstrates the correct pattern.

### P1-2: Missing AC for marker name consistency with existing codebase convention

**Location**: §9 (Acceptance Criteria)

**Issue**: Even after fixing P0-1, there is no AC that verifies the chosen marker is consistent with existing usage across the codebase. A new AC should confirm the marker string matches what sync scripts, README, CHANGELOG, and downstream projects already use.

**Fix**: Add AC13: `grep -rF '<!-- TAD:PROJECT-CONTENT-BELOW -->' CLAUDE.md tad.sh | wc -l >= 2` (marker present in both the source CLAUDE.md and the tad.sh merge function).

### P1-3: `call_migration_engine` silently skips on same-version `--force` reinstall

**Location**: tad.sh lines 684-687, interaction with Bug 3 fix

**Issue**: When `--force` triggers a reinstall of the same version, `call_migration_engine` checks `old_ver == new_ver` and returns 0 (skip). This means `--force` reinstall will NOT run any migration logic (including any CLAUDE.md merge if P0-2 is resolved via manifest). `copy_framework_files` still runs, so framework files are refreshed -- but the merge behavior depends on the approach chosen for P0-2.

**Fix**: Document this as expected behavior in the handoff, OR modify `call_migration_engine` to accept a `--force` flag that bypasses the version equality check.

### P1-4: Bug 2 code uses `printf '\n%s\n'` which adds extra blank lines

**Location**: Bug 2 code snippet, line 109 of handoff

**Issue**: `printf '\n%s\n' "$project_content" >> CLAUDE.md` prepends a newline before the project content. If the source CLAUDE.md already ends with a newline (which it will, since the marker line ends with newline), this creates a double blank line before the project content. Minor cosmetic issue but accumulates on repeated upgrades (each upgrade adds one more blank line).

**Fix**: Use `printf '%s\n' "$project_content"` (without leading `\n`), or better yet, use the migration engine's approach which handles whitespace correctly.

---

## Suggestions (P2)

### P2-1: README.md version verification string is stale

**Location**: README.md line 114

**Issue**: `# Should show: 2.30.0` but version.txt is already `2.31.0`. Since Bug 4 already touches README.md for curl --yes fixes, this could be updated in the same pass. Not in the handoff scope but a trivial fix while in the file.

### P2-2: `parseArgs` switch in tad-install.mjs -- `default` falls through due to eslint-disable comment

**Location**: bin/tad-install.mjs line 125

**Issue**: The existing code has `default: // eslint-disable-line no-fallthrough` which is misleading -- it does NOT actually fall through (it calls `process.exit(1)`). The comment is about ESLint, not about actual fallthrough. When adding `case '--force': force = true; break;`, ensure it is placed BEFORE the `default` case. The handoff's code snippet is correct but does not specify the exact insertion point in the switch statement.

### P2-3: Consider adding `--force` to tad-install.mjs `--help` output

**Location**: bin/tad-install.mjs lines 118-123

**Issue**: The handoff specifies adding `--force` to tad.sh's `--help` output (Bug 3, item 2) but does not mention updating tad-install.mjs's `--help` output (lines 118-123), which currently does not mention `--force`. Blake may miss this.

---

## Positive Confirmations

- Bug 1 (package.json version drift) is a clear 1-line fix, correctly identified and trivially verifiable
- Bug 5 (package.json files missing .agents/) is correct -- confirmed `.agents/` exists in codebase but not in `files` array
- Implementation order (Bug 1 -> Bug 5 -> Bug 4 -> Bug 3 -> Bug 2) correctly sequences from simplest to most complex
- AC12 (end-to-end verification: fresh install -> add content -> upgrade -> verify preservation) is well-designed
- Decision D2 (legacy backup + warn) is the right call for files without markers
- The handoff correctly identifies all 3 locations of bare `cp` in tad.sh (lines 1113, 1209, 1287)

---

## Overall Assessment: CONDITIONAL PASS

The handoff correctly identifies 5 real bugs and proposes a sound overall approach. However, the CLAUDE.md merge implementation (Bug 2 -- the most complex and highest-risk fix) has two critical issues:

1. **P0-1**: The proposed marker name `<!-- TAD:FRAMEWORK-END -->` conflicts with the established `<!-- TAD:PROJECT-CONTENT-BELOW -->` used throughout the codebase and in downstream projects. Using the wrong marker will cause the exact data loss this fix is supposed to prevent.

2. **P0-2**: A battle-tested merge engine already exists (`execute_merge_entry()` in migration-engine.sh) with atomic writes, idempotency, and proper error handling. The proposed hand-written `merge_claude_md()` is inferior on every dimension.

3. **P0-3**: The `--force` flag does not guard against downgrade -- it blindly converts "installed newer" into upgrade, overriding the existing "never downgrade" safety.

With P0s fixed and P1s addressed, this handoff provides Blake with clear, actionable fix specifications for all 5 bugs.
