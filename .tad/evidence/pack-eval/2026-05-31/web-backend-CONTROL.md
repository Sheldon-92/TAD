# Endpoint Review: `GET /users/search?page=5000`

**Reviewed:** 2026-05-31
**Endpoint:** `GET /users/search?page=5000`
**Context:** Offset-based pagination over a 50M-row `users` table; writes an audit-log row on every call; DB password hardcoded in the handler; deployed on Kubernetes.

---

## Summary

This endpoint has four independent problems spanning security, performance, and correctness/operability. The hardcoded credential is the most urgent (an exploitable, possibly already-leaked secret). The deep-offset query is a latency and DB-load bomb that gets worse as users paginate. The per-call audit write turns a read endpoint into a write endpoint, hurting scalability and creating a contention/abuse surface. Below, issues are grouped by severity with concrete fixes.

---

## CRITICAL

### C1. Hardcoded DB password in the handler

**Problem.** A credential committed to source is compromised the moment it lands in version control. It is visible to everyone with repo read access, lives forever in git history (rotating the variable does not purge old commits), leaks into CI logs, container image layers, and backups, and cannot be rotated without a code deploy. On Kubernetes specifically, there is no excuse — the platform has first-class secret injection.

**Fix.**
1. **Rotate the password now.** Assume it is already exposed. Treat it as a live incident: rotate the DB user's password, review DB access logs for anomalous connections.
2. **Move the secret out of code.** Read it from the environment / a secret store, not a literal:
   ```python
   # before
   conn = connect(password="hunter2")
   # after
   conn = connect(password=os.environ["DB_PASSWORD"])
   ```
3. **Inject via Kubernetes Secret**, mounted as an env var or file:
   ```yaml
   env:
     - name: DB_PASSWORD
       valueFrom:
         secretKeyRef:
           name: db-credentials
           key: password
   ```
   Better still, use an external manager (AWS/GCP Secrets Manager, Vault, External Secrets Operator) so the secret is never stored in etcd in plaintext. Note: a raw k8s `Secret` is only base64-encoded, not encrypted — enable encryption-at-rest for etcd or use a sealed/external secret.
4. **Purge git history** (e.g., `git filter-repo` / BFG) and force-push, then have all collaborators re-clone. Rotation in step 1 is what actually protects you; history purge is hygiene.
5. **Add a secret scanner to CI** (gitleaks / trufflehog) to block this class of regression.

**Even better:** drop static DB passwords entirely. Use IAM/workload-identity DB auth (e.g., IAM database authentication, Cloud SQL IAM, or Vault dynamic short-lived credentials) so there is no long-lived password to leak.

---

## HIGH

### H1. Deep OFFSET pagination on a 50M-row table

**Problem.** `LIMIT n OFFSET 5000*pageSize` forces the database to **scan and discard every row before the offset**. At `page=5000` with, say, 20 rows/page, the engine reads ~100,000 rows just to throw away 99,980 and return 20. The cost grows linearly with page number — late pages can take seconds, hold locks/buffers, and evict cache. A handful of users (or a scraper) walking deep pages can saturate DB CPU and I/O. This is a classic O(offset) anti-pattern and a denial-of-service vector.

**Fixes (in order of preference).**

1. **Keyset / seek pagination (cursor).** Paginate by the last-seen sort key instead of an offset. Cost is O(page size), independent of depth:
   ```sql
   -- first page
   SELECT * FROM users WHERE <filter> ORDER BY id LIMIT 20;
   -- next page (cursor = last id from previous page)
   SELECT * FROM users WHERE <filter> AND id > :last_id ORDER BY id LIMIT 20;
   ```
   Return an opaque `next_cursor` token to the client rather than a page number. Requires a stable, indexed, unique-or-tie-broken sort key (e.g., `(created_at, id)`). This is the correct fix for "infinite scroll" / API consumers.

2. **If page numbers are a hard product requirement**, cap the maximum reachable offset (e.g., reject `page > 500`) and steer deep navigation toward filtering/search instead of raw paging. Most legitimate users never go past the first few pages; deep pages are almost always bots.

3. **Ensure the search is index-backed.** A `/users/search` endpoint implies a WHERE clause. Confirm the filter columns are indexed and the `ORDER BY` matches an index so the DB can avoid a full sort. For text search, use a proper index (trigram/GIN/`pg_trgm`, or a dedicated search engine like OpenSearch) rather than `LIKE '%term%'`, which can't use a btree index.

4. **Avoid expensive total counts.** If the response includes a total count, `COUNT(*)` over 50M filtered rows is itself costly. Use approximate counts (`reltuples` estimates), cache them, or omit total counts in favor of "has next page" (fetch `limit+1`).

**Validation.** Run `EXPLAIN (ANALYZE, BUFFERS)` on the deep-page query before and after. Look for the disappearance of large `Rows Removed by Filter` / high `actual rows` scanned, and confirm an index scan replaces a seq scan.

### H2. Audit-log write on every search call (read endpoint doing writes)

