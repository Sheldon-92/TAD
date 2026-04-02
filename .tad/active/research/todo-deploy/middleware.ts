/**
 * Next.js Edge Middleware
 * Handles: CSP nonce injection, rate limiting headers, security
 */
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

// Generate cryptographic nonce for CSP
function generateNonce(): string {
  const array = new Uint8Array(16);
  crypto.getRandomValues(array);
  return Buffer.from(array).toString('base64');
}

// Rate limiting configuration
// [ASSUMPTION] Using in-memory counter for demo; production should use
// @upstash/ratelimit with Vercel KV for distributed rate limiting
const RATE_LIMITS: Record<string, { requests: number; windowMs: number }> = {
  '/api/auth/login':    { requests: 5,    windowMs: 60_000 },   // 5/min
  '/api/auth/register': { requests: 3,    windowMs: 60_000 },   // 3/min
  '/api/todos':         { requests: 60,   windowMs: 60_000 },   // 60/min
  '/api/':              { requests: 100,  windowMs: 60_000 },   // 100/min (default API)
};

export function middleware(request: NextRequest) {
  const nonce = generateNonce();
  const { pathname } = request.nextUrl;

  // Build CSP with nonce
  const cspHeader = [
    "default-src 'self'",
    `script-src 'self' 'nonce-${nonce}'`,
    `style-src 'self' 'nonce-${nonce}' https://fonts.googleapis.com`,
    "img-src 'self' data: https: blob:",
    "font-src 'self' https://fonts.gstatic.com",
    "connect-src 'self' https://o0.ingest.sentry.io https://vitals.vercel-insights.com",
    "frame-src 'none'",
    "object-src 'none'",
    "base-uri 'self'",
    "form-action 'self'",
    "frame-ancestors 'none'",
    "upgrade-insecure-requests",
  ].join('; ');

  const response = NextResponse.next({
    request: {
      headers: new Headers(request.headers),
    },
  });

  // Inject CSP nonce (Phase 1: Report-Only; Phase 2: switch header name)
  response.headers.set('Content-Security-Policy-Report-Only', cspHeader);
  // response.headers.set('Content-Security-Policy', cspHeader);  // Phase 2

  // Pass nonce to server components via header
  response.headers.set('x-nonce', nonce);

  // Add rate limit info header for API routes
  if (pathname.startsWith('/api/')) {
    const matchedLimit = Object.entries(RATE_LIMITS).find(([path]) =>
      pathname.startsWith(path)
    );
    if (matchedLimit) {
      const [, limit] = matchedLimit;
      response.headers.set('X-RateLimit-Limit', String(limit.requests));
      // [ASSUMPTION] Actual counter tracking requires persistent storage (Redis/KV)
      // This middleware sets the headers; actual enforcement needs @upstash/ratelimit
    }
  }

  return response;
}

export const config = {
  matcher: [
    // Match all paths except static files and images
    '/((?!_next/static|_next/image|favicon.ico|images/).*)',
  ],
};
