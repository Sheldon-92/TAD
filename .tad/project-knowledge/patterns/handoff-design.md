# Handoff Design Patterns (Layer 2)

> Reusable patterns for handoff structure, protocol design, lifecycle management, and state machines.

---

### Platform Capability Assumptions Decay Fast — Re-research Before Architecture - 2026-06-08
- **Context**: 2026-04-27 Codex Adaptation Epic built a compressed dual-edition system (85% content loss) based on "Codex lacks hooks/skills/subagents." 6 weeks later, deep research revealed Codex had gained all those capabilities (hooks 10 events, .agents/skills/, subagent GA, ask_user_question). The entire compression architecture was unnecessary waste.
- **Discovery**: Platform capability assumptions (especially for fast-evolving CLI tools) become stale within weeks. The cost of re-research (~30 min web search + doc fetch) is trivial compared to maintaining a wrong architecture (dual editions, regen scripts, parity checks, 72-85% information loss). Always re-verify platform capabilities before designing cross-platform adaptations.
- **Action**: Before any cross-platform architectural decision, do a fresh capability audit of the target platform's current state (official docs + changelog). Never rely on assumptions older than 2 months for fast-evolving CLI tools.
- **Grounded in**: EPIC-20260608-cross-platform-unification.md, Codex CLI docs (developers.openai.com/codex/)
- **failure_mode**: Naive default: rely on capability assumptions from weeks/months ago when designing cross-platform architecture. Why wrong: fast-evolving CLI tools gain new capabilities within weeks, making entire architectural workarounds unnecessary waste.

### SKILL Progressive Loading: Activation Works But Deep Protocol References Don't Auto-Load on Codex - 2026-06-09
- **Context**: SKILL Progressive Loading Epic (2026-06-08) extracted 27 protocols from Alex+Blake SKILL.md to references/ with `load_when` stubs. Body shrank 73% (8316→2222 lines). Codex dogfood: $alex/$blake activation succeeds, *help menu displays correctly. But when Blake in Codex executed a real handoff (GEN food project), Layer 2 expert review, completion report format, and evidence requirements were all skipped — the corresponding references/ files were never loaded.
- **Discovery**: Codex's progressive loading (Layer 1→2→3) loads SKILL.md body on skill activation but does NOT automatically follow `load_when` stubs to read references/ during execution. The model must actively decide to Read the reference file when it hits a stub — but without the full protocol context in memory, it doesn't know it's missing something. This creates a "silent capability loss": the agent activates correctly and knows its commands, but lacks the detailed execution rules that were moved to references/. Claude Code's Skill tool handles this better because it has tighter integration with the file system.
- **Action**: (1) Critical protocols that affect every execution (Gate 3 checklist, completion report format, Layer 2 requirements) may need to stay in body or be inlined back as abbreviated versions. (2) References/ work well for mode-specific protocols (*bug, *discuss) that are explicitly entered via intent router. (3) Test any SKILL restructuring with a real end-to-end task in Codex, not just activation. Activation ≠ execution fidelity.
- **Grounded in**: Codex dogfood 2026-06-09 (GEN food project), EPIC-20260608-skill-progressive-loading.md
- **failure_mode**: Naive default: extract all protocols to reference files and assume activation success means execution fidelity. Why wrong: Codex does not auto-follow load_when stubs during execution, causing silent capability loss where the agent activates correctly but lacks detailed execution rules.

