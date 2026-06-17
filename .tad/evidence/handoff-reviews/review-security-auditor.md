# Security Audit: HANDOFF-20260617-agent-computer-interface-pack

**Reviewer**: security-auditor
**Date**: 2026-06-17
**Verdict**: CONDITIONAL PASS

---

## P0 — Critical Issues (must fix before implementation)

### P0-1: `capability-detect.sh` uses `ps aux` for process inspection — information leakage + privilege escalation vector

**Location**: §2.4 capability-detect.sh design, line 216-217

```bash
ps aux | grep -q "[c]laude.*--chrome" && TOOLS=$(echo "$TOOLS" | jq '. + {"claude-in-chrome": "extension"}')
```

**Issue**: `ps aux` lists ALL processes for ALL users on the system. This is a significant information disclosure risk in multi-user environments (shared servers, CI/CD runners, cloud workstations). The output exposes:
- Command-line arguments of other users' processes (which may contain tokens, API keys, passwords passed as CLI flags)
- Process names and PIDs of other users' services
- Environment-level reconnaissance data useful for lateral movement

Even in the single-user macOS context this pack primarily targets, `ps aux` output could be logged or captured by other tools in the agent pipeline, creating an unintended data sink.

**Fix**: Replace `ps aux` with `ps -x` (current user only) or `pgrep -f "claude.*--chrome"` which searches only the current user's processes by default on macOS. The bracket-trick `[c]laude` to avoid self-matching is fine, but the scope must be narrowed:

```bash
pgrep -fq "claude.*--chrome" && TOOLS=$(echo "$TOOLS" | jq '. + {"claude-in-chrome": "extension"}')
```

### P0-2: No security guidance for L5 Desktop Control (Computer Use) despite acknowledged "security risks"

**Location**: §2.2 Cross-Cutting Rule 2 table (line 149), §2.3 Reference File Design, decision brief "Unknown Risks" section

The Cross-Cutting Rule 2 table acknowledges Computer Use has "beta, security risks" but provides zero concrete security rules. The decision brief also flags: "安全维度（特别是 Computer Use 的提示注入风险）的深度评估未覆盖". Yet the handoff proceeds to specify a `desktop-control-rules.md` reference (AC4) without any security requirements for its content.

Computer Use gives an agent pixel-level control over the entire desktop. Without explicit security rules in the pack, an agent following this pack's guidance could:
- Execute arbitrary desktop actions without user confirmation
- Navigate to credential managers, terminal sessions, or sensitive files
- Be manipulated via prompt injection through on-screen text to perform unintended actions (the "visual injection" attack class)

