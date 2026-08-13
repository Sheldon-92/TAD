# Sync Add Protocol (extracted from SKILL.md for progressive loading)
# Source: .claude/skills/alex/SKILL.md
# Extracted: 2026-06-08 (EPIC-20260608-skill-progressive-loading Phase 2)

sync_add_protocol:
  description: "Register a new project for TAD sync"
  trigger: "User types *sync-add"

  execution:
    step1:
      name: "Get Project Path"
      action: |
        Ask user for the project's absolute path.
        Validate:
        - Path exists
        - .tad/ directory exists (has TAD installed)
        - .tad/version.txt exists (can read current version)
        If validation fails → error with specific message.

    step2:
      name: "Detect CLAUDE.md Strategy"
      action: |
        Read the project's CLAUDE.md.
        If it contains `<!-- TAD:PROJECT-CONTENT-BELOW -->` marker:
          → Pre-select "merge"
          → Show: "Detected project-specific content in CLAUDE.md (N lines after marker)"
        Else:
          → Pre-select "overwrite"
        Use AskUserQuestion to confirm strategy.
        If user selects "merge" but marker doesn't exist yet:
          → Inform: "You'll need to add `<!-- TAD:PROJECT-CONTENT-BELOW -->` to the project's CLAUDE.md before the project-specific section."

    step3:
      name: "Register"
      action: |
        Add entry to .tad/sync-registry.yaml with:
        - path, name (derived from directory name), claude_md_strategy
        - last_synced_version: read from target's .tad/version.txt
        - last_synced_date: today
        Confirm: "Project {name} registered for TAD sync."

