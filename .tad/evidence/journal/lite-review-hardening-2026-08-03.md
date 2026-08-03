# Blake Gate 3 Journal — Lite Review Hardening

Date: 2026-08-03
Task: `lite-review-hardening`

## New discoveries

Yes — reusable testing/protocol findings were discovered during implementation.

1. Section-scoped acceptance checks need the same boundary semantics as the
   protocol they verify. The first AC8 evidence extractor used
   `awk '/^## 执行证据$/,/^## /'`; because the end expression also matched the
   start heading, it returned only the heading and falsely reported missing
   evidence. The corrected stateful extractor starts after the heading and
   stops only at the next heading.
2. A handoff requirement can be present in a later Completion template while
   still being absent from the mandated reviewer-prompt location. The
   independent spec reviewer caught this placement gap; the exact L3 sentence
   was added to both Blake mirrors and an incremental review passed.
3. For this host, role-separation assertions must use `grep -Fxq -e` for
   patterns beginning with `-`; the AC3 command-level assertion preserves this
   portability constraint.

## Evidence

- `.tad/evidence/acceptance-tests/lite-review-hardening/AC-08-behavioral-probe.sh`
- `.tad/evidence/acceptance-tests/lite-review-hardening/AC-01-execution-probe.sh`
- `.tad/evidence/reviews/blake/lite-review-hardening/spec-compliance-reviewer.md`
- `.tad/evidence/acceptance-tests/lite-review-hardening/acceptance-verification-report.md`

Distillation into `.tad/project-knowledge/` is deferred to Alex's Gate 4
distillation loop.
