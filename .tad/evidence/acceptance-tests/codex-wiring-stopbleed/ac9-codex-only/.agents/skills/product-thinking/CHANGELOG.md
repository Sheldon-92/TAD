# Changelog

## v0.1.0 (2026-05-07)

Initial release.

### Added

**Core Skills**
- `skills/pressure-test.md` — 6-round adversarial product diagnosis with anti-sycophancy rules, type-specific search queries, and BUILD/PIVOT/KILL verdict
- `skills/shotgun.md` — Anti-convergence variant generation with 4-perspective review (EXPAND/SELECTIVE/HOLD/REDUCE)
- `skills/define.md` — Auto-filled type-specific product definition (6 output formats)

**Product Type Adapters** (6 types)
- `adapters/software.md` — SaaS, apps, developer tools
- `adapters/ecommerce.md` — Amazon FBA, DTC, dropshipping
- `adapters/hardware.md` — Physical products, IoT, crowdfunding
- `adapters/service.md` — Consulting, agencies, freelance
- `adapters/content.md` — Newsletters, YouTube, podcasts, communities
- `adapters/marketplace.md` — Two-sided platforms

**Supporting Files**
- `tools/tool-registry.md` — Complete tool availability matrix (ZERO_CONFIG / NEEDS_SETUP / WEBSEARCH_FALLBACK)
- `checklists/fatal-flaws.md` — 15 universal startup killer patterns with severity guide
- `checklists/per-type-validation.md` — Type-specific validation checklists (8 checks each)
- `examples/pressure-test-example.md` — Complete walkthrough: AI meeting summarizer → PIVOT verdict
- `install.sh` — Claude Code installer with --dry-run / --force / --global options

**Infrastructure**
- Session persistence via `~/.product-thinking/session.json` (skill-to-skill data flow)
- Graceful degradation: all search steps have WebSearch fallback

### Architecture Decisions

- 3 deep skills instead of 40 templates (pm-skills proved quantity ≠ quality)
- Adversarial default tone — AI must be convinced, not the user
- Real data mandatory — every round searches, no self-simulation
- Product type adapter pattern — same skill structure, type-specific data layer
- session.json for cross-skill data flow (pressure-test → shotgun → define)
