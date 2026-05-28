# Code Review: Pack Behavioral Examples Framework

**Reviewer**: code-reviewer (sub-agent)
**Handoff**: HANDOFF-20260527-pack-behavioral-examples
**Date**: 2026-05-27
**Scope**: install.sh modification, 2 fixture files, 1 template file

---

## Summary

The implementation adds an `examples/` directory convention for capability packs, modifies `install.sh` to copy example fixtures alongside references, and creates 2 video-creation dogfood fixtures plus a template. The install.sh modification is well-structured with proper edge-case handling. The fixture format is clear and grep-verifiable. One P1 issue found (regex/description mismatch in Fixture B). All files are within line-count budgets. No P0 issues.

---

## Findings

### P0 (Blocking): None

---

### P1 (Should Fix)

#### P1-1: Fixture B regex `music.+1[0-5]` does not cover the stated 10-20% range

**File**: `.tad/capability-packs/video-creation/examples/single-clip-narration.md`, line 28
**Also affects**: line 37 (Verification Command)

The description on line 27 states:

> voiceover volume dominance (100%) with background music reduced (10-20%)

But the grep pattern `music.+1[0-5]` only matches 10%, 11%, 12%, 13%, 14%, 15% -- it does NOT match 16%, 17%, 18%, 19%, or 20%. The character class `[0-5]` constrains the second digit to 0-5.

This matters because the source rule in `audio-design.md` (lines 42, 201) specifies "10-20% of voiceover level". If the AI agent correctly outputs "music at 20%" or "music at 18%", the fixture grep would fail to match, producing a false negative.

**Verified empirically**: tested `echo "music at 18%" | grep -oE 'music.+1[0-5]'` -- no match. Same for 16, 17, 19, 20.

**Fix**: Change the regex to cover the full 10-20 range:

```
# Option A: character class for 10-20
music.+1[0-9]|music.+20

# Option B: simpler, matches 10-20 (also matches 1-19 with prefix)
music.+[12][0-9]%

# Option C: broadest — any percentage after "music"
music.+[0-9]+%
```

Recommended: Option A -- precise match for the 10-20 range. Update both line 28 (grep pattern documentation) and line 37 (Verification Command).

**Severity justification**: P1 not P0 because the alternative markers in the same fixture (`narrative`, `voice.first`, `volume.+mix`) can still reach min_marker_count=3. But a marker that fails on valid output undermines fixture credibility and the "Volume Mix" rule listed in `tests_rules`.

---

### P2 (Nice to Have)

#### P2-1: Handoff spec section 4.2 still contains the known `grep -ocE` bug

**File**: `.tad/active/handoffs/HANDOFF-20260527-pack-behavioral-examples.md`, line 150

The handoff spec section 4.2 (fixture format reference) shows `grep -ocE` in the Verification Command template. This is the exact bug pattern documented in architecture.md ("AC Verification Command Bug: grep -ocE | sort -u | wc -l"). The `-c` flag causes `grep` to output a single count number per file instead of individual matches, making `sort -u | wc -l` always return 1 for single-file queries.

The actual fixture files and the template file correctly use `grep -oE` (without `-c`). So this is a documentation-only inconsistency -- no functional impact since Blake correctly implemented without `-c`. But if a future pack author copies from the handoff spec instead of the template, they would hit this bug.

**Fix**: No action needed on implementation files (they are correct). This is handoff-doc-only. Noted for Alex awareness.

#### P2-2: references/ loop lacks the `[[ -f ]] || continue` glob guard that examples/ loop has

**File**: `.tad/capability-packs/video-creation/install.sh`, lines 152-156

The new examples/ copy loop (lines 162-168) correctly uses `[[ -f "$ex_file" ]] || continue` to handle the case where the glob `*.md` matches no files (bash expands the literal pattern string). The existing references/ loop (lines 152-156) does NOT have this guard.

This is a pre-existing issue, not introduced by this handoff. In practice, a video-creation pack without any `.md` files in `references/` is unlikely. But for consistency and defensive coding, the same guard pattern should be applied.

**Fix** (out of scope for this handoff, but noted):
```bash
for ref_file in "${SCRIPT_DIR}/references/"*.md; do
    [[ -f "$ref_file" ]] || continue    # <-- add this line
    filename="$(basename "$ref_file")"
    ...
```

#### P2-3: Template file is exactly at the 40-line budget limit

**File**: `.tad/templates/pack-example-fixture.md` -- 40 lines

This is exactly at the handoff's stated budget of "<=40 lines". While technically within spec, any future addition (e.g., a "Negative Markers" section as deferred in P2-2 of expert review) would exceed the budget. Not blocking -- just noting the tight margin.

#### P2-4: Fixture `.` in grep patterns matches any character, not just separators

**File**: Both fixture files

Patterns like `view.specific`, `angle.match`, `camera.tree`, `voice.first` use `.` (matches any single character) as a separator match. This means `viewXspecific` or `voice3first` would also match.

In practice this is acceptable for fixture grep verification (false positives from random single-character matches are extremely unlikely in LLM output about video production). But for documentation clarity, consider noting that `.` is intentionally used as a flexible separator (underscore, hyphen, space all match) rather than a literal dot.

---

## Positive Observations

1. **install.sh examples/ block is well-guarded**: The `if [[ -d ... ]]` outer check + `[[ -f ]] || continue` inner guard + `found_examples` diagnostic flag is better defensive coding than the existing references/ block. This is the correct pattern for optional directory copying.

2. **Anti-Slop Check section is genuinely useful**: Each fixture explicitly lists which markers pass and fail the anti-slop test with clear reasoning. This prevents the "validation theater" problem identified in the YOLO audit.

3. **Structural marker annotation**: The `[structural]` tag on markers (Fixture A line 24, Fixture B line 25) addresses the product-expert P0 from Gate 2 review. These markers test output structure, not just vocabulary presence.

4. **Discriminative fixture pair**: Fixture A (all patterns trigger) + Fixture B (patterns 3/4 must NOT trigger) together test both positive activation and correct non-activation. This is a stronger signal than two positive-only fixtures.

5. **Consistent format across all files**: Frontmatter fields, section ordering, grep pattern documentation style, and verification command format are uniform across both fixtures and match the template.

---

## Verdict

| Severity | Count | Details |
|----------|-------|---------|
| P0       | 0     | --      |
| P1       | 1     | Regex range mismatch in Fixture B (10-15 vs stated 10-20) |
| P2       | 4     | Doc inconsistency, pre-existing guard gap, budget margin, flexible dot |

**Result**: CONDITIONAL PASS

**Condition**: Fix P1-1 (Fixture B regex to cover full 10-20% range) in both the grep pattern documentation (line 28) and the Verification Command (line 37), then propagate to the installed copy in `.claude/skills/video-creation/examples/single-clip-narration.md`.

After P1-1 fix: PASS (P0=0, P1=0).
