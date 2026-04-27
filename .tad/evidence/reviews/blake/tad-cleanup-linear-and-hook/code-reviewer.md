# Code Review: HANDOFF-20260427-tad-cleanup-linear-and-hook.md

**Reviewer**: code-reviewer
**Reviewed File**: `/Users/sheldonzhao/01-on progress programs/TAD/.tad/active/handoffs/HANDOFF-20260427-tad-cleanup-linear-and-hook.md`
**Review Date**: 2026-04-27
**Reviewer Type**: Edit correctness + shell portability + verification command validity

---

## Summary

Handoff is mostly well-formed and the cited line numbers verify accurately for SKILL.md and the hook script. Verification commands in §9.1 are BSD/macOS-portable (no `grep -P`, no GNU-only flags). The Phase 3 hook regression test invocation is syntactically correct.

However, there is **one P0 structural error in §4.2 File 2** (config-platform.yaml deletion plan) that will cause Blake to either produce invalid YAML or have to silently deviate from the spec. There is also a P1 arithmetic mismatch between the deletion size estimate and AC12. Other findings are minor.

---

## Critical Issues (P0 — must fix before Blake starts)

### P0-1: §4.2 File 2 misclassifies `important_notes:` as not-Linear — will produce invalid YAML if followed literally

**Location**: handoff §4.2 File 2 (config-platform.yaml deletion spec), Phase 2 step 2

**Claim in handoff**:
> 紧接的 `important_notes:` 段保留（不属于 Linear 段，是 MCP 工具通用提醒）

**Actual structure** (verified via `python3 -c "import yaml; ..."`):
- `linear_integration:` is a top-level key starting at line 230
- `important_notes:` at line 278 is **2-space indented** = a sub-key OF `linear_integration:`
- yaml.safe_load confirms `data['linear_integration']` contains the key `'important_notes'`

**Failure mode if Blake follows the spec literally**:
1. Blake deletes `# ==================== Linear Integration ====================` through line 276 (end of `section_mapping:`)
2. Blake "preserves" lines 277-284 (`# 重要提醒` + `important_notes:` + 6 list items)
3. Result: orphan `  important_notes:` at 2-space indent with no parent map above it → `yaml.safe_load` raises an error → AC8/Phase 4 step 3 (YAML syntax check) FAILS
4. Blake will then need to either dedent `important_notes` to top-level (NOT in spec) or include it in the deletion (NOT in spec) — either way they're guessing at intent

**Recommended fix** (Alex must clarify before handoff goes to Blake):

Option A (cleaner — the comment text reads MCP-generic, even though indentation says Linear-specific):
- Update §4.2 File 2 to: "Delete entire `linear_integration:` block (lines 229-275 OR 229-284 depending on intent — see clarifying note). The `important_notes:` sub-key at lines 278-284 is currently structurally nested under `linear_integration:` despite its content reading as generic MCP guidance. Resolution: dedent `important_notes:` to top-level (column 0) before deletion, OR delete it entirely with `linear_integration:`. Recommended: dedent because the content is genuinely MCP-generic. Then Phase 4 YAML check will pass."

Option B (simplest — delete it all):
- Update §4.2 File 2 to: "Delete entire `linear_integration:` block including the nested `important_notes:` sub-key (lines 229-284, all the way to EOF). Note: `important_notes:` is currently nested under `linear_integration:` even though its content is generic MCP guidance — historical accident. Loss is acceptable since the same notes appear ~elsewhere in mcp_tools (verify with grep before deletion)."

Either way: `Phase 2 step 4` (`grep -c "linear" .tad/config-platform.yaml` → 0) will then hold trivially because no Linear text remains.

**Severity**: P0. This single misstatement will block Phase 4 YAML validation and Phase 5 commit.

---

## Recommendations (P1 — should address)

### P1-1: AC12 line-count threshold is over-budget — will likely FAIL

**Location**: §9 AC12 — `wc -l .claude/skills/alex/SKILL.md` 减少 ≥100 行

**Verified line counts**:
- STEP 3.7: lines 90-144 = **55 lines**
- step0b_evidence_check: lines 2797-2803 = **7 lines**
- step4b_linear_sync: lines 2872-2893 = **22 lines**
- **Total: 84 lines**

