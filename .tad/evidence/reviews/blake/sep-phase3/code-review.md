# Code Review: Self-Evolution Pruning Phase 3 (FINAL)

**Commit**: `260041d8e91a8188f386d52f46a3c6a94bc06fb6`
**Reviewer**: Code Review Agent (Claude Opus 4.6)
**Date**: 2026-06-10
**Scope**: 24 files changed, +32 / -1872 lines (net -1840)

---

## Summary

Phase 3 removes the retired self-evolution commands (`*dream`, `*evolve`,
`*optimize`, `*skillify`), their 4 protocol reference files, STEPs 3.56/3.57,
the `step4d` acceptance block, and the `trace-digest.sh` helper script.
It replaces the startup-review tax with an explicit-only `*harvest` command
and rewords surviving `*evolve` prose to "cross-project audits". Dual-platform
parity (.claude/ vs .agents/) is maintained. Template additions (carrier line
in completion-report, `materialized_at`/`reference_at` in SCAND) are clean
and well-scoped.

Overall quality: **GOOD** -- the core surgery is clean, parity is verified,
and the preserved `skillify_evaluation` engine (Blake L1839-L1897) is intact.
However, 3 files outside the commit's explicit scope still contain retired
command references that will confuse agents at runtime.

---

## Findings Table

| ID | Severity | File | Line(s) | Finding |
|----|----------|------|---------|---------|
| P1-1 | P1 | `.claude/skills/alex/references/intent-router-protocol.md` | L150 | **Stale retired commands in skip_if list.** The intent-router skip_if list still contains `*dream, *optimize, *evolve` as framework management commands. An agent processing user input `*dream` would match this skip_if rule and silently skip pack loading -- but the command itself no longer exists, so the user gets no feedback. Should be cleaned to remove retired commands. |
| P1-2 | P1 | `.claude/skills/alex/references/intent-router-protocol.md` | L198 | **Stale standby transition for *dream.** `"After *dream completes (promote/skip) -> Enter standby"` references a command that no longer exists. If an agent somehow enters a `*dream` flow, it would look for this standby transition rule for a non-existent protocol. Should be removed. |
| P1-3 | P1 | `.claude/skills/alex/references/accept-command.md` | L251 | **Stale *optimize suggestion in accept output.** The accept command output template says: "Trace data available. Run *optimize to analyze execution history and propose improvements." -- directing users to a retired command. Should be reworded to remove the `*optimize` reference or replaced with a current alternative (e.g., cross-project audit language). |
| P1-4 | P1 | `.tad/templates/handoff-a-to-b.md` | L24 | **Stale *evolve reference in handoff template comment.** Comment reads: "Future *evolve queries use this for cross-project drift detection." Every new handoff created from this template will carry this stale reference. Should be reworded to "cross-project audits" for consistency with the other rewordings in this commit. |
| P2-1 | P2 | `.tad/hooks/lib/askuser-capture.sh` | L103 | **Stale *evolve reference in shell script comment.** "Future *evolve sees 'user picked Other' but never reads what they typed." Low functional impact (comment only, no behavioral change), but creates confusion about what consumes the trace data. Should be reworded for consistency. |
| P2-2 | P2 | `.claude/skills/academic-research/SKILL.md` | L236 | **Stale *optimize reference in capability pack.** "This pack improves via TAD's existing *optimize -> proposal -> human approval -> handoff cycle" references a retired command. This is in a capability pack that downstream projects load; it could prompt users to invoke a non-existent command. Lower severity because it is documentation prose, not protocol logic. |
| P2-3 | P2 | `.claude/skills/blake/SKILL.md` | L1897 | **Retained *skillify reference in forbidden_implementations.** "MUST NOT auto-invoke *skillify without user explicit command (Alex side)" -- `*skillify` is now retired. The constraint is technically correct (you MUST NOT invoke something that does not exist), but the prose is misleading. Could be reworded to reference `*harvest` or removed since the command no longer exists. Note: this is in a `forbidden_implementations` block, so per the principles.md "Judgment-Only Skill Files" entry and the SAFETY grep-count constraints, any edit here requires careful line-set diff verification. |
| P2-4 | P2 | `.agents/skills/` (3 matching files) | various | **Same P1-1 through P2-3 residuals in .agents/ platform.** The .agents/ platform mirrors .claude/ exactly (parity confirmed), so the same stale references exist in the Codex-side copies. Any fix to .claude/ must be mirrored. |

