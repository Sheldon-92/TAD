# Phase 2 Grounding — Reader + Capture MVP (EPUB)

> Conductor (Alex) grounding pass before YOLO implement. Greenfield phase.

## Target state
- Target dir `.claude/skills/reading-companion/` does NOT yet exist (greenfield) — all files CREATE.
- `.gitignore` does NOT yet contain `.reading/` — Blake must add it.

## Authoritative spec
- Handoff: `.tad/active/handoffs/HANDOFF-20260613-ai-reading-companion-phase2-epub-reader.md` (Gate 2 PASS, 6 P0 + 10 P1 resolved).
- Design rules: `.tad/evidence/research/ai-native-reading/DESIGN-FINDINGS.md` (evidence-grounded).

## Load-bearing constraints (from expert review — MUST honor)
1. **§4.4 Re-attach algorithm**: source_hash gate → quote-match scoped to refinedBy.pid → prefix/suffix tie-break within paragraph → Range/stale fallback. NEVER document-wide indexOf.
2. **stdlib-only** EPUB parse (zipfile+xml+html.parser); watch XML namespaces, spine→href relative to OPF dir, malformed-XHTML fallback to html.parser. No lxml.
3. **Typography**: serif font, ≥18px adjustable, max-width 66ch on content element, line-height 1.5, hyphens:auto.
4. **Two themes** cream/dark with distinct `--bg` values, WCAG AA ≥4.5:1.
5. **Persistence (Phase 2 locked)**: read-only render + browser Blob download + `render --save` merge. NO browser-writes-local-file (that is Phase 3).
6. **Fixture MUST contain a duplicated sentence** to make AC5 discriminative; negative-control stale annotation for AC5b.
7. **plan questions**: content-based, ≥5 ending in `?`, ≥2 adversarial (argue/refute).
8. Keyboard nav + export-annotations (highlights-in-context MD).

## AC verification source
§9.1 of the handoff (10 ACs + AC5b) — all post-impl, run at Gate 3.
