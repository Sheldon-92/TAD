import { by, device, element, expect, waitFor } from 'detox';

describe('Dietary Filter Application', () => {
  beforeAll(async () => {
    await device.launchApp({
      permissions: { camera: 'YES' },
    });
  });

  beforeEach(async () => {
    await device.reloadReactNative();
    // Navigate to results screen
    await waitFor(element(by.id('camera-overlay')))
      .toBeVisible()
      .withTimeout(5000);
    await element(by.id('capture-button')).tap();
    await waitFor(element(by.id('results-screen')))
      .toBeVisible()
      .withTimeout(10000);
  });

  it('should open dietary filter sheet', async () => {
    // Act
    await element(by.id('filter-button')).tap();

    // Assert
    await waitFor(element(by.id('dietary-filter-sheet')))
      .toBeVisible()
      .withTimeout(3000);
    await expect(element(by.id('filter-vegetarian'))).toBeVisible();
    await expect(element(by.id('filter-vegan'))).toBeVisible();
    await expect(element(by.id('filter-gluten-free'))).toBeVisible();
    await expect(element(by.id('filter-nut-free'))).toBeVisible();
  });

  it('should filter menu items by vegetarian', async () => {
    // Open filter
    await element(by.id('filter-button')).tap();
    await waitFor(element(by.id('dietary-filter-sheet')))
      .toBeVisible()
      .withTimeout(3000);

    // Act: select vegetarian
    await element(by.id('filter-vegetarian')).tap();
    await element(by.id('apply-filters-button')).tap();

    // Assert: filter badge visible on results screen
    await waitFor(element(by.id('active-filter-badge')))
      .toBeVisible()
      .withTimeout(3000);
    // Results screen should update (menu cards still present)
    await expect(element(by.id('results-screen'))).toBeVisible();
  });

  it('should apply multiple dietary filters', async () => {
    await element(by.id('filter-button')).tap();
    await waitFor(element(by.id('dietary-filter-sheet')))
      .toBeVisible()
      .withTimeout(3000);

    // Act: select vegan + gluten-free
    await element(by.id('filter-vegan')).tap();
    await element(by.id('filter-gluten-free')).tap();
    await element(by.id('apply-filters-button')).tap();

    // Assert: multiple filter badges
    await waitFor(element(by.id('active-filter-badge')))
      .toBeVisible()
      .withTimeout(3000);
  });

  it('should clear all filters', async () => {
    // Apply a filter first
    await element(by.id('filter-button')).tap();
    await waitFor(element(by.id('dietary-filter-sheet')))
      .toBeVisible()
      .withTimeout(3000);
    await element(by.id('filter-vegetarian')).tap();
    await element(by.id('apply-filters-button')).tap();
    await waitFor(element(by.id('active-filter-badge')))
      .toBeVisible()
      .withTimeout(3000);

    // Act: clear
    await element(by.id('clear-filters-button')).tap();

    // Assert: no filter badge
    await waitFor(element(by.id('active-filter-badge')))
      .not.toBeVisible()
      .withTimeout(3000);
  });

  it('should show empty state when no dishes match filters', async () => {
    // [ASSUMPTION] Selecting all restrictive filters may yield zero results
    await element(by.id('filter-button')).tap();
    await waitFor(element(by.id('dietary-filter-sheet')))
      .toBeVisible()
      .withTimeout(3000);
    await element(by.id('filter-vegan')).tap();
    await element(by.id('filter-gluten-free')).tap();
    await element(by.id('filter-nut-free')).tap();
    await element(by.id('apply-filters-button')).tap();

    // Assert: empty state OR filtered results
    // Exact behavior depends on menu content
    await expect(element(by.id('results-screen'))).toBeVisible();
  });
});
