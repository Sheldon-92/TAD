# Test Coverage Assessment — trace-instrumentation-fix
**Reviewer:** test-runner
**Date:** 2026-05-30
**Artifact:** `.tad/hooks/post-write-sync.sh` (5 new parse helpers + 4 modified case arms) + `.tad/hooks/lib/trace-writer.sh`
**Method:** Static analysis of hook branches against the 10 acceptance tests documented in `.tad/evidence/acceptance-tests/trace-instrumentation-fix/acceptance-verification-report.md`

---

## Overall Verdict

PASS — with documented gaps. The hard requirement of "never fail-closed" (NFR1) is satisfied across all reachable paths. No uncovered branch will cause hook exit non-zero or produce invalid JSONL. The gaps below are data-completeness and behavioral-parity issues, not correctness or safety issues. For a single-user CLI hook whose primary contract is fault tolerance, coverage is adequate. The gaps are low-probability in normal practice and none represent a regression risk to existing functionality.

---

## What Is Well-Covered

The 10 acceptance tests adequately cover the high-probability paths:

- The primary dedup mechanism for `handoff_created` and `task_completed` was tested under repeated fires (test 1, test 4).
- The `gate_result` emit/skip/override logic was tested with `pass` as first emit and `partial` as verdict change (test 4), plus real-trace dogfood via the handoff's own completion (test 8). The `fail` verdict was not tested as a first emit but the code path is identical to `pass` — only the string value differs after the `case "$verdict" in pass|fail|partial` guard.
- The `expert_review_finding` counter correctly excludes prose "no P-zero issues" text and the `gate3-verdict.md` special case (test 5).
- The `reflexion_diagnosis` parser emits correctly from `## Reflexion History` blocks and deduplicates by `(slug, what_failed)` on re-fire (test 6).
- The fault injection suite (test 7) validates NFR1 across malformed COMPLETION inputs including embedded pipe characters, newlines, non-UTF8 bytes, and bogus confidence values.
- The context truncation regression is covered with a 250-character stress test verifying `detail_level=full` and downstream `fromjson` compatibility (test 8, regression note).
- Consumer compatibility via `dream-scanner.sh` exit 0 on all four new event types is verified (test 9).

---

## Coverage Gaps (numbered, lowest risk first)

**1. `HAS_JQ=false` shell-fallback paths are entirely untested.**

There are seven `if [ "$HAS_JQ" = true ]` branches in the new and modified code: `gate_result_should_emit`, `reflexion_already_emitted`, `trace_decision_point`, `trace_reflexion_diagnosis`, `trace_knowledge_extraction`, `record_trace`, and `output_response`. None of the 10 tests exercised the `HAS_JQ=false` path. In this developer environment `jq` is present (`/usr/bin/jq 1.7.1`), so the fallback is unreachable in normal use. Risk is therefore low in practice. However, the `reflexion_already_emitted` fallback (lines 115–117) has a behavioral discrepancy relative to the jq path: the shell fallback uses `grep -qF "$ewf"` which is a substring match, whereas the jq path uses `grep -Fxq` which is an exact-line match. A `what_failed` value of `"tsc"` would be considered already-emitted by the shell path if the trace contains an entry with `what_failed="tsc: missing type"`, but not by the jq path. This divergence would produce a false dedup under `HAS_JQ=false`, silently suppressing a new distinct reflexion event. Not a fail-closed issue, but a data-loss inconsistency between environments.

**2. Legacy empty-slug paths are untested (lines 273 and 287).**

When `extract_slug` returns empty — triggered by a `HANDOFF-*.md` or `COMPLETION-*.md` filename that does not match the `HANDOFF/COMPLETION-YYYYMMDD-slug.md` contract — the hook falls through to a legacy `record_trace` call with no `TRACE_SLUG`. For the COMPLETION arm, `emit_gate_result` and `emit_reflexions` are then effectively skipped (both guard on `[ -n "$slug" ] || return 0`). This means a COMPLETION file with an unusual timestamp format (e.g., a COMPLETION-20260530T1200-slug.md where the separator isn't a plain hyphen) would have its `gate3_verdict` and `## Reflexion History` data silently dropped. No test fired the hook with a deliberately malformed filename to confirm the legacy path exits cleanly and that the trace file stays valid JSONL after the no-slug emit.

**3. Override markers other than `用户选` are untested.**

The `case "$c $r" in` actor-detection block (line 205) defines four markers: `用户选`, `"user chose"`, `"human override"`, and `人类决策`. Only `用户选` was exercised in test 3. The English-language markers and `人类决策` are not covered. Since the logic is a single `case` arm with `|`-joined patterns, a copy-paste error in any of the untested variants would go undetected. This is a low-risk gap given the patterns are syntactically simple, but the omission means the English-marker variant has no behavioral proof.

**4. `decision_point` rows added in a second HANDOFF edit are silently dropped.**

The dedup guard at line 269 (`if ! trace_already_emitted "decision_point" "$_slug"`) prevents re-emission on every subsequent write to the same HANDOFF file. The comment at line 268 describes this as handling "the '§11 added in a later edit' case", but the guard's effect is the opposite: once any `decision_point` for that slug exists today, `emit_decision_points` is entirely skipped on the next write. Any new rows added by a second edit that same day are never captured. No test verified what happens to rows added after first emission — whether they are silently dropped or re-captured. This is a design gap (data completeness), not a safety gap.

**5. `expert_review_finding` has no dedup guard and was not tested for re-fire.**

`emit_expert_findings` calls `trace_expert_finding` with no check against today's trace. If Blake edits a review file after initial write (to correct a typo or add a paragraph), the hook fires again and emits duplicate `expert_review_finding` events with the same reviewer and slug. Test 4 verified the initial emission but did not re-fire the same review file to check the duplicate behavior. The consequence is inflated finding counts in `dream-scanner` analyses.

**6. The anti-recursion guard for `*.tad/evidence/traces/*` was not explicitly tested.**

The comment at line 328 marks this arm as CRITICAL because `record_trace` itself writes to the traces directory, and without this guard the hook would recurse. The guard is correctly ordered before `*.tad/evidence/*` in the case statement and exits with `output_empty`. However, no test verified that writing to `.tad/evidence/traces/` actually hits this arm and returns cleanly rather than the catch-all. The static `bash -n` and `shellcheck` passes (test 1) confirm syntactic correctness but not execution path routing.

**7. `reflexion` block missing its `confidence:` field is silently dropped.**

The `emit_reflexions` awk block (lines 227–229) only flushes a collected block when `confidence:` is encountered. A `## Reflexion History` block with `what_failed`, `root_cause_hypothesis`, and `revised_approach` fields but no `confidence:` line will accumulate state but never emit, and the partial state is lost when parsing moves to the next block or end of file. No test exercised this structural omission. The consequence is a silent data loss of a reflexion entry that an agent wrote without the confidence field.

---

## Notes on Items Confirmed Adequate

The fault injection suite (test 7) provides strong coverage for NFR1. The embedded-pipe, newline, and non-UTF8 fixture tests directly validate the "never fail-closed" requirement at the boundary where malformed agent output enters the parsers. The meta-dogfood test (test 8) adds external confidence that the `gate3_verdict` round-trip works end-to-end against a real COMPLETION file. The `shellcheck -S warning` pass (test 1) catches portability issues at the static level, reducing the chance of uncaught behavioral differences between BSD and GNU environments.
