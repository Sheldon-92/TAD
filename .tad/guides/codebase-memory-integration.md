# Codebase-Memory-MCP Integration Guide

TAD uses codebase-memory-mcp as a persistent code knowledge graph for structural
code queries. It is entirely optional — TAD silently falls back to LSP or grep
when the tool is unavailable.

## Three-Tier Code Intelligence Architecture

```
Alex step1c_lsp:
  ┌─────────────────┐
  │ Tier 1: Graph   │──available──→ detect_changes + query_graph → blast radius
  │ (codebase-mem)  │                → done, skip LSP query
  └────────┬────────┘
           unavailable
  ┌────────▼────────┐
  │ Tier 2: LSP     │──available──→ documentSymbol + incomingCalls → blast radius
  │ (language plugin)│               → done
  └────────┬────────┘
           unavailable
  ┌────────▼────────┐
  │ Tier 3: Grep    │────────────→ text search fallback
  └─────────────────┘
```

Each tier activates only when the previous tier is unavailable. Detection is
via CLI probe, not MCP protocol negotiation.

## Silent Degradation (NFR1)

Graph tier unavailability produces zero user-visible output. No warnings, no
prompts, no slowdown — just falls through to the next tier. This applies to:
- Binary not installed
- Project not indexed
- Index older than 7 days (staleness guard)
- CLI probe error or timeout

## Graph Probe Detection

```bash
command -v codebase-memory-mcp >/dev/null 2>&1 && \
  codebase-memory-mcp cli list_projects '{}' 2>/dev/null | grep -q '"projects"'
```

If the probe succeeds, Alex checks for a project matching the current working
directory and verifies the index is fresh (≤7 days old).

## Project Name Format

codebase-memory-mcp derives project names from the absolute filesystem path
with slashes replaced by dashes:

```
/Users/sheldonzhao/01-on progress programs/menu-snap
→ Users-sheldonzhao-01-on progress programs-menu-snap
```

Always discover the correct project name via `list_projects` before querying.

## Query Patterns

### Input Sanitization (Cypher/JSON injection prevention)

Two-layer defense against injection:
1. **Shell/JSON injection**: `jq --arg` safely passes values into jq as strings
2. **Cypher injection**: regex validation restricts input to safe character sets

Both layers are required. `jq --arg` alone does not prevent Cypher injection
because `\($s)` inside the jq filter performs string interpolation at the Cypher
level. The regex ensures the interpolated value cannot break out of the Cypher
property match syntax.

```bash
# Validate project name: allow alphanumeric, space, dash, underscore, dot
validate_project_name() {
  local val="$1"
  if [[ ! "$val" =~ ^[A-Za-z0-9\ _.\-]+$ ]]; then
    echo "INVALID" && return 1
  fi
  echo "$val"
}

# Validate symbol name: stricter — no spaces (function/class names never have spaces)
validate_symbol_name() {
  local val="$1"
  if [[ ! "$val" =~ ^[A-Za-z0-9_.\-]+$ ]]; then
    echo "INVALID" && return 1
  fi
  echo "$val"
}
```

### Blast Radius (replaces LSP documentSymbol + incomingCalls)

```bash
# 1. Get project name (match current directory, not first in list)
PROJECT=$(codebase-memory-mcp cli list_projects '{}' 2>/dev/null | \
  jq -r --arg cwd "$(pwd)" '.projects[] | select(.path == $cwd) | .name // empty' 2>/dev/null | head -1)
[ -z "$PROJECT" ] && graph_available=false

# 2. Detect changes from git diff → impacted symbols
codebase-memory-mcp cli detect_changes "$(jq -nc --arg p "$PROJECT" '{project: $p}')"

# 3. Find all callers of a specific symbol via Cypher
SYMBOL="useAuth"
codebase-memory-mcp cli query_graph "$(jq -nc --arg p "$PROJECT" --arg s "$SYMBOL" \
  '{query: "MATCH (caller)-[:CALLS]->(fn {name: \"\($s)\"}) RETURN caller.name AS caller, caller.file_path AS file, caller.start_line AS line", project: $p}')"
```

### Symbol Search (replaces grep for function/class lookup)

```bash
codebase-memory-mcp cli search_graph "$(jq -nc --arg q "AuthProvider" --arg p "$PROJECT" \
  '{query: $q, project: $p}')"
```

### Architecture Overview

```bash
codebase-memory-mcp cli get_architecture "$(jq -nc --arg p "$PROJECT" \
  '{project: $p, aspects: ["all"]}')"
```

## Known Limitations

| Language | Call-Chain Detection | Symbol Search | detect_changes |
|----------|---------------------|---------------|----------------|
| TypeScript | Full (type-aware) | Full | Full |
| Python | Full | Full | Full |
| Go | Full | Full | Full |
| Shell (bash/zsh) | Limited (CALLS edges sparse) | Partial | Full |
| YAML/Markdown | N/A | N/A | File-level only |

For shell-heavy projects like TAD itself, graph provides `search_graph` and
`detect_changes` value but not full call-chain analysis. TypeScript/Python/Go
projects get the most benefit.

## Index Management

TAD does NOT manage indexing. codebase-memory-mcp self-manages its index via:
- `--watch` mode for live incremental updates
- Git-hook-based incremental indexing (XXH3 content hashing)
- Manual: `codebase-memory-mcp cli index_repository '{"repo_path":"<abs_path>"}'`

### Staleness Policy

If the index is older than 7 days, TAD treats the graph as unavailable and
falls back to LSP. Stale index producing confident-but-wrong blast-radius
results is worse than no index at all.

## Installation

codebase-memory-mcp is opt-in. TAD never auto-installs it.

```bash
curl -fsSL https://raw.githubusercontent.com/DeusData/codebase-memory-mcp/v0.7.0/install.sh | bash
```

After installation, index the project:

```bash
codebase-memory-mcp cli index_repository "$(jq -nc --arg r "$(pwd)" '{repo_path: $r}')"
```

The tool auto-registers itself as an MCP server during install. Do NOT manually
edit `.claude/settings.json` MCP sections.

## Downstream Project Setup

Projects synced via `*sync` receive the TAD integration code (step0_graph in
alex/SKILL.md) automatically. Each downstream project still needs:
1. The `codebase-memory-mcp` binary installed (one-time, per machine)
2. The project indexed (one-time per project, then incremental)

`tad.sh` prints a hint during install/upgrade if the binary is not detected.

## Blake Layer 2 Reviewer Integration

The `expert_prompt_template` in alex/SKILL.md includes an advisory paragraph
informing reviewers that graph tools may be available. Reviewers decide whether
to use graph tools or read files directly — this is purely advisory.

## Related Tools

- **knowledge-blame.sh** — Query provenance of knowledge rules via git blame.
  Complements this tool: codebase-memory-mcp handles CODE structure (call graphs,
  blast radius), knowledge-blame handles KNOWLEDGE provenance (why a rule exists,
  who added it, when). See tool-quick-reference-alex.md for usage.
