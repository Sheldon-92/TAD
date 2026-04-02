/**
 * Sentry Client-Side Configuration
 * Loaded automatically by @sentry/nextjs in the browser.
 */
import * as Sentry from '@sentry/nextjs';

Sentry.init({
  dsn: process.env.NEXT_PUBLIC_SENTRY_DSN,

  // Environment tagging
  environment: process.env.NODE_ENV ?? 'development',

  // Performance Monitoring
  tracesSampleRate: process.env.NODE_ENV === 'production' ? 0.1 : 1.0,

  // Session Replay (captures user interactions for debugging)
  replaysSessionSampleRate: 0.01, // 1% of sessions
  replaysOnErrorSampleRate: 1.0,  // 100% of sessions with errors

  integrations: [
    Sentry.replayIntegration({
      maskAllText: true,
      blockAllMedia: true,
    }),
    Sentry.browserTracingIntegration(),
  ],

  // Filter out known noise
  ignoreErrors: [
    // Browser extension noise
    'ResizeObserver loop',
    'Non-Error exception captured',
    // Network errors users can't control
    'Failed to fetch',
    'NetworkError',
    'Load failed',
  ],

  // Don't send PII
  sendDefaultPii: false,

  // Release tracking (set by CI/CD)
  release: process.env.NEXT_PUBLIC_APP_VERSION,

  // Before sending, scrub sensitive data
  beforeSend(event) {
    // Remove cookies from breadcrumbs
    if (event.breadcrumbs) {
      event.breadcrumbs = event.breadcrumbs.map((bc) => {
        if (bc.data?.headers?.cookie) {
          bc.data.headers.cookie = '[REDACTED]';
        }
        return bc;
      });
    }
    return event;
  },
});
