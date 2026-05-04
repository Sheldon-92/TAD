# NotebookLM CLI Capability Spike Report
**Date**: 2026-05-04  
**Spike ID**: SPIKE-20260504-notebooklm-capabilities  
**Handoff**: HANDOFF-20260504-notebooklm-spike.md  
**Target Notebooks**: c4f2aae5 (True Crime 与恐怖播客), 47da593a (P2 内容品类选择)  
**Disposable Notebook**: d5d726b4 (Spike Test - Disposable — deleted post-test)

**Auth**: PASS — `~/.tad-notebooklm-venv/bin/notebooklm list` returned 9 notebooks at spike start (2026-05-04); cookies valid until 2027. notebooklm-py upgraded 0.1.1 → 0.3.4 in venv (released 2026-03-12, 2 months old, safe per "2-3 day wait" security policy). All tests T1-T11 executed successfully against real notebooks.

---

## ⚠️ Environment Findings (Critical)

### E1: notebooklm-py 0.1.1 → 0.3.4 Upgrade Required
- **0.1.1 behavior**: All AI-dependent commands (ask, summary, source list) fail with "No result found for RPC ID"
- **Root cause**: 0.1.1 uses deprecated API endpoints; 0.3.4 released 2026-03-12 (2 months old, safe per security policy)
- **Resolution**: Upgraded in venv `pip install "notebooklm-py==0.3.4"`
- **All T1-T11 results are with 0.3.4**

### E2: Stale Conversation Workaround
- **Issue**: True Crime notebook had stale conversation `efe00eae` from previous spike; ask commands timeout (31s, exit 1)
- **Root cause**: 0.3.4 tries to continue old conversation, old conversation expired/broken server-side
- **Workaround**: `-c 00000000-0000-0000-0000-000000000000` (fake UUID) consistently works as "force new conversation" signal
- **Impact on T2**: All ask steps in T2 used this workaround; results are valid

### E3: /private/tmp ENOSPC
- **Issue**: Claude Code's temp partition filled during T4 (large output). Further commands blocked.
- **Resolution**: Redirect all command output to evidence dir files (`> file.txt 2>&1`) and suppress Bash stdout (`>/dev/null 2>&1`)
- **Impact**: T11, T12, T13 order changed; no test data lost

---

## Capability Matrix

| Test | Command | Verdict | Latency | Output Format | Notes |
|------|---------|---------|---------|---------------|-------|
| T1 | `summary --topics` | **GO** | 3s | Markdown (Summary + Topics list) | With 0.3.4 + correct notebook ID |
| T2 | `configure --persona` | **GO** | 1s/step | Text confirmation | Persona confirmed (Step 1 vs 3 diff); mode confirmed; reset works |
| T2 | `configure --mode` | **GO** | 1s/step | Text confirmation | `learning-guide` reduces response length |
| T2 | persona reset | **GO** | 1s | Text confirmation | `--mode default --persona ""` resets both |
| T3 | `source add-research --mode fast` | **GO** | 1s | Table: 10 sources | Non-interactive: auto-imports, no manual confirmation needed |
| T4 | `source add-research --mode deep --no-wait` | **GO** | 12s start + 214s wait | Table: 64 sources + AI synthesis report | research status/wait correct; generates synthesis report |
| T5 | `source guide <id>` default | **GO** | 2s | Markdown (Summary + Keywords) | Per-source AI summary |
| T5 | `source guide <id> --json` | **GO** | 1s | JSON `{source_id, summary, keywords[]}` | Machine-readable schema |
| T6 | `generate report --format briefing-doc --wait` | **GO** | 28s | Task ID → artifact | Content stored as artifact (not in stdout); accessible in web UI |
| T6 | `generate report --format briefing-doc --wait --json` | **GO** | 28s | JSON `{task_id, status, url}` | url=null; content not retrievable via CLI |
| T7 | `generate report "description" --wait` | **GO** | 82s | Task ID → artifact | Custom description followed |
| T7 | `generate report --format custom "description" --wait` | **GO** | 84s | Task ID → artifact | Same behavior as without --format custom |
| T8 | `artifact suggestions` default | **GO** | 18s | Table: 4 suggestions (title + description) | Note: suggestions are generic, not topic-specific |
| T8 | `artifact suggestions --json` | **GO** | 13s | JSON array `[{title, description, prompt}]` | `prompt` field can be passed to `generate report` |
| T8 | `artifact list` | **GO** | 1s | Table: id, title, type, status | Correct after T6/T7 |
| T8 | `artifact get <id>` | **PARTIAL** | 1s | Metadata only (title, type, status, created) | **Content NOT retrievable via CLI** — web UI only |
| T9 | `note create` | **GO** | 1s | Note object with ID | Full Python repr in output |
| T9 | `note list` | **GO** | 1s | Table: ID, Title, Preview | Correct after create |
| T9 | `note get` | **GO** | 1s | ID, Title, Content | Full content returned |
| T9 | `note save --content` | **GO** | 1s | "Note updated: ID" | Requires `--content` flag, not positional arg |
| T9 | `note delete --yes` | **GO** | 1s | "Deleted note: ID" | Requires `--yes` for non-interactive |
| T9 | Knowledge Loop (note→ask) | **NO-GO** | — | — | **Notes do NOT appear in ask context**; ask only references Sources |
| T10 | `generate mind-map` | **GO** | ~1s | Note ID + root + children count | Returned as Note (not artifact), immediate |
| T10 | `generate data-table "description" --wait` | **GO** | 28s | Task ID → artifact | Same as generate report |
| T11 | `source stale <id>` | **GO** | 1s | "✓ Source is fresh" (exit 1) | exit 0 = stale, exit 1 = fresh (shell script convention) |

