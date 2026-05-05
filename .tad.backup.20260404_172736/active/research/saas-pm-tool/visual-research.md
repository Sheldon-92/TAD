# Visual Design Research — SaaS PM Tool

## 1. Competitor Visual Style Map

| Competitor | Primary Color | Hex | Visual Style | Typography |
|---|---|---|---|---|
| Linear | Purple/Violet | #5E6AD2 | Dark mode default, minimal, lots of whitespace | Inter, system |
| Jira/Atlassian | Blue | #0052CC | Dense, enterprise, information-heavy | -apple-system, system |
| Asana | Coral/Pink-Red | #FC636B (Pastel Scarlet) | Friendly, colorful, warm | -apple-system, system |
| Notion | Black/White | #000000/#FFFFFF | Ultra-minimal, content-focused, near-monochrome | system-ui |
| GitHub Issues | Gray/Green | #24292F/#1F883D | Dev-focused, utilitarian | system-ui, -apple-system |

## 2. Color Differentiation Strategy

**Occupied color territories:**
- Purple/Violet: Linear (strongly associated)
- Blue: Jira/Atlassian (strongly associated)
- Coral/Pink: Asana
- Black/White: Notion
- Green: GitHub

**Available differentiating territories:**
- Teal/Cyan — fresh, modern, calming. Not occupied by major PM tools.
- Warm orange — energetic but risks looking like "fun" rather than "professional"
- Deep emerald — too close to GitHub's green territory

**Decision: Teal (#0D9488) as primary**

**Reasoning:**
1. **No competitor occupies teal**: Linear=purple, Jira=blue, Asana=pink, Notion=B&W. Teal is visually distinct from all of them.
2. **Teal conveys**: calm confidence, clarity, focus — aligns with "tool for indie devs who want calm productivity" (vs Jira's enterprise density or Asana's playfulness).
3. **2026 trend alignment**: Pantone's Cloud Dancer (warm neutral) + teal creates a sophisticated pairing without looking corporate.
4. **Anti-pattern avoidance**: NOT using purple (would look like a Linear clone), NOT using blue (would look like a Jira clone).

## 3. Visual Preset Selection

**Selected: Modern SaaS** (Preset 1 from domain pack)

**Why:**
- Indie devs expect modern, clean SaaS aesthetics (they use Linear, Vercel, Supabase daily)
- Neutral base + one strong accent color = professional without being boring
- 8px grid + generous whitespace aligns with Approach 1 (Linear-style minimal)
- Enterprise/Corporate (Preset 3) is too dense for indie devs
- Apple-level Minimal (Preset 2) is too sparse — PM tools need some information density
- Data Dashboard (Preset 5) is wrong paradigm (PM tool, not analytics tool)

## 4. Visual Direction

### Colors
- **Primary**: Teal #0D9488 — buttons, links, active states
- **Primary hover**: #0F766E — darker teal for hover states
- **Background**: #FAFAFA — warm near-white (not cold #FFF)
- **Surface**: #FFFFFF — cards, panels, modals
- **Text primary**: #1A1A2E — near-black with slight warmth (not pure #000)
- **Text secondary**: #64748B — slate gray for secondary text
- **Border**: #E2E8F0 — subtle slate border
- **Error**: #DC2626 — standard red
- **Success**: #16A34A — standard green
- **Warning**: #D97706 — amber

### Typography
- **Family**: Inter (widely available, excellent for data-dense UIs, used by Vercel/Linear)
- **Fallback**: system-ui, -apple-system, sans-serif
- **Scale**: 12/14/16/20/24/32px (base=14px for dense PM UI — [ASSUMPTION] 14px base is more standard for PM tools than 16px, as validated by Linear and Jira both using 13-14px body text)

### Spacing & Layout
- **Base unit**: 4px
- **Scale**: 4/8/12/16/20/24/32/48/64px
- **Border radius**: 4px (inputs), 6px (cards), 8px (modals), full (avatars/badges)
- **Shadows**: Minimal — only for elevated elements (modals, dropdowns, command palette)