### Circular Trigger Pattern: Structural Discriminant for Body vs Reference Placement - 2026-06-09
- **Context**: Phase 1 audit of 36 reference files for EPIC-20260609-skill-body-reference-boundary. Applied two-part criterion (omission + mis-execution) to all files. Expected many borderline cases; found a clean structural separator instead.
- **Discovery**: All 3 must-body files share a structural property: **circular triggers** — the `load_when` stub refers to a step that the reference itself defines. Ralph-loop.md defines the Ralph Loop but the stub says "read when entering Ralph Loop"; without the reference, the agent doesn't know the Loop exists, so the trigger never fires. All 33 reference-ok files have **non-circular triggers** — the agent knows the triggering event independently (explicit `*command`, workflow chain step, or on-demand capability). This is a mechanically verifiable property, not a subjective judgment: check whether the `load_when` can fire WITHOUT the agent having read the reference. If it can't → circular → must-body.
- **Action**: When creating new reference files, verify the `load_when` trigger is non-circular. If the trigger references a concept defined inside the reference, the content must stay in body. Use this as a pre-flight check before extracting any protocol to references/.
- **Grounded in**: .tad/evidence/designs/skill-body-reference-audit.md, EPIC-20260609-skill-body-reference-boundary.md Phase 1
- **failure_mode**: Naive default: extract any protocol to a reference file regardless of whether the load_when trigger depends on content defined inside the reference. Why wrong: circular triggers mean the agent never learns the concept exists, so the trigger never fires and the protocol is silently lost.

### Runtime Freshness Applies to Both First-Class Platforms - 2026-06-09
- **Context**: Gate 4 acceptance of EPIC-20260609-dual-platform-native-runtime-architecture Phase 1. Blake initially treated Claude Code freshness as lower-risk while designing a Codex-heavy freshness loop; review corrected the boundary.
- **Discovery**: Codex is the higher-volatility platform, but Claude Code is not "not applicable" for freshness tracking. Compact behavior, Skill tool behavior, Agent tool/subagent behavior, hook contracts, MCP config, and sync semantics can also drift. A dual-platform architecture needs two compatibility ledgers: a high-volatility Codex ledger and a lighter Claude Code ledger. Otherwise TAD recreates the same stale-assumption failure on the "primary" runtime.
- **Action**: For every first-class TAD runtime, maintain a runtime compatibility ledger with `last_verified`, source/version, volatility, next review, regression requirement, and fallback behavior. Treat Codex unknown safety/quality-affecting behavior as fail-closed; treat Claude Code changes as lower-frequency but still release-gated.
- **Grounded in**: .tad/evidence/designs/dual-platform-native-runtime-architecture.md D7 + Capability Matrix, HANDOFF-20260609-dual-platform-runtime-architecture-phase1.md, code-review-r2.md
- **failure_mode**: Naive default: only track freshness for the higher-volatility platform (Codex) and treat the primary platform (Claude Code) as stable. Why wrong: Claude Code's compact behavior, Skill tool, Agent tool, hook contracts, and MCP config can also drift, recreating the stale-assumption failure on the "safe" runtime.

### Runtime Config Drafts Need Parsed-Path Verification - 2026-06-09
- **Context**: Phase 2 Codex native runtime policy created draft `.codex/config.toml` and custom-agent TOML files under evidence. Spec review found that a syntactically valid TOML draft can still place a key under the wrong table if root-level keys appear after a `[table]` header.
- **Discovery**: TOML parsing success is not enough. A key like `web_search = "cached"` after `[agents]` parses cleanly but becomes `agents.web_search`, silently changing semantics. Runtime config handoffs must verify both parse success and parsed key path for load-bearing settings.
- **Action**: For TOML/YAML/JSON runtime config drafts, include a parsed-path check for every important key, not only syntax validation. For TOML, root-level keys must appear before any table header unless intentionally scoped.
- **Grounded in**: .tad/evidence/designs/codex-runtime-candidates/config.toml.draft, spec-compliance-review.md AC17, code-review-r2.md
- **failure_mode**: Naive default: validate runtime config files only for syntax/parse success. Why wrong: a key placed after a [table] header silently becomes scoped under that table (e.g., root-level key becomes agents.key), changing semantics while parsing cleanly.

