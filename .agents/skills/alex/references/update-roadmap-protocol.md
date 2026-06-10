<!-- Extracted from alex/SKILL.md P3 progressive disclosure 2026-05-31. Byte-identical to the original block. -->

update_roadmap_protocol:
  description: "Propose and apply ROADMAP.md updates based on discussion conclusions"
  trigger: "User selects 'Update ROADMAP' from *discuss exit_protocol"

  execution:
    step1:
      name: "Read Current State"
      action: |
        Read ROADMAP.md (project root).
        If not found: create from template (theme-driven structure with header, Themes section, Archive section).

    step2:
      name: "Propose Changes"
      action: |
        Based on discussion conclusions, Alex proposes specific changes:
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
        After applying, return to Alex standby.

  constraints:
    - "Alex proposes, human confirms — no auto-updates"
    - "Changes must be concise — ROADMAP stays under ~150 lines"
    - "Only update based on discussion content — no speculative additions"

# *status Panoramic Protocol
