import { by, device, element, expect, waitFor } from 'detox';

describe('Camera Scan -> Results Display', () => {
  beforeAll(async () => {
    await device.launchApp({
      permissions: { camera: 'YES', photos: 'YES' },
    });
  });

  beforeEach(async () => {
    await device.reloadReactNative();
  });

  it('should display camera overlay on launch', async () => {
    await waitFor(element(by.id('camera-overlay')))
      .toBeVisible()
      .withTimeout(5000);
    await expect(element(by.id('capture-button'))).toBeVisible();
    await expect(element(by.id('flash-toggle'))).toBeVisible();
  });

  it('should capture menu image and show scanning indicator', async () => {
    // Arrange: camera overlay visible
    await waitFor(element(by.id('camera-overlay')))
      .toBeVisible()
      .withTimeout(5000);

    // Act: tap capture
    await element(by.id('capture-button')).tap();

    // Assert: scanning indicator appears
    await waitFor(element(by.id('scanning-indicator')))
      .toBeVisible()
      .withTimeout(3000);
  });

  it('should display translated menu results after scan', async () => {
    // Arrange
    await waitFor(element(by.id('camera-overlay')))
      .toBeVisible()
      .withTimeout(5000);

    // Act: capture and wait for results
    await element(by.id('capture-button')).tap();
    await waitFor(element(by.id('results-screen')))
      .toBeVisible()
      .withTimeout(10000);

    // Assert: at least one menu card is visible
    await expect(element(by.id('menu-card-0'))).toBeVisible();
    // Assert: translation text is present
    await expect(element(by.id('translation-text-0'))).toExist();
  });

  it('should allow retaking photo from results screen', async () => {
    // Navigate to results first
    await waitFor(element(by.id('camera-overlay')))
      .toBeVisible()
      .withTimeout(5000);
    await element(by.id('capture-button')).tap();
    await waitFor(element(by.id('results-screen')))
      .toBeVisible()
      .withTimeout(10000);

    // Act: tap retake
    await element(by.id('retake-button')).tap();

    // Assert: back to camera
    await waitFor(element(by.id('camera-overlay')))
      .toBeVisible()
      .withTimeout(5000);
  });

  afterEach(async () => {
    // Screenshot on failure is handled by jest-circus + Detox artifacts
  });
});
