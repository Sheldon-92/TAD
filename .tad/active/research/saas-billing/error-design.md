# Error Handling Design — Multi-Tenant SaaS Billing

## 1. Error Catalog

### Standard HTTP Errors (All Endpoints)

| HTTP | Error Code | Type URI | Description | Retryable |
|------|-----------|----------|-------------|-----------|
| 400 | VALIDATION_FAILED | /errors/validation-failed | Request body invalid | No |
| 400 | INVALID_WEBHOOK_SIGNATURE | /errors/invalid-webhook-signature | Stripe signature check failed | No |
| 401 | MISSING_TOKEN | /errors/missing-token | No auth credentials | No |
| 401 | INVALID_TOKEN | /errors/invalid-token | JWT expired or malformed | No |
| 401 | INVALID_API_KEY | /errors/invalid-api-key | API key not found | No |
| 401 | API_KEY_EXPIRED | /errors/api-key-expired | API key past expiry date | No |
| 401 | API_KEY_REVOKED | /errors/api-key-revoked | API key manually revoked | No |
| 403 | INSUFFICIENT_PERMISSIONS | /errors/insufficient-permissions | Role lacks permission | No |
| 403 | TENANT_SCOPE_VIOLATION | /errors/tenant-scope-violation | Accessing another tenant | No |
| 404 | RESOURCE_NOT_FOUND | /errors/resource-not-found | Entity not found | No |
| 409 | RESOURCE_ALREADY_EXISTS | /errors/resource-already-exists | Unique constraint | No |
| 409 | CONCURRENT_MODIFICATION | /errors/concurrent-modification | Optimistic lock fail | Yes (re-fetch) |
| 422 | VALIDATION_FAILED | /errors/validation-failed | Business validation | No |
| 429 | RATE_LIMIT_EXCEEDED | /errors/rate-limit-exceeded | Too many requests | Yes (Retry-After) |
| 500 | INTERNAL_ERROR | /errors/internal-error | Unexpected server error | Yes |

### Billing-Specific Errors

| HTTP | Error Code | Type URI | Description | Retryable |
|------|-----------|----------|-------------|-----------|
| 402 | PAYMENT_FAILED | /errors/payment-failed | Card declined / insufficient funds | Yes (new card) |
| 403 | SUBSCRIPTION_LIMIT_REACHED | /errors/subscription-limit-reached | Plan usage limit exceeded | No (upgrade) |
| 409 | SUBSCRIPTION_ALREADY_EXISTS | /errors/subscription-already-exists | Tenant already subscribed | No |
| 409 | INVALID_STATUS_TRANSITION | /errors/invalid-status-transition | Invalid state machine move | No |
| 409 | GRACE_PERIOD_EXPIRED | /errors/grace-period-expired | Reactivation too late | No |
| 409 | SAME_PLAN | /errors/same-plan | Trying to change to same plan | No |
| 422 | SUBSCRIPTION_NOT_ACTIVE | /errors/subscription-not-active | Usage on inactive sub | No |
| 422 | FEATURE_NOT_IN_PLAN | /errors/feature-not-in-plan | Usage for non-plan feature | No |

### Stripe Error Code → User-Friendly Message Mapping

| Stripe Decline Code | User-Friendly Message |
|---------------------|----------------------|
| card_declined | Your card was declined. Please try a different payment method. |
| insufficient_funds | Your card has insufficient funds. Please use a different card or add funds. |
| expired_card | Your card has expired. Please update your payment method. |
| incorrect_cvc | The CVC number is incorrect. Please check and try again. |
| processing_error | An error occurred while processing your card. Please try again. |
| incorrect_number | The card number is incorrect. Please check and try again. |
| authentication_required | This transaction requires authentication. Please complete 3D Secure verification. |

## 2. Payment Failure Error Chain (Complete Lifecycle)

```
1. Stripe → invoice.payment_failed webhook
   ↓ WebhookService receives, verifies HMAC signature
   ↓ Idempotency check (WebhookEvent table)
   
2. Update subscription status → PAST_DUE
   ↓ AuditLog entry: { before: ACTIVE, after: PAST_DUE }
   
3. Notify TenantAdmin + BillingAdmin
   ↓ Email: "Payment failed for invoice #INV-001"
   ↓ WebSocket: { type: "PAYMENT_FAILED", data: { failureReason, nextRetryAt } }
   
4. Schedule retry (exponential backoff)
   ↓ Attempt 1: +1 hour  (card_declined)
   ↓ Attempt 2: +4 hours (insufficient_funds)
   ↓ Attempt 3: +24 hours (card_declined)
   ↓ Attempt 4: +72 hours (card_declined)
   
5. Max retries exceeded → Cancel subscription
   ↓ status: PAST_DUE → CANCELED
   ↓ gracePeriodEnd: now + 7 days
   ↓ AuditLog: { reason: "Payment failed after maximum retry attempts." }
   
6. Final notice sent
   ↓ Email: "Your subscription has been canceled. 7 days to resolve."
   ↓ WebSocket: { type: "SUBSCRIPTION_CANCELED", reason: "payment_failure_max_retries" }
   
7. Grace period ends (7 days)
   ↓ Cron job: status CANCELED → EXPIRED
   ↓ Data access revoked
```

## 3. Webhook Idempotency Design

```
Request arrives: POST /webhooks/stripe
  ├── Verify HMAC signature (Stripe-Signature header)
  ├── Extract event.id from payload
  ├── SELECT * FROM WebhookEvent WHERE stripeEventId = event.id
  │   ├── EXISTS + status=PROCESSED → return 200 (already done)
  │   ├── EXISTS + status=PROCESSING → return 200 (in progress)
  │   ├── EXISTS + status=FAILED → retry processing
  │   └── NOT EXISTS → INSERT with status=RECEIVED
  ├── Process event (dispatch to handler)
  ├── UPDATE status=PROCESSED, processedAt=now()
  └── On error: UPDATE status=FAILED, errorMessage=...
       └── Still return 200 (Stripe will retry up to 3 days)
```

## 4. Logging Strategy

- **Format**: Structured JSON (one JSON object per line)
- **Fields**: `{ level, timestamp, requestId, method, path, errorCode, message }`
- **NEVER log**: passwords, tokens, credit card numbers, PII
- **Server-side only**: stack traces, SQL queries, internal error details
- **Levels**: error (5xx) > warn (4xx) > info (requests) > debug
- **X-Request-ID**: Generated or forwarded on every request, included in all responses and logs
