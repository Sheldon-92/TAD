# GitHub Release Description for v1.0.0

Copy this content to create a GitHub Release at: https://github.com/Sheldon-92/TAD/releases/new

---

# TAD Framework v1.0.0 🎉

**Triangle Agent Development** - A revolutionary approach to AI-assisted software development

## 🚀 What is TAD?

TAD simplifies AI-assisted development by creating a balanced triangle of collaboration:
- **Human** (Value Guardian) - Defines what matters
- **Agent A** (Strategic Architect) - Designs how to build it
- **Agent B** (Execution Master) - Makes it happen

## ✨ Key Features

### Simple 3-Party Model
Instead of juggling 10+ roles, TAD uses just 3 participants that work in harmony.

### 6 Ready-to-Use Scenarios
- `new_project` - Start from scratch
- `add_feature` - Add new functionality
- `bug_fix` - Systematic debugging
- `performance` - Optimization workflows
- `refactoring` - Technical debt cleanup
- `deployment` - Production deployment

### 16 Real Claude Code Sub-agents
Seamless integration with Claude Code's built-in specialized agents like:
- `product-expert`, `backend-architect`, `api-designer`
- `parallel-coordinator`, `bug-hunter`, `test-runner`
- `devops-engineer`, `database-expert`, `docs-writer`

### Claude Code CLI Integration
Automatic recognition through `.claude` folder with custom commands:
- `/tad-init` - Initialize project
- `/tad-status` - Check configuration
- `/tad-scenario` - Start workflows
- `/tad-help` - Get help

## 📦 Installation

### One-line installer (Recommended)
```bash
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/install.sh | bash
```

### Manual installation
```bash
git clone https://github.com/Sheldon-92/TAD.git
cp -r TAD/.tad ./
cp -r TAD/.claude ./
rm -rf TAD
```

### NPM (Coming Soon)
```bash
npm install -g tad-framework
tad init
```

## 🎯 Quick Start

1. **Install TAD** in your project directory
2. **Open with Claude Code**: `claude .`
3. **Initialize**: Run `/tad-init`
4. **Start developing**: `/tad-scenario new_project`

## 📚 Documentation

- [Installation Guide](https://github.com/Sheldon-92/TAD/blob/main/INSTALLATION_GUIDE.md)
- [Workflow Playbook](https://github.com/Sheldon-92/TAD/blob/main/WORKFLOW_PLAYBOOK.md)
- [Sub-agents Guide](https://github.com/Sheldon-92/TAD/blob/main/CLAUDE_CODE_SUBAGENTS.md)
- [Configuration Guide](https://github.com/Sheldon-92/TAD/blob/main/CONFIG_AGENT_PROMPT.md)

## 🔄 Why TAD over BMAD?

| Aspect | BMAD | TAD |
|--------|------|-----|
| Agents | 10+ fictional roles | 2 real agents + 16 sub-agents |
| Documentation | 5 layers, complex | 2 layers, simple |
| Setup Time | 30+ minutes | 2 minutes |
| Learning Curve | Steep | Gentle |
| Focus | Process-heavy | Value-driven |

## 🎁 What's in the Box?

```
your-project/
├── .tad/
│   ├── agents/          # Agent A & B definitions
│   ├── config.yaml      # Simple configuration
│   ├── context/         # Project context
│   ├── working/         # Active documents
│   └── templates/       # Sprint & report templates
└── .claude/
    ├── commands/        # TAD CLI commands
    └── settings.json    # Claude Code integration
```

## 🤝 Contributing

TAD is open source and welcomes contributions!
- Report issues: [GitHub Issues](https://github.com/Sheldon-92/TAD/issues)
- Discussions: [GitHub Discussions](https://github.com/Sheldon-92/TAD/discussions)
- Pull requests: Always welcome!

## 📄 License

MIT License - Use freely in your projects

## 🙏 Acknowledgments

TAD stands on the shoulders of giants:
- Claude Code team for the amazing platform
- BMAD for inspiration (and lessons on what to simplify)
- Early adopters for valuable feedback

## 🚦 Getting Started Right Now

```bash
# Install TAD
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/install.sh | bash

# Open with Claude Code
claude .

# Start your first project
/tad-scenario new_project
```

---

**TAD - Making AI-assisted development simple, effective, and enjoyable.**

Star ⭐ this repo if you find it useful!