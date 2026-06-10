# Tool Permission Model Rules
<!-- capability: tool_permission_model -->

## Quick Rule Index

| # | Rule | Scope |
|---|------|-------|
| P1 | Read/write separation: separate MCP servers with separate IAM roles | architecture |
| P2 | Four-level permission pipeline: deny > hooks > allow > prompt | enforcement |
| P3 | OAuth 2.1 + PKCE mandatory for remote MCP servers | auth |
| P4 | Resource Indicators (RFC 8707) for multi-resource auth | auth |
| P5 | Session-scoped auth: time-limited, expires with session | lifecycle |
| P6 | Human-in-the-loop mandatory for destructive/irreversible operations | safety |
| P7 | Protected Resource Metadata (PRM): 401 + pointer for auth discovery | protocol |
| P8 | Tool annotations drive permission classification | metadata |
| P9 | Audit logging: timestamp + tool + action + decision + reason | compliance |
| P10 | Interrupt behavior: cancel for read-only, block for write | reliability |

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

**Local STDIO servers**: PKCE is not needed (communication is over process pipes, not network).

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

**Rule**: Each MCP server that accesses a distinct backend resource SHOULD request a resource-scoped token. Broad-scope tokens violate least-privilege.

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

### P7: Protected Resource Metadata (PRM)

When an MCP client receives a 401 from a server, the server MUST include a PRM pointer:

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

**Rule**: MCP servers MUST implement PRM for auth discovery. Clients MUST NOT hardcode auth endpoints -- always discover via PRM.

### P8: Tool Annotations Drive Permission Classification

Tool annotations determine automatic permission classification:

| Annotation Combination | Permission Level | Interrupt Behavior |
|------------------------|------------------|-------------------|
| `readOnlyHint: true` | allow (auto-approve) | cancel (safe to restart) |
| `readOnlyHint: false, destructiveHint: false` | allow or prompt (context-dependent) | block (wait for completion) |
| `destructiveHint: true` | prompt (human confirmation) | block (avoid partial execution) |
| `idempotentHint: true` | safe to retry | cancel (can re-execute) |

**Every tool MUST have annotations**. Missing annotations default to the most restrictive classification (destructiveHint: true).

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

---

## Anti-Patterns

- **All tools same permission**: Destructive operations auto-approved = disaster. Classify every tool.
- **Permission only in prompt**: Prompt-level instructions can be bypassed by prompt injection. Use tool annotations + hooks.
- **No confirmation for delete**: Every delete, send, or deploy without HITL is one bad LLM judgment away from data loss.
- **No audit trail**: Post-incident investigation impossible without logs. Log every invocation.
- **Persistent credentials**: Access tokens saved to disk outlive the session. Use session-scoped tokens.
- **Broad-scope tokens**: One token for all resources violates least-privilege. Use Resource Indicators.