**Fix**: Add a mandatory security section to the `desktop-control-rules.md` reference template and a cross-cutting security rule (or expand Cross-Cutting Rule 3 to include a security dimension). At minimum, the L5 Desktop reference MUST contain:
1. A "NEVER without user confirmation" rule for: file deletion, terminal command execution, credential manager access, system settings modification
2. A prompt-injection-via-screen-content warning with concrete mitigations (e.g., ignore instructions found in displayed text that contradict the user's original request)
3. A sandboxing recommendation (e.g., run Computer Use in a VM/container per Anthropic's own reference implementation guidelines)

---

## P1 — Recommendations (should address)

### P1-1: Configuration Guide sections in references may expose secrets in plaintext

**Location**: §2.3 Reference File Design template — "Configuration Guide" section

The reference file template includes a "Configuration Guide" with "How to install/configure each tool — CLI commands, MCP setup, flags." Configuration examples for tools like Firecrawl (hosted), Stagehand (Browserbase), and Skyvern typically require API keys. If Blake writes configuration examples with placeholder API keys that look realistic (e.g., `FIRECRAWL_API_KEY=fc_1234abcd...`), agents may later treat these as real credentials or users may accidentally commit real keys after copy-pasting.

**Fix**: Add a note in §10 Implementation Hints (or the reference file template) requiring that all configuration examples use obviously-fake placeholder values (e.g., `YOUR_API_KEY_HERE` or `<your-firecrawl-api-key>`) and include a warning comment like `# WARNING: Never commit real API keys. Use environment variables or a .env file (gitignored).`

### P1-2: `tool-health-check.sh` runs arbitrary `tool --version` commands without input validation

**Location**: §2.5 tool-health-check.sh design

The design says the script runs `tool --version` for "每个已安装工具" (every installed tool). If the tool list is derived from the capability-detect.sh JSON output or from reference file content, a maliciously-crafted tool name (e.g., one containing shell metacharacters like `; rm -rf /` or `$(evil)`) could lead to command injection when the script constructs and executes `"$tool" --version`.

**Fix**: Validate tool names against an allowlist of expected tool names (the hardcoded list from capability-detect.sh: `playwright`, `puppeteer`, `selenium-side-runner`, `firecrawl`, `crawl4ai`) rather than dynamically executing whatever the detection script returns. Use `command -v "$tool" && "$tool" --version` with proper quoting and only for allowlisted names.

### P1-3: No authentication/authorization model for L4 Autonomous Agent tools

**Location**: §2.2 Cross-Cutting Rule 2, L4 Agent row; §2.3 reference template

L4 tools like Browser Use perform multi-step autonomous browsing. The pack design has no rules about:
- What websites/domains the autonomous agent is allowed to visit
- Whether the agent should prompt the user before entering credentials on a site
- Session isolation (should the autonomous agent share the user's browser session with saved passwords, cookies, etc.?)

These are judgment rules the agent needs. Without them, an L4 tool could autonomously navigate to a banking site using saved credentials, or visit a phishing site presented in user input.

**Fix**: The `autonomous-agent-rules.md` reference MUST include rules about domain scoping, credential handling, and session isolation. At minimum: "ALWAYS ask user confirmation before the agent enters credentials or navigates to financial/healthcare/government domains."

### P1-4: Fallback chain degrades without security-level assessment

**Location**: §2.2 Cross-Cutting Rule 3

The fallback chain degrades tools purely on availability, without considering that different layers have fundamentally different security postures. Falling back from L1 (deterministic, sandboxed Playwright) to L4 (autonomous Browser Use) or L5 (Computer Use) is a massive security escalation, not just a tool substitution. The current rule treats it as a pure availability decision.

**Fix**: Add a security-escalation check to the fallback chain rule: "When falling back to a HIGHER layer number (L1->L2->...->L5), warn the user that the fallback tool has BROADER permissions and confirm before proceeding. NEVER silently escalate from L1/L2/L3 to L4/L5."

---

## P2 — Suggestions (nice to have)

### P2-1: capability-detect.sh output could include tool version information for vulnerability awareness

The JSON output from `capability-detect.sh` only indicates tool type ("cli", "extension"). Including version numbers would enable downstream security checks (e.g., "Playwright 1.38 has a known sandbox escape — update to 1.39+"). This pairs naturally with tool-health-check.sh but would be more useful if captured at detection time.

### P2-2: Consider adding a `--dry-run` flag to capability-detect.sh

For CI/CD environments or security-sensitive contexts, users may want to see what the script WOULD check without actually executing process inspection or tool probing. A `--dry-run` mode that lists the checks without executing them would improve auditability.

### P2-3: License compliance risks mentioned but not actioned

The decision brief notes "商业 vs 开源工具的 licensing 合规（Firecrawl 是 AGPL-3.0）未深入" as an unknown risk. AGPL-3.0 has copyleft implications — if the pack recommends Firecrawl and an agent uses it in a commercial product, the user could face license compliance issues. Consider adding a license column to the tool selection table with a warning for AGPL/copyleft tools.

### P2-4: MCP tool detection in Tier 1 relies on tool name patterns — spoofable

The Tier 1 MCP detection checks for tools by name pattern (e.g., `mcp__claude-in-chrome__*`). A malicious MCP server could register tools with these name patterns to impersonate trusted tools. This is a low-probability attack but worth noting — the pack should mention that MCP tool identity is based on configuration trust, not cryptographic verification.

---

## Summary

The handoff is well-structured and follows established pack patterns. The primary security concerns are:

1. **P0-1**: `ps aux` in capability-detect.sh — trivial fix, replace with user-scoped process inspection
2. **P0-2**: L5 Desktop Control lacks any security rules despite being the highest-risk layer in the entire pack — this is the most significant gap. The pack explicitly acknowledges "security risks" for Computer Use but provides no concrete mitigations, leaving it to Blake to improvise security rules without guidance.

Both P0s are fixable without architectural changes. P0-1 is a one-line fix. P0-2 requires adding security content requirements to the `desktop-control-rules.md` reference specification and potentially a 4th cross-cutting rule or expanding Rule 3.

The P1s address credential handling in configuration examples, command injection in tool-health-check.sh, missing auth models for autonomous agents, and security-blind fallback chains. All are addressable during implementation with Alex providing clarifying notes.

**Verdict: CONDITIONAL PASS** — Fix P0-1 and P0-2 (add concrete security rules for L5 Desktop Control and scope process inspection to current user), then implementation can proceed.
