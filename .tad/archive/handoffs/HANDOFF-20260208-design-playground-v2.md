# Handoff: Design Playground v2 — Independent Command

**From:** Alex (Solution Lead)
**To:** Blake (Execution Master)
**Date:** 2026-02-08
**Task ID:** TASK-20260208-001
**Priority:** P1
**Complexity:** Large (Standard TAD)
**Status:** ✅ COMPLETE (Gate 2 PASS → Gate 3 PASS → Gate 4 PASS)
**Supersedes:** HANDOFF-20260204-curation-playground.md (approach pivot: curation tokens → full page generation)

---

## Expert Review Status

| Expert | Verdict | P0 Issues | P1 Issues |
|--------|---------|-----------|-----------|
| code-reviewer | CONDITIONAL PASS → RESOLVED | 3 (all fixed) | 5 (key items addressed) |
| ux-expert-reviewer | CONDITIONAL PASS → RESOLVED | 4 (all fixed) | 5 (key items addressed) |

### P0 Issues Resolved

**Code Reviewer P0s:**
- P0-1: Command file lacks error handling/session recovery → Added Section 4.8 (Error Handling & Session Recovery) ✅
- P0-2: Style library YAML lacks explicit schema → Added style_schema definition in Section 4.2 ✅
- P0-3: Gallery state management lacks size limits/sync → Added safeguards in Section 4.3 ✅

**UX Expert P0s:**
- P0-4: Missing exit path for "none are good" → Added Escape Path Protocol in Section 4.4 ✅
- P0-5: Version overload without management → Added Active/History/Compare views in Section 4.3 ✅
- P0-6: "Mix" feedback lacks processing flow → Added Fusion Spec protocol in Section 4.4 ✅
- P0-7: Design Spec missing interaction states → Expanded Section 5 in DESIGN-SPEC template (Section 4.5) ✅

**Key P1 Items Addressed:**
- Style Discovery two-tier filtering (Category → Style → Selection) in Section 4.1 Step 2 ✅
- Phase dependency matrix added to Section 6 ✅
- Style library `avoid_for` field added to schema ✅
- Finalization preview step before batch generation added to Section 4.5 ✅
- Cross-platform scope clarified as OUT OF SCOPE for this handoff ✅

---

## Executive Summary

Redesign TAD's Design Playground from a curation-based token picker embedded in Alex's workflow into a **standalone command (`/playground`)** that generates complete Landing Pages for visual exploration.

**Core Shift:**

| Dimension | Old (Curation v1) | New (Generation v2) |
|-----------|-------------------|---------------------|
| Output | Design Tokens (colors/fonts) | Complete Landing Page HTML |
| Method | Pick from pre-built library | Generate full pages from style directions |
| Quantity | 2-3 color schemes | 3+ complete pages per round, unlimited rounds |
| Ownership | Sub-phase of Alex's *design | Independent command, platform-agnostic |
| Selection | Choose a palette | Choose a whole page's *feel* |
| Iteration | Max 2 rounds | Until user is satisfied |
| Post-selection | Export tokens for Blake | Expand to multi-page prototype → design spec |

**Why the change:** The curation approach never ran successfully in practice. It tried to make Alex (a requirements/architecture agent) do aesthetic work. The new approach:
1. Makes Playground a first-class command with its own clear workflow
2. Generates complete visual artifacts users can actually see and compare
3. Uses a rich style library (30+ directions) as the foundation for generation
4. Supports iterative refinement through structured feedback collection
5. Is platform-agnostic but optimized for Gemini (strongest at frontend generation)

---

## 📋 Handoff Checklist (Blake必读)

- [ ] Read all sections
- [ ] Read "Project Knowledge" section
- [ ] Understand the 6-step workflow (Section 4.1)
- [ ] Understand the Style Library structure (Section 4.2)
- [ ] Understand the Gallery HTML architecture (Section 4.3)
- [ ] Understand the feedback collection mechanism (Section 4.4)
- [ ] Confirm you can independently complete implementation

❌ If anything is unclear, **return to Alex immediately**.

---

## 1. Task Overview

### 1.1 What We're Building

A standalone `/playground` command that:
1. Understands the project context
2. Presents design style directions from a comprehensive library
3. Generates 3 complete Landing Pages per round in different styles
4. Displays all versions in a single HTML with tab switching (auto-opens in browser)
5. Collects user feedback through structured questions + open discussion
6. Iterates until user is satisfied
7. Expands confirmed direction into multi-page prototypes
8. Outputs design specification + prototype HTML for Blake's implementation

### 1.2 Why We're Building It

**Business Value**: Non-designer users cannot visualize designs from text descriptions, leading to 8+ iteration cycles during implementation.

**User Benefit**: See real, browsable Landing Pages before any code is written. Choose from multiple aesthetically distinct options.

**Success Criteria**: When a user can run `/playground`, browse generated pages, provide feedback, and get a confirmed design direction with spec — all before implementation starts.

### 1.3 Intent Statement

**The real problem**: There's no efficient way to establish visual direction for a project. Text-based design descriptions don't convey aesthetics. Users need to *see* options.

**Not doing:**
- ❌ Not building a Figma replacement
- ❌ Not generating complex graphics, logos, or illustrations
- ❌ Not replacing Alex or Blake — this is a pre-implementation design exploration tool
- ❌ Not tied to any specific AI model (works with any, optimized for Gemini)

---

## 📚 Project Knowledge (Blake必读)

### Relevant Categories
- [x] architecture - TAD command system, config module architecture
- [x] ux - Design iteration pain points
- [x] frontend-design - (will be created by this feature)

