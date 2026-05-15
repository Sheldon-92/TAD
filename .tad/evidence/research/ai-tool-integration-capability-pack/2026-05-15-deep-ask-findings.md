# ai-tool-integration Capability Pack — Deep Ask Research Findings

> Notebook: AI Tool Integration — MCP Servers, CLI Wrapping, API Integration
> Notebook ID: e29b32c1-64f8-4d07-8baa-5dc54666d0af
> Sources: 10 GitHub repos (MCP SDK, awesome-mcp-servers, Anthropic cookbook/courses/SDK, Claude Code docs)
> Date: 2026-05-15
> Rounds: 3

---

## Round 1: MCP Server Dev, Schema Design, Server Patterns

### MCP Server Development
- SDK: `@modelcontextprotocol/sdk` — McpServer class, server.tool(), ResourceTemplate
- Tool registration: `server.tool(name, description, inputSchema: zodShape, handler)`
- Resources: static or dynamic via ResourceTemplate, URI-based, resources/list + resources/read
- Testing: `npx @modelcontextprotocol/inspector node build/index.js` (visual inspector)
- Claude Code: `claude mcp add --transport stdio myserver -- npx server`
- Project structure: src/index.ts (registration) + src/tools/*.ts (logic) — modular

### Schema Design
- JSON Schema draft 2020-12 or draft-07 for parameters
- Use `enum` constraints to prevent hallucinated inputs
- Zero-param tools: `{ "type": "object", "additionalProperties": false }`
- Tool names: 1-128 chars, alphanumeric + _ - . only, case-sensitive, must be unambiguous
- Namespace prefix: `mcp__plugin_<plugin>_<server>__<tool>` for collision avoidance
- Error responses: `{ isError: true, content: [...] }` for business logic errors; JSON-RPC codes for protocol errors
- x-mcp-header annotation for HTTP header mirroring (NOT for secrets)

### Server Categories (Top 5 Patterns)
1. Database integrations (PostgreSQL, MySQL, Supabase, MongoDB, SQLite)
2. API proxies / SaaS adapters (AWS, Stripe, Slack, Jira, GitHub) — OAuth at server level
3. File system management (read/write with permitted directory scoping)
4. Browser automation + search (Playwright, Puppeteer, Brave Search)
5. Code execution + dev tools (Docker sandbox, test runners, AST analysis, Semgrep)

---

## Round 2: CLI Wrapping, Permissions, Testing

### CLI Wrapping vs MCP
- MCP wrapping: structured JSON, managed auth, state — but 10-32x token cost ("schema dumping")
- Direct CLI/Bash: near-zero overhead, ~100% reliability — LLMs know CLI tools from training
- **Inner loop (fast local iteration)**: use direct CLI
- **Outer loop (shared infra, CI/CD, compliance)**: use MCP wrapping

### Permission Model
- Read/write separation: separate MCP servers, read-only IAM roles
- Least-privilege: function-specific roles, time-limited
- Scope Challenges: `mcp:tools:read` — prove mandate before revealing resource existence
- OAuth 2.1: Resource Indicators (RFC 8707), mandatory PKCE, session-scoped auth
- Client ID Metadata Documents (CIMD): scalable trust for thousands of agents
- Protected Resource Metadata (PRM): 401 + PRM pointer for auth discovery
- Human-in-the-loop: mandatory for destructive/irreversible operations

### Testing
- MCP Inspector: UI mode (interactive) + CLI mode (CI/CD batch processing)
- Testomat.io: full MCP protocol support across AI ecosystems
- Mock client: MCP Inspector CLI mode as lightweight test client (no LLM needed)
- Multi-transport testing: test both stdio and HTTP/SSE early
- Security testing: auth gates, authorization, no leaking internal IPs/schemas
- Drift monitoring: track response formatting changes, latency spikes, error rates

---

## Round 3: API Integration, Documentation, Anti-Patterns

### API Integration
- OpenAPI-to-MCP converters: openapi-to-mcp, mcp-swagger-server (auto-generate from spec)
- Rate limiting: MUST implement to prevent DoS and manage API costs
- Retry logic: delegate to LLM via isError:true + actionable feedback (not hardcoded retry loops)
- Pagination: return structured JSON; restrict zero-param tools explicitly

### Tool Documentation
- JSON Schema (draft 2020-12 or draft-07) for all parameters
- Embed usage examples IN the tool description
- outputSchema (optional but recommended): guides LLM parsing + enables validation
- x-mcp-header for HTTP header mirroring (not for secrets — visible to proxies)

### Anti-Patterns
1. **God Tool**: single tool does everything — break into focused single-task tools
2. **Schema dumping**: 150K+ tokens before first task — use deferred ToolSearch loading
3. **Missing error context**: generic errors prevent LLM self-correction; but no stack traces (security)
4. **Authentication leaks**: secrets in code/config/env vars; x-mcp-header for sensitive params
5. **Tool name ambiguity**: "check_status" → "get_inventory_level"; namespace prefixing for multi-server

---

## Key Judgment Rules Extracted

### mcp_server_development
1. Use `@modelcontextprotocol/sdk` McpServer class for TypeScript servers
2. Modular structure: src/index.ts (registration) + src/tools/*.ts (logic)
3. Test with MCP Inspector: `npx @modelcontextprotocol/inspector node build/index.js`
4. Local Claude Code testing: `claude mcp add --transport stdio myserver`

### cli_tool_wrapping
1. Inner loop (local dev) = direct CLI/Bash; outer loop (infra/CI) = MCP wrapping
2. Token cost: MCP 10-32x more expensive than raw CLI
3. CLI-first when LLM already knows the tool from training data

### api_integration
1. OpenAPI-to-MCP auto-conversion for REST APIs
2. Rate limiting MUST be implemented (prevent DoS + cost control)
3. Retry via isError:true + actionable feedback (not hardcoded loops)
4. outputSchema recommended for structured parsing

### tool_schema_design
1. JSON Schema draft 2020-12, use enum to prevent hallucination
2. Tool names: specific, unambiguous, 1-128 chars, alphanumeric + _ - .
3. Zero-param: explicit { type: object, additionalProperties: false }
4. Error: isError:true + content array (not generic messages, not stack traces)

### tool_permission_model
1. Read/write separation: separate MCP servers with different IAM roles
2. OAuth 2.1 + PKCE + Resource Indicators (RFC 8707) for remote servers
3. Session-scoped auth: time-limited, expires with session
4. Human-in-the-loop mandatory for destructive operations

### tool_testing
1. MCP Inspector CLI mode for CI/CD integration testing
2. Multi-transport testing: stdio AND HTTP/SSE before deployment
3. Security: verify auth gates, no leaked internals in error messages
4. Drift monitoring: track format/latency/error shifts over time

### tool_documentation
1. Embed usage examples IN tool description field
2. JSON Schema + enum constraints for all parameters
3. outputSchema for response validation and LLM parsing guidance
4. No secrets in x-mcp-header annotations
