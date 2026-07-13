# Phase 4 Grounding — interaction/context small items (Conductor-written, 2026-07-13)

## Scope (from Epic Phase 4)
(a) AskUserQuestion `preview` field wired into *design 2-up comparisons + tournament final
display. (b) Single-file path-scoped `.claude/rules` pilot with context measurement.

## Actual state (verified by Conductor)

### (a) AskUserQuestion preview
- Native facts (harness-level, first-party): `preview` is an OPTIONAL per-option field; renders
  markdown in a monospace box, side-by-side layout (options left, preview right). SINGLE-SELECT
  questions only (multiSelect + preview unsupported). Intended for concrete artifact comparison
  (mockups, code variants, diagram/config alternatives) — NOT for simple preference questions.
- Wiring targets (grep-verified):
  - `.claude/skills/alex/references/design-protocol.md` — option-presentation points exist
    (pack selection ~L75/93 is NOT a preview use-case — preference question; the 2+ options
    per significant technical decision presentation IS; tournament offer ~L127).
  - Tournament final display: `.claude/workflows/tournament-design.workflow.js` + wherever the
    judge/synthesis results are presented to the human (grep 'tournament' in alex references).
  - frontend 2-up (warm-palette rule): `.tad/project-knowledge/frontend-design.md` documents the
    2-up confirm step — the *design flow should use preview for it when artifacts are textual.
- Design constraint: this is PROTOCOL TEXT change only (skill/reference .md) — teach WHEN to use
  preview (artifact comparison, single-select) and when NOT (preference, multiSelect). No code.
- Behavioral AC idea: a scripted example in the protocol showing a 2-up preview call; real
  behavioral evidence = next *design session uses it (mark as observe-on-next-use if no design
  task is in flight — honest_partial acceptable for a protocol-text phase).

### (b) path-scoped rules pilot
- `.claude/rules/` does NOT exist in this repo yet.
- Native facts: `.claude/rules/*.md` with frontmatter path-scoping — rules load only when the
  agent touches matching paths. Exact frontmatter key syntax (e.g. `paths:`/`globs:`) must be
  verified against current docs during implementation (research was doc-level; cite the doc).
- Pilot candidate (per idea file): shell-portability constraints that only matter when touching
  `.tad/hooks/**` — content SOURCE is `.tad/project-knowledge/patterns/shell-portability.md`
  (loaded today via Blake's keyword-matched context refresh, NOT via global @import — note:
  CLAUDE.md @imports do NOT include patterns/*.md; the pilot's win is therefore about making
  the constraint AVAILABLE at edit-time in non-TAD-flow sessions, not about removing an
  existing global tax).
- Measurement (Measure Before Optimizing — principles.md): define metric BEFORE building:
  e.g. (1) rule fires when editing .tad/hooks/* (observable in session), (2) rule does NOT load
  in unrelated sessions, (3) content parity with source pattern file (derived excerpt, cite
  source, no fork drift — add a sync note or make it a pointer file).
- Risk to design around: DUPLICATING knowledge (patterns file + rules file) creates drift.
  Prefer a thin rule that states the 3-5 hard constraints + pointer to the pattern file.

### Layer 1
Protocol .md edits: line-set diff discipline (only intended sections changed); rules file:
frontmatter parses + manual fire-test evidence.

### Evidence dir
`.tad/evidence/yolo/native-capability-adoption/` (phase4-*).
