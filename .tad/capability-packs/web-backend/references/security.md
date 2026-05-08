# Security Rules

Seven explicit security rules plus OWASP API Security Top 10 mapping.
Applied when the user is implementing authentication, authorization, input handling,
secret management, or any security-sensitive feature.

Run `scripts/security-scan.sh` to automate checks for secrets, dependencies, and
OWASP API Security Top 10 issues.

---

**Rule 1: Always validate JWT signatures server-side — never trust client-decoded claims**

JWT tokens are Base64-encoded. A client (or attacker) can decode the payload without
any key. Never use the decoded claims unless you have verified the signature:

```typescript
// WRONG: using decoded payload without verification
const decoded = JSON.parse(atob(token.split('.')[1]));
const userId = decoded.sub;  // trusting unverified data

// RIGHT: verify signature first
import { verify } from 'jsonwebtoken';
const payload = verify(token, process.env.JWT_SECRET, { algorithms: ['HS256'] });
const userId = payload.sub;
```

```python
# Python
import jwt
payload = jwt.decode(token, secret, algorithms=['HS256'])  # raises if invalid
```

Also: set `alg` explicitly, never accept `alg: none`. Validate `exp`, `iss`, `aud`.

[Source: OWASP/API-Security — API2:2023 Broken Authentication; JWT Best Practices RFC 8725]

---

**Rule 2: Rate limit by authenticated user, not by IP address alone**

IP-based rate limiting fails in environments with shared egress (corporate NATs,
VPNs, mobile carriers): one misbehaving client can block 1000 legitimate clients
behind the same IP. Rate limit primarily by authenticated identity.

```typescript
// If Node.js + Express: rate limit by user ID
const rateLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: 100,
  keyGenerator: (req) => req.user?.id ?? req.ip,  // user ID when authed, IP as fallback
  message: { type: 'https://api.example.com/problems/rate-limit-exceeded', status: 429 },
});
```

Apply stricter limits to authentication endpoints (login, password reset) regardless
of user identity — these are the primary targets for credential stuffing.

[Source: OWASP/API-Security — API4:2023 Unrestricted Resource Consumption]

---

**Rule 3: Never return different error messages for "user not found" vs "wrong password"**

Returning distinct error messages for authentication failures enables **user enumeration
attacks**: an attacker can determine whether an email is registered without any credentials.

```typescript
// WRONG: reveals whether the account exists
if (!user) throw new NotFoundException('User not found');
if (!await bcrypt.compare(password, user.passwordHash)) {
  throw new UnauthorizedException('Invalid password');
}

// RIGHT: identical message for both failure cases
if (!user || !await bcrypt.compare(password, user.passwordHash)) {
  throw new UnauthorizedException('Invalid credentials');
}
// Still call bcrypt.compare even if user is null, to prevent timing attacks
```

