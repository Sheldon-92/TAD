# Handoff: Learning Opportunity (AI→Human Knowledge Transfer)

**From:** Alex (Solution Lead)
**To:** Blake (Execution Master)
**Date:** 2026-02-16
**Task ID:** TASK-20260216-002
**Priority:** P1
**Complexity:** Medium (Standard TAD)
**Status:** Expert Review Complete - Ready for Implementation
**Epic:** EPIC-20260216-alex-flexibility-and-project-mgmt.md (Phase 2/5)

---

## Socratic Inquiry Summary

**Complexity**: Medium | **Rounds**: 2

| Dimension | Question | Decision |
|-----------|----------|----------|
| *learn scope | Task-related only or any topic? | Both — default to task context, but user can specify any topic |
| Post-handoff invite | How detailed? | **Removed** — user self-initiates *learn when they have questions |
| Teaching style | How should Alex teach? | Socratic Teaching — guide with questions, not lectures |
| Persistence | Save learning content? | No — pure conversational, no file writes |
| Integration | *learn as Intent Router path or independent? | Intent Router 5th path — auto-detect + user confirm |
| Re-trigger | Intent Router runs only once or re-triggers? | Re-triggers after every path exit (standby → new message → Intent Router) |

---

## Executive Summary

TAD currently has no AI→Human learning mechanism. When Alex designs a solution using patterns like "Route Before Process" or "Manifest + Directory Isolation", the human gets the output but not the understanding. Phase 2 adds a learning channel:

1. **\*learn path** — A 5th Intent Router mode where Alex becomes a Socratic teacher, guiding users through technical concepts via questions rather than lectures. Users self-initiate when they have questions — no auto-prompting.

Additionally, this handoff addresses a Phase 1 P1 gap: **standby state definition**, **Intent Router re-trigger** after path completion, and **idle message detection** to prevent unnecessary routing.

**Key design decision**: *learn is integrated into the Intent Router (5 modes total), not a standalone command. Signal words like "学习", "teach me", "concept", "原理" trigger detection. Post-handoff learning invite was removed — user self-initiates learning via *learn command.

---

## Current State (What Exists)

In `tad-alex.md`:
- `intent_router_protocol` has 4 modes (bug/discuss/idea/analyze)
- `step3` AskUserQuestion shows 4 options
- `commands` section has no `learn` entry
- `on_start` lists 4 modes, no *learn
- Path exits say "return to Alex standby" but standby is undefined
- No re-trigger mechanism defined
- No idle message detection (non-task messages trigger full Intent Router)

In `config-workflow.yaml`:
- `intent_modes.modes` has 4 entries (bug/discuss/idea/analyze)
- No `learn` mode defined

