# Release Execution Task (版本发布执行任务)

## ⚠️ CRITICAL EXECUTION NOTICE ⚠️

**THIS IS AN EXECUTABLE WORKFLOW - RELEASE GATES MUST BE PASSED**

When this task is invoked:

1. **MANDATORY SOP** - Follow RELEASE.md standard operating procedure
2. **VERSION VALIDATION** - Verify SemVer rules are followed
3. **QUALITY GATES** - Release-specific gates must pass
4. **EVIDENCE COLLECTION** - All release steps must be documented

**VIOLATION INDICATOR:** Releasing without passing release gates is a critical violation.

## Purpose

Execute version releases following TAD's release management system with proper quality gates and cross-platform coordination.

---

## Release Types

### Type 1: Routine Release (Blake)
**Patch/Minor releases without breaking changes**

```yaml
trigger: "Blake receives routine release request"
authority: Blake
gates: Gate 3 (Release Quality)
```

### Type 2: Major Release (Alex → Blake)
**Major versions or breaking changes**

```yaml
trigger: "Alex creates release handoff"
authority: Alex (planning) + Blake (execution)
gates: Gate 2 (Release Planning) + Gate 3 (Release Quality) + Gate 4 (Release Verification)
template: .tad/templates/release-handoff.md
```

### Type 3: iOS Release (Blake)
**iOS platform-specific release**

```yaml
trigger: "iOS build needed after web changes"
authority: Blake
commands: npm run release:ios
gates: Gate 3 (Release Quality)
```

---

## Release Execution Protocol

### Pre-Release Checklist

```
✅ Pre-Release Verification:
- [ ] All tests pass: `npm test`
- [ ] Build succeeds: `npm run build`
- [ ] Lint passes: `npm run lint`
- [ ] No uncommitted changes (except release updates)
- [ ] On correct branch (main/master)
- [ ] CHANGELOG.md updated with changes
```

### Version Bump Decision

```
Version Bump Guide (SemVer):

PATCH (0.2.0 → 0.2.1):
- [ ] Bug fixes only
- [ ] No new features
- [ ] No API changes

MINOR (0.2.0 → 0.3.0):
- [ ] New features added
- [ ] Backward compatible
- [ ] No breaking changes

MAJOR (0.2.0 → 1.0.0):
- [ ] Breaking changes
- [ ] Major new features
- [ ] API contract changes
- [ ] Requires Alex handoff
```

### Execution Steps

**Step 1: Update CHANGELOG.md**
```markdown
## [X.Y.Z] - YYYY-MM-DD

### Added
- [List new features]

### Changed
- [List changes]

### Fixed
- [List bug fixes]

### Deprecated
- [List deprecations]

### Security
- [List security fixes]
```

**Step 2: Bump Version**
```bash
# Choose one based on change type:
npm version patch  # 0.2.0 → 0.2.1
npm version minor  # 0.2.0 → 0.3.0
npm version major  # 0.2.0 → 1.0.0
```

**Step 3: Deploy Web**
```bash
git push origin main  # Triggers Vercel auto-deploy
```

**Step 4: Deploy iOS (if needed)**
```bash
npm run release:ios   # Syncs version + builds iOS
# Then: Open Xcode, Archive, Submit to App Store
```

---

## Release Quality Gate (Gate 3R)

**Special release gate executed during releases**

```
Gate 3R: Release Quality Check

Pre-Release Status:
✅ Tests: [X/Y passing]
✅ Build: [Success/Failed]
✅ Lint: [Pass/Fail]
✅ CHANGELOG: [Updated/Not Updated]

Please select an option (0-8) or 9 to release:
0. Run tests again
1. Fix failing tests
2. Fix build errors
3. Fix lint issues
4. Update CHANGELOG
5. Review version bump type
6. Check platform impact
7. Verify iOS changes (if applicable)
8. Fail gate and fix issues
9. Pass gate and execute release

Select 0-9:
```

---

## Release Verification Gate (Gate 4R)

**Post-release verification**

```
Gate 4R: Release Verification Check

Post-Release Status:
✅ Web Deployment: [Verified/Failed]
✅ Production Health: [OK/Issues]
✅ iOS Build: [Success/NA/Failed]
✅ Version Numbers: [Consistent/Mismatch]

Please select an option (0-8) or 9 to complete:
0. Check Vercel deployment status
1. Verify production endpoint
2. Test critical user flows
3. Check error monitoring
4. Verify iOS build (if applicable)
5. Roll back if needed
6. Update documentation
7. Notify stakeholders
8. Fail gate and investigate
9. Pass gate and complete release

Select 0-9:
```

---

## Platform-Specific Procedures

### Web (Vercel)

```yaml
deployment: Automatic on push to main
verification:
  - Check Vercel dashboard
  - Test production URL
  - Monitor error rates (24h)
rollback:
  - Use Vercel instant rollback
  - Or: git revert + push
```

### iOS (App Store)

```yaml
deployment: Manual via Xcode
steps:
  1. npm run release:ios  # Sync version + build
  2. Open Xcode: npx cap open ios
  3. Product → Archive
  4. Distribute → App Store Connect
verification:
  - TestFlight testing
  - App Store review approval
rollback:
  - Submit previous version
  - Or: Expedited review for critical fix
```

---

## Evidence Collection

### Release Evidence Template

```yaml
release:
  version: "X.Y.Z"
  type: [patch|minor|major]
  date: [timestamp]
  executor: Blake

pre_release:
  tests_passed: [X/Y]
  build_success: [true/false]
  lint_clean: [true/false]
  changelog_updated: [true/false]

deployment:
  web:
    status: [success/failed]
    url: [production URL]
    deploy_time: [timestamp]
  ios:
    status: [success/na/failed]
    build_number: [YYYYMMDDHHMM]

post_release:
  production_verified: [true/false]
  errors_24h: [count or "monitoring"]
  rollback_needed: [true/false]

notes: |
  [Any special notes about this release]
```

Save to: `.tad/evidence/releases/release-[version]-[timestamp].yaml`

---

## Violation Handling

### Release Violations

**V1: Releasing without tests**
```
⚠️ RELEASE VIOLATION ⚠️
Tests not executed before release
Required: npm test with all passing
Action: Run tests, fix failures, retry release
```

**V2: Version mismatch**
```
⚠️ VERSION VIOLATION ⚠️
Version inconsistency detected
package.json: X.Y.Z
iOS Info.plist: A.B.C
Action: Run npm run version:sync
```

**V3: Breaking change without major bump**
```
⚠️ SEMVER VIOLATION ⚠️
Breaking API change detected
Current bump: [patch/minor]
Required: major version bump
Action: Use npm version major, update CHANGELOG
```

---

## Quick Reference Commands

```bash
# Routine patch release
npm test && npm run build && npm version patch && git push origin main

# Minor release with new features
npm test && npm run build && npm version minor && git push origin main

# iOS release (after web changes)
npm run release:ios && npx cap open ios

# Version sync check
node -p "require('./package.json').version"
```

---

## CRITICAL REMINDERS

**❌ NEVER:**
- Release without running tests
- Skip CHANGELOG updates
- Deploy major changes without Alex handoff
- Push to production without verification
- Ignore version sync for iOS

**✅ ALWAYS:**
- Follow RELEASE.md SOP
- Execute release gates
- Verify production after deploy
- Keep CHANGELOG current
- Sync iOS versions with npm run release:ios
- Collect release evidence

[[LLM: This task enforces TAD's release management system. Releases are not just code pushes - they are controlled quality events with proper gates, verification, and evidence collection.]]
