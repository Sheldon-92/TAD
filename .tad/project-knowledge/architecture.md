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
