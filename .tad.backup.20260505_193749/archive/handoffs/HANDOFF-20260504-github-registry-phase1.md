---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: [".tad/github-registry", ".claude/skills/research-github"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-05-04
**Project:** TAD Framework
**Task ID:** TASK-20260504-004
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260504-github-knowledge-integration.md (Phase 1/3)

---

## 🔴 Gate 2: Design Completeness

**执行时间**: 2026-05-04 17:15

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Two-layer (registry + notebook), cross-registry sync contract defined |
| Components Specified | ✅ | 6 commands, preflight, file selection tiers, source limit check |
| Functions Verified | ✅ | `gh api`, `notebooklm source add`, `notebooklm ask` all verified in *discuss experiments |
| Data Flow Mapped | ✅ | Full pipeline: gh api raw → parse → select → create notebook → add sources → synthesize |

**Gate 2 结果**: ✅ PASS (after 2-round expert review, 7 P0 resolved)

---

## 1. Executive Summary

Build the GitHub Awesome-List Registry — a YAML-based catalog of community-curated awesome-lists organized by domain. Includes a new `*research-github` SKILL for Alex to discover, browse, and create deep-research notebooks from GitHub repos.

**Core insight from *discuss experiment (2026-05-04):** GitHub sub-page URLs fed directly to NotebookLM give code-level understanding (class names, function signatures, design patterns). No local download needed.

---

## 2. Background & Motivation

User's core problem: "我不想要重复造东西。我只关心我的业务价值，但 TAD 应该知道用什么方法最好地实现它。"

GitHub has the world's richest open-source resources, but finding and leveraging them during projects is manual and ad-hoc. Awesome-lists already provide community curation — we just need to register, index, and connect them to TAD's research pipeline.

---

## 3. Requirements

### Functional Requirements
- FR1: GitHub Registry YAML schema storing domains → awesome-lists → metadata
- FR2: Initial population with 30+ awesome-lists across 20 domains (data from *discuss session)
- FR3: `*research-github` SKILL.md with commands: list, search, add, explore, notebook
- FR4: `explore` command: given a domain, use `gh api` to read the awesome-list README, extract top repos
- FR5: `notebook` command: given selected repos, use `gh api contents/` to list files, construct sub-page URLs, run `notebooklm source add` for each, then run initial synthesis query
- FR6: Registry integrates with existing REGISTRY.yaml pattern (cross-reference notebook_id when notebook created)

### Non-Functional Requirements
- NFR1: All `gh` CLI invocations must check `gh auth status` in preflight
- NFR2: All `notebooklm` CLI invocations use absolute path `~/.tad-notebooklm-venv/bin/notebooklm`
- NFR3: YAML schema must be extensible for Phase 2 (Alex auto-query) and Phase 3 (automation)
- NFR4: SKILL.md is Alex-domain only (research phase, not implementation)

---

## 4. Technical Design

### 4.1 GitHub Registry Schema

File: `.tad/github-registry/REGISTRY.yaml`

```yaml
version: 1.0.0
last_updated: 2026-05-04

domains:
  - name: "AI Agents"
    slug: "ai-agents"
    awesome_lists:
      - repo: "e2b-dev/awesome-ai-agents"
        stars: 27637
        url: "https://github.com/e2b-dev/awesome-ai-agents"
        last_checked: 2026-05-04
      - repo: "Shubhamsaboo/awesome-llm-apps"
        stars: 108704
        url: "https://github.com/Shubhamsaboo/awesome-llm-apps"
        last_checked: 2026-05-04
    notebook_id: null   # filled when *research-github notebook creates one
    last_researched: null

  - name: "MCP Servers"
    slug: "mcp-servers"
    awesome_lists:
      - repo: "punkpeye/awesome-mcp-servers"
        stars: 86214
        url: "https://github.com/punkpeye/awesome-mcp-servers"
        last_checked: 2026-05-04
    notebook_id: null
    last_researched: null

  # ... 20 domains total (see §4.2 for full list)
```

### 4.2 Initial Data — 20 Domains

Full list of awesome-lists to pre-populate (all verified via `gh search repos` on 2026-05-04):

**AI / Agent / LLM:**
- `Shubhamsaboo/awesome-llm-apps` (108K), `e2b-dev/awesome-ai-agents` (27K), `Hannibal046/Awesome-LLM` (27K), `aishwaryanr/awesome-generative-ai-guide` (27K), `punkpeye/awesome-mcp-servers` (86K), `promptslab/Awesome-Prompt-Engineering` (6K)

**Web Development:**
- `enaqx/awesome-react` (73K), `brillout/awesome-react-components` (47K), `sindresorhus/awesome-nodejs` (66K), `vinta/awesome-python` (296K), `dzharii/awesome-typescript` (5K), `TonnyL/Awesome_APIs` (13K)

**Architecture / System Design:**
- `ashishps1/awesome-system-design-resources` (37K), `DovAmir/awesome-design-patterns` (47K), `mehdihadeli/awesome-software-architecture` (11K)

**Database / Data:**
- `pingcap/awesome-database-learning` (11K), `igorbarinov/awesome-data-engineering` (9K), `awesomedata/awesome-public-datasets` (75K)

**Security:**
- `sbilly/awesome-security` (14K), `decalage2/awesome-security-hardening` (6K)

**Mobile:**
- `jondot/awesome-react-native` (36K), `matteocrippa/awesome-swift` (26K)

**DevOps / Self-hosted:**
- `awesome-selfhosted/awesome-selfhosted` (290K), `wmariuss/awesome-devops` (4K)

**Design:**
- `alexpate/awesome-design-systems` (24K), `DovAmir/awesome-design-patterns` (47K)

**Hardware / IoT:**
- `nhivp/Awesome-Embedded` (8K), `phodal/awesome-iot` (5K), `ad-si/awesome-3d-printing` (2K)

**Languages:**
- `avelino/awesome-go` (172K), `rust-unofficial/awesome-rust` (57K)

**Finance:**
- `wilsonfreitas/awesome-quant` (26K), `thuquant/awesome-quant` (5K)

**NLP / CV:**
- `fighting41love/funNLP` (80K), `keon/awesome-nlp` (18K), `jbhuang0604/awesome-computer-vision` (23K)

**AI + Science / Medical:**
- `ai-boost/awesome-ai-for-science` (1.5K), `danielecook/Awesome-Bioinformatics` (4K), `analyticalmonk/awesome-neuroscience` (1.6K)

**Startup / Product:**
- `mezod/awesome-indie` (11K), `dend/awesome-product-management` (2K)

**Developer Tools:**
- `viatsko/awesome-vscode` (29K), `agarrharr/awesome-cli-apps` (19K), `taowen/awesome-lowcode` (15K)

**Testing:**
- `atinfo/awesome-test-automation` (7K)

**Knowledge Graph:**
- `husthuke/awesome-knowledge-graph` (5K)

**Autonomous Driving:**
- `autodriving-heart/Awesome-Autonomous-Driving` (1K)

**Game Dev:**
- `Calinou/awesome-gamedev` (3K)

**Meta:**
- `sindresorhus/awesome` (463K) — the master list of all awesome lists

### 4.3 SKILL Design — `*research-github`

File: `.claude/skills/research-github/SKILL.md`

**Preflight (runs before every sub-command):** (CR-P1-6)
```yaml
preflight:
  checks:
    - "gh CLI authenticated: gh auth status 2>&1 | grep -q 'Logged in'"
    - "notebooklm CLI available: test -x ~/.tad-notebooklm-venv/bin/notebooklm"
    - "notebooklm version ≥0.3.4"
    - "REGISTRY exists: test -f .tad/github-registry/REGISTRY.yaml"
  on_fail_gh: "Output: '⚠️ gh CLI not authenticated. Run: gh auth login'"
  on_fail_notebooklm: "Output: '⚠️ NotebookLM not ready. Run: bash .tad/cross-model/setup-notebooklm.sh'"
```

**Commands:**

| Command | Description |
|---------|-------------|
| `*research-github list` | Show all domains with awesome-list count, notebook status |
| `*research-github search <topic>` | Search GitHub for new awesome-lists (`gh search repos "awesome <topic>"`) |
| `*research-github add <repo>` | Add a new awesome-list to registry under a domain |
| `*research-github explore <domain>` | Browse domain's awesome-list README, extract top repos, present selection |
| `*research-github notebook <domain>` | Create NotebookLM notebook from selected repos (the full pipeline) |
| `*research-github refresh [--domain <slug>]` | Check awesome-lists for updates (scoped or all) |

**`explore` command — README parsing algorithm:** (BA-P0-2)
```
Step 1: Read awesome-list README via raw content API:
  → gh api -H "Accept: application/vnd.github.raw+json" repos/{owner}/{repo}/contents/README.md
  (This returns raw markdown text directly — no JSON envelope, no base64)

Step 2: Extract repo links using markdown link pattern:
  → grep -oE 'https://github\.com/[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+' | sort -u
  → De-duplicate by {owner}/{repo}
  → Filter: exclude links to issues/pulls/wiki (only keep repo root URLs)

Step 3: Fallback — if <5 links extracted:
  → Present raw README section headers to user for manual selection
  → "Could only auto-extract {N} repos. Here are the README sections — pick repos manually."

Step 4: Present extracted repos to user (AskUserQuestion, multiSelect):
  → "Found {N} repos in '{domain}'. Select which to research:"
  → Options show repo name + description (from gh api if available)
```

**`notebook` command pipeline (critical path):** (CR-P0-1/2/3/4 + BA-P0-1 fixed)
```
Step 1: User picks domain → Alex reads domain's awesome-lists from REGISTRY

Step 2: Run explore algorithm (above) → user selects repos

Step 3: For each selected repo, query default branch:
  → gh api repos/{owner}/{repo} --jq '.default_branch'
  (NOT hardcoded 'main' — repos may use 'master' or other branches) (CR-P1-1)

Step 4: For each selected repo, list files:
  → gh api repos/{owner}/{repo}/contents/ --jq '.[].path'
  → Response is JSON array of file metadata

Step 5: Smart file selection per repo: (BA-P1-1)
  tier_1_always:  README.md, docs/README.md
  tier_2_docs:    docs/*.md, *.md (root, excl CHANGELOG/CONTRIBUTING/LICENSE) — up to 5
  tier_3_source:  src/index.*, src/main.*, lib/index.*, app/main.* — up to 3
  tier_4_config:  package.json, pyproject.toml, Cargo.toml, go.mod — up to 2
  max_sources_per_repo: 10

Step 6: Source limit check: (BA-P0-1)
  → Count total files across all repos
  → If total > 50 (NotebookLM per-notebook limit): AskUserQuestion to reduce selection
  → "Total {N} sources exceeds NotebookLM limit (50). Reduce repo count or file selection."

Step 7: Create NotebookLM notebook: (CR-P0-1)
  → ~/.tad-notebooklm-venv/bin/notebooklm create "{domain} Research"
  → Capture notebook_id from output

Step 8: Add sources — for each file:
  → Construct URL: https://github.com/{owner}/{repo}/blob/{default_branch}/{path}
  → Determine type flag: (CR-P0-2)
    .py/.js/.ts/.go/.rs/.java/.rb/.sh/.c/.cpp → --type text
    .md/.txt → no flag (auto-detected)
    .json/.yaml/.toml → --type text
  → ~/.tad-notebooklm-venv/bin/notebooklm source add <url> [--type text] -n <notebook_id>

Step 9: Initial synthesis query:
  → ~/.tad-notebooklm-venv/bin/notebooklm ask "这些项目的共同架构模式是什么？最适合单人开发者的方案？" -n <notebook_id>
  → AskUserQuestion: "这是默认综合问题。要用自定义问题替换吗？" (P2-5)
  → Present synthesis to user

Step 10: Update BOTH registries: (BA-P0-3 cross-registry sync)
  a. github-registry/REGISTRY.yaml: set notebook_id, last_researched
  b. research-notebooks/REGISTRY.yaml: add full notebook entry with:
     id: <slug>, topic: "{domain} Research", status: active,
     source_count: <N>, created_by: "research-github",
     sources: [list of URLs added]
```

### 4.4 Data Flow (corrected)

```
User → *research-github explore "MCP Servers"
  → Read REGISTRY.yaml → domain.awesome_lists
  → gh api -H "Accept: application/vnd.github.raw+json" repos/punkpeye/awesome-mcp-servers/contents/README.md
  → grep extract repo links → de-duplicate
  → Present: "Found 15 repos. Select which to research?" (multiSelect)
  → User picks 3

User → *research-github notebook "MCP Servers"
  → For each picked repo:
      gh api repos/{owner}/{repo} --jq '.default_branch' → branch
      gh api repos/{owner}/{repo}/contents/ --jq '.[].path' → file list
      Smart select (tier 1-4, max 10/repo)
  → Source limit check (total ≤ 50)
  → ~/.tad-notebooklm-venv/bin/notebooklm create "MCP Servers Research" → id
  → For each file:
      ~/.tad-notebooklm-venv/bin/notebooklm source add <sub-page-URL> [--type text] -n <id>
  → ~/.tad-notebooklm-venv/bin/notebooklm ask "综合分析..." -n <id>
  → Update github-registry/REGISTRY.yaml + research-notebooks/REGISTRY.yaml
```

### 4.5 Cross-Registry Sync Contract (BA-P0-3)

Two registries coexist:
- `.tad/github-registry/REGISTRY.yaml` — discovery layer (domains → awesome-lists)
- `.tad/research-notebooks/REGISTRY.yaml` — understanding layer (notebooks → sources)

Sync rules:
1. `*research-github notebook` writes to BOTH: github-registry gets `notebook_id`, research-notebooks gets full entry with `created_by: "research-github"`
2. `*research-notebook archive` of a github-created notebook → nulls `notebook_id` in github-registry
3. `*research-github list` checks notebook_id validity: if referenced notebook not in research-notebooks REGISTRY → show "(stale ref)" warning
4. Staleness is acceptable — display warning, don't auto-fix

---

## 5. Micro-Tasks (Blake 可参考的执行顺序)

1. Create `.tad/github-registry/` directory
2. Design and write REGISTRY.yaml with full schema + all 50+ awesome-lists from §4.2
3. Create `.claude/skills/research-github/SKILL.md` with all 6 commands
4. Implement `list` command (read REGISTRY, format table)
5. Implement `explore` command (gh api + README parsing + repo extraction)
6. Implement `notebook` command (the critical pipeline: gh api → file selection → notebooklm source add → synthesis)
7. Implement `search` and `add` commands (gh search + REGISTRY update)
8. Implement `refresh` command (check last commit dates)
9. Test end-to-end: explore "MCP Servers" → notebook → verify NotebookLM answers code-level questions
10. Register SKILL in appropriate places (skill listing, Alex awareness)

---

## 6. Files to Create / Modify

| # | File | Action | Description |
|---|------|--------|-------------|
| 1 | `.tad/github-registry/REGISTRY.yaml` | CREATE | Registry schema + 50+ awesome-lists |
| 2 | `.claude/skills/research-github/SKILL.md` | CREATE | *research-github command SKILL |
| 3 | `.tad/templates/github-registry-entry.yaml` | CREATE | Template for adding new domain entries |
| 4 | `.tad/active/epics/EPIC-20260504-github-knowledge-integration.md` | MODIFY | Update Phase 1 status: ⬚→🔄 |

**Grounded Against** (Alex step1c):
- `.tad/research-notebooks/REGISTRY.yaml` (head 30, read at 2026-05-04 — reference for schema design)
- `.claude/skills/research-notebook/SKILL.md` (head 60, read at 2026-05-04 — reference for command pattern)
- `.tad/templates/epic-template.md` (full, read at 2026-05-04)
- `.tad/github-registry/` (new — will be created)
- `.claude/skills/research-github/SKILL.md` (new — will be created)

---

## 7. Acceptance Criteria

- [ ] AC1: `.tad/github-registry/REGISTRY.yaml` exists with valid YAML schema containing ≥20 domains
- [ ] AC2: REGISTRY.yaml contains ≥50 awesome-list entries with repo, stars, url, last_checked fields
- [ ] AC3: `.claude/skills/research-github/SKILL.md` exists with 6 commands documented
- [ ] AC4: `*research-github list` displays all domains in formatted table
- [ ] AC5: `*research-github explore <domain>` reads awesome-list via `gh api`, extracts ≥5 repo links
- [ ] AC6: `*research-github notebook <domain>` creates NotebookLM notebook with ≥3 repo sub-URLs as sources
- [ ] AC7: After AC6, `notebooklm ask` returns code-level answer (not just README-level) — verified by asking about a specific class/function name
- [ ] AC8: `*research-github search <topic>` returns ≥3 GitHub results via `gh search repos`
- [ ] AC9: `*research-github add <repo>` successfully adds entry to REGISTRY.yaml
- [ ] AC10: `*research-github refresh` checks last commit date for ≥3 awesome-lists
- [ ] AC11: Epic Phase Map updated: Phase 1 → 🔄 Active

---

## 8. Testing Checklist

- [ ] REGISTRY.yaml valid YAML (yamllint or yq parse)
- [ ] SKILL.md renders correctly (markdown lint)
- [ ] `gh auth status` passes in Blake's terminal
- [ ] `notebooklm` CLI v0.3.4+ available
- [ ] End-to-end: explore → notebook → ask → code-level answer

---

## 9. Spec Compliance Checklist

### 9.1 Spec Compliance

| AC | Verification Method | Expected Evidence |
|----|--------------------|--------------------|
| AC1 | `yq '.domains \| length' .tad/github-registry/REGISTRY.yaml` | ≥20 |
| AC2 | `yq '[.domains[].awesome_lists[]] \| length' .tad/github-registry/REGISTRY.yaml` | ≥50 |
| AC3 | `test -f .claude/skills/research-github/SKILL.md && echo EXISTS` | EXISTS |
| AC4-AC10 | Blake demonstrates in Gate 3 Layer 1 | Functional test output |
| AC11 | `grep -c '🔄 Active' .tad/active/epics/EPIC-20260504-github-knowledge-integration.md` | 1 |

### 9.2 Expert Review Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|--------------------|--------|
| code-reviewer | CR-P0-1: `notebook` missing `notebooklm create` + `-n` flag | §4.3 Step 7-8 | Resolved |
| code-reviewer | CR-P0-2: `--type text` not in pipeline steps | §4.3 Step 8 type flag table | Resolved |
| code-reviewer | CR-P0-3: `gh api` base64 decode not specified | §4.3 explore Step 1 raw header | Resolved |
| code-reviewer | CR-P0-4: bare `notebooklm` violates NFR2 | §4.3 + §4.4 全部改为绝对路径 | Resolved |
| backend-architect | BA-P0-1: NotebookLM source limit not checked | §4.3 Step 6 source limit check | Resolved |
| backend-architect | BA-P0-2: README parsing under-specified | §4.3 explore algorithm 4 steps | Resolved |
| backend-architect | BA-P0-3: cross-registry sync contract missing | §4.5 new section | Resolved |
| backend-architect | BA-P0-4: `gh api` endpoint confusion | §4.3 explore Step 1 + §4.4 | Resolved |
| code-reviewer | CR-P1-1: missing default_branch field | §4.3 Step 3 query default_branch | Resolved |
| code-reviewer | CR-P1-6: missing preflight section | §4.3 preflight block added | Resolved |
| backend-architect | BA-P1-1: file selection heuristics vague | §4.3 Step 5 tier 1-4 spec | Resolved |
| backend-architect | BA-P1-2: DovAmir duplicate in two domains | §4.2 keep under Architecture only | Deferred |
| code-reviewer | CR-P1-2: explore/notebook coupling | §4.3 notebook Step 2 runs explore internally | Resolved |
| backend-architect | BA-P1-5: --type text in pipeline | ��4.3 Step 8 (merged with CR-P0-2) | Resolved |

---

## 10. Important Notes

### 10.1 Critical Design Decisions

1. **Sub-page URLs, not local download** — T4 experiment proved GitHub sub-page URLs work directly with NotebookLM. No `gh api` + base64 decode + local file needed.
2. **SKILL-based, not code** — `*research-github` is a SKILL.md (prompt-level orchestration), not a script. Alex reads the SKILL and executes the CLI commands. No new `.sh` files.
3. **Separate SKILL from *research-notebook** — GitHub registry is discovery layer; NotebookLM notebooks is understanding layer. Different concerns, different commands.
4. **Code files need `--type text`** — when adding `.py`/`.js` files to NotebookLM, must use `notebooklm source add <url> --type text`. SKILL must document this.

### 10.2 Anti-Patterns to Avoid
- ❌ Don't try to clone repos — sub-page URLs give NotebookLM everything it needs
- ❌ Don't auto-add all files from a repo — smart selection (README + docs + key source files)
- ❌ Don't hardcode star counts — they change. Only record at last_checked time for sorting

---

## 11. Decision Summary

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | Registry location | .tad/github-registry/ vs .tad/research-notebooks/ | .tad/github-registry/ | Separate concern from NotebookLM registry |
| 2 | Command namespace | Extend *research-notebook vs new *research-github | New *research-github | research-notebook already has 19 sub-commands; avoid bloat |
| 3 | File delivery to NotebookLM | Local download + source add vs sub-page URL | Sub-page URL | T4 experiment: same depth, zero local I/O |
| 4 | Data source for registry | Manual curation vs awesome-list piggybacking | Awesome-list piggybacking | Community already curates; we register, not reinvent |

---

## 📚 Project Knowledge

### ⚠️ Blake 必须注意的历史教训

- **NotebookLM CLI Capability Matrix (2026-05-04)**: `source add` works for web URLs directly; `source stale`/`source refresh` for updates
- **notebooklm-py 0.3.4 Required (2026-05-04)**: Must use 0.3.4+, earlier versions have broken AI endpoints
- **Venv Absolute Path for AI-Invoked CLI Tools (2026-05-03)**: Always use `~/.tad-notebooklm-venv/bin/notebooklm`, never bare command
- **Registry Lifecycle State Machine (2026-05-03)**: When registry has hybrid states (user-set + derived), document which is which

### Experiment Evidence (from *discuss 2026-05-04)

| Test | Method | Result |
|------|--------|--------|
| T1 | GitHub main URL → NotebookLM | README-level only, no sub-dirs |
| T3 | Local files → NotebookLM | Code-level (FlexibleOrchestrator, process()) |
| T4 | GitHub sub-page URLs → NotebookLM | Code-level ✅ Same depth as T3, no download |
| Code files | .py with --type text | Works ✅ |

---

## Required Evidence Manifest

```yaml
evidence_manifest:
  expert_reviews:
    - .tad/evidence/reviews/blake/github-registry-phase1/code-reviewer.md
    - .tad/evidence/reviews/blake/github-registry-phase1/{second-reviewer}.md
  gate_verdicts:
    - .tad/evidence/completions/github-registry-phase1/GATE3-REPORT.md
  completion:
    - .tad/active/handoffs/COMPLETION-20260504-github-registry-phase1.md
  knowledge_updates:
    - .tad/project-knowledge/architecture.md (if discoveries made)
```
