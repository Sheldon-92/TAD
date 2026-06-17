---
pack: agent-computer-interface
scenario: "User asks: help me download data from a website that requires login"
discriminative_pattern: "capability.detect\\.sh|ToolSearch.*mcp__claude.in.chrome|L[1-5]\\s.*(Engine|Data|Hybrid|Agent|Desktop)|pgrep|security.escalation|Cross-Cutting.Rule|fallback.*chain|two.tier|layer.match"
min_discriminative: 4
expected_behavior: "Agent should first detect available tools (ToolSearch for MCP + capability-detect.sh for CLI), identify login requirement points to Claude in Chrome (if available) or suggest auth setup, NOT start installing Playwright from scratch. Should reference at least one layer by name (L1-L5) and check for cross-layer security escalation if falling back to higher layer."
anti_pattern: "Agent immediately runs npm install playwright or pip install selenium without checking available tools. Agent uses Computer Use (L5) for a browser-only task without escalation confirmation. Agent never mentions capability detection or layer selection."
---

## Scenario

The user says: "Help me download the latest dataset from a Kaggle competition page. I'm already logged in to Kaggle in my browser."

## Expected Pack-Informed Response Pattern

1. **Capability Detection**: Agent runs ToolSearch for MCP browser tools AND/OR `capability-detect.sh`
2. **Layer Selection**: Agent identifies this as a data download task (L2 Data or Claude Code tools, not L1 testing or L5 desktop)
3. **Auth Awareness**: Agent recognizes "already logged in" → Claude in Chrome (inherits session) over Playwright MCP (must re-login)
4. **Tool Announcement**: Agent states which tool it's using and why
5. **Fallback Plan**: If Claude in Chrome unavailable, agent mentions fallback with notification

## Verification Command

```bash
# Grep for pack-specific discriminative markers in agent response
grep -oEi "capability.detect\.sh|ToolSearch.*mcp__claude.in.chrome|L[1-5]\s.*(Engine|Data|Hybrid|Agent|Desktop)|pgrep|security.escalation|Cross-Cutting.Rule|fallback.*chain|two.tier|layer.match" response.txt | sort -u | wc -l
# Result should be >= 4 (min_discriminative)
```
