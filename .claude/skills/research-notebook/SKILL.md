---
name: research-notebook
description: TAD Research Notebook Manager — NotebookLM multi-source knowledge base for Alex *discuss and research workflows. 14 sub-commands for full research lifecycle management.
---

# /research-notebook Command (NotebookLM Integration)

## Overview

`*research-notebook` manages NotebookLM notebooks as persistent knowledge assets for TAD workflows.
Use for research-intensive topics requiring cross-source synthesis (YouTube + PDF + web).

**Key principle**: NotebookLM is a knowledge asset (stateful, persistent), not a stateless tool call.

**This skill is Alex-domain only** — research happens in design/discuss phase, not implementation.

---

## Preflight Check (runs before every sub-command)

```yaml
preflight:
  venv_path: "~/.tad-notebooklm-venv"
  notebooklm_bin: "~/.tad-notebooklm-venv/bin/notebooklm"
  checks:
    - "notebooklm CLI available: test -x ~/.tad-notebooklm-venv/bin/notebooklm"
    - "Version check: ver=$(~/.tad-notebooklm-venv/bin/notebooklm --version | awk '{print $NF}'); printf '%s\\n0.3.4\\n' \"$ver\" | sort -V | head -1 | grep -qx '0.3.4'"
    - "Auth valid: ~/.notebooklm/storage_state.json exists (not checking expiry)"
  on_fail_missing: "Output: '⚠️ NotebookLM not ready. Run: bash .tad/cross-model/setup-notebooklm.sh'"
  on_fail_version: "Output: '⚠️ notebooklm-py < 0.3.4 has broken AI endpoints — re-run: bash .tad/cross-model/setup-notebooklm.sh'"
  on_pass: "Proceed to sub-command"
  invocation_pattern: "~/.tad-notebooklm-venv/bin/notebooklm <subcommand>"
```

> Note: All `notebooklm` CLI invocations use the absolute path `~/.tad-notebooklm-venv/bin/notebooklm`
> (not `notebooklm` bare) to avoid PATH/venv activation dependency. The binary lives in the
> venv created by setup-notebooklm.sh at `~/.tad-notebooklm-venv/`.

---

## Commands

### `*research-notebook create <topic>`

Create a new notebook, add initial sources, register to REGISTRY.

```
Step 1: Create NotebookLM notebook
  → ~/.tad-notebooklm-venv/bin/notebooklm create "<topic>"
  → Capture notebook_id from output

Step 2: Guide source addition (AskUserQuestion)
  → "What sources would you like to add?"
  Options:
    - "I'll provide URL list"
    - "Search for conference/official YouTube videos on this topic"
    - "Both"
    - "Add later"

Step 3: If user selects YouTube search:
  → WebSearch: "{topic} conference talk OR official channel 2026 site:youtube.com"
  → Display video list (title + URL)
  → User selects which to add
  → ~/.tad-notebooklm-venv/bin/notebooklm source add <url>  (one by one)

Step 4: If user provides URL list:
  → For each URL: ~/.tad-notebooklm-venv/bin/notebooklm source add <url>
  → Report success/failure per URL

Step 5: Register to REGISTRY
  → Update .tad/research-notebooks/REGISTRY.yaml
  → Record: notebook_id, topic, source_count, sources list, created date, status=active

Step 6: Confirm
  → "✅ Notebook '{topic}' created, {N} sources added.
     Query with: *research-notebook ask 'your question'"
```

---

### `*research-notebook add <url> [--notebook <id>]`

Add a source to the active (or specified) notebook.

```
Step 1: Resolve target notebook
  → If --notebook <id> specified → use that
  → Else read REGISTRY.yaml active_notebook field

Step 2: Check source limit
  → Read source_count from REGISTRY
  → If source_count >= max_sources_per_notebook (config-workflow.yaml):
    → "⚠️ Notebook at source limit ({max}). Run *research-notebook curate first."
    → Exit

Step 3: Add source
  → ~/.tad-notebooklm-venv/bin/notebooklm use <notebook_id>
  → ~/.tad-notebooklm-venv/bin/notebooklm source add <url>
  → Capture success/failure

Step 4: Update REGISTRY
  → Append source entry (url, type, added date, title if detectable)
  → Increment source_count
  → Output: "✅ Source added. Total: {N} sources."
```

---

