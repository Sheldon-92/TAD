# AI Tool Integration — Tool Research

## Tool Needs per Capability

| Capability | Type | Need | Tool | Registry? |
|-----------|------|------|------|-----------|
| mcp_server_development | Code B | MCP server scaffold | @modelcontextprotocol/create-server | ❌ New |
| mcp_server_development | Code B | MCP server testing | @modelcontextprotocol/inspector | ❌ New |
| cli_tool_wrapping | Code B | CLI execution + parsing | Bash (builtin) | ✅ |
| api_integration | Code B | HTTP requests | WebFetch (builtin) | ✅ |
| tool_schema_design | Doc A | Schema diagrams | D2 | ✅ diagram_generation |
| tool_schema_design | Doc A | Design documents | Typst | ✅ pdf_generation |
| tool_permission_model | Doc A | Permission pipeline diagrams | D2 | ✅ diagram_generation |
| tool_testing | Code B | Test execution | npm test / jest / vitest | ✅ (project-local) |
| tool_documentation | Doc A | Documentation PDF | Typst | ✅ pdf_generation |

## Tool Testing Results

### Test 1: @modelcontextprotocol/create-server (MCP Scaffold)

```bash
# Install (via npx, no global install needed)
npx @modelcontextprotocol/create-server my-server --name "my-server"

# Note: Deprecated as of v0.3.1, but still functional for scaffolding
# Interactive prompts: name, description — creates TypeScript MCP server project
```

**Result**: ⚠️ PARTIAL — Package deprecated, requires interactive input (can't fully automate in non-interactive Claude session). However, the generated project structure is standard and can be created manually:

```
my-server/
├── package.json
├── tsconfig.json
├── src/
│   └── index.ts    # MCP server entry point
└── README.md
```

**Alternative**: Manual scaffold using `npm init` + MCP SDK dependency. More reliable for automated creation.

### Test 2: @modelcontextprotocol/inspector (MCP Testing)

```bash
# Install (via npx)
npx @modelcontextprotocol/inspector

# Version: 0.21.1
# Starts a web UI for testing MCP servers
# Connects to server via STDIO or HTTP
```

**Result**: ✅ SUCCESS — Inspector starts and provides web UI for testing MCP tools. However, it's interactive (web browser needed), so for automated testing, use the MCP SDK client directly:

```typescript
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StdioClientTransport } from "@modelcontextprotocol/sdk/client/stdio.js";

const transport = new StdioClientTransport({
  command: "node",
  args: ["dist/index.js"]
});
const client = new Client({ name: "test", version: "1.0.0" });
await client.connect(transport);
const result = await client.callTool({ name: "my_tool", arguments: { ... } });
```

### Test 3: Existing Registry Tools

| Tool | Test | Result |
|------|------|--------|
| D2 (diagram_generation) | `d2 --version` → 0.7.1 | ✅ Already tested in agent-architecture pack |
| Typst (pdf_generation) | `typst --version` → 0.14.2 | ✅ Already tested |
| Python/Matplotlib | `python3 -c "import matplotlib"` | ✅ Available |

## New Registry Entries Needed

### mcp_scaffold

```yaml
mcp_scaffold:
  description: "MCP server project scaffolding and development"
  recommended:
    name: manual-scaffold
    type: builtin
    install: "npm init -y && npm install @modelcontextprotocol/sdk zod"
    verify: "node -e \"require('@modelcontextprotocol/sdk')\""
    usage: |
      1. Create project: mkdir my-server && cd my-server && npm init -y
      2. Install SDK: npm install @modelcontextprotocol/sdk zod
      3. Add TypeScript: npm install -D typescript @types/node && npx tsc --init
      4. Create src/index.ts with MCP server setup
      5. Build: npx tsc
      6. Test: node dist/index.js (via MCP Inspector or SDK client)
    example: |
      // src/index.ts
      import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
      import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
      import { z } from "zod";

      const server = new McpServer({ name: "my-server", version: "1.0.0" });

      server.tool("greet", { name: z.string() }, async ({ name }) => ({
        content: [{ type: "text", text: `Hello, ${name}!` }]
      }));

      const transport = new StdioServerTransport();
      await server.connect(transport);
    output_format: "TypeScript MCP server project"
    tested: true
    test_result: "MCP SDK v1.12+ installs correctly, server runs on STDIO"
```

## Conclusion

- **Existing registry tools** cover Doc A capabilities (D2, Typst, Matplotlib)
- **MCP SDK** is the primary new tool — manual scaffold is more reliable than deprecated create-server
- **MCP Inspector** useful for interactive testing but not automatable
- **SDK Client** is the right approach for automated tool testing
- 1 new registry entry recommended: `mcp_scaffold`
