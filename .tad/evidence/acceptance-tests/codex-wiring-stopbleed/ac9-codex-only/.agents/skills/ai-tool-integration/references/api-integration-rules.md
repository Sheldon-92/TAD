# API Integration Rules
<!-- capability: api_integration -->

## Quick Rule Index

| # | Rule | Scope |
|---|------|-------|
| A1 | OpenAPI-to-MCP conversion for REST APIs | architecture |
| A2 | Rate limiting MUST be implemented -- prevent DoS + cost control | reliability |
| A3 | Retry via isError:true + actionable feedback, not hardcoded loops | error handling |
| A4 | Pagination: return structured JSON with cursor/next indicators | data handling |
| A5 | Endpoint-to-tool mapping: merge related endpoints into workflow tools | design |
| A6 | Idempotency keys for all mutation endpoints | data integrity |
| A7 | Auth injection: API keys via env vars, never hardcoded | security |
| A8 | Output filtering: extract only agent-needed fields | token efficiency |

---

## Rules

### A1: OpenAPI-to-MCP Conversion

When integrating a REST API that has an OpenAPI/Swagger spec:

```bash
# Auto-generate MCP server from OpenAPI spec
npx openapi-to-mcp --spec https://api.example.com/openapi.json --output ./my-api-server

# Alternative: mcp-swagger-server for dynamic runtime conversion
npx mcp-swagger-server --url https://api.example.com/swagger.json
```

**Post-generation checklist**:
1. Review generated tools -- remove low-value endpoints (admin, internal)
2. Merge related endpoints into workflow tools (see A5)
3. Add enum constraints where OpenAPI spec uses free-text strings
4. Add rate limiting (see A2) -- auto-generators do NOT add this
5. Add output filtering (see A8) -- auto-generators return full API responses
6. Test with MCP Inspector before registering with Claude Code

**Rule**: Auto-generation is a starting point, not a finished product. Every generated server needs manual review for tool count, output size, and security.

### A2: Rate Limiting -- Mandatory

Every API integration MUST implement rate limiting. Without it, an agent in a retry loop can:
- Exhaust API quotas in minutes
- Trigger IP bans
- Generate unexpected costs ($100+ on pay-per-call APIs)

**Implementation pattern**:
```typescript
class RateLimiter {
  private calls: number[] = [];
  constructor(
    private maxCalls: number,  // e.g., 60
    private windowMs: number,  // e.g., 60000 (1 minute)
  ) {}

  async check(): Promise<void> {
    const now = Date.now();
    this.calls = this.calls.filter(t => t > now - this.windowMs);
    if (this.calls.length >= this.maxCalls) {
      const waitMs = this.calls[0] + this.windowMs - now;
      return Promise.reject({
        isError: true,
        content: [{
          type: "text",
          text: `Rate limit: ${this.maxCalls}/${this.windowMs/1000}s. Retry in ${Math.ceil(waitMs/1000)}s.`
        }],
      });
    }
    this.calls.push(now);
  }
}
```

**Per-tool caps**: Document the limit for each tool (e.g., "5 calls per session" for expensive operations).

### A3: Retry via isError -- Delegate to Agent

Hardcoded retry loops inside the tool are an anti-pattern. The agent cannot reason about WHY the retry is happening, and infinite retry loops waste tokens and time.

**Correct pattern**: Return `isError: true` with actionable feedback. Let the agent decide whether to retry.

```typescript
// WRONG: hardcoded retry loop
async function callApi(params) {
  for (let i = 0; i < 3; i++) {
    try { return await fetch(url, params); }
    catch (e) { await sleep(1000 * Math.pow(2, i)); }
  }
}

// RIGHT: return isError with guidance
async function callApi(params) {
  try {
    return await fetch(url, params);
  } catch (e) {
    if (e.status === 429) {
      return {
        isError: true,
        content: [{ type: "text", text: JSON.stringify({
          error: "rate_limited",
          message: "API rate limit hit. Retry after " + e.headers['retry-after'] + "s.",
          hint: "Reduce batch size or wait before retrying."
        })}],
      };
    }
    // ... other error types
  }
}
```

**Exception**: Network-level retries (TCP timeout, DNS failure) at the HTTP client layer are acceptable -- these are transport issues, not business logic.

