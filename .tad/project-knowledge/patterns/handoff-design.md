# Handoff Design Patterns (Layer 2)

> Reusable patterns for handoff structure, protocol design, lifecycle management, and state machines.

---

### Platform Capability Assumptions Decay Fast — Re-research Before Architecture - 2026-06-08
- **Context**: 2026-04-27 Codex Adaptation Epic built a compressed dual-edition system (85% content loss) based on "Codex lacks hooks/skills/subagents." 6 weeks later, deep research revealed Codex had gained all those capabilities (hooks 10 events, .agents/skills/, subagent GA, ask_user_question). The entire compression architecture was unnecessary waste.
- **Discovery**: Platform capability assumptions (especially for fast-evolving CLI tools) become stale within weeks. The cost of re-research (~30 min web search + doc fetch) is trivial compared to maintaining a wrong architecture (dual editions, regen scripts, parity checks, 72-85% information loss). Always re-verify platform capabilities before designing cross-platform adaptations.
- **Action**: Before any cross-platform architectural decision, do a fresh capability audit of the target platform's current state (official docs + changelog). Never rely on assumptions older than 2 months for fast-evolving CLI tools.
- **Grounded in**: EPIC-20260608-cross-platform-unification.md, Codex CLI docs (developers.openai.com/codex/)

### Cognitive Firewall: Embed Into Existing Flows - 2026-02-06
- **Discovery**: Cross-cutting concerns are most effective embedded into existing mandatory flows (Gates, Alex design phase, Blake execution) rather than standalone commands. Insert, don't create. Escalation over automation.
- **Action**: Embed quality/safety concerns as mandatory steps in existing flows rather than separate commands.

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

### Cleanup Handoff Scope-Estimation Drift - 2026-04-27
- **Discovery**: Alex routinely underestimates cross-cutting deletion blast radius (4 files initially → 10 actual). Primary-mention bias finds DEFINITION sites. Consumer blind spot misses OUTPUT MECHANISM consumers. Post-impl Layer 2 catches consumers because it greps the post-deletion codebase.
- **Action**: Add "Downstream Consumers Grep" step for deletion handoffs: extract output mechanism signature, grep broadly.

### Protocol State-Machine Design - 2026-05-02
- **Discovery**: Three mandatory patterns for AI protocols: (1) explicit state-machine transitions at every section end, (2) bootstrapping path for missing resources, (3) named Q1/Q2/Q3 blocks with inline gates instead of numbered lists for sequential questions. AI agents enforce protocol-embedded requirements even against explicit user override.
- **Action**: Map every section → next section. Include bootstrapping steps. Use named blocks with inter-step gates.

### Registry and Protocol Field Design - 2026-05-04
- **Discovery**: (1) Hybrid persisted+derived state: document which states are user-set vs derived, which operations persist. (2) Protocol fields need three declarations: which file, lifecycle semantics, missing-field bootstrap. (3) Scan-log merge-not-overwrite preserves user decisions across automation runs. (4) `gh api` = snake_case; `gh search repos --json` = camelCase. (5) `gh api contents/` returns root only — use `git/trees?recursive=1`.
- **Action**: Document status field semantics explicitly. Separate fresh scan data from user decision state.

### Step Insertion Requires Predecessor Transition Arrow Audit - 2026-05-14
- **Discovery**: Updating the new step's `trigger` field is necessary but NOT sufficient. ALL explicit transition arrows in predecessor steps must also be audited. Grep for references to the old successor step. The grep audit is cheap (~2 min) and prevents silent step-bypass.
- **Action**: When inserting step N between N-1 and N+1: grep for ALL references to N+1 in predecessor action text.

### Sufficiency Check Must Precede the Step It Influences - 2026-05-14
- **Discovery**: When a conditional modifies an earlier step's behavior, it must be placed BEFORE that step. Handoff design can have ordering bugs that expert review misses pre-handoff but catches post-impl.
- **Action**: Verify conditional check runs BEFORE the step it modifies in protocol execution order.

