---
name: research-github
description: GitHub Awesome-List Registry — discover, browse, and create deep-research notebooks from GitHub repos. 6 commands for Alex research phase.
---

# /research-github Command (GitHub Knowledge Discovery)

## Overview

`*research-github` manages the GitHub Awesome-List Registry as TAD's open-source discovery layer.
Use to find relevant repos before starting a project, then create deep-research NotebookLM notebooks.

**Key principle**: Awesome-lists are community-curated "book lists" — leverage existing curation, don't reinvent.

**This skill is Alex-domain only** — research happens in design/discuss phase, not implementation.

---

## Preflight Check (runs before every sub-command)

```yaml
preflight:
  notebooklm_bin: "~/.tad-notebooklm-venv/bin/notebooklm"
  registry_path: ".tad/github-registry/REGISTRY.yaml"
  checks:
    - "gh CLI authenticated: gh auth status 2>&1 | grep -q 'Logged in'"
    - "notebooklm CLI available: test -x ~/.tad-notebooklm-venv/bin/notebooklm"
    - "notebooklm version ≥0.3.4: ver=$(~/.tad-notebooklm-venv/bin/notebooklm --version | awk '{print $NF}'); printf '%s\\n0.3.4\\n' \"$ver\" | sort -V | head -1 | grep -qx '0.3.4'"
    - "REGISTRY exists: test -f .tad/github-registry/REGISTRY.yaml"
  on_fail_gh: "Output: '⚠️ gh CLI not authenticated. Run: gh auth login'"
  on_fail_notebooklm: "Output: '⚠️ NotebookLM not ready. Run: bash .tad/cross-model/setup-notebooklm.sh'"
  on_fail_version: "Output: '⚠️ notebooklm-py < 0.3.4 has broken AI endpoints — re-run: bash .tad/cross-model/setup-notebooklm.sh'"
  on_fail_registry: "Output: '⚠️ REGISTRY.yaml not found. Expected at .tad/github-registry/REGISTRY.yaml'"
  on_pass: "Proceed to sub-command"
  note: "gh auth check is NOT required for: list, scan-log. Required for all other commands (explore, notebook, search, refresh, scan, add)."
```

> Note: All `notebooklm` CLI invocations use the absolute path `~/.tad-notebooklm-venv/bin/notebooklm`
> to avoid PATH/venv activation dependency. Never use bare `notebooklm`.

---

## Commands

### `*research-github list`

Show all domains with awesome-list count and notebook status.

```
Step 1: Read .tad/github-registry/REGISTRY.yaml
  → Parse all domains

Step 2: Read research-notebooks REGISTRY for staleness check:
  → Load .tad/research-notebooks/REGISTRY.yaml
  → Build lookup set: {notebook.id → notebook.status}

Step 3: Format table output:
  | Domain | Slug | # Lists | Notebook | Last Researched |
  |--------|------|---------|----------|-----------------|
  For each domain:
    - Domain = domain.name
    - Slug = domain.slug
    - # Lists = len(domain.awesome_lists)
    - Notebook: if domain.notebook_id is null → "—"
                if domain.notebook_id found in research-notebooks lookup → domain.notebook_id
                if domain.notebook_id NOT found in research-notebooks lookup → "{notebook_id} (stale ref)"
    - Last Researched = domain.last_researched (or "never" if null)

Step 4: Display summary line:
  "{N} domains, {M} total awesome-lists registered."
  "{K} domains have associated NotebookLM notebooks."
```

---

### `*research-github search <topic>`

Search GitHub for new awesome-lists related to a topic.

```
Step 1: Run GitHub search:
  → gh search repos "awesome {topic}" --limit 10 --sort stars --json fullName,stargazersCount,description,url
  → Parse JSON output

Step 2: Format results:
  | Repo | Stars | Description |
  |------|-------|-------------|
  For each result, display fullName, stargazersCount, description (truncated to 80 chars)

Step 3: AskUserQuestion — "Found {N} repos. What would you like to do?"
  Options:
    - "Add one to the registry" → go to *research-github add
    - "Add multiple" → loop through add
    - "Just exploring, no action needed"
    - "Research one of these now" → go to *research-github notebook

Note: This searches for new lists to add — not for researching existing ones.
```

