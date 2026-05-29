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
<!-- Consolidated by *dream on 2026-05-14. Original: 119 entries / 1118 lines. -->

### Ralph Loop Two-Layer Architecture - 2026-01-26
- **Discovery**: Two-layer quality (Layer 1: fast self-check, Layer 2: expert review) with circuit breaker (3 same errors → escalate), state persistence for crash recovery, and priority groups (blocking gate before parallel verification).
- **Action**: Apply this pattern to any iterative workflow needing external quality validation.

### Gate Responsibility Matrix - 2026-01-26
- **Discovery**: Technical experts (code-reviewer, test-runner, security, performance) → Blake's Gate 3 v2. Business acceptance (requirement verification, user approval) → Alex's Gate 4 v2.
- **Action**: Separate technical automation from business judgment in quality gates.

### Cognitive Firewall: Embed Into Existing Flows - 2026-02-06
- **Discovery**: Cross-cutting concerns are most effective embedded into existing mandatory flows (Gates, Alex design phase, Blake execution) rather than standalone commands. Insert, don't create. Escalation over automation.
- **Action**: Embed quality/safety concerns as mandatory steps in existing flows rather than separate commands.

### Standalone Agent Command Pattern - 2026-02-08
- **Discovery**: When a workflow grows beyond ~100 lines with distinct skills, extract to standalone command with own persona and output-only integration (DESIGN-SPEC.md). Terminal isolation preserved. Supersedes: Style Library Architecture (same date — usage guidance pattern).
- **Action**: Extract sub-phases with >100 lines and distinct skill profiles to standalone commands.

### Manifest + Directory Isolation for Multi-Instance Resources - 2026-02-09
- **Discovery**: Singleton → multi-instance: directory isolation per instance, YAML manifest as index (but directories are ground truth), atomic archive via `mv`, max_active constraint at creation time.
- **Action**: Use directory isolation + manifest index. Always make directories the source of truth.

### Intent Router and Mode Addition - 2026-02-16
- **Discovery**: Route BEFORE process — insert routing layer before existing protocol. Always confirm intent via AskUserQuestion. Adding modes requires 5-layer integration (config, protocol, router, lifecycle, surface) to avoid silent partial integration. Supersedes: separate Mode Addition Checklist entry.
- **Action**: Create routers that dispatch to isolated paths. Use 5-layer checklist for new modes.

### Storage and Lifecycle Patterns - 2026-02-16
- **Discovery**: (1) Lightweight storage upgrade: template-first, cross-reference don't migrate, forward-only lifecycle. (2) Aggregation layer: reference don't copy, suggest don't auto-sync. (3) Lifecycle chain closure: separate status update from target workflow entry, use conversation memory for same-session transitions.
- **Action**: Maintain cross-references in original locations. Aggregation layers reference, never duplicate.

### Feature Deprecation Cleanup Pattern - 2026-02-17
- **Discovery**: Use function names not line numbers for script cleanup. Detect dual-purpose files. Grep-driven completeness: always run `grep -r` across entire codebase. Acceptance criteria MUST include automated grep verification.
- **Action**: For multi-file feature removal: function-name targeting, broad grep, automated verification in AC.

### Minimal Viable Cross-Cutting Enhancement - 2026-02-19
- **Discovery**: Start with the 2 most critical points (producer + consumer) rather than all possible points. Resist over-engineering. YAML insertions must match surrounding format exactly.
- **Action**: Identify producer + consumer nodes first. Expand only based on observed need.

### Measure Before Optimizing - 2026-03-23
- **Discovery**: TAD's context loading is already well-optimized (~8.5% session start overhead). @import zero-cost for non-existent files. Hooks supplement, don't replace. Spike-driven pivot with explicit threshold (10% rule) enables early course correction.
- **Action**: Always measure actual baseline before designing optimization systems. Include pivot thresholds in spike ACs.

### Long Context Enables In-Session Decision Making (4D Protocol) - 2026-03-25
- **Discovery**: 1M context window changes methodology from "find bugs → fix later" to "discover → discuss → decide → record" in a single session. Context richness at discovery time is highest. Reports become action logs, not bug lists.
- **Action**: Design protocols for in-session decision-making with full context retention.

