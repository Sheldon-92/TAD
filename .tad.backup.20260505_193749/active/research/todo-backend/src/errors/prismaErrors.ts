/**
 * Prisma Error Mapper — Converts Prisma errors to AppError
 *
 * Prisma throws specific error codes (P2002, P2025, etc.)
 * that map to meaningful HTTP status codes.
 *
 * Reference: https://www.prisma.io/docs/reference/api-reference/error-reference
 */

import { AppError } from "./AppError";

/**
 * Map Prisma error to AppError.
 *
 * Common Prisma error codes:
 * - P2002: Unique constraint violation → 409 Conflict
 * - P2003: Foreign key constraint violation → 400 Bad Request
 * - P2025: Record not found → 404 Not Found
 * - P2014: Required relation violation → 400 Bad Request
 * - P2016: Query interpretation error → 400 Bad Request
 */
export function mapPrismaError(err: any): AppError {
  const code = err?.code as string | undefined;
  const meta = err?.meta as Record<string, unknown> | undefined;

  switch (code) {
    case "P2002": {
      // Unique constraint violation
      const target = (meta?.target as string[])?.join(", ") || "field";
      return AppError.conflict(
        `A record with this ${target} already exists.`,
        "RESOURCE_ALREADY_EXISTS"
      );
    }

    case "P2003": {
      // Foreign key constraint violation
      const fieldName = (meta?.field_name as string) || "reference";
      return AppError.badRequest(
        `Invalid reference: the related ${fieldName} does not exist.`,
        "INVALID_FORMAT"
      );
    }

    case "P2025": {
      // Record not found (update/delete on non-existent record)
      return AppError.notFound(
        "The requested resource was not found.",
        "RESOURCE_NOT_FOUND"
      );
    }

    case "P2014": {
      // Required relation violation
      return AppError.badRequest(
        "A required related record is missing.",
        "REQUIRED"
      );
    }

    case "P2016": {
      // Query interpretation error
      return AppError.badRequest(
        "The query could not be interpreted. Check your input.",
        "INVALID_FORMAT"
      );
    }

    default: {
      // Unknown Prisma error → treat as 500
      // Log the original error for debugging but don't expose details
      console.error("Unhandled Prisma error:", {
        code,
        message: err?.message,
        meta,
      });
      return AppError.internal(
        "A database error occurred. Please try again later."
      );
    }
  }
}
