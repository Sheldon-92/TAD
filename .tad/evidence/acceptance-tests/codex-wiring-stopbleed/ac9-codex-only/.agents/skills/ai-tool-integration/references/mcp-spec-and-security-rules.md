# MCP Spec (2025-06-18) & Tool-Supply-Chain Security Rules
<!-- capability: mcp_spec_and_security -->

> Protocol version date pinned: **2025-06-18**. Re-check before copying — MCP iterates fast.
> Sources (retrieved 2026-06-13): modelcontextprotocol.io/specification/2025-06-18/server/tools,
> forgecode.dev/blog/mcp-spec-updates, github.com/modelcontextprotocol/modelcontextprotocol .../2025-06-18/client/elicitation.mdx,
> truefoundry.com/blog/blog-mcp-tool-poisoning-gateway-defense, owasp.org/www-community/attacks/MCP_Tool_Poisoning.

## Quick Rule Index

| # | Rule | Scope |
|---|------|-------|
| X1 | Pin protocol version 2025-06-18; send MCP-Protocol-Version header (400 on invalid; default 2025-03-26 if absent) | protocol |
| X2 | JSON-RPC batching REMOVED in 2025-06-18 -- do not send batched requests | protocol (breaking) |
| X3 | outputSchema -> server MUST return conforming structuredContent; also serialize JSON into a TextContent block | output |
| X4 | Annotation defaults + MUST treat annotations untrusted unless server is trusted | metadata/security |
| X5 | OAuth Resource Server: PRM per RFC 9728; client MUST send `resource` (RFC 8707, SHOULD->MUST) | auth |
| X6 | Elicitation: accept/decline/cancel, primitive types only, MUST NOT request secrets | HITL |
| X7 | Tool Poisoning / Rug-Pull: pin+hash tool definitions, re-verify on change, treat descriptions as untrusted | supply chain |

---

## Rules

### X1: Protocol Version Header

Every HTTP request from client to server **MUST** carry the `MCP-Protocol-Version` header. Servers reject an invalid value with **HTTP 400**. If the header is absent, the server defaults to **`2025-03-26`** for backwards-compat. Pin and assert `2025-06-18` so you exercise the current contract (structuredContent rules, elicitation, RFC 9728/8707 auth) rather than silently falling back.

### X2: JSON-RPC Batching Removed (Breaking)

The 2025-06-18 spec **removed JSON-RPC batching**. Code that bundled multiple JSON-RPC calls into a single array request will break against a current server. Send one request per call.

### X3: structuredContent Is Mandatory When outputSchema Is Declared

Spec language: **if a tool declares an `outputSchema`, the server MUST return `structuredContent` conforming to it**, and clients **SHOULD** validate the structured result against the schema. For backwards-compat, a tool returning `structuredContent` **SHOULD** also serialize the same JSON into a `TextContent` block so clients that don't understand `structuredContent` still receive the data. (Implementation detail lives in tool-schema-rules.md S7 and mcp-server-dev-rules.md M4.)

### X4: Annotation Defaults + Untrusted

Spec defaults for the four hints: `readOnlyHint` **false**, `destructiveHint` **true**, `idempotentHint` **false**, `openWorldHint` **true**. So an un-annotated tool is assumed destructive and not read-only.

**Security MANDATE**: clients **MUST consider tool annotations untrusted unless they come from a trusted server.** Annotations are UX hints, never an authorization boundary — a malicious server can lie. Enforce isolation via read/write server separation (P1) + scoped IAM, not annotation values.

### X5: OAuth 2.0 Resource Server (RFC 9728 + RFC 8707)

MCP servers are formally **OAuth 2.0 Resource Servers** and **MUST publish Protected Resource Metadata per RFC 9728**. Clients **MUST** include the `resource` parameter (Resource Indicators, **RFC 8707**) binding the access token to a specific server — the spec **upgraded this from SHOULD to MUST** in 2025-06-18, closing a confused-deputy / token-reuse gap. (Flow detail in tool-permission-rules.md P3-P7.)

### X6: Elicitation (elicitation/create)

The spec-blessed mid-session input mechanism. Three-action client response model: **accept / decline / cancel** (decline != cancel). Requested schema is restricted to **primitive types** (`string`, `number`, `boolean`). Servers **MUST NOT** use elicitation to request sensitive information — secrets go through OAuth, never an elicitation prompt. (Detail + JSON example in tool-permission-rules.md P11.)

### X7: Tool Poisoning & Rug-Pull -- The Supply-Chain Attack on Agent Context

This is the production-incident failure class the rest of the pack assumed away. It is NOT a user-side jailbreak — it is a supply-chain attack on the agent's context.

**Tool Poisoning**: malicious instructions are hidden in a tool's **`description` field** (or other metadata the model reads). The model ingests them as instructions and executes them with the agent's full ambient authority — file access, other tools, network. The user never sees the injected text. Tracked as **CVE-2025-54136 (MCPoison)** and **CVE-2025-54135 (CurXecute)**.

**Rug-Pull**: a tool silently **redefines itself after install**. Day-1 the definition is benign and passes review; Day-7 it mutates to exfiltrate API keys or call destructive tools. Approval-on-install is worthless if the definition can change underneath it.

**Mitigations**:
1. **Pin + hash tool definitions** (name, description, inputSchema, annotations). Store the hash at approval time.
2. **Re-verify the hash on every load/connect.** If a definition changed, **do NOT auto-approve** — surface the diff to a human (re-runs the P6 HITL gate).
3. **Treat all tool descriptions as untrusted input**, exactly like user-supplied data — never let a description instruction override your operating rules.
4. **Never auto-approve a server whose definitions changed** since the last verified hash.

**Context**: OWASP ranks **prompt injection #1 in the LLM Top 10 (2025)**; tool poisoning is the agent-context delivery vector for it. This reinforces P1 (read/write server separation) and P8/X4 (annotations are untrusted): isolation and verification, not trust, are the boundary.

---

## Anti-Patterns

- **Trusting the description field**: it is attacker-controlled in a poisoned/3rd-party server. Treat it as untrusted input.
- **Approve-on-install, never re-check**: enables rug-pulls. Re-verify the definition hash on every connect.
- **Annotations as authorization**: a malicious server lies. Annotations are UX, isolation is the boundary.
- **Batching JSON-RPC against a 2025-06-18 server**: removed in spec; breaks. One request per call.
- **Omitting the `resource` parameter**: now a MUST (RFC 8707); without it a token can be replayed against another server.
- **Eliciting secrets**: spec forbids it; route secrets through OAuth only.
