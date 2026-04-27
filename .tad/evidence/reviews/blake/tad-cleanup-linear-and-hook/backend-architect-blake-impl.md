# Backend Architect Review — Blake Implementation Diff

**Reviewer:** backend-architect (Layer 2, post-implementation)
**Handoff:** HANDOFF-20260427-tad-cleanup-linear-and-hook.md
**Scope:** 7-file diff committed as Phases 1-5 of the cleanup
**Date:** 2026-04-27

---

## 1. Summary

Blake's 7-file diff faithfully executes the Alex-specified deletions and structural moves; the YAML dedent is correct and `tad.sh::apply_deprecations` parses the new `files: []` entry safely. **However, 3 P0 cross-reference defects exist** — all of them are STALE CONSUMER references to behavior the cleanup just removed (one in a hook regression test runner, one in a Phase 1 acceptance test, one in the release runbook smoke test). These files are not in the 7-file scope, but they will silently break or false-fail the next time anyone runs the test/release pipeline. **Verdict: CONDITIONAL PASS — the in-scope work is correct, but follow-up is needed in 3 out-of-scope files before the next release.**

---

## 2. Critical Issues (P0)

### P0-1. `run-phase2b-tests.sh` parses `hookSpecificOutput.additionalContext` from hook output → 0/30 after passive switch

**Location:** `.tad/hooks/run-phase2b-tests.sh:64`

**Code:**
```python
ctx = d.get("hookSpecificOutput", {}).get("additionalContext", "")
m = re.search(r"Pack \[([^\]]+)\]", ctx)
```

**Behavior change:** The Phase 2b regression test runner parses `additionalContext` to extract the matched pack name and matched/total ratio. Blake's hook now emits NOTHING (the entire `if [ -n "$BEST_PACK" ]; then jq -nc ... fi` block was deleted). Every test case will receive empty stdout → empty `actual` → 0/30 PASS — exit 1.

**Why P0:** This is the canonical regression suite cited by the spike (`evidence/phase2b-integration-test.md`) and runs on every keywords.yaml change. After this commit, the test cannot distinguish a real regression from passive-mode-as-designed. It will produce false FAILs forever.

**Fix recommendation:** Either (a) update `run-phase2b-tests.sh` to parse the new log file `.tad/hooks/.router.log` (each line records `<ts> <ms> <pack> <matched/total> <msglen>`), or (b) add a `TAD_DOMAIN_ROUTER_TEST_EMIT=1` env var to the hook that re-enables additionalContext output for test mode only. Option (a) is cleaner because the log file is the new source of truth for "what the router thought."

---

### P0-2. `AC-P1.4-router-event-filter.sh` `_assert_match` greps for `additionalContext` → all positive cases now FAIL

**Location:** `.tad/evidence/acceptance-tests/phase1-state-consistency/AC-P1.4-router-event-filter.sh:41`

**Code:**
```bash
if [ -n "$out" ] && printf '%s' "$out" | grep -q 'additionalContext'; then
  printf '[PASS] %s (hook emitted hookSpecificOutput)\n' "$name"
```

**Behavior change:** Phase 1 P1.4 acceptance test asserts that real user prompts cause the hook to emit `additionalContext`. With the passive-mode change, hook stdout is now always empty in normal-prompt cases. `_assert_match` cases will all fail; `_assert_skip` cases will still pass (no output for system-injected prompts is the same outcome with or without the injection block).

**Why P0:** This is a committed acceptance test for Phase 1 — re-running it as part of any future regression gate or `*reproduce` will report the file as failing, which is a noisy false alarm and erodes trust in the AC suite.

**Fix recommendation:** Either (a) update `_assert_match` to grep for the new log line in `.tad/hooks/.router.log` instead (positive cases write a log line with non-`none` pack name), or (b) mark the AC as superseded by the passive-mode change with a comment block at the top of the file pointing to deprecation.yaml 2.8.4. Option (a) preserves the regression coverage; option (b) acknowledges the AC's intent is no longer applicable. Either is acceptable.

---

