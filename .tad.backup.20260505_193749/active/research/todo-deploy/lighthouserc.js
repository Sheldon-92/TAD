/**
 * Lighthouse CI Configuration
 * Run: npx @lhci/cli autorun
 */
module.exports = {
  ci: {
    collect: {
      // Number of runs per URL (median is used)
      numberOfRuns: 3,

      // URLs to audit
      url: [
        'http://localhost:3000/',           // Landing page
        'http://localhost:3000/login',      // Auth page
        'http://localhost:3000/dashboard',  // Main app page (requires auth mock)
      ],

      // Start server for CI
      startServerCommand: 'npm run start',
      startServerReadyPattern: 'ready on',
      startServerReadyTimeout: 30000,

      // Chrome flags for CI environment
      settings: {
        chromeFlags: '--no-sandbox --headless --disable-gpu',
        preset: 'desktop', // Test desktop performance
      },
    },

    assert: {
      assertions: {
        // ── Performance ──
        'categories:performance': ['error', { minScore: 0.9 }],
        'first-contentful-paint': ['warn', { maxNumericValue: 1500 }],    // 1.5s
        'largest-contentful-paint': ['error', { maxNumericValue: 2500 }],  // 2.5s
        'cumulative-layout-shift': ['error', { maxNumericValue: 0.1 }],
        'total-blocking-time': ['warn', { maxNumericValue: 200 }],        // 200ms
        'interactive': ['error', { maxNumericValue: 3500 }],              // 3.5s TTI

        // ── Accessibility ──
        'categories:accessibility': ['error', { minScore: 0.9 }],

        // ── Best Practices ──
        'categories:best-practices': ['error', { minScore: 0.9 }],

        // ── SEO ──
        'categories:seo': ['warn', { minScore: 0.9 }],

        // ── Resource Budgets ──
        'resource-summary:script:size': ['error', { maxNumericValue: 204800 }],  // 200KB JS
        'resource-summary:image:size': ['warn', { maxNumericValue: 512000 }],    // 500KB images
        'resource-summary:total:size': ['error', { maxNumericValue: 1048576 }],  // 1MB total

        // ── Security ──
        'is-on-https': 'error',
        'redirects-http': 'error',
      },
    },

    upload: {
      // Use temporary public storage for CI (free)
      target: 'temporary-public-storage',
      // Alternative: self-hosted LHCI server
      // target: 'lhci',
      // serverBaseUrl: 'https://lhci.todoapp.example.com',
    },
  },
};
