# Phase 5 Architecture Review — Publish Gate + Historical Migration

**Reviewer**: Backend Architecture (release-verify integration, manifest generation, schema compliance)
**Date**: 2026-06-10
**Handoff**: HANDOFF-20260610-publish-gate-phase5.md
**Verdict**: PASS with 0 P0, 3 P1, 3 P2

---

## Review Scope

1. Does the migration mode integrate cleanly with existing release-verify.sh?
2. Is the historical manifest generation approach sound (git diff between tags)?
3. Does the draft script output valid manifest YAML per schema v1?

---

## Findings

### P0 (Blocking) — None

No blocking architectural issues found. The design correctly reuses existing patterns
(ZERO_TOUCH reading, exit code contract, git-scoped queries) and extends them coherently.

---

### P1 (Must Fix Before Implementation)

#### P1-1: `git describe --tags --abbrev=0 HEAD^` is Fragile for Prev-Tag Detection

**Section**: FR1.2, Algorithm step 1

**Problem**: `git describe --tags --abbrev=0 HEAD^` finds the most recent tag reachable
from `HEAD^`, which is NOT necessarily the immediate previous release tag. If HEAD has
multiple parents (merge commit) or if there are lightweight non-release tags (e.g.,
test tags, pre-release tags), this command may return an unexpected tag. Additionally,
on a fresh release where HEAD IS the tag, `HEAD^` would correctly give the previous
tag — but if there are intermediate commits between tags (the normal case during
development), `HEAD^` only walks back ONE commit, which may still resolve to the SAME
tag as HEAD (since `git describe --abbrev=0` finds the nearest ancestor tag).

**Evidence**: In the actual TAD repo right now:
```
git describe --tags --abbrev=0 HEAD^  → v2.27.0
git describe --tags --abbrev=0 HEAD   → v2.27.0
```
Both resolve to v2.27.0 because HEAD and HEAD^ are both descendants of v2.27.0.
The command would return the SAME version as the one being released, making
`prev_ver == exp_ver`, and the manifest filename would be `2.27.0-to-2.27.0.yaml`
— nonsensical.

**Fix**: Use `git tag -l 'v*' | sort -V` and find the tag immediately before the
expected version. Or better: compute `prev_tag` as the last tag before the CURRENT
version from version.txt. Algorithm:
```bash
EXPECTED_VER="$(head -1 "$REPO/.tad/version.txt" | tr -d '[:space:]')"
PREV_TAG="$(git -C "$REPO" tag -l 'v*' | sort -V | grep -B1 "^v${EXPECTED_VER}$" | head -1)"
```
If `PREV_TAG` equals `v${EXPECTED_VER}` (no previous found), exit 0 gracefully.

**Impact**: Without this fix, the migration mode will always report "no previous tag"
or compare against the wrong version during normal development (where HEAD has commits
after the last tag).

---

#### P1-2: grep -F Path Matching Can Produce False Negatives on Prefix Collisions

**Section**: 4.2.1 algorithm step 7, "YAML checking without yq"