---

### `*research-github add <repo>`

Add a new awesome-list to the registry under a domain.

```
Step 1: Validate repo exists:
  → gh api repos/{repo} --jq '.full_name,.stargazers_count,.description' 2>/dev/null
  → If error: "⚠️ Repo '{repo}' not found on GitHub. Check repo name (format: owner/repo)."
  Note: gh api (REST) uses snake_case (.full_name, .stargazers_count).
        gh search repos --json uses camelCase (fullName, stargazersCount) — these are different APIs.

Step 2: Fetch repo metadata:
  stars = gh api repos/{repo} --jq '.stargazers_count'
  url = "https://github.com/{repo}"
  description = gh api repos/{repo} --jq '.description'

Step 3: AskUserQuestion — "Which domain should this go under?"
  Options: [list of domain names from REGISTRY.yaml] + "Create new domain"

Step 4: If "Create new domain":
  AskUserQuestion: "Enter domain name and slug"
  → Add new domain entry to REGISTRY.yaml with empty awesome_lists

Step 5: Add entry to REGISTRY.yaml under selected domain:
  Entry format:
    - repo: "{owner}/{repo}"
      stars: {stars}
      url: "{url}"
      last_checked: {today YYYY-MM-DD}
      description: "{description}"

Step 6: Confirm: "✅ Added {repo} ({stars} ⭐) to '{domain}' domain."
```

---

### `*research-github explore <domain>`

Browse a domain's awesome-list README, extract top repos, present selection.

```
Step 1: Look up domain in REGISTRY.yaml by name or slug
  → If not found: "Domain '{domain}' not in registry. Available: {list}. Try *research-github search <topic> to find new lists."

Step 2: For each awesome-list in domain.awesome_lists:
  Read README via raw content API:
  → gh api -H "Accept: application/vnd.github.raw+json" repos/{owner}/{repo}/contents/README.md
  → This returns raw markdown text directly (no JSON envelope, no base64 decode needed)
  → On error: "⚠️ Could not fetch README for {repo}: {error}"

Step 3: Extract repo links from README:
  → grep -oE 'https://github\.com/[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+' | sort -u
  → De-duplicate by {owner}/{repo}
  → Filter: exclude links to issues, pulls, wiki, user profiles
    (keep only repo root URLs: no /issues, /pull, /wiki, /blob, /tree suffixes)

Step 4: Fallback — if <5 links extracted from a list:
  → Show README section headers (lines starting with ##)
  → "Could only auto-extract {N} repos from {repo}. Here are the README sections — pick repos manually."

Step 5: Collect extracted repos across all awesome-lists in the domain
  → Deduplicate across lists

Step 6: Fetch metadata for extracted repos, then present selection:
  → For each extracted repo (best-effort, skip on error):
    gh api repos/{owner}/{repo} --jq '.stargazers_count,.description'
  → Attach {stars} and {description} to each repo object
  AskUserQuestion (multiSelect) — "Found {N} repos in '{domain}'. Select which to research:"
  Options: each repo as "[owner/repo] ({stars}⭐) — {description}"
  Note: stars must be fetched here — needed for Step 6 of notebook command's "Keep top 3" reduction.

Step 7: Store selection in conversation for *research-github notebook to use
  → "Selected {N} repos. Ready to create a research notebook with: *research-github notebook '{domain}'"
```

---

### `*research-github notebook <domain>`

Create a NotebookLM notebook from selected repos (the full research pipeline).

