# HANDOFF: Agent Team Default for Full + Standard TAD

**Date**: 2026-02-07
**Priority**: P2
**Complexity**: Small
**Status**: Ready for Implementation

## Executive Summary

Change Agent Teams from "Full TAD only" to the default mode for both Full and Standard TAD process depths. Light TAD remains subagent. Fallback mechanism unchanged. Also lower Blake's `min_tasks_for_team` from 3 to 2 so Standard TAD tasks can activate Agent Teams more readily.

## Task Breakdown

### Task 1: Update coexistence rules + min_tasks in config-agents.yaml

**File**: `.tad/config-agents.yaml`

**Change A** — Coexistence rules (line 311):

```yaml
# OLD (line 311)
      standard_tad: "subagent"     # Standard TAD → subagent
# NEW
      standard_tad: "agent_team"   # Standard TAD → Agent Team (default)
```

**Change B** — Blake min_tasks threshold (line 338):

```yaml
# OLD (line 338)
    min_tasks_for_team: 3
# NEW
    min_tasks_for_team: 2
```

### Task 2: Widen Alex activation condition in tad-alex.md

**File**: `.claude/commands/tad-alex.md`

**Change A** — Comment (line 844):
```yaml
# OLD
    # Alternative to step3 when process_depth == full and Agent Teams available
# NEW
    # Alternative to step3 when process_depth is full or standard, and Agent Teams available
```

**Change B** — Name (line 846):
```yaml
# OLD
      name: "Agent Team Expert Review (Full TAD only)"
# NEW
      name: "Agent Team Expert Review (Full + Standard TAD)"
```

**Change C** — Description (line 847):
```yaml
# OLD
      description: "Alternative to step3 when process_depth == full and Agent Teams available"
# NEW
      description: "Alternative to step3 when process_depth is full or standard, and Agent Teams available"
```

**Change D** — Activation condition (line 852):
```yaml
# OLD
        1. process_depth == "full" (user chose Full TAD in adaptive complexity)
# NEW
        1. process_depth in ["full", "standard"] (user chose Full or Standard TAD)
```

### Task 3: Widen Blake activation condition in tad-blake.md

**File**: `.claude/commands/tad-blake.md`

**Change A** — Comment (line 267):
```yaml
# OLD
  # Agent Team Implementation Mode (TAD v2.3 - experimental)
  # Parallel implementation with file ownership when conditions allow
# NEW
  # Agent Team Implementation Mode (TAD v2.3)
  # Parallel implementation with file ownership — default for Full + Standard TAD
```

**Change B** — Name (line 270):
```yaml
# OLD
    name: "Agent Team Implementation (Full TAD only)"
# NEW
    name: "Agent Team Implementation (Full + Standard TAD)"
```

**Change C** — Description (line 271):
```yaml
# OLD
    description: "Parallel implementation with file ownership when conditions allow"
# NEW
    description: "Parallel implementation with file ownership — default for Full + Standard TAD"
```

**Change D** — Activation condition (line 276):
```yaml
# OLD
      1. process_depth == "full"
# NEW
      1. process_depth in ["full", "standard"]
```

## Acceptance Criteria

- [ ] AC1: `config-agents.yaml` coexistence `standard_tad` value is `"agent_team"`
- [ ] AC2: `config-agents.yaml` blake `min_tasks_for_team` is `2`
- [ ] AC3: `tad-alex.md` step3_agent_team activates for both full and standard process depths
- [ ] AC4: `tad-blake.md` agent_team_develop activates for both full and standard process depths
- [ ] AC5: Light TAD still uses subagent (unchanged)
- [ ] AC6: Fallback mechanism unchanged (auto_fallback_to_subagent)
- [ ] AC7: All name/description strings updated to say "Full + Standard" instead of "Full TAD only"

## Files to Modify

1. `.tad/config-agents.yaml` — coexistence rules (line 311) + min_tasks (line 338)
2. `.claude/commands/tad-alex.md` — step3_agent_team: lines 844, 846, 847, 852
3. `.claude/commands/tad-blake.md` — agent_team_develop: lines 267, 270, 271, 276

## Testing Checklist

- [ ] Verify config-agents.yaml syntax is valid YAML
- [ ] Verify no other references to "Full TAD only" remain for Agent Teams
- [ ] Verify fallback section is untouched
- [ ] Verify light_tad and skip_tad rules are unchanged
- [ ] Verify min_tasks_for_team is now 2

## Expert Review Status

| Expert | Result | P0 Issues | Key Feedback |
|--------|--------|-----------|--------------|
| code-reviewer | CONDITIONAL PASS | 0 | Line numbers clarified; no hidden refs found; fallback safe |
| backend-architect | CONDITIONAL PASS | 1 (resolved) | min_tasks_for_team mismatch → lowered to 2 per user decision |

**P0 Resolution**: Architect's P0-1 (min_tasks_for_team threshold) resolved by adding Task 1 Change B (lower from 3 to 2).

Expert Review Complete — Ready for Implementation