**Problem**: The handoff proposes `grep -F "$path" "$manifest_file"` to check if a
deleted path is "covered" by the manifest. This has a subtle false-NEGATIVE risk:
if the manifest contains path `.tad/codex/codex-tad-alex.sh` and you grep for
`.tad/codex/codex-tad-alex.sh`, it matches. But the handoff says grep -F is a
"smoke alarm" that errs toward false-negative (covered when not really). The ACTUAL
dangerous case is a path like `.tad/codex/codex-tad-alex.sh.bak` — grepping for
`.tad/codex/codex-tad-alex.sh` in the manifest would MATCH even though the manifest
entry is for a different file. This is a false NEGATIVE (the grep "covers" a path
that isn't actually in the delete list).

More critically: the grep matches ANY occurrence of the path string in the YAML,
including in `verify:` sections or `reason:` strings that quote the path. A file
deleted in version N whose path appears only in a `verify: absent` check for an
earlier manifest entry would pass the grep but isn't actually covered by a `delete:`
entry.

**Mitigation**: Use `grep -F "path: \"$path\"" "$manifest_file"` which matches the
YAML field format, not just the bare path string. This is still approximate but reduces
false negatives significantly. The schema mandates quoted paths, so this pattern is
reliable. Alternatively, grep for the path within lines that start with whitespace
followed by `path:` or `- path:`:
```bash
grep -F "$path" "$manifest_file" | grep -qE '^\s*-?\s*path:'
```

**Impact**: Without scoping the grep, the gate could PASS (report "covered") when a
deletion is actually not manifested — the exact false-negative the gate exists to prevent.

---

#### P1-3: Manifest Count Discrepancy — Handoff Says 12 but Actual Pairs are 12 (11 to generate)

**Section**: Phase 1 Implementation Hints, counting section

**Problem**: The handoff has a confusing self-correction in the "Implementation hints"
section that ultimately arrives at "Generate 11 new manifests" — which is correct.
However, AC3 says "12 manifest files exist (11 new + 1 existing)" = 12 total, and
FR3.1 says "Generate 12 draft manifests." This is inconsistent: FR3.1 says generate 12,
but the implementation hint says generate 11 (since 2.26.0-to-2.27.0 already exists).

There are 13 tags (v2.19.0 through v2.27.0) = 12 adjacent pairs. 1 manifest exists
(2.26.0-to-2.27.0.yaml). Therefore 11 need generation. AC3 correctly expects 12 total
files. FR3.1 is wrong to say "generate 12."

**Fix**: FR3.1 should say "Generate 11 draft manifests" not 12. Blake should follow
AC3 (12 total files = 11 new + 1 existing) as the authoritative number. The
implementation hint's self-correction paragraph is unnecessarily confusing and should
be read as: "generate 11."

**Impact**: Low risk of actual harm (Blake will hit the "refuse to overwrite" guard on
2.26.0-to-2.27.0.yaml if attempted), but the confused FR could waste time or cause
gate failure if someone counts "12 generated" as the acceptance criterion.

---

### P2 (Should Fix / Improvement)

#### P2-1: Historical Manifests for ZERO_TOUCH-Only Pairs are Architecturally Correct but Unnecessary Work

**Section**: FR3.3, FR3.4

**Evidence from live verification**:
- v2.22.0->v2.22.1: 2 D entries, BOTH in `.tad/active/` (ZERO_TOUCH) → filtered to zero
- v2.22.1->v2.23.0: 1 R entry, BOTH paths in ZERO_TOUCH dirs → filtered to zero
- v2.19.0->v2.19.1, v2.19.1->v2.20.0, v2.20.0->v2.21.0, v2.21.0->v2.22.0,
  v2.23.0->v2.23.1, v2.23.1->v2.24.0, v2.24.0->v2.24.1, v2.24.1->v2.25.0:
  ALL have 0 D/R entries in framework paths.

Only v2.25.0->v2.26.0 has actual non-ZERO_TOUCH deletions (14 files in .tad/codex/
and .tad/hooks/lib/).

**Assessment**: The empty manifests serve as "chain completeness attestation" (proving
the pair was audited), which is architecturally sound. No change needed. But the review
notes that 10 of 11 manifests will be empty-section no-ops, so Blake should batch these
quickly rather than spending review time on them.

---

#### P2-2: Secondary Rename Detection Heuristic is Weak for Flat Basename Matches

**Section**: FR1.6, Phase 2 Implementation hints

**Problem**: The secondary rename detection matches D files against A files by basename
only. In large diffs (v2.25.0->v2.26.0 has many A entries), common basenames like
`SKILL.md` or `README.md` would produce many false-positive "POSSIBLE RENAME" flags.
The handoff acknowledges "prefer false-positive" which is correct, but the signal-to-noise
could be very low.

**Suggestion**: Consider adding a same-directory heuristic: flag as possible rename only
if the D and A files share the same parent directory path OR the same basename with
different parent. This reduces noise while maintaining the false-positive bias.

---

#### P2-3: publish-protocol.md step3d Placement Should Be Explicitly After step3c

**Section**: FR4.1

**Assessment**: The handoff correctly says "insert between step3c and step4" and shows
the architecture diagram. However, the existing publish-protocol.md structure has step1,
step2, step3, step3c, step4, step5 — no step3a/step3b. The naming convention `step3d`
implies there are 3a and 3b. This is cosmetically inconsistent but functionally fine.
Consider naming it `step3m` (for migration) to be more descriptive, but this is purely
aesthetic.

---

## Integration Assessment

### Does the gate integrate cleanly with existing release-verify.sh?

**YES**, with the P1-1 caveat on prev-tag detection. The proposed design follows
the exact same patterns as the existing `version` mode:
- Same ZERO_TOUCH reading pattern (lines 203-207 of version mode)
- Same exit code contract (0/1/2)
- Same `git -C "$REPO"` scoping
- Same LC_ALL=C discipline
- Same NFR4 (no external deps)

The case-arm addition is clean and non-invasive to existing modes.

### Is the historical manifest generation approach sound?

**YES**. `git diff --name-status -M <from>..<to>` scoped to framework paths is the
correct data source. Live verification confirms:
- All 13 tags exist and are reachable
- The framework path scoping (`.tad/ .claude/ .codex/ .agents/ CLAUDE.md AGENTS.md tad.sh`)
  matches the schema v1 Step 3 Assert-Prefix allow-list exactly
- ZERO_TOUCH filtering correctly eliminates v2.22.0-v2.22.1 and v2.22.1-v2.23.0 entries
- The only substantive manifest will be v2.25.0-to-v2.26.0 (14 codex deletions + 1 hooks/lib deletion)

### Does the draft script output valid manifest YAML per schema v1?

**YES**, based on the template shown in the handoff:
- `schema_version: 1` (integer, correct)
- `from`/`to` are quoted 3-segment semver (correct)
- `generated_by: "draft-script"` (matches NFR1e values)
- `delete` section uses list-of-maps with `path`, `type`, `reason` (correct per schema)
- `verify` section uses `type: "absent"` pattern (correct)
- Empty sections use `[]` (correct per schema's empty section equivalence rule)
- No `merge` entries in draft (correct — merges are human decisions)

---

## Summary

The Phase 5 design is architecturally sound and integrates cleanly with the existing
release-verify.sh infrastructure. The three P1 findings are implementation-level fixes
(prev-tag detection algorithm, grep scoping for manifest cross-reference, FR count
inconsistency) that do not require architectural redesign. The approach of generating
historical manifests from git diff between tags is validated against live data.

| Priority | Count | Items |
|----------|-------|-------|
| P0       | 0     | —     |
| P1       | 3     | prev-tag detection fragile, grep -F false negatives, FR3.1 count wrong |
| P2       | 3     | empty manifests are fine, rename heuristic weak, step naming cosmetic |
