# TAD Method - Triangle Agent Development

**Version 1.5 - Framework & User Data Separation**

> 🚀 **TAD v1.5** introduces **clean separation** between framework files (`.tad/`) and user work (`tad-work/`), enabling **safe upgrades** without data loss.
>
> 📚 **[Documentation Portal](docs/README.md)** | [v1.5 Release Notes](docs/releases/v1.5-release.md)

## 🎯 What's New in v1.5

### Directory Structure Revolution
```
project/
├── .tad/        # Framework (config, templates, tasks) - Safe to upgrade
└── tad-work/    # Your work (handoffs, evidence) - Never touched by upgrades
```

**Benefits:**
- ✅ **Safe Upgrades** - Framework updates won't touch your work
- ✅ **Clear Ownership** - Know what's framework vs. your data
- ✅ **Better Git Control** - Separate .gitignore rules for each
- ✅ **No Data Loss** - Migration preserves all history

### v1.4 Features (Preserved)
- MQ6 Technical Research & Skills Knowledge System (42 built-in skills)
- Learn System for framework improvements
- Evidence-Based Development (MQ1-5)

## 🚀 Quick Installation

### Fresh Install (New Projects)
```bash
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/install.sh | bash
```

For new projects without TAD.

### Migrate to v1.5 (Existing Projects) ⭐ RECOMMENDED
```bash
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/migrate-to-v1.5.sh | bash
```

**For projects using TAD v1.4 or earlier:**
- ✅ Migrates to new directory structure (.tad/ + tad-work/)
- ✅ Preserves ALL your work (handoffs, evidence, context)
- ✅ Updates framework to v1.5
- ✅ Zero data loss, safe migration

**After migration:**
- Framework upgrades won't touch your work anymore
- Clear separation: `.tad/` (framework) vs `tad-work/` (yours)

### Quick Fix Upgrade (v1.4 → v1.4.1)
```bash
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/upgrade.sh | bash
```

Only for v1.4 users who need bug fixes but don't want structure change yet.

### Manual installation
```bash
git clone https://github.com/Sheldon-92/TAD.git .tad-temp
cp -r .tad-temp/.tad ./
cp -r .tad-temp/.claude ./
cp .tad-temp/*.md ./
rm -rf .tad-temp
```

### NPM installation (Coming soon)
```bash
npm install -g tad-framework
tad init
```

## ⚙️ Configuration

**Current Version (v1.4):**
- Main config: `.tad/config.yaml` (v1.4.0)
- Skills: `.claude/skills/` (42 knowledge files)
- The framework automatically uses the correct version

**Legacy Configs (Reference only):**
- See [Legacy Documents Index](docs/legacy/index.md) for historical documentation

**Note:** You don't need to manually edit configs. TAD agents know which version to use.

## Welcome

This is TAD (Triangle Agent Development), a new software development methodology based on human-AI collaboration.

## 🎯 What's New in v1.4

### MQ6 - Proactive Technical Research
- **Automatic Trigger**: Any technical decision triggers a search
- **Depth Auto-Determination**: Search depth based on decision complexity
- **Evidence Collection**: Search results become part of design evidence

### Research Phase
- **On-Demand Search**: Search as needed during implementation
- **Final Technical Review**: Comprehensive review before completion
- **Knowledge Capture**: Learnings recorded for future reference

### Skills Knowledge System
- **42 Built-in Skills**: Covering development, design, security, testing, and more
- **Auto-Discovery**: Skills automatically loaded based on task context
- **Hybrid Strategy**: 3 mandatory skills + context-based recommendations
- **Mandatory Skills**: security-checklist, test-driven-development, verification

### Learn System
- **`/tad-learn` Command**: Record framework suggestions
- **Pattern Recognition**: Capture success and failure patterns
- **Continuous Evolution**: Framework improves with each project

### v1.3 Features (Preserved)
- **Evidence-Based Development**: MQ1-5 mandatory questions
- **Human Visual Empowerment**: Value Guardian role
- **Progressive Validation**: Phase-based checkpoints
- **Continuous Learning**: 5 learning mechanisms

### v1.2 Features (Preserved)
- **MCP Integration**: 70-85% efficiency boost
- **16 Real Sub-agents**: Claude Code platform agent access
- **4-Gate Quality System**: Systematic quality control

### Key Benefits
- **100% Backward Compatible**: Works with v1.3 and v1.2 projects
- **Research-Driven**: Technical decisions backed by evidence
- **Knowledge-First**: Skills system provides best practices
- **Self-Improving**: Learn system captures improvements

## What is TAD?

TAD is a development method that leverages the unique strengths of both humans and AI through a triangular collaboration model. Instead of traditional hierarchical structures or attempting full automation, TAD creates a balanced partnership where:

- **Humans** define value and verify experiences
- **AI Agents** design solutions and implement them
- **Together** they create better software faster