### `*research-notebook ask <question> [--notebook <id>]`

Query a notebook (cross-source reasoning).

```
Step 1: Resolve target notebook
  → If --notebook <id> specified → use that
  → Else read REGISTRY.yaml active_notebook field
  → If no active notebook → AskUserQuestion: "Which notebook to query?"
    Options: list of active notebooks + "Create new"

Step 2: Activate notebook
  → ~/.tad-notebooklm-venv/bin/notebooklm use <notebook_id>

Step 3: Execute query (stale conversation fallback)
  Layer 1 (normal):
    → ~/.tad-notebooklm-venv/bin/notebooklm ask "<question>"
    → Measure wall-clock time
    → If exit 0 and output non-empty → proceed to Step 4
    → If exit != 0 AND stderr matches "timeout|stale|conversation.*not found|expired":
  Layer 2 (stale conversation retry — only for stale-specific failures):
    → ~/.tad-notebooklm-venv/bin/notebooklm ask "<question>" -c 00000000-0000-0000-0000-000000000000
    → If still fails or exit != 0 for non-stale reason: "⚠️ Query failed. Check auth or notebook state."

Step 4: Return results
  → Output query result to user
  → Update REGISTRY.yaml: last_queried = today, status = active
    (if was dormant → auto-transition back to active; archived → warn user first)

Note: If called from Alex *discuss context → result feeds directly into discussion.
If called from research_decision_protocol step2_5 → result supplements WebSearch findings.

Status transition rules:
  → If notebook status == "archived": AskUserQuestion "This notebook is archived. Query anyway?" before proceeding
  → If notebook status == "dormant": query succeeds → set status = active (last_queried update implies reactivation)
  → If notebook status == "active": normal path, no status change needed
```

---

### `*research-notebook list`

List all registered notebooks + status + source count. Runs lightweight sync.

```
Step 1: Read REGISTRY.yaml

Step 2: Lightweight sync (single cloud call — P0-3 fix)
  → cloud_json=$(~/.tad-notebooklm-venv/bin/notebooklm list --json)
  → For each REGISTRY active/dormant notebook:
    → If notebook_id not found in cloud_json → mark with ⚠️ "cloud-deleted"
  (Note: notebooklm list returns ALL notebooks in one call — do NOT call per notebook)

Step 3: Apply lifecycle rules (from config-workflow.yaml research_notebook section)
  → active: last_queried within dormant_after_days → show normally
  → dormant: last_queried between dormant_after_days and archive_suggest_after_days
    → show with 💤 badge + "consider curate or archive"
  → archived: show with 📦 badge (collapsed)

Step 4: Output table
  | Notebook | Status | Sources | Last Queried | Notes |
  |----------|--------|---------|--------------|-------|
  | {topic}  | ✅/💤/📦 | {N}  | {date}       | {flags} |
```

---

### `*research-notebook sync`

Full sync: compare REGISTRY with NotebookLM cloud state.

```
Step 1: Read REGISTRY.yaml (all active/dormant notebooks)

Step 2: Single cloud call to get all notebooks
  → ~/.tad-notebooklm-venv/bin/notebooklm list --json
  → Compare each REGISTRY notebook: source count, existence

Step 3: Classify discrepancies
  → Local only (cloud deleted) → ⚠️ "REGISTRY outdated"
  → Source count mismatch (web UI edits) → ⚠️ "sources changed"
  → Consistent → ✅

Step 4: Present sync report + AskUserQuestion
  Options:
    - "Update REGISTRY to match cloud"
    - "Keep local state"
    - "Confirm each discrepancy individually"

Step 5: Apply user choice → update REGISTRY.yaml
```

---

### `*research-notebook curate [--notebook <id>]`

Audit and maintain source quality for a notebook.