### Missing Interactive-Decision Hooks Are Evidence-Completeness Gaps - 2026-06-09
- **Context**: Phase 2 Codex native runtime policy assessed `.codex/hooks.json`. The `askuser-capture.sh` hook is wired to `PostToolUse` matcher `ask_user_question`, but Phase 1 could not verify an exact Codex `ask_user_question` tool equivalent.
- **Discovery**: If a decision-capture hook silently never fires on Codex, the impact is not merely convenience. It removes decision provenance from the evidence chain for Socratic inquiry, mode selection, and gate confirmations, creating a quality-chain evidence-completeness gap.
- **Action**: Treat unknown interactive-decision hook behavior as a Phase 5 regression requirement. If the Codex matcher does not fire, adapt the matcher to Codex's actual tool/event name or implement an alternate evidence-capture path.
- **Grounded in**: .tad/evidence/designs/codex-native-runtime-policy.md Hooks Policy + Risks, HANDOFF-20260609-codex-native-runtime-policy.md, code-review-r2.md
- **failure_mode**: Naive default: treat a decision-capture hook that silently never fires on a platform as a minor convenience issue. Why wrong: it removes decision provenance from the evidence chain for Socratic inquiry, mode selection, and gate confirmations — a quality-chain evidence-completeness gap, not just missing UX.

### Cognitive Firewall: Embed Into Existing Flows - 2026-02-06
- **Discovery**: Cross-cutting concerns are most effective embedded into existing mandatory flows (Gates, Alex design phase, Blake execution) rather than standalone commands. Insert, don't create. Escalation over automation.
- **Action**: Embed quality/safety concerns as mandatory steps in existing flows rather than separate commands.
- **failure_mode**: Naive default: create standalone commands or separate workflows for cross-cutting concerns (quality, safety). Why wrong: standalone commands are optional and skippable; embedding into mandatory existing flows (Gates, design phase, execution) ensures enforcement without extra ceremony.

### Manifest + Directory Isolation for Multi-Instance Resources - 2026-02-09
- **Discovery**: Singleton → multi-instance: directory isolation per instance, YAML manifest as index (but directories are ground truth), atomic archive via `mv`, max_active constraint at creation time.
- **Action**: Use directory isolation + manifest index. Always make directories the source of truth.
- **failure_mode**: Naive default: track multi-instance resources in a single manifest file as source of truth. Why wrong: the manifest can desync from actual directories; directories must be ground truth with the manifest as a derived index.

### Intent Router and Mode Addition - 2026-02-16
- **Discovery**: Route BEFORE process — insert routing layer before existing protocol. Always confirm intent via AskUserQuestion. Adding modes requires 5-layer integration (config, protocol, router, lifecycle, surface) to avoid silent partial integration. Supersedes: separate Mode Addition Checklist entry.
- **Action**: Create routers that dispatch to isolated paths. Use 5-layer checklist for new modes.
- **failure_mode**: Naive default: add a new mode by only updating the config and protocol, skipping router, lifecycle, and surface integration. Why wrong: partial integration causes silent mode bypass where the mode exists but is never routed to or properly surfaced to the user.

### Storage and Lifecycle Patterns - 2026-02-16
- **Discovery**: (1) Lightweight storage upgrade: template-first, cross-reference don't migrate, forward-only lifecycle. (2) Aggregation layer: reference don't copy, suggest don't auto-sync. (3) Lifecycle chain closure: separate status update from target workflow entry, use conversation memory for same-session transitions.
- **Action**: Maintain cross-references in original locations. Aggregation layers reference, never duplicate.
- **failure_mode**: Naive default: copy/duplicate data between aggregation layers and auto-sync status changes. Why wrong: duplication creates desync; reference-only aggregation with manual lifecycle transitions preserves single source of truth.

### Feature Deprecation Cleanup Pattern - 2026-02-17
- **Discovery**: Use function names not line numbers for script cleanup. Detect dual-purpose files. Grep-driven completeness: always run `grep -r` across entire codebase. Acceptance criteria MUST include automated grep verification.
- **Action**: For multi-file feature removal: function-name targeting, broad grep, automated verification in AC.
- **failure_mode**: Naive default: use line numbers for script cleanup and skip codebase-wide grep verification. Why wrong: line numbers shift across edits, and without grep -r across the entire codebase, orphaned references to the deprecated feature survive silently.

