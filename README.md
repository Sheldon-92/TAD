# TAD Method - Triangle Agent Development

**Version 1.8.0 - Human-in-the-Loop Excellence**

> 🚀 **TAD v1.8** introduces **Socratic Inquiry Protocol**, **Terminal Isolation**, and **Knowledge Assessment** for higher quality human-AI collaboration.
>
> 📚 **[Documentation Portal](docs/README.md)** | [Version History](#version-history)

---

## 🎯 What's New in v1.8

### Socratic Inquiry Protocol (NEW)
- **Mandatory AskUserQuestion**: Before writing any handoff, Alex must use the `AskUserQuestion` tool
- **6 Question Dimensions**: value_validation, boundary_clarification, risk_foresight, acceptance_criteria, user_scenarios, technical_constraints
- **Complexity-Based Depth**: Small (2-3 questions), Medium (4-5), Large (6-8)
- **Blindspot Discovery**: Help users discover requirements they hadn't considered

### Terminal Isolation (NEW)
- **Alex = Terminal 1**: Design, planning, review
- **Blake = Terminal 2**: Implementation, testing, deployment
- **Human Bridge**: Human is the ONLY information bridge between agents
- **No Cross-Calling**: Alex cannot call `/blake` in same terminal (VIOLATION)

### Knowledge Assessment (Enhanced)
- **BLOCKING Gate 3/4**: Knowledge capture is now mandatory for passing gates
- **`/knowledge-audit` Command**: Audit project knowledge health
- **Knowledge Bootstrap Template**: Establish foundational knowledge during init

### Expert Review Protocol (Enhanced)
- **Minimum 2 Experts**: Every handoff must be reviewed by at least 2 subagents
- **code-reviewer Required**: Always required for every handoff
- **Parallel Review**: Experts called in parallel for efficiency

---

## 🚀 Installation & Upgrade

### One Command for Everything

```bash
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/tad.sh | bash
```

This smart script automatically:
- **Fresh install**: Creates complete TAD structure (`.tad/`, `.claude/`, `CLAUDE.md`)
- **Upgrade**: Detects current version and upgrades in place
- **Preserves data**: Your handoffs, learnings, and evidence are never overwritten

### What Gets Installed

```
your-project/
├── .tad/
│   ├── config.yaml              # v1.8 configuration (2100+ lines)
│   ├── active/handoffs/         # Active handoff documents
│   ├── archive/handoffs/        # Completed handoffs
│   ├── project-knowledge/       # Project-specific learnings
│   ├── evidence/reviews/        # Gate evidence files
│   └── templates/               # Document templates
│       ├── output-formats/      # 12 standardized review formats
│       └── knowledge-bootstrap.md
├── .claude/
│   ├── commands/                # Slash commands
│   │   ├── tad-alex.md          # /alex - Solution Lead
│   │   ├── tad-blake.md         # /blake - Execution Master
│   │   ├── tad-gate.md          # /gate - Quality gates
│   │   ├── tad-init.md          # /tad-init - Project setup
│   │   ├── knowledge-audit.md   # /knowledge-audit - Health check
│   │   └── ...
│   └── skills/                  # Agent skills
│       ├── code-review/         # Code review checklist
│       └── doc-organization.md  # Documentation hygiene
└── CLAUDE.md                    # Project rules (mandatory reading)
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
# Check version in config
grep "version:" .tad/config.yaml | head -1
# Should show: version: "1.8.0"
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

## 🚦 4-Gate Quality System

| Gate | Name | Owner | Trigger |
|------|------|-------|---------|
| Gate 1 | Requirements Clarity | Alex | After 3-5 elicitation rounds |
| Gate 2 | Design Completeness | Alex | Before creating handoff |
| Gate 3 | Implementation Quality | Blake | After implementation |
| Gate 4 | Integration Verification | Blake | Before delivery |

### Gate Evidence Requirements (v1.8)

**Gate 3 requires:**
- `test-runner` subagent execution
- Evidence file in `.tad/evidence/reviews/`
- Knowledge assessment (record if discoveries made)

**Gate 4 requires:**
- `code-reviewer` + `security-auditor` + `performance-optimizer`
- All evidence files generated
- Knowledge assessment completed

---

## 📋 Key Commands

| Command | Agent | Purpose |
|---------|-------|---------|
| `/alex` | - | Activate Alex (Solution Lead) |
| `/blake` | - | Activate Blake (Execution Master) |
| `/gate N` | Both | Execute quality gate N |
| `/knowledge-audit` | Both | Audit project knowledge health |
| `/tad-init` | - | Initialize TAD in new project |
| `/tad-learn` | Both | Record framework improvement |

### Alex Commands (use `*` prefix)
- `*analyze` - Start requirement elicitation
- `*design` - Create technical design
- `*handoff` - Generate handoff with expert review
- `*review` - Review Blake's completion
- `*accept` - Accept and archive handoff

### Blake Commands (use `*` prefix)
- `*implement` - Start implementation from handoff
- `*test` - Run tests
- `*gate 3` / `*gate 4` - Execute quality gates
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
| **v1.8** | Socratic Inquiry, Terminal Isolation, Knowledge Assessment |
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
- [Agent Definitions](.claude/commands/)
- [Configuration Guide](.tad/config.yaml)
- [Output Templates](.tad/templates/output-formats/)

---

**Welcome to TAD v1.8 - Where humans and AI collaborate with excellence.**

*The goal is not perfect process, but delivering value through effective human-AI partnership.*
