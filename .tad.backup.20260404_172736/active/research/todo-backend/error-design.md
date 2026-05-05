# Error Design — Todo App Backend

## Implementation Components

### 1. AppError Class (`src/errors/AppError.ts`)
- Extends native `Error`
- Properties: `statusCode`, `errorCode`, `type` (URI), `errors[]` (field-level), `retryable`
- Factory methods: `badRequest()`, `unauthorized()`, `forbidden()`, `notFound()`, `conflict()`, `rateLimited()`, `internal()`
- `toJSON()` method produces RFC 7807 output

### 2. Error Middleware (`src/errors/errorMiddleware.ts`)
- Registered LAST in Express middleware chain
- Handles 4 error types in priority order:
  1. `AppError` → direct RFC 7807 response
  2. `ZodError` → convert to 400 with field-level errors
  3. Prisma errors → map via `prismaErrors.ts`
  4. Unknown errors → 500 with generic message

### 3. Prisma Error Mapper (`src/errors/prismaErrors.ts`)
- Maps Prisma error codes (P2002, P2003, P2025, etc.) to AppError instances
- Extracts metadata (constraint name, field) for helpful messages
- Unknown Prisma errors → 500 (logged server-side, generic client message)

### 4. Request ID Middleware
- Generates UUID for each request
- Propagates existing `X-Request-ID` header (for distributed tracing)
- Included in all error responses and log entries

## Security Rules
- 5xx responses NEVER include: stack traces, DB error messages, internal paths
- 4xx responses include only user-facing error details
- Passwords and tokens are NEVER logged
- `requestId` is always included for debugging correlation
