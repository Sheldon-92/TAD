---
task_type: mixed
e2e_required: no
research_required: yes
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: AI Prompt Engineering Capability Pack

**From:** Alex | **To:** Blake | **Date:** 2026-05-07
**Project:** Independent repo (not TAD)
**Epic:** EPIC-20260507-agent-capability-packs (Phase 1e — parallel to web-ui-design/product-thinking/web-backend/ai-agent-architecture)

---

## 1. Task Overview

Build an **AI Prompt Engineering Capability Pack** — a production prompt lifecycle toolkit that gives any AI coding agent the ability to design, test, optimize, version, and deploy prompts like a senior prompt engineer.

**Core idea**: AI agents can write prompts, but they can't:
- Test prompts against regression suites before deploying
- Diagnose why a prompt hallucinates or drifts format
- Set up CI/CD pipelines that block bad prompts from shipping
- Handle model updates that silently break existing prompts

This pack encodes the **production prompt lifecycle** — 4 phases with specific CLI tools at each phase — that most prompt engineering guides skip.

**Key distinction**: Existing guides (Anthropic tutorial, Lakera, learnprompting) teach "how to write a prompt." This pack teaches "how to run prompts in production" — testing, versioning, drift detection, CI/CD gates.

**Phase 1 target: Claude Code.** Same install.sh pattern as web-ui-design/web-backend.

---

## 2. Research Foundation

- **Notebook:** `26012e7b-7a2c-465c-8778-68afe3f84c5b` — 24 sources
- **Existing knowledge:** `37cfefa5` (tad-evolution, 45 sources) — Q7 pre-check
- **Research findings:** `.tad/evidence/research/ai-prompt-engineering-capability-pack/2026-05-07-research-findings.md`
- **Key references:**
  - promptfoo/promptfoo (CLI-first prompt testing + red teaming, used by OpenAI + Anthropic)
  - stanfordnlp/dspy (programmatic prompt optimization, 160K monthly downloads)
  - DeepEval (pytest-native, 50+ metrics with natural-language explanations)
  - Anthropic prompt engineering docs (Claude 4.x best practices + interactive tutorial)
  - Lakera 2026 guide (enterprise security + adversarial)
  - "When Better Prompts Hurt" paper (evaluation-driven iteration, Define/Test/Diagnose/Fix)
  - "Fix the Prompt is a Root Cause Fallacy" (AI failure taxonomy: 46% env, 25% config)
  - Braintrust 2026 comparisons (prompt management tools + promptfoo alternatives)
  - Agenta (Git-like prompt versioning)
  - LLM Testing Tools 2026 engineering guide

---

## 3. Architecture

### 3.1 File Structure

```
ai-prompt-engineering/
├── CAPABILITY.md            # Main SKILL — Step 0 router + 4-phase lifecycle
│                            # YAML frontmatter: name + description (load-bearing)
│                            # Step 0: signal-word routing table → load relevant refs
│                            # Two entry modes: /write (new) + /audit (existing)
│                            # Budget: ≤1200 lines (router + phases, rules in references/)
│
├── README.md                # Quick start: install + first use + FAQ
├── install.sh               # Cross-agent installer (--agent flag for Phase N stubs)
├── CHANGELOG.md
├── LICENSE                   # Apache 2.0
├── LICENSE-ATTRIBUTION.md    # Source attribution for researched content
│
├── references/
│   ├── claude.md            # Claude 4.x-specific rules (7 rules: effort param, prefill
│   │                        # deprecated, literal following, cache arch, etc.)
│   ├── failure-catalog.md   # 6 production failure modes with post-mortems
│   ├── ci-cd-templates.md   # 3-tier CI/CD pipeline templates
│   ├── few-shot-design.md   # Few-shot example design: 5-question quality assessment,
│   │                        # selection strategy, token budget, diversity/gradient rules
│   └── output-format.md     # Output format control: schema definition, compliance
│                            # verification (≥95%), format type selection matrix
│
├── tools/
│   ├── selection-matrix.md  # When to use promptfoo vs DSPy vs DeepEval
│   │                        # Includes DSPy optimizer sub-matrix (MIPROv2 vs COPRO vs
│   │                        # BootstrapFewShot — when, input/output, cost)
│   └── promptfoo-starter.yaml  # Ready-to-use config: 18 test cases
│                               # (10 core + 5 edge + 3 adversarial)
│
├── checklists/
│   ├── pre-deploy.md        # Pre-deployment quality checklist
│   └── regression.md        # Prompt version regression testing protocol
│
└── examples/
    └── system-prompt-template.md  # Annotated system prompt skeleton
```

