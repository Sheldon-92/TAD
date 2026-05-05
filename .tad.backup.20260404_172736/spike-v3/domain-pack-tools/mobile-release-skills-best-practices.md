# Mobile Release Skills Best Practices — Research Summary

**Sources**: 3 GitHub repos + Apple guidelines + fastlane docs (2026-04-02 Blake research)

---

## Repositories Researched

| # | Repository | Key Strength |
|---|-----------|-------------|
| 1 | greenstevester/fastlane-skill | Fastlane automation: setup→certs→screenshots→beta→release workflow |
| 2 | rshankras/claude-code-apple-skills | 148 Apple skills, 7 App Store skills (keywords, descriptions, screenshots, rejection handling) |
| 3 | theapplaunchpad.com (2026 guidelines) | Top 10 rejection reasons with fix guidance |

---

## Capability: store_metadata

**Best steps (from rshankras + fastlane-skill)**:
1. Use `fastlane deliver download_metadata` to pull existing metadata
2. Optimize keywords (search volume vs competition, 100-char limit)
3. Write description focused on conversion (what it does, not how)
4. Generate screenshots with fastlane snapshot across devices/languages
5. Validate: all screenshots show actual app, not mockups

**Quality standards**:
- Title ≤ 30 chars, subtitle ≤ 30 chars
- Keywords: 100-char limit, no spaces after commas, no duplicates of title words
- Screenshots: actual app, correct device sizes, latest version features
- "Misleading screenshots → rejection" (guideline 2.3.1)

**Anti-patterns**:
- ❌ Screenshots showing features not in the app
- ❌ Keywords duplicating title words (wasted characters)
- ❌ Description with marketing fluff instead of functionality

---

## Capability: testflight_distribution

**Best steps (from fastlane-skill + docs)**:
1. `fastlane match` to sync certificates (encrypted in git repo)
2. Increment build number: `fastlane run increment_build_number`
3. Build: `fastlane gym` (Xcode build + archive)
4. Upload: `fastlane pilot upload` (or `eas submit --platform ios`)
5. Manage testers: `fastlane pilot add` (by email, no UDID needed)

**Quality standards**:
- API key auth (not password): App Store Connect API key (.p8 file)
- Build succeeds before upload
- Testers list managed, not ad-hoc

**Anti-patterns**:
- ❌ Password auth (deprecated, use API key)
- ❌ Manual screenshot upload for 12 languages ("47 screenshots by hand")
- ❌ Not incrementing build number before upload

---

## Capability: review_compliance

**Best steps (from theapplaunchpad 2026 guidelines)**:
Top 10 rejection reasons → checklist:
1. **Crashes**: test on multiple devices, zero crashes on launch
2. **Privacy labels mismatch**: audit ALL data collection, match labels
3. **Misleading metadata**: screenshots show actual app, description accurate
4. **Broken links**: every link works (privacy policy, terms, support)
5. **IAP config**: full pricing, renewal terms, cancellation visible
6. **Performance**: no excessive lag, test on min-spec device
7. **Missing privacy policy**: accessible link in app + App Store listing
8. **AI disclosure (2026)**: explain what AI does, data used, user controls
9. **Accessibility**: Dynamic Type, Dark Mode, contrast ratio
10. **SDK version**: built with latest Xcode, supports latest iOS SDK

**Quality standards**:
- Checklist of 10 items, all must pass
- Each item references specific Apple guideline number
- Provide reviewer a demo account if login required

**Anti-patterns**:
- ❌ Submitting without testing on real device
- ❌ Partial fix for rejection (triggers re-rejection)
- ❌ No demo account for reviewer

---

## Capability: privacy_policy

**Best steps (from 2026 guidelines)**:
1. Identify ALL data collected (analytics, crash logs, user accounts, location, etc.)
2. Document for each: what data, why collected, how stored, who shared with
3. App Privacy Labels must match actual practice exactly
4. Third-party SDKs: list each SDK and what data it collects
5. AI services: explicit consent before sharing data with AI providers
6. Generate privacy policy page (HTML or PDF)

**Quality standards**:
- Privacy policy accessible via link (not just in app)
- App Privacy Labels match actual behavior (mismatch = rejection)
- Third-party SDK data collection documented

---

## Capability: version_management

**Best steps (from fastlane docs)**:
1. Semantic versioning: MAJOR.MINOR.PATCH
2. Build number auto-increment: `agvtool next-version -all` or fastlane action
3. Tag git: `git tag v1.0.0` after release
4. Version in app.json (Expo) or Info.plist (native)

---

## Capability: release_automation

**Best steps (from fastlane-skill + GitHub Actions)**:
1. Setup: `fastlane init` → generates Appfile + Fastfile
2. Lanes: test → beta → release
3. CI: GitHub Actions with `setup_ci` (temporary keychain)
4. Signing: `fastlane match` for team cert sharing

---

## Capability: post_release_monitoring

**Best steps (from rshankras)**:
1. Crash monitoring: Sentry or Crashlytics
2. App Store ratings: monitor via App Store Connect API
3. Review responses: handle within 24-48h
4. Download/revenue tracking: App Store Connect dashboard
