# SPIKE-REPORT: Cross-Model Orchestration Feasibility
**Date:** 2026-05-03
**Spike ID:** SPIKE-20260503-cross-model-orchestration
**Handoff:** HANDOFF-20260503-cross-model-spike.md
**Time Used:** ~15 minutes (well under 60-minute hard cap)
**Executed by:** Blake (TAD v2.8.5)

---

## Verdict: ✅ GO (3/3 PASS)

Both Codex CLI and Gemini CLI are accessible from Claude Code sub-agents, can follow unified output formats, and produce detectable error signals on failure.

---

## Test 1: Gemini CLI 子 Agent 可达性

**Method:**
```bash
# Actual command run (exit code captured via ; echo "EXIT_CODE=$?"):
gemini -p "List 3 advantages of TypeScript over JavaScript. Output as a numbered list, nothing else." 2>&1; echo "EXIT_CODE=$?"
```

**Raw Output (verbatim shell output including captured exit code):**
```
1. Static typing allows for catching errors at compile-time rather than runtime.
2. Enhanced IDE support provides superior autocomplete, navigation, and refactoring tools.
3. Explicit type annotations improve code readability and long-term maintainability.
EXIT_CODE=0
```

**Judgment:**
| Criterion | Result |
|-----------|--------|
| exit code = 0 | ✅ PASS |
| stdout contains ≥3 numbered items | ✅ PASS (3 items) |
| No auth error / quota error | ✅ PASS |

**Test 1 Result: ✅ PASS**

**Notes:**
- Gemini CLI v0.39.1 at `/opt/homebrew/bin/gemini`
- `-p` flag is required for non-TTY mode (as handoff noted)
- No `--skip-trust` needed in this directory
- Response latency: fast (~3s)

---

## Test 2: 统一输出格式 — Codex + Gemini 同一 Review Prompt

**Review prompt:** SQL injection + weak token vulnerability code (`login()` function with f-string query and base64 password token).

### 2a: Gemini Review

**Method:**
```bash
# Actual command run (exit code captured via ; echo):
cat /tmp/review-prompt.txt | gemini -p "respond to the review request from stdin" 2>&1; echo "GEMINI_EXIT_CODE=$?"
```

**Raw Output:**
```
## Findings
| # | Severity | Issue | Suggestion |
|---|----------|-------|------------|
| 1 | P0 | SQL Injection vulnerability: raw user input is interpolated directly into the query string. | Use parameterized queries or an ORM to safely handle user input. |
| 2 | P0 | Sensitive data exposure: the user's plaintext password is included in the base64-encoded token. | Use secure session identifiers or JWTs that do not contain sensitive credentials. |
| 3 | P0 | Insecure password handling: the query suggests passwords are stored and compared in plaintext. | Store passwords using strong cryptographic hashes (e.g., Argon2, bcrypt) and verify them using secure comparison functions. |
| 4 | P1 | Hardcoded "never" expiration for tokens increases the risk of account takeover if a token is compromised. | Implement short-lived tokens with a defined expiration time and a secure refresh mechanism. |
| 5 | P2 | Missing imports: `base64` is used but not imported in the provided snippet. | Add `import base64` at the top of the module. |

## Summary
- P0 (must fix): 3
- P1 (should fix): 1
- P2 (nice to have): 1
```

### 2b: Codex Review

**Method:**
```bash
cat /tmp/review-prompt.txt | codex exec --full-auto -
CODEX_EXIT_CODE=0
```

**Raw Output (sanitized — removed internal session header and trailing log):**
```
## Findings
| # | Severity | Issue | Suggestion |
|---|----------|-------|------------|
| 1 | P0 | SQL injection via f-string interpolation of `username` and `password` into the query | Use parameterized queries/prepared statements |
| 2 | P0 | Token contains base64-encoded username and password, which is reversible and exposes credentials | Generate a random signed session token or JWT without embedding the password |
| 3 | P1 | Passwords appear to be compared directly against stored plaintext values | Store password hashes using a strong password hashing algorithm such as Argon2id or bcrypt |
| 4 | P1 | Token never expires | Add a reasonable expiration time and server-side revocation support |
| 5 | P2 | `SELECT *` fetches unnecessary data | Select only the required columns |

## Summary
- P0 (must fix): 2
- P1 (should fix): 2
- P2 (nice to have): 1
```

