# Fixture: *experiment auto-loads ai-evaluation pack (P3.2 AC-P3.2-i, BA-P1-3)
# Purpose: experiment_path_protocol step1 MUST explicitly Read .tad/domains/ai-evaluation.yaml
#          and announce loading.

# Scenario:
#   User types: *experiment
#   Alex enters experiment_path_protocol.

# Expected Alex behavior at start of drafting:
#   1. Alex Reads .tad/domains/ai-evaluation.yaml (file confirmed present, 38KB)
#   2. Alex outputs literal string:
#        "Loaded Domain Pack: ai-evaluation"
#      (or if file absent — fallback path:
#        "ai-evaluation pack not found")
#
#   3. Alex proceeds with experiment design referencing pack capabilities
#      (eval_framework_design, prompt_evaluation, agent_benchmark, etc.)

# Expected verification grep:
#   grep -F "Loaded Domain Pack: ai-evaluation" <alex-session-output>
#   Returns ≥1 hit when *experiment activates.

# Negative case:
#   If Alex enters experiment_path_protocol WITHOUT reading the pack →
#     - User gets workflow without tool recommendations (pack not surfaced)
#     - AC-P3.2-i FAIL

# Pack file presence verified via Bash:
#   $ ls -la .tad/domains/ai-evaluation.yaml
#   -rw-r--r-- 1 sheldonzhao staff 38746 Apr  2 18:12 .tad/domains/ai-evaluation.yaml ✅

# Reference:
#   experiment_path_protocol.domain_pack_auto_load (in .claude/skills/alex/SKILL.md)
#   - rule: "experiment_path_protocol step1 MUST Read .tad/domains/ai-evaluation.yaml"
#   - rationale: pack is router-mode-loaded, not keyword-loaded — explicit Read required