### 3.2 CAPABILITY.md Structure

**Interaction Contract** (CR P1-4 fix):
Professional prompt engineer — challenge vague requirements with specific questions
(e.g., "What's the output consumer — API code or human reader?"), but do not refuse
to proceed. Present tradeoffs, human decides. Not adversarial (unlike product-thinking),
not passive (unlike web-backend router).

**Step 0: Context Detection Router** (BA P0-3 fix — follows web-backend pattern):
Signal-word routing table at the top of CAPABILITY.md. Matches user input to entry mode + relevant references.

| Signal Words | Entry Mode | Load References |
|-------------|------------|-----------------|
| "write prompt", "design prompt", "system prompt for" | `/write` | references/claude.md (if Claude target) |
| "few-shot", "examples", "shots" | `/write` | references/few-shot-design.md |
| "output format", "JSON schema", "structured output" | `/write` | references/output-format.md |
| "hallucinating", "drifting", "broken prompt", "optimize" | `/audit` | references/failure-catalog.md |
| "CI/CD", "pipeline", "deploy prompt", "version" | Phase 4 direct | references/ci-cd-templates.md |
| "test prompt", "eval", "promptfoo", "red team" | Phase 2 direct | tools/selection-matrix.md |
| "model update", "prompt drift", "regression" | `/audit` | references/failure-catalog.md + references/claude.md |

**Two entry modes:**
- `/write` — Design a new prompt from scratch → Phase 1 → 2 → 3 → 4
- `/audit` — Diagnose/optimize an existing prompt → Phase 3 (with escalation gate) → 2 → 4

**Phase 1: Write** — Design system prompt (core focus)
- Role definition with value anchoring (not "helpful assistant")
- Constraint design: MUST/NEVER ≤10, front 30% placement
- Anti-hallucination: grounding constraints + capability declaration
- Security: prompt injection defense (delimiter isolation, scaffolding)
- **Context architecture**: token audit, U-shaped attention placement, stable prefix vs dynamic suffix
- If task involves few-shot → load `references/few-shot-design.md` (5-question quality assessment, selection strategy, diversity/gradient, token budget ≤40%)
- If task involves structured output → load `references/output-format.md` (schema definition, compliance verification ≥95%, format type selection)
- Tool: none (pure prompt craft), references/claude.md for model-specific rules
- Output: complete system prompt + optional few-shot examples + optional output schema

**Phase 2: Test** — Automated testing with promptfoo
- Golden dataset creation: 10 core + 5 edge + 3 adversarial (18 minimum)
- Generate promptfooconfig.yaml (agent writes the YAML config)
- Execute: `npx promptfoo eval --no-cache`
- Result interpretation: PASS rate, consistency, cost, latency
- Red teaming: vulnerability scan (50+ types)
- Tool: promptfoo CLI
- **Exit criteria**: all test assertions pass (PASS rate ≥80% on golden dataset)
- Output: test results + pass/fail analysis + promptfooconfig.yaml