```
Step 1: Read REGISTRY.yaml sources for target notebook

Step 2: Check each source (age-based staleness)
  → Added >90 days ago (source_stale_after_days) → ⚠️ possibly stale
  → URL unreachable (if WebFetch available) → ❌ broken
  → Same type >5 sources → suggest pruning (quality > quantity)

Step 2b (content-staleness check — URL-type sources only):
  → For each URL-type source (skip type=youtube/text/file; max 20 to avoid slowness):
    → ~/.tad-notebooklm-venv/bin/notebooklm source stale <source_id> -n <notebook_id>
    → ⚠️ INVERTED exit codes (shell `if` compatible):
      exit 0 = stale (content changed at source URL)
      exit 1 = fresh (no change)
  → Display combined age + content staleness:
    | Source | Age-Stale | Content-Stale | Action |
    | {title} | 🟢/🔴 (>90 days) | 🟢/🔴 (CLI check) | — / "Refresh?" |

Step 2c (refresh stale sources — URL-type only):
  → If content-stale URL sources found:
    → AskUserQuestion: "Found {N} content-stale sources. Refresh?"
      Options:
        - "Refresh all content-stale" → ~/.tad-notebooklm-venv/bin/notebooklm source refresh <source_id> -n <id> for each
          (Note: refresh only works for URL/Drive sources, not YouTube/text/file types)
        - "Skip, review manually" → continue
        - "Skip all refreshes" → continue

Step 3: Output curation report
  | # | Source | Type | Added | Age-Stale | Content-Stale | Suggestion |
  |---|--------|------|-------|-----------|---------------|------------|

Step 4: AskUserQuestion (for removal suggestions)
  Options:
    - "Apply all removal suggestions"
    - "Decide each manually"
    - "Skip, no changes"

Step 5: Execute confirmed removals
  → ~/.tad-notebooklm-venv/bin/notebooklm source delete <source_id> -n <notebook_id> --yes
  → Update REGISTRY.yaml source list + source_count
```

---

### `*research-notebook archive [--notebook <id>]`

Archive a notebook: export history → update registry → mark archived.

```
Step 1: Confirm with user (AskUserQuestion)
  → "Archive notebook '{topic}'? It will remain in NotebookLM but marked archived in REGISTRY."
  Options: "Yes, archive" / "Cancel"

Step 2: Ensure archive directory exists
  → mkdir -p .tad/research-notebooks/archived/

Step 3: Export query history (if any recorded in REGISTRY)
  → Write to .tad/research-notebooks/archived/{notebook_id}-history.md
  → If Write fails → ABORT (do NOT proceed to Step 4); report error to user

Step 4: Update REGISTRY.yaml (only after Step 3 succeeds)
  → Set status: archived
  → Record archived_date
  → If active_notebook == this notebook_id → clear active_notebook field (set to null)

Step 5: Confirm
  → "📦 Notebook '{topic}' archived. REGISTRY updated."
```

---

### `*research-notebook use <notebook_id>`

Set active notebook for this session (session-scoped override).

```
Step 1: Verify notebook_id exists in REGISTRY.yaml
  → If not found → "⚠️ Notebook not found. Run *research-notebook list to see available."

Step 2: Update REGISTRY.yaml active_notebook field

Step 3: Confirm
  → "✅ Active notebook set to '{topic}' ({notebook_id})"
```

---

### `*research-notebook research <topic> [--mode fast|deep]`

High-level command: automated source discovery + import + summary in one step.

