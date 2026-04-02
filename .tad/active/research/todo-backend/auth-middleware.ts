/**
 * Auth Middleware — JWT Authentication & RBAC for Todo App
 *
 * Dependencies (install in real project):
 *   npm install jsonwebtoken bcryptjs
 *   npm install -D @types/jsonwebtoken @types/bcryptjs
 */

import { Request, Response, NextFunction } from "express";
import jwt from "jsonwebtoken";

// ─── Types ────────────────────────────────────────────────

export interface JwtPayload {
  userId: string;
  email: string;
  role: "owner" | "member";
  iat: number;
  exp: number;
}

export interface AuthenticatedRequest extends Request {
  user: JwtPayload;
}

type Role = "owner" | "member";

// ─── Configuration ────────────────────────────────────────

const AUTH_CONFIG = {
  /** [ASSUMPTION] Secret should come from env var in production */
  jwtSecret: process.env.JWT_SECRET || "CHANGE_ME_IN_PRODUCTION",
  accessTokenTtl: "15m", // 15 minutes
  refreshTokenTtl: "7d", // 7 days
  bcryptRounds: 12,
  /** Rate limit: max 5 login attempts per minute per IP */
  loginRateLimit: { windowMs: 60_000, max: 5 },
} as const;

// ─── JWT Utilities ────────────────────────────────────────

/**
 * Generate an access token (short-lived, 15 min).
 */
export function generateAccessToken(payload: {
  userId: string;
  email: string;
  role: Role;
}): string {
  return jwt.sign(payload, AUTH_CONFIG.jwtSecret, {
    expiresIn: AUTH_CONFIG.accessTokenTtl,
  });
}

/**
 * Generate a refresh token (longer-lived, 7 days).
 * Stored hashed in DB for rotation validation.
 */
export function generateRefreshToken(payload: {
  userId: string;
}): string {
  return jwt.sign(payload, AUTH_CONFIG.jwtSecret, {
    expiresIn: AUTH_CONFIG.refreshTokenTtl,
  });
}

/**
 * Verify and decode a JWT token.
 * Throws on invalid/expired tokens.
 */
export function verifyToken(token: string): JwtPayload {
  return jwt.verify(token, AUTH_CONFIG.jwtSecret) as JwtPayload;
}

// ─── Authentication Middleware ─────────────────────────────

/**
 * Middleware: Verify JWT Bearer token.
 * Extracts user info from token and attaches to `req.user`.
 *
 * Usage: app.use("/v1/todos", authenticate, todoRoutes);
 */
export function authenticate(
  req: Request,
  res: Response,
  next: NextFunction
): void {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    res.status(401).json({
      type: "https://todoapp.example.com/errors/missing-token",
      title: "Unauthorized",
      status: 401,
      detail: "Authorization header with Bearer token is required.",
    });
    return;
  }

  const token = authHeader.slice(7); // Remove "Bearer "

  try {
    const payload = verifyToken(token);
    (req as AuthenticatedRequest).user = payload;
    next();
  } catch (error) {
    if (error instanceof jwt.TokenExpiredError) {
      res.status(401).json({
        type: "https://todoapp.example.com/errors/expired-token",
        title: "Unauthorized",
        status: 401,
        detail: "Access token has expired. Use /auth/refresh to obtain a new one.",
      });
      return;
    }

    res.status(401).json({
      type: "https://todoapp.example.com/errors/invalid-token",
      title: "Unauthorized",
      status: 401,
      detail: "Access token is invalid.",
    });
  }
}

// ─── Role-Based Access Control Middleware ──────────────────