**Phase 3: Optimize** — Diagnose + iterate
- **Entry criteria**: test failures exist that need diagnosis, OR user explicitly requests optimization via `/audit`
- 6-dimension diagnostic scan (task clarity, context sufficiency, format precision, scope boundary, reasoning support, agentic safety)
- Score each dimension 1-10, ≤4 = needs fix
- **Escalation gate** (BA P0-2 + CR P1-3 fix): if ≥2 dimensions score ≤2, escalate to Phase 1 redesign before optimization. This ensures `/audit` users with fundamentally broken prompts don't waste time optimizing a bad foundation.
- Context + format diagnosis: load `references/output-format.md` and check compliance; load context audit steps from Phase 1 for token/attention analysis. (This ensures `/audit` path has access to capabilities originally in Phase 1.)
- Tradeoff presentation: ≥2 options per fix (human decides)
- Apply fixes with 6-point pre-delivery check
- **Regression verification** (distinct from Phase 2 initial test): confirm optimization didn't break passing tests
- DSPy programmatic optimization when applicable: consult `tools/selection-matrix.md` DSPy optimizer sub-matrix (MIPROv2 for large search space, COPRO for fast iteration, BootstrapFewShot for demo generation)
- Tool: promptfoo (regression verify), DSPy (optimize), DeepEval (metrics)
- Output: optimized prompt + before/after comparison

**Phase 4: Ship** — Version + CI/CD + deploy
- Directory structure for prompt versioning (git-native)
- CHANGELOG with Why + test results
- Semantic versioning: MAJOR (behavior change) / MINOR (improvement) / PATCH (typo)
- 3-tier CI/CD config generation → load `references/ci-cd-templates.md`
- Model version pinning guidance (pin exact version, never use alias)
- Prompt drift monitoring setup
- Tool: git + promptfoo + GitHub Actions template
- Output: versioned prompt directory + CI config

### 3.3 Anti-Slop Design Rules

From research — rules to prevent the pack from producing generic output:

1. **No generic system prompts**: "You are a helpful assistant" is explicitly marked as anti-pattern. Must have domain + value anchoring.
2. **No manual CoT for reasoning-native models**: Claude 4.x with `effort` parameter doesn't need hand-written Chain-of-Thought (but keep CoT in few-shot examples)
3. **No "MUST USE" aggressive language on Claude 4.6+**: Causes over-triggering
4. **No testing without assertions**: Every test case needs ≥1 assertion, not just "looks good"
5. **No version without test results**: Every prompt version must link to a test run
6. **No prompt fix without root cause**: Check the failure taxonomy (46% env, 25% config) before blaming the prompt

---

## 4. Design Decisions

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | 7 capabilities → 4 lifecycle phases | 7 independent / 4 lifecycle / 3 skills | 4 lifecycle phases | Prompt engineering is a workflow (write→test→optimize→ship), not a judgment collection |
| 2 | Tool integration depth | Advise / Generate / Mixed | Agent generates configs | Pack tells agent to write promptfooconfig.yaml, run CLI, interpret results |
| 3 | Multi-model handling | Claude-only / Universal / Inline branches | Universal + model-specific references/ | 70% of rules are model-agnostic; Claude-specific in references/claude.md |
| 4 | Target user | Human / AI agent / Both | AI coding agent | Written as SKILL.md, not textbook. Agent reads and executes. |
| 5 | Pack shape | Router+refs (web-backend) / Deep skills (product-thinking) / Hybrid | Hybrid | Lifecycle workflow SKILL + reference files for rules/templates |

---

## 5. Required Evidence Manifest

```yaml
expert_reviews:
  - .tad/evidence/reviews/blake/capability-pack-ai-prompt-engineering/code-reviewer.md
  - .tad/evidence/reviews/blake/capability-pack-ai-prompt-engineering/backend-architect.md
gate_verdicts:
  - .tad/evidence/completions/capability-pack-ai-prompt-engineering/GATE3-REPORT.md
completion:
  - .tad/active/handoffs/COMPLETION-20260507-capability-pack-ai-prompt-engineering.md
knowledge_updates:
  - .tad/project-knowledge/architecture.md  # if new capability pack patterns discovered
```

