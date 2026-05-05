# Handoff: Alex Intent Router (Multi-mode Switching)

**From:** Alex (Solution Lead)
**To:** Blake (Execution Master)
**Date:** 2026-02-16
**Task ID:** TASK-20260216-001
**Priority:** P1
**Complexity:** Medium (Standard TAD)
**Status:** Ready for Implementation (Expert Review P0 Fixed)
**Epic:** EPIC-20260216-alex-flexibility-and-project-mgmt.md (Phase 1/5)

---

## Socratic Inquiry Summary

**Complexity**: Medium | **Rounds**: 2

| Dimension | Question | Decision |
|-----------|----------|----------|
| *bug scope | Can Alex fix bugs directly? | ~~Yes, simple bugs with user confirmation~~ → **Revised after expert review**: No. Alex diagnoses only, creates express mini-handoff for Blake |
| *discuss output | Where to store discussion conclusions? | NEXT.md or idea file (upgrade to Idea Pool in Phase 3) |
| Fallback | What if intent detection fails? | Always ask user via AskUserQuestion |
| *bug boundary | Conflict with "Alex doesn't write code" principle? | **Resolved**: Alex never writes code. Bug path = diagnose + mini-handoff only |
| Scope | How many files to change? | Alex decides based on technical reasoning |

---

## Executive Summary

Alex currently defaults to a single workflow path: `*analyze → *design → *handoff`. In practice, users need Alex to handle 4 distinct interaction modes: quick bug diagnosis/fix, free-form product discussion, lightweight idea capture, and the standard TAD design flow. This handoff adds an **Intent Router** layer that detects user intent (via explicit commands or auto-detection) and routes to the appropriate path.

**Core change**: Insert an intent routing layer before Adaptive Complexity in `tad-alex.md`, add 3 new command paths (`*bug`, `*discuss`, `*idea`), and update supporting config/docs.

**Key design decision (post-expert-review)**: `*bug` path is **diagnose-only** — Alex never writes implementation code, even for simple bug fixes. Alex creates an express mini-handoff for Blake. This preserves terminal isolation and the "Alex doesn't code" principle.

**Inspiration**: Zevi Arnovitz (Meta PM) workflow analysis — his single-agent, multi-mode slash command system demonstrated the value of flexible mode switching within a unified agent.

---

## Current State (What Exists)

