<!-- Extracted from alex/SKILL.md P3 progressive disclosure 2026-05-31. Byte-identical to the original block. -->

idea_list_protocol:
  description: "Browse and manage saved ideas"
  trigger: "User types *idea-list"

  # Status lifecycle reference:
  # captured  — just logged, initial state
  # evaluated — user reviewed and decided it's worth keeping
  # promoted  — (Phase 5) converted to Epic/Handoff
  # archived  — decided not to pursue

  execution:
    step1:
      name: "Scan Ideas"
      action: |
        Read all files in .tad/active/ideas/ matching IDEA-*.md
        For each file, extract: ID, Title, Status, Scope, Date
        If no ideas found → "No ideas captured yet. Use *idea to capture one." → exit to standby

    step2:
      name: "Display"
      action: |
        Show table:
        | # | Title | Scope | Status | Date | File |
        |---|-------|-------|--------|------|------|
        | 1 | {title} | {scope} | {status} | {date} | IDEA-{date}-{slug}.md |

        Sort by date (newest first).
        Filter: show only non-archived ideas by default.

    step3:
      name: "Action"
      action: |
        Use AskUserQuestion:
        "What would you like to do?"
        Options:
        - "View details of an idea" → read and display the full idea file, then return to step3
        - "Update status" → change status (captured → evaluated, or → archived)
        - "Done browsing" → exit to standby

        On "Update status":
        - Ask which idea (by number from table)
        - Ask new status: captured / evaluated / archived (forward only, no backwards)
        - Update the Status field in the idea .md file
        - If status → archived: also mark NEXT.md cross-reference as [x] (if exists)

# *idea promote Protocol
