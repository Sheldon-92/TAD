# Tool & Permission Model Rules
<!-- capability: tool_permissions -->

## Quick Rule Index

| # | Rule | determinismLevel |
|---|------|-----------------|
| TP1 | Claude Agent SDK: 3 permission layers (allowedTools / disallowedTools / permissionMode) — evaluate in order | deterministic |
| TP2 | A tool allowlist WITHOUT an explicit permissionMode lets the mode decide unmatched tools — use `dontAsk` for a locked-down boundary, never `acceptEdits` as "restrictive" | deterministic |
| TP3 | Subagents: add `"Agent"` to allowedTools; trace nesting via `parent_tool_use_id` | deterministic |
| TP4 | Lifecycle hooks: PreToolUse / PostToolUse / Stop / SessionStart / SessionEnd / UserPromptSubmit for audit | deterministic |
| TP5 | OpenAI Agents SDK: 5 tool categories — agents-as-tools ≠ handoff | deterministic |
| TP6 | OpenAI Agents SDK tool timeouts: `error_as_result` (default, recoverable) vs `raise_exception` (terminates run) | deterministic |

---

## Rules

### TP1: Claude Agent SDK — Three Permission Layers

Tool execution permissions are managed via `ClaudeAgentOptions`. Proposed tool calls are evaluated against three distinct layers:

1. **Allowed Tools** (`allowedTools` / `allowed_tools`) — auto-approval allowlist; listed tools execute without prompting.
2. **Disallowed Tools** (`disallowedTools` / `disallowed_tools`) — blocklist; listed tools are completely blocked from execution.
3. **Permission Mode** (`permissionMode` / `permission_mode`) — fallback behavior for tools not on the allowlist. E.g. `'dontAsk'` denies anything outside the allowlist (locked-down boundary); `'acceptEdits'` auto-approves file edits AND basic filesystem operations (not a restrictive choice for write-capable agents).

**Rule**: Design all three layers together. The mode is the fallback that governs everything not explicitly allow/disallow-listed.

> Source: findings.md "Claude Agent SDK" permission evaluation [12]

**determinismLevel**: deterministic — the policy is a fixed configuration.

### TP2: An Allowlist Without an Explicit Mode Lets the Mode Decide

`allowedTools` only governs auto-approval; a tool NOT on the allowlist does not get blocked by its absence — it falls through to whatever `permissionMode` is in effect. The default mode does not silently auto-run unmatched commands (it routes them to the `canUseTool`/approval path), but leaving the mode unset invites config drift toward a permissive mode (`acceptEdits`, `bypassPermissions`) where non-allowlisted file/shell operations run unprompted.

**Rule**: Never ship an allowlist without an explicit `permissionMode`. For an allowlist-as-boundary (locked-down agent), use `permissionMode: 'dontAsk'` so anything outside the allowlist is denied outright rather than prompted. Do NOT use `'acceptEdits'` as the "restrictive" choice — it auto-approves file edits AND basic filesystem operations (including `rm`/`mv`), so it is only appropriate when filesystem mutation is intentionally trusted. Never use `'bypassPermissions'`.

> Source: findings.md "Claude Agent SDK" — three-layer evaluation [12]; Claude Agent SDK permissions docs (`dontAsk` for locked-down allowlists; `acceptEdits` approves file ops) (retrieved 2026-06-01)

**determinismLevel**: deterministic.

### TP3: Subagent Spawning and Nested Traceability

For complex tasks, a parent agent spawns subagents by adding `"Agent"` to its `allowedTools` list, then invoking subagents via the built-in `Agent` tool with specialized instructions.

- For debugging across nested hierarchies, every execution message generated inside a subagent context includes a `parent_tool_use_id` field, letting logging systems map the nested execution graph back to the parent coordinator.

**Rule**: Grant the `Agent` tool only when delegation is required, and rely on `parent_tool_use_id` to reconstruct the nested execution graph in logs — do not flatten subagent traces.

> Source: findings.md "Claude Agent SDK" subagent spawning [10]

**determinismLevel**: deterministic.

### TP4: Lifecycle Hooks for Audit and Control

Hook into the agent lifecycle by registering callbacks. Available hooks: `PreToolUse`, `PostToolUse`, `Stop`, `SessionStart`, `SessionEnd`, `UserPromptSubmit`.

- Example: register a `PostToolUse` callback to write file-modification details to an external audit file (`./audit.log`) whenever the model invokes `Edit` or `Write`.

**Rule**: Use `PreToolUse` for gating/validation and `PostToolUse` for audit trails on side-effecting tools (`Edit`/`Write`/`Bash`). An agent that writes files with no `PostToolUse` audit hook has no audit record at all. Note that a `PostToolUse` hook writing a local `./audit.log` is NOT tamper-evident — the same agent/process can edit or delete it; for tamper evidence use append-only/write-once external storage, signed entries, or off-host log shipping.

> Source: findings.md "Claude Agent SDK" lifecycle hooks [10]

**determinismLevel**: deterministic.

### TP5: OpenAI Agents SDK — Five Tool Categories (Agents-as-Tools ≠ Handoff)

The OpenAI Agents SDK provides five primary tool categories:

1. **Hosted OpenAI Tools** — code interpreter, file search, web search running on OpenAI servers.
2. **Local/Runtime Execution Tools** — `ComputerTool` and `ApplyPatchTool` (local runtime), `ShellTool` (local or hosted container).
3. **Function Calling** — Python functions wrapped dynamically as tools.
4. **Agents as Tools** — exposing a specialist agent as a callable function **without executing a full handoff**.
5. **Hosted MCP Tools** — connecting to remote Model Context Protocol servers.

Tool outputs are structured: `ToolOutputImage`, `ToolOutputFileContent`, `ToolOutputText` (or stringable types).

**Rule**: Distinguish **Agents-as-Tools** (call a specialist and get a value back, control returns to caller) from a **handoff** (transfer the active execution pointer). Use agents-as-tools when the caller must retain control; use handoff to delegate the rest of the conversation.

> Source: findings.md "OpenAI Agents SDK" five tool categories + output types [21]

**determinismLevel**: deterministic — the categorization is fixed.

### TP6: OpenAI Agents SDK Tool Timeout Behavior

Configure tool execution timeouts via `timeout_behavior`:

- `"error_as_result"` (**the default**) — catches the timeout and returns a recoverable error message to the model, so the run continues.
- `"raise_exception"` — triggers a `ToolTimeoutError` and **terminates the run**.

**Rule**: Keep `error_as_result` for tools the agent can route around; use `raise_exception` only when a tool timeout means the whole run is invalid and should hard-stop.

> Source: findings.md "OpenAI Agents SDK" timeout_behavior [21]

**determinismLevel**: deterministic.

---

## Anti-Patterns

- **Allowlist with no explicit mode**: non-allowlisted tools fall through to whatever `permissionMode` is set; an unset mode invites drift to a permissive mode. Set `dontAsk` for a locked-down boundary (TP2).
- **Granting `Agent` by default**: subagent spawning should be deliberate; ungated delegation multiplies tool surface.
- **Flattened subagent logs**: dropping `parent_tool_use_id` makes nested failures undebuggable.
- **No PostToolUse audit on writes**: side-effecting tools with no audit hook leave no record. (And a local `./audit.log` alone is not tamper-evident — use append-only/external storage for that.)
- **Confusing agents-as-tools with handoff**: a handoff transfers control; agents-as-tools returns a value. Picking the wrong one changes who owns the conversation.
- **`raise_exception` everywhere**: a single recoverable tool timeout should not always kill the whole run — default to `error_as_result`.
