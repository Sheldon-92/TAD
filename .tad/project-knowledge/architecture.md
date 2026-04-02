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

### Judgment-Only Skill Files: 76% Reduction is Safe - 2026-03-31
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
