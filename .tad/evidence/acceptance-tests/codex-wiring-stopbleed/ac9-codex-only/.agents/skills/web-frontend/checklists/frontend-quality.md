# Frontend Quality Checklist

Run before every production release. Tier 1 items can be automated in CI. Tier 2 requires human judgment. Tier 3 depends on infrastructure availability.

---

## Tier 1: Automatable Checks

Run these in CI on every PR. Failing any Tier 1 item is a release blocker.

### Performance (Core Web Vitals)
- [ ] **LCP < 2.5s** — `bash scripts/lighthouse-check.sh http://localhost:3000` — Lighthouse "Good" rating
- [ ] **INP < 200ms** — Lighthouse Performance score ≥ 90 on mobile throttling
- [ ] **CLS < 0.1** — Lighthouse "Good" rating — no layout shift on page load
- [ ] **Initial JS bundle ≤ 200KB** (gzipped) — `bash scripts/bundle-check.sh`
- [ ] **No single chunk > 100KB** (gzipped) — bundle-check.sh output

### Accessibility (Automated)
- [ ] **0 axe-core critical violations** — `bash scripts/a11y-scan.sh http://localhost:3000`
- [ ] **0 axe-core serious violations** — same command
- [ ] **All images have alt attributes** — `grep -r '<img' src/ | grep -v 'alt='` returns 0 (for plain `<img>`, not next/image)
- [ ] **HTML lang attribute present** — `grep -c 'lang=' src/app/layout.tsx` returns ≥1
- [ ] **All form inputs have labels** — axe-core label rule passes

### Code Quality
- [ ] **TypeScript strict mode** — `npx tsc --noEmit` exits 0
- [ ] **ESLint passes** — `npm run lint` exits 0
- [ ] **No console.log in production code** — `grep -rn 'console\.log' src/ --include='*.ts' --include='*.tsx' | grep -v '.test.' | grep -v '.stories.'` returns 0
- [ ] **No hardcoded localhost URLs** — `grep -rn 'localhost:' src/ --include='*.ts' --include='*.tsx' | grep -v '.test.'` returns 0
- [ ] **No TODO/FIXME comments in new code** — `git diff main --name-only | xargs grep -l 'TODO\|FIXME'` returns 0 for new files
- [ ] **Test suite passes** — `npm test` exits 0
- [ ] **Test coverage ≥ 70%** — `npm run test:coverage` meets branch/function thresholds

### Design Tokens
- [ ] **No hardcoded hex colors in components** — `grep -rn '#[0-9A-Fa-f]\{3,6\}' src/components/ --include='*.tsx' --include='*.css'` returns 0 (or justified exceptions documented)
- [ ] **tokens.css imported in globals** — `grep -c 'tokens.css' src/styles/globals.css` returns ≥1 (if token pipeline is set up)

---

## Tier 2: Human Attestation

These require a developer or designer to manually verify. Mark each as ✅ with your initials and date.

### UX and Visual Quality
- [ ] **Design fidelity** — Side-by-side comparison with DESIGN.md or Figma specs. Key measurements match: spacing, typography, border-radius, color values.
- [ ] **Responsive behavior** — Tested at 320px (mobile small), 768px (tablet), 1024px (laptop), 1440px (desktop). No horizontal scroll. No broken layouts.
- [ ] **Dark mode** (if applicable) — All text readable, no pure-white text on near-white backgrounds, no invisible elements.
- [ ] **Loading states** — Every async operation (data fetch, form submit, file upload) has a visible loading indicator. No blank flash.
- [ ] **Error states** — API errors, network failures, validation errors all display user-friendly messages (not stack traces or "Error 500").
- [ ] **Empty states** — Lists, tables, and dashboards have meaningful empty state messages (not blank space).

### Accessibility (Manual)
- [ ] **VoiceOver (macOS)** — Navigate the critical flow (login/checkout/main feature) with VoiceOver active. Verify: all interactive elements are reachable, announcements make sense, no "unlabeled button" announcements.
- [ ] **Keyboard navigation** — Tab through the entire page. Verify: visible focus ring on every interactive element, logical Tab order, no keyboard traps.
- [ ] **Color contrast (gradients/images)** — Manually verify text on gradient backgrounds, text on images, and icon-only buttons meet 4.5:1 contrast ratio.

### Content and Localization
- [ ] **Content overflow** — Verify UI with 2× longer text (simulates translated languages). No text clipping, no broken layouts.
- [ ] **Numbers and dates** — Currency, dates, and numbers formatted per locale. No hardcoded "$" or "/" date separators.

---

## Tier 3: Infrastructure-Dependent

These require specific infrastructure to be available. Document which are available in this project and run them when possible.

### Monitoring and Observability
- [ ] **Error tracking configured** — Sentry (or equivalent) DSN set in environment variables. Test error appears in dashboard after manual trigger.
- [ ] **Real User Monitoring (RUM)** — Google Analytics / Datadog RUM / Vercel Analytics capturing CWV in production.
- [ ] **CDN cache headers** — Static assets served with `Cache-Control: public, max-age=31536000, immutable`. Verify in browser DevTools Network tab.

### CI/CD
- [ ] **Lighthouse CI configured** — `.lighthouserc.js` or `lighthouserc.yaml` in repo. CWV thresholds enforced as PR check.
- [ ] **Bundle size tracking** — `bundlesize` or `size-limit` in CI. PR fails if bundle exceeds budget.

### Security
- [ ] **Content Security Policy header** — CSP set in HTTP headers or `<meta>` tag. Test with browser extension or `curl -I`.
- [ ] **No sensitive data in client bundle** — `grep -rn 'API_KEY\|SECRET\|PASSWORD' public/ dist/` returns 0.

---

## Release Sign-off

| Check | Status | Verified by | Date |
|-------|--------|-------------|------|
| All Tier 1 items automated and passing | | | |
| All Tier 2 items manually verified | | | |
| Applicable Tier 3 items verified | | | |
| Performance regression compared to previous release | | | |
| Accessibility regression compared to previous release | | | |