---

## 6. Implementation Steps

### P1: Scaffold
Create `~/ai-prompt-engineering/` with full directory structure per §3.1.
Initialize git repo. Create LICENSE (Apache 2.0) + README.md skeleton.
install.sh following the web-backend pattern (--agent flag with Phase N stubs for codex/cursor/gemini).

### P2: CAPABILITY.md — Main SKILL
Write the 4-phase lifecycle router. YAML frontmatter: `name: ai-prompt-engineering`, `description: Production prompt lifecycle...`.
Two entry modes: `/write` and `/audit`.
Each phase: numbered workflow steps with inline CLI commands.
Total budget: ≤2000 lines (including all inline content).

### P3: references/claude.md
Claude 4.x-specific rules from Q3 research findings (7 rules, each as `### Rule N:` heading):
- Rule 1: `effort` parameter replaces `budget_tokens` and manual CoT
- Rule 2: Prefilling assistant messages deprecated (400 error on Mythos)
- Rule 3: Literal instruction following on 4.7 — must explicitly state scope
- Rule 4: "MUST USE" → normal language (over-triggering on 4.6+)
- Rule 5: One-shot upfront requirements (multi-turn drains reasoning tokens)
- Rule 6: Prompt caching architecture: stable prefix + dynamic suffix
- Rule 7: Claude 4.7 reasons more, uses tools LESS — raise `effort` to `high`/`xhigh` to increase tool use

### P4: references/failure-catalog.md
6 production failure modes from Q6 with concrete post-mortems:
1. Format drift (generic "helpful" conflicts with task constraints, -10%)
2. Hallucination in RAG (no grounding constraints, -13.3% citations)
3. Silent regression (provider silent model update)
4. Context overflow + zombie memory (60% fact destruction)
5. Prompt injection (84% attack rate in multi-agent)
6. "Fix the prompt" fallacy (46% env faults, 25% config)

Each entry uses heading format `## FM-N: [Name]` (e.g., `## FM-1: Format Drift`).
Each entry has 3 sub-sections: (a) what went wrong, (b) root cause, (c) fix.

### P5: references/ci-cd-templates.md
3-tier CI/CD pipeline templates from Q2:
- Tier 1: per-commit (<2 min): JSON format, keywords, token budget
- Tier 2: per-PR (10-20 min): LLM-as-judge regression on golden set, blocks merge
- Tier 3: weekly/pre-release (60-90 min): vulnerability scan, jailbreak, edge-case

Include: GitHub Actions YAML examples, promptfoo config snippets.

### P6: tools/selection-matrix.md + tools/promptfoo-starter.yaml
When to use which tool:
| Tool | When | Why |
|------|------|-----|
| promptfoo | Testing + red teaming + CI/CD | CLI-native, YAML configs, 50+ vulns |
| DSPy | Automated optimization | Programmatic, MIPROv2/COPRO, compiles prompts |
| DeepEval | Quality metrics + debugging | pytest-native, 50+ scored metrics with explanations |

promptfoo-starter.yaml: ready-to-use config with 18 test cases (10 core + 5 edge + 3 adversarial).
Label starter as "Starter — minimum viable. Production recommendation: 20+ per research findings."

DSPy optimizer sub-matrix (inside selection-matrix.md):
| Optimizer | When | Input | Cost |
|-----------|------|-------|------|
| MIPROv2 | Large search space, best quality | 5-10 examples + metric | 200+ LLM calls |
| COPRO | Fast iteration, coordinate ascent | metric + `depth` param | 50-100 LLM calls |
| BootstrapFewShot | Need demonstrations, not instruction tuning | teacher module + `max_demos` | Low (few-shot only) |