### Claude Code Hook Contract Summary - 2026-03-31
- **Discovery**: (1) Hooks are production-ready; skill frontmatter is limited (allowed-tools NOT enforced, per-skill hooks NOT implemented). (2) Hook event keys are PascalCase. (3) Validated events: SessionStart, PreToolUse, PostToolUse, UserPromptSubmit. (4) `type: command` supports additionalContext injection; `type: prompt` is permission-gate-only ({ok:bool}). (5) Enforcement priority: permissions.deny > hooks > allow. (6) bypassPermissions overrides everything — MUST NOT use in TAD. (7) Haiku JSON output MUST include fence-stripper (Haiku wraps in ```json fences). Supersedes: 3 separate hook mechanism entries.
- **Action**: Use hooks as primary enforcement. Validate mechanisms via spike before designing architecture.

### Judgment-Only Skill Files: Constraint Rules Are NOT Mechanical — AMENDED 2026-04-04
- **Discovery**: v2.7 slim skills removed constraint rules alongside mechanical logic → quality chain failure. Constraint rules (MUST/MANDATORY/VIOLATION) cannot be removed. Only truly mechanical logic (file I/O, config duplication) is safe to extract. Resolution (v2.8.1): commands consolidated into skills, single source of truth restored.
- **Action**: Never remove constraint rules during slimming. Audit judgment vs mechanical before extraction.
- ⚠️ SAFETY ENTRY — requires human review for any modification

### Domain Pack Architecture Patterns - 2026-04-02
- **Discovery**: (1) Type A/B/Mixed step models: Document=search→analyze→derive→generate, Code=select→execute→verify→optimize, Mixed=human-AI 4D Protocol. (2) Declare tool availability boundaries explicitly. (3) Workflow steps > quality criteria text for improving pack quality. (4) Each capability judged independently — same pack can mix types.
- **Action**: Classify capabilities as A/B/Mixed first. Require ≥1 new step per research task. Declare platform scope.

### Hook Shell Portability Rules - 2026-04-03
- **Discovery**: (1) No `grep -P` on macOS — use `grep -o` + `sed`. (2) Glob prefix `*.tad/` not `*/.tad/` for relative paths. (3) Single awk process beats N×grep loop (7-9x faster due to fork/exec overhead). (4) Use `ENVIRON["VAR"]` not `awk -v` for user content. (5) `perl -MTime::HiRes=time` for per-step timing, NOT python3 (~130ms startup). (6) bash `$()` strips `\x00` — use `\x1E` for separators. (7) `jq @tsv` escapes content tabs — use `join("")` instead. Supersedes: 4 separate shell portability entries.
- **Action**: Follow these rules for all TAD hook scripts. Test both relative and absolute paths.

### Domain Pack Keyword Curation - 2026-04-07
- **Discovery**: Strict uniqueness (zero cross-pack) + threshold 1 = 100% accuracy. Include hyphen AND space variants. Hand-curate Chinese synonyms (~5 min/pack). Avoid phrasal keywords interrupted by particles.
- **Action**: Prefer threshold 1 with strict uniqueness. Budget time for CJK hand-curation.

### Epic Architecture: Spike-Driven Pivots - 2026-04-07
- **Discovery**: Plan for 2-3 architectural pivots as default. Split "design" and "contract validation" into separate spikes. Favor simpler architectures after mechanism surprises. Budget expert review by risk, not code volume. Light TAD + spike de-risks "is mechanism X possible?" unknowns. Build multi-axis verdicts (integration/accuracy/latency/cost).
- **Action**: Insert Light TAD spike as Phase 1 for mechanism unknowns. Pre-allocate forward-compatibility fields.

### Expert Review Blind Spots - 2026-04-04
- **Discovery**: (1) Pre-handoff vs post-impl reviewers catch different things — same agent type, different artifact = different findings. Post-impl catches blast radius; pre-handoff catches spec bugs. (2) Cross-file internal references (peer references) are missed by expert review — broader grep is the safety net. (3) Pre-handoff reviewers grep the SPEC; post-impl reviewers grep the WHOLE codebase.
- **Action**: Always run post-impl Layer 2 review separately from pre-handoff review. Save both with distinguishing suffixes.

### Alex Handoff AC Design Rules - 2026-04-14
- **Discovery**: (1) AC lists become the operational contract — anything not in ACs is effectively optional. Alex MUST explicitly list ALL required evidence files. (2) "≥N triggers" with a concrete list is ambiguous — use "All of A, B, C must PASS" form. (3) When 3 co-mandated ACs are mutually exclusive by construction (byte-preservation + optimization + behavioral invariant), add AC Conflict Matrix sub-step. (4) AC verification commands need pre-ship smoke test — Alex MUST dry-run each on representative existing artifacts before shipping handoff.
- **Action**: Use imperative AC form. Dry-run verification commands. Add AC Conflict Matrix for structural ACs.

### Gate 4 Verification Integrity - 2026-04-14
- **Discovery**: Re-derive key pass/fail numbers from primary evidence, don't read Blake's summary. Run the same command Blake ran. Dogfood check: apply any validator to the top-level artifact. Check `git status` for uncommitted changes.
- **Action**: Gate 4 requires: raw-data recompute, validator dogfood, git status before declaring acceptance.

### Express Handoff is NOT Review-Exemption - 2026-04-14
- **Discovery**: "Express → exempt" rationalization is persistent. "Small edit" pattern-matches to "low risk" but bypasses the real question: "does this change a protocol contract?" Self-caught: expert review found 4 P0 on a 15-min express edit.
- **Action**: Express may skip e2e but MUST NOT skip expert review (min 1 expert). Treat "express = no review" as forbidden.
- ⚠️ SAFETY ENTRY — requires human review for any modification

### Claude Code Sub-Agent Safety Classifier - 2026-04-14
- **Discovery**: Haiku-layer safety classifier fires on red-team vocabulary even in authorized contexts. 70s delay with zero tokens is the refusal signature. Fix: reframe as "negative test case / blue-team defensive testing". `general-purpose` subagent accepts same prompts that `security-auditor` refuses.
- **Action**: Default to blue-team framing for security sub-agent invocations.

### Mechanical Enforcement Rejected on Single-User CLI - 2026-04-15
- **Discovery**: PreToolUse hooks work as designed but fail-closed on missing deps (Homebrew PATH not in pin list) → deny all tool calls with no self-recovery. User verdict: "日常恢复成本 > 防偶尔跳步骤收益". Kept: SKILL hardening (anti_rationalization_registry, honest_partial_protocol). Archived: hook code. Alternative: trace + human audit (smoke alarm not fire suppressor).
- **Action**: Deployment environment (single-user vs multi-user) determines enforcement means. Soft reminders for single-user CLI; mechanical hooks for multi-tenant production.
- ⚠️ SAFETY ENTRY — requires human review for any modification

### Shell Pattern: Word-Boundary Matching for Slugs - 2026-04-24
- **Discovery**: `\b` is wrong for identifier-style slugs containing `-`. BSD grep treats `-` as word boundary. Use `(^|[^A-Za-z0-9_-])PATTERN([^A-Za-z0-9_-]|$)` bracket class instead.
- **Action**: For shell-level slug matching, use bracket class not `\b`.

### Drift-Check and Staleness Detection - 2026-04-24
- **Discovery**: (1) Project-level paths (.tad/project-knowledge/*, NEXT.md, configs) are intentionally cross-handoff — allowlist them in drift detectors. (2) Staleness detection needs a `Revalidated: YYYY-MM-DD` quieting path to defeat alarm fatigue. (3) BSD `date -j` needs explicit time component.
- **Action**: Maintain allowlists for shared files. Design quieting paths for smoke-alarm tools from day one.

### Path Layering: Three Defenses Against AR-001 Drift - 2026-04-24
- **Discovery**: Three independently sufficient defenses: (1) SKILL grep for CI detection, (2) NOT_via_alex_suggestion 3-rule constraint, (3) symmetric forbidden_implementations across sibling features. Three independent defenses each blocking a different failure class beats one strong mechanical defense.
- **Action**: Anchor constraints in SKILL-text grep, write explicit "NOT via X" rules, replicate forbidden_implementations symmetrically.
- ⚠️ SAFETY ENTRY — requires human review for any modification

### DESIGN.md Spec Integration as Type A Capability - 2026-04-25
- **Discovery**: External specs → new Type A capability with version pinning + license attribution + read-only consumption of upstream outputs. References block must pin version + retrieval date + license_verified. Cross-command consumption requires explicit read-only contract. Alpha tools need explicit fallback procedures.
- **Action**: Classify external spec imports as Type A. Pin versions. Include "MUST NOT modify upstream output" declarations.

### Data-Capture and AskUser Hooks - 2026-04-25
- **Discovery**: For array-valued data, do elementwise membership checks not joined-string checks. Multi-select `["P","Q"]` joined as `"P, Q"` fails membership check against `["P","Q","R"]`. Test assertions must match the data flow's purpose, not just incidental fields.
- **Action**: Write elementwise membership checks for arrays. Assert captured payload content, not just metadata.

### honest_partial_protocol: Real-Use Validation - 2026-04-25
- **Discovery**: Self-installed hard rules without env-aware exception clauses WILL eventually deadlock self-dogfood (e.g., sub-agent quota exhaustion). honest_partial is the right exit — PARTIAL not PASS, explicit conflict statement, named options for Alex. Audit script correctly refused PASS. Future hard-rule handoffs need "env edge case" sub-section. Alex MUST NOT pick options that violate the rule under acceptance-time pressure.
- **Action**: Include env edge cases in hard-rule handoffs. Use honest_partial for environmental deadlocks, not silent compliance.

### AC Verification Drift Pattern - 2026-04-25 (recurring through 4 phases)
- **Discovery**: Alex specifies AC verification commands without testing them on real artifacts. Failures surface only when Blake runs the literal command. Three sub-patterns: (1) sentinel/marker substring leak, (2) output-shape assumption mismatch (single vs multi-file grep), (3) expert reviewer scope mismatch. Root cause: mental simulation of regex is insufficient. §9.2 "Verified Output" column should be MANDATORY-FILLED by Alex before handoff ships.
- **Action**: Every non-trivial AC verification command MUST be dry-run on a representative existing artifact during handoff drafting. Paste actual command output in §9.2.

### YAML String-Form Annotation for Pack Schema Homogeneity - 2026-04-25
- **Discovery**: Dict conversion for one entry breaks schema homogeneity — every consumer must branch on type. Trailing `[applies_when: ...]` annotation is grep-extractable and zero-schema-impact. Reserve dict conversion for when ≥2 entries need the same metadata.
- **Action**: Prefer trailing inline annotation over dict polymorphism for single-entry scoping.

### Anti-AI-Slop as Cross-Pack Quality Bar - 2026-04-25
- **Discovery**: Anti-slop targets the default behavior of the agent itself, not expertise. Needs positive framing alongside negative (bold aesthetic direction, not just "don't use Inter/Roboto"). Quality bar moves with training corpus (~6 month review cycle).
- **Action**: Pair anti-slop negative patterns with positive "commit to a direction" criteria. Review every ~6 months.

### AC Self-Leak from Removal Rationale - 2026-04-27
- **Discovery**: When a grep-substring AC verifies "no occurrence of X" and the impl adds a rationale comment containing X (e.g., handoff slug containing the forbidden word), the comment self-leaks. Fix: reference META artifacts (deprecation.yaml entry, ADR id) not the handoff slug.
- **Action**: Removal rationale pointers must reference META artifacts, never the removed-feature name verbatim.

### Cleanup Handoff Scope-Estimation Drift - 2026-04-27
- **Discovery**: Alex routinely underestimates cross-cutting deletion blast radius (4 files initially → 10 actual). Primary-mention bias finds DEFINITION sites. Consumer blind spot misses OUTPUT MECHANISM consumers. Post-impl Layer 2 catches consumers because it greps the post-deletion codebase.
- **Action**: Add "Downstream Consumers Grep" step for deletion handoffs: extract output mechanism signature, grep broadly.

### `.router.log` 5-Tuple as Load-Bearing Hook Output Contract - 2026-04-27
- **Discovery**: When a hook's side-output (log file) becomes consumed by downstream scripts, it transitions from artifact to API. Format changes are breaking changes. `whitelist_early_exit` is a quasi-pack-name in field 3 that consumers must handle. Concurrency hazard with `tail -1`.
- **Action**: Add CONTRACT block to hook scripts with consumed output. Treat log format changes as semver-major.

### Two-Layer Compact Recovery Pattern - 2026-04-28
- **Discovery**: Layer 1 (trigger): self-check rule in CLAUDE.md fires every reply. Layer 2 (persistent state): `.tad/active/session-state.md` on disk. Stale detection via Status field + file existence. Hook writes metadata; SKILL writes semantics. sed delimiter `#` not `|` for path safety.
- **Action**: Anchor trigger in system-prompt content. Store state on-disk. Add stale detection. Separate hook-managed from agent-managed fields.

### Codex CLI Feasibility and Patterns - 2026-05-01
- **Discovery**: (1) ChatGPT-account Codex = permanent read-only sandbox (writes blocked). (2) `codex exec resume --last` enables multi-turn workflows. (3) SKILL injection via stdin (76KB) works with gpt-5.5. (4) `--full-auto` validated for workspace-write. (5) `codex exec --skip-git-repo-check` required for non-git dirs. (6) stderr `failed to record rollout items` is benign — use exit code. (7) `--commit` incompatible with positional PROMPT — use stdin. (8) Strip-only rule for Codex-edition SKILLs prevents drift.
- **Action**: Test write access with API key. Use `--full-auto` + stdin. Exit code is truth, ignore stderr noise.

### Codex AGENTS.md Auto-Load - 2026-05-02
- **Discovery**: Codex auto-loads `AGENTS.md` from project root (analogous to CLAUDE.md). Reference-and-read works. ≥8 trigger phrases per role (Chinese + English + slash). Default Behavior guard needed to prevent reading handoff content outside Blake activation.
- **Action**: Keep AGENTS.md (Codex) and CLAUDE.md (Claude Code) as parallel routing documents.

### Protocol State-Machine Design - 2026-05-02
- **Discovery**: Three mandatory patterns for AI protocols: (1) explicit state-machine transitions at every section end, (2) bootstrapping path for missing resources, (3) named Q1/Q2/Q3 blocks with inline gates instead of numbered lists for sequential questions. AI agents enforce protocol-embedded requirements even against explicit user override.
- **Action**: Map every section → next section. Include bootstrapping steps. Use named blocks with inter-step gates.

### Gemini CLI Constraints - 2026-05-03
- **Discovery**: (1) `-p` flag required for non-TTY invocation — hangs without it. All Gemini CLI invocations MUST use `-p` flag. (2) `-p` mode is read-only (no write_file, run_shell_command). (3) Emits PCRE-style regex — MUST validate with `grep -E` on macOS before use in hooks.
- **Action**: Always use `-p` flag. Gemini = read + analyze + text output only. Validate regex with BSD grep.

### NotebookLM Integration Patterns - 2026-05-03
- **Discovery**: (1) Auth: `notebooklm login` profile ≠ `storage_state.json` — run Playwright export. (2) Min version 0.3.4 (0.1.1 deprecated). (3) YouTube needs captions (conference/official channels). (4) `status: ready` is NOT content quality signal — always run quality probe after import. (5) `source add` (not `note create`) for knowledge feedback loop. (6) 23-43s latency acceptable for research tasks only.
- **Action**: Use absolute venv paths. Run quality probe after every import. PDF is the only reliable import path.

### NotebookLM Research Methodology - 2026-05-05
- **Discovery**: Report is baseline (orientation), multi-round Ask is value (cross-source reasoning). Five steps: create → deep research → curate (clean + deduplicate) → report → multi-round ask → save findings. Deep research imports ~30% error sources, ~25% duplicates. Token efficiency: ~60 tokens/source vs ~10K for WebSearch (150-200x improvement). `-n <id>` for per-command notebook selection (stateless), not `use <id>` (mutates global state in loops).
- **Action**: Report = Step 3 of 5, not final. Curate before asking. Use `-n <id>` in loops.

### Cross-Model Orchestration Principles - 2026-05-03
- **Discovery**: (1) Prompt symmetry is load-bearing for comparison validity. (2) Include production incumbent as third-way baseline. (3) Three-way comparison (Claude vs Codex vs production code-reviewer) needed. (4) Codex stderr `failed to record rollout items` is benign. (5) `claude -p` is valid for hook fire + injection verification (NOT latency).
- **Action**: Use identical prompts for model comparison. Include incumbent baseline. Pilot on ≥3 test cases.

### Registry and Protocol Field Design - 2026-05-04
- **Discovery**: (1) Hybrid persisted+derived state: document which states are user-set vs derived, which operations persist. (2) Protocol fields need three declarations: which file, lifecycle semantics, missing-field bootstrap. (3) Scan-log merge-not-overwrite preserves user decisions across automation runs. (4) `gh api` = snake_case; `gh search repos --json` = camelCase. (5) `gh api contents/` returns root only — use `git/trees?recursive=1`.
- **Action**: Document status field semantics explicitly. Separate fresh scan data from user decision state.

### CLAUDE.md Routing Label Conflicts - 2026-05-05
- **Discovery**: When a CLAUDE.md routing table row uses keyword X AND an associated note uses X as label prefix, grep-c X returns 2 instead of 1. Fix: relabel notes to NOT share the routing keyword.
- **Action**: Use unique label prefixes for exclusion/annotation lines. Dry-run grep ACs on proposed text.

### Capability Pack: YAML Frontmatter is Load-Bearing - 2026-05-07
- **Discovery**: Claude Code requires `name:` + `description:` YAML frontmatter for SKILL.md registration. Without it, install succeeds silently but the skill never activates. This is a MANDATORY requirement.
- **Action**: Every SKILL.md for `.claude/skills/` MUST have YAML frontmatter. Validate in install.sh.

### Capability Pack: Architecture Spectrum - 2026-05-08
- **Discovery**: Three patterns: (1) Reference-based (thin router + `references/*.md` judgment rules), (2) Deep-skill (3 interconnected SKILLs with session.json cross-skill state), (3) Orchestration-router (state-machine router with phase transitions and gates). Judgment rules → reference-based. Structured interaction → deep-skill. Workflow orchestration → router.
- **Action**: Classify pack type before starting. Classification determines file structure and content distribution.

### Capability Pack: Design and Build Rules - 2026-05-07
- **Discovery**: (1) Multi-agent install: `--agent` flag + Phase N stubs from Phase 1. (2) 3-skill deep design > 40 thin templates — interaction contracts + session.json state flow + product type adapters. (3) Rule sourcing: MUST read the cited source, not just the citation. Research findings = what to COVER, not what to SAY. (4) CONSUMES/PRODUCES interface contract between packs. (5) Write to project root first, session dir only on gate approval. (6) Use cost ratios not absolute prices (stable across years). Codex-edition SKILLs MUST follow strip-only rule to prevent drift.
- **Action**: Read cited sources before writing rules. Verify API parameter names against official docs. Declare CONSUMES/PRODUCES.

### Capability Pack: Specific Technical Rules - 2026-05-07
- **Discovery**: (1) Kubernetes: preStop sleep is MANDATORY for zero-downtime (SIGTERM-readiness race). Any K8s checklist MUST include the preStop pattern. (2) Dual-agent security (CaMeL): parser has zero tools AND planner treats parser output as typed data — MUST NOT treat as instructions. (3) Parallel tool-call atomic boundary: compression boundaries MUST fall between fully resolved assistant turns. (4) FFmpeg `sidechaincompress` attack/release in milliseconds, not seconds. (5) Quick Rule Index needs exact heading match. (6) Saturation detection: three states (SATURATED/DIMINISHING/CONTINUE), minimum threshold, consecutive rounds.
- **Action**: preStop hook for K8s. Typed schema for dual-agent output. Three-state saturation detection.

### Research-Methodology Pack as Capability Pack Factory - 2026-05-08
- **Discovery**: Plan→Source→Curate→Analyze→Output pipeline produces higher-quality rules than ad-hoc WebSearch. Persistent notebook enables cross-source synthesis with citations. Eliminates "rules from training data intuition" failure mode.
- **Action**: Run research-methodology as Phase 0 for capability packs involving external APIs or cross-vendor comparisons.

### Shell Dispatcher Patterns - 2026-05-09
- **Discovery**: (1) `set -e` propagates non-zero exits through `case` arms. (2) Portable timeout: `gtimeout` → `timeout` → no-op fallback. (3) Set-difference for newly-added item ID (`comm -13`), not positional index. (4) UTM normalization: per-param split by `&`, not bulk regex. (5) Fast-fail phases before slow-fail in fallback chains (1-2s API check before 5-10s yt-dlp). (6) Phase-specific `method:` field in frontmatter is zero-cost audit trail.
- **Action**: Single awk process for classification. Per-param split for URL query manipulation. Fast-fail first.

### Source Import Quality: False Success Patterns - 2026-05-09
- **Discovery**: NotebookLM `status: ready` is NOT content quality signal. Three failure modes: SPA shell capture, login wall capture, WAF error capture. PDF is only reliably high-quality import path. Mandatory post-import quality verification needed.
- **Action**: Never trust `status: ready` alone. Default expectation for web pages: "will probably fail" — preprocessing is primary path.

### Expert Reviewer Premise Check - 2026-05-09
- **Discovery**: Expert reviewers can confuse raw CLI calls (`~/.tad-notebooklm-venv/bin/notebooklm ask`) with SKILL command invocations (`*research-notebook ask`). These have fundamentally different execution paths. Add protective comments to raw CLI calls in mixed contexts.
- **Action**: Verify whether invocation is raw CLI or SKILL command. Add "(Raw CLI — NOT *command)" comments.

### Dynamic Research Protocol Design - 2026-05-09
- **Discovery**: (1) Saturation counters MUST have explicit update rules at every loop-back point — declare, update, embed in on-disk artifact. (2) Array-indexed conditions need `len(arr) >= N` guard before `arr[-N]` access. (3) Off-by-one in tunnel detection: `current_depth >= 3 AND len(arr) >= 2`, not just `depth >= 2`.
- **Action**: Explicit update rules at every loop-back point. Length guards for all array index access.

### Step Insertion Requires Predecessor Transition Arrow Audit - 2026-05-14
- **Discovery**: Updating the new step's `trigger` field is necessary but NOT sufficient. ALL explicit transition arrows in predecessor steps must also be audited. Grep for references to the old successor step. The grep audit is cheap (~2 min) and prevents silent step-bypass.
- **Action**: When inserting step N between N-1 and N+1: grep for ALL references to N+1 in predecessor action text.

### Epic Auto-Conductor: Sub-Agent Constraints - 2026-05-14
- **Discovery**: (1) Sub-agents have NO Agent tool — cannot spawn their own sub-agents. All review at Conductor level. (2) Sub-agents fabricate reviewer labels — don't trust self-generated "CR-P0-1" labels. (3) File is source of truth, prompt is not — write REVIEW.md, don't pass via prompt text. (4) worktree isolation doesn't protect downstream projects. (5) Conductor must ground before dispatching Alex.
- **Action**: Conductor = only real reviewer layer. Every step produces a persistent file. Sub-agent instructions reference file paths not inline content.

### Sufficiency Check Must Precede the Step It Influences - 2026-05-14
- **Discovery**: When a conditional modifies an earlier step's behavior, it must be placed BEFORE that step. Handoff design can have ordering bugs that expert review misses pre-handoff but catches post-impl.
- **Action**: Verify conditional check runs BEFORE the step it modifies in protocol execution order.

### Autonomous Protocol Design: Three Mandatory Patterns - 2026-05-14
- **Discovery**: (1) Explicit transition arrows at every step (agents make different navigation decisions without them). (2) Verify + on_verify_fail for every sub-agent output (crash resume). (3) Re-review after every P0 fix (Gate PASS must reflect v2, not v1). KEEP steps requiring tool access must be Conductor-side post-validation.
- **Action**: Add transition arrows inline. Every Agent spawn needs verify + on_verify_fail. Re-review after P0 fixes.

### YOLO Epic Execution: Cross-Model Audit Findings - 2026-05-15
- **Context**: YOLO mode executed a full Epic (5 capability pack builds + validation + freeze + cross-agent + template) in one session. Post-completion, Codex and Gemini independently audited the workflow (23/35 and 24/35 respectively).
- **Discovery**: (1) **Validation Theater** (Codex 3/5, Gemini 2/5): structural checks (grep, word count, install exit code, frontmatter) prove files exist correctly but do NOT prove the pack improves agent behavior. "13/13 installed" confirms file operations, not functional quality. (2) **Rule Soup / Context Saturation** (both 2/5 on scalability): 13 packs × 178 rules will choke reasoning at 50+ packs. Progressive disclosure (step4_5 max 2 packs) is the right direction but needs enforcement. (3) **Zero Collision Detection**: packs don't know about each other. A code-security rule could contradict a web-frontend performance rule with no mechanism to detect or resolve. (4) **Research evidence lacks auditability**: findings cite tool names and numbers but not source URLs or retrieval dates, making freshness/accuracy unverifiable.
- **Action**: (A) Add mandatory behavioral eval per pack: 3-5 before/after task comparisons with fixed rubric before marking accepted (Codex recommendation). (B) Implement pack collision detection: when ≥2 packs load, scan for contradicting rules across loaded references (Gemini recommendation). (C) Enforce max 2 packs per session via step4_5 guardrail — already exists, verify it's not bypassed. (D) Add source URLs + retrieval dates to research findings files.
- ⚠️ SAFETY ENTRY — requires human review for any modification

### YOLO Mode Strengths and Constraints - 2026-05-15
- **Context**: First full YOLO Epic execution covering research→build→validate→freeze→cross-agent→template.
- **Discovery**: (1) **Research must be Conductor-side**: NotebookLM is stateful and sequential — cannot be delegated to Blake sub-agents. Conductor runs research in Y2, saves to evidence file, Blake reads file in Y5. (2) **Pipeline parallelization works**: while Blake builds pack N, Conductor can research pack N+1 (notebook creation + source addition + deep research launch). This overlapping saved ~40% wall-clock time. (3) **Expert review diminishing returns on repetitive packs**: first pack (ai-evaluation) got full 2×2 expert review (design + implementation) catching real P0s. Subsequent packs following same pattern got lighter Conductor-level verification — appropriate for identical architecture. (4) **Cross-agent validation is cheap and high-value**: two `codex exec` calls (<2 min total) proved the AGENTS.md routing pattern works. Worth doing for every major pack change.
- **Action**: For future YOLO Epics: (A) Always pipeline research ahead of build. (B) Full expert review on first instance of a pattern, lighter verification on repetitions. (C) Include at least 1 cross-agent smoke test per Epic. (D) Conductor owns NotebookLM, Blake owns file creation — never mix.

### Capability Pack Quality Bar: Anti-Slop Metrics - 2026-05-15
- **Context**: Codex and Gemini independently scored 5 new packs on Anti-Slop dimension (does the pack add value beyond frontier LLM training data?).
- **Discovery**: (1) **Highest Anti-Slop scores** (5/5 from both): packs with specific numbers (n=550, exit code 183, 10-32x token cost ratio, ICC>0.92) that an LLM wouldn't produce from training data alone. (2) **Lowest Anti-Slop score** (Codex 3/5 on web-testing): unit testing rules partially restated common knowledge (AAA pattern, co-location, behavior-over-implementation). (3) **The differentiator is economic/statistical thresholds**: Gemini specifically called out "these packs define 'better' using concrete numbers that are easy for an agent to validate" as the top strength. (4) **Anti-slop formula**: specific threshold from research > generic principle from training data. Example: "n≥550 for production A/B decisions" > "use sufficient sample size."
- **Action**: When building future packs, prioritize extracting specific numbers/thresholds/exit codes from research. If a rule could be generated by a frontier LLM without the research notebook, it's low-value — either sharpen with specifics or remove.

### Shell Env-Var Convention for Backward-Compatible Function Extension - 2026-05-19
- **Context**: Extending `record_trace()` from 3 positional params to 10+ fields for v2 trace schema. Expert review (code-reviewer + backend-architect) independently flagged positional params as P0: "10-positional-param record_trace() is maintenance hazard — silent data corruption when callers swap arg order."
- **Discovery**: Env-var convention (`TRACE_*` variables set before call, function reads with `${TRACE_VAR:-default}`, `unset` after call) is the correct pattern for extending shell functions beyond ~3 positional args. Advantages: (1) Backward compat — existing callers unchanged, (2) Self-documenting at call site (`TRACE_OUTCOME="fail"` vs positional arg 7), (3) No silent corruption from arg order mistakes, (4) Inline assignment (`VAR=val command`) scopes to single call without export. The `unset` after call prevents bleed between sequential calls in the same script.
- **Action**: For shell functions with >3 params, use env-var convention. Reserve positional args for the 2-3 most common required params only.

### Double-Parse Pattern for String-Encoded JSON Fields - 2026-05-20
- **Context**: dream-scanner.sh needs to extract sub-fields from v2 trace events where `context` is a JSON-encoded string inside JSONL (e.g., `"context": "{\"what_failed\":\"tsc: missing type\"}""`). Three bugs discovered during implementation.
- **Discovery**: (1) **Single-pass jq is mandatory**: `jq '.context | fromjson | .what_failed'` works in one invocation. Two-step extraction (`jq -r '.context'` → shell variable → `echo "$var" | jq 'fromjson | .field'`) fails because `jq -r` outputs raw text that a second `jq` receives as a JSON object (not a string), so `fromjson` errors. (2) **jq string interpolation**: `\(expr)` is required inside `"\(...)"` — bare `((expr))` without the backslash-paren wrapper silently produces no output. (3) **Bash `read` with `IFS=$'\t'` collapses consecutive empty fields**: input `a\t\tb` splits as `field1=a field2=b` (not `field1=a field2="" field3=b`). Fix: use file-based intermediary (jq -c → temp file → while read per JSON object) instead of tab-delimited output for multi-field extraction.
- **Action**: For string-encoded JSON: always use single-pass jq with `fromjson`. For multi-field extraction from jq: use compact JSON objects per line, not tab-delimited fields.

### AC Verification Command Bug: grep -ocE | sort -u | wc -l - 2026-05-27
- **Context**: HANDOFF-20260527-vimax-pattern-upgrade-video-creation §9.1 AC15 specified `grep -ocE 'pattern' file | sort -u | wc -l` expecting count of unique pattern signal matches.
- **Discovery**: This command ALWAYS returns 1 for a single-file query, regardless of actual match content. Because `grep -c` outputs ONE number (line count for the file), `sort -u` on a single number trivially returns 1 line, `wc -l` counts 1. The intended semantics (count unique distinct match strings) requires `grep -oE 'pattern' file | sort -u | wc -l` (without `-c`, so each MATCH is on its own line). Blake's completion report inherited the same buggy command and reported "4" — Gate 4 raw-recompute caught the bug, but only by chance (Alex re-ran with `-oE` alone to investigate).
- **Action**: When AC requires "count unique distinct pattern signals", use `grep -oE 'a|b|c' file | sort -u | wc -l` (drop `-c`). Never combine `grep -c` with `sort -u | wc -l`. Add this to Alex step1d dry-run sanity check: any AC with `-oc` flags + `sort -u | wc -l` pipeline should be flagged for re-derivation.
- **Grounded in**: .tad/active/handoffs/HANDOFF-20260527-vimax-pattern-upgrade-video-creation.md:AC15, .tad/active/handoffs/COMPLETION-20260527-vimax-pattern-upgrade-video-creation.md

### Layer 2 Audit Canonical Reviewer Name Drift - 2026-05-27
- **Context**: Gate 4 ran `layer2-audit.sh vimax-pattern-upgrade-video-creation`. Audit script returned exit 0 (PASS) with `DISTINCT_COUNT=0` and WARN: "unknown reviewer name(s) — add to KNOWN_REVIEWERS in layer2-audit.sh if legitimate: spec-compliance-review code-review architecture-review".
- **Discovery**: Blake's Layer 2 review files use suffix `-review.md` (spec-compliance-review.md, code-review.md, architecture-review.md). The audit script's KNOWN_REVIEWERS list expects canonical names like `code-reviewer.md` / `backend-architect.md` / `security-auditor.md` (matching Claude Code sub-agent type names). When pack upgrade handoffs use the "domain-task-review" naming convention, the audit's distinct-count gate (Tier 1 requires ≥2 distinct reviewers) computes 0 and would WARN but for the file-count fallback.
- **Action**: Two options: (a) standardize Blake review file names to canonical sub-agent type names (code-reviewer.md, backend-architect.md, security-auditor.md, etc.) so audit script recognizes them; (b) extend KNOWN_REVIEWERS list in layer2-audit.sh to include "-review" suffix patterns for pack upgrade work. Prefer (a) — keeps audit script generic; Blake should match review filename to sub-agent type, not to handoff theme.
- **Grounded in**: .tad/hooks/lib/layer2-audit.sh, .tad/evidence/reviews/blake/vimax-pattern-upgrade-video-creation/

### ScienceClaw Skill Decoupling — Migration Feasibility Pattern - 2026-05-28
- **Context**: Phase 1 deep source study of ScienceClaw (285 skills, 8812 files). Grep scan of all 285 SKILL.md files for runtime dependency references.
- **Discovery**: ScienceClaw skills are architecturally decoupled from the OpenClaw runtime: 0/285 skills import plugin-sdk or context-engine; 37/285 mention "memory" in text (documentation references, not code imports); 8/285 reference other skills/ paths (documentation citations). The skill content (judgment rules, research protocols, API templates) is fully portable as standalone SKILL.md files. The tightly coupled components (context engine, routing, 96-file memory system, plugin SDK) are infrastructure — NOT needed for skill migration. Anti-slop value concentrates in specific thresholds (PRISMA 27-item checklist, DerSimonian-Laird formula, FDR < 0.05) rather than in generic API wrappers.
- **Action**: When porting skill libraries from external agent frameworks, scan for runtime dependency imports before planning migration scope. Zero-import skills can be extracted as judgment rules; import-heavy skills require infrastructure adaptation. Database API wrapper skills (curl templates to public APIs) have lower anti-slop value than domain-specific judgment rules — prioritize the latter.
- **Grounded in**: .tad/evidence/research/scienceclaw/architecture-analysis.md (Section 8), .tad/evidence/research/scienceclaw/skill-taxonomy.md (Runtime Deps column)

### Source Citation Integrity for Adapted Values - 2026-05-28
- **Context**: Phase 2 academic-research pack build. Code-reviewer P0 finding: tool-call thresholds were adapted from ScienceClaw SCIENCE.md (5/30/60/100+) to ranges (3-5/20-40/40-80/80+) per tad-mapping-blueprint.md Decision 6, but "> Source:" citations referenced only SCIENCE.md lines — omitting the adaptation step.
- **Discovery**: When a TAD mapping blueprint adjusts raw source values, the "> Source:" citation must reference BOTH the original source AND the adaptation document. Citing only the original creates false provenance — a user tracing the citation finds different numbers. This is the zero-hallucination principle applied to the pack's own build process. The code-reviewer caught this because the pack's content rules (zero-hallucination.md) require every claim to trace to its actual source.
- **Action**: For capability pack builds that adapt external source material via an intermediate analysis document (tad-mapping-blueprint, architecture-analysis), always cite "Adapted from [original source], adjusted per [adaptation document]". Apply this rule during Alex's AC dry-run step (§9.2 verification).
- **Grounded in**: .tad/evidence/reviews/blake/academic-research-pack-phase2/code-review.md (P0-1)

### Scoring Rubrics in Reference Files Need Methodology Review - 2026-05-28
- **Context**: Phase 5 academic-research pack. UX-expert-reviewer found 2 P0 issues in pattern-extraction.md's similarity scoring rubric that code-reviewer missed entirely.
- **Discovery**: When capability pack reference files contain scoring/rating systems (0-5 scales, pass/fail rubrics, classification schemes), code-reviewer checks structural consistency and anti-slop but does NOT check inter-rater reliability — whether two independent raters would assign the same score. The UX-expert-reviewer caught: (1) overlapping score definitions (Score 2 "2-3 shared features" vs Score 3 "same symmetry group" were simultaneously satisfiable), (2) undefined terms in rubric ("rhythm" had no glossary entry). These are invisible to code review but critical for research output reproducibility.
- **Action**: Any capability pack reference file containing a scoring rubric, rating scale, or classification scheme should trigger ux-expert-reviewer (or equivalent methodology review) in Layer 2, not just code-reviewer. Add to Blake's Layer 2 trigger heuristic: if reference file contains "|.*Score.*|" or "0-5 scale" or "rating" patterns, include ux-expert-reviewer in Group 2.
- **Grounded in**: .tad/evidence/reviews/blake/academic-research-pack-phase5/ux-review.md (P0-1, P0-2)

### Per-Tool Numeric Thresholds Require Research Provenance, Not Interpolation - 2026-05-28
- **Context**: AI voice production pack build. Code-reviewer P0-1: voice-cloning.md duration table included fabricated per-tool minimums (OpenVoice V2 10s, VoxCPM2 10s, Fish S2 Pro 10s) attributed to research but not present in research data. The baseline report mentioned "10-30 seconds" as a generic zero-shot cloning range, which was incorrectly split into per-tool entries.
- **Discovery**: When a research source provides a general range (e.g., "10-30 seconds for zero-shot cloning"), it is NOT valid to assign specific values from that range to individual tools as if they were independently measured. The research separately measured minimums for 7 specific tools (Qwen3-TTS 3s, NeuTTS Air 3s, GPT-SoVITS 5s, VibeVoice 5s, XTTS-v2 6s, Chatterbox 10s, Kokoro 15s) — these are Category A numbers. The generic "10-30s" range is a Category A range for the METHOD, not for unlisted tools. Interpolating it into per-tool entries creates false provenance: the `> Source:` citation implies research measurement when none occurred.
- **Action**: When building capability pack tables with per-tool numeric columns: (1) Only include tools with individually measured values, (2) Add a footnote for tools without measurements referencing the general range, (3) Never split a method-level range into tool-specific entries. Apply this pattern to any future pack with tool comparison matrices.
- **Grounded in**: .tad/evidence/reviews/blake/ai-voice-production-pack/code-review.md (P0-1)

### Academic Research Pack Pilot: Quality Gap Analysis - 2026-05-28
- **Context**: Epic EPIC-20260527-academic-research-pack Phase 7 pilot test. Soy sauce cross-cultural usage study. ScholarEval 0.626 (Minor Revision). 12 citations verified, zero hallucination. 17 tool calls (below 20 minimum for literature survey tier).
- **Discovery**: Three structural quality gaps in the pack's first real-world test: (1) **Depth enforcement is advisory, not blocking** — Blake self-reported 17 < 20 tool calls but completed anyway. The pack's minimum tool-call thresholds are self-checked by the agent, not mechanically enforced. This mirrors TAD's "Mechanical Enforcement Rejected on Single-User CLI" principle but means the depth guarantee depends on agent honesty. (2) **Evidence level disambiguation missing** — recipe-website quantities (America's Test Kitchen "2 tbsp per stir-fry") were presented alongside USDA-verified lab data (5493mg Na/100g) without evidence-grade labels. The pack needs a "source quality tier" annotation rule (Tier 1: primary food composition DB / Tier 2: peer-reviewed paper / Tier 3: recipe website / Tier 4: general web). (3) **Database coverage gaps foreseeable but not pre-mitigated** — Thai soy sauce USDA gap was predicted by expert review (architect P0) but the pack's fallback-chains.md only covers academic database fallbacks, not food composition database alternatives (Thai FDA, Japan Standard Tables of Food Composition). Domain-specific fallback chains need to be added to cluster reference files, not just the protocol-level fallback reference.
- **Action**: For academic-research pack v0.2: (a) Add evidence-grade labeling rule to research-protocol.md (Tier 1-4 with visual markers). (b) Add domain-specific database fallback chains to database-apis-life-sciences.md (Thai FDA, JP MEXT food composition, CN CDC nutrition). (c) Consider adding a "depth checkpoint" rule: at 50% of minimum tool calls, agent must self-audit coverage gaps before proceeding.
- **Grounded in**: .tad/evidence/research/food-science-pilot/soy-sauce-cross-cultural-report.md, .tad/evidence/research/food-science-pilot/methodology-log.md

