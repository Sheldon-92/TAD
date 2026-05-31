<!-- Extracted from alex/SKILL.md P3 progressive disclosure 2026-05-31. Byte-identical to the original block. -->

idea_promote_protocol:
  description: "Upgrade an idea to Epic or Handoff — changes status and enters *analyze"
  trigger: "User types *idea promote"

  execution:
    step1:
      name: "Select Idea"
      action: |
        1. Scan .tad/active/ideas/ for IDEA-*.md files
        2. Filter: show only ideas with status "captured" or "evaluated" (not already promoted/archived)
        3. If no promotable ideas → "No ideas available to promote. Use *idea to capture one." → exit to standby
        4. Display table (same format as *idea-list step2)
        5. Ask user to select an idea by number

    step2:
      name: "Choose Target"
      action: |
        Read the selected idea file to get scope and summary.
        Use AskUserQuestion:
        "How would you like to promote this idea?"
        Options:
        - "Start as Epic (multi-phase)" → for medium/large scope ideas
        - "Start as Handoff (single task)" → for small scope ideas
        - "Cancel" → return to standby

    step3:
      name: "Update Idea Status"
      action: |
        1. Update the idea file's Status field: → "promoted"
        2. Fill the "Promoted To" field at bottom of idea file:
           - If Epic: "Promoted To: Epic (via *analyze — {date})"
           - If Handoff: "Promoted To: Handoff (via *analyze — {date})"
        3. Update NEXT.md cross-reference:
           - Search for "IDEA-{id}" in NEXT.md
           - If found: mark as [x] with note "(promoted)"
           - If not found: no action needed (idea may predate cross-reference system)

    step4:
      name: "Transition to *analyze"
      action: |
        1. Announce: "Idea promoted. Entering *analyze with idea context pre-loaded."
        2. Call adaptive_complexity_protocol with idea context:
           - Title → becomes the task description for complexity assessment
           - Scope → informs initial complexity guess (small→light, medium→standard, large→full)
           - Summary & Problem → Alex presents this context at start of Socratic Inquiry
           - Open Questions → Alex uses these as early Socratic discussion seed points
        3. The *analyze flow runs normally from step1 (Assess) onward.
           If user chose "Epic": Alex's step2b Epic Assessment will naturally trigger.
        (Context transfer is via conversation memory — no special persistence mechanism needed)

# *learn Path Protocol
