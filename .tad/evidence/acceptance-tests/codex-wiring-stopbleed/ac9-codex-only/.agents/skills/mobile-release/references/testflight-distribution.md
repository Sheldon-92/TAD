# TestFlight Distribution — Build, Sign, Upload

Build, sign, and upload to TestFlight for beta testing. Plan/verification docs go to `.tad/active/release/{project}/` (distribution-plan.md, distribution-verification.md); config files (Fastfile, eas.json) go into the project directory.

## Step 1: Select Distribution Method

1. Expo project → EAS Build + EAS Submit (`eas build --platform ios && eas submit`)
2. Native/RN CLI → fastlane (`fastlane ios beta`)
3. CI/CD → GitHub Actions + fastlane/EAS

**Decision rule: Expo = EAS, Native = fastlane.** Both need an Apple Developer Account.

## Step 2: Execute Distribution

**For fastlane:**

1. `fastlane match development` → sync certificates (encrypted git repo)
2. `fastlane run increment_build_number` → auto-increment
3. `fastlane gym` → build + archive
4. `fastlane pilot upload` → upload to TestFlight
5. `fastlane pilot add email@test.com` → add testers

**For EAS:**

1. `eas build:configure` → setup eas.json
2. `eas build --platform ios --profile preview` → cloud build
3. `eas submit --platform ios --latest` → upload to TestFlight

**Auth: always use App Store Connect API key (.p8), NOT password.**

## Step 3: Verify Distribution

1. Build succeeds (IPA generated or EAS build completes)
2. Upload to TestFlight succeeds
3. Build appears in App Store Connect
4. Testers can install via TestFlight

## Step 4: Optimize

1. Cache certificates with fastlane match (avoid re-creating)
2. Use API key auth exclusively (faster, no 2FA prompts)
3. Add CI integration (GitHub Actions with setup_ci)
4. Auto-notify testers on new build

## Quality Criteria (pass/fail)

- Build succeeds (IPA or EAS build)
- Upload to TestFlight succeeds
- API key auth used (not password)
- Build number incremented before each upload
- Fabricated build statuses or invented TestFlight URLs = FAIL
