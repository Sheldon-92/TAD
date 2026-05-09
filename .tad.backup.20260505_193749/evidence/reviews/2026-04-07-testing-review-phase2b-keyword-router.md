# Testing Review — Phase 2b Keyword Router Hook

| Field | Value |
|---|---|
| Reviewer role | test-runner (Gate 3 mandatory) |
| Task ID | TASK-20260407-004 |
| Review date | 2026-04-07 |
| Artifacts reviewed | `userprompt-domain-router.sh`, `generate-keywords.sh`, `keywords.yaml`, `phase2b-integration-test.md` |
| Evidence verified | Live execution during review (not paper-only) |

---

## §1 Overall Verdict

**CONDITIONAL PASS**

The test suite is substantially adequate for production shipping with one required fix (regression runner) and two advisory improvements. All critical safety behaviors (always-exit-0, kill-switch, privacy, injection safety) were independently verified live during this review. The 30-case integration test report shows credible real-execution evidence. The single gap that blocks a clean PASS is the absence of a standalone regression test runner script — the test data exists but there is no mechanism for a future developer to rerun the battery after modifying the hook.

---

## §2 Evidence of Real Execution Assessment

**PASS — evidence is genuine, not paper artifact.**

Verification points observed in `phase2b-integration-test.md`:

1. **Tuning rounds show real discovery process.** Round 1 at 11/30 (36.7%) with documented root causes (hyphen vs space, threshold too strict, missing synonyms) is the strongest signal of actual execution. A paper artifact would start at 30/30.
2. **Latency measurements are consistent with the described architecture.** Cold start 148ms, warm 74-84ms median. The analysis correctly attributes the variance to `yq` startup cost (~40ms per invocation). The 7-9x improvement from grep-loop to awk is internally consistent and plausible.
3. **TC14 failure in Round 2 identifies a specific non-obvious substring mismatch.** `prompt 漂移` failing against "我的 prompt 总是漂移" (because `总是` interrupts the compound) and the fix of adding standalone `漂移` is the kind of detail only discovered by running real tests.
4. **Privacy canary output `grep -c SECRET-CANARY .tad/hooks/.router.log` returning 0** was independently reproduced during this review — the log line for that call reads `2026-04-07T23:36:18-0400 46 none 0 31` (31 = byte length of the canary JSON payload, no content).
5. **AC trace table maps 22 ACs to specific file lines/commands**, not to vague claims.

---

## §3 Test Coverage Assessment

### 3.1 What was tested (verified or replicated)

| Test category | Cases | Independently verified |
|---|---|---|
| Integration: happy-path positive | 20 | Sample replicated (TC01, TC04, TC08, TC14, TC25, TC28) |
| Integration: adversarial cross-match | 5 | TC17, TC22 replicated |
| Integration: negative (expected NONE) | 4 | TC12, TC18, TC23, TC24 replicated |
| Integration: whitelist early-exit | 1 | TC30 replicated |
| Bad input behavioral (AC10) | 5 | All 5 replicated: `not json`, `""`, `{"prompt":null}`, `{"prompt":""}`, `{}` |
| Shell injection safety | 1 | Replicated with backtick command substitution; target file survived |
| Kill-switch: env var | 1 | Replicated with `TAD_DOMAIN_ROUTER=off` |
| Kill-switch: marker file | 1 | Replicated with `.router-disabled` touch/rm cycle |
| Kill-switch: recovery after reset | 1 | Verified: correct match resumes after marker removal |
| Privacy canary | 1 | Replicated: `grep -c SECRET-CANARY .router.log` = 0 |
| Latency n=5 | 5 | Replicated: median 88ms vs reported 84ms (within variance) |
| Corrupt/missing keywords.yaml | implicit | yq error path returns `{}`, pack count = 0, exits 0 |
| Missing yq/jq dependency | 1 | Replicated: PATH restricted to /usr/bin:/bin → exits 0 silently |
| Non-UTF8 locale forced | 1 | C locale override; hook overrides to en_US.UTF-8 correctly |
| Very long prompt (12KB+) | 1 | NEW: replicated during this review (see §4) |
| Concurrent invocations | 3 | NEW: replicated during this review (see §4) |

### 3.2 Coverage for a bash hook (no pytest/jest applicable)

The handoff's claim that traditional unit tests are "not strictly applicable" is correct for this task type — the production artifact is a bash script with no importable function surface. The appropriate test methodology for this artifact is:

