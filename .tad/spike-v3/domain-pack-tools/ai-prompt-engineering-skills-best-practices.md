# AI Prompt Engineering Skills Best Practices — Research Summary

**Date**: 2026-04-02
**Sources**: 5 GitHub repos + 1 industry guide
**Purpose**: ai-prompt-engineering.yaml design reference

---

## Research Sources

| Repo / Source | Stars | Focus | Key Value |
|------|-------|-------|-----------|
| ckelsoe/prompt-architect | High | 27 frameworks, quality scoring | Framework selection decision tree, 5-dim scoring (Clarity/Specificity/Context/Completeness/Structure) |
| nidhinjs/prompt-master (OpenClaw) | Mid | Tool-aware prompt generation | 9-dim intent extraction, 6-point verification gate, failure category diagnosis |
| muratcankoylan/Agent-Skills-for-Context-Engineering | Mid | 13 context engineering skills | Context compression, attention degradation patterns, progressive disclosure |
| promptfoo/promptfoo (CLI tool) | Very High | Prompt testing & evaluation | YAML-based test configs, assertion types, CI/CD integration, used by OpenAI & Anthropic |
| Lakera prompt engineering guide | N/A | Industry best practices 2026 | System prompt design, few-shot patterns, model-specific techniques |
| Local: Claude Code source + OpenClaw SOUL.md | N/A | Real production prompts | Hook enforcement priority, template patterns, versioning via git |

---

## Capability 1: System Prompt Design

**Best Step Design** (from prompt-architect + Lakera):

1. **Role Definition**: "You are a [domain expert] who prioritizes [core value]" — not vague "be helpful"
2. **Behavioral Constraints**: MUST/NEVER language (prompt-master: "strongest signal: MUST > should; NEVER > avoid")
3. **Output Format Lock**: Explicit schema or template in first 30% of prompt
4. **Context Anchoring**: Background situation before task specification
5. **Anti-hallucination Guardrails**: "Use only information you are highly confident about. Mark uncertain claims [uncertain]."

