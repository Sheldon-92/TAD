---
task_type: code
e2e_required: no
research_required: no
git_tracked_dirs: [".claude/skills/alex", ".tad/hooks/lib"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: Knowledge Lifecycle Phase 3 — Maintain Engine

**From:** Alex | **To:** Blake | **Date:** 2026-06-02
**Epic:** EPIC-20260602-knowledge-layering.md (Phase 3/3)

---

## 1. Task Overview

**Title:** Maintain Engine — Gate 4 Auto-Classification + *dream Graduation + Incident Expiration + knowledge-blame.sh Scope Fix

**Summary:** Make the Knowledge Lifecycle System self-sustaining. Gate 4 KA auto-classifies new entries at write time. *dream detects graduation candidates (L3 → L2). Incident expiration proposes archival for entries >90 days. principles.md gets Epic-level protection. Also fix knowledge-blame.sh scope to cover the new `patterns/` and `incidents/` subdirectories (P2 known forward-compat issue).

**Business Value:** After this lands, the knowledge system maintains itself. New knowledge enters the right layer automatically. Old incidents expire. Patterns graduate when evidence accumulates. The human only reviews promotion decisions — never sorts files.

---

## 2. Implementation Steps

### Task 1: Gate 4 KA Auto-Classification

In `.claude/skills/alex/SKILL.md`, find the `acceptance_protocol` → `step7` (Knowledge Assessment). Modify section C (`C_alex_own_discoveries`) to auto-classify new entries:

Add BEFORE the existing "write directly to .tad/project-knowledge/{category}.md" instruction:

```yaml
    C_alex_own_discoveries:
      action: |
        1. Evaluate: did this acceptance reveal business/architecture insights?
        2. If Yes → classify the discovery using prediction-error heuristic:
           a. "Does this fundamentally change how TAD works?" → L1-CANDIDATE
              → Write to .tad/project-knowledge/principles.md ONLY IF an active Epic
                references a principles-modification task. Otherwise:
              → "⚠️ L1 CANDIDATE detected: '{title}'. Promoting to principles.md requires
                an Epic-level TAD flow. Recording as L2 pattern for now."
              → Write to appropriate patterns/{theme}.md instead
              → Append to patterns/_index.md
           b. "Is this a reusable pattern for a class of problems?" → L2
              → Write to .tad/project-knowledge/patterns/{matched_theme}.md
              → Append one-line entry to patterns/_index.md
              → Match theme via keyword similarity to existing pattern file names
                (if no match, create a new theme file)
           c. "Is this evidence of a specific event?" → L3
              → Write to .tad/project-knowledge/incidents/{YYYY-MM}/{slug}.md
              → Append to incidents/_index.md with linked L1/L2 reference
           d. "Would a senior TAD user already know this?" → YES → skip writing
        3. Fill Gate 4 Knowledge Assessment table with: layer, file path, entry title
```

### Task 2: *dream Graduation Detection

In `.claude/skills/alex/SKILL.md`, find `dream_protocol` → `step2_gather_signal`. Add a new signal type:

```yaml
        6. **Graduation candidates**: Scan incidents/_index.md for entries with the same
           "linked" L2 pattern. If ≥2 incidents link to the same L2 pattern:
           → Propose graduation: "Pattern '{pattern}' has {N} supporting incidents.
             Consider promoting the common finding to a stronger pattern entry."
           → In step4 review, show these as "🎓 Graduation candidate" with option to:
             - "Accept graduation" → merge incident findings into the L2 pattern entry,
               archive the incidents
             - "Keep separate" → incidents stay, no merge
```

### Task 3: 90-Day Incident Expiration

In `dream_protocol` → `step2_gather_signal`, add another signal type:

```yaml
        7. **Expired incidents**: For each incident in incidents/_index.md:
           a. Extract date from the entry (YYYY-MM-DD format in title or _index.md)
           b. Compute age_days = today - date
           c. If age_days > 90:
              Check: has the linked L2 pattern had a NEW incident in the last 60 days?
              → If no new incident (pattern is stable) → propose archival:
                "Incident '{title}' is {age_days} days old and its linked pattern
                '{pattern}' has been stable for 60+ days. Archive?"
              → If yes (pattern still active) → keep incident (still relevant evidence)
           d. In step4 review, show these as "🗄️ Expiration candidate" with options:
              - "Archive" → mv incident file to .tad/archive/knowledge/{YYYY-MM}/
              - "Keep" → incident stays (resets the 90-day clock via Revalidated date)
              - "Revalidate" → add Revalidated: {today} date, keep for another 90 days
```

### Task 4: principles.md Epic-Level Protection

In `.claude/skills/alex/SKILL.md`, add a check in `handoff_creation_protocol` → `step1` (Draft Creation):

```yaml
      # principles.md protection check (Knowledge Lifecycle System)
      If any file in §6 "Files to Modify" targets .tad/project-knowledge/principles.md:
        Check: does the current handoff have an Epic field?
        → If yes (Epic context active) → allow modification, log: "principles.md edit authorized by Epic {slug}"
        → If no (standalone handoff) → WARN:
          "⚠️ principles.md contains L1 methodology rules. Modifying it requires an
          Epic-level TAD flow. Either create an Epic first, or reclassify this change
          as an L2 pattern edit (patterns/*.md) if it's not truly a methodology change."
          Use AskUserQuestion: "Override?" / "Create Epic first" / "Change target to patterns/"
```

### Task 5: Fix knowledge-blame.sh Scope (P2 Forward-Compat)

In `.tad/hooks/lib/knowledge-blame.sh`, widen the scope guard to cover subdirectories:

Change:
```bash
.tad/project-knowledge/*|.claude/skills/*/SKILL.md|.tad/hooks/lib/*.sh) ;;
```
To:
```bash
.tad/project-knowledge/*|.tad/project-knowledge/*/*|.tad/project-knowledge/*/*/*|.claude/skills/*/SKILL.md|.tad/hooks/lib/*.sh) ;;
```

This covers: top-level files (principles.md), one-deep (patterns/gate-design.md), and two-deep (incidents/2026-05/slug.md).

### Task 6: dream-validator.sh Layer Validation

In `.tad/hooks/lib/dream-validator.sh`, add layer-specific validation checks:

```bash
# Layer validation (Knowledge Lifecycle System)
if [ -f "$CANDIDATE" ]; then
  # Check L1 cap: principles.md should have ≤15 entries
  if [ -f .tad/project-knowledge/principles.md ]; then
    l1_count=$(grep -c '^### ' .tad/project-knowledge/principles.md 2>/dev/null || echo 0)
    if [ "$l1_count" -gt 15 ]; then
      echo "WARN: principles.md has $l1_count entries (cap: 15)"
    fi
  fi
  # Check SAFETY markers preserved
  # (existing check — ensure it also covers principles.md)
fi
```

---

## 3. Acceptance Criteria

| # | AC | Verification |
|---|-----|-------------|
| AC1 | Gate 4 KA C_alex_own_discoveries has layer classification | `grep -c 'L1-CANDIDATE\|L2\|L3' .claude/skills/alex/SKILL.md` ≥ 3 (in acceptance_protocol area) |
| AC2 | Gate 4 KA writes to patterns/ not flat architecture.md | `grep -c 'patterns/' .claude/skills/alex/SKILL.md` ≥ 2 (in acceptance_protocol) |
| AC3 | *dream has graduation detection | `grep -c 'Graduation candidate\|graduation' .claude/skills/alex/SKILL.md` ≥ 1 |
| AC4 | *dream has 90-day expiration | `grep -c '90.*day\|age_days.*90\|Expiration candidate' .claude/skills/alex/SKILL.md` ≥ 1 |
| AC5 | principles.md Epic protection | `grep -c 'principles.md.*Epic\|Epic.*principles' .claude/skills/alex/SKILL.md` ≥ 1 |
| AC6 | knowledge-blame.sh covers patterns/ and incidents/ | `echo '.tad/project-knowledge/patterns/test.md' | bash -c 'FILE=".tad/project-knowledge/patterns/test.md"; case "$FILE" in .tad/project-knowledge/*\|.tad/project-knowledge/*/*\|.tad/project-knowledge/*/*/*) echo MATCH;; *) echo NOMATCH;; esac'` = MATCH |
| AC7 | dream-validator checks L1 cap | `grep -c 'l1_count\|principles.md.*15' .tad/hooks/lib/dream-validator.sh` ≥ 1 |
| AC8 | Backward compat: *dream runs without crash | `grep -c 'dream_protocol' .claude/skills/alex/SKILL.md` ≥ 1 (still present) |

---

## 4. Important Notes

- Gate 4 KA classification is JUDGMENT-BASED (Alex decides the layer), not mechanical regex. The decision tree is a guide, not an algorithm.
- L1-CANDIDATE → L2 downgrade is the SAFE default. Only an active Epic can promote to L1.
- Graduation merges incident FINDINGS into the L2 pattern — it doesn't delete the incident (archive it for audit trail).
- 90-day expiration is PROPOSED, not automatic. Human (or Alex in YOLO) confirms each archival.
- knowledge-blame.sh scope fix: the triple glob pattern (`*`, `*/*`, `*/*/*`) covers 3 levels. If knowledge structure goes deeper than 3 levels in the future, the scope guard needs another level.

## 5. Required Evidence

```yaml
completion: .tad/active/handoffs/COMPLETION-20260602-knowledge-lifecycle-phase3.md
```
