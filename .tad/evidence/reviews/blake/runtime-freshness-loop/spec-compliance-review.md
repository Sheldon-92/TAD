# Spec Compliance Review: Phase 4 Runtime Freshness Loop

**Reviewer:** Spec-compliance verifier (Gate 3 sub-agent)
**Date:** 2026-06-09
**Handoff:** HANDOFF-20260609-runtime-freshness-loop.md, Section 9.1
**Files Under Review:**
- `.tad/runtime-compat/codex.md`
- `.tad/runtime-compat/claude-code.md`
- `.tad/hooks/lib/runtime-freshness-verify.sh`
- `.tad/hooks/lib/release-verify.sh`

---

## AC Compliance Table

| AC# | Criterion | Verdict | Evidence |
|-----|-----------|---------|----------|
| 1 | `codex.md` exists | SATISFIED | File present at `.tad/runtime-compat/codex.md`, 36 lines, contains platform header, drift policy, and 12-row ledger table. |
| 2 | `claude-code.md` exists | SATISFIED | File present at `.tad/runtime-compat/claude-code.md`, 31 lines, contains platform header, drift policy, and 9-row ledger table. |
| 3 | Both include drift response policy | SATISFIED | Both files contain `## Drift Response Policy` sections with 3-step detect/evaluate/adopt-defer lifecycle, fail-closed rule, and recheck triggers. |
| 4 | Both include all required fields | SATISFIED | Both ledger table headers contain all 11 FR5-required fields: `surface, owner, current_behavior, source, runtime_version, last_verified, volatility, next_review, regression_required, fallback_behavior, status`. Every data row populates all 11 columns (no empty required fields). |
| 5 | Codex ledger includes all required Codex surfaces (12) | SATISFIED | All 12 surfaces from handoff section 4.2 present: `skill_loading`, `agents_guidance_AGENTS_md`, `hooks`, `subagents_custom_agents`, `mcp`, `config_toml`, `sandbox_approval_permissions`, `codex_cloud`, `context_compaction`, `trace_evidence_capture`, `release_sync_install`, `ask_user_question_hook`. Verified via `grep "| <surface> |"` on each. |
| 6 | Claude Code ledger includes all required surfaces (9) | SATISFIED | All 9 surfaces from handoff section 4.3 present: `skill_loading`, `hooks_settings`, `workflows`, `agent_tool_subagents`, `mcp`, `permissions`, `context_compaction`, `trace_evidence_capture`, `release_sync_source`. Verified via `grep "| <surface> |"` on each. |
| 7 | `ask_user_question_hook` represented as unresolved, accepted_limitation, fallback-covered, regression-required | SATISFIED | Entry has: `status=accepted_limitation`, `regression_required=yes`, `fallback_behavior="Conversational questioning + manual decision evidence; evidence-completeness gap documented"`, `current_behavior="Codex has no exact AskUserQuestion tool equivalent; askuser-capture.sh hook may never fire; decision provenance lost"`. All four criteria met: unresolved (no equivalent exists), accepted_limitation (status), fallback-covered (fallback_behavior populated), regression-required (yes). |
| 8 | `runtime-freshness-verify.sh` exists and is executable | SATISFIED | File at `.tad/hooks/lib/runtime-freshness-verify.sh` exists. `test -x` confirms executable bit set. 175 lines, includes `#!/usr/bin/env bash` shebang. |
| 9 | Verifier exits 0 on current ledgers | SATISFIED | `bash .tad/hooks/lib/runtime-freshness-verify.sh . 2026-06-09` output: `Total: 21 entries | PASS: 21 | WARN: 0 | BLOCK: 0`, `VERDICT: runtime freshness PASS`, exit code 0. |
| 10 | Verifier exits 1 on high-volatility stale fixture | SATISFIED | Created temp fixture with codex `hooks` surface `last_verified=2026-04-01` (69 days old, >30 threshold). Output: `BLOCK [codex] hooks: high-volatility stale (69 days > 30)`, `VERDICT: runtime freshness BLOCK`, `GATE: runtime-freshness exit=1`, exit code 1. |
| 11 | Verifier exits 2 on malformed/missing fixture | SATISFIED | Test A (missing file): Temp dir with no `codex.md` produced `ERROR: missing ledger`, `GATE: runtime-freshness exit=2`, exit code 2. Test B (malformed date): `last_verified=INVALID-DATE` produced `BLOCK [codex] hooks: invalid last_verified date 'INVALID-DATE'`, `GATE: runtime-freshness exit=2`, exit code 2. |
| 12 | `release-verify.sh freshness . 2026-06-09` exits 0 | SATISFIED | `bash .tad/hooks/lib/release-verify.sh freshness . 2026-06-09` output: `Total: 21 entries | PASS: 21 | WARN: 0 | BLOCK: 0`, `VERDICT: runtime freshness PASS`, exit code 0. Freshness mode delegates to `runtime-freshness-verify.sh` correctly. |
| 13 | `release-verify.sh version . 2.26.0` still exits 0 | SATISFIED | `bash .tad/hooks/lib/release-verify.sh version . 2.26.0` output: `(no <old_version> given -- nothing to detect; PASS)`, `VERDICT: version PASS (exit 0)`, exit code 0. No regression. |
| 14 | Existing release-verify usage updated without breaking structural or version | SATISFIED | `git diff HEAD -- release-verify.sh` shows only two additions: (a) usage line for freshness mode, (b) `freshness)` case block (6 lines). No lines removed or modified in `structural` or `version` blocks. `release-verify.sh structural . .` self-diff exits 0. Usage display exits 2 and shows all three modes. |
| 15 | No active `.codex/config.toml` or `.codex/agents/*` created | SATISFIED | `.codex/config.toml` does not exist. `.codex/agents/` directory does not exist. Only `.codex/hooks.json` is present (pre-existing from earlier phases). |
| 16 | No SKILL, hooks.json, version, or changelog modified | SATISFIED | `git diff HEAD` shows zero changes to `.claude/skills/*/SKILL.md`, `.codex/hooks.json`, `.tad/version.txt`, or `CHANGELOG.md`. Only modified tracked file is `.tad/hooks/lib/release-verify.sh` (permitted by handoff). |
| 17 | Layer 2 review P0=0 P1=0 | N/A | Per handoff spec: "N/A for self-review". Deferred to separate Layer 2 review pass. |