```
Step 0: Resolve target notebook
  → If --notebook <id> specified → use that
  → Else read REGISTRY.yaml active_notebook
  → If no active notebook → AskUserQuestion: "Which notebook?"
    Options: list of active notebooks + "Create new notebook for '{topic}'"

Step 1: Mode selection
  → If --mode fast explicitly specified by user → skip AskUserQuestion, proceed directly
  → If --mode deep explicitly specified by user:
    → AskUserQuestion confirmation:
      "Deep mode 将搜索 50+ 源并永久导入 (~3-4min)。确认？"
      Options: "确认 Deep" / "改用 Fast" / "Cancel"
  → If no --mode specified → AskUserQuestion:
    "即将让 NotebookLM 搜索 '{topic}' 并自动导入源。"
    Options: "Fast (10 sources, ~1s)" / "Deep (50+ sources, ~3-4min)" / "Cancel"

Step 2: Execute
  → If fast mode:
    → ~/.tad-notebooklm-venv/bin/notebooklm source add-research "{topic}" --mode fast --import-all -n <id>
  → If deep mode:
    → ~/.tad-notebooklm-venv/bin/notebooklm source add-research "{topic}" --mode deep --import-all --no-wait -n <id>
    → Portable timeout for research wait (max 600s):
      timeout_cmd="timeout"; command -v gtimeout >/dev/null && timeout_cmd="gtimeout"
      $timeout_cmd 600 ~/.tad-notebooklm-venv/bin/notebooklm research wait -n <id>
    → If exit code 124 (timeout): "⚠️ Deep research still running after 10min. Sources may be partially imported. Check: *research-notebook list" + EXIT
  → Capture output (source count + titles)
  → ⚠️ ERROR HANDLING:
    - If exit code != 0 (non-timeout): "❌ Research failed: {stderr}" + EXIT (do NOT proceed to Step 3)
    - If source_count == 0: "⚠️ No sources found for '{topic}'. Try broader keywords." + EXIT

Step 3: Summary
  → ~/.tad-notebooklm-venv/bin/notebooklm summary --topics -n <id>
  → Display: "✅ {N} sources added. Notebook summary: {summary}"
  → Display: "Suggested topics to explore: {topics}"

Step 4: Post-research source review (deep mode only)
  → If --mode deep AND source_count > 20:
    → ~/.tad-notebooklm-venv/bin/notebooklm source list -n <id>
    → AskUserQuestion: "Deep research 添加了 {N} 个源。要现在清理不相关的源吗？"
      Options:
        - "查看并清理" → display source titles, user picks which to delete
          → For each selected: ~/.tad-notebooklm-venv/bin/notebooklm source delete <source_id> -n <id> --yes
        - "全部保留" → continue
        - "稍后用 *research-notebook curate 清理" → continue
  → If fast mode: skip (10 sources, low cleanup urgency)

Step 5: Update REGISTRY
  → Update source_count (after any deletions), last_queried, status=active
```

---

### `*research-notebook report <description>`

Generate a structured report + download as local markdown.

```
Step 0: Resolve target notebook (same as ask command)

Step 1: Validate download capability (first-time only per session)
  → ~/.tad-notebooklm-venv/bin/notebooklm download report --help 2>&1 | grep -q "dry-run"
  → If grep matches → CLI supports report download, proceed
  → If not → "⚠️ download report not available in this CLI version. Update: bash .tad/cross-model/setup-notebooklm.sh" + EXIT
  → Cache validation result: skip this check on subsequent *report calls in same session
  (Note: --dry-run validates CLI capability, not artifact presence)

Step 2: Generate
  → ~/.tad-notebooklm-venv/bin/notebooklm generate report "{description}" -n <id> --wait
  → Display: "Generating report... (typically 30-90s)"
  → If exit code != 0: "❌ Report generation failed: {stderr}" + EXIT

Step 3: Download with exponential backoff retry
  → output_path: .tad/evidence/research/{notebook_topic}/{YYYY-MM-DD}-{slug}.md
    where {slug} = first 50 chars of {description}, lowercase, non-alphanumeric → "-",
    collapse multiple "-", trim leading/trailing "-"
    (collision: if file exists, append "-2", "-3", etc.)
    (mkdir -p the directory if missing)
  → ~/.tad-notebooklm-venv/bin/notebooklm download report --latest -n <id> "{output_path}"
  → If download returns empty or error:
    → Wait 20s, retry (attempt 2)
    → Wait 30s, retry (attempt 3)
    → If still fails: "⚠️ Report generated but download failed. View in NotebookLM web UI."

Step 4: Display
  → Read first 20 lines of downloaded file
  → Count lines + words
  → Output: "✅ Report saved: {path} ({line_count} lines, {word_count} words)"
```

---

### `*research-notebook guide [--source <id>]`

Per-source AI summary: understand what each source contributes.

```
Step 0: Resolve target notebook (same as ask command)

Step 1: Source selection
  → If --source <id> specified → use that source directly
  → If no --source: ~/.tad-notebooklm-venv/bin/notebooklm source list -n <id>
    → AskUserQuestion: "Which source(s) to summarize?" (display numbered list)

Step 2: For each selected source:
  → ~/.tad-notebooklm-venv/bin/notebooklm source guide <source_id> -n <id> --json
  → Parse JSON: {summary, keywords[]}

Step 3: Display formatted summary + keywords
  → "📖 Source: {title}"
  → Summary paragraph
  → "Keywords: {kw1}, {kw2}, ..."
```

---

### `*research-notebook configure [--persona <text>] [--mode <mode>]`

Set notebook research persona and query mode.

