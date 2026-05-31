# Fixture 2 — Contrast standard collision (SAME-category a11y → escalate)

**Topic**: `contrast-standard`
**Packs**: web-ui-design × web-frontend
**Expected classification**: `same-cat-escalate` — both sides `a11y`, precedence cannot break the tie

## Both-side file:line (hand-re-derive against live `.claude/skills/` at acceptance)

| side | category | ref | quote |
|------|----------|-----|-------|
| A (APCA) | a11y | `.claude/skills/web-ui-design/SKILL.md:454` | `**Step 4: Validate contrast with APCA**` (LC scale at `:476` — `APCA LC ≥60 for body text, ≥45 for large text`) |
| B (WCAG) | a11y | `.claude/skills/web-frontend/references/accessibility.md:45` | `Minimum 4.5:1 (normal text), 3:1 (large text/UI)` — WCAG 2.2 SC 1.4.3 |

> Third pack on the WCAG side: `.claude/skills/web-testing/references/accessibility-testing-rules.md:12`
> (`Contrast ratio >= 4.5:1 for normal text`). Same a11y-vs-a11y escalate either way.

## Why it escalates (does NOT auto-resolve)

Both directives are category `a11y` (accessibility, category 3). Precedence **cannot
break a same-category tie**, so it ESCALATES to a human. This is a real conflict: APCA
(perceptual lightness contrast) and WCAG 2.x (4.5:1 ratio) can give **different pass/fail
verdicts on the same color pair** — a human/project must choose the standard.

## Expected surfacing one-liner

```
⚠️ unresolved: web-ui-design vs web-frontend — human decides (contrast-standard)
```
