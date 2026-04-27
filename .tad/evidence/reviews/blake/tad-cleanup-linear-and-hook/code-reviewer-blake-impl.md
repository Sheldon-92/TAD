# Code Review — Blake's Implementation of HANDOFF-20260427-tad-cleanup-linear-and-hook

**Reviewer**: code-reviewer (Layer 2, Blake-side)
**Subject**: Blake's IMPLEMENTATION DIFF (7 files) — NOT the handoff design (that was reviewed pre-handoff at .tad/evidence/reviews/blake/tad-cleanup-linear-and-hook/code-reviewer.md)
**Date**: 2026-04-27
**Diff scope**: `.claude/skills/alex/SKILL.md`, `.tad/config-platform.yaml`, `.tad/config.yaml`, `.tad/templates/handoff-a-to-b.md`, `.tad/hooks/userprompt-domain-router.sh`, `.tad/hooks/post-write-sync.sh`, `.tad/deprecation.yaml`
**Diff stat**: 7 files modified, 28 insertions(+), 157 deletions(-)

---

## 1. Summary

Blake's execution is clean, surgical, and matches the handoff spec letter-for-letter. All 15 acceptance criteria (AC1-AC15) corroborate via independent re-execution: every grep returns the expected count, both YAML files load, both shell scripts pass `bash -n`, and the hook integration test produces 0 stdout bytes + 2 new log lines exactly as specified. No P0 or P1 issues found. Two minor cleanup observations (P2) noted below — neither blocks acceptance.

**Verdict**: PASS

---

## 2. Critical Issues (P0)

**None.**

The high-risk classes were all checked:

- **Deletion correctness**: All 3 SKILL.md regions removed cleanly (87 lines net = ~56 STEP 3.7 + 8 step0b + 23 step4b, slightly above Alex's 84-line estimate but well within AC12's "≥80 lines" threshold). No surrounding YAML structure damaged — STEP 4 now correctly follows STEP 3.6, step1 follows step0_git_check, step5 follows step4.
- **YAML structural integrity**: `python3 -c "yaml.safe_load(...)"` succeeds for all three YAML files. `important_notes` is now top-level (6 items), `linear_integration` key absent, `mcp_tools` key intact. The "Important Notes (MCP-generic)" comment block clarifies the dedent — good defensive documentation.
- **Hook syntax**: `bash -n` exits 0 for both `userprompt-domain-router.sh` and `post-write-sync.sh`.
- **AC4 whitelist grep** (the one with the leak Blake fixed mid-implementation): `grep -rln -i "linear"` over the 5 active files returns empty list. Independently re-verified.
- **Deprecation 2.8.4 entry**: parses as YAML, schema matches prior entries (description / files / note / date), correctly placed after 2.8.2.

---

## 3. Recommendations (P1)

**None.**

The hook passive-mode comment block (lines 224-226) is concise and references the deprecation.yaml entry — exactly the right level of breadcrumb for future maintainers. The variable-flow through to logging is preserved: `BEST_PACK` / `BEST_MATCHED` / `BEST_TOTAL` are still computed at line 218-220 and consumed by `logged_pack` / `logged_ratio` at lines 230-234. Live integration test confirmed: prompt "react native expo mobile platform_features" → log line `mobile-development 2/15 42` written, stdout still 0 bytes.