```
PREREQUISITE: Run *research-github explore <domain> first to select repos.
If no repos selected yet, run explore internally (Step 2).

Step 1: Confirm domain and selected repos from explore step
  AskUserQuestion: "Creating notebook for '{domain}' with these repos: {list}. Proceed?"
  Options: "Yes, proceed" | "Change selection (re-run explore)" | "Cancel"

Step 2: If no prior explore selection, run explore algorithm (see explore command above)
  → Present selection → user picks repos

Step 3: For each selected repo, query default branch:
  → gh api repos/{owner}/{repo} --jq '.default_branch'
  → Store as {branch} per repo (NOT hardcoded 'main' — repos may use 'master' or other)

Step 4: For each selected repo, list ALL files (recursive):
  → gh api repos/{owner}/{repo}/git/trees/{branch}?recursive=1 --jq '{truncated: .truncated, paths: [.tree[] | select(.type == "blob") | .path]}'
  → Returns flat list of ALL file paths in repo (recursive, blob-type only)
  Note: Do NOT use gh api .../contents/ — it returns only ROOT-level entries (not subdirs).
        The recursive tree API is the correct primitive for path enumeration.
  Truncation check: if .truncated == true:
    → Log: "⚠️ {repo} tree was truncated (>100K files or >7MB). Using root-level files only."
    → Fallback: gh api repos/{owner}/{repo}/contents/ --jq '[.[] | select(.type == "file") | .path]'
    → Tier selection will be limited to root-level files only for this repo.

Step 5: Smart file selection per repo (tier-based, max 10/repo):
  tier_1_always:    ["README.md", "docs/README.md"]
  tier_2_docs:      paths matching docs/*.md, *.md at root (exclude CHANGELOG.md, CONTRIBUTING.md, LICENSE.md) — up to 5 files
  tier_3_source:    paths matching src/index.*, src/main.*, lib/index.*, app/main.* — up to 3 files
  tier_4_config:    paths matching package.json, pyproject.toml, Cargo.toml, go.mod — up to 2 files
  Selection logic:
    1. Always include tier_1 paths that exist in the recursive file list
    2. Fill remaining slots from tier_2 (alphabetical, prefer shorter paths)
    3. If <8 selected, add tier_3 files
    4. If <9 selected, add tier_4 files
    5. Cap at 10 per repo

Step 6: Source limit check (NotebookLM per-notebook limit = 50):
  total_sources = sum of selected files across all repos
  If total_sources > 50:
    AskUserQuestion: "Total {total_sources} sources exceeds NotebookLM limit (50). How to reduce?"
    Options:
      - "Remove a repo from selection" → let user deselect
      - "Reduce files per repo to 5 max" → apply 5-cap to tier selection
      - "Keep top 3 repos only" → discard lowest-star repos

Step 7: Create NotebookLM notebook:
  → ~/.tad-notebooklm-venv/bin/notebooklm create "{domain} Research"
  → Parse output to capture notebook_id
  → If error: "⚠️ Failed to create notebook: {error}. Check NotebookLM auth."

Step 8: Add sources — for each selected file in each repo:
  Construct URL: https://github.com/{owner}/{repo}/blob/{branch}/{path}
  Determine type flag:
    Code files (.py/.js/.ts/.go/.rs/.java/.rb/.sh/.c/.cpp/.h) → --type text
    Config files (.json/.yaml/.toml) → --type text
    Doc files (.md/.txt) → no flag (auto-detected by NotebookLM)

  Execute: ~/.tad-notebooklm-venv/bin/notebooklm source add "{url}" [--type text] -n {notebook_id}
  Track: success_count, fail_count, failed_urls
  On individual failure: log warning, continue with next source
  Failure threshold: if fail_count > total_sources × 0.5:
    AskUserQuestion "High failure rate ({fail_count}/{total_sources} failed). How to proceed?"
    Options: "Keep notebook with partial sources" | "Retry failed URLs manually later" | "Delete notebook and abort"
    If Delete: ~/.tad-notebooklm-venv/bin/notebooklm delete {notebook_id} -- do NOT update registries

Step 9: Initial synthesis query:
  AskUserQuestion: "Choose synthesis question for notebook '{domain} Research':"
  Options:
    - "这些项目的共同架构模式是什么？最适合单人开发者的方案？" (default)
    - "这些库/框架解决了什么核心问题？有什么设计取舍？"
    - "Custom question" → AskUserQuestion for free text

  → ~/.tad-notebooklm-venv/bin/notebooklm ask "{question}" -n {notebook_id}
  → Present synthesis result to user

Step 10: Update BOTH registries (cross-registry sync):
  Write order: (b) first, then (a) — if (b) fails, abort before touching (a) to avoid stale ref
  If (a) fails after (b) succeeds: display "⚠️ Notebook registered in research-notebooks but github-registry not updated. Manually set notebook_id: {notebook_id} for domain '{domain}' in REGISTRY.yaml"

  b. Update .tad/research-notebooks/REGISTRY.yaml FIRST:
     Add new notebook entry:
       id: "{domain-slug}-github-research"
       topic: "{domain} Research (GitHub Awesome-Lists)"
       created: "{today YYYY-MM-DD}"
       status: active
       last_queried: "{today YYYY-MM-DD}"
       source_count: {success_count}
       notes: "Created by *research-github from awesome-lists. Repos: {repo list}"
       created_by: "research-github"   # extension field — identifies github-registry-created notebooks
       sources:
         - (list of successfully added URLs with type and added date)
     Note: `created_by` is an extension field not in the original template schema.
           It allows *research-github list to distinguish stale refs from archive events.
           The *research-notebook archive command does NOT auto-null github-registry's notebook_id —
           this is a manual action (see Cross-Registry Sync Contract rule #2 below).

  a. Update .tad/github-registry/REGISTRY.yaml SECOND:
     Set domain.notebook_id = {notebook_id}
     Set domain.last_researched = {today YYYY-MM-DD}

Step 11: Confirm summary:
  "✅ Research notebook created for '{domain}':
   - notebook_id: {notebook_id}
   - {success_count} sources added ({fail_count} failed)
   - Initial synthesis: [displayed above]
   - Query more: *research-notebook ask '{question}' --notebook {notebook_id}"
```

