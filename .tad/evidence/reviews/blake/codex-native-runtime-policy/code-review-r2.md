# Code Review Round 2: Phase 2 Codex Native Runtime Policy

**Reviewer**: code-reviewer (TAD Layer 2 Group 1)
**Date**: 2026-06-09
**Round**: R2 (post P1-fix verification)
**Artifacts reviewed**:
- `.tad/evidence/designs/codex-native-runtime-policy.md`
- `.tad/evidence/designs/codex-runtime-candidates/config.toml.draft`

---

## Fix Verification

| R1 Finding | Severity | Fix Applied? | Verification Detail | Status |
|------------|----------|-------------|---------------------|--------|
| #1 (P2): Session-local `/tmp/` path in YAML summary | P2 | Yes | `grep '/tmp/' policy.md` returns zero matches. Line 18 now reads `manual_source: "local cache via fetch-codex-manual.mjs (11935 lines)"` — machine-specific path replaced with reproducible description. | VERIFIED |
| #3 (P2→P1): `web_search` TOML scoping under `[agents]` | P1 | Yes | `web_search = "cached"` moved to line 19 of `config.toml.draft`, between `approval_policy` (line 16) and `[features]` (line 22). `tomllib.load()` confirms parsed structure: `web_search` is a root-level key, not under `agents` or `features`. Matches documented intent in policy.md Config Policy table (line 107). | VERIFIED |
| #2 (P1): Sandbox boundary matrix "User-Owned" contradicts Risk #4 | P1 | Yes | Line 66 boundary matrix row now reads: `Sandbox filesystem | Policy | Stricter override | Yes | TAD needs workspace-write for evidence/code; user may override with stricter mode in ~/.codex/config.toml (higher-precedence config wins)`. This is consistent with Risk #4 (line 318) which describes the same override behavior. The matrix, rationale, and risk section are now aligned. | VERIFIED |
| #7 (P1): `askuser-capture.sh` impact understated for quality chain | P1 | Partial | Line 169 (Hooks Policy decision #5) correctly upgraded: "this IS an evidence-completeness gap in the quality chain, not merely a convenience loss. Medium-priority: Phase 5 regression must verify." **However**, line 322 (Risks and Unknowns section, Unknown #1) still reads: "Impact: loss of decision capture, not quality chain." This directly contradicts the fixed text at line 169. See New Finding #1 below. | PARTIAL — stale reference at L322 |

### Fix Verification Summary

- 3 of 4 fixes fully verified (including the bonus `/tmp/` path fix).
- 1 fix partially applied: the primary location (L169) is correct but a second reference (L322) was not updated, creating an internal contradiction.

---

## New Findings

| # | Severity | Location | Finding | Recommendation |
|---|----------|----------|---------|----------------|
| R2-1 | P1 | policy.md L322 | **Stale `askuser-capture.sh` impact statement contradicts L169 fix**. Line 322 reads: "Impact: loss of decision capture, not quality chain. Phase 5 should verify." Line 169 (the R1 P1 fix) reads: "this IS an evidence-completeness gap in the quality chain." These two lines directly contradict each other within the same document. A reader encountering L322 first would get the wrong risk assessment. | Update L322 to: "Impact: evidence-completeness gap in the quality chain (decision provenance lost). Medium-priority Phase 5 verification required — adapt matcher or implement alternative capture path." This aligns with the authoritative statement at L169. |

No other new P0 or P1 issues found. Security re-check clean: zero secrets, personal paths, or account-specific values in any draft file.

---

## R1 P2 Findings Status (8 items, acknowledged)

These were not blocking and are not re-checked in R2, per standard protocol:

| R1 # | Summary | Status |
|-------|---------|--------|
| #1 | Session-local `/tmp/` path | Fixed (promoted above) |
| #3 | `web_search` TOML scoping | Fixed (promoted above) |
| #4 | Unverified Codex manual line reference (L2111) | Acknowledged — Phase 4 freshness |
| #5 | `[[skills.config]]` undocumented TOML schema | Acknowledged — Phase 5 verify |
| #6 | Agent drafts lack `model_provider` field | Acknowledged — Phase 5 verify |
| #8 | No output_format/max_tokens guidance for agents | Acknowledged — Phase 5 regression |
| #9 | `memories = false` stale-knowledge drift risk | Acknowledged — rationale enhancement |
| #10 | `max_threads`/`max_depth` default vs recommendation ambiguity | Acknowledged — clarification |

---

## Counts

| Severity | R1 Count | R2 Count | Delta |
|----------|----------|----------|-------|
| P0 | 0 | 0 | -- |
| P1 | 2 | 1 | -1 (2 R1 P1s resolved; 1 new P1 from incomplete R1 fix) |
| P2 | 8 | 0 new | -- (8 carried, acknowledged) |

---

## Verdict: FAIL (conditional)

P0 = 0, P1 = 1. The single remaining P1 is a one-line text fix at L322 (align with L169). No structural, TOML, security, or architectural issues.

**To pass**: Update line 322 of `codex-native-runtime-policy.md` to replace "Impact: loss of decision capture, not quality chain" with language consistent with line 169's corrected assessment. After this fix, R3 can be a spot-check (verify L322 only) rather than a full re-review.