```
Step 0: Resolve target notebook (same as ask command)

Step 1: If no flags → show current config + AskUserQuestion for what to change
  Options:
    - "Set custom persona (up to 10,000 chars)"
    - "Use preset mode (learning-guide / concise / detailed)"
    - "Reset to default"
    - "Cancel"

Step 2: Execute (mutually exclusive cases — check in order)
  Case A — Reset (selected from Step 1 menu OR --mode default passed):
    → ~/.tad-notebooklm-venv/bin/notebooklm configure --mode default --persona "" -n <id>
  Case B — Both --persona AND --mode flags specified simultaneously:
    → ~/.tad-notebooklm-venv/bin/notebooklm configure --persona "{text}" --mode {mode} -n <id>
  Case C — Persona only (--persona specified, no --mode):
    → ~/.tad-notebooklm-venv/bin/notebooklm configure --persona "{text}" -n <id>
  Case D — Mode only (--mode specified, no --persona):
    → ~/.tad-notebooklm-venv/bin/notebooklm configure --mode {mode} -n <id>
  (Note: Reset uses BOTH --mode default AND --persona "" — required to reset both axes)

Step 3: Confirm
  → "✅ Notebook configured."
  → If persona set: "Persona: {first 50 chars}..."
  → If mode set: "Mode: {mode}"

Note: persona up to 10,000 chars. Useful for domain-specific framing (e.g., "You are a security researcher
reviewing offensive AI techniques from a defensive blue-team perspective...").
```

---

### `*research-notebook topics`

Quick notebook overview + suggested query topics. Display-only, returns to standby.

```
Step 0: Resolve target notebook (same as ask command)

Step 1: Fetch summary + topics (stale conversation fallback)
  Layer 1 (normal):
    → ~/.tad-notebooklm-venv/bin/notebooklm summary --topics -n <id>
    → If exit 0 and output non-empty → proceed to Step 2
    → If exit != 0 AND stderr matches "timeout|stale|conversation.*not found|expired":
  Layer 2 (retry with fresh conversation — stale-specific failures only):
    → ~/.tad-notebooklm-venv/bin/notebooklm summary --topics -n <id> -c 00000000-0000-0000-0000-000000000000
    → If still fails or non-stale error: report error to user

Step 2: Display
  → Output formatted summary paragraph
  → Output numbered topic list: "1. {topic} 2. {topic} ..."
  → Return to standby — no AskUserQuestion (user invokes *research-notebook ask themselves)

Step 3: Update REGISTRY
  → Update last_queried = today, status = active
  (topics consumes AI quota like ask — lifecycle should track it equally)
```

---

### `*research-notebook ingest <file_path>`

Add a local research finding (.md or .txt) as a notebook source.

**Knowledge loop status: VERIFIED GO** — `source add` with local file paths is empirically
confirmed to participate in `ask` context within ~30s (verified 2026-05-04, TASK-20260504-002).

```
Step 0: Resolve target notebook (same as ask command)

Step 1: Validate file
  → Check file exists: test -f "{file_path}"
  → Check extension is .md or .txt
  → Check file size < 500KB: du -k "{file_path}" | awk '{print $1}'
  → If any check fails: report error + EXIT

Step 2: AskUserQuestion confirmation
  → "将 {filename} 的内容作为新 source 加入 notebook '{topic}'。确认？"
  Options: "确认" / "取消"

Step 3: Execute
  → ~/.tad-notebooklm-venv/bin/notebooklm source add "{file_path}" -n <id>
  → If exit code != 0: "❌ source add failed: {stderr}" + EXIT

Step 4: (Optional) Verify ingestion — only if --verify flag passed
  → Default (no --verify): skip. source add success implies ingestion (~30s indexing).
  → If --verify flag present:
    → Wait 30s
    → ~/.tad-notebooklm-venv/bin/notebooklm ask "summarize the content from {filename}" -n <id> -c 00000000-0000-0000-0000-000000000000
    → If answer references file content: "✅ Ingestion verified — content is queryable."
    → If answer doesn't reference content: "⚠️ Content added but not yet indexed. Try asking again in ~60s."
      (This is a transient state — content IS added, may need more time to index)

Step 5: Update REGISTRY
  → Increment source_count, add source entry (filename, type=file, added date)
  → Update last_queried = today, status = active

Step 6: Confirm
  → "✅ {filename} added as source to notebook '{topic}'. Total sources: {N}."
  → Reminder: "Content will be queryable via *ask within ~30s."
```

