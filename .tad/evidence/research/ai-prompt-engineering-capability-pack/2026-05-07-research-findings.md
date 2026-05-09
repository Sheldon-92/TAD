# AI Prompt Engineering Capability Pack — Research Findings
> Source: NotebookLM notebook `26012e7b` (24 sources) + tad-evolution notebook `37cfefa5` (45 sources)
> Date: 2026-05-07 | Q1-Q7 answered

---

## Q7: Existing Knowledge (tad-evolution notebook)

Already covered: DSPy, LangSmith/Langfuse/Braintrust, prompt caching, context rot, deferred tool loading, subagent isolation, structured outputs (Pydantic AI, Instructor).

---

## Q1: CLI Tools for Prompt Lifecycle

| Tool | Install | Unique Value | CLI-suitable? |
|------|---------|-------------|---------------|
| **promptfoo** | `npx promptfoo@latest init` | CLI-first, YAML configs, 50+ vuln scanning, CI/CD native | ✅ Ideal |
| **DSPy** | `pip install dspy-ai` | Programmatic optimization (MIPROv2, COPRO, BootstrapFewShot), compiles prompts | ✅ Python-native |
| **DeepEval** | pytest-based | 50+ typed metrics (G-Eval, hallucination, faithfulness), returns score + explanation | ✅ pytest-native |
| **Braintrust** | CLI + GitHub Actions | Loop AI auto-generates test datasets from logs, blocks PR merges | ✅ CLI + CI |
| **EvalView** | YAML test cases | Multi-step agent regression detection | ✅ CLI |
| **PromptLayer** | SDK | CMS-style visual editing, non-technical user friendly | ❌ Web UI focused |
| **Agenta** | Python SDK | Git-like branching for prompts, collaborative | ⚠️ SDK, not CLI |
| **LangSmith** | SDK | Deep LangChain tracing, prompt hub | ⚠️ SDK, LangChain-locked |
| **Maxim AI** | Multi-lang SDKs | Agent simulation, canary releases | ⚠️ Platform-first |

**Verdict for pack**: promptfoo (testing), DSPy (optimization), DeepEval (metrics) are the CLI-native trio.

---

## Q2: Production Prompt Lifecycle Patterns

### Versioning
- Start: Git + YAML files
- Scale: Dedicated platforms with prompt slugs + API retrieval
- Best practice: Environment segregation (Dev → Staging → Prod)

### CI/CD Pipeline (3-tier)
| Tier | When | Duration | What |
|------|------|----------|------|
| 1 | Per-commit | <2 min | Deterministic: JSON format, keywords, token budget |
| 2 | Per-PR | 10-20 min | LLM-as-judge regression on 20+ golden set, blocks merge |
| 3 | Weekly/pre-release | 60-90 min | Vuln scan (Giskard), jailbreak, edge-case hallucination |

### A/B Testing
- Canary releases: 5-10% traffic, 24-48h monitor
- Offline side-by-side against historical traces
- Platform-managed traffic splitting

### Prompt Drift Handling
- **Model version pinning** (e.g., `gpt-4o-2024-11-20` not `gpt-4o`)
- Upgrade regression testing before version bump
- Distribution monitoring (refusal rates, semantic similarity drift)

---

## Q3: Claude 4.x Specific Changes

### Extended Thinking
- **Stop prescribing CoT steps** — `effort` parameter replaces manual reasoning plans
- **Keep CoT in few-shot examples** — Claude learns reasoning from `<thinking>` examples
- Manual CoT as fallback when `effort=low`

### Prompt Caching Architecture
- **Stable prefix (top)**: system prompts, docs, tool defs + `cache_control` breakpoints
- **Dynamic suffix (bottom)**: user queries — up to 30% quality boost at end