### Minimal Viable Cross-Cutting Enhancement - 2026-02-19
- **Discovery**: Start with the 2 most critical points (producer + consumer) rather than all possible points. Resist over-engineering. YAML insertions must match surrounding format exactly.
- **Action**: Identify producer + consumer nodes first. Expand only based on observed need.
- **failure_mode**: Naive default: enhance all possible touchpoints for a cross-cutting concern at once. Why wrong: over-engineering beyond the 2 critical points (producer + consumer) adds complexity without observed need; expand only when gaps are demonstrated.

### Cleanup Handoff Scope-Estimation Drift - 2026-04-27
- **Discovery**: Alex routinely underestimates cross-cutting deletion blast radius (4 files initially → 10 actual). Primary-mention bias finds DEFINITION sites. Consumer blind spot misses OUTPUT MECHANISM consumers. Post-impl Layer 2 catches consumers because it greps the post-deletion codebase.
- **Action**: Add "Downstream Consumers Grep" step for deletion handoffs: extract output mechanism signature, grep broadly.
- **failure_mode**: Naive default: estimate deletion blast radius from primary definition sites only. Why wrong: primary-mention bias misses output mechanism consumers; actual blast radius is typically 2-3x the initial estimate (e.g., 4 files → 10).

### Protocol State-Machine Design - 2026-05-02
- **Discovery**: Three mandatory patterns for AI protocols: (1) explicit state-machine transitions at every section end, (2) bootstrapping path for missing resources, (3) named Q1/Q2/Q3 blocks with inline gates instead of numbered lists for sequential questions. AI agents enforce protocol-embedded requirements even against explicit user override.
- **Action**: Map every section → next section. Include bootstrapping steps. Use named blocks with inter-step gates.
- **failure_mode**: Naive default: write AI protocols as numbered sequential lists without explicit state transitions or bootstrapping. Why wrong: AI agents make unpredictable navigation decisions without explicit transition arrows at every section end, and fail when resources are missing without bootstrapping paths.

### Registry and Protocol Field Design - 2026-05-04
- **Discovery**: (1) Hybrid persisted+derived state: document which states are user-set vs derived, which operations persist. (2) Protocol fields need three declarations: which file, lifecycle semantics, missing-field bootstrap. (3) Scan-log merge-not-overwrite preserves user decisions across automation runs. (4) `gh api` = snake_case; `gh search repos --json` = camelCase. (5) `gh api contents/` returns root only — use `git/trees?recursive=1`.
- **Action**: Document status field semantics explicitly. Separate fresh scan data from user decision state.
- **failure_mode**: Naive default: mix user-set decision state and auto-derived scan data in the same fields without documenting which is which. Why wrong: automation runs overwrite user decisions, and gh API field casing inconsistencies (snake_case vs camelCase) cause silent data loss.

### Step Insertion Requires Predecessor Transition Arrow Audit - 2026-05-14
- **Discovery**: Updating the new step's `trigger` field is necessary but NOT sufficient. ALL explicit transition arrows in predecessor steps must also be audited. Grep for references to the old successor step. The grep audit is cheap (~2 min) and prevents silent step-bypass.
- **Action**: When inserting step N between N-1 and N+1: grep for ALL references to N+1 in predecessor action text.
- **failure_mode**: Naive default: update only the new step's trigger field when inserting a step between existing steps. Why wrong: predecessor steps may have explicit transition arrows pointing to the old successor, causing the new step to be silently bypassed.

### Sufficiency Check Must Precede the Step It Influences - 2026-05-14
- **Discovery**: When a conditional modifies an earlier step's behavior, it must be placed BEFORE that step. Handoff design can have ordering bugs that expert review misses pre-handoff but catches post-impl.
- **Action**: Verify conditional check runs BEFORE the step it modifies in protocol execution order.
- **failure_mode**: Naive default: place a conditional check anywhere in the protocol without verifying execution order relative to the step it modifies. Why wrong: if the conditional runs after the step it should influence, the modification never takes effect — an ordering bug that expert review may miss pre-handoff.

