# D5: Permission Design and MCP Security

**Decision**: How does the agent decide what it is allowed to do, and how are those boundaries enforced?

This is a two-part decision: (1) the agent's own permission model, and (2) the security of external tool connections (MCP). Both must be designed before the agent has access to external tools or takes irreversible actions.

---

## Part 1: Agent Permission Model

### Selection Matrix: Permission Level vs Risk Tolerance

| Permission Level | What It Allows | Risk Profile | When RIGHT |
|-----------------|----------------|--------------|------------|
| Plan only | Read + propose, no execution | Minimal | Reviewing decisions, generating plans |
| Default | Standard tool use with user confirmation prompts | Low | Daily development work |
| Accept Edits | Auto-accept non-destructive writes | Medium-Low | Trusted workspaces, known files |
| Auto | All tool use, limited confirmations | Medium | CI/automated pipelines |
| Bypass Permissions | Skip all confirmation checks | High | Never in production |

**Rule**: deploy at the LOWEST permission level that allows the task to complete. Creep upward only with explicit justification. [Source: Claude Code #5]

---

### Deny-First with Independent Failure Modes [Source: Claude Code #2]

```
Deny rules ALWAYS override allow rules, even when allow is more specific.
```

**Design principle**: if there is any ambiguity about whether an action is allowed, the answer is NO. Erring toward restriction produces recoverable outcomes (agent fails to complete task). Erring toward permission produces potentially irreversible outcomes (agent deletes data, sends email, charges customer).

**Independent failure modes**: each safety layer must fail independently of the others. [Source: Claude Code #2]

```
Layer 1: Permission model (what is the agent allowed to request?)
Layer 2: Tool-level validation (is this specific call safe?)
Layer 3: Environment sandbox (is the execution environment isolated?)
```

If all three layers share a common dependency (e.g., all read the same config file), one corrupted config disables all three. Design each layer with a different mechanism.

---

### Permission Scope: Session Boundaries [Source: Claude Code #7]

```
Permissions NEVER persist across sessions.
Trust must be re-established in each new session.
```

**Why**: permissions granted for session N may be appropriate for that specific task. In session N+1, the task, context, and risk profile may be completely different. Persisted permissions are stale permissions.

**Implementation**: permission state is initialized from immutable policy files at session start, never from the previous session's runtime state.

---

### Graduated Trust: HITL Placement [Source: research finding #18]

If more than 90% of human-in-the-loop approvals are granted without reading (approval fatigue), the approval gate provides no safety.

**Two-stage classifier** [Source: research finding #18]:
1. **Fast gate**: cheap model filters obvious non-issues (90%+ filtered, auto-approved)
2. **Adaptive permission gate**: human reviews only the flagged 10%

If all approvals look the same, humans stop paying attention. Differentiate by highlighting what changed, what tool is being called, and what the irreversibility is.

---

### Atomic Approval Consumption [Source: OpenClaw #5]

For high-risk actions (destructive mutations, external sends, financial transactions):

```
Approval = one-time token with expiration
After consumption: token invalidated
Replay window: zero
```

**Anti-pattern**: approval that persists for a session. If an agent receives blanket approval for "all writes in this session," a prompt injection or misbehaving tool can make writes the user never intended to approve.

**Implementation**: generate a unique nonce per approval request. Consumption burns the nonce. A second attempt with the same nonce is rejected, even if seconds apart.

---

### Dual-Agent Architecture for Untrusted Data [Source: research finding #19, OWASP]

When the agent processes external data (email, web pages, documents, API responses from third parties):

```
Privileged Planner (has tools) → sends data to →
Unprivileged Parser (no tools) → processes data → returns result to →
Privileged Planner → uses result
```

**The attack this prevents**: indirect prompt injection. Malicious instructions hidden in external data (email subject, web page content, JSON response) are processed by the Parser which CANNOT execute any tools. The Parser can only return text — it cannot trigger the agent to take actions.

**Key requirement 1**: the Parser LLM must have NO tool access. Zero tools. Not "limited tools." If the Parser can call even one tool, the isolation is broken.

**Key requirement 2**: the Privileged Planner must treat Parser output as structured data, NOT instructions [Source: "CaMeL-style" defense, Beurer-Kellner et al. 2025]. If the Planner reads Parser output and executes commands embedded in it ("the document says to email X"), the injection has hopped through the Parser. Parser output must be returned as a typed schema (fixed JSON structure, or pre-categorized fields) — the Planner consumes values, not verbs.

**Lethal trifecta** [Source: OWASP LLM Top 10]: if an agent simultaneously has:
1. Access to valuable data (files, emails, databases)
2. Ability to ingest untrusted external content
3. Ability to communicate externally (send email, call APIs)

...then a single indirect prompt injection can exfiltrate all data. The dual-agent architecture breaks condition 2 — Parser cannot communicate externally.

---

### Scoped Tokens per Environment [Source: Incident #1 — PocketOS database wipe]

**Production disaster**: staging agent found Railway CLI token with blanket permissions → issued DELETE volume mutation → wiped production database.

**Required design**: tokens and credentials must be scoped to the environment and operation they were issued for:
- Staging tokens: cannot affect production resources
- Read tokens: cannot perform mutations
- Ephemeral tokens: expire after the specific task completes

SPIFFE/SPIRE identity + RBAC per tool is the enterprise-grade implementation. At minimum: separate credential sets per environment, no cross-environment access.

---

## Part 2: MCP Security Checklist [Source: Elastic, Invariant Labs, research]

Use this checklist before connecting any MCP server to a production agent.

### Why this checklist is non-optional: 2026 MCP attack surface [Source: research finding #27, https://censys.com/blog/mcp-servers-on-the-internet/ retrieved 2026-06-13]

The dual-agent / deny-first rules above are backed by a fast-growing, measured attack surface:

- Internet-exposed MCP grew from **1,862 unauthenticated MCP servers** (July 2025 scan) to **12,520 internet-accessible MCP services across 8,758 unique IPs / 56 countries** (April 28 2026 scan) — a ~6.7x increase in ~9 months.
- Two landmark CVEs established the dominant client-side threat: **MCPoison (CVE-2025-54136)** and **CurXecute (CVE-2025-54135)** — **tool-poisoning**: malicious instructions embedded in tool descriptions, **visible to the LLM but not the user** (exactly the Incident #2 Cursor mechanism, Checklist Item 1 below).
- **9 of 11 MCP registries** tested accepted malicious packages **with no security review** — so registry presence is NOT a trust signal (Checklist Item 7 reputation scoring is required, not optional).

### Checklist Item 1: Display Full Tool Descriptions [Source: Incident #2 — Cursor poisoning]

**Attack**: malicious MCP server embeds `<IMPORTANT>` instructions in tool descriptions. Agent reads description, executes hidden instructions, exfiltrates credentials.

**Requirement**: the UI or agent MUST display the FULL tool description to users, not a summary. Users who cannot see the full description cannot detect hidden instructions.

**Verification**: for each connected MCP tool, render the full `description` field visible to the operator before the agent runs.

---

### Checklist Item 2: Enforce Cross-Server Boundaries [Source: Incident #3 — email hijacking]

**Attack**: malicious server modifies how trusted server tools behave (tool shadowing). User asks agent to send email using trusted email server → malicious server intercepts → routes to attacker.

**Requirement**: cross-server dataflow must be controlled. Tool from Server A cannot modify the behavior of Tool from Server B. Implement tool isolation boundaries between servers.

**Verification**: agent cannot pass output from an untrusted server directly as input to a trusted server without inspection.

---

### Checklist Item 3: Cryptographically Verify and Pin Tool Versions

**Attack (rug-pull)**: MCP server distributes a safe tool description → operator approves → server updates description post-approval to include malicious instructions → agent runs malicious version.

**Requirement**: hash the tool description at approval time. Verify the hash matches before each execution. If description has changed since approval → refuse + alert.

---

### Checklist Item 4: Container Sandbox with Network Isolation

Every MCP server execution MUST run in an isolated environment:
- Read-only filesystem (no writes outside designated paths)
- Network isolation (MCP server cannot make outbound calls to arbitrary hosts)
- seccomp/BPF system call filtering (limits what the process can do at the OS level)
- No access to host credentials, environment variables, or SSH keys

**E2B, Daytona, Cloudflare Workers** are managed sandbox options if building custom sandboxes is out of scope.

---

### Checklist Item 5: Zero Trust + Just-In-Time Access

**Anti-pattern**: persistent broad permissions ("this MCP server has admin access for the session").

**Required pattern**:
- Access is granted at task-start, scoped to the specific task
- Credentials expire when the task completes
- Next task requires fresh access grant
- Never: persistent service accounts with broad permissions

---

### Checklist Item 6: Dual-LLM for Untrusted Data Sources

Same as the dual-agent architecture above, applied specifically to MCP tools that ingest external data:
- MCP tool reads external data (email, web, database)
- Quarantined LLM (no tools) processes the data
- Privileged LLM receives only the processed result

**When required**: any MCP tool whose inputs can include content from outside the trusted boundary.

---

### Checklist Item 7: Centralized Tool Registry with Reputation Scoring

**Before adding a new MCP server to production**:
1. Run the server in a sandbox and log all network calls, file accesses, and subprocess spawns
2. Review against expected behavior
3. Assign a reputation score based on: publisher identity, code audit status, sandbox behavior
4. Only promote to production after score meets threshold

**Centralized registry**: track which MCP servers are in use, their versions, approval dates, and reputation scores. Enables fleet-wide response if a server is compromised post-approval.

---

## Cross-Reference

- **Why permission scope matters for each coordination pattern**: see D2 (coordination-and-state.md)
- **Tool loading that minimizes permission surface**: see D4 (tool-management.md)
- **Cost of security reviews vs. incident cost**: see D7 (cost-token-economics.md)
- **Detecting permission violations in production**: see D8 (observability.md)
- **Disasters this decision prevents**: see D10 (production-disasters.md), Incidents #1 (database wipe), #2 (MCP poisoning), #3 (email hijacking)
