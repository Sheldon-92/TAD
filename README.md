# TAD Method - Triangle Agent Development

**Version 2.8.0 - Self-Evolving Framework**

> 📚 **[Documentation Portal](docs/README.md)** | **[Specialized Tools Guide](docs/MULTI-PLATFORM.md)** | **[Ralph Loop Guide](docs/RALPH-LOOP.md)** | [Version History](#version-history)

---

## 💡 Philosophy: Beneficial Friction

**TAD is not about making AI do more. It's about making human involvement more valuable.**

Many AI coding tools promise: "Give AI a goal, it handles everything." This sounds appealing, but in practice leads to:
- **Requirement drift**: AI's understanding diverges from what you actually need
- **False quality**: AI says "all tests pass" — but it wrote those tests itself
- **Priority confusion**: AI spends 80% of time on 20% of value

TAD takes a different approach: **AI can do a lot, but must stop at three critical points for human confirmation.**

### The Three Friction Points

| Point | Why Human is Essential | Without Human |
|-------|----------------------|---------------|
| **Requirement Clarification** | Only humans know the real problem to solve | AI builds "technically correct but directionally wrong" things |
| **Priority Decision** | Involves resources, time, business judgment | AI sorts by "technical complexity" instead of value |
| **End-to-End Acceptance** | Only humans can judge "does this actually work" | AI passes all unit tests but UX is broken |

These three points correspond to the **Value Guardian** role in the Triangle Model — not participating in every step, but gatekeeping at critical nodes.

### Beneficial vs. Wasteful Friction

| Wasteful Friction | Beneficial Friction |
|-------------------|---------------------|
| Copy-pasting code manually | Requirement clarification dialogue |
| Formatting adjustments | Priority decisions |
| Environment setup | End-to-end acceptance testing |
| Waiting for builds | Feedback when acceptance fails |

Wasteful friction should be automated. Beneficial friction should be **preserved and strengthened** — it's where value is created.

### A Deeper Insight

**The stronger AI becomes, the more critical human checkpoints are.**

When AI is weak, humans must participate in every step. When AI is strong, humans can step back to higher levels — but those few critical points become even more important, because once AI deviates there, it races toward the wrong direction faster.

This is why "fully autonomous AI development" is a false premise — **not because AI can't do it, but because AI without human gatekeeping produces unreliable results.**

---

## 🎯 What's New in v2.8

### Self-Evolving Framework (v2.8)
- **Execution Traces**: PostToolUse hook auto-records file events (JSONL) + step-level trace recording
- **`*optimize`**: Analyze project traces → propose Domain Pack + Project Knowledge improvements
- **`*evolve`**: Cross-project trace aggregation → propose TAD framework improvements
- **Human Approval Workflow**: PROPOSAL YAML schema + AskUserQuestion approval + safety constraints

### Domain Packs (v2.8) — 20 Packs, 78 Tools
- **5 Domain Chains**: Web (6 packs), Mobile (4), AI (4), Hardware (4), Security (2)
- Each pack includes: capabilities, workflow steps, quality criteria, anti-patterns, tool references
- `tools-registry.yaml`: 78 CLI/MCP tools across all packs
- **Workflow Integration**: Packs actively loaded during `*design` and injected into handoffs
- Pack creation template + HOW-TO guide for custom domain packs

### Quality Gate Hooks (v2.8)
- `pre-accept-check.sh`: BLOCK `*accept` without COMPLETION report
- `pre-gate-check.sh`: BLOCK Gate 3 without evidence (cold-start safe)
- `post-write-sync.sh`: Workflow reminders for handoffs, completions, Ralph Loop

### Knowledge Assessment Pipeline (v2.8)
- Gate 3/4 tables require evidence (file path + entry title) — "Yes" without proof = FAIL
- Alex verifies Blake's Gate 3 knowledge entries exist before accepting
- Handoff creation scans all knowledge entries for keyword-relevant history

### Hook-Native Architecture (v2.7)
- **5-layer architecture**: CLAUDE.md router → settings.json hooks → .tad/hooks/ scripts → Skills (judgment-only) → Config YAML
- SessionStart health check, PostToolUse workflow reminders, PreToolUse intelligent gating
- Skill files reduced ~76% (judgment-only residual) — hooks handle automation
- Total context footprint reduced ~76% (59K → 14K tokens)

### 4D Protocol Pair Testing (v2.6)
- **Discover → Discuss → Decide → Deliver** — decisions made at discovery time, not deferred
- Leverages 1M context window for in-session decision-making

### Autoresearch Optimization Mode (v2.6)
- Ralph Loop Layer 0.5: autonomous optimization loop for numeric targets
- Git commit/reset as state management, safety anchor tags, circuit breaker

### Linear Kanban Integration (v2.6)
- Cross-project human dashboard via Linear MCP
- NEXT.md → Linear one-way auto-sync on Alex startup

### Earlier Releases (v2.2–v2.5)
- **v2.5**: Spec Compliance Reviewer, Anti-Rationalization Tables, TDD Skill, Git Worktree
- **v2.4**: `*publish` + `*sync`, Context Refresh, Git Commit Verification
- **v2.3**: Intent Router, `*learn`, `*idea`, `*status`, ROADMAP.md
- **v2.2**: Bidirectional Messages, Adaptive Complexity, Modular Config, `/tad-maintain`

---

## 🚀 Installation & Upgrade

### One Command for Everything

```bash
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/tad.sh | bash
```

This smart script automatically:
- **Fresh install**: Creates complete TAD structure for Claude Code
- **Upgrade**: Detects current version and upgrades in place
- **Preserves data**: Your handoffs, learnings, and evidence are never overwritten
- **Rollback on failure**: Automatic backup and restore if anything goes wrong

### What Gets Installed

```
your-project/
├── .tad/
│   ├── config.yaml              # v2.8.0 configuration (modular: 6 config files)
│   ├── domains/                 # Domain Packs (20 YAML packs + tools-registry)
│   ├── hooks/                   # Shell hooks (5 scripts: startup, trace, gate, sync)
│   ├── skills/                  # Platform-agnostic skills (9 skills)
│   ├── ralph-config/            # Ralph Loop configuration
│   ├── templates/               # Handoff, completion, output format templates
│   ├── active/handoffs/         # Active handoff documents
│   ├── archive/handoffs/        # Completed handoffs
│   ├── project-knowledge/       # Project-specific learnings
│   └── evidence/                # Gate evidence (reviews/, ralph-loops/, traces/)
├── .claude/                     # Claude Code configuration
│   ├── commands/                # Slash commands (/alex, /blake, /gate, etc.)
│   ├── skills/                  # Claude-enhanced skills (alex, blake)
│   └── settings.json            # Hook-native architecture (SessionStart, PostToolUse, PreToolUse)
├── CLAUDE.md                    # Project rules for Claude Code (router pattern)
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
# Should show: 2.8

# Check skills
ls .tad/skills/
# Should show: 9 skill directories

# Check domain packs
ls .tad/domains/*.yaml | wc -l
# Should show: 21 (20 packs + tools-registry)
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

### Alex Commands (use `*` prefix)
- `*analyze` - Start requirement elicitation
- `*design` - Create technical design (with Domain Pack loading)
- `*handoff` - Generate handoff with expert review
- `*review` - Review Blake's completion
- `*accept` - Accept and archive handoff
- `*optimize` - Analyze traces → propose improvements
- `*evolve` - Cross-project framework evolution
- `*status` - Panoramic project status view

### Blake Commands (use `*` prefix)
- `*develop` - Start Ralph Loop (auto Layer 1 + Layer 2)
- `*layer1` - Run Layer 1 self-checks only
- `*layer2` - Run Layer 2 expert review only
- `*ralph-status` - Check Ralph Loop state
- `*ralph-resume` - Resume from checkpoint
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
| **v2.8.0** | **Self-Evolving Framework, 20 Domain Packs (78 tools), Execution Traces, Quality Gate Hooks** |
| **v2.7.0** | **Hook-Native Architecture, 76% context reduction, PreToolUse gating** |
| **v2.6.0** | **4D Protocol Pair Testing, Autoresearch Optimization, Linear Integration** |
| v2.5.0 | Spec Compliance Reviewer, Anti-Rationalization, TDD Skill, Worktree |
| v2.4.0 | *publish + *sync, Context Refresh, Git Commit Verification |
| v2.3.0 | Multi-Platform Cleanup, Intent Router, *learn, *idea, ROADMAP |
| v2.2.x | Bidirectional Messages, Adaptive Complexity, Pair Testing, Modular Config |
| v2.1.x | Agent-Agnostic Architecture, 9 Skills, `/tad-maintain` |
| v2.0 | Ralph Loop Fusion, Gate 3/4 Restructure |
| v1.8 | Socratic Inquiry, Terminal Isolation, Knowledge Assessment |

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

These principles are the practical implementation of [Beneficial Friction](#-philosophy-beneficial-friction) — each one preserves a human checkpoint where it matters most, while automating everything else.

### 1. Human-in-the-Loop (Beneficial Friction)
Human is not just a requester but the Value Guardian at three critical friction points: requirement clarification, priority decisions, and end-to-end acceptance. Information flows through the human.

### 2. Design Before Code
Alex designs completely before Blake implements. No implementation without handoff. This ensures requirements are clarified (friction point #1) before any code is written.

### 3. Evidence-Based Quality
Every gate requires evidence. Subagent reviews are mandatory, not optional. Automated checks eliminate wasteful friction; human review at gates preserves beneficial friction.

### 4. Knowledge Accumulation
Project learns from every feature. Patterns captured prevent repeated mistakes.

### 5. Adaptive Complexity
Scale process to task size. Small task = light process. Large task = full TAD. Match the amount of beneficial friction to the risk level.

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

TAD evolves through direct improvement in the [TAD repository](https://github.com/Sheldon-92/TAD). If you find issues or have suggestions, modify the framework directly or open an issue.

---

## 📖 Further Reading

- [Documentation Portal](docs/README.md)
- [Specialized Tools Guide](docs/MULTI-PLATFORM.md)
- [Ralph Loop Guide](docs/RALPH-LOOP.md)
- [Agent Definitions](.claude/commands/)
- [Configuration Guide](.tad/config.yaml)
- [Skills Reference](.tad/skills/README.md)

---

**Welcome to TAD v2.8.0 - Self-Evolving Framework for AI-Assisted Development.**

*AI does the work. Humans guard the value.*
