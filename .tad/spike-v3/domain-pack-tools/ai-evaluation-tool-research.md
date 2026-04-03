# AI Evaluation Tool Research

**Date**: 2026-04-02
**Purpose**: ai-evaluation Domain Pack tool selection

---

## Tool 1: promptfoo (TESTED ✅)

| Field | Value |
|-------|-------|
| Name | promptfoo |
| Version | 0.121.3 |
| Type | CLI (Node.js) |
| Install | `npx promptfoo@latest` (auto-downloads, no global install needed) |
| Verify | `npx promptfoo --version` |
| License | MIT (maintained by OpenAI as of March 2026) |
| Adoption | 300K+ developers, 127 Fortune 500 companies |

### Test Results
- ✅ Install: npx auto-download, ~30s first run
- ✅ YAML config: parsed correctly, supports vars/assertions/providers
- ✅ Eval run: executed 2 test cases with 3 assertion types
- ✅ Output: JSON results file (8KB), structured with evalId/results/config
- ✅ CI mode: `--ci` flag exits non-zero on failure

### Capabilities Verified
- Prompt evaluation with multiple assertion types
- YAML-based test configuration
- JSON output for programmatic analysis
- Red teaming via `npx promptfoo redteam` (not tested live, documented)
- Agent evaluation via Claude Agent SDK / Codex SDK providers

### Limitations
- Red teaming requires API keys for target models
- Agent evaluation requires Claude Agent SDK installed separately
- Web UI (`promptfoo view`) requires port binding

---

## Tool 2: deepeval (DOCUMENTED, install requires Python ≥3.10)

| Field | Value |
|-------|-------|
| Name | deepeval |
| Type | Python CLI + pytest plugin |
| Install | `pip install deepeval` (requires Python ≥3.10) |
| Verify | `deepeval --version` |
| License | Apache 2.0 |
| Adoption | High (PyPI, Confident AI) |

### Key Features (from docs)
- 50+ evaluation metrics (G-Eval, Task Completion, Tool Correctness, etc.)
- pytest integration: `deepeval test run`
- Agentic metrics: Task Completion, Argument Correctness, Tool Correctness, Step Efficiency, Plan Adherence
- CI/CD: standard pytest exit codes

### Limitation
- Requires Python ≥3.10 (uses `X | None` union syntax)
- Heavy dependency tree (llama_index, etc.)
- LLM-as-judge metrics require API keys

---

## Tool 3: deepteam (DOCUMENTED, same ecosystem as deepeval)

| Field | Value |
|-------|-------|
| Name | deepteam |
| Type | Python CLI |
| Install | `pip install deepteam` (requires Python ≥3.10) |
| License | Apache 2.0 |

### Key Features (from docs)
- 37+ vulnerability types in 6 categories
- OWASP Top 10 for LLMs + OWASP Top 10 for Agents 2026
- 10+ adversarial attack methods (prompt injection, jailbreaking, etc.)
- YAML config for reproducible red team scans
- Binary 0/1 scoring per vulnerability

---

## Recommendation for Domain Pack

| Capability | Primary Tool | Fallback |
|------------|-------------|----------|
| eval_framework_design | N/A (document output) | pdf_generation (typst) |
| benchmark_testing | **promptfoo** (tested ✅) | deepeval (if Python ≥3.10) |
| ab_testing | **promptfoo** (side-by-side eval) | deepeval |
| regression_testing | **promptfoo** (--ci mode) | deepeval pytest |
| adversarial_testing | **promptfoo red team** | deepteam |
| automated_pipeline | **promptfoo** (CI/CD native) | deepeval pytest |
| human_eval_protocol | N/A (process, not tool) | pdf_generation (typst) |

**Decision**: promptfoo is the primary tool — CLI, tested, zero-install via npx, CI/CD native.
deepeval/deepteam are alternatives for Python-native workflows (when Python ≥3.10 available).