### Claude 4.x Anti-Patterns
- ❌ Prefilling assistant messages (deprecated, 400 error on Mythos)
- ❌ Aggressive "MUST USE" language (causes over-triggering on 4.6+)
- ❌ `budget_tokens` (deprecated → use `effort` parameter)
- ❌ Generic "clean and minimal" design prompts (locks into AI-slop palette)
- ❌ Piecemeal multi-turn requirements (drains reasoning tokens — give upfront)
- Claude 4.7 is MORE literal — must explicitly state scope of formatting rules
- Claude 4.7 reasons more, uses tools LESS — raise `effort` to increase tool use

---

## Q4: Tool Automation for AI Agents

### promptfoo CLI
- `npx promptfoo@latest init` — bootstrap
- `npx promptfoo eval --no-cache` — run evaluation
- Red teaming: 50+ vuln types
- All YAML-driven, no web UI needed

### DSPy Optimizers
- **Input**: unoptimized program + metric function + 5-10 training examples
- **Output**: optimized program as JSON (loadable via `.load()`)
- MIPROv2: Bayesian optimization over instructions + demos
- COPRO: coordinate ascent hill-climbing with `depth` parameter
- BootstrapFewShot: teacher-generated demonstrations

### DeepEval
- pytest-native: `pytest test_prompts.py`
- 50+ metrics returning score (0-1) + natural-language explanation
- G-Eval, hallucination, answer relevancy, contextual recall, faithfulness

**All three are terminal-runnable, no web UI required.**

---

## Q5: Competitive Analysis — Existing Guides

### What exists
- **Anthropic Tutorial**: 9 chapters (basic → advanced), interactive playground, industry use cases
- **Lakera Guide**: Enterprise focus, adversarial security, prompt scaffolding
- **"When Better Prompts Hurt" paper**: Generic improvements can DEGRADE performance (-10% JSON accuracy, -13.3% citations)

### What ALL guides miss (= our differentiation)
1. **Automated testing integration** — none teach how to set up CI/CD for prompts
2. **Prompt drift handling** — assume static model, no version pinning guidance
3. **Context window optimization** — only "make it shorter", not cache architecture
4. **The "Fix the Prompt" fallacy** — 46% of failures are infrastructure, not prompt

---

## Q6: Production Failure Modes (Post-Mortems)

| Failure Mode | Root Cause | Fix |
|-------------|-----------|-----|
| Format drift | Generic "helpful" system prompt conflicts with task constraints (-10% accuracy) | Task-specific constraints only, automated format validation |
| Hallucination (RAG) | No grounding constraints, "helpfulness" pressure overrides citations (-13.3%) | Strict attribution + explicit "I don't know" + faithfulness metrics (RAGAS) |
| Silent regression | Provider silent model update, same name different weights | Pin versions, run full regression before upgrade |
| Context overflow + zombie memory | Naive truncation, 60% fact destruction, 54% constraint erosion | Structured retrieval layer, active context compression |
| Prompt injection (production) | Trusted user input, 84% attack rate in multi-agent | Prompt scaffolding (reasoning step before response) |
| "Fix the prompt" | Env faults 46%, config 25%, prompt is minority cause | Blameless post-mortem with failure taxonomy |

---

## Synthesis: Pack Shape Decision Inputs

### Why NOT web-backend shape (1 router + references/)
Prompt engineering is a **workflow**, not a **judgment collection**. You don't look up "rule #17" — you walk through a sequence: write prompt → test → diagnose → optimize → version → deploy.

### Why NOT product-thinking shape (3 adversarial skills)
Prompt engineering is more tool-integrated than product thinking. It needs CLI command generation, YAML config writing, test result interpretation — not just Q&A interaction.

### Recommended: Hybrid (workflow SKILL + reference rules)
- **1 main SKILL.md**: Production prompt lifecycle workflow (write → test → optimize → version)
  - Each phase invokes specific tools (promptfoo, DSPy, DeepEval)
  - Agent writes YAML configs, runs CLI commands, interprets results
- **references/**: Claude 4.x-specific rules, failure mode catalog, CI/CD templates
- **checklists/**: Pre-deploy checklist, regression checklist
- **tools/**: Tool selection matrix (when promptfoo vs DSPy vs DeepEval)

This is closest to web-ui-design's Vision→Execution→Validation flow, but with heavier tool integration.
