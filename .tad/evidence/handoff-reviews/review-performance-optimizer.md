# Performance Optimizer Review: HANDOFF-20260617-agent-computer-interface-pack

**Reviewer**: performance-optimizer
**Date**: 2026-06-17
**Handoff**: `.tad/active/handoffs/HANDOFF-20260617-agent-computer-interface-pack.md`
**Scope**: Performance bottlenecks, regex/ReDoS risk, cost estimates, caching strategies, script efficiency

---

## Critical Issues (P0 -- must fix before implementation)

None identified.

---

## Recommendations (P1 -- should address)

### P1-1: capability-detect.sh repeatedly spawns jq subprocesses in a loop -- O(N) process forks

**Location**: Handoff section 2.4, lines 210-213

The design shows:
```bash
for tool in playwright puppeteer selenium-side-runner firecrawl crawl4ai; do
  command -v "$tool" >/dev/null 2>&1 && TOOLS=$(echo "$TOOLS" | jq --arg t "$tool" '. + {($t): "cli"}')
done
```

Each iteration: (1) echo to pipe, (2) spawn jq, (3) capture output via `$()`. For 5 tools this is 5 x 3 = 15 subprocess forks. This is functionally correct but wasteful. More importantly, the pattern invites future maintainers to add tools (the list will likely grow to 10-15 as the landscape expands), linearly growing subprocess count.

**Recommendation**: Build the JSON in a single pass. Either:
- Accumulate results as shell variables and emit one `jq -n` at the end: `jq -n --arg a "$a" --arg b "$b" '{($a): "cli", ($b): "cli"}'`
- Use a bash associative array, then serialize once
- Or simply build a comma-separated string and wrap it: `echo "{$CSV}" | jq .`

This keeps the script O(1) in jq invocations regardless of how many tools are added.

### P1-2: `ps aux | grep` for extension detection is expensive and fragile

**Location**: Handoff section 2.4, line 217

```bash
ps aux | grep -q "[c]laude.*--chrome"
```

`ps aux` enumerates ALL system processes (potentially hundreds/thousands) and pipes the entire output through grep. On a machine running many processes this is non-trivial I/O. Additionally:

- The regex `[c]laude.*--chrome` is a greedy `.*` match across the full command line. While not a ReDoS risk (grep uses DFA-based matching, not backtracking), it can false-match on unrelated processes containing both substrings.
- `ps aux` output varies by platform (macOS vs Linux column widths differ), making the match position-dependent.

**Recommendation**: Use `pgrep -f 'claude.*--chrome'` which is purpose-built, faster (no full `ps aux` formatting overhead), and portable. Add a comment explaining the detection is best-effort and may miss non-standard invocations.

### P1-3: Token cost claims lack consistent units and some are inconsistent across sections

**Location**: Handoff section 2.2 (Cross-Cutting Rule 3) vs section 2.8 research brief

The handoff states:
- "Playwright CLI uses 4x fewer tokens than MCP mode" (section 2.2, line 152)
- "Playwright MCP loads ~13.6k tokens of tool definitions" (section 2.2, line 152)
- "Claude in Chrome uses ~10k tokens/page" (section 2.2, line 152)

But the research brief (decision-brief.md line 28) states:
- Playwright MCP: "2-5KB snapshots (20-50x cheaper than screenshots)"
- Claude in Chrome: "~10k/page"

The "2-5KB" figure in the research brief refers to page snapshot SIZE, while the "~13.6k token" figure refers to tool DEFINITION loading cost. These are different cost categories (per-invocation data vs one-time schema load). The handoff Cross-Cutting Rule 3 conflates them into a single "token cost" narrative without distinguishing the two cost types.

**Recommendation**: In the reference files and SKILL.md, clearly separate:
1. **One-time schema/context tax** (tool definitions loaded at session start): Playwright MCP ~13.6k tokens
2. **Per-page data cost** (each page interaction): Claude in Chrome ~10k tokens/page, Playwright MCP 2-5KB/snapshot
3. **Per-test session total** (full workflow): Playwright MCP ~114k vs CLI ~27k

This prevents the agent from making incorrect cost comparisons.

### P1-4: tool-health-check.sh 90-day staleness threshold is arbitrary with no caching

**Location**: Handoff section 2.5, lines 224-226

The design says: "check each reference's `last_verified` date, if > 90 days output WARNING. For each installed tool run a simple version check (`tool --version`)."