### Autonomous Protocol Design: Three Mandatory Patterns - 2026-05-14
- **Discovery**: (1) Explicit transition arrows at every step (agents make different navigation decisions without them). (2) Verify + on_verify_fail for every sub-agent output (crash resume). (3) Re-review after every P0 fix (Gate PASS must reflect v2, not v1). KEEP steps requiring tool access must be Conductor-side post-validation.
- **Action**: Add transition arrows inline. Every Agent spawn needs verify + on_verify_fail. Re-review after P0 fixes.

### Verify the Worktree Base Contains the Prerequisite Commits a Handoff Grounds Against - 2026-05-31
- **Context**: research-breadth-quality-phase5. The agent worktree branch was cut from `e6ca251` (a release-sync commit) but the handoff explicitly grounded FR1/FR2 against "the WIRED protocol post-merge `4c84b09`" (Phase 4) with exact line anchors (Step 1 @ :1359, PHASE 4c @ :1543, research_complexity @ :1539). The worktree's SKILL.md was the PRE-Phase-4 single-angle version — none of those anchors existed; FR2 was meant to ENHANCE a PHASE 4c challenge step that wasn't present. Main was 7 commits ahead (incl. all of Phase 4).
- **Discovery**: A handoff's "Grounded Against {commit}" line is a precondition on the BASE, not just a citation. When a worktree/branch is cut from a different commit than the one the handoff grounds against, every line anchor and grep baseline silently refers to a file that doesn't exist in the working tree. Building anyway would attach new code to a phantom base (here: persona pass + rubric onto a protocol with no PHASE 4c). The tell: baseline greps still matched ONLY by luck would have differed — confirm anchors BEFORE editing. Clean fix: `git merge <grounding-commit-or-main> --ff-only` when the worktree has no committed work (fast-forward is non-destructive); re-verify every line anchor + baseline count post-merge.
- **Action**: Before implementing any handoff, (1) read the "Grounded Against {commit}" line, (2) `git log --oneline | grep -c <commit>` in the WORKING tree — if 0, the base is wrong, (3) fast-forward/merge the grounding commit in (or escalate if the tree has divergent committed work), (4) re-confirm the handoff's stated line anchors + grep baselines resolve before the first edit. Treat a missing grounding commit as a STOP-and-fix-base condition, not a reason to improvise against the wrong base.
- **Grounded in**: COMPLETION-20260531-research-breadth-quality-phase5.md §2, handoff §6 "Grounded Against" (4c84b09)

### Auto-Generated Registry → Persisted Decision State in Side-File - 2026-05-31
- **Context**: P5 needed a `behaviorally_verified` flag per capability pack. The natural home (pack-registry.yaml) is regenerated by scan-packs.sh.
- **Discovery**: `scan-packs.sh` regenerates `pack-registry.yaml` with `cat > "$OUTPUT"` from CAPABILITY.md/SKILL.md frontmatter, emitting a fixed field set. A flag added to the registry is CLOBBERED on the next scan (verified: `grep -c behaviorally_verified pack-registry.yaml` = 0, generator has no such field). This is the registry desync pattern (architecture.md "Registry and Protocol Field Design"): user/conductor-owned DECISION state must be separated from auto-derived SCAN data. The fix is a side-file (`behavioral-eval-status.yaml`) keyed by pack name, with documented status semantics (pending/verified/no-fixture) and a "never hand-set verified — only a passing runner result justifies it" contract (count ≠ signal).
- **Action**: Before adding any persisted flag to an auto-generated file, check whether the generator does a full regen (`cat >`/full overwrite). If so, put the flag in a name-keyed side-file with explicit status semantics, not in the regenerated artifact.
- **Grounded in**: .tad/scripts/scan-packs.sh:88,129,136,171 (cat > / cat >> regen), .tad/capability-packs/behavioral-eval-status.yaml, COMPLETION-20260531-tad-lean-trustworthy-phase5.md Task 3
