// Auth Middleware — Multi-Tenant SaaS Billing System
// Supports JWT Bearer Token + API Key dual authentication

import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import crypto from 'crypto';
import Stripe from 'stripe';

// ═══════════════════════════════════════
// Types
// ═══════════════════════════════════════

export interface JwtPayload {
  sub: string;         // userId
  tenantId: string;
  role: UserRole;
  permissions: string[];
  iat: number;
  exp: number;
}

export enum UserRole {
  SUPER_ADMIN = 'SUPER_ADMIN',
  TENANT_ADMIN = 'TENANT_ADMIN',
  BILLING_ADMIN = 'BILLING_ADMIN',
  MEMBER = 'MEMBER',
}

export interface AuthContext {
  userId: string | null;       // null for API key auth
  tenantId: string;
  role: UserRole;
  permissions: string[];
  authMethod: 'jwt' | 'api_key';
}

declare global {
  namespace Express {
    interface Request {
      auth?: AuthContext;
    }
  }
}

// ═══════════════════════════════════════
// JWT Authentication
// ═══════════════════════════════════════

const JWT_SECRET = process.env.JWT_SECRET!;
const JWT_ISSUER = process.env.JWT_ISSUER || 'https://api.example.com';

export function verifyJwt(token: string): JwtPayload {
  return jwt.verify(token, JWT_SECRET, {
    issuer: JWT_ISSUER,
    audience: JWT_ISSUER,
  }) as JwtPayload;
}

export function signAccessToken(payload: Omit<JwtPayload, 'iat' | 'exp'>): string {
  return jwt.sign(payload, JWT_SECRET, {
    expiresIn: '15m',
    issuer: JWT_ISSUER,
    audience: JWT_ISSUER,
  });
}

export function signRefreshToken(userId: string): string {
  return jwt.sign({ sub: userId, type: 'refresh' }, JWT_SECRET, {
    expiresIn: '7d',
    issuer: JWT_ISSUER,
  });
}

// ═══════════════════════════════════════
// API Key Authentication
// ═══════════════════════════════════════

function hashApiKey(key: string): string {
  return crypto.createHash('sha256').update(key).digest('hex');
}

// [ASSUMPTION] ApiKeyRepository is injected via DI in production
async function lookupApiKey(keyHash: string): Promise<{
  tenantId: string;
  expiresAt: Date | null;
  revokedAt: Date | null;
} | null> {
  // Repository call: prisma.apiKey.findUnique({ where: { keyHash } })
  throw new Error('Implement with actual repository');
}

// ═══════════════════════════════════════
// Authentication Middleware
// ═══════════════════════════════════════

/**
 * Authenticate request via JWT Bearer token or API Key.
 * Sets req.auth with tenant context and permissions.
 */
export function authenticate(
  req: Request,
  res: Response,
  next: NextFunction
): void {
  const authHeader = req.headers.authorization;
  const apiKey = req.headers['x-api-key'] as string | undefined;

  if (authHeader?.startsWith('Bearer ')) {
    // JWT authentication
    const token = authHeader.slice(7);
    try {
      const payload = verifyJwt(token);
      req.auth = {
        userId: payload.sub,
        tenantId: payload.tenantId,
        role: payload.role as UserRole,
        permissions: payload.permissions,
        authMethod: 'jwt',
      };
      return next();
    } catch (err) {
      res.status(401).json({
        type: 'https://api.example.com/errors/unauthorized',
        title: 'Unauthorized',
        status: 401,
        detail: 'Invalid or expired token.',
        error_code: 'INVALID_TOKEN',
      });
      return;
    }
  }

  if (apiKey) {
    // API Key authentication
    const keyHash = hashApiKey(apiKey);
    lookupApiKey(keyHash)
      .then((result) => {
        if (!result) {
          res.status(401).json({
            type: 'https://api.example.com/errors/unauthorized',
            title: 'Unauthorized',
            status: 401,
            detail: 'Invalid API key.',
            error_code: 'INVALID_API_KEY',
          });
          return;
        }

        if (result.revokedAt) {
          res.status(401).json({
            type: 'https://api.example.com/errors/unauthorized',
            title: 'Unauthorized',
            status: 401,
            detail: 'API key has been revoked.',
            error_code: 'API_KEY_REVOKED',
          });
          return;
        }

        if (result.expiresAt && result.expiresAt < new Date()) {
          res.status(401).json({
            type: 'https://api.example.com/errors/unauthorized',
            title: 'Unauthorized',
            status: 401,
            detail: 'API key has expired.',
            error_code: 'API_KEY_EXPIRED',
          });
          return;
        }

        req.auth = {
          userId: null, // API keys don't have user context
          tenantId: result.tenantId,
          role: UserRole.BILLING_ADMIN, // [ASSUMPTION] API keys have BillingAdmin-level access
          permissions: ['usage:record', 'usage:read'],
          authMethod: 'api_key',
        };
        next();
      })
      .catch(next);
    return;
  }

  // No credentials
  res.status(401).json({
    type: 'https://api.example.com/errors/unauthorized',
    title: 'Unauthorized',
    status: 401,
    detail: 'Authentication credentials are missing.',
    error_code: 'MISSING_TOKEN',
  });
}

