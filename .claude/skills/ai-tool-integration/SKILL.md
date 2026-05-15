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

AI agents build MCP servers by copying tutorial scaffolds. They wrap every CLI tool as an MCP server (10-32x token cost). They skip schema constraints, letting models hallucinate parameter values. They put read and write operations on the same server with the same IAM role. They never test with MCP Inspector. They write tool descriptions that say "use this tool" without examples, error guidance, or "when NOT to use."

This pack embeds the judgment rules that tool integration engineers apply automatically -- rules from the MCP TypeScript SDK, Anthropic's production patterns, OAuth 2.1 spec, and real MCP server architectures.

**Pack = tool integration judgment. Your workflow system = process constraints. No overlap.**

---

## Cross-Cutting Rules

### Rule 1: Inner Loop = CLI, Outer Loop = MCP

> **When deciding whether to wrap a CLI tool as an MCP server, apply the loop test.** Inner loop (local dev, fast iteration, single-user) = direct CLI/Bash. Outer loop (shared infra, CI/CD, multi-user, compliance) = MCP wrapping. MCP wrapping costs 10-32x more tokens than raw CLI. If the LLM already knows the tool from training data, CLI-first is correct.

This rule applies to: every CLI wrapping decision, tool registry design, and agent architecture. It is surfaced here because agents default to "wrap everything as MCP" without considering token cost.

### Rule 2: Read/Write Server Separation

> **Read-only and write/destructive operations MUST run on separate MCP servers with separate IAM roles.** A single server with mixed permissions means a read operation compromise escalates to write access. Separate servers = separate blast radius.

This rule applies to: MCP server architecture, permission model design, and deployment configuration. It is surfaced here because the default tutorial pattern puts all tools in one server.

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
| "full tool integration", "complete MCP setup", "build everything" | Load **all references** sequentially |

---

## Step 1: Apply Rules

After loading the relevant reference file(s):

1. **Read the reference completely** -- do not skim
2. **Apply each rule as a judgment check** against the user's tool setup, code, or request
3. **For each violated rule**: state the violation clearly, then give the specific fix
4. **Enforce both cross-cutting rules** (Inner/Outer Loop + Read/Write Separation) on every tool integration task
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
| "CLI wrapping as MCP is cleaner" | 10-32x token overhead per call. If the LLM already knows `git`, `jq`, `curl` from training, MCP wrapping wastes tokens and adds latency. |
| "We'll add schema constraints later" | Without enum constraints, the LLM hallucinates parameter values NOW. Every call without constraints is a potential failure. |
| "OAuth is too complex for a prototype" | Session-scoped auth with PKCE takes 30 minutes. Without it, API keys in env vars leak on the first misconfigured deployment. |
| "MCP Inspector is just for debugging" | Inspector CLI mode is your CI/CD integration test. Without it, you discover transport bugs in production. |
| "The tool name is obvious enough" | "check_status" matches 5 different tools. "get_inventory_level" matches exactly one. Ambiguous names cause wrong-tool selection. |

---

## Tool Quick Reference

| Tool | Install | Primary Use |
|------|---------|-------------|
| MCP TypeScript SDK | `npm install @modelcontextprotocol/sdk zod` | Build MCP servers |
| MCP Inspector | `npx @modelcontextprotocol/inspector` | Test MCP servers (UI + CLI mode) |
| Claude Code MCP CLI | `claude mcp add --transport stdio <name> -- <cmd>` | Register MCP server locally |
| openapi-to-mcp | `npx openapi-to-mcp` | Convert OpenAPI specs to MCP servers |
| Zod | `npm install zod` | Runtime schema validation |
