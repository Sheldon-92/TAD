# Intent Router Protocol (extracted from SKILL.md for progressive loading)
# Source: .claude/skills/alex/SKILL.md
# Extracted: 2026-06-08 (EPIC-20260608-skill-progressive-loading Phase 2)

intent_router_protocol:
  description: "Detect user intent and route to appropriate path before any other processing"
  trigger: "User describes a task or need (before adaptive_complexity_protocol)"
  blocking: true
  prerequisite: "Activation protocol complete (STEP 1-4)"

  execution:
    step1:
      name: "Check Explicit Command"
      action: |
        If user input starts with *bug, *discuss, *idea, *learn, *express, *experiment, or *analyze:
          → Skip detection, go directly to the corresponding path
          → For *analyze: proceed to adaptive_complexity_protocol (existing flow)
          → For *express: enter express_path_protocol (Phase 3 P3.1)
          → For *experiment: enter experiment_path_protocol (Phase 3 P3.2)
          → No new step3 special case — *express / *experiment reuse the same explicit-command
            bypass mechanism as *bug / *discuss / *idea / *learn (step3 is skipped automatically
            because step1 routes directly to step4).

    step1_5:
      name: "Idle Detection"
      action: |
        Before running signal word analysis, check if user input is a non-task message:

        Idle patterns (not exhaustive, use judgment):
        - zh: ["谢谢", "ok", "好的", "收到", "明白了", "嗯", "知道了", "没问题"]
        - en: ["thanks", "ok", "got it", "sure", "cool", "noted", "understood"]

        If input matches idle pattern (short message, no task content):
          → Respond briefly and naturally (e.g., "好的！有新任务随时告诉我。")
          → Stay in standby — do NOT proceed to step2
          → Do NOT trigger AskUserQuestion

        If input has task content beyond idle words:
          → Proceed to step2 (signal word analysis)

    step2:
      name: "Signal Detection (no explicit command)"
      action: |
        Read intent_modes from config-workflow.yaml.
        Scan user input for signal_words across all modes.
        Count matches per mode.
        Pre-select the mode with highest signal count (if >= signal_confidence_threshold from config).
        If multiple modes tie: read priority_order from intent_modes.detection in config-workflow.yaml (bug > idea > discuss > learn > analyze).
        If no mode reaches threshold → pre-select "analyze" (standard TAD).

    step3:
      name: "User Confirmation (ALWAYS — only triggers when input is ambiguous text, not explicit command)"
      action: |
        Use AskUserQuestion to confirm detected intent.

        # Phase 3 P3.1 (BA-P0-1, 2026-04-24): 7-mode display strategy with 4-option overflow
        # Modes available: bug / idea / discuss / learn / experiment / express / analyze
        # AskUserQuestion hard cap: 4 options.
        7-mode display strategy:
        1. Option 1: {detected_mode} (Recommended) — always first
           ⚠️ EXCEPTION (BA-P1-2 + AR-001 letter-not-spirit defense):
              *express MUST NOT appear as Option 1 (Recommended) even if signal-word
              detection favors it. If signals suggest express, classify as analyze with
              note "looks small — start *analyze; user can downgrade by typing *express".
              Reason: prevents Alex from auto-downgrading scope to fit *express
              (anti_rationalization_registry AR-001 attack surface).
        2. Options 2-3: next 2 modes by signal match count (descending)
        3. Option 4: analyze — ALWAYS included as fallback/default (always 4th position)
        4. Drop: modes with lower signal match (>4 candidates → tiebreak by priority_order)

        Tiebreaker (when >4 candidate modes):
          Read priority_order from .tad/config-workflow.yaml → intent_modes.detection.priority_order:
            bug > idea > experiment > express > discuss > learn > analyze
          Pick top 3 non-analyze modes by (signal_count desc, priority_order asc).
          analyze always occupies position 4.

        Exception: if detected_mode IS analyze, show analyze as recommended (Option 1)
        and fill options 2-4 with the 3 modes that had highest signal counts (subject
        to *express never-Recommended rule above).

        AskUserQuestion({
          questions: [{
            question: "我判断这是一个 {detected_mode_label} 场景。你想怎么处理？",
            header: "Intent",
            options: [
              {label: "{detected_mode} (Recommended)", description: "{mode_description}"},
              {label: "{2nd_mode}", description: "{description}"},
              {label: "{3rd_mode}", description: "{description}"},
              {label: "analyze", description: "Standard TAD workflow (fallback)"}
            ],
            multiSelect: false
          }]
        })

        Note: User can always type *express / *experiment / *learn (or any mode)
        directly via "Other" if their desired mode was dropped from the 4 options.

    step4:
      name: "Route"
      action: |
        Based on user's choice:
        - bug → Enter bug_path_protocol
        - discuss → Enter discuss_path_protocol
        - idea → Enter idea_path_protocol
        - learn → Enter learn_path_protocol
        - express → Enter express_path_protocol (Phase 3 P3.1)
        - experiment → Enter experiment_path_protocol (Phase 3 P3.2)
        - analyze → Enter adaptive_complexity_protocol (existing, unchanged)
        
        NOTE: Entering any *_path_protocol whose body is a `reference:` stub (P3 progressive disclosure)
        means: Read that reference file first, then follow it verbatim.
        
        → After routing decision, execute step4_5 (Pack Awareness Scan) before entering the path protocol

    step4_5:
      name: "Pack Awareness Scan"
      trigger: "After intent router resolves (step4), before entering the specific path"
      action: |
        1. Check if .tad/capability-packs/pack-registry.yaml exists
           → If not: skip silently (no packs registered)
        
        2. Read pack-registry.yaml → extract all pack entries with keywords
        
        3. For each pack, determine availability (same 3-tier as step1_5b):
           Tier 1: .tad/capability-packs/{name}/CAPABILITY.md exists → available
           Tier 2: .claude/skills/{name}/SKILL.md exists → available
           Tier 3: neither → not installed, skip (don't offer install here — not the right moment)
        
        4. Match user input keywords against available packs' keywords lists
           (LLM semantic match, same mechanism as step1_5b)
        
        5. If ≥1 pack matches:
           → Read matched pack(s) SKILL.md (Tier 2) or CAPABILITY.md (Tier 1)
           → Output: "🎯 Pack loaded: {name} — {one-line description}"
           → Pack content is now in context for the entire path execution
        
        5b. Collision check (only if ≥2 packs were loaded in step 5):
           → Read .tad/capability-packs/pack-collisions.yaml (if absent or parse error → skip silently)
           → For each collision row where BOTH pack_a AND pack_b are in the loaded set:
             - resolution: auto → "⚙️ resolved: {winner} over {loser} ({rule}) — {topic}. loser said: \"{loser quote}\" (verify it isn't independently violated)"
             - resolution: escalate → "⚠️ unresolved: {pack_a} vs {pack_b} — human decides ({topic}); full quotes in pack-collisions.yaml"
           → Advisory surfacing ONLY — does NOT block, does NOT auto-edit packs, does NOT change which packs loaded.
        
        6. If no match: skip silently (no output)
      
      applies_to: "All user-task modes: *analyze, *express, *bug, *discuss, *learn, *experiment"
      skip_if:
        - "pack-registry.yaml not found or YAML parse error (WARN + skip)"
        - "No available packs (all Tier 3)"
        - "Framework management commands: *publish, *sync, *sync-add, *sync-list, *status, *dream, *optimize, *evolve, *idea-list, *idea-promote, *research-review, *research-plan, *test-review, *cancel"
      
      max_packs: 2  # Load at most 2 packs per session (context budget)
      ranking_when_over_limit: |
        If >2 packs match, select 2 with highest keyword overlap count.
        Break ties by pack order in pack-registry.yaml (earlier = higher priority).
      
      does_NOT_write_to_handoff: |
        step4_5 loads pack into conversation context only — it does NOT inject
        the "🔧 Domain Pack References" section into the handoff. That remains
        step1_5b's responsibility during *design. Blake's 1_5a independently
        re-detects packs, so Alex and Blake may load different packs for the
        same task. This is intentional — Blake catches what Alex missed.
      note: |
        This does NOT replace step1_5b in *design — step1_5b has the full
        confirmation flow (AskUserQuestion, CONSUMES/PRODUCES chain, install offer).
        step4_5 is lightweight and silent — no user interaction.
        If step4_5 already loaded a pack, step1_5b should detect it and skip re-loading.

  # Standby State Definition (P1 fix from Phase 1)
  standby:
    definition: |
      "Alex standby" means:
      1. Current path context is cleared (no active *bug/*discuss/*idea/*learn/*analyze)
      2. Session remains active (Alex persona still loaded)
      3. Any new user input triggers Intent Router fresh (step1: check explicit command)
      4. No state carries over from previous path except conversation history

    enters_standby:
      - "After *bug step5_record completes → Enter standby"
      - "After *discuss exit_protocol: user selects 'No need to record' → Enter standby"
      - "After *discuss exit_protocol: user selects 'Record conclusions to NEXT.md' (after recording) → Enter standby"
      - "After *idea step4: user selects 'Done, back to standby' → Enter standby"
      - "After *learn step4: user selects 'Done, back to standby' → Enter standby"
      - "After *express completes Gate 4 accept → Enter standby"
      - "After *experiment completes Gate 4 accept → Enter standby"
      - "After *analyze handoff step7 completes → Enter standby"
      - "After any path transition fails or is cancelled → Enter standby"
      - "After *idea-promote step2: user selects 'Cancel' → Enter standby"
      - "After *idea-promote step1: no promotable ideas → Enter standby"
      - "After *status step3 completes → Enter standby"
      - "After *research-review step3 completes (user selects 'only look, no action') → Enter standby"
      - "After *research-review step4 operations complete → Enter standby"
      - "After *research-plan step5 completes → Enter standby"
      - "After *publish step5 completes → Enter standby"
      - "After *sync step4 completes → Enter standby"
      - "After *sync-add step3 completes → Enter standby"
      - "After *sync-list step1 completes → Enter standby"
      - "After *dream completes (promote/skip) → Enter standby"

    on_new_input_in_standby: |
      When user sends a new message while Alex is in standby:
      → Run Intent Router from step1 (full detection cycle, including step1.5 idle check)
      → step4_5 (Pack Awareness Scan) re-runs on each new input since packs may be relevant to the new task
      → This is AUTOMATIC — no need for user to say "start over" or re-invoke /alex
      → Idle messages (step1.5) get brief response without triggering full routing

  trigger_timing: |
    Intent Router activates on the FIRST user message AFTER on_start greeting completes.
    - on_start greeting is STEP 4 of Activation Protocol
    - Intent Router is STEP 5 (new) — runs when user describes a task/need
    - If user sends *analyze explicitly, Intent Router still runs but skips to step4 immediately

  path_transitions:
    description: "Rules for switching between paths mid-session (Phase 3 P3.1 BA-P1-1, 2026-04-24: complete matrix)"
    allowed:
      - from: "discuss"
        to: "analyze"
        trigger: "User says 'this needs proper design' or selects *analyze from exit options"
      - from: "discuss"
        to: "idea"
        trigger: "User says 'capture this as an idea' or selects *idea from exit options"
      - from: "bug"
        to: "analyze"
        trigger: "Bug diagnosis reveals need for larger architectural change"
      - from: "idea"
        to: "analyze"
        trigger: "User says 'I want to do this now' from step4 options"
      - from: "learn"
        to: "analyze"
        trigger: "User says 'Back to work — start *analyze' from step4 options"
      - from: "idea-promote"
        to: "analyze"
        trigger: "Automatic after idea status updated to 'promoted' (step4)"
      # Phase 3 P3.1 (2026-04-24): 3 new allowed transitions for *express / *experiment
      - from: "express"
        to: "analyze"
        trigger: "User says 'this turned out bigger than I thought' — *express scope insufficient for the actual work"
      - from: "express"
        to: "experiment"
        trigger: "User realizes the bugfix is actually an A/B test (e.g., 'I want to compare two approaches')"
      - from: "experiment"
        to: "analyze"
        trigger: "Experiment results show this needs production design — promote findings into Standard TAD handoff"
    forbidden:
      - from: "analyze"
        to: "any"
        reason: "Once in standard TAD flow (Socratic/Design/Handoff), switching out would lose context. Complete or abort first."
      # Phase 3 P3.1 (2026-04-24): explicit forbidden for analyze→express / analyze→experiment
      # Even though "any" already covers these, AC-P3.1-l requires explicit declaration
      # to defend against AR-001 mid-flight scope downgrade attack.
      - from: "analyze"
        to: "express"
        reason: |
          Once in Standard TAD with Socratic complete, downgrading to *express loses ceremony
          rationale (AR-001 attack surface — Alex auto-rationalizing 'this turned out small,
          let's downgrade'). User must explicitly *cancel current *analyze handoff and start
          a fresh *express if scope truly shrunk.
      - from: "analyze"
        to: "experiment"
        reason: |
          Same — analyze→experiment would hide a scope shift mid-flight. User must explicitly
          *cancel current *analyze and start a fresh *experiment if the work turned out to be
          an A/B test.
      - from: "any"
        to: "any (other than listed allowed)"
        reason: "Default deny — only the explicitly listed allowed transitions are permitted."
    mechanism: |
      Path transitions use AskUserQuestion to confirm.
      On transition, Alex announces: "Switching from {from_mode} to {to_mode}."
      No state from the previous path carries over except conversation context.

