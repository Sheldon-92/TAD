<!-- Extracted from alex/SKILL.md P3 progressive disclosure 2026-05-31. Byte-identical to the original block. -->

status_panoramic_protocol:
  description: "One-screen project overview scanning all management layers"
  trigger: "User types *status"

  execution:
    step1:
      name: "Scan All Layers"
      action: |
        Scan these sources (read-only, no modifications):
        1. ROADMAP.md → extract themes with status
           - If not found: show "No ROADMAP.md yet — use *discuss to create one"
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
        | {topic}  | 🟢 Active / 💤 Dormant / ❓ Drifting | {N} | {date} | {Alex judgment} |

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
        After displaying, return to standby.
        No AskUserQuestion needed — *status is a read-only command.

# *research --deep Protocol (formerly *research-plan, now part of *research unified)
