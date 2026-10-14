<!-- Extracted from alex/SKILL.md P3 progressive disclosure 2026-05-31. Moved to Cora 2026-10-13 (EPIC-20261013-cora-conductor-role): Alex is replaced by Cora as the actor; otherwise as extracted. -->

## Status

The status view modifies nothing and asks nothing.

status_panoramic_protocol:
  description: "One-screen project overview scanning all management layers"
  trigger: "User types *status"

  execution:
    step1:
      name: "Scan All Layers"
      action: |
        Scan these sources (read-only, no modifications):
        1. ROADMAP.md → extract themes with status
           - If not found: show "No ROADMAP.md yet — start a direction discussion to create one"
        2. .tad/active/epics/EPIC-*.md → extract name, derived status, progress (N/M phases)
        3. .tad/active/handoffs/HANDOFF-*.md → extract name, date, priority
        4. .tad/active/ideas/IDEA-*.md → count by status (captured/evaluated/promoted/archived)
        5. .tad/research-notebooks/REGISTRY.yaml → extract notebooks with status + last_queried
           - Also read ROADMAP.md + NEXT.md to understand current project goals for relevance judgment
           - If REGISTRY not found: skip Research Portfolio section silently

    step2:
      name: "Display Summary"
      action: |
        Output a compact panoramic view:

        ```
        ## Project Status

        ### Roadmap Themes
        | Theme | Status |
        |-------|--------|
        | {name} | {Active/Planned/Complete} |

        ### Active Epics
        | Epic | Progress | Current Phase |
        |------|----------|---------------|
        | {name} | {N}/{M} phases | {current phase name} |
        (or: "No active Epics" if .tad/active/epics/ is empty)

        ### Active Handoffs
        | Handoff | Date | Priority |
        |---------|------|----------|
        | {name} | {date} | {P0-P3} |
        (or: "No active Handoffs" if .tad/active/handoffs/ is empty)

        ### Ideas
        | Status | Count |
        |--------|-------|
        | captured | {N} |
        | evaluated | {N} |
        | promoted | {N} |
        (only show statuses with count > 0, exclude archived)
        (or: "No ideas captured yet" if empty)

        ### Research Portfolio
        (Only show if REGISTRY.yaml found with ≥1 non-archived notebook)
        | Notebook | Status | Sources | Last Activity | Relevance to Current Goals |
        |----------|--------|---------|---------------|---------------------------|
        | {topic}  | 🟢 Active / 💤 Dormant / ❓ Drifting | {N} | {date} | {Cora judgment} |

        Relevance judgment logic:
        - Read current ROADMAP.md themes + NEXT.md active tasks
        - For each notebook: does its topic align with active Epic/task/roadmap theme?
          → YES: "🎯 Aligned with: {Epic/task name}"
          → No clear alignment: "❓ No current alignment — consider archive or pivot"
          → Actively supporting in-progress task: "🔥 Supporting: {task name}"
        ```

    step3:
      name: "Next Action"
      action: |
        After displaying, return to Cora.
        No AskUserQuestion needed — *status is a read-only command.

## Update roadmap

update_roadmap_protocol:
  description: "Propose and apply ROADMAP.md updates based on discussion conclusions"
  trigger: "The human chooses to update the roadmap (at the end of a direction discussion)"

  execution:
    step1:
      name: "Read Current State"
      action: |
        Read ROADMAP.md (project root).
        If not found: create from template (theme-driven structure with header, Themes section, Archive section).

    step2:
      name: "Propose Changes"
      action: |
        Based on discussion conclusions, Cora proposes specific changes:
        - Add new theme?
        - Update existing theme status (Active → Complete)?
        - Add/remove items in a theme's table?
        - Move completed theme to Archive section?
        Present proposed changes as a bulleted summary to user.

    step3:
      name: "Confirm & Apply"
      action: |
        Use AskUserQuestion:
        "Here are the proposed ROADMAP changes. Confirm?"
        Options:
        - "Apply all changes" → write to ROADMAP.md
        - "Modify first" → user specifies adjustments, then re-confirm
        After applying, return to Cora.

  constraints:
    - "Cora proposes, human confirms — no auto-updates" [A142]
    - "Changes must be concise — ROADMAP stays under ~150 lines" [A143]
    - "Only update based on discussion content — no speculative additions" [A144]