---

### `*research-github refresh [--domain <slug>]`

Check awesome-lists for updates (check last commit dates).

```
Step 1: Determine scope:
  → If --domain <slug>: check only that domain's awesome_lists
  → If no flag: check all domains (may be slow; warn user: "Checking {N} awesome-lists — this may take 1-2 minutes")

Step 2: For each awesome-list in scope:
  → gh api "repos/{owner}/{repo}/commits?per_page=1" --jq '.[0].commit.committer.date'
  Note: Use `committer.date` (reliable merge date — matches GitHub "last updated" display).
        Never use `author.date` — can be stale when old PRs are merged recently.
  Note: Use ?per_page=1 query param (NOT --limit flag — --limit is for gh search, not gh api)
  → Parse date as last_commit_date
  → Compare to last_checked in REGISTRY.yaml

Step 3: Detect stale lists:
  → If last_commit_date > last_checked: mark as "UPDATED since last check"
  → If repo returns 404: mark as "ARCHIVED or DELETED"
  → Stars change: note new stars count

Step 4: Display results:
  | Repo | Status | Last Commit | Stars (was → now) |
  For each checked list, show UPDATED / CURRENT / ARCHIVED status

Step 5: AskUserQuestion — "Found {N} updated lists. Update REGISTRY.yaml last_checked dates?"
  Options: "Yes, update all" | "Select which to update" | "No, just showing"

Step 6: Update REGISTRY.yaml for confirmed lists:
  → Set last_checked = today for updated entries
  → If repo ARCHIVED: add note field: "archived: true" to entry (don't delete — preserve history)
```

---

### `*research-github scan [--domain <slug>]`

