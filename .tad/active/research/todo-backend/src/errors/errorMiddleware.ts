/**
 * Global Error Middleware — Catches all errors and returns RFC 7807 responses
 *
 * Must be registered LAST in the Express middleware chain:
 *   app.use(errorMiddleware);
 */

import { Request, Response, NextFunction } from "express";
import { AppError } from "./AppError";
import { mapPrismaError } from "./prismaErrors";
import { ZodError } from "zod";

// ─── Request ID Middleware ─────────────────────────────────

/**
 * Generates a unique request ID for every request.
 * Used for error correlation in logs.
 *
 * Register FIRST in the middleware chain:
 *   app.use(requestIdMiddleware);
 */
export function requestIdMiddleware(
  req: Request,
  res: Response,
  next: NextFunction
): void {
  const requestId =
    (req.headers["x-request-id"] as string) || crypto.randomUUID();
  res.setHeader("X-Request-ID", requestId);
  // Attach to request for use in logging
  (req as any).requestId = requestId;
  next();
}

// ─── Global Error Handler ──────────────────────────────────

export function errorMiddleware(
  err: Error,
  req: Request,
  res: Response,
  _next: NextFunction
): void {
  const requestId =
    (req as any).requestId || res.getHeader("X-Request-ID") || "unknown";

  // === 1. Known AppError ===
  if (err instanceof AppError) {
    logError(requestId, err, "warn");

    res.status(err.statusCode).json({
      ...err.toJSON(),
      // Include requestId for client-side debugging
    });
    return;
  }

  // === 2. Zod Validation Error ===
  if (err instanceof ZodError) {
    const fieldErrors = err.errors.map((e) => ({
      field: e.path.join("."),
      message: e.message,
      code: "INVALID_FORMAT",
    }));

    const appError = AppError.badRequest(
      "One or more fields failed validation.",
      "VALIDATION_FAILED",
      fieldErrors
    );

    logError(requestId, appError, "warn");

    res.status(400).json(appError.toJSON());
    return;
  }

  // === 3. Prisma Error ===
  if (err.constructor?.name?.startsWith("Prisma")) {
    const appError = mapPrismaError(err);

    logError(requestId, appError, "warn");

    res.status(appError.statusCode).json(appError.toJSON());
    return;
  }

  // === 4. Unknown Error (500) ===
  // SECURITY: Never expose internal details to the client
  logError(requestId, err, "error");

  res.status(500).json({
    type: "https://todoapp.example.com/errors/internal-error",
    title: "Internal Server Error",
    status: 500,
    detail: "An unexpected error occurred. Please try again later.",
    // requestId included so users can report it for debugging
  });
}

// ─── Structured Logging ────────────────────────────────────

type LogLevel = "warn" | "error";

/**
 * Structured JSON log output.
 * SECURITY: Never log passwords, tokens, or PII.
 */
function logError(requestId: string, err: Error, level: LogLevel): void {
  const logEntry = {
    timestamp: new Date().toISOString(),
    level,
    requestId,
    error: {
      name: err.name,
      message: err.message,
      // Only include stack in non-production
      ...(process.env.NODE_ENV !== "production" && { stack: err.stack }),
      ...(err instanceof AppError && {
        statusCode: err.statusCode,
        errorCode: err.errorCode,
      }),
    },
  };

  if (level === "error") {
    console.error(JSON.stringify(logEntry));
  } else {
    console.warn(JSON.stringify(logEntry));
  }
}
