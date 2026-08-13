# Backend Conventions

Naming conventions, directory layout, and worked examples for common backend
patterns. Language-agnostic with Node.js/TypeScript, Python, and Go branches.

---

## Directory Layout

```
project-root/
├── src/                        # Application source
│   ├── api/                    # HTTP handlers / controllers
│   │   ├── middleware/         # Auth, rate-limit, logging middleware
│   │   ├── routes/             # Route definitions
│   │   └── validators/         # Request schema validation
│   ├── domain/                 # Business logic (no framework dependencies)
│   │   ├── commands/           # Write operations
│   │   ├── queries/            # Read operations
│   │   ├── events/             # Domain events
│   │   └── models/             # Entities, value objects, aggregates
│   ├── infrastructure/         # Adapters (DB, queue, email, external APIs)
│   │   ├── database/           # Repository implementations
│   │   ├── queue/              # Job queue workers
│   │   └── http/               # External HTTP client wrappers
│   └── shared/                 # Cross-cutting concerns
│       ├── errors/             # Error types
│       ├── logger/             # Logging configuration
│       └── config/             # Environment configuration
├── migrations/                 # Database migration files (numbered)
├── tests/
│   ├── unit/                   # Domain logic tests (no I/O)
│   ├── integration/            # Tests against real database / services
│   └── e2e/                    # End-to-end HTTP tests
├── scripts/                    # Dev scripts (not shipped to production)
├── .env.example                # Environment variable template
├── Dockerfile
└── docker-compose.yml          # Local development services
```

---

## Naming Conventions

### Files

| Type | Convention | Example |
|------|-----------|---------|
| Route handler | `kebab-case.handler.ts` | `create-order.handler.ts` |
| Service / Use case | `kebab-case.service.ts` | `payment-processor.service.ts` |
| Repository | `kebab-case.repository.ts` | `order.repository.ts` |
| Domain model | `kebab-case.ts` | `order.ts` |
| Test file | `*.test.ts` or `*_test.go` | `order.test.ts` |
| Database migration | `NNNN_description.sql` | `0042_add_orders_user_id_index.sql` |

### Variables and Functions

| Language | Functions | Classes | Constants | Files |
|----------|-----------|---------|-----------|-------|
| TypeScript/JS | `camelCase` | `PascalCase` | `SCREAMING_SNAKE` | `kebab-case.ts` |
| Python | `snake_case` | `PascalCase` | `SCREAMING_SNAKE` | `snake_case.py` |
| Go | `camelCase` (unexported), `PascalCase` (exported) | `PascalCase` | `PascalCase` (exported) | `snake_case.go` |

### API Endpoints

```
# Resource naming: plural nouns, lowercase, hyphens for multi-word
GET    /v1/users              # list users
GET    /v1/users/:id          # get one user
POST   /v1/users              # create user
PATCH  /v1/users/:id          # partial update
DELETE /v1/users/:id          # delete user

# Sub-resources
GET    /v1/orders/:id/items   # items for a specific order
POST   /v1/orders/:id/cancel  # action as sub-resource (not verb in main path)

# Multi-word resources
GET    /v1/payment-methods    # hyphenated, not camelCase
```

### Error Codes

```
# RFC 9457 type URL pattern
https://api.example.com/problems/{kebab-case-problem-type}

# Examples
https://api.example.com/problems/insufficient-funds
https://api.example.com/problems/user-not-found
https://api.example.com/problems/rate-limit-exceeded
```

---

## Worked Example: REST Endpoint

A complete endpoint implementing input validation, error handling, and structured logging.

### If Node.js/TypeScript (Express + Zod)

```typescript
// src/api/routes/orders.ts
import { z } from 'zod';
import { Router } from 'express';
import { createOrder } from '../domain/commands/create-order';
import { log } from '../shared/logger';

const CreateOrderSchema = z.object({
  userId: z.string().uuid(),
  items: z.array(z.object({
    productId: z.string().uuid(),
    quantity: z.number().int().min(1).max(100),
  })).min(1).max(50),
});

export const ordersRouter = Router();

ordersRouter.post('/', async (req, res) => {
  const parsed = CreateOrderSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(422).json({
      type: 'https://api.example.com/problems/validation-error',
      title: 'Validation Error',
      status: 422,
      detail: parsed.error.message,
    });
  }

  const result = await createOrder(parsed.data);
  if (result.isErr()) {
    log.warn({ error: result.error }, 'Order creation failed');
    return res.status(result.error.httpStatus).json(result.error.toRFC9457());
  }

  log.info({ orderId: result.value.id, userId: parsed.data.userId }, 'Order created');
  return res.status(201).json({ id: result.value.id });
});
```

