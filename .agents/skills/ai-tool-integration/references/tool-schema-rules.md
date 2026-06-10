# Tool Schema Design Rules
<!-- capability: tool_schema_design -->

## Quick Rule Index

| # | Rule | Scope |
|---|------|-------|
| S1 | JSON Schema draft 2020-12 or draft-07 for all parameters | standard |
| S2 | Enum constraints over free-text strings to prevent hallucination | input design |
| S3 | Tool names: 1-128 chars, alphanumeric + _ - . only, specific and unambiguous | naming |
| S4 | Namespace prefix: mcp__plugin_<plugin>_<server>__<tool> for collision avoidance | naming |
| S5 | Zero-param tools: explicit { type: object, additionalProperties: false } | edge case |
| S6 | Error format: isError:true + content array, structured JSON inside | error design |
| S7 | outputSchema: optional but recommended for structured parsing guidance | output design |
| S8 | Zod .strict() on all object schemas to reject extra properties | validation |
| S9 | Every parameter: type + constraint + description + example | completeness |
| S10 | maxResultSizeChars: hard limit on output to protect agent context | output safety |

---

## Rules

### S1: JSON Schema Standard

All tool input schemas MUST use JSON Schema (draft 2020-12 preferred, draft-07 acceptable):

```json
{
  "type": "object",
  "properties": {
    "query": {
      "type": "string",
      "description": "Search query, e.g. 'inventory level for WIDGET-001'",
      "maxLength": 500
    },
    "limit": {
      "type": "integer",
      "description": "Max results to return",
      "minimum": 1,
      "maximum": 100,
      "default": 20
    }
  },
  "required": ["query"],
  "additionalProperties": false
}
```

