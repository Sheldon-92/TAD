# Phase 2 Completion Report — AI-Native Reading Companion (EPUB Reader)

**Agent:** Blake (TAD Execution Master)
**Date:** 2026-06-13
**Handoff:** HANDOFF-20260613-ai-reading-companion-phase2-epub-reader.md (Gate 2 PASS, 6 P0 + 10 P1 integrated)
**Status:** READY
**Layer 1 self-check verdict:** PASS — all 11 ACs (AC1–AC10 + AC5b) run and pass.

---

## Intent confirmation (handoff §1.3)

1. **解决什么问题**: 把任意 EPUB 变成电子阅读器级的本地 HTML 阅读页，能划线标注、带结构地图，标注真相源在 sidecar (`reading-state.json`)，HTML 只是可重生成的视图。
2. **用户怎么用**: `epub-ingest` → content.json；`render` → 自包含 index.html（浏览器沉浸阅读、划线、Blob download annotations.json）；`render --save` 合并回 sidecar 并重渲染（标注永不丢）；`plan-gen` 生成主动阅读计划；`export-annotations` 导出带上下文高亮。
3. **成功标准**: 删 HTML 重渲染后标注按 §4.4 重挂载到正确段落（重复句也对，证伪 doc-wide indexOf）；源变了标 stale 不静默错挂；排版符合 DESIGN-FINDINGS；三脚本零外部依赖。

---

## Files created

| File | Lines | Purpose |
|------|------:|---------|
| `.claude/skills/reading-companion/SKILL.md` | 119 | Invocation guide, workspace layout, anchoring model doc, persistence model |
| `.claude/skills/reading-companion/tools/epub-ingest.py` | 431 | EPUB → content.json (stdlib only; ns/spine/malformed-XHTML traps handled) |
| `.claude/skills/reading-companion/tools/render.py` | 299 | content.json + state → self-contained index.html; §4.4 re-attach; `--save` merge |
| `.claude/skills/reading-companion/tools/plan-gen.py` | 206 | content.json → plan.md (structure map + reading path + ≥5 Qs incl. ≥2 adversarial) |
| `.claude/skills/reading-companion/tools/export-annotations.py` | 105 | reading-state.json → highlights-in-context Markdown (blockquote context) |
| `.claude/skills/reading-companion/templates/reader.html` | 369 | Reader shell: serif/themes/TOC/progress/pagination/keyboard/highlight+Blob save |
| `.claude/skills/reading-companion/fixtures/make_fixture.py` | 101 | Builds sample.epub (chap2 has a duplicated sentence — twice within c2-p5) |
| `.claude/skills/reading-companion/fixtures/sample.epub` | 2055 B | Hand-made test EPUB (mimetype + container + OPF-in-subdir + 2 XHTML chapters) |
| `.gitignore` (modified) | +3 | Added `.reading/` (runtime workspaces) |

Total new source: ~1,630 lines.

---

## §9.1 AC-by-AC results

> grep commands below use BSD `/usr/bin/grep`; the interactive shell aliases `grep`→`ugrep`,
> which rejects the AC5b/AC3 ERE alternation `(;|[[:space:]]|})`. With standard grep all pass.