/**
 * RBAC Matrix:
 *
 * | Resource       | Action  | Owner        | Member          |
 * |----------------|---------|--------------|-----------------|
 * | Users (list)   | GET     | All users    | Forbidden       |
 * | Users (by ID)  | GET     | Any user     | Forbidden       |
 * | Users (delete) | DELETE  | Any user     | Forbidden       |
 * | Users (me)     | GET     | Own profile  | Own profile     |
 * | Users (me)     | PATCH   | Own profile  | Own profile     |
 * | Todos          | GET     | All todos    | Own todos only  |
 * | Todos          | POST    | Create any   | Create own      |
 * | Todos          | PATCH   | Any todo     | Own todos only  |
 * | Todos          | DELETE  | Any todo     | Own todos only  |
 * | Categories     | GET     | Own cats     | Own cats        |
 * | Categories     | POST    | Create own   | Create own      |
 * | Categories     | PATCH   | Own cats     | Own cats        |
 * | Categories     | DELETE  | Own cats     | Own cats        |
 */

/**
 * Middleware factory: Require specific role(s).
 *
 * Usage: app.get("/v1/users", authenticate, requireRole("owner"), listUsers);
 */
export function requireRole(...allowedRoles: Role[]) {
  return (req: Request, res: Response, next: NextFunction): void => {
    const user = (req as AuthenticatedRequest).user;

    if (!user) {
      res.status(401).json({
        type: "https://todoapp.example.com/errors/missing-token",
        title: "Unauthorized",
        status: 401,
        detail: "Authentication required.",
      });
      return;
    }

    if (!allowedRoles.includes(user.role)) {
      res.status(403).json({
        type: "https://todoapp.example.com/errors/insufficient-permissions",
        title: "Forbidden",
        status: 403,
        detail: `This action requires one of the following roles: ${allowedRoles.join(", ")}.`,
      });
      return;
    }

    next();
  };
}

// ─── Resource Ownership Middleware ─────────────────────────

/**
 * Middleware factory: Verify the authenticated user owns the resource.
 * Owner role bypasses ownership check (can access any resource).
 *
 * Usage:
 *   app.patch("/v1/todos/:todoId", authenticate, requireOwnership("todo"), updateTodo);
 *
 * The handler must set `res.locals.resourceOwnerId` before this middleware,
 * OR this middleware fetches the resource itself via the provided lookup function.
 */
export function requireOwnership(
  resourceType: "todo" | "category",
  lookupOwnerId: (resourceId: string) => Promise<string | null>
) {
  return async (
    req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> => {
    const user = (req as AuthenticatedRequest).user;

    // Owner role can access any resource
    if (user.role === "owner") {
      next();
      return;
    }

    // Extract resource ID from path params
    const resourceId =
      req.params.todoId || req.params.categoryId;

    if (!resourceId) {
      res.status(400).json({
        type: "https://todoapp.example.com/errors/missing-resource-id",
        title: "Bad Request",
        status: 400,
        detail: "Resource ID is required.",
      });
      return;
    }

    const ownerId = await lookupOwnerId(resourceId);

    if (!ownerId) {
      res.status(404).json({
        type: "https://todoapp.example.com/errors/resource-not-found",
        title: "Not Found",
        status: 404,
        detail: `The requested ${resourceType} was not found.`,
      });
      return;
    }

    if (ownerId !== user.userId) {
      res.status(403).json({
        type: "https://todoapp.example.com/errors/resource-forbidden",
        title: "Forbidden",
        status: 403,
        detail: `You do not have permission to access this ${resourceType}.`,
      });
      return;
    }

    next();
  };
}

// ─── Route Protection Configuration ───────────────────────

/**
 * Route protection summary:
 *
 * PUBLIC routes (no auth required):
 *   POST /v1/auth/register
 *   POST /v1/auth/login
 *   POST /v1/auth/refresh
 *
 * AUTHENTICATED routes (any role):
 *   POST /v1/auth/logout
 *   GET  /v1/users/me
 *   PATCH /v1/users/me
 *   GET/POST /v1/todos (Member: scoped to own)
 *   GET/PATCH/DELETE /v1/todos/:todoId (Member: ownership check)
 *   GET/POST /v1/categories (scoped to own)
 *   GET/PATCH/DELETE /v1/categories/:categoryId (ownership check)
 *
 * OWNER-ONLY routes:
 *   GET /v1/users
 *   GET /v1/users/:userId
 *   DELETE /v1/users/:userId
 */