**Braintrust and Agenta exclusion rationale** (CR P0-4): Both were evaluated in research Q1.
Braintrust requires SaaS login for its Loop AI features (auto-generates datasets from logs) — not CLI-native for agent automation. Agenta is SDK-first with a collaborative web UI, not a terminal tool. Both are valid for teams but don't fit this pack's "AI agent runs from terminal" constraint. Mentioned in selection-matrix.md as "Evaluated, not included" with rationale.

### P7: checklists/ + examples/
- checklists/pre-deploy.md: 6-point pre-delivery check (tool syntax, critical weight, signal strength, fabrication audit, token efficiency, first-pass success)
- checklists/regression.md: version upgrade regression protocol
- examples/system-prompt-template.md: annotated skeleton with role + constraints + format lock + anti-hallucination + security

### P8: LICENSE-ATTRIBUTION.md + CHANGELOG.md
Source attribution for all researched content (Lakera Apache 2.0, Anthropic docs, promptfoo MIT, DSPy MIT, research papers). CHANGELOG v1.0.0 entry.

**Grounded Against** (Alex step1c):
- ~/web-backend/CAPABILITY.md (head 50, read at 2026-05-07 — structural reference)
- ~/web-backend/install.sh (head 50, read at 2026-05-07 — install pattern)
- ~/product-thinking/skills/pressure-test.md (head 50 — deep skill interaction pattern reference)
- .tad/domains/ai-prompt-engineering.yaml (full read — existing YAML pack baseline)

---

## 📚 Project Knowledge

### 步骤 1: 相关类别
- [x] architecture — capability pack patterns

### 步骤 2: 历史经验

| 文件 | 相关记录数 | 关键提醒 |
|------|-----------|----------|
| architecture.md | 7 | Capability pack patterns (frontmatter, install, deep skills, rule sourcing, etc.) |

### ⚠️ Blake 必须注意的历史教训

1. **Capability Pack: YAML Frontmatter is Load-Bearing** (architecture.md)
   - SKILL.md without frontmatter installs but is invisible to Claude Code
   - CAPABILITY.md MUST start with `---\nname: ...\ndescription: ...\n---`

2. **Capability Pack Rule Sourcing: Read the Cited Source** (architecture.md)
   - Never write rules from training data intuition with `[Source: X]` tag
   - WebFetch or `gh api` the actual source and read before writing the rule

3. **Capability Pack: Multi-Agent Install Pattern** (architecture.md)
   - Add `--agent` flag from Phase 1; future agents return exit 2 with "not yet implemented"

4. **Capability Pack: 3-Skill Deep Design vs Template Proliferation** (architecture.md)
   - 3 deep skills (500-800 lines each) > 40 thin templates (50-100 lines each)
   - For this pack: 1 deep CAPABILITY.md (≤2000 lines) + references/ for modular rules

---

## 9. Acceptance Criteria

