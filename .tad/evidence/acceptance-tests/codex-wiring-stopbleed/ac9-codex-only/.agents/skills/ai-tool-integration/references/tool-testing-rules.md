# Tool Testing Rules
<!-- capability: tool_testing -->

## Quick Rule Index

| # | Rule | Scope |
|---|------|-------|
| T1 | MCP Inspector: UI mode for interactive testing, CLI mode for CI/CD | test tool |
| T2 | Multi-transport testing: test STDIO and HTTP/SSE before deployment | coverage |
| T3 | Schema validation testing: missing required, constraint violation, extra properties | input |
| T4 | Security testing: auth gates, no leaked internals in errors | security |
| T5 | Drift monitoring: track response format, latency, error rate changes | operations |
| T6 | Mock vs integration: mock for unit tests, real API for at least one integration test | strategy |
| T7 | STDIO server testing: use timeout or MCP SDK client, not direct execution | technique |
| T8 | Evaluation scenarios: 5+ complex, independent, read-only, verifiable test cases | quality |

---

## Rules

### T1: MCP Inspector -- Primary Test Tool

MCP Inspector is the official testing tool for MCP servers:

**UI mode (interactive testing)**:
```bash
# Launch Inspector with your server
npx @modelcontextprotocol/inspector node dist/index.js

# Opens browser UI at http://localhost:5173
# Test each tool manually: input params, execute, inspect response
```

**CLI mode (CI/CD batch testing)**:
```bash
# List available tools
npx @modelcontextprotocol/inspector --cli node dist/index.js --method tools/list

# Call a specific tool
npx @modelcontextprotocol/inspector --cli node dist/index.js \
  --method tools/call \
  --tool-name get_inventory \
  --tool-arg sku=WIDGET-001 \
  --tool-arg warehouse=us-east

# List resources
npx @modelcontextprotocol/inspector --cli node dist/index.js --method resources/list
```

**CI/CD integration**: CLI mode returns JSON on stdout. Parse with `jq` for assertions:
```bash
result=$(npx @modelcontextprotocol/inspector --cli node dist/index.js \
  --method tools/call \
  --tool-name get_inventory \
  --tool-arg sku=WIDGET-001)

echo "$result" | jq -e '.content[0].text | fromjson | .quantity > 0'
```

### T2: Multi-Transport Testing

Test BOTH transport modes before deployment:

**STDIO transport** (local development):
```bash
# Server runs as subprocess, communicates via stdin/stdout
npx @modelcontextprotocol/inspector node dist/index.js
```

**HTTP/SSE transport** (remote deployment):
```bash
# Server runs as HTTP service
node dist/index.js --transport http --port 3000

# Test via Inspector with URL
npx @modelcontextprotocol/inspector --url http://localhost:3000/sse
```

**What breaks between transports**:
- STDIO: console.log() corrupts the stream (caught by M3 rule)
- HTTP/SSE: CORS headers, auth middleware, connection timeout
- Both: JSON-RPC message framing, large response handling

**Rule**: If you only test STDIO and deploy HTTP, you WILL discover auth and CORS bugs in production.

### T3: Schema Validation Testing

For every tool, test three schema failure modes:

**Missing required parameter**:
```bash
# Should return clear error, not crash
npx @modelcontextprotocol/inspector --cli node dist/index.js \
  --method tools/call \
  --tool-name get_inventory
  # (no --tool-arg sku=...)
```
Expected: Error message naming the missing field.

**Constraint violation**:
```bash
# String too long, number out of range, invalid enum
npx @modelcontextprotocol/inspector --cli node dist/index.js \
  --method tools/call \
  --tool-name get_inventory \
  --tool-arg sku=THIS_IS_WAY_TOO_LONG_FOR_THE_SKU_FIELD_AAAAAAAA
```
Expected: Error message stating the constraint (maxLength, min/max, valid enum values).

**Extra properties (strict mode)**:
```bash
npx @modelcontextprotocol/inspector --cli node dist/index.js \
  --method tools/call \
  --tool-name get_inventory \
  --tool-arg sku=WIDGET-001 \
  --tool-arg nonexistent_field=true
```
Expected: Rejection with "unrecognized key" error (if schema is strict).

### T4: Security Testing

**Auth gate verification**:
```bash
# Remove API key from env, verify tool returns auth_error
unset MY_API_KEY
npx @modelcontextprotocol/inspector --cli node dist/index.js \
  --method tools/call \
  --tool-name get_inventory \
  --tool-arg sku=WIDGET-001
# Expected: { isError: true, error: "auth_error" }
```

