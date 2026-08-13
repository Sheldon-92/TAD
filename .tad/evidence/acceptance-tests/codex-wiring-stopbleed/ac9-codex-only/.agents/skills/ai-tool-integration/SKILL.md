---
name: ai-tool-integration
description: AI tool integration capability pack. Gives AI agents the judgment rules for MCP server development, CLI tool wrapping, API integration, tool schema design, permission models, testing, and documentation. Research-grounded rules from MCP TypeScript SDK, Anthropic cookbook, Claude Code source, and production MCP server patterns. Use for any MCP server build, CLI-to-MCP wrapping decision, API integration, tool schema review, or tool permission design task.
keywords: ["工具", "tool", "MCP", "server", "API", "集成", "integration", "schema", "权限", "permission", "CLI", "wrapping", "tool-use", "工具集成", "MCP服务器", "工具测试", "tool testing", "tool documentation"]
type: reference-based
---

**CONSUMES**: User tool integration task + target API/CLI/service description + optional existing MCP server code or tool configs
**PRODUCES**: Applied tool integration judgment rules + MCP server code + CLI wrapping decisions + API integration configs + schema reviews + permission models + test plans + tool documentation

# AI Tool Integration Capability Pack

**Version**: 0.1.0
**Compatibility**: Claude Code (Phase 1); Codex / Cursor / Gemini in Phase 3
**License**: Apache 2.0

---

## What This Pack Does

AI agents build MCP servers by copying tutorial scaffolds. They wrap every CLI tool as an MCP server even when code execution would cut a 150,000-token Drive-to-Salesforce workflow to 2,000 tokens (98.7% reduction, Anthropic engineering 2026-06-13). They skip schema constraints, letting models hallucinate parameter values. They put read and write operations on the same server with the same IAM role. They never test with MCP Inspector. They write tool descriptions that say "use this tool" without examples, error guidance, or "when NOT to use." They teach the deprecated 4-arg `server.tool()` API instead of the current `server.registerTool()` (SDK v1.29.0). They ignore tool poisoning (CVE-2025-54136 / CVE-2025-54135), the OWASP LLM01 #1 risk.

This pack embeds the judgment rules that tool integration engineers apply automatically -- rules from the MCP TypeScript SDK (v1.29.0), the MCP 2025-06-18 spec, Anthropic's measured tool-use research, OAuth 2.1 (RFC 9728 / RFC 8707), and real MCP server architectures.

**Pack = tool integration judgment. Your workflow system = process constraints. No overlap.**

---

## Cross-Cutting Rules

### Rule 1: Inner Loop = CLI, Outer Loop = MCP

> **When deciding whether to wrap a CLI tool as an MCP server, apply the loop test.** Inner loop (local dev, fast iteration, single-user) = direct CLI/Bash. Outer loop (shared infra, CI/CD, multi-user, compliance) = MCP wrapping. Anthropic measured a Drive-to-Salesforce workflow drop from 150,000 tokens to 2,000 tokens (98.7% reduction) when tools are called as code instead of loaded as MCP definitions; an independent agent-search benchmark measured 17x more tokens per call (MCP vs CLI), with CLI winning 60-90% on cost. If the LLM already knows the tool from training data, CLI-first is correct.

This rule applies to: every CLI wrapping decision, tool registry design, and agent architecture. It is surfaced here because agents default to "wrap everything as MCP" without considering token cost. Source: anthropic.com/engineering/code-execution-with-mcp + earezki.com agent-search benchmark (both retrieved 2026-06-13).

### Rule 2: Read/Write Server Separation

> **Read-only and write/destructive operations MUST run on separate MCP servers with separate IAM roles.** A single server with mixed permissions means a read operation compromise escalates to write access. Separate servers = separate blast radius.

This rule applies to: MCP server architecture, permission model design, and deployment configuration. It is surfaced here because the default tutorial pattern puts all tools in one server.

### Rule 3: Tool Search Tool / Programmatic Tool Calling Before Manual Merging

> **Before hand-merging tools to save context (M6), reach for the Tool Search Tool + Programmatic Tool Calling — the modern alternative.** Enable the Tool Search Tool when tool definitions consume >10K tokens OR 10+ tools are available; it is less beneficial with <10 tools. Anthropic measured: 85% token reduction while keeping the full tool library loadable on demand; MCP eval accuracy Opus 4.5 79.5%->88.1% (Opus 4 49%->74%); Programmatic Tool Calling cut average usage 43,588->27,297 tokens (37% reduction); adding tool-use examples raised accuracy 72%->90%.

This rule applies to: any server with 10+ tools or >10K tokens of definitions. It is surfaced here because agents reach for ad-hoc tool-merging (lossy, M6) before the spec-blessed search/programmatic mechanisms. Source: anthropic.com/engineering/advanced-tool-use (retrieved 2026-06-13). Full detail in `references/mcp-server-dev-rules.md` M11.

---

## Step 0: Context Detection

When the user mentions tool integration work, detect the context and load the right reference:

| User Signal | Reference to Load |
|-------------|-------------------|
| "MCP server", "build server", "McpServer", "STDIO server", "MCP开发" | `references/mcp-server-dev-rules.md` |
| "CLI wrap", "CLI tool", "bash tool", "inner loop", "outer loop", "CLI封装" | `references/cli-tool-wrapping-rules.md` |
| "API integration", "REST API", "OpenAPI", "rate limit", "retry", "API集成" | `references/api-integration-rules.md` |
| "schema", "input schema", "Zod", "JSON Schema", "enum", "tool naming", "schema设计" | `references/tool-schema-rules.md` |
| "permission", "OAuth", "read-only", "destructive", "HITL", "权限" | `references/tool-permission-rules.md` |
| "test tool", "MCP Inspector", "tool testing", "drift", "工具测试" | `references/tool-testing-rules.md` |
| "tool description", "tool docs", "searchHint", "when to use", "工具文档" | `references/tool-documentation-rules.md` |
| "tool poisoning", "rug pull", "MCPoison", "elicitation", "spec 2025-06-18", "MCP-Protocol-Version", "CVE-2025-5413", "供应链", "工具投毒" | `references/mcp-spec-and-security-rules.md` |
| "full tool integration", "complete MCP setup", "build everything" | Load **all references** sequentially |