### P0-3. `release-runbook/SKILL.md` per-project smoke test pipes hook into `grep -q "web-frontend"` → entire fleet smoke test fails

**Location:** `.claude/skills/release-runbook/SKILL.md:296-300`

**Code:**
```bash
echo '{"prompt":"做一个 React button 组件","session_id":"","transcript_path":"","cwd":"","permission_mode":"","hook_event_name":"UserPromptSubmit"}' \
  | bash "$project/.tad/hooks/userprompt-domain-router.sh" \
  | grep -q "web-frontend"
```

**Behavior change:** The "Final step: per-project verification checklist" §"6. Live smoke test" pipes hook stdout into `grep -q "web-frontend"` to confirm the hook works on each downstream project. Hook stdout is now always empty → grep -q returns 1 → smoke test fails for every project in `sync-registry.yaml` on the next release. Per the runbook's own rule: "Anything not green → **do not close the release**". The runbook will block all future releases.

**Why P0:** This is the highest-blast-radius P0 — the very next `*publish` or `*sync` cycle will report the smoke test as RED for every downstream project (menu-snap, OpenClaw, sober-creator, etc.) and block the release with no clear failure signal (the runbook hasn't been updated to expect empty output).

**Fix recommendation:** Update the smoke test to read `.tad/hooks/.router.log` after invoking the hook:
```bash
echo '{"prompt":"做一个 React button 组件",...}' \
  | bash "$project/.tad/hooks/userprompt-domain-router.sh" >/dev/null
# Hook is passive; verify via log file
tail -1 "$project/.tad/hooks/.router.log" 2>/dev/null | grep -q "web-frontend"
```
Plus a one-line note above the snippet explaining "passive mode (2.8.4): hook does not emit context, log file is the smoke-test target."

---

## 3. Recommendations (P1)

### P1-1. `.tad/config.yaml` v2.4.0 changelog still advertises Linear features as current

**Location:** `.tad/config.yaml:320-321`
```yaml
- "Linear Kanban Integration: Cross-project human dashboard via Linear MCP"
- "Linear Auto-Sync: NEXT.md → Linear one-way sync on Alex startup"
```

These lines describe v2.4.0 changelog entries — they are HISTORICAL records of what was added in 2.4.0, not active feature advertisements. **Strictly correct to leave as-is** (changelogs preserve historical state, like the Backup Files Are Expected Exceptions principle from `.tad/project-knowledge/architecture.md`). However, a forward-looking reader scanning config.yaml for "what does this framework do now?" will see these lines without the 2.8.4 deprecation context.

**Proposed fix:** Add a `v2.8.4` changelog entry stating "Linear integration removed (cleanup); Domain Pack hook switched to passive mode" to provide forward context. Do NOT delete the v2.4.0 lines — they are accurate history.

### P1-2. `tad-help/SKILL.md` advertises Domain Pack hook as "Auto-Loading" — now misleading

**Location:** `.claude/skills/tad-help/SKILL.md:222`
```
- **Domain Pack Auto-Loading Hook**: UserPromptSubmit hook + keyword router (20 packs, 100% acc / 81ms, no LLM)
```

After the cleanup, the hook is **passive** — it scores and logs but does not auto-load (does not inject anything that causes Alex/Blake to load the pack). The "Auto-Loading" label now overstates the feature. Users reading `*help` will form an inaccurate mental model.

**Proposed fix:** Change to "**Domain Pack Discovery Hook**: UserPromptSubmit keyword router scores + logs matched packs (passive). Pack loading is agent-judgment via SessionStart pack catalog." This matches the actual passive-mode behavior described in the new hook comment.

### P1-3. Two IDEA files (`linear-auto-sync`, `linear-kanban-for-human`) are status:promoted but the work they describe is now retired

**Locations:**
- `.tad/active/ideas/IDEA-20260325-linear-auto-sync.md:5` (`Status: promoted`)
- `.tad/active/ideas/IDEA-20260325-linear-kanban-for-human.md:5` (`Status: promoted`)

These ideas were promoted to handoffs in 2026-03-25, the handoffs were completed and archived, and the resulting feature has now been cleanly removed (this handoff). Per the Lifecycle Chain Closure pattern (architecture.md 2026-02-16), the lifecycle should be `captured → evaluated → promoted → archived` — these files should now be marked `archived` (and ideally moved to `.tad/archive/ideas/`) to reflect that the underlying functionality no longer exists.

**Proposed fix:** Update Status field to `archived` on both files; add a `Retired-In: 2.8.4` line referencing deprecation.yaml; optionally move to `.tad/archive/ideas/`. Not a blocker for this handoff but should be tracked as cleanup follow-up.

### P1-4. `linear-seed-issues.md` is orphaned in `.tad/active/`

**Location:** `.tad/active/linear-seed-issues.md` (unrelated artifact, exists since 2026-03-25)

This file is seed data for Linear issues that no longer have a TAD-managed sync target. It's not in the 7-file scope and Blake correctly didn't touch it, but as long as it lives in `.tad/active/`, future readers may assume Linear sync is active. This is the same anti-pattern as P1-3 (stale active artifacts implying live functionality).

**Proposed fix:** Move to `.tad/archive/notes/` or delete entirely if no longer needed. Mention in deprecation.yaml 2.8.4 `note:` block.

### P1-5. `deprecation.yaml` 2.8.4 entry uses `files: []` inline form — works with tad.sh but is non-standard for the file

**Location:** `.tad/deprecation.yaml:62`
```yaml
files: []  # No standalone files removed; changes are within existing files
```

Verified empirically: `tad.sh::apply_deprecations` correctly handles this — it only matches the `files:\s*$` pattern (newline-terminated) for entering "in_files=1" state, and the inline `files: []` does not match, so no spurious file deletion happens. `yq` also handles it cleanly (zero iterations on `.files[]`).

However, this is the FIRST entry in the file using inline empty list rather than line-by-line list. The `note:` field below is also new (no prior entry has it). Both work, but adding a brief comment in `release-runbook/SKILL.md` "Top 10 Gotchas" section noting "deprecation.yaml entries with `files: []` mean 'in-place edits only — no file removal'" would prevent future maintainers from mistaking the entry for a malformed one and trying to "fix" it.

**Proposed fix:** Add a one-paragraph note in the release-runbook gotchas section about the `files: []` + `note:` convention. Not blocking.

### P1-6. Hook passive-mode comment block is correct but missing forward-looking note

**Location:** `.tad/hooks/userprompt-domain-router.sh:224-226`
```bash
# ─── Passive mode (TAD 2.8.4): no context injection emitted. Score + log only.
#     Agent decides Pack loading via *discuss / *design self-judgment.
#     See deprecation.yaml entry 2.8.4 for rationale.
```

This is good — it cites the version + the alternative mechanism + the rationale source. One small enhancement: the architecture.md 2026-04-15 lesson ("Mechanical Enforcement Rejected on Single-User CLI") is the deeper "why this design pattern exists" reference. A future reader who sees only "passive mode" without that lesson may be tempted to "re-enable injection because it would be more helpful" — exactly the AR-001 attack surface that the lesson addresses.

**Proposed fix:** Append a line: `#     Pattern: smoke-alarm > automatic-extinguisher (project-knowledge/architecture.md 2026-04-15).` This makes the future-edit-temptation directly traceable to the prior decision.

---

## 4. Suggestions (P2)

### P2-1. SessionStart-based Domain Pack discovery now carries 100% of the load — worth a knowledge entry

The cleanup removes one of two parallel pack-discovery channels (UserPromptSubmit injection). The other channel — SessionStart `additionalContext` injecting the pack catalog (line 84 of `startup-health.sh`) — is now load-bearing for Alex's `domain_pack_awareness` and step1_5 logic. This isn't broken (verified the SessionStart code still emits the pack catalog), but the architectural shift "two channels → one channel" is significant enough to warrant a project-knowledge/architecture.md entry. Future cleanup that touches `startup-health.sh` will need to know the SessionStart channel is now the sole pack-discovery point.

### P2-2. Consider whether `.tad/sync-registry.yaml` needs a 2.8.4 marker

The sync-registry tracks `last_synced_version` per project. After this commit, downstream projects sync'd at 2.8.3 will retain stale Linear references (in their copies of alex/SKILL.md, config-platform.yaml, etc.). The next `*sync` cycle will fix this, but the state is "downstream is currently inconsistent with source-of-truth until next sync." Worth flagging in the user-facing release notes.

### P2-3. Hook trace in passive mode still records pack scoring — evolves into useful future signal

The hook's `.router.log` now records pack scoring on every prompt with no user-visible side effect. Over weeks/months, this log becomes valuable training data for "did Alex actually decide to load the pack the keyword router thought was relevant?" — a future Epic could compare log entries to evidence/decisions/*.jsonl entries to measure keyword-router precision/recall in the wild. This is the strongest argument for the passive-mode design, beyond just "stop being annoying." Worth capturing as an Idea (`*idea`) for future analysis.

---

## 5. Cross-Reference Sweep

Searches were conducted across `.claude/`, `.tad/` (excluding `/archive/` and `.tad.backup*`), `CLAUDE.md`, `NEXT.md`, `PROJECT_CONTEXT.md`, `ROADMAP.md`. Results table:

| Search Pattern | Files Searched | Hits Found (excluding handoff/reviews/archive) | Status |
|----------------|----------------|-----------------------------------------------|--------|
| `linear_integration` | All `.md`/`.yaml`/`.sh` | 0 in active code; 1 in deprecation.yaml note (intentional) | ✅ Clean |
| `step0b_evidence_check` | All `.md`/`.yaml`/`.sh` | 0 in active code; only in deprecation.yaml note + 1 IDEA file | ✅ Clean |
| `step4b_linear_sync` | All `.md`/`.yaml`/`.sh` | 0 in active code; only in deprecation.yaml note + 1 IDEA file (P1-3) | ✅ Clean |
| `STEP 3.7` | All `.md`/`.yaml`/`.sh` | 0 in active code; only in pre-handoff reviews + handoff itself | ✅ Clean |
| `Linear sync` (string) | `.tad/hooks/`, `.claude/skills/`, evidence | 1 hit at `.tad/evidence/acceptance-tests/TASK-20260331-002/AC-all-verify.sh:50` (legacy AC for the now-changed hint) | ⚠️ stale but in committed AC scripts — see addendum below |
| `additionalContext` (assumed from hook) | hooks + acceptance tests | **2 active consumers found** (P0-1 `run-phase2b-tests.sh:64`, P0-2 `AC-P1.4-router-event-filter.sh:41`) | ❌ **P0** |
| `Pack [` (reminder text consumers) | hooks + skills + evidence | Only in `startup-health.sh` (SessionStart, intentional) and reviews | ✅ Clean |
| `检测到任务匹配 Domain Pack` | All | 0 in production code; 1 mention in pre-handoff backend-architect review | ✅ Clean |
| Hook output piped to `grep` | release-runbook + active hooks | **1 active consumer at `release-runbook/SKILL.md:299`** (`grep -q "web-frontend"`) | ❌ **P0** |
| `domain_pack_awareness` reads `additionalContext` from where? | alex/SKILL.md | Line 561 says "from SessionStart additionalContext" — SessionStart hook still emits this | ✅ Safe |
| `step1_5 Domain Pack Loading` reads from where? | alex/SKILL.md | Line 1540-1541 says "from session start context" — SessionStart hook still emits this | ✅ Safe |
| `domain_pack_auto_load` rationale reference | alex/SKILL.md:1031 | Says "keywords.yaml does not auto-fire on protocol routing" — text becomes MORE accurate post-cleanup | ✅ Safe (bonus) |
| `Auto-Loading` claim about hook | tad-help/SKILL.md | **1 hit at line 222** — describes the hook as "Auto-Loading" which is no longer accurate | ⚠️ **P1-2** |
| `Linear` in v2.4.0 changelog | config.yaml | Lines 320-321 (intentional history) | ⚠️ **P1-1** (cosmetic) |
| `Linear` in NEXT.md `Recently Completed` | NEXT.md | Lines 134, 136, 172, 173 (history of past work) | ✅ Acceptable (historical) |
| Existence of `.tad/active/linear-seed-issues.md` | filesystem | Orphaned artifact (P1-4) | ⚠️ **P1-4** |
| `tad.sh::apply_deprecations` parses `files: []` correctly | simulation harness | Yes — `files:\s*$` regex doesn't match inline `files: []`, so zero spurious deletions; `yq .files[]` returns 0 iterations cleanly | ✅ Safe |
| `yq . .tad/deprecation.yaml` valid YAML | yq parse | Exit 0; entry well-formed | ✅ Safe |
| `additionalContext` in `claude/settings.json` UserPromptSubmit consumer | settings.json | Hook is registered as `command` type; no consumer in settings.json reads the output | ✅ Safe (Claude Code itself is the consumer; see Phase 1 spike) |
| Mid-line "linear" string false-positives | full grep | Filtered out: `linear-gradient`, `Linear-style`, sklearn `linear_model`, `non-linear`, etc. — all unrelated to Linear-app | ✅ Confirmed unrelated |

**Addendum on AC-all-verify.sh:50:** This is in `.tad/evidence/acceptance-tests/TASK-20260331-002/` — a 2026-03-31 acceptance test predating both the keyword router and Linear integration changes. It tests the OLD post-write-sync.sh emission ("NEXT.md detection + sync reminder") looking for the literal string `"Linear sync"`. Now Blake's change emits just `"NEXT.md updated."` — so AC5 of that test will fail. Categorized P1 not P0 because TASK-20260331-002 is a closed/archived task and its AC script is unlikely to be re-run, but worth flagging.

---

## 6. Overall Assessment

**Verdict: CONDITIONAL PASS**

**In-scope work (the 7-file diff):** Clean, faithful execution of Alex's spec. YAML dedent is correct; all 3 SKILL.md deletion regions match the cited line ranges; the hook's passive-mode comment block correctly cites deprecation.yaml 2.8.4 + alternative mechanism; tad.sh correctly parses the new `files: []` form.

**Out-of-scope blast radius:** 3 P0 stale-consumer references exist in files Blake correctly did not touch (they were not in the handoff scope). All three rely on the now-deleted `additionalContext` injection from the hook. Two are test scripts (will silently false-FAIL on next regression run), one is the release runbook smoke test (will block the entire fleet release on next `*publish` or `*sync`).

**Conditions for clearing the conditional pass — pick ONE of these paths:**

- **Path A (preferred, low friction):** Add a follow-up handoff (~30 min) that updates the 3 P0 consumers to read from `.tad/hooks/.router.log` instead of parsing `additionalContext` from stdout. Same handoff can address P1-1 through P1-4 (changelog entry, tad-help wording, IDEA archival, linear-seed-issues cleanup). Single-pass cleanup of all stale references.

- **Path B (acceptable but deferred):** Accept this commit as PASS with explicit user acknowledgment of the 3 P0s; defer the consumer updates to "the next time someone tries to run those tests/release." The risk: the next `*publish` will hit P0-3 first and require an emergency in-flight fix.

- **Path C (not recommended):** Re-enable `additionalContext` output via a `TAD_DOMAIN_ROUTER_TEST_EMIT=1` env var so existing tests pass unchanged. This re-introduces the very behavior the cleanup intentionally removed and complicates the passive-mode mental model.

**Recommendation: Path A.** The follow-up handoff is small (3 file edits, ~50 lines of changes total) and prevents the release-pipeline failure that Path B will eventually trigger.

**Note on Layer 2 dogfooding:** This review was conducted by `general-purpose` subagent (acting as backend-architect persona) because the user's prior reviewer-quota deadlock pattern (see project-knowledge/architecture.md "honest_partial_protocol Real Use - 2026-04-25") may apply if `code-reviewer` subagent quota is also exhausted. Per `hard_requirement_distinct_reviewers`, the code-reviewer review of this same diff must be conducted independently; this review covers the architectural / cross-reference dimension only.
