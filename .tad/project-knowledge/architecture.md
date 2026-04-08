# Architecture Knowledge

Project-specific architecture learnings accumulated through TAD workflow.

---

## Foundational: TAD Framework Architecture

> Established at project inception.

### Two-Agent System
- **Alex (Solution Lead)**: Design, planning, requirements, business acceptance
- **Blake (Execution Master)**: Implementation, testing, technical quality

### Four-Gate Quality System
- Gate 1: Requirements Clarity
- Gate 2: Design Completeness
- Gate 3: Implementation Quality (v2.0: expanded)
- Gate 4: Integration/Acceptance (v2.0: simplified)

---

## Accumulated Learnings

<!-- Entries from development experience below -->

### Ralph Loop Two-Layer Architecture - 2026-01-26
- **Context**: Implementing TAD v2.0 Blake + Ralph Loop Fusion
- **Discovery**: The two-layer quality architecture (Layer 1: fast self-check, Layer 2: expert review) is a reusable pattern for iterative quality assurance. Key principles:
  1. **Separation of Concerns**: Cheap/fast checks (build, lint) separate from expensive/slow checks (expert review)
  2. **Expert Exit Conditions**: Quality is judged by specialized agents, not self-assessment
  3. **Circuit Breaker Pattern**: Detect stuck states (3 same errors) and escalate automatically
  4. **State Persistence**: Enable crash recovery without losing progress
  5. **Priority Groups**: Sequential blocking gate (code-reviewer) before parallel verification
- **Action**: This pattern can be applied to other iterative workflows where quality needs external validation

### Gate Responsibility Matrix - 2026-01-26
- **Context**: Restructuring Gate 3 and Gate 4 for v2.0
- **Discovery**: Clear separation of technical vs business responsibilities improves gate efficiency:
  - Technical experts (code-reviewer, test-runner, security, performance) → Blake's Gate 3 v2
  - Business acceptance (requirement verification, user approval) → Alex's Gate 4 v2
- **Action**: When designing quality gates, separate technical automation from business judgment

### Cognitive Firewall: Embed Into Existing Flows, Don't Create New Ones - 2026-02-06
- **Context**: Designing a 3-pillar human empowerment system (decision transparency, research-first, fatal operation protection)
- **Discovery**: Cross-cutting concerns (like "human must approve tech decisions") are most effective when embedded into existing mandatory flows (Gates, Alex design phase, Blake execution) rather than creating standalone commands or modules. Key pattern:
  1. **Insert, don't create**: New protocol inserted between Socratic Inquiry and Design — guaranteed to run
  2. **Gate enforcement**: Risk Translation in Gate 3 makes protection mandatory, not optional
  3. **Escalation over automation**: Blake PAUSE (not auto-proceed) respects terminal isolation principle
  4. **Handoff-awareness**: Risk checks must understand intent to avoid blocking legitimate operations
- **Action**: When adding cross-cutting quality/safety concerns, embed them as mandatory steps in existing flows rather than creating separate commands that can be forgotten

### Standalone Agent Command Pattern - 2026-02-08
- **Context**: Redesigning Design Playground from embedded Alex sub-phase to independent `/playground` command
- **Discovery**: When a workflow grows beyond ~100 lines and has distinct skills/concerns from its host agent, extract it to a standalone command. Key pattern:
  1. **Independence**: Standalone command with own persona, activation protocol, and workflow — not tied to Alex or Blake
  2. **Output-only Integration**: Connects to the main system through output files (DESIGN-SPEC.md), not direct invocation
  3. **Terminal Isolation Preserved**: Standalone commands must respect the same isolation rules (no cross-calling /alex or /blake)
  4. **Session Recovery**: Standalone commands need their own state persistence since they run outside the main TAD flow
- **Action**: When a sub-phase of Alex/Blake develops its own complex workflow (>100 lines, distinct skill profile), extract to standalone command with clear input/output contracts

### Style Library Architecture - 2026-02-08
- **Context**: Building a comprehensive design reference library for Playground v2
- **Discovery**: Effective style/theme libraries require both aesthetic description AND usage guidance:
  1. **Visual Spec**: colors (with hex), typography (with font names), layout approach, component patterns
  2. **Usage Guidance**: `best_for` AND `avoid_for` tags — knowing when NOT to use a style is as important as knowing when to use it
  3. **Category Indexing**: Two-tier discovery (Category → Style) prevents cognitive overload with 30+ options
  4. **Schema Enforcement**: Required vs optional fields with build-time validation prevents incomplete entries
- **Action**: When building reference libraries, include both positive and negative usage guidance, enforce schema at build time

