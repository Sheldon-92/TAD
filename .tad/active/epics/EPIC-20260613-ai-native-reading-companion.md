# Epic: AI-Native Reading Companion — Reimagining the Reading Experience

**Epic ID**: EPIC-20260613-ai-native-reading-companion
**Created**: 2026-06-13
**Owner**: Alex

---

## Objective
Build a reading experience where any document becomes an e-reader-grade HTML reading
surface with an AI co-researcher that talks back in real time. You drop in a file →
it produces a reading/research plan + structure map → renders a readable, annotatable
HTML reader → and lets you discuss the exact passage you're on with terminal Claude
Code over a bidirectional bridge. North star: the experience must make you think
**more**, not less (Socratic/synthesis-first, not auto-summary). Built inside TAD
first; designed to stand alone later.

## Success Criteria
- [ ] Drop in an EPUB → get a readable HTML reader (66 CPL, 1.5 line-height, themed) + a reading/research plan (structure map + question list)
- [ ] Highlight/annotate in the HTML; annotations persist to a sidecar data file (W3C TextQuote+prefix/suffix+refinedBy) and survive HTML regeneration
- [ ] Open a co-read session: select a passage in HTML → message terminal Claude Code → reply appears back in the HTML chat panel (bidirectional, session open/close)
- [ ] AI co-read defaults to Socratic/synthesis-first behavior (asks before answering; no unsolicited summaries)
- [ ] Reading produces durable sinks: structured notes + question list + Markdown export
- [ ] Format coverage extended beyond EPUB (PDF / TXT / URL)

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 1 | Research + Vision Spec | ✅ Done | — | DESIGN-FINDINGS.md (evidence-grounded design rules) + locked decisions |
| 2 | Reader + Capture MVP (EPUB) | ✅ Done | archive/handoffs/HANDOFF-20260613-...-phase2-epub-reader.md | EPUB → e-reader HTML + reading plan + annotation→sidecar (no live bridge) |
| 3 | Live Co-Read Bridge | ✅ Done | archive/handoffs/HANDOFF-20260613-...-phase3-live-bridge.md | localhost bridge + session open/close + select-to-discuss + Socratic AI |
| 4 | Sinks + Multi-Format | ⬚ Planned | — | structured notes / question-list / MD export + PDF/TXT/URL adapters |

### Phase Dependencies
Sequential. Phase 2 → 3 → 4. "Complete closed loop for one format" = Phase 2 + Phase 3.

### Derived Status
- **Status**: In Progress (Phase 1 ✅, Phase 2 ✅, Phase 3 ✅) — closed loop for EPUB complete; Gate 4 accepted 2026-06-14 (test_bridge.py 34/34 independently re-run; Gate 3 fix round resolved 9 defects incl. P0 CSP-nonce)
- **Progress**: 3 / 4

---

## Phase Details

### Phase 1: Research + Vision Spec

**Status:** ✅ Done
**Execution:** completed 2026-06-13

#### Scope
Ground the design in evidence before building. Research open-source readers + reading
UX + AI-on-comprehension literature; distill into concrete design rules. NOT in scope:
any implementation.

#### Input
User vision (reimagine reading), Socratic inquiry results, NotebookLM CLI.

#### Output
- NotebookLM notebook `ai-native-reading` (189fbf20-…, 19 sources) — persistent, reusable
- `.tad/evidence/research/ai-native-reading/DESIGN-FINDINGS.md` — design rules
- Raw asks: q1-reader-ux.md, q2-deepen-vs-flatten.md, q3-annotation-anchoring.md

#### Acceptance Criteria
- [x] Notebook created + registered in REGISTRY.yaml with ≥15 sources
- [x] 3 synthesis answers captured with citations (UX patterns / north-star rules / anchoring)
- [x] DESIGN-FINDINGS.md translates findings into actionable architecture rules

#### Files Likely Affected
- `.tad/evidence/research/ai-native-reading/DESIGN-FINDINGS.md` (CREATE) ✅
- `.tad/research-notebooks/REGISTRY.yaml` (MODIFY) ✅

#### Dependencies
None.

