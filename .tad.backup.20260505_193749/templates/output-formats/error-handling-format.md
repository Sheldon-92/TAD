# Error Handling Review Format

> Extracted from error-handling skill - use this for error handling code reviews

## Quick Checklist

```
1. [ ] Errors classified: Recoverable / Unrecoverable / Programming (don't catch programming errors)
2. [ ] Fail fast on invalid inputs with clear messages
3. [ ] Structured logging with correlation ID (traceId/correlationId)
4. [ ] HTTP errors use RFC 7807 format with correct status codes
5. [ ] Error paths and edge cases tested (including retry/fallback)
```

## Red Flags

- Swallowing exceptions / silent failures
- Logging without context
- Treating programming errors as business errors
- Using `eval()` / `new Function()` for dynamic code execution
- Rendering unescaped error messages in frontend
- HTTP always returns 200 with error text
- No standard error structure
- Empty catch blocks

## Error Classification

| Type | Examples | Handling |
|------|----------|----------|
| Recoverable | Validation failure, Timeout, Resource unavailable | Retry, Fallback, User feedback |
| Unrecoverable | Config error, Critical dependency missing | Fail fast, Alert, Manual intervention |
| Programming | Null pointer, Type error, Assertion failure | Fix the code, DON'T catch |

## Output Format

### Error Handling Audit

| Category | Check | Status | Finding |
|----------|-------|--------|---------|
| Error Classification | Types defined | Pass/Fail | [details] |
| Fail Fast | Invalid inputs rejected | Pass/Fail | [details] |
| Logging | Structured with traceId | Pass/Fail | [details] |
| API Errors | RFC 7807 format | Pass/Fail | [details] |
| Error Tests | Edge cases covered | Pass/Fail | [details] |

### API Error Format (RFC 7807)

```json
{
  "type": "https://api.example.com/errors/validation",
  "title": "Validation Error",
  "status": 400,
  "detail": "Email format is invalid",
  "instance": "/users/123",
  "requestId": "req_abc123"
}
```

### Error Code Mapping

| Error Code | HTTP Status | When to Use |
|------------|-------------|-------------|
| VALIDATION_ERROR | 400 | Invalid input |
| UNAUTHORIZED | 401 | Auth required |
| FORBIDDEN | 403 | No permission |
| NOT_FOUND | 404 | Resource missing |
| CONFLICT | 409 | Duplicate/conflict |
| RATE_LIMITED | 429 | Too many requests |
| INTERNAL_ERROR | 500 | Server error |

### Resilience Patterns

| Pattern | Implemented | Configuration |
|---------|-------------|---------------|
| Retry with backoff | Yes/No | [max retries, delays] |
| Circuit breaker | Yes/No | [threshold, timeout] |
| Fallback | Yes/No | [fallback behavior] |
| Timeout | Yes/No | [timeout values] |

### Recommendations

1. **Critical**: [must fix - security/data loss risk]
2. **Important**: [should fix - reliability/debuggability]
3. **Nice to have**: [consider - improved observability]