### Manifest + Directory Isolation for Multi-Instance Resources - 2026-02-09
- **Context**: Upgrading pair testing from singleton (one TEST_BRIEF.md) to multi-session support
- **Discovery**: When a system resource designed as singleton needs multi-instance support, the pattern is:
  1. **Directory Isolation**: Each instance gets its own subdirectory (S01/, S02/) — eliminates naming conflicts
  2. **Manifest Index**: A YAML/JSON manifest (SESSIONS.yaml) tracks all instances with metadata — single source of truth for system state
  3. **Manifest Recovery**: Directories are the ground truth, manifest can be rebuilt from scanning directories — don't trust manifest alone
  4. **Linear Inheritance**: For iterative workflows, single-parent context chain (inherits_from: S01) is sufficient — fan-out is a different paradigm
  5. **Atomic Archive**: Use `mv` (atomic rename) over copy-then-delete for same-filesystem moves — prevents partial state
  6. **Active Guard**: Enforce max_active constraint at creation time, not just in documentation
- **Action**: When converting singleton resources to multi-instance, use directory isolation + manifest index. Always make directories the source of truth over manifest metadata.

### Intent Router: Route Before Process - 2026-02-16
- **Context**: Adding multi-mode support to Alex (bug/discuss/idea/analyze) without modifying existing workflow
- **Discovery**: When an agent needs to support multiple interaction modes, insert a routing layer BEFORE the existing protocol rather than modifying it. Key pattern:
  1. **Route before process**: Intent Router runs first, dispatches to the correct path. Existing *analyze flow is completely untouched
  2. **Always confirm**: Even with signal word detection, always use AskUserQuestion to confirm intent — auto-detection is a hint, not a decision
  3. **Path isolation with escape hatches**: Each path has its own lifecycle, but defined transitions allow upgrading (discuss→analyze) while preventing downgrading (analyze→any)
  4. **Principle preservation**: New paths must respect ALL existing constraints (Alex never codes, terminal isolation) — don't create exemptions for convenience
- **Action**: When adding multi-mode support to an agent, create a router that dispatches to isolated paths rather than adding conditional branches inside existing workflows

