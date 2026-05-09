# backend-architect Pre-Handoff Review — Pre-Publish Cleanup

**Reviewer**: backend-architect (pre-handoff, parallel with code-reviewer)
**Handoff**: `/Users/sheldonzhao/01-on progress programs/TAD/.tad/active/handoffs/HANDOFF-20260427-pre-publish-cleanup.md`
**Date**: 2026-04-27
**Type**: Design coherence + AC13 fresh grep dogfood + symmetry concerns
**Mode**: REVIEW only — no handoff modifications, no implementation code

---

## AC13 Fresh Grep Result (REQUIRED)

**Command run from `/Users/sheldonzhao/01-on progress programs/TAD/`**:
```bash
grep -rln "additionalContext\|hookSpecificOutput" .tad/ .claude/ 2>/dev/null \
  | grep -v "^\.tad/archive" \
  | grep -v "^\.tad/active/handoffs/"
```

**Total hits**: 50 files. Below is the de-duplicated classification (5 in-scope handoff files + 45 external).

### A. In-scope (5) — handoff §7.2 Files to Modify
| File | Status |
|------|--------|
| `.tad/hooks/run-phase2b-tests.sh` | in-scope, FR1 |
| `.tad/evidence/acceptance-tests/phase1-state-consistency/AC-P1.4-router-event-filter.sh` | in-scope, FR2 |
| `.claude/skills/release-runbook/SKILL.md` | in-scope, FR3 |
| `.claude/skills/alex/SKILL.md` | in-scope, FR4 |
| `.claude/skills/blake/SKILL.md` | in-scope, FR5 |

### B. Expected (historical / spike / archived evidence) — NO ACTION REQUIRED
- `.tad/evidence/spikes/SPIKE-20260413-quality-enforcement/*` (2 files) — historical Epic 1 spike
- `.tad/evidence/spikes/SPIKE-20260414-quality-enforcement-adversarial/*` (4 files) — historical Epic 1b spike
- `.tad/evidence/spikes/SPIKE-20260414-phase1c-ac17-perf-fix/*` (6 files) — historical Epic 1c spike
- `.tad/evidence/spikes/SPIKE-20260407-domain-pack-hook/*` (4 files) — historical Phase 1 router-hook spike
- `.tad/evidence/spikes/SPIKE-20260407-phase2a-prompt-contract/*` (4 files) — historical Phase 2a contract spike
- `.tad/evidence/completions/phase4-domain-pack-expansion/anti-epic1-grep.txt` — Anti-Epic-1 frozen evidence dump
- `.tad/evidence/completions/phase2-grounding/anti-epic1-grep.txt` — same
- `.tad/evidence/phase2b-integration-test.md` — historical Phase 2b validation report (frozen)
- `.tad/evidence/reviews/blake/tad-cleanup-linear-and-hook/*` (3 files) — prior cleanup-handoff reviews
- `.tad/evidence/reviews/blake/phase1-state-consistency/*` (3 files) — Phase 1 historical reviews
- `.tad/evidence/reviews/alex/phase2-grounding/code-reviewer.md` — Phase 2 historical review
- `.tad/evidence/reviews/2026-04-24-testing-review-phase1-state-consistency.md` — historical testing review
- `.tad/spike-v3/*` (8 files: ARCHITECTURE-v3.md, README.md, CONTEXT-MEASUREMENT.md, exp1/3c/4/6/7) — TAD v3 leaked-source spike, archived in spirit
- `.tad/tests/test-domain-pack.md` — old test stub (low-touch, not a runtime consumer)
- `.tad/deprecation.yaml:73` — single string mention "additionalContext injection removed (passive mode)" — this is documenting the removal, **expected**

### C. CRITICAL CLARIFICATION — these are NOT dangling, they are LEGITIMATE OTHER HOOKS
This is the most important finding of the review. The handoff implicitly assumes "every `additionalContext` reference in TAD is a UserPromptSubmit consumer". The fresh grep proves this assumption is **wrong** — TAD has TWO other live hooks that legitimately emit `hookSpecificOutput.additionalContext`, and they MUST NOT be touched:

