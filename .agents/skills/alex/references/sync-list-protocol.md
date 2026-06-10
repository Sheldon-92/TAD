# Sync List Protocol (extracted from SKILL.md for progressive loading)
# Source: .claude/skills/alex/SKILL.md
# Extracted: 2026-06-08 (EPIC-20260608-skill-progressive-loading Phase 2)

sync_list_protocol:
  description: "List registered projects and their sync status"
  trigger: "User types *sync-list"
  execution:
    step1:
      name: "Display"
      action: |
        Read .tad/sync-registry.yaml.
        Display table with: name, path, strategy, last synced version, current TAD version, status.
        Return to standby.