---

## Notebook Lifecycle Rules

```yaml
lifecycle_rules:
  states:
    active:
      condition: "last_queried within dormant_after_days"
      display: "✅ Active"
      action: "Normal use"
    dormant:
      condition: "last_queried between dormant_after_days and archive_suggest_after_days"
      display: "💤 Dormant"
      action: "Suggest curate or archive at list time"
    archived:
      condition: "User executed *archive"
      display: "📦 Archived"
      action: "REGISTRY entry retained, notebook remains in NotebookLM"

  thresholds: "Configured in .tad/config-workflow.yaml research_notebook section"
  source_limit: "Configured in .tad/config-workflow.yaml research_notebook.max_sources_per_notebook"

  status_field_semantics: |
    The `status` field in REGISTRY.yaml is a HYBRID:
    - "archived" is USER-SET (only changes via *archive, never auto)
    - "active" and "dormant" are DERIVED from last_queried at display time (*list)
    AND persisted by *ask and *topics (both set status=active on success)
    RESOLUTION: *list always recomputes active/dormant from last_queried when status != "archived"
    This means a persisted "dormant" that gets queried → *ask/*topics sets it to "active" immediately

  state_transitions:
    active_to_dormant: "Computed at *list time when last_queried > dormant_after_days"
    dormant_to_active: "*ask or *topics success → REGISTRY.yaml status = active"
    active_to_archived: "*archive command only"
    dormant_to_archived: "*archive command only"
    archived_to_active: "NOT automatic — user must *ask with explicit confirmation prompt"
    topics_updates_last_queried: "YES — *topics consumes AI quota like *ask and updates last_queried"
```

---

## Integration Notes

- **Auth expiry**: NotebookLM sessions expire (Google cookies). When CLI returns auth error,
  prompt user: "Run bash .tad/cross-model/setup-notebooklm.sh to refresh auth."
- **YouTube sources**: Only videos with captions work via CLI. Use conference talks
  (CCC, RSAC, Black Hat) or official channels (Anthropic, Google) for reliable ingestion.
- **Query latency**: 23-43s per query. Normal for research tasks (not for real-time workflows).
- **REGISTRY is local index, cloud is canonical**: Use `*sync` when discrepancies appear. Local metadata (notes, titles, added dates) is preserved during sync — only source presence/count is compared to cloud.
- **Cross-topic isolation**: Different topics → different notebooks. Cross-source redundancy is OK.
- **URL curate skip**: Sources with `url` starting with `(web-UI added` are exempt from reachability checks — these were added via NotebookLM web UI and URL was not captured at add-time.
- **Stale conversation**: Layer 2 retry (`-c 00000000...`) fires ONLY on stale-specific stderr signals ("timeout", "stale", "conversation not found", "expired") — NOT on all exit != 0.
- **Minimum version**: notebooklm-py 0.3.4+. Earlier versions (0.1.1) have deprecated RPC endpoints — all AI-dependent commands fail.
- **Local file ingestion**: `source add /path/to/file.md` is VERIFIED GO — local .md and .txt files are accepted and queryable via `ask` within ~30s.
- **source refresh**: Only works for URL/Drive source types. YouTube, text, and file sources cannot be refreshed.

---

## Quick Reference

| Command | Purpose |
|---------|---------|
| `*research-notebook create <topic>` | New notebook + guide sources + register |
| `*research-notebook add <url>` | Add source to active notebook |
| `*research-notebook ask <question>` | Query notebook (cross-source reasoning) |
| `*research-notebook list` | List all notebooks + lightweight sync |
| `*research-notebook sync` | Full cloud sync |
| `*research-notebook curate` | Audit + prune + content-staleness check |
| `*research-notebook archive` | Archive notebook |
| `*research-notebook use <id>` | Set active notebook (session) |
| `*research-notebook research <topic>` | Auto source discovery + import + summary |
| `*research-notebook report <desc>` | Generate + download report as local .md |
| `*research-notebook guide` | Per-source AI summary + keywords |
| `*research-notebook configure` | Set notebook persona / query mode |
| `*research-notebook topics` | Quick overview + suggested query topics |
| `*research-notebook ingest <file>` | Add local .md/.txt as source (knowledge loop GO) |