### If Python (FastAPI + Pydantic)

```python
# src/api/routes/orders.py
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field
from uuid import UUID
from ..domain.commands.create_order import create_order
from ..shared.logger import log

router = APIRouter(prefix="/v1/orders")

class OrderItemInput(BaseModel):
    product_id: UUID
    quantity: int = Field(ge=1, le=100)

class CreateOrderInput(BaseModel):
    user_id: UUID
    items: list[OrderItemInput] = Field(min_length=1, max_length=50)

@router.post("/", status_code=201)
async def create_order_endpoint(body: CreateOrderInput):
    result = await create_order(body)
    if result.is_err():
        raise HTTPException(
            status_code=result.error.http_status,
            detail=result.error.to_rfc9457(),
        )
    log.info("order_created", order_id=str(result.value.id), user_id=str(body.user_id))
    return {"id": str(result.value.id)}
```

### If Go (net/http + standard library)

```go
// src/api/routes/orders.go
func CreateOrderHandler(svc *OrderService) http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        var input CreateOrderInput
        if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
            writeProblemDetail(w, 422, "Validation Error", err.Error())
            return
        }
        if err := input.Validate(); err != nil {
            writeProblemDetail(w, 422, "Validation Error", err.Error())
            return
        }
        order, err := svc.CreateOrder(r.Context(), input)
        if err != nil {
            log.Error().Err(err).Str("userId", input.UserID).Msg("order creation failed")
            writeProblemDetail(w, 500, "Internal Error", "order creation failed")
            return
        }
        log.Info().Str("orderId", order.ID).Str("userId", input.UserID).Msg("order created")
        w.WriteHeader(http.StatusCreated)
        json.NewEncoder(w).Encode(map[string]string{"id": order.ID})
    }
}
```

---

## Worked Example: Database Migration

```sql
-- migrations/0042_add_orders_user_id_index.sql
-- Add index on orders.user_id for pagination queries
-- Run: atlas migrate apply --env dev
-- Rollback: DROP INDEX CONCURRENTLY idx_orders_user_id;

CREATE INDEX CONCURRENTLY idx_orders_user_id
  ON orders(user_id)
  WHERE deleted_at IS NULL;  -- partial index: only active orders
```

---

## Worked Example: Error Types

```typescript
// src/shared/errors/domain-errors.ts
export class InsufficientFundsError {
  readonly httpStatus = 422;

  constructor(
    readonly available: number,
    readonly required: number,
  ) {}

  toRFC9457() {
    return {
      type: 'https://api.example.com/problems/insufficient-funds',
      title: 'Insufficient Funds',
      status: 422,
      detail: `Available balance ${this.available} is below required ${this.required}.`,
    };
  }
}
```

---

## Worked Example: Auth Middleware

```typescript
// src/api/middleware/auth.ts
import { verify, JsonWebTokenError, TokenExpiredError } from 'jsonwebtoken';

export function requireAuth(req: Request, res: Response, next: NextFunction) {
  const header = req.headers.authorization;
  if (!header?.startsWith('Bearer ')) {
    return res.status(401).json({
      type: 'https://api.example.com/problems/unauthorized',
      title: 'Unauthorized',
      status: 401,
    });
  }
  try {
    const token = header.slice(7);
    req.user = verify(token, process.env.JWT_SECRET!, {
      algorithms: ['HS256'],
      issuer: process.env.JWT_ISSUER,
    }) as JWTPayload;
    next();
  } catch (e) {
    const detail = e instanceof TokenExpiredError ? 'Token expired' : 'Invalid token';
    return res.status(401).json({
      type: 'https://api.example.com/problems/unauthorized',
      title: 'Unauthorized',
      status: 401,
      detail,
    });
  }
}
```

---

## Environment Configuration

```bash
# .env.example — copy to .env and fill in values
# Application
NODE_ENV=development
PORT=3000
LOG_LEVEL=info

# Database
DATABASE_URL=postgres://user:password@localhost:5432/myapp

# Authentication
JWT_SECRET=           # min 32 characters, use: openssl rand -hex 32
JWT_ISSUER=https://api.example.com
JWT_EXPIRY=3600       # seconds

# External services
STRIPE_API_KEY=       # never commit real value
REDIS_URL=redis://localhost:6379

# CORS
ALLOWED_ORIGINS=http://localhost:3000,https://app.example.com
```
