# LongHorizon-Harness — Raw Web and Source Research

Date: 2026-08-24

## Decision question

What is LongHorizon-Harness, how does it work, how strong is its evidence, and what does it imply for TAD's YOLO mode?

## Primary sources

- Repository: https://github.com/AMAP-ML/LongHorizon-Harness
- Paper: https://arxiv.org/abs/2608.01964
- Project site: https://lh-harness.pages.dev/
- Core manager loop: https://raw.githubusercontent.com/AMAP-ML/LongHorizon-Harness/main/src/lh_harness/manager.py
- Codex adapter: https://raw.githubusercontent.com/AMAP-ML/LongHorizon-Harness/main/src/lh_harness/adapters/codex.py
- Claude role policy: https://raw.githubusercontent.com/AMAP-ML/LongHorizon-Harness/main/src/lh_harness/adapters/claude_permissions.py
- Reproduction notes: https://raw.githubusercontent.com/AMAP-ML/LongHorizon-Harness/main/eval/WeaveBench-harness/WeaveBench/docs/REPRODUCE.md

## Verified project facts

1. The system reframes long-horizon execution as explicit task-state management. Its Manage–Execute–Audit loop assigns one bounded subtask, runs a fresh-context executor, and independently audits the resulting environment.
2. The manager persists task state and task contract outside executor context. Each round stores manager input/plan, task state, contract, executor output, auditor report, raw trajectories, and an event stream. Resume reconstructs planning context from the round ledger.
3. A manager completion claim is rejected unless the latest usable auditor report is `complete`, integrity is `clean`, and contract audit is `aligned`.
4. Human intervention is available at end-of-round boundaries for completion, blocking, requests for input, repeated failure, and round-budget exhaustion.
5. Current package metadata is version 0.1.7, Python >=3.10, MIT licensed.

## Reported results

- WeaveBench, 114 tasks, Qwen 3.7-Plus + Claude Code executor: PassRate 51.8% -> 80.7%; mean score 0.702 -> 0.835.
- OSWorld 2.0, 108 tasks, Qwen 3.7-Plus: binary completion 2.8% -> 8.3%; partial score 21.5% -> 35.2%. Average output tokens rise from 28.9K to 104K in this configuration.
- Terminal-Bench 2.1: 69.7% -> 77.2%, while the project reports 24% fewer tokens.
- Claude Opus 4.7 OSWorld subset, 34 tasks: binary 20.6% -> 35.3%; partial 55.8% -> 66.9%.
- Manager share of tokens is reported as 2.8%, 2.0%, and 8.1% across the three benchmarks. Auditing is the larger cost center: 19.4%, 24.8%, and 38.1%.

## Source-audit findings and limitations

1. The core source is materially more robust than a prompt-only wrapper: it has durable crash records, event-ledger resume, bounded rounds, completion rejection, role budgets, human gates, no-follow filesystem handling, and explicit invalid-state paths.
2. The state ledger is still natural-language state maintained by the manager. Per-fact provenance is encouraged by prompts and auditor reports, but not represented as a typed immutable fact table.
3. Claude Code receives role-specific deny lists and auditor workspace snapshots. The Codex adapter has no role parameter, defaults every role to `--dangerously-bypass-approvals-and-sandbox`, and the CLI source explicitly notes that Codex has no auditor snapshot guard. Therefore read-only auditor enforcement is not backend-equivalent.
4. WeaveBench uses a separate host-side OpenClaw judge and trajectory-aware evidence. The pinned judge is Claude Opus 4.7. This is cross-family for the main Qwen results, but same-family/self-judge risk exists for Opus 4.7 rows; no human-calibration evidence was located.
5. The project is an early v0.1.x release. README says the CLI default is 30 rounds while source defines 25. Reproduction notes say v0.1 lacks a canonical result aggregator. These are maturity/drift signals, not proof that the core idea is wrong.
6. The local source snapshot contains 303 Python test functions. Tests were not executed because pytest is absent in the research environment; no dependency installation was performed.

## TAD comparison

TAD YOLO already has file-as-source-of-truth, separate design/implementation review, circuit breakers, evidence files, Conductor gate judgment, phase checkpoints, and honest-partial exits. The main gap is granularity: TAD's durable boundary is mostly the Epic phase, while the entire Y5 implementation can remain one long executor context. LongHorizon-Harness moves the durable audited boundary inside the phase, after every bounded subtask.

## Cross-harness capability check (2026-08-24)

Primary sources:

- OpenCode CLI: https://opencode.ai/docs/cli/
- OpenCode agents and permissions: https://opencode.ai/docs/agents/
- OpenCode V2 compaction: https://opencode.ai/v2/docs/compaction
- OpenCode V2 permissions: https://opencode.ai/v2/docs/permissions
- Local TAD runtime ledgers: `.tad/runtime-compat/claude-code.md`, `.tad/runtime-compat/codex.md`

Findings:

1. TAD currently treats Claude Code and Codex as first-class installer targets. OpenCode is not present in `.tad/platform-codes.yaml`, so the Epic must not imply existing first-class support.
2. OpenCode exposes custom primary/subagents, fresh child sessions, permission rules, session resume, headless execution, and automatic compaction. These are sufficient to build an adapter, but its V1 and V2 permission/config vocabularies differ; a version-probed capability manifest is required instead of a static universal config.
3. OpenCode V2 explicitly describes compaction as lossy while retaining durable earlier session messages. This reinforces the architectural boundary: session history may help diagnosis, but verified YOLO progress must live in the framework-owned ledger.
4. Claude Code currently has the richest TAD-native workflow and worktree-isolation path. Codex has shared skills/subagents but partial hook/compaction verification. OpenCode has promising primitives but no TAD compatibility ledger or regression evidence yet.
5. Therefore the portable kernel must define semantics independently of all three runtimes. An adapter may claim `full` only after probing required capabilities; otherwise it must select a named degraded mode or block autonomous execution. Merely accepting the same prompt is not parity.
