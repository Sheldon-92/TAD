# Web UI Design Tool Research

> Date: 2026-04-01
> Environment: macOS ARM64, Node.js, Playwright pre-installed

## Summary Table

| Tool | Type | Install | Works? | Needs Browser? | Notes |
|------|------|---------|--------|----------------|-------|
| pa11y | CLI (npx) | `npx pa11y` | YES | Yes (bundles Puppeteer) | WCAG2AA checker, JSON output, catches contrast + a11y |
| style-dictionary | CLI (npx) | `npx style-dictionary` | YES | No | Design tokens -> CSS variables, clean output |
| svgo | CLI (npx) | `npx svgo` | YES | No | SVG optimizer, 44% reduction in test, fast |
| playwright screenshot | CLI | `playwright screenshot` | YES | Yes (Chromium installed) | HTML->PNG, 1280x720 default, full-page option |
| color-contrast (Node) | Script | Built-in Node.js | YES | No | 15-line script, WCAG AA/AAA checking, zero deps |
| figma-mcp | MCP Server | Figma plugin install | NOT TESTED | N/A (remote) | Read+Write capable, see detailed notes below |

## Detailed Results

### Tool 1: pa11y (Accessibility Checker)

- **Install**: `npx pa11y` (auto-downloads 9.1.1, bundles own Puppeteer)
- **Verify**: `npx pa11y --version` -> 9.1.1
- **Test**: `npx pa11y "file:///path/to/test.html"`
- **Result**: **PASS**
- **Output formats**: Human-readable (default), JSON (`--reporter json`), CSV, HTML
- **What it catches**:
  - Insufficient color contrast (WCAG2AA 4.5:1 threshold)
  - Missing alt attributes on images
  - Missing form labels
  - ARIA violations
  - Many more WCAG2AA rules
- **Browser requirement**: Yes, uses Puppeteer internally. Bundles its own Chromium so it works out of the box with `npx`. No global Chrome needed.
- **JSON output example**:
```json
[
  {
    "code": "WCAG2AA.Principle1.Guideline1_4.1_4_3.G18.Fail",
    "type": "error",
    "message": "This element has insufficient contrast... Expected 4.5:1, got 2.32:1.",
    "context": "<p class=\"low-contrast\">This text has low contrast.</p>",
    "selector": "html > body > p:nth-child(3)"
  }
]
```
- **Registry entry**:
```yaml
pa11y:
  type: cli
  install: npx (auto-download)
  command: "npx pa11y {file} --reporter json"
  input: HTML file (local path or URL)
  output: JSON array of WCAG violations
  needs_browser: true (bundled)
  use_for: accessibility auditing, WCAG compliance checking
```

### Tool 2: style-dictionary (Design Tokens)

- **Install**: `npx style-dictionary` (auto-downloads 5.4.0)
- **Verify**: `npx style-dictionary --version` -> 5.4.0
- **Test**: Created tokens.json + sd-config.json, ran `npx style-dictionary build --config sd-config.json`
- **Result**: **PASS**
- **What it does**: Converts design tokens (JSON) into platform-specific outputs
- **Tested output** (CSS variables):
```css
:root {
  --color-primary: #0066cc;
  --color-secondary: #6c757d;
  --color-success: #28a745;
  --color-danger: #dc3545;
  --color-background: #ffffff;
  --color-text: #333333;
  --spacing-small: 8px;
  --spacing-medium: 16px;
  --spacing-large: 32px;
  --font-family: 'Inter', sans-serif;
  --font-size-base: 16px;
  --font-size-lg: 20px;
}
```
- **Supported output formats**: CSS variables, SCSS, Less, Android XML, iOS Swift, JSON, JS module
- **Browser requirement**: No
- **Registry entry**:
```yaml
style-dictionary:
  type: cli
  install: npx (auto-download)
  command: "npx style-dictionary build --config {config}"
  input: JSON token file + config JSON
  output: CSS variables, SCSS, Less, Android XML, iOS Swift
  needs_browser: false
  use_for: design system token management, cross-platform style generation
```

### Tool 3: svgo (SVG Optimization)

