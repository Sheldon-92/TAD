# EPIC COMPLETION — AI-Native Reading Companion

**Epic:** EPIC-20260613-ai-native-reading-companion | **Completed:** 2026-06-14 | **4/4 phases**

## Vision shipped
Drop in any document (EPUB / PDF / TXT / Markdown / URL) → e-reader-grade HTML reading
surface + auto reading/research plan → highlight & annotate (durable W3C sidecar) →
**live co-read with terminal Claude over a localhost bridge** (Socratic/synthesis-first,
not auto-summary) → export structured by-chapter notes + open-question list. North star
held: the experience pushes the reader to think *more*.

## Phases
| # | Phase | Gate 4 | Key evidence |
|---|-------|--------|--------------|
| 1 | Research + Vision Spec | ✅ | NotebookLM `ai-native-reading` (19 src) + DESIGN-FINDINGS.md |
| 2 | Reader + Capture (EPUB) | ✅ | phase2-completion.md; real-book browser test; triple-click bug found+fixed in-browser |
| 3 | Live Co-Read Bridge | ✅ | phase3-completion.md; **live co-read run in real Chrome** (send→reply, CSP-nonce P0 verified live) |
| 4 | Sinks + Multi-Format | ✅ | phase4-completion.md; 4 adapters byte-match schema, export-notes structured sink |

## Deliverable
`.claude/skills/reading-companion/` (skill `reading-companion`), committed on branch
`feat/reading-companion` (dc51f50 P2+3, 5efca79 P4). 14 stdlib-only tools + reader.html +
fixtures. Runtime workspaces under `.reading/` (gitignored).

## Process highlights (TAD value)
Independent review (2 experts/phase, run-the-code) caught **what self-report + green ACs missed every phase**:
- P2: triple-click highlight invisible (browser-only; AC-green).
- P3: **CSP blocked the reader's own inline script** → panel dead in a real browser (P0; curl ACs + agent's browser claim both missed it).
- P4: URL security-branch validation-theater + heading-only near-empty book + epub hash-drift.
KA → patterns/ac-verification.md: "UI/security branches must be executed under the property under test; a green curl/AC ≠ working."

## Known v2 limitations (documented, not bugs)
URL SSRF check-then-connect TOCTOU; PDF page-as-chapter (no heading-less coalescing);
export-notes no own source_hash gate; flashcards/KM-sync deferred (out of Phase-4 scope).
