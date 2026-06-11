# Domain Pack Retirement Archive — 2026-06-11

## Summary

9 YAML Domain Packs + 2 guide documents archived from `.tad/domains/` as part of Pack System Unification Phase 1 (EPIC-20260611-pack-system-unification).

## Reason

Measurement showed YAML Domain Pack routing was effectively dead (zero live invocations since v2.17.0 keyword router retirement). The runtime remained active only as SessionStart injection overhead. Capability Packs (SKILL.md-based) replaced all active pack functionality.

## Archived Files

### Hardware Domain Packs
- `hw-circuit-design.yaml` — Circuit design workflows and tools
- `hw-enclosure.yaml` — Enclosure/mechanical design workflows
- `hw-firmware.yaml` — Firmware development workflows
- `hw-testing.yaml` — Hardware testing and validation

### Mobile Domain Packs
- `mobile-development.yaml` — Mobile app development workflows
- `mobile-release.yaml` — Mobile release process
- `mobile-testing.yaml` — Mobile testing workflows
- `mobile-ui-design.yaml` — Mobile UI design patterns

### Security
- `supply-chain-security.yaml` — Pre-install dependency trust assessment

### Guide Documents
- `DOMAIN-PACK-ROADMAP.md` — Historical roadmap for Domain Pack development
- `HOW-TO-CREATE-DOMAIN-PACK.md` — Historical creation guide

## Migrate-On-Demand Policy

These archived YAML packs should NOT be bulk-converted into Capability Packs. Instead:

1. **When a real task** needs content from an archived pack (e.g., a hardware project needs circuit design workflows)
2. **Create a Capability Pack** using the archived YAML as source material, following the current pack build process
3. **Validate** the new pack with a real project task before registering it
4. **T2 references** in `.tad/skill-library/` point to these archives for quick assessment

## T2 Skill-Library References

- `tad--hw-domain-archive.md` — Hardware domain pack learnings
- `tad--supply-chain-security-archive.md` — Supply chain security learnings

## What NOT to Reuse

- Keyword routing mechanism (replaced by Capability Pack auto-awareness)
- YAML step models (replaced by SKILL.md reference-based architecture)
- Tools-registry.yaml format (tools now documented inline in SKILL.md references)
- SessionStart injection pattern (Capability Packs load on demand, not at startup)

## Related

- Previous partial retirement: v2.17.0 archived 12 YAML packs with Capability Pack equivalents
- Epic: `.tad/active/epics/EPIC-20260611-pack-system-unification.md`
- Idea: `.tad/active/ideas/IDEA-20260610-pack-system-unification.md`
