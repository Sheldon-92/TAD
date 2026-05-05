/**
 * Sentry Server-Side Configuration
 * Loaded automatically by @sentry/nextjs on the server (API routes, SSR).
 */
import * as Sentry from '@sentry/nextjs';

Sentry.init({
  dsn: process.env.SENTRY_DSN,

  // Environment tagging
  environment: process.env.NODE_ENV ?? 'development',

  // Performance Monitoring — lower sample rate on server (higher volume)
  tracesSampleRate: process.env.NODE_ENV === 'production' ? 0.05 : 1.0,

  // Profile server-side performance
  profilesSampleRate: process.env.NODE_ENV === 'production' ? 0.05 : 0,

  integrations: [
    Sentry.prismaIntegration(), // Track Prisma query spans
  ],

  // Release tracking
  release: process.env.NEXT_PUBLIC_APP_VERSION,

  // Don't send PII
  sendDefaultPii: false,

  // Scrub sensitive server-side data
  beforeSend(event) {
    // Remove database connection strings from stack traces
    if (event.exception?.values) {
      event.exception.values.forEach((ex) => {
        if (ex.value) {
          ex.value = ex.value.replace(
            /postgresql:\/\/[^@]+@[^\s]+/g,
            'postgresql://[REDACTED]'
          );
        }
      });
    }
    return event;
  },

  beforeSendTransaction(transaction) {
    // Drop health check transactions (noisy, no value)
    if (transaction.transaction === 'GET /api/health') {
      return null;
    }
    return transaction;
  },
});
