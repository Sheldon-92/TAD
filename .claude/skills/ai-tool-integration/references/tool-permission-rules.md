# Tool Permission Model Rules
<!-- capability: tool_permission_model -->

## Quick Rule Index

| # | Rule | Scope |
|---|------|-------|
| P1 | Read/write separation: separate MCP servers with separate IAM roles | architecture |
| P2 | Four-level permission pipeline: deny > hooks > allow > prompt | enforcement |
| P3 | OAuth 2.1 + PKCE mandatory for remote MCP servers; MCP-Protocol-Version header MUST be sent | auth |
| P4 | Resource Indicators (RFC 8707) -- clients MUST send `resource` param (spec 2025-06-18 upgraded SHOULD->MUST) | auth |
| P5 | Session-scoped auth: time-limited, expires with session | lifecycle |
| P6 | Human-in-the-loop mandatory for destructive/irreversible operations | safety |
| P7 | Server is an OAuth 2.0 Resource Server; MUST publish PRM per RFC 9728 | protocol |
| P8 | Tool annotations drive permission classification -- but MUST be treated as untrusted | metadata |
| P9 | Audit logging: timestamp + tool + action + decision + reason | compliance |
| P10 | Interrupt behavior: cancel for read-only, block for write | reliability |
| P11 | Elicitation (elicitation/create): accept/decline/cancel, primitive types only, no secrets | HITL |

---

## Rules

### P1: Read/Write Server Separation

Read-only and write/destructive operations MUST run on separate MCP servers:

```
my-api-reader/          # Read-only server
  tools: search, get, list, describe
  IAM role: ReadOnly
  Permission: auto-approve

my-api-writer/          # Write server
  tools: create, update, delete, send
  IAM role: ReadWrite
  Permission: human confirmation
```

**Why**: A compromised or buggy read-only tool on a combined server has implicit write access. Separate servers = separate blast radius, separate IAM roles, separate audit trails.

**Exception**: Prototypes and local development can use a single server with tool-level annotation separation (readOnlyHint/destructiveHint). Production MUST separate.

### P2: Four-Level Permission Pipeline

Permissions are evaluated in priority order. Higher levels override lower:

```
Level 1: deny (remove tool entirely)
  --> Tool is not even registered. Agent cannot invoke it.
  --> Use for: dangerous operations, deprecated tools, security-banned tools.

Level 2: hooks (conditional judgment)
  --> PreToolUse hook evaluates context and returns allow/deny.
  --> Use for: context-dependent decisions, rate limiting, scope checking.

Level 3: allow (auto-approve)
  --> Tool executes without human confirmation.
  --> Use for: read-only operations, idempotent operations.

Level 4: prompt (human confirmation)
  --> Agent shows action summary, waits for human approve/deny.
  --> Use for: destructive operations, irreversible changes, sensitive data access.
```

**Enforcement priority**: `deny > hooks > allow > prompt`. A deny rule cannot be overridden by an allow rule. This is the same enforcement model Claude Code uses internally.

### P3: OAuth 2.1 + PKCE for Remote Servers

Remote MCP servers (HTTP/SSE transport) MUST use OAuth 2.1 with PKCE:

```
Authorization flow:
1. Client generates code_verifier (random 43-128 chars)
2. Client computes code_challenge = SHA256(code_verifier)
3. Client redirects to auth server with code_challenge
4. User authenticates and authorizes
5. Auth server returns authorization_code
6. Client exchanges code + code_verifier for access_token
7. Client uses access_token for MCP requests
```

**PKCE is MANDATORY** (not optional): Without it, authorization codes can be intercepted by malicious apps. OAuth 2.1 deprecates the implicit flow entirely.

**Protocol-version header (spec 2025-06-18)**: Every HTTP request from the client to the server **MUST** carry the `MCP-Protocol-Version` header. Servers reject an invalid value with **HTTP 400**; if the header is absent, servers default to `2025-03-26` for backwards-compat. **JSON-RPC batching was REMOVED** in 2025-06-18 (breaking change) — do not send batched requests.

**Local STDIO servers**: PKCE is not needed (communication is over process pipes, not network). Source: forgecode.dev/blog/mcp-spec-updates (retrieved 2026-06-13).

### P4: Resource Indicators (RFC 8707)

