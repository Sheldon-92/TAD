# /tad Command (TAD Framework v2.5.0 Main Entry)

When this command is triggered, provide TAD framework guidance and options:

## TAD Framework v2.5.0
**Triangle Agent Development — Beneficial Friction for AI-Assisted Development**

```
Welcome to TAD v2.5.0 — Beneficial Friction + Ralph Loop

        Human (You)
         /\
        /  \
       /    \
      /      \
Alex -------- Blake
(Design)    (Execute)
```

## Quick Start Options

Please select an option (0-8):

```
0. Initialize TAD in current project (/tad-init)
1. Activate Agent A - Alex (/alex)
2. Activate Agent B - Blake (/blake)
3. Start requirement elicitation (/elicit)
4. Execute quality gate (/gate)
5. Create/verify handoff (/handoff)
6. Start parallel execution (/parallel)
7. Show TAD status (/tad-status)
8. View help documentation (/tad-help)

Select 0-8:
```

## Key Features in v2.5.0

### 🆕 v2.5.0 Additions
- **Beneficial Friction Philosophy**: AI executes, humans guard value at 3 critical friction points
- **Pair Testing Protocol**: Cross-tool E2E testing (TAD CLI → Claude Desktop)
- **Pair Testing**: All files in `.tad/pair-testing/` (Brief, Report, Screenshots)

### ✅ Earlier Highlights (Preserved)
- **Modular Config**: config.yaml split into 6 modules with per-command binding
- **Bidirectional Messages**: Structured copy-pasteable messages between Alex ↔ Blake
- **Adaptive Complexity**: Auto-suggest process depth (Light/Standard/Full/Skip TAD)
- **Blake Auto-Detect**: Scans for active handoffs on startup

### 🔄 v2.0 Highlights (Preserved)
- **Ralph Loop**: Blake's iterative quality cycle (Layer 1 self-check + Layer 2 expert review)
- **Gate 3 v2 Expanded**: All technical quality checks consolidated
- **Gate 4 v2 Simplified**: Pure business acceptance by Alex
- **Circuit Breaker**: Auto-escalate after 3 same errors
- **State Persistence**: Resume from crash without losing progress

### 🎯 Core Mechanisms
- **4-Gate Quality System**: Systematic quality control with evidence
- **Socratic Inquiry**: Alex must use AskUserQuestion before writing handoffs
- **Expert Handoff Review**: 2+ experts review handoff before Blake executes
- **Knowledge Accumulation**: Project learns from every feature
- **Parallel Execution**: 40%+ time savings via parallel-coordinator

## Slash Commands Available

### Agent Activation
- `/alex` - Activate Agent A (Solution Lead)
- `/blake` - Activate Agent B (Execution Master)

### Core Workflows
- `/elicit` - Start requirement gathering (Socratic inquiry)
- `/handoff` - Create/verify handoff document
- `/gate` - Execute quality gate
- `/parallel` - Start parallel execution

### Utility
- `/tad-init` - Initialize TAD for a project
- `/tad-status` - Check TAD installation and configuration
- `/tad-help` - View help documentation
- `/tad-maintain` - Document health check, sync, and cleanup
- `/tad-test-brief` - Generate test brief for E2E testing
- `/knowledge-audit` - Audit project knowledge files

### Quick Sub-agent Access
- `/product` - Launch product-expert
- `/coordinator` - Launch parallel-coordinator

## Typical Workflow

1. **Terminal 1**: `/alex` → Activate Agent A
   - Socratic inquiry → Gather requirements (adaptive questions)
   - `*design` → Create technical design with expert review
   - `*handoff` → Generate handoff for Blake

2. **Terminal 2**: `/blake` → Activate Agent B
   - Verify handoff from Alex (auto-detect on startup)
   - `*develop` → Ralph Loop (Layer 1 + Layer 2)
   - Gate 3 v2 → Technical verification
   - Report to Alex for Gate 4 v2

## Quality Gates (Mandatory)

| Gate | Owner | When | Purpose |
|------|-------|------|---------|
| Gate 1 | Alex | After elicitation | Requirements clarity |
| Gate 2 | Alex | Before handoff | Design completeness (with expert review) |
| Gate 3 | Blake | After Ralph Loop | Implementation & integration quality |
| Gate 4 | Alex | After Gate 3 | Acceptance & archive (business-only) |

## Success Patterns

✅ **Always Do:**
- Use Socratic inquiry before designing
- Search existing code before designing
- Use `*develop` for implementation (triggers Ralph Loop)
- Use parallel-coordinator for multi-component tasks
- Collect evidence at every step
- Record knowledge discoveries in Gate results

❌ **Never Do:**
- Skip Socratic inquiry
- Let Alex write code
- Start Blake without handoff
- Bypass Ralph Loop for implementation
- Skip quality gates
- Omit Knowledge Assessment from Gate results

## Need Help?

- **Documentation**: `/tad-help`
- **Check Status**: `/tad-status`
- **Select Scenario**: `/tad-scenario`
- **View Evidence**: Check `.tad/evidence/`
- **Project Knowledge**: See `.tad/project-knowledge/`

## Remember

TAD v2.5.0 combines:
- 🎯 **Beneficial Friction**: Humans guard value at 3 critical points
- ⚡ **Simplicity**: Only 3 roles (Human, Alex, Blake)
- 🔄 **Ralph Loop**: Iterative quality with expert exit conditions
- 🧪 **Evidence**: Mandatory at every gate
- 📐 **Adaptive**: Scale process to task complexity
- ✅ **Quality**: 4-gate system with knowledge accumulation

[[LLM: This is the main entry point for TAD v2.5.0. When invoked, present these options and guide the user through TAD's workflow with Beneficial Friction, Ralph Loop, and Adaptive Complexity.]]
