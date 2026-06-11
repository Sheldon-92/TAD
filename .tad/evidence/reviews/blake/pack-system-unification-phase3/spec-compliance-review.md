# Spec Compliance Review: Pack System Unification Phase 3

**Reviewer**: Spec-compliance reviewer (independent)
**Handoff**: HANDOFF-20260611-pack-system-unification-phase3.md
**Commit under review**: 4c64e19
**Date**: 2026-06-11

---

## Summary

Phase 3 adds a `platform-skills` mode to `release-verify.sh` that verifies framework-owned skill symmetry between `.claude/skills` and `.agents/skills` in a target project after sync/install. The implementation is clean, well-structured, and follows the handoff's technical design closely. Protocol files, runbook, and platform docs are all updated with the required content. Evidence includes pass, fail, and INFO fixture outputs.

---

## AC Verdicts

### AC1: Existing source-repo parity still passes
**SATISFIED**

Live verification confirms `bash .tad/hooks/lib/release-verify.sh parity "$PWD"` exits 0. The new `platform-skills` mode is added as a separate `case` branch; no existing mode logic was modified. The `parity` mode contract in the file header is unchanged.

### AC2: New platform-skill verifier passes on current source repo
**SATISFIED**

Live verification confirms `bash .tad/hooks/lib/release-verify.sh platform-skills "$PWD" "$PWD"` exits 0 with 46 framework-owned skills checked. Evidence captured in `platform-skills-source-pass.txt` matches the live run output.

### AC3: Injected framework-owned drift fails and names the drifted skill
**SATISFIED**

Evidence file `platform-skills-drift-fail.txt` shows the verifier detecting drift in the `alex` skill after appending `DRIFT-FIXTURE` to `$tmp/.agents/skills/alex/SKILL.md`. Output line 17: `DRIFT: alex -- .claude and .agents differ in target`. Exit code is 1 (FAIL). The skill name is explicitly printed. Fixture construction in `fixture-notes.md` is documented.

### AC4: Target-only local skill additions pass with INFO, not FAIL
**SATISFIED**

Evidence file `platform-skills-local-info.txt` shows the verifier passing (exit 0) when a `local-only-demo` skill exists only in the target. Output line 52: `local-skill: local-only-demo (target-only, not framework-owned)`. Summary line confirms `Local-only: 1 (INFO, not blocking)`. Exit code is 0.

### AC5: Missing framework-owned target skill fails and names the missing skill
**SATISFIED**

Evidence file `platform-skills-missing-fail.txt` shows the verifier detecting that `blake` SKILL.md was deleted from `.agents/skills/blake/` in the target. Output line 18: `DRIFT: blake -- .claude and .agents differ in target` with detail `Only in ... .claude/skills/blake: SKILL.md`. Exit code is 1 (FAIL). The skill name is explicitly printed.

Note: The output says "DRIFT" rather than "MISSING" because the dir still exists (only the file was deleted, not the dir). This is technically accurate -- `diff -rq` reports the asymmetry -- but could be more precise. Minor observation, not a compliance failure since the handoff AC says "fails and names the missing skill", which it does.

### AC6: Sync protocol files in `.claude` and `.agents` are byte-identical and include the new verifier at the post-install point
**SATISFIED**

- `cmp -s .claude/skills/alex/references/sync-protocol.md .agents/skills/alex/references/sync-protocol.md` confirms byte-identity.
- `grep -F "platform-skills"` confirms the mode name appears in the sync protocol.
- The new step is placed as step `e` (between the existing parity check at step `d` and the registry update now at step `f`), which is after all skill copy/install writes and before declaring success. This matches the handoff's required placement.

### AC7: Release runbook files in `.claude` and `.agents` are byte-identical and include the new verifier
**SATISFIED**

- `cmp -s .claude/skills/release-runbook/SKILL.md .agents/skills/release-runbook/SKILL.md` confirms byte-identity.
- `grep -F "platform-skills"` confirms the mode name appears in the runbook.
- The new section "Post-sync platform-skills check" is marked MANDATORY and placed after the sync results table and before the final registry update step. This matches the handoff's required placement (after capability pack install/sync writes, before declaring success).

