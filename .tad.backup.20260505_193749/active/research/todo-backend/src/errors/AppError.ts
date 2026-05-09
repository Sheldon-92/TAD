/**
 * AppError — Custom application error class (RFC 7807 Problem Details)
 *
 * All business errors should use this class.
 * The global error middleware converts AppError → RFC 7807 JSON response.
 */

// ─── Types ────────────────────────────────────────────────

export interface FieldError {
  field: string;
  message: string;
  code: string;
}

// ─── Error Catalog ────────────────────────────────────────

/**
 * Error type URIs — stable identifiers for each error category.
 * Consumers can use these URIs to programmatically handle errors.
 */
export const ERROR_TYPES = {
  VALIDATION_FAILED: "https://todoapp.example.com/errors/validation-failed",
  INVALID_CREDENTIALS: "https://todoapp.example.com/errors/invalid-credentials",
  MISSING_TOKEN: "https://todoapp.example.com/errors/missing-token",
  INVALID_TOKEN: "https://todoapp.example.com/errors/invalid-token",
  EXPIRED_TOKEN: "https://todoapp.example.com/errors/expired-token",
  INSUFFICIENT_PERMISSIONS: "https://todoapp.example.com/errors/insufficient-permissions",
  RESOURCE_FORBIDDEN: "https://todoapp.example.com/errors/resource-forbidden",
  RESOURCE_NOT_FOUND: "https://todoapp.example.com/errors/resource-not-found",
  RESOURCE_ALREADY_EXISTS: "https://todoapp.example.com/errors/resource-already-exists",
  RATE_LIMIT_EXCEEDED: "https://todoapp.example.com/errors/rate-limit-exceeded",
  INTERNAL_ERROR: "https://todoapp.example.com/errors/internal-error",
} as const;

/**
 * Error retryability map.
 * Clients can check this to decide whether to retry.
 */
export const RETRYABLE_ERRORS: Record<number, boolean> = {
  400: false,
  401: false,
  403: false,
  404: false,
  409: false,
  422: false,
  429: true, // Rate limit — retry after Retry-After header
  500: false, // Don't auto-retry 500s (could be a bug)
  503: true, // Service unavailable — retry with backoff
};

// ─── AppError Class ───────────────────────────────────────

export class AppError extends Error {
  public readonly statusCode: number;
  public readonly errorCode: string;
  public readonly type: string;
  public readonly errors?: FieldError[];
  public readonly retryable: boolean;

  constructor(
    statusCode: number,
    detail: string,
    errorCode: string,
    errors?: FieldError[]
  ) {
    super(detail);
    this.name = "AppError";
    this.statusCode = statusCode;
    this.errorCode = errorCode;
    this.type =
      ERROR_TYPES[errorCode as keyof typeof ERROR_TYPES] ||
      ERROR_TYPES.INTERNAL_ERROR;
    this.errors = errors;
    this.retryable = RETRYABLE_ERRORS[statusCode] ?? false;

    // Maintain proper stack trace
    Error.captureStackTrace(this, AppError);
  }

  /**
   * Convert to RFC 7807 Problem Details JSON.
   */
  toJSON(): Record<string, unknown> {
    return {
      type: this.type,
      title: this.title(),
      status: this.statusCode,
      detail: this.message,
      ...(this.errors && this.errors.length > 0 && { errors: this.errors }),
    };
  }

  private title(): string {
    const titles: Record<number, string> = {
      400: "Bad Request",
      401: "Unauthorized",
      403: "Forbidden",
      404: "Not Found",
      409: "Conflict",
      422: "Unprocessable Entity",
      429: "Too Many Requests",
      500: "Internal Server Error",
    };
    return titles[this.statusCode] || "Error";
  }

  // ─── Factory Methods ────────────────────────────────────

  static badRequest(
    detail: string,
    errorCode: string = "VALIDATION_FAILED",
    errors?: FieldError[]
  ): AppError {
    return new AppError(400, detail, errorCode, errors);
  }

  static unauthorized(
    detail: string,
    errorCode: string = "INVALID_TOKEN"
  ): AppError {
    return new AppError(401, detail, errorCode);
  }

  static forbidden(
    detail: string,
    errorCode: string = "INSUFFICIENT_PERMISSIONS"
  ): AppError {
    return new AppError(403, detail, errorCode);
  }

  static notFound(
    detail: string,
    errorCode: string = "RESOURCE_NOT_FOUND"
  ): AppError {
    return new AppError(404, detail, errorCode);
  }

  static conflict(
    detail: string,
    errorCode: string = "RESOURCE_ALREADY_EXISTS"
  ): AppError {
    return new AppError(409, detail, errorCode);
  }

  static rateLimited(retryAfterSeconds: number): AppError {
    const error = new AppError(
      429,
      `Too many requests. Please retry after ${retryAfterSeconds} seconds.`,
      "RATE_LIMIT_EXCEEDED"
    );
    return error;
  }

  static internal(detail: string = "An unexpected error occurred."): AppError {
    return new AppError(500, detail, "INTERNAL_ERROR");
  }
}
