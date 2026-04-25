# Fixture: Intent Router 7-mode display with 4-option overflow tiebreaker (P3.1 AC-P3.1-k, BA-P0-1)
# Purpose: When candidate modes >4, priority_order resolves; analyze always 4th position.

# Scenario:
#   User input (ambiguous):
#     "我想做一个评估，然后修个 bug，可能要讨论一下方向，顺便学一下原理"
#
#   Signal counts (hypothetical):
#     bug: 1 ("bug")
#     discuss: 1 ("讨论")
#     learn: 1 ("学一下", "原理")
#     experiment: 2 ("评估")
#     express: 0
#     idea: 0
#     analyze: 0 (fallback)

# Candidate modes with non-zero signal: 4 (bug, discuss, learn, experiment)
# Plus analyze fallback = 5 candidate modes for 4-option AskUserQuestion.

# Tiebreaker:
#   priority_order from config-workflow.yaml:
#     bug > idea > experiment > express > discuss > learn > analyze
#
#   Sort: (signal_count desc, priority_order asc)
#     1. experiment (signal=2, priority=3)  ← highest signal
#     2. bug         (signal=1, priority=1)  ← higher priority among ties
#     3. discuss     (signal=1, priority=5)
#     4. learn       (signal=1, priority=6)
#
#   Top 3 non-analyze: experiment, bug, discuss
#   analyze always 4th.

# Expected step3 AskUserQuestion options:
#   Option 1: experiment (Recommended)
#     "OPRO / A-B test / benchmark / prompt tuning"
#   Option 2: bug
#     "Quick bug diagnosis"
#   Option 3: discuss
#     "Free-form product/tech discussion"
#   Option 4: analyze
#     "Standard TAD workflow (fallback)"
#
#   DROPPED: learn (lowest priority among ties)

# Verification:
#   - analyze MUST be at position 4
#   - *express MUST NOT appear (zero signal AND never-Recommended rule)
#   - Tiebreaker must follow priority_order, not insertion order