| File | Hook Type | Status |
|------|-----------|--------|
| `.tad/hooks/startup-health.sh` | **SessionStart** hook — injects TAD project health summary at session start. Lines 3-4: `# Injects TAD status into every new session via additionalContext.` Line 49: `# Domain Pack detection — extract capabilities summary for additionalContext` | **ACTIVE, MUST NOT MODIFY** |
| `.tad/hooks/lib/common.sh` | shared library — `output_response()` function (line 35-55) builds `{hookSpecificOutput:{hookEventName,additionalContext}}` JSON. This is the SHARED EMITTER used by both startup-health.sh (SessionStart) and post-write-sync.sh (PostToolUse). Modifying it would break BOTH active hooks. | **ACTIVE, MUST NOT MODIFY** |
| `.tad/hooks/post-write-sync.sh` | **PostToolUse** hook — injects workflow reminders on Write/Edit to TAD-managed files. Line 5: `# Output: JSON with hookSpecificOutput wrapper, or empty JSON for non-TAD files.` | **ACTIVE, MUST NOT MODIFY** |
| `.claude/skills/alex/SKILL.md:561,570,1541` | Alex SKILL prose — references the **SessionStart hook's** `additionalContext` to teach Alex how to read injected Domain Pack capabilities. NOT the UserPromptSubmit hook (which is now passive). | **ACTIVE, MUST NOT MODIFY** |

### D. Test fixtures / acceptance scripts that grep for the literal pattern — context-dependent
| File | Behavior |
|------|----------|
| `.tad/evidence/acceptance-tests/phase2-grounding/AC-P2.2-grounding-pass.sh:166-168` | Greps for `PreToolUse|UserPromptSubmit|hookSpecificOutput|permissions.deny` as part of Anti-Epic-1 detection — the literal pattern is part of an alarm regex, not a consumer. **Expected, no change.** |
| `.tad/evidence/acceptance-tests/TASK-20260331-002/AC-all-verify.sh:38` | `jq -e '.hookSpecificOutput.additionalContext'` — verifies the hook output schema. This is testing the SessionStart-style hook contract, generic to any hook that emits the envelope. **Likely still works** since SessionStart + PostToolUse still emit the envelope. **Expected, no change.** |
| `.tad/evidence/fixtures/phase6/p6a-ac-drift-catch-test.sh:84,86` | Test fixture — greps the pattern as part of a drift check. **Expected, no change.** |

### E. Knowledge/docs — pure documentation
| File | Behavior |
|------|----------|
| `.tad/project-knowledge/architecture.md` (14 hits) | Historical learnings entries discussing past hook behavior. **Expected, no change.** |

### Summary
**No P0 dangling consumer was missed by the handoff scope.** The 3 in-scope migrations (FR1/FR2/FR3) cover all UserPromptSubmit consumers. **However, 4 files (startup-health.sh, common.sh, post-write-sync.sh, alex/SKILL.md) contain `additionalContext` references that are NOT dangling — they belong to SessionStart and PostToolUse hooks. Blake must be EXPLICITLY told not to touch these.** This is a P0-level handoff scope warning gap, not a P0 missing-file gap.

The handoff §10.1 critical warnings already say "不动 hook 本身的脚本（只动 consumer 端）" but does NOT name the 3 hook script files explicitly NOR mention the SessionStart legitimate-use of `additionalContext`. A Blake who runs the AC13 grep will find these and could rationalize "Alex told me to remove all additionalContext refs, these look the same" — false positive.

---

## Critical Issues (P0 — must fix before Blake starts)

### P0-1: Handoff implicitly assumes ALL `additionalContext` references are UserPromptSubmit consumers — WRONG. Must whitelist 4 files explicitly.