### ChatTTS Consistency Pattern: Seed Reset + Saved Embedding > Batch Mode - 2026-05-28
- **Context**: Dogfood test of ai-voice-production pack. Chinese narration of Barney Frank article. ChatTTS batch mode (12 paragraphs as list to single `infer()`) ran 25+ minutes on Mac 16GB without completing. Sequential per-paragraph mode with varying `spk_emb` state produced inconsistent voice and background noise across segments.
- **Discovery**: (1) **Batch mode is impractical on 16GB Mac** — memory and compute scale with paragraph count, 12 paragraphs exceeded reasonable wall-clock time (25+ min CPU, 18.7% RAM). (2) **Sequential + fixed seed is the correct pattern** — `torch.manual_seed(42)` before EACH `infer()` call + same `spk_emb` tensor = consistent voice characteristics across independently generated segments. Without per-paragraph seed reset, the random state drifts and voice timbre shifts. (3) **Speaker embedding persistence** — `torch.save(spk_emb, "narrator.pt")` (~4KB) enables cross-session, cross-project voice identity. This is the long-term consistency primitive. (4) **Undocumented Chinese dependencies** — ChatTTS requires ordered-set, pypinyin, cn2an, jieba for Chinese but does not declare them in its pip dependencies. Each missing dep surfaces as a separate `ModuleNotFoundError` at import time.
- **Action**: For any TTS tool generating long-form audio segment-by-segment: (a) Reset random seed before each segment for voice consistency. (b) Persist speaker embedding to disk for cross-session reuse. (c) Use sequential generation, not batch, on memory-constrained hardware. (d) Test Chinese/CJK dependencies explicitly during pack dogfood — pip metadata is unreliable for CJK support.
- **Grounded in**: .claude/skills/ai-voice-production/references/chattts-workflow.md, dogfood artifacts /tmp/barney-frank-chattts-*.mp3

