# Version Management — Semver + Build Numbers

Semantic versioning + build number management — automated, consistent, tagged. Docs to `.tad/active/release/{project}/` (version-strategy.md, version-verification.md, version-optimization.md); version config lives in the project.

## Step 1: Select Version Strategy

1. Expo → version in app.json (`"version": "1.0.0"`, `"ios.buildNumber": "1"`)
2. Native → agvtool or fastlane increment_build_number
3. Semantic versioning: MAJOR.MINOR.PATCH
   - MAJOR: breaking changes / major redesign
   - MINOR: new features
   - PATCH: bug fixes
4. Build number: auto-increment on every TestFlight upload

## Step 2: Set Up Version Management

1. For Expo: script to bump app.json version + buildNumber
2. For native: fastlane lane to increment + commit
3. Git tag on each release: `git tag v{version}`
4. CHANGELOG.md generation (optional: from git commits)

## Step 3: Verify

1. Version number follows semver (X.Y.Z)
2. Build number increments on each upload
3. Git tag exists for current version
4. Version in app matches version in Store listing

## Step 4: Optimize

1. Automate in CI (increment build number on merge to main)
2. Auto-generate CHANGELOG from conventional commits
3. Pre-release versions for beta: `1.0.0-beta.1`

## Quality Criteria (pass/fail)

- Version follows semantic versioning (MAJOR.MINOR.PATCH)
- Build number auto-incremented before each TestFlight upload
- Git tag exists for each release
- Fabricated version numbers or skipped builds = FAIL