**Problem.** Several issues bundled here:
- A `GET` is supposed to be safe/idempotent and read-only. Writing on every `GET` violates HTTP semantics and means any retry, prefetch, crawler, or CDN/client revalidation amplifies writes.
- It puts a synchronous write in the hot path of a read endpoint: every search now incurs an INSERT, a transaction, and lock/WAL overhead. Latency and DB write load scale with read traffic.
- It is an **unbounded write-amplification / abuse surface**: an attacker hammering search inflates the audit table (and its indexes) without limit, driving storage cost and slowing everything that touches that table. Combined with H1, deep-page scans are now also generating audit rows.
- The audit write likely shares the request transaction, so an audit-table problem (lock, full disk, index bloat) can fail otherwise-successful reads — or worse, a partial failure leaves the read succeeding but the audit missing (or vice versa), undermining the audit log's integrity guarantee.

**Fixes.**
1. **Question whether a search GET needs per-call auditing at all.** Audit logs are usually for state changes and sensitive access. If this is "who searched for whom" compliance logging, keep it but make it cheap and asynchronous; if it's incidental, drop it.
2. **Make it asynchronous / out-of-band.** Emit the audit event to a queue (Kafka/SQS/Redis stream) or an in-process buffered channel, and persist in a background worker / batch insert. The request returns without waiting on the audit write.
3. **Decouple failure domains.** The audit write must not be able to fail the read. If you keep it inline, wrap it so an audit error logs-and-continues rather than aborting the response (only acceptable if the audit is non-critical; if it IS compliance-critical, you instead need a durable queue so you don't silently lose events).
4. **Batch the inserts.** Buffer N events / T milliseconds and do multi-row INSERTs to amortize transaction overhead.
5. **Rate-limit the endpoint** (per-user / per-IP) so abuse can't drive unbounded audit growth or DB load — this also caps H1's deep-paging cost.
6. **Plan audit-table lifecycle:** partition by time and set a retention/archival policy (e.g., monthly partitions, drop/cold-store old ones) so the audit table doesn't grow without bound and degrade.

---

## MEDIUM

### M1. Missing input validation on `page` (and other query params)

**Problem.** `page=5000` is accepted as-is. Without validation you risk negative/zero/huge values, non-numeric input, integer overflow, and the deep-offset DoS from H1. Unvalidated params are also a place where injection sneaks in if the value is ever string-concatenated into SQL.

**Fix.** Validate and clamp: `page` must be a positive integer within a sane max; `pageSize` must be bounded (e.g., 1–100) with a default. Reject out-of-range with `400`. Always use parameterized queries / bound parameters — never string-format user input into SQL.

### M2. Authorization & data-exposure on a user-search endpoint

**Problem.** `/users/search` returns user records. It's unclear that the caller is authenticated and authorized, or that the response is field-filtered. A search endpoint is a common vector for enumeration and PII scraping (email, phone, internal IDs).

**Fix.** Enforce authn + authz on the endpoint. Return only the minimum necessary fields (no password hashes, internal flags, PII the caller isn't entitled to). Apply per-user rate limiting and consider that exhaustive pagination = bulk export; deep paging caps (H1) double as a scraping control.

### M3. Connection handling / per-request connect

**Problem.** A password literal in the handler hints the handler may be opening its own connection per call. Per-request `connect()` against the DB is expensive and can exhaust DB connection slots under load — especially with the extra audit write.

**Fix.** Use a shared connection pool (pgbouncer / framework pool) sized to the DB's limits, initialized once at startup, with sensible timeouts. The handler borrows and returns connections rather than creating them.

---

## LOW / Operability

### L1. Observability for the slow path
Add metrics (latency histogram, query time, rows scanned) and structured logs tagged with `page`/`pageSize` so deep-page abuse and slow queries are visible. Add a statement timeout on the DB session so a pathological query is killed rather than holding resources.

### L2. Kubernetes production hardening (since it's deployed on K8s)
- **Probes:** ensure liveness/readiness probes don't hit this expensive endpoint; a slow deep-page query shouldn't flap the pod.
- **Resource requests/limits** set so a query storm can't OOM neighbors.
- **HPA** keyed on CPU/latency — but note autoscaling pods won't save you from a single overloaded DB; the DB is the bottleneck here (H1/H2).
- **Graceful shutdown / `preStop` sleep** so in-flight requests drain on rollout.
- **Network policy** restricting which pods can reach the DB.

### L3. HTTP contract
Set caching headers deliberately (search results are typically `Cache-Control: no-store` if user-specific). Return a stable pagination contract (`next_cursor`, not just `page`) per H1.

---

## Prioritized action list

1. **Rotate the DB password and move it to a K8s/external secret** (C1) — do today; treat as incident.
2. **Replace OFFSET with keyset pagination** (or cap max page) and confirm the search is index-backed (H1).
3. **Make the audit write async/batched, decouple its failure domain, add rate limiting** (H2).
4. **Validate/clamp `page` & `pageSize`; enforce authz + field filtering** (M1, M2).
5. **Add a connection pool** (M3).
6. **Add metrics, statement timeout, and K8s hardening** (L1–L3).

---

## One-line verdict

A read endpoint that leaks a credential, scans 100k rows to return 20, and writes to the DB on every call — fix the secret immediately, switch to cursor pagination, and move the audit write off the hot path.