**⚠️ Codex stderr noise:** `ERROR codex_core::session: failed to record rollout items: thread ... not found` appears but does not affect output and exit code is 0. This is a benign internal Codex logging issue (also observed in Phase 2 dogfood). Downstream consumers should filter stderr or check exit code, not absence of stderr.

**Judgment:**
| Criterion | Gemini | Codex |
|-----------|--------|-------|
| Returns markdown table format | ✅ PASS | ✅ PASS |
| Identifies SQL injection (P0) | ✅ PASS | ✅ PASS |
| Identifies token security issue (P0) | ✅ PASS | ✅ PASS |
| Output parseable by grep/awk | ✅ PASS | ✅ PASS |

**Test 2 Result: ✅ PASS (both platforms)**

**Notes:**
- Both models correctly identified the two critical vulnerabilities
- Gemini found more granular P0 issues (3 vs Codex's 2), but core security findings align
- Table structure is identical — same headers, same severity labels
- `grep -i "sql injection\|injection"` would match both outputs reliably
- Codex session header (`workdir:`, `model:`, `tokens used`) is noise but filterable — the actual content starts after the header block

---

## Test 3: Fallback 错误检测

### 3a: Codex with nonexistent model
```bash
codex exec --full-auto --model "nonexistent-model-xyz" "say hello" 2>&1; echo "EXIT_CODE=$?"
```
**Raw Output (relevant portion):**
```
ERROR: {"type":"error","status":400,"error":{"type":"invalid_request_error","message":"The 'nonexistent-model-xyz' model is not supported when using Codex with a ChatGPT account."}}
EXIT_CODE=1
```

### 3b: Gemini with nonexistent model
```bash
gemini -p "test" -m "nonexistent-model-xyz" 2>&1; echo "EXIT_CODE=$?"
```
**Raw Output (relevant portion):**
```
Error when talking to Gemini API ...
ModelNotFoundError: Requested entity was not found.
...code: 404
EXIT_CODE=1
```

### 3c: Bash conditional detection validated
```bash
result=$(codex exec --full-auto --model "nonexistent-model-xyz" "say hello" 2>&1)
exit_code=$?
if [ $exit_code -ne 0 ]; then
    echo "FALLBACK_DETECTED: exit_code=$exit_code"  # ← confirmed printed
    # -E required for | alternation; plain grep treats | as literal (BSD grep on macOS)
    if echo "$result" | grep -qiE "error|invalid|not supported|not found"; then
        echo "ERROR_KEYWORD_FOUND: can classify error type"  # ← confirmed printed
    fi
fi
```
**Output:** Both `FALLBACK_DETECTED` and `ERROR_KEYWORD_FOUND` printed. ✅

**Note:** `-E` flag (extended regex) is required for `|` alternation. Plain `grep -qi "error|invalid"` on macOS BSD grep searches for the literal string `error|invalid` — always use `grep -qiE` or BRE form `grep -qi "error\|invalid"` in production fallback handlers.

**Judgment:**
| Criterion | Codex | Gemini |
|-----------|-------|--------|
| exit code ≠ 0 on failure | ✅ exit 1 | ✅ exit 1 |
| stderr/stdout contains error keyword | ✅ "invalid_request_error" | ✅ "ModelNotFoundError" |
| Blake can detect via bash `[ $? -ne 0 ]` | ✅ confirmed | ✅ confirmed |

**Test 3 Result: ✅ PASS**

**Notes:**
- Error keyword patterns differ between platforms:
  - Codex: `invalid_request_error`, `not supported`, `status:400` (JSON in stderr)
  - Gemini: `ModelNotFoundError`, `Requested entity was not found`, `code: 404`
- For production orchestration, recommend platform-specific error pattern detection rather than a single regex
- Both are detectable via generic `grep -qi "error\|not found\|invalid"` as a simple fallback

---

## Summary

| Test | Result | Key Finding |
|------|--------|-------------|
| Test 1: Gemini CLI Accessibility | ✅ PASS | `-p` flag required, works cleanly in sub-agent/Bash tool |
| Test 2: Unified Format (Codex + Gemini) | ✅ PASS | Both follow markdown table format; both catch SQL injection P0 |
| Test 3: Fallback Error Detection | ✅ PASS | Both return exit code 1; bash conditional detection works |

## Comprehensive Verdict: ✅ GO (3/3)

Cross-model orchestration (Claude=implementation, Codex=review, Gemini=research) is **technically feasible** at the CLI invocation layer.

---

## Architecture Implications for Next Phase

Based on spike findings:

1. **Invocation pattern confirmed:**
   - Codex: `echo "$prompt" | codex exec --full-auto -` (stdin via `-`)
   - Gemini: `echo "$prompt" | gemini -p "respond to the review request from stdin"`
   - Both callable from Blake's Bash tool or Agent tool

2. **Noise filtering needed for Codex (to validate in implementation phase):**
   - Session header (`workdir:`, `model:`, `tokens used`) is always printed before response content
   - **Recommended approach:** Search for first content-signal header (e.g., `## Findings`) and slice from there — more robust than line-count skipping or regex on the session header format
   - Specific filter regex deferred to implementation phase where full unsanitized output can be sampled

3. **Error handling per-platform (use exit code as primary signal):**
   - Exit code is the reliable source of truth — both platforms return exit 1 on failure ✅
   - Error keywords differ: Codex uses JSON stderr (`invalid_request_error`); Gemini uses plain text (`ModelNotFoundError`)
   - **For grep-based classification, always use `-E` flag** (extended regex): `grep -qiE "error|invalid|not found"` — plain `grep -qi` on macOS BSD grep treats `|` as literal
   - Recommended: `if [ $? -ne 0 ]; then` as primary detector; keyword grep as secondary classifier

4. **Gemini CLI flag for non-TTY is mandatory:**
   - Always use `-p` flag; interactive mode hangs in sub-agent context
   - `-m` flag for model selection is supported (for when specific models needed)

5. **Codex internal stderr log is benign (new observation, not in prior dogfood entry):**
   - `failed to record rollout items: thread ... not found` appears in stderr but exit code remains 0
   - **Correct handling:** Use exit code, not stderr absence, as success signal — do not build an allowlist of ignorable stderr lines (brittle; real errors would be swallowed)
   - This is a new behavioral finding beyond the Phase 2 dogfood validation (which only confirmed exit 0 on success)

---

## Limitations

- **N=1 per platform per test.** Format adherence on second/third runs not validated. Test 2 showed one successful structured review each; robustness across temperature variation is unknown.
- **Severity disagreement observed.** Gemini found 3 P0s, Codex found 2 P0s for the same code (disagreement on whether plaintext password storage in DB is P0 or P1). A consensus-review architecture must define a disagreement-resolution policy (majority vote / escalate to human / merge all findings).
- **Only one prompt template tested.** Robustness across review categories (security / performance / style / architecture) is not validated.
- **Session header filter regex not validated.** Codex output includes a preamble header that must be stripped for downstream parsing. The specific filter approach deferred to implementation phase.

---

## What This Enables

Architecture previously blocked on "Gemini CLI not validated" can now proceed:
- TAD 3-platform review workflow: Claude implements → Codex reviews code → Gemini researches alternatives
- Parallel sub-agent calls to Codex + Gemini for cross-model consensus review
- Fallback chain: if Codex fails → use Gemini; if Gemini fails → use Claude internal reviewer

**Recommended next step (if user chooses):** Design the cross-model orchestration protocol in a *discuss session with Alex.