| # | Criterion | Verification |
|---|-----------|-------------|
| AC1 | ~/ai-prompt-engineering/ exists with all files from §3.1 | `find ~/ai-prompt-engineering/ -type f \| wc -l` ≥ 14 |
| AC2 | CAPABILITY.md has YAML frontmatter with name + description | `head -5 ~/ai-prompt-engineering/CAPABILITY.md \| grep -c "name:"` = 1 |
| AC3 | CAPABILITY.md has 4 lifecycle phases (Write/Test/Optimize/Ship) | `grep -cE "^## Phase [1-4]" ~/ai-prompt-engineering/CAPABILITY.md` = 4 |
| AC4 | Two entry modes (/write and /audit) + Step 0 routing table | `grep -c "/write\|/audit" ~/ai-prompt-engineering/CAPABILITY.md` ≥ 2 AND `grep -c "Step 0" ~/ai-prompt-engineering/CAPABILITY.md` ≥ 1 |
| AC5 | references/claude.md has ≥7 rules with `### Rule` headings | `grep -c "^### Rule" ~/ai-prompt-engineering/references/claude.md` ≥ 7 |
| AC6 | references/failure-catalog.md has 6 failure modes with `## FM-` headings | `grep -c "^## FM-" ~/ai-prompt-engineering/references/failure-catalog.md` = 6 |
| AC7 | references/ci-cd-templates.md has 3-tier pipeline | `grep -c "Tier" ~/ai-prompt-engineering/references/ci-cd-templates.md` ≥ 3 |
| AC8 | tools/selection-matrix.md covers promptfoo + DSPy + DeepEval + DSPy optimizer sub-matrix | `grep -cE "promptfoo\|DSPy\|DeepEval" ~/ai-prompt-engineering/tools/selection-matrix.md` ≥ 6 |
| AC9 | tools/promptfoo-starter.yaml is valid YAML with ≥18 test cases | `python3 -c "import yaml; yaml.safe_load(open('$HOME/ai-prompt-engineering/tools/promptfoo-starter.yaml'))" && echo PASS` AND `grep -c "assert:" ~/ai-prompt-engineering/tools/promptfoo-starter.yaml` ≥ 18 |
| AC10 | install.sh installs to .claude/skills/ with --agent flag | `grep -c "\-\-agent" ~/ai-prompt-engineering/install.sh` ≥ 1 |
| AC11 | checklists/pre-deploy.md has ≥6 check items | `grep -c "^\- \[" ~/ai-prompt-engineering/checklists/pre-deploy.md` ≥ 6 |
| AC12 | examples/system-prompt-template.md is annotated (≥5 annotation markers) | `grep -cE "WHY:\|NOTE:\|RULE:" ~/ai-prompt-engineering/examples/system-prompt-template.md` ≥ 5 |
| AC13 | Total pack size ≤5000 lines | `find ~/ai-prompt-engineering/ -name "*.md" -o -name "*.yaml" -o -name "*.sh" \| xargs wc -l \| tail -1` ≤ 5000 |
| AC14 | Zero TAD terminology in pack content | `grep -rli "handoff\|Gate 3\|Gate 4\|Ralph Loop\|Blake (Execution\|Alex (Solution" ~/ai-prompt-engineering/ --include="*.md" \| grep -v CHANGELOG \| grep -v LICENSE` = empty |
| AC15 | LICENSE file exists (Apache 2.0) | `grep -c "Apache" ~/ai-prompt-engineering/LICENSE` ≥ 1 |
| AC16 | Git repo initialized with ≥1 commit | `cd ~/ai-prompt-engineering && git log --oneline \| wc -l` ≥ 1 |
| AC17 | Layer 2: ≥2 distinct expert reviews | Per Blake SKILL hard_requirement_distinct_reviewers |
| AC18 | references/few-shot-design.md exists with quality assessment | `test -f ~/ai-prompt-engineering/references/few-shot-design.md && echo PASS` |
| AC19 | references/output-format.md exists with compliance verification | `test -f ~/ai-prompt-engineering/references/output-format.md && echo PASS` |

---

## 10. Important Notes

