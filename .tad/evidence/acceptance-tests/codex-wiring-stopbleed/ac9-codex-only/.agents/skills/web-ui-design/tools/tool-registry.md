# Tool Registry

14 FULLY_CLI tools verified for web UI design workflows.
Format: `Install:` / `Test:` / `Use:` labels (grep-able, consistent across all entries).

> **FULLY_CLI**: entire workflow runnable from terminal without browser or GUI.
> **PARTIAL_CLI**: some steps require browser or GUI (noted explicitly).
> **GUI_ONLY**: cannot be used from CLI.

---

## FULLY_CLI Tools

### 1. Style Dictionary

Token transformation: JSON → CSS/iOS/Android.

Install:
```bash
npm install -D style-dictionary
```

Test:
```bash
npx style-dictionary --version
```

Use:
```bash
npx style-dictionary init basic
npx style-dictionary build --config sd.config.json
```

---

### 2. axe-core CLI

Automated accessibility auditing.

Install:
```bash
npm install -g @axe-core/cli
```

Test:
```bash
axe --version
```

Use:
```bash
axe http://localhost:3000 --tags wcag2aa --exit
axe http://localhost:3000 --reporter json > axe-report.json
```

---

### 3. Lighthouse CI

Performance, accessibility, and best practices auditing.

Install:
```bash
npm install -g @lhci/cli
```

Test:
```bash
lhci --version
```

Use:
```bash
lhci autorun
lhci collect --url=http://localhost:3000
```

---

### 4. Pa11y

Accessibility testing — alternative rule engine to axe-core.

Install:
```bash
npm install -g pa11y
```

Test:
```bash
pa11y --version
```

Use:
```bash
pa11y http://localhost:3000 --standard WCAG2AA
pa11y http://localhost:3000 --reporter json > pa11y-report.json
```

---

### 5. Mermaid CLI

Diagram generation: flowcharts, sequence diagrams, user flows.

Install:
```bash
npm install -g @mermaid-js/mermaid-cli
```

Test:
```bash
mmdc -V
```

Use:
```bash
mmdc -i diagram.mmd -o diagram.svg
mmdc -i diagram.mmd -o diagram.png -w 1200
```

---

### 6. D2

Architecture and system diagrams.

Install:
```bash
curl -fsSL https://d2lang.com/install.sh | sh
```

Test:
```bash
d2 version
```

Use:
```bash
d2 architecture.d2 architecture.svg
echo 'x -> y' | d2 - output.svg
```

---

### 7. PurgeCSS

Remove unused CSS rules to reduce bundle size.

Install:
```bash
npm install -g purgecss
```

Test:
```bash
purgecss --version
```

Use:
```bash
purgecss --css src/styles.css --content src/**/*.html src/**/*.tsx \
  --output dist/styles.purged.css
```

---

### 8. shadcn/ui CLI

Copy-paste component system for React + Tailwind.

Install:
```bash
# (requires project with React + Tailwind)
npx shadcn-ui@latest init
```

Test:
```bash
npx shadcn-ui@latest --help
```

Use:
```bash
npx shadcn-ui@latest add button
npx shadcn-ui@latest add dialog
npx shadcn-ui@latest add dropdown-menu input card
```

---

### 9. Tailwind CSS CLI

Utility-first CSS framework.

Install:
```bash
npm install -D tailwindcss
```

Test:
```bash
npx tailwindcss --help
```

Use:
```bash
npx tailwindcss init
npx tailwindcss -i src/input.css -o dist/output.css --watch
```

---

### 10. PostCSS CLI

CSS post-processing with plugins.

Install:
```bash
npm install -D postcss postcss-cli autoprefixer
```

Test:
```bash
npx postcss --version
```

Use:
```bash
npx postcss src/styles.css -o dist/styles.css
npx postcss src/styles.css -o dist/styles.css --watch
```

---

### 11. react-docgen

Extract component API documentation from React component source.

Install:
```bash
npm install -g react-docgen
```

Test:
```bash
npx react-docgen --version
```

Use:
```bash
npx react-docgen src/components/Button.tsx -o docs/Button.json
find src/components -name "*.tsx" | xargs -I{} npx react-docgen {} 2>/dev/null
```

---

### 12. Builder.io CLI

Analyze codebase design patterns for consistent AI generation.

Install:
```bash
npm install -g @builder.io/cli
```

Test:
```bash
npx @builder.io/cli --version
```

Use:
```bash
npx @builder.io/cli --help
# Analyzes existing codebase design patterns
```

---

### 13. Anima MCP Server

MCP integration for Claude Code — reads design data and provides AI context.

Install:
```bash
npx @animaapp/mcp-server --help
```

Test:
```bash
npx @animaapp/mcp-server --help
```

Use:
```bash
# Add to Claude Code MCP configuration
# claude mcp add anima -- npx @animaapp/mcp-server
```

---

### 14. open-props

CSS custom properties design system primitives.

Install:
```bash
npm install open-props
```

Test:
```bash
npm ls open-props
```

Use:
```bash
# In CSS
# @import "open-props/style";
# Then use: var(--size-1), var(--font-size-2), etc.
```

---

## PARTIAL_CLI Tools

These require at least one manual/GUI step — noted explicitly.

### Storybook

Component documentation and visual development.

Install:
```bash
npx storybook@latest init
```

Test:
```bash
npm run build-storybook
```

Use:
```bash
npm run storybook
# ⚠️ Manual step: visual review requires browser
# CLI-only: npx build-storybook (headless build)
```

---

### Chromatic

Visual regression testing against Storybook.

Install:
```bash
npx chromatic --help
```

Test:
```bash
npx chromatic --version
```

Use:
```bash
npx chromatic --project-token=<YOUR_TOKEN>
# ⚠️ Manual step: diff review requires browser at chromatic.com
```

---

### v0.dev CLI

Pull pre-built components from v0.dev.

Install:
```bash
npx v0 --help
```

Test:
```bash
npx v0 --version
```

Use:
```bash
npx v0 add [component-url]
# ⚠️ Manual step: component generation is web-only at v0.dev
```

---

## GUI_ONLY Tools

These cannot be used from CLI and require a desktop application.

| Tool | Purpose | Why GUI only |
|------|---------|-------------|
| Tokens Studio | Figma → JSON → Git token sync | Figma plugin only |

---

## Quick Install: Full Design Toolchain

```bash
# Install all FULLY_CLI tools at once
npm install -D style-dictionary tailwindcss postcss postcss-cli autoprefixer
npm install -g @axe-core/cli @lhci/cli pa11y purgecss @mermaid-js/mermaid-cli react-docgen
npm install open-props
curl -fsSL https://d2lang.com/install.sh | sh

# Verify all installed
echo "Style Dictionary:" && npx style-dictionary --version
echo "axe:" && axe --version
echo "Lighthouse CI:" && lhci --version
echo "Pa11y:" && pa11y --version
echo "Mermaid:" && mmdc -V
echo "D2:" && d2 version
echo "PurgeCSS:" && purgecss --version
echo "PostCSS:" && npx postcss --version
```