Manual trigger for weekly scan logic: check freshness + discover new lists. Writes results to scan-log.yaml (single-writer principle — does NOT update REGISTRY.yaml last_checked).

**API call budget**: ~75 calls total (50 REST `commits` + 24 `gh search`). gh search has 30/min limit — builds in 2s delay between search calls.

```
Step 1: Determine scope:
  → If --domain <slug>: check only that domain
  → If no flag: check all domains

Step 1b: Today-guard (avoid duplicate scan):
  → Read scan-log.yaml: if last_scan == today YYYY-MM-DD:
    → If running in non-interactive/scheduled context (the invoking prompt declares
      "non-interactive mode" — e.g., the weekly cron routine):
      Output one line: "Already scanned today ({last_scan}) — non-interactive mode, exiting without changes."
      → EXIT. NEVER call AskUserQuestion in non-interactive context.
    → Else (interactive/manual invocation — unchanged behavior):
      AskUserQuestion: "Already scanned today ({last_scan}). Re-scan?"
      Options: "Yes, re-scan" / "Show last results → *research-github scan-log"
      → "Show last results": redirect to *research-github scan-log + EXIT

Step 2: Freshness check (Behavior A — already-registered lists)
  For each awesome_list in scope:
  → gh api "repos/{owner}/{repo}/commits?per_page=1" --jq '.[0].commit.committer.date'
    Note: Use `committer.date` (reliable merge date), not `author.date`
    Note: Use ?per_page=1 query param (NOT --limit — --limit is for gh search, not gh api)
  → If last_commit_date > awesome_list.last_checked → mark as "updated"
  → If repo returns 404 → mark as "archived"
  → Collect {repo, domain_slug, last_commit, previous_checked} per updated entry

Step 3: Discovery check (Behavior B — new awesome-lists, with rate-limit guard)
  For each domain in scope:
  → gh search repos "awesome {domain.slug}" --sort stars --limit 5 \
      --json fullName,stargazersCount,description
    Note: --json uses camelCase (fullName, stargazersCount) — gh search CLI convention
  → Rate-limit handling: if gh search returns HTTP 403 / rate-limit error:
    → Wait 60s and retry once
    → If still fails: log {domain, error: "rate_limited"} and continue to next domain
  → Sleep 2s between domain searches to stay under 30/min limit
  → For each result NOT already in domain.awesome_lists (match by fullName):
    → If stargazersCount > 500: mark as "new_candidate"
    → Collect {repo, domain, stars, description}  (status assigned in Step 4 merge)
  (Repos with ≤500 stars are silently filtered — avoids noise)

Step 4: Merge-write scan-log.yaml (NEVER full overwrite — preserve user decisions):
  → Read existing scan-log.yaml (if exists)
  → Build merged new_candidates list:
      For each newly-found candidate {repo, domain}:
        If already exists in scan_results.new_candidates with status == "accepted":
          SKIP (already in REGISTRY — drop from scan-log)
        If already exists with status == "rejected":
          PRESERVE rejected status (do NOT reset to pending)
        If new entry: status = pending
  → GC: remove entries with status: accepted (in REGISTRY already)
         remove entries with status: rejected AND first_seen < previous last_scan date
         (first_seen field: written as {today} when a new candidate is first added to scan_results.new_candidates)
  → Ensure new_candidates entries include first_seen field: {today YYYY-MM-DD} for new entries
  → Write merged result to .tad/github-registry/scan-log.yaml:
      version: 1.0.0
      last_scan: {today YYYY-MM-DD}
      scan_results:
        updates: [{repo, domain, last_commit, previous_checked}]
        new_candidates: [{repo, domain, stars, description, status}]

Step 5: Display summary:
  "✅ Scan complete: {N} lists updated, {M} new candidates found ({K} previously rejected preserved)."
  "Results saved to .tad/github-registry/scan-log.yaml"
  "Alex will report next time on session start (STEP 3.9)."

Single-writer for scan-log.yaml data: scan command + routine write scan data here.
Status mutations (accept/reject) are also written to scan-log.yaml but via separate yq commands
in scan-log interactive flow and STEP 3.9 — see mutation_protocol in those commands.
REGISTRY.yaml is NOT modified. To update last_checked: use *research-github refresh.
```