---

## Summary

| Category | Count |
|----------|-------|
| SATISFIED | 16 |
| PARTIALLY_SATISFIED | 0 |
| NOT_SATISFIED | 0 |
| N/A | 1 (AC17 deferred per spec) |

---

## Implementation Quality Notes

**Positive observations:**
- Shell script is BSD/macOS safe: uses `date -j -f` (not GNU `date -d`), avoids `grep -P`, no associative arrays.
- Verifier correctly implements three-tier staleness: high >30d BLOCK, medium >60d WARN, low >180d WARN.
- `next_review` overdue logic correctly distinguishes high-volatility (BLOCK) from medium/low (WARN).
- Safety surface fail-closed: `unknown_current_behavior` on safety surfaces triggers BLOCK.
- Output includes `GATE: runtime-freshness exit=<n>` on non-zero, matching the contract spec.
- Release-verify integration is minimal and clean: delegates to the standalone verifier, preserving existing mode isolation.
- Codex `trace_evidence_capture` correctly marked `verified_partial` (not all evidence conventions mapped).
- `ask_user_question_hook` models the Phase 1/2 finding honestly: accepted limitation with regression flag.

**Minor observations (not blocking):**
- The `$FRESH_TODAY` variable in release-verify.sh line 294 is intentionally unquoted to allow the empty-string case to omit the argument. This is correct behavior but may trigger shellcheck SC2086. Consider `${FRESH_TODAY:+"$FRESH_TODAY"}` for defensive quoting if shellcheck is added later.
- Codex `agents_guidance_AGENTS_md` surface name contains uppercase, which is fine for readability but the verifier's `awk` surface extraction is case-sensitive. No bug today but worth noting if future surfaces use mixed case.

---

## Verdict

**PASS** -- 16 of 16 applicable ACs satisfied, 0 NOT_SATISFIED. AC17 is N/A per spec.

Phase 4 implementation is compliant with the handoff acceptance criteria.
