# AI Prompt Engineering Capability Pack

**Production prompt lifecycle toolkit** — design, test, optimize, version, and deploy prompts like a senior prompt engineer.

**Version**: 1.0.0 | **License**: Apache 2.0

---

## What This Pack Does

Most prompt engineering guides teach "how to write a prompt." This pack teaches **how to run prompts in production** — testing, versioning, drift detection, and CI/CD gates.

The 4-phase lifecycle this pack encodes:
- **Phase 1: Write** — System prompt design with anti-hallucination, security, and context architecture
- **Phase 2: Test** — Automated testing with promptfoo (18+ test cases, CI/CD gates)
- **Phase 3: Optimize** — Diagnose failures with 6-dimension scoring; programmatic optimization with DSPy
- **Phase 4: Ship** — Version control, model pinning, 3-tier CI/CD pipeline, drift monitoring

---

## Quick Start

### Install (Claude Code)

```bash
# Project install (recommended)
cd your-project/
bash /path/to/ai-prompt-engineering/install.sh

# Global install
bash /path/to/ai-prompt-engineering/install.sh --global
```

### First Use

In Claude Code, reference the skill:
```
Use the ai-prompt-engineering capability pack to help me write a system prompt for [your task].
```

Or describe your task:
```
I need to write a system prompt for a customer support classification bot that outputs JSON.
```

---

## Pack Structure

```
ai-prompt-engineering/
├── CAPABILITY.md            # Main SKILL — Step 0 router + 4-phase lifecycle
├── references/
│   ├── claude.md            # Claude 4.x-specific rules (7 rules)
│   ├── failure-catalog.md   # 6 production failure modes with post-mortems
│   ├── ci-cd-templates.md   # 3-tier CI/CD pipeline templates (GitHub Actions)
│   ├── few-shot-design.md   # Few-shot example design and quality assessment
│   └── output-format.md     # Output format control and compliance verification
├── tools/
│   ├── selection-matrix.md  # When to use promptfoo vs DSPy vs DeepEval
│   └── promptfoo-starter.yaml  # Ready-to-use config with 18 test cases
├── checklists/
│   ├── pre-deploy.md        # Pre-deployment checklist
│   └── regression.md        # Version regression testing protocol
└── examples/
    └── system-prompt-template.md  # Annotated system prompt skeleton
```

---

## CLI Tools Required

| Tool | Install | Phase |
|------|---------|-------|
| promptfoo | `npx promptfoo@latest init` | Phase 2, 4 |
| DSPy | `pip install dspy-ai` | Phase 3 (optional) |
| DeepEval | `pip install deepeval` | Phase 3 (optional) |

All tools are CLI-native. No web UI required.

---

## FAQ

**Q: Does this work for models other than Claude?**
Yes. The core workflow (Phases 1–4) is model-agnostic. Claude-specific rules are in `references/claude.md` and are only loaded when the target model is Claude.

**Q: Do I need to install all three CLI tools?**
No. promptfoo is the core tool (Phases 2 and 4). DSPy and DeepEval are optional and only needed for programmatic optimization and detailed quality metrics.

**Q: How is this different from the Anthropic prompt engineering tutorial?**
The Anthropic tutorial covers how to write a prompt. This pack covers what happens after you write it — testing, CI/CD, versioning, and production operations. Start with the tutorial; use this pack when you're ready to productionize.

**Q: What's the "Fix the Prompt Fallacy"?**
46% of AI failures are environment/infrastructure faults, 25% are configuration faults, and only ~29% are actual prompt wording issues. Before revising your prompt, check environment and configuration first. See `references/failure-catalog.md` FM-6.

---

## License

Apache 2.0 — see LICENSE and LICENSE-ATTRIBUTION.md for source credits.
