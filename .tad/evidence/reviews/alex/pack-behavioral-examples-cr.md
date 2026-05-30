# Code Review: HANDOFF-20260527-pack-behavioral-examples

**Reviewer:** Expert Code Reviewer (Alex-side pre-handoff review)
**Date:** 2026-05-27
**Artifact:** `.tad/active/handoffs/HANDOFF-20260527-pack-behavioral-examples.md`
**Verdict:** CONDITIONAL PASS (1 P0, 2 P1, 3 P2)

---

## P0 (Blocking) -- Must Fix Before Handoff Ships

### P0-1: Step 3 install.sh snippet has a glob edge case under zsh invocation

**Location:** Handoff section 7, Step 3 (lines 208-217)

**Issue:** The proposed snippet uses:
```bash
for ex_file in "${SCRIPT_DIR}/examples/"*.md; do
```

While the script's shebang is `#!/usr/bin/env bash` (where this pattern is safe -- unmatched globs expand to the literal string and the `[[ -f "$ex_file" ]] || continue` guard catches it), there is a **different edge case that IS a real problem**: the `if [[ -d "${SCRIPT_DIR}/examples" ]]` guard passes when the directory exists but contains ZERO `.md` files (e.g., contains only `.yaml` or `.txt` files, or is entirely empty). In bash, the glob expands to the literal `*.md`, the `-f` guard skips it, and the loop silently produces no output. This is functionally correct but **confusing** -- the user sees the `examples` directory detected but no files copied, with no diagnostic message.

More importantly, the existing `references/` copy block (line 152) does NOT have the `[[ -f ]] || continue` guard. If Blake copies the proposed snippet's pattern but doesn't notice the asymmetry, a future reviewer may question why `examples/` has the guard but `references/` doesn't.

**Fix:** Add a diagnostic message when the directory exists but no `.md` files are found:

```bash
# Copy all examples (behavioral eval fixtures)
if [[ -d "${SCRIPT_DIR}/examples" ]]; then
  mkdir -p "${TARGET_DIR}/examples"
  local found_examples=false
  for ex_file in "${SCRIPT_DIR}/examples/"*.md; do
    [[ -f "$ex_file" ]] || continue
    found_examples=true
    filename="$(basename "$ex_file")"
    cp "$ex_file" "${TARGET_DIR}/examples/${filename}"
    echo "  examples/${filename}"
  done
  if ! $found_examples; then
    echo "  (examples/ directory exists but contains no .md fixtures)"
  fi
fi
```

**Severity justification:** Promoting to P0 because this is an install.sh modification touching 13+ pack installations' shared pattern. The diagnostic gap means Blake will have a confusing debug session if the fixture file isn't named `.md` or is accidentally placed wrong. Per architecture knowledge "AC Verification Drift Pattern": Alex must dry-run proposed code changes.

**Amended assessment after bash verification:** The functional behavior is correct (bash glob + `-f` guard works). Downgrading the *crash risk* to zero but keeping the *diagnostic gap* at P0 because install.sh is shared infrastructure and silent failure on misconfigured `examples/` directories will confuse future pack authors.

---

## P1 (Should Fix)

### P1-1: Step 4 is redundant with Step 3 -- creates ambiguity about source of truth

**Location:** Handoff section 7, Step 4 (lines 224-229)

**Issue:** Step 3 modifies `install.sh` to copy `examples/` automatically. Step 4 then tells Blake to manually `cp` the same file. If Blake runs `install.sh` after Step 3, the manual copy is redundant. If Blake does Step 4 BEFORE running install.sh, the file exists in `.claude/skills/` but wasn't placed there by install.sh.

This creates confusion about the canonical installation flow: is `install.sh` the source of truth, or is manual copy?

**Fix:** Replace Step 4 with: "Run `bash .tad/capability-packs/video-creation/install.sh` to verify the modified install.sh correctly copies examples/ alongside references/. Verify with `diff -q`."

This tests the install.sh change AND produces the same AC2-verifiable result.

### P1-2: ViMax fixture's Verification Command grep pattern covers 5 of 6 markers -- new fixture must decide

**Location:** Handoff section 7, Step 2 (lines 194-201) and the source fixture (photo-to-beat-sync-fixture.md lines 43-46)

