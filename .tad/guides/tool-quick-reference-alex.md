# Alex Tool Quick Reference
> Loaded at activation. Contains invocation methods only. Full workflows in referenced SKILLs.

## External CLI Tools

### NotebookLM
- **Path:** `~/.tad-notebooklm-venv/bin/notebooklm`
- **Preflight:** `test -x ~/.tad-notebooklm-venv/bin/notebooklm`
- **Setup:** `bash .tad/cross-model/setup-notebooklm.sh`
- **Key commands:**
  - Create notebook: `~/.tad-notebooklm-venv/bin/notebooklm create "<topic>"`
  - Auto-research (fast): `~/.tad-notebooklm-venv/bin/notebooklm source add-research "<topic>" --mode fast --import-all -n <id>`
  - Auto-research (deep): `~/.tad-notebooklm-venv/bin/notebooklm source add-research "<topic>" --mode deep --no-wait -n <id>` then `~/.tad-notebooklm-venv/bin/notebooklm research wait -n <id> --timeout 600 --import-all`
  - Ask (cross-source): `~/.tad-notebooklm-venv/bin/notebooklm ask "<question>" -n <id>`
  - Add source: `~/.tad-notebooklm-venv/bin/notebooklm source add <url> -n <id>`
  - Summary: `~/.tad-notebooklm-venv/bin/notebooklm summary --topics -n <id>`
  - Generate report: `~/.tad-notebooklm-venv/bin/notebooklm generate report "<description>" -n <id>`
  - Ingest local file: `~/.tad-notebooklm-venv/bin/notebooklm source add <local_path> -n <id>`
- **Registry:** `.tad/research-notebooks/REGISTRY.yaml` (update after every create/add/research)
- **Full workflow:** `.claude/skills/research-notebook/SKILL.md`

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
- **Full workflow:** `.claude/skills/research-github/SKILL.md`

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
- **Project naming:** Directory path with slashes replaced by dashes (e.g., `Users-sheldonzhao-01-on progress programs-menu-snap`)
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
- **Scope:** `.tad/project-knowledge/*.md`, `.claude/skills/*/SKILL.md`, and `.tad/hooks/lib/*.sh`
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

### *research-notebook (19 commands — top 7 for daily use)
| Command | What it does | When to use |
|---------|-------------|-------------|
| `*research-notebook create "<topic>"` | Create notebook + add sources | New research topic |
| `*research-notebook research "<topic>" --mode deep` | Auto-discover 50+ sources | Deep dive |
| `*research-notebook curate` (upgraded) | Auto-clean errors + dedup + quality tier | After every deep research |
| `*research-notebook ask "<question>"` | Cross-source Q&A with citations | During *discuss or *design |
| `*research-notebook report "<desc>"` | Generate structured report | Before handoff creation |
| `*research-notebook ingest <file_path>` | Feed local findings back into notebook | After writing research notes |
| `*research-notebook list` | Show all notebooks with status | Portfolio check |

Execution: Read `.claude/skills/research-notebook/SKILL.md` for the sub-command, then run CLI via Bash tool. SEQUENTIAL, not parallel Agent tools.

**`*research-plan` now uses 5-Phase Pipeline** (v2.10.2):
Phase 1 Deep Research → Phase 2 Auto-Curate → Phase 3 Baseline Report → Phase 4 Question Tree (OBJECTIVES.md KRs) → Phase 5 Research→AC Bridge

### *research-github (6 commands — top 3)
| Command | What it does | When to use |
|---------|-------------|-------------|
| `*research-github explore <domain>` | Browse awesome-lists in a domain | Tech discovery |
| `*research-github notebook <domain>` | Create NotebookLM notebook from registry entries | Deep study |
| `*research-github scan` | Weekly scan for new awesome-lists | Automated via /schedule |

Execution: Read `.claude/skills/research-github/SKILL.md` for the sub-command.

## TAD Hook Scripts (Alex invokes directly)

| Script | Purpose | Invocation |
|--------|---------|------------|
| `layer2-audit.sh` | Verify Blake's expert review artifacts | `bash .tad/hooks/lib/layer2-audit.sh <slug>` |
| `stale-knowledge-check.sh` | Advisory: flag possibly-stale knowledge entries | `bash .tad/hooks/lib/stale-knowledge-check.sh --json` |
| `trace-digest.sh` | Advisory: detect skipped Domain Pack steps | `bash .tad/hooks/lib/trace-digest.sh <slug>` |

## Domain Packs (20 packs)
- **Location:** `.tad/domains/{pack-name}.yaml`
- **How to load:** Read the YAML file during *design step1_5 or *discuss domain_pack_awareness
- **Matching:** SessionStart hook provides pack list via additionalContext; LLM matches task keywords
- **Registry:** `.tad/domains/tools-registry.yaml` for cross-pack tool index
