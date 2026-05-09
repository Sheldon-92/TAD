import { by, device, element, expect, waitFor } from 'detox';

describe('Save to Favorites', () => {
  beforeAll(async () => {
    await device.launchApp({
      delete: true, // Fresh state — no existing favorites
      permissions: { camera: 'YES' },
    });
  });

  beforeEach(async () => {
    await device.reloadReactNative();
    // Navigate to dish detail
    await waitFor(element(by.id('camera-overlay')))
      .toBeVisible()
      .withTimeout(5000);
    await element(by.id('capture-button')).tap();
    await waitFor(element(by.id('results-screen')))
      .toBeVisible()
      .withTimeout(10000);
    await element(by.id('menu-card-0')).tap();
    await waitFor(element(by.id('dish-detail-screen')))
      .toBeVisible()
      .withTimeout(3000);
  });

  it('should save a dish to favorites', async () => {
    // Act
    await element(by.id('favorite-button')).tap();

    // Assert: button changes to "saved" state
    await waitFor(element(by.id('favorite-button-active')))
      .toBeVisible()
      .withTimeout(2000);
  });

  it('should show saved dish in favorites tab', async () => {
    // Save a dish
    await element(by.id('favorite-button')).tap();
    await waitFor(element(by.id('favorite-button-active')))
      .toBeVisible()
      .withTimeout(2000);

    // Navigate to favorites tab
    await element(by.id('back-button')).tap();
    await waitFor(element(by.id('results-screen')))
      .toBeVisible()
      .withTimeout(3000);
    await element(by.id('tab-favorites')).tap();

    // Assert: at least one favorite item
    await waitFor(element(by.id('favorites-screen')))
      .toBeVisible()
      .withTimeout(3000);
    await expect(element(by.id('favorite-item-0'))).toBeVisible();
  });

  it('should remove dish from favorites on second tap', async () => {
    // Save first
    await element(by.id('favorite-button')).tap();
    await waitFor(element(by.id('favorite-button-active')))
      .toBeVisible()
      .withTimeout(2000);

    // Act: unsave
    await element(by.id('favorite-button-active')).tap();

    // Assert: reverted to unsaved state
    await waitFor(element(by.id('favorite-button')))
      .toBeVisible()
      .withTimeout(2000);
  });
});