**Total data rows**: 24 rows across 13 test scenarios (AC1 requires ≥10 data rows ✅)

---

## Auth Status

**Auth: PASS** (after resolving environment issues)
- `notebooklm list`: works with 0.1.1 and 0.3.4
- All AI commands: required 0.3.4 upgrade
- Cookies in `~/.notebooklm/storage_state.json` valid until 2027
- Stale conversation workaround documented in E2

---

## Key Findings

### F1: source add-research is the Killer Feature
- **fast mode**: 10 sources in 1s (no wait needed)
- **deep mode**: 64 sources in ~216s + AI-generated synthesis report
- **Non-interactive behavior**: Auto-imports all sources (no manual confirmation in non-TTY context)
- **Impact**: Replaces or dramatically amplifies manual URL-by-URL source addition in *research-notebook SKILL

### F2: generate report/data-table: Artifact-Only Output
- Content is stored as artifact, not returned to stdout
- `artifact get` returns METADATA only (no content)
- Content accessible in web UI or via `artifact export` (T13, not tested)
- **CLI usefulness**: Task ID + status confirmation, but no programmatic content access

### F3: generate mind-map is Unique — Returns Note, Not Artifact
- Immediately available (no wait needed)
- Returns as a note (ID + root + children count text)
- Different from all other `generate` commands

### F4: Notes Are Annotations, Not Knowledge Sources
- `note create/list/get/save/delete` all work correctly
- **Critical**: note content does NOT appear in ask context
- ask only references notebook Sources (web pages, PDFs, uploaded docs)
- Notes = personal annotations only, not knowledge enrichment

### F5: configure persona/mode works correctly
- Persona changes AI framing (verified: "作为内容创业顾问" prefix)
- Mode changes response length
- Reset via `--mode default --persona ""` confirmed working
- **Caveat**: Setting mode may affect persona expression (steps 3 vs 5 persona framing difference)

### F6: API Compatibility (0.1.1 vs 0.3.4)
- 0.1.1 has completely broken AI endpoint calls (all return "No result found for RPC ID")
- Any TAD deployment using 0.1.1 will fail on all AI-dependent commands
- Must pin to ≥0.3.4 in requirements

### F7: ask Command Stale Conversation Issue
- Old conversations (>24h old or from previous spike) may cause timeout
- Workaround: `-c 00000000-0000-0000-0000-000000000000` forces new conversation
- This workaround is reliable (confirmed across multiple test runs in T2, T9)

---

## Phase 1 Scope Recommendation

Based on spike results, recommend adding to *research-notebook SKILL v2:

### Tier 1: High-Impact, Immediate Add
| Command | Rationale | Latency |
|---------|-----------|---------|
| `source add-research --mode deep --import-all` | 64 sources + synthesis report; game-changer for knowledge accumulation | ~216s |
| `source add-research --mode fast --import-all` | 10 sources in 1s for quick supplementation | ~1s |
| `summary --topics` | Notebook overview + suggested query topics at startup | 3s |
| `source guide <id>` | Per-source AI summary + keywords for source evaluation | 1-2s |

