# Release Automation — CI/CD Pipeline

CI/CD pipeline for automated build → test → upload → submit. Docs to `.tad/active/release/{project}/` (ci-strategy.md, ci-verification.md, ci-optimization.md); pipeline config (.github/workflows/release.yml or eas.json) goes into the project.

## Step 1: Select CI Platform

1. GitHub Actions + fastlane → most flexible, free for public repos
2. EAS Build → cloud-based, no local Xcode needed
3. Xcode Cloud → Apple-native, tight integration

Decision based on: existing CI, team familiarity, budget.

## Step 2: Set Up the Release Pipeline

1. Create `.github/workflows/release.yml` (or eas.json profiles)
2. Stages: lint → test → build → upload → notify
3. Secrets: Apple API key, match passphrase, team ID — in CI secrets storage, never in code
4. For fastlane + GitHub Actions: use `setup_ci` action (temporary keychain)
5. For EAS: configure build profiles (development, preview, production)

## Step 3: Verify the Pipeline

1. Push to trigger branch → CI runs
2. Build succeeds in CI
3. Upload to TestFlight succeeds from CI
4. Secrets not exposed in logs

## Step 4: Optimize

1. Cache dependencies (node_modules, CocoaPods)
2. Parallel jobs where possible (lint + test in parallel, build after)
3. Conditional submission (only on tagged commits)
4. Slack/Discord notification on success/failure

## Quality Criteria (pass/fail)

- CI pipeline triggers on push/tag
- Build + upload succeeds in CI environment
- Secrets stored securely (not in code)
- Pipeline has lint → test → build → upload stages
- Fabricated CI results or invented pipeline statuses = FAIL
