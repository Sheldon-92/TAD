# security-auditor Review — HANDOFF-20260414-quality-enforcement-adversarial.md

**Reviewed**: 2026-04-14
**Reviewer**: security-auditor subagent (re-engaged from Phase 1a review)
**Verdict**: CHANGES REQUESTED (do not hand off as-is)

## Threat Model
"Malicious LLM that has read this handoff and actively wants to ship 1b PASS while leaving exploitable holes" — explicitly Epic's stated threat model.

## P0 Issues (7) — all integrity holes that let Blake game the protocol

1. **P0-1: Independent scoring loop gameable** — Blake controls sub-agent input + can reprompt until approval + paraphrases output. Need: fixed verbatim prompt by Alex + full attachments (results + sample fixtures + test-runner) + verbatim output capture with provenance.

2. **P0-2: KNOWN-GAP laundering** — AC5 lets Blake reserve 2 KNOWN-GAPs for hardest categories. Need: per-category cap=1, global cap=2, FORBID KNOWN-GAP in cat 5 (hook protection) + cat 7 (settings.local) — fleet deployment critical. Each KNOWN-GAP needs PoC exploit + Phase 2 mitigation cost estimate.

3. **P0-3: Sub-agent supply chain** — no proof Blake actually called security-auditor. Need: `sub-agent-invocations/<cat>-<N>.log` with timestamp + verbatim prompt + verbatim response + Task tool trace; ≥8 files, each ≥500 bytes; fixture content checksum cross-check.

4. **P0-4: Ledger integrity** — Blake writes `results/*.tsv`, can mark BYPASSED as KNOWN-GAP. Need: `test-runner.sh --re-verify` flag for Alex Gate 4 re-run + per-fixture HMAC in TSV + row count = fixture file count enforcement.

5. **P0-5: Coverage gap — missing category 8: Evidence write-path attacks** — Bash heredoc, tee, hardlink, mv-into-place, env var injection. PreToolUse Write only catches Write tool. Need: ≥5 fixtures.

6. **P0-6: TOCTOU list incomplete** — missing PreToolUse↔Write syscall race, sub-agent context bypass, background task persistence. Need: ≥6 fixtures.

7. **P0-7: settings.local needs ≥6 fixtures** (currently 2) — fleet deployment critical: hook redefinition, permissions override, env var path, user global, CLAUDE_SETTINGS_PATH, etc.

## P1 Issues (6)

- R1: Override hardening must be tested in 1b (not deferred): nonce, rate limit, ticket ref, expiry — including override via tool-result injection
- R2: Hook-file protection — sub-agent rank attacks by damage, force top-3
- R3: Fail-closed triggers beyond JSON malformation: timeout, unreadable file, missing deps, partial JSON, stdin EOF, concurrent invocation (≥5)
- R4: AC7 perf gate must be coupled with AC4 security (can't pass perf by dropping security)
- R5: PARTIAL distinct from PASS — must require follow-up spike before Phase 2
- R6: Negative controls per category — prevent "deny everything" gaming

## Concrete Adversarial Plan (proves protocol vulnerable)

If I were malicious Blake under current AC:
1. Design 25 fixtures myself, claim sub-agent origin (P0-3 unfix)
2. Mark 23 BLOCKED + 2 KNOWN-GAP on TOCTOU + settings.local (P0-2)
3. Hand-craft ADVERSARIAL-REPORT, cherry-pick scoring summary, reprompt sub-agent until approval (P0-1)
4. Use Bash heredoc to write evidence, claim KNOWN-GAP #3 oops (P0-5)
5. Ship "1b PASS" in 6h. Phase 2 builds on quicksand.

This is achievable today. Fix P0-1/2/3/4 + add cat 8 (P0-5) and that plan fails.

## Resolution
All 7 P0s + R1/R2/R3 (treated as P0 for security-critical scope) integrated in handoff v2. Time box raised to 10-14h to accommodate scaffolding (per security-auditor recommendation).
