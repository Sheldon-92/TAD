# Spike Verdict: Session Hook Context Optimization

## Verdict: ⚠️ PARTIAL
## Confidence: High

**Summary**: Claude Code hooks mechanism IS technically capable of context injection, but the optimization target is smaller than assumed. Session start context is only ~8.5% of total TAD context. Hooks are feasible for supplementary context but cannot replace CLAUDE.md. The Epic should **pivot** from context reduction to value-adding features.

---

## Baseline Measurement

### Token Budget Analysis

| Component | Characters | Tokens (approx) | Loads At | Can Defer? |
|-----------|-----------|-----------------|----------|------------|
| Global CLAUDE.md (~/.claude/) | 315 | ~79 | Session start | No (user prefs) |
| Project CLAUDE.md (routing rules) | 5,778 | ~1,445 | Session start | Partially (~30%) |
| @import architecture.md | 14,466 | ~3,617 | Session start | Yes |
| @import (8 non-existent files) | 0 | 0 | N/A (silently skipped) | N/A |
| .claude/settings.json | ~870 | ~218 | Session start | No (config) |
| **Total at session start** | **~21,429** | **~5,359** | | |
| | | | | |
| tad-alex.md (on /alex) | 101,573 | ~25,393 | On-demand (Skill) | Already deferred |
| tad-blake.md (on /blake) | 35,064 | ~8,766 | On-demand (Skill) | Already deferred |
| config.yaml | 12,414 | ~3,104 | On agent activation | Already deferred |
| config-agents.yaml | 11,250 | ~2,813 | On agent activation | Already deferred |
| config-quality.yaml | 27,461 | ~6,865 | On agent activation | Already deferred |
| config-execution.yaml | 13,386 | ~3,347 | On agent activation | Already deferred |
| config-platform.yaml | 7,873 | ~1,968 | On agent activation | Already deferred |
| config-cognitive.yaml | 10,945 | ~2,736 | On agent activation | Already deferred |
| **Total on-demand (Blake)** | **~118,393** | **~29,599** | | |
| **Total on-demand (Alex)** | **~171,516** | **~42,879** | | |

### Key Metrics

| Metric | Value |
|--------|-------|
| Session start tokens | ~5,359 |
| Blake activation tokens | ~29,599 |
| Total TAD tokens (Blake session) | ~34,958 |
| **Session start as % of total** | **~8.5%** |
| Maximum deferrable at session start | ~3,617 (architecture.md only) |
| **Deferrable as % of total** | **~6%** |

### @import Behavior Test Results

- **9 @import directives** in CLAUDE.md Section 8
- **1 file exists**: architecture.md (14,466 chars) — loaded at session start
- **8 files don't exist**: code-quality.md, security.md, testing.md, ux.md, performance.md, api-integration.md, mobile-platform.md, frontend-design.md
- **Non-existent @imports cost zero tokens**: CLAUDE.md line 140 states "Non-existent files are silently skipped"
- **Verified**: code-quality.md returned "File does not exist" error, confirming it's not loaded

**Conclusion**: The @import mechanism is already effectively "lazy" for non-existent files. As project-knowledge files are created over time, they will start consuming tokens at session start. This is a FUTURE concern, not a current bottleneck.

---

## Findings

### Approach 1: Claude Code Shell Hooks

**Capability Matrix**:

| Capability | Supported? | Details |
|-----------|-----------|---------|
| Hook types | ✅ | command, http, prompt, agent |
| Context injection | ✅ | stdout → appended to agent context |
| SessionStart event | ✅ | Fires at session init, resume, compact |
| Conditional triggers | ✅ | Regex matchers per event type |
| Multiple sources | ✅ | Global + project + local + plugin scopes coexist |
| Replace CLAUDE.md | ❌ | Hooks SUPPLEMENT, not replace — CLAUDE.md is primary |
| Execution order | ⚠️ | SessionStart → CLAUDE.md load → InstructionsLoaded |
| Resume behavior | ✅ | Re-fires with `source: "resume"` in input |

**Execution Model**:
1. Event fires → JSON written to hook's stdin
2. Hook processes → writes to stdout/stderr
3. Exit 0: stdout text appended to context
4. Exit 2: block the action, stderr fed back as error
5. Other exit codes: non-blocking error, stderr logged only

**Registration**: `hooks` field in settings.json at 3 scopes:
- `~/.claude/settings.json` (global)
- `.claude/settings.json` (project, version-controlled)
- `.claude/settings.local.json` (project, local-only)

**Existing hooks in this environment**: User already has hooks configured:
- `Stop` → macOS notification on task completion
- `Notification` → macOS notification on confirmation needed
- This confirms hooks work in this environment.