### AC8: Platform docs state that `SKILL.md` Capability Packs are the only active pack system for Claude Code and Codex
**SATISFIED**

Two files contain the required claim:
- `docs/MULTI-PLATFORM.md`: New "Active Pack System" section with the exact required sentence plus local-skill explanation and verifier reference.
- `.tad/codex/README.md`: Added the exact required sentence plus retirement date and archive location.

Both documents also explain local-skill exceptions as required by the handoff section 4.3.

### AC9: No active Domain Pack runtime references are reintroduced
**SATISFIED** (with documented friction)

The `rg` command from section 9.1 matches one line in `docs/HISTORY.md:20`:
```
Production hook LIVE: userprompt-domain-router.sh + 20 curated packs in keywords.yaml
```

This is a historical archive entry (a completed Epic checkbox from 2026-04-08) that records what was shipped at the time. It is NOT an active runtime reference -- it is descriptive history. The `fixture-notes.md` documents this as a false positive from the `docs` recursive search scope including HISTORY.md.

Assessment: Acceptable friction. The AC9 intent is to prevent reintroduction of active Domain Pack runtime code (routers, SessionStart injection, keyword files). A historical completion record in HISTORY.md does not constitute reintroduction. The actual active runtime surfaces (`.tad/hooks`, `.claude/skills`, `.agents/skills`) are clean. Adding HISTORY.md to the exclusion list would be worse -- it would mask any future accidental insertion into that directory.

### AC10: Evidence directory contains raw pass/fail/INFO outputs and completion report states the `research-methodology` disposition
**PARTIALLY_SATISFIED**

Evidence files present:
- `platform-skills-source-pass.txt` -- present, non-empty, correct content
- `platform-skills-drift-fail.txt` -- present, non-empty, correct content
- `platform-skills-local-info.txt` -- present, non-empty, correct content
- `platform-skills-missing-fail.txt` -- present, non-empty, correct content (bonus: not in minimum artifacts list but valuable)
- `fixture-notes.md` -- present, includes `research-methodology` disposition

Missing:
- `COMPLETION-20260611-pack-system-unification-phase3.md` does not exist yet. The handoff lists it under "Minimum artifacts" in section 8 and AC10 explicitly requires it.
- `ac-outputs.txt` (listed in section 8 minimum artifacts) is not present.

The `research-methodology` disposition IS documented in `fixture-notes.md` (lines 28-29: "The `platform-skills` verifier covers it as a framework-owned skill because it exists in both `.claude/skills/research-methodology/` and `.agents/skills/research-methodology/`. The current source content matches on both platforms."). However, AC10 requires it in the completion report specifically.

Verdict: PARTIALLY_SATISFIED because the completion report does not yet exist. The raw evidence files are all present and correct. The research-methodology disposition is documented in fixture-notes.md and visible in the source-pass evidence (line 32 shows `research-methodology symmetric`), but needs to appear in the completion report per AC10.

### AC11: Layer 2 reviews are present and no P0/P1 remains unresolved
**NOT_SATISFIED** (expected timing)

Neither review file exists yet:
- `.tad/evidence/reviews/blake/pack-system-unification-phase3/spec-compliance-review.md` -- being created now (this file)
- `.tad/evidence/reviews/blake/pack-system-unification-phase3/code-review.md` -- not yet created

This is expected per the handoff's implementation sequence (step 7: "Run Layer 2 review and fix P0/P1 findings") -- the reviews are being produced now. This AC will be satisfiable once this review and the code review are written and any P0/P1 findings are resolved.

---

## FR Traceability