When an MCP server accesses multiple backend resources, use Resource Indicators to scope tokens:

```
Token request:
POST /token
  grant_type=authorization_code
  code=AUTH_CODE
  resource=https://api.inventory.example.com  # Specific resource
```

The issued token is scoped to ONLY the indicated resource. An agent with an inventory token cannot use it to access the billing API, even if both are behind the same auth server.

**Rule (spec 2025-06-18)**: clients **MUST** include the `resource` parameter (Resource Indicators, RFC 8707) to bind the token to a specific MCP server — the spec upgraded this from SHOULD to **MUST**. This prevents token reuse/confused-deputy across servers. Broad-scope tokens violate least-privilege. Source: forgecode.dev/blog/mcp-spec-updates (retrieved 2026-06-13).

### P5: Session-Scoped Auth

Auth tokens MUST be time-limited and session-scoped:

- **Access token TTL**: 15-60 minutes (shorter for destructive operations)
- **Refresh token TTL**: Session duration (revoked on session end)
- **Session end**: Token revocation, no persistent credentials

```typescript
// Session-scoped token management
class SessionAuth {
  private accessToken: string | null = null;
  private expiresAt: number = 0;

  async getToken(): Promise<string> {
    if (Date.now() > this.expiresAt - 60000) {  // Refresh 1min before expiry
      await this.refresh();
    }
    return this.accessToken!;
  }

  async endSession(): Promise<void> {
    await this.revokeToken();
    this.accessToken = null;
  }
}
```

**NEVER** persist access tokens to disk, environment variables, or config files beyond the session.

### P6: Human-in-the-Loop for Destructive Operations

Operations classified as destructive (irreversible, data-loss, external side-effects) MUST require human confirmation:

```typescript
// Tool classification
const DESTRUCTIVE_TOOLS = [
  "delete_record",      // Data loss
  "send_email",         // External side-effect, cannot unsend
  "execute_payment",    // Financial transaction
  "drop_table",         // Schema destruction
  "deploy_production",  // Production impact
];

// Confirmation flow
if (DESTRUCTIVE_TOOLS.includes(toolName)) {
  const summary = formatActionSummary(toolName, args);
  const approved = await askUser(`Confirm: ${summary} [approve/deny]`);
  if (!approved) {
    return { isError: true, content: [{ type: "text", text: "Operation denied by user." }] };
  }
}
```

**The agent MUST NOT bypass confirmation** through prompt engineering, multi-step decomposition, or parameter manipulation.

### P7: MCP Server = OAuth 2.0 Resource Server (PRM, RFC 9728)

The MCP 2025-06-18 spec formally classifies MCP servers as **OAuth 2.0 Resource Servers**. They **MUST** publish **Protected Resource Metadata per RFC 9728** so clients can discover the authorization server. When an MCP client receives a 401 from a server, the server MUST include a PRM pointer:

```http
HTTP/1.1 401 Unauthorized
WWW-Authenticate: Bearer
Link: <https://auth.example.com/.well-known/oauth-authorization-server>; rel="oauth-authorization-server"
```

The client follows the PRM link to discover:
- Authorization endpoint
- Token endpoint
- Supported scopes
- PKCE requirement

**Rule**: MCP servers MUST implement PRM (RFC 9728) for auth discovery. Clients MUST NOT hardcode auth endpoints -- always discover via PRM. Source: forgecode.dev/blog/mcp-spec-updates (retrieved 2026-06-13).

### P8: Tool Annotations Drive Permission Classification

Tool annotations determine automatic permission classification:

| Annotation Combination | Permission Level | Interrupt Behavior |
|------------------------|------------------|-------------------|
| `readOnlyHint: true` | allow (auto-approve) | cancel (safe to restart) |
| `readOnlyHint: false, destructiveHint: false` | allow or prompt (context-dependent) | block (wait for completion) |
| `destructiveHint: true` | prompt (human confirmation) | block (avoid partial execution) |
| `idempotentHint: true` | safe to retry | cancel (can re-execute) |

**Every tool MUST have annotations**. Per spec, unset hints default to the most restrictive classification: `destructiveHint` defaults to `true`, `readOnlyHint` to `false`, `idempotentHint` to `false`, `openWorldHint` to `true`.