The deprecation.yaml note correctly enumerates all 7 affected files (more comprehensive than the handoff's File 4 spec, which Blake noticed listed only 3 — Blake expanded it to 7, which is an improvement, not drift).

---

## 4. Suggestions (P2)

### P2-1: Two now-dead variables in `userprompt-domain-router.sh`

**Location**: `.tad/hooks/userprompt-domain-router.sh:128, 221`

**Observation**: `BEST_RATIO_NUM` (line 128, initialized to 0) was declared as a header comment for the integer-ratio-x1000 trick but is no longer referenced anywhere — likely dead before this change too, but worth noting. `BEST_FILE` (line 221, populated from `cut -f4`) was previously consumed inside the `${BEST_FILE}` interpolation in the deleted injection block; after the deletion, its assignment is dead (it's not used in the log line, which records pack/ratio/elapsed_ms/msg_length only).

**Why this is P2 not P1**: Neither variable causes incorrect behavior; they're 2 lines of waste each. Removing them is a separate cleanup not in scope of this handoff. Calling out so a future hook touch knows to remove them.

**Fix (optional, not blocking)**:
```diff
-BEST_RATIO_NUM=0   # integer ratio * 1000 for bash arithmetic
-BEST_FILE=""
...
   BEST_TOTAL=$(printf '%s' "$SCORE_RESULT" | cut -f3)
-  BEST_FILE=$(printf '%s' "$SCORE_RESULT" | cut -f4)
 fi
```

### P2-2: deprecation.yaml note enumerates all 7 files (not just 3 as handoff spec wrote)

**Location**: `.tad/deprecation.yaml:67-74`

**Observation**: The handoff §4.2 File 4 spec showed a 3-file note (SKILL.md / config-platform / hook). Blake's implementation expanded the note to 7 files, matching what was actually changed. **This is correct improvement** — downstream `*sync` consumers reading the note get the full picture. Flagging only as "be aware that the note is more comprehensive than the spec template" — acceptance is fine, this was a smart Blake call.

### P2-3: SKILL.md line delta is 86, handoff predicted 84

**Location**: `.claude/skills/alex/SKILL.md` (overall)

**Observation**: AC12 requires `≥80` line reduction — actual is 86, so PASS. The handoff §4.2 File 1 estimated `~84 = 55 + 7 + 22`. Actual block sizes were `56 + 8 + 23 ≈ 87`. The 2-3 line delta is from blank separator lines bundled into each deletion. No correctness issue — just an arithmetic-vs-actual gap that should not surprise any future audit.

---

## 5. Overall Assessment

**PASS** — Blake delivered exactly what the handoff specified across 7 files. Every AC re-verifies independently. All structural-integrity checks (YAML parse, bash -n, variable flow, log behavior) pass. The 2 P2 items are observations, not defects.

**Counts**: P0=0, P1=0, P2=3 → satisfies Layer 2 PASS criteria (P0=0, P1=0, P2≤10).

**Recommended next step for Blake**: Proceed to Gate 3 with PASS verdict. The P2 dead-variable cleanup can be a future micro-handoff if desired; not required for this acceptance.

---

## 6. Verified Citations

| File | Line(s) | Claim (handoff/AC) | Re-verified actual | Status |
|------|---------|---------------------|---------------------|--------|
| .claude/skills/alex/SKILL.md | (3 deletion regions) | AC1 `STEP 3.7` count = 0 | `grep -c "STEP 3.7"` → `0` | PASS |
| .claude/skills/alex/SKILL.md | line 2740 | AC2 `step0b_evidence_check` = 0 | `grep -c` → `0` | PASS |
| .claude/skills/alex/SKILL.md | line 2806 | AC3 `step4b_linear_sync` = 0 | `grep -c` → `0` | PASS |
| .tad/config-platform.yaml + .tad/hooks/* + .tad/templates/handoff-a-to-b.md + .claude/skills/alex/SKILL.md | (5 active files) | AC4 whitelist grep returns empty | `grep -rln -i "linear" <5 files>` → empty (exit 1) | PASS |
| .tad/config-platform.yaml | (entire) | AC5 `linear_integration` = 0 | `grep -c "linear_integration"` → `0` | PASS |
| .tad/config-platform.yaml | top-level | AC5b `important_notes` is top-level list ≥6 items | python yaml.safe_load → `OK; len=6; linear_integration=False; mcp_tools=True` | PASS |
| .tad/hooks/userprompt-domain-router.sh | (entire) | AC6 `additionalContext` = 0 | `grep -c` → `0` | PASS |
| .tad/hooks/userprompt-domain-router.sh | (entire) | AC7 `hookSpecificOutput` = 0 | `grep -c` → `0` | PASS |
| .tad/hooks/userprompt-domain-router.sh | (entire) | AC8 `bash -n` exit 0 | `bash -n` → `exit=0` | PASS |
| .tad/hooks/post-write-sync.sh | line 74 | AC8b `Linear` = 0 + `bash -n` exit 0 | `grep -c` → `0`; `bash -n` → `exit=0` | PASS |
| .tad/deprecation.yaml | new 2.8.4 block | AC9 `"2.8.4"` count ≥1 | `grep "..." \| wc -l` → `1` | PASS |
| .tad/hooks/userprompt-domain-router.sh | runtime | AC10 Test 2 stdout bytes = 0 | `wc -c < /tmp/hook-out-2.txt` → `0` | PASS |
| .tad/hooks/.router.log | runtime | AC11 log lines +≥2 | `599 → 601 (Δ=2)`; tail shows `mobile-development 2/15 42` + `none 0 26` | PASS |
| .claude/skills/alex/SKILL.md | (overall) | AC12 line reduction ≥80 | `4075 → 3989 (Δ=86)` | PASS |
| (7 files) | git diff stat | AC13 exactly 7 modified, 0 created, 0 deleted | `git diff --stat` → 7 modified, +28/-157 | PASS |
| .tad/config.yaml | line 77, 80, 320-321 | AC14 `Linear` ≤2 + `linear_integration` = 0 | `grep -c "Linear"` → `2` (lines 320-321 changelog), `grep -c "linear_integration"` → `0` | PASS |
| .tad/templates/handoff-a-to-b.md | line 39 | AC15 `Linear` = 0 | `grep -c "Linear"` → `0` | PASS |
| .tad/hooks/userprompt-domain-router.sh | lines 217-222 | Variables BEST_PACK/MATCHED/TOTAL still flow into log | log line `2026-04-27T09:15:57-0400 50 mobile-development 2/15 42` confirms | PASS |
| .tad/templates/handoff-a-to-b.md | lines 35-43 | `**Epic:**` directly precedes `**Supersedes:**` (no blank gap) | `sed -n '35,43p'` confirms — Epic line on 38, Supersedes line on 39 | PASS |
| .tad/deprecation.yaml | (entire) | YAML parses, keys = ['2.3.0', '2.8.1', '2.8.2', '2.8.4'] | `yaml.safe_load` → keys list confirmed | PASS |
| .tad/config.yaml | (entire) | YAML parses, description = "MCP tools integration", contains = [mcp_tools] | `yaml.safe_load` → confirmed | PASS |
| .tad/hooks/userprompt-domain-router.sh | line 128 | `BEST_RATIO_NUM` declared but unused after deletion | `grep` finds only line 128 declaration, no usage | NOTE (P2-1) |
| .tad/hooks/userprompt-domain-router.sh | line 221 | `BEST_FILE` assigned but no longer consumed | `grep` finds line 129 init + line 221 assign, no read | NOTE (P2-1) |

---

## Appendix: Commands run for re-verification

```bash
cd "/Users/sheldonzhao/01-on progress programs/TAD"

# AC1-9, AC12-15 grep batch (output above)
grep -c "STEP 3.7" .claude/skills/alex/SKILL.md
grep -c "step0b_evidence_check" .claude/skills/alex/SKILL.md
grep -c "step4b_linear_sync" .claude/skills/alex/SKILL.md
grep -c "linear_integration" .tad/config-platform.yaml
grep -c "additionalContext" .tad/hooks/userprompt-domain-router.sh
grep -c "hookSpecificOutput" .tad/hooks/userprompt-domain-router.sh
bash -n .tad/hooks/userprompt-domain-router.sh
grep -c "Linear" .tad/hooks/post-write-sync.sh
bash -n .tad/hooks/post-write-sync.sh
grep '"2.8.4"' .tad/deprecation.yaml | wc -l
grep -c "Linear" .tad/config.yaml
grep -c "linear_integration" .tad/config.yaml
grep -c "Linear" .tad/templates/handoff-a-to-b.md
wc -l .claude/skills/alex/SKILL.md  # vs HEAD: 4075 → 3989

# AC4 whitelist
grep -rln -i "linear" .tad/config-platform.yaml .tad/hooks/userprompt-domain-router.sh \
  .tad/hooks/post-write-sync.sh .tad/templates/handoff-a-to-b.md \
  .claude/skills/alex/SKILL.md  # → empty

# AC5b YAML structural
python3 -c "import yaml; d = yaml.safe_load(open('.tad/config-platform.yaml')); \
  assert 'important_notes' in d and isinstance(d['important_notes'], list) and len(d['important_notes']) >= 6; \
  print('OK; len=', len(d['important_notes']))"

# AC10/11 hook integration test (passive mode + log preserved)
echo '{"prompt":"react native expo mobile platform_features", ...}' \
  | bash .tad/hooks/userprompt-domain-router.sh > /tmp/hook-out-2.txt
wc -c < /tmp/hook-out-2.txt  # → 0
tail -1 .tad/hooks/.router.log  # → mobile-development 2/15 42

# AC13
git diff --stat -- .claude/skills/alex/SKILL.md .tad/config-platform.yaml \
  .tad/config.yaml .tad/templates/handoff-a-to-b.md \
  .tad/hooks/userprompt-domain-router.sh .tad/hooks/post-write-sync.sh \
  .tad/deprecation.yaml
# → 7 files changed, 28 insertions(+), 157 deletions(-)
```
