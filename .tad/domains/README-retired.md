# .tad/domains — RETIRED (2026-06-11)

YAML Domain Packs have been retired as an active TAD runtime mechanism.

- **Active pack format**: SKILL.md Capability Packs in `.claude/skills/` and `.agents/skills/`
- **Archived content**: `.tad/archive/domains/2026-06-11-domain-pack-retirement/`
- **T2 references**: `.tad/skill-library/tad--hw-domain-archive.md`, `.tad/skill-library/tad--supply-chain-security-archive.md`
- ~~**Migrate on demand**: when a real task needs hw/mobile/supply-chain content, create a Capability Pack from the archived YAML source~~
  **Migration complete (done 2026-07-12, TASK-20260705-001)** — all 9 archived YAMLs migrated (all of hw/mobile/supply-chain). The live Capability Packs are:
  - `.claude/skills/hw-circuit-design/` (mirror: `.agents/skills/hw-circuit-design/`)
  - `.claude/skills/hw-enclosure/`
  - `.claude/skills/hw-firmware/`
  - `.claude/skills/hw-testing/`
  - `.claude/skills/mobile-development/`
  - `.claude/skills/mobile-release/`
  - `.claude/skills/mobile-testing/`
  - `.claude/skills/mobile-ui-design/`
  - `.claude/skills/supply-chain-security/`

  (each pack: `SKILL.md` + `references/`, with a byte-identical `.agents/skills/{pack}/` mirror; archived YAML sources remain untouched as the audit trail)

See EPIC-20260611-pack-system-unification.md for rationale.