- **Install**: `npx svgo` (auto-downloads 4.0.1)
- **Verify**: `npx svgo --version` -> 4.0.1
- **Test**: `npx svgo test.svg -o test.min.svg`
- **Result**: **PASS**
- **Performance**: 484 bytes -> 269 bytes (44.4% reduction) in 17ms
- **What it removes**: Comments, unused defs/styles, empty elements, redundant attributes, shortens color codes (#0066cc -> #06c)
- **Browser requirement**: No
- **Registry entry**:
```yaml
svgo:
  type: cli
  install: npx (auto-download)
  command: "npx svgo {input} -o {output}"
  input: SVG file
  output: Optimized SVG file
  needs_browser: false
  use_for: SVG optimization, reducing SVG file size for web delivery
```

### Tool 4: playwright screenshot (HTML to Image)

- **Install**: `playwright` (already installed via npm, v1.54.2)
- **Browser**: Requires `npx playwright install chromium` (one-time, ~210MB)
- **Test**: `playwright screenshot "file:///path/to/test.html" screenshot.png --full-page`
- **Result**: **PASS** (after browser install)
- **Output**: PNG 1280x720, 18KB for simple test page
- **Options**: `--full-page`, `--device "iPhone 11"`, `--color-scheme dark`, viewport control
- **Browser requirement**: Yes (Chromium, must be installed separately)
- **Registry entry**:
```yaml
playwright-screenshot:
  type: cli
  install: "npm install -g playwright && npx playwright install chromium"
  command: "playwright screenshot {url} {output} --full-page"
  input: URL or file:// path
  output: PNG screenshot
  needs_browser: true (Chromium must be pre-installed)
  use_for: capturing HTML prototypes as images, visual regression, PDF embedding
```

### Tool 5: Color Contrast Checker

- **Install**: None needed (pure Node.js computation)
- **Test**: Node.js script calculating WCAG contrast ratios
- **Result**: **PASS** (built-in approach)
- **Finding**: No good standalone CLI tool exists. However:
  - pa11y already catches contrast issues in HTML files
  - For raw hex-pair checking, a 15-line Node.js script handles it perfectly
  - The WCAG formula is simple: relative luminance -> contrast ratio -> compare to 4.5:1 (AA) or 7:1 (AAA)
- **Recommendation**: Use pa11y for HTML-level checking. For token-level checking (e.g., verifying a design token palette), embed the formula as a Node.js one-liner in the domain pack workflow.
- **Registry entry**:
```yaml
color-contrast:
  type: script
  install: none (Node.js built-in)
  command: "node -e '{inline WCAG contrast formula}'"
  input: Two hex color values
  output: Contrast ratio + AA/AAA pass/fail
  needs_browser: false
  use_for: verifying color palette accessibility before use in designs
```

### Tool 6: Figma MCP Server

- **Install**: Via Figma plugin (remote MCP server, not local)
- **Test**: NOT TESTED (no Figma MCP configured in this environment)
- **Result**: DOCUMENTED (based on official docs research)

**Read capabilities (confirmed by official docs):**
- `get_design_context` — structured React+Tailwind representation of selected frames
- Extract variables, styles (colors, spacing, typography)
- Map Figma instances to Code Connect components
- Take screenshots of Figma selections

**Write capabilities (remote server only):**
- Create/edit/delete frames, components, variants, variables, styles, text, images
- Build auto layout structures
- Capture web pages into Figma files
- Create new Figma Design or FigJam files

**Key limitations:**
- Remote server required for write capabilities
- Rate limited: 6 calls/month on Starter plan; per-minute limits on paid plans
- Requires Figma plugin installation + auth token

**Registry entry** (already in registry as figma-mcp):
```yaml
figma-mcp:
  type: mcp
  install: "Figma plugin + MCP server config in settings.json"
  capabilities: read (design context, variables, screenshots) + write (frames, components, variables)
  needs_browser: false (remote server)
  use_for: design-to-code, code-to-design, design system sync
  limitations: rate-limited, requires Figma account with Dev/Full seat for full access
```

## Recommended Additions to Web UI Design Domain Pack

### Tier 1 — High Value, Zero Friction
1. **svgo** — SVG optimization. Zero deps, fast, useful for any SVG workflow.
2. **style-dictionary** — Design token management. Critical for design system workflows.
3. **color-contrast (script)** — WCAG contrast checking. Zero deps, embeddable.

### Tier 2 — High Value, Requires Browser
4. **pa11y** — Accessibility auditing. Bundles own Puppeteer, so friction is low.
5. **playwright screenshot** — HTML-to-PNG. Requires Chromium install but very useful for visual review and PDF embedding.

### Tier 3 — Already Registered
6. **figma-mcp** — Already in registry. Research confirms it is read+write capable (not read-only as sometimes assumed). Write requires remote server mode.

## Sources
- [Figma MCP Server Guide](https://help.figma.com/hc/en-us/articles/32132100833559-Guide-to-the-Figma-MCP-server)
- [Figma MCP Tools and Prompts](https://developers.figma.com/docs/figma-mcp-server/tools-and-prompts/)
- [Figma Blog: Claude Code to Figma](https://www.figma.com/blog/introducing-claude-code-to-figma/)
- [Figma MCP Server Guide (GitHub)](https://github.com/figma/mcp-server-guide)
