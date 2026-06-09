# Experiment Path Protocol (extracted from SKILL.md for progressive loading)
# Source: .claude/skills/alex/SKILL.md
# Extracted: 2026-06-08 (EPIC-20260608-skill-progressive-loading Phase 2)

experiment_path_protocol:
  description: "For OPRO / A-B test / benchmark / prompt tuning / eval-loop tasks. Gates ADD experiment-validity checks; original Gate 3 still applies to harness code."

  trigger:
    type: "user_explicit_OR_frontmatter"
    activation_word: "*experiment"
    frontmatter_field: "task_type=experiment"
    note: |
      User can say *experiment to enter (via existing step1 explicit-command bypass).
      OR Alex during *analyze can set task_type=experiment based on signals (then path is
      Standard *analyze with experiment_specific_gates AUGMENTING Gate 3/4 criteria).
    auto_detection_signals:
      - "task involves OPRO / A-B / benchmark / eval-loop"
      - "comparing prompts/models/configs and measuring against rubric"
      - "iteratively tuning generator/optimizer/judge model"

  alex_evaluation_signals:
    when_to_suggest_task_type_experiment:
      - "Socratic answers mention 'iteratively', 'rubric', 'A vs B', 'optimize prompt', 'eval against baseline'"
      - "Domain Pack ai-evaluation or ai-prompt-engineering matches"
      - "Output measured by score not by 'feature works'"
    note: |
      Alex MAY set task_type=experiment in frontmatter during *analyze drafting.
      Alex MUST NOT bypass *analyze and route directly to *experiment without user explicit input.

  domain_pack_auto_load:
    rule: "experiment_path_protocol step1 MUST Read .claude/skills/ai-evaluation/SKILL.md at start of drafting"
    rationale: |
      *experiment is a router mode — the Capability Pack must be explicitly loaded.
      Without this explicit Read, *experiment users get workflow without quality rules.
    fallback: |
      If ai-evaluation.yaml missing → emit WARN
      "ai-evaluation pack not found; experiment_path_protocol will use default workflow only"
      and continue (do not block).
    on_load_announcement: |
      Alex MUST output the literal string "Loaded Domain Pack: ai-evaluation"
      (or "ai-evaluation pack not found" on fallback) so AC-P3.2-i fixture
      can grep the announcement.

  required_steps:
    # P1-3 (CR review 2026-04-24): list ALL Standard TAD steps explicitly to mirror
    # express_path_protocol.required_steps. Avoids the "Standard TAD steps DO follow"
    # shorthand letting a future Alex skip Gate 2 / step7 / Gate 3 / Gate 4.
    - "Socratic Inquiry Protocol (3-5 rounds) — DO follow"
    - "step0_5 Risk Translation (cognitive firewall) — DO follow"
    - "step1 draft creation (handoff scaffold + frontmatter)"
    - "step1 explicit Read of .claude/skills/ai-evaluation/SKILL.md (per domain_pack_auto_load)"
    - "step1 §6 may be 'Experiment Setup' (rubric / fixture / generator-judge config) instead of 'Files to Modify'"
    - "step1b frontmatter validation (含 git_tracked_dirs)"
    - "step1c grounding pass (P2.2 — Read 目标文件 head 50)"
    - "step2 expert review — recommend security-auditor SKIP unless safety-critical (toy OPRO 非 safety); add product-expert IF stakeholder validation matters"
    - "step4 Audit Trail integration (P1.5 — record reviewer findings)"
    - "step5 Gate 2 check (Design Completeness)"
    - "step7 Blake message generation with 人话版"
    - "Gate 3 v2 (Blake side: build/test/lint on harness AUGMENTED with 5 experiment-validity checks)"
    - "Gate 4 v2 acceptance (Alex side: business AC AUGMENTED with 4 experiment outcome checks)"

  experiment_specific_gates:
    gate3_focus_AUGMENTATION:
      # ⚠️ AUGMENT not REPLACE (BA-P0-2 critical fix).
      # Original Gate 3 v2 still applies to any harness code.
      semantics: |
        Original Gate 3 v2 (build / test / lint / coverage) STILL APPLIES to any
        harness/runner code in the experiment. The following 5 checks are ADDITIONAL —
        BOTH layers must PASS. A harness syntax error → Gate 3 FAIL even if all 5
        experiment checks pass (verified by AC-P3.2-h fixture).
      additional_checks:
        - "1. Control variables clear (which model is generator? judge? optimizer? all 3 different or some shared?)"
        - "2. Self-enhancement bias mitigated (judge ≠ optimizer; or documented as accepted limitation with rationale)"
        - "3. Baseline established (what's the 'before optimization' score; how was it measured)"
        - "4. Reproducibility (rubric saved, fixtures saved, hyperparams saved)"
        - "5. Generator model = production model (toy OPRO 教训: 别在 Qwen Plus 上调出 prompt 然后部署到 qwen3-omni-flash)"

    gate4_focus_AUGMENTATION:
      # ⚠️ AUGMENT not REPLACE.
      semantics: |
        Original Gate 4 v2 (user-facing behavior + business AC) STILL APPLIES.
        The following 4 checks are ADDITIONAL — BOTH layers must PASS.
      additional_checks:
        - "1. Score improvement statistically meaningful (not within noise)"
        - "2. Improvement transfers to production model (re-eval on production model if generator differed)"
        - "3. No regression on holdout / negative test cases"
        - "4. Discoveries (positive findings + anti-patterns) captured in knowledge_updates"

  required_evidence_manifest_template:
    experiment_design: ".tad/evidence/experiments/{slug}/experiment-design.md"
    rubric: ".tad/evidence/experiments/{slug}/rubric.yaml"
    raw_results: ".tad/evidence/experiments/{slug}/results.tsv"
    analysis: ".tad/evidence/experiments/{slug}/analysis.md"
    baseline: ".tad/evidence/experiments/{slug}/baseline.txt"
    production_validation:
      path: ".tad/evidence/experiments/{slug}/production-validation.txt"
      conditional: |
        REQUIRED IF gate3_focus_AUGMENTATION check #5 detects generator≠production model
        mismatch; OPTIONAL otherwise.

  domain_pack_integration:
    pack: "ai-evaluation"
    pack_path: ".claude/skills/ai-evaluation/SKILL.md"
    relationship: |
      Pack is tool/framework recommendations (promptfoo / DSPy / trulens).
      experiment_path_protocol is the workflow + Gate semantics.
      Loaded explicitly via domain_pack_auto_load (above) at protocol entry.

  enforcement: "prompt-level-only"  # See constraints.enforcement (global)
  # Mechanical deny migrated to frontmatter constraints.deny (global) + section_overrides.experiment_path
  forbidden_implementations:
    - "MUST NOT replace Gate 3/4 silently — semantics is AUGMENT (additive), original criteria still apply"
    - "MUST NOT bypass *analyze Socratic for *experiment — all Standard TAD steps DO run"

