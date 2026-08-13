---
name: cli-vs-mcp-decision
description: "Tests Inner/Outer-Loop CLI-vs-MCP rule + measured token cost (98.7% / 17x) + read/write server separation + tool annotation hints + tool-poisoning awareness"
pack: ai-tool-integration
tests_rules:
  - "Rule 1: Inner Loop = CLI, Outer Loop = MCP (loop test)"
  - "Rule 2: Read/Write Server Separation"
  - "Measured token cost: 150K->2K (98.7%) code-exec vs MCP; 17x more tokens/call"
  - "Tool annotations: readOnlyHint / destructiveHint / idempotentHint (untrusted unless trusted server)"
  - "Tool poisoning / rug-pull on a 3rd-party server (CVE-2025-54136)"
min_marker_count: 3
# DISCRIMINATIVE gate: ONLY pack-specific markers. Excludes generic "idempotent" (bare),
# "build an MCP server", "use the API". Inner/Outer Loop test, the measured 98.7%/17x cost
# figures, the camelCase MCP annotation Hints, and the tool-poisoning/MCPoison terms are
# pack-introduced markers a no-pack agent does not name.
discriminative_pattern: "Inner Loop|Outer Loop|98\\.7%|17x|readOnlyHint|destructiveHint|idempotentHint|tool poisoning|rug.?pull|MCPoison|registerTool"
min_discriminative: 3
---

# Fixture: CLI-vs-MCP Wrapping Decision

## Input Scenario

"We want to wrap our internal `git` and `curl` operations plus a destructive `delete_records` API, plus a third-party `analytics` MCP server we found online, as one MCP server so our agent can call them. The tutorial we copied uses `server.tool(name, desc, schema, handler)`. Review the plan."

## Expected Markers

When an AI agent processes the Input Scenario with the ai-tool-integration pack loaded,
the output MUST contain these markers:

1. **Inner/Outer loop test with measured token cost** [structural]: the agent applies the loop test and quantifies MCP overhead with the measured figures (98.7% / 17x), concluding git/curl (known from training) stay CLI rather than blindly wrapping everything
   grep pattern: `inner loop|outer loop|loop test|98\.7%|17x|CLI.?first|already knows? (the tool|git)`
2. **Read/write server separation**: the destructive delete must NOT share a server/IAM role with read tools
   grep pattern: `[Rr]ead.?/?[Ww]rite separation|separate (MCP )?server|separate IAM|blast radius`
3. **Tool annotation hints (and that they are untrusted)**: the pack's specific annotation vocabulary driving approval behavior, plus the untrusted-unless-trusted-server caveat
   grep pattern: `readOnlyHint|destructiveHint|idempotentHint|human confirmation|untrusted`
4. **Tool poisoning / rug-pull on the 3rd-party server**: the agent flags the untrusted analytics MCP server's definitions as a supply-chain risk and recommends pin+hash + re-verify
   grep pattern: `tool poisoning|rug.?pull|MCPoison|CVE-2025-5413|pin.?(\+|and)?.?hash|untrusted (input|server)`
5. **Deprecated API + severity-tagged findings**: flags the deprecated 4-arg `server.tool` -> `registerTool`, with P0/P1 rule codes
   grep pattern: `\[P0\]|\[P1\]|Rule [MSPX][0-9]|registerTool|deprecated|enum constraint|STDIO`

## Verification Command

```bash
grep -oE 'inner loop|outer loop|loop test|98\.7%|17x|CLI.?first|already knows the tool|read/write separation|separate server|separate IAM|blast radius|readOnlyHint|destructiveHint|idempotentHint|untrusted|tool poisoning|rug.?pull|MCPoison|pin.?(\+|and)?.?hash|registerTool|deprecated|\[P0\]|\[P1\]|Rule [MSPX][0-9]|enum constraint' cli-vs-mcp-decision-output.md | sort -u | wc -l | tr -d ' '
# Expected: ≥ 3
```

## Anti-Slop Check

These markers are pack-specific (would NOT appear without the pack):
- ✅ "Inner/Outer Loop test + measured 98.7% / 17x token cost" (the pack's CLI-vs-MCP decision rule with the sourced figures)
- ✅ "Read/Write server separation + separate IAM / blast radius" (the pack's permission-isolation rule)
- ✅ "readOnlyHint / destructiveHint / idempotentHint + untrusted-unless-trusted-server" (the MCP annotation vocabulary the pack enforces, with the spec caveat)
- ✅ "Tool poisoning / rug-pull / MCPoison / pin+hash" (the pack's supply-chain anti-pattern, X7)
- ✅ "registerTool vs deprecated 4-arg server.tool" (the current SDK v1.29.0 API the pack corrects to)
- ❌ "build an MCP server" (restates the input — wrapping everything is the wrong default the pack corrects)
- ❌ "make it secure" (generic, non-discriminative)
- ❌ "use the API" (generic)