Running `--version` on every installed tool on every invocation adds latency. If the agent calls `tool-health-check.sh` at session start (as section 2.7 suggests it can), this adds N version-check subprocess spawns to session startup.

**Recommendation**: 
- Add a simple file-based cache (e.g., `.cache/tool-health.json` with timestamp). If cache is < 24h old, return cached results. Force re-check with `--force` flag.
- Document that session-start invocation is OPTIONAL and the agent should prefer on-demand checks (when a specific tool is about to be used) over blanket session-start scans.

---

## Suggestions (P2 -- nice to have)

### P2-1: SKILL.md estimated at ~300 lines -- verify against Anthropic's <500 line guidance

**Location**: Handoff section 2.1, line 109

The architecture diagram notes SKILL.md at "~300 lines." The pack-evaluation knowledge (pack-evaluation.md, Structural-Gold entry) references Anthropic's `<500 line` progressive-disclosure rule for SKILL.md body. 300 lines is within bounds, but with 3 cross-cutting rules, a full context router table, and Step 0-2 instructions, the actual line count may exceed the estimate. The web-backend reference pack's SKILL.md is 147 lines.

**Suggestion**: After implementation, verify the actual SKILL.md line count stays under 250 lines (with 6 references to load, the router itself is the primary content -- keeping the SKILL.md lean ensures fast initial load).

### P2-2: capability-detect.sh MCP tier detection via ToolSearch is not a shell-native operation

**Location**: Handoff section 2.4, lines 205-208

The design mentions "Tier 1: MCP servers (check by name pattern) -- Claude in Chrome: check for mcp__claude-in-chrome__* tools." ToolSearch is a Claude Code tool-call, not a shell command. The script cannot invoke ToolSearch from bash.

**Suggestion**: Either (a) have the SKILL.md instruct the agent to call ToolSearch BEFORE running the shell script and pass results as an environment variable, or (b) accept that the shell script only covers Tier 2 (CLI) and Tier 3 (extension/process), while Tier 1 (MCP) detection is done inline by the agent in SKILL.md Step 0. This is an architectural clarification, not a performance issue per se, but a mismatch between design and reality would cause unnecessary retries.

### P2-3: Consider adding `set -euo pipefail` to both scripts for fail-fast behavior

**Location**: Handoff section 2.4-2.5

The capability-detect.sh design shows no error handling preamble. Existing TAD scripts (e.g., readiness-score.sh, detect-platform.sh) use `set -euo pipefail` or `set -e`. Without it, a failed jq command in the loop silently produces malformed JSON.

**Suggestion**: Add `set -euo pipefail` and handle jq absence gracefully (fallback to raw shell output if jq is not installed, since jq is noted as a prerequisite in section 8.4 but may not be present on all systems).

### P2-4: The fixture discriminative_pattern uses dots as literal separators in a regex context

**Location**: Handoff section 2.6, line 237

```yaml
discriminative_pattern: "capability.detect|Layer.Match|fallback.chain|Claude.in.Chrome|Playwright.MCP|token.cost"
```

The dots in `capability.detect` etc. are used as word separators in a `grep -oE` context. In regex, `.` matches ANY character. This means `capabilityXdetect` would also match. While not a functional failure (it is a grep for presence, not exact match), it inflates match counts slightly.

**Suggestion**: If the pack-eval-runner uses `grep -oE`, either escape dots (`capability\.detect`) or use a non-regex separator that matches the actual output text (e.g., spaces: `capability detect`). The pack-evaluation pattern entry notes "YAML double-quoted patterns escape `\` as `\\`" -- follow that convention.

---

## Overall Assessment

**Verdict: PASS**

From a performance optimization perspective, this handoff describes a well-structured capability pack with clear awareness of token cost trade-offs (the core value proposition of the pack IS performance optimization -- choosing cheaper tools). The identified issues are P1-level implementation improvements, not architectural flaws:

1. The script designs (capability-detect.sh, tool-health-check.sh) have minor efficiency issues (loop-spawned jq, ps aux scan, no caching) that are easy to fix during implementation without design changes.
2. Token cost claims are well-researched and verified but need clearer categorization (one-time vs per-page vs per-session) to prevent agent misinterpretation.
3. No ReDoS risks found -- the regex patterns used are simple alternations or bounded wildcards suitable for DFA-based grep.
4. The five-layer architecture with fallback chains is a sound performance-aware design that routes tasks to the cheapest adequate tool.

No P0 blockers. P1s are implementation guidance that Blake can address during build.
