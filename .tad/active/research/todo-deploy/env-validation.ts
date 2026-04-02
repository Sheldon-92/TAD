/**
 * Environment variable validation using Zod.
 * Import this at app startup (e.g., in instrumentation.ts or layout.tsx).
 * Missing required variables will throw a clear error at build/start time.
 */
import { z } from 'zod';

// Server-side environment variables (never exposed to client)
const serverSchema = z.object({
  // L1 Critical
  DATABASE_URL: z.string().min(1, 'DATABASE_URL is required'),
  JWT_SECRET: z.string().min(32, 'JWT_SECRET must be at least 32 characters'),

  // L2 Sensitive
  SENTRY_DSN: z.string().url().optional(),
  SENTRY_AUTH_TOKEN: z.string().optional(),
  SMTP_HOST: z.string().optional(),
  SMTP_PORT: z.coerce.number().int().positive().optional(),
  SMTP_USER: z.string().optional(),
  SMTP_PASSWORD: z.string().optional(),

  // L3 Config
  NODE_ENV: z.enum(['development', 'test', 'staging', 'production']).default('development'),
  APP_URL: z.string().url().default('http://localhost:3000'),
  API_BASE_URL: z.string().url().default('http://localhost:3000/api'),
  JWT_EXPIRY: z.string().default('7d'),
  ENABLE_REGISTRATION: z.coerce.boolean().default(true),
  ENABLE_EMAIL_NOTIFICATIONS: z.coerce.boolean().default(false),
  MAX_TODOS_PER_USER: z.coerce.number().int().positive().default(100),
});

// Client-side environment variables (exposed to browser via NEXT_PUBLIC_*)
const clientSchema = z.object({
  NEXT_PUBLIC_APP_NAME: z.string().default('TodoApp'),
  NEXT_PUBLIC_APP_VERSION: z.string().default('0.0.0'),
  NEXT_PUBLIC_SENTRY_DSN: z.string().url().optional(),
  NEXT_PUBLIC_API_URL: z.string().default('/api'),
});

// Validate and export
export type ServerEnv = z.infer<typeof serverSchema>;
export type ClientEnv = z.infer<typeof clientSchema>;

function validateEnv() {
  const serverResult = serverSchema.safeParse(process.env);
  const clientResult = clientSchema.safeParse(process.env);

  const errors: string[] = [];

  if (!serverResult.success) {
    errors.push(
      '--- Server Env Errors ---',
      ...serverResult.error.issues.map(
        (i) => `  ${i.path.join('.')}: ${i.message}`
      )
    );
  }

  if (!clientResult.success) {
    errors.push(
      '--- Client Env Errors ---',
      ...clientResult.error.issues.map(
        (i) => `  ${i.path.join('.')}: ${i.message}`
      )
    );
  }

  if (errors.length > 0) {
    console.error('\n========================================');
    console.error(' ENVIRONMENT VALIDATION FAILED');
    console.error('========================================');
    console.error(errors.join('\n'));
    console.error('========================================\n');
    throw new Error(`Missing or invalid environment variables:\n${errors.join('\n')}`);
  }

  return {
    server: serverResult.data!,
    client: clientResult.data!,
  };
}

// Security audit: ensure no L1/L2 secrets leak to client
function auditClientExposure() {
  const dangerousPatterns = [
    'NEXT_PUBLIC_JWT_SECRET',
    'NEXT_PUBLIC_DATABASE_URL',
    'NEXT_PUBLIC_ENCRYPTION_KEY',
    'NEXT_PUBLIC_SMTP_PASSWORD',
  ];

  for (const key of dangerousPatterns) {
    if (process.env[key]) {
      throw new Error(
        `SECURITY: ${key} detected! L1/L2 secrets must NEVER use NEXT_PUBLIC_ prefix.`
      );
    }
  }
}

// Run on import
auditClientExposure();
export const env = validateEnv();