---

## Positive Observations

1. **Clean STEP removal.** STEPs 3.56 and 3.57 were removed without breaking
   the STEP 3.55 -> STEP 3.8 flow. The `interacts_with` cross-references in
   STEP 3.55 correctly had their STEP 3.56/3.57 suppression lines removed as
   part of the block deletion. No orphaned `suppress_if` or `interacts_with`
   references remain.

2. **step4d removal preserves acceptance flow.** The step4c -> step4e_feedback ->
   step5 -> step6 -> step7 chain is intact. The accept-command.md checklist
   correctly removed the `step4d (trace-digest)` entry.

3. **harvest_protocol is well-designed.** Placed in the SKILL body (not a
   reference), which avoids the circular-trigger problem documented in
   principles.md ("Execution Discipline Content Must Stay in SKILL Body").
   The `forbidden_implementations` block correctly prevents startup auto-scan,
   unattended materialization, and candidate acceptance without human
   AskUserQuestion.

4. **skillify_evaluation engine fully preserved.** Blake's L1839-L1897 retains
   the complete 4-gate evaluation, Step 5 type routing (judgment vs
   orchestration), and the T1 materialization ceremony. The `note:` field
   was updated to reference "T1 in-session ceremony (step 5) or master
   *harvest" -- correct and consistent with the new command surface.

5. **Dual-platform parity confirmed.** `diff -qr .claude/skills/ .agents/skills/`
   returns clean (0 differences). Both platforms received identical changes.

6. **Surplus scan sources cleaned.** `dream-candidates/` and `evidence/proposals/`
   removed from both the SKILL.md no-mutation list and the workflow.js default
   sources array. No orphaned directory references remain in these files.

7. **Template additions are additive-only.** The completion-report carrier line
   and SCAND `materialized_at`/`reference_at` fields are clean additions that
   don't break existing template consumers.

8. **Constraint token density maintained.** 35 MUST/MANDATORY/VIOLATION/forbidden
   tokens in alex SKILL.md post-edit. No SAFETY constraints were lost; the
   frontmatter `skillify` deny block (L106-L116) is preserved as expected.

9. **trace-digest.sh deleted.** The file is confirmed gone from disk. No
   references to `trace-digest` or `trace_digest` remain in any of the skill
   files or acceptance protocol.

---

## Verdict

**PASS -- with P1 follow-up required.**

The core surgery (alex SKILL.md, acceptance-protocol.md, blake SKILL.md,
surplus SKILL.md, surplus-scan.workflow.js, deleted references, deleted
trace-digest.sh) is clean, correct, and parity-verified.

The 3 P1 findings (intent-router-protocol.md L150/L198, accept-command.md L251,
handoff-a-to-b.md L24) are residual stale references in files that were NOT
in scope for this commit but which will direct agents to invoke retired commands
at runtime. These should be fixed in a follow-up commit before the next release
or sync.

The P2 findings are documentation/comment cosmetics that carry lower risk but
should be cleaned for consistency during the same follow-up pass.

### Recommended Next Steps

1. **Follow-up commit**: Clean the 4 P1 residuals + 3 P2 residuals across
   both `.claude/` and `.agents/` platforms (+ 2 in `.tad/` templates/hooks).
   Total: ~9 line edits across ~6 files (x2 for parity = ~12 file touches).
2. **Verification**: After the follow-up, run:
   ```
   grep -rn '\*dream\b\|\*evolve\b\|\*optimize\b\|\*skillify\b' \
     .claude/skills/ .agents/skills/ .tad/templates/ .tad/hooks/ \
     --include='*.md' --include='*.sh' --include='*.js' --include='*.yaml'
   ```
   Expected output: only frontmatter `forbidden_implementations` / `deny_ref`
   entries (which are constraint anchors and MUST survive).
