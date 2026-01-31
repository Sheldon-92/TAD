# TAD Method - Triangle Agent Development

**Version 2.1.1 - Document Lifecycle Management**

> 🚀 **TAD v2.1.1** adds **`/tad-maintain`** - automated document health checks and stale handoff detection.
>
> 📚 **[Documentation Portal](docs/README.md)** | **[Multi-Platform Guide](docs/MULTI-PLATFORM.md)** | **[Ralph Loop Guide](docs/RALPH-LOOP.md)** | [Version History](#version-history)

---

## 🎯 What's New in v2.1.1

### `/tad-maintain` Command (NEW)
- **3 Modes**: CHECK (read-only scan), SYNC (scoped writes), FULL (comprehensive)
- **Handoff Lifecycle Audit**: 4 detection criteria
  - Criterion A/B: Slug-based completion and version matching (auto)
  - Criterion C: Age-based stale detection (>7 days, user confirms)
  - Criterion D: Topic cross-reference against archived handoffs (user confirms)
- **NEXT.md Monitoring**: Size thresholds, automatic archival to `docs/HISTORY.md`
- **PROJECT_CONTEXT.md Sync**: Auto-create and keep in sync
- **Auto-triggers**: Runs on agent activation, `*exit`, and `*accept`

### Simplified Architecture (Changed in v2.1.1)
- Removed `.tad/adapters/` directory — all conversion logic now in `/tad-init`
- Removed command converter templates — simpler, more maintainable

### Multi-Platform Support (from v2.1.0)
- **Claude Code**: Full subagent support (primary)
- **Codex CLI**: Self-check mode with native SKILL.md support
- **Gemini CLI**: Self-check mode with TOML commands
- **8 Platform-Agnostic Skills**: testing, code-review, security-audit, performance, ux-review, architecture, api-design, debugging
- **Automatic Platform Detection**: Installation script detects and configures all tools

### From v2.0 (Retained)
- **Ralph Loop**: Autonomous quality cycles with expert review
- **Gate 3 v2 (Expanded)**: Technical Quality (Layer 1 + Layer 2)
- **Gate 4 v2 (Simplified)**: Pure Alex Acceptance + Archive
- Socratic Inquiry Protocol
- Terminal Isolation (Alex=T1, Blake=T2)
- Knowledge Assessment (mandatory for gates)

---

## 🚀 Installation & Upgrade

### One Command for Everything

```bash
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/tad.sh | bash
```

This smart script automatically:
- **Detects platforms**: Claude Code, Codex CLI, Gemini CLI
- **Fresh install**: Creates complete TAD structure for all detected platforms
- **Upgrade**: Detects current version and upgrades in place
- **Preserves data**: Your handoffs, learnings, and evidence are never overwritten
- **Rollback on failure**: Automatic backup and restore if anything goes wrong

### What Gets Installed

```
your-project/
├── .tad/
│   ├── config.yaml              # v2.1.1 configuration
│   ├── skills/                  # Platform-agnostic skills (8 P0 skills)
│   │   ├── testing/SKILL.md
│   │   ├── code-review/SKILL.md
│   │   ├── security-audit/SKILL.md
│   │   ├── performance/SKILL.md
│   │   ├── ux-review/SKILL.md
│   │   ├── architecture/SKILL.md
│   │   ├── api-design/SKILL.md
│   │   └── debugging/SKILL.md
│   ├── ralph-config/            # Ralph Loop configuration
│   ├── templates/               # Handoff, completion, output format templates
│   ├── active/handoffs/         # Active handoff documents
│   ├── archive/handoffs/        # Completed handoffs
│   ├── project-knowledge/       # Project-specific learnings
│   └── evidence/reviews/        # Gate evidence files
├── .claude/                     # Claude Code configuration
│   ├── commands/                # Slash commands (/alex, /blake, /gate)
│   └── skills/                  # Claude-enhanced skills
├── .codex/                      # Codex CLI configuration (if detected)
│   └── prompts/                 # TAD commands for Codex
├── .gemini/                     # Gemini CLI configuration (if detected)
│   └── commands/                # TAD commands in TOML format
├── CLAUDE.md                    # Project rules for Claude Code
├── AGENTS.md                    # Project rules for Codex CLI (if detected)
└── GEMINI.md                    # Project rules for Gemini CLI (if detected)
```

### Manual Installation

```bash
git clone https://github.com/Sheldon-92/TAD.git .tad-temp
cp -r .tad-temp/.tad ./
cp -r .tad-temp/.claude ./
cp .tad-temp/CLAUDE.md ./
rm -rf .tad-temp
```

### Verify Installation

```bash
# Check version
cat .tad/version.txt
# Should show: 2.1.1

# Check skills
ls .tad/skills/
# Should show: 8 skill directories

# Check /tad-maintain command (v2.1.1)
cat .claude/commands/tad-maintain.md | head -1
# Should show: # TAD Maintain Command
```

---

## ⚡ Quick Start (5 minutes)

### 1. Install TAD
```bash
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/tad.sh | bash
```

### 2. Open Two Terminals

| Terminal 1 | Terminal 2 |
|------------|------------|
| `/alex` | `/blake` |
| Design & Planning | Implementation |

### 3. Start Collaboration

**Terminal 1 (Alex):**
```
You: I want to add user authentication
Alex: [Uses AskUserQuestion to clarify requirements]
Alex: [Creates handoff after Socratic inquiry]
Alex: "Handoff ready. Please tell Blake to execute it in Terminal 2."
```

**Terminal 2 (Blake):**
```
You: Execute the auth handoff
Blake: [Reads handoff, implements, runs Gate 3/4]
Blake: [Creates completion report]
```

**Terminal 1 (Alex):**
```
You: Blake finished, here's the completion report
Alex: [Reviews with subagents, accepts or requests changes]
```

---

## 🔺 The Triangle Model

```
           Human
       (Value Guardian)
            /\
           /  \
          /    \
         /      \
   Agent A ──── Agent B
  (Solution)  (Execution)
   Terminal 1  Terminal 2
```

### Human - The Value Guardian
- **Defines** what is valuable for users
- **Bridges** information between Alex and Blake
- **Decides** when conflicts arise
- **Verifies** final delivery meets expectations

### Agent A (Alex) - Solution Lead
- **Elicits** requirements through Socratic inquiry
- **Designs** solutions with expert review
- **Creates** handoffs for Blake
- **Owns** Gate 1 (Requirements) & Gate 2 (Design)

### Agent B (Blake) - Execution Master
- **Implements** based on handoff only
- **Tests** with mandatory subagent calls
- **Owns** Gate 3 (Implementation) & Gate 4 (Integration)
- **Reports** completion for Alex review

---

## 🚦 4-Gate Quality System (v2.0)

| Gate | Name | Owner | What Changed in v2.0 |
|------|------|-------|----------------------|
| Gate 1 | Requirements Clarity | Alex | (unchanged) |
| Gate 2 | Design Completeness | Alex | (unchanged) |
| **Gate 3 v2** | **Implementation + Integration** | **Blake** | **Expanded: includes old Gate 4 Part A** |
| **Gate 4 v2** | **Acceptance + Archive** | **Alex** | **Simplified: pure business acceptance** |

### Gate 3 v2 (Blake - Technical Quality)

**Layer 1 (Self-Check):**
- build, test, lint, tsc
- Max 15 retries with circuit breaker

**Layer 2 (Expert Review):**
- Group 1: `code-reviewer` (blocking)
- Group 2: `test-runner`, `security-auditor`, `performance-optimizer` (parallel)
- Max 5 rounds with escalation to Alex

**Evidence Required:**
- All expert review files in `.tad/evidence/reviews/`
- Iteration evidence in `.tad/evidence/ralph-loops/`
- Knowledge assessment

### Gate 4 v2 (Alex - Business Acceptance)

**What Alex Verifies:**
- Handoff requirements satisfied
- Business value delivered
- User acceptance confirmed

**Actions:**
- Archive handoff to `.tad/archive/handoffs/`
- Record final knowledge assessment

---

## 📋 Key Commands

| Command | Agent | Purpose |
|---------|-------|---------|
| `/alex` | - | Activate Alex (Solution Lead) |
| `/blake` | - | Activate Blake (Execution Master) |
| `/gate N` | Both | Execute quality gate N |
| `/knowledge-audit` | Both | Audit project knowledge health |
| `/tad-init` | - | Initialize TAD in new project |
| `/tad-maintain` | - | Document health check and sync |
| `/tad-learn` | Both | Record framework improvement |

### Alex Commands (use `*` prefix)
- `*analyze` - Start requirement elicitation
- `*design` - Create technical design
- `*handoff` - Generate handoff with expert review
- `*review` - Review Blake's completion
- `*accept` - Accept and archive handoff

### Blake Commands (use `*` prefix)
- `*develop` - Start Ralph Loop (auto Layer 1 + Layer 2) **(NEW)**
- `*implement` - Start implementation from handoff
- `*layer1` - Run Layer 1 self-checks only
- `*layer2` - Run Layer 2 expert review only
- `*ralph-status` - Check Ralph Loop state **(NEW)**
- `*ralph-resume` - Resume from checkpoint **(NEW)**
- `*gate 3` - Execute Gate 3 v2 (technical quality)
- `*complete` - Generate completion report

---

## 📚 Project Knowledge System

TAD captures project-specific learnings in `.tad/project-knowledge/`:

```
.tad/project-knowledge/
├── README.md           # How to use knowledge system
├── ux.md               # UX patterns and decisions
├── code-quality.md     # Code standards learned
├── security.md         # Security considerations
├── architecture.md     # Architectural decisions
└── [custom].md         # Create new categories as needed
```

### Knowledge Capture Flow
1. Gate 3/4 passes
2. Agent assesses: "Did I learn something project-specific?"
3. If yes → Record in appropriate category
4. If no → Skip (don't record obvious/generic knowledge)

### `/knowledge-audit` Command
Run periodically to check knowledge health:
- Files with content vs empty
- Missing foundational sections
- Categories needing attention

---

## 🔄 Version History

| Version | Key Features |
|---------|--------------|
| **v2.1.1** | **`/tad-maintain`, Stale Detection (Criterion C/D), Simplified Adapters** |
| v2.1.0 | Agent-Agnostic Architecture, Multi-Platform Support, 8 P0 Skills |
| v2.0 | Ralph Loop Fusion, Gate 3/4 Restructure, Tiered Timeout |
| v1.8 | Socratic Inquiry, Terminal Isolation, Knowledge Assessment |
| v1.6 | Evidence-Based Gates, Output Templates, Skills Architecture |
| v1.5 | Project Knowledge System, *accept/*exit protocols |
| v1.4 | Proactive Research, Skills System, Learn Command |
| v1.3 | Evidence-Based Development, Human Empowerment |
| v1.2 | MCP Integration, 16 Sub-agents, 4-Gate System |

---

## 🤔 When to Use TAD

### Use TAD When:
- New feature (>3 files or >1 day work)
- Architecture changes
- Complex multi-step requirements
- Cross-module refactoring

### Skip TAD When:
- Single-file bug fix
- Config changes (.env, versions)
- Documentation updates
- Emergency hotfix

---

## 💡 Key Principles

### 1. Human-in-the-Loop
Human is not just a requester but an active bridge between agents. Information flows through the human.

### 2. Design Before Code
Alex designs completely before Blake implements. No implementation without handoff.

### 3. Evidence-Based Quality
Every gate requires evidence. Subagent reviews are mandatory, not optional.

### 4. Knowledge Accumulation
Project learns from every feature. Patterns captured prevent repeated mistakes.

### 5. Adaptive Complexity
Scale process to task size. Small task = light process. Large task = full TAD.

---

## 🛠 Troubleshooting

### "Alex called /blake in same terminal"
This is a VIOLATION. Alex must stop and instruct human to switch to Terminal 2.

### "Gate failed - no evidence file"
Ensure subagents were called and wrote to `.tad/evidence/reviews/`.

### "Handoff created without Socratic inquiry"
Alex must use AskUserQuestion before writing handoff. Re-run with proper flow.

### "Knowledge files empty"
Run `/knowledge-audit --fix` or manually bootstrap with templates.

---

## 🤝 Contributing

TAD evolves through usage. Use `/tad-learn` to record improvement suggestions:
```
/tad-learn
Category: workflow
Finding: [What you discovered]
Suggestion: [How to improve]
```

Learnings are pushed to `.tad/learnings/pushed/` for framework updates.

---

## 📖 Further Reading

- [Documentation Portal](docs/README.md)
- [Multi-Platform Guide](docs/MULTI-PLATFORM.md)
- [Ralph Loop Guide](docs/RALPH-LOOP.md)
- [Agent Definitions](.claude/commands/)
- [Configuration Guide](.tad/config.yaml)
- [Skills Reference](.tad/skills/README.md)

---

**Welcome to TAD v2.1.1 - Agent-Agnostic Quality-Driven Development.**

*Use your favorite AI coding assistant. TAD adapts to your tools.*