**Issue**: §10.1 says "不动 hook 本身的脚本（只动 consumer 端）" but does not name the protected files, and does not mention that **SessionStart + PostToolUse hooks legitimately keep emitting `hookSpecificOutput.additionalContext`**. Blake's AC13 fresh grep will surface 4 files (`startup-health.sh`, `lib/common.sh`, `post-write-sync.sh`, `alex/SKILL.md` lines 561/570/1541) as raw hits, and the handoff text alone does not let Blake distinguish "legitimate other-hook use" from "dangling consumer". Without an explicit allowlist, the safer-looking action ("remove all `additionalContext` to be safe") would silently break SessionStart and PostToolUse hooks.

**Fix recommendation**: Add a new sub-section §10.5 "Files NOT to modify (legitimate other-hook use of `additionalContext`)" listing:
- `.tad/hooks/startup-health.sh` — SessionStart hook, MUST keep emitting `additionalContext`
- `.tad/hooks/lib/common.sh::output_response()` — shared emitter for SessionStart + PostToolUse, MUST stay intact
- `.tad/hooks/post-write-sync.sh` — PostToolUse hook, MUST keep emitting `hookSpecificOutput`
- `.claude/skills/alex/SKILL.md` lines 561, 570, 1541 — references SessionStart's `additionalContext`, NOT UserPromptSubmit; do NOT touch

Also update AC13 wording to: "0 unexpected hits **outside the 5 handoff files + the 4 allowlisted other-hook files + .tad/archive/ + .tad/active/handoffs/**". The current AC13 wording would force Blake to flag the 4 allowlisted files as unexpected hits and create P0 noise.

### P0-2: Alex SKILL line numbers are wrong — `step7.generate_message` is at line 2005, not 980-1050.

