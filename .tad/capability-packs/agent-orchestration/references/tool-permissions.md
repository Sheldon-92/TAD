# Tool & Permission Model Rules
<!-- capability: tool_permissions -->

## Quick Rule Index

| # | Rule | determinismLevel |
|---|------|-----------------|
| TP1 | Claude Agent SDK: 3 permission layers (allowedTools / disallowedTools / permissionMode) — evaluate in order | deterministic |
| TP2 | A tool allowlist WITHOUT a permissionMode fallback is an arbitrary-command hole | deterministic |
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
3. **Permission Mode** (`permissionMode` / `permission_mode`) — fallback behavior for tools not on the allowlist. E.g. `'acceptEdits'` auto-approves filesystem changes but still prompts for arbitrary shell commands.

**Rule**: Design all three layers together. The mode is the fallback that governs everything not explicitly allow/disallow-listed.

> Source: findings.md "Claude Agent SDK" permission evaluation [12]

**determinismLevel**: deterministic — the policy is a fixed configuration.

### TP2: An Allowlist Without a Mode Fallback Is a Hole

If you set `allowedTools` (e.g. `Bash`, `Edit`) but leave the `permissionMode` fallback unconsidered, any tool not on the allowlist falls through to whatever the default mode permits — potentially auto-running arbitrary commands.

**Rule**: Never ship an allowlist without an explicit `permissionMode`. Use a restrictive mode like `'acceptEdits'` (auto-approve file edits, prompt for shell) so non-allowlisted high-risk tools are gated, not silently permitted.

> Source: findings.md "Claude Agent SDK" — three-layer evaluation + `acceptEdits` example [12]

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

**Rule**: Use `PreToolUse` for gating/validation and `PostToolUse` for audit trails on side-effecting tools (`Edit`/`Write`/`Bash`). An agent that writes files with no `PostToolUse` audit hook has no tamper-evident record.

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

- **Allowlist with no mode**: non-allowlisted tools fall through to a permissive default — an arbitrary-command hole (TP2).
- **Granting `Agent` by default**: subagent spawning should be deliberate; ungated delegation multiplies tool surface.
- **Flattened subagent logs**: dropping `parent_tool_use_id` makes nested failures undebuggable.
- **No PostToolUse audit on writes**: side-effecting tools with no audit hook leave no record.
- **Confusing agents-as-tools with handoff**: a handoff transfers control; agents-as-tools returns a value. Picking the wrong one changes who owns the conversation.
- **`raise_exception` everywhere**: a single recoverable tool timeout should not always kill the whole run — default to `error_as_result`.
