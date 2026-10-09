# Alex Tool Quick Reference
> Loaded at activation. Contains invocation methods only. Full workflows in referenced SKILLs.

## External CLI Tools

> Research fallback chain: local_wiki → websearch (SSOT: .tad/config-workflow.yaml fallback_chains.research); NotebookLM layer retired 2.44.6.

### TAD Brain (knowledge search)
- **Index:** `.tad/brain-index.md` (auto-generated)
- **Rebuild:** `bash .tad/hooks/lib/brain-index-gen.sh`
- **Search:** `Agent({ description: "tad-brain search", prompt: "Read .tad/brain-index.md ... For the query '{query}': ..." })`
- **Agent type:** general-purpose (do NOT specify subagent_type)
- **Full protocol:** `alex/SKILL.md → tad_brain_protocol`

### Codex CLI
- **Path:** `codex` (Homebrew global)
- **Preflight:** `command -v codex >/dev/null 2>&1`
- **Key commands:**
  - Execute: `echo "$prompt" | codex exec --full-auto "instructions"`
  - Code review: `{ echo "Review:"; cat diff.txt; } | codex exec --full-auto "P0/P1/P2 findings"`
  - SKILL inject: `cat SKILL.md | codex exec --full-auto "follow the protocol"`
  - Resume session: `codex exec resume --last`
  - Non-git dir: add `--skip-git-repo-check`
- **Constraints:** Sandbox workspace-write; stderr noise is benign; use exit code for success
- **Full guide:** `.tad/guides/cross-model-invocation.md`

### Gemini CLI
- **Path:** `gemini` (`/opt/homebrew/bin/gemini`)
- **Preflight:** `command -v gemini >/dev/null 2>&1`
- **Key commands:**
  - Research: `gemini -p "<question>"`
  - With model: `gemini -m "gemini-2.5-flash" -p "<question>"`
  - Stdin: `cat file.txt | gemini -p "analyze"`
- **Constraints:** READ-ONLY (no writes, no shell commands). Must use `-p` or hangs forever.
  Regex output needs BSD grep-E validation before use in hooks.
- **Full guide:** `.tad/guides/cross-model-invocation.md`

### GitHub CLI (gh)
- **Path:** `gh` (Homebrew global)
- **Key commands:**
  - Repo info: `gh api repos/{owner}/{repo}` (snake_case: `.full_name`, `.stargazers_count`)
  - Search repos: `gh search repos "query" --json fullName,stargazersCount` (camelCase)
  - Full tree: `gh api repos/{owner}/{repo}/git/trees/{branch}?recursive=1`
  - Repo contents: `gh api repos/{owner}/{repo}/contents/` (root only — use git/trees for full)
- **Full workflow:** `.agents/skills/research-github/SKILL.md`

### Codebase-Memory-MCP (Code Knowledge Graph)
- **Path:** `codebase-memory-mcp` (user local bin)
- **Preflight:** `command -v codebase-memory-mcp >/dev/null 2>&1`
- **Install:** `curl -fsSL https://raw.githubusercontent.com/DeusData/codebase-memory-mcp/v0.7.0/install.sh | bash`
- **Key commands:**
  - Index project: `codebase-memory-mcp cli index_repository '{"repo_path":"<abs_path>"}'`
  - List projects: `codebase-memory-mcp cli list_projects '{}'`
  - Search symbol: `codebase-memory-mcp cli search_graph '{"query":"<name>","project":"<proj>"}'`
  - Blast radius: `codebase-memory-mcp cli detect_changes '{"project":"<proj>"}'`
  - Caller chain: `codebase-memory-mcp cli query_graph "$(jq -nc --arg p '<proj>' --arg s '<fn>' '{query: "MATCH (c)-[:CALLS]->(f {name: \"\($s)\"}) RETURN c.name, c.file_path", project: $p}')"`
  - Architecture: `codebase-memory-mcp cli get_architecture '{"project":"<proj>","aspects":["all"]}'`
- **Project naming:** Directory path with slashes replaced by dashes (e.g., `path-to-your-project`)
- **Graph DB:** `~/.cache/codebase-memory-mcp/` (SQLite, auto-managed)
- **Known limitation:** Shell script call-chain detection is limited (CALLS edges sparse for bash). TypeScript/Python/Go have full type-aware resolution.
- **Integration guide:** `.tad/guides/codebase-memory-integration.md`

### Knowledge-Blame (Rule Provenance Query)
- **Path:** `.tad/hooks/lib/knowledge-blame.sh`
- **Used by:** Blake (during implementation), Alex (during knowledge review)
- **Key commands:**
  - Blame a specific line: `bash .tad/hooks/lib/knowledge-blame.sh .tad/project-knowledge/architecture.md --line 42`
  - Search and blame: `bash .tad/hooks/lib/knowledge-blame.sh .tad/project-knowledge/code-quality.md --search "tsc missing type"`
  - File summary: `bash .tad/hooks/lib/knowledge-blame.sh .tad/project-knowledge/architecture.md`
- **Output:** Structured RULE/COMMIT/DATE/AUTHOR/MESSAGE fields
- **Scope:** `.tad/project-knowledge/*.md`, `.agents/skills/*/SKILL.md`, and `.tad/hooks/lib/*.sh`
- **Relationship:** Complements stale-knowledge-check.sh (Alex scans breadth, Blake queries depth)