---

## Step 1: Apply Rules

After loading the relevant reference file(s):

1. **Read the reference completely** -- do not skim
2. **Apply each rule as a judgment check** against the user's tool setup, code, or request
3. **For each violated rule**: state the violation clearly, then give the specific fix
4. **Enforce all three cross-cutting rules** (Inner/Outer Loop + Read/Write Separation + Tool Search before manual merging) on every tool integration task
5. **Check tool annotations** -- they tell the agent how to handle the tool:
   - `readOnlyHint: true`: safe to auto-approve, cancel on interrupt
   - `destructiveHint: true`: requires human confirmation, block on interrupt
   - `idempotentHint: true`: safe to retry on failure

Output format per finding:
```
[P0] Rule M3 (mcp-server): console.log() in STDIO server -- stdout is the JSON-RPC channel.
--> Replace with console.error() or server.sendLoggingMessage().

[P1] Rule S2 (schema): parameter "status" is free-text string -- should be enum.
--> Add enum constraint: ["active", "inactive", "pending"] to prevent hallucinated values.
```

---

## Step 2: Output

Produce a structured tool integration report:

```
## Tool Integration Review: [area reviewed]

### P0 -- Blocking (must fix before deployment)
- [finding + specific fix]

### P1 -- Required (fix before production use)
- [finding + specific fix]

### P2 -- Advisory (improves tool quality)
- [finding + specific fix]

### Tool Annotation Audit
[table of tools with readOnlyHint/destructiveHint/idempotentHint classifications]

### Architecture Decision
[CLI vs MCP decision with token cost justification]
```

---

## Anti-Skip Table

| Excuse | Counter |
|--------|---------|
| "We only have one server, splitting is overkill" | A single compromised read tool now has write access. Separate servers cost 5 minutes to set up. Separate blast radius is not optional. |
| "CLI wrapping as MCP is cleaner" | Anthropic measured 150,000->2,000 tokens (98.7% drop) for code-execution vs MCP definitions; agent-search benchmark measured 17x more tokens per MCP call. If the LLM already knows `git`, `jq`, `curl` from training, MCP wrapping wastes tokens and adds latency. |
| "We'll add schema constraints later" | Without enum constraints, the LLM hallucinates parameter values NOW. Every call without constraints is a potential failure. |
| "OAuth is too complex for a prototype" | Session-scoped auth with PKCE takes 30 minutes. Per MCP 2025-06-18 spec, servers are OAuth 2.0 Resource Servers that MUST publish PRM (RFC 9728); clients MUST send the `resource` parameter (RFC 8707). Without it, API keys in env vars leak on the first misconfigured deployment. |
| "MCP Inspector is just for debugging" | Inspector CLI mode is your CI/CD integration test. `scripts/verify-mcp-server.sh` runs the `tools/list` smoke test plus the M3/M6/S8 checks and exits non-zero on violation. Without it, you discover transport bugs in production. |
| "The tool name is obvious enough" | "check_status" matches 5 different tools. "get_inventory_level" matches exactly one. Ambiguous names cause wrong-tool selection. |
| "We trust the tool, no need to pin its definition" | Tool poisoning (CVE-2025-54136 MCPoison) hides instructions in the description field; a rug-pull tool is safe Day-1 and exfiltrates keys Day-7. Pin/hash tool definitions and re-verify on change. OWASP ranks prompt injection #1 in the 2025 LLM Top 10. |
| "The tutorial uses `server.tool(name, desc, schema, handler)`" | That 4-arg form is deprecated. SDK v1.29.0 uses `server.registerTool(name, {title, description, inputSchema, outputSchema, annotations}, handler)` and returns `content[]` + `structuredContent`. Copying the old signature ships an API that no longer matches the docs. |

---

## Tool Quick Reference

> Version pins reflect the API taught in this pack (retrieved 2026-06-13). Re-check before copying examples — MCP moves fast.

| Tool | Install (pinned) | Primary Use |
|------|------------------|-------------|
| MCP TypeScript SDK | `npm install @modelcontextprotocol/sdk@1.29.0 zod@3.x` | Build MCP servers (use `registerTool`, not the deprecated 4-arg `tool`) |
| MCP spec | protocol version `2025-06-18` (send `MCP-Protocol-Version` header) | Server/tools, elicitation, OAuth Resource Server contract |
| MCP Inspector | `npx @modelcontextprotocol/inspector` | Test MCP servers (UI + CLI mode `--cli ... --method tools/list`) |
| Claude Code MCP CLI | `claude mcp add --transport stdio <name> -- <cmd>` | Register MCP server locally |
| openapi-to-mcp | `npx openapi-to-mcp` | Convert OpenAPI specs to MCP servers |
| Zod | `npm install zod@3.x` | Runtime schema validation (`.strict()` per S8) |
| `scripts/verify-mcp-server.sh` | `bash scripts/verify-mcp-server.sh <server-dir> [-- <run cmd>]` | Deterministic validator: M3 console.log grep, M6 tool count, S8 strict-schema, Inspector `tools/list` smoke. Exits non-zero on violation. |
