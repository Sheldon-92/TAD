# Application Logic Rules

Six judgment rules for domain logic, error handling, command/query separation,
and object design. Applied when the user is writing domain models, command handlers,
query handlers, or working with DDD patterns.

---

**Rule 1: Do not throw HTTP exceptions from domain core**

Domain logic that throws `HttpException`, `BadRequestException`, or framework-specific
HTTP errors creates an invisible dependency from your domain to your delivery layer.
The domain cannot be tested without a web framework, and cannot be reused in a CLI,
worker, or gRPC context.

```typescript
// WRONG: domain throws HTTP exception
class TransferFunds {
  execute(amount: number): void {
    if (amount > this.balance) {
      throw new BadRequestException('Insufficient funds');  // framework-coupled
    }
  }
}

// RIGHT: domain returns explicit error type
class TransferFunds {
  execute(amount: number): Result<void, InsufficientFundsError> {
    if (amount > this.balance) {
      return Err(new InsufficientFundsError(amount, this.balance));
    }
    return Ok();
  }
}

// The HTTP layer translates:
const result = transferFunds.execute(amount);
if (result.isErr()) {
  throw new UnprocessableEntityException(result.error.toRFC9457());
}
```

```python
# Python equivalent using Result type
def execute(self, amount: Decimal) -> Result[None, InsufficientFundsError]:
    if amount > self.balance:
        return Err(InsufficientFundsError(amount, self.balance))
    return Ok(None)
```

[Source: Sairyss/domain-driven-hexagon — Domain Layer; Sairyss/backend-best-practices — Error Handling]

---

**Rule 2: Return recoverable errors, throw unrecoverable ones**

Not all errors are equal. Design error propagation around whether the caller can do
something meaningful when the error occurs:

- **Recoverable errors** (caller can handle): invalid input, resource not found,
  business rule violation, external API timeout → **return** as explicit error values
- **Unrecoverable errors** (caller cannot fix this): out of memory, disk full,
  corrupted program state, programmer error → **throw** as exceptions (let them crash
  and restart cleanly)

```typescript
// Recoverable: return Result
async findUser(id: string): Promise<Result<User, UserNotFoundError>> {
  const user = await this.repository.find(id);
  if (!user) return Err(new UserNotFoundError(id));
  return Ok(user);
}

// Unrecoverable: throw (let the process restart)
function parseConfig(raw: unknown): Config {
  if (!raw || typeof raw !== 'object') {
    throw new Error('Config file is corrupted — cannot start application');
  }
  return raw as Config;
}
```

[Source: Sairyss/backend-best-practices — Exceptions vs Return Values]

---

**Rule 3: Do not execute commands from within command handlers**

Command handlers should orchestrate, not chain. If a command handler calls another
command handler, you create a hidden workflow that is hard to trace, test, and revert.

The correct pattern: a command handler executes one unit of work, then publishes a
domain event. Other handlers subscribe to the event and execute their own work.

```typescript
// WRONG: command handler chains to another command
class CreateOrderHandler {
  async execute(cmd: CreateOrderCommand) {
    const order = await this.orderService.create(cmd);
    await this.inventoryCommandHandler.execute(new ReserveInventoryCommand(...)); // chaining!
    await this.emailCommandHandler.execute(new SendConfirmationCommand(...)); // chaining!
  }
}

// RIGHT: command handler publishes an event
class CreateOrderHandler {
  async execute(cmd: CreateOrderCommand) {
    const order = await this.orderService.create(cmd);
    await this.eventBus.publish(new OrderCreatedEvent(order));
    // ReserveInventoryHandler and SendConfirmationHandler subscribe to OrderCreatedEvent
  }
}
```

[Source: Sairyss/domain-driven-hexagon — Command Handlers and Events]

---

**Rule 4: Bypass the domain model for read queries**

Forcing every read through the domain model (loading aggregates, running invariant
checks, deserializing value objects) for display-only queries adds unnecessary load.
Query the database directly from the query handler.

```typescript
// WRONG: loading aggregate just to return a view
class GetOrderSummaryHandler {
  async execute(query: GetOrderSummaryQuery) {
    const order = await this.orderRepository.findById(query.orderId); // loads full aggregate
    return OrderSummaryDto.fromDomain(order); // then strips most fields
  }
}

// RIGHT: query handler goes directly to DB
class GetOrderSummaryHandler {
  async execute(query: GetOrderSummaryQuery) {
    return this.db.queryOne(
      `SELECT id, status, total, created_at FROM orders WHERE id = $1`,
      [query.orderId]
    );
  }
}
```

Read queries have no invariants to protect. The domain model is for protecting
invariants during writes. Using it for reads is a performance and complexity tax.

[Source: Sairyss/domain-driven-hexagon — CQRS Read Side]

---

**Rule 5: Convert Value Objects to primitives before external serialization**

Value Objects (e.g., `Money`, `Email`, `UserId`) carry domain logic and validation.
Serializing them directly exposes their internal structure, creates coupling to
internal class layout, and can leak implementation details.

```typescript
// WRONG: serializing value object directly
class Order {
  toJSON() {
    return {
      id: this.id,           // UserId value object → serialized as {}
      total: this.total,     // Money value object → serialized as {amount: 100, currency: "USD"}
    };
  }
}

// RIGHT: convert to primitives explicitly
class Order {
  toDTO(): OrderDTO {
    return {
      id: this.id.value,             // string primitive
      total: this.total.toNumber(),  // number primitive
      currency: this.total.currency, // string primitive
    };
  }
}
```

At API boundaries, external queues, and storage serialization: always unwrap value
objects to their primitive representation.

[Source: Sairyss/domain-driven-hexagon — Value Objects at Boundaries]

---

**Rule 6: Limit inheritance depth to 1-2 levels; prefer composition**

Deep inheritance chains (3+ levels) create brittle hierarchies where a change to a
base class breaks all subclasses in unpredictable ways. The Liskov Substitution
Principle is routinely violated after the second level.

```typescript
// WRONG: deep inheritance
class Entity { ... }
class AuditedEntity extends Entity { ... }
class TenantAuditedEntity extends AuditedEntity { ... }
class SoftDeletableTenantAuditedEntity extends TenantAuditedEntity { ... }

// RIGHT: compose via mixins or traits
class Order extends Entity {
  private readonly audit = new AuditTrail();
  private readonly tenant = new TenantContext();
  private deletedAt?: Date;
}
```

Maximum allowed: 1 level for framework base classes (ActiveRecord, SQLAlchemy Base),
2 levels when a genuine specialization hierarchy exists and will not grow further.

[Source: Sairyss/backend-best-practices — OOP Patterns; GoF Design Patterns — Composition over Inheritance]
