# Cancel Protocol (extracted from SKILL.md for progressive loading)
# Source: .claude/skills/alex/SKILL.md
# Extracted: 2026-06-08 (EPIC-20260608-skill-progressive-loading Phase 2)

cancel_protocol:
  description: "Cancel active handoff that won't be completed — 4-reason taxonomy + rationale + cancelled/ archive. Skips Gate 4."

  trigger:
    type: "user_explicit_only"
    activation_word: "*cancel"
    NOT_via_alex_suggestion: |
      Alex MUST NOT proactively recommend *cancel. Specifically:
      (a) MUST NOT add *cancel to adaptive_complexity_protocol step2 AskUserQuestion options
      (b) MUST NOT pre-select *cancel as Recommended in any AskUserQuestion
      (c) MUST NOT signal-word-detect "abandon" / "scrap" / "give up" → *cancel
      Reason: Anti-AR-001. *cancel is for explicit user-initiated abandonment with
      full reason+rationale ceremony. Auto-suggesting it creates a path of least
      resistance away from completion — exactly the AR-001 attack surface.

  reason_taxonomy:
    options:
      - id: "pivoted"
        label: "Pivoted"
        description: "Direction changed — different approach now correct, this handoff's scope no longer fits"
      - id: "obsolete"
        label: "Obsolete"
        description: "External change made this handoff irrelevant (vendor deprecation, policy change, etc.)"
      - id: "superseded"
        label: "Superseded"
        description: "A newer handoff covers this scope better; cite the superseding handoff in rationale"
      - id: "scope-change"
        label: "Scope Change"
        description: "Original scope was wrong; the actual work is too big or too small for this handoff"

  required_inputs:
    - "cancel_reason: exactly one of [pivoted, obsolete, superseded, scope-change]"
    - "cancel_rationale: free-text one-line explanation (why this reason was chosen, what triggered cancellation)"
    - "Both fields MANDATORY — empty rationale → block *cancel and re-prompt"

  execution:
    step1:
      name: "Confirm cancellation intent"
      action: |
        Use AskUserQuestion to confirm user explicitly wants to cancel (not pause):
          question: "Cancel this handoff? Cancelled handoffs bypass Gate 4 and archive to cancelled/ — this is permanent (handoff won't complete)."
          options:
            - "Yes, cancel — I'll provide reason next"
            - "No, keep active — I'll resume later"
            - "Pause instead — keep in active/, no archive"
        IF user picks "No" or "Pause" → exit cancel_protocol; return to standby.

    step2:
      name: "Capture reason + rationale"
      action: |
        Use AskUserQuestion to select reason from 4-option taxonomy
        (see reason_taxonomy.options above). Then prompt user for one-line
        rationale (free text). Both fields are REQUIRED.

    step3:
      name: "Append cancel fields to handoff frontmatter"
      action: |
        Read current handoff frontmatter. Append (NOT replace) two scalar fields:
          cancel_reason: <chosen reason id>
          cancel_rationale: "<one-line rationale, YAML-escaped>"
        Note: gate4_delta is NOT touched — that's for accepted handoffs only.
        skip_knowledge_assessment is NOT touched — orthogonal concern.

    step4:
      name: "Move handoff to cancelled/ archive"
      action: |
        Create `.tad/archive/handoffs/cancelled/` if missing (mkdir -p).
        Move the cancelled handoff file (atomic mv):
          mv .tad/active/handoffs/HANDOFF-{date}-{slug}.md \
             .tad/archive/handoffs/cancelled/HANDOFF-{date}-{slug}.md
        Move any matching COMPLETION-{date}-{slug}.md if it exists (incomplete completion).

    step5:
      name: "Update NEXT.md"
      action: |
        In NEXT.md:
        1. Find the In Progress entry for this handoff slug → remove it
        2. Find or create a "## Cancelled" section (after "## Recently Completed" or at end)
        3. Add line: "- [c] {slug} ({date}) — {reason}: {rationale truncated to 80 chars}"
        4. Use [c] marker (not [x]) to distinguish cancelled from completed.

    step6:
      name: "Skip Gate 4 ceremony — by design"
      action: |
        Do NOT execute *accept ceremony. Do NOT add `## Gate 4` section to handoff.
        Do NOT call layer2-audit.sh.
        Cancelled work has no acceptance — only archival. This is the explicit
        contract that makes cancellation distinct from completion.
      verification: |
        AC-P5.3-f verifies: post-cancel diff shows NO `## Gate 4` section addition.

    step7:
      name: "Confirm + return to standby"
      action: |
        Output to user: "✅ Cancelled: {slug}. Reason: {reason}. Rationale recorded.
        Archived to .tad/archive/handoffs/cancelled/. Returning to standby."
        Enter Alex standby state (per intent_router_protocol.standby).

  enforcement: "prompt-level-only"  # See constraints.enforcement (global)

  # P5.3 BA-P0-3: symmetric forbidden_implementations 5-item block
  # (parity with *express / *experiment / skip_knowledge_assessment per
  # Path Layering 2026-04-24 attack-surface defense)
  # Mechanical deny migrated to frontmatter constraints.deny (global) + section_overrides.cancel_protocol
  forbidden_implementations:
    - "MUST NOT couple *cancel to skip_knowledge_assessment (cancelled handoffs bypass Gate 4 by design but MUST still write cancel_reason + cancel_rationale)"
    - "Anti-AR-001: '*cancel = silent abandonment' is a forbidden interpretation — both reason taxonomy AND rationale text are mandatory"
    - "MUST NOT auto-downgrade Standard TAD handoff to *cancel via any mechanism (no Alex AskUserQuestion suggestion, no signal-word auto-detection)"

  rationale: |
    Phase 5 P5.3 formalizes what was previously the "silent abandoned handoff"
    failure mode (toy 2026-04-11 example: handoff sat in active/ for weeks,
    never accepted, never deleted, eventually disappeared without record).
    Structured cancellation gives future cross-project audits a way to distinguish "Alex
    over-scoped" from "external pivot" from "supersede chain" — all of which
    look like missing-completion to a naive aggregator.

