# TAD Method - Triangle Agent Development

**Version 1.3 - Evidence-Based Development**

> 🚀 **TAD v1.3 introduces Evidence-Based Development**: 95%+ problem detection rate through mandatory evidence, human visual empowerment, and continuous learning mechanisms - transforming from declarative to provable quality assurance.

## 🚀 Quick Installation

### Fresh Installation (Recommended)
```bash
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/install.sh | bash
```

### Upgrade from v1.2 to v1.3
```bash
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/upgrade-to-v1.3.sh | bash
```

### Upgrade from v1.1 to v1.3
```bash
# First upgrade to v1.2, then to v1.3
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/upgrade-to-v1.2.sh | bash
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/upgrade-to-v1.3.sh | bash
```

### Upgrade from v1.0 to v1.3
```bash
# Upgrades through v1.1 and v1.2 automatically
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/install.sh | bash
```

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

**Current Version (v1.3):**
- Main config: `.tad/config.yaml` (v1.3.0)
- The framework automatically uses the correct version

**Legacy Configs (Reference only):**
- `.tad/archive/configs/config-v1.2.2.yaml` - v1.2.2 backup
- `.tad/archive/configs/config-v1.1.yaml` - v1.1 configuration
- `.tad/archive/configs/config-v2.yaml` - Experimental features

**Note:** You don't need to manually edit configs. TAD agents know which version to use.

## Welcome

This is TAD (Triangle Agent Development), a new software development methodology based on human-AI collaboration.

## 🎯 What's New in v1.3

### Evidence-Based Quality Assurance
- **95%+ Problem Detection**: From 0-30% to 95%+ through mandatory evidence
- **6 Evidence Types**: Search results, code location, data flow, state flow, UI screenshots, test results
- **5 Mandatory Questions (MQ1-5)**: Prevent common failures before they happen
  - MQ1: Historical code search (prevent duplicate creation)
  - MQ2: Function existence (prevent runtime crashes)
  - MQ3: Data flow completeness (ensure UI displays all data)
  - MQ4: Visual hierarchy (make different states visually distinct)
  - MQ5: State synchronization (prevent data inconsistency)
- **Human-Verifiable Checkpoints**: Every evidence has clear validation criteria

### Human Visual Empowerment
- **New Role**: Value Guardian + Checkpoint Validator
- **3 Participation Points**:
  - Gate 2 Review: 10-15 min (verify design evidence)
  - Phase Checkpoints: 5-10 min each (progressive validation)
  - Gate 3 Verification: 10-15 min (final validation)
- **No Technical Knowledge Required**: Verify through charts and screenshots
- **ROI 1:5 to 1:10**: Invest 30-60 min → Save 3-6 hours rework

### Continuous Learning Mechanisms
- **5 Learning Mechanisms**:
  - Decision Rationale: Understand technical tradeoffs
  - Interactive Challenge: Think before accepting solutions
  - Impact Visualization: See ripple effects of changes
  - What-If Scenarios: Compare alternative approaches
  - Failure Learning Entry: Auto-improve from mistakes
- **4 Learning Dimensions**: Tech tradeoffs, System thinking, UX intuition, Quality awareness
- **Failure Learning Loop**: System gets smarter with each project

### Progressive Validation
- **Phase-Based Approach**: Break large tasks into 2-4 hour phases
- **Early Direction Validation**: Catch errors at 20% instead of 100%
- **Evidence Requirements**: Each phase provides code, tests, and UI proof
- **Continuous Feedback**: Human validates direction before next phase

### v1.2 Features (Preserved)
- **MCP Integration**: 70-85% efficiency boost with Model Context Protocol
- **Smart Project Detection**: Auto-recommend tools by project type
- **16 Real Sub-agents**: Claude Code platform agent access
- **Parallel Execution**: 40%+ time savings
- **4-Gate Quality System**: Systematic quality control

### Key Benefits
- **100% Backward Compatible**: Works with v1.2 projects
- **Evidence-Driven**: From "AI says" to "Human sees proof"
- **Human Growth**: Build technical intuition through learning mechanisms
- **Self-Improving**: Failure loop auto-generates new quality checks
- **Measurable ROI**: Track time invested vs saved

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
3. **Check Version**: Run `./tad version` to confirm v1.2 is installed
4. **Start Development**: Use `/alex` and `/blake` slash commands to activate agents
5. **Start Small**: Try TAD on a simple feature first
6. **Iterate**: Adjust the process based on what works

## CLI Commands

TAD v1.2 includes a simple CLI for framework management:

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