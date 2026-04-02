// AppError — Unified error class for RFC 7807 Problem Details
// All business errors extend this class

export interface FieldError {
  field: string;
  message: string;
}

export class AppError extends Error {
  public readonly statusCode: number;
  public readonly errorCode: string;
  public readonly type: string;
  public readonly title: string;
  public readonly detail: string;
  public readonly errors?: FieldError[];
  public readonly isRetryable: boolean;

  constructor(params: {
    statusCode: number;
    errorCode: string;
    title: string;
    detail: string;
    errors?: FieldError[];
    isRetryable?: boolean;
  }) {
    super(params.detail);
    this.name = 'AppError';
    this.statusCode = params.statusCode;
    this.errorCode = params.errorCode;
    this.type = `https://api.example.com/errors/${params.errorCode.toLowerCase().replace(/_/g, '-')}`;
    this.title = params.title;
    this.detail = params.detail;
    this.errors = params.errors;
    this.isRetryable = params.isRetryable ?? false;

    // Preserve prototype chain
    Object.setPrototypeOf(this, AppError.prototype);
  }

  /**
   * Serialize to RFC 7807 Problem Details JSON.
   */
  toJSON(requestId?: string) {
    return {
      type: this.type,
      title: this.title,
      status: this.statusCode,
      detail: this.detail,
      error_code: this.errorCode,
      ...(requestId ? { request_id: requestId } : {}),
      ...(this.errors?.length ? { errors: this.errors } : {}),
    };
  }

  // ─── Factory Methods ────────────────────────────

  static badRequest(detail: string, errorCode: string = 'BAD_REQUEST', errors?: FieldError[]) {
    return new AppError({
      statusCode: 400,
      errorCode,
      title: 'Bad Request',
      detail,
      errors,
    });
  }

  static unauthorized(detail: string = 'Authentication credentials are missing or invalid.', errorCode: string = 'INVALID_TOKEN') {
    return new AppError({
      statusCode: 401,
      errorCode,
      title: 'Unauthorized',
      detail,
    });
  }

  static forbidden(detail: string = 'You do not have permission to perform this action.', errorCode: string = 'INSUFFICIENT_PERMISSIONS') {
    return new AppError({
      statusCode: 403,
      errorCode,
      title: 'Forbidden',
      detail,
    });
  }

  static notFound(detail: string = 'The requested resource was not found.', errorCode: string = 'RESOURCE_NOT_FOUND') {
    return new AppError({
      statusCode: 404,
      errorCode,
      title: 'Not Found',
      detail,
    });
  }

  static conflict(detail: string, errorCode: string = 'RESOURCE_ALREADY_EXISTS') {
    return new AppError({
      statusCode: 409,
      errorCode,
      title: 'Conflict',
      detail,
    });
  }

  static unprocessable(detail: string, errorCode: string = 'VALIDATION_FAILED', errors?: FieldError[]) {
    return new AppError({
      statusCode: 422,
      errorCode,
      title: 'Unprocessable Entity',
      detail,
      errors,
    });
  }

  static rateLimited(detail: string = 'Too many requests. Please try again later.', retryAfter?: number) {
    return new AppError({
      statusCode: 429,
      errorCode: 'RATE_LIMIT_EXCEEDED',
      title: 'Too Many Requests',
      detail: retryAfter
        ? `${detail} Retry after ${retryAfter} seconds.`
        : detail,
      isRetryable: true,
    });
  }

  static internal(detail: string = 'An unexpected error occurred.') {
    return new AppError({
      statusCode: 500,
      errorCode: 'INTERNAL_ERROR',
      title: 'Internal Server Error',
      detail,
      isRetryable: true,
    });
  }

  // ─── Billing-Specific Errors ────────────────────

  static paymentFailed(detail: string, failureCode?: string) {
    return new AppError({
      statusCode: 402,
      errorCode: 'PAYMENT_FAILED',
      title: 'Payment Failed',
      detail,
    });
  }

  static subscriptionLimitReached(feature: string, limit: number) {
    return new AppError({
      statusCode: 403,
      errorCode: 'SUBSCRIPTION_LIMIT_REACHED',
      title: 'Subscription Limit Reached',
      detail: `You have reached the ${feature} limit of ${limit} for your current plan. Please upgrade to continue.`,
    });
  }

  static gracePeriodExpired() {
    return new AppError({
      statusCode: 409,
      errorCode: 'GRACE_PERIOD_EXPIRED',
      title: 'Grace Period Expired',
      detail: 'The 7-day grace period has expired. Please create a new subscription.',
    });
  }

  static concurrentModification(expected: number, actual: number) {
    return new AppError({
      statusCode: 409,
      errorCode: 'CONCURRENT_MODIFICATION',
      title: 'Concurrent Modification',
      detail: `Resource was modified by another request. Expected version ${expected}, found ${actual}.`,
    });
  }

  static invalidStatusTransition(from: string, to: string) {
    return new AppError({
      statusCode: 409,
      errorCode: 'INVALID_STATUS_TRANSITION',
      title: 'Invalid Status Transition',
      detail: `Cannot transition from ${from} to ${to}.`,
    });
  }

  static webhookSignatureInvalid() {
    return new AppError({
      statusCode: 400,
      errorCode: 'INVALID_WEBHOOK_SIGNATURE',
      title: 'Bad Request',
      detail: 'Invalid Stripe webhook signature.',
    });
  }
}