### Historical Lessons

1. **Cognitive Firewall: Embed Into Existing Flows** (from architecture.md)
   - Problem: Cross-cutting concerns fail when created as standalone modules that can be forgotten
   - Relevance: /playground IS standalone, but its outputs must integrate into Alex's handoff flow
   - Action: Ensure clear integration points with TAD workflow

2. **Gate Responsibility Matrix** (from architecture.md)
   - Problem: Unclear ownership between Alex and Blake causes confusion
   - Relevance: /playground is neither Alex nor Blake — needs clear ownership definition
   - Action: Define playground as an independent agent with clear input/output contracts

---

## 2. Background Context

### 2.1 Previous Work

- `HANDOFF-20260204-frontend-playground.md` — Original generation-based approach (archived)
- `HANDOFF-20260204-curation-playground.md` — Curation-based approach (archived, superseded by this)
- Existing assets that may be partially reusable:
  - `.tad/references/design-curations.yaml` — Has 5 palettes, 5 fonts, 3 presets (too narrow, needs replacement)
  - `.tad/templates/playground-template.html` — 1,340 line HTML template (needs major rewrite for new architecture)
  - `.tad/templates/playground-guide.md` — Alex's curation guide (needs rewrite)
  - `.tad/templates/design-tokens-template.md` — Token export format (may be reusable for final output)

### 2.2 Current State

- Playground protocol exists in `tad-alex.md` but has never successfully executed end-to-end
- All existing playground directories are empty (no archived outputs)
- PROJECT_CONTEXT.md notes: "Playground: Running suboptimally, Alex doesn't fully understand user intent"

### 2.3 Key Design Decision

**Generation over Curation:** User explicitly chose this direction based on practical experience. The curation approach (pick color tokens from a library) produced outputs that were too abstract. Users need to see **complete pages**, not color swatches.

---

## 3. Requirements

### 3.1 Functional Requirements

- **FR1**: `/playground` command activates a Design Playground agent with its own persona and workflow
- **FR2**: Agent reads project context (package.json, README, existing code) to understand the project
- **FR3**: Agent presents style directions from a comprehensive library (30+ styles) and recommends fitting ones
- **FR4**: Agent generates 3 complete Landing Pages per round, each in a distinct visual style
- **FR5**: All generated pages are displayed in a single HTML file with tab/button switching
- **FR6**: HTML file auto-opens in the user's default browser
- **FR7**: Every generated version has a unique name and is permanently preserved (version history)
- **FR8**: After each round, agent collects feedback using mixed mode (structured questions + open discussion)
- **FR9**: Agent iterates (generates new versions) until user confirms a direction
- **FR10**: Once direction is confirmed, agent expands to additional pages based on project needs
- **FR11**: Final output includes design specification document + confirmed HTML prototypes
- **FR12**: All outputs stored in `.tad/` directory structure

### 3.2 Non-Functional Requirements

- **NFR1**: Pure HTML+CSS design — no complex image generation, logos, or illustrations required
- **NFR2**: Platform-agnostic command definition — works on Claude Code, Gemini CLI, Codex CLI
- **NFR3**: Each Landing Page should be self-contained HTML (inline CSS, no external dependencies)
- **NFR4**: Gallery HTML must work offline (no CDN dependencies for core functionality)
- **NFR5**: Style library YAML should be human-readable and extensible
- **NFR6**: Command must not depend on Alex or Blake being active

---

## 4. Technical Design

### 4.1 Workflow: The 6-Step Playground Loop

```
┌──────────────────────────────────────────────────────────┐
│                   /playground                             │
│                                                          │
│  Step 1: UNDERSTAND                                      │
│  ├─ Read project files (package.json, README, etc.)      │
│  ├─ Identify project type (SaaS, consumer, portfolio...) │
│  └─ Summarize to user: "This is a ____ project"          │
│                                                          │
│  Step 2: DISCOVER (Two-Tier Filtering)                    │
│  ├─ Load style library (.tad/references/design-styles.yaml) │
│  ├─ Tier 1: Present 7 CATEGORIES with descriptions        │
│  │   → User picks 2-3 categories of interest               │
│  ├─ Tier 2: Show styles within chosen categories           │
│  │   → User picks 3 styles for generation                  │
│  ├─ Optional: WebSearch for latest trends + award winners │
│  └─ Present final selection to user for confirmation       │
│                                                          │
│  Step 3: GENERATE                                        │
│  ├─ User picks 3 directions (or agent recommends)        │
│  ├─ Generate 3 complete Landing Pages (HTML+CSS)         │
│  ├─ Add to gallery HTML (tab switching)                  │
│  └─ Auto-open in browser                                 │
│                                                          │
│  Step 4: COLLECT FEEDBACK                                │
│  ├─ Structured questions:                                │
│  │   "Overall favorite?", "Best color scheme?",          │
│  │   "Best layout?", "Any specific element you love?"    │
│  ├─ Open discussion for nuanced feedback                 │
│  └─ Synthesize: user preference profile                  │
│                                                          │
│  Step 5: ITERATE (loop back to Step 3 if needed)         │
│  ├─ Generate 3 new versions based on feedback            │
│  ├─ Append to gallery (old versions preserved)           │
│  └─ Repeat until user says "I'm happy with version X"   │
│                                                          │
│  Step 6: FINALIZE                                        │
│  ├─ User confirms final direction                        │
│  ├─ Expand: generate additional pages (project-specific) │
│  ├─ Output: Design Specification + Prototype HTML files  │
│  └─ Store in .tad/active/playground/                     │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

### 4.2 Style Library Structure

**File:** `.tad/references/design-styles.yaml` (replaces `design-curations.yaml`)

```yaml
# Design Styles Library v2.0
# 30+ aesthetic directions for Design Playground
# Each style = complete aesthetic language (not just colors)

