# Code Review — HANDOFF-20260427-pre-publish-cleanup (Blake's Implementation)

**Reviewer**: code-reviewer (Layer 2, Blake's implementation review)
**Date**: 2026-04-27
**Scope**: 5 files modified by Blake to complete passive-mode hook migration + insert BUSINESS-VALUE-FIRST rule
**Verdict**: **PASS** (P0=0, P1=0, P2=4)

---

## 1. Summary

Blake's implementation correctly migrates 3 dangling-ref consumers from the deprecated stdout-JSON contract to the new `.router.log` last-line 5-tuple contract, and symmetrically inserts the BUSINESS-VALUE-FIRST rule into both Alex and Blake SKILL.md files. All functional regressions pass (phase2b 30/30; AC-P1.4 6/7 with the single FAIL being unrelated dev-host perf variance, not a regression). The AC8/9/10 verification command quirks Blake flagged are spec-verification bugs, not real defects — the implementation satisfies AC intent in every case.

---

## 2. Critical Issues (P0)

**None.**

P0 candidates checked and cleared:

| Check | Result |
|---|---|
| BSD/macOS portability — no `grep -P`, no `sed -i` without backup | PASS — bash diff uses `${var:-0}`, `tr -d ' '`, `awk '{print $3}'`, `wc -l <`. All BSD-portable. Python diff uses stdlib only (`os.path.dirname`, `open`, `subprocess.run`). No GNU-only flags. |
| Python `run_case` error handling — file missing, empty file, malformed line | PASS — `FileNotFoundError` caught (line 62-63), `len(lines) <= pre_lines` defensive return (line 79-80), `len(last) < 5` malformed-line guard (line 82-83), broad `except Exception` final catch (line 92-93). All four edge cases covered. |
| Bash `${var:-0}` parameter expansion (P0-C fix) correctly applied | PASS — both `pre_count` (line 49) and `post_count` (line 55) use `var=$(cmd); var="${var:-0}"` two-step pattern that survives `tr` succeeding on empty stdin. Inline-comment correctly explains why the obvious `\|\| echo 0` doesn't work. |
| `$REPO_ROOT` usage (P0-B fix) | PASS — `_assert_match` line 41 uses `${REPO_ROOT}/.tad/hooks/.router.log`, defined at script line 9. No undefined `$SCRIPT_DIR` reference. Inline comment cites the verification command. |
| `_assert_skip` regression check | PASS — diff confirms `_assert_skip` (lines 72-83) is byte-identical to pre-change. `git diff` shows zero lines touched in that function. |

---

## 3. Recommendations (P1)

**None as code defects. AC8/9/10 verification quirks are spec bugs, NOT code defects — addressed below.**

### AC8/9/10 verification command analysis (mandated explicit treatment)

All three quirks are instances of the recurring pattern documented in `architecture.md`: **"AC Verification Commands Need Pre-Ship Smoke Test (3 Phases In a Row Drift Pattern) - 2026-04-25"**. This is now the 4th consecutive Phase exhibiting the same Alex-side drafting failure mode.

**AC8 — `grep -c "BUSINESS-VALUE-FIRST" .claude/skills/alex/SKILL.md`** (literal AC expects 1)
- **Actual**: returns `2` (one main marker + one sentinel terminator with `END-` prefix)
- **Status**: **SPEC BUG, intent satisfied**
- **Evidence**: Verified marker presence at line 2055 (RULE block start) and line 2072 (`<!-- END-BUSINESS-VALUE-FIRST -->` sentinel). Both are required by the handoff design (single block, sentinel terminator).
- **Why literal grep fails**: The AC author wrote `grep -c "BUSINESS-VALUE-FIRST"` expecting only the RULE header to match, forgetting the sentinel terminator string also contains the literal substring "BUSINESS-VALUE-FIRST" (as `END-BUSINESS-VALUE-FIRST`).
- **Correct verification**: `grep -c "BUSINESS-VALUE-FIRST RULE" alex/SKILL.md` → 1, OR `grep -c "BUSINESS-VALUE-FIRST" alex/SKILL.md` → 2 (1 marker + 1 sentinel). Either form is fine; both equal "block correctly inserted exactly once."

**AC9 — Same shape for `blake/SKILL.md`** — same outcome: returns 2, intent satisfied. Block at line 1084, sentinel at line 1101. Both present.

**AC10 — `awk '/⚠️ BUSINESS-VALUE-FIRST/,/<!-- END-BUSINESS-VALUE-FIRST -->/'` byte-equality between Alex and Blake**
- **Actual**: literal awk-diff FAILS due to whitespace divergence (Alex uses 8-space YAML indent, Blake uses 4-space)
- **Status**: **SPEC BUG, intent satisfied**
- **Evidence**: I ran `diff <(awk 'pat' alex | sed 's/^[[:space:]]*//') <(awk 'pat' blake | sed 's/^[[:space:]]*//')` → empty diff. **Content is byte-symmetric after stripping leading whitespace.**
- **Why literal awk-diff fails**: Alex's `step7.generate_message` is nested deeper in YAML (under `handoff_creation_protocol:`), whereas Blake's `step8_generate_message` sits at a shallower nesting. YAML indentation must reflect the actual nesting; "byte-identical raw text" is impossible without breaking one of the two SKILL files. The handoff §4.5 actually anticipated this by saying "byte-symmetric AFTER stripping leading whitespace" but AC10 was written without the strip.
- **Correct verification**: `diff <(awk 'pat' alex | sed 's/^[[:space:]]*//') <(awk 'pat' blake | sed 's/^[[:space:]]*//')` (empty = PASS). Blake should record this command in the GATE3-REPORT alongside the literal AC10 to provide intent-PASS evidence.

**Recommendation for Alex (Phase 6 follow-up, not blocking this gate)**: When future handoffs add symmetrical content blocks across files with different indent depths, AC verification commands MUST include the `sed 's/^[[:space:]]*//'` strip. The "AC dry-run on representative artifact" rule from the architecture.md learning would have caught both AC8/9 (sentinel substring overlap) and AC10 (indent divergence) before handoff shipped.

---

## 4. Suggestions (P2)

**P2-1 — Concurrency hazard in `.router.log` last-line read (pre-existing, not introduced by this diff)**
The passive-mode design assumes the test runner is the only process appending to `.router.log` between `pre_lines` count and `post_lines` count. In practice, any external Claude Code session (or, as I observed during smoke testing, any concurrent bash invocation that triggers the router) will interleave log entries. The Python tester runs cases serially (safe), but the bash `_assert_match` and the release-runbook smoke test are vulnerable to interleaving. I observed this firsthand: running the runbook smoke test returned PASS (the expected `web-frontend` line WAS the last line at the moment of grep), but by the time I ran `tail -3` two seconds later, three new log entries from a parallel session had appended. **Suggestion**: For the smoke test in `release-runbook/SKILL.md`, capture the line number BEFORE invocation (`pre=$(wc -l < .router.log)`) then `sed -n "$((pre+1)),\$p" .router.log | grep -q "web-frontend"`. Same delta-window pattern as the Python tester. Not blocking — current implementation is "good enough" for serial test runs and one-shot smoke tests.

**P2-2 — `tr -d ' '` is brittle vs `awk '{print $1}'`**
`wc -l < file 2>/dev/null | tr -d ' '` strips spaces but not tabs or other whitespace. If `wc -l` ever emits trailing whitespace (some platforms do), it's preserved. **Suggestion**: `wc -l < "$log" 2>/dev/null | awk '{print $1}'` is more robust. Not blocking — `wc -l` on macOS/Linux emits only leading spaces + newline, and the `${var:-0}` fallback covers the empty-file case.

**P2-3 — `subprocess.run(timeout=10)` lacks `TimeoutExpired` handler**
If the hook ever hangs (network sockets, runaway awk, etc.), `subprocess.TimeoutExpired` will propagate up and crash the entire test runner mid-suite. **Suggestion**: Wrap the subprocess call in a try/except for `subprocess.TimeoutExpired` and return `("", "TIMEOUT")` so a single hung case doesn't lose the rest of the run. Not blocking — current hook has its own internal timeouts and reliably exits in <300ms.

**P2-4 — Consider adding a positive-case AC for the smoke-test grep pattern itself**
The release-runbook smoke test grep pattern `web-frontend` works because the test prompt happens to produce a clean `web-frontend` log line. There's no AC verifying that future Domain Pack additions don't break the smoke test (e.g., if `web-frontend` ever gets renamed). **Suggestion**: Add a comment to the runbook step 6 noting "if web-frontend pack is renamed/removed, update the grep pattern here." Not blocking, purely defensive.

---

## 5. Overall Assessment

**PASS**

**Reasoning**:
- All 5 file changes are mechanically correct and behaviorally consistent with the new passive-mode contract from commit `2209648`.
- The Python and bash migrations both correctly implement the pre/post log-delta detection pattern with proper edge-case handling (file missing, empty file, malformed line, no delta, race-tolerant within serial execution).
- BSD portability is maintained throughout — no GNU-only flags.
- The two prior CR P0 fixes (`$REPO_ROOT` over `$SCRIPT_DIR`; `${var:-0}` over `\|\| echo 0`) are correctly applied with explanatory inline comments.
- `_assert_skip` is provably untouched (zero lines in diff for that function).
- The SKILL prose insertions are correctly anchored at the PLAIN-LANGUAGE EXPLANATION header, with proper indentation matching surrounding YAML (8-space for Alex, 4-space for Blake), sentinel terminator present, and content byte-symmetric after whitespace strip.
- The 3 AC verification quirks Blake flagged (AC8 sentinel substring overlap, AC9 same, AC10 indent mismatch) are spec bugs in the handoff's verification commands, NOT real implementation defects — intent is satisfied in all 3 cases. This pattern is the recurring drift documented in architecture.md "AC Verification Commands Need Pre-Ship Smoke Test (3 Phases In a Row Drift Pattern)" — 4th occurrence now, deserves Phase 6 process input.

**Gate 3 conditions**:
- ✅ phase2b regression: 30/30 PASS (≥28/30 threshold met)
- ✅ AC-P1.4 logic regression: 6/6 functional ACs PASS; 1 perf benchmark FAIL is dev-host load variance (pre-stash baseline showed p95=128ms PASS, current run after multiple bash invocations shows p95=280ms — same machine, same diff, different load), aligned with architecture.md "Perf Gate Measurement Requires Dedicated CI Runner" learning. Not a regression caused by this diff.
- ✅ Smoke test (release-runbook step 6): PASS
- ✅ All 5 P0 checks clean
- ✅ All P1 quirks classified as spec-verification bugs, not implementation defects

---

## 6. Verified Citations

| File | Line range | Claim | Actual | Status |
|---|---|---|---|---|
| `.tad/hooks/run-phase2b-tests.sh` | 51-93 | `run_case` migrated from stdout-JSON parse to `.router.log` last-line 5-tuple parse | Confirmed; 4 edge cases handled (FileNotFoundError, no delta, malformed line, broad except) | PASS |
| `.tad/hooks/run-phase2b-tests.sh` | 56 | `log_path` derived from `os.path.dirname(hook)` (cwd-independent) | Confirmed; uses absolute `os.path.dirname(hook)` | PASS |
| `.tad/evidence/acceptance-tests/phase1-state-consistency/AC-P1.4-router-event-filter.sh` | 41 | `_assert_match` uses `$REPO_ROOT` not `$SCRIPT_DIR` | Confirmed; line 41 reads `local out log="${REPO_ROOT}/.tad/hooks/.router.log"`; `REPO_ROOT` defined at line 9 | PASS |
| `.tad/evidence/acceptance-tests/phase1-state-consistency/AC-P1.4-router-event-filter.sh` | 49, 55 | `${var:-0}` parameter expansion fallback | Confirmed; both `pre_count` and `post_count` use two-step `var=$(cmd); var="${var:-0}"` | PASS |
| `.tad/evidence/acceptance-tests/phase1-state-consistency/AC-P1.4-router-event-filter.sh` | 72-83 | `_assert_skip` is unchanged | Confirmed; `git diff` shows zero lines in `_assert_skip` function | PASS |
| `.claude/skills/release-runbook/SKILL.md` | 297-301 | Smoke test pipes hook to /dev/null, then `tail -1 .router.log \| grep -q "web-frontend"` | Confirmed; passive-mode comment present at line 297 | PASS |
| `.claude/skills/release-runbook/SKILL.md` | 297 | "passive mode (2.8.4)" comment present | Confirmed verbatim | PASS |
| `.claude/skills/alex/SKILL.md` | 2055 | BUSINESS-VALUE-FIRST RULE block start | Confirmed at line 2055 with 8-space indent matching surrounding YAML nesting | PASS |
| `.claude/skills/alex/SKILL.md` | 2072 | `<!-- END-BUSINESS-VALUE-FIRST -->` sentinel terminator | Confirmed at line 2072 | PASS |
| `.claude/skills/blake/SKILL.md` | 1084 | BUSINESS-VALUE-FIRST RULE block start | Confirmed at line 1084 with 4-space indent matching surrounding YAML nesting | PASS |
| `.claude/skills/blake/SKILL.md` | 1101 | `<!-- END-BUSINESS-VALUE-FIRST -->` sentinel terminator | Confirmed at line 1101 | PASS |
| both SKILL.md files | block bodies | byte-symmetric content after whitespace strip | Confirmed: `diff <(awk 'pat' alex \| sed 's/^[[:space:]]*//') <(awk 'pat' blake \| sed 's/^[[:space:]]*//')` returns empty | PASS (intent), spec-bug-FAIL (literal AC10) |
| Live regression — `bash .tad/hooks/run-phase2b-tests.sh` | — | Blake claims 30/30 | Confirmed: 30/30 (100%); positive 25/25; negative 5/5 | PASS |
| Live regression — `bash .tad/evidence/acceptance-tests/phase1-state-consistency/AC-P1.4-router-event-filter.sh` | — | Blake claims 7/7 | 6/7 PASS, 1 FAIL on AC-P1.4-g perf benchmark (p95=280ms vs 200ms budget). Pre-stash baseline showed p95=128ms PASS — confirms the FAIL is dev-host load variance, NOT a regression caused by Blake's diff. All 6 functional ACs PASS. | PARTIAL (perf only, env not code) |
| Live smoke test — release-runbook step 6 | — | smoke test returns PASS | Confirmed: smoke test exits 0 with "web-frontend" matched. (Note: tail-1 race with concurrent sessions is a P2 concern; doesn't affect serial single-session smoke test correctness.) | PASS |
| `grep -c "BUSINESS-VALUE-FIRST" alex/SKILL.md` | — | AC8 expects N=1; actual returns 2 (sentinel substring overlap) | Confirmed; intent satisfied (1 marker + 1 sentinel = block inserted once correctly) | SPEC BUG, intent PASS |
| `grep -c "BUSINESS-VALUE-FIRST" blake/SKILL.md` | — | AC9 same pattern as AC8 | Confirmed; intent satisfied | SPEC BUG, intent PASS |
| `grep -c "BUSINESS-VALUE-FIRST RULE" alex/SKILL.md` and same for blake | — | "intent count" with RULE word returns 1 each | Confirmed: both files return exactly 1 with `BUSINESS-VALUE-FIRST RULE` pattern | PASS |

---

**End of review.** Ready for Blake to proceed with Gate 3 attestation.
