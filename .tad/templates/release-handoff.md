# Release Handoff Template

**Created**: [DATE]
**Author**: Alex (Solution Lead)
**Executor**: Blake (Execution Master)
**Version**: [X.Y.Z]
**Type**: [patch | minor | major]

---

## Release Decision

### Version Change

| Field | Value |
|-------|-------|
| Current Version | [e.g., 0.2.0] |
| New Version | [e.g., 0.2.1] |
| Change Type | [patch/minor/major] |

### Change Summary

```
[1-3 bullet points describing what's in this release]
-
-
```

### Breaking Changes

- [ ] No breaking changes
- [ ] Breaking changes (list below):
  -

### Platform Impact

| Platform | Impact | Action Required |
|----------|--------|-----------------|
| Web | [Immediate/None] | [Redeploy/None] |
| iOS | [Needs rebuild/None] | [Rebuild + Submit/None] |

---

## Blake's Execution Checklist

### Pre-Release
- [ ] Run tests: `npm test`
- [ ] Run build: `npm run build`
- [ ] Update CHANGELOG.md
- [ ] Bump version: `npm version [patch|minor|major]`

### Deploy
- [ ] Push to main: `git push origin main`
- [ ] Verify Vercel deployment
- [ ] (If iOS affected) Run: `npm run release:ios`

### Post-Release
- [ ] Verify production works
- [ ] Monitor error rates (24h)
- [ ] Create completion report

---

## Gate Criteria

### Gate 2: Design Completeness (process)

Process Gate 2 PASS ⇔ **two independent review files on disk** (P0=0 or sanctioned). Do **not**
block dispatch on a human typing `/gate 2`. Role switch is still `当 Blake`. See `docs/process-tax-cut.md` §3.

### Gate 3: Release Quality
- [ ] Tests pass
- [ ] Build succeeds
- [ ] CHANGELOG updated
- [ ] Version numbers consistent

### Gate 4: Release Verification
- [ ] Production accessible
- [ ] Critical paths working
- [ ] No increase in error rates

---

**Alex's Notes to Blake:**
[Any special instructions for this release]
