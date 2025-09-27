# TAD Method - Triangle Agent Development

## 🚀 Quick Installation

### One-line installer (Recommended)
```bash
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

## Welcome

This is TAD (Triangle Agent Development), a new software development methodology based on human-AI collaboration.

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
(Architect) (Executor)
```

### Human - The Value Guardian
- **Defines** what is valuable for users
- **Verifies** that value is delivered
- **Decides** when conflicts arise
- **Learns** technical possibilities from agents

### Agent A - The Strategic Architect
- **Translates** human needs into technical designs
- **Explains** technical decisions in human terms
- **Reviews** implementation quality
- **Manages** sub-agent specialists for analysis

### Agent B - The Execution Master
- **Implements** the technical designs
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
2. Terminal 1: Activate Agent A (Strategic Architect)
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

1. **Install TAD**: Follow the setup guide in SETUP.md
2. **Configure Agents**: Customize agent definitions for your project
3. **Start Small**: Try TAD on a simple feature first
4. **Iterate**: Adjust the process based on what works

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