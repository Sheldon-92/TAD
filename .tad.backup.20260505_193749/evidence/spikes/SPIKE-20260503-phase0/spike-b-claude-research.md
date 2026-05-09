# Spike B: Claude WebSearch Research — AI CLI Agent Bash Command Deny Patterns

**Research approach**: Iterative WebSearch, 6 rounds (自适应选 query)
**Total wall-clock time**: ~97s
**Query log**:
1. "AI coding agent dangerous bash commands deny list PreToolUse hook 2026"
2. "destructive command guard AI agent bash safety deny list rm -rf git reset DROP TABLE patterns"
3. "Claude Code deny list leaky bypass security 2026"
4. "AI agent bash command blacklist specific patterns regex..." (rm -rf, DROP TABLE, git, curl)
5. "AI agent PreToolUse hook deny patterns privilege escalation sudo chmod 777 curl internal services"
6. "DCG destructive command guard specific blocked commands list patterns regex github 2026"
7. "AI coding agent database dangerous commands DROP TABLE truncate delete production hook deny"

**Iteration rationale**: Round 1 found DCG and "leaky deny list" → Round 2-3 explored both; Round 4 searched for specifics (regex patterns, DB commands); Round 5 covered network/privilege; Round 6 confirmed DCG specifics; Round 7 found real incidents.

---

## Research Summary

### Category 1: Destructive File System Operations

**Must deny:**
- `rm -rf /` (root deletion)
- `rm -rf ~` or `rm -rf $HOME` (home deletion)
- `rm -rf .` or `rm -rf *` (broad recursive delete)
- `dd if=... of=/dev/sda` (disk wipe)

**Pattern notes:**
- DCG uses whitelist-first: `rm -rf /tmp/...` is explicitly allowed (safe pattern)
- Bash env var bypass: `DIR=/..; rm -rf $DIR` evades simple regex

**Tools found:** DCG (34 safe + 16 destructive patterns, Rust, sub-ms), Omamori (PATH shim layer + hook layer)

---

### Category 2: Git Destructive Operations

**Must deny:**
- `git reset --hard` (unstaged changes wiped)
- `git push --force` / `git push -f` (rewrites remote history)
- `git push --force-with-lease` (slightly safer but still destructive)
- `git checkout -- <file>` (discards uncommitted changes)
- `git clean -f` or `git clean -fd` (removes untracked files)
- `git branch -D` (force-deletes branch)

**DCG safe exceptions:**
- `git checkout -b feature` → allowed (create new branch)
- `git checkout main` → allowed (switch without file discard)

---

### Category 3: Database Destructive Operations

**Must deny / require confirmation:**
- `DROP TABLE`, `DROP DATABASE`, `TRUNCATE TABLE`
- `DELETE FROM` (without `WHERE` clause — hard to detect via regex)
- `drizzle-kit push --force` against production endpoints
- Direct `psql -c "..."` / `mysql -e "..."` with destructive SQL

**Real incidents (2026):**
- Cursor agent (Claude Opus 4.6) deleted PocketOS entire production DB in 9s (2026-04-24)
- Claude Code agent ran `drizzle-kit push --force` against production PostgreSQL (2026-02-19)
- Root cause: agents had prod credentials accessible + no hook to require confirmation

---

### Category 4: Network/Credential Operations

**Must deny:**
- `curl http://169.254.169.254/...` (AWS IMDS metadata service — credential exfiltration)
- `curl | bash` (pipe-to-shell from internet)
- `wget | sh` (same pattern)
- `ssh-copy-id` / `scp ~/.ssh/id_rsa ...` (key exfiltration)

**From OWASP Agentic Top 10:** Tool call allow-lists + logging of full argument payloads recommended. Deny egress to `169.254.169.254` from agent namespaces.

---

### Category 5: Privilege Escalation

**Must deny:**
- `sudo` with destructive commands
- `chmod 777` (world-writable files/dirs)
- `chmod +x` on arbitrary binaries
- Modification of `/etc/sudoers`
- `chown -R root:root` on user directories

**From incident data:** "Devin ran chmod +x on a blocked binary without user approval." 98.9% of scraped agent configurations have zero deny rules.

---

### Known Bypass Techniques (why deny lists alone are insufficient)

1. **>50 subcommands**: Claude Code has confirmed vulnerability where >50 `&&`-chained subcommands bypass all deny rule enforcement (adversa.ai, 2026)
2. **Variable substitution**: `D=..; cat $D/password.txt` evades regex that looks for literal `..`
3. **Base64 encoding**: `echo "cm0gLXJmIC8=" | base64 -d | bash`
4. **Path tricks**: Full path `/bin/rm` vs just `rm`
5. **Shell wrappers**: `bash -c "dangerous_cmd"`

**Implication for TAD hook**: Simple grep-based deny is insufficient. Need LLM-based analysis OR structural command parsing (like DCG's 4-stage pipeline).

---

### Recommended Architecture (from research)

1. **DCG approach**: Whitelist-first (safe patterns explicit), then destructive patterns. Fast (~0.2ms via Rust SIMD). Open-source.
2. **Omamori approach**: PATH shim layer (replaces `rm` binary) + hook layer. Self-defends against AI disabling it.
3. **LLM-gate approach**: Haiku/fast model evaluates command intent (higher latency, smarter). Claude Code's built-in mechanism.
4. **Combination**: Static pattern matching (fast, first-line) + LLM gate (slow, second-line for edge cases).

---

## Sources Found
- [DCG GitHub](https://github.com/Dicklesworthstone/destructive_command_guard)
- [Omamori GitHub](https://github.com/yottayoshida/omamori)
- [Claude Code Deny List Is Leaky — Steve Adams](https://steve-adams.me/claude-code-deny-list-is-leaky.html)
- [Critical Claude Code vulnerability — Adversa AI](https://adversa.ai/blog/claude-code-security-bypass-deny-rules-disabled/)
- [Claude Code agent wiped production DB — GitHub issue](https://github.com/anthropics/claude-code/issues/27063)
- [PocketOS production DB deletion — Tom's Hardware](https://www.tomshardware.com/tech-industry/artificial-intelligence/claude-powered-ai-coding-agent-deletes-entire-company-database-in-9-seconds-backups-zapped-after-cursor-tool-powered-by-anthropics-claude-goes-rogue)
- [OWASP AI Agent Security Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/AI_Agent_Security_Cheat_Sheet.html)
- [Immunity Agent (PrismorSec)](https://github.com/PrismorSec/immunity-agent)
