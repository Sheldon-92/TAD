# MCP Server Development Rules
<!-- capability: mcp_server_development -->

## Quick Rule Index

| # | Rule | Scope |
|---|------|-------|
| M1 | Use McpServer class from @modelcontextprotocol/sdk | project setup |
| M2 | Modular structure: src/index.ts (registration) + src/tools/*.ts (logic) | project structure |
| M3 | STDIO servers: console.log() is FORBIDDEN -- stdout is JSON-RPC | transport |
| M4 | Tool registration: server.tool(name, description, schema, handler) | API |
| M5 | Resources: URI-based, ResourceTemplate for dynamic, resources/list + resources/read | API |
| M6 | Tool count: target 15 or fewer per server | architecture |
| M7 | Output size: 25K token hard limit with truncation strategy | output |
| M8 | Error responses: isError:true + content array, not generic messages | error handling |
| M9 | Tool annotations: readOnlyHint, destructiveHint, idempotentHint on every tool | metadata |
| M10 | Shared infrastructure: extract utils/ for API client, pagination, error handler | code quality |

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

### M4: Tool Registration API

Register tools using the 4-argument pattern:

```typescript
server.tool(
  "get_inventory",                          // name (see schema rules for naming)
  "Get current inventory level for a SKU",  // description (see doc rules)
  {
    sku: z.string().describe("Product SKU, e.g. 'WIDGET-001'"),
    warehouse: z.enum(["us-east", "us-west", "eu"]).describe("Warehouse region"),
  },
  async ({ sku, warehouse }) => {
    // handler implementation
    const result = await apiClient.getInventory(sku, warehouse);
    return {
      content: [{ type: "text", text: JSON.stringify(result, null, 2) }],
    };
  }
);
```

The Zod schema passed as the third argument IS the inputSchema. Use `.strict()` on complex objects to reject extra properties.

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

### M6: Tool Count -- Target 15 or Fewer

Each tool adds ~700-1500 tokens to the agent's context (name + description + schema). 35 tools (like GitHub MCP) consume ~26K tokens before the first task.

**Strategy**: Merge related API endpoints into workflow-oriented tools:
- `create_issue` + `set_labels` + `assign_user` --> `create_configured_issue`
- `search_code` + `get_file` --> `find_and_read_code`

**Exception**: If operations are genuinely independent and users need them separately, keep them separate. Merge for workflows, not to hit an arbitrary number.

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
server.tool(
  "delete_record",
  "Permanently delete a record by ID",
  { id: z.string() },
  async ({ id }) => { /* ... */ },
  {
    readOnlyHint: false,
    destructiveHint: true,
    idempotentHint: true,     // deleting same ID twice = same result
    openWorldHint: false,     // operates only on known records
  }
);
```

| Annotation | Effect on Agent |
|------------|----------------|
| `readOnlyHint: true` | Auto-approve, cancel on interrupt |
| `destructiveHint: true` | Require human confirmation |
| `idempotentHint: true` | Safe to retry on failure |
| `openWorldHint: true` | May interact with external world |

### M10: Shared Infrastructure

Extract repeated patterns to utils/:

- **api-client.ts**: Base URL, auth headers, request/response logging, timeout (30s default)
- **pagination.ts**: Cursor-based or offset pagination with configurable page size
- **errors.ts**: Standardized error formatting (isError pattern from M8)

Do NOT duplicate auth logic, pagination, or error formatting across tool files.

---

## Anti-Patterns

- **God Server**: 35+ tools on one server. Context cost = 26K+ tokens. Split into domain-specific servers.
- **console.log() in STDIO**: Corrupts the JSON-RPC stream. Use console.error() or server.sendLoggingMessage().
- **Raw API passthrough**: Returning unfiltered API responses wastes context. Extract only the fields the agent needs.
- **Sync I/O**: All tool handlers MUST be async. Sync I/O blocks the event loop and stalls the transport.
- **No truncation**: A single tool dumping 200K chars can exhaust the agent's context window.
