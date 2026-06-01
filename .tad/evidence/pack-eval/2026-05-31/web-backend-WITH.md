# Backend Review: GET /users/search

**Endpoint under review**: `GET /users/search?page=5000`
**Observed behaviors**:
1. Offset pagination (`page=5000`) against a 50M-row table.
2. Writes an audit-log row on every call (state mutation inside a GET).
3. DB password hardcoded in the handler.
4. Deployed on Kubernetes.

**Pack applied**: `web-backend` v0.1.0 — references loaded: `api-design.md`,
`database.md`, `security.md`, `infrastructure.md`. Severity model per SKILL.md
Step 1 (P0 = security/data-loss/outage risk; P1 = correctness/perf-cliff/debt;
P2 = best-practice deviation).

This single endpoint violates rules in all four reference files. Three of them are
P0. Do not merge in its current form.

---

## P0 — Blocking (must fix before merge)

### [P0] Rule 4 (security): DB password hardcoded in the handler

> `Secrets belong in environment variables or a secrets manager — never in code`
> (security.md Rule 4 — OWASP API8:2023 Security Misconfiguration; 12-Factor App)

A hardcoded password is a **permanent leak the moment it is committed** — it lives
in git history forever, even after you "remove" it later. Anyone with repo read
access (or a leaked clone, a CI log, a fork) has production DB credentials.

**Concrete fix**:
1. **Rotate the password NOW.** Treat it as already compromised — it is in git
   history. Removing the line from the current file does not undo the leak; the
   secret must be changed at the database.
2. Load it from the environment, never inline:
   ```python
   # WRONG (current)
   DATABASE_URL = "postgres://admin:supersecret@prod.db:5432/app"

   # RIGHT
   DATABASE_URL = os.getenv("DATABASE_URL")
   ```
3. On Kubernetes (the deploy target here), follow the storage hierarchy in
   security.md Rule 4: a raw **Kubernetes Secret is base64, not encrypted** — pair
   it with Sealed Secrets or an external manager (Vault / AWS Secrets Manager /
   GCP Secret Manager) and mount it as an env var.
   ```yaml
   env:
     - name: DATABASE_URL
       valueFrom:
         secretKeyRef:
           name: app-db
           key: url
   ```
4. Add `.env` to `.gitignore`, ship a placeholder `.env.example`, and run
   `scripts/security-scan.sh <project-root>` (SKILL.md Step 2) to catch any other
   committed secrets. The Anti-Skip table is explicit: run the security scan
   *regardless of whether the user asked for security*.
5. Scrub the secret from git history (`git filter-repo` / BFG) after rotation — but
   rotation is the real fix; history-scrubbing is hygiene.

---

### [P0] Rule 3 (api-design): GET /users/search writes an audit-log row → side effect in a safe method

> `GET requests must never have business logic side effects`
> (api-design.md Rule 3 — RFC 7231 §4.3.1; zalando guidelines)

GET is defined by HTTP as **safe and idempotent**. Writing an audit row on every
call breaks that contract with real, exploitable consequences:
- **CSRF**: a malicious `<img src="https://api/users/search?page=…">` forces a
  victim's browser to fire the write with their cookies — a GET side-effect is the
  classic CSRF sink.
- **Cache/proxy corruption**: any cache, CDN, prefetcher, or retrying proxy may
  replay the GET, multiplying audit rows (and on a 50M-row table, multiplying the
  expensive query below). Browsers and link-prefetchers fire GETs speculatively.
- **Idempotency is now false** — clients and infra assume GET can be retried freely.

**Concrete fix** — separate the read from the write (api-design.md Rule 3):
- Keep `GET /users/search` pure: it returns results and writes nothing.
- Move the audit write off the request path. Two acceptable shapes:
  1. **Async post-response** via middleware / background queue — *"fire it
     asynchronously post-response via middleware or a background queue — not inside
     the GET handler"* (Rule 3 verbatim). The GET responds; the audit row is
     enqueued after the response flushes.
  2. If the audit must be an explicit, recorded action, expose
     `POST /users/search/audit-events` (fire-and-forget) and call it deliberately.
- Reinforced by infrastructure.md Rule 6 (return fast, don't block on
  non-essential work) — the audit write should never be in the critical path of
  the read response.

---

### [P0] Rule 1 (api-design) + Rule 3 (database): offset `page=5000` on a 50M-row table → outage-grade performance cliff