**Issue:** The existing ViMax fixture lists 6 conceptual markers but its grep pattern only covers 5:
- `first.frame` and `last.frame` (Visual Decomposition)
- `intent.+(narrative|motion|montage)` (Intent Router)
- `view-specific` (View-Specific Reference)
- `camera.tree` (Camera Tree)

Missing from grep: **BPM target** (marker #5) and **Cut timing** (marker #6).

The handoff says "keep Input Scenario and Expected Markers content unchanged" (line 197), but the new fixture's `min_marker_count` and `Verification Command` must be internally consistent. If Blake preserves the grep pattern as-is, the max possible `sort -u | wc -l` result is 5, not 6. The `min_marker_count` should be calibrated against what the grep CAN detect, not the conceptual marker count.

**Fix:** The handoff should explicitly state whether Blake should:
- (a) Keep the existing 5-pattern grep and set `min_marker_count: 4` (current ViMax threshold), OR
- (b) Extend the grep to cover BPM and Cut timing and set `min_marker_count: 5` or `6`

Option (a) is recommended for dogfood MVP -- don't over-engineer the first fixture.

---

## P2 (Nice to Have)

### P2-1: AC8 verification is fragile -- "not containing 'Unknown' or error" is underspecified

**Location:** Section 9.1, AC8 (line 283)

**Issue:** `bash install.sh --check 2>&1 | tail -1` currently outputs "All prerequisites satisfied." The AC says the output should not contain "Unknown" or "error" -- but this negative check doesn't verify positive behavior. If a future install.sh change causes `--check` to output something unexpected on the last line (e.g., a warning), this AC would still pass.

**Fix (minor):** Change to positive assertion: `grep -c 'prerequisites' <<< "$(bash install.sh --check 2>&1 | tail -1)"` expected `1`. Or just `echo OK` -- the real signal is exit code 0.

### P2-2: AC10 is underspecified -- no concrete command

**Location:** Section 9.1, AC10 (line 285)

**Issue:** AC10 says "run fixture Verification Command on dogfood-output.md" but doesn't provide the exact command. This is the only AC without a concrete verification command. Per architecture knowledge "AC Verification Drift Pattern": every non-trivial AC verification command MUST be dry-run by Alex.

**Fix:** Since the exact grep pattern depends on Step 2's output, add a note: "Blake: paste the exact Verification Command from the created fixture here after Step 2 completes, before running Step 5."

### P2-3: File list (section 6) is missing evidence directory

**Location:** Section 6 (lines 172-178) and section 8 (lines 258-266)

**Issue:** Section 8 lists `dogfood-output.md` at path `.tad/evidence/handoffs/HANDOFF-20260527-pack-behavioral-examples/dogfood-output.md`, but section 6 (Files to Modify/Create) doesn't include it. Section 6 lists 4 files; section 8 lists 7 evidence artifacts. The gap is expected (section 6 = code files, section 8 = all evidence), but the dogfood output and completion report are created during implementation steps and should arguably appear in section 6 for completeness.

**Fix (optional):** Add a note to section 6: "Step 5 also creates dogfood evidence at path listed in section 8."

---

## Positive Observations

1. **Intent Statement is excellent** (section 1.3) -- clearly separates what IS and IS NOT in scope. The four "not doing" items prevent scope creep.

2. **Decision Summary** (section 11) is well-structured with considered alternatives. Decision 3 (AC-driven, not Layer 1) is the right MVP choice.

3. **Anti-Patterns section** (section 10.3) proactively addresses the most likely Blake mistakes.

4. **AC3 grep pattern is correct** -- dry-run on a representative fixture produces the expected count of 5. The `tests_rules:` key line (without array items) is correctly matched by `^tests_rules:`.

5. **Backward compatibility** is well-handled -- the `if [[ -d ... ]]` guard in the install.sh snippet ensures existing packs without `examples/` are unaffected.

6. **Fixture format** (section 4.2) is well-defined and internally consistent. The Anti-Slop Check section is a smart addition over the raw ViMax fixture format.

---

## Summary

| Severity | Count | Items |
|----------|-------|-------|
| P0 | 1 | Install.sh diagnostic gap on empty examples/ |
| P1 | 2 | Step 4 redundancy; grep/marker count alignment |
| P2 | 3 | AC8 fragility; AC10 underspecified; section 6 gap |

**Verdict: CONDITIONAL PASS** -- fix P0-1 (add diagnostic for empty examples/) and address P1-2 (clarify grep pattern scope for new fixture) before shipping to Blake. P1-1 and P2s are recommendations.
