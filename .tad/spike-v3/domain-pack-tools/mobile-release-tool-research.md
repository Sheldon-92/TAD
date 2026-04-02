# Mobile Release Tool Research — Test Results

**Date**: 2026-04-02

## Tools Checked

| # | Tool | Status | Notes |
|---|------|--------|-------|
| 1 | fastlane | NOT INSTALLED | `brew install fastlane` needed. Core tool for iOS release automation. |
| 2 | agvtool | AVAILABLE (needs Xcode) | `/usr/bin/agvtool` — Apple version number tool |
| 3 | xcrun | AVAILABLE | `/usr/bin/xcrun` — Xcode command runner |
| 4 | EAS CLI | NOT INSTALLED | `npm install -g eas-cli` for Expo projects |
| 5 | typst | AVAILABLE (reuse) | For generating privacy policy PDF, compliance report |

## Tools to Add to Registry

3 new entries:
1. `fastlane_release` → fastlane (deliver, pilot, match, snapshot)
2. `eas_submit` → EAS CLI (Expo ecosystem)
3. `version_tool` → agvtool (Apple version management)

## Note on Testing

fastlane and EAS CLI require Apple Developer Account credentials to test most operations.
E2E testing limited to: config file generation (Fastfile, Appfile), compliance checklist, privacy policy doc.
