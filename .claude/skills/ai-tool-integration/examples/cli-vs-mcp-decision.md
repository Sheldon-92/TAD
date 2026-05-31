---
name: cli-vs-mcp-decision
description: "Tests Inner/Outer-Loop CLI-vs-MCP rule + 10-32x token cost + read/write server separation + tool annotation hints"
pack: ai-tool-integration
tests_rules:
  - "Rule 1: Inner Loop = CLI, Outer Loop = MCP (loop test)"
  - "Rule 2: Read/Write Server Separation"
  - "10-32x token cost of MCP wrapping"
  - "Tool annotations: readOnlyHint / destructiveHint / idempotentHint"
min_marker_count: 3
---

# Fixture: CLI-vs-MCP Wrapping Decision

## Input Scenario

"We want to wrap our internal `git` and `curl` operations plus a destructive `delete_records` API as one MCP server so our agent can call them. Review the plan."

## Expected Markers

When an AI agent processes the Input Scenario with the ai-tool-integration pack loaded,
the output MUST contain these markers:

1. **Inner/Outer loop test with token cost** [structural]: the agent applies the loop test and quantifies MCP overhead, concluding git/curl (known from training) stay CLI rather than blindly wrapping everything
   grep pattern: `inner loop|outer loop|loop test|10.?32x|CLI.?first|already knows? (the tool|git)`
2. **Read/write server separation**: the destructive delete must NOT share a server/IAM role with read tools
   grep pattern: `[Rr]ead.?/?[Ww]rite separation|separate (MCP )?server|separate IAM|blast radius`
3. **Tool annotation hints**: the pack's specific annotation vocabulary driving approval behavior
   grep pattern: `readOnlyHint|destructiveHint|idempotentHint|human confirmation`
4. **Severity-tagged findings**: P0/P1 with rule codes (e.g. console.log in STDIO, enum schema)
   grep pattern: `\[P0\]|\[P1\]|Rule [MS][0-9]|enum constraint|STDIO`

## Verification Command

```bash
grep -oE 'inner loop|outer loop|loop test|10.?32x|CLI.?first|already knows the tool|read/write separation|separate server|separate IAM|blast radius|readOnlyHint|destructiveHint|idempotentHint|\[P0\]|\[P1\]|Rule [MS][0-9]|enum constraint' cli-vs-mcp-decision-output.md | sort -u | wc -l | tr -d ' '
# Expected: ≥ 3
```

## Anti-Slop Check

These markers are pack-specific (would NOT appear without the pack):
- ✅ "Inner/Outer Loop test + 10-32x token cost" (the pack's specific CLI-vs-MCP decision rule with the cost ratio)
- ✅ "Read/Write server separation + separate IAM / blast radius" (the pack's permission-isolation rule)
- ✅ "readOnlyHint / destructiveHint / idempotentHint" (the MCP annotation vocabulary the pack enforces)
- ❌ "build an MCP server" (restates the input — wrapping everything is the wrong default the pack corrects)
- ❌ "make it secure" (generic, non-discriminative)
- ❌ "use the API" (generic)
