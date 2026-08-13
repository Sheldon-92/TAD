---
name: mobile-release
description: "Mobile release capability pack. Covers App Store metadata & ASO, TestFlight distribution, review compliance checking, privacy policy & App Privacy Labels, version management, release CI/CD automation, and post-release monitoring. Use for any mobile app release, App Store submission, TestFlight beta, app review compliance, or release pipeline task."
version: 0.1.0
type: reference-based
keywords: ["App Store", "应用商店", "TestFlight", "iOS release", "iOS 发布", "上架", "fastlane", "EAS", "Expo", "app review", "审核", "rejection", "拒审", "privacy policy", "隐私政策", "privacy labels", "隐私标签", "ASO", "metadata", "元数据", "screenshots", "截图", "semver", "版本管理", "build number", "构建号", "release automation", "发布自动化", "crash monitoring", "崩溃监控", "评论回复"]
---

# Mobile Release Capability Pack

> From build to App Store — metadata, compliance, distribution, monitoring. iOS-primary, Android basic support. **Core value: prevent App Store review rejection BEFORE submission.**
> **CONSUMES**: An app project (Expo or native/RN CLI), Apple Developer Account, developer's answers about data practices.
> **PRODUCES**: Config files (Fastfile, eas.json, fastlane/metadata/) into the project directory; TAD documentation (compliance report, privacy policy, strategies) into `.tad/active/release/{project}/`.

---

## Step 1: Context Detection

| User Signal | Load Reference |
|---|---|
| metadata, title, keywords, screenshots, description, ASO, listing, 元数据, 关键词 | `references/store-metadata.md` |
| TestFlight, beta, build, sign, upload, certificates, match, 测试分发 | `references/testflight-distribution.md` |
| review, rejection, guideline, compliance, submit, 审核, 拒审, 上架检查 | `references/review-compliance.md` |
| privacy policy, privacy labels, data collection, COPPA, GDPR, SDK data, 隐私 | `references/privacy-policy.md` |
| version, semver, build number, tag, changelog, 版本号 | `references/version-management.md` |
| CI/CD, pipeline, GitHub Actions, automation, secrets, 自动化发布 | `references/release-automation.md` |
| crash, rating, reviews, monitoring, analytics, post-release, 崩溃, 评分 | `references/post-release-monitoring.md` |
| Gate review, reviewing a release deliverable, acceptance check, 验收 | `references/review-checklist.md` |

**Multi-signal**: Load all matched references. Before ANY Gate/expert review of release work → also load `references/review-checklist.md` (reviewer personas + Gate 2/Gate 4 checklists).

---

## Step 2: Decision Entry Point

**Q1 — What release stage?**
- Preparing store listing → `store-metadata.md`
- Getting a build to testers → `testflight-distribution.md`
- About to submit for review → `review-compliance.md` + `privacy-policy.md` (BOTH, always, before submission)
- Setting up repeatable releases → `version-management.md` + `release-automation.md`
- App already live → `post-release-monitoring.md`

**Q2 — What toolchain?**
- Expo project → EAS Build + EAS Submit (`eas build` / `eas submit`)
- Native / RN CLI → fastlane (`fastlane ios beta`, match, gym, pilot)
- CI/CD wanted → GitHub Actions + fastlane/EAS, or Xcode Cloud (Apple-native)
- Decision rule: **Expo = EAS, Native = fastlane.** Both need an Apple Developer Account.

**Q3 — Does the app have login?**
- Yes → a demo account for the Apple reviewer is MANDATORY (automatic rejection without one). Flag it now, not at submission time.

**Q4 — Does the app use AI, or have IAP/subscriptions?**
- AI → must disclose (2026 requirement, guideline 5.6.4) — check in `review-compliance.md`
- IAP/subscriptions → strict pricing transparency rules (guideline 3.1.1)

---

## Step 3: Hard Judgment Rules

These are pass/fail rules distilled from the pack's quality criteria. Violating any = the deliverable FAILS review.