### A4: Pagination -- Structured JSON

When an API endpoint returns paginated results:

```typescript
return {
  content: [{
    type: "text",
    text: JSON.stringify({
      results: items.slice(0, 20),  // First page
      pagination: {
        total: totalCount,
        returned: Math.min(20, items.length),
        has_more: items.length > 20,
        next_cursor: lastItem?.id,   // For cursor-based
        // OR
        next_offset: offset + 20,    // For offset-based
      },
      hint: "Use cursor parameter to fetch next page.",
    }),
  }],
};
```

**Rules**:
- Default page size: 20 items (balance between usefulness and token cost)
- Always include `has_more` boolean -- agent needs to know if more data exists
- Always include `total` count if the API provides it
- Zero-param tools that return unbounded lists MUST have a default limit

### A5: Endpoint-to-Tool Mapping

Do NOT create one tool per API endpoint. Merge related endpoints into workflow-oriented tools:

| API Endpoints | Merged Tool | Why |
|---------------|-------------|-----|
| POST /issues + PUT /issues/:id/labels + PUT /issues/:id/assignees | `create_configured_issue` | Common workflow is create-then-configure |
| GET /search/code + GET /repos/:owner/:repo/contents/:path | `find_and_read_code` | Search results need content to be useful |
| GET /users/:id + GET /users/:id/orders + GET /users/:id/tickets | `get_user_context` | Agent always needs the full picture |

**Target**: 15 or fewer tools per server. If you have 30+ endpoints, split into domain-specific servers (read vs write, different resource types).

### A6: Idempotency Keys for Mutations

Every mutation endpoint (POST, PUT, DELETE) MUST use idempotency keys:

```typescript
const idempotencyKey = `${userId}-${action}-${resourceId}-${Date.now()}`;

const response = await fetch(url, {
  method: 'POST',
  headers: {
    'Idempotency-Key': idempotencyKey,
    'Content-Type': 'application/json',
  },
  body: JSON.stringify(params),
});
```

Without idempotency keys, agent retry on timeout creates duplicate records. The key format `{user}-{action}-{resource}` ensures the same logical operation produces the same key.

### A7: Auth Injection

API keys and tokens MUST come from environment variables, never hardcoded:

```typescript
// CORRECT
const apiKey = process.env.MY_API_KEY;
if (!apiKey) {
  throw new Error("MY_API_KEY env var required. Set in MCP server config.");
}

// WRONG -- hardcoded key
const apiKey = "sk-abc123...";

// WRONG -- key in config file committed to git
import config from './config.json'; // contains API key
```

MCP server config injects env vars:
```json
{
  "mcpServers": {
    "my-api": {
      "command": "node",
      "args": ["dist/index.js"],
      "env": { "MY_API_KEY": "${MY_API_KEY}" }
    }
  }
}
```

### A8: Output Filtering

API responses often contain 50+ fields. The agent needs 5-10. Return only what the agent needs:

```typescript
// WRONG: return full API response
return { content: [{ type: "text", text: JSON.stringify(apiResponse) }] };

// RIGHT: extract relevant fields
const filtered = {
  id: apiResponse.id,
  title: apiResponse.title,
  status: apiResponse.status,
  assignee: apiResponse.assignee?.login,
  created: apiResponse.created_at,
};
return { content: [{ type: "text", text: JSON.stringify(filtered, null, 2) }] };
```

**Rule**: Each returned field must be justifiable. "The agent might need it" is not justification -- add it when the agent actually needs it.

---

## Anti-Patterns

- **Raw traceback as error**: Agent cannot reason about stack traces. Structured error with `hint` field is required.
- **No retry guidance**: Generic "error occurred" gives the agent no path forward. Include what to try next.
- **No rate limiting**: Agent in a loop = API ban + cost explosion. Always implement.
- **Mutation without idempotency**: Retry on timeout creates duplicate data. Always use idempotency keys.
- **Unfiltered API responses**: 50-field JSON wastes context tokens. Return only agent-needed fields.
- **One tool per endpoint**: 30 API endpoints = 30 tools = 45K tokens of schema. Merge into 10-15 workflow tools.