metadata:
  version: "2.0"
  total_styles: 30+
  last_updated: "2026-02-08"
  categories: 7

# Reference sources for best practices
reference_sources:
  awards:
    - name: "Awwwards"
      url: "https://www.awwwards.com/"
      use: "Award-winning website examples per style"
    - name: "CSS Design Awards"
      url: "https://www.cssdesignawards.com/"
      use: "CSS-focused design excellence"
    - name: "DesignRush"
      url: "https://www.designrush.com/best-designs/websites"
      use: "Best website designs by category"
    - name: "A' Design Award"
      url: "https://competition.adesignaward.com/"
      use: "International design recognition"

styles:
  # ── Classic Movements ──
  bauhaus:
    name: "Bauhaus"
    category: "classic"
    era: "1920s origin, timeless"
    mood: "Functional, geometric, purposeful"
    description: "Form follows function. Geometric forms, modular composition, primary colors."
    visual:
      colors: "Primary colors (red, blue, yellow) + black/white"
      typography: "Sans-serif, functional, strong hierarchy"
      layout: "Grid-based, asymmetric, modular blocks"
      components: "Clean geometric shapes, strong alignment"
    best_for: ["developer tools", "productivity apps", "design tools"]
    reference_products: ["Stripe", "Linear"]
    reference_urls: []  # To be populated by runtime search

  swiss_international:
    name: "Swiss/International Typographic Style"
    category: "classic"
    # ... (full definition for each style)

  art_deco:
    name: "Art Deco"
    category: "classic"
    era: "1920s-1930s"
    mood: "Luxurious, glamorous, bold geometry"
    # ...

  art_nouveau:
    name: "Art Nouveau"
    category: "classic"
    mood: "Organic, flowing, elegant"
    # ...

  constructivism:
    name: "Constructivism"
    category: "classic"
    mood: "Bold, dynamic, urgent"
    # ...

  # ── Modern UI ──
  glassmorphism:
    name: "Glassmorphism"
    category: "modern_ui"
    mood: "Light, layered, contemporary"
    # ...

  neumorphism:
    name: "Neumorphism"
    category: "modern_ui"
    mood: "Soft, tactile, refined"
    # ...

  neobrutalism:
    name: "Neobrutalism"
    category: "modern_ui"
    mood: "Bold, raw, confrontational"
    # ...

  flat_design:
    name: "Flat Design"
    category: "modern_ui"
    mood: "Clean, efficient, crisp"
    # ...

  skeuomorphism:
    name: "Skeuomorphism"
    category: "modern_ui"
    mood: "Familiar, tactile, realistic"
    # ...

  # ── Minimal Spectrum ──
  minimalism:
    name: "Minimalism"
    category: "minimal"
    mood: "Calm, focused, intentional"
    # ...

  expressive_minimalism:
    name: "Expressive Minimalism"
    category: "minimal"
    mood: "Restrained but bold"
    # ...

  geominimalism:
    name: "Geominimalism"
    category: "minimal"
    mood: "Geometric, earthy, calm"
    # ...

  japanese_minimalism:
    name: "Japanese Minimalism (Wabi-Sabi)"
    category: "minimal"
    mood: "Imperfect beauty, natural, serene"
    # ...

  # ── Retro & Nostalgic ──
  retro_vintage:
    name: "Retro Vintage"
    category: "retro"
    mood: "Nostalgic, warm, textured"
    # ...

  y2k_evolution:
    name: "Y2K Evolution"
    category: "retro"
    mood: "Metallic, holographic, playful nostalgia"
    # ...

  retrofuturism:
    name: "Retrofuturism"
    category: "retro"
    mood: "Past visions of future, neon, chrome"
    # ...

  american_kitsch:
    name: "American Kitsch"
    category: "retro"
    mood: "Campy, playful, ironic nostalgia"
    # ...

  eighties_electronic:
    name: "80s Electronic / Synthwave"
    category: "retro"
    mood: "Neon grids, sunset gradients, digital nostalgia"
    # ...

  # ── Expressive & Bold ──
  new_maximalism:
    name: "New Maximalism"
    category: "expressive"
    mood: "Vibrant, chaotic energy, abundant"
    # ...

  psychedelic:
    name: "Psychedelic"
    category: "expressive"
    mood: "Trippy, swirling, consciousness-exploring"
    # ...

  punk:
    name: "Punk"
    category: "expressive"
    mood: "Raw, rebellious, DIY"
    # ...

  grunge:
    name: "Grunge"
    category: "expressive"
    mood: "Distressed, dark, authentic"
    # ...

  modern_surrealism:
    name: "Modern Surrealism"
    category: "expressive"
    mood: "Dreamlike, unexpected, imaginative"
    # ...

  # ── 2026 Trends ──
  bento_grid:
    name: "Bento Grid"
    category: "trending"
    mood: "Organized, modular, compartmentalized"
    # ...

  kinetic_typography:
    name: "Kinetic Typography"
    category: "trending"
    mood: "Dynamic, animated, expressive text"
    # ...

  scroll_storytelling:
    name: "Scroll Storytelling"
    category: "trending"
    mood: "Cinematic, narrative, immersive"
    # ...

  organic_anti_grid:
    name: "Organic / Anti-Grid"
    category: "trending"
    mood: "Fluid, natural, asymmetric"
    # ...

  dark_mode_first:
    name: "Dark Mode First"
    category: "trending"
    mood: "Sleek, modern, eye-friendly"
    # ...

  # ── Futuristic ──
  pop_futurism:
    name: "Pop Futurism"
    category: "futuristic"
    mood: "Optimistic future, neon, playful tech"
    # ...

  cyberpunk:
    name: "Cyberpunk"
    category: "futuristic"
    mood: "High tech, low life, neon dystopia"
    # ...

  tech_mono:
    name: "Technical Mono"
    category: "futuristic"
    mood: "Developer aesthetic, monospace, raw data"
    # ...

