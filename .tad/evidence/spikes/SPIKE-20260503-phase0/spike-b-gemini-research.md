# Spike B: Gemini Research — AI CLI Agent Bash Command Deny Patterns

**Model**: Gemini CLI v0.39.1 (ChatGPT-account quota, one retry — "capacity exhausted, reset after 2s")
**Invocation**: `gemini -p "Research the best practices..."`
**Wall-clock time**: 61s (including 5s retry backoff)
**Note**: One transient quota error with automatic retry. `-p` flag required (non-TTY context per architecture.md lesson).

---

## Restricting Bash Commands in AI Coding Agents: Best Practices

Restricting bash commands in AI coding agents is a critical security layer often implemented via **PreToolUse hooks**. These hooks intercept the agent's intent before execution to validate, prompt, or deny dangerous operations.

### 1. Destructive File Operations

| Command Pattern | Risk | Regex Example |
| :--- | :--- | :--- |
| **Recursive Root Deletion** | Deletion of the entire filesystem or home directory | `\brm\s+-[rf]*[rf]\s+(/|\$HOME|~|/\*)\b` |
| **Recursive Deletion** | Potential for massive data loss in the workspace | `\brm\s+-[rf]*[rf]\s+` |
| **Find & Delete** | Using `find` to silently wipe files matching criteria | `\bfind\b.*\b-delete\b` |
| **Move to Null** | "Deleting" files by moving them to `/dev/null` | `\bmv\b.*\b/dev/null\b` |

### 2. Database Operations

| Command Pattern | Risk | Regex Example |
| :--- | :--- | :--- |
| **Drop/Truncate** | Deletion of tables, databases, or entire schemas | `\b(psql\|mysql\|sqlite3)\b.*\b(DROP\|TRUNCATE\|DELETE)\b` |
| **Schema Mutation** | Destructive changes to database structure | `\b(psql\|mysql)\b.*\bALTER\s+TABLE\s+.*\bDROP\b` |
| **Bulk Data Wipe** | Unfiltered deletion of records (no WHERE clause) | `\bDELETE\s+FROM\s+\w+\b(?!.*\bWHERE\b)` |

### 3. Network Operations

| Command Pattern | Risk | Regex Example |
| :--- | :--- | :--- |
| **Internal Discovery** | Targeting internal metadata or private IPs | `\b(curl\|wget)\b.*(169\.254\.169\.254\|10\.\|192\.168\.\|172\.)` |
| **Data Exfiltration** | Posting sensitive files to external endpoints | `\b(curl\|wget)\b.*\b-F\b.*\b@` |
| **Pipe to Shell** | Downloading and executing arbitrary scripts | `(curl\|wget).*\b\|\s*(ba)?sh\b` |
| **Reverse Shells** | Opening a TCP connection for remote control | `\b/dev/tcp/[0-9.]+/` |

### 4. Privilege Escalation

| Command Pattern | Risk | Regex Example |
| :--- | :--- | :--- |
| **Sudo Execution** | Running commands with root privileges | `\bsudo\s+` |
| **Global Permissions** | World-writable/executable bits (777, 666) | `\bchmod\b.*\b(777\|666)\b` |
| **Setuid/Setgid** | Binaries that run with owner privileges | `\bchmod\b.*\b[u\|g]\+s\b` |
| **Ownership Hijack** | Changing file owners to root | `\bchown\b.*\broot\b` |

### 5. Git Destructive Operations

| Command Pattern | Risk | Regex Example |
| :--- | :--- | :--- |
| **Force Push** | Overwriting remote history | `\bgit\s+push\b.*(--force\|-f\|--force-with-lease)\b` |
| **Hard Reset** | Wiping uncommitted work | `\bgit\s+reset\b.*--hard\b` |
| **Clean Wipe** | Deleting untracked files | `\bgit\s+clean\b.*-f[d]*\b` |
| **Branch Deletion** | Deleting remote/local branches | `\bgit\s+branch\b.*(-D\|-d)\b` |

### 6. Framework Comparison (Claude Code vs Codex CLI)

| Feature | Claude Code | Codex CLI |
| :--- | :--- | :--- |
| **Default Policy** | Prompt-first (file writes, installs require approval) | Prefix-based (rules match command prefixes) |
| **Read-Only List** | Hardcoded list (`ls`, `grep`, `cat`) auto-allowed | Configurable `allow` rules via Starlark DSL |
| **Sandboxing** | OS-native (Seatbelt/macOS, bubblewrap/Linux) | Container-expected (Docker/gVisor) |
| **Compound Commands** | Splits `&&`, `\|\|`, `;` for individual validation | Splits and validates; one fail blocks chain |
| **Network Control** | Blocks all outbound except `allowedDomains` | Host/container network configuration |

### 7. Strategic Recommendations

1. **Whitelisting over Blacklisting**: Blacklists bypass via obfuscation (`r"m" -rf`). Prefer allowlist + HITL for everything else.
2. **Use `shlex.split()`**: Parse command into argument list before regex. Prevents shell quote/escape bypasses.
3. **Detect Obfuscation**: Flag hex/octal escapes (`\x41`), base64 decoding (`base64 -d`), dynamic eval (`eval`, `xargs`).
4. **Environment Isolation**: Regex is a "speed bump." True security = disposable sandbox (Docker, Firecracker) with ephemeral filesystem.
5. **Audit Logs**: Store raw command, expanded command, agent justification in immutable log.

---

## Sources Cited by Gemini
- Anthropic: Claude Code Security (docs.anthropic.com)
- Trail of Bits: Securing LLM Tools (trailofbits.com/reports/llm-agent-security.pdf)
- OWASP: Top 10 for LLM Applications — L05 Insecure Output Handling (genai.owasp.org)

*Note: Gemini-cited source URLs not independently verified — may be hallucinated or paraphrased paths.*
