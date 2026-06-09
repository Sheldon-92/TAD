# Ralph Loop (extracted from blake/SKILL.md for progressive loading)
# Source: .claude/skills/blake/SKILL.md
# Extracted: 2026-06-08 (EPIC-20260608-skill-progressive-loading Phase 3)

ralph_loop_execution:
  # Agent Team Implementation Mode (TAD v2.3)
  # Parallel implementation with file ownership — default for Full + Standard TAD
  agent_team_develop:
    name: "Agent Team Implementation (Full + Standard TAD)"
    description: "Parallel implementation with file ownership — default for Full + Standard TAD"
    experimental: true

    activation: |
      This mode REPLACES the standard sequential implementation when ALL conditions met:
      1. process_depth in ["full", "standard"]
      2. Agent Teams feature available
      3. dependency_analysis confirms zero file overlap
      4. handoff has 2+ independent tasks
      If any condition not met → use standard Ralph Loop.
      If Team fails mid-execution → fallback to standard Ralph Loop.

    terminal_scope_constraint:
      rule: "Implementation Team stays within Blake's domain"
      allowed: ["code writing", "test writing", "building", "linting"]
      forbidden: ["requirement changes", "handoff modifications", "design decisions"]

    dependency_analysis:
      step1: "Parse handoff task list and 'Files to Modify' section"
      step2: "Map each task → set of files it will create/modify"
      step3: "Compute intersection of all file sets"
      step4_decision: |
        overlap_count == 0 AND task_count >= 2 → PROCEED with Agent Team
        overlap_count > 0 → FALLBACK to sequential Ralph Loop
        task_count < 2 → FALLBACK (overhead not justified)

    team_prompt_template: |
      Create an agent team to implement this handoff:

      HANDOFF: {handoff_path}

      FILE OWNERSHIP (strictly enforced):
      {file_ownership_map}

      Rules:
      1. Each teammate ONLY edits files in their ownership list
      2. Shared config files (package.json, etc.) are RESERVED for the lead
      3. After implementation, run: build check on your files + relevant tests
      4. Report to lead: files changed, tests added, issues found

      CONSTRAINT: This is an IMPLEMENTATION team. Do NOT change requirements or design.

    workflow:
      phase1_parallel_implementation:
        - "Blake spawns teammates based on handoff tasks"
        - "Each teammate implements their assigned tasks"
        - "Each teammate runs lightweight self-check (tsc on their files, relevant tests)"

      phase2_integration:
        - "Blake (lead) applies shared config changes if needed"
        - "Blake runs full Layer 1 (build + test + lint + tsc) on combined result"
        - "Fix integration issues (Blake does this, not teammates)"

      phase3_expert_review:
        - "Blake runs standard Layer 2 (spec-compliance → code-reviewer → test-runner etc.)"
        - "Same quality gate as current Ralph Loop"
        - "Gate 3 v2 checks apply normally"

    fallback_protocol: |
      Scenario A - Team creation fails:
        → Automatic fallback to standard Ralph Loop
      Scenario B - Teammate fails mid-execution:
        → Checkpoint completed work (git stash)
        → Remaining tasks: standard Ralph Loop
      Scenario C - Integration issues after parallel work:
        → Blake (lead) fixes integration in phase2
      All fallbacks are automatic — no user intervention needed.

    shared_files_strategy:
      config_files: ["package.json", "tsconfig.json", ".env*", "*.config.*"]
      rule: "Only the lead (Blake) modifies shared config files AFTER teammates finish"

  # Implementation Decision Escalation (Cognitive Firewall - Pillar 1 supplement)
  implementation_decision_escalation:
    description: "When Blake encounters a technical choice not covered by handoff, escalate to human"
    config: ".tad/config-cognitive.yaml → decision_transparency.decision_triggers"

    trigger: |
      During implementation, Blake encounters a situation where:
      1. Multiple viable approaches exist AND
      2. The handoff doesn't specify which approach to use AND
      3. The choice matches decision_triggers (always_significant or contextually_significant)
      Use classification_criteria to resolve ambiguous cases.

    action: |
      1. PAUSE implementation at this point
      2. Git stash current changes (checkpoint)
      3. Research the options (quick search, 2-3 minutes)
      4. Present to human via structured message:

      ────────────────────────────
      ⏸️ PAUSED: Implementation Decision Needed

      Context: While implementing {task}, I encountered a choice not covered by the handoff.

      Decision: {what needs to be decided}

      | Option | Pros | Cons |
      |--------|------|------|
      | A: {name} | ... | ... |
      | B: {name} | ... | ... |

      My recommendation: {option} because {reason}

      ⚠️ I will NOT proceed until you respond. Please choose an option.
      ────────────────────────────

      5. Wait for human response (DO NOT auto-proceed — terminal isolation means human may be in Terminal 1)
      6. On human response: git stash pop, apply decision, continue
      7. Record in completion report's "Implementation Decisions" section

    not_escalate:
      - "Pure implementation details (function decomposition, variable naming)"
      - "Decisions already made in handoff Decision Summary"
      - "Trivial choices with no significant impact"

    completion_report_section: |
      ## Implementation Decisions (Made During Execution)

      | # | Decision | Context | Chosen | Escalated? | Human Approved? |
      |---|----------|---------|--------|------------|-----------------|
      | 1 | {title} | {why it came up} | {option} | Yes/No | Yes/Default |

  # *develop command implementation
  develop_command:
    trigger: "*develop [task-id]"
    steps:
      1_init:
        - "Load/create state file: .tad/evidence/ralph-loops/{task_id}_state.yaml"
        - "Check for existing state (resume vs fresh start)"
        - "Initialize iteration counter"
        - "Create/overwrite .tad/active/session-state.md from .tad/templates/session-state-template.md:
           substitute ALL {placeholders} with actual values:
           - Status = ACTIVE
           - Active Agent.Role = Blake
           - Active Task.Handoff = <full path of current handoff>
           - Big Picture.Goal = <from handoff §1 Executive Summary — one sentence>
           - Big Picture.Why Now = <from handoff §1 problem description>
           - Big Picture.Key Constraint = <most important constraint from handoff §10>
           - Big Picture.Success When = <copy key ACs summary>
           - Current Position = 'Ralph Loop → start'
           - Last Updated = <current ISO timestamp>"

      1_5_context_refresh:
        description: "Context Refresh before implementation start"
        action: |
          Before starting implementation, re-read critical context:

          1. Re-read the selected handoff document (full content)
          2. Read the handoff's "📚 Project Knowledge" section to identify relevant files
          3. Read .tad/project-knowledge/principles.md (always — L1 methodology rules)
          4. Read .tad/project-knowledge/patterns/_index.md → match task keywords against index entries
          5. For each matched pattern file (max 3): Read .tad/project-knowledge/patterns/{matched}.md
          6. L3 incidents are NOT loaded — use knowledge-blame.sh on demand (see 1_5_knowledge_provenance)
          7. If handoff has no Project Knowledge section, the above L1+L2 loading is sufficient as default
          5. Read handoff YAML frontmatter (task_type, e2e_required, research_required)
          6. Announce: "Frontmatter: task_type={value}, e2e_required={value}, research_required={value}"
          7. Store these values — execution_checklist.during_development.task_type_branching will reference them
          8. Brief output: "📖 Implementation context refreshed: {files read}"
          
          → Proceed to 1_5a_pack_detection
        purpose: "Ensure handoff context is fresh before coding, not just at activation"

      1_5_knowledge_provenance:
        description: "On-demand knowledge rule provenance query (DiffMem-inspired)"
        trigger: |
          Blake uses this when:
          a. A .tad/project-knowledge/ rule seems inapplicable to the current task
          b. Layer 1 retry was caused by following a knowledge rule that produced an error
          c. Blake wants to understand WHY a constraint exists before deciding to follow or adapt it
        action: |
          1. Identify the specific rule line in the knowledge file
          2. Run: bash .tad/hooks/lib/knowledge-blame.sh <file> --search "<rule text snippet>"
             Or: bash .tad/hooks/lib/knowledge-blame.sh <file> --line <N>
          3. Read the COMMIT/DATE/MESSAGE output
          4. Use provenance to make an informed decision:
             - MESSAGE references a specific handoff → check if that handoff's context matches current task
             - DATE is recent (< 30 days) → rule is likely still relevant
             - DATE is old (> 90 days) → consider whether the codebase has changed since
             - AUTHOR is "Sheldon" → human-authored rule, higher weight
             - AUTHOR is agent → machine-derived rule, verify against current state
          5. Document the decision in completion report:
             "Knowledge rule '{rule}' from {date} ({message}): followed / adapted / flagged because {reason}"
        scope: ".tad/project-knowledge/*.md, .claude/skills/*/SKILL.md, and .tad/hooks/lib/*.sh"
        blocking: false
        advisory: true
        relationship_to_stale_check: |
          stale-knowledge-check.sh (Alex step0_5) scans ALL entries for staleness at handoff creation.
          knowledge-blame.sh (this protocol) queries ONE specific rule during implementation.
          They are complementary — Alex catches breadth, Blake investigates depth.

      1_5a_pack_detection:
        description: "Auto-detect and load relevant capability packs based on handoff content"
        action: |
          1. Check handoff for explicit pack references:
             a. Look for "🔧 Domain Pack References" section in handoff
             b. If found: read referenced pack files directly → announce + skip auto-detection
          
          2. If no explicit references (Alex didn't include pack section):
             a. Extract primary file extensions from handoff §6 (Files to Modify):
                - .tsx/.jsx/.css/.scss → keywords: ["frontend", "component", "UI"]
                - .ts/.js (in api/, routes/, server/, services/) → keywords: ["backend", "API"]
                - .py → keywords: ["backend", "agent"]
                - .md (DESIGN.md, design tokens) → keywords: ["UI", "design"]
             b. Read .tad/capability-packs/pack-registry.yaml (or scan .claude/skills/)
                If not found or YAML parse error → skip silently
             c. Match extracted keywords against pack keyword lists
             d. For each matched pack (max 2):
                → Check availability: .claude/skills/{name}/SKILL.md or .tad/capability-packs/{name}/CAPABILITY.md
                → If available: Read SKILL.md/CAPABILITY.md
                → Output: "🎯 Pack loaded: {name} — applying quality rules during implementation"
          
          2.5 Collision check (only if ≥2 packs loaded above):
             → Read .tad/capability-packs/pack-collisions.yaml (if absent or parse error → skip silently)
             → For each row where BOTH pack_a AND pack_b are loaded:
               - resolution: auto → "⚙️ resolved: {winner} over {loser} ({rule}) — {topic}"
               - resolution: escalate → "⚠️ unresolved: {pack_a} vs {pack_b} — human decides ({topic})"
             → Advisory only; does NOT block implementation.
          
          3. If no pack matches: skip silently
          
          → Proceed to 1_5b_notebook_check
        
        blocking: false
        purpose: "Catch packs Alex missed — Blake independently identifies relevant quality rules"
        note: |
          This is INDEPENDENT of Alex's handoff. Even if Alex loaded a pack,
          Blake re-checks because: (a) Alex may have used *express which skips
          step1_5b entirely, (b) Alex's keyword matching may have missed a relevant pack.
          If the same pack was already loaded via handoff's Domain Pack References (step 1),
          don't re-read it.

      1_5b_notebook_check:
        description: "Check for relevant research notebooks before implementation"
        action: |
          0. P1-1 early-exit: Read stored task_type (from 1_5_context_refresh).
             If task_type == "research" → SKIP this step entirely.
             Rationale: 1_5c will run the full research pipeline which includes
             its own notebook queries. Avoids duplicate 23-43s latency.

          1. Read .tad/research-notebooks/REGISTRY.yaml
             If not found → skip silently (no error)

          2. Identify relevant notebook:
             a. Check handoff §5 Research Evidence for explicit notebook_id reference
                → If found: use that notebook_id directly
             b. If no explicit reference: match handoff topic/task against notebook
                `topic` fields using LLM semantic judgment
                → Match if notebook topic clearly covers the implementation domain

          3. If relevant notebook found:
             a. Announce: "📚 Found relevant notebook: '{topic}' ({source_count} sources)"
             b. Run: *research-notebook ask --notebook {notebook_id}
                     "What are the key implementation patterns and constraints for {handoff_task_summary}?"
                (Uses allowed command from notebooklm_access — NOT raw ~/.tad-notebooklm-venv/bin/notebooklm binary.
                 Expect 23-43s latency — acceptable since step is non-blocking.)
             c. Note key findings in context: "📌 Notebook findings: {brief_summary}"
             d. For deeper lookup during implementation: see notebooklm_access.allowed for full
                permitted command list (*research-notebook ask, fulltext, guide, topics, list)

          4. Skip silently when:
             - REGISTRY.yaml not found
             - No notebook matches the handoff topic
             - *research-notebook command unavailable (preflight fail)
             - Notebook query returns error or timeout
        blocking: false
        purpose: "Surface existing research findings before Blake starts coding — avoid re-searching what's already known"

      1_5c_research_task_detection:
        description: "Detect if this handoff's primary deliverable is research, and execute research-methodology pack pipeline"
        action: |
          1. Read handoff frontmatter `task_type` field (already stored from 1_5_context_refresh)

          2. Detection rule (CR-P1-3 fix — strict):
             Trigger IF AND ONLY IF: task_type == "research"
             ⚠️ research_required: yes alone is NOT sufficient — it means "research supports
             the implementation", not "research IS the implementation". Ignore research_required
             for detection purposes. Only task_type: research triggers this path.

          3. If research task detected:
             a. Announce: "🔬 This is a research task. Loading research-methodology capability pack.
                           Entering research-task mode — expanded notebook access active."
             b. Read .tad/capability-packs/research-methodology/CAPABILITY.md
                If NOT found → go to step 5 (fallback)
             c. Execute the pack's 5-phase pipeline (Plan→Source→Curate→Analyze→Output)
                as the PRIMARY implementation workflow — INSTEAD of normal code implementation.
                Pack outputs are the deliverables:
                - .research/report.md (QCE-structured research report)
                - .research/acs.md (extracted ACs from research)
             d. H3 gate quality checks (CR-P0-2 fix — BEFORE presenting to user):
                - Citation count: ≥3 unique sources cited per Claim
                - T1 source ratio: ≥30% of cited sources are T1 (official/academic)
                - Contradictory evidence: every Claim has non-empty contradictory evidence section
                - Extracted ACs: ≥1 concrete AC per research question in the question tree
                If any check fails → note gap and present to user with warning (not blocking)
             e. After pipeline completes, announce:
                "Exiting research-task mode — notebook access reverted to read-only."

          4. If NOT a research task → skip this step entirely, proceed to 1_5d_lsp_blast_radius

          5. Fallback (CAPABILITY.md missing — CR-P1-4 fix):
             Warn: "⚠️ research-methodology pack not installed at .tad/capability-packs/research-methodology/.
                    Falling back to WebSearch-based research."
             Execute WebSearch-based research inline, following the research-methodology
             degraded mode: Plan question tree → Search ≥3 sources per question →
             Curate findings → QCE structure output → Reference .research/report.md

        blocking: true
        purpose: "Enable Blake to execute complete research workflows when research IS the deliverable"

        notebooklm_access_override:
          description: "CR-P0-1 fix: temporarily expands allowed notebook commands during pack execution only"
          rationale: |
            notebooklm_access.forbidden was designed for Blake-as-code-implementer.
            When Blake executes research-methodology pack as primary task, the pack
            requires source management operations (add, research, curate) that are
            normally Alex-only. The override is STRICTLY SCOPED: active only during
            step 3c pipeline execution, reverts to normal forbidden list after pipeline.
          semantics: |
            P0-1 delta formulation (avoids snapshot-drift): During 1_5c pipeline execution,
            the effective allowed set is: base.allowed ∪ pack_required_commands.
            The effective forbidden set is: base.forbidden − pack_required_commands.
            Any command in base.forbidden NOT listed in pack_required_commands remains
            forbidden — INCLUDING any future-added forbidden subcommands. This override
            does NOT enumerate the still-forbidden list (to avoid two diverging sources
            of truth); it defines only the delta (the 4 newly allowed commands).
          pack_required_commands:
            - "*research-notebook research --mode fast/deep"  # Phase 2 SOURCE
            - "*research-notebook add <url>"                  # Phase 2 SOURCE
            - "*research-notebook curate"                     # Phase 3 CURATE
            - "*research-notebook report"                     # Phase 4 ANALYZE baseline
          still_forbidden_notable_examples:
            # Non-exhaustive — for human readability only. The delta semantics above
            # are the authoritative rule; this list does NOT limit the forbidden set.
            - "*research-notebook create"        # notebook must exist before handoff (Alex creates)
            - "*research-notebook configure"     # Alex sets persona/mode
            - "*research-notebook use <id>"      # writes REGISTRY active_notebook — Alex-owned state
            - "*research-notebook language set"  # writes persistent per-notebook config — Alex configures
            - "*research-notebook consolidate, archive, sync"  # Alex lifecycle management
          visibility_mechanism: |
            P1-2 rename: Announcements in step 3a ("Entering research-task mode") and
            step 3e ("Exiting research-task mode") make override scope visible to user.
            Honoring base.forbidden for non-pack commands is Blake's protocol responsibility
            (text-level discipline, consistent with TAD's single-user CLI alignment model).

        completion_report_requirements:
          description: "AC9: completion report references pack outputs as evidence"
          items:
            - "Reference .research/report.md in evidence list"
            - "Reference .research/acs.md in evidence list"
            - "Note which pack phases completed successfully"

        constraints:
          - "Blake executes the pack pipeline but does NOT modify the pack CAPABILITY.md itself"
          - "notebooklm_access_override applies ONLY during 1_5c pipeline execution"
          - "After pack pipeline completes, Blake writes normal completion report"

      # ──────────────────────────────────────────────────────────
      # 1_5d: LSP Blast Radius Check
      # ──────────────────────────────────────────────────────────
      1_5d_lsp_blast_radius:
        name: "LSP Blast Radius Check"
        trigger: "After 1_5c_research_task_detection, before 1_6_tdd_check"
        prerequisite: "lsp_provision_protocol completed (see Alex SKILL lsp_provision_protocol)"

        action: |
          1. Follow lsp_provision_protocol per Alex SKILL §lsp_provision_protocol
             (detect → try → install → fallback). If LSP available → continue.
             If not → skip this step silently.

          2. For each file in handoff §6 marked as MODIFY:
             a. Run LSP documentSymbol (line=1, character=1) → exported symbols
             b. For key symbols (functions/classes with >0 callers likely):
                Extract the symbol's line and character position from the documentSymbol result,
                then run LSP incomingCalls with those coordinates → caller list
             c. Output blast radius summary:
                "🔍 Blast radius for {file}:
                 - {symbol}: {N} callers in {M} files
                 - {symbol}: {N} callers in {M} files"
             d. If ANY caller is NOT in handoff §6:
                Output: "⚠️ {caller_file}:{caller_func} calls {symbol} but is not in handoff scope.
                Verify this caller won't break after the change."

          3. This is INFORMATIONAL — does NOT block implementation.
             Blake uses judgment on whether to also update the unlisted callers.

        skip_if:
          - "LSP not available (provision failed) → skip silently"
          - "All files in §6 are new (create, not modify)"
          - "task_type is doc-only, yaml, or research"

        compact_recovery: "Step produces no persistent state. Safe to skip after compact."

        forbidden_implementations:
          <!-- Claude Code: .claude/settings.json hooks / Codex: .codex/hooks.json -->
          - "MUST NOT register as PreToolUse hook in .claude/settings.json"
          - "MUST NOT block implementation based on blast radius findings"
          - "MUST NOT auto-expand handoff §6 (informational only — Alex owns scope)"

      1_6_tdd_check:
        description: "Check if TDD mode is enabled and set implementation guidance"
        action: |
          1. Read .tad/config.yaml → check optional_features.tdd_enforcement.enabled
             (If config is malformed or field missing → treat as disabled, log warning)
          2. If false → skip, proceed to normal implementation (no change to existing flow)
          3. If true:
             a. Read .tad/skills/tdd-enforcement/SKILL.md
             b. Announce: "TDD mode enabled. Following RED-GREEN-REFACTOR cycle."
             c. Set TDD guidance flag — Blake's IMPLEMENTATION phase (between 1_6 and 2_layer1)
                follows RED-GREEN-REFACTOR per task/AC:
                - RED: Write failing test first
                - GREEN: Write minimum code to pass
                - REFACTOR: Clean up, commit
             d. Layer 1 then runs as normal VALIDATION (build/test/lint/tsc on all code)
        interaction_with_layer1: |
          TDD mode does NOT replace Layer 1. It changes HOW Blake writes code (test-first),
          but Layer 1 still runs all checks as validation. The difference:
          - Without TDD: Blake implements freely → Layer 1 catches issues
          - With TDD: Blake implements test-first → Layer 1 validates (usually passes on first try)
        optional: true
        skip_if: "tdd_enforcement.enabled == false or field not found"

      1_7_worktree_setup:
        description: "Optional: create git worktree for isolated implementation"
        trigger: "*develop --worktree [task-id]"
        action: |
          1. Only runs if --worktree flag is present. Skip otherwise.
          2. Derive branch name: tad/{task-id} (e.g., tad/TASK-20260323-006)
          3. Create worktree:
             git worktree add .worktrees/tad-{task-id} -b tad/{task-id}
          4. Ensure .worktrees/ is in .gitignore (add if missing — check root .gitignore)
          5. Announce: "Worktree created at .worktrees/tad-{task-id} on branch tad/{task-id}"
          6. All subsequent implementation happens in the worktree directory
          Edge cases:
            - If branch tad/{task-id} already exists → ask user: reuse or rename
            - If not a git repo → skip with warning
        skip_if: "--worktree flag not present"
        # NOTE: When worktree active, ALL steps run INSIDE .worktrees/tad-{task-id}/ directory.

      1_8_optimization_check:
        description: "Detect optimization_target in handoff"
        action: |
          1. Read handoff Section 3 (Requirements)
          2. Search for `optimization_target:` block
          3. If NOT found → skip to IMPLEMENTATION (existing flow, no change)
          4. If found:
             a. Read config.yaml → check optional_features.autoresearch_mode.enabled
             b. If disabled → skip with note: "Optimization target found but autoresearch_mode disabled in config"
             c. If enabled → parse optimization_target fields
             d. Validate required fields: metric, baseline, target, direction, benchmark_cmd, metric_pattern, scope
             e. If validation fails → WARN, skip to IMPLEMENTATION
             f. If valid → proceed to 1_9_optimization_loop
        skip_if: "No optimization_target in handoff"

      1_9_optimization_loop:
        description: "Autoresearch-style optimization loop (Layer 0.5)"
        prerequisite: "1_8_optimization_check found valid optimization_target"
        action: |
          ## Setup
          1. Read .tad/templates/optimization-program.md for strategy guidance
          2. Create results dir + file: `mkdir -p .tad/evidence/optimization-runs/`
             Create: .tad/evidence/optimization-runs/{task_id}_results.tsv
             Header: iteration\tcommit\tmetric_value\tstatus\tdescription\ttimestamp
          3. **Safety anchor**: Ensure working tree is clean (`git status --porcelain` = empty).
             If dirty → commit existing changes first: `git add -A && git commit -m "pre-optimization baseline"`
             Then tag: `git tag tad-opt-baseline-{task_id}`
             This tag is the "never reset past" boundary.
          4. Run baseline benchmark: execute benchmark_cmd, extract metric via metric_pattern
             If baseline doesn't match handoff's declared baseline → WARN but continue
          5. Set best_value = baseline_value
          6. Announce: "Entering optimization loop. Target: {metric} from {baseline} to {target} ({direction}). Max {max_iterations} iterations. Safety anchor: tad-opt-baseline-{task_id}"

          ## Loop (max_iterations)
          For each iteration:
            a. **Hypothesize**: Based on scope files, previous results, and constraints,
               decide what code change to try. Document reasoning briefly.
            b. **Modify**: Edit file(s) within scope ONLY.
               Respect constraints from optimization_target.
            c. **Scope verify**: Run `git diff --name-only` and check that ALL changed files
               are in the optimization_target.scope list. If any file outside scope was modified:
               → `git checkout -- {out_of_scope_files}` to discard those changes
               → If scope files were also changed, proceed. If not, treat as failed iteration.
            d. **Commit**: `git add {scope_files} && git commit -m "opt-{iteration}: {description}"`
            e. **Benchmark**: Run benchmark_cmd using Bash tool with timeout: time_budget * 1000 ms.
               If timeout → treat as failure, log as "timeout".
               If crash → treat as failure, log as "crash".
               After benchmark: `git checkout -- {scope_files}` to discard any benchmark side effects.
            f. **Extract**: Match benchmark output against metric_pattern regex.
               Parse first capture group as numeric value.
               If can't parse → treat as failure, log as "parse_error".
            g. **Compare**:
               - direction="lower": improved if new_value < best_value
               - direction="higher": improved if new_value > best_value
            h. **Decide**:
               - If improved: KEEP commit. Update best_value. Log status="✓" to results.tsv.
               - If not improved: `git reset --hard HEAD~1`. Log status="✗" to results.tsv.
                 Guard: NEVER reset past tad-opt-baseline-{task_id} tag.
               - If target reached (value meets or exceeds target): Log status="✓ TARGET". Exit loop.
            i. **Constraint check** (on keep only): Before finalizing a kept commit, verify
               constraints from optimization_target.constraints are not violated.
               If violated → treat as not-improved, revert, log status="✗ constraint".
            j. **Circuit breaker**: If 5 consecutive non-improvement (✗, timeout, crash, parse_error, ✗ constraint)
               → exit loop with note "plateau reached"

          ## Post-Loop
          1. **Squash optimization commits**: Squash all kept optimization commits since
             tad-opt-baseline-{task_id} into a single commit:
             `git reset --soft tad-opt-baseline-{task_id} && git commit -m "opt: {metric} improved {baseline} → {best_value}"`
             This keeps branch history clean for merge/PR.
          2. Remove baseline tag: `git tag -d tad-opt-baseline-{task_id}`
          3. Output summary:
             "Optimization complete: {iterations_run} iterations, {kept_count} kept.
              Metric: {baseline} → {best_value} (target: {target})
              Status: {TARGET_REACHED / PLATEAU / MAX_ITERATIONS}"
          4. If other implementation tasks remain in handoff → continue to IMPLEMENTATION
          5. Proceed to 2_layer1_loop (standard Layer 1 checks on optimized code)

        circuit_breaker:
          consecutive_no_improvement: 5
          action: "Exit optimization loop, proceed to Layer 1 with best result so far"

        constraints:
          - "Only modify files listed in optimization_target.scope (enforced by scope verify step)"
          - "Respect all items in optimization_target.constraints (enforced by constraint check step)"
          - "Prefer one conceptual change per iteration for clear attribution. Multiple small coupled changes acceptable."
          - "Document reasoning for each change in commit message"

        mode_interactions:
          agent_team: |
            If optimization_target is present, Agent Team mode is DISABLED for this handoff.
            Optimization requires sequential git state management (commit/reset) that is
            incompatible with parallel file ownership.
          tdd: |
            If both tdd_enforcement and autoresearch_mode are enabled:
            - Autoresearch mode takes precedence for optimization_target.scope files
            - TDD applies to remaining implementation tasks (if any) outside scope
            - Rationale: optimization loop measures via benchmark_cmd, not test suite

      2_layer1_loop:
        description: "Self-Check Loop (max 15 retries)"
        commands:
          - "npm run build"
          - "npm test"
          - "npm run lint"
          - "npx tsc --noEmit"
        on_failure:
          - "Increment layer1_retries"
          - "Check circuit breaker (same error 3x → escalate)"
          - "Fix error and retry"
          - "Advisory: if this retry was caused by following a .tad/project-knowledge/ rule, consider running knowledge-blame.sh to check the rule's provenance before the next attempt (see 1_5_knowledge_provenance)"
        on_success:
          - "Checkpoint state"
          - "Proceed to Layer 2"

      3_layer2_loop:
        description: "Expert Review Loop (max 5 rounds)"
        # ⚠️ ANTI-RATIONALIZATION: "已经跑过 npm test 全部通过，再调 subagent 是重复劳动"
        # → Layer 1 的 npm test 只检查是否通过。test-runner subagent 额外检查覆盖率和测试质量。两者目的不同。
        # ⚠️ express-not-exempt rule (Phase 3 anchor B-03, per AR-001/AR-003):
        # Express handoffs, spike handoffs, and infra/tooling handoffs are NOT review-exempt.
        # They may justify skipping e2e_test, but MUST call ≥1 expert (≥2 for security-adjacent).
        # Rationale: 2026-04-14 plain-language express handoff — expert review caught 4 P0 that
        # would have shipped broken. Small-edit ≠ low-risk when it changes a protocol contract.
        priority_groups:
          group0:
            name: "Spec Compliance Gate"
            parallel: false
            experts:
              - subagent: "spec-compliance-reviewer"
                pass_criteria: "NOT_SATISFIED=0, PARTIALLY_SATISFIED≤3"
                blocking: true
          group1:
            name: "Code Quality Gate"
            parallel: false
            experts:
              - subagent: "code-reviewer"
                pass_criteria: "P0=0, P1=0, P2≤10"
                blocking: true
          group2:
            name: "Verification Experts"
            parallel: true
            experts:
              - subagent: "test-runner"
                pass_criteria: "100% pass, 70% coverage"
                blocking: true
              - subagent: "security-auditor"
                trigger: "auth|token|password|credential|api.*key|encrypt"
                pass_criteria: "critical=0, high=0"
                blocking: false
              - subagent: "performance-optimizer"
                trigger: "database|query|cache|batch|loop|sort"
                pass_criteria: "no blocking patterns"
                blocking: false
        on_failure:
          - "Increment layer2_rounds"
          - "Check escalation threshold (same category 3x → escalate to Alex)"
          - "Fix issues and restart from Layer 1"
        on_success:
          - "Checkpoint state"
          - "Proceed to Gate 3 v2"

      4_gate3_v2:
        description: "Expanded Gate 3 (Implementation & Integration)"
        items:
          - "All Layer 1 checks passing"
          - "All Layer 2 experts passed"
          - "Evidence files created"
          - "Knowledge Assessment completed"
          - "Implementation changes committed to git (step3c)"

      5_worktree_finish:
        description: "Worktree finishing workflow — only runs if worktree was created"
        trigger: "After 4_gate3_v2 completes, if worktree is active"
        action: |
          Only runs if 1_7_worktree_setup was executed. Skip otherwise.

          Use AskUserQuestion:
          question: "Implementation complete in worktree. How to proceed?"
          options:
            - "Merge to {original_branch}" → cd to original repo, git merge tad/{task-id}, cleanup
            - "Create PR" → git push -u origin tad/{task-id}, suggest gh pr create
            - "Keep worktree" → leave as-is for manual review
            - "Discard" → cleanup worktree and delete branch

          Cleanup (for merge and discard):
            git worktree remove .worktrees/tad-{task-id}
            git branch -d tad/{task-id}  # -d (safe delete) for merge, -D (force) for discard

          Edge cases:
            - If merge conflicts → PAUSE, ask user to resolve manually
        skip_if: "no worktree active"

  # Circuit Breaker Logic
  circuit_breaker:
    trigger: "consecutive_same_error >= 3"
    detection:
      - "Compare error message hash with previous"
      - "Track error category (build/test/lint/type)"
    action: "escalate_to_human"
    message: |
      ⚠️ CIRCUIT BREAKER TRIGGERED

      Same error occurred {count} times.
      Error category: {category}
      Last error: {message}

      ⚡ Reflexion History:
      {for each reflection in reflection_history:}
        Attempt {N}: {what_failed}
          Hypothesis: {root_cause_hypothesis}
          Tried: {revised_approach}
          Confidence: {confidence}
          Result: Still failing

      Blake assessment: {design_issue | environment_issue | unknown}
      Recommendation: {escalate to Alex for redesign | human fix environment | need more context}
      Human intervention required.

  # Escalation Logic
  escalation:
    trigger: "same_category_failures >= 3 in Layer 2"
    detection:
      - "Track which expert is failing"
      - "Group failures by root cause category"
    action: "escalate_to_alex"
    message: |
      ⚠️ ESCALATION TO ALEX
      Layer 2 repeatedly failing on: {category}
      Failed {count} rounds on same issue type.
      Returning to Alex for re-design.
      Evidence: {evidence_path}

  # State Persistence
  state_management:
    file: ".tad/evidence/ralph-loops/{task_id}_state.yaml"
    checkpoint_points:
      - "After Layer 1 success"
      - "After each Layer 2 round"
      - "On any error"
    recovery:
      stale_check: "If state > 30 min old, ask user: resume or fresh?"
      resume_action: "continue_from_last_checkpoint"
      fresh_action: "reset state and start from Layer 1"

  # Session State for Compact Recovery (v2.8.5)
  session_state_protocol:
    description: "人类可读的 session 状态快照，用于 compact 后恢复身份 + 任务进度"
    file: ".tad/active/session-state.md"
    template: ".tad/templates/session-state-template.md"

    stale_detection: |
      读取 session-state.md 时先检查：
      1. Status 字段 != ACTIVE → 不 resume（旧 handoff 已完成）
      2. Status = ACTIVE 但 Active Task.Handoff 路径文件不存在（已归档） → 视为 stale，忽略
      3. Status = ACTIVE 且 handoff 文件存在 → 正常 resume

    write_triggers:
      - "develop_command.1_init — 启动时从模板创建，Status=ACTIVE"
      - "After Layer 1 ALL PASS — 更新 Current Position + Status=ACTIVE"
      - "After each Layer 2 round — 更新 Completed + Current Position"
      - "completion_protocol 写完 COMPLETION 报告后 — Status=COMPLETE（必须）"

    compact_recovery_self_check: |
      ⚠️ 每次回复前自检：我知道当前 handoff 的完整文件路径吗？
      如果 NO：
        1. Read .tad/active/session-state.md
        2. 检查 Status = ACTIVE 且 handoff 路径文件存在（stale_detection）
        3. Re-run /blake to reload full SKILL
        4. Resume from Current Position