# Category index for quick filtering
categories:
  classic:
    label: "Classic Movements"
    description: "Timeless design philosophies from art/architecture history"
    styles: [bauhaus, swiss_international, art_deco, art_nouveau, constructivism]

  modern_ui:
    label: "Modern UI Styles"
    description: "Contemporary digital-native design approaches"
    styles: [glassmorphism, neumorphism, neobrutalism, flat_design, skeuomorphism]

  minimal:
    label: "Minimal Spectrum"
    description: "Various approaches to 'less is more'"
    styles: [minimalism, expressive_minimalism, geominimalism, japanese_minimalism]

  retro:
    label: "Retro & Nostalgic"
    description: "Past eras reimagined for the web"
    styles: [retro_vintage, y2k_evolution, retrofuturism, american_kitsch, eighties_electronic]

  expressive:
    label: "Expressive & Bold"
    description: "High-energy, rule-breaking aesthetics"
    styles: [new_maximalism, psychedelic, punk, grunge, modern_surrealism]

  trending:
    label: "2026 Trends"
    description: "Current and emerging design directions"
    styles: [bento_grid, kinetic_typography, scroll_storytelling, organic_anti_grid, dark_mode_first]

  futuristic:
    label: "Futuristic"
    description: "Forward-looking tech-inspired aesthetics"
    styles: [pop_futurism, cyberpunk, tech_mono]
