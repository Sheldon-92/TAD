# Web UI Design Capability Pack

Give any AI coding agent professional-grade web UI design skills — in one file.

## What This Is

A self-contained capability pack that teaches AI agents how to design and build web UIs with:
- Committed aesthetic direction (not safe, generic defaults)
- Proper design token architecture (primitive → semantic → component)
- Accessible, responsive code
- Specific CLI tools for every step

> **Core idea**: AI agents produce generic "AI-slop" UI by default — Inter font, purple gradients, card grids. This pack gives them the taste and tools to do better.

## Quick Install

### Claude Code
```bash
bash install.sh
```

The script copies `CAPABILITY.md` to `.claude/skills/web-ui-design/SKILL.md` in your project.

### Manual (any agent)
1. Copy `CAPABILITY.md` to wherever your agent reads its skill files
2. Reference it in your project's agent config file
3. Start building

## What's Inside

```
CAPABILITY.md              ← Main file: entry protocol + 9 design capabilities
DESIGN-TEMPLATE.md         ← Template for project-specific brand DESIGN.md
install.sh                 ← Phase 1: Claude Code installer + --dry-run

checklists/
  accessibility.md         ← WCAG/APCA checks with CLI commands
  anti-slop.md             ← Anti-AI-slop rules (concrete, not vague)
  responsive.md            ← Breakpoints, touch targets, fluid typography
  post-generation.md       ← Semantic HTML, relative units, CSS purge

tools/
  tool-registry.md         ← 14+ FULLY_CLI tools (Install/Test/Use format)
  component-matrix.md      ← Component library selection guide
  tokens-to-css.sh         ← Level 0: bash+jq token→CSS (no npm needed)

references/
  brand-tokens.md          ← Real design system token examples
  design-system-patterns.md← Polaris/Primer/Spectrum architecture patterns
  awesome-lists.md         ← Curated GitHub resources

examples/
  starter-tokens.json      ← Neutral 3-level token defaults to start from
```

## How to Use

1. **Install** — run `bash install.sh` in your project root
2. **Activate** — your agent now has web UI design skills loaded
3. **Build** — start any UI design task; the agent follows the Vision → Execution → Validation pipeline

## Agent Loading (Phase 1: Claude Code)

```bash
# Dry run first (no files written)
bash install.sh --dry-run

# Install
bash install.sh
```

After install, CAPABILITY.md lives at `.claude/skills/web-ui-design/SKILL.md` in your project.

## Design Capabilities

| # | Capability | What It Unlocks |
|---|-----------|----------------|
| C1 | Information Architecture | Navigation patterns, user flow diagrams |
| C2 | Wireframing | Structural layout before styling |
| C3 | Visual Design | Token architecture, anti-slop aesthetics |
| C4 | Interaction Design | Motion timing, keyboard navigation |
| C5 | Design System | Component library selection + Storybook setup |
| C6 | Responsive Design | Fluid typography, container queries |
| C7 | Usability Review | axe-core, Lighthouse CI, Pa11y automation |
| C8 | Design System Documentation | Storybook autodocs, design.md |
| C9 | Design Iteration Decisions | ADR format, A/B testing, token versioning |

## Minimum Viable Path

For most projects, you only need three capabilities:
- **C3** (Visual Design) — tokens and aesthetic direction
- **C5** (Design System) — component selection
- **C7** (Usability Review) — automated quality check

## License

MIT License — see [LICENSE](LICENSE)

This pack includes content derived from:
- Anthropic frontend-design SKILL (Apache 2.0) — anti-slop rules
- VoltAgent DESIGN.md standard (Apache 2.0) — 9-section template structure

See [LICENSE-ATTRIBUTION.md](LICENSE-ATTRIBUTION.md) for full attribution.

## Version

v0.1.0 — Phase 1: Claude Code support
