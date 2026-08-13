# Web Frontend Capability Pack

> Judgment rules for AI agents to write production-grade React code.

## What This Is

A set of engineering judgment rules that make any AI agent (Claude Code, Copilot, Cursor, Gemini) write frontend code like a senior React engineer — not just code that renders, but code that performs, accessible, maintainable, and correctly integrated with your design system.

**This pack CONSUMES design artifacts. It does NOT create them.**
Use the [web-ui-design](https://github.com/tad-capability-packs/web-ui-design) pack to produce DESIGN.md, tokens, and palettes. This pack turns those artifacts into production code.

## What's Included

| File | Purpose |
|------|---------|
| `CAPABILITY.md` | Main entry point — context-sensitive router |
| `CONVENTIONS.md` | React naming conventions, directory structure, code patterns |
| `references/component-architecture.md` | 7 rules: composition, RSC, splitting, headless UI |
| `references/state-management.md` | 6 rules: selection matrix, local/global/server separation |
| `references/design-tokens.md` | 6 rules: DTCG pipeline, Style Dictionary, DESIGN.md consumption |
| `references/styling.md` | 5 rules: Tailwind vs CSS Modules vs vanilla decision tree |
| `references/performance.md` | 6 rules: CWV thresholds, images, bundle, memoization |
| `references/accessibility.md` | 6 rules: top axe failures, semantic HTML, headless UI |
| `references/testing.md` | 5 rules: pyramid, behavioral testing, Storybook |
| `checklists/frontend-quality.md` | 3-tier quality checklist (automatable / attestation / infra) |
| `scripts/lighthouse-check.sh` | Core Web Vitals measurement |
| `scripts/a11y-scan.sh` | axe-core accessibility scan |
| `scripts/bundle-check.sh` | Bundle size budget check |

**Total**: 41 judgment rules across 7 dimensions.

## Install

```bash
bash install.sh
# or explicitly:
bash install.sh --agent=claude-code
```

Preview what would be installed:
```bash
bash install.sh --dry-run
```

## Use

Once installed for Claude Code, the skill activates automatically when you ask about:

- **Components**: `"How should I structure this component?"` → loads component-architecture rules
- **State**: `"Should I use Zustand or Context?"` → loads state-management rules
- **Design tokens**: `"How do I consume DESIGN.md?"` → loads design-tokens rules
- **Styling**: `"Tailwind vs CSS Modules for this?"` → loads styling rules
- **Performance**: `"My LCP is 4.2s, what do I do?"` → loads performance rules
- **Accessibility**: `"Is this component accessible?"` → loads accessibility rules
- **Testing**: `"What tests should I write?"` → loads testing rules

## Validate

After building your app (`npm run build` + start server):

```bash
# Core Web Vitals (LCP/INP/CLS)
bash scripts/lighthouse-check.sh http://localhost:3000

# Accessibility violations
bash scripts/a11y-scan.sh http://localhost:3000

# Bundle size budgets
bash scripts/bundle-check.sh
```

## Design System Integration

If your project has a `DESIGN.md` file (produced by web-ui-design pack or manually), the pack reads it automatically and uses its token values as constraints for all subsequent rules.

```
DESIGN.md contains:
  --color-primary: #1D4ED8
  --spacing-4: 16px

The pack will:
  ✅ Use #1D4ED8 for primary actions (not hardcoded Tailwind blue)
  ✅ Use 16px/spacing-4 for base spacing (not arbitrary values)
```

## Requirements

- Scripts require Node.js (for Lighthouse + axe) and `npm install -g lighthouse @axe-core/cli`
- Rules reference React 19+ APIs where noted; mark with `[React 19+]` annotations

## License

Apache 2.0. See [LICENSE](LICENSE) and [LICENSE-ATTRIBUTION.md](LICENSE-ATTRIBUTION.md) for source attribution.