In TypeScript with Zod (the MCP SDK's native validation):
```typescript
{
  query: z.string().max(500).describe("Search query, e.g. 'inventory level for WIDGET-001'"),
  limit: z.number().int().min(1).max(100).default(20).describe("Max results to return"),
}
```

### S2: Enum Over Free-Text -- Prevent Hallucination

When a parameter has a finite set of valid values, use `enum` (Zod: `z.enum()`):

```typescript
// WRONG: free-text -- LLM hallucinates "active_users", "all", "everything"
status: z.string().describe("Filter by status")

// RIGHT: enum -- LLM can only pick from valid values
status: z.enum(["active", "inactive", "pending"]).describe("Filter by user status")
```

**When to use enum**:
- Status fields (active/inactive/pending)
- Category fields (type, priority, severity)
- Region/locale (us-east, us-west, eu)
- Output format (json, csv, markdown)
- Sort order (asc, desc)

**When NOT to use enum**: Search queries, free-text content, file paths, IDs.

### S3: Tool Naming Conventions

Tool names MUST be:
- **1-128 characters** (MCP protocol limit)
- **Characters**: alphanumeric, underscore `_`, hyphen `-`, dot `.` only
- **Case-sensitive**: `get_user` and `Get_User` are different tools
- **Specific and unambiguous**: the name alone should identify what the tool does

| Bad Name | Problem | Good Name |
|----------|---------|-----------|
| `check_status` | Status of what? | `get_inventory_level` |
| `process` | Process what? | `validate_order_input` |
| `do_thing` | Meaningless | `send_notification_email` |
| `data` | Not an action | `fetch_sales_report` |
| `run` | Run what? | `execute_sql_query` |

**Pattern**: `{verb}_{noun}` or `{verb}_{adjective}_{noun}`
- Verbs: get, list, search, create, update, delete, validate, send, execute
- Nouns: specific to the domain (inventory, order, user, report)

### S4: Namespace Prefix for Multi-Server

When multiple MCP servers are registered, tool names can collide. Use the namespace prefix:

```
mcp__plugin_<plugin>_<server>__<tool>
```

Examples:
- `mcp__plugin_inventory_warehouse__get_stock_level`
- `mcp__plugin_crm_salesforce__search_contacts`

This is the format Claude Code uses internally. For single-server setups, simple `{verb}_{noun}` is sufficient.

### S5: Zero-Parameter Tools

Tools that take no input still need an explicit empty schema:

```typescript
// CORRECT
server.tool(
  "get_server_status",
  "Get current server health status",
  {},  // Zod empty object = { type: object, additionalProperties: false }
  async () => { /* ... */ }
);
```

JSON Schema equivalent:
```json
{
  "type": "object",
  "properties": {},
  "additionalProperties": false
}
```

Without an explicit schema, some clients pass arbitrary parameters that the handler silently ignores, leading to confusing behavior.

### S6: Error Format -- Structured JSON

Tool errors MUST be structured, not free-text:

```typescript
// Error response structure
return {
  isError: true,
  content: [{
    type: "text",
    text: JSON.stringify({
      error: "invalid_input",           // machine-readable error code
      message: "SKU format invalid.",    // human-readable description
      hint: "Use format 'WIDGET-NNN', e.g. 'WIDGET-001'.",  // recovery guidance
      field: "sku",                      // which parameter caused the error
    }),
  }],
};
```

**Error taxonomy** (minimum 3 per tool):

| Code | HTTP Equiv | When |
|------|-----------|------|
| `invalid_input` | 400 | Parameter validation failed |
| `auth_error` | 401 | Missing or invalid credentials |
| `forbidden` | 403 | Valid credentials but insufficient permissions |
| `not_found` | 404 | Resource does not exist |
| `rate_limited` | 429 | Too many requests |
| `server_error` | 500 | Upstream service failure |

**NEVER** include: stack traces (security leak), raw HTTP response bodies (unstructured), or generic "an error occurred" (agent cannot self-correct).

### S7: outputSchema -- Response Validation

outputSchema is optional in MCP but recommended for:
- Guiding LLM parsing of tool responses
- Enabling client-side validation
- Documenting the response contract

```typescript
server.tool(
  "get_inventory",
  "Get inventory level for a SKU",
  { sku: z.string() },
  async ({ sku }) => { /* ... */ },
  {
    annotations: { readOnlyHint: true },
    outputSchema: {
      type: "object",
      properties: {
        sku: { type: "string" },
        quantity: { type: "integer" },
        warehouse: { type: "string" },
        last_updated: { type: "string", format: "date-time" },
      },
      required: ["sku", "quantity"],
    },
  }
);
```

### S8: Zod .strict() -- Reject Extra Properties

All object schemas MUST use `.strict()` (or `additionalProperties: false` in JSON Schema):

```typescript
// WRONG: accepts any extra properties silently
const schema = z.object({ name: z.string() });

// RIGHT: rejects extra properties with clear error
const schema = z.object({ name: z.string() }).strict();
// Input { name: "test", extra: true } --> ZodError: Unrecognized key(s) in object: 'extra'
```

Without `.strict()`, LLMs pass hallucinated parameters that are silently ignored, making debugging difficult.

### S9: Parameter Completeness

Every parameter MUST have all four attributes:

| Attribute | Purpose | Example |
|-----------|---------|---------|
| Type | Data type | `z.string()`, `z.number().int()` |
| Constraint | Valid range/pattern | `.max(500)`, `.min(1).max(100)`, `.regex(/^WIDGET-\d{3}$/)` |
| Description | What it means + when to use | `"Product SKU, format WIDGET-NNN"` |
| Example | Concrete value | Via `.describe("..., e.g. 'WIDGET-001'")` |

**"string type" alone is NOT a schema**. Without constraints, the LLM can pass any string of any length.

### S10: maxResultSizeChars -- Output Safety

Every tool that returns variable-length data MUST enforce a character limit:

```typescript
const MAX_RESULT_CHARS = 25000;  // ~6K tokens

function formatResult(data: unknown): string {
  const json = JSON.stringify(data, null, 2);
  if (json.length <= MAX_RESULT_CHARS) return json;

  // Truncate with notice
  return json.substring(0, MAX_RESULT_CHARS) +
    `\n\n[TRUNCATED: ${json.length} chars total. Use 'limit' or 'filter' params to narrow results.]`;
}
```

Without this limit, a single tool response can consume the agent's entire context window, leaving no room for reasoning.

---

## Anti-Patterns

- **No schema**: LLM hallucinates parameters. Known, documented risk.
- **All string types**: No validation means no safety. Use specific types with constraints.
- **Tool description says "what" but not "when"**: Agent triggers the tool in wrong contexts. Include "when to use" and "when NOT to use."
- **No maxResultSizeChars**: Output grows unbounded. One bad query eats the entire context window.
- **Ambiguous tool names**: "check_status" matches multiple tools. Be specific: "get_inventory_level."
