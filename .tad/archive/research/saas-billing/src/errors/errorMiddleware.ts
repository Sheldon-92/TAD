// Global Error Middleware — Catches all errors and returns RFC 7807 responses
// Also includes Prisma error mapping and request ID tracking

import { Request, Response, NextFunction } from 'express';
import { ZodError } from 'zod';
import { Prisma } from '@prisma/client';
import { AppError, FieldError } from './AppError';

// ═══════════════════════════════════════
// Prisma Error Mapping
// ═══════════════════════════════════════

/**
 * Map Prisma error codes to AppError instances.
 * Reference: https://www.prisma.io/docs/orm/reference/error-reference
 */
function mapPrismaError(error: Prisma.PrismaClientKnownRequestError): AppError {
  switch (error.code) {
    case 'P2002': {
      // Unique constraint violation
      const target = (error.meta?.target as string[])?.join(', ') || 'field';
      return AppError.conflict(
        `A record with this ${target} already exists.`,
        'RESOURCE_ALREADY_EXISTS',
      );
    }
    case 'P2025':
      // Record not found
      return AppError.notFound('The requested resource was not found.');
    case 'P2003':
      // Foreign key constraint failed
      return AppError.badRequest(
        'Referenced resource does not exist.',
        'FOREIGN_KEY_VIOLATION',
      );
    case 'P2014':
      // Required relation violation
      return AppError.badRequest(
        'The operation would violate a required relation.',
        'RELATION_VIOLATION',
      );
    default:
      return AppError.internal('A database error occurred.');
  }
}

// ═══════════════════════════════════════
// Zod Error Mapping
// ═══════════════════════════════════════

function mapZodError(error: ZodError): AppError {
  const fieldErrors: FieldError[] = error.errors.map((e) => ({
    field: e.path.join('.'),
    message: e.message,
  }));

  return AppError.unprocessable(
    'Request body contains invalid fields.',
    'VALIDATION_FAILED',
    fieldErrors,
  );
}

// ═══════════════════════════════════════
// Stripe Error Mapping
// ═══════════════════════════════════════

/**
 * Map Stripe decline codes to user-friendly messages.
 */
const STRIPE_ERROR_MESSAGES: Record<string, string> = {
  card_declined: 'Your card was declined. Please try a different payment method.',
  insufficient_funds: 'Your card has insufficient funds. Please use a different card or add funds.',
  expired_card: 'Your card has expired. Please update your payment method.',
  incorrect_cvc: 'The CVC number is incorrect. Please check and try again.',
  processing_error: 'An error occurred while processing your card. Please try again.',
  incorrect_number: 'The card number is incorrect. Please check and try again.',
  authentication_required: 'This transaction requires authentication. Please complete 3D Secure verification.',
};

export function getStripeErrorMessage(declineCode: string): string {
  return STRIPE_ERROR_MESSAGES[declineCode] || 'Payment failed. Please try a different payment method.';
}

// ═══════════════════════════════════════
// Global Error Handler
// ═══════════════════════════════════════

/**
 * Express global error handler.
 *
 * Priority:
 * 1. AppError → return structured RFC 7807 response
 * 2. ZodError → map to 422 with field-level errors
 * 3. PrismaClientKnownRequestError → map to appropriate HTTP status
 * 4. Unknown error → 500 with generic message (log details server-side)
 *
 * NEVER expose stack traces, SQL queries, or internal details in responses.
 */
export function globalErrorHandler(
  err: Error,
  req: Request,
  res: Response,
  _next: NextFunction,
): void {
  const requestId = req.headers['x-request-id'] as string;

  // 1. Known application error
  if (err instanceof AppError) {
    const body = err.toJSON(requestId);
    res.status(err.statusCode).json(body);

    // Log warning for client errors, error for server errors
    if (err.statusCode >= 500) {
      logError(requestId, err, req);
    } else {
      logWarn(requestId, err, req);
    }
    return;
  }

  // 2. Zod validation error
  if (err instanceof ZodError) {
    const appError = mapZodError(err);
    res.status(appError.statusCode).json(appError.toJSON(requestId));
    logWarn(requestId, appError, req);
    return;
  }

  // 3. Prisma error
  if (err instanceof Prisma.PrismaClientKnownRequestError) {
    const appError = mapPrismaError(err);
    res.status(appError.statusCode).json(appError.toJSON(requestId));
    logWarn(requestId, appError, req);
    return;
  }

  // 4. Unknown error — 500 with generic message
  const genericError = AppError.internal('An unexpected error occurred.');
  res.status(500).json(genericError.toJSON(requestId));

  // Log FULL error details server-side (never send to client)
  logError(requestId, err, req);
}

// ═══════════════════════════════════════
// Structured Logging (JSON)
// ═══════════════════════════════════════

function logWarn(requestId: string, error: Error, req: Request): void {
  const logEntry = {
    level: 'warn',
    timestamp: new Date().toISOString(),
    requestId,
    method: req.method,
    path: req.path,
    errorCode: error instanceof AppError ? error.errorCode : error.name,
    message: error.message,
    // DO NOT log: password, token, PII, body with sensitive fields
  };
  console.warn(JSON.stringify(logEntry));
}

function logError(requestId: string, error: Error, req: Request): void {
  const logEntry = {
    level: 'error',
    timestamp: new Date().toISOString(),
    requestId,
    method: req.method,
    path: req.path,
    errorCode: error instanceof AppError ? error.errorCode : error.name,
    message: error.message,
    stack: error.stack, // Only in server logs, never in response
    // DO NOT log: password, token, PII
  };
  console.error(JSON.stringify(logEntry));
}