### Autonomous Protocol Design: Three Mandatory Patterns - 2026-05-14
- **Discovery**: (1) Explicit transition arrows at every step (agents make different navigation decisions without them). (2) Verify + on_verify_fail for every sub-agent output (crash resume). (3) Re-review after every P0 fix (Gate PASS must reflect v2, not v1). KEEP steps requiring tool access must be Conductor-side post-validation.
- **Action**: Add transition arrows inline. Every Agent spawn needs verify + on_verify_fail. Re-review after P0 fixes.
- **failure_mode**: Naive default: design autonomous protocols without explicit transition arrows, without verify/on_verify_fail for sub-agent outputs, and pass Gate after fixing P0s without re-review. Why wrong: agents navigate unpredictably without arrows, crash without recovery paths for failed sub-agents, and Gate PASS reflects the pre-fix version instead of the actual final state.

### Verify the Worktree Base Contains the Prerequisite Commits a Handoff Grounds Against - 2026-05-31
- **Context**: research-breadth-quality-phase5. The agent worktree branch was cut from `e6ca251` (a release-sync commit) but the handoff explicitly grounded FR1/FR2 against "the WIRED protocol post-merge `4c84b09`" (Phase 4) with exact line anchors (Step 1 @ :1359, PHASE 4c @ :1543, research_complexity @ :1539). The worktree's SKILL.md was the PRE-Phase-4 single-angle version — none of those anchors existed; FR2 was meant to ENHANCE a PHASE 4c challenge step that wasn't present. Main was 7 commits ahead (incl. all of Phase 4).
- **Discovery**: A handoff's "Grounded Against {commit}" line is a precondition on the BASE, not just a citation. When a worktree/branch is cut from a different commit than the one the handoff grounds against, every line anchor and grep baseline silently refers to a file that doesn't exist in the working tree. Building anyway would attach new code to a phantom base (here: persona pass + rubric onto a protocol with no PHASE 4c). The tell: baseline greps still matched ONLY by luck would have differed — confirm anchors BEFORE editing. Clean fix: `git merge <grounding-commit-or-main> --ff-only` when the worktree has no committed work (fast-forward is non-destructive); re-verify every line anchor + baseline count post-merge.
- **Action**: Before implementing any handoff, (1) read the "Grounded Against {commit}" line, (2) `git log --oneline | grep -c <commit>` in the WORKING tree — if 0, the base is wrong, (3) fast-forward/merge the grounding commit in (or escalate if the tree has divergent committed work), (4) re-confirm the handoff's stated line anchors + grep baselines resolve before the first edit. Treat a missing grounding commit as a STOP-and-fix-base condition, not a reason to improvise against the wrong base.
- **Grounded in**: COMPLETION-20260531-research-breadth-quality-phase5.md §2, handoff §6 "Grounded Against" (4c84b09)
- **failure_mode**: Naive default: start implementing a handoff in a worktree without checking whether the worktree's base commit contains the commits the handoff was grounded against. Why wrong: every line anchor and grep baseline in the handoff silently refers to code that doesn't exist in the working tree, causing implementation to attach new code to a phantom base.

### Epic Phase Accepted Sections Are the ONLY Carry-Forward Mechanism — Missing = Silent Loss - 2026-06-09
- **Context**: Phase 5 handoff for dual-platform regression Epic. Code-reviewer P0-2 found that the Epic had no "Phase 4 Accepted" section in "Context for Next Phase." Phase 4 completion report listed 4 carry-forward items + 5 P2 code-reviewer items. Phase 2 acceptance listed 8 P2 items "for Phase 4/5 verification." None of these appeared in the Phase 5 handoff draft.
- **Discovery**: In a multi-phase Epic, the "Phase N Accepted" section in the Epic's "Context for Next Phase" is the ONLY structured mechanism that carries requirements forward. Handoff authors naturally look at the Epic's Phase Details and the prior handoff — but carry-forward items and P2 review items live in the completion report and the prior Phase Accepted section, not in the Phase Details. If the Phase Accepted section doesn't exist, those items are invisible to the next handoff author. This was caught by expert review, not by the handoff author.
- **Action**: After every Gate 4 acceptance, the *accept flow MUST write a "Phase N Accepted" section in the Epic before proceeding. Handoff authors for Phase N+1 MUST cross-check the Epic's "Context for Next Phase" sections for ALL prior accepted phases, not just the immediately preceding one (Phase 2 items skipped Phase 3/4 and landed in Phase 5).
- **Grounded in**: EPIC-20260609-dual-platform-native-runtime-architecture.md (Phase 4 Accepted added post-review), HANDOFF-20260609-dual-platform-regression-phase5.md §12 expert review CR-P0-2
- **failure_mode**: Naive default: assume carry-forward items from prior phases are visible in the Epic's Phase Details or the prior handoff. Why wrong: carry-forward items and P2 review items live in completion reports and Phase Accepted sections, not Phase Details; without a Phase Accepted section they are invisible to the next handoff author.