**No leaked internals**:
```bash
# Trigger an error and inspect the response
result=$(npx @modelcontextprotocol/inspector --cli node dist/index.js \
  --method tools/call \
  --tool-name get_inventory \
  --tool-arg sku=INVALID)

# Verify no stack traces, internal IPs, file paths, or config details
echo "$result" | grep -i -E "(stack|trace|internal|/home/|/usr/|localhost:[0-9]|192\.168\.|10\.0\.)" && echo "FAIL: leaked internals" || echo "PASS"
```

**Authorization scope**:
- Read-only server cannot execute write tools
- Write server does not expose read tools (separation per P1)
- Each server's IAM role is scoped to its operation type

### T5: Drift Monitoring

After deployment, monitor for three types of drift:

**Response format drift**: API provider changes field names or types. Track by:
```bash
# Capture baseline response shape
npx @modelcontextprotocol/inspector --cli node dist/index.js \
  --method tools/call \
  --tool-name get_inventory \
  --tool-arg sku=WIDGET-001 | jq 'keys' > baseline_keys.json

# Weekly: compare current shape to baseline
current=$(npx @modelcontextprotocol/inspector --cli ... | jq 'keys')
diff <(echo "$current") baseline_keys.json
```

**Latency drift**: Tool response time increases beyond acceptable threshold:
- Baseline: measure p50, p95 latency for each tool at deployment
- Alert threshold: 2x baseline p95
- Investigation trigger: 3 consecutive alerts

**Error rate drift**: Error percentage increases:
- Baseline: measure error rate per tool over first week
- Alert threshold: error rate > 2x baseline OR > 10% of calls
- Common cause: upstream API changes, expired credentials, quota exhaustion

### T6: Mock vs Integration Strategy

**Unit tests with mocks** (run on every commit):
- Mock the API client, test tool logic in isolation
- Verify: schema validation, error formatting, output filtering, truncation
- Fast: <1s per test, no network required

**Integration tests with real API** (run daily or pre-release):
- Hit real API with test credentials (sandbox/staging)
- Verify: auth flow, actual response parsing, rate limiting behavior
- Slow: 2-10s per test, needs API access

**Rule**: Mock-only testing hides SDK shape drift (see ai-evaluation pack B7 rule). At least one integration test per tool MUST hit the real API or MCP Inspector with live server.

### T7: STDIO Server Testing Technique

STDIO MCP servers cannot be tested by running them directly -- they hang waiting for JSON-RPC input on stdin:

```bash
# WRONG: hangs forever
node dist/index.js

# RIGHT: use timeout for smoke test
echo '{}' | timeout 5s node dist/index.js
# Expected: exits with error (invalid JSON-RPC) but does not crash

# RIGHT: use MCP Inspector
npx @modelcontextprotocol/inspector node dist/index.js

# RIGHT: use MCP SDK client in test code
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StdioClientTransport } from "@modelcontextprotocol/sdk/client/stdio.js";

const transport = new StdioClientTransport({
  command: "node",
  args: ["dist/index.js"],
});
const client = new Client({ name: "test-client", version: "1.0.0" });
await client.connect(transport);

const result = await client.callTool("get_inventory", { sku: "WIDGET-001" });
assert(result.content[0].text.includes("WIDGET-001"));

await client.close();
```

### T8: Evaluation Scenarios

Design 5+ end-to-end scenarios that test real-world usage:

Each scenario MUST be:
- **Independent**: Does not depend on other test results
- **Read-only**: Does not modify data (safe to run repeatedly)
- **Complex**: Requires multiple tool calls or parameter combinations
- **Verifiable**: Has a deterministic expected answer (string comparison)

```yaml
scenarios:
  - name: "Multi-warehouse inventory check"
    steps:
      - tool: get_inventory
        args: { sku: "WIDGET-001", warehouse: "us-east" }
        assert: "quantity field is integer >= 0"
      - tool: get_inventory
        args: { sku: "WIDGET-001", warehouse: "us-west" }
        assert: "quantity field is integer >= 0"
    verify: "Both responses have same SKU, different warehouse"

  - name: "Error handling on invalid SKU"
    steps:
      - tool: get_inventory
        args: { sku: "NONEXISTENT-999" }
        assert: "isError is true, error code is 'not_found'"

  - name: "Rate limit behavior"
    steps:
      - tool: get_inventory (x6 rapid calls)
        assert: "6th call returns rate_limited error with retry guidance"
```

---

## Anti-Patterns

- **Direct STDIO server execution**: Hangs forever. Use timeout, Inspector, or SDK client.
- **Happy path only**: Errors are the primary failure mode for tools. Test error handling.
- **No integration tests**: Mock-only tests miss real API changes. Hit the real API at least once.
- **No drift monitoring**: APIs change without notice. Track format, latency, and error rates.
- **Test timeout > 5s**: Likely indicates a hanging connection or infinite loop. Investigate.