---

### `*research-github scan-log`

Display the most recent scan results from scan-log.yaml.

```
Step 1: Read .tad/github-registry/scan-log.yaml
  → If file not found or last_scan == null: "📡 No scan results yet. Run *research-github scan to start."

Step 2: Display scan summary header:
  "📡 Last scan: {last_scan} ({N_days} ago)"

Step 3: Display updates section:
  If scan_results.updates is empty: "✅ No updates — all lists are current."
  Else:
  "🔄 Updated lists ({N}):"
  | Repo | Domain | Last Commit | Was Checked |
  |------|--------|-------------|-------------|
  For each updated entry.
  → Suggest: "Run *research-github refresh to update REGISTRY.yaml last_checked dates."

Step 4: Display new candidates section:
  If scan_results.new_candidates is empty: "🔍 No new candidates found."
  Else:
  "🆕 New candidates ({M}) — status: pending:"
  | Repo | Domain | Stars | Description |
  |------|--------|-------|-------------|
  For each candidate with status == "pending".
  If any pending candidates:
    AskUserQuestion: "有 {M} 个新发现的 awesome-list。要现在处理吗？"
    Options:
      - "逐一查看并决定 (accept/reject)"
      - "全部接受 (add to REGISTRY)"
      - "全部跳过 (mark rejected)"
      - "稍后处理 (leave as pending)"
    → "逐一查看":
        For each candidate: display + AskUserQuestion "加入 Registry？"
        → "加入":
            1. call *research-github add {candidate.repo}  (writes to REGISTRY.yaml)
            2. If add SUCCEEDS: write status to scan-log.yaml (scan-log status update ONLY after add succeeds):
               yq -i '(.scan_results.new_candidates[] | select(.repo == "{candidate.repo}")).status = "accepted"' \
                 .tad/github-registry/scan-log.yaml
            3. If add FAILS: do NOT update scan-log.yaml; display: "⚠️ Add failed — scan-log unchanged. Retry manually."
        → "跳过":
            yq -i '(.scan_results.new_candidates[] | select(.repo == "{candidate.repo}")).status = "rejected"' \
              .tad/github-registry/scan-log.yaml
    → "全部接受": loop each pending candidate through the "加入" mutation_protocol above (REGISTRY write first, scan-log second)
    → "全部跳过":
            yq -i '.scan_results.new_candidates[] |= (select(.status == "pending") | .status = "rejected")' \
              .tad/github-registry/scan-log.yaml
    → "稍后处理": no action (Alex will prompt again next session)

Step 5: Display archived entries (if any):
  If any entries marked "archived" in updates: warn user, suggest removing from REGISTRY.
```

---

## Setup: Scheduled Routine

Weekly automatic scanning runs as a Claude Code scheduled routine (registered by the
Conductor / main session via CronCreate, or manually via `/schedule`).

The routine prompt DELEGATES to this SKILL's scan protocol — it deliberately contains
NO inline scan logic. A duplicated copy of the scan steps drifts from the protocol
(the previous inline version full-overwrote scan-log.yaml, violating Step 4 merge-write
and destroying user accept/reject decisions). Single source of truth: the scan protocol above.

### Routine prompt (canonical standalone copy: `.tad/evidence/spikes/cron-github-scan-2026-07/cron-prompt.md`):

