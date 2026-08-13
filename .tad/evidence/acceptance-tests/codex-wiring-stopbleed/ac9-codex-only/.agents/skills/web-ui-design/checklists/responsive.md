# Responsive Design Checklist

Mobile-first responsive design checks — each item is a runnable command or binary yes/no.

---

## Breakpoints

- [ ] Mobile base styles work without any media query (< 480px)
- [ ] Tablet layout tested at 481px–768px
- [ ] Desktop layout tested at 769px–1024px
- [ ] Wide layout tested at ≥ 1200px
- [ ] No content overflows horizontally at any breakpoint

```bash
# Run Lighthouse to check responsive design
lhci autorun --config=lighthouserc.json

# Check for fixed-width containers that break mobile
grep -r "width: [0-9]*px" src/ --include="*.css" | grep -v "max-width\|min-width\|border\|outline\|box-shadow"
```

---

## Fluid Typography

- [ ] Body font uses `clamp()` — NOT fixed `px`
- [ ] Headings use `clamp()` — NOT fixed `px`
- [ ] No font sizes below `0.75rem` on mobile
- [ ] Line height between 1.4–1.6 for body text

```bash
# Check for hardcoded pixel font sizes (should be 0 in semantic layer)
grep -r "font-size: [0-9]*px" src/ --include="*.css" | grep -v "var(\|clamp(\|calc("

# Verify clamp() usage
grep -r "clamp(" src/ --include="*.css" | wc -l
```

---

## Touch Targets

- [ ] All buttons ≥ 44×44px on touch devices
- [ ] All links ≥ 44×44px on touch devices (or sufficient padding)
- [ ] All form inputs ≥ 44px height on touch devices
- [ ] Spacing between adjacent touch targets ≥ 8px

```bash
# Find elements likely under 44px (review each)
grep -r "height: [1-3][0-9]px\|min-height: [1-3][0-9]px" src/ --include="*.css"
```

---

## Images

- [ ] All `<img>` elements have `loading="lazy"` (except above-the-fold)
- [ ] Hero images use `<picture>` with `srcset` for multiple sizes
- [ ] WebP or AVIF format used (not just JPEG/PNG)
- [ ] Images have explicit `width` and `height` to prevent layout shift

```bash
# Check for images without loading="lazy"
grep -r "<img" src/ --include="*.html" --include="*.tsx" --include="*.jsx" | \
  grep -v 'loading="lazy"' | grep -v "above-the-fold\|hero" | wc -l
```

---

## Layout

- [ ] No hardcoded container widths (use `max-width` + fluid padding)
- [ ] Grid uses `auto-fit` with `minmax` (not fixed column counts)
- [ ] Components use `@container` queries for internal responsiveness
- [ ] Flexbox and Grid items don't overflow their containers at any breakpoint

```bash
# Check for rigid fixed-column grids (anti-pattern)
grep -r "grid-template-columns: repeat([0-9]" src/ --include="*.css" | grep -v "auto-fit\|auto-fill"

# Check for container query usage
grep -r "@container" src/ --include="*.css" | wc -l

# Check for container-type declarations
grep -r "container-type:" src/ --include="*.css" | wc -l
```

---

## Navigation

- [ ] Mobile navigation is accessible via thumb zone (bottom or hamburger)
- [ ] Desktop navigation is visible without interaction
- [ ] Navigation collapses gracefully at 480px
- [ ] Active navigation state is visually clear

---

## Forms

- [ ] Form inputs stack vertically on mobile (no side-by-side at < 480px)
- [ ] Labels are above inputs on mobile (not inline/placeholder-only)
- [ ] Submit buttons are full-width on mobile

---

## Performance

- [ ] CSS file is purged (no unused rules)
- [ ] Run: `lhci autorun` — Performance score ≥ 80
- [ ] Run: `lhci autorun` — Largest Contentful Paint ≤ 2.5s

```bash
# Purge unused CSS
purgecss --css dist/styles.css --content dist/**/*.html dist/**/*.js \
  --output dist/styles.purged.css

# Compare sizes
echo "Before:" && wc -c dist/styles.css
echo "After:" && wc -c dist/styles.purged.css
```

---

## Quick Responsive Audit

```bash
echo "=== Responsive Audit ==="
echo ""
echo "1. Fixed pixel font sizes (should be 0):"
grep -r "font-size: [0-9]*px" src/ --include="*.css" | grep -v "var(\|clamp(" | wc -l

echo ""
echo "2. Container queries (target ≥ 1):"
grep -r "@container" src/ --include="*.css" | wc -l

echo ""
echo "3. Auto-fit grids (target ≥ 1):"
grep -r "auto-fit\|auto-fill" src/ --include="*.css" | wc -l

echo ""
echo "4. Lazy-loaded images:"
grep -r 'loading="lazy"' src/ | wc -l

echo ""
echo "5. Lighthouse (full run):"
lhci autorun 2>&1 | grep -E "performance|accessibility|best-practices" | head -5
```
