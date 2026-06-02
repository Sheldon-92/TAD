---
task_type: code
e2e_required: no
research_required: no
git_tracked_dirs: [".claude/skills/alex", ".tad/guides", ".tad/hooks"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-06-02
**Project:** TAD Framework
**Task ID:** TASK-20260602-001
**Handoff Version:** 3.1.0
**Epic:** N/A
**Supersedes:** N/A

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-06-02

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Three-tier fallback: graph → LSP → grep. MCP integration only, no custom code |
| Components Specified | ✅ | 4 files to modify, 1 new file, all paths confirmed |
| Functions Verified | ✅ | codebase-memory-mcp CLI tools verified via experiment (search_graph, detect_changes, trace_path, query_graph) |
| Data Flow Mapped | ✅ | Alex step1c → graph query → §6 blast radius. Blake Layer 2 → graph-assisted review prompt |

**Gate 2 结果**: ✅ PASS

**Alex确认**: 我已验证所有设计要素，Blake可以独立根据本文档完成实现。

---

## 📋 Handoff Checklist (Blake必读)

Blake在开始实现前，请确认：
- [ ] 阅读了所有章节
- [ ] **阅读了「📚 Project Knowledge」章节中的历史经验**
- [ ] 理解了真正意图（不只是字面需求）
- [ ] 确认可以独立使用本文档完成实现

---

## 1. Task Overview

**Title:** Integrate codebase-memory-mcp into TAD Framework

**Summary:** Add codebase-memory-mcp (persistent code knowledge graph via MCP) as the preferred code intelligence layer in TAD's handoff and review workflows. When the tool is available, Alex uses graph queries for blast radius detection (replacing per-handoff LSP calls), and Blake's Layer 2 expert reviewers use graph tools for code navigation (replacing full-file reads). When unavailable, silently fall back to existing LSP → grep chain.

**Why Now:** Experiment on TAD project (3.1s index, 31K nodes) and menu-tales project (7s index, 55K nodes, 62K edges) confirmed:
- TypeScript projects: Cypher query returns complete caller chain (12 callers of `useAuth`) in 0.5s vs LSP 10-30s
- Shell projects: limited call-chain detection, but `detect_changes` and `search_graph` still faster than grep
- Token impact: graph queries return ~200 tokens per structural query vs ~5,000+ tokens for file reads

**Business Value:** After this lands, every downstream project synced via `*sync` gets persistent code intelligence for free. Handoff creation is faster (graph query vs LSP warm-up), reviewer sub-agents consume fewer tokens (graph lookup vs full-file read), and projects without LSP plugins still get structural code understanding.

---

## 2. Requirements

### Functional Requirements

**FR1: Three-Tier Code Intelligence Fallback**
Alex's step1c_lsp must attempt code intelligence in this order:
1. **Graph** (codebase-memory-mcp): `detect_changes` for blast radius, `search_graph` / `query_graph` for symbol lookup
2. **LSP** (existing): `documentSymbol` + `incomingCalls` (current behavior)
3. **Grep** (existing fallback): plain text search

Each tier activates only when the previous tier is unavailable. Detection is via Bash CLI probe, not MCP protocol.

**FR2: Blake Layer 2 Graph Hint**
The `expert_prompt_template` in Alex's SKILL.md adds an optional paragraph informing reviewers that `codebase-memory-mcp` tools may be available via MCP for code navigation. This is advisory — reviewers can still read files directly.

**FR3: tad.sh Install Hint (Documentation Only)**
`tad.sh` prints a one-line hint when codebase-memory-mcp is not detected, directing the user to the install command. TAD does NOT auto-install third-party binaries via `curl | bash` — this violates the project's supply-chain security principles (no version pinning, no lock file, `main` branch content can change between syncs). Installation is fully opt-in via the documented command in the integration guide.

**FR4: Tool Quick Reference Update**
`.tad/guides/tool-quick-reference-alex.md` adds a codebase-memory-mcp section with CLI syntax, key tools, and project naming convention.

**FR5: Integration Guide**
New `.tad/guides/codebase-memory-integration.md` documents the three-tier architecture, graph query patterns, known limitations (shell call-chain detection), and project name format.

### Non-Functional Requirements

**NFR1: Silent Degradation**
Graph tier unavailability must produce zero user-visible output. No warnings, no prompts, no slowdown. Just fall through to LSP tier.

**NFR2: No MCP Config Changes**
codebase-memory-mcp auto-registers itself during `install.sh`. TAD must NOT manually edit `.claude/settings.json` MCP sections.

**NFR3: Index Freshness with Staleness Guard**
TAD does NOT auto-index. The tool has its own `--watch` mode and git-hook-based incremental updates. However, a stale index producing confident-but-wrong blast-radius results is worse than no index at all. The graph probe (step0_graph) must check index age from `list_projects` output — if older than 7 days, treat graph as unavailable and fall through to LSP. This keeps the "TAD doesn't manage indexing" boundary while preventing stale data from producing false confidence.

---

## 3. Technical Design

### Architecture: Graph-First Fallback Chain

```
Alex step1c_lsp_v2:
  ┌─────────────────┐
  │ step0: Graph?    │──yes──→ detect_changes + query_graph → blast radius
  │ (CLI probe)      │          → done, skip LSP
  └────────┬────────┘
           no
  ┌────────▼────────┐
  │ step1-4: LSP?   │──yes──→ documentSymbol + incomingCalls → blast radius
  │ (existing flow)  │          → done
  └────────┬────────┘
           no
  ┌────────▼────────┐
  │ step5: Grep     │──────→ text search fallback
  └─────────────────┘
```

### Graph Probe Detection

```bash
# Detection: does the binary exist and can it list projects?
command -v codebase-memory-mcp >/dev/null 2>&1 && \
  codebase-memory-mcp cli list_projects '{}' 2>/dev/null | grep -q '"projects"'
```

If the probe succeeds, Alex sets `graph_available=true` and uses graph tools for the remainder of step1c_lsp.

### Graph Query Patterns for TAD

**⚠️ Input Sanitization (P0 fix — Cypher/JSON injection prevention):**
Project names come from filesystem paths and may contain spaces or special characters.
Symbol names come from LLM extraction and could contain anything.
ALL values interpolated into JSON or Cypher MUST be validated first:
```bash
# Validate: allow only alphanumeric, space, dash, underscore, dot
validate_graph_input() {
  local val="$1"
  if [[ ! "$val" =~ ^[A-Za-z0-9\ _.\-]+$ ]]; then
    echo "INVALID" && return 1
  fi
  echo "$val"
}
```

**Blast radius (replaces LSP documentSymbol + incomingCalls):**
```bash
# 1. Get project name (use jq, not python3 — 5ms vs 130ms)
PROJECT=$(codebase-memory-mcp cli list_projects '{}' 2>/dev/null | \
  jq -r '.projects[0].name // empty' 2>/dev/null)
[ -z "$PROJECT" ] && graph_available=false

# 2. Detect changes from git diff → impacted symbols (safe: project via jq construction)
codebase-memory-mcp cli detect_changes "$(jq -nc --arg p "$PROJECT" '{project: $p}')"

# 3. For specific symbol: find all callers via Cypher (safe: jq builds JSON with proper escaping)
SYMBOL="useAuth"
codebase-memory-mcp cli query_graph "$(jq -nc --arg p "$PROJECT" --arg s "$SYMBOL" \
  '{query: "MATCH (caller)-[:CALLS]->(fn {name: \"\($s)\"}) RETURN caller.name AS caller, caller.file_path AS file, caller.start_line AS line", project: $p}')"
```

**Symbol search (replaces grep for function/class lookup):**
```bash
codebase-memory-mcp cli search_graph "$(jq -nc --arg q "AuthProvider" --arg p "$PROJECT" '{query: $q, project: $p}')"
```

**Key principle:** Never interpolate `$PROJECT` or `$SYMBOL` directly into JSON/Cypher strings. Always use `jq -nc --arg` to construct JSON with proper escaping. This prevents both shell injection and Cypher injection.

### Blake Layer 2 Integration

Add to `expert_prompt_template` AFTER "EXPLICIT BLAST-RADIUS CHECKS" block and BEFORE "NOT ALLOWED:" block (groups "available tools" before "restrictions"):

```
OPTIONAL TOOLS (if codebase-memory-mcp is available via MCP):
- search_graph: Find symbol definitions by name → returns file:line
- query_graph: Cypher queries for caller/callee chains, imports, usage
- detect_changes: Git diff → impacted symbols + blast radius
These return structured data (~200 tokens) instead of full file reads (~5000 tokens).
Use when you need structural answers. Fall back to file reads for content analysis.
```

This is purely advisory. Reviewers decide whether to use graph tools or read files.

---

## 4. Decision Summary

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | Detection method | MCP protocol check / CLI probe / settings.json check | CLI probe | MCP protocol requires running the server; CLI probe is instant and doesn't require MCP connection |
| 2 | Index management | TAD auto-index / user manual / tool self-manages | Tool self-manages | codebase-memory-mcp has `--watch` mode and git hooks. TAD treating index as "available or not" is the simplest integration |
| 3 | Reviewer integration | Force graph use / advisory hint / no change | Advisory hint | Forcing graph use could break when tool unavailable. Advisory lets reviewers choose. |
| 4 | tad.sh install | Required / optional non-blocking / hint-only / skip | Hint-only (print command, user runs manually) | ARCH P0-1: `curl\|bash` from unpinned `main` branch = supply-chain attack surface across 14 projects. Hint-only preserves user choice + version pinning in displayed URL. |

---

## 5. Architecture & Data Flow

See §3 Technical Design for the three-tier fallback diagram.

Data flow: Alex step0_graph probe → graph_available flag → step1c_lsp graph branch OR LSP branch → §6 blast radius → expert_prompt_template graph hint → Blake Layer 2 reviewers optionally use graph MCP tools.

---

## 6. Files to Modify / Create

| # | File | Action | Description |
|---|------|--------|-------------|
| 1 | `.claude/skills/alex/SKILL.md` | MODIFY | Add `step0_graph` to `lsp_provision_protocol` (with staleness guard + forbidden_implementations) + modify `step1c_lsp` prerequisite + add graph-first branch with jq-safe queries + add OPTIONAL TOOLS to `expert_prompt_template` |
| 2 | `.tad/guides/tool-quick-reference-alex.md` | MODIFY | Add codebase-memory-mcp section |
| 3 | `.tad/guides/codebase-memory-integration.md` | CREATE | Integration guide: three-tier architecture, jq-safe query patterns, silent degradation, limitations, staleness policy |
| 4 | `tad.sh` | MODIFY | Add print-only install hint (NOT curl\|bash execution) in both install and upgrade paths |

**Grounded Against** (Alex step1c read):
- `.claude/skills/alex/SKILL.md` lines 2825-2910 (lsp_provision_protocol + step1c_lsp), lines 3266-3304 (expert_prompt_template)
- `.tad/guides/tool-quick-reference-alex.md` head 50 (existing tool reference format)
- `tad.sh` line 249 (copy_framework_files function location)

---

## 7. Implementation Steps

### Task 1: Modify `lsp_provision_protocol` in alex/SKILL.md (~lines 2825-2860)

Insert a new `step0_graph` before existing `step1_detect`:

```yaml
step0_graph:
  name: "Graph Intelligence Check"
  action: |
    Before LSP detection, check if codebase-memory-mcp is available:
    1. Bash: command -v codebase-memory-mcp >/dev/null 2>&1
    2. If found: Bash: codebase-memory-mcp cli list_projects '{}' 2>/dev/null
       Parse output via jq for project matching current working directory
    3. Staleness check: extract last_indexed timestamp from list_projects output.
       If index is older than 7 days → treat as unavailable (stale index = wrong blast radius)
    4. If project found AND indexed AND fresh (≤7 days):
       → Set graph_available=true, graph_project=<project_name>
       → ⚠️ Do NOT skip step1_detect through step4_install — LSP provisioning
         still runs (other SKILL features may use LSP directly; if graph crashes
         mid-session there is no LSP fallback if provisioning was skipped)
       → Graph mode only replaces the QUERY step inside step1c_lsp, not the
         PROVISIONING steps
    5. If binary not found OR project not indexed OR stale:
       → Set graph_available=false
       → Continue to existing step1_detect (LSP path, unchanged)
  time_budget: "<500ms (CLI probe is ~30ms)"
  skip_if:
    - "§6 is empty or all files are new (create, not modify)"
    - "task_type is doc-only, yaml, or research"
  forbidden_implementations:
    - "MUST NOT auto-index the repository (TAD never triggers indexing)"
    - "MUST NOT modify .claude/settings.json MCP configuration"
    - "MUST NOT block or slow down if graph probe fails (strict <500ms budget)"
```

### Task 2: Modify `step1c_lsp` in alex/SKILL.md (~lines 2865-2910)

**2a. Update `prerequisite` field** (CR P0-1 fix):
Change from:
```yaml
prerequisite: "lsp_provision_protocol completed (step3 or step4 succeeded)"
```
To:
```yaml
prerequisite: "lsp_provision_protocol completed (step0_graph succeeded OR step3/step4 succeeded)"
```

**2b. Add graph-mode branch** at the top of the `action:` block:

```yaml
action: |
  # ── Graph-first path (if graph_available from lsp_provision_protocol.step0_graph) ──
  If graph_available:
    1. Run: codebase-memory-mcp cli detect_changes "$(jq -nc --arg p "$graph_project" '{project: $p}')"
       → Parse changed_files + impacted_symbols + downstream_dependents
    2. For each impacted symbol with label Function/Method/Class:
       Validate symbol_name: [[ "$symbol_name" =~ ^[A-Za-z0-9_.\-]+$ ]] || skip
       Run: codebase-memory-mcp cli query_graph "$(jq -nc --arg p "$graph_project" --arg s "$symbol_name" \
         '{query: "MATCH (caller)-[:CALLS]->(fn {name: \"\($s)\"}) RETURN caller.name AS caller, caller.file_path AS file, caller.start_line AS line", project: $p}')"
       ⚠️ Use jq --arg for JSON construction — never interpolate $variables into Cypher strings directly
    3. Collect all caller file paths into graph_callers set
    4. Compare graph_callers against §6 file list (same logic as LSP path step 5)
    5. Append to Grounded Against:
       "Graph impact: {N} symbols checked via codebase-memory-mcp, {M} callers found, {G} scope gaps added"
    6. DONE — skip the LSP QUERY path below (but LSP provisioning already ran in step1-4)

  # ── LSP path (existing, unchanged — runs when graph_available=false) ──
  For each EXISTING file in §6 that handoff proposes to MODIFY (not create):
  ... (existing step1c_lsp action unchanged)
```

### Task 3: Modify `expert_prompt_template` in alex/SKILL.md (~line 3289)

Insert AFTER "EXPLICIT BLAST-RADIUS CHECKS" block (~line 3289) and BEFORE "NOT ALLOWED:" block (~line 3291):

```
OPTIONAL TOOLS (if codebase-memory-mcp is available via MCP):
- search_graph: Find symbol definitions by name → returns file:line
- query_graph: Cypher queries for caller/callee chains, imports, usage
- detect_changes: Git diff → impacted symbols + blast radius
These return structured data (~200 tokens) instead of full file reads (~5000 tokens).
Use when you need structural answers. Fall back to file reads for content analysis.
```

⚠️ Placement rationale: groups "available tools" together before "restrictions" — reviewer sees capabilities then constraints, not constraints then capabilities.

### Task 4: Modify `.tad/guides/tool-quick-reference-alex.md`

Add a new section after the existing NotebookLM / Codex / Gemini sections:

```markdown
### Codebase-Memory-MCP (Code Knowledge Graph)
- **Path:** `codebase-memory-mcp` (user local bin)
- **Preflight:** `command -v codebase-memory-mcp >/dev/null 2>&1`
- **Install:** `curl -fsSL https://raw.githubusercontent.com/DeusData/codebase-memory-mcp/main/install.sh | bash`
- **Key commands:**
  - Index project: `codebase-memory-mcp cli index_repository '{"repo_path":"<abs_path>"}'`
  - List projects: `codebase-memory-mcp cli list_projects '{}'`
  - Search symbol: `codebase-memory-mcp cli search_graph '{"query":"<name>","project":"<proj>"}'`
  - Blast radius: `codebase-memory-mcp cli detect_changes '{"project":"<proj>"}'`
  - Caller chain: `codebase-memory-mcp cli query_graph '{"query":"MATCH (c)-[:CALLS]->(f {name: '<fn>'}) RETURN c.name, c.file_path","project":"<proj>"}'`
  - Architecture: `codebase-memory-mcp cli get_architecture '{"project":"<proj>","aspects":["all"]}'`
- **Project naming:** Directory path with slashes replaced by dashes (e.g., `Users-sheldonzhao-01-on progress programs-menu-snap`)
- **Graph DB:** `~/.cache/codebase-memory-mcp/` (SQLite, auto-managed)
- **Known limitation:** Shell script call-chain detection is limited (CALLS edges sparse for bash). TypeScript/Python/Go have full type-aware resolution.
```

### Task 5: Create `.tad/guides/codebase-memory-integration.md`

New file documenting:
1. Three-tier architecture diagram (graph → LSP → grep)
2. How graph probe works (CLI command, project name format)
3. Query patterns with examples (detect_changes, query_graph Cypher, search_graph)
4. Known limitations per language (shell limited, TypeScript excellent)
5. Index management (tool self-manages, `--watch` mode, incremental via XXH3)
6. Downstream project setup (auto-installed via tad.sh, or manual `curl | bash`)

### Task 6: Modify `tad.sh` — add install HINT (documentation only, no curl|bash)

**⚠️ Supply-chain security fix (ARCH P0-1):** Do NOT auto-install third-party binary via `curl | bash`.
No version pinning, no lock file, `main` branch HEAD can change between syncs — a single
compromise would auto-execute on 14 downstream projects via `*sync`.

In tad.sh, AFTER `copy_framework_files "$TAD_SRC"` returns (in BOTH install AND upgrade
case arms — CR P1-2: must cover both paths), add:

```bash
# Hint: codebase-memory-mcp for code intelligence (opt-in, user installs manually)
if ! command -v codebase-memory-mcp >/dev/null 2>&1; then
  printf "  💡 Optional: install codebase-memory-mcp for code graph intelligence:\n"
  printf "     curl -fsSL https://raw.githubusercontent.com/DeusData/codebase-memory-mcp/v0.7.0/install.sh | bash\n"
  printf "     (see .tad/guides/codebase-memory-integration.md for details)\n"
fi
```

This only PRINTS the command — the user decides when/whether to run it.
Note the pinned version tag (`v0.7.0`) in the displayed URL.

---

## 8. 📚 Project Knowledge — ⚠️ Blake 必须注意的历史教训

| Entry | Source | Relevance |
|-------|--------|-----------|
| LSP Auto-Provision Protocol | alex/SKILL.md :2825 | The existing three-step provision flow (detect→try→install→fallback) is the pattern to extend, not replace |
| Shell Env-Var Convention | architecture.md | If adding >3 params to any function, use env-var convention |
| Hook Shell Portability Rules | architecture.md | No `grep -P` on macOS; `perl -MTime::HiRes` for timing |
| Never Hand-Write What an Existing Tool Already Does | architecture.md | codebase-memory-mcp install.sh already exists — use it, don't rewrite |
| Deny-List Beats Allow-List for Sync Sets | architecture.md | tad.sh new install step must not break the deny-list sync architecture |

---

## 9. Acceptance Criteria

### 9.1 Spec Compliance Checklist

| # | AC | Verification Method | Expected Evidence |
|---|-----|-------------------|-------------------|
| AC1 | `lsp_provision_protocol` has `step0_graph` before `step1_detect` | `grep -c 'step0_graph' .claude/skills/alex/SKILL.md` | = 1 |
| AC2 | `step1c_lsp` has graph-first branch with `detect_changes` | `grep -c 'detect_changes' .claude/skills/alex/SKILL.md` | ≥ 1 |
| AC3 | `expert_prompt_template` mentions codebase-memory-mcp (placed BEFORE NOT ALLOWED block) | `grep -c 'codebase-memory-mcp' .claude/skills/alex/SKILL.md` | ≥ 1 |
| AC4 | tool-quick-reference-alex.md has codebase-memory-mcp section | `grep -c 'Codebase-Memory-MCP' .tad/guides/tool-quick-reference-alex.md` | ≥ 1 |
| AC5 | Integration guide exists and documents silent degradation | `test -f .tad/guides/codebase-memory-integration.md && grep -cE 'silent|silently|zero.*(output\|visible)' .tad/guides/codebase-memory-integration.md` | ≥ 1 |
| AC6 | tad.sh has install HINT (printf, not curl\|bash execution) | `grep -c 'codebase-memory-mcp' tad.sh` | ≥ 1 |
| AC7 | tad.sh hint is print-only (no pipe to bash) | `grep -A5 'codebase-memory-mcp' tad.sh \| grep -cE 'printf\|echo'` | ≥ 1 (AND `grep -A5 'codebase-memory-mcp' tad.sh \| grep -c '\| bash'` = 0) |
| AC8 | Three-tier fallback: graph_available flag used in both provision and step1c_lsp | `grep -c 'graph_available' .claude/skills/alex/SKILL.md` | ≥ 2 |
| AC9 | step1c_lsp prerequisite includes graph-mode | `grep -E 'prerequisite.*step0_graph' .claude/skills/alex/SKILL.md \| wc -l` | ≥ 1 |
| AC10 | step0_graph has forbidden_implementations block | `grep -A10 'step0_graph' .claude/skills/alex/SKILL.md \| grep -c 'forbidden_implementations'` | ≥ 1 |
| AC11 | Graph queries use jq for JSON construction (no direct $VAR interpolation into Cypher) | `grep -cE 'jq -nc --arg' .claude/skills/alex/SKILL.md` | ≥ 1 |
| AC12 | Staleness guard: step0_graph checks index age | `grep -cE 'stale\|7.*day\|staleness' .claude/skills/alex/SKILL.md` | ≥ 1 |
| AC13 | tad.sh hint appears in BOTH install and upgrade paths | `grep -c 'codebase-memory-mcp' tad.sh` | ≥ 2 |

### 9.2 Expert Review Status

| Reviewer | Focus | P0 | P1 | P2 | Verdict |
|----------|-------|----|----|----|----|
| code-reviewer | Fallback correctness, AC runnability, shell portability | 3 (all fixed) | 4 (all addressed) | 4 | CONDITIONAL PASS → fixed |
| backend-architect | Architecture coupling, *sync risk, supply-chain, staleness | 3 (all fixed) | 4 (all addressed) | 3 | CONDITIONAL PASS → fixed |

### 9.2.1 Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|--------------------|--------|
| ARCH P0-1 | `curl\|bash` supply-chain risk in tad.sh | FR3 rewritten + Task 6 rewritten (hint-only) + AC7 tightened | Resolved |
| ARCH P0-2 + CR P0-2 | Cypher/JSON injection via unvalidated input | §3 Input Sanitization section + Task 2 jq --arg pattern + AC11 | Resolved |
| ARCH P0-3 + CR P2-3 | Section numbering gap (§5-§9 jump) | Added §5 Architecture, renumbered §6→§7→§8 | Resolved |
| CR P0-1 | step1c_lsp prerequisite excludes graph mode | Task 2a prerequisite update + AC9 | Resolved |
| CR P0-3 | AC7 fragile grep pattern | AC7 rewritten with dual check (printf present AND no pipe-to-bash) | Resolved |
| ARCH P1-2 | Stale index = silent wrong results | NFR3 + step0_graph staleness check (7-day) + AC12 | Resolved |
| ARCH P1-3 | Skip LSP provisioning too aggressive | step0_graph rewritten: graph replaces QUERY only, not PROVISIONING | Resolved |
| CR P1-1 | step0_graph lacks forbidden_implementations | Added 3-item block + AC10 | Resolved |
| CR P1-3 | AC9 uses BRE `\|` instead of ERE | AC5/AC9 rewritten with `-cE` flag | Resolved |
| CR P1-4 | OPTIONAL TOOLS after NOT ALLOWED is confusing | Task 3 placement changed to BEFORE NOT ALLOWED | Resolved |
| ARCH P1-1 | Blake SKILL.md graph awareness | Deferred: follow-up handoff (Blake implementation phase is bigger token savings opportunity) | Deferred |
| CR P1-2 | tad.sh insert location underspecified | Task 6 specifies BOTH install AND upgrade case arms + AC13 | Resolved |

---

## 10. Important Notes

### 10.1 Known Limitations
- Shell script (bash/zsh) call-chain detection via codebase-memory-mcp is limited — CALLS edges are sparse. For shell-heavy projects like TAD itself, graph provides `search_graph` and `detect_changes` value but not full call-chain. TypeScript/Python/Go projects get full benefit.
- Project name format is path-based with dashes (e.g., `Users-sheldonzhao-01-on progress programs-menu-snap`). Alex must discover the correct project name via `list_projects` before querying.

### 10.2 What NOT to Do
- Do NOT add codebase-memory-mcp to `.claude/settings.json` MCP section manually — it auto-registers during install
- Do NOT trigger indexing from TAD workflow — the tool manages its own index lifecycle
- Do NOT make graph availability a blocking requirement — always fall through silently

### 10.3 Testing Strategy
After implementation, run comparison test:
1. On menu-tales project, create a test handoff modifying `useAuth` in `AuthContext.tsx`
2. Measure: graph-mode step1c_lsp (time + token estimate from query size)
3. Measure: LSP-mode step1c_lsp (time + token estimate from file reads)
4. Compare results and document in completion report

---

## 11. Required Evidence Manifest

```yaml
expert_reviews:
  - .tad/evidence/reviews/blake/codebase-memory-mcp-integration/code-reviewer.md
  - .tad/evidence/reviews/blake/codebase-memory-mcp-integration/backend-architect.md
gate_verdicts:
  - gate3_verdict in COMPLETION frontmatter
completion:
  - .tad/active/handoffs/COMPLETION-20260602-codebase-memory-mcp-integration.md
knowledge_updates:
  - .tad/project-knowledge/architecture.md (if new pattern discovered)
```