| FR | Mapped To | Status |
|----|-----------|--------|
| FR1 | `release-verify.sh` lines 663-797, `platform-skills` mode | Implemented |
| FR2 | Lines 680-698: derives from source dirs via glob, no hardcoded list | Implemented |
| FR3 | Lines 743-772: `diff -rq` between target `.claude` and `.agents` per skill | Implemented |
| FR4 | Lines 748-762: missing dir on either side is FAIL with named skill | Implemented |
| FR5 | Lines 764-770: byte drift is FAIL with named skill | Implemented |
| FR6 | Lines 774-783: target-only skills are INFO | Implemented |
| FR7 | AC2 live pass confirms | Verified |
| FR8 | AC3 drift fixture confirms | Verified |
| FR9 | sync-protocol.md step e + release-runbook.md "Post-sync platform-skills check" | Implemented |
| FR10 | MULTI-PLATFORM.md "Active Pack System" + codex/README.md | Implemented |

## NFR Traceability

| NFR | Status | Notes |
|-----|--------|-------|
| NFR1 | PASS | No `grep -P`, no GNU-only flags, `diff -rq` is POSIX. `bash -n` syntax check passes. |
| NFR2 | PASS | No hooks, settings entries, or SessionStart checks added. Mode is manual/script-invoked. |
| NFR3 | PASS | Verifier only reads target dirs (`diff -rq`), never writes. |
| NFR4 | PASS | sync-protocol and release-runbook counterparts confirmed byte-identical via `cmp -s`. |
| NFR5 | PASS | Output includes mode name ("PLATFORM-SKILLS VERIFY"), target root, skill name, and issue type (DRIFT/MISSING/local-skill). |
| NFR6 | PASS | Evidence directory has raw output for pass, fail (drift + missing), and INFO-local-skill cases. |

---

## Implementation Quality Observations

Positive:
- Source precondition check (lines 707-721) is a good defensive addition -- catches source-side drift before verifying the target, preventing false passes.
- The framework-owned set is derived as a union of both platform dirs, which correctly handles the case where a skill exists only on one source platform.
- The `case " $fw_skills "` dedup pattern is simple and correct for space-delimited sets.
- Exit code contract follows the established 0/1/2 pattern from other modes.

Minor observations (not P0/P1):
- The `fw_skills` variable uses space-delimited string instead of an array. This works because skill names are convention-enforced to have no spaces, but an array would be more robust. Existing code in the same file uses the same pattern, so this is consistent.
- The usage line was added to the `usage()` function (line 126), maintaining the contract documentation.

---

## Verdict Summary

| AC | Verdict | Notes |
|----|---------|-------|
| AC1 | SATISFIED | Parity mode unchanged, passes live |
| AC2 | SATISFIED | platform-skills passes on source repo, 46 skills |
| AC3 | SATISFIED | Drift detected, skill named |
| AC4 | SATISFIED | Local-only is INFO, exit 0 |
| AC5 | SATISFIED | Missing detected, skill named |
| AC6 | SATISFIED | Byte-identical, mode name present, correct placement |
| AC7 | SATISFIED | Byte-identical, mode name present, correct placement |
| AC8 | SATISFIED | Required claim in both docs |
| AC9 | SATISFIED | HISTORY.md match is a documented false positive (historical archive) |
| AC10 | PARTIALLY_SATISFIED | Evidence files present; completion report not yet written |
| AC11 | NOT_SATISFIED | Reviews being created now (expected timing) |

**Overall**: 9/11 SATISFIED, 1 PARTIALLY_SATISFIED (pending completion report), 1 NOT_SATISFIED (expected -- reviews in progress). No P0 or P1 issues found. Implementation correctly maps all 10 FRs and 6 NFRs.

---

## Findings

### P0 Issues
None.

### P1 Issues
None.

### P2 Observations (no action required for Gate 3)

1. **AC5 message precision**: When a file is deleted from a skill dir (but the dir remains), the output says "DRIFT" rather than "MISSING". The AC says "fails and names the missing skill" -- technically satisfied because the skill IS named and the verifier DOES fail. A future improvement could distinguish dir-missing from file-missing within a dir.

2. **Completion report needed for AC10/AC11**: These are timing-dependent artifacts. The completion report must include `research-methodology` disposition (already documented in fixture-notes.md, needs to be carried forward). The code review must be written separately.