### 10.1 What This Pack Is NOT
- NOT a prompt engineering tutorial (Anthropic's tutorial already does that)
- NOT a tool wrapper (don't just document promptfoo commands)
- NOT Claude-only (core workflow is model-agnostic, Claude specifics in references/claude.md)

### 10.2 Key Architectural Constraints
- Pack MUST be zero-dependency on TAD framework
- CAPABILITY.md is the entry point — agent reads it as a SKILL
- references/ files are loaded on-demand per phase (not all at once)
- Total ≤5000 lines across all files

### 10.3 Anti-Patterns from Research
- ❌ "You are a helpful assistant" — must have domain + value anchoring
- ❌ Manual CoT for reasoning-native models (effort parameter instead)
- ❌ Testing without assertions (every test case needs ≥1)
- ❌ Version without test results (must link to a test run)
- ❌ Prompt fix without root cause (check failure taxonomy first)
- ❌ Generic "MUST USE" language on Claude 4.6+ (over-triggering)

---

## 11. Decision Summary

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | Capability scope | 7 YAML capabilities / 4 lifecycle / 3 skills | 4 lifecycle phases | Prompt engineering is a workflow, not a judgment collection |
| 2 | Tool integration | Advise / Generate / Mixed | Agent generates | Pack instructs agent to write YAML, run CLI, interpret results |
| 3 | Multi-model | Claude-only / Universal / Inline | Universal + refs/ | 70% model-agnostic; Claude-specific in references/claude.md |
| 4 | Target user | Human / AI agent / Both | AI agent | SKILL.md style, not textbook |
| 5 | Pack shape | Router+refs / Deep skills / Hybrid | Hybrid | Lifecycle SKILL + reference files for rules/templates |
| 6 | Diff vs existing guides | Duplicate / Complement / Replace | Complement | Our gap = CI/CD + testing + drift handling (what guides miss) |
| 7 | Braintrust/Agenta | Include / Exclude / Mention | Exclude (mention in selection-matrix) | Both require SaaS/web UI for core features — not CLI-native for agent automation. Documented as "evaluated, not included" with rationale. |
| 8 | CAPABILITY.md budget | 2000 lines / 1200 lines / 800 lines | ≤1200 lines (router) + refs | BA P2-3: web-ui-design is 1197 lines for 9 capabilities — 2000 for 4 phases is over-inline. Extract depth to references/. |

---

## 9.2 Expert Review Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| CR P0-1 | AC6 heading pattern won't match implementation | AC6 → `^## FM-` heading format, P4 → `## FM-N: [Name]` format | Resolved |
| CR P0-2 | AC5 counts all headings, not rules | AC5 → `^### Rule` heading count ≥ 7 | Resolved |
| CR P0-3 | AC14 "Alex" too generic, false positives | AC14 → `Alex (Solution` and `Blake (Execution` (TAD-specific phrases only) | Resolved |
| CR P0-4 | Braintrust/Agenta exclusion rationale missing | P6 + Decision #7 — SaaS/web-UI not CLI-native | Resolved |
| BA P0-1 | Phase 1 compresses 4 YAML capabilities into 1 phase | §3.1 + §3.2 → extract few-shot-design.md + output-format.md to references/, Phase 1 loads on-demand | Resolved |
| BA P0-2 | /audit path orphans context/format concerns | §3.2 Phase 3 → escalation gate + context/format diagnosis with ref loading | Resolved |
| BA P0-3 | Missing Step 0 routing table | §3.2 → Step 0 signal-word routing table added | Resolved |
| CR P1-2 | Phase 2/3 overlap on promptfoo | §3.2 → Phase 2 exit criteria + Phase 3 entry criteria + "regression verification" label | Resolved |
| CR P1-3 | /audit needs escalation to Phase 1 | §3.2 Phase 3 → escalation gate (≥2 dims ≤2 → Phase 1) | Resolved |
| CR P1-4 | No interaction contract | §3.2 → Interaction Contract added | Resolved |
| CR P1-6 | Q3 has 7 Claude rules, P3 lists 6 | P3 → 7 rules with Rule 7 (tool use frequency) added | Resolved |
| BA P1-3 | Golden dataset count mismatch (10 vs 18) | P6 → 18 test cases (10+5+3), AC9 → assert count ≥ 18 | Resolved |
| BA P1-5 | DSPy integration underspecified | P6 → DSPy optimizer sub-matrix (MIPROv2/COPRO/BootstrapFewShot) | Resolved |
| BA P2-3 | CAPABILITY.md 2000 lines too high | Decision #8 → ≤1200 lines, rest in references/ | Resolved |
| CR P1-5 | AC9 only validates YAML syntax | AC9 → added `assert:` count ≥ 18 check | Resolved |
| CR P2-3 | AC12 weak (wc -l only) | AC12 → annotation marker count (WHY:/NOTE:/RULE:) ≥ 5 | Resolved |