**⚠️ Annotations are advisory, not a security boundary.** The MCP 2025-06-18 spec MANDATES that clients **MUST consider tool annotations untrusted unless they come from a trusted server**. A malicious server can claim `destructiveHint: false` on a `drop_table`. Use annotations for UX/approval defaults only; enforce real isolation through read/write server separation (P1) and scoped IAM roles. Source: modelcontextprotocol.io/specification/2025-06-18/server/tools.

### P9: Audit Logging

All tool invocations MUST be logged with:

```json
{
  "timestamp": "2026-05-15T10:30:00Z",
  "tool": "delete_record",
  "args": { "id": "rec_123" },
  "decision": "approved",
  "reason": "User confirmed via HITL prompt",
  "user": "session_abc",
  "duration_ms": 245,
  "result": "success"
}
```

**Fields**: timestamp, tool name, sanitized arguments (no secrets), decision (approved/denied/auto), reason, session ID, duration, result.

**Retention**: Minimum 30 days for production, 7 days for development.

### P10: Interrupt Behavior Classification

When an agent session is interrupted (user cancels, timeout, crash):

| Tool Type | Interrupt Behavior | Reason |
|-----------|-------------------|--------|
| Read-only | cancel (stop + discard) | Can be re-executed anytime |
| Write (idempotent) | cancel (stop + discard) | Can be re-executed safely |
| Write (non-idempotent) | block (wait for completion) | Partial execution = data inconsistency |
| Destructive | block (wait for completion) | Cannot undo partial destruction |

Set `interruptBehavior` to match the tool's annotation:
- `readOnlyHint: true` --> cancel
- `destructiveHint: true` --> block
- `idempotentHint: true` + write --> cancel (safe to re-execute)

### P11: Elicitation -- Spec-Blessed Mid-Session Input (2025-06-18)

The MCP 2025-06-18 spec adds **`elicitation/create`**: a server can request user input mid-session (e.g. ask for a missing parameter or a confirmation) instead of failing or guessing. This is the spec-native complement to the HITL confirmation in P6.

**Contract**:
- **Three-action client response model**: the user can **accept**, **decline**, or **cancel** the request — the server MUST handle all three (decline != cancel; cancel means the user dismissed without answering).
- **Primitive types only**: the requested schema is restricted to primitive JSON-schema types — `string`, `number`, `boolean` (no nested objects/arrays). Keep requests atomic.
- **No sensitive data**: servers **MUST NOT** use elicitation to request sensitive information (passwords, API keys, tokens). Route secrets through the OAuth flow (P3-P7), never an elicitation prompt.

```jsonc
// Server -> client
{ "method": "elicitation/create",
  "params": {
    "message": "Which warehouse should I deploy to?",
    "requestedSchema": { "type": "object",
      "properties": { "warehouse": { "type": "string", "enum": ["us-east","us-west","eu"] } },
      "required": ["warehouse"] } } }
// Client -> server: { "action": "accept" | "decline" | "cancel", "content": { "warehouse": "us-east" } }
```

Source: github.com/modelcontextprotocol/modelcontextprotocol .../2025-06-18/client/elicitation.mdx (retrieved 2026-06-13).

---

## Anti-Patterns

- **All tools same permission**: Destructive operations auto-approved = disaster. Classify every tool.
- **Permission only in prompt**: Prompt-level instructions can be bypassed by prompt injection. Use tool annotations + hooks.
- **No confirmation for delete**: Every delete, send, or deploy without HITL is one bad LLM judgment away from data loss.
- **No audit trail**: Post-incident investigation impossible without logs. Log every invocation.
- **Persistent credentials**: Access tokens saved to disk outlive the session. Use session-scoped tokens.
- **Broad-scope tokens**: One token for all resources violates least-privilege. Use Resource Indicators (RFC 8707), now a MUST.
- **Trusting tool annotations as a security boundary**: A malicious server lies (`destructiveHint: false` on `drop_table`). Spec says annotations MUST be treated as untrusted. Isolate via P1, do not trust hints.
- **Approve-on-install with no re-verification (rug-pull)**: A tool benign on Day-1 mutates Day-7 to exfiltrate keys. Pin+hash definitions, re-verify on change. See `references/mcp-spec-and-security-rules.md` X7.