**Issue**: §3.1 FR4, §6 Phase 4 step 1, §7.3 Grounded Against, and §5 MQ2 all cite "line 980-1050" / "lines 980-1050" for Alex SKILL `step7.generate_message`. Actual location verified by grep: `step7:` at line 2005, `generate_message:` at line 2009, `PLAIN-LANGUAGE EXPLANATION (MANDATORY)` at line 2053. Line 980-1050 in the same file is the *forbidden*/*standby_protocol* section — completely wrong place. If Blake follows the cited line range, the Edit will fail to find the target text or insert into the wrong section.

**Fix recommendation**: Replace all 4 line-range citations of `~980-1050` with `~2005-2080`. The handoff §5 MQ2 already lists the precise verified line "1028" for Blake SKILL `step8_generate_message` — apply the same precision to Alex SKILL. Recommended verification phrasing: "Alex SKILL `step7.generate_message` at line 2005, `PLAIN-LANGUAGE EXPLANATION` block at line 2053, target insertion point: immediately before `Required content:` (line 2067)".

### P0-3: AC13 verification command needs the new allowlist baked in or it will produce false-positive failures.

**Issue**: AC13 in §9 says "0 unexpected hits (or document any expected historical hits)". The Phase 6 step 5 grep command in §6:
```bash
grep -rln "additionalContext\|hookSpecificOutput" .tad/ .claude/ 2>/dev/null \
  | grep -v "^\.tad/archive" \
  | grep -v "^\.tad/active/handoffs/"
```
will return ~50 files. The AC's "expected residual only in historical spike + historical evidence/phase2b-integration-test.md + 5 文件之外 0 hits" wording does NOT name `startup-health.sh`, `common.sh`, `post-write-sync.sh`, or `alex/SKILL.md` SessionStart references as expected. Blake's Layer 2 backend-architect will report these as unexpected → false-positive P0.

**Fix recommendation**: Update §6 Phase 6 step 5 to a 3-tier exclusion grep:
```bash
grep -rln "additionalContext\|hookSpecificOutput" .tad/ .claude/ 2>/dev/null \
  | grep -v "^\.tad/archive" \
  | grep -v "^\.tad/active/handoffs/" \
  | grep -vE "^\.tad/evidence/(spikes|completions/phase[0-9]|reviews|fixtures|phase2b-integration-test\.md|acceptance-tests/(phase2-grounding|TASK-)|traces)" \
  | grep -vE "^\.tad/(spike-v3|tests|deprecation\.yaml|project-knowledge)" \
  | grep -vE "^\.tad/hooks/(startup-health\.sh|post-write-sync\.sh|lib/common\.sh)$" \
  | grep -vE "^\.claude/skills/alex/SKILL\.md$"
```
This must yield exactly the 5 in-scope files (or 0 after Blake completes FR1/FR2/FR3). Alex SKILL appears in both the in-scope list AND the SessionStart-reference allowlist — that is fine because line 561/570/1541 references are SessionStart-context, not the FR4 step7 insertion.

---

## Recommendations (P1 — should address)

### P1-1: NFR3 byte-symmetry has no ongoing enforcement — drift will silently happen at the 6-month horizon.

**Issue**: AC10 verifies byte-symmetry at delivery time, but nothing enforces it ongoing. Six months from now, when someone updates Alex's `BUSINESS-VALUE-FIRST` rule (e.g., adds a new positive example), Blake's copy will silently drift. The architecture.md "Path Layering: Three Defenses Against Single-Path AR-001 Drift - 2026-04-24" lesson (mechanical SKILL grep as CI-detectable check) is directly applicable here.

**Fix recommendation (3 options, ranked)**:
1. **Best**: Add a new release-runbook smoke test step (Phase 7 or pre-flight) that runs the AC10 `diff` command and FAILs the release if non-empty. Code lives in `.claude/skills/release-runbook/SKILL.md`, gets exercised every *publish.
2. **Alternative**: Add a single source of truth — extract the rule prose into `.tad/templates/business-value-first-rule.md` and have both Alex SKILL and Blake SKILL `@import` or reference it. Reduces drift surface to 1 file. Requires deeper refactor; defer to a follow-up.
3. **Minimum acceptable**: Add a new AC11.5 to this handoff: "Add a 1-line comment marker in both SKILLs noting `# SYMMETRY-PAIR: business-value-first-rule (Alex/Blake must remain byte-identical)`. Future maintainers will see the marker." This is a passive reminder, not enforcement, but better than nothing.

**Recommended choice**: Option 1 — add a step to release-runbook that runs `diff <(awk '/BUSINESS-VALUE-FIRST/,/^[[:space:]]*$/' .claude/skills/alex/SKILL.md) <(awk ... blake)` and aborts release if non-empty. Catches drift the moment it tries to ship. Aligns with the architecture.md "anchor at least one constraint in mechanical SKILL-text grep so it's CI-detectable" guidance.

### P1-2: `≥28/30 PASS` threshold (FR1 / Decision row 4) is asserted without documented baseline of CURRENT pass rate.

**Issue**: Decision #4 says "keyword DB drift 不可避免, 强求 30/30 是 over-spec". Reasonable, but: what's the CURRENT pass rate at this commit? If today the script is silently producing 0/30 (because it parses stdout that's now empty), Blake has no comparison anchor. After the migration, if the script reports 27/30, is that a real regression or just keyword drift? Without a pre-migration baseline established by manual scoring (e.g., manually running the 30 cases against the live `.router.log`), `≥28/30` is a guess number.

**Fix recommendation**: Add to §6 Phase 1 step 0 (before the migration): "Manually run `.router.log` scoring on each of the 30 test cases to establish the CURRENT achievable pass rate (call this $BASELINE). After migration, AC3 threshold becomes `min($BASELINE, 28)` — whichever is lower. Document $BASELINE in completion §AC3." This protects against the case where keyword DB drift has already pushed achievable below 28, where a `≥28/30` AC would force Blake to either fudge or chase phantom regressions.

### P1-3: `.router.log` rotation behavior at 1MB is unstated — Path A consumers all do `tail -1` / line counting which can produce wrong results at the rotation boundary.

**Issue**: The handoff says "log rotates at 1MB" but never describes the rotation mechanism. Three possibilities, each with different risk:
- **a)** truncate-and-rewrite (filename stays, content reset) — `wc -l` pre/post around a hook call could be wrong if rotation happens mid-test (post < pre is possible)
- **b)** rename-to-`.1` and start fresh — same risk, plus File 1's `with open(log_path) as f` could capture an old fd
- **c)** rename-and-keep-tail (last N lines copied to new file) — robust

For the 30-case test run (FR1) the log grows by ≤30 lines (~3KB) which is well under 1MB, so rotation during a single test run is unlikely. For File 2 (single hook invocation per assertion), even less likely. But the handoff §10.2 should mention "rotation does not happen during a single test run because each invocation appends ≤200 bytes; baseline log size at test start is far below 1MB threshold" to make the reasoning explicit.

**Fix recommendation**: Add to §10.2 Known Constraints: "`.router.log` rotates at 1MB (verified at 29KB / 606 lines as of 2026-04-27). 30-case test run appends ~30 lines (~3KB), so rotation cannot trigger mid-run. Path A consumers do not need rotation-handling logic." This makes the reasoning explicit so Blake doesn't add unnecessary defensive code.

### P1-4: `.router.log` doesn't exist on first run — File 1's pre_lines fallback is correct, but File 2's `wc -l < "$log" 2>/dev/null` returns empty string, not 0, on missing file.

**Issue**: §8.3 Edge Cases mentions `.router.log` non-existence for File 1 (correctly handled via `FileNotFoundError → pre_lines = 0`). But for File 2, the bash code uses `wc -l < "$log" 2>/dev/null | tr -d ' ' || echo 0`. Trace: if `$log` does not exist, `wc -l < missingfile` errors out, `2>/dev/null` swallows stderr, but `wc` outputs nothing to stdout (not 0). `tr -d ' '` of empty input is empty. `|| echo 0` only fires if the pipeline exits non-zero, but `tr` on empty input exits 0. Net: `pre_count=""` not 0. Subsequent `[ "$post_count" -gt "$pre_count" ]` becomes `[ "X" -gt "" ]` which produces a bash `integer expression expected` error.

**Fix recommendation**: Change File 2's pattern to:
```bash
pre_count=$(wc -l < "$log" 2>/dev/null | tr -d ' ')
[ -z "$pre_count" ] && pre_count=0
```
Same for `post_count`. Or more concisely use `${VAR:-0}`. Verify by running fixtures with `rm .tad/hooks/.router.log` before invocation. This affects FR2 / AC5.

### P1-5: §6 Phase 6 step 5 dogfood grep is buried inside Backend-architect's job description but AC13 expects Blake to pick it up. Make the cmd a top-level AC verification, not buried in §6.

**Issue**: AC13 in §9 references "§6 Phase 6 step 5 backend-architect grep cmd". The cmd is buried in §6. Spec Compliance Checklist §9.1 has only "see §6 Phase 6 step 5 backend-architect grep cmd" for AC13. After this review's P0-3 fix (refined grep filter), the actual cmd should live INSIDE §9.1 row AC13 as the literal Verification Method, not as a chase-the-pointer. This aligns with the architecture.md "AC Verification Commands Need Pre-Ship Smoke Test" learning — keep verification commands inline with their AC.

**Fix recommendation**: After applying P0-3 fix, paste the full multi-line grep into §9.1 row AC13's "Verification Method" cell. Drop the "see §6" pointer.

---

## Suggestions (P2 — nice to have)

### P2-1: Decision #6 "字字对称" rationale is one line — would benefit from architectural note about why a single-source-of-truth refactor was deferred.

The Decision Summary table row 6 just says "历史漂移风险来源——一处 prose 改了另一处忘了". Suggest adding a 1-line note: "Single-source-of-truth refactor (extract to .tad/templates/) is **viable but deferred** to keep this handoff scoped to 5 files. Future Epic candidate." This signals to future maintainers that the byte-symmetry approach is a pragmatic choice, not architectural ideal. Connects to P1-1 above.

### P2-2: §1.3 Intent Statement's "不是要做的" list is comprehensive but could explicitly call out "不动 deprecation.yaml" since it has a literal `additionalContext` mention.

`.tad/deprecation.yaml:73` says "additionalContext injection removed (passive mode)" — this is **documenting** the removal, intentionally, as part of the v2.8.4 deprecation manifest. The fresh grep will surface it. To preempt Blake's "should I clean this up?" question, add to §1.3 "不是要做的" list: "❌ 不动 deprecation.yaml line 73 — that comment IS the v2.8.4 deprecation note, removing it would lose the audit trail".

### P2-3: NFR1 (Backward Compat) is technically correct but reads as confusing.

Line 192: "修改后旧的 acceptance test runs（pre-cleanup commits）仍能在 git checkout 历史 commit 后跑 — 不删 stdout-parsing 的 fallback 不必要..." — the logic is sound (acceptance tests are version-bound) but the prose is hard to parse. Suggest rewriting to: "**NFR1 (Backward Compat)**: Acceptance tests are version-bound by design. After this handoff lands, running an old `git checkout <pre-cleanup-commit>` and executing its tests will work (because the old commit's hook still emits stdout). The new (post-handoff) consumer code does NOT need a stdout-parsing fallback — the version coupling between hook and consumer makes that unnecessary." Same content, clearer flow.

### P2-4: Ongoing-symmetry-enforcement (P1-1 option 1) timing — if Blake adds a release-runbook step, the handoff needs an FR6.

If P1-1 option 1 is accepted, scope grows to 6 files (release-runbook gets 2 distinct edits — FR3 hook-output migration + FR6 byte-symmetry check). AC11 ("exactly 5 files") would need to stay at 5 because release-runbook is one file with 2 edits. But AC11 could be misread. Suggest changing AC11 to: "exactly 5 files modified (release-runbook may have 2 distinct edit regions: passive-mode smoke test + symmetry CI check)". Or: defer P1-1 option 1 to a follow-up handoff and keep this one at exactly 5 files.

---

## Overall Assessment

**CONDITIONAL PASS** — handoff is fundamentally sound (Path A architecture is correct, FR1-3 patches are well-grounded against verified `.router.log` format, FR4-5 symmetric prose is the right call), but **3 P0 issues must be fixed before Blake starts** to prevent (a) Blake mistakenly modifying the 4 legitimate non-UserPromptSubmit `additionalContext` files, (b) Blake editing the wrong section of Alex SKILL via the off-by-1000-lines citation, and (c) AC13 producing false-positive failures that block Gate 3.

**Critical confirmation**: AC13 fresh grep dogfood **PASSES** in the sense that no UserPromptSubmit consumer was missed by the 5-file scope. The Cleanup Scope-Estimation Drift Pattern lesson is honored — the 3 dangling consumers (FR1/FR2/FR3) cover all real consumers. The 4 "extra" files surfaced by the grep (startup-health.sh, common.sh, post-write-sync.sh, alex/SKILL.md SessionStart references) are **legitimate other-hook use, not dangling consumers**.

The handoff's gate4_delta tracking from the prior cleanup correctly self-prescribed AC13 + AR-001 P6-A.2 ≥2 reviewers — this review is doing exactly what those captured lessons demanded. No additional 4th-file scope miss exists.

---

**File**: `/Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/reviews/blake/pre-publish-cleanup/backend-architect.md`
**Reviewer**: backend-architect
**Status**: CONDITIONAL PASS — fix P0-1, P0-2, P0-3 before Blake starts