// ═══════════════════════════════════════
// Authorization Middleware
// ═══════════════════════════════════════

/**
 * Check if user has required permission.
 * SuperAdmin bypasses all permission checks.
 */
export function requirePermission(permission: string) {
  return (req: Request, res: Response, next: NextFunction): void => {
    if (!req.auth) {
      res.status(401).json({
        type: 'https://api.example.com/errors/unauthorized',
        title: 'Unauthorized',
        status: 401,
        detail: 'Authentication required.',
        error_code: 'MISSING_TOKEN',
      });
      return;
    }

    // SuperAdmin bypasses permission checks
    if (req.auth.role === UserRole.SUPER_ADMIN) {
      return next();
    }

    if (!req.auth.permissions.includes(permission)) {
      res.status(403).json({
        type: 'https://api.example.com/errors/forbidden',
        title: 'Forbidden',
        status: 403,
        detail: `Missing required permission: ${permission}`,
        error_code: 'INSUFFICIENT_PERMISSIONS',
      });
      return;
    }

    next();
  };
}

/**
 * Enforce tenant scope — non-SuperAdmin users can only access their own tenant's resources.
 * Reads tenantId from route params and compares with JWT claims.
 */
export function enforceTenantScope(
  req: Request,
  res: Response,
  next: NextFunction
): void {
  if (!req.auth) {
    res.status(401).json({
      type: 'https://api.example.com/errors/unauthorized',
      title: 'Unauthorized',
      status: 401,
      detail: 'Authentication required.',
      error_code: 'MISSING_TOKEN',
    });
    return;
  }

  // SuperAdmin can access any tenant
  if (req.auth.role === UserRole.SUPER_ADMIN) {
    return next();
  }

  const routeTenantId = req.params.tenantId;
  if (routeTenantId && routeTenantId !== req.auth.tenantId) {
    res.status(403).json({
      type: 'https://api.example.com/errors/forbidden',
      title: 'Forbidden',
      status: 403,
      detail: 'You can only access resources within your own tenant.',
      error_code: 'TENANT_SCOPE_VIOLATION',
    });
    return;
  }

  next();
}

/**
 * Require specific roles (OR logic — any listed role is sufficient).
 */
export function requireRole(...roles: UserRole[]) {
  return (req: Request, res: Response, next: NextFunction): void => {
    if (!req.auth) {
      res.status(401).json({
        type: 'https://api.example.com/errors/unauthorized',
        title: 'Unauthorized',
        status: 401,
        detail: 'Authentication required.',
        error_code: 'MISSING_TOKEN',
      });
      return;
    }

    // SuperAdmin always passes role checks
    if (req.auth.role === UserRole.SUPER_ADMIN) {
      return next();
    }

    if (!roles.includes(req.auth.role)) {
      res.status(403).json({
        type: 'https://api.example.com/errors/forbidden',
        title: 'Forbidden',
        status: 403,
        detail: `Required role: ${roles.join(' or ')}`,
        error_code: 'INSUFFICIENT_ROLE',
      });
      return;
    }

    next();
  };
}

// ═══════════════════════════════════════
// Stripe Webhook Signature Verification
// ═══════════════════════════════════════

const STRIPE_WEBHOOK_SECRET = process.env.STRIPE_WEBHOOK_SECRET!;
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!);

/**
 * Verify Stripe webhook signature (HMAC-SHA256, NOT JWT).
 * Must use raw body (not parsed JSON) for signature verification.
 */
export function verifyStripeWebhook(
  req: Request,
  res: Response,
  next: NextFunction
): void {
  const signature = req.headers['stripe-signature'] as string;

  if (!signature) {
    res.status(400).json({
      type: 'https://api.example.com/errors/bad-request',
      title: 'Bad Request',
      status: 400,
      detail: 'Missing Stripe-Signature header.',
      error_code: 'MISSING_WEBHOOK_SIGNATURE',
    });
    return;
  }

  try {
    // req.body must be the raw body (Buffer), not parsed JSON
    // Configure express.raw({ type: 'application/json' }) for the webhook route
    const event = stripe.webhooks.constructEvent(
      req.body, // raw body
      signature,
      STRIPE_WEBHOOK_SECRET
    );
    // Attach verified event to request
    (req as any).stripeEvent = event;
    next();
  } catch (err) {
    res.status(400).json({
      type: 'https://api.example.com/errors/bad-request',
      title: 'Bad Request',
      status: 400,
      detail: 'Invalid Stripe webhook signature.',
      error_code: 'INVALID_WEBHOOK_SIGNATURE',
    });
  }
}

// ═══════════════════════════════════════
// Request ID Middleware
// ═══════════════════════════════════════

/**
 * Generate or forward X-Request-ID for request tracing.
 */
export function requestId(
  req: Request,
  res: Response,
  next: NextFunction
): void {
  const id =
    (req.headers['x-request-id'] as string) || `req_${crypto.randomUUID()}`;
  req.headers['x-request-id'] = id;
  res.setHeader('X-Request-ID', id);
  next();
}