- **Behavioral I/O testing**: feed input JSON, observe stdout + side effects (log, exit code). This is exactly what was done.
- **State transition testing**: kill-switch on/off, dependency missing, file missing. All tested.
- **Integration testing against the real keywords DB**: the 30-case battery tests the full pipeline including the live YAML.

The test suite adequately covers the meaningful behaviors for this artifact type. Coverage gaps (§4) are edge cases that do not affect the critical path.

---

## §4 Coverage Gaps by Severity

### P1 — Required fix before production shipping

**GAP-1: No standalone regression runner script**

Severity: P1 (blocks long-term maintainability, not production shipping).

The test data exists in machine-readable form:
- `.tad/hooks/.phase2b-testset.tsv` — 30 cases, columns: `id`, `expected_pack`, `input_text`
- `.tad/hooks/.phase2b-testresults.tsv` — 30 cases, columns: `id`, `expected`, `actual`, `ratio`, `result`

During this review, a replay runner was constructed ad-hoc from `.phase2b-testset.tsv` and produced 29/30 PASS (the one "failure" was a false negative in the runner's multi-pattern logic for TC29 `_any_hw_fw_or_circuit` — the hook correctly returned `hw-firmware`; the runner's grep did not handle `_or_` compound patterns). The test data is correct; the runner just does not exist as a persistent artifact.

**Required fix**: create `.tad/hooks/run-phase2b-tests.sh` as a standalone executable that reads `.phase2b-testset.tsv` and invokes the hook for each case. Any developer modifying `userprompt-domain-router.sh` or `keywords.yaml` should be able to run `bash .tad/hooks/run-phase2b-tests.sh` and see `30/30 PASS` within 60 seconds.

Without this script, the 30-case battery is documentation, not a regression harness.

---

### P2 — Advisory (should add, does not block shipping)

**GAP-2: Concurrent log rotation race condition (untested)**

Severity: P2.

The log rotation at lines 237-241 of `userprompt-domain-router.sh` has a TOCTOU window:

```bash
if [ -f "$LOG_FILE" ]; then
  log_size=$(wc -c < "$LOG_FILE" ...)
  if [ "${log_size:-0}" -gt "$LOG_ROTATE_BYTES" ]; then
    mv "$LOG_FILE" "${LOG_FILE}.1" ...   # ← two processes can both reach this mv
  fi
fi
```

If two hook invocations simultaneously read `log_size > 1MB` and both execute `mv "$LOG_FILE" "${LOG_FILE}.1"`, the second `mv` silently overwrites `.router.log.1`. The log itself is never corrupted (the subsequent `printf >>` creates a new file), but the previous `.router.log.1` backup is silently lost. This is a **data integrity edge case for the log backup only** — it does not affect hook correctness, user experience, or the primary log append.

During this review, 3 concurrent invocations produced 3 clean log lines with zero corruption. The race is only observable at the 1MB rotation boundary under concurrent load. Low severity, but worth a comment in the code at minimum.

**Advisory fix**: add an `flock`-guarded rotation, or accept the known limitation and document it at the rotation code block.

**GAP-3: Very long prompts (>10KB) tested live but not in the battery**

Severity: P2 (informational — gap filled during this review).

A 12,014-byte prompt (`react ` repeated 2000 times) was tested live during this review. The hook completed in 88ms and exited 0. The `awk index()` approach scales linearly with message length (no quadratic behavior). This is within spec.

**Advisory fix**: add one long-prompt case (e.g., 10KB input, expected NONE) to the test battery to formalize what was verified informally.

**GAP-4: Non-UTF8 / binary garbage in prompt field (untested in battery)**

Severity: P2 (informational — tested live, not in battery).

Input with bytes `\xff\xfe\x00\x01` preceding "react button" produced exit 0 during this review. Input with a null byte `\x00` mid-prompt also exited 0. The `jq -r '.prompt // empty'` extraction handles these via jq's JSON parser, which discards or handles invalid UTF-8 gracefully at the jq layer. Result is correct (no crash, no injection).

**Advisory fix**: add one binary/non-UTF8 case to the battery with expected `exit 0, no output`.

---

### P3 — Informational only

**GAP-5: settings.json uses relative path, not absolute path**