### Mode Addition Checklist Pattern - 2026-02-16
- **Context**: Adding *learn as 5th Intent Router mode (Phase 2 of Alex Flexibility Epic)
- **Discovery**: Adding a new mode to a multi-mode router requires a 5-layer integration pattern to achieve zero regression:
  1. **Config layer**: Add mode entry with signal words + priority in config-workflow.yaml
  2. **Protocol layer**: Add path protocol (behavior + execution steps) in agent file
  3. **Router layer**: Update step1 (explicit command), step3 (display logic with 4-option limit), step4 (routing table)
  4. **Lifecycle layer**: Add standby integration (enter conditions, path transitions, idle detection coexistence)
  5. **Surface layer**: Update commands section, on_start greeting, Quick Reference, CLAUDE.md routing table
  Missing any layer creates a partial integration that may silently fail (e.g., mode exists in config but router doesn't recognize explicit command).
- **Action**: Use this 5-layer checklist when adding future modes to Intent Router or similar multi-mode systems

### Lightweight Storage Upgrade Pattern - 2026-02-16
- **Context**: Upgrading *idea storage from NEXT.md one-liners to individual structured files in .tad/active/ideas/
- **Discovery**: When upgrading from "append to shared file" to "individual structured files", follow this pattern:
  1. **Template-first**: Create the template before changing the storage target — template defines the contract
  2. **Cross-reference, don't migrate**: Keep a one-liner in the original location (NEXT.md) as cross-reference — avoids breaking existing workflows that scan the shared file
  3. **Forward-only lifecycle**: Status fields with forward-only transitions (captured → evaluated → promoted → archived) prevent accidental state regression without complex validation
  4. **Section-aware append**: When creating cross-references in shared files, define explicit section placement rules (after ## Pending, before ## Blocked) to avoid disrupting document structure
- **Action**: When upgrading storage from shared-file to individual-file pattern, always maintain cross-references in the original location and define template contracts first

### Aggregation Layer: Coexist Don't Replace - 2026-02-16
- **Context**: Adding ROADMAP.md as a strategic view above PROJECT_CONTEXT.md, NEXT.md, and Epic files
- **Discovery**: When a project needs a higher-level view across existing documents, create an aggregation layer that references existing files rather than replacing or duplicating them:
  1. **Distinct scopes**: Each document owns a specific scope (ROADMAP=strategic themes, PROJECT_CONTEXT=current state, NEXT=tactical tasks, Epics=multi-phase tracking)
  2. **Reference, don't copy**: Use links/cross-references to source documents; never duplicate operational details
  3. **Suggest, don't auto-sync**: Human-confirmed updates (via *discuss exit) are safer than auto-sync which risks stale or incorrect aggregation
  4. **Non-blocking load**: Read aggregation files at startup for context, but never block on them — partial context is better than a blocked workflow
- **Action**: When adding overview/dashboard layers, define clear scope boundaries, reference existing documents by link, and keep updates human-initiated

### Lifecycle Chain Closure: Promote as Status Change + Handoff - 2026-02-16
- **Context**: Adding *idea promote to close the Idea → Epic → Handoff lifecycle, and *status as a panoramic read-only view
- **Discovery**: When creating a "promote" or "upgrade" command that bridges two lifecycle stages:
  1. **Status change, then redirect**: Promote is two operations — update the source artifact's status, then enter the target workflow. Don't try to create the target artifact directly.
  2. **Context via conversation, not files**: When transitioning between protocols (promote → analyze), pass context through conversation memory rather than intermediate persistence files. Simpler and sufficient for same-session transitions.
  3. **Read-only commands need no interaction**: Dashboard/status commands should display and return to standby — no AskUserQuestion, no follow-up. Users invoke specific commands when they want to act.
  4. **Standby exclusion for redirect steps**: When a protocol step transitions to another protocol (step4 → *analyze), that step must NOT appear in enters_standby — it's a redirect, not an exit.
- **Action**: When building lifecycle bridges, separate the status update from the target workflow entry. Use conversation memory for context transfer within the same session.

### Feature Deprecation Cleanup Pattern - 2026-02-17
- **Context**: Removing full TAD runtime support for Codex/Gemini (~1100 lines across 20 files)
- **Discovery**: When removing a cross-cutting feature from a mature codebase, two key patterns emerged:
  1. **Function-name targeting over line numbers**: Shell scripts change frequently. Expert review caught that line-number-based removal instructions are risky — always reference function names (e.g., "delete `generate_codex_config()`") for surgical script cleanup
  2. **Dual-purpose file detection**: config-platform.yaml contained BOTH the feature being removed (multi_platform, 55 lines) and an orthogonal feature (MCP tools, 233 lines). In-place cleanup (keep file, remove section) is safer than file splitting/renaming when the file is referenced in module binding chains
  3. **Grep-driven completeness**: Expert review found 4 files the handoff missed by running broader grep patterns. Acceptance criteria MUST include automated grep verification, not manual file listing
  4. **Backup files are expected exceptions**: grep hits in `.tad/config-backup.yaml` or `.tad/config-full-backup.yaml` are NOT dangling references — backup files preserve historical state by design
- **Action**: For multi-file feature removal: (a) use function names not line numbers for scripts, (b) grep broadly for references before declaring the file list complete, (c) include automated grep verification in AC

### Minimal Viable Cross-Cutting Enhancement - 2026-02-19
- **Context**: Adding Context Refresh Protocol to prevent long-session knowledge compression loss
- **Discovery**: When adding a cross-cutting concern to multiple workflow nodes, start with the 2 most critical points rather than all possible points (started with 9, trimmed to 2+1):
  1. **Producer-Consumer targeting**: Cover the information "write point" (Alex writing handoff) and "consume point" (Blake starting implementation) — these are where missing knowledge causes the most damage
  2. **Over-engineering resistance**: Initial expert review expanded scope to 9 nodes; user correctly pushed back to minimal viable version. More nodes can be added later based on real need
  3. **YAML structure awareness**: Protocol files mix flat (`step1: "string"`) and nested (`step1: { name, action }`) YAML formats. New insertions must match surrounding context exactly
- **Action**: When enhancing workflows with cross-cutting features, identify the 2 most impactful nodes (producer + consumer) and implement there first. Expand only based on observed need, not theoretical completeness

### Measure Before Optimizing: Context Loading Spike - 2026-03-23
- **Context**: Superpowers-inspired Epic assumed TAD's context footprint needed optimization (session hook for lazy loading). Spike measured actual baseline.
- **Discovery**: TAD's architecture is ALREADY well-optimized for on-demand loading. Three key findings:
  1. **Session start overhead is small (~8.5%)**: Only CLAUDE.md (~1,445 tokens) + resolved @imports (~3,617 tokens) load at start. Agent files + config modules already load on-demand via Skill tool.
  2. **@import zero-cost for non-existent files**: 8 of 9 @import directives point to non-existent files and are silently skipped (zero tokens). This is effectively lazy loading.
  3. **Hooks supplement, don't replace**: Claude Code hooks (shell command type) can inject context but cannot prevent CLAUDE.md from loading. They add to context, not reduce it.
  4. **Spike-driven pivot works**: AC11 (threshold trigger) caught the small target early, enabling data-driven pivot instead of building unnecessary infrastructure.
- **Action**: Always measure actual baseline before designing optimization systems. Include explicit pivot thresholds (like AC11's 10% rule) in spike acceptance criteria to enable early course correction.

### Long Context Enables In-Session Decision Making (4D Protocol) - 2026-03-25
- **Context**: Upgrading pair testing protocol based on menu-snap S04 experience (4 sessions, 11 rounds)
- **Discovery**: 1M context window fundamentally changes pair testing methodology. With full context preserved across 10+ rounds, "find bugs now → fix later" becomes "discover → discuss → decide → record" in a single session. Key pattern:
  1. **Context richness at discovery**: Solutions decided at the moment of finding have the richest context (screenshot just viewed, code just analyzed, human reaction immediate)
  2. **No information loss**: Round 10 still has Round 1's full details — no need to defer decisions to a separate review session
  3. **Reports become action logs**: Output is "Findings + Solutions Decided" per round, not a bug list waiting for triage
  4. **Tool capability shapes methodology**: The 4D Protocol exists because 1M context makes it possible — it wouldn't work with 8K/32K context
- **Action**: When designing protocols that span long sessions, assume full context retention and design for in-session decision-making rather than deferred review. The "save context to document → review later" pattern is a workaround for limited context, not a best practice.

### Claude Code Native Mechanism Validation — Hooks > Skill Frontmatter - 2026-03-31
- **Context**: TAD v3.0 rebuild spike — tested 7 Claude Code mechanisms from leaked source code analysis
- **Discovery**: Claude Code's enforcement capabilities are asymmetric:
  1. **Hooks are production-ready and powerful**: PostToolUse/PreToolUse command hooks, prompt hooks (Haiku gating), SessionStart hooks, `if` condition filtering ALL work as documented. additionalContext injects as `<system-reminder>` (system-level authority).
  2. **Skill frontmatter is limited**: `allowed-tools` field is NOT enforced (neither fork nor inline mode). Per-skill `hooks` frontmatter is NOT implemented (v2.1.88). Skills are good for prompt injection and model override, but NOT for tool restriction or hook registration.
  3. **Hook event keys are PascalCase**: `PostToolUse`, `PreToolUse`, `SessionStart` — not kebab-case.
  4. **Parallel Agent spawning works**: Multiple Agent tool calls in one message execute truly concurrently with per-agent model override.
  5. **Design implication**: TAD v3.0 must use `settings.json` global hooks as primary enforcement layer. Tool restriction via PreToolUse prompt hooks (not allowed-tools). Context-specific behavior via `matcher` + `if` patterns (not per-skill hooks).
- **Action**: When designing framework extensions on Claude Code, validate mechanisms via spike before designing architecture. Source code reading ≠ runtime behavior. Hooks are the reliable enforcement primitive; skill frontmatter is for prompt delivery and model selection only.

### Judgment-Only Skill Files: 76% Reduction Was NOT Safe — AMENDED 2026-04-04
- **Amendment**: The original "76% reduction is safe" conclusion was proven WRONG by Quality Chain failure.
  - v2.7 slim skills (570/283 lines) removed constraint rules alongside mechanical logic
  - v2.8 Quality Chain Phases 2-3 restored constraints to COMMAND files, but never synced back to skills
  - Result: commands and skills diverged for weeks, slim skills were missing critical guardrails
  - **Corrected action**: Constraint rules (MUST/MANDATORY/VIOLATION) are NOT mechanical — they cannot be removed. Only truly mechanical logic (file I/O, config duplication) is safe to extract.
  - **Resolution (v2.8.1)**: Commands consolidated into skills. Single source of truth restored.

### [ORIGINAL — superseded by amendment above] Judgment-Only Skill Files: 76% Reduction is Safe - 2026-03-31
- **Context**: TAD v3.0 Phase 3 — slimming Alex (2528→570) and Blake (1052→283) skill files
- **Discovery**: When hooks handle automation and config YAML holds definitions, skill files can be reduced to judgment-only residual with no functionality loss:
  1. **78% of Alex was non-judgment**: mechanical file operations, config duplication, verbose format specs
  2. **The judgment core is compact**: Intent Router (50 lines), Socratic Inquiry (63 lines), Adaptive Complexity (40 lines) — core protocols total ~300 lines
  3. **One-liner replacements work**: Protocols like *status (56→5 lines) can be reduced to a single instruction line when the model has config files to reference
  4. **Forbidden actions list is small but critical**: 10 lines of unique guardrails that exist nowhere else — never remove
- **Action**: When skill files grow large, audit for judgment vs mechanical. Mechanical logic should be in hooks/scripts, config in YAML, leaving skills as pure reasoning guides.

### Domain Pack Step Model: Type A/B/Mixed - 2026-04-02
- **Context**: Building web-testing Domain Pack with 7 capabilities across 3 types
- **Discovery**: Domain Pack capabilities need different step structures based on their nature:
  1. **Type A (Document/Research)**: search→analyze→derive→generate. For capabilities producing analysis/reports. Prevents "search-then-paste" shallow output.
  2. **Type B (Code/Tool)**: select→execute→verify→optimize. For capabilities producing runnable code/config. Prevents "wrong framework choice" and "code doesn't compile."
  3. **Type Mixed (Human-AI)**: Cannot be fully automated. pair_testing with 4D Protocol (Discover→Discuss→Decide→Deliver) forces in-session decision-making rather than deferred triage. Value = human intuition + AI analysis, decided together.
  4. **Each capability judged independently** — same pack can mix all three types. web-testing has 5 code, 1 mixed, 1 document.
- **Action**: When designing Domain Pack capabilities, first classify each as A/B/Mixed, then apply the corresponding step model. Don't force all capabilities into the same structure.

### Domain Pack Must Declare Tool Availability Boundaries - 2026-04-02
- **Context**: Building mobile-testing domain pack; expert review flagged Android coverage missing
- **Discovery**: Mobile testing CLI tools have severe availability gaps vs web: VoiceOver has no CLI audit tool (ecosystem blank), Android emulator needs full SDK (35GB+), xcrun simctl needs Xcode absolute path (CLT insufficient). A domain pack named "mobile-testing" but only covering iOS creates false expectations.
- **Action**: Domain Pack description must declare platform/tool scope explicitly (e.g., "iOS/RN-first, Android deferred to v1.1"). Don't name a pack broadly if tool availability only covers one platform. Include scope comments at YAML top level.

### Hook Path Matching: Glob Prefix Must Handle Relative Paths - 2026-04-02
- **Context**: post-write-sync.sh case patterns used `*/.tad/` which requires a character + `/` before `.tad`. Claude Code passes file_path as relative (`.tad/active/...`) not absolute (`/path/.tad/...`).
- **Discovery**: `*/.tad/` does NOT match `.tad/` (no character before the slash). Must use `*.tad/` (any prefix including empty) to handle both absolute and relative paths. Similarly, `*NEXT.md` is too broad (matches WHATSNEXT.md) — use `*/NEXT.md|NEXT.md` for exact matching.
- **Action**: All hook case patterns must use `*.tad/` not `*/.tad/`. Test with both relative and absolute paths. For exact filename matches, use `*/name|name` pattern.

### Claude Code Enforcement Priority Order — permissions.deny > hooks > allow - 2026-03-31
- **Context**: Supplementary spike (Exp 3c) testing tool restriction mechanisms
- **Discovery**: Claude Code's enforcement is layered with strict priority:
  1. `permissions.deny` removes tools ENTIRELY before hooks even see them. Hooks CANNOT override deny.
  2. `permissions.deny` only works at tool-name level (e.g., `"Write"`), NOT path patterns (e.g., `"Write(*.ts)"` doesn't work).
  3. `bypassPermissions` mode overrides EVERYTHING including deny — TAD v3.0 must NOT use bypass mode.
  4. **Best pattern for context-aware restriction**: Don't deny tools that sometimes need to be used. Instead, use PreToolUse prompt hooks (Haiku) for intelligent path/context gating. Reserve deny only for tools that should NEVER be available.
- **Action**: For TAD v3.0, use two-layer enforcement: `permissions.deny` for hard tool removal (Bash rm patterns if needed), PreToolUse prompt hooks for everything else. Never deny a tool that a hook needs to conditionally allow.

### Domain Pack Research: Workflow Steps > Quality Criteria Text - 2026-04-03
- **Context**: HW Domain Pack Phase 1 research supplement — two rounds of YAML iteration
- **Discovery**: When improving Domain Pack quality via research, **new workflow steps** (adding a step to the capability pipeline) deliver far more value than **quality_criteria text additions** (adding a line to the checklist). First round added ~20 quality_criteria lines — Blake self-assessed as insufficient. Second round added 4 new steps (scan_anti_patterns, verify_static_analysis, validate_manifold, declare_measurement_specs) + 2 tool integrations — this changed how the pack actually operates.
  1. **Steps change behavior**: A new step in the pipeline is mandatory — it runs every time. A quality_criteria line is advisory — it can be skimmed or ignored.
  2. **Tool integration amplifies steps**: Steps referencing tool_ref (platformio_cli, admesh) create verifiable checkpoints. Text-only criteria rely on LLM judgment.
  3. **Research ROI hierarchy**: new step with tool_ref > new step without tool > new anti_pattern > new quality_criteria text
- **Action**: When designing Domain Pack research tasks, explicitly require "at least 1 new step per pack" as an AC. Text-only quality_criteria additions should be a secondary output, not the primary deliverable.

### Hook Shell Portability: No grep -P on macOS - 2026-04-03
- **Context**: Quality Chain Phase 4 — code-reviewer caught `grep -oP` (Perl regex) in pre-gate-check.sh
- **Discovery**: macOS ships BSD grep which does NOT support `-P` (Perl regex). `grep -oP '(?<=pattern).*'` silently fails or errors on stock macOS. The portable alternative is `grep -o 'full_pattern' | sed 's/prefix//'`. This is critical for hook scripts that must run on any developer machine.
- **Action**: Never use `grep -P` in hook scripts. Use `grep -o` + `sed` for lookbehind-like extractions. Add this to hook code review checklist.

### UserPromptSubmit Hook Verified — 4th Validated Hook Event - 2026-04-07
- **Context**: Epic 1 Phase 1 spike (SPIKE-20260407-domain-pack-hook) validated whether Claude Code's `UserPromptSubmit` hook event exists and can deliver `additionalContext` to the main conversation. This event was NOT in the verified list from 2026-03-31.
- **Discovery**: `UserPromptSubmit` IS supported in Claude Code 2.1.92. Settings.json accepts the event without error, hook fires reliably on every user prompt submission, and `hookSpecificOutput.UserPromptSubmit.additionalContext` is delivered into the model context (proven by 3/3 child sessions returning MARKER_SEEN to a marker injection). **Validated hook event list grows to 4: SessionStart, PreToolUse, PostToolUse, UserPromptSubmit.**
  - Hook stdin payload contains `session_id`, `transcript_path` keys (same envelope as PreToolUse/SessionStart, consumable by `lib/common.sh::read_stdin_json`)
  - additionalContext output format identical to SessionStart (`output_response()` works)
  - Hook command can be inline bash OR a separate script (spike used `bash '/abs/path/spike-hook.sh'` cleanly)
  - **CAVEAT — Latency measured via `claude -p` proxy is misleading**: `claude -p` adds ~3-4s overhead from process spawn + 19k cache_creation tokens + extended thinking. A 4567ms proxy measurement does NOT mean Haiku takes 4.5s. Direct API curl with `max_tokens` cap is required for true latency.
  - **CAVEAT — Haiku-4.5 ALWAYS wraps JSON in ```json fences** despite explicit "no fences" instruction. Production hooks calling Haiku for JSON output MUST include a fence-stripper, or use stop_sequences `["\n```","```"]`.
- **SUB-FINDING — `type: prompt` vs `type: command` contract divergence on UserPromptSubmit** (added 2026-04-07 from Phase 2a spike, SPIKE-20260407-phase2a-prompt-contract):
  - **`type: command` hook on UserPromptSubmit** supports `hookSpecificOutput.additionalContext` for context injection (Phase 1 proven, 3/3 MARKER_SEEN).
  - **`type: prompt` hook on UserPromptSubmit** is a **permission gate only** — semantically identical to PreToolUse `type: prompt`. Claude Code parses the Haiku response as `{ok:bool, reason?:str}` and honors `{ok:false}` to block the user message entirely (model round-trip skipped, `result=''`). Any other response shape (including explicit `hookSpecificOutput` envelope, auto-find for `additionalContext`/`reason` fields) is **discarded**. Context injection is NOT supported on this hook type.
  - **System-layer stdin payload for command hooks** (from Phase 2a Probe 1b `cat >>` sentinel dump): JSON envelope with **6 fields** — `session_id`, `transcript_path`, `cwd`, `permission_mode`, `hook_event_name`, **`prompt`** (the user's actual message, may have trailing `\n`). Read via `jq -r '.prompt'` in bash, matches existing `lib/common.sh::read_stdin_json` pattern. **NOT `$ARGUMENTS`**.
- **Action**: Production hooks using UserPromptSubmit follow the same pattern as PreToolUse prompt hooks. When measuring Haiku latency, always use direct API not `claude -p`. When parsing Haiku JSON, always strip markdown fences post-hoc. **For context injection on UserPromptSubmit, use `type: command` ONLY** — `type: prompt` will fire and run Haiku but the response will be discarded unless it matches the `{ok:bool}` gate shape. Reserve `type: prompt` for intent gating (blocking disallowed prompts), not for delivering hints to the main conversation.

### Hook Performance: Single-awk vs Per-item grep Loop - 2026-04-07
- **Context**: Epic 1 Phase 2b built a production `type: command` UserPromptSubmit hook that scores 20 Domain Packs × ~12 keywords each against a user message. First draft used a bash inner loop `while read kw; do printf '%s' "$msg" | grep -qiF "$kw"; done` across all packs. Measured 600-740ms per invocation — 6-7x over the 200ms AC budget.
- **Discovery**: The bottleneck was fork/exec overhead, not regex cost. 20 packs × ~12 keywords = 240+ grep process starts per hook call, each ~1-2ms on macOS → ~400ms just in process creation. Replaced with a SINGLE `awk` process that reads all packs as a TSV dump (via one `yq -o=json` + one `jq -r @tsv`) and does `tolower()` + `index()` substring matching per-pack in a single pass. Latency dropped to 84ms median (7-9x faster).
- **Key awk pattern**:
  1. Dump YAML to JSON via `yq` (single invocation); dump all packs as TSV via `jq @tsv` (single invocation). Keywords within a pack are joined by `\x01`.
  2. Pass the user message to awk via `ENVIRON["VAR"]`, NOT `awk -v var=$msg`. `-v` interprets backslash escapes in user content (`\n`, `\t`, `\\`) which is a data-integrity risk.
  3. The env-var assignment must be on the AWK command, not a preceding pipeline stage: `cmd1 | VAR="$X" awk '...'`, NOT `VAR="$X" cmd1 | awk '...'`. Pipeline variable assignments apply only to the immediate command. This bug silently collapses scoring to "no match" on every invocation if violated — document inline as a load-bearing comment.
  4. `index(tolower(msg), tolower(kw))` is byte-wise under BSD awk, which is correct for UTF-8 because UTF-8 is self-synchronizing. Chinese keywords match reliably.
- **Action**: For any TAD hook that does per-item classification over N items (packs, rules, patterns), use a single awk process not a bash grep loop. Budget: ~5-10ms per 20 items. Test both at the designed input scale and with a latency microbench, because fork overhead is invisible in functional tests.

### `claude -p` is a Valid UserPromptSubmit Hook Testing Channel - 2026-04-07
- **Context**: Phase 2a handoff P0-5 strictly mandated "new interactive terminal + `claude` interactive mode, NEVER `claude -p`" for hook testing, citing "non-interactive hook semantics may differ". Blake used `claude -p --no-session-persistence --tools ''` anyway due to environmental constraints (non-interactive Blake cannot open a new terminal). Phase 2a's verdict was PARTIAL on this AC with documented deviation. Phase 2b then built production code + tested it the same way.
- **Discovery**: Empirically verified across 3 spikes + 1 production deployment that `claude -p` DOES fire `type: command` UserPromptSubmit hooks identically to interactive mode: (a) sentinel files are written, (b) `hookSpecificOutput.additionalContext` is delivered to the main session model (proven via MARKER_SEEN / INJECTION_SEEN probes), (c) `{ok:false}` blocks messages identically (Phase 2a Probe 3b). The "non-interactive semantics may differ" concern was conservative and never materialized.
- **Caveats**: (a) `claude -p` adds ~3-5s CLI cold-start overhead + loads ~19k cache-creation tokens of CLAUDE.md/skills context — so it is NOT a valid proxy for LATENCY measurement of prompt hooks (direct API curl is required). (b) Streaming / mid-response injection behavior is untested — `claude -p` is request-response, not streaming.
- **Action**: Future TAD hook spikes should default to `claude -p --no-session-persistence --tools '' --system-prompt <probe>` for hook fire + injection verification. Reserve "new interactive terminal" only when the test explicitly concerns streaming or long-session behavior. This unblocks automated hook testing from Blake's non-interactive sessions.

### Domain Pack Keyword Curation: Uniqueness > Count - 2026-04-07
- **Context**: Phase 2b built `.tad/hooks/keywords.yaml` with 20 packs for the production Architecture C router hook. Handoff mandated ≥3 unique anchors per pack, ≤2 packs per keyword, threshold 2 for packs ≥8 keywords. Initial curation hit 11/30 integration test accuracy because threshold 2 was too strict for short messages, even when the keywords were well-chosen.
- **Discovery**: When keywords are **strictly unique per pack** (zero cross-pack appearance), `threshold: 1` produces high-confidence matches with 100% accuracy on a 30-case test. The handoff's "threshold 2 for packs ≥8 keywords" rule was designed as a safeguard against low-quality keyword lists; with stricter uniqueness auditing, the safeguard becomes unnecessary.
- **Curation rules that actually matter** (ranked by accuracy impact):
  1. **Include both hyphenated AND space-separated variants** of multi-word keywords (`react-native` AND `react native`, `mcp-server` AND `mcp server`, `play-store` AND `play store`). Literal `index()` match cannot bridge the gap. This alone fixed ~6 of 19 Round 1 failures.
  2. **Hand-curate Chinese synonyms** per test-scenario vocabulary: the English-only generator heuristic misses `手势`, `密钥泄漏`, `3d 打印`, `电路板上电`, `防幻觉`, `漂移`, etc. Budget ~5 minutes per pack for CJK curation.
  3. **Avoid phrasal keywords that can be interrupted** by particles: `prompt 漂移` fails on `prompt 总是漂移` because of `总是`. Use standalone words when the compound form is fragile.
  4. **Strict unique-anchor audit after every curation round**: zero keywords in >1 pack gives single-hit reliability. Run a cross-pack collision audit script; make it an AC not an afterthought.
- **Action**: For keyword-based classification hooks: prefer threshold 1 with strict uniqueness over threshold 2 with relaxed uniqueness. Include hyphen + space variants of compound terms. Budget real time for CJK hand-curation; no English-only generator can produce it.

### Epic Architecture Pivot Through Successive Spikes - 2026-04-07
- **Context**: Epic 1 Domain Pack Reliable Loading went through 3 spike-driven architectural pivots in ~1 working day: (1) Phase 1 validated `UserPromptSubmit` hook EXISTS via `type: command`; (2) Phase 2a assumed Architecture A (`type: prompt` + Haiku) would work since type:prompt precedent exists in PreToolUse — proved WRONG, type:prompt is permission-gate-only; (3) pivoted to Architecture C (keyword matching, no LLM) which shipped with 100% accuracy and 81ms latency.
- **Discovery**: Each pivot was cheap because of spike discipline. Key pattern:
  1. **Cross-validate assumptions between hook types**. Phase 1 used `type: command` but Phase 2 designed `type: prompt`. The two types have completely different response contracts — we learned this only through Phase 2a spike, not code review. Expert review caught the unverified contract as P0 but couldn't tell us WHICH contract was correct without an actual test.
  2. **"The simple solution" often beats "the smart solution" when mechanism constraints force it**. Architecture A (LLM classifier) was intuitive and smart. Architecture C (bash + grep + YAML) was dismissed as "maintenance heavy" in initial design. Post-spike, C shipped in 6h with 100% accuracy and zero ongoing LLM cost. The ~2h spent curating keywords.yaml was dominated by type:prompt pivot cost we would've hit anyway.
  3. **Expert review scales with architectural risk, not file count**. Phase 2a micro-spike (~45 min) had 2 rounds of expert review (8 P0s total) because the unknown carried fleet-wide blast radius. Phase 2b (~6h production code) also had 2 rounds (8 P0s). Same review investment, very different code volumes. For hook/infra code, review-per-hour is HIGH.
  4. **Performance surprises live in fork/exec, not algorithms**. Blake's 7-9x hook speedup came from replacing `N×grep` with `1×awk` — fork overhead was invisible in functional tests but dominated wall clock. Always measure p95 wall clock, not just "it works".
  5. **Prior review constraints should be challenged with evidence**. Phase 2a's P0-5 "only use interactive terminal for hook testing" was empirically wrong (Blake proved `claude -p` works for hook fire + injection across 4 spikes). Knowledge captured — future hook spikes can test non-interactively, saving setup time.
- **Action**: For multi-phase Epics touching hooks/settings/system infra: (a) plan for 2-3 architectural pivots as the default, not the exception; (b) split "design" and "contract validation" into separate spikes when the contract is untested; (c) favor simpler architectures after mechanism surprises — the "smart" option often turns out to have hidden mechanism costs; (d) budget expert review time by risk, not code volume.

### Spike-Driven Epic De-Risking with Light TAD - 2026-04-07
- **Context**: Epic 1 Phase 1 was a Light TAD spike to validate two unknowns (UserPromptSubmit existence + Haiku classification accuracy) before committing to full Epic design
- **Discovery**: The Light TAD + spike combination is a powerful pattern for de-risking Epics that contain "mechanism unknown" risks. Key elements that made this work:
  1. **Cheap to fail**: ~50 minutes actual time (vs 4.5h hard cap) — failure cost is bounded
  2. **Pivot threshold in AC**: AC11 explicit time cap + AC6 hard accuracy/latency bar = automatic pivot signal
  3. **Two-axis verdict** (`integration:GO / accuracy:GO / latency:NO-GO`) instead of single GO/NO-GO — captures partial success without forcing false binary
  4. **Forward compatibility built-in**: spike's schema (matched_packs envelope, recipe field) reserved for downstream Epics (Epic 3) to avoid retrofitting
  5. **Failed sub-AC ≠ failed spike**: latency missed the bar but the spike was still valuable because the failure had a clear remediation path. PARTIAL verdict is honest and useful.
  6. **In-spike escalation**: when ANTHROPIC_API_KEY was missing, Blake escalated to user mid-spike rather than abandoning. User chose proxy mode, which produced inflated but still informative numbers + a clear "Phase 2 must remeasure" caveat.
- **Action**: When an Epic contains "is mechanism X possible?" type unknowns, always insert a Light TAD spike as Phase 1. Build the spike's verdict structure as multi-axis (integration / accuracy / latency / cost) not single GO/NO-GO. Pre-allocate forward-compatibility fields (envelope schemas) even when spike only tests one case.

### Expert Review Blind Spot: Cross-File Internal References - 2026-04-04
- **Context**: Commands/Skills consolidation handoff — expert review caught config files and tad.sh but missed skill-to-skill cross-references
- **Discovery**: When renaming/moving files, expert reviewers (code-reviewer + architect) checked config files, installer scripts, and documentation — but did NOT check references WITHIN the skill files themselves (tad-help, tad-status, tad-init all had `.claude/commands/` internal references). Blake's broader grep caught these.
  1. **Expert review checks "known reference points"** (configs, scripts, docs) but misses **peer references** (skill A referencing skill B's old path)
  2. **Broader grep is the safety net** — always run `grep -r` across the entire active codebase as a final verification step, don't rely on expert-identified file lists alone
- **Action**: For file rename/move handoffs, always include an AC that requires `grep -r '{old_path}'` across the entire project (excluding archive/backup). This catches references that expert review misses.
