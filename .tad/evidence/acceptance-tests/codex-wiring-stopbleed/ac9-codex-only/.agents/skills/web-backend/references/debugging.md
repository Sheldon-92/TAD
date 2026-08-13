# Debugging Rules

Four judgment rules for systematic debugging. Applied when the user is
investigating a bug, performance issue, or unexpected behavior.

These rules prevent the most common debugging failure mode: fixing symptoms
instead of causes, which creates a surface fix that leaves the root problem
in place to manifest again.

---

**Rule 1: Apply the 3-Strike Rule when hypotheses fail**

If three consecutive hypotheses about a bug are wrong, stop forming new hypotheses
about the same layer. Escalate the question: the bug is in the architecture or
the assumptions, not in the place you've been looking.

The 3-Strike sequence:
1. **Strike 1**: Hypothesis fails → form a new hypothesis at the same layer
2. **Strike 2**: Hypothesis fails → expand the scope one level up
3. **Strike 3**: Hypothesis fails → **stop**. Question the fundamental model.

At Strike 3, ask:
- "Am I debugging the right service / process / thread?"
- "Are my assumptions about data flow correct?"
- "Is the bug in how I'm observing the system, not the system itself?"

```bash
# Before forming a 4th hypothesis, verify your observation tools first
# Example: is the log I'm reading the right process?
ps aux | grep myapp
ls -la /proc/$(pgrep myapp)/fd | grep log
```

The 3-Strike Rule is from garrytan/gstack — a systematic debugging methodology
used in production incident response at scale.

[Source: garrytan/gstack — Iron Law and 3-Strike debugging methodology]

---

**Rule 2: Never apply a fix you cannot verify with a test**

A fix without a verifying test is a guess. The test must:
1. **Fail before the fix is applied** (proves the test catches the bug)
2. **Pass after the fix is applied** (proves the fix works)

```typescript
// Before writing any fix, write this test first:
it('should not charge twice when payment webhook is received twice', async () => {
  // Arrange
  const orderId = 'test-order-123';
  await sendPaymentWebhook(orderId);
  await sendPaymentWebhook(orderId);  // duplicate

  // Assert
  const charges = await getChargesForOrder(orderId);
  expect(charges).toHaveLength(1);  // FAILS before the fix
});

// Now apply the idempotency fix, then verify the test passes
```

If the bug cannot be reproduced in a test (race condition, hardware fault, external API):
- Document why it cannot be tested
- Add the closest possible approximation
- Add observability (logs, metrics) to detect recurrence in production

[Source: garrytan/gstack — Verification-First Debugging; Kent Beck — Test-Driven Development]

---

**Rule 3: Flag fixes that touch more than 5 files — review blast radius first**

A fix that modifies 6+ files is no longer a targeted fix. It is a refactor with
a fix embedded. Before proceeding:

1. List all files in the change and ask: does each file change fix the specific bug,
   or is it incidental cleanup?
2. Separate the minimal fix from the cleanup: ship them in separate commits
3. For the minimal fix: is there a more targeted path that touches fewer files?

```bash
# Enumerate your blast radius before committing
git diff --name-only

# If > 5 files: extract the core fix
git stash
git apply --3way minimal-fix.patch  # apply only the essential change first
```

The larger the blast radius, the higher the probability of introducing a regression.
A 1-file fix with a test is almost always safer than a 10-file fix without one.

[Source: garrytan/gstack — Blast Radius Analysis; Sairyss/backend-best-practices — Debugging]

---

**Rule 4: Never fix symptoms without root cause investigation — the Iron Law**

Fixing the symptom suppresses the error signal without removing the underlying problem.
The root cause typically resurfaces later, in a different form, at a worse time.

The Iron Law of debugging: **find the cause, not the nearest fix**.

```
SYMPTOM:   "Requests to /orders are timing out"
           ↓
BAD FIX:   Increase timeout from 5s to 30s
           ↓
RESULT:    Timeouts still happen, now with worse UX and held connections

ROOT CAUSE INVESTIGATION:
  Step 1: Get a slow query log → "SELECT * FROM orders WHERE user_id = $1 takes 4s"
  Step 2: EXPLAIN ANALYZE → "Seq Scan on orders (10M rows)"
  Step 3: Root cause → missing index on user_id
  Step 4: Fix → CREATE INDEX CONCURRENTLY idx_orders_user_id ON orders(user_id);
  Step 5: Verify → query now takes 3ms, timeouts gone
```

Root cause investigation tools:
```bash
# Slow query log (PostgreSQL)
SET log_min_duration_statement = 100;  # log queries > 100ms

# Node.js profiling
node --prof app.js
node --prof-process isolate-*.log | head -20

# Memory leak detection
node --expose-gc app.js  # then heap snapshot comparison

# Linux: what is the process actually waiting for?
strace -p $(pgrep myapp) -e trace=network,file
```

[Source: garrytan/gstack — Iron Law of Debugging; Sairyss/backend-best-practices — Performance Debugging]