The handoff §4.2 specified `bash '/Users/sheldonzhao/01-on progress programs/TAD/.tad/hooks/userprompt-domain-router.sh'` (absolute path). The actual settings.json contains `bash .tad/hooks/userprompt-domain-router.sh` (relative). This is consistent with all five other hook commands in settings.json and with how Claude Code appears to resolve paths (relative to project root). The `$SCRIPT_DIR` computation in the hook script uses `$(cd "$(dirname "$0")" && pwd)` which correctly resolves to the absolute directory regardless of how the script is invoked. **No functional problem identified.** Worth noting for documentation alignment.

**GAP-6: `perl` as timing dependency**

The hook uses `perl -MTime::HiRes=time` for millisecond timestamps (lines 39, 86, 227). If `perl` is absent, the fallback is `echo 0` (all latencies log as 0). This is not a correctness issue (the hook still functions and exits 0), but the latency measurement in logs becomes useless on a perl-free system. The dependency check on lines 50-52 only checks `jq` and `yq`. The battery does not test the perl-absent path.

**Informational only** — perl ships with macOS and is the only realistic target platform per the handoff. No action required.

---

## §5 Claim Verification: "Traditional Unit Tests Not Applicable"

The handoff §10.3 claim is **substantively correct** but the framing understates the quality of testing that IS applicable.

Accurate restatement: "Traditional framework-based unit tests (pytest, jest, JUnit) are not applicable because the artifact is a bash script with no importable module surface. The equivalent testing methodology for bash hooks is behavioral I/O testing: feed structured input, assert stdout content, exit code, and side effects (log entries, file state). This methodology was applied."

The 30-case I/O battery, the 9 smoke tests, the 5 bad-input tests, the kill-switch tests, the privacy canary, and the latency measurements together constitute a comprehensive functional test suite appropriate for this artifact type. The labeling of "no traditional unit tests" should not be read as "light testing" — the coverage is thorough for the risk profile of a deterministic bash hook.

---

## §6 Regression Safety Assessment

**Partial PASS** — limited to existence of test data.

Current state:
- Test data exists: `.phase2b-testset.tsv` (30 cases, machine-readable) and `.phase2b-testresults.tsv` (30 cases with ratio)
- No standalone runner script exists
- The test commands in `phase2b-integration-test.md` are copy-pasteable but not executable as a single command

A developer modifying `keywords.yaml` today would need to manually reconstruct the runner from the documentation before knowing if their change caused regressions. This is the primary gap.

After GAP-1 is addressed (runner script), regression safety will be **PASS**: the 30-case battery with TSV ground truth is an adequate regression harness for this class of artifact.

---

## §7 Summary Table

| Criteria | Status | Notes |
|---|---|---|
| Test coverage adequacy | PASS | Comprehensive for bash hook artifact type |
| Evidence of real execution | PASS | Tuning rounds, specific failure analysis, independent replication |
| Test independence and determinism | PASS | I/O tests are stateless; each case is independent |
| Happy path coverage | PASS | 20 happy-path cases across 5 domain families |
| Failure mode coverage | PASS | Bad input, kill-switch, missing deps, corrupt YAML all covered |
| Regression safety (runner exists) | FAIL | GAP-1: no `run-phase2b-tests.sh` script |
| Concurrency safety | PASS with caveat | Log rotation race is benign (backup loss only); append-level tested clean |
| Privacy compliance | PASS | Canary test verified live |
| Injection safety | PASS | Command substitution test verified live |

---

## §8 Recommendation

**Test suite is adequate for production shipping of the hook.**

The hook's core behaviors — correct pack matching, always-exit-0, kill-switch, privacy, injection safety — are thoroughly verified. The 30-case battery with 100% accuracy across 3 tuning rounds demonstrates the keyword database quality.

**Required before closing this task (P1):**

Create `.tad/hooks/run-phase2b-tests.sh` as a standalone regression runner that reads `.phase2b-testset.tsv` and asserts each case against the live hook. This is the minimum artifact needed to prevent keyword database regressions from going undetected in Phase 3 and beyond. Estimated implementation effort: 30 minutes. The test data and expected logic are fully defined — only the wrapper script is missing.

**Advisory (P2, can be done in Phase 3 or alongside the runner):**

- Add a long-prompt case and a binary-input case to the test battery
- Add a comment at the log rotation block documenting the benign TOCTOU race

---

**End of testing review**
