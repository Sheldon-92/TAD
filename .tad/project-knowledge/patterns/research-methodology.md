# Research Methodology Patterns (Layer 2)

> Reusable patterns for research workflows, cross-model orchestration, NotebookLM integration, and source quality.

---

### Long Context Enables In-Session Decision Making (4D Protocol) - 2026-03-25
- **Discovery**: 1M context window changes methodology from "find bugs → fix later" to "discover → discuss → decide → record" in a single session. Context richness at discovery time is highest. Reports become action logs, not bug lists.
- **Action**: Design protocols for in-session decision-making with full context retention.
- **failure_mode**: Naive default: design research protocols as "find issues now, fix later in a separate session." Why wrong: context richness is highest at discovery time — deferring decisions to a later session loses the full context, turning actionable discoveries into stale bug lists that require expensive re-investigation.

### Codex CLI Feasibility and Patterns - 2026-05-01
- **Discovery**: (1) ChatGPT-account Codex = permanent read-only sandbox (writes blocked). (2) `codex exec resume --last` enables multi-turn workflows. (3) SKILL injection via stdin (76KB) works with gpt-5.5. (4) `--full-auto` validated for workspace-write. (5) `codex exec --skip-git-repo-check` required for non-git dirs. (6) stderr `failed to record rollout items` is benign — use exit code. (7) `--commit` incompatible with positional PROMPT — use stdin. (8) Strip-only rule for Codex-edition SKILLs prevents drift.
- **Action**: Test write access with API key. Use `--full-auto` + stdin. Exit code is truth, ignore stderr noise.
- **failure_mode**: Naive default: assume Codex CLI works like a standard REPL (writes allowed, stderr = errors, single-turn). Why wrong: ChatGPT-account Codex has a permanent read-only sandbox (writes blocked), stderr `failed to record rollout items` is benign noise (exit code is truth), and `--commit` is incompatible with positional PROMPT — misunderstanding any of these wastes debugging cycles on non-issues.

### NotebookLM Integration Patterns - 2026-05-03
- **Discovery**: (1) Auth: `notebooklm login` profile ≠ `storage_state.json` — run Playwright export. (2) Min version 0.3.4 (0.1.1 deprecated). (3) YouTube needs captions (conference/official channels). (4) `status: ready` is NOT content quality signal — always run quality probe after import. (5) `source add` (not `note create`) for knowledge feedback loop. (6) 23-43s latency acceptable for research tasks only.
- **Action**: Use absolute venv paths. Run quality probe after every import. PDF is the only reliable import path.
- **failure_mode**: Naive default: trust `status: ready` as confirmation that a NotebookLM source imported successfully with quality content. Why wrong: `status: ready` only confirms the import completed — three failure modes (SPA shell capture, login wall capture, WAF error capture) produce "ready" status with garbage content, so without a post-import quality probe the knowledge base is silently poisoned.

### NotebookLM Research Methodology - 2026-05-05
- **Discovery**: Report is baseline (orientation), multi-round Ask is value (cross-source reasoning). Five steps: create → deep research → curate (clean + deduplicate) → report → multi-round ask → save findings. Deep research imports ~30% error sources, ~25% duplicates. Token efficiency: ~60 tokens/source vs ~10K for WebSearch (150-200x improvement). `-n <id>` for per-command notebook selection (stateless), not `use <id>` (mutates global state in loops).
- **Action**: Report = Step 3 of 5, not final. Curate before asking. Use `-n <id>` in loops.
- **failure_mode**: Naive default: generate a NotebookLM report and treat it as the final research output. Why wrong: the report is orientation (Step 3 of 5) — the real value comes from multi-round Ask (cross-source reasoning). Stopping at the report misses the deepest insights and wastes the ~30% error sources and ~25% duplicates that curation would have caught.

### Cross-Model Orchestration Principles - 2026-05-03
- **Discovery**: (1) Prompt symmetry is load-bearing for comparison validity. (2) Include production incumbent as third-way baseline. (3) Three-way comparison (Claude vs Codex vs production code-reviewer) needed. (4) Codex stderr `failed to record rollout items` is benign. (5) `claude -p` is valid for hook fire + injection verification (NOT latency).
- **Action**: Use identical prompts for model comparison. Include incumbent baseline. Pilot on ≥3 test cases.
- **failure_mode**: Naive default: compare models using different prompt phrasings or without including the production incumbent as a baseline. Why wrong: asymmetric prompts confound model differences with prompt differences — you cannot tell whether a quality delta comes from the model or the prompt. Without an incumbent baseline, you lack the third-way reference to calibrate whether either new model is actually better than what you already have.

### Source Import Quality: False Success Patterns - 2026-05-09
- **Discovery**: NotebookLM `status: ready` is NOT content quality signal. Three failure modes: SPA shell capture, login wall capture, WAF error capture. PDF is only reliably high-quality import path. Mandatory post-import quality verification needed.
- **Action**: Never trust `status: ready` alone. Default expectation for web pages: "will probably fail" — preprocessing is primary path.
- **failure_mode**: Naive default: import web pages directly into NotebookLM and trust `status: ready` as proof of successful content capture. Why wrong: three failure modes (SPA shell, login wall, WAF error) produce "ready" status with empty/garbage content — the default expectation for web pages should be "will probably fail," with PDF preprocessing as the primary path.

### Dynamic Research Protocol Design - 2026-05-09
- **Discovery**: (1) Saturation counters MUST have explicit update rules at every loop-back point — declare, update, embed in on-disk artifact. (2) Array-indexed conditions need `len(arr) >= N` guard before `arr[-N]` access. (3) Off-by-one in tunnel detection: `current_depth >= 3 AND len(arr) >= 2`, not just `depth >= 2`.
- **Action**: Explicit update rules at every loop-back point. Length guards for all array index access.
- **failure_mode**: Naive default: declare a saturation counter without specifying explicit update rules at every loop-back point, and use `arr[-N]` without checking `len(arr) >= N`. Why wrong: a saturation counter without update rules silently stalls (never increments to termination), and unguarded negative indexing causes runtime crashes or silent wrong-element access on short arrays.

### Cloud Compute Resource Awareness — Hardware Limitation ≠ Infeasibility — 2026-05-29
- **Context**: Colin voice project — user assumed voice training was impossible on 8GB Mac. Discovered free cloud GPU (Colab T4 12GB, Kaggle P100 16GB) could do it. Many stalled ideas (voice cloning, LLM fine-tune, custom assistant training) were blocked by the false assumption "local hardware = all available compute".
- **Discovery**: When an agent encounters "local hardware insufficient for task X" (model training, large-scale inference, fine-tuning), the default response should NOT be "this can't be done" but rather "this can't be done locally — here are cloud alternatives." Free and paid cloud GPU tiers exist for most ML workloads. This applies to any ML-adjacent task, not just voice production.
- **Action**: (1) In Socratic inquiry, when user mentions hardware limitations, always ask about cloud GPU awareness. (2) In capability packs involving training/fine-tuning, include cloud GPU as a hardware option alongside local. (3) Never treat "my machine can't run this" as a terminal condition — treat it as a resource allocation question.
- **Grounded in**: Colin声音项目 dogfood session (2026-05-29), ChatTTS hardware limitation discovery
- **failure_mode**: Naive default: when local hardware is insufficient for a task (model training, fine-tuning), conclude "this can't be done" and abandon the approach. Why wrong: free cloud GPU tiers (Colab T4 12GB, Kaggle P100 16GB) can handle most ML workloads — treating "my machine can't run this" as a terminal condition blocks viable ideas that are really just resource allocation questions.
