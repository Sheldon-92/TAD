# Blake Tool Quick Reference
> Loaded at activation. Contains invocation methods only. Full workflows in referenced SKILLs.

## External CLI Tools

### Codex CLI (for independent review)
- **Path:** `codex` (Homebrew global)
- **Preflight:** `command -v codex >/dev/null 2>&1`
- **Key commands:**
  - Code review from diff: `{ echo "Review:"; git diff HEAD~1..HEAD; } | codex exec --full-auto "P0/P1/P2 findings"`
  - SKILL-aware review: `cat .claude/skills/blake/SKILL.md | codex exec --full-auto "Review handoff implementation"`
  - Non-git dir: add `--skip-git-repo-check`
- **Constraints:** Sandbox workspace-write; stderr noise benign; exit code = truth
- **NOT a substitute for** Layer 2 code-reviewer sub-agent (independent second opinion only)
- **Full guide:** `.tad/guides/cross-model-invocation.md`

### Gemini CLI (for read-only research)
- **Path:** `gemini -p "<question>"`
- **Constraints:** READ-ONLY. Use only when handoff explicitly calls for Gemini research.
- **Full guide:** `.tad/guides/cross-model-invocation.md`

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

## TAD Hook Scripts (Blake invokes directly)

| Script | Purpose | Invocation |
|--------|---------|------------|
| `gate3-git-tracked-check.sh` | Verify git-tracked dirs in handoff | `bash .tad/hooks/lib/gate3-git-tracked-check.sh` |
| `layer2-audit.sh` | Self-check: do my review artifacts exist? | `bash .tad/hooks/lib/layer2-audit.sh <slug>` |
| `trace-step.sh` | Record Domain Pack step execution trace | `bash .tad/hooks/trace-step.sh <event_type> <capability> <step> <pack>` |

## TAD Templates (Blake uses during completion)

| Template | When | Path |
|----------|------|------|
| Completion report | After Gate 3 pass | `.tad/templates/completion-report.md` |
| Session state | Init + completion | `.tad/templates/session-state-template.md` |
| Handoff B→A | Message to Alex | `.tad/templates/handoff-b-to-a.md` |

## NotebookLM (Blake-limited)
- Blake MAY use `*research-notebook ingest <file>` to feed implementation findings back
- **Path:** `~/.tad-notebooklm-venv/bin/notebooklm source add <file> -n <id>`
- Blake does NOT create notebooks or run research — that's Alex domain
