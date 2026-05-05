import { by, device, element, expect, waitFor } from 'detox';

describe('Dish Detail View', () => {
  beforeAll(async () => {
    await device.launchApp({
      permissions: { camera: 'YES' },
    });
  });

  beforeEach(async () => {
    await device.reloadReactNative();
    // Navigate to results screen (scan a menu first)
    await waitFor(element(by.id('camera-overlay')))
      .toBeVisible()
      .withTimeout(5000);
    await element(by.id('capture-button')).tap();
    await waitFor(element(by.id('results-screen')))
      .toBeVisible()
      .withTimeout(10000);
  });

  it('should open dish detail when tapping a menu card', async () => {
    // Act
    await element(by.id('menu-card-0')).tap();

    // Assert
    await waitFor(element(by.id('dish-detail-screen')))
      .toBeVisible()
      .withTimeout(3000);
    await expect(element(by.id('dish-name'))).toBeVisible();
    await expect(element(by.id('dish-description'))).toBeVisible();
    await expect(element(by.id('dish-price'))).toBeVisible();
  });

  it('should display dietary badges on dish detail', async () => {
    await element(by.id('menu-card-0')).tap();
    await waitFor(element(by.id('dish-detail-screen')))
      .toBeVisible()
      .withTimeout(3000);

    // Assert: dietary info section exists
    await expect(element(by.id('dietary-badges-section'))).toExist();
  });

  it('should display AI recommendation section', async () => {
    await element(by.id('menu-card-0')).tap();
    await waitFor(element(by.id('dish-detail-screen')))
      .toBeVisible()
      .withTimeout(3000);

    // Assert: AI recommendation
    await expect(element(by.id('ai-recommendation'))).toExist();
  });

  it('should navigate back to results list', async () => {
    await element(by.id('menu-card-0')).tap();
    await waitFor(element(by.id('dish-detail-screen')))
      .toBeVisible()
      .withTimeout(3000);

    // Act: go back
    await element(by.id('back-button')).tap();

    // Assert
    await waitFor(element(by.id('results-screen')))
      .toBeVisible()
      .withTimeout(3000);
  });
});
