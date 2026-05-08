# Changelog

All notable changes to the AI Prompt Engineering Capability Pack.

---

## v1.0.0 (2026-05-07)

**Initial release.**

### Added
- `CAPABILITY.md` — Main SKILL with Step 0 router + 4-phase prompt lifecycle (Write/Test/Optimize/Ship)
- `references/claude.md` — 7 Claude 4.x-specific rules (effort parameter, prefill deprecation, literal following, MUST USE anti-pattern, upfront requirements, cache architecture, tool use frequency)
- `references/failure-catalog.md` — 6 production failure modes with post-mortems (FM-1 through FM-6)
- `references/ci-cd-templates.md` — 3-tier CI/CD pipeline templates (GitHub Actions)
- `references/few-shot-design.md` — Few-shot example design: 5-question quality assessment, selection strategy, token budget, diversity/gradient rules
- `references/output-format.md` — Output format control: schema definition, compliance verification (≥95%), format type selection matrix
- `tools/selection-matrix.md` — Tool selection matrix (promptfoo vs DSPy vs DeepEval) + DSPy optimizer sub-matrix
- `tools/promptfoo-starter.yaml` — Ready-to-use promptfoo config with 18 test cases (10 core + 5 edge + 3 adversarial)
- `checklists/pre-deploy.md` — Pre-deployment quality checklist (6 categories, 18 items)
- `checklists/regression.md` — Prompt version regression testing protocol
- `examples/system-prompt-template.md` — Annotated system prompt skeleton with WHY/NOTE/RULE comments
- `install.sh` — Cross-agent installer with `--agent` flag (Phase N stubs for codex/cursor/gemini)

### Research basis
- NotebookLM notebook `26012e7b` (24 sources): promptfoo, DSPy, DeepEval, Anthropic docs, Lakera 2026, "When Better Prompts Hurt" paper, "Fix the Prompt is a Root Cause Fallacy", Braintrust 2026, Agenta, LLM Testing Tools 2026
- Key differentiation over existing guides: CI/CD integration, prompt drift handling, context architecture, failure taxonomy (46% env / 25% config)
