# Anti-AI-Slop Checklist

> Based on Anthropic frontend-design SKILL (Apache 2.0) — 6 core rules.
> Expanded with 4 additional patterns from research.

Run this checklist before finalizing any UI design. Each item is a yes/no decision.

---

## Core Rules (Anthropic — Apache 2.0)

### Rule 1: Font Prohibition
- [ ] Primary typeface is NOT Inter
- [ ] Primary typeface is NOT Roboto
- [ ] Primary typeface is NOT Arial
- [ ] Primary typeface is NOT system-ui
- [ ] A distinctive font pairing is chosen (e.g., slab serif + grotesque, display + humanist)

```bash
# Verify no banned fonts in CSS
grep -r "font-family.*Inter\|font-family.*Roboto\|font-family.*Arial\|font-family.*system-ui" \
  src/ --include="*.css" --include="*.scss" | grep -v "fallback\|comment"
```

### Rule 2: Gradient Prohibition
- [ ] No purple/blue gradient (`linear-gradient` with purple/blue tones) on white background
- [ ] Hero section does NOT use the generic gradient formula
- [ ] If gradients are used: they are unexpected (diagonal / mesh / noise-overlaid)

```bash
# Check for generic gradient patterns
grep -r "linear-gradient" src/ --include="*.css" | head -20
# Review each result manually for purple/blue-on-white pattern
```

### Rule 3: Animation Discipline
- [ ] Page has ONE primary animation chosen
- [ ] That primary animation is high-impact (page load reveal, primary CTA, hero entrance)
- [ ] All other elements: instant or ≤100ms transitions
- [ ] Total distinct keyframe animations ≤ 5 per page

```bash
# Count keyframe animations
grep -r "@keyframes" src/ --include="*.css" | wc -l
```

### Rule 4: Aesthetic Commitment
- [ ] A bold aesthetic direction is named (not "clean" or "minimal")
- [ ] The aesthetic direction is documented in DESIGN.md Section 1
- [ ] Every design decision traces back to that direction
- [ ] Aesthetic: _______________________________________________

### Rule 5: Spatial Composition
- [ ] Layout uses unexpected spatial composition (not uniform 12-column grid)
- [ ] At least one of: asymmetric layout / overlapping elements / diagonal flow / intentional whitespace imbalance
- [ ] No rigid equal-height card grid without compositional variation

### Rule 6: Background Prohibition
- [ ] No flat solid background in hero or landing section
- [ ] Background has character: noise texture / gradient mesh / grain overlay / geometric pattern
- [ ] Pure `#ffffff` or `#f5f5f5` sections are intentional (not defaults)

---

## Expanded Rules

### Rule 7: Token Naming
- [ ] No primitive token names in component styles (`blue-500`, `gray-100`, `red-error`)
- [ ] All color references use semantic tokens (`color-button-background-brand`)
- [ ] Run: `grep -r "blue-[0-9]\|red-[0-9]\|gray-[0-9]" src/ --include="*.css" | grep -v "primitive"` → 0

### Rule 8: Typography Weight
- [ ] 3-weight typography system exists (light/regular/medium or similar)
- [ ] Display text is NOT the same weight as body text
- [ ] UI labels are visually distinct from body copy

### Rule 9: Icon Usage
- [ ] No icon-only primary actions (icons always paired with text label)
- [ ] Decorative icons have `aria-hidden="true"`
- [ ] Run: `grep -r "icon-button\|IconButton\|btn.*icon" src/` — review each for text label presence

### Rule 10: Container Queries
- [ ] Components use `container-type` for internal responsiveness
- [ ] Run: `grep -r "@container" src/ --include="*.css"` — at least 1 result for component-level responsive
- [ ] Components do NOT rely solely on viewport media queries for their internal layout

---

## Quick Audit Command

```bash
echo "=== Anti-Slop Audit ==="
echo ""
echo "1. Banned fonts (should be 0):"
grep -r "font-family.*Inter\b\|font-family.*Roboto\b\|font-family.*Arial\b" \
  src/ --include="*.css" 2>/dev/null | grep -v "fallback\|\/\*" | wc -l

echo ""
echo "2. Primitive token names in components (should be 0):"
grep -r "blue-[0-9]\|red-[0-9]\|gray-[0-9]\|color: #\|background: #" \
  src/ --include="*.css" 2>/dev/null | grep -v "primitive\|:root\|var(" | wc -l

echo ""
echo "3. outline:none without focus-visible (should be 0):"
grep -r "outline: none\|outline:0" src/ --include="*.css" 2>/dev/null | \
  grep -v "focus-visible" | wc -l

echo ""
echo "4. Keyframe animation count (target ≤5):"
grep -r "@keyframes" src/ --include="*.css" 2>/dev/null | wc -l

echo ""
echo "5. Container queries present (target ≥1):"
grep -r "@container" src/ --include="*.css" 2>/dev/null | wc -l
```