### Store Metadata
- Title ≤ 30 chars (includes primary keyword); subtitle ≤ 30 chars (value proposition).
- Keywords ≤ 100 chars, comma-separated, no spaces after commas, no words duplicating the title.
- Screenshots MUST show the actual app (not mockups/renders), at required device sizes (6.7" + 6.1" minimum).
- Description first 3 lines must explain what the app does (visible without "more"). Feature-focused, not marketing fluff.
- Fabricated download numbers or invented reviews = FAIL.

### TestFlight Distribution
- Auth MUST use an App Store Connect API key (.p8), NEVER password (2FA breaks CI).
- Build number MUST be incremented before EVERY upload (duplicate = upload rejected).
- Certificates sync via fastlane match (encrypted git repo) — never shared ad-hoc.
- Verify end-to-end: build succeeds → upload succeeds → build visible in App Store Connect → testers can install.
- Fabricated build statuses or invented TestFlight URLs = FAIL.

### Review Compliance (CORE VALUE)
- Run the 10-item compliance checklist against THIS app BEFORE submission — every check cites a specific Apple guideline number (2.1, 2.3.1, 5.1.1, 3.1.1, 5.6.4...). Generic advice without guideline numbers = not a compliance check.
- Every FAIL item gets a specific, actionable fix (severity: blocking vs warning; effort: quick vs significant; blocking+quick first) — not "fix the bug".
- Login app → demo account for reviewer prepared.
- AI features → disclosure checked (new 2026 requirement).
- Fabricated compliance statuses or invented guideline numbers = FAIL.

### Privacy Policy
- MUST interrogate the developer BEFORE generating anything (SDK list from package.json/Podfile, account fields, permissions usage, AI/cloud data flow, children under 13, hosting URL). DO NOT PROCEED without answers — a privacy policy with wrong data categories is legally worse than none.
- App Privacy Labels MUST match actual data practices exactly, including EVERY third-party SDK (missing one = label mismatch = rejection).
- Policy must be app-specific (never a generic template) and hosted at an accessible URL (Apple requires it).
- Fabricated privacy claims or invented data practices = FAIL.

### Version Management
- Semantic versioning MAJOR.MINOR.PATCH (breaking/feature/fix); build number auto-increments on every TestFlight upload.
- Git tag `v{version}` on each release; app version must match Store listing version.
- Fabricated version numbers or skipped builds = FAIL.

### Release Automation
- Secrets (Apple API key, match passphrase, team ID) live in CI secrets storage, NEVER in code.
- Pipeline stages: lint → test → build → upload (never skip tests in CI).
- Verify from CI itself: trigger runs, build succeeds, upload succeeds, secrets not exposed in logs.
- Fabricated CI results or invented pipeline statuses = FAIL.

### Post-Release Monitoring
- Crash reporting (Sentry or Firebase Crashlytics) configured and tested — never ship blind.
- Alert thresholds: crash-free rate < 99%, rating < 4.0, downloads drop > 30% week-over-week.
- Respond to all 1-2 star reviews within 48h; never argue with reviewers; a human reviews and approves responses before posting.
- Fabricated monitoring data or invented crash rates = FAIL.

---

## Quick Rule Index

### Store Metadata (`references/store-metadata.md`)
- **4-step flow**: strategy (new vs `deliver download_metadata` vs localization) → create files → verify limits → ASO optimization
- **ASO rules**: use all 100 keyword chars, no cross-field word repeats, localize top markets (en/zh/ja/ko/de/fr)

### TestFlight Distribution (`references/testflight-distribution.md`)
- **Method selection**: Expo→EAS, Native→fastlane, CI→GitHub Actions + either
- **fastlane sequence**: match → increment_build_number → gym → pilot upload → pilot add
- **EAS sequence**: build:configure → build --platform ios → submit --latest

### Review Compliance (`references/review-compliance.md`)
- **10-item checklist table** with guideline numbers (crash, privacy labels, screenshots, links, IAP, performance, policy URL, AI disclosure, accessibility, latest Xcode)
- **4-layer flow**: search current guidelines → analyze against THIS app → prioritized fix plan → formatted report (PDF for stakeholders)

