# NotebookLM CLI Full Research — Phase 2 Design Input

**Date**: 2026-05-04 (Alex Gate 4 session, post-spike deep research)
**Source**: GitHub README + PyPI + CLI Reference docs (notebooklm-py 0.3.4)
**Purpose**: Capabilities NOT in Phase 1 handoff, deferred to Phase 2

---

## Tier 0: Must-Have for Phase 2 (changes Alex Research Director design)

### 1. `source fulltext <id> -o FILE`
- Retrieves the FULL indexed text of any source
- Alex can read source content directly without using `ask`
- Use case: Research Director evaluates source quality before diving deep
- Flags: `--json`, `-o FILE`

### 2. `ask "question" --source <id>` (repeatable flag)
- Scope questions to specific sources instead of whole notebook
- Critical for targeted research: "tell me about X from THIS source only"
- Can repeat `--source` to select multiple specific sources

### 3. `ask "question" --save-as-note --note-title "title"`
- Auto-saves Q&A to notebook notes
- Though notes don't participate in `ask` context, they persist conversation
- Use case: research audit trail — every question Alex asks gets logged

### 4. `generate report --append "extra instructions"`
- Append custom instructions on top of report templates
- Example: `generate report --format briefing-doc --append "Focus on ROI data and include a comparison table"`
- Allows fine-tuning without going full `--format custom`

### 5. `language set <code>` (80+ languages)
- GLOBAL account setting affecting all artifact generation
- `language set zh_Hans` → Chinese reports, quizzes, flashcards
- Key codes: en, zh_Hans, zh_Hant, ja, ko, es, fr, de, pt_BR
- `language list` shows all supported
- `language get --local` shows current setting

### 6. `auth check --test` + `doctor --fix`
- Better auth diagnostics than `notebooklm list`
- `auth check --test` → structured diagnostic output
- `doctor --fix` → self-repair common issues
- Should replace current SKILL preflight `list` check

---

## Tier 1: Should-Have for Phase 2

### 7. `download quiz --format [json|markdown|html]`
- Quiz and flashcard export in structured formats
- Markdown format directly usable for *learn mode integration
- `--difficulty [easy|medium|hard]` + `--quantity [fewer|standard|more]`

### 8. `source delete-by-title "exact title"`
- Easier than ID-based deletion for cleanup workflows
- Useful after `add-research --mode deep` bulk import

### 9. `generate <type> --retry N`
- Built-in exponential backoff retry on rate limits
- Available on ALL generate commands
- Phase 1 handoff implemented manual retry — this makes it unnecessary

### 10. `download all <directory>`
- Batch download all artifacts of a type to a directory
- Useful for exporting entire notebook's research output at once

### 11. `history --save --note-title "session log"`
- Save complete conversation history as a note
- Research session audit trail

### 12. `metadata --json`
- Export notebook metadata as structured JSON
- Richer than `list` — includes source summaries, creation dates, etc.

---

## Tier 2: Nice-to-Have for Phase 2+

### 13. `generate slide-deck` + `download slide-deck --format pptx`
- Editable PowerPoint generation from notebook sources
- `--format [detailed|presenter]` + `--length [default|short]`

### 14. `generate revise-slide "instruction" --artifact <id> --slide N`
- Natural language revision of individual slides
- Zero-based slide index

### 15. `share add <email> [--permission viewer|editor]`
- Collaborative notebook sharing
- `share status` shows current sharing state
- `share public --enable` for public link

### 16. `profile create/switch/delete`
- Multiple account profiles
- Work/personal separation

### 17. `generate cinematic-video "description" --style [whiteboard|kawaii|anime|...]`
- 9 visual styles for video generation
- High production value but long latency

---

## Key CLI Behaviors to Document in Phase 2 SKILL

1. **`--retry N`**: All generate commands support it — use instead of manual retry logic
2. **`--source ID` (repeatable)**: Scope any `ask` or `generate` to specific sources
3. **`-s/--source ID`** also works on `artifact suggestions` — get topic ideas from specific sources
4. **Mind map is synchronous** — no --wait needed, completes instantly
5. **`source wait <id> --timeout N --interval N`** — wait for source processing after add
6. **`--no-clobber`** is default on downloads — won't overwrite existing files
7. **`--force`** overrides no-clobber on downloads
8. **All IDs support partial prefix matching** — "abc" matches "abc123..."
9. **JSON output available on most commands** via `--json` flag
10. **Environment variables**: NOTEBOOKLM_HOME, NOTEBOOKLM_PROFILE, NOTEBOOKLM_AUTH_JSON, NOTEBOOKLM_LOG_LEVEL, NOTEBOOKLM_DEBUG_RPC

---

## Python API (for potential future programmatic integration)

```python
from notebooklm import NotebookLMClient

async with await NotebookLMClient.from_storage() as client:
    # Sources
    await client.sources.add_url(nb_id, url, wait=True)
    fulltext = await client.sources.get_fulltext(nb_id, source_id)
    
    # Chat
    result = await client.chat.ask(nb_id, "question", sources=[src1, src2])
    # result.answer, result.references
    
    # Artifacts
    status = await client.artifacts.generate_report(nb_id, description="...")
    await client.artifacts.wait_for_completion(nb_id, status.task_id)
    await client.artifacts.download_report(nb_id, "output.md")
    
    # Sharing
    await client.sharing.add_user(nb_id, "email@x.com", permission="viewer")
```

Note: Python API is async-first. CLI wraps it with asyncio.run(). If TAD ever needs programmatic integration (e.g., hooks calling NotebookLM), the Python API is available without CLI overhead.

---

## Phase 2 Design Implications

1. **Alex Research Director** should use `fulltext` to preview source quality before recommending deep dives
2. **`--source` targeting** enables Alex to ask about specific sources rather than the whole corpus — more precise research
3. **`--save-as-note`** enables automatic research audit trail without explicit `note create` steps
4. **`--retry N`** simplifies C2 report generation — remove manual retry logic from Phase 1, use CLI-native retry
5. **`language set`** should be part of notebook initialization — Alex asks user's preferred research output language
6. **`auth check --test`** should replace current preflight in all commands
7. **Quiz/flashcard generation** is a natural extension for *learn mode
8. **`source delete-by-title`** simplifies the post-research cleanup flow (C1 Step 4)