### Auto-Generated Registry → Persisted Decision State in Side-File - 2026-05-31
- **Context**: P5 needed a `behaviorally_verified` flag per capability pack. The natural home (pack-registry.yaml) is regenerated by scan-packs.sh.
- **Discovery**: `scan-packs.sh` regenerates `pack-registry.yaml` with `cat > "$OUTPUT"` from CAPABILITY.md/SKILL.md frontmatter, emitting a fixed field set. A flag added to the registry is CLOBBERED on the next scan (verified: `grep -c behaviorally_verified pack-registry.yaml` = 0, generator has no such field). This is the registry desync pattern (architecture.md "Registry and Protocol Field Design"): user/conductor-owned DECISION state must be separated from auto-derived SCAN data. The fix is a side-file (`behavioral-eval-status.yaml`) keyed by pack name, with documented status semantics (pending/verified/no-fixture) and a "never hand-set verified — only a passing runner result justifies it" contract (count ≠ signal).
- **Action**: Before adding any persisted flag to an auto-generated file, check whether the generator does a full regen (`cat >`/full overwrite). If so, put the flag in a name-keyed side-file with explicit status semantics, not in the regenerated artifact.
- **Grounded in**: .tad/scripts/scan-packs.sh:88,129,136,171 (cat > / cat >> regen), .tad/capability-packs/behavioral-eval-status.yaml, COMPLETION-20260531-tad-lean-trustworthy-phase5.md Task 3
- **failure_mode**: Naive default: add a persisted decision flag directly to an auto-generated registry file. Why wrong: the generator does a full regen (cat >) on every scan, silently clobbering any manually-added flags on the next run.

### Concurrent Terminals Share the Git Index and Source Trees: Pathspec-Scope Commits; Run Global Gates at Quiet Points - 2026-07-12
- **Discovery**: While one terminal completed a handoff, the SHARED git index already held 2 pre-staged files from another terminal (post-write-sync.sh, detect-state-fixture.sh); a bare `git commit` would have swept those riders into the wrong commit. `git commit -- <pathspec>` committed only the 52 in-scope paths and left the riders staged for their owner — caught by the spec-compliance reviewer, not the doer, who had checked only the worktree. Same session: the global parity set-equality gate could not PASS while the other terminal kept mutating `.claude/skills` ("both sides have uncommitted changes — cannot determine direction / STOP"), and a `parity --fix` mid-flight mirrored the other workstream's half-built state; byte-level `cmp` of the in-scope mirror files was the honest scope-level substitute.
- **Action**: In any repo where multiple terminals/agents work concurrently: commit with an explicit pathspec (`git commit -- <your paths>`) and inspect STAGED entries (`git status`), not just worktree changes, before committing. Run global consistency gates (parity set-equality, `diff -r`) only at quiet points (e.g., pre-*publish); mid-flight, present scope-level evidence (cmp of in-scope files) and explicitly defer the global re-run — do not force `--fix`.
- **failure_mode**: Naive default: run bare `git commit` after checking only your own worktree edits, and treat a mid-flight global parity FAIL as your defect to force-fix. Why wrong: the index is shared state — a bare commit sweeps another terminal's staged riders into your commit; and a global set-equality gate structurally cannot PASS under concurrent mutation, so forcing `--fix` mirrors half-built alien state into the destination tree.
- **Grounded in**: .tad/evidence/journal/memory-redirect-capture-layer-2026-07-12.md findings 2-3
