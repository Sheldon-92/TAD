# Idea: Pack System Unification — Kill Domain Packs, One Format, One Channel, Two Platforms

**ID:** IDEA-20260610-pack-system-unification
**Date:** 2026-06-10
**Status:** promoted
**Scope:** large (multi-phase Epic)

---

## Summary & Problem

TAD currently runs TWO pack systems and TWO distribution behaviors, both measured broken or asymmetric on 2026-06-10:

**Problem A — Domain Packs (YAML) are a dead mechanism with a live tax.**
- 9 YAML packs in `.tad/domains/` (hw-circuit-design, hw-enclosure, hw-firmware, hw-testing, mobile-development, mobile-release, mobile-testing, mobile-ui-design, supply-chain-security), 7,132 lines total.
- Runtime routing is DEAD: `.router.log` does not exist in master OR any heavy downstream project (menu-snap, toy, Colin); the UserPromptSubmit domain-router hook is NOT registered in settings.json. The keyword-routing machinery never actually ran.
- Execution evidence: exactly **1** handoff in all trace history shows domain-pack step execution. toy has 3 archived handoffs referencing hw-* (the only real content usage found).
- The live tax: startup-health.sh injects all 9 pack descriptions into **every session of every one of 14 projects** (the SessionStart "Domain Pack [...]" block). Dead mechanism, recurring context cost.
- Root contrast: Capability Packs (SKILL.md) ride native Claude Code/Codex skill triggering — no self-built routing needed. Domain Packs require self-maintained routing+injection to be visible at all.

**Problem B — Pack INSTALL layer is platform-blind (quantified during v2.29.0 sync).**
- All 25 `install.sh` hardcode `.claude/skills`; **0** know `.agents`. Two distribution channels exist: the sync/copy channel (platform-mirrored, parity-gated, modern) and the install channel (single-platform, ungated, predates Codex first-class v2.26.0).
- Measured downstream effect: 6 packs' SKILL.md install-transformed on `.claude` only (academic-research / ai-agent-architecture / ai-voice-production / video-creation / web-frontend / web-ui-design); ml-training exists ONLY on `.claude` (no prebuilt SKILL.md). Codex users of these 7 packs get raw/missing editions.
- This is the predicted failure class from principles.md 2026-06-01 ("every copy granularity needs its own symmetry + verification granularity"): platform symmetry was fixed at the copy granularity, not the install granularity.

## Target State (the unification)

**One format**: SKILL.md capability packs only. **One channel behavior**: copy + IDEMPOTENT install (install never produces content different from the prebuilt SKILL.md). **Two platforms**: byte-symmetric by construction, verified per-project post-sync.

## Proposed Phases (sketch — Alex refines at *idea-promote)

1. **Phase 1 — Domain Pack retirement**: archive 9 YAMLs to `.tad/archive/domains/`; remove `domains` from the sync derivation set via deprecation/migration-manifest entry (formal downstream removal — no corpses in 14 projects); delete startup-health.sh SessionStart injection block; clean keywords.yaml + router script remnants + runbook Phase 7 keywords check + config/skills-config references. Content policy = **migrate-on-demand**: when a real task next needs hw-*/mobile-*/supply-chain content, upgrade THAT one pack via the existing capability-upgrade flow (no preemptive bulk migration — internal-plumbing prepayment).
2. **Phase 2 — Install single-sourcing**: eliminate install-transform — make the 6 transform packs' prebuilt SKILL.md == install output (CAPABILITY/SKILL single-source); give ml-training a prebuilt SKILL.md. Install becomes pure idempotent copy. This ALSO kills the structural-gate false-positive root (old NEXT item (a)) for good.
3. **Phase 3 — Platform symmetry + verification granularity**: post-install mirror (or platform-aware install lib) so `.agents/skills/{pack}` == `.claude/skills/{pack}`; add per-project post-sync check `diff -qr .claude/skills .agents/skills` (exempting true local skills via the FR7 local-skill model) to the sync protocol — the new copy granularity gets its own verification granularity.

## Open Questions

- Domain YAML knowledge with single-project evidence (hw-* learnings from toy): archive as-is, or also extract key judgment rules into `.tad/skill-library/` T2 references before archiving?
- supply-chain-security: user-personally-motivated (litellm 投毒 incident) — archive-and-wait like the rest, or fast-track to capability pack (security family)?
- Does anything besides startup-health.sh read `.tad/domains/` at runtime? (Blake 1_5a / Alex step4_5 pack scans reference domain packs — sweep needed, same discipline as the self-evolution-pruning anchor map.)
- Migration manifest for downstream `domains/` removal: this would be the first REAL manifest-driven deletion since the Upgrade Lifecycle engine landed — good dogfood, but Phase 3-6 of that epic are unfinished; verify engine path works for dir-level deletion or fall back to deprecation.yaml entry.
- Sequencing vs Upgrade Lifecycle epic: coordinate so the domains-removal manifest doesn't collide with their manifest-chain backfill work.

## Notes

- Measurements taken 2026-06-10 (this session): router.log absent ×4 repos checked; 1 per-handoff domain trace ever; toy hw-* references = 3 archived handoffs; install.sh `.agents` awareness = 0/25; downstream platform diff = 6 transformed + 1 missing pack (menu-snap/my-openclaw-agents spot-checked, identical pattern).
- Companion evidence: `.tad/evidence/releases/sync-v2.29.0.log` (the sync run that quantified Problem B); NEXT.md item "Pack install layer is platform-blind" (Problem B's standing entry — absorbed by this idea's Phase 2/3).
- Method precedent: same retire-by-measurement discipline as EPIC-20260610-self-evolution-pruning ([[self-evolution-pruning]]) — dead mechanism + live tax + preserved-content escape hatch (migrate-on-demand mirrors that epic's T2/T3 graduation rules).
- Strategic fit: "Depth-first — freeze packs, rebuild as SKILL.md one by one" (project_tad-next-direction memory); this idea is that direction's enforcement arm.

---

**Status Values**: captured → evaluated → promoted → archived
**Promoted To**: `.tad/active/epics/EPIC-20260611-pack-system-unification.md` (via *analyze - 2026-06-11)
