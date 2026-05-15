# Tool Documentation Rules
<!-- capability: tool_documentation -->

## Quick Rule Index

| # | Rule | Scope |
|---|------|-------|
| D1 | Description: embed usage examples IN the tool description field | content |
| D2 | 8-dimension documentation: summary, description, when-to, when-not-to, params, returns, errors, example | completeness |
| D3 | searchHint: 3-10 words using terms NOT in the tool name | discoverability |
| D4 | "When NOT to use" is as important as "when to use" | safety |
| D5 | outputSchema for response validation and LLM parsing guidance | contract |
| D6 | x-mcp-header for HTTP header mirroring -- NOT for secrets | HTTP integration |
| D7 | Examples must be complete: input --> call --> output (copy-paste runnable) | usability |
| D8 | Readability test: an agent seeing this tool for the first time can use it correctly | quality bar |

---

## Rules

### D1: Embed Examples in Description

The tool `description` field is the primary (often only) documentation the agent reads. Embed usage examples directly:

```typescript
server.tool(
  "search_inventory",
  `Search product inventory across warehouses.

Use when: checking stock levels, finding product availability, auditing inventory.
Do NOT use when: modifying inventory (use update_inventory instead).

Example: search_inventory({ query: "WIDGET", warehouse: "us-east", limit: 10 })
Returns: { results: [{ sku: "WIDGET-001", quantity: 42, warehouse: "us-east" }], total: 1 }`,
  { /* schema */ },
  async (args) => { /* handler */ }
);
```

**Why in description**: Many agent frameworks only show tool descriptions, not separate documentation files. If the guidance is not in the description, the agent does not see it.

### D2: 8-Dimension Documentation

Every tool MUST be documented across all 8 dimensions:

| # | Dimension | Content | Example |
|---|-----------|---------|---------|
| 1 | Summary | One line, <= 15 words | "Search product inventory across warehouses" |
| 2 | Description | Why use, how it works | "Queries the inventory database..." |
| 3 | When to use | >= 3 scenarios | "Checking stock, finding availability, auditing" |
| 4 | When NOT to use | >= 2 scenarios | "Modifying inventory, checking pricing" |
| 5 | Parameters | Each: type + constraint + desc + example | "sku: string, max 20 chars, e.g. 'WIDGET-001'" |
| 6 | Returns | Structure + field descriptions + example output | "{ results: [...], total: number }" |
| 7 | Errors | Each error: code + cause + recovery | "not_found: SKU does not exist. Verify SKU format." |
| 8 | Example | Complete input --> call --> output | Full runnable example |

**"Usage: use this tool" = FAIL.** That sentence has zero information content.

### D3: searchHint -- Discovery Keywords

searchHint enables deferred tool loading (agent loads tool schema only when relevant):

```typescript
// Tool: get_inventory_level
// searchHint should use terms NOT in the tool name
searchHint: "stock count warehouse availability product SKU"

// Tool: send_notification_email
searchHint: "alert message notify user communication"
```

**Rules**:
- 3-10 words
- Use synonyms and related terms the user might say
- Do NOT repeat words already in the tool name
- Include domain-specific jargon the user might use

### D4: "When NOT to Use" -- Preventing Misuse

"When NOT to use" documentation is as important as "when to use." Without it, agents trigger tools in wrong contexts:

```
When NOT to use get_inventory:
- To modify inventory levels (use update_inventory)
- To check pricing (use get_pricing -- inventory has no price data)
- For real-time stock during checkout (use check_availability -- lower latency)
- For historical inventory data (use get_inventory_history)
```

**Minimum**: 2 "when NOT to use" scenarios per tool. These should reference the CORRECT alternative tool.

### D5: outputSchema for Response Contract

outputSchema documents what the tool returns and enables client-side validation:

```json
{
  "outputSchema": {
    "type": "object",
    "properties": {
      "results": {
        "type": "array",
        "items": {
          "type": "object",
          "properties": {
            "sku": { "type": "string", "description": "Product SKU" },
            "quantity": { "type": "integer", "description": "Current stock count" },
            "warehouse": { "type": "string", "description": "Warehouse location" }
          }
        }
      },
      "total": { "type": "integer", "description": "Total matching results" },
      "has_more": { "type": "boolean", "description": "Whether more pages exist" }
    }
  }
}
```

**Benefits**:
- Agent knows exactly what fields to expect
- Client can validate responses before passing to agent
- Serves as living documentation (code = docs)

### D6: x-mcp-header -- HTTP Header Mirroring

x-mcp-header annotations map tool parameters to HTTP headers:

```yaml
# In OpenAPI spec
x-mcp-header:
  X-Request-ID: requestId        # Maps param 'requestId' to header
  Accept-Language: locale         # Maps param 'locale' to header
```

**Rules**:
- USE for: request IDs, locale preferences, content negotiation, API versioning
- DO NOT USE for: API keys, auth tokens, session secrets
- Reason: Headers are visible to proxies and logging middleware. Secrets in headers leak.

### D7: Complete Examples -- Input to Output

Every example MUST show the full cycle:

```
Input:
  { "sku": "WIDGET-001", "warehouse": "us-east" }

Call:
  search_inventory({ sku: "WIDGET-001", warehouse: "us-east" })

Output:
  {
    "results": [{
      "sku": "WIDGET-001",
      "quantity": 42,
      "warehouse": "us-east",
      "last_updated": "2026-05-15T08:00:00Z"
    }],
    "total": 1,
    "has_more": false
  }
```

**Test**: Can someone copy this example and run it? If the answer is no, the example is incomplete.

Error example (equally important):
```
Input:
  { "sku": "NONEXISTENT-999" }

Output:
  {
    "isError": true,
    "error": "not_found",
    "message": "SKU 'NONEXISTENT-999' not found in any warehouse.",
    "hint": "Verify SKU format (WIDGET-NNN) or search with partial match."
  }
```

### D8: Readability Test

The quality bar for tool documentation:

> **"Give this tool documentation to an agent that has never seen this tool before. Can it use the tool correctly on the first attempt?"**

If the answer is no, the documentation is insufficient. Common failures:
- Missing parameter format (agent guesses wrong format)
- No error handling guidance (agent retries with same bad input)
- No "when NOT to use" (agent uses tool in wrong context)
- Jargon without explanation (agent misinterprets terminology)

---

## Anti-Patterns

- **"Usage: use this tool"**: Zero information content. Describe WHAT, WHEN, HOW, and WHEN NOT TO.
- **Happy path only docs**: Error handling guidance is more critical than success docs. Agents fail frequently.
- **Internal jargon without explanation**: "Use the FQDN from the SRE config" means nothing to an agent without context.
- **Stale examples**: Code changed but docs did not update. Examples must be tested.
- **No "when NOT to use"**: Agent uses the wrong tool in the wrong context. Always document alternatives.
- **Secrets in x-mcp-header**: Visible to proxies. Use env vars for secrets, x-mcp-header for non-sensitive metadata.