| # | AC | Command (as run) | Actual output | Verdict |
|---|----|------------------|---------------|---------|
| AC1 | EPUB → chapters ≥1 | `epub-ingest.py sample.epub -o c.json && jq '.chapters\|length'` | `2` | **PASS** |
| AC2 | pid stable + format | double-run `diff <(jq -S .chapters a) <(jq -S .chapters b)`; `jq -r '...pid'` | diff EMPTY; `c1-p1` matches `^c[0-9]+-p[0-9]+$` | **PASS** |
| AC3 | measure 66ch + line-height 1.5 on content | `grep -Ec 'max-width:[[:space:]]*6[0-9]ch'`; `grep -Ec 'line-height:[[:space:]]*1\.5(;\|[[:space:]]\|})'` | `1` and `1` | **PASS** |
| AC4 | ≥2 distinct `--bg` | `grep -Eo '\-\-bg:[^;]+' \| sort -u \| wc -l` | `2` (`#f5f0e6`, `#1a1a1a`) | **PASS** |
| AC5 | re-attach to **correct** pid + 2nd occurrence (repeated sentence) | highlight 2nd occ in c2-p5 → save → `rm index.html` → re-render → assert enclosing pid==refinedBy.pid AND offset==2nd | `enclosing_pid=c2-p5 refinedBy=c2-p5 \| mark_offset=120 first=35 second=120` | **PASS** |
| AC5b | source change → stale, no silent mis-anchor | mutate 1 char (source_hash differs) → re-render → `jq -e '[.annotations[]\|select(.stale==true)]\|length>0'` | `true`; exact preserved; count unchanged (1) | **PASS** |
| AC6 | anchor TextQuote+prefix/suffix+refinedBy | `jq -e '.annotations[0].anchor\|has("exact") and has("prefix") and has("suffix") and has("refinedBy")'` | `true` | **PASS** |
| AC7 | plan ≥5 `?`-questions incl. ≥2 adversarial | `awk '/^## Questions/.../^## /' \| grep -c '?$'`; same `\| grep -Ec '论证\|反驳\|argue\|defend\|refute'` | `6` and `3` | **PASS** |
| AC8 | three+ scripts stdlib-only (ast whole-token allow-set) | handoff AC8 ast script over `tools/*.py` | `NON_STDLIB: []`, exit `0` | **PASS** |
| AC9 | change scope = skill dir + .gitignore | Blake-authored files | skill dir + `.gitignore` (+ this evidence report). No out-of-scope Blake artifacts. | **PASS** |
| AC10 | export highlights-in-context (blockquote, not isolated list) | `export-annotations.py reading-state.json -o hl.md && grep -c '> '` | `1` (each highlight followed by its paragraph context as `> …`) | **PASS** |

**Tally: 11/11 PASS (AC1–AC10 + AC5b).**

### AC5 discrimination evidence (load-bearing)

The fixture's `c2-p5` contains the sentence `The map is not the territory.` **twice** (offsets 35 and 120). The annotation's prefix/suffix point at the 2nd. After `rm index.html` + re-render purely from the sidecar, the baked `<mark>` lands at **offset 120 (2nd)**, not 35 (1st). A document-wide `indexOf` (the anti-pattern §4.4 forbids) would have returned 35 — so this AC genuinely discriminates correct re-attach from naive matching. The same sentence also appears in c2-p2/c2-p4 (other paragraphs), which scoping to `refinedBy.pid` ignores.

### Negative control (handoff Blake Phase C)

An annotation whose `exact` does not exist in its paragraph (`THIS PHRASE NEVER APPEARS…`) → marked `stale: true`, data preserved, **not painted** (no silent mis-anchor). Verified independently.

---

## §4.4 re-attach algorithm — implementation map

Implemented server-side in `render.py::reattach()` (deterministic, browser-independent → verifiable):

1. **source_hash gate** — `state.source_hash != content.source_hash` → set `stale:true`, still best-effort, never silent re-anchor.
2. **scope** — `find_occurrence()` matches `exact` **only within the `refinedBy.pid` paragraph text**, never doc-wide.
3. **in-paragraph disambiguation** — if `exact` occurs >1× in that paragraph, prefix/suffix selects the unique occurrence.
4. **fallback** — unresolvable (ambiguous, or paragraph gone) → `stale:true`, annotation data retained (no loss); not painted.

The chosen occurrence is baked as `<mark class="hl[ stale]" data-annot data-pid>` so the enclosing pid is assertable.

---

## Persistence model (handoff §10.1 — LOCKED, honored)

Read-only render + browser Blob **download** + `render --save` merge. The reader's `saveAnnotations()` builds a `Blob` and triggers a `download` of `annotations.json`; the browser never writes local files. `render.py --save <file>` merges (de-dup by id) into `reading-state.json` then re-renders. No browser-writes-local-file path exists (that is Phase 3).

