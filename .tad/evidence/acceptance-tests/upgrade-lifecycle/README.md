# Upgrade Lifecycle Acceptance Evidence

**Date**: 2026-06-10
**TAD Version**: 2.27.0
**Epic**: EPIC-20260609-upgrade-lifecycle-system (Phase 6/6)
**Engine Version**: 2.29.0

## Evidence Files

| File | Description |
|------|-------------|
| fixture-run-output.txt | Output of run-fixtures.sh (22 E2E fixtures) |
| gate-exercise-output.txt | Output of gate-exercise.sh (migration gate interception proof) |
| chain-dry-run-output.txt | Chain dry-run v2.19.0 to v2.27.0 (12 manifests resolved) |
| README.md | This file (evidence index + recommendation) |

## Results Summary

- **Fixture harness**: 22/22 PASS (18 engine + 1 AC17 + 3 migration gate)
- **Gate exercise**: PASS (exit 1 on unmanifested delete, output contains "UNMANIFESTED DELETE")
- **Chain dry-run**: PASS (exit 0, resolves 12 manifests from v2.19.0 through v2.27.0)

## Gate Warn-to-Hard-Block Recommendation

**Current state**: TAD_RELEASE_GATE=warn downgrades migration gate (release-verify.sh
migration mode exit 1) to advisory warning during *publish.

**Recommendation**: Flip to hard-block.

**Evidence supporting the flip**:
1. Gate exercise proves real interception (exit 1 on unmanifested delete)
2. 22/22 engine fixtures pass (including 3 migration gate fixtures MG1-MG3)
3. 12 historical manifests cover v2.19.0 through v2.27.0 with no gaps
4. MG2 proves ZERO_TOUCH exclusion works (no false positives on user dirs)

**Remaining risk**: False positives on real *publish with non-framework file
changes. Mitigation: the gate scopes to framework paths only (.tad/, .claude/,
.codex/, .agents/, root files) and excludes ZERO_TOUCH dirs.

**Recommended trigger**: After the 14-project real *sync confirms the acceptance
script passes on all projects, flip TAD_RELEASE_GATE from warn to hard-block
(or remove the warn override entirely, since hard-block is the default for
non-patch releases per the gate rule contract in release-verify.sh header).

## Merge-Strategy Projects (Human Post-Epic Step)

Three registered projects need the `<!-- TAD:PROJECT-CONTENT-BELOW -->` marker
added to their CLAUDE.md before the tad-head-marker merge-strategy can work:

1. **my-openclaw-agents** - CLAUDE.md has no marker; merge will skip_and_report
2. **toy** - CLAUDE.md has no marker; merge will skip_and_report
3. **内存管理** (memory-management) - CLAUDE.md has no marker; merge will skip_and_report

**Action required**: After completing the 14-project *sync, manually add the marker
line `<!-- TAD:PROJECT-CONTENT-BELOW -->` at the appropriate boundary in each
project's CLAUDE.md (between TAD-managed head content and project-specific content),
then re-run *sync for the merge to apply.

This is a one-time manual step. Future *sync runs will automatically update the
TAD-managed head while preserving project content below the marker.

## Note on *sync Scope

The 14-project *sync itself is NOT part of this phase. This phase provides:
- `upgrade-acceptance.sh` — the verification SCRIPT for post-sync validation
- `gate-exercise.sh` — proof that the gate can block

The human triggers *sync separately and uses upgrade-acceptance.sh to verify each project.
