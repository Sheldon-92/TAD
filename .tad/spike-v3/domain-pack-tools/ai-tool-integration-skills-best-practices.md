# AI Tool Integration — Skills Best Practices

## Sources

| Source | Type | Key Value |
|--------|------|-----------|
| Claude Code Tool.ts (source code) | Primary reference | Tool interface: isConcurrencySafe/isReadOnly/isDestructive, validateInput→checkPermissions pipeline, schema contracts |
| ComposioHQ/awesome-claude-skills mcp-builder | GitHub SKILL.md | 4-phase MCP dev workflow, evaluation-driven development, 10 anti-patterns |
| modelcontextprotocol/typescript-sdk | Official SDK | MCP server structure, tool registration, Zod schema patterns |
| Production Tool Use Patterns (DEV.to) | Production guide | Enum params, structured errors, idempotency keys, confirmation gates |
| MCP Official Docs (modelcontextprotocol.io) | Protocol spec | Resources/Tools/Prompts capabilities, STDIO transport, debugging |
| TAD spike-v3/README.md | Claude Code hooks | Hook system validation, PreToolUse/PostToolUse patterns |

---

## Capability 1: mcp_server_development (Type B: Code)

**Best Step Design** (from ComposioHQ/mcp-builder SKILL.md):
1. Research target API: endpoints, auth, rate limits, error codes, data models, pagination
2. Design tool selection: prioritize high-impact use cases, consolidate related operations
3. Build shared infrastructure first: API helpers, error handling, response formatting, pagination
4. Implement tools with Zod/Pydantic schemas + tool annotations (readOnlyHint, destructiveHint)
5. Test via evaluation harness (NOT direct execution — causes hangs on STDIO servers)
6. Create 10 evaluation scenarios: complex, independent, read-only, verifiable

**Best Analysis Framework** (from ComposioHQ):
- Agent-Centric Design: "Build for Workflows, Not API Endpoints"
- Tool annotations: readOnlyHint, destructiveHint, idempotentHint, openWorldHint
- Response budget: 25,000 token character limit with truncation
- Evaluation-Driven Development: create eval scenarios early, iterate on agent performance

**Best Quality Standards** (from MCP SDK + ComposioHQ):
- Every tool has: name + description + inputSchema (Zod strict) + annotations
- Response ≤25K tokens with truncation strategy
- Zero `any` types (TypeScript strict mode)
- Error messages are actionable ("Try filter='active_only'" not "error 400")
- Shared utilities: no code duplication between tools

**Anti-Patterns** (from ComposioHQ — 10 listed):
- ❌ Direct API wrapping (one tool per endpoint instead of consolidated workflows)
- ❌ Exhaustive data returns (dump all fields instead of high-signal results)
- ❌ Poor error messages (diagnostic not actionable)
- ❌ Missing tool annotations (readOnlyHint, destructiveHint)
- ❌ No character limits (unbounded data consumes agent context)
- ❌ Testing STDIO server directly (causes indefinite hangs)

---

## Capability 2: cli_tool_wrapping (Type B: Code)

**Best Step Design** (from Claude Code Tool.ts + tools-registry.yaml):
1. Identify CLI tool: verify install command, version check, basic usage
2. Design wrapper interface: map CLI flags → tool input schema
3. Implement execution: Bash subprocess with timeout + error capture
4. Parse output: structured extraction from CLI stdout/stderr
5. Test: verify install, verify basic call, verify error handling

**Best Analysis Framework** (from TAD tools-registry.yaml pattern):
- Registry format: name + install + verify + usage + example (with actual output)
- Claude readability: "Write to the level that Claude can copy-paste and run"
- Safety classification: read-only vs write vs destructive

**Best Quality Standards** (from tools-registry.yaml + Claude Code):
- Install command: `brew install X` or `npx X` (simple, no Docker/registration)
- Verify command: `X --version` returns version number
- Usage: step-by-step with actual commands
- Example: complete input → command → output (with file sizes)
- Tested: actual execution with result recorded

