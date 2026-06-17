# Expert Review: code-reviewer
## Handoff: HANDOFF-20260617-agent-computer-interface-pack.md

**Reviewer**: code-reviewer
**Date**: 2026-06-17
**Verdict**: CONDITIONAL PASS
**Sections Reviewed**: Full document (sections 3-8 abbreviated into single block, no standard section 6/7 separation). Focused on: section 2 (Technical Design), section 9 (Acceptance Criteria + section 9.1), section 10 (Implementation Hints), section 11 (Decision Summary). Cross-referenced with: pack-build-rules.md, pack-evaluation.md, existing ai-tool-integration pack structure, research evidence files.

---

## Critical Issues (P0)

### P0-1: capability-detect.sh MCP detection design is a no-op -- ToolSearch is a Claude runtime API, not a shell command

**Location**: Section 2.4 (capability-detect.sh design), Cross-Cutting Rule 1

**Issue**: The capability-detect.sh design says "Tier 1: MCP servers (check by name pattern)" with comments referencing checking for `mcp__claude-in-chrome__*` tools, `mcp__playwright__*`, and `mcp__chrome-devtools__*`. However, these MCP tool names exist only inside the Claude Code runtime -- they are discoverable via ToolSearch (a Claude-internal API) but NOT from a bash script. A shell script cannot call `ToolSearch` or query what MCP servers are connected to the current Claude Code session. There is no CLI equivalent or environment variable that exposes connected MCP server names.

The script's Tier 1 is structurally impossible as designed. This is the PRIMARY value of the pack ("capability detection first") and its failure undermines Cross-Cutting Rule 1 and the entire tool selection flow.

**Impact**: AC5 requires "scripts/capability-detect.sh executable, outputs JSON, detects >= 3 tool types." If Tier 1 (MCP) is a no-op, the script can only detect Tier 2 (CLI tools via `command -v`) and Tier 3 (extension via `ps aux` grep). Detecting exactly 2 tiers means AC5 ">=3 tool types" becomes borderline -- it depends on whether "tool types" means tiers or individual tools. More critically, the pack's marquee use case ("agent detects Claude in Chrome is available and uses it directly") cannot work through this script since Claude in Chrome is an MCP server, not a CLI tool.

**Fix**: Split capability detection into two mechanisms: (1) a shell script for CLI/process detection (Tier 2 + Tier 3), and (2) SKILL.md instructions telling the agent to use ToolSearch directly for MCP server detection (Tier 1). The SKILL.md Step 0 should say: "For MCP detection, use ToolSearch with query 'select:mcp__claude-in-chrome__navigate' etc. to probe availability. For CLI/extension detection, run `bash scripts/capability-detect.sh`." This matches how existing packs work -- they instruct the agent to use ToolSearch in SKILL.md prose, not in shell scripts.

### P0-2: install.sh is specified to exist BUT existing packs in .claude/skills/ have NO install.sh -- the install.sh pattern lives in .tad/capability-packs/

**Location**: Section 2.1 (directory structure), AC8, FR6

**Issue**: The handoff specifies `install.sh` in `.claude/skills/agent-computer-interface/`. However, inspecting the actual codebase: ZERO of the 24+ existing packs in `.claude/skills/` have an install.sh file. The install.sh files live in `.tad/capability-packs/{pack}/install.sh` (e.g., `.tad/capability-packs/ai-tool-integration/install.sh`). Furthermore, per the pack-build-rules.md pattern "Sync That Mirrors Skills THEN Runs install.sh Can Silently Downgrade Them" (2026-06-15), install.sh regenerating from `.tad/capability-packs/` was identified as a BUG that causes downgrades. The current *sync workflow mirrors `.claude/skills/` directly and does NOT rely on install.sh.

AC8 says install.sh should use "single-source copy from .claude/skills/, NOT regenerate from .tad/capability-packs/". This is contradictory -- if the pack is already IN `.claude/skills/`, what would install.sh copy FROM and TO? The install.sh pattern is for external distribution (from `.tad/capability-packs/` into `.claude/skills/`), not for inclusion inside the skills directory itself.

