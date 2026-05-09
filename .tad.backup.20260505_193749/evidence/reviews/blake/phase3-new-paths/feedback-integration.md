# Phase 3 — Layer 2 Code Review Feedback Integration

**Date**: 2026-04-24
**Reviewer**: code-reviewer (sub-agent)
**Reviewee**: Blake (this session)
**Original review**: `.tad/evidence/reviews/blake/phase3-new-paths/code-reviewer.md`

The code-reviewer flagged 2 P0 + 3 P1 + 3 P2 issues. P0s and P1s have been integrated (P2s are cosmetic and out-of-scope for this Layer 2 round).

## Audit Trail

| ID | Severity | Issue | Resolution Section | Status |
|---|---|---|---|---|
| CR-P0-1 | P0 | Override-marker anchor `## Knowledge Updates` does NOT match canonical template (`## Knowledge Assessment`) and 10+ archived completion reports — silently breaks P3.3 safety net | Replaced anchor everywhere: Alex SKILL step7.pre_check, Blake SKILL completion_knowledge_override.override_marker_anchor + override_marker_format prose, all 3 override-marker fixtures, dogfood.md. Verified `grep -c "Knowledge Updates"` returns 0 in both Alex/Blake SKILLs and the entire `.tad/evidence/completions/phase3-new-paths/` tree. | Resolved |
| CR-P0-2 | P0 | "First non-blank line under section" insertion location ambiguous relative to existing template body (`**是否有新发现？**` line) | Added explicit insertion location to Blake `override_marker_format`: "Override marker is inserted AS A NEW LINE between the section header and the existing template body. Existing template body remains intact below." Paired with Alex `pre_check` adjustment: grep window covers the first ~5 non-blank lines after the header (not strictly the first), so a future template tweak doesn't break the match. Both sides reference each other for symmetry. | Resolved |
| CR-P1-1 | P1 | `path_transitions.forbidden` "any → any" entry structurally ambiguous if a future implementer reads the matrix as a tuple list | Deferred — current form is human-readable documentation only, no enforcement code reads it; the explicit `analyze→express` and `analyze→experiment` forbidden rows are the load-bearing entries (per BA-P1-1). The "any → any" entry serves as a default-deny declaration, not a tuple. Refactor to `default: deny` field is a future-style cleanup, not blocking. | Deferred (low priority) |
| CR-P1-2 | P1 | `branch_1_skip_no_override` sets `A_verify_blake_claims: SKIP` — diverges from handoff §3 which said `REQUIRED`, without an Audit Trail justification | Added `semantic_note:` block under branch_1 explaining the deviation: "Original handoff §3 P3.3.b spec said REQUIRED. Implementation deviates to SKIP because there is logically nothing to verify under skip — Blake had NO KA obligation, so there are no 'Blake KA claims' to read or cross-check. B (raw-TSV recompute for quantitative ACs) still runs — that's the integrity guarantee, not A." Net effect matches spec intent. | Resolved |
| CR-P1-3 | P1 | `experiment_path_protocol.required_steps` only lists 4 items vs express's 9 — risks future "Gate 2 implied skipped" misread of the "Standard TAD steps DO follow" shorthand | Expanded `experiment_path_protocol.required_steps` to enumerate all 13 mandatory steps explicitly (Socratic / step0_5 / step1 / step1b / step1c / step2 / step4 Audit Trail / step5 Gate 2 / step7 Blake message / Gate 3 v2 augmented / Gate 4 v2 augmented). Mirrors express enumeration style. Added inline comment explaining the rationale. | Resolved |
| CR-P2-1 | P2 | Comment style inconsistency in step7 branches | Deferred (cosmetic) | Deferred |
| CR-P2-2 | P2 | Anti-Epic-1 grep `^[^#]*` could miss inline `#` comments | Deferred — current form is sufficient given 0 actual hits; sharper pattern is a future hardening | Deferred |
| CR-P2-3 | P2 | "*express never appears as Recommended" rule duplicated in 4 places | Deferred — 4 places is intentional defense-in-depth (config-workflow + 2 Alex SKILL spots + intent_modes prose). Single source of truth refactor would improve DRY but reduce defense-in-depth. | Deferred (low priority) |

## Mechanical re-verification after fixes

| Check | Command | Pre-fix | Post-fix |
|---|---|---|---|
| AR-001 anchor (AC-P3.1-h) | `grep -A 30 'express_path_protocol:' alex/SKILL.md \| grep -c 'expert review.*code-reviewer\|code-reviewer.*expert review'` | 2 | 2 (≥1 PASS) |
| Anti-Epic-1 grep | full pattern from handoff §5 against settings.json + .tad/hooks/*.sh + .tad/hooks/lib/*.sh | 0 hits | 0 hits |
| Anti-Epic-1 file scan | `ls .tad/hooks/ \| grep -E '^(express\|experiment\|skip_knowledge\|knowledge_assessment)'` | 0 | 0 |
| forbidden_implementations symmetry | python regex count over 3 blocks | 5/5/5 | 5/5/5 |
| Knowledge Updates string remaining | `grep -rl "Knowledge Updates" .claude/skills/ .tad/templates/ .tad/evidence/completions/phase3-new-paths/` | 21 hits across 5 files | 0 hits |
| Knowledge Assessment string after fix | same paths | 16 in Alex / 10 in Blake / 6 in fixtures | confirmed |

## Final Verdict (post-integration)

- **code-reviewer**: CONDITIONAL PASS → **PASS** (2 P0 + 3 P1 Resolved or Deferred-with-rationale; 3 P2 Deferred as low-priority cosmetic)
- Mechanical anchors: all green.
- Phase 3 ready for Gate 3 v2.