> `Use cursor pagination for datasets > 10K rows` (api-design.md Rule 1)
> `Set external dependency timeouts…` (database.md Rule 3)

`page=5000` with a typical page size means an offset around **100,000–500,000 rows
or more**, and the database **must scan and discard every row up to that offset on
every request** before returning a single result. On a 50M-row table this is a
full index/heap walk deep into the table. This is classified P0 because under
concurrent traffic it exhausts DB connections and cascades into a service outage —
exactly the failure class the pack defines as P0.

Two compounding facts:
- The table is **50M rows** — five thousand times past the 10K threshold where
  api-design.md Rule 1 says cursor pagination is *required*, not optional.
- Deep offsets also return **inconsistent results** when rows are inserted/deleted
  between page fetches (Rule 1).

**Concrete fix**:
1. **Switch to cursor (keyset) pagination** (api-design.md Rule 1):
   ```sql
   -- instead of LIMIT n OFFSET 100000
   SELECT * FROM users
   WHERE id > :cursor_id          -- (or a compound cursor, see below)
   ORDER BY id ASC
   LIMIT :page_size;
   ```
   Return an opaque `next_cursor` + `has_more` envelope (Rule 1 response shape).
2. **If the search sorts by a non-unique key** (e.g. `created_at`, `display_name`,
   relevance) — which "search" usually does — use a **compound cursor
   `(sort_key, tiebreaker_id)`** so colliding values don't skip rows (Rule 1
   explicit branch). Pure id-keyset is only valid if the result is ordered by id.