In `CLAUDE.md`:
- §2 table has 3 Alex intent rows (*bug/*discuss/*idea), no *learn

---

## Target State (What We Want)

### Updated Flow Architecture

```
User input arrives (after on_start OR after path exit → standby)
       ↓
┌──────────────────────────────────────┐
│      Intent Router (UPDATED)         │
│                                      │
│  Step 1: Check explicit command      │
│    *bug → Bug Path                   │
│    *discuss → Discuss Path           │
│    *idea → Idea Path                 │
│    *learn → Learn Path (NEW)         │
│    *analyze → Standard TAD           │
│                                      │
│  Step 1.5: Idle detection (NEW)      │
│    "谢谢"/"ok"/"好的" → brief reply  │
│    → Stay in standby, no routing     │
│                                      │
│  Step 2: No command detected         │
│    → Signal word analysis            │
│    → AskUserQuestion (4 options)     │
│    → Route to chosen path            │
└──────────────────────────────────────┘
```

---

## Task Breakdown

### Task 1: Add `learn` mode to config-workflow.yaml

**File**: `.tad/config-workflow.yaml`

**Modify `intent_modes.modes`** — add new entry after `idea`:

```yaml
    learn:
      command: "*learn"
      label: "Learn"
      icon: "📚"
      description: "Socratic teaching — understand concepts through guided questions"
      signal_words:
        zh: ["学习", "教我", "为什么", "怎么理解", "原理", "解释一下", "什么意思", "学一下"]
        en: ["learn", "teach me", "why", "explain", "how does", "understand", "what is", "concept"]
      leads_to_handoff: "never"  # learning never produces handoff
```

**Modify `intent_modes.detection.priority_order`** — insert `learn` between `discuss` and `analyze`:

```yaml
    priority_order: ["bug", "idea", "discuss", "learn", "analyze"]
```

Rationale: `learn` is lower priority than `discuss` (if user says "let's discuss why X works", that's discuss, not learn). Higher than `analyze` (which is the fallback).

### Task 2: Add Learn Path Protocol to tad-alex.md

**File**: `.claude/commands/tad-alex.md`

**Add section** after `idea_path_protocol`:

```yaml
# *learn Path Protocol
learn_path_protocol:
  description: "Socratic teaching mode — guide user to understand concepts through questions"
  trigger: "Intent Router routes to learn mode"

  behavior:
    persona: "Teacher / Mentor (not Solution Lead executing a process)"
    style: "socratic"
    principles:
      - "Ask questions to check current understanding before explaining"
      - "Build from what the user already knows"
      - "Use the current project as context when possible"
      - "Break complex topics into digestible pieces"
      - "Never lecture for more than 3-4 sentences without checking comprehension"

    allowed:
      - "Reading project code to find concrete examples"
      - "Using WebSearch for reference material"
      - "Drawing analogies to concepts user already understands"
      - "Creating small conceptual diagrams (ASCII/text)"
    forbidden:
      - "Writing implementation code"
      - "Creating handoffs or design documents"
      - "Running Gate checks"
      - "Modifying any project files"

  execution:
    step1:
      name: "Identify Topic"
      action: |
        If user specified a topic (e.g., "*learn Router Pattern"):
          → Use that topic directly
        If no specific topic:
          → Check recent context (current session, last handoff, project-knowledge)
          → Suggest 2-3 relevant topics from recent work
          → Use AskUserQuestion:
            "What would you like to learn about?"
            Options: [recent topic 1, recent topic 2, "Something else (type your topic)"]

    step2:
      name: "Assess Understanding"
      action: |
        Ask 1-2 questions to gauge current knowledge level:
        - "What do you already know about {topic}?"
        - "Have you used {topic} before, or is this completely new?"
        Adjust depth based on response.

    step3:
      name: "Teach (Socratic Loop)"
      action: |
        Repeat until user signals they're satisfied:
        1. Ask a guiding question that leads toward a key insight
        2. Based on user's answer:
           - If correct → affirm, add nuance, move to next concept
           - If partially correct → ask a follow-up that reveals the gap
           - If incorrect → provide a brief hint, ask again from different angle
        3. After each concept, provide a concrete example from the project if possible
        4. Check: "Does this make sense? Want to go deeper or move on?"

        Keep each exchange SHORT (2-4 sentences from Alex, then a question).

    step4:
      name: "Wrap Up"
      action: |
        Summarize key takeaways (3-5 bullet points).
        Optionally suggest related topics.
        Use AskUserQuestion:
        "Learning session done. What's next?"
        Options:
        - "Learn another topic" → restart step1
        - "Back to work — start *analyze" → transition to analyze path
        - "Done, back to standby" → exit to standby
```

### Task 3: Define Standby State + Idle Detection + Intent Router Re-trigger

**File**: `.claude/commands/tad-alex.md`

**Location**: Add to `intent_router_protocol` section

**3a. Add idle detection to step1** — insert new step1.5 after step1 (explicit command check):

```yaml
    step1_5:
      name: "Idle Detection"
      action: |
        Before running signal word analysis, check if user input is a non-task message:

        Idle patterns (not exhaustive, use judgment):
        - zh: ["谢谢", "ok", "好的", "收到", "明白了", "嗯", "知道了", "没问题"]
        - en: ["thanks", "ok", "got it", "sure", "cool", "noted", "understood"]

        If input matches idle pattern (short message, no task content):
          → Respond briefly and naturally (e.g., "好的！有新任务随时告诉我。")
          → Stay in standby — do NOT proceed to step2
          → Do NOT trigger AskUserQuestion

        If input has task content beyond idle words:
          → Proceed to step2 (signal word analysis)
```

**3b. Add standby subsection** after `path_transitions`:

```yaml
  # Standby State Definition (P1 fix from Phase 1)
  standby:
    definition: |
      "Alex standby" means:
      1. Current path context is cleared (no active *bug/*discuss/*idea/*learn/*analyze)
      2. Session remains active (Alex persona still loaded)
      3. Any new user input triggers Intent Router fresh (step1: check explicit command)
      4. No state carries over from previous path except conversation history

    enters_standby:
      - "After *bug step5_record completes"
      - "After *discuss exit_protocol: user selects 'No need to record'"
      - "After *discuss exit_protocol: user selects 'Record conclusions to NEXT.md' (after recording)"
      - "After *idea step4: user selects 'Done, back to standby'"
      - "After *learn step4: user selects 'Done, back to standby'"
      - "After *analyze handoff step7 completes"
      - "After any path transition fails or is cancelled"

    on_new_input_in_standby: |
      When user sends a new message while Alex is in standby:
      → Run Intent Router from step1 (full detection cycle, including step1.5 idle check)
      → This is AUTOMATIC — no need for user to say "start over" or re-invoke /alex
      → Idle messages (step1.5) get brief response without triggering full routing
```

**3c. Modify each path's exit point** to reference standby explicitly:

- `bug_path_protocol.step5_record` → append: `→ Enter standby`
- `discuss_path_protocol.exit_protocol` → each "end" option → append: `→ Enter standby`
- `idea_path_protocol.step4` → "Done, back to standby" → append: `→ Enter standby (Intent Router re-triggers on next input)`
- `learn_path_protocol.step4` → same

### Task 4: Update Intent Router for 5 Modes

**File**: `.claude/commands/tad-alex.md`

**Modify `intent_router_protocol.execution.step1`** — add `*learn` to explicit commands:

```yaml
    step1:
      name: "Check Explicit Command"
      action: |
        If user input starts with *bug, *discuss, *idea, *learn, or *analyze:
          → Skip detection, go directly to the corresponding path
          → For *analyze: proceed to adaptive_complexity_protocol (existing flow)
```

**Modify `intent_router_protocol.execution.step3`** — update AskUserQuestion for 5 modes with 4-option limit:

```yaml
    step3:
      name: "User Confirmation (ALWAYS)"
      action: |
        Use AskUserQuestion to confirm detected intent.

        5-mode display strategy (AskUserQuestion 4-option limit):
        1. Option 1: {detected_mode} (Recommended) — always first
        2. Options 2-3: next 2 modes by signal match count (descending)
        3. Option 4: analyze — ALWAYS included as fallback/default
        4. Drop: the mode with lowest signal match (if not already shown)

        Exception: if detected_mode IS analyze, show analyze as recommended
        and fill options 2-4 with the 3 modes that had highest signal counts.

        AskUserQuestion({
          questions: [{
            question: "我判断这是一个 {detected_mode_label} 场景。你想怎么处理？",
            header: "Intent",
            options: [
              {label: "{detected_mode} (Recommended)", description: "{mode_description}"},
              {label: "{2nd_mode}", description: "{description}"},
              {label: "{3rd_mode}", description: "{description}"},
              {label: "analyze", description: "Standard TAD workflow (fallback)"}
            ],
            multiSelect: false
          }]
        })

        Note: User can always type *learn (or any mode) directly via "Other" if their
        desired mode was dropped from the 4 options.
```

**Modify `intent_router_protocol.execution.step4`** — add learn route:

```yaml
    step4:
      name: "Route"
      action: |
        Based on user's choice:
        - bug → Enter bug_path_protocol
        - discuss → Enter discuss_path_protocol
        - idea → Enter idea_path_protocol
        - learn → Enter learn_path_protocol
        - analyze → Enter adaptive_complexity_protocol (existing, unchanged)
```

### Task 5: Update Commands, on_start, Quick Reference

**File**: `.claude/commands/tad-alex.md`

**Modify `commands` section** — add learn:

```yaml
  # Intent-based paths (v2.4 → v2.5)
  bug: Quick bug diagnosis — analyze, diagnose, create express mini-handoff for Blake
  discuss: Free-form discussion — product direction, strategy, technical questions (no handoff)
  idea: Capture an idea for later — lightweight discussion, store to NEXT.md Ideas section
  learn: Socratic teaching — understand technical concepts through guided questions
```

**Modify `on_start`**:

```
Hello! I'm Alex, your Solution Lead.

I can help you in several ways:
- *analyze — Design a new feature (full TAD workflow)
- *bug — Quick bug diagnosis → express handoff to Blake
- *discuss — Free-form product/tech discussion
- *idea — Capture an idea for later
- *learn — Understand a technical concept (Socratic teaching)

Just describe what you need, and I'll figure out the right mode.
Or use a command directly to skip detection.
```

**Modify Quick Reference** — add *learn to Key Commands:

```
- `*learn` - Socratic teaching — understand concepts through guided questions
```

**Modify "Remember" section**:

```
- I route intent first (*bug / *discuss / *idea / *learn / *analyze)
```

### Task 6: Update CLAUDE.md Usage Scenarios

**File**: `CLAUDE.md`

**Modify §2 table** — add new row after *idea:

```markdown
| `/alex` + `*learn` | Want to understand a technical concept — Socratic teaching mode |
```

---

## Files to Modify

| File | Change Type | Scope |
|------|-------------|-------|
| `.claude/commands/tad-alex.md` | Major | Add learn_path_protocol, idle detection (step1.5), standby definition, update Intent Router to 5 modes, update commands/on_start/reference |
| `.tad/config-workflow.yaml` | Minor | Add learn mode to intent_modes, update priority_order |
| `CLAUDE.md` | Minor | Add 1 row to §2 usage scenario table |

**No new files created** (all changes are to existing files).

---

## Acceptance Criteria

### *learn Path (Tasks 1-2)
- [ ] **AC1**: `*learn` command activates learn_path_protocol — Socratic teaching mode
- [ ] **AC2**: `*learn` is detected by Intent Router signal words (zh: "学习", "教我", "为什么" etc.)
- [ ] **AC3**: `*learn` uses Socratic style — asks questions before explaining, checks comprehension
- [ ] **AC4**: `*learn` can use project code as examples (reads files, doesn't modify)
- [ ] **AC5**: `*learn` never creates handoffs, design docs, or modifies files
- [ ] **AC6**: `*learn` exit offers 3 options (learn more / *analyze / standby)
- [ ] **AC7**: config-workflow.yaml has `learn` mode with signal words
- [ ] **AC8**: priority_order updated to include learn (bug > idea > discuss > learn > analyze)

### Standby + Idle Detection (Task 3)
- [ ] **AC9**: Standby state is explicitly defined with enter conditions and re-trigger behavior
- [ ] **AC10**: All path exits reference standby explicitly
- [ ] **AC11**: New user message in standby triggers Intent Router from step1
- [ ] **AC12**: Idle messages ("谢谢"/"ok"/"好的" etc.) get brief response WITHOUT triggering full Intent Router
- [ ] **AC13**: Idle detection does NOT block real task messages that happen to contain idle words

### Intent Router 5-Mode Update (Task 4)
- [ ] **AC14**: Intent Router step3 shows 4 options: recommended + 2 most relevant + analyze (always)
- [ ] **AC15**: Intent Router step1 recognizes `*learn` as explicit command
- [ ] **AC16**: Intent Router step4 routes `learn` to learn_path_protocol

### Surface Updates (Tasks 5-6)
- [ ] **AC17**: on_start greeting lists 5 modes including *learn
- [ ] **AC18**: CLAUDE.md §2 has *learn row
- [ ] **AC19**: `*help` and Quick Reference updated with *learn
- [ ] **AC20**: *analyze path behavior unchanged (no regression)

---

## Important Notes

### Critical Warnings
- ⚠️ `tad-alex.md` is already ~1760 lines. New sections should be concise.
- ⚠️ AskUserQuestion has a 4-option limit. Intent Router step3 with 5 modes: recommended + 2 relevant + analyze (always). Drop the least-likely mode.
- ⚠️ Standby idle detection must be conservative — only short, clearly non-task messages. Longer messages with idle words + task content should still route.
- ⚠️ Signal word overlap between *discuss and *learn ("为什么", "explain") is INTENTIONAL — resolved by AskUserQuestion confirmation step + priority_order (discuss > learn).

### Known Constraints
- *learn persistence deferred — no file writes in Phase 2 (may revisit in future)
- Standby definition is documentation-only (no code enforcement possible in agent protocol files)
- Idle detection is heuristic-based — may occasionally misclassify

### Sub-Agent Usage
Blake should consider using:
- [ ] **code-reviewer** — review protocol consistency with Phase 1 patterns
- [ ] **test-runner** — verify 20 ACs, especially no regression on existing 4 modes

---

## Expert Review Status

| Expert | Status | P0 Issues | P1 Issues |
|--------|--------|-----------|-----------|
| code-reviewer | CONDITIONAL PASS → **PASS (P0 resolved)** | 4 P0 (all resolved) | 5 P1 |
| backend-architect | CONDITIONAL PASS → **PASS (P0 resolved)** | 2 P0 (all resolved) | 3 P1 |

### P0 Resolution Summary

| P0 | Source | Issue | Resolution |
|----|--------|-------|------------|
| P0-1 | Both | step8_learning_invite conflicts with step7 STOP | **Removed**: step8 deleted entirely. User self-initiates *learn |
| P0-2 | Both | Standby idle messages trigger full Intent Router | **Fixed**: Added step1.5 idle detection before signal analysis |
| P0-3 | code-reviewer | Signal word overlap (*discuss/*learn: "为什么", "explain") | **By design**: Overlap kept intentionally, AskUserQuestion confirmation + priority_order resolves |
| P0-4 | code-reviewer | AskUserQuestion 5-mode display with 4-option limit | **Fixed**: Recommended + 2 most relevant + analyze (always). Drop lowest. User can type *learn via "Other" |

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-02-16
**Status**: Expert Review Complete - Ready for Implementation
**Version**: 3.2.0