**AC12 expects ≥100. Actual deletion will be ~84.** AC12 will FAIL on truthful execution. Blake will either flag it (correct behavior, blocks Gate 3) or be tempted to over-delete to hit the threshold (bad).

**Recommended fix**: Lower AC12 threshold to **≥80 lines** (gives 4-line buffer for Blake's editing variance + any whitespace/blank-line collapsing). Align Phase 1 step 5 wording too: handoff currently says "应减少 ~110 行" — change to "应减少 ~84 行 (55+7+22)".

### P1-2: Phase 1 step 7 `grep -c "Linear"` premise depends on P0-1 resolution

**Location**: Phase 1 step 7

If P0-1 is resolved by deleting `important_notes:` with the rest of `linear_integration:`, then `grep -c "Linear" .claude/skills/alex/SKILL.md` → 0 will hold. If P0-1 is resolved by dedent-and-keep, the SKILL.md won't be affected (the issue is in config-platform.yaml). So this AC is conditionally OK — but the verification phrasing makes Blake think the AC is independent. Add a cross-reference: "AC depends on P0-1 resolution per Alex revision."

Also: AC4 says `grep -ci "linear"` (case-insensitive) → 0. Verified this will hold after the two SKILL.md deletions (all 33 matches fall within the deletion regions).

### P1-3: Phase 1 step 5 (`wc -l` should reduce ~110) inconsistent with actual line count

Same arithmetic problem as P1-1. The "~110" is wrong; actual is ~84. Update Phase 1 step 5.

### P1-4: STEP 3.7 region described as "约 80 行" in §4.2 File 1 区域 A — actually 55 lines

**Location**: §4.2 File 1 删除区域 A

The handoff says "STEP 3.7，约 80 行". Actual is 55 lines (90-144 inclusive). Not a blocker since the start/end lines are correctly cited, but the size estimate is inaccurate and may confuse Blake's mental model.

**Recommended fix**: change "约 80 行" → "约 55 行".

### P1-5: Phase 4 step 3 uses `python3 -c "import yaml"` for syntax check — works but worth noting `yq` is also available and faster

Not a blocker. The handoff's choice (`python3 -c "import yaml; yaml.safe_load(open(...))"`) is portable and correct on macOS. Just flagging that `yq eval . file.yaml >/dev/null` is the more idiomatic check if `yq` is installed (it is, used elsewhere in TAD hooks).

---

## Suggestions (P2 — nice to have)

### P2-1: Phase 5 commit message uses fenced code block, not actual heredoc

**Location**: §6 Phase 5 step 5

The handoff shows the commit message in a markdown fenced code block. Blake will need to construct the heredoc himself per CLAUDE.md `git commit -m "$(cat <<'EOF' ... EOF)"` convention. This is standard and Blake has done it many times — no real issue. Worth a one-line note in the handoff: "Blake: use HEREDOC per CLAUDE.md convention; the message text is just shown as a code block here for readability."

### P2-2: Hook regression test prompt may not match enough keywords to actually trigger Phase 3 hook in passive mode

**Location**: §6 Phase 3 step 5

The test prompt `"test domain pack matching prompt with mobile expo react native"` should hit the `mobile-development` pack (expo + react-native are likely keywords). The intent is to verify NO injection happens after passive-mode change. **This works as a negative test** (expects `NO_INJECTION` → confirms passive mode). However, to be a complete regression, Blake should ALSO verify that BEFORE passive-mode change (e.g., from a git-stash of the old hook), the same prompt would inject. Otherwise we're verifying "MARKER not seen" but it could be because the keyword didn't match at all.

**Recommended fix**: Add a sub-step: "Confirm hook DID score: after running the regression, `tail -1 .tad/hooks/.router.log` should show `mobile-development X/Y` not `none 0` — proves keyword match path still works, just no injection."

This is already partially covered by AC11 (`.router.log` test before/after rows +1) but the explicit pack-name check makes the test more robust.

### P2-3: AC14 slug is correct

**Location**: §9 AC14, §9.1 last row

Verified: `bash .tad/hooks/lib/layer2-audit.sh tad-cleanup-linear-and-hook` matches the layer2-audit.sh whitelist regex `^[A-Za-z0-9_]([A-Za-z0-9_-]*[A-Za-z0-9_])?$`. No issues.

### P2-4: `claude -p` regression test — escape correctness

**Location**: §6 Phase 3 step 5 + §8.2 Integration Tests

The single-quoted system-prompt argument:
```
'Reply only with the literal string MARKER if you saw a "Domain Pack" mention in your context, otherwise reply NO_INJECTION'
```
Inside `''`, double quotes are literal — no escape needed. Bash will pass the entire string as one argv element. Correct.

`--tools ''` (empty string) is documented precedent (architecture.md 2026-04-07). Correct.

`--no-session-persistence` is correct flag.

No issues with the invocation.

### P2-5: §9.1 verification commands — BSD/macOS portability check

All commands in §9.1 are BSD-portable:
- `grep -c PATTERN file` — BSD-OK
- `grep '"2.8.4"' file | wc -l` — pipe is fine, the `\|` in the markdown table is just markdown escape
- `bash -n script.sh; echo $?` — POSIX
- `git diff --stat | tail -1` — POSIX
- `bash .tad/hooks/lib/layer2-audit.sh slug` — internal TAD tool, already BSD-tested

No `grep -P`, no `sed -i` without backup arg, no GNU-only flags. PASS.

### P2-6: deprecation.yaml format consistency

The proposed 2.8.4 entry includes a `note:` field with a multi-line YAML string (`note: |`), which matches the format used in the existing 2.8.1 entry. Good. The `files: []` empty list is valid YAML and consistent with the deletion-being-within-existing-files rationale documented in §10.1. No issues.

---

## Overall Assessment

**CONDITIONAL PASS** — handoff is otherwise well-structured, but Blake cannot start until P0-1 (config-platform.yaml `important_notes:` indentation issue) is resolved by Alex. P1-1 / P1-3 / P1-4 (line-count arithmetic across AC12, Phase 1 step 5, §4.2 File 1 size estimate) should also be corrected to prevent a Gate 3 false-fail.

Once P0-1 is resolved and P1-1/P1-3/P1-4 are corrected, this handoff is implementation-ready.

---

## Verified Citations

| Citation | Handoff Claim | Actual | Status |
|----------|--------------|--------|--------|
| SKILL.md line 90 | "STEP 3.7: Linear sync" | line 90 = `  - STEP 3.7: Linear sync (startup full sync)` | ✅ |
| SKILL.md line 2797 | `step0b_evidence_check:` | line 2797 = `    step0b_evidence_check:` | ✅ |
| SKILL.md line 2803 | end of step0b block | line 2803 = `      blocking: true` | ✅ |
| SKILL.md line 2872 | `step4b_linear_sync:` | line 2872 = `    step4b_linear_sync:` | ✅ |
| SKILL.md line 2893 | end of step4b block | line 2893 = `        Principle: Linear sync NEVER blocks *accept. All errors are warnings.` | ✅ |
| hook lines 217-222 | BEST_PACK assignments (PRESERVE) | lines 217-222 = `if [ -n "$SCORE_RESULT" ]; then` ... `fi` block setting BEST_PACK/MATCHED/TOTAL/FILE | ✅ |
| hook lines 224-234 | additionalContext emission (DELETE) | lines 224-234 = `# ─── Emit hookSpecificOutput ...` through `fi` | ✅ |
| config-platform.yaml ~line 229 | "Linear Integration" header | line 229 = `# ==================== Linear Integration ====================` | ✅ |
| config-platform.yaml `important_notes:` claim | "不属于 Linear 段" | actually nested under `linear_integration:` | ❌ **P0-1** |
| STEP 3.7 size estimate | "约 80 行" | 55 lines (90-144) | ⚠️ **P1-4** |
| step4b size estimate | "约 25 行" | 22 lines (2872-2893) | minor |
| AC12 ≥100 line reduction | 110 lines | 84 lines | ❌ **P1-1** |
| layer2-audit.sh slug whitelist | `tad-cleanup-linear-and-hook` | matches regex | ✅ |
| §9.1 BSD portability | all commands | no GNU-only / `grep -P` / `sed -i` | ✅ |
| Hook regression test syntax | `claude -p` invocation | proper quoting | ✅ |
