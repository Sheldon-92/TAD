# Fixture 1 — Inter font collision (CROSS-category → auto-resolve)

**Topic**: `inter-font`
**Packs**: web-ui-design × web-frontend
**Expected classification**: `cross-cat-resolve` — `performance>style`, **winner = web-frontend**, loser = web-ui-design

## Both-side file:line (hand-re-derive against live `.claude/skills/` at acceptance)

| side | category | ref | quote |
|------|----------|-----|-------|
| A (BAN) | style | `.claude/skills/web-ui-design/SKILL.md:93` | `NEVER use Inter, Roboto, Arial, or system-ui as the primary typeface.` |
| B (ENDORSE) | performance | `.claude/skills/web-frontend/references/performance.md:215` | `import { Inter } from 'next/font/google'` |

> Also flagged by the scanner: `.claude/skills/web-frontend/CONVENTIONS.md:195`
> (`import { Inter, Roboto_Mono } from 'next/font/google'`) — same next/font endorsement,
> same resolution. `performance.md:215` is the canonical ref.

## Why it resolves (does NOT escalate)

The two directives are in **different** categories: web-ui-design's ban is `style`
(anti-AI-slop, category 5); web-frontend's `next/font` import is `performance`
(font-loading optimization, category 4). Cross-category → the **lower number wins** →
`performance(4) > style(5)` → **web-frontend wins**.

⚠️ **Dangerous case**: this auto-resolve MUST be logged visibly. The log lets a human
verify web-frontend is loading Inter as an OPTIMIZED webfont, not installing it as the
**primary typeface** (which is exactly what the style ban targets). Silent resolution
could mask a real anti-slop violation.

## Expected surfacing one-liner

```
⚙️ resolved: web-frontend over web-ui-design (performance>style)
```
