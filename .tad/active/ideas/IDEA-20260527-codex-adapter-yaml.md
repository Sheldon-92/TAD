# Idea: Capability Pack Codex YAML Adapter

**ID:** IDEA-20260527-codex-adapter-yaml
**Date:** 2026-05-27
**Status:** captured
**Scope:** small

---

## Summary & Problem

ECC places a 6-line `agents/openai.yaml` file next to each SKILL.md to enable Codex compatibility. TAD's Codex adaptation (AGENTS.md + static SKILL.md) works but is heavier. Adding a `--agent=codex` flag to each capability pack's `install.sh` that auto-generates a minimal `openai.yaml` adapter would give TAD packs zero-cost Codex compatibility without maintaining a separate AGENTS.md routing table per pack.

## Open Questions

- What fields does Codex actually read from openai.yaml? (ECC uses: display_name, short_description, brand_color, default_prompt, allow_implicit_invocation)
- Should the adapter be generated from SKILL.md frontmatter automatically or hand-curated?
- Does this replace or supplement the existing AGENTS.md routing approach from the Codex CLI Adaptation Epic?
- TAD's Codex SKILL files follow a strip-only rule — does the adapter need to account for this?

## Notes

- Reference: ECC `.agents/skills/*/agents/openai.yaml` — 6 lines per adapter
- TAD Codex Epic already archived: `.tad/archive/epics/EPIC-20260427-codex-cli-adaptation.md`
- ECC's cross-harness doc explicitly says hooks are "instruction-backed" on Codex (no mechanical execution) — matches TAD's architecture.md entry on Codex constraints

---

**Status Values**: captured → evaluated → promoted → archived
**Promoted To**: (filled by *idea promote)