### Never Hand-Write What an Existing Tool Already Does — 2026-05-28
- **Context**: Installing TAD v2.18.0 to a new project (Colin声音项目). `tad.sh` failed due to interactive `/dev/tty` prompt in non-TTY context. Alex wrote a manual install script from memory instead of fixing `tad.sh` or reusing `*sync` logic.
- **Discovery**: (1) The manual script listed 12 of 32 `.tad/` subdirectories from memory, missing 14 directories (`hooks`, `codex`, `cross-model`, `github-registry`, `pair-testing`, etc.) and causing SessionStart hook errors + `/alex` unrecognized. (2) Skills copy also failed partially (9 of 34 installed) due to glob pattern issues with spaces in paths. (3) Root cause: bypassed two existing mechanisms (`tad.sh` installer + `*sync` process) that already have complete, tested file lists. Reimplemented from scratch → incomplete. (4) Post-install verification only checked version.txt + skill count, not a structural diff against the source — insufficient to catch missing directories.
- **Action**: (a) When an existing tool fails, fix the tool (e.g., add `--yes` flag to `tad.sh`) — don't rewrite it ad-hoc. (b) For new project installation, prefer `*sync` logic (which was just validated on 13 projects) over a one-off script. (c) Post-install verification must include structural comparison: `diff <(ls -d source/.tad/*/) <(ls -d target/.tad/*/)` to catch missing directories. (d) Future improvement: add `tad.sh --non-interactive` or `--yes` flag so it works in Claude Code terminal.
- ⚠️ SAFETY ENTRY — requires human review for any modification

### Cloud Compute Resource Awareness — Hardware Limitation ≠ Infeasibility — 2026-05-29
- **Context**: Colin voice project — user assumed voice training was impossible on 8GB Mac. Discovered free cloud GPU (Colab T4 12GB, Kaggle P100 16GB) could do it. Many stalled ideas (voice cloning, LLM fine-tune, custom assistant training) were blocked by the false assumption "local hardware = all available compute".
- **Discovery**: When an agent encounters "local hardware insufficient for task X" (model training, large-scale inference, fine-tuning), the default response should NOT be "this can't be done" but rather "this can't be done locally — here are cloud alternatives." Free and paid cloud GPU tiers exist for most ML workloads. This applies to any ML-adjacent task, not just voice production.
- **Action**: (1) In Socratic inquiry, when user mentions hardware limitations, always ask about cloud GPU awareness. (2) In capability packs involving training/fine-tuning, include cloud GPU as a hardware option alongside local. (3) Never treat "my machine can't run this" as a terminal condition — treat it as a resource allocation question.
- **Grounded in**: Colin声音项目 dogfood session (2026-05-29), ChatTTS hardware limitation discovery