## Core Philosophy

### The Problem We're Solving

Traditional software development often faces these challenges:
- Over-engineering: Building complex solutions for simple problems
- Value misalignment: Technical excellence doesn't guarantee user satisfaction
- Communication overhead: Too many handoffs between roles
- Documentation burden: More time documenting than building

### The TAD Solution

TAD addresses these issues through:
1. **Simplified roles**: Only 3 key participants instead of 10+
2. **Direct communication**: Document-based interfaces between agents
3. **Dual verification**: Technical correctness + Human value validation
4. **Flexible formality**: Scale process to match task complexity

## The Triangle Model

```
        Human
    (Value Guardian)
         /\
        /  \
       /    \
      /      \
Agent A ---- Agent B
(Solution) (Execution)
```

### Human - The Value Guardian
- **Defines** what is valuable for users
- **Verifies** that value is delivered
- **Decides** when conflicts arise
- **Learns** technical possibilities from agents

### Agent A - The Solution Lead
- **Translates** human needs into comprehensive solutions
- **Designs** product, technical, and user experience
- **Reviews** implementation quality
- **Manages** sub-agent specialists for analysis

### Agent B - The Execution Master
- **Implements** the solution designs
- **Orchestrates** parallel development tasks
- **Tests** and deploys solutions
- **Reports** progress and issues

## How It Works

### For Small Tasks (<2 hours)
```
Human states need → Agent A designs solution → Agent B implements
Simple, verbal, no heavy documentation
```

### For Medium Tasks (2-8 hours)
```
Light documentation in current-sprint.md
Key decisions recorded
Basic verification process
```

### For Large Projects (>1 day)
```
Full design documentation
Formal verification gates
Comprehensive testing
```

## Key Principles

### 1. Value-Driven Development
Every sprint must deliver **human-perceptible value**, not just technical progress.

### 2. Dual-Layer Verification
- **Layer 1**: Automated tests ensure technical correctness
- **Layer 2**: Human verification ensures value delivery

### 3. Continuous Learning
- Agents learn what humans value
- Humans learn what's technically possible
- Both evolve together

## Getting Started

### Quick Start (5 minutes)
1. Open two terminal windows
2. Terminal 1: Activate Agent A (Solution Lead)
3. Terminal 2: Activate Agent B (Execution Master)
4. Human: State what you need
5. Begin the collaboration

### Project Structure
```
your-project/
├── .tad/
│   ├── agents/          # Agent definitions
│   ├── context/         # Project context
│   └── working/         # Active documents
```

## Why TAD Works

### Leverages Strengths
- **Human strength**: Understanding user needs, making value judgments
- **AI strength**: Fast implementation, parallel processing, vast knowledge
- **Combined**: Better decisions, faster delivery, higher quality

### Reduces Waste
- No unnecessary documentation
- No redundant handoffs
- No over-engineering
- No value misalignment

### Scales Naturally
- Start simple with basic collaboration
- Add process only when needed
- Grow complexity with project size
- Maintain agility at all scales

## Comparison with Other Methods

| Aspect | Traditional | Agile | Pure AI | TAD |
|--------|------------|-------|---------|-----|
| Roles | Many (10+) | Several (5-7) | One (AI) | Three |
| Communication | Documents | Meetings | Prompts | Direct dialogue |
| Verification | QA Team | Sprint reviews | Automated | Dual-layer |
| Flexibility | Low | Medium | High | Adaptive |
| Value Focus | Indirect | Better | Unclear | Central |

## Success Metrics

You know TAD is working when:
- Features ship faster with fewer bugs
- Humans feel empowered, not overwhelmed
- Technical debt decreases naturally
- User satisfaction improves
- Team enjoys the process

## Next Steps

1. **Install TAD**: Use the one-line installer above or follow manual installation steps
2. **Verify Installation**: Run `./tad doctor` to check your TAD installation health
3. **Check Version**: Run `./tad version` to confirm v1.4 is installed
4. **Start Development**: Use `/alex` and `/blake` slash commands to activate agents
5. **Start Small**: Try TAD on a simple feature first
6. **Iterate**: Adjust the process based on what works

## CLI Commands

TAD v1.4 includes a simple CLI for framework management:

```bash
./tad version   # Show TAD version
./tad doctor    # Run health check
./tad upgrade   # Upgrade to latest version
./tad help      # Show help message
```

**Note**: The `tad` CLI is for framework management only. Agent activation, requirement elicitation, design, and implementation are handled through slash commands (`/alex`, `/blake`) or direct agent activation.

## Remember

TAD is not a rigid framework but a flexible philosophy:
- Start simple
- Add complexity only when needed
- Keep focus on value
- Enjoy the collaboration

The goal is not perfect documentation or process compliance, but delivering value to users through effective human-AI partnership.

---

Welcome to the future of software development.
Welcome to TAD.
