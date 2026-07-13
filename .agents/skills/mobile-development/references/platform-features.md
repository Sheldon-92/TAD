# Platform Features

Integrate platform-specific features — camera, location, notifications, biometrics.
Workflow shape: select → execute → verify → optimize.

## 1. Select features

Identify needed platform features:

1. **Camera**: expo-camera (photo/video capture)
2. **Location**: expo-location (GPS, geofencing)
3. **Notifications**: expo-notifications (push + local)
4. **Biometrics**: expo-local-authentication (Face ID / Touch ID)
5. **File system**: expo-file-system

For each: check permission requirements, check iOS/Android differences. Document the plan (platform-features-plan.md).

## 2. Execute features

Implement each feature:

1. Permission flow: check → request → handle denial gracefully
2. Request permissions IN CONTEXT (when user needs the feature, not at app start)
3. Add to app.json `plugins` array for native configuration
4. iOS: add NSUsageDescription strings
5. Android: add to AndroidManifest.xml (Expo handles via plugins)

## 3. Verify features

Use a mobile simulator/device:

1. Each feature works on simulator/device
2. Permission denial handled (app doesn't crash, shows helpful message)
3. app.json plugins correctly configured
4. iOS privacy descriptions present

## 4. Optimize

1. Lazy-load heavy feature modules (camera only when needed)
2. Cache permission status (don't re-check every render)
3. Background location: use significant-change mode (saves battery)

## Quality criteria (pass/fail)

- Permission requested in context (not all at app start)
- Permission denial handled gracefully (no crash)
- iOS NSUsageDescription strings present for all used permissions
- app.json plugins correctly configured
- Fabricated platform behavior or invented permission APIs = FAIL