### Privacy Policy (`references/privacy-policy.md`)
- **Data practices matrix**: Data Type | Collected By | Purpose | Linked to User? | Tracking? → maps directly to App Privacy Labels
- **6 developer interrogation questions** — blocking gate before generation
- **8-section policy structure** (collect/why/storage/sharing/rights/contact/AI/COPPA)

### Version Management (`references/version-management.md`)
- **Setup per toolchain**: Expo app.json bump script vs native agvtool/fastlane increment lane
- **Automation**: CI build-number increment on merge, changelog from conventional commits, `1.0.0-beta.1` pre-releases

### Release Automation (`references/release-automation.md`)
- **Platform choice**: GitHub Actions + fastlane (flexible) vs EAS Build (no local Xcode) vs Xcode Cloud (Apple-native)
- **Setup detail**: setup_ci temporary keychain, EAS build profiles, caching, conditional submission on tags

### Post-Release Monitoring (`references/post-release-monitoring.md`)
- **Tool setup**: Sentry/Crashlytics, App Store Connect analytics, review monitoring (AppFollow)
- **Review response protocol** + iteration rules (top crashes → hotfix X.Y.Z+1)

### Review Checklist (`references/review-checklist.md`)
- **7 reviewer personas** with per-capability checklists (ASO Specialist, Release Engineer, Review Specialist, Privacy Officer, Release Manager, DevOps, PM)
- **Gate 2 / Gate 4 checklists** + expected release artifact structure

---

## Anti-Skip Table

| Shortcut Attempt | Required Action |
|---|---|
| "Let's just submit and see" | MUST run the 10-item checklist in `review-compliance.md` first — rejection costs a 1-7 day wait |
| "I'll write a standard privacy policy" | MUST interrogate the developer first per `privacy-policy.md` — wrong data categories are legally worse than none |
| "Password auth works locally" | MUST use App Store Connect API key (.p8) — password auth breaks in CI with 2FA |
| "Reuse the build number" | MUST increment before every upload — Apple rejects duplicate build numbers |
| "Fix the one thing Apple flagged" | MUST re-run the full checklist — partial fixes trigger re-rejection |
| "No one reads privacy labels" | MUST match labels to actual SDK behavior — mismatch is a top rejection reason |
| "We'll add crash reporting later" | MUST configure before release — otherwise blind to production issues |

---

## Anti-Patterns

### Store Metadata
- ❌ Screenshots showing features not in the app (guideline 2.3.1 rejection)
- ❌ Keywords duplicating title words (wasted characters)
- ❌ Marketing fluff description ('revolutionary', 'best ever')
- ❌ Missing required device screenshot sizes

### TestFlight Distribution
- ❌ Password auth (deprecated, 2FA issues in CI)
- ❌ Manual screenshot upload for multi-language
- ❌ Not incrementing build number (upload rejected)
- ❌ Sharing certificates via email (use fastlane match)

### Review Compliance
- ❌ Submitting without running compliance check (1-7 day wait if rejected)
- ❌ Partial fix for rejection issues (triggers re-rejection)
- ❌ No demo account for reviewer (automatic rejection if login required)
- ❌ Ignoring AI disclosure requirement (new in 2026)

### Privacy Policy
- ❌ Generic template privacy policy (must be app-specific)
- ❌ Privacy labels don't match actual behavior (top rejection reason)
- ❌ Missing third-party SDK data disclosure
- ❌ No accessible URL for privacy policy

### Version Management
- ❌ Manual version bumping (error-prone, forgettable)
- ❌ Same build number for multiple uploads (rejected)
- ❌ No git tags (can't trace what was in which release)

### Release Automation
- ❌ Secrets in code (API keys, certificates)
- ❌ No CI (manual build + upload every time)
- ❌ Skipping tests in CI (false confidence)

### Post-Release Monitoring
- ❌ No crash reporting (blind to production issues)
- ❌ Ignoring 1-star reviews (missed feedback + poor optics)
- ❌ No alert thresholds (find problems from user complaints, not data)
