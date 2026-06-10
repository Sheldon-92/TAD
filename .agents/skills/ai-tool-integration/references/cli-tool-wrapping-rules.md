# CLI Tool Wrapping Rules
<!-- capability: cli_tool_wrapping -->

## Quick Rule Index

| # | Rule | Scope |
|---|------|-------|
| C1 | Inner loop = CLI, outer loop = MCP -- apply the loop test | decision |
| C2 | Token cost: MCP wrapping costs 10-32x more than raw CLI | cost |
| C3 | CLI-first when LLM knows the tool from training data | decision |
| C4 | Evaluation matrix: install, CLI mode, output format, free tier, security | assessment |
| C5 | Registry entry format: description, install, verify, usage, example, output_format | implementation |
| C6 | MCP wrapper format: use SDK when parameter validation or complex logic needed | implementation |
| C7 | Parallel CLI prefetch: fan out N independent calls via subshells + wait | performance |
| C8 | Vision OOM: never re-paste base64 images across turns | anti-pattern |

---

## Rules

### C1: The Loop Test -- CLI vs MCP Decision

Before wrapping any CLI tool, apply this decision framework:

| Factor | Inner Loop (CLI) | Outer Loop (MCP) |
|--------|------------------|-------------------|
| Users | Single developer | Multi-user / shared |
| Iteration | Fast, local | CI/CD, compliance |
| State | Ephemeral | Persistent sessions |
| Auth | Local credentials | OAuth / managed |
| Context | LLM knows the tool | LLM does not know the tool |
| Token cost | ~100% reliability, near-zero overhead | 10-32x token overhead for schema |

**Decision**: If 3+ factors fall in the Inner Loop column, use direct CLI. If 3+ factors fall in the Outer Loop column, wrap as MCP.

**Example**: `git` -- LLM knows it from training, single developer, fast local use, local credentials --> CLI. No MCP wrapper needed.

**Example**: Custom internal inventory API -- LLM does not know it, multi-user, needs OAuth, persistent state --> MCP wrapper justified.

### C2: Token Cost of MCP Wrapping

MCP tool registration adds tokens to every conversation turn:
- Tool name + description: ~100-300 tokens
- Input schema (Zod/JSON Schema): ~200-800 tokens per tool
- Output schema (if defined): ~100-400 tokens per tool
- Total per tool: ~700-1500 tokens

For 20 MCP-wrapped CLI tools: ~14K-30K tokens of static context before the first user message. The same 20 CLI tools invoked directly via Bash: 0 tokens of static context.

**Rule**: Do not wrap a tool as MCP purely for "cleanliness." The token cost must be justified by structured input validation, managed auth, or multi-user state that CLI cannot provide.

### C3: CLI-First for Training-Known Tools

LLMs have seen these tools millions of times in training data. MCP wrapping adds cost with zero capability gain:

| Tool | CLI Command | MCP Wrapping Justified? |
|------|-------------|------------------------|
| git | `git status`, `git diff` | NO -- LLM knows git |
| jq | `echo '{}' \| jq '.field'` | NO -- LLM knows jq |
| curl | `curl -s https://api.example.com` | NO for simple calls; YES for complex auth flows |
| grep/ripgrep | `rg "pattern" --type ts` | NO -- LLM knows search tools |
| npm/npx | `npm install`, `npx tsc` | NO -- LLM knows npm |
| docker | `docker run`, `docker build` | MAYBE -- depends on orchestration complexity |
| kubectl | `kubectl get pods` | MAYBE -- multi-cluster needs auth management |
| Custom internal CLI | varies | YES -- LLM has never seen this tool |

### C4: CLI Evaluation Matrix

Before wrapping a CLI tool (either as registry entry or MCP), evaluate:

| Criterion | Good (wrap it) | Bad (skip it) |
|-----------|---------------|---------------|
| Install | `brew install X` or `npx X` | Requires compilation, Docker, or account registration |
| CLI mode | Command line + arguments | GUI only |
| Output format | File/stdout, parseable (JSON/CSV/text) | Only displays in GUI |
| Free tier | Unlimited or >100/month | <10/month |
| Security | No remote execution, no root needed | Requires root/sudo or remote exec |

**Test sequence**:
```bash
# 1. Install
brew install <tool>  # or: npm install -g <tool>

# 2. Verify
<tool> --version

# 3. Basic usage
echo '<input>' | <tool>  # or: <tool> <input> > output.txt

# 4. Check output is parseable
<tool> <input> | head -20
```

### C5: Registry Entry Format

For simple CLI tools, a registry entry is sufficient (no MCP server needed):

```yaml
tool_name:
  description: "One-line description of what this tool does"
  recommended:
    name: tool-binary-name
    type: cli
    install: "brew install tool-name"
    verify: "tool-name --version"
    usage: |
      1. Run tool-name with input file: tool-name input.json
      2. Parse output: tool-name input.json | jq '.results'
      3. Save results: tool-name input.json > output.json
    example: |
      $ echo '{"query": "test"}' > input.json
      $ tool-name input.json
      {"results": [{"id": 1, "name": "Test Result"}]}
    output_format: "JSON object with results array"
    tested: true
    test_result: "2.3KB JSON, 15 results"
```

**Every field is mandatory**. `usage` MUST have numbered steps. `example` MUST have complete input-to-output (copy-paste runnable). `tested: true` means a human or agent actually ran it.

### C6: MCP Wrapper -- When to Escalate

Wrap as MCP server when the CLI tool needs:

1. **Parameter validation**: Complex input that benefits from Zod schema
2. **Output parsing**: Raw CLI output needs transformation to structured JSON
3. **Auth management**: Tool needs tokens/keys injected per-session
4. **State tracking**: Tool needs to remember results across calls
5. **Error enrichment**: Raw exit codes need mapping to actionable messages

MCP wrapper implementation follows the rules in `mcp-server-dev-rules.md`.

### C7: Parallel CLI Prefetch

When a workflow triggers N >= 2 independent read-only CLI calls, fan them out in parallel:

```bash
# BSD bash 3.2 portable (macOS default)
(gh api repos/owner/repo > /tmp/repo.json) &
(npm view package-name version > /tmp/version.txt) &
(curl -s https://api.example.com/status > /tmp/status.json) &
wait

# Read results
repo_data=$(cat /tmp/repo.json)
version=$(cat /tmp/version.txt)
status=$(cat /tmp/status.json)
```

Cuts N x latency to 1 x latency (slowest call). macOS BSD bash 3.2 lacks `wait -n`, so use the explicit `wait` form. Avoid GNU `parallel` (extra dependency).

### C8: Vision OOM -- Base64 in Conversation History

When wrapping tools that produce images (screenshots, charts, diagrams):

**NEVER** re-paste base64-encoded images across conversation turns. Each turn carries the full image bytes (Claude does not deduplicate). Long-running visual sessions exhaust the API request size limit before the model runs.

**FIX**: Store images once via the Files API (or upload to a CDN and pass URLs), then reference by ID/URL in subsequent turns.

---

## Anti-Patterns

- **"Usage: use X to do Y"**: The agent does not know HOW to use it. Provide exact commands with arguments.
- **No verify command**: Cannot confirm installation succeeded. Always include `<tool> --version` or equivalent.
- **Wrapping GUI-only tools**: The agent cannot interact with graphical interfaces. CLI mode is mandatory.
- **No example**: The agent encounters this tool for the first time. Without a complete input-to-output example, it guesses the format.
- **Wrapping everything as MCP**: 10-32x token overhead for tools the LLM already knows. Apply the loop test first.