#### Notes
Locked decisions (carry into all phases): sidecar bridge + state; HTML = rendered view;
AI = active co-researcher bound to Socratic/synthesis-first; reading plan = structure
map + question list + pace; sinks = notes + HTML + MD; independent of research-notebook;
MVP format = **EPUB**; live transport = local bridge service; session = open/close
toggle (one-shot context per message, persists until user closes).

---

### Phase 2: Reader + Capture MVP (EPUB)

**Status:** ✅ Done (Gate 4 ACCEPTED 2026-06-13)
**Execution:** YOLO (Conductor fallback — Workflow named-args plumbing failed; manual impl+review)
**Handoff:** archive/handoffs/HANDOFF-20260613-ai-reading-companion-phase2-epub-reader.md
**Gate 3:** ✅ PASS — 11/11 §9.1 ACs + AC5b; 2 independent impl reviewers (code + ux) ran the code; 1 P0 + 6 P1 + 4 P2 found and fixed; all key fixes (P0#1 visible mark, P1#2 stale-gate, P1#3 zero-loss merge) independently re-verified by Conductor. Security: defense-in-depth PASS (malicious-EPUB XSS blocked, 3 layers). Evidence: .tad/evidence/yolo/ai-native-reading-companion/phase2-completion.md
**Gate 4:** ✅ ACCEPTED — real-book browser test (29-ch Yvon Chouinard EPUB, 832KB, opened in Chrome): reader renders well (cream+dark, 66ch serif), drag-highlight works, theme toggle works. Found + fixed a browser-only triple-click stray-empty-mark bug (Gate 4 Fix Round), re-verified in browser: triple-click now highlights the line cleanly, 0 stray marks.

#### Scope
Turn an EPUB into an e-reader-grade HTML reading surface plus a reading/research plan,
with in-flow annotation that persists to a sidecar. This phase is the reading surface
ONLY — NO live bridge / no terminal conversation yet (that is Phase 3). NOT in scope:
PDF/TXT/URL, real-time chat, AI co-read behavior.

#### Input
Phase 1 DESIGN-FINDINGS.md; epub.js / Readium CSS / Foliate as references; web-ui-design
+ web-frontend capability packs (anti-slop tokens, typography).

#### Output
- A skill + scripts that ingest an EPUB and emit a reading workspace
- E-reader HTML: per-section pages, TOC + progress, pagination AND scroll, themes (cream/dark), 66 CPL / 1.5 line-height
- Reading/research plan: structure map + reading path + auto-generated question list
- Annotation: select-to-highlight, in-line markup (no isolated-list pitfall); annotations written to `reading-state.json` sidecar using W3C TextQuoteSelector (+prefix/suffix) refinedBy paragraph anchor + source content-hash
- Re-attach: reopening HTML re-renders highlights from sidecar by quote-match

#### Acceptance Criteria
- [ ] `bash <reader-tool> ingest <sample.epub>` produces a workspace dir with `index.html`, `reading-state.json`, `plan.md`
- [ ] Rendered HTML measures ~66 CPL (50–75) and uses line-height 1.5; cream + dark themes both selectable
- [ ] TOC navigates to sections; a visible progress indicator updates while reading
- [ ] Highlighting a passage writes a W3C-style anchor (textQuote + prefix/suffix + refinedBy) to `reading-state.json`; re-opening the HTML restores the highlight on the correct passage
- [ ] Delete or regenerate `index.html`, re-render from source+sidecar → annotations re-attach (zero loss)
- [ ] `plan.md` contains a structure map + ≥5 auto-generated reading questions derived from the EPUB content

#### Files Likely Affected
- `.claude/skills/reading-companion/SKILL.md` (CREATE)
- `.claude/skills/reading-companion/tools/epub-ingest.{py|sh}` (CREATE)
- `.claude/skills/reading-companion/tools/render-html.{py|sh}` (CREATE)
- `.claude/skills/reading-companion/templates/reader.html` (CREATE)
- `.claude/skills/reading-companion/tools/plan-gen.{py|sh}` (CREATE)
- `.reading/<doc-slug>/{index.html,reading-state.json,plan.md}` (RUNTIME output, gitignored)

#### Dependencies
Phase 1.

#### Notes
Decide EPUB parsing path (epub.js in-browser vs server-side extract to normalized HTML/JSON
— recommend server-side normalize so the sidecar anchoring is stable). Annotation
multi-match guard (widen prefix/suffix or fall back to Range Selector). Keep anti-AI-slop
typography from web-ui-design pack.

---

### Phase 3: Live Co-Read Bridge

**Status:** ✅ Done — Gate 4 accepted 2026-06-14 (Alex independently re-ran test_bridge.py 34/34; human approved accept & archive). Caveat carried to Phase 4 / first real use: real-browser *visual* co-read (send→reply renders, enforcing-CSP inline-script load) still UNVERIFIED — verify on first real-book session.
**Execution:** YOLO (Conductor-manual)
**Handoff:** HANDOFF-20260613-ai-reading-companion-phase3-live-bridge.md
**Gate 2:** ✅ PASS — security-auditor (FAIL→resolved) + code-reviewer (CONDITIONAL→resolved); 8 P0 (5 security + 3 concurrency) + 11 P1 integrated.
**Gate 3:** ✅ PASS — built (bridge-server.py/bridge-client.py/test_bridge.py + reader.html bridge mode + render --bridge + SKILL co-read protocol). 2 independent reviewers ran live attacks: found 1 P0 (CSP blocked own inline script → feature dead in enforcing browser; the 15 curl ACs + agent's browser claim missed it) + 3 P1 (keep-alive framing desync, SSE no-cap, /close body) + P2 — ALL fixed. Conductor independently re-verified: test_bridge 34/34, CSP nonce per-response (3/3 inline tags nonced, 0 un-nonced, no unsafe-inline), keep-alive reject→reuse 200, Host/token/traversal/headers live, stdlib clean. NOT live-verified: real-browser visual (user denied nav) → deferred to Gate 4. Evidence: phase3-completion.md (+ Gate 3 Fix Round).

#### Scope
Add bidirectional real-time communication between the HTML reader and terminal Claude
Code via a local bridge service. HTML chat panel + select-to-discuss → message terminal
Claude → reply renders back in the panel. Session is an explicit open/close toggle; one-shot
context (current passage + state) sent per message; session persists until user closes.
NOT in scope: multi-format, persistent sinks/export (Phase 4).

#### Input
Phase 2 reader + `reading-state.json`; DESIGN-FINDINGS north-star rules; feedback-collector
overlay model as reference; claude-in-chrome (optional preview channel).

#### Output
- Local bridge service (localhost; SSE for server→browser push, POST for browser→server)
- Session lifecycle: "开启共读 / 结束共读" — open registers, close releases
- HTML chat panel (history + input + reply stream) + select-text → "问 Claude / 标注" popup that locks discussion to the selected passage's context
- A co-read mode the user starts in terminal that connects to the bridge, receives one-shot context+message, replies; Socratic/synthesis-first behavior (asks before answering; no auto-summary); switchable answer mode
- Messages + AI replies recorded into the sidecar thread

#### Acceptance Criteria
- [ ] Start a co-read session; clicking send in HTML delivers the message + current passage context to terminal Claude, and the reply appears in the HTML panel
- [ ] Terminal Claude can write a message that appears in the HTML panel/input (both directions verified)
- [ ] Selecting a passage and "问 Claude" sends that passage as locked context (reply references it)
- [ ] Closing the session releases the bridge (port freed, no lingering process); reopening works
- [ ] Default AI behavior asks a probing question / requests user's reasoning before giving an answer (Socratic); answer-mode toggle works
- [ ] Conversation turns are appended to the sidecar thread and reload with the document

#### Files Likely Affected
- `.claude/skills/reading-companion/tools/bridge-server.{py|js}` (CREATE)
- `.claude/skills/reading-companion/templates/reader.html` (MODIFY — chat panel + SSE client + select popup)
- `.claude/skills/reading-companion/SKILL.md` (MODIFY — co-read session protocol + Socratic prompt rules)
- `.reading/<doc-slug>/reading-state.json` (RUNTIME — thread storage)

#### Dependencies
Phase 2.

#### Notes
Hardest, most novel phase. Decide transport (SSE vs WebSocket — SSE + POST is simplest,
Python stdlib-capable). Decide how terminal Claude "listens" while session open (a scoped
wait/loop bounded to session lifetime — NOT a permanent resident). Port/lifecycle safety.
Avoid browser modal dialogs. Security: bind to 127.0.0.1 only, token-guard the endpoint.

---

### Phase 4: Sinks + Multi-Format

**Status:** ⬚ Planned
**Execution:** pending

#### Scope
Make reading produce durable, portable outputs, and extend ingestion beyond EPUB. NOT in
scope: new bridge/UX mechanics (those are stable from Phase 3).

#### Input
Phases 2–3 (reader + bridge + sidecar threads); Koodo export lesson; TAD
`*research-notebook quiz|flashcards` for spaced-retrieval.

#### Output
- Sinks: structured notes (by section) + open-question list + Markdown export of the whole session; optional KM-friendly format
- Spaced-retrieval: generate quiz/flashcards from the reading (reuse research-notebook)
- Format adapters: PDF, TXT, URL → normalized into the same reading pipeline

#### Acceptance Criteria
- [ ] One command exports a session to Markdown (notes + questions + key highlights with their passages)
- [ ] Structured notes are organized by the document's structure map (not a flat highlight dump)
- [ ] At least PDF and one of {TXT, URL} ingest into the same reader pipeline and pass Phase 2's reader ACs
- [ ] Quiz/flashcards can be generated from a finished reading (via research-notebook)

#### Files Likely Affected
- `.claude/skills/reading-companion/tools/export-notes.{py|sh}` (CREATE)
- `.claude/skills/reading-companion/tools/pdf-ingest.{py|sh}` (CREATE)
- `.claude/skills/reading-companion/tools/url-ingest.{py|sh}` (CREATE)
- `.claude/skills/reading-companion/SKILL.md` (MODIFY)

#### Dependencies
Phase 3.

#### Notes
PDF is the hard parser (scanned vs text). Decide acceptable fidelity (text reflow vs
figure preservation). URL ingest can reuse TAD source-preprocessor patterns.

---

## Context for Next Phase
Phase 3 starts next: the live co-read bridge. Build on the Phase-2 reader + reading-state.json sidecar.

### Completed Work Summary
- Phase 1: Evidence-grounded research (NotebookLM `ai-native-reading`, 19 sources) → DESIGN-FINDINGS.md (north-star rules, reader UX numbers, W3C anchoring).
- Phase 2: `reading-companion` skill — stdlib-only EPUB→content.json→self-contained e-reader index.html (serif/66ch/1.5/cream+dark) + plan-gen (active-reading questions) + annotation→sidecar (W3C TextQuote+prefix/suffix+refinedBy.pid+source_hash, §4.4 re-attach) + export-annotations. Gate 3 PASS (11 ACs, 2 independent reviewers, security defense-in-depth), Gate 4 ACCEPTED (real-book browser test; triple-click bug found+fixed in-browser).

### Decisions Made So Far
- MVP format = EPUB; HTML = rendered view, annotations live in sidecar; AI = Socratic/synthesis-first; independent of research-notebook; reuse quiz/flashcards + web-ui-design/web-frontend packs.
- Phase-2 persistence (interim) = read-only render + browser Blob download + `render --save` merge. Phase 3 replaces this with the live bridge.
- stdlib-only is a hard constraint (verified holds; pyexpat broken on Homebrew py3.14 → html.parser fallback already in place).

### Known Issues / Carry-forward
- **Phase 3 key open design Q: "how does terminal Claude listen?"** → bounded session-lifetime loop, NOT permanent resident (user-confirmed: one-shot context per message, session persists until user closes).
- Bridge transport fork (SSE+POST vs WebSocket) — recommend SSE+POST (Python stdlib http.server capable, simplest).
- Security: bind 127.0.0.1 only, token-guard the endpoint, no browser modal dialogs.
- Deferred from Phase 2 (later phase): reading ruler, touch targets, mobile topbar overflow, help-text size, mode-button state label.
- Reuse the existing reading-state.json `thread: []` field for the conversation log.

### Next Phase Scope
Phase 3: localhost bridge service (SSE/POST) + 开启/结束共读 session toggle + select-to-discuss (passage as locked context) + HTML chat panel + terminal co-read mode with Socratic/synthesis-first behavior; conversation turns appended to sidecar thread.

---

## Notes
Built inside TAD but structured as a self-contained skill (`.claude/skills/reading-companion/`)
so it can later stand alone. 3rd active Epic — at cap (max 3); do not open a 4th until one closes.
