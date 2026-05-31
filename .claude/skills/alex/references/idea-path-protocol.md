<!-- Extracted from alex/SKILL.md P3 progressive disclosure 2026-05-31. Byte-identical to the original block. -->

idea_path_protocol:
  description: "Lightweight idea capture — discuss briefly, store for later"
  trigger: "Intent Router routes to idea mode"

  execution:
    step1:
      name: "Capture"
      action: |
        Let user describe their idea freely.
        If the idea is clear enough, proceed to step2.
        If vague, ask 2-3 lightweight clarifying questions (NOT full Socratic Inquiry):
        - "What problem does this solve?"
        - "Who benefits?"
        - "Any initial thoughts on how it might work?"

    step2:
      name: "Structure"
      action: |
        Organize into a brief structured format:
        - Title (one line)
        - Summary (2-3 sentences)
        - Open questions (things not yet decided)
        - Potential scope (small / medium / large — rough guess)
        Present to user for confirmation.

    step3:
      name: "Store"
      action: |
        1. Generate slug from title (lowercase, hyphens, max 40 chars)
        2. Check if .tad/active/ideas/IDEA-{YYYYMMDD}-{slug}.md already exists
           If exists: append sequence number (e.g., IDEA-{date}-{slug}-2.md)
        3. Create .tad/active/ideas/IDEA-{YYYYMMDD}-{slug}.md using idea-template.md
           - Fill: title, date, status (captured), scope (from step2)
           - Fill: summary, open questions (from step2 structured output)
           - "Summary & Problem" comes from step1 clarifying questions (if asked) or summary context
        4. Append one-line cross-reference to NEXT.md:
           - If "## Ideas" section exists: append under it
           - If not: create "## Ideas" section AFTER "## Pending" (before "## Blocked")
           - Format: `- [ ] IDEA-{date}-{slug}: {title}`
        5. Confirm to user: "Idea saved to .tad/active/ideas/IDEA-{date}-{slug}.md"

    step4:
      name: "Next"
      action: |
        Use AskUserQuestion:
        "Idea captured. What's next?"
        Options:
        - "I have another idea" → restart step1
        - "This one I want to do now → start *analyze" → switch to adaptive_complexity_protocol
        - "Done, back to standby" → end

# *idea-list Protocol