**Impact**: Blake will create an install.sh inside `.claude/skills/agent-computer-interface/` that serves no purpose (the files are already where they need to be) or that introduces the exact downgrade bug that the 2026-06-15 principle warns against. This also breaks the established structural pattern of the other 24 packs.

**Fix**: Remove install.sh from the `.claude/skills/` directory structure. If an install.sh is needed for external distribution, it belongs in `.tad/capability-packs/agent-computer-interface/install.sh` following the existing pattern. Update AC8 to instead verify that the pack structure follows the standard pattern (no install.sh in skills dir).

---

## Recommendations (P1)

### P1-1: Missing CONSUMES/PRODUCES interface contract

**Location**: Section 2.2 (SKILL.md design)

**Issue**: Per pack-build-rules.md "Design and Build Rules" (2026-05-07), every capability pack MUST declare CONSUMES/PRODUCES interface contracts. The ai-tool-integration gold reference pack has these on lines 8-9 of its SKILL.md. The handoff's SKILL.md design (section 2.2) shows frontmatter and cross-cutting rules but does NOT include CONSUMES/PRODUCES. `grep -c "CONSUMES\|PRODUCES"` on the handoff returns 0.

**Fix**: Add CONSUMES/PRODUCES to the SKILL.md design template. Suggested:
```
CONSUMES: User browser/computer control task + target URL/application description + optional existing MCP server connections
PRODUCES: Applied tool selection judgment + capability detection results + fallback chain recommendations + configuration guidance
```

### P1-2: No explicit section 6 (Implementation Steps) -- "3-8 abbreviated" loses critical ordering information

**Location**: Sections 3-8 (abbreviated block)

**Issue**: The handoff collapses sections 3-8 into a single block with only FR table and friction preflight. Standard handoff section 6 contains ordered implementation steps with explicit sequencing. The "Implementation Hints" in section 10 are unordered bullet points. Key dependency: reference files must be written before SKILL.md's Quick Rule Index can reference them, and capability-detect.sh design must be finalized (with P0-1 fix) before SKILL.md's Cross-Cutting Rule 1 can accurately describe its usage.

