import { by, device, element, expect, waitFor } from 'detox';

describe('Error Recovery & Offline', () => {
  beforeAll(async () => {
    await device.launchApp({
      permissions: { camera: 'YES' },
    });
  });

  beforeEach(async () => {
    await device.reloadReactNative();
  });

  it('should show error state when scan fails (no network)', async () => {
    // Arrange: disable network [ASSUMPTION] using Detox device API
    await device.setURLBlacklist(['.*']);

    await waitFor(element(by.id('camera-overlay')))
      .toBeVisible()
      .withTimeout(5000);

    // Act: capture (translation API will fail)
    await element(by.id('capture-button')).tap();

    // Assert: error state with retry button
    await waitFor(element(by.id('error-screen')))
      .toBeVisible()
      .withTimeout(10000);
    await expect(element(by.id('retry-button'))).toBeVisible();

    // Cleanup
    await device.setURLBlacklist([]);
  });

  it('should retry successfully after network restored', async () => {
    // Go offline
    await device.setURLBlacklist(['.*']);
    await waitFor(element(by.id('camera-overlay')))
      .toBeVisible()
      .withTimeout(5000);
    await element(by.id('capture-button')).tap();
    await waitFor(element(by.id('error-screen')))
      .toBeVisible()
      .withTimeout(10000);

    // Restore network
    await device.setURLBlacklist([]);

    // Act: retry
    await element(by.id('retry-button')).tap();

    // Assert: results eventually load
    await waitFor(element(by.id('results-screen')))
      .toBeVisible()
      .withTimeout(15000);
  });

  it('should handle camera permission denied gracefully', async () => {
    // [ASSUMPTION] App launched without camera permission shows a permission prompt screen
    await device.launchApp({
      delete: true,
      permissions: { camera: 'NO' },
    });

    // Assert: permission request screen (not a crash)
    await waitFor(element(by.id('camera-permission-prompt')))
      .toBeVisible()
      .withTimeout(5000);
    await expect(element(by.id('open-settings-button'))).toBeVisible();
  });
});
