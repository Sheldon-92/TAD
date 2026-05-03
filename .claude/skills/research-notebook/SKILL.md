---
name: research-notebook
description: TAD Research Notebook Manager — NotebookLM multi-source knowledge base for Alex *discuss and research workflows. 8 sub-commands for notebook lifecycle management.
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
    - "Auth valid: ~/.notebooklm/storage_state.json exists (not checking expiry)"
  on_fail: "Output: '⚠️ NotebookLM not ready. Run: bash .tad/cross-model/setup-notebooklm.sh'"
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

Step 3: Execute query
  → ~/.tad-notebooklm-venv/bin/notebooklm ask "<question>"
  → Capture output + measure wall-clock time

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

Step 2: Lightweight sync (existence check only)
  → For each active/dormant notebook:
    → ~/.tad-notebooklm-venv/bin/notebooklm list (check notebook_id still exists in cloud)
    → If not found → mark with ⚠️ "cloud-deleted"

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

Step 2: For each notebook → check cloud state
  → ~/.tad-notebooklm-venv/bin/notebooklm list (or equivalent)
  → Compare: source count, notebook existence

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

Step 2: Check each source
  → Added >90 days ago (source_stale_after_days) → ⚠️ possibly stale
  → URL unreachable (if WebFetch available) → ❌ broken
  → Same type >5 sources → suggest pruning (quality > quantity)

Step 3: Output curation report
  | # | Source | Type | Added | Status | Suggestion |
  |---|--------|------|-------|--------|------------|

Step 4: AskUserQuestion
  Options:
    - "Apply all suggestions"
    - "Decide each manually"
    - "Skip, no changes"

Step 5: Execute confirmed removals
  → ~/.tad-notebooklm-venv/bin/notebooklm source remove <source_id>  (if CLI supports)
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
    AND persisted by *ask (sets status=active on success)
    RESOLUTION: *list always recomputes active/dormant from last_queried when status != "archived"
    This means a persisted "dormant" that gets queried → *ask sets it to "active" immediately

  state_transitions:
    active_to_dormant: "Computed at *list time when last_queried > dormant_after_days"
    dormant_to_active: "*ask success → REGISTRY.yaml status = active"
    active_to_archived: "*archive command only"
    dormant_to_archived: "*archive command only"
    archived_to_active: "NOT automatic — user must *ask with explicit confirmation prompt"
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

---

## Quick Reference

| Command | Purpose |
|---------|---------|
| `*research-notebook create <topic>` | New notebook + guide sources + register |
| `*research-notebook add <url>` | Add source to active notebook |
| `*research-notebook ask <question>` | Query notebook (cross-source reasoning) |
| `*research-notebook list` | List all notebooks + lightweight sync |
| `*research-notebook sync` | Full cloud sync |
| `*research-notebook curate` | Audit + prune stale sources |
| `*research-notebook archive` | Archive notebook |
| `*research-notebook use <id>` | Set active notebook (session) |