## Claude Code Native Tools

### LSP (Code Intelligence — Claude Code Native)
- **Availability:** Requires language-specific plugin. See `.tad/guides/lsp-language-map.yaml`
- **Preflight:** Try `LSP documentSymbol` on a target file. "No LSP server available" → needs plugin install.
- **Auto-install:** `claude plugin install {plugin_name}` (takes effect next session)
- **Key operations:**
  - Impact analysis: `LSP incomingCalls` — who calls this function?
  - Dependency chain: `LSP outgoingCalls` — what does this function call?
  - All references: `LSP findReferences` — every usage of this symbol
  - File structure: `LSP documentSymbol` — all symbols in a file
  - Workspace search: `LSP workspaceSymbol` — find symbol across project
  - Type info: `LSP hover` — documentation and type at a position
- **Parameters:** operation, filePath (absolute), line (1-based), character (1-based)
- **Note:** `documentSymbol` and `workspaceSymbol` require line+character by tool schema but don't use them semantically. Pass line=1, character=1.
- **Session constraint:** Newly installed plugins need NEW session to activate.
- **Mapping:** `.tad/guides/lsp-language-map.yaml`

## Adversarial Challenge (Cross-Model Review)

### Challenge Prompt Assembly
- **Template:** `.tad/templates/research-challenge-prompt.md`
- **Extract variant:** `sed -n '/<!-- BEGIN {variant} -->/,/<!-- END {variant} -->/p' .tad/templates/research-challenge-prompt.md`
- **Variants:** `plan` (Phase 0c), `findings` (Phase 4c), `actions` (Phase 5b)

### Challenge Invocation Pattern
```bash
# Symmetric instruction (BOTH models receive identical string)
CHALLENGE_INSTRUCTION="Review the research input below. Follow the output format exactly. Be adversarial — challenge quality, do not agree."

# Assemble: extract variant (strip delimiters) + append data
rm -f /tmp/tad-challenge-findings.md
sed -n '/<!-- BEGIN findings -->/,/<!-- END findings -->/{ /<!-- BEGIN/d; /<!-- END/d; p; }' \
  .tad/templates/research-challenge-prompt.md > /tmp/tad-challenge-findings.md
printf '\n---\n' >> /tmp/tad-challenge-findings.md
cat .tad/evidence/research/{slug}/{date}-ask-findings.md >> /tmp/tad-challenge-findings.md

# Codex (stdin=data, positional=instruction)
codex_result=$(cat /tmp/tad-challenge-findings.md | codex exec --full-auto --skip-git-repo-check \
  "$CHALLENGE_INSTRUCTION" 2>/dev/null)

# Gemini (stdin=data, -p=instruction)
gemini_result=$(cat /tmp/tad-challenge-findings.md | gemini -p \
  "$CHALLENGE_INSTRUCTION" 2>/dev/null)
```

### Rating Extraction (fail-closed)
```bash
rating=$(head -5 challenge-file.md | grep -oE 'INSUFFICIENT|ADEQUATE|STRONG' | head -1)
[ -z "$rating" ] && rating=$(grep -ioE 'INSUFFICIENT|ADEQUATE|STRONG' challenge-file.md | head -1 | tr '[:lower:]' '[:upper:]')
[ -z "$rating" ] && rating="INSUFFICIENT"  # fail-closed default
```

### Challenge Output Paths
- Plan: `.tad/evidence/research/{slug}/challenge-plan-{codex|gemini}.md`
- Findings: `.tad/evidence/research/{slug}/challenge-findings-r{N}-{codex|gemini}.md`
- Actions: `.tad/evidence/research/{slug}/challenge-actions-{codex|gemini}.md`
- Log: `.tad/evidence/research/{slug}/challenge-log.md`

## TAD Research Commands (Alex-domain)

### Local Wiki Research Suite (Primary)
| Command / Script | Purpose | When to use |
|---|---|---|
| `python3 research/scripts/search.py query "<q>"` | Local Wiki 语义与关键词检索 | 调研前知识排查 |
| `bash research/scripts/ingest.sh <url>` | 摄取原始语料到 `research/raw/` | 收集一手材料 |
| `bash research/canon/lint.sh` | 机械检查 6 大 Iron Rule | Canon 词条合规校验 |
| `python3 research/scripts/generate.py` | 纯函数生成 index 与目录 | 词条编译更新 |
| `*research --standard "<topic>"` | 启动标准 Local Wiki 调研 | 常规方案调研 |
| `*research --deep "<topic>"` | 启动深度 Local Wiki 调研（含对抗） | 架构与全景调研 |

### *research-github (top 2)
| Command | What it does | When to use |
|---------|-------------|-------------|
| `*research-github explore <domain>` | Browse awesome-lists in a domain | Tech discovery |
| `*research-github scan` | Weekly scan for new awesome-lists | Automated via /schedule |

Execution: Read `.agents/skills/research-github/SKILL.md` for the sub-command.

## TAD Hook Scripts (Alex invokes directly)

| Script | Purpose | Invocation |
|--------|---------|------------|
| `layer2-audit.sh` | Verify Blake's expert review artifacts | `bash .tad/hooks/lib/layer2-audit.sh <slug>` |
| `stale-knowledge-check.sh` | Advisory: flag possibly-stale knowledge entries | `bash .tad/hooks/lib/stale-knowledge-check.sh --json` |