---

## Typography / accessibility (DESIGN-FINDINGS, verified)

- Serif font stack; base `--fontsize:19px` (≥18px), A−/A+ buttons + `-`/`+` keys, persisted to localStorage.
- `max-width:66ch` literally on `article.content`; `line-height:1.5`; `hyphens:auto` + `<html lang>`.
- Two themes — cream (`--bg #f5f0e6` / `--fg #2b2620` ≈ 11.6:1) and dark (`--bg #1a1a1a` / `--fg #d6d3cc` ≈ 11.4:1) — both well above WCAG AA 4.5:1; `d` toggles, persisted.
- TOC (`t`), pagination/scroll toggle, **mode-aware progress** (scroll % vs chapter X/Y), keyboard paging (`←/→`, `j/k`).
- Anti-AI-slop: flat design-token CSS, no gradients/emoji soup. Self-contained HTML (no external css/js/img; 0 unreplaced template tokens; ~19 KB).

---

## Edge cases verified (handoff §8.3)

- **Nested OPF dir** — fixture places OPF in `OEBPS/` so spine hrefs are OPF-relative (trap #2); resolved correctly.
- **Repeated identical sentence** — c2-p5 (twice in-paragraph) + cross-paragraph copies; disambiguation correct.
- **CJK / non-ASCII** — built a `测试书` EPUB (`第一章 阅读`, `地图不是疆域。`); parsed locale-safe end-to-end.
- **Deterministic pids** — double-run ingest produces byte-identical chapters (AC2).

---

## Browser runtime verification (§8.5, non-gating per §8.4)

The sandboxed Chrome instance blocks `file://` navigation (chrome-error page) and external nav, so a live visual screenshot was not obtainable in this environment. Compensating checks performed:

- **Reader inline JavaScript syntax** validated with `node --check` (Node v24.7.0) → **PASS, no syntax errors** (9,147-byte runtime).
- **Static wiring** confirmed: keyboard `keydown` handler, theme toggle, font controls, TOC toggle, selection→highlight capture, Blob-download save — all present and correctly wired in the rendered HTML.
- Self-containment grep: 0 external `<link>/<script src>/<img>`, 0 unreplaced `{{…}}` tokens.

Recommendation: a human opens `.reading/<slug>/index.html` directly in a desktop browser for the §8.5 feedback pass (typography comfort, theme glare, highlight feel). This is the one optional, non-gating item.

---

## Friction encountered

| # | Friction | Resolution | Status |
|---|----------|-----------|--------|
| F1 | **Homebrew Python 3.14.4's `pyexpat` C extension is broken** (`Symbol not found: _XML_SetAllocTrackerActivationThreshold`) — `xml.etree.ElementTree` cannot parse on the default `python3`. | Added a transparent pure-Python fallback: `epub-ingest.py` probes `ET.fromstring` at import; if expat is unavailable it parses container.xml/OPF with a stdlib `html.parser`-based `_TagScanner` and parses XHTML with the existing `html.parser` extractor. **Still STDLIB-ONLY** (AC8 exit 0). Verified identical `source_hash` on broken `python3` (3.14.4, fallback) and `python3.13` (working expat). | EQUIVALENT_SUBSTITUTE (stdlib html.parser substitutes for stdlib xml.etree under a broken platform build; no external dep introduced) |
| F2 | Interactive shell aliases `grep`→`ugrep`, which errors on the AC's ERE alternation `(;\|[[:space:]]\|})`. | Ran the §9.1 verification commands with standard `/usr/bin/grep` (the semantics the ACs were authored against). All pass. Documented above. | NOT_APPLICABLE_WITH_REASON (environment alias, not a code issue) |
| F3 | Sandboxed Chrome blocks `file://` + external navigation → no live screenshot. | Substituted `node --check` syntax validation + static wiring grep; visual feedback flagged for human (non-gating per §8.4 "Gate Impact: None"). | EQUIVALENT_SUBSTITUTE for the non-gating visual check |

No constraint was silently worked around. No external dependency was installed (AC8 clean). No global env pollution.

---

## Git state

Left in working tree (no commit, per instructions). Blake footprint: `.claude/skills/reading-companion/**`, `.gitignore` (+`.reading/`), and this report. Pre-existing `.tad/` modifications (epic/handoff/decisions/traces/registry/surplus/ideas) are Alex/framework artifacts, not Blake's.

---

## Gate 3 Fix Round

Independent Gate 3 review (2 reviewers ran the code) surfaced defects the §9.1 ACs don't cover. All 11 ACs still passed, but these were required before acceptance. Fixed in the same files (`templates/reader.html`, `tools/render.py`, `tools/plan-gen.py`); no scope change (AC9 still clean). **Re-verification tally: 11/11 ACs pass (+AC5b), all P0/P1/P2 findings verified.**

### P0 (fixed)

| # | Finding | Fix | Verification evidence |
|---|---------|-----|------------------------|
| P0#1 | **In-browser highlight had no visual feedback** — `commitHighlight()`→`paintNew()` only set `data-has-new="1"`; never wrapped the selection in a `<mark>`. User highlights → sees nothing. | `captureSelection()` now stores the live `Range` (`cloneRange()`) **before** the selection is cleared. `paintNew(ann, range)` inserts a real `<mark class="hl" data-annot data-pid>`: `range.surroundContents(mark)` for a single text node, with an `extractContents()`+wrap+`insertNode()` fallback when the selection crosses element boundaries. The dead `data-has-new` path is removed (0 occurrences). | `node` DOM-shim test (logic verbatim-identical to reader.html, confirmed by `grep -F` on all 4 load-bearing lines): **CASE A single-node** → `<mark>` wraps exactly "brave new", class `hl`, paragraph text preserved, UUID id. **CASE B cross-node** (selection spanning `<em>`) → fallback wraps "see brave" under one `<mark data-pid>`. P0#1 VERDICT: PASS. `node --check` on the rendered runtime: PASS. |

### P1 (fixed)

| # | Finding | Fix | Verification evidence |
|---|---------|-----|------------------------|
| P1#2 | **source_hash stale gate bypassed on the standard `--save` path** — default/new state pre-filled `source_hash` with the *current* content hash, so the adoption guard never fired and the export's own hash was discarded → §4.4 step 1 defeated on the browser→download→`render --save`→fresh-workspace happy path. | Default new state now `source_hash=""`; `--save` **always** prefers the incoming export's `source_hash` (falls back to existing only when the export omits one). So the gate compares "source the annotations were made against" vs "current content". | Fresh workspace, no prior sidecar: export carrying an **OLD** hash + content edited to a **new** hash → render `--save`: state adopts old hash (`46c16d6c…`), content is `cb615831…`, annotation `stale: true`, exact preserved. Happy-path regression: annotation made against current content → `stale: false`, painted. AC5b still passes. |
| P1#3 | **Merge dedup lost id-less annotations** — `merge_annotations` keyed on `a.get("id")`, so all id-less annotations collided under `None` (last-write-wins) → FR4 zero-loss violation. | De-dup key is the id when present; for id-less annotations a **content-derived key** (`pid`+exact+prefix+suffix) keeps distinct highlights separate. | 3 distinct id-less annotations exported → merged → all 3 survive in `reading-state.json` (was 1 before). |
| P1#4 | TOC links `:focus-visible{outline:none}` → WCAG 2.4.7 failure. | TOC links now get `outline:2px solid var(--accent); outline-offset:1px` on `:focus-visible`, matching the topbar buttons. | `grep` confirms `.toc a:focus-visible{…outline:2px solid var(--accent)…}` in rendered HTML. |
| P1#5 | Notebar (`role="dialog"`) had no Escape-to-dismiss and no focus trap. | Added `aria-modal="true"`; `openNotebar`/`closeNotebar` (restores prior focus); `Escape` closes from inside the dialog and from the global keydown; `Tab`/`Shift+Tab` wraps within the dialog's focusables; `Enter` in the note field commits. | `grep` confirms `e.key === "Escape"`, `closeNotebar`, `notebarFocusables` present; `node --check` PASS. |
| P1#6 | `btn-save` missing `aria-label`; label misled users (looked like "save position"). | Added `aria-label="Export annotations as JSON"` + a precise `title`; added a one-line help explainer: "Save = downloads an `annotations.json`; re-merge it with `render.py --save` … it does not save your scroll position." | `grep` confirms the aria-label and the explainer text in rendered HTML. |
| P1#7 | `key_phrases()` emitted broken verb fragments ("How does **absorbs** connect to Reading"). | Removed the unreliable frequency-based lowercase fallback (no POS tagger → leaked verbs). `key_phrases` now emits **only multi-word Capitalized concepts**; when none exists the question builder falls back to **always-grammatical chapter-title questions** ("What is the core claim of \"…\", and what would it take to convince you it is wrong?"), leaning on the good thesis/adversarial questions per reviewer guidance. | All generated questions now read grammatically (no bare verb stems). AC7 holds: 5 `?`-questions, 4 adversarial (≥5 / ≥2). |

### P2 (fixed)

| # | Finding | Fix | Verification |
|---|---------|-----|--------------|
| P2#8 | annotation id used `Date.now()+random`. | `newId()` uses `crypto.randomUUID()` (with the Date-based fallback only if unavailable). | `grep` confirms `crypto.randomUUID`; DOM test ids match `^a-[0-9a-f-]{8,}`. |
| P2#9 | CJK word-count counted an unspaced CJK run as 1 word → mis-flagged "skippable". | `words()` counts CJK codepoints + Latin tokens separately. | Unit: 16-char CJK run → 17 (was 1). End-to-end: an ~85-CJK-char chapter is **not** flagged skippable. |
| P2#10 | `merge_annotations` list-form branch was unreachable/crashed (`.get` before the `isinstance(list)` check). | Reordered: handle bare top-level JSON **list** before any `.get`; else dict `.get("annotations")`; else `[]`. | Bare-list export merges cleanly (1 annotation), no crash. |
| P2#11 | "Read slowly" tie-break picked the first chapter on equal minutes. | Tie-break by `(minutes, word_count)` → higher word-count chapter on a tie. | Selects "Chapter Two: Maps and Territory" (denser) as expected. |

### P2 (deferred, noted per instruction)

- help-text 12px font size, mobile topbar overflow, and the `⇄ Mode` button label clarity — deferred to a later Phase (cosmetic/responsive polish, not correctness or a11y-blocking).

### Re-verification summary (Gate 3 Fix Round)

- §9.1 AC suite (run with `/usr/bin/grep`): **AC1–AC10 + AC5b = 11/11 PASS**; AC9 scope clean.
- P0#1: new highlight inserts a visible `<mark>` (both single-node and cross-node paths) — PASS via node DOM-shim.
- P1#2: old-source-hash export against changed content → `stale:true` (not silently adopted); happy path not over-flagged — PASS.
- P1#3: 3 id-less annotations all survive merge — PASS.
- Reader runtime `node --check`: PASS. plan-gen imports warning-free (`-W error`).

---

## Gate 4 Fix Round — triple-click stray marks

Gate 4 real-book browser test (Yvon Chouinard EPUB in Chrome) found a highlight bug invisible to AC checks and the earlier node-shim. **Confirmed-working behaviour was left untouched** (drag-select within a prose paragraph → correct yellow `<mark>`, persists across theme toggle). ONE focused fix applied to `templates/reader.html` (+ defensive server-side guard in `tools/render.py`). No scope change.

### The bug

Triple-click on a short standalone line (e.g. `—Ray Anderson, chairman, Interface, Inc.`) → Highlight → produced **two faint EMPTY `<mark>` slivers on the adjacent blank lines** (above/below) and did **not** highlight the intended line. Root cause: a triple-click / block selection Range starts/ends on whitespace-only boundary text nodes between block elements; the old `extractContents`+single-wrap path wrapped those boundary nodes, yielding empty marks and mis-anchoring the real text.

### The fix (reader.html `paintNew` / `captureSelection` / `commitHighlight`)

1. **Per-text-node wrapping with whitespace trim.** Replaced the single `surroundContents`/`extractContents` wrap with `rangeTextSegments(range)` — it walks the range's intersecting text nodes (snapshotting offsets before any DOM mutation), clips each to the range's `[start,end]`, and **drops any segment whose trimmed text is empty**. Each surviving segment is wrapped via `wrapTextSlice()` (splitText → replaceChild), processed last-to-first so earlier offsets stay valid.
2. **Never create an empty `<mark>`.** `wrapTextSlice()` returns `null` (inserts nothing) when the slice is whitespace-only. The single-text-node fast path also routes through `wrapTextSlice`, so it too can never emit an empty mark.
3. **Whole-paragraph / triple-click anchoring.** `captureSelection()` now anchors `refinedBy.pid` to the paragraph containing the **first real text segment** of the range (via `rangeTextSegments` + `enclosingPidEl`), not to a boundary/whitespace `anchorNode`. So a triple-click on a standalone line anchors to that line's pid.
4. **Multi-paragraph selections.** Each paragraph's real-text portion is wrapped; whitespace-only boundary segments between blocks are skipped; the annotation anchors to where the text actually starts.
5. **Server-side parity (`render.py`).** `reattach()` now marks any annotation with empty/whitespace-only `exact` as `stale` (data kept, no paint), and treats a zero-length resolve as stale rather than painting. `paint_paragraph()` additionally skips any zero-length/whitespace-only slice — so a regenerated `index.html` can never bake an empty `<mark>` either.

### Regression evidence (node DOM-shim, using the REAL functions extracted from rendered reader.html)

The shim implements `TreeWalker`, `splitText`, `replaceChild`, `intersectsNode`, and a Range with container/offset, then runs the actual `paintNew`/`rangeTextSegments`/`wrapTextSlice` pulled from the rendered HTML:

- **CASE 1 — triple-click standalone line** (Range start on leading-whitespace node, end on trailing-whitespace node around `<p data-pid="c2-p9">—Ray Anderson, chairman, Interface, Inc.</p>`): result = **exactly ONE non-empty `<mark>`** over the line's text, `data-pid="c2-p9"`, **ZERO empty marks**, line text intact. PASS. *(Before the fix this produced 2 empty marks + no real highlight.)*
- **CASE 2 — drag-select within a paragraph** (`"passive act"` inside c1-p1): ONE `<mark>` over exactly "passive act", zero empty marks, paragraph text preserved. PASS (no regression to the confirmed-working path).
- **CASE 3 — cross-element selection spanning an `<em>` with a whitespace node between**: marks created over real text, **zero empty marks** (the whitespace node is skipped). PASS.
- **GATE-4 VERDICT: PASS** (all 3 cases).

Server-side: a reading-state with `exact:"   "`, `exact:""`, and one good exact → render → the two empties are `stale:true` (data preserved), **0 empty `<mark>` in the HTML**, good annotation painted (1), all 3 annotations retained (no loss).

### Re-verification summary (Gate 4 Fix Round)

- §9.1 AC suite (`/usr/bin/grep`): **AC1–AC10 + AC5b = 11/11 PASS**. (AC9: Blake scope clean — the only out-of-scope tracked-file dirt is a pre-existing `NEXT.md` edit, +1 line, no mention of reading-companion/epub, modified before this session; not Blake's.)
- Triple-click regression: PASS (1 non-empty mark, 0 empty). Drag-within-paragraph: PASS (no regression). Cross-element: PASS.
- Server-side empty-exact guard: PASS (stale, no empty mark, no data loss).
- Reader runtime `node --check`: PASS.