Same principle applies to: password reset emails ("if this address is registered,
you'll receive an email"), account lockout messages.

[Source: OWASP/API-Security — API2:2023 Broken Authentication]

---

**Rule 4: Secrets belong in environment variables or a secrets manager — never in code**

Hardcoded secrets are permanent leaks the moment code is committed to any repository.

```bash
# WRONG: secret in code
DATABASE_URL = "postgres://admin:supersecret@prod.db:5432/app"
API_KEY = "sk-prod-abc123xyz"

# RIGHT: loaded from environment
DATABASE_URL = os.getenv("DATABASE_URL")
API_KEY = os.getenv("STRIPE_API_KEY")
```

Storage hierarchy by risk tolerance:
1. **CI/CD secrets** (GitHub Actions, GitLab CI): inject as masked environment variables
2. **Container secrets**: Kubernetes Secrets (base64 encoded, not encrypted by default —
   use Sealed Secrets or an external secrets manager)
3. **Production**: HashiCorp Vault, AWS Secrets Manager, GCP Secret Manager

Add `.env` to `.gitignore`. Provide `.env.example` with placeholder values.
Run `scripts/security-scan.sh` to detect accidental commits.

[Source: OWASP/API-Security — API8:2023 Security Misconfiguration; 12-Factor App methodology]

---

**Rule 5: Validate input at system boundaries using a whitelist approach**

Input validation must happen at the entry point of your system (API handler, queue
consumer, file upload processor). Validate by specifying what is allowed, not by
checking for known-bad patterns:

```typescript
// WRONG: blacklist approach (misses new attack vectors)
if (input.includes('<script>') || input.includes('DROP TABLE')) { reject(); }

// RIGHT: whitelist approach
const schema = z.object({
  username: z.string().regex(/^[a-zA-Z0-9_-]{3,30}$/),
  email: z.string().email(),
  age: z.number().int().min(0).max(150),
});
const validated = schema.parse(req.body);  // throws on invalid
```

```python
# Python — Pydantic
class UserInput(BaseModel):
    username: str = Field(pattern=r'^[a-zA-Z0-9_-]{3,30}$')
    email: EmailStr
    age: int = Field(ge=0, le=150)
```

For SQL: always use parameterized queries or an ORM — never string concatenation.

```typescript
// WRONG: SQL injection
await db.query(`SELECT * FROM users WHERE email = '${email}'`);

// RIGHT: parameterized
await db.query('SELECT * FROM users WHERE email = $1', [email]);
```

[Source: OWASP/API-Security — API1:2023 Broken Object Level Authorization; OWASP Input Validation Cheat Sheet]

---

**Rule 6: CORS must have explicit allowed origins — never wildcard with credentials**

`Access-Control-Allow-Origin: *` with `Access-Control-Allow-Credentials: true`
is rejected by browsers, but wildcard + credentials in misconfigured servers
allows credential theft from any origin.

```typescript
// WRONG
app.use(cors({ origin: '*', credentials: true }));

// RIGHT: explicit origins
const allowedOrigins = process.env.ALLOWED_ORIGINS?.split(',') ?? [];
app.use(cors({
  origin: (origin, callback) => {
    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true,
}));
```

For public APIs with no cookies or credentials: `Access-Control-Allow-Origin: *` is acceptable.

[Source: OWASP/API-Security — API8:2023 Security Misconfiguration; MDN CORS documentation]

---

**Rule 7: Run dependency audits before every release**

Vulnerable dependencies are the most common production security issue and the most
easily prevented. Automate the check:

```bash
# If Node.js
npm audit --audit-level=high

# If Python
pip-audit --desc

# If Go
govulncheck ./...

# If Rust
cargo audit
```

Configure CI to fail on `high` or `critical` severity findings. For `npm audit`:
distinguish development-only vulnerabilities (in `devDependencies`) from production
ones — only block on production dependency vulnerabilities.

[Source: OWASP/API-Security — API10:2023 Unsafe Consumption of APIs; supply-chain-security best practices]

---

## OWASP API Security Top 10 — Quick Mapping

| OWASP ID | Vulnerability | Mitigation |
|----------|--------------|------------|
| API1 | Broken Object Level Authorization | Validate resource ownership on every request, not just authentication |
| API2 | Broken Authentication | JWT server-side validation (Rule 1), enumeration prevention (Rule 3) |
| API3 | Broken Object Property Level Auth | Use whitelist DTOs (Rule 4 in api-design.md) |
| API4 | Unrestricted Resource Consumption | Rate limiting by user (Rule 2), pagination limits |
| API5 | Broken Function Level Authorization | Explicit role checks, not just authentication |
| API6 | Unrestricted Access to Sensitive Business Flows | Rate limiting on critical flows (signup, checkout) |
| API7 | Server-Side Request Forgery | Validate and allowlist outbound URLs |
| API8 | Security Misconfiguration | Secrets in env (Rule 4), CORS explicit (Rule 6) |
| API9 | Improper Inventory Management | Versioned APIs, remove deprecated endpoints |
| API10 | Unsafe Consumption of APIs | Dependency audit (Rule 7), input validation (Rule 5) |

Run: `npx @stoplight/spectral-cli lint --ruleset @stoplight/spectral-owasp-rules <spec>`