**Fix**: Add an explicit implementation sequence in section 10 or restore section 6:
1. Read research sources (decision-brief.md + raw-ask-results.md)
2. Create 6 reference files (references/*.md) with judgment rules from research
3. Create scripts/capability-detect.sh (CLI + extension tiers only, per P0-1 fix)
4. Create scripts/tool-health-check.sh
5. Create SKILL.md (frontmatter + cross-cutting rules + context router referencing created files)
6. Create examples/fixture-browser-task.md
7. Sync to .agents/skills/

### P1-3: capability-detect.sh uses `ps aux | grep` for extension detection -- fragile and potentially false-positive

**Location**: Section 2.4 (Tier 3 detection)

**Issue**: The script detects Claude in Chrome via `ps aux | grep -q "[c]laude.*--chrome"`. This pattern:
- May not match if the process name or flag changes in future Claude Code releases
- Could false-positive on any process containing "claude" followed by "chrome" (e.g., a user script named claude-chrome-test.sh)
- The `[c]laude` bracket trick only avoids matching the grep process itself -- it does not ensure the match is a Claude Code process specifically
- Whether `--chrome` is even a real Claude Code flag is not verified in the research sources

**Fix**: Document this detection as "heuristic, may produce false positives" in SKILL.md's Step 0. Consider adding `pgrep -f` as an alternative pattern. More importantly, since MCP detection via ToolSearch (P0-1 fix) will be the primary mechanism for Claude in Chrome detection, demote this to a secondary fallback signal.

### P1-4: Fixture discriminative_pattern contains potentially generic terms

**Location**: Section 2.6 (Behavioral Eval Fixture)

**Issue**: Per pack-evaluation.md "Behavioral-Eval Gate Must Run on SEPARATE Discriminative Field" (2026-05-31), discriminative patterns must contain ONLY pack-specific markers. The proposed pattern: `"capability.detect|Layer.Match|fallback.chain|Claude.in.Chrome|Playwright.MCP|token.cost"`.

Potential generics:
- `token.cost` -- any cost-aware LLM discussion mentions this
- `fallback.chain` -- common resilience pattern terminology
- `Layer.Match` -- could appear in networking/OSI discussions

With `min_discriminative: 3`, a CONTROL agent discussing browser automation could plausibly hit `fallback.chain` + `token.cost` + `Claude.in.Chrome` (if Claude in Chrome is mentioned in the conversation context), reaching 3 without the pack.

**Fix**: Either tighten the pattern to truly pack-specific terms (e.g., `"capability.detect.sh|L[1-5].Engine|five.layer.selection|MCP.tier.scan|context.tax.13k|Stagehand.act.extract"`) or raise `min_discriminative` to 4+.

---

## Suggestions (P2)

### P2-1: Missing LICENSE file in pack directory

**Location**: Section 2.1 (directory structure)

**Issue**: The gold-standard ai-tool-integration pack includes a LICENSE file. The proposed directory structure does not include one. While not blocking, maintaining structural consistency with existing packs reduces maintenance burden during *sync operations.

### P2-2: Missing Version/Compatibility header in SKILL.md design

**Location**: Section 2.2

**Issue**: The ai-tool-integration pack includes `Version: 0.1.0` and `Compatibility: Claude Code (Phase 1); Codex / Cursor / Gemini in Phase 3` headers. The proposed SKILL.md design does not include these. Adding them improves traceability and aligns with the established pattern.

### P2-3: tool-health-check.sh 90-day threshold is arbitrary and ungrounded

**Location**: Section 2.5

**Issue**: The 90-day staleness threshold for `last_verified` dates is stated without research grounding. Given the handoff notes the domain "changes extremely fast" (section 11, D3 rationale), 90 days may be too generous. Consider documenting the rationale or making the threshold configurable (e.g., `STALE_DAYS=${STALE_DAYS:-90}`).

### P2-4: AC4 "each rule cites research source" needs verification method

**Location**: AC4

**Issue**: AC4 says "6 reference files exist, each with >=5 judgment rules, each rule cites research source." But there is no specified verification method (grep pattern, manual review). Consider adding a verification command like `grep -c 'Source:' references/*.md` to check each file has at least 5 source citations.

### P2-5: Consider specifying LC_ALL for capability-detect.sh

**Location**: Section 2.4

**Issue**: Per shell-portability pattern in pack-build-rules.md, macOS scripts that process potentially Unicode text should set `LC_ALL=en_US.UTF-8`. While capability-detect.sh primarily handles ASCII tool names, the fallback notification messages contain CJK characters (the "warn" format uses Chinese characters). Setting LC_ALL at the script top prevents silent encoding issues.

---

## Positive Confirmations

- The five-layer architecture model (L1 Engine through L5 Desktop) is well-grounded in the research evidence (decision-brief.md confirms the taxonomy with star counts and benchmark numbers).
- The 3 cross-cutting rules are well-chosen and genuinely cross-reference (capability detection, layer match, fallback chain) -- each applies regardless of which reference is loaded.
- The reference-based architecture correctly follows the Pack Architecture Spectrum pattern for judgment-rules packs.
- AC9 (.agents/skills parity via byte-identical check) follows established practice.
- AC10 (numeric claims verified against research) directly addresses the Research Provenance Rules pattern.
- The YAML frontmatter design includes both Chinese and English keywords, following the Domain Pack Keyword Curation pattern.
- The token cost comparison table (section 2.2, Cross-Cutting Rule 3) provides genuinely discriminative specific numbers (13.6k tokens, 4x cost ratio) that satisfy the anti-slop quality bar.
- Research sources are well-documented with notebook ID and verified claims table.

---

## Overall Assessment: CONDITIONAL PASS

The handoff demonstrates strong research grounding and a sound five-layer architecture design. The two P0 issues must be fixed before Blake starts:

1. **P0-1** (capability-detect.sh MCP detection is structurally impossible from a shell script) undermines the pack's core value proposition. The fix is straightforward: split detection into shell script (CLI/process) + SKILL.md prose (ToolSearch for MCP).

2. **P0-2** (install.sh in the wrong location, contradicting the established 24-pack pattern and the 2026-06-15 principle) will create structural inconsistency. Remove it from .claude/skills/ or clarify its actual purpose.

With P0s fixed and P1s addressed, this handoff provides Blake with a clear, research-backed design for the 25th capability pack.
