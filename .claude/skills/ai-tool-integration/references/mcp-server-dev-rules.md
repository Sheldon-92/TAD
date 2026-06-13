# MCP Server Development Rules
<!-- capability: mcp_server_development -->

## Quick Rule Index

| # | Rule | Scope |
|---|------|-------|
| M1 | Use McpServer class from @modelcontextprotocol/sdk | project setup |
| M2 | Modular structure: src/index.ts (registration) + src/tools/*.ts (logic) | project structure |
| M3 | STDIO servers: console.log() is FORBIDDEN -- stdout is JSON-RPC | transport |
| M4 | Tool registration: server.registerTool(name, config, handler) -- SDK v1.29.0 (4-arg server.tool is deprecated) | API |
| M5 | Resources: URI-based, ResourceTemplate for dynamic, resources/list + resources/read | API |
| M6 | Tool count: merge tools; real evidence = 58 tools ~55K tokens, one agent 134K tokens of defs, Jira MCP ~17K | architecture |
| M7 | Output size: 25K token hard limit with truncation strategy | output |
| M8 | Error responses: isError:true + content array, not generic messages | error handling |
| M9 | Tool annotations: 4 hints + spec defaults; MUST treat as untrusted unless server is trusted | metadata |
| M10 | Shared infrastructure: extract utils/ for API client, pagination, error handler | code quality |
| M11 | Tool Search Tool + Programmatic Tool Calling: enable >10K token defs OR 10+ tools (85% token cut) | scaling |

---

## Rules

### M1: SDK and McpServer Class

When building an MCP server in TypeScript:

```bash
mkdir my-server && cd my-server
npm init -y
npm install @modelcontextprotocol/sdk zod
npm install -D typescript @types/node
```

tsconfig.json must set:
- `target`: `"ES2022"`
- `module`: `"NodeNext"`
- `moduleResolution`: `"NodeNext"`
- `strict`: `true`
- `outDir`: `"./dist"`

Entry point pattern:
```typescript
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";

const server = new McpServer({
  name: "my-server",
  version: "1.0.0",
});

// Register tools here (see M4)

const transport = new StdioServerTransport();
await server.connect(transport);
```

### M2: Project Structure

Modular layout separates registration from logic:

```
my-server/
  src/
    index.ts          # McpServer init + tool registration + transport
    tools/
      search.ts       # export async function handleSearch(args)
      create.ts       # export async function handleCreate(args)
    utils/
      api-client.ts   # shared HTTP client with auth
      pagination.ts   # cursor/offset pagination helper
      errors.ts       # error formatting (isError pattern)
  package.json
  tsconfig.json
```

Each tool file exports a single handler function. index.ts imports and registers them. This pattern scales to 15+ tools without index.ts becoming unreadable.

### M3: STDIO Transport -- console.log() is FORBIDDEN

STDIO MCP servers use stdout as the JSON-RPC channel. Any `console.log()` call corrupts the protocol stream.

**MUST use instead**:
- `console.error()` -- goes to stderr, safe for debugging
- `server.sendLoggingMessage({ level: "info", data: "..." })` -- MCP protocol logging

**Verification**: `grep -rn "console\.log" src/ | grep -v "console\.error\|console\.warn" | grep -v "\.test\."` should return zero lines.

### M4: Tool Registration API -- `registerTool` (SDK v1.29.0)

The 4-arg `server.tool(name, description, schema, handler)` form is **deprecated**. The current MCP TypeScript SDK (v1.29.0, retrieved 2026-06-13) documents `server.registerTool(name, config, handler)`, where `config` is a single object carrying `title`, `description`, `inputSchema`, `outputSchema`, and `annotations`:

```typescript
server.registerTool(
  "get_inventory",
  {
    title: "Get Inventory",
    description: "Get current inventory level for a SKU",   // see doc rules
    inputSchema: {
      sku: z.string().describe("Product SKU, e.g. 'WIDGET-001'"),
      warehouse: z.enum(["us-east", "us-west", "eu"]).describe("Warehouse region"),
    },
    outputSchema: {                                          // see S7 -- if present, server MUST return conforming structuredContent
      sku: z.string(),
      quantity: z.number().int(),
      warehouse: z.string(),
    },
    annotations: { readOnlyHint: true },                     // see M9
  },
  async ({ sku, warehouse }) => {
    const result = await apiClient.getInventory(sku, warehouse);
    // Return BOTH for backwards-compat: structuredContent (validated against outputSchema)
    // AND a TextContent block serializing the same JSON (clients without outputSchema support).
    return {
      content: [{ type: "text", text: JSON.stringify(result, null, 2) }],
      structuredContent: result,
    };
  }
);
```

The Zod object passed as `inputSchema` IS the JSON Schema the client sees. Use `.strict()` on complex objects to reject extra properties (S8). Source: github.com/modelcontextprotocol/typescript-sdk/blob/main/docs/server.md (retrieved 2026-06-13).

### M5: Resources -- URI-Based Access

Resources expose data the agent can read but not modify:

**Static resources** (known at registration):
```typescript
server.resource("config", "config://app", async (uri) => ({
  contents: [{ uri: uri.href, mimeType: "application/json", text: configJson }],
}));
```

**Dynamic resources** (parameterized):
```typescript
server.resource(
  "user-profile",
  new ResourceTemplate("users://{userId}/profile", { list: undefined }),
  async (uri, { userId }) => ({
    contents: [{ uri: uri.href, text: JSON.stringify(await getProfile(userId)) }],
  })
);
```

Clients discover resources via `resources/list` and read via `resources/read`. Use resources for reference data; use tools for actions.

### M6: Tool Count -- Merge to Cut Context Bloat

Tool definitions are loaded before the conversation even starts, and the cost is measured, not theoretical. Anthropic's tool-use research (retrieved 2026-06-13) reports: **58 tools = ~55K tokens** of definitions before the conversation begins; an internal agent where **tool definitions consumed 134K tokens** before optimization; and **Jira's MCP server alone uses ~17K tokens**. That is the real "why merge tools" evidence.

**Strategy**: Merge related API endpoints into workflow-oriented tools:
- `create_issue` + `set_labels` + `assign_user` --> `create_configured_issue`
- `search_code` + `get_file` --> `find_and_read_code`

**Better than ad-hoc merging at scale**: when definitions exceed ~10K tokens or you have 10+ tools, prefer the Tool Search Tool + Programmatic Tool Calling (M11) over lossy hand-merging — it keeps the full library loadable on demand while cutting ~85% of the token cost.

**Exception**: If operations are genuinely independent and users need them separately, keep them separate. Merge for workflows, not to hit an arbitrary number. Source: anthropic.com/engineering/advanced-tool-use.

### M7: Output Size -- 25K Token Hard Limit

Agent context windows are finite. A single tool response consuming 50K tokens leaves no room for reasoning.

**Implementation**:
```typescript
const MAX_CHARS = 25000; // ~6K tokens
if (result.length > MAX_CHARS) {
  const truncated = result.substring(0, MAX_CHARS);
  return {
    content: [{
      type: "text",
      text: truncated + "\n\n[TRUNCATED: " + result.length + " total chars. Use pagination or filter to narrow results.]"
    }],
  };
}
```

Always tell the agent the total size and how to get more data.

### M8: Error Responses -- isError Pattern

Business logic errors (invalid input, not found, rate limited) use the isError flag:

```typescript
// Business error -- agent can reason about this
return {
  isError: true,
  content: [{
    type: "text",
    text: JSON.stringify({
      error: "rate_limited",
      message: "API rate limit exceeded (60/min). Try again in 45 seconds.",
      hint: "Reduce batch size or add a delay between calls.",
    }),
  }],
};
```

Protocol errors (malformed request, transport failure) use JSON-RPC error codes (-32600 to -32603). The agent never sees these -- the MCP client handles them.

**NEVER**: Return raw stack traces (security leak). Return generic "error occurred" (agent cannot self-correct).

### M9: Tool Annotations

Every tool MUST declare its behavioral hints:

```typescript
server.registerTool(
  "delete_record",
  {
    title: "Delete Record",
    description: "Permanently delete a record by ID",
    inputSchema: { id: z.string() },
    annotations: {
      readOnlyHint: false,
      destructiveHint: true,
      idempotentHint: true,     // deleting same ID twice = same result
      openWorldHint: false,     // operates only on known records
    },
  },
  async ({ id }) => { /* ... */ }
);
```

| Annotation | Spec default (2025-06-18) | Effect on Agent |
|------------|---------------------------|----------------|
| `readOnlyHint` | `false` | `true` -> auto-approve, cancel on interrupt |
| `destructiveHint` | `true` | `true` -> require human confirmation |
| `idempotentHint` | `false` | `true` -> safe to retry on failure |
| `openWorldHint` | `true` | `true` -> may interact with external world |

**Defaults matter**: an unset `destructiveHint` defaults to `true` and an unset `readOnlyHint` defaults to `false` — i.e. the spec assumes a tool is destructive and not read-only until you say otherwise. Set hints explicitly; do not rely on the agent inferring them.

**⚠️ Annotations are NOT a security boundary.** The MCP 2025-06-18 spec MANDATES that clients **MUST consider tool annotations untrusted unless they come from a trusted server**. A malicious server can lie (`destructiveHint: false` on a `drop_table`). Annotations drive UX, not authorization — enforce real isolation via read/write server separation (P1) and IAM scope. Source: modelcontextprotocol.io/specification/2025-06-18/server/tools.

### M10: Shared Infrastructure

Extract repeated patterns to utils/:

- **api-client.ts**: Base URL, auth headers, request/response logging, timeout (30s default)
- **pagination.ts**: Cursor-based or offset pagination with configurable page size
- **errors.ts**: Standardized error formatting (isError pattern from M8)

Do NOT duplicate auth logic, pagination, or error formatting across tool files.

### M11: Tool Search Tool + Programmatic Tool Calling

When tool definitions get large, the spec-blessed alternative to hand-merging tools (M6) is the **Tool Search Tool** (load tool schemas on demand instead of all upfront) and **Programmatic Tool Calling** (the model writes code that calls tools, rather than emitting one tool-call per turn).

**Operationalized enable thresholds** (Anthropic, retrieved 2026-06-13):
- Enable the Tool Search Tool when **tool definitions consume >10K tokens** OR **10+ tools are available**.
- Less beneficial with **<10 tools** (the search overhead is not repaid).

**Measured impact**:
- Tool Search Tool: **85% token reduction** while keeping the full tool library available.
- MCP eval accuracy: **Opus 4.5 79.5% -> 88.1%**; **Opus 4 49% -> 74%**.
- Programmatic Tool Calling: average usage **43,588 -> 27,297 tokens (37% reduction)**.
- Adding tool-use examples to definitions: accuracy **72% -> 90%**.

**Rule**: For a server crossing the 10-tool / 10K-token line, evaluate Tool Search + Programmatic Tool Calling before lossy manual merging. Source: anthropic.com/engineering/advanced-tool-use.

---

## Anti-Patterns

- **God Server**: 58 tools on one server = ~55K tokens of definitions before the first task (Jira MCP alone ~17K). Split into domain-specific servers or adopt the Tool Search Tool (M11).
- **console.log() in STDIO**: Corrupts the JSON-RPC stream. Use console.error() or server.sendLoggingMessage().
- **Raw API passthrough**: Returning unfiltered API responses wastes context. Extract only the fields the agent needs.
- **Sync I/O**: All tool handlers MUST be async. Sync I/O blocks the event loop and stalls the transport.
- **No truncation**: A single tool dumping 200K chars can exhaust the agent's context window.