**Anti-Patterns**:
- ❌ "Usage: use X to do Y" (Claude doesn't know how — needs exact commands)
- ❌ No verify command (can't confirm installation succeeded)
- ❌ GUI-only tools (Claude can't interact with GUIs)
- ❌ Tools requiring API keys without free tier (blocks adoption)

---

## Capability 3: api_integration (Type B: Code)

**Best Step Design** (from Production Tool Use Patterns):
1. Research API: endpoints, auth flow, rate limits, error codes
2. Design integration schema: input types, output types, error mapping
3. Implement with retry logic: exponential backoff at tool level (not agent loop)
4. Add idempotency keys for mutation endpoints
5. Test: mock API responses + live integration test

**Best Analysis Framework** (from Production patterns):
- Transient failure handling: retry at tool level, invisible to LLM
- Rate limiting per tool: cap individual calls (typically 5/session)
- Structured error objects: `{"error": "type", "message": "...", "hint": "..."}`
- Token budget enforcement: kill agent loop when cumulative tokens exceed threshold

**Best Quality Standards**:
- Every endpoint has: input schema + output schema + error codes + retry policy
- Idempotency keys on all mutation endpoints
- Rate limit: documented per-tool cap
- Cost tracking: per-call cost calculated from API pricing

**Anti-Patterns**:
- ❌ Raw traceback as error (model can't reason about it)
- ❌ No retry logic (single failure = task failure)
- ❌ No rate limiting (infinite loop = API ban + cost explosion)
- ❌ Mutation without idempotency (retry creates duplicates)

---

## Capability 4: tool_schema_design (Type A: Doc)

**Best Step Design** (from Claude Code Tool.ts + Anthropic API):
1. Define input schema with Zod/Pydantic: types, constraints, descriptions, examples
2. Define output schema: structured return type, not raw strings
3. Define error conditions: each error code + message + recovery hint
4. Define tool metadata: concurrency safety, read-only, destructive classification
5. Validate: schema strictness test (reject invalid inputs)

**Best Analysis Framework** (from Claude Code Tool.ts interface):
- Required methods: inputSchema, outputSchema, maxResultSizeChars
- Safety methods: isConcurrencySafe(), isReadOnly(), isDestructive()
- Validation pipeline: validateInput() → checkPermissions()
- Deferred loading: shouldDefer + searchHint for large tool sets
- Strict mode: `.strict()` on Zod schemas prevents extra properties
- Enum parameters reduce hallucination (fixed value sets)

**Best Quality Standards** (from Anthropic API + Production patterns):
- `strict: true` on all schemas (grammar-constrained sampling)
- Every parameter has: type + description + example + constraints
- Error conditions: ≥3 documented (auth fail, invalid input, rate limit)
- Tool description: "when to use" not just "what it does"

**Anti-Patterns**:
- ❌ No schema (AI hallucinates parameters)
- ❌ String type for everything (no validation)
- ❌ Missing "when to use" in description (agent activates tool incorrectly)
- ❌ Unbounded string outputs (consumes context without limit)

---

## Capability 5: tool_permission_model (Type A: Doc)

**Best Step Design** (from Claude Code permission pipeline):
1. Classify each tool: read-only / write / destructive
2. Design permission levels: auto-approve / conditional / human-confirm
3. Map to enforcement: static rules → mode-based → LLM classifier → user prompt
4. Define confirmation gates for destructive actions
5. Document escalation paths

**Best Analysis Framework** (from Claude Code Tool.ts):
- 4-level permission pipeline: deny (removes tool) → hooks (conditional) → allow (auto) → prompt (blocking)
- Tool classification: `isConcurrencySafe()`, `isReadOnly()`, `isDestructive()`
- `interruptBehavior()`: 'cancel' vs 'block' on user interrupt
- Denial tracking: >3 consecutive denials → escalate to user

**Anti-Patterns**:
- ❌ All tools same permission level (destructive operations auto-approved)
- ❌ No confirmation gate for destructive tools
- ❌ Permission checks only in prompt (bypassable)

---

## Capability 6: tool_testing (Type B: Code)

**Best Step Design** (from ComposioHQ + Production patterns):
1. Schema validation test: invalid inputs rejected correctly
2. Mock test: tool returns correct output for known inputs
3. Error handling test: graceful failure on timeout/auth error/rate limit
4. Integration test: real API call with test data
5. Evaluation harness: 10 complex scenarios, agent actually uses the tool

**Best Quality Standards**:
- ⚠️ STDIO MCP servers: NEVER test by running directly (causes hangs)
- Use timeout: `timeout 5s python server.py` or evaluation harness
- Schema test: every required field missing → proper error
- Error test: every documented error code has a test case

**Anti-Patterns**:
- ❌ Running STDIO server directly for testing (indefinite hang)
- ❌ Only testing happy path (errors are where tools fail)
- ❌ No integration test (mock passes but real API fails)

---

## Capability 7: tool_documentation (Type A: Doc)

**Best Step Design** (from Claude Code + ComposioHQ):
1. Write tool description: one-line summary + detailed purpose + when to use / not use
2. Document parameters: type + description + example + constraints + default
3. Document return values: structure + fields + example output
4. Document error conditions: code + message + recovery hint
5. Document usage examples: complete request → response pairs

**Best Analysis Framework** (from Claude Code Tool.ts):
- "Tool documentation = contract" (Anthropic API principle)
- Description fields: purpose line → detailed explanation → usage examples → error docs
- searchHint: 3-10 word capability phrase for deferred tools
- userFacingName: human-readable display name

**Best Quality Standards** (from ComposioHQ):
- Every tool has: purpose + parameters + return type + errors + examples
- Examples are complete: input → command → output (copy-paste runnable)
- "When NOT to use" is as important as "when to use"
- Documentation tested: give to someone unfamiliar, can they use the tool?

**Anti-Patterns**:
- ❌ "Usage: use this tool" (no example, no parameters, no errors)
- ❌ Only documenting happy path (no error handling guidance)
- ❌ Internal jargon without explanation
- ❌ Outdated examples that no longer work

---

## Cross-Cutting Patterns

### Pattern: Evaluation-Driven Development
Create 10 realistic eval scenarios BEFORE implementation. Test with agent, not manually. Iterate based on agent performance, not human judgment.

### Pattern: Workflow Tools > API Wrappers
Consolidate related operations into single tools. "create_and_configure_project" > "create_project" + "set_config" + "add_members" separately.

### Pattern: High-Signal Returns
Return only what the agent needs, not everything available. Character limit (25K tokens) + truncation strategy. Every unnecessary byte costs tokens on every subsequent turn.