```

**Style Schema (Required/Optional Fields):**

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| `name` | ✅ | string | Display name |
| `category` | ✅ | enum | One of 7 categories |
| `mood` | ✅ | string | 3-5 word mood descriptor |
| `description` | ✅ | string | 1-2 sentence description |
| `visual.colors` | ✅ | string | Color palette description |
| `visual.typography` | ✅ | string | Font/type approach |
| `visual.layout` | ✅ | string | Layout structure |
| `visual.components` | ✅ | string | Component styling approach |
| `best_for` | ✅ | list[string] | Project types this style fits |
| `avoid_for` | ✅ | list[string] | Project types this style is poor for |
| `reference_products` | ✅ | list[string] | Known products using this style |
| `era` | optional | string | Historical period |
| `reference_urls` | optional | list[string] | Live examples (populated at runtime) |

**Validation rule**: Blake MUST validate at build time that every style entry has all required fields populated. Any style missing required fields → build error.

**Note:** Each style entry will be fully populated with detailed `visual` properties (colors, typography, layout, components), `best_for` tags, `avoid_for` tags, `reference_products`, and `reference_urls`. The YAML shown above is the structure — Blake will populate all fields during implementation.

### 4.3 Gallery HTML Architecture

**Single HTML file with version management:**

```
.tad/active/playground/PLAYGROUND-{YYYYMMDD}-{project-slug}/
├── gallery.html          # Single file, all versions with tab switching
├── versions/
│   ├── v1-bauhaus.html         # Individual version (standalone)
│   ├── v2-neobrutalism.html
│   ├── v3-minimalism.html
│   └── ...
└── playground-state.json  # Version history + user feedback log
```

**Gallery HTML key features:**
- **Fixed top nav**: Version tabs (v1: "Bauhaus", v2: "Neobrutalism", v3: "Minimalism"...)
- **Tab switching**: Click tab → shows that version's Landing Page inline (iframe or embedded)
- **Version counter**: "Showing 6 versions (Round 1: v1-v3, Round 2: v4-v6)"
- **Star/favorite button**: User can star versions they like (state saved to playground-state.json)
- **Auto-open**: After generation, run `open gallery.html` (macOS) to open in default browser
- **Append-only**: New rounds ADD tabs, never remove old ones

**Version Management Strategy:**

The gallery uses a two-view system to prevent version overload:

| View | Scope | Behavior |
|------|-------|----------|
| **Active View** (default) | Latest round only | Shows only the 3 newest versions as tabs |
| **History View** | All rounds | Expandable accordion: "Round 1 (v1-v3)", "Round 2 (v4-v6)", etc. |
| **Compare Mode** | User-selected | Pick any 2 versions side-by-side (split screen) |

Toggle between views via buttons in the gallery header. Active View prevents cognitive overload while History View preserves full access.

**State Management Safeguards:**

| Safeguard | Rule |
|-----------|------|
| `max_versions` | 30 (10 rounds × 3). After 30 versions, agent prompts: "You've explored 30 versions. Ready to choose, or should we narrow down?" |
| `atomic_writes` | Write to `.playground-state.tmp.json` then rename to `playground-state.json` (prevents corruption on crash) |
| `sync_validation` | On each round start, verify `playground-state.json` version count matches actual `versions/*.html` file count. Mismatch → warn user + auto-repair |
| `backup` | Before each write, copy current state to `playground-state.backup.json` |

**playground-state.json:**
```json
{
  "project": "project-slug",
  "created": "2026-02-08",
  "rounds": [
    {
      "round": 1,
      "versions": [
        {"id": "v1", "name": "Bauhaus Landing", "style": "bauhaus", "starred": false},
        {"id": "v2", "name": "Neobrutalist Landing", "style": "neobrutalism", "starred": true},
        {"id": "v3", "name": "Minimal Landing", "style": "minimalism", "starred": false}
      ],
      "feedback": {
        "overall_favorite": "v2",
        "best_colors": "v1",
        "best_layout": "v2",
        "notes": "Like v2's bold typography but want v1's color restraint"
      }
    }
  ],
  "confirmed_version": null,
  "confirmed_at": null
}
```

### 4.4 Feedback Collection Mechanism

After each round of generation, the agent conducts a **mixed-mode feedback session**:

**Phase A: Structured Questions (3-4 questions)**

```
Questions to ask after user browses the generated pages:

1. "Which version's overall feeling is closest to what you want?"
   Options: [v1: {name}], [v2: {name}], [v3: {name}], [None — need different direction]

2. "Which version has the best color scheme?"
   Options: [v1], [v2], [v3], [None of them]

3. "Which version's layout/typography feels right?"
   Options: [v1], [v2], [v3], [Mix — explain below]

4. "Any specific section or element you particularly like?"
   Options: [Hero section of vX], [Card layout of vX], [Footer of vX], [Let me describe...]
```

**Phase B: Open Discussion**

After structured questions, open the floor:
> "Based on your answers, it seems like you prefer {synthesis}. Anything else you'd like to adjust? Any elements from other versions you want to keep?"

**Phase C: Decision Point**

```
"Ready to decide, or want another round?"
Options:
  - "Confirm version X as the direction" → proceed to Step 6 (Finalize)
  - "Generate 3 more versions" → loop back with refined style targeting
  - "Combine elements from version X and Y" → agent creates a fusion version (see Fusion Spec below)
  - "None of these work — try completely different styles" → Escape Path (see below)
```

**Escape Path Protocol (P0 Fix):**

When user selects "None of these work" or expresses dissatisfaction with all versions:

1. **Acknowledge**: "Got it — none of these hit the mark. Let's reset direction."
2. **Diagnose**: Ask 2 targeted questions:
   - "What specifically felt wrong? (e.g., too corporate, too playful, wrong era)"
   - "Can you name a website or app whose look you admire?"
3. **Pivot**: Return to Step 2 (DISCOVER) with updated filters:
   - Exclude styles from previous rounds (`tried_styles` list in state JSON)
   - If user named a reference, agent WebSearches it and identifies matching styles
4. **Safety valve**: After 3 consecutive "none work" rounds, agent suggests:
   - "We've tried {N} styles across {categories}. Would you like to describe your ideal look in your own words? I'll generate from your description instead of the library."
   - This switches to **freeform generation mode** (no library constraint)

**Fusion Spec Protocol (P0 Fix):**

When user selects "Combine elements from version X and Y":

1. **Decompose**: Agent asks which specific elements to take from each:
   ```
   "Let's build your fusion version. For each element, which version should I take from?"
   - Color scheme: [vX] or [vY]?
   - Typography: [vX] or [vY]?
   - Layout structure: [vX] or [vY]?
   - Hero section style: [vX] or [vY]?
   - Component style (buttons, cards): [vX] or [vY]?
   ```
2. **Synthesize**: Agent generates a single fusion version and names it "vN-fusion-{X}+{Y}"
3. **Present**: Add to gallery as a new version, auto-open
4. **Iterate**: Return to Phase A feedback on the fusion result

### 4.5 Finalization & Output

When user confirms a direction:

**Step 6a: Preview before committing**
- Agent shows a summary of the confirmed direction:
  ```
  Confirmed Direction:
  - Style: {style name} (from version {vN})
  - Key elements: {color scheme source}, {typography source}, {layout source}
  - Feedback incorporated: {summary of refinements}

  Ready to expand to full prototype? (Yes / Adjust first)
  ```
- User confirms → proceed to expansion. User says "Adjust" → return to feedback loop.

**Step 6b: Expand to multi-page prototype**
- Agent asks: "What pages does your project need?"
- Agent suggests based on project type (e.g., SaaS → Landing, Features, Pricing, About, Contact)
- User confirms page list
- Agent generates each page in the confirmed style

**Step 6c: Generate Design Specification**

Output file: `.tad/active/playground/PLAYGROUND-{date}-{slug}/DESIGN-SPEC.md`

```markdown
# Design Specification: {Project Name}

## 1. Design Direction
- **Selected Style**: {style name}
- **Based on Version**: {version id}
- **Mood**: {mood description}

## 2. Color System
- Primary: {hex}
- Secondary: {hex}
- Accent: {hex}
- Background: {hex}
- Surface: {hex}
- Text Primary: {hex}
- Text Secondary: {hex}
- Error/Success/Warning: {hex values}

## 3. Typography
- Headings: {font family}, {weights}
- Body: {font family}, {weights}
- Code/Mono: {font family}
- Scale: {size scale}

## 4. Spacing & Layout
- Base unit: {px}
- Grid: {description}
- Breakpoints: {values}

## 5. Component Patterns
- Buttons: {description + reference to prototype}
  - States: default, hover, active, disabled, loading
- Cards: {description}
  - States: default, hover, expanded (if applicable)
- Navigation: {description}
  - States: default, active link, mobile hamburger, scrolled (sticky)
- Forms: {description}
  - States: empty, focused, filled, error, success, disabled
- Footer: {description}
- Modals/Overlays: {description if applicable}
  - States: opening animation, open, closing

## 6. Reference
- Prototype HTML files: {list of files}
- Selected version: {path}
- Style library entry: {style key}
- Inspiration sources: {URLs}

## 7. For Blake
- Use this specification when implementing the frontend
- Prototype HTML files serve as visual reference (not production code)
- Maintain consistency with the confirmed style across all pages
```

**Step 6d: Update project knowledge**
- Write/update `.tad/project-knowledge/frontend-design.md` with the confirmed design direction

### 4.6 Command Definition

**File:** `.claude/commands/playground.md`

The command file defines:
- Agent persona: "Design Explorer" — focused on visual aesthetics and design
- Activation protocol: Read style library → Read project context → Greet → Show available styles
- 6-step workflow (as defined in 4.1)
- Not tied to Alex or Blake — independent agent
- Clear input (project files) and output (design spec + prototypes in .tad/)

**Integration with TAD:**
- Alex can reference playground outputs in handoffs: "See `.tad/active/playground/` for design spec"
- Blake implements according to the design spec
- On `*accept`, playground directory archived with handoff

### 4.7 Platform Compatibility

The command definition is a markdown file. For non-Claude platforms:
- **Gemini CLI**: Convert to .toml format (via /tad-init)
- **Codex CLI**: Convert to prompt file format (via /tad-init)

The style library (YAML) and gallery HTML are platform-agnostic.

### 4.8 Error Handling & Session Recovery (P0 Fix)

**Crash Recovery:**

The playground agent must be resumable. If the session crashes or the user closes the terminal:

| Scenario | Recovery Mechanism |
|----------|-------------------|
| Crash during generation | `playground-state.json` tracks `current_step` field. On `/playground` re-activation, agent detects existing state and asks: "Found an in-progress playground session for {project}. Resume or start fresh?" |
| Crash during feedback | Feedback is written to state JSON after each Phase (A, B, C separately). Partial feedback is preserved. |
| Crash during finalization | `finalization_started` flag in state JSON. Agent detects and resumes from last completed step. |
| User closes terminal | State file persists. Next `/playground` invocation auto-detects. |

**Session State Fields (added to playground-state.json):**
```json
{
  "session_status": "active|paused|completed",
  "current_step": "discover|generate|feedback|finalize",
  "last_updated": "ISO-8601 timestamp",
  "tried_styles": ["bauhaus", "minimalism", ...],
  "finalization_started": false,
  "finalization_step": null
}
```

**Terminal Isolation Enforcement:**

The `/playground` command runs in its own terminal context. It MUST NOT:
- ❌ Call `/alex` or `/blake`
- ❌ Modify handoff files directly
- ❌ Create or modify any files outside `.tad/active/playground/` and `.tad/references/`

Integration with Alex/Blake is through output files only (DESIGN-SPEC.md), not through direct invocation.

**Error Categories & Handling:**

| Error | Handling |
|-------|----------|
| YAML parse error in style library | Agent reports specific line, suggests fix, falls back to embedded minimal style set |
| Gallery HTML write failure | Retry once, then report to user with file path |
| Browser auto-open fails | Print file path and instruct user to open manually |
| State JSON corruption | Restore from `playground-state.backup.json`, warn user |
| WebSearch fails (offline) | Skip reference URL population, proceed with library styles only |

---

## 5. Mandatory Questions (Evidence Required)

### MQ1: Historical Code Search

**Question**: Does the user mention "previous" or "existing" approaches?

**Answer**: ✅ Yes — extensive previous work exists.

**Search Evidence:**
```bash
# Existing playground-related files
.tad/references/design-curations.yaml        # 500 lines, pre-built design library
.tad/templates/playground-template.html       # 1,340 lines, HTML template
.tad/templates/playground-guide.md            # 216 lines, curation guide
.tad/templates/design-tokens-template.md      # 254 lines, token export format
.tad/archive/handoffs/HANDOFF-20260204-curation-playground.md    # Previous handoff
.tad/archive/handoffs/HANDOFF-20260204-frontend-playground.md    # Original handoff
```

**Decision**: ❌ Create new (with selective reuse)
- `design-curations.yaml` → REPLACE with `design-styles.yaml` (fundamentally different structure)
- `playground-template.html` → REPLACE with gallery HTML (different architecture)
- `playground-guide.md` → REPLACE with new command guide
- `design-tokens-template.md` → REUSE as reference for final design spec output format

### MQ2: Function Existence Verification

| Function/File | Location | Status | Notes |
|---------------|----------|--------|-------|
| `/playground` command | `.claude/commands/playground.md` | ❌ New | To be created |
| `design-styles.yaml` | `.tad/references/` | ❌ New | Replaces design-curations.yaml |
| Gallery HTML template | `.tad/templates/` | ❌ New | Replaces playground-template.html |
| `playground-state.json` | Runtime | ❌ New | Generated per playground session |
| DESIGN-SPEC.md | Runtime | ❌ New | Generated on finalization |

### MQ3: Data Flow

```
Style Library (YAML)
    ↓ Agent reads + filters by project type
User Selection (3 styles)
    ↓ Agent generates HTML
Gallery HTML (single file, tab switching)
    ↓ User browses in browser
Feedback (structured + open)
    ↓ Agent synthesizes
New Generation (refined styles)
    ↓ Appended to gallery
... iterate ...
    ↓ User confirms
Design Spec (markdown) + Prototype HTML files
    ↓ Stored in .tad/active/playground/
Alex references in Handoff → Blake implements
```

### MQ5: State Management

| Data | Storage | Source of Truth | Sync |
|------|---------|----------------|------|
| Style definitions | `.tad/references/design-styles.yaml` | YAML file | Static, manual updates |
| Generated versions | `versions/*.html` | HTML files | Append-only |
| Gallery state | `playground-state.json` | JSON file | Updated each round |
| User feedback | `playground-state.json` | JSON file | Updated each round |
| Final design spec | `DESIGN-SPEC.md` | Markdown file | Written once on finalize |

✅ Single source of truth per data type. No dual-state sync issues.

---

## 6. Implementation Steps

### Phase Dependency Matrix

```
Phase 1 ──→ Phase 2 ──→ Phase 3 ──→ Phase 4
(Foundation)  (Gallery)   (Feedback)  (Cleanup)
```

| Phase | Depends On | Blocking For | Can Parallelize With |
|-------|-----------|-------------|---------------------|
| Phase 1 | None | Phase 2, 3, 4 | — |
| Phase 2 | Phase 1 (needs style YAML + command file) | Phase 3 | — |
| Phase 3 | Phase 2 (needs gallery template + generation protocol) | Phase 4 | — |
| Phase 4 | Phase 3 (cleanup only after end-to-end works) | None | — |

**Strictly sequential**: Each phase depends on the previous one. No parallelization possible because:
- Phase 2 needs the style YAML from Phase 1 to define how styles map to HTML generation
- Phase 3 needs the gallery from Phase 2 to build the feedback loop on top of it
- Phase 4 is cleanup — only safe after the full flow works end-to-end

### Phase 1: Style Library + Command Shell (Core Foundation)

#### Deliverables
- [ ] `.tad/references/design-styles.yaml` — Complete style library with 30+ styles, fully populated
- [ ] `.claude/commands/playground.md` — Command definition with agent persona + workflow
- [ ] `.tad/config-workflow.yaml` — Add playground v2 section
- [ ] Update `config.yaml` command binding for playground

#### Implementation Steps
1. Create `design-styles.yaml` with all 30+ styles fully populated:
   - Each style: name, category, era, mood, description, visual (colors, typography, layout, components), best_for, reference_products, reference_urls
   - 7 categories: classic, modern_ui, minimal, retro, expressive, trending, futuristic
   - For reference_urls: search Awwwards/CSS Design Awards for 2-3 exemplary sites per style
2. Create `playground.md` command file:
   - Agent persona: "Design Explorer"
   - 6-step workflow protocol
   - Style library loading instructions
   - Feedback collection protocol
   - Finalization protocol
3. Update config files to register the new command

#### Verification
- `design-styles.yaml` loads without YAML syntax errors
- Command file has complete workflow definition
- Config files reference the new command

### Phase 2: Gallery HTML Template + Generation Protocol

#### Deliverables
- [ ] `.tad/templates/gallery-template.html` — Gallery shell with tab switching, version management
- [ ] Generation protocol in command file — How agent generates Landing Pages
- [ ] Auto-open mechanism documented

#### Implementation Steps
1. Create gallery HTML template:
   - Fixed top nav with version tabs
   - Iframe or embedded content area for each version
   - Star/favorite buttons per version
   - Version counter + round indicator
   - Responsive design
   - JavaScript for tab switching, star toggling
   - No external dependencies (self-contained)
2. Define the generation protocol in command file:
   - How to read a style entry and generate a complete Landing Page
   - Landing Page HTML structure (hero, features, testimonials, CTA, footer)
   - How to apply style's visual properties (colors, typography, layout)
   - How to add new versions to gallery (append tabs, update state JSON)
3. Document the `open` command mechanism for macOS/Linux/Windows

#### Verification
- Gallery HTML opens in browser and tab switching works
- New tabs can be added without breaking existing ones

### Phase 3: Feedback Collection + Iteration + Finalization

#### Deliverables
- [ ] Feedback collection protocol fully defined in command file
- [ ] Iteration loop logic (when to regenerate, how to refine)
- [ ] Finalization protocol: expand to multi-page + generate DESIGN-SPEC.md
- [ ] `playground-state.json` schema and management logic
- [ ] Integration points with TAD workflow documented

#### Implementation Steps
1. Define feedback question templates in command file
2. Define how feedback maps to next-round style targeting
3. Define finalization workflow:
   - Multi-page expansion (ask user what pages, generate each)
   - DESIGN-SPEC.md generation (extract from confirmed version)
   - project-knowledge update
4. Define playground-state.json read/write protocol
5. Document integration:
   - How Alex references playground outputs in handoffs
   - How playground directory is archived on `*accept`
   - Update `tad-alex.md` to remove embedded playground protocol (replaced by standalone command)

#### Verification
- End-to-end flow: `/playground` → browse → feedback → iterate → confirm → spec output
- State JSON correctly tracks all versions and feedback
- Design spec contains all necessary information for Blake

### Phase 4: Cleanup + Migration

#### Deliverables
- [ ] Remove/archive old playground protocol from `tad-alex.md`
- [ ] Archive old `design-curations.yaml` (keep for reference)
- [ ] Archive old `playground-template.html`
- [ ] Archive old `playground-guide.md`
- [ ] Update `CLAUDE.md` if playground is referenced
- [ ] Update `PROJECT_CONTEXT.md`
- [ ] Update `NEXT.md`

#### Implementation Steps
1. In `tad-alex.md`: Remove `playground_protocol` section, replace with reference to `/playground` command
2. In `tad-alex.md`: Update `design_protocol` to remove playground sub-steps, add reference to standalone command
3. Archive old files to `.tad/archive/playground/legacy-v1/`
4. Update project documentation

#### Verification
- `tad-alex.md` no longer contains playground execution logic
- `/playground` command works independently
- No broken references in any TAD config files

---

## 7. File Structure

### 7.1 Files to Create
```
.claude/commands/playground.md                    # New standalone command
.tad/references/design-styles.yaml                # New comprehensive style library
.tad/templates/gallery-template.html              # New gallery HTML with tab switching
```

### 7.2 Files to Modify
```
.tad/config.yaml                                  # Add playground command binding
.tad/config-workflow.yaml                         # Update playground section
.claude/commands/tad-alex.md                      # Remove embedded playground protocol
```

### 7.3 Files to Archive
```
.tad/references/design-curations.yaml             → .tad/archive/playground/legacy-v1/
.tad/templates/playground-template.html           → .tad/archive/playground/legacy-v1/
.tad/templates/playground-guide.md                → .tad/archive/playground/legacy-v1/
```

### 7.4 Files to Keep (Reusable)
```
.tad/templates/design-tokens-template.md          # Reference for DESIGN-SPEC.md format
```

---

## 8. Testing Requirements

### 8.1 Style Library Validation
- YAML parses without errors
- All 30+ styles have complete `visual` properties
- All categories are correctly indexed
- `best_for` tags cover common project types

### 8.2 Gallery HTML Testing
- Opens in Chrome, Safari, Firefox
- Tab switching works with 3, 6, 9, 12 tabs
- Star/favorite toggle works
- Responsive on mobile viewport
- No external dependency failures (offline test)

### 8.3 Command Integration Testing
- `/playground` activates correctly
- Agent can read and filter style library
- Agent persona is distinct from Alex/Blake

### 8.4 End-to-End Flow
- Complete flow from `/playground` to DESIGN-SPEC.md generation
- Version history preserved across multiple rounds
- Feedback correctly influences next-round generation

---

## 9. Acceptance Criteria

Blake's implementation is complete when:
- [ ] AC1: `/playground` command exists and activates a Design Explorer agent
- [ ] AC2: `design-styles.yaml` contains 30+ fully populated styles across 7 categories
- [ ] AC3: Each style has all required schema fields: name, category, mood, description, visual (colors, typography, layout, components), best_for, avoid_for, reference_products
- [ ] AC4: Gallery HTML displays multiple versions with Active View / History View / Compare Mode
- [ ] AC5: Gallery HTML auto-opens in browser after generation
- [ ] AC6: All generated versions are permanently preserved (append-only, max 30)
- [ ] AC7: Feedback collection protocol uses mixed mode (structured + open) with Escape Path and Fusion Spec
- [ ] AC8: DESIGN-SPEC.md is generated on finalization with complete design information including interaction states
- [ ] AC9: All outputs stored in `.tad/active/playground/` directory
- [ ] AC10: Old playground protocol removed from `tad-alex.md`
- [ ] AC11: Old playground files archived to `.tad/archive/playground/legacy-v1/`
- [ ] AC12: Config files updated (config.yaml, config-workflow.yaml)
- [ ] AC13: Command works independently without Alex or Blake being active
- [ ] AC14: Session recovery works — `/playground` detects existing state and offers resume
- [ ] AC15: State management uses atomic writes + backup + sync validation
- [ ] AC16: Two-tier style discovery (Category → Style) implemented in Step 2
- [ ] AC17: Preview step exists before finalization expansion

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ The style library YAML is the foundation — if styles lack detail, the agent can't generate distinctive pages
- ⚠️ Gallery HTML must be truly self-contained (no CDN) — users may be offline or behind firewalls
- ⚠️ Do NOT delete old playground files without archiving first (two-phase safety)

### 10.2 Known Constraints
- Landing Page generation quality depends on the executing model's frontend capability
- User noted Gemini performs best for this task — command should be model-agnostic but this is the recommended model
- Pure HTML+CSS scope — no JavaScript-heavy interactions, no image generation, no complex animations

### 10.3 Sub-Agent Usage Suggestions
- [ ] **code-reviewer** — Review gallery HTML template for accessibility and cross-browser compatibility
- [ ] **test-runner** — Validate YAML syntax, HTML rendering
- [ ] **ux-expert-reviewer** — Review feedback collection flow for usability

---

## 11. Decision Summary

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | Playground approach | Curation (token picking) vs Generation (full pages) | Generation | User's practical experience: curation too abstract, never ran successfully |
| 2 | Ownership | Alex sub-phase vs Blake task vs Independent | Independent command | Neither Alex nor Blake has the right skill profile for aesthetic work |
| 3 | Style library scope | 10 styles vs 20 vs 30+ | 30+ (as many as possible) | User wants maximum breadth of directions |
| 4 | Versions per round | 3 vs 5 vs user-defined | 3 | Balance between variety and cognitive load |
| 5 | Version display | Separate files vs single page tabs | Single page with tabs | User specified: one HTML, button switching, auto-open |
| 6 | Version history | Replace old vs append | Append (permanent) | User wants to revisit any version at any time |
| 7 | Feedback mode | Structured only vs free-form vs mixed | Mixed | Structured for core decisions, open for nuances |

---

## 12. Sub-Agent Usage Record

Blake fills after completion:

| Sub-Agent | Called | When | Output Summary | Evidence |
|-----------|-------|------|----------------|----------|
| code-reviewer | | | | |
| test-runner | | | | |
| ux-expert-reviewer | | | | |

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-02-08
**Version**: 3.1.0
