# Changelog

All notable changes to this project will be documented in this file.

Format: [Semantic Versioning](https://semver.org/) — Added / Changed / Fixed / Removed

---

## [0.1.0] — 2026-05-07

### Added

- `CAPABILITY.md` — main capability file with Entry Protocol + 9 capabilities (C1–C9)
  - Each capability: Vision + Execution + Validation pipeline
  - Framework-agnostic tools first, React/Vue as optional branches
  - Anti-AI-Slop Rules section (6 Anthropic rules + 4 expanded)
- `DESIGN-TEMPLATE.md` — 9-section project DESIGN.md template (VoltAgent standard)
- `install.sh` — Claude Code installer with `--dry-run` support
- `checklists/accessibility.md` — WCAG/APCA checks with CLI commands
- `checklists/anti-slop.md` — Anti-AI-slop rules (Anthropic 6 + expanded)
- `checklists/responsive.md` — Responsive design checks
- `checklists/post-generation.md` — Post-generation cleanup checklist
- `tools/tool-registry.md` — 14 FULLY_CLI tools (Install/Test/Use format)
- `tools/component-matrix.md` — 8 component libraries compared
- `tools/tokens-to-css.sh` — Level 0 token→CSS compiler (bash+jq only, no npm)
- `references/brand-tokens.md` — Real design system token values (Stripe, Vercel, Linear)
- `references/design-system-patterns.md` — Architecture patterns (Polaris, Primer, Spectrum)
- `references/awesome-lists.md` — Curated GitHub resources
- `examples/starter-tokens.json` — Neutral 3-level token defaults (primitive/semantic/component)

### Phase 1 Scope

- Claude Code installation only
- Cross-agent support (Codex, Cursor, Gemini) reserved for Phase 3