**Key Limitation**: Hooks fire BEFORE CLAUDE.md loads, but they can only ADD context, not PREVENT CLAUDE.md from loading. There is no mechanism to make CLAUDE.md loading conditional or partial.

### Approach 2: Meta-Skill Bootstrap Pattern

**Concept**: Slim CLAUDE.md to minimal routing rules, use Skill tool invocation to load heavier content on-demand.

**Assessment**:
- ✅ TAD already uses this pattern! Agent files (tad-alex.md, tad-blake.md) load via Skill tool on-demand
- ✅ Config modules load via agent activation protocol, not at session start
- ⚠️ CLAUDE.md @imports cannot be made conditional — they either resolve (file exists) or skip (file doesn't exist)
- ⚠️ Moving routing rules to a Skill would mean they're not available UNTIL the Skill is invoked — defeating the purpose of always-on routing

**Conclusion**: The meta-skill bootstrap pattern is ALREADY implemented in TAD's architecture. Agent files and config modules are already on-demand. The only always-loaded content is CLAUDE.md + resolved @imports, which is the correct behavior for routing rules.

### Approach 3: Alternative Optimizations (IT5)

| Alternative | Feasible? | Savings | Effort | Verdict |
|------------|-----------|---------|--------|---------|
| Conditional @imports | ❌ | N/A | N/A | @import syntax doesn't support conditions |
| CLAUDE.md directory splitting | ⚠️ | Minimal | Low | Could split by directory level, but TAD only operates in one directory |
| Config module lazy loading | ✅ Already done | ~30K tokens | N/A | config-*.yaml files load on agent activation, not session start |
| Manual CLAUDE.md slimming | ⚠️ | ~500 tokens | Low | Already slimmed to 153 lines (router pattern) in v2.2 |
| Move architecture.md to on-demand | ✅ Possible | ~3,617 tokens | Medium | Could create a Skill that loads project-knowledge on demand |
| Hook-based dynamic context | ✅ Possible | Neutral | Medium | SessionStart hook could inject recent project state instead of static content |

**Best alternative**: If optimization is needed in the future (when more project-knowledge files exist), create a `/knowledge-load` Skill that reads project-knowledge files on-demand, and remove the @import directives from CLAUDE.md. This would save proportionally more as the knowledge base grows.

### TAD CLAUDE.md Content Analysis

| Category | Content | Lines | Tokens | Can Defer? |
|----------|---------|-------|--------|------------|
| **CRITICAL** (must load at startup) | | | | |
| Handoff routing rules (§1) | "Handoff → Blake → Gates" enforcement | 11 | ~130 | No |
| Terminal isolation (§4) | Alex=T1, Blake=T2 enforcement | 16 | ~200 | No |
| Plan Mode prohibition (§5) | Prevent EnterPlanMode during TAD | 10 | ~120 | No |
| Violation handling (§6) | Stop, correct, redo | 5 | ~60 | No |
| **IMPORTANT** (should load at startup) | | | | |
| TAD usage scenarios (§2) | When to use /alex, /blake, /gate | 25 | ~350 | Partially |
| Quality Gates overview (§3) | 6 rules summary | 12 | ~180 | Partially |
| **DEFERRABLE** (could load on-demand) | | | | |
| Protocol locations (§7) | Table of where protocols live | 8 | ~100 | Yes |
| Project Knowledge @imports (§8) | 9 @import directives | 15 | ~80 + resolved files | Imports: Yes |

**Summary**: ~510 tokens are CRITICAL (must stay). ~530 tokens are IMPORTANT (should stay for safety). ~180 tokens + resolved imports are deferrable. Total potential savings from CLAUDE.md slimming: ~180 tokens (trivial) + resolved @imports (~3,617 tokens currently, growing over time).

---

## Recommended Architecture

### For Current State: No Changes Needed

The current architecture is already well-optimized:
1. **CLAUDE.md** (153 lines, ~1,445 tokens) serves as a lightweight router — this is correct
2. **Agent files** load on-demand via Skill tool — this is correct
3. **Config modules** load on agent activation — this is correct
4. **@imports** silently skip non-existent files — this is effectively lazy loading

### For Future Growth: Deferred Knowledge Loading

When project-knowledge files grow beyond 5 files (each ~3K tokens), implement this:

```
CLAUDE.md (keep as-is, remove @import section)
  ↓
/alex or /blake invoked
  ↓
Agent activation protocol reads .tad/project-knowledge/*.md
  (already happens in Blake's step 1.5 Context Refresh)
  (already happens in Alex's step0_5 handoff creation)
```

This is essentially what Context Refresh Protocol already does — it re-reads project-knowledge before key operations. The @imports in CLAUDE.md are partially redundant.

### Optional Hook Enhancement

If desired, a SessionStart hook could inject dynamic context:

```json
{
  "SessionStart": [{
    "matcher": "startup",
    "hooks": [{
      "type": "command",
      "command": "echo 'TAD v2.4.0 | Active handoffs:' && ls .tad/active/handoffs/HANDOFF-*.md 2>/dev/null | wc -l | tr -d ' ' && echo ' | Project knowledge files:' && ls .tad/project-knowledge/*.md 2>/dev/null | wc -l | tr -d ' '"
    }]
  }]
}
```

This would show a one-line TAD status at session start without loading full files. Low value but demonstrates the pattern.

---

## Alternative Approach

### If Not Pursuing Context Optimization

The baseline measurement shows the optimization target is **~8.5% of total context** at session start, with only **~6% being deferrable** (architecture.md). This is below the 10% threshold defined in AC11.

**Recommendation**: The Epic should **pivot** from context optimization to direct value-adding features. Specifically:

1. **Skip Phase 0 follow-up** (no hook-based context system needed)
2. **Proceed directly to Phase 1-5** features that add capability, not reduce overhead
3. **Revisit context optimization** when project-knowledge reaches 5+ files with content

### When to Revisit

Context optimization becomes worthwhile when:
- Total session-start tokens exceed ~10,000 (currently ~5,359)
- Project-knowledge files exceed 5 with content (currently 1)
- Users report noticeable performance degradation in long sessions

---

## Impact on Epic Phases

| Phase | Original Purpose | Impact of Verdict |
|-------|-----------------|-------------------|
| Phase 0 (this spike) | Determine hook feasibility | ✅ COMPLETE — hooks work but optimization target is small |
| Phase 1: Spec Compliance | Add spec compliance to Ralph Loop | No impact — proceed as planned, but don't worry about context cost |
| Phase 2: Anti-Rationalization | Add tables to agent files | No impact — tables add to on-demand files, not session start |
| Phase 3: TDD Skill | Add TDD enforcement | No impact — new Skill loads on-demand |
| Phase 4: Micro-Tasks | Pressure testing integration | No impact — runtime feature |
| Phase 5: Git Worktree | Worktree integration | No impact — runtime feature |

**Key insight**: Phases 1-5 add content to ON-DEMAND files (agent commands, config modules), not to CLAUDE.md. The session-start overhead will not grow from these features. The original concern that "CLAUDE.md will grow further" was based on an incorrect assumption — features are added to agent files, not CLAUDE.md.

---

## Risks & Limitations

1. **Token estimation accuracy**: Using char/4 approximation. Actual tokenization varies by content type (code vs prose, CJK vs ASCII). Real token count could be ±20%.

2. **Future @import growth**: If all 9 project-knowledge files eventually exist with ~3K tokens each, session-start would grow to ~28K tokens. This is the scenario where optimization would matter — but it's hypothetical.

3. **Hook stability**: Claude Code hooks API may change between versions. Any hook-based solution would need version tracking.

4. **CLAUDE.md is not the only always-loaded content**: Claude Code also loads system prompts, tool definitions, and other internal context. TAD's session-start overhead is a fraction of the total agent context.

5. **Measurement caveat**: This measurement covers TAD-specific content only. The Claude Code system prompt, tool definitions, and conversation history consume significantly more context than TAD's CLAUDE.md.

---

## Appendix: Raw Measurements

### File Sizes (characters)
```
CLAUDE.md (project):     5,778
CLAUDE.md (global):        315
architecture.md:        14,466
settings.json (project):   870 (approx)
settings.local.json:     6,632

tad-alex.md:           101,573
tad-blake.md:           35,064
config.yaml:            12,414
config-agents.yaml:     11,250
config-quality.yaml:    27,461
config-execution.yaml:  13,386
config-platform.yaml:    7,873
config-cognitive.yaml:  10,945
```

### Hooks Capability Evidence
- Global settings.json already has working hooks (Stop, Notification)
- Hook types: command, http, prompt, agent
- SessionStart supported with matchers: startup, resume, compact
- Context injection: stdout → appended to agent context (exit code 0)
- Hooks supplement CLAUDE.md, cannot replace it

### Project Knowledge File Status
```
architecture.md:    EXISTS (14,466 chars) — @imported, loaded at session start
code-quality.md:    DOES NOT EXIST — @import silently skipped
security.md:        DOES NOT EXIST — @import silently skipped
testing.md:         DOES NOT EXIST — @import silently skipped
ux.md:              DOES NOT EXIST — @import silently skipped
performance.md:     DOES NOT EXIST — @import silently skipped
api-integration.md: DOES NOT EXIST — @import silently skipped
mobile-platform.md: DOES NOT EXIST — @import silently skipped
frontend-design.md: DOES NOT EXIST — @import silently skipped
```