**Best Framework** (from prompt-architect):
- CO-STAR (Context, Objective, Style, Tone, Audience, Response) — most versatile for system prompts
- TIDD-EC (Task, Instructions, Do, Don't, Examples, Context) — when explicit anti-patterns needed

**Best Quality Criteria** (from prompt-architect 5-dim scoring):
- Clarity: Goal unambiguity (1-10)
- Specificity: Detail sufficiency (1-10)
- Context: Background information quality (1-10)
- Completeness: All required components present (1-10)
- Structure: Organization and hierarchy (1-10)
- "Overall ≥7/10 = production-ready, <4/10 = needs substantial rework"

**Anti-patterns**:
- ❌ Vague role ("be helpful") instead of domain-specific role + value priority (prompt-architect)
- ❌ Soft language ("could you", "please", "make sure to") wastes tokens (Lakera: 50% reduction by removing)
- ❌ Critical constraints buried at end — must be in first 30% (prompt-master)
- ❌ Missing "Don't" section — anti-patterns leak through without explicit exclusions (TIDD-EC pattern)

---

## Capability 2: Few-Shot Example Design

**Best Step Design** (from Lakera + prompt-master):

1. **Select Diverse Examples**: Cover edge cases, not just happy path (3-5 examples)
2. **Consistent Format**: Input-output pairs with clear structural separation (delimiters)
3. **Difficulty Gradient**: Order from simple → complex
4. **Anti-example Inclusion**: Show what NOT to output (TIDD-EC "Don't" pattern)
5. **Minimal Set Test**: Try 1 example first, add more only if output drifts

**Best Framework** (from prompt-architect):
- RISE-IX (Instructions-Examples): Content creation with reference samples
- Few-shot with boundary markers: `---EXAMPLE START---` / `---EXAMPLE END---`

**Best Quality Criteria**:
- "Input variety + output formatting consistency = maximizes generalization" (Lakera)
- Each example must be independently correct (no dependent examples)
- ≤5 examples total (diminishing returns after 5, Lakera)
- Total few-shot section ≤300 tokens (research: "performance degrades around 3,000 tokens" overall)

**Anti-patterns**:
- ❌ Inconsistent formatting across examples (degrades performance) (Lakera)
- ❌ Only happy-path examples (no edge cases covered)
- ❌ Overly complex examples that confuse more than help
- ❌ Examples that contradict system prompt constraints

---

## Capability 3: Prompt Testing

**Best Step Design** (from promptfoo + prompt-master):

1. **Define Golden Dataset**: 10-20 high-priority test cases (core use cases + failure cases)
2. **Configure YAML**: Prompts + providers + test vars + assertions
3. **Run Evaluation**: `promptfoo eval` — all prompt × model combinations
4. **Score Results**: Automatic assertions (contains, llm-rubric, cost, latency)
5. **Regression Guard**: CI/CD gate that blocks quality degradation on merge

**Best Framework** (from promptfoo):
- Assertion types: `contains`, `icontains`, `llm-rubric`, `cost`, `latency`, `javascript`
- Non-determinism handling: Run 3+ times per test case, measure consistency
- Side-by-side comparison: A/B prompt versions on same test set

**Best Quality Criteria** (from promptfoo docs):
- 100% pass rate on golden dataset
- ≥80% consistency across 3 runs (non-determinism check)
- Cost per evaluation ≤ budget threshold
- Latency ≤ acceptable threshold per use case
- No regression from previous version (CI/CD blocking)

**Anti-patterns**:
- ❌ Testing on single model only (overfitting to model quirks) (Lakera)
- ❌ Manual review only without automated assertions (not scalable)
- ❌ Golden dataset <10 cases (insufficient coverage)
- ❌ No regression testing — prompts drift without CI gates (promptfoo)

---

## Capability 4: Prompt Optimization

**Best Step Design** (from prompt-master + prompt-architect):

1. **Diagnostic Scan**: Classify current prompt failures (task/context/format/scope/reasoning/agentic)
2. **Targeted Fix**: Apply specific fix per failure type (not random rewording)
3. **A/B Compare**: Run both versions on same test set
4. **Token Efficiency Audit**: "Every sentence load-bearing? No vague adjectives? Format explicit? Scope bounded?" (prompt-master 6-point gate)
5. **Iterate Until First-Pass Success**: "Prompt pasted into tool → works first attempt → zero re-prompts needed" (prompt-master success metric)

**Best Framework** (from prompt-master diagnostic categories):
- Task failures: vague verbs → replace with precise operations ("analyze" → "extract and rank")
- Context failures: assumes prior knowledge → prepend memory block
- Format failures: unspecified output → derive from task type + add explicit lock
- Scope failures: unlimited scope → add explicit scope lock
- Reasoning failures: logic tasks without scaffolding → add CoT (but NOT for reasoning-native models)
- Agentic failures: no stop conditions → add checkpoints and human review triggers

**Best Quality Criteria**:
- Pre-delivery 6-point verification (prompt-master):
  1. Tool syntax correct for target?
  2. Critical constraints in first 30%?
  3. Signal strength: MUST > should, NEVER > avoid?
  4. Forbidden techniques removed?
  5. Token efficiency: every sentence load-bearing?
  6. First-pass success: would this work on attempt one?

**Anti-patterns**:
- ❌ Random rewording instead of diagnostic-driven fixing (prompt-master)
- ❌ Adding CoT to reasoning-native models (o3, o4-mini, DeepSeek-R1) — they already reason (prompt-master)
- ❌ Multiple tasks in one prompt → split into sequential prompts
- ❌ Emotional language ("broken") → extract technical fault

---

## Capability 5: Output Format Control

**Best Step Design** (from Lakera + prompt-master):

1. **Select Format Type**: JSON / Markdown / XML / plain text based on consumer
2. **Define Schema**: Explicit field names, types, constraints (JSON Schema for structured output)
3. **Add Format Lock**: "IMPORTANT: Respond only with the following structure." + "Do not explain your answer"
4. **Prefill/Anchor**: Start response with skeleton structure (model mirrors it)
5. **Validate Output**: Parse and verify against schema (automated)

**Best Framework**:
- JSON Schema for API integration (Anthropic strict mode: `strict: true`)
- Markdown + XML tags for Claude (model-specific preference, Lakera)
- Template-with-placeholders for human consumption

**Best Quality Criteria**:
- Schema validates 100% of outputs (automated parsing)
- Zero explanatory text outside format (when "no explanation" specified)
- Consistent field ordering across calls
- Handles edge cases gracefully (empty data → explicit null, not omission)

**Anti-patterns**:
- ❌ "Respond in JSON" without schema definition (inconsistent field names)
- ❌ Format instructions at end of prompt (gets lost in long prompts)
- ❌ Mixing format styles (JSON fields + prose explanation)
- ❌ No validation step (silent schema violations accumulate)

---

## Capability 6: Context Management

**Best Step Design** (from context-engineering skills + Lakera):

1. **Token Audit**: Measure current prompt token usage per section
2. **Compression Pass**: Drop soft phrasing, convert sentences to labeled directives (Lakera: ~50% reduction possible)
3. **Priority Ordering**: Summary first → context second → task last (hierarchical structuring)
4. **Attention Optimization**: Place critical info at start and end (avoid "lost-in-the-middle" degradation)
5. **Progressive Disclosure**: Load only what's needed, expand on demand

**Best Framework** (from context-engineering skills + LangChain):
- LangChain 4 strategies: Write (persist externally), Select (RAG), Compress (summarize), Isolate (separate agent contexts)
- "Smallest possible set of high-signal tokens that maximize desired outcomes" (context-engineering core principle)

**Best Quality Criteria**:
- Token budget defined per section (not just overall)
- Critical info in first 30% AND last 10% of context (U-shaped attention curve)
- Compression ratio ≥30% from original (without losing information)
- No attention-degradation patterns (tested via "needle in haystack")

**Anti-patterns**:
- ❌ Indiscriminate context inclusion without signal evaluation (context-engineering)
- ❌ Entire codebase as context → scope to relevant file/function only (prompt-master)
- ❌ "Could you please carefully make sure to" — remove all politeness tokens (Lakera)
- ❌ Ignoring model-specific attention mechanics (prompt-master: different models handle context differently)

---

## Capability 7: Prompt Versioning

**Best Step Design** (from promptfoo + dev.to survey + Lakera):

1. **Version in Git**: Prompts as files in source control (natural diff/blame/history)
2. **YAML Config**: promptfoo-style versioned config with prompt + test cases together
3. **Change Tracking**: Semantic versioning for prompts (major: behavior change, minor: improvement, patch: typo)
4. **Regression Test**: Auto-run golden dataset on every version change
5. **Rollback Protocol**: Keep previous version's test results for comparison

**Best Framework** (from promptfoo + Braintrust comparison):
- CLI-first approach: `promptfoo eval` with YAML configs checked into git
- Version metadata: date, author, rationale, test results
- Deployment pipeline: dev → staging (eval) → production

**Best Quality Criteria**:
- Every prompt change has associated test results
- Diff shows exactly what changed (git diff)
- Rollback to any previous version in <1 minute
- Deployment requires passing regression tests

**Anti-patterns**:
- ❌ Prompts hardcoded in source code (no version tracking)
- ❌ Manual copy-paste versioning ("prompt_v2_final_FINAL.txt")
- ❌ No test results attached to versions (can't compare)
- ❌ Version without rationale (why was this changed?)

---

## How to Use These Best Practices

When writing ai-prompt-engineering.yaml:
1. Each capability's `steps` should embed the "Best Step Design" above (not self-invented)
2. `quality_criteria` should use the quantifiable standards from "Best Quality Criteria"
3. `anti_patterns` should include the specific errors from "Anti-patterns"
4. `reviewers` should cover the domains: prompt quality, testing coverage, production readiness
