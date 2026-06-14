# AI-Native Reading Experience — Design Findings (Research Phase)

> Grounding for the interactive reading-companion project ("reimagining reading").
> Source: NotebookLM notebook `ai-native-reading` (189fbf20-…), 19 sources.
> Date: 2026-06-13. Raw answers: q1-reader-ux.md, q2-deepen-vs-flatten.md, q3-annotation-anchoring.md.

---

## 1. North Star (evidence-backed): make the reader think MORE, not less

The literature is explicit that AI can **flatten** comprehension ("AI summaries can
flatten understanding"). The design must engineer **desirable difficulty**. Four
concrete rules distilled from the active-reading / AI-comprehension sources:

1. **Socratic partner, not oracle.** When the reader highlights a hard concept, the AI
   should ask probing questions or ask the reader to explain their reasoning — and can
   generate counterarguments to the text's thesis that the reader must rebut. (cognitive
   sparring partner)
2. **Scaffold synthesis — reader first, AI as junior editor.** Do NOT auto-summarize.
   Force the reader to attempt their own synthesis, THEN the AI gives feedback /
   compares viewpoints / checks citations. AI = junior editor, not omniscient author.
3. **Spaced retrieval for retention.** Auto-generate Q&A / flashcards from the reading
   and resurface at expanding intervals (harder retrieval = deeper processing). TAD
   already has `*research-notebook quiz|flashcards` — reuse, don't rebuild.
4. **Low-friction integrated active tools.** Highlighting tool access → readers covered
   34% more subtopics; note-taking → 34% more facts. The win is keeping tools IN the
   reading flow (no context switch), which is exactly the bridge's purpose.

> This is the product's defensible core. Every UI decision is judged against: *does it
> make the reader do more cognitive work, or less?*

---

## 2. Reader UX patterns (what the best OSS readers do)

**Typography (hard numbers):**
- Line length (measure): **50–75 CPL, target 66**; line-height **1.5**.
- Foliate: language-aware auto-hyphenation for typographic rhythm.

**Layout / focus aids:**
- Readest: "reading ruler" + paragraph-by-paragraph mode + code syntax highlighting
  (useful when the "book" is a technical manual).
- Offer both pagination and continuous scroll (reader preference varies).

**Navigation / orientation:**
- Readers must build a "structure map" in working memory → give explicit TOC + page
  list + bookmarks (Thorium) + a visible progress indicator ("X of Y" / progress bar).
- This validates our **structure-map / reading-plan** feature — it's not a nicety, it
  offloads working memory.

**Color / comfort:**
- Avoid pure-white glare. Offer soft cream / off-white / dark (Koodo night mode +
  background/text/brightness controls). Dyslexia-friendly defaults.

**Annotation UX (critical pitfall):**
- **Highlights shown as an isolated list LOSE their context** — a major UX failure.
  Keep markup in-line, frictionless (Readest "instant mode").
- Koodo's lesson: annotations must not be trapped — one-click export (MD/HTML/CSV/PDF)
  + sync to Readwise/Notion/Obsidian. → Our three-way sink (structured notes / HTML /
  Markdown) is the right instinct; make export first-class.

---

## 3. Annotation anchoring architecture (resolves the "data file ↔ regenerated HTML" problem)

The earlier design concern — annotations live in a sidecar and must re-attach to
regenerated HTML — has a known-good answer from the **W3C Web Annotation Data Model**:

**Recommended: chained/refined selectors + recorded resource state.**
- Anchor = `TextQuoteSelector` (exact phrase + **prefix/suffix** context) **refinedBy**
  a coarse locator (paragraph via Fragment/XPath). Prefix/suffix disambiguates.
- Use a **Range Selector** (startSelector/endSelector) for selections crossing element
  boundaries.
- Record the **resource State/version** the annotation was attached to, so re-attach
  knows which representation it came from.

**Failure modes to design against:**
- `TextPositionSelector` (char-offset) is **very brittle** — any edit shifts offsets. Do
  not rely on it alone.
- XPath/CSS selectors break on DOM shifts; browsers auto-inject elements (e.g. `<tbody>`)
  — XPath must account for it.
- `TextQuoteSelector` **multi-match** if the same quote+prefix+suffix repeats → must
  handle ambiguous matches (widen context or fall back to range).
- Bare fragment IDs (`#section1`) can't describe an arbitrary span.

**Design rule:** store annotations in the sidecar as TextQuote (with prefix/suffix) +
refinedBy paragraph anchor + content-hash of the source version. HTML is a *view*
rendered from source + sidecar; re-attach on load by quote-match within the anchored
paragraph. This makes "HTML is just a window, annotations live in the data file"
technically sound.

---

## 4. Direct implications for our architecture

| Decision (locked earlier) | Research confirms / refines |
|---------------------------|------------------------------|
| Sidecar holds reading state + annotations | ✅ + use W3C TextQuote(prefix/suffix)+refinedBy, content-hash the version |
| HTML is a rendered "window" | ✅ standard practice; re-attach annotations by quote-match |
| AI = active co-researcher | ✅ but bind to "Socratic/synthesis-first" rules, NOT auto-summary |
| Reading/research plan (structure map) | ✅ offloads working memory; pair with TOC + progress |
| Three-way sink (notes/HTML/MD) | ✅ make export + KM-sync first-class (Koodo lesson) |
| Spaced repetition / quiz | Reuse TAD `*research-notebook quiz|flashcards` |

**Reusable TAD assets to lean on:** research-notebook quiz/flashcards, feedback-collector
overlay model (element-level interaction in HTML), web-ui-design + web-frontend packs
(anti-slop tokens, typography), claude-in-chrome (optional preview channel).

**Open design questions for the design step (not research):**
- Bridge transport details (SSE vs WebSocket) + session open/close lifecycle.
- MVP format choice (recommend easiest-to-parse first to de-risk the bridge, not PDF).
- How "Socratic mode" vs "answer mode" is surfaced in the chat panel.