3. **If users genuinely need to jump to arbitrary page N** (e.g. "page 500 of
   10,000"), cursor pagination *cannot* do that — Rule 1 says route this to
   **Elasticsearch / a search index or pre-computed page indexes**. For a 50M-row
   user *search*, a dedicated search engine is the right home anyway (full-text,
   ranking, facets) — the relational offset scan is the wrong tool.
4. **Set an explicit statement timeout** (database.md Rule 3) so a pathological
   query is rejected instead of piling up and exhausting the pool:
   `timeout = max(p99 × 2, p99.9 + 100ms)`; if p99 unknown, start at 1s for DB
   queries and tighten. Without this, the offset scan is also a thread-pool/
   connection-pool exhaustion vector.
5. **Cap `page_size`** (whitelist validation, security.md Rule 5) — an unbounded
   page size on 50M rows is its own DoS.

---

## P1 — Required (fix this sprint)

### [P1] Rule 4 (api-design): whitelist Response DTO for user records

> `Use whitelisting, not blacklisting, for Response DTOs` (api-design.md Rule 4)

A `/users/search` endpoint returning user rows is the single highest-risk place to
leak fields. If the handler returns ORM rows / `SELECT *`, then the day someone adds
`password_hash`, `mfa_secret`, `internal_notes`, or `stripe_customer_id` to the
`users` table, this endpoint silently serializes it to every caller.

**Concrete fix**: return an explicit whitelist DTO/schema. Only listed fields are
serialized; new columns are invisible until consciously added.
```python
class UserSearchResultDto(BaseModel):   # only these fields ever leave the system
    id: str
    display_name: str
    # password_hash, mfa_secret, email(?) are NOT listed → never serialized
```
Pairs with database.md Rule 2 below — do not expose internal integer ids in this DTO.

### [P1] Rule 5 (security): validate the `page` (and all search) input at the boundary

> `Validate input at system boundaries using a whitelist approach` (security.md Rule 5)

`page=5000` arrives as untrusted input and is presumably interpolated into a query.
Two required checks:
1. **Type/range validation** — `page` must be a bounded positive integer, and
   `page_size` must be capped (see P0 #3). Use a schema (Zod/Pydantic), not ad-hoc
   parsing.
2. **Parameterized queries only** — if any search term (name/email filter) is
   concatenated into SQL, that is SQL injection (Rule 5). Use `WHERE col = $1`
   binding or the ORM, never string interpolation.

### [P1] Rule 7 (infrastructure): graceful shutdown + preStop sleep on Kubernetes

> `Implement graceful shutdown in the correct sequence` (infrastructure.md Rule 7)

This is deployed on K8s, and the endpoint holds DB connections (and, once fixed,
enqueues audit jobs). On a rolling deploy, K8s sends SIGTERM but **removes the pod
from Service endpoints only *after* SIGTERM** — without a propagation delay,
in-flight `/users/search` requests get dropped / connection-refused for 1–3s.

**Concrete fix** (Rule 7):
```yaml
lifecycle:
  preStop:
    exec:
      command: ["sh", "-c", "sleep 10"]   # let endpoint removal propagate
spec:
  terminationGracePeriodSeconds: 60       # ≥ shutdown timeout + 5s
```
Plus an in-process SIGTERM handler that: stops accepting new connections → drains
in-flight requests (10s) → drains the audit job queue → closes the DB pool → exits.

### [P1] Rule 1 (infrastructure): set CPU/memory requests + memory limit on the pod

> `Set CPU requests always; set CPU limits only in multi-tenant clusters`
> (infrastructure.md Rule 1)

Since this runs on K8s and the (fixed) endpoint does real DB work, the pod needs
resource requests or it lands in `BestEffort` QoS and is evicted first under node
pressure — i.e. your search service dies first when the node is stressed.

**Concrete fix**: always set `requests.cpu` + `requests.memory`; always set
`limits.memory` (never omit — memory exhaustion kills the node). Set a `limits.cpu`
≥ 2× request **only** in a multi-tenant cluster; omit it in single-tenant to avoid
CFS throttling on burst. For a production-critical search path, prefer Guaranteed
QoS (`requests.memory == limits.memory`).

---

## P2 — Advisory (track as tech debt)

### [P2] Rule 2 (database): don't expose auto-increment user IDs

> `Choose identifiers appropriate to context` / *"public-facing API: never expose
> auto-incrementing IDs"* (database.md Rule 2)

`/users/search` is a public-facing read. If user ids are sequential integers, a
caller who sees user `#1047` can infer your total user count and enumerate accounts.
**Fix**: expose **UUIDv7/ULID** externally (time-ordered, index-friendly, no count
leak); keep auto-increment internally and map at the application/DTO layer. Folds
into the P1 DTO work above.

### [P2] Rule 2 (security): rate-limit search by authenticated user

> `Rate limit by authenticated user, not by IP address alone` (security.md Rule 2;
> OWASP API4:2023 Unrestricted Resource Consumption)

Even after switching to cursor pagination, search is an expensive endpoint and a
scraping/enumeration target. Rate-limit primarily by authenticated identity
(`keyGenerator: req.user?.id ?? req.ip`), falling back to IP only when unauthed.
This also caps the audit-row write volume.

### [P2] Rule 5 (infrastructure): structured JSON logging to stdout

> `Write logs to stdout/stderr in JSON format — not to files` (infrastructure.md Rule 5)

The audit write suggests this service cares about access trails. Ensure operational
logs (and ideally the audit event itself) are emitted as **structured JSON to
stdout** with `timestamp`, `level`, `message`, and a `request_id`/`trace_id` — not
to local files (which need rotation + a sidecar in K8s) and not bare
`console.log(string)`.

---

## Validation Script Output

Per SKILL.md Step 2 + the Anti-Skip table ("run `scripts/security-scan.sh`
regardless of whether the user mentioned security"), the following should be run
against the real project root:

```
bash scripts/security-scan.sh   <project-root>   # P0 #1: confirm no other committed secrets
bash scripts/readiness-score.sh <project-root>   # K8s deploy → production readiness tiers
```

Not executed here — this review operated on a described endpoint, not a checked-out
repository, so there is no `<project-root>` to scan. **These scripts MUST be run
before merge**; the hardcoded-secret P0 in particular means a secrets scan is
mandatory, and the K8s deployment means the readiness score (graceful shutdown,
resource limits, secrets management) should gate go-live.

---

## Summary

| Severity | Count | Rules triggered |
|----------|-------|-----------------|
| P0 | 3 | security R4 (secret), api-design R3 (GET side-effect), api-design R1 + database R3 (offset cliff / timeout) |
| P1 | 4 | api-design R4 (DTO), security R5 (input validation), infra R7 (shutdown), infra R1 (resources) |
| P2 | 3 | database R2 (id exposure), security R2 (rate limit), infra R5 (logging) |

**Verdict: BLOCK merge.** Three independent P0s. Minimum path to unblock:
1. Rotate the DB password + move it to a K8s Secret/secrets manager via env var.
2. Make the GET pure; move the audit write to async post-response.
3. Replace offset pagination with cursor (compound cursor for non-unique sort) or
   route arbitrary-page search to a search index; add a statement timeout + page-size cap.

Then run `security-scan.sh` and `readiness-score.sh` before go-live, and pick up the
P1 K8s hardening (graceful shutdown, resource requests) since this is deployed on
Kubernetes.
