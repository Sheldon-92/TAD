/**
 * Security Headers Configuration for Next.js
 * Use in next.config.js: headers() function
 *
 * References:
 * - OWASP Secure Headers Project (https://owasp.org/www-project-secure-headers/)
 * - OWASP HTTP Headers Cheat Sheet (https://cheatsheetseries.owasp.org/cheatsheets/HTTP_Headers_Cheat_Sheet.html)
 */

// ── Phase 1: Report-Only CSP (deploy first, monitor for 2 weeks) ──
export const CSP_REPORT_ONLY = [
  "default-src 'self'",
  "script-src 'self' 'nonce-{NONCE}'",  // Nonce injected per-request by middleware
  "style-src 'self' 'nonce-{NONCE}' https://fonts.googleapis.com",
  "img-src 'self' data: https: blob:",
  "font-src 'self' https://fonts.gstatic.com",
  "connect-src 'self' https://o0.ingest.sentry.io https://vitals.vercel-insights.com",
  "frame-src 'none'",
  "object-src 'none'",
  "base-uri 'self'",
  "form-action 'self'",
  "frame-ancestors 'none'",
  "upgrade-insecure-requests",
  "report-uri /api/csp-report",
].join('; ');

// ── Phase 2: Enforced CSP (after validating no false positives) ──
export const CSP_ENFORCE = CSP_REPORT_ONLY; // Same policy, different header name

// ── Complete Security Headers (OWASP recommended) ──
export const securityHeaders = [
  // === Headers to SET ===

  // Prevent XSS — use nonce-based strict CSP
  {
    key: 'Content-Security-Policy-Report-Only', // Phase 1
    // key: 'Content-Security-Policy',           // Phase 2 (swap when ready)
    value: CSP_REPORT_ONLY,
  },

  // Force HTTPS for 1 year, include subdomains, allow HSTS preload list
  {
    key: 'Strict-Transport-Security',
    value: 'max-age=31536000; includeSubDomains; preload',
  },

  // Prevent MIME type sniffing (stops browsers guessing content types)
  {
    key: 'X-Content-Type-Options',
    value: 'nosniff',
  },

  // Prevent clickjacking (redundant with CSP frame-ancestors but older browser compat)
  {
    key: 'X-Frame-Options',
    value: 'DENY',
  },

  // Control referrer information sent with requests
  {
    key: 'Referrer-Policy',
    value: 'strict-origin-when-cross-origin',
  },

  // Restrict browser features (camera, mic, location, etc.)
  {
    key: 'Permissions-Policy',
    value: 'camera=(), microphone=(), geolocation=(), browsing-topics=(), payment=(), usb=()',
  },

  // Prevent cross-origin information leaks
  {
    key: 'Cross-Origin-Opener-Policy',
    value: 'same-origin',
  },

  // Prevent cross-origin resource reading
  {
    key: 'Cross-Origin-Resource-Policy',
    value: 'same-origin',
  },

  // Prevent cross-origin embedding attacks
  {
    key: 'Cross-Origin-Embedder-Policy',
    value: 'require-corp',
  },

  // Enable DNS prefetch for performance
  {
    key: 'X-DNS-Prefetch-Control',
    value: 'on',
  },
];

// ── Headers to REMOVE (via next.config.js poweredByHeader: false) ──
// X-Powered-By: removed by setting poweredByHeader: false in next.config.js
// Server: typically handled by the deployment platform (Vercel strips by default)

// ── next.config.js integration ──
export const nextConfigHeaders = {
  // Add to next.config.js
  poweredByHeader: false, // Remove X-Powered-By header
  async headers() {
    return [
      {
        source: '/(.*)',
        headers: securityHeaders,
      },
    ];
  },
};