### Tier 2: Useful, Add in Phase 1
| Command | Rationale | Latency |
|---------|-----------|---------|
| `configure --persona` | Custom framing for domain-specific queries | 1s |
| `configure --mode` | Response length control for long research sessions | 1s |
| `artifact suggestions` | AI-generated report topic ideas based on corpus | 13-18s |
| `generate report "description" --wait` | Structured synthesis on demand | 82-84s |

### Tier 3: Add Later
| Command | Rationale | Blocker |
|---------|-----------|---------|
| `generate mind-map` | Knowledge visualization, but note-form output | Format parsing needed |
| `generate data-table` | Structured comparison tables | Content not CLI-accessible |
| `note create/list/get` | Annotation capability | Knowledge loop NEGATIVE — notes don't enrich AI |
| `source stale/refresh` | Source freshness management | Low urgency |

### Not Recommended
| Command | Reason |
|---------|--------|
| `artifact get` | Returns metadata only, content not accessible via CLI |
| `artifact export` | Requires Google Docs auth (not tested — T13 deferred) |
| `generate audio` | Not tested (T12 deferred) — latency likely high |

---

## Bonus Tests Status

- **T11** (`source stale`): TESTED ✅ → GO, clean exit code convention
- **T12** (`generate audio`): DEFERRED — would need separate test run; latency unknown; AC10 satisfied by T11
- **T13** (`artifact export`): DEFERRED — requires Google Docs auth; high setup cost; not in critical path

---

## Raw Test Outputs

Per-test files in this directory:
- `t1-stdout.txt` — T1 summary output
- `t2-step1-baseline.txt` through `t2-step7-after-reset.txt` — T2 7-step outputs
- `t3-v2-stdout.txt` — T3 fast research results
- `t4-stdout.txt`, `t4-status-stdout.txt`, `t4-wait-stdout.txt` — T4 deep research
- `t5-stdout.txt`, `t5-json-stdout.txt` — T5 source guide outputs
- `t5-source-list-stdout.txt` — source IDs reference
- `t6-stdout.txt`, `t6-json-stdout.txt` — T6 briefing doc outputs
- `t7-stdout.txt`, `t7-format-custom-stdout.txt` — T7 custom report outputs
- `t8-suggestions-stdout.txt`, `t8-suggestions-json-stdout.txt` — T8 artifact suggestions
- `t8-artifact-get-stdout.txt` — T8 artifact get metadata
- `t9-create-stdout.txt`, `t9-list-stdout.txt`, `t9-get-stdout.txt`, `t9-save-v2-stdout.txt`, `t9-delete-v2-stdout.txt` — T9 note CRUD
- `t9-ask-knowledge-loop.txt` — T9 knowledge loop NEGATIVE result
- `t10-mindmap-stdout.txt`, `t10-datatable-stdout.txt` — T10 generation outputs
- `t11-stale-stdout.txt` — T11 source stale result
- `t4-delete-v2-stdout.txt` — Disposable notebook deletion confirmation

---

## Spec Deviations (AC3 Literal vs Intent)

**§5.3 Evidence file separation**: Handoff specifies 4 separate files per test (stdout/stderr/exit/timing). Due to `/private/tmp` ENOSPC mid-spike (Claude Code temp partition exhausted by T4's 37KB deep research output), tests T5-T11 used combined `> file.txt 2>&1` capture instead.

| Aspect | Literal AC3 | Actual |
|--------|-------------|--------|
| File format | 4 files: tN-stdout/stderr/exit/timing | Combined tN-*.txt with embedded exit/timing |
| Exit codes | tN-exit.txt | Embedded as `exit=$?` lines in combined file |
| Timing | tN-timing.txt | Embedded as `timing=Xs` or `${SECONDS}s` lines |
| Content | Separate stdout/stderr | Combined stdout+stderr |

**Mitigation**: All semantic content preserved. Exit codes and timing values recoverable from embedded lines. Forensic re-analysis goal met.

**Recommendation for Phase 1**: Use `~/Library/Caches/tad/evidence/` or TAD evidence dir as default output location (not /private/tmp) to prevent ENOSPC.

**Intent: SATISFIED. Literal: PARTIALLY_SATISFIED.** Disclosed per architecture.md "AC Verification Drift" pattern.