In `tad-alex.md`:
- `adaptive_complexity_protocol` is the first thing that runs when user describes a task
- `commands` section lists available commands but no *bug/*discuss/*idea
- `forbidden` section includes "Writing implementation code"
- `on_start` greeting only mentions standard TAD workflow

In `CLAUDE.md`:
- §2 "TAD Framework 使用场景" table only has Alex for new features/architecture/complex tasks
- "跳过 TAD" scenarios listed but no intermediate modes

In `config-workflow.yaml`:
- No intent_modes section exists

---

## Target State (What We Want)

### New Flow Architecture

```
User input arrives
       ↓
┌─────────────────────────────────┐
│      Intent Router (NEW)        │
│                                 │
│  Step 1: Check explicit command │
│    *bug → Bug Path              │
│    *discuss → Discuss Path      │
│    *idea → Idea Path            │
│    *analyze → Standard TAD      │
│                                 │
│  Step 2: No command detected    │
│    → Signal word analysis       │
│    → AskUserQuestion to confirm │
│    → Route to chosen path       │
└─────────────────────────────────┘
       ↓
  ┌────┴────┬──────────┬──────────┐
  ↓         ↓          ↓          ↓
*bug     *discuss    *idea    *analyze
path      path       path   (unchanged)
```

---

## Task Breakdown

### Task 1: Add `intent_modes` to config-workflow.yaml

**File**: `.tad/config-workflow.yaml`

**Add new section** (after `socratic_inquiry_protocol`):

```yaml
# ==================== Intent Modes (v2.4) ====================
intent_modes:
  enabled: true
  version: "1.0"
  description: "Alex multi-mode routing — detect user intent before entering workflow"

  modes:
    bug:
      command: "*bug"
      label: "Bug/Fix"
      icon: "🔧"
      description: "Quick bug diagnosis and optional fix"
      signal_words:
        zh: ["bug", "报错", "出问题", "崩溃", "修复", "不工作", "出错", "异常", "失败"]
        en: ["bug", "error", "broken", "crash", "fix", "not working", "fail", "issue"]
      leads_to_handoff: "optional"  # may or may not produce handoff

    discuss:
      command: "*discuss"
      label: "Discussion"
      icon: "💬"
      description: "Free-form product/tech discussion, no handoff pressure"
      signal_words:
        zh: ["讨论", "聊聊", "怎么看", "方向", "策略", "纠结", "不确定", "想法", "觉得"]
        en: ["discuss", "think about", "direction", "strategy", "opinion", "uncertain"]
      leads_to_handoff: "never"  # discussion mode never auto-generates handoff

    idea:
      command: "*idea"
      label: "Idea Capture"
      icon: "💡"
      description: "Capture and refine ideas for later"
      signal_words:
        zh: ["突然想到", "有个想法", "能不能加", "以后可以", "要不要做", "灵感"]
        en: ["idea", "maybe", "what if", "could we", "someday", "nice to have"]
      leads_to_handoff: "never"  # ideas are stored, not immediately executed

    analyze:
      command: "*analyze"
      label: "Standard TAD"
      icon: "🎯"
      description: "Full TAD workflow: Socratic inquiry → design → handoff"
      signal_words: []  # default fallback, no specific signals
      leads_to_handoff: "always"

  detection:
    strategy: "always_confirm"  # always use AskUserQuestion to confirm intent
    fallback_mode: "analyze"    # if truly ambiguous, suggest standard TAD
    signal_confidence_threshold: 2  # need 2+ signal words to pre-select a mode

    # P1 FIX: Signal word priority when multiple modes match
    priority_order: ["bug", "idea", "discuss", "analyze"]
    priority_note: |
      When signal words match multiple modes equally:
      1. bug — highest priority (immediate action needed)
      2. idea — user is capturing something specific
      3. discuss — broad conversation
      4. analyze — fallback / default
      Ties are broken by this priority order. Final confirmation via AskUserQuestion still applies.
```

### Task 2: Add Intent Router Protocol to tad-alex.md

**File**: `.claude/commands/tad-alex.md`

**Location**: Insert new section `intent_router_protocol` BEFORE `adaptive_complexity_protocol`

```yaml
# ⚠️ MANDATORY: Intent Router Protocol (First Contact)
intent_router_protocol:
  description: "Detect user intent and route to appropriate path before any other processing"
  trigger: "User describes a task or need (before adaptive_complexity_protocol)"
  blocking: true
  prerequisite: "Activation protocol complete (STEP 1-4)"

  execution:
    step1:
      name: "Check Explicit Command"
      action: |
        If user input starts with *bug, *discuss, *idea, or *analyze:
          → Skip detection, go directly to the corresponding path
          → For *analyze: proceed to adaptive_complexity_protocol (existing flow)

    step2:
      name: "Signal Detection (no explicit command)"
      action: |
        Read intent_modes from config-workflow.yaml.
        Scan user input for signal_words across all modes.
        Count matches per mode.
        Pre-select the mode with highest signal count (if >= signal_confidence_threshold).
        If no mode reaches threshold → pre-select "analyze" (standard TAD).

    step3:
      name: "User Confirmation (ALWAYS)"
      action: |
        Use AskUserQuestion to confirm detected intent:
        AskUserQuestion({
          questions: [{
            question: "我判断这是一个 {detected_mode_label} 场景。你想怎么处理？",
            header: "Intent",
            options: [
              {label: "{detected_mode} (Recommended)", description: "{mode_description}"},
              {label: "🔧 Bug/Fix", description: "Quick diagnosis and optional fix"},
              {label: "💬 Discussion", description: "Free-form discussion, no handoff"},
              {label: "💡 Idea Capture", description: "Capture idea for later"},
              {label: "🎯 Standard TAD", description: "Full design → handoff workflow"}
            ],
            multiSelect: false
          }]
        })
        Note: Only show 4 options (skip the one that's already "Recommended" to avoid duplicate)

    step4:
      name: "Route"
      action: |
        Based on user's choice:
        - bug → Enter bug_path_protocol
        - discuss → Enter discuss_path_protocol
        - idea → Enter idea_path_protocol
        - analyze → Enter adaptive_complexity_protocol (existing, unchanged)

  # P0-2 FIX: Trigger timing and path transition rules
  trigger_timing: |
    Intent Router activates on the FIRST user message AFTER on_start greeting completes.
    - on_start greeting is STEP 4 of Activation Protocol
    - Intent Router is STEP 5 (new) — runs when user describes a task/need
    - If user sends *analyze explicitly, Intent Router still runs but skips to step4 immediately

  path_transitions:
    description: "Rules for switching between paths mid-session"
    allowed:
      - from: "discuss"
        to: "analyze"
        trigger: "User says 'this needs proper design' or selects *analyze from exit options"
      - from: "discuss"
        to: "idea"
        trigger: "User says 'capture this as an idea' or selects *idea from exit options"
      - from: "bug"
        to: "analyze"
        trigger: "Bug diagnosis reveals need for larger architectural change"
      - from: "idea"
        to: "analyze"
        trigger: "User says 'I want to do this now' from step4 options"
    forbidden:
      - from: "analyze"
        to: "any"
        reason: "Once in standard TAD flow (Socratic/Design/Handoff), switching out would lose context. Complete or abort first."
    mechanism: |
      Path transitions use AskUserQuestion to confirm.
      On transition, Alex announces: "Switching from {from_mode} to {to_mode}."
      No state from the previous path carries over except conversation context.
```

### Task 3: Define Bug Path Protocol in tad-alex.md

**File**: `.claude/commands/tad-alex.md`

**Add section**:

```yaml
# *bug Path Protocol
bug_path_protocol:
  description: "Quick bug diagnosis → express mini-handoff to Blake"
  trigger: "Intent Router routes to bug mode"

  # ⚠️ NO code exemption — Alex NEVER writes implementation code, even for bugs
  # This was explicitly decided during expert review (P0-1 fix)
  code_policy: "diagnose_only"

  execution:
    step1:
      name: "Understand the Bug"
      action: |
        Ask user to describe the bug:
        - What happened? (symptoms)
        - What was expected?
        - When does it happen? (steps to reproduce)
        If user provides enough info, proceed. If not, ask clarifying questions.

    step2:
      name: "Diagnose"
      action: |
        Read relevant code files.
        Optionally call bug-hunter subagent for complex issues.
        Identify root cause and affected files.
        Output diagnosis to user:
        - Root cause
        - Affected files
        - Proposed fix approach
        - Severity assessment (simple / complex)

    step3:
      name: "Propose Action"
      action: |
        Use AskUserQuestion:
        "I've diagnosed the issue. How would you like to proceed?"
        Options:
        - "Create express mini-handoff for Blake" → step4_handoff
        - "I understand now, I'll handle it myself" → step5_record
        - "This is bigger than a bug — start *analyze" → transition to analyze path

    step4_handoff:
      name: "Generate Express Mini-Handoff"
      action: |
        Create a lightweight handoff in .tad/active/handoffs/HANDOFF-{date}-bugfix-{slug}.md

        Mini-handoff template:
        ```
        # Mini-Handoff: Bugfix — {title}
        **From:** Alex | **To:** Blake | **Date:** {date}
        **Type:** Express Bugfix (skip Socratic, skip expert review)
        **Priority:** {P0/P1/P2}

        ## Bug Description
        {user's description + symptoms}

        ## Root Cause Analysis
        {Alex's diagnosis from step2}

        ## Proposed Fix
        {specific changes: file, line range, what to change}

        ## Affected Files
        {list of files}

        ## Acceptance Criteria
        - [ ] Bug no longer reproduces under reported conditions
        - [ ] No regression in related functionality

        ## Blake Instructions
        - This is an express bugfix — no Socratic inquiry or expert review needed
        - Apply fix → run Ralph Loop Layer 1 (self-check) → verify AC → done
        - If fix turns out to be more complex than described, escalate to user
        ```

        Generate Blake message (same format as standard handoff step7).

    step5_record:
      name: "Record"
      action: |
        If mini-handoff created:
          Add to NEXT.md In Progress: "- [ ] Bugfix: {description} (mini-handoff to Blake)"
        If user handled it themselves:
          No action needed (user manages their own work)
```

### Task 4: Define Discuss Path Protocol in tad-alex.md

**File**: `.claude/commands/tad-alex.md`

**Add section**:

```yaml
# *discuss Path Protocol
discuss_path_protocol:
  description: "Free-form discussion mode — Alex as product/tech consultant"
  trigger: "Intent Router routes to discuss mode"

  behavior:
    persona: "Consultant / Thought Partner (not Solution Lead executing a process)"
    style: |
      - Ask questions to understand the user's thinking
      - Offer perspectives and trade-offs
      - Challenge assumptions constructively
      - Do NOT steer toward handoff creation
      - Do NOT run Socratic Inquiry protocol
      - Do NOT run Adaptive Complexity assessment

    # P0-3 FIX: Explicit allowed/forbidden to avoid conflict with Research Protocol
    allowed:
      - "Reading code files to understand context"
      - "Searching codebase for relevant patterns (Grep/Glob)"
      - "Using WebSearch/WebFetch for background research"
      - "Summarizing findings and presenting trade-offs"
      - "Updating NEXT.md or PROJECT_CONTEXT.md with discussion conclusions"
      - "Invoking research subagent (Explore) for deep investigation"
    forbidden:
      - "Auto-generating handoff or design documents"
      - "Running Gate checks"
      - "Suggesting 'let me create a handoff for this'"
      - "Creating HANDOFF-*.md files"
      - "Running Socratic Inquiry protocol"
      - "Writing implementation code"
    note_on_research_protocol: |
      *discuss mode and research_decision_protocol (Cognitive Firewall) are COMPATIBLE:
      - If a discussion surfaces a technical decision with risk implications,
        the research_decision_protocol still applies (research → present options → let human decide)
      - The difference: *discuss does not FORCE research protocol on every topic,
        only on topics that match Cognitive Firewall triggers (architecture, dependency, security decisions)

  # P1 FIX: Soft checkpoint for long discussions
  soft_checkpoint:
    trigger: "After 6+ exchanges (user messages) in discuss mode without natural conclusion"
    action: |
      Gently check in (NOT a forced exit):
      "We've been discussing for a while. Quick check — want to keep going, or capture what we have so far?"
      This is a SOFT prompt, not blocking. If user continues the conversation, Alex follows along.

  exit_protocol:
    trigger: "User signals they want to wrap up, OR natural conclusion reached"
    action: |
      Use AskUserQuestion:
      "Discussion seems to be wrapping up. Would you like to capture anything?"
      Options:
      - "Record conclusions to NEXT.md" → append summary to NEXT.md
      - "Create an idea from this" → switch to idea_path_protocol
      - "This needs proper design — start *analyze" → switch to adaptive_complexity_protocol
      - "No need to record, just a chat" → end, return to Alex standby
    note: "If user doesn't signal wrap-up, Alex does NOT proactively suggest ending"
```

### Task 5: Define Idea Path Protocol in tad-alex.md

**File**: `.claude/commands/tad-alex.md`

**Add section**:

```yaml
# *idea Path Protocol
idea_path_protocol:
  description: "Lightweight idea capture — discuss briefly, store for later"
  trigger: "Intent Router routes to idea mode"

  execution:
    step1:
      name: "Capture"
      action: |
        Let user describe their idea freely.
        If the idea is clear enough, proceed to step2.
        If vague, ask 2-3 lightweight clarifying questions (NOT full Socratic Inquiry):
        - "What problem does this solve?"
        - "Who benefits?"
        - "Any initial thoughts on how it might work?"

    step2:
      name: "Structure"
      action: |
        Organize into a brief structured format:
        - Title (one line)
        - Summary (2-3 sentences)
        - Open questions (things not yet decided)
        - Potential scope (small / medium / large — rough guess)
        Present to user for confirmation.

    step3:
      name: "Store"
      action: |
        # Phase 3 (Idea Pool) not yet built — use NEXT.md for now
        Append to NEXT.md under a new "## Ideas" section (create if not exists):
        - [ ] 💡 {title}: {summary} ({date})

        # FUTURE (Phase 3): Store to .tad/active/ideas/IDEA-{date}-{slug}.md

    step4:
      name: "Next"
      action: |
        Use AskUserQuestion:
        "Idea captured. What's next?"
        Options:
        - "I have another idea" → restart step1
        - "This one I want to do now → start *analyze" → switch to adaptive_complexity_protocol
        - "Done, back to standby" → end
```

### Task 6: Update Alex Commands & Help

**File**: `.claude/commands/tad-alex.md`

**Modify `commands` section** — add 3 new entries:

```yaml
commands:
  # ... existing commands ...

  # Intent-based paths (NEW)
  bug: Quick bug diagnosis — analyze, diagnose, optionally fix or create mini-handoff
  discuss: Free-form discussion — product direction, strategy, technical questions (no handoff)
  idea: Capture an idea for later — lightweight discussion, store to idea pool
```

**Modify `on_start`** — update greeting:

```
Hello! I'm Alex, your Solution Lead.

I can help you in several ways:
- *analyze — Design a new feature (full TAD workflow)
- *bug — Quick bug diagnosis → express handoff to Blake
- *discuss — Free-form product/tech discussion
- *idea — Capture an idea for later

Just describe what you need, and I'll figure out the right mode.
Or use a command directly to skip detection.
```

**Modify `forbidden` section** — NO changes needed (Alex never writes code, including in *bug path). The existing `forbidden` rule "Writing implementation code" remains absolute.

### Task 7: Update CLAUDE.md Usage Scenarios

**File**: `CLAUDE.md`

**Modify §2 table** — add new rows:

```markdown
| `/alex` + `*bug` | Bug found, need quick diagnosis. Alex diagnoses → creates express mini-handoff for Blake |
| `/alex` + `*discuss` | Product direction question, strategy discussion, no handoff needed |
| `/alex` + `*idea` | New idea to capture, not ready for implementation yet |
```

---

## Files to Modify

| File | Change Type | Scope |
|------|-------------|-------|
| `.claude/commands/tad-alex.md` | Major | Add intent_router_protocol, bug_path, discuss_path, idea_path, update commands/help/forbidden |
| `.tad/config-workflow.yaml` | Minor | Add intent_modes section |
| `CLAUDE.md` | Minor | Add 3 rows to §2 usage scenario table |

**No new files created** (all changes are to existing files).

---

## Acceptance Criteria

- [ ] **AC1**: `*bug` command activates bug_path_protocol — Alex diagnoses the issue
- [ ] **AC2**: In `*bug` path, Alex NEVER writes code — only diagnoses and creates express mini-handoff (P0-1 fix)
- [ ] **AC3**: `*bug` can generate express mini-handoff for Blake (lightweight, no Socratic inquiry, uses template from Task 3)
- [ ] **AC4**: `*discuss` command activates discuss_path_protocol — free conversation mode
- [ ] **AC5**: `*discuss` does NOT auto-generate handoff or run Socratic Inquiry
- [ ] **AC5b**: `*discuss` has explicit allowed/forbidden lists; research IS allowed (P0-3 fix)
- [ ] **AC6**: `*discuss` exit offers 4 options (record / idea / analyze / end)
- [ ] **AC6b**: `*discuss` has soft checkpoint after 6+ exchanges (P1 fix)
- [ ] **AC7**: `*idea` command captures idea and appends to NEXT.md Ideas section
- [ ] **AC8**: `*idea` asks 2-3 lightweight questions max (not full Socratic)
- [ ] **AC9**: Without explicit command, Alex uses AskUserQuestion to confirm intent
- [ ] **AC9b**: Signal word priority order is defined (bug > idea > discuss > analyze) (P1 fix)
- [ ] **AC10**: `*analyze` path behavior is identical to current flow (no regression)
- [ ] **AC11**: `*help` displays all 4 paths with descriptions (no *learn in Phase 1)
- [ ] **AC12**: `on_start` greeting mentions 4 modes (not *learn — that's Phase 2) (P1 fix)
- [ ] **AC13**: `config-workflow.yaml` contains `intent_modes` section with signal words + priority order
- [ ] **AC14**: `CLAUDE.md` §2 table includes 3 new usage scenario rows
- [ ] **AC15**: Path transition rules are defined (discuss→analyze, bug→analyze, etc.) (P0-2 fix)
- [ ] **AC16**: Intent Router trigger timing is explicit (after on_start, before adaptive_complexity) (P0-2 fix)
- [ ] **AC17**: `forbidden` section in tad-alex.md remains unchanged — no code exemption for *bug

---

## Important Notes

### Critical Warnings
- ⚠️ `tad-alex.md` is already large. New sections should be concise and well-organized.
- ⚠️ Alex NEVER writes implementation code — including in `*bug` path. This is absolute.
- ⚠️ Intent Router must run BEFORE adaptive_complexity_protocol. Only `*analyze` path enters Adaptive Complexity.
- ⚠️ Path transitions from `*analyze` back to other modes are FORBIDDEN (complete or abort first).

### Known Constraints
- `*idea` storage is temporary (NEXT.md) until Phase 3 builds the Idea Pool
- Express mini-handoff for `*bug` is intentionally lightweight — no Socratic inquiry, no expert review
- Signal word lists are initial versions — will be refined through usage
- `*discuss` soft checkpoint (6+ exchanges) is a soft prompt, not blocking

### Sub-Agent Usage
Blake should consider using:
- [ ] **code-reviewer** — review the new protocol sections for consistency with existing patterns
- [ ] **test-runner** — verify no regression in existing *analyze flow

---

## Expert Review Status

| Expert | Status | P0 Issues | P1 Issues |
|--------|--------|-----------|-----------|
| code-reviewer | CONDITIONAL PASS → **P0 FIXED** | P0-1: *bug direct fix violates terminal isolation ✅ FIXED (removed) | P1: *idea storage fragile, signal word overlap |
| backend-architect | CONDITIONAL PASS → **P0 FIXED** | P0-1: *bug code exemption (same as above) ✅ FIXED; P0-2: missing path transitions ✅ FIXED; P0-3: *discuss vs Research Protocol conflict ✅ FIXED | P1: mini-handoff template, soft checkpoint, *learn in on_start |

### P0 Fix Summary
- **P0-1** (both experts): Removed `*bug` direct fix entirely. Alex diagnoses only → express mini-handoff to Blake. User decision: "移除直接修复".
- **P0-2** (backend-architect): Added `path_transitions` section with allowed/forbidden transitions + `trigger_timing` clarification.
- **P0-3** (backend-architect): Added explicit `allowed` and `forbidden` lists to `*discuss` behavior + `note_on_research_protocol` compatibility statement.

### P1 Fix Summary
- Mini-handoff template: Embedded in Task 3 step4_handoff.
- Soft checkpoint: Added to Task 4 (6+ exchanges soft prompt).
- *learn in on_start: Removed (Phase 2).
- Signal word priority: Added `priority_order` to detection config.
- *idea storage fragility: Acknowledged as known constraint (Phase 3 will fix).

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-02-16
**Version**: 3.1.0
