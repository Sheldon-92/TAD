# TAD Method - Triangle Agent Development

**Version 2.32.1 - Reading Companion + Pack Quality**

> 📚 **[Documentation Portal](docs/README.md)** | **[Specialized Tools Guide](docs/MULTI-PLATFORM.md)** | **[Ralph Loop Guide](docs/RALPH-LOOP.md)** | [Version History](#version-history)

---

## 💡 Philosophy: Beneficial Friction

**TAD is not about making AI do more. It's about making human involvement more valuable.**

Many AI coding tools promise: "Give AI a goal, it handles everything." This sounds appealing, but in practice leads to:
- **Requirement drift**: AI's understanding diverges from what you actually need
- **False quality**: AI says "all tests pass" — but it wrote those tests itself
- **Priority confusion**: AI spends 80% of time on 20% of value

TAD takes a different approach: **AI can do a lot, but must stop at three critical points for human confirmation.**

### The Three Friction Points

| Point | Why Human is Essential | Without Human |
|-------|----------------------|---------------|
| **Requirement Clarification** | Only humans know the real problem to solve | AI builds "technically correct but directionally wrong" things |
| **Priority Decision** | Involves resources, time, business judgment | AI sorts by "technical complexity" instead of value |
| **End-to-End Acceptance** | Only humans can judge "does this actually work" | AI passes all unit tests but UX is broken |

These three points correspond to the **Value Guardian** role in the Triangle Model — not participating in every step, but gatekeeping at critical nodes.

### Beneficial vs. Wasteful Friction

| Wasteful Friction | Beneficial Friction |
|-------------------|---------------------|
| Copy-pasting code manually | Requirement clarification dialogue |
| Formatting adjustments | Priority decisions |
| Environment setup | End-to-end acceptance testing |
| Waiting for builds | Feedback when acceptance fails |

Wasteful friction should be automated. Beneficial friction should be **preserved and strengthened** — it's where value is created.

### A Deeper Insight

**The stronger AI becomes, the more critical human checkpoints are.**

When AI is weak, humans must participate in every step. When AI is strong, humans can step back to higher levels — but those few critical points become even more important, because once AI deviates there, it races toward the wrong direction faster.

This is why "fully autonomous AI development" is a false premise — **not because AI can't do it, but because AI without human gatekeeping produces unreliable results.**

---

## 🔄 Codex CLI Support (v2.26.0)

TAD runs on Codex CLI with the same SKILL files. Use `$alex` or `$blake` to activate roles:

```bash
bash tad.sh --platform both --yes   # Dual-platform (recommended)
bash tad.sh --platform codex --yes  # Codex only
# In Codex: $alex or $blake (auto-discovered via .agents/skills/)
```

See [INSTALLATION_GUIDE.md "Codex CLI Setup"](INSTALLATION_GUIDE.md) for details.

---

## 🎯 What's New in v2.28

### Upgrade Lifecycle System (v2.28) — Zero-Garbage Upgrades
Every version upgrade is now driven by a **declarative migration manifest** (`delete/rename/merge/verify`), executed by a shared engine with a 5-step path safety pipeline:

- **Migration Engine** (`migration-engine.sh`): Single `rm` choke point with TOCTOU re-validation, user-modified file detection via `git show`, fail-closed on malicious paths
- **CLAUDE.md Merge**: `<!-- TAD:PROJECT-CONTENT-BELOW -->` marker splits framework head (auto-updated) from user content (preserved byte-identical)
- **Publish Gate**: `release-verify.sh migration` mode — delete a file without writing a manifest and the release is blocked
- **12 Historical Manifests**: v2.19.0 → v2.27.0 complete chain, so upgrades from any version work
- **22 E2E Fixtures**: Normal/idempotent/user-modified/malicious-injection/merge/gate scenarios
- **tad.sh + \*sync Integration**: Both paths use the same engine (zero dual-implementation)

```bash
# What happens now when you upgrade:
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/tad.sh | bash -s -- --yes
# 1. Downloads new version
# 2. Copies framework files
# 3. ⭐ Runs migration engine: cleans old files, renames moved files, merges CLAUDE.md
# 4. Verifies install completeness
# Result: new files in, old files gone, your content untouched
```

### Earlier Highlights
- **v2.27.0**: SKILL progressive loading, circular-trigger body-integrity checker
- **v2.26.0**: Codex CLI support, dual-platform runtime architecture
- **v2.25.0**: Universal AC-driven Gate (§9.1 primary verification)
- **v2.24.0**: Non-dev deliverable lane, categorical/checklist verdict shapes
- **v2.23.0**: Self-deriving release/sync (deny-list derivation)
- **v2.21.0**: 24 capability packs via NotebookLM pack factory
- **v2.8.0**: Self-evolving framework, 20 domain packs, execution traces

---

## 🚀 Installation & Upgrade

```bash
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/tad.sh | bash -s -- --yes
```

一行命令，全量安装 Claude Code + 全部 25 个 capability packs。升级也用同一命令。

Codex 用户或想选 packs：加 `--platform codex --packs web-frontend,web-backend`，或用交互式 `npx github:Sheldon-92/TAD`。

> 详细指南见 **[INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md)**

### Verify Installation

```bash
cat .tad/version.txt
# Should show: 2.30.0

# Check migration engine installed
test -f .tad/hooks/lib/migration-engine.sh && echo "Migration engine: OK"

# Check historical manifests
ls .tad/migrations/*.yaml | wc -l
# Should show: 12+ manifests
```

---

## ⚡ Quick Start (5 minutes)

### 1. Install TAD
```bash
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/tad.sh | bash -s -- --yes
```

### 2. Open Two Terminals

| Terminal 1 | Terminal 2 |
|------------|------------|
| `/alex` | `/blake` |
| Design & Planning | Implementation |

### 3. Start Collaboration

**Terminal 1 (Alex):**
```
You: I want to add user authentication
Alex: [Uses AskUserQuestion to clarify requirements]
Alex: [Creates handoff after Socratic inquiry]
Alex: "Handoff ready. Please tell Blake to execute it in Terminal 2."
```

**Terminal 2 (Blake):**
```
You: Execute the auth handoff
Blake: [Reads handoff, implements, runs Gate 3/4]
Blake: [Creates completion report]
```

**Terminal 1 (Alex):**
```
You: Blake finished, here's the completion report
Alex: [Reviews with subagents, accepts or requests changes]
```

---

## 🔺 The Triangle Model

```
           Human
       (Value Guardian)
            /\
           /  \
          /    \
         /      \
   Agent A ──── Agent B
  (Solution)  (Execution)
   Terminal 1  Terminal 2
```

### Human - The Value Guardian
- **Defines** what is valuable for users
- **Bridges** information between Alex and Blake
- **Decides** when conflicts arise
- **Verifies** final delivery meets expectations

### Agent A (Alex) - Solution Lead
- **Elicits** requirements through Socratic inquiry
- **Designs** solutions with expert review
- **Creates** handoffs for Blake
- **Owns** Gate 1 (Requirements) & Gate 2 (Design)

### Agent B (Blake) - Execution Master
- **Implements** based on handoff only
- **Tests** with mandatory subagent calls
- **Owns** Gate 3 (Implementation) & Gate 4 (Integration)
- **Reports** completion for Alex review

---

## 🚦 4-Gate Quality System (v2.0)

| Gate | Name | Owner | What Changed in v2.0 |
|------|------|-------|----------------------|
| Gate 1 | Requirements Clarity | Alex | (unchanged) |
| Gate 2 | Design Completeness | Alex | (unchanged) |
| **Gate 3 v2** | **Implementation + Integration** | **Blake** | **Expanded: includes old Gate 4 Part A** |
| **Gate 4 v2** | **Acceptance + Archive** | **Alex** | **Simplified: pure business acceptance** |

### Gate 3 v2 (Blake - Technical Quality)

**Layer 1 (Self-Check):**
- build, test, lint, tsc
- Max 15 retries with circuit breaker

**Layer 2 (Expert Review):**
- Group 1: `code-reviewer` (blocking)
- Group 2: `test-runner`, `security-auditor`, `performance-optimizer` (parallel)
- Max 5 rounds with escalation to Alex

**Evidence Required:**
- All expert review files in `.tad/evidence/reviews/`
- Iteration evidence in `.tad/evidence/ralph-loops/`
- Knowledge assessment

### Gate 4 v2 (Alex - Business Acceptance)

**What Alex Verifies:**
- Handoff requirements satisfied
- Business value delivered
- User acceptance confirmed

**Actions:**
- Archive handoff to `.tad/archive/handoffs/`
- Record final knowledge assessment

---

## 📋 Key Commands

| Command | Agent | Purpose |
|---------|-------|---------|
| `/alex` | - | Activate Alex (Solution Lead) |
| `/blake` | - | Activate Blake (Execution Master) |
| `/gate N` | Both | Execute quality gate N |
| `/knowledge-audit` | Both | Audit project knowledge health |
| `/tad-init` | - | Initialize TAD in new project |
| `/tad-maintain` | - | Document health check and sync |

### Alex Commands (use `*` prefix)
- `*analyze` - Start requirement elicitation
- `*design` - Create technical design (with Capability Pack loading)
- `*handoff` - Generate handoff with expert review
- `*review` - Review Blake's completion
- `*accept` - Accept and archive handoff
- `*optimize` - Analyze traces → propose improvements
- `*evolve` - Cross-project framework evolution
- `*status` - Panoramic project status view

### Blake Commands (use `*` prefix)
- `*develop` - Start Ralph Loop (auto Layer 1 + Layer 2)
- `*layer1` - Run Layer 1 self-checks only
- `*layer2` - Run Layer 2 expert review only
- `*ralph-status` - Check Ralph Loop state
- `*ralph-resume` - Resume from checkpoint
- `*gate 3` - Execute Gate 3 v2 (technical quality)
- `*complete` - Generate completion report

---

## 📚 Project Knowledge System

TAD captures project-specific learnings in `.tad/project-knowledge/`:

```
.tad/project-knowledge/
├── README.md           # How to use knowledge system
├── ux.md               # UX patterns and decisions
├── code-quality.md     # Code standards learned
├── security.md         # Security considerations
├── architecture.md     # Architectural decisions
└── [custom].md         # Create new categories as needed
```

### Knowledge Capture Flow
1. Gate 3/4 passes
2. Agent assesses: "Did I learn something project-specific?"
3. If yes → Record in appropriate category
4. If no → Skip (don't record obvious/generic knowledge)

### `/knowledge-audit` Command
Run periodically to check knowledge health:
- Files with content vs empty
- Missing foundational sections
- Categories needing attention

---

## 🔄 Version History

| Version | Key Features |
|---------|--------------|
| **v2.29.0** | **Self-Evolution Pruning & Feedback Collector: retired near-zero-yield loops (*dream/*evolve/*optimize, 18→1 measured yield) replaced by 3-tier skill formalization (T1 in-session ceremony + T2 skill-library + T3 *harvest cross-project promotion); Feedback Collector complete (structured human feedback for non-code artifacts, overlay model, /playground deprecated); TAD Friction Protocol (friction is never a skip reason); codex parity gate v2 (DIRECTION signal + --fix); layer2-audit fail-closed** |
| **v2.28.0** | **Upgrade Lifecycle System: migration engine (5-step safety pipeline, single rm choke point, TOCTOU re-validation) + tad.sh/\*sync integration + CLAUDE.md merge execution + publish gate (hard-block on unmanifested deletions) + 12 historical manifests (v2.19.0→v2.27.0) + 22 E2E fixtures + acceptance tooling** |
| **v2.27.0** | **SKILL progressive loading (36 protocols → references/), circular-trigger body-integrity checker, dual-platform runtime freshness verifier** |
| **v2.26.0** | **Codex CLI support — dual-platform native runtime, compatibility ledgers, `.codex/` policy framework** |
| **v2.25.0** | **Universal AC-Driven Gate: §9.1 becomes primary verification source for Gate 3/4. Hardcoded tsc/test/lint replaced by task-scoped ACs.** |
| **v2.24.1** | **npx cross-platform installer (`bin/tad-install.mjs`): `npx github:Sheldon-92/TAD` offers interactive platform selection (Claude Code / Codex CLI) + capability-pack selection with one-line descriptions. Codex users get a slimmed install (excludes the 86K Claude-edition alex/blake SKILLs + hooks via deny-delta). `tad.sh --platform <claude-code\|codex>` + `--packs <list>` config-driven routing via `.tad/platform-codes.yaml`. README + INSTALLATION_GUIDE npx docs.** |
| **v2.24.0** | **Non-dev deliverable lane — Gate 3/4 deliverable branches add `categorical` (rigor band, decoupled from BUILD/PIVOT/KILL via order-of-emission firewall + swap test) and `checklist` (export-spec pass/fail with ≥1-required guard) verdict_shapes alongside `weighted`. product-thinking gains a dogfood-verified categorical rubric; voice/video checklist gate-logic verified via synthetic fixture. visual-code-bridge (React fiber source locator) + ai-podcast-production pack (registry → 25 packs). Triple-Question KA simplified to draft-then-confirm.** |
| **v2.23.1** | **Triple-Question KA — Knowledge Assessment expanded from 2 to 3 questions (knowledge + skill + workflow). Skillify Step 5 routes patterns to SKILL.md (judgment) or .workflow.js (orchestration). Alex .workflow.js authoring carve-out. Workflow completion trigger (agent_count ≥ 3).** |
| **v2.23.0** | **Self-Deriving Release/Sync — publish, sync, and install now DERIVE their file sets from the repo structure (deny-list) instead of hardcoded lists. Includes derive-sync-set.sh (deny-list single source of truth), release-verify.sh (structure-agnostic version+structural gates), tad.sh self-derivation, and release-runbook SKILL upgrade to derive+verify procedure.** |
| **v2.21.0** | **Agent-Adjacent Pack Factory — 8 new research-grounded capability packs (16→24 total): rag-retrieval, agent-memory, llm-observability, ai-guardrails, data-engineering, agent-orchestration, synthetic-data, knowledge-graph. Built via NotebookLM deep research (~401 sources) → parallel build workflow → adversarial review → cross-model (Codex) review (caught + fixed ~44 factual/API errors the same-model loop missed) → real discriminative behavioral eval (WITH-pack vs no-pack CONTROL). Measured: pack value is cross-vendor (Codex/Gemini) and non-monotonic in model strength (peaks at Sonnet-tier). Honest status: 7/8 behaviorally verified, 1 (data-engineering) pending — CONTROL also passed.** |
| **v2.19.0** | **Observational Trace Instrumentation + ML Pack — (1) v2 observational trace emission: gate_result/expert_review_finding/decision_point/reflexion_diagnosis now fire by PARSING agent-written artifacts (COMPLETION gate3_verdict marker, HANDOFF §11 decision table, review files) instead of unreliable imperative helper calls (1/328 fire rate); handoff_created 6x over-fire fixed; analyzer schema fix + N=0 gate skip guard — self-evolution data layer now functional. (2) *sync directory-list fix: added .tad/domains/ + .tad/hooks/ to sync list (mirrors tad.sh). (3) ML Training capability pack (reference-based, cloud-GPU training judgment). (4) Cloud compute resource awareness in Socratic inquiry. Hooks never fail-closed; no trace schema change.** |
| **v2.14.1** | **Research Adversarial Challenge — Codex+Gemini 双模型 adversarial review 内置研究 pipeline (3 挑战点: Phase 0c 计划/4c 结论/5b 行动); 5 维度挑战 (证据充分性/角度完整性/假设可靠性/因果推理/决策支撑力); 双模型 ADEQUATE+ 通过条件; max 2 轮循环; CHALLENGE_INSTRUCTION 对称常量; fail-closed rating extraction; 清理 1 Epic + 8 Ideas** |
| **v2.14.0** | **YOLO Mode + LSP Code Understanding — (1) YOLO Mode: Alex 可自动驱动 Blake sub-agent 执行多 Phase Epic (step7_execution_mode + yolo_execution_protocol Y1-Y8); 增强 Epic 模板 (Phase Detail Block: Scope/Input/Output/AC/Files); audit-yolo.sh 4-dimension 审计 (产物链/内容真实性/代码验证/时序); dogfood 验证 39/39 PASS. (2) LSP Code Understanding: Claude Code 原生 LSP tool 集成; Alex step1c_lsp + Blake 1_5d_lsp_blast_radius; 12-language auto-provision** |
| **v2.13.0** | **STORM + Elicit + Auto Source + Adaptive Seed — 4 research methodology upgrades: STORM multi-perspective questioning (strategy #4 in step3_5, OBJECTIVES.md-derived stakeholder perspectives); Elicit structured paper extraction (Phase 4.5, academic sources only); Auto Source Discovery (WebSearch + quality-probed add when internal gap enrichment fails, max 3 URLs); Adaptive Research Plan (dynamic seed generation, max 2 user-confirmed seeds); bilibili-handler 4-phase fallback (CC→B站API→yt-dlp→Jina)** |
| **v2.12.0** | **Research Routing + Action Bridge — CLAUDE.md global research routing (deep research → NotebookLM, not WebSearch); /deep-research skill exclusion; research-notebook standalone usage without /alex; step6 Research→Action Bridge (5 next-step options); persistent research knowledge base (NotebookLM notebooks queryable across sessions)** |
| **v2.10.4** | **CRAG Judge Loop + Parallel Curate — Phase 4b auto gap detection in research pipeline (3 signal phrases, per-notebook scope, max 1 re-ask, diminishing returns check); xargs -P5 parallel batch delete for Phase 2 curate (~2x faster); validated on real NotebookLM API (0 rate limit errors)** |
| **v2.10.3** | **Global Skill Exclusion + Tool Quick Reference — prevents global skills from shadowing TAD methods; tool-quick-reference-alex/blake.md loaded at activation (CLI paths for NotebookLM/Codex/Gemini/gh); archived 5 conflicting skills; fixed stale version strings in Alex/Blake SKILL** |
| **v2.10.1** | **GitHub Knowledge Integration — `*research-github` 8-command skill; GitHub Awesome-List Registry (24 domains, 50 lists); Alex step2c_github auto-recommend; notebook auto-refresh; research priority rule; weekly scan automation; domain-pack-feedback loop** |
| **v2.10.0** | **Goal-Driven Research Director + NotebookLM Full Integration — `*research-notebook` 19-command skill; Alex STEP 3.8 research scan; `*research-plan` autonomous goal-driven research; OBJECTIVES.md OKR template; Blake NotebookLM read-only access; cross-model invocation guide** |
| **v2.9.1** | **Cross-Model Orchestration + NotebookLM Knowledge Layer — `*research-notebook` skill (8 commands) for multi-source research (YouTube + PDF + web); cross-model capability catalog (Codex Image-2, NotebookLM, Gemini); notebook lifecycle management; Alex integration for research workflows** |
| **v2.9.0** | **Codex CLI Support — cross-platform TAD via OpenAI Codex (AGENTS.md native role switching, launcher scripts, static Codex-edition SKILLs, 4 operation guides, portable extraction system)** |
| **v2.8.5** | **Compact Recovery (two-layer session state persistence — CLAUDE.md self-check + session-state.md on-disk file; prevents agent identity/task loss after context compaction)** |
| **v2.8.4** | **Token Efficiency (L1 tiered Layer 2 reviewer count by task_type / L2 lazy knowledge load / L4 *express ≤5 files / L6 narrow-scope expert prompts) ~30-35% per architecture handoff savings; Linear integration removed (unused); Hook passive mode (no more additionalContext injection — keyword scoring + log preserved); BUSINESS-VALUE-FIRST rule for handoff/completion 人话版** |
| **v2.8.3** | **Layer 2 Audit (smoke-alarm replacement for Epic 1 mechanical enforcement), Alex `*accept` step4c red-flag, SKILL hardening (anti_rationalization_registry + honest_partial_protocol + Slug Contract), Epic 1 cancelled** |
| **v2.8.2** | **Domain Pack Auto-Loading Hook (UserPromptSubmit + keyword router, 100% acc / 81ms), tad.sh bug fixes** |
| **v2.8.1** | **Commands consolidated into skills (18 command files → skills), deprecation registry** |
| **v2.8.0** | **Self-Evolving Framework, 20 Domain Packs (78 tools), Execution Traces, Quality Gate Hooks** |
| **v2.7.0** | **Hook-Native Architecture, 76% context reduction, PreToolUse gating** |
| **v2.6.0** | **4D Protocol Pair Testing, Autoresearch Optimization, Linear Integration** |
| v2.5.0 | Spec Compliance Reviewer, Anti-Rationalization, TDD Skill, Worktree |
| v2.4.0 | *publish + *sync, Context Refresh, Git Commit Verification |
| v2.3.0 | Multi-Platform Cleanup, Intent Router, *learn, *idea, ROADMAP |
| v2.2.x | Bidirectional Messages, Adaptive Complexity, Pair Testing, Modular Config |
| v2.1.x | Agent-Agnostic Architecture, 9 Skills, `/tad-maintain` |
| v2.0 | Ralph Loop Fusion, Gate 3/4 Restructure |
| v1.8 | Socratic Inquiry, Terminal Isolation, Knowledge Assessment |

---

## 🤔 When to Use TAD

### Use TAD When:
- New feature (>3 files or >1 day work)
- Architecture changes
- Complex multi-step requirements
- Cross-module refactoring

### Skip TAD When:
- Single-file bug fix
- Config changes (.env, versions)
- Documentation updates
- Emergency hotfix

---

## 💡 Key Principles

These principles are the practical implementation of [Beneficial Friction](#-philosophy-beneficial-friction) — each one preserves a human checkpoint where it matters most, while automating everything else.

### 1. Human-in-the-Loop (Beneficial Friction)
Human is not just a requester but the Value Guardian at three critical friction points: requirement clarification, priority decisions, and end-to-end acceptance. Information flows through the human.

### 2. Design Before Code
Alex designs completely before Blake implements. No implementation without handoff. This ensures requirements are clarified (friction point #1) before any code is written.

### 3. Evidence-Based Quality
Every gate requires evidence. Subagent reviews are mandatory, not optional. Automated checks eliminate wasteful friction; human review at gates preserves beneficial friction.

### 4. Knowledge Accumulation
Project learns from every feature. Patterns captured prevent repeated mistakes.

### 5. Adaptive Complexity
Scale process to task size. Small task = light process. Large task = full TAD. Match the amount of beneficial friction to the risk level.

---

## 🛠 Troubleshooting

### "Alex called /blake in same terminal"
This is a VIOLATION. Alex must stop and instruct human to switch to Terminal 2.

### "Gate failed - no evidence file"
Ensure subagents were called and wrote to `.tad/evidence/reviews/`.

### "Handoff created without Socratic inquiry"
Alex must use AskUserQuestion before writing handoff. Re-run with proper flow.

### "Knowledge files empty"
Run `/knowledge-audit --fix` or manually bootstrap with templates.

---

## 🤝 Contributing

TAD evolves through direct improvement in the [TAD repository](https://github.com/Sheldon-92/TAD). If you find issues or have suggestions, modify the framework directly or open an issue.

---

## 📖 Further Reading

- [Documentation Portal](docs/README.md)
- [Specialized Tools Guide](docs/MULTI-PLATFORM.md)
- [Ralph Loop Guide](docs/RALPH-LOOP.md)
- [Agent Skills](.claude/skills/)
- [Configuration Guide](.tad/config.yaml)
- [Skills Reference](.tad/skills/README.md)

---

**Welcome to TAD v2.30.0 - Reading Companion + Pack Quality**

*AI does the work. Humans guard the value.*
