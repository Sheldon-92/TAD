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

### Doc-Level Native-Capability Research Is Hypothesis, Not Fact — One Epic Falsified 3 of Its Own Research Claims via Local Spikes - 2026-07-13
- **Context**: EPIC-20260712-native-capability-adoption adopted 6 Claude Code native capabilities identified by a 23-source deep-research pass (notebook b07a6598). The research matrix carried an explicit caveat (no adversarial challenge — Codex/Gemini both unavailable). Every phase was designed spike-first with degradation matrices.
- **Discovery**: Local spikes falsified 3 doc-level claims and confirmed 3 others, all on the same CLI build (2.1.172): FALSIFIED — subagent `memory` frontmatter (INERT), subagent `skills` preload (INERT), CronCreate `durable:true` persistence (session-only + 7-day expiry regardless). CONFIRMED — project-level `.claude/agents/` shadowing (full replace), `.claude/rules` paths-frontmatter loading (works; even the opposite GitHub issue claim #17204 "only globs: works" did not reproduce), PreCompact hook registration. Net: for platform-capability adoption, documentation and community reports BOTH mis-predict local behavior in either direction; the spike is the only ground truth, and a NEGATIVE spike with a pre-designed degradation matrix still ships value (spec-compliance-reviewer, fm-lint.sh landed from the "failed" phase).
- **Action**: (1) Treat every native-capability research finding as a hypothesis carrying a version pin; the first micro-task of any adoption phase is a local spike whose FAIL branch is pre-designed (degradation matrix), never a blocker. (2) Record verdicts as VERDICT-<topic>: PASS/FAIL lines with raw transcripts so reviewers can re-adjudicate. (3) When a spike contradicts research (or a GitHub issue), write the falsification back to the research evidence AND the decision record — the version-pinned correction is itself the reusable asset (re-spike triggers on CLI upgrade).
- **failure_mode**: Naive default: design integrations directly on top of documented/community-reported platform capabilities because the research phase was thorough. Why wrong: 3 of 6 capabilities behaved differently on the actual installed CLI than every doc-level source suggested — integrations built without spikes would have shipped inert config (validation theater) or silently-dying automation.
- **Grounded in**: .tad/evidence/spikes/subagent-frontmatter-2026-07/spike-report.md, .tad/evidence/spikes/cron-github-scan-2026-07/spike-evidence.md (incl CRON-FIRE-VERIFY), .tad/evidence/yolo/native-capability-adoption/phase4-rules-spike.md (GH #17204 adjudication), EPIC-COMPLETION.md "Native-Runtime Ground Truth"

### A Native-Capability Verdict Without a Spawn-Path Dimension Is Underspecified — Same CLI, Same Field, Opposite Results by Path - 2026-07-13

- **Context**: skills-preload delivery (FR5). The `skills:` subagent-frontmatter field on the
  SAME Claude Code 2.1.207 produced: 6/6 FAIL via headless `claude -p --agent` spawns, then a
  clean PASS via interactive-harness Agent-tool spawn (discriminative pair with a no-`skills:`
  negative-control agent — the pack arrives as a command block at spawn, attributable to the
  frontmatter key as the only variable). One version, one field, opposite verdicts by spawn path.
- **Discovery**: (1) "Does capability X work on version V" is an incomplete question — the
  execution PATH (interactive harness / headless CLI / nested wrapper) is an independent axis,
  and the path a spike happens to use may not be the path production uses. TAD's production
  path for reviewers is the Agent tool; the earlier all-FAIL evidence was gathered exclusively
  on a path TAD doesn't ship on, and nearly closed a capability that works. (2) Preload-probe
  design has two mandatory guards, both learned the hard way the same day: (a) ban the `Skill`
  tool (and ToolSearch equivalents) — an agent that can load-on-demand and quote is
  indistinguishable from preload (the morning false-PASS mechanism); (b) verify ban efficacy
  IN-BAND before trusting a quote-based verdict — `--disallowedTools` is variadic on 2.1.207
  and a comma-joined single arg mis-parses (swallows the trailing prompt as deny rules); the
  working form is space-separated names + prompt via stdin. (3) The airtight closer is a
  same-session discriminative pair: identical spawn path and probe, the tested key as the only
  variable, negative control MUST come back clean.
- **Action**: Every native-capability verdict must be pinned to (version, spawn path) — never
  version alone; test on the path production actually uses before declaring FAIL/PASS. For any
  preload/context probe: ban Skill+ToolSearch, prove the ban held in-band, and close with a
  key-present vs key-absent pair on the production path.
- **failure_mode**: Naive default: spike a capability on whatever spawn path is scriptable
  (headless CLI), pin the verdict to the CLI version, and ship the conclusion. Why wrong: path
  behavior diverges — today that default produced 6/6 FAIL evidence on the non-production path
  for a capability that works on the production one; the reverse error (headless-only PASS,
  harness FAIL) would ship a dead config key with a false claim.
- **Grounded in**: .tad/evidence/spikes/subagent-frontmatter-2026-07/spike-report.md (ADDENDUM
  #2+#3), fr5-delivery-evidence.md (AC1b discriminative pair), COMPLETION-20260713-skills-preload-delivery.md
