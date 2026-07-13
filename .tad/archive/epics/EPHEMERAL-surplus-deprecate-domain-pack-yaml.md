# EPHEMERAL Epic: deprecate-domain-pack-yaml

> Ephemeral surplus Epic — single phase, auto-executed, archive on completion.
> Source: ideas backlog (surplus task deprecate-domain-pack-yaml).

## Goal

Finish the Domain Pack YAML retirement started 2026-06-11 (EPIC-20260611-pack-system-unification).
Migrate the 9 remaining archived YAML packs (hw-circuit-design, hw-enclosure, hw-firmware,
hw-testing, mobile-development, mobile-release, mobile-testing, mobile-ui-design,
supply-chain-security — 7,132 YAML lines total) into Capability Pack format
(`.claude/skills/{pack}/SKILL.md` + `references/`), mirror to `.agents/skills/`, and record
the mechanism retirement (incl. domain-router hook decommission confirmation) in CHANGELOG.

## Ground Truth (2026-07-05)

- `.tad/domains/` contains ONLY `README-retired.md` — the live YAML mechanism is already dead.
- The 9 source YAMLs live at `.tad/archive/domains/2026-06-11-domain-pack-retirement/*.yaml`
  (9 files, 7,132 lines). They stay archived (audit trail) — this Epic does NOT delete them.
- No `domain-router` hook file exists in `.tad/hooks/` — decommission is a verify-and-document step.
- Existing pack format precedent: `.claude/skills/{pack}/SKILL.md` (+ optional `references/`),
  mirrored in `.agents/skills/{pack}/` for Codex parity.

## Phases

| Phase | Name | Status |
|-------|------|--------|
| 1 | migrate-9-yaml-packs | Active |

## Phase 1 Scope

- Convert each of the 9 archived YAMLs into a Capability Pack: distilled SKILL.md
  (judgment rules, not YAML config dumps) + references/ for depth content.
- Mirror all 9 packs to `.agents/skills/` (structural parity with existing packs).
- CHANGELOG entry: 9 packs migrated, YAML mechanism fully retired, domain-router
  hook confirmed decommissioned. Update `.tad/domains/README-retired.md` migrate-on-demand
  note to point at the new packs.

## Out of Scope

- Deleting archived YAML sources (they are the audit trail).
- New research per pack (pack-upgrade dual-layer bar) — this is format migration;
  content quality upgrades are a future pack-upgrade pass.
- Touching any of the 24 existing active packs.

## Handoff

`.tad/active/handoffs/HANDOFF-surplus-deprecate-domain-pack-yaml.md`