```
Non-interactive mode. You are a scheduled weekly GitHub registry scan session.

1. Read .claude/skills/research-github/SKILL.md.
2. Execute the `*research-github scan` protocol in full (Step 1 through Step 5,
   including the Step 4 merge-write), in non-interactive mode:
   - Today-guard (Step 1b): if last_scan == today, print the one-line log and exit.
     Never prompt — this session has no human attached.
   - Step 4 MERGE-write semantics are mandatory: NEVER full-overwrite scan-log.yaml;
     preserve existing accepted/rejected candidate statuses and first_seen fields.
3. Write ONLY .tad/github-registry/scan-log.yaml. Do NOT modify REGISTRY.yaml or any
   other file. Single-writer principle: scan-log.yaml is the only output of this routine.
4. If any prerequisite or step fails (gh CLI not authenticated, unrecoverable API errors
   beyond the protocol's built-in wait-60s-retry-once rule): print one error line and
   exit quietly. Do not retry, do not loop.
5. Do nothing else.
```

### Schedule: Weekly (Sunday 23:00)

### Setup steps (Conductor / main session — sub-agents cannot use CronCreate):
1. Register via CronCreate (or `/schedule`): weekly, Sunday 23:00, prompt = the text
   above (take verbatim from cron-prompt.md)
2. Optional first-run verification: a one-shot cron (+5 min) with the same prompt proves
   cron-fires-at-all before waiting a week

### Verification:
- After first run: `*research-github scan-log` shows last_scan date
- Alex will automatically report in STEP 3.9 on next session start

---

## Cross-Registry Sync Contract

Two registries coexist with different concerns:
- `.tad/github-registry/REGISTRY.yaml` — **discovery layer** (domains → awesome-lists)
- `.tad/research-notebooks/REGISTRY.yaml` — **understanding layer** (notebooks → sources)

Sync rules:
1. `*research-github notebook` writes to **both**: github-registry gets `notebook_id` + `last_researched`; research-notebooks gets full entry with `created_by: "research-github"`
2. `*research-notebook archive` of a github-created notebook → caller should null `notebook_id` in github-registry (manual action; display reminder)
3. `*research-github list` checks notebook_id validity: if referenced notebook_id not found in research-notebooks REGISTRY → show "(stale ref)" warning next to the domain
4. Staleness is acceptable — display warning, don't auto-fix (no silent mutations)

---

## Anti-Patterns

- ❌ Don't try to clone repos locally — GitHub sub-page URLs give NotebookLM full code-level access
- ❌ Don't auto-add all files from a repo — use smart tier selection (README + docs + key source files, max 10/repo)
- ❌ Don't hardcode `main` as branch — always query `.default_branch` via `gh api`
- ❌ Don't use bare `notebooklm` command — always use absolute path `~/.tad-notebooklm-venv/bin/notebooklm`
- ❌ Don't exceed 50 total sources per NotebookLM notebook — check before adding

---

## Usage Examples

```bash
# See all registered domains
*research-github list

# Search for new awesome-lists about a topic
*research-github search "vector database"

# Browse what repos are in the MCP Servers domain
*research-github explore "mcp-servers"

# Create a research notebook for MCP Servers (after explore)
*research-github notebook "mcp-servers"

# Add a new awesome-list to the registry
*research-github add "modelcontextprotocol/servers"

# Check if awesome-lists have been updated (for one domain)
*research-github refresh --domain mcp-servers

# Check all domains for updates
*research-github refresh
```

---

## Quick Reference

| Command | Purpose | gh auth needed? | notebooklm needed? |
|---------|---------|-----------------|-------------------|
| `list` | Show all domains | No | No |
| `search <topic>` | Find new lists | Yes | No |
| `add <repo>` | Add to registry | Yes | No |
| `explore <domain>` | Read README, pick repos | Yes | No |
| `notebook <domain>` | Create research notebook | Yes | Yes |
| `refresh` | Check for updates | Yes | No |
| `scan` | Manual weekly scan (freshness + discovery) | Yes | No |
| `scan-log` | Display latest scan results | No | No |

[[LLM: When activated via /research-github, always run preflight checks before any operation. For notebook command, follow the 11-step pipeline exactly — especially Step 3 (query default_branch) and Step 10 (update BOTH registries). Use absolute notebooklm path everywhere.]]
