# Security Checklist Skill

---
title: "Security Checklist"
version: "3.0"
last_updated: "2026-01-06"
tags: [security, mandatory, gate5, owasp, asvs, supply-chain]
domains: [web, api, backend, frontend, mobile, devops]
level: intermediate-advanced
estimated_time: "60min"
prerequisites: []
sources:
  - "OWASP Top 10 2021"
  - "OWASP ASVS 4.0.3"
  - "OWASP API Security Top 10"
  - "CWE/SANS Top 25"
  - "NIST Cybersecurity Framework"
enforcement: mandatory
tad_gates: [Gate5_Security]
---

## TL;DR Quick Checklist

```
1. [ ] npm audit / dependency scan - no critical/high vulnerabilities
2. [ ] gitleaks / secrets scan - no exposed credentials
3. [ ] All user inputs validated + sanitized (XSS, SQLi, XXE)
4. [ ] Auth: bcrypt/argon2 + rate limiting + session secure flags
5. [ ] HTTPS + Security headers (CSP, HSTS, Permissions-Policy)
```

**Red Flags (Instant Rejection):**
- Hardcoded API keys, passwords, or private keys
- SQL/NoSQL queries with string concatenation
- `eval()`, `Function()`, `new Function()`, dynamic code execution
- `innerHTML`, `v-html`, `dangerouslySetInnerHTML` with user input
- CORS with `origin: '*'` in production
- XML parsing without disabling external entities (XXE)
- Missing CSRF protection on state-changing operations

---

## Overview

This skill enforces comprehensive security checks across the entire application lifecycle. It maps to:
- **OWASP Top 10 (2021)** - Web application vulnerabilities
- **OWASP API Security Top 10 (2023)** - API-specific risks
- **OWASP ASVS 4.0.3** - Verification standard levels

**Core Principle:** "Security is not a feature, it's a constraint. Code that violates security constraints is buggy, not 'working but risky'."

**ASVS Levels:**
| Level | Description | Use Case |
|-------|-------------|----------|
| L1 | Opportunistic | All applications (minimum) |
| L2 | Standard | Business-critical, handles PII |
| L3 | Advanced | High-value targets, financial, healthcare |

---

## Triggers

| Trigger | Context | Action | Gate |
|---------|---------|--------|------|
| Gate5 | Pre-deployment security gate | Full security audit | Gate5 |
| `*deploy` command | Blake deploying | Deployment security checklist | Gate5 |
| `*review` command | Alex reviewing implementation | Security review focus | Gate3 |
| Code touching auth/input/data | Any development | Inline security checks | - |
| New dependency added | Package installation | Supply chain review | - |
| API endpoint created | API development | API security checklist | Gate3 |

**MQ6 Triggers:**
- "OWASP prevention for [vulnerability type]"
- "Secure implementation of [feature]"
- "Security best practices for [framework/language]"

---

## Inputs

- Source code to be reviewed
- API endpoint definitions
- Database schema and queries
- Third-party dependencies list (`package.json`, `requirements.txt`, etc.)
- Infrastructure configuration (Docker, K8s, cloud)
- Threat model (if exists)

---

## Outputs / Evidence / Acceptance

### Required Evidence

| Evidence Type | Description | Location | Tool |
|---------------|-------------|----------|------|
| `dependency_scan` | SCA scan results | `.tad/evidence/security/deps-scan.json` | npm audit, Snyk |
| `secrets_scan` | No secrets in codebase | `.tad/evidence/security/secrets-scan.txt` | gitleaks |
| `sast_report` | Static analysis results | `.tad/evidence/security/sast-report.json` | Semgrep, ESLint |
| `security_headers` | Header configuration | `.tad/evidence/security/headers-check.txt` | curl, securityheaders.com |
| `threat_model` | Critical flow analysis | `.tad/evidence/security/threat-model.md` | Manual |
| `container_scan` | Image vulnerabilities | `.tad/evidence/security/container-scan.json` | Trivy |

### Acceptance Criteria (Gate5)

```
[ ] No critical or high vulnerabilities in dependencies
[ ] No secrets detected in codebase
[ ] SAST scan passes with no high-severity findings
[ ] All OWASP Top 10 items addressed
[ ] Security headers configured correctly
[ ] Input validation on all user-facing endpoints
[ ] Authentication/Authorization properly implemented
[ ] Threat model documented for critical flows
[ ] Container images scanned (if applicable)
```

### Artifacts

| Artifact | Path | Template |
|----------|------|----------|
| Security Audit Report | `.tad/evidence/security/audit-report.md` | See below |
| SBOM | `docs/security/sbom.json` | CycloneDX |
| Threat Model | `docs/security/threat-model.md` | STRIDE |
| Security Headers Config | `config/security-headers.yaml` | Helmet config |

---

## Procedure

### Phase 1: Supply Chain Security

#### Dependency Scanning (SCA)

```bash
# Node.js - Multiple tools for comprehensive coverage
npm audit --audit-level=high --json > audit-results.json
npx better-npm-audit audit
npx snyk test --severity-threshold=high

# Python
pip-audit --format json --output audit.json
safety check --full-report

# Go
govulncheck ./...

# Rust
cargo audit

# .NET
dotnet list package --vulnerable
```

#### SBOM Generation

```bash
# CycloneDX (recommended)
npx @cyclonedx/cdxgen -o sbom.json

# SPDX format
npx @cyclonedx/cdxgen -o sbom.spdx.json --spec-version 1.4

# Verify SBOM
npx @cyclonedx/cdxgen -o sbom.json --validate
```

#### Supply Chain Checklist

```
[ ] npm audit shows no critical/high vulnerabilities
[ ] Lockfile (package-lock.json) committed and up-to-date
[ ] Dependabot/Renovate configured for auto-updates
[ ] SBOM generated and stored
[ ] Unused dependencies removed
[ ] Dependencies from trusted sources only (npm, PyPI)
[ ] No typosquatting packages (verify package names)
[ ] License compliance checked (no GPL in proprietary projects)
```

### Phase 2: Secrets Detection

```bash
# gitleaks (recommended)
gitleaks detect --source . --verbose --report-format json --report-path secrets.json

# trufflehog (cloud-aware)
trufflehog filesystem . --only-verified --json

# detect-secrets (baseline support)
detect-secrets scan --all-files --baseline .secrets.baseline

# Pre-commit hook setup
cat > .pre-commit-config.yaml << 'EOF'
repos:
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.18.0
    hooks:
      - id: gitleaks
EOF
```

#### Secrets Checklist

```
[ ] No API keys in source code
[ ] No passwords in configuration files
[ ] No private keys (SSH, SSL) committed
[ ] No JWT secrets in code
[ ] No database connection strings with credentials
[ ] .env files in .gitignore
[ ] Secrets managed via:
    [ ] Environment variables (development)
    [ ] Secret manager (production): AWS Secrets Manager, Vault, etc.
[ ] Pre-commit hook installed for secrets detection
```

### Phase 3: OWASP Top 10 (2021) + ASVS Mapping

#### A01: Broken Access Control (ASVS V4)

```typescript
// Access control implementation pattern
import { Request, Response, NextFunction } from 'express';

// 1. Middleware chain: Authenticate -> Authorize -> Validate Ownership
app.get('/api/v1/users/:id/documents/:docId',
  authenticate,                    // ASVS 4.1.1 - Verify identity
  authorize(['user', 'admin']),    // ASVS 4.1.3 - Role check
  validateOwnership('userId'),     // ASVS 4.1.2 - Resource ownership
  getDocument
);

// 2. Deny by default - explicit permission grants
const rbac = {
  permissions: {
    'user': ['read:own_profile', 'update:own_profile'],
    'manager': ['read:team_profiles', 'update:team_profiles'],
    'admin': ['read:all', 'write:all', 'delete:all']
  },
  default: []  // No permissions by default
};

// 3. CORS - strict configuration
const corsOptions = {
  origin: (origin, callback) => {
    const allowedOrigins = process.env.ALLOWED_ORIGINS?.split(',') || [];
    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error('CORS not allowed'));
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  maxAge: 86400  // 24 hours preflight cache
};
```

**Checklist (ASVS V4):**
```
[ ] V4.1.1 - All endpoints require authentication (unless public)
[ ] V4.1.2 - Resource ownership validated (prevent IDOR)
[ ] V4.1.3 - Role-based access control implemented
[ ] V4.1.4 - Deny by default policy
[ ] V4.2.1 - CORS properly configured (no wildcards)
[ ] V4.3.1 - Admin functions protected
[ ] Directory traversal prevented (validate file paths)
```

#### A02: Cryptographic Failures (ASVS V6)

```typescript
// Password hashing - argon2 preferred
import argon2 from 'argon2';

const hashPassword = async (password: string): Promise<string> => {
  return argon2.hash(password, {
    type: argon2.argon2id,    // Hybrid mode (recommended)
    memoryCost: 65536,        // 64 MB
    timeCost: 3,              // 3 iterations
    parallelism: 4,           // 4 threads
    hashLength: 32            // 256-bit hash
  });
};

// Data encryption at rest - AES-256-GCM
import crypto from 'crypto';

class Encryptor {
  private key: Buffer;
  private algorithm = 'aes-256-gcm' as const;

  constructor(secretKey: string) {
    this.key = crypto.scryptSync(secretKey, 'unique-salt', 32);
  }

  encrypt(plaintext: string): { ciphertext: string; iv: string; tag: string } {
    const iv = crypto.randomBytes(16);
    const cipher = crypto.createCipheriv(this.algorithm, this.key, iv);

    let ciphertext = cipher.update(plaintext, 'utf8', 'hex');
    ciphertext += cipher.final('hex');

    return {
      ciphertext,
      iv: iv.toString('hex'),
      tag: cipher.getAuthTag().toString('hex')
    };
  }

  decrypt(ciphertext: string, iv: string, tag: string): string {
    const decipher = crypto.createDecipheriv(
      this.algorithm,
      this.key,
      Buffer.from(iv, 'hex')
    );
    decipher.setAuthTag(Buffer.from(tag, 'hex'));

    let plaintext = decipher.update(ciphertext, 'hex', 'utf8');
    plaintext += decipher.final('utf8');
    return plaintext;
  }
}
```

**Checklist (ASVS V6):**
```
[ ] V6.2.1 - Passwords hashed with argon2id or bcrypt (cost 12+)
[ ] V6.2.2 - No deprecated algorithms (MD5, SHA1, DES, 3DES)
[ ] V6.2.3 - Sensitive data encrypted at rest (AES-256-GCM)
[ ] V6.2.4 - TLS 1.2+ for all connections
[ ] V6.2.5 - Keys stored securely (not in code)
[ ] V6.4.1 - Cryptographic keys rotated periodically
[ ] V6.4.2 - Key derivation uses PBKDF2/scrypt/argon2
```

#### A03: Injection (ASVS V5)

```typescript
// SQL Injection Prevention
// Always use parameterized queries
const getUser = async (userId: string) => {
  // SAFE - Parameterized query
  return db.query('SELECT * FROM users WHERE id = $1', [userId]);
};

// ORM with proper escaping (Prisma example)
const user = await prisma.user.findUnique({
  where: { id: userId }  // SAFE - Auto-escaped
});

// Command Injection Prevention
import { execFile } from 'child_process';
import path from 'path';

const processFile = (filename: string) => {
  // Validate filename first
  const sanitizedName = path.basename(filename);  // Remove path traversal
  if (!/^[\w.-]+$/.test(sanitizedName)) {
    throw new Error('Invalid filename');
  }

  // SAFE - execFile doesn't use shell, args are array
  return execFile('convert', [sanitizedName, '-resize', '100x100', 'output.jpg']);
};

// NoSQL Injection Prevention (MongoDB)
const findUser = async (username: string) => {
  // UNSAFE: userInput could be { "$gt": "" }
  // return db.users.findOne({ username: userInput });

  // SAFE: Explicit string cast + operator
  return db.users.findOne({
    username: { $eq: String(username) }
  });
};

// XPath Injection Prevention
// Use parameterized XPath queries or sanitize input
const sanitizedInput = input.replace(/['"]/g, '');
```

**Checklist (ASVS V5):**
```
[ ] V5.3.1 - All SQL uses parameterized queries or ORM
[ ] V5.3.2 - No string concatenation in queries
[ ] V5.3.3 - NoSQL queries use explicit operators
[ ] V5.3.4 - LDAP queries properly escaped
[ ] V5.3.5 - OS command injection prevented (execFile, not exec)
[ ] V5.3.6 - XPath/XML injection prevented
[ ] V5.3.7 - Template injection prevented
```

#### A04: Insecure Design (Threat Modeling)

**STRIDE Threat Model Template:**

```markdown
## Threat Model: [Feature Name]

### Data Flow Diagram
[Include diagram showing trust boundaries]

### Assets
| Asset | Sensitivity | Location |
|-------|-------------|----------|
| User credentials | High | Database |
| Session tokens | High | Cookie/Redis |
| User PII | Medium | Database |

### Threats (STRIDE)
| Threat | Category | Likelihood | Impact | Mitigation |
|--------|----------|------------|--------|------------|
| Credential stuffing | Spoofing | High | High | Rate limiting, MFA |
| Session hijacking | Tampering | Medium | High | Secure cookies, HTTPS |
| Data exfiltration | Info Disclosure | Medium | High | Encryption, access control |
| Account lockout DoS | DoS | Medium | Medium | Progressive delays |
| Privilege escalation | Elevation | Low | Critical | RBAC, ownership checks |

### Security Controls
1. Rate limiting: 5 failed logins / 15 min
2. Account lockout: 10 failures = 1 hour lockout
3. MFA required for admin accounts
4. Session timeout: 1 hour idle
```

**Checklist:**
```
[ ] Threat modeling completed for critical flows
[ ] Rate limiting on sensitive operations
[ ] Account lockout after failed attempts (with progressive delays)
[ ] Secure password reset flow (time-limited tokens)
[ ] No security-sensitive data in URLs
[ ] Business logic flaws reviewed
```

#### A05: Security Misconfiguration (ASVS V14)

```typescript
// Security headers with Helmet.js
import helmet from 'helmet';

app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'"],  // Remove 'unsafe-inline' if possible
      styleSrc: ["'self'", "'unsafe-inline'"],  // Required for some CSS-in-JS
      imgSrc: ["'self'", "data:", "https:"],
      connectSrc: ["'self'", "https://api.example.com"],
      fontSrc: ["'self'", "https://fonts.gstatic.com"],
      objectSrc: ["'none'"],
      mediaSrc: ["'self'"],
      frameSrc: ["'none'"],
      frameAncestors: ["'none'"],
      formAction: ["'self'"],
      baseUri: ["'self'"],
      upgradeInsecureRequests: []
    }
  },
  hsts: {
    maxAge: 31536000,           // 1 year
    includeSubDomains: true,
    preload: true
  },
  referrerPolicy: {
    policy: 'strict-origin-when-cross-origin'
  },
  permissionsPolicy: {
    features: {
      accelerometer: [],
      camera: [],
      geolocation: [],
      gyroscope: [],
      magnetometer: [],
      microphone: [],
      payment: [],
      usb: []
    }
  },
  crossOriginEmbedderPolicy: true,
  crossOriginOpenerPolicy: { policy: 'same-origin' },
  crossOriginResourcePolicy: { policy: 'same-origin' }
}));

// Remove fingerprinting headers
app.disable('x-powered-by');
```

**Expected Security Headers:**
```http
Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
Content-Security-Policy: default-src 'self'; script-src 'self'; ...
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: geolocation=(), camera=(), microphone=()
Cross-Origin-Embedder-Policy: require-corp
Cross-Origin-Opener-Policy: same-origin
```

**Checklist (ASVS V14):**
```
[ ] V14.1.1 - Debug mode disabled in production
[ ] V14.1.2 - Default credentials changed
[ ] V14.1.3 - Unnecessary features disabled
[ ] V14.2.1 - Error messages don't leak internal details
[ ] V14.4.1 - CSP configured (restrictive policy)
[ ] V14.4.2 - HSTS enabled (1 year, include subdomains)
[ ] V14.4.3 - X-Content-Type-Options: nosniff
[ ] V14.4.4 - Referrer-Policy configured
[ ] V14.4.5 - Permissions-Policy restricts browser features
[ ] V14.4.6 - Cross-Origin policies configured
[ ] X-Powered-By header removed
```

#### A06: Vulnerable Components

See Phase 1: Supply Chain Security

#### A07: Authentication Failures (ASVS V2, V3)

```typescript
// Secure session configuration
import session from 'express-session';
import RedisStore from 'connect-redis';
import { createClient } from 'redis';

const redisClient = createClient({ url: process.env.REDIS_URL });

app.use(session({
  store: new RedisStore({ client: redisClient }),
  secret: process.env.SESSION_SECRET,   // From secret manager
  name: '__Host-sessionId',             // Cookie prefix for security
  resave: false,
  saveUninitialized: false,
  rolling: true,                        // Reset expiry on activity
  cookie: {
    httpOnly: true,                     // No JS access
    secure: true,                       // HTTPS only
    sameSite: 'strict',                 // CSRF protection
    maxAge: 3600000,                    // 1 hour
    path: '/',
    domain: undefined                    // Current domain only
  }
}));

// Rate limiting with progressive delays
import rateLimit from 'express-rate-limit';
import slowDown from 'express-slow-down';

const loginSlowDown = slowDown({
  windowMs: 15 * 60 * 1000,  // 15 minutes
  delayAfter: 3,              // Allow 3 requests per window
  delayMs: (hits) => hits * 500,  // Progressive delay
  maxDelayMs: 10000           // Max 10 seconds delay
});

const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10,                    // 10 attempts per 15 min
  standardHeaders: true,
  legacyHeaders: false,
  handler: (req, res) => {
    res.status(429).json({
      error: 'Too many login attempts. Try again later.',
      retryAfter: 900
    });
  }
});

app.post('/api/v1/auth/login', loginSlowDown, loginLimiter, loginHandler);
```

**Checklist (ASVS V2, V3):**
```
[ ] V2.1.1 - Password minimum 12 characters
[ ] V2.1.2 - Password allows 64+ characters
[ ] V2.1.7 - Breach password check (HaveIBeenPwned)
[ ] V2.2.1 - Rate limiting on authentication
[ ] V2.2.2 - Account lockout with progressive delays
[ ] V2.5.1 - Password reset uses time-limited tokens
[ ] V2.8.1 - MFA available for sensitive accounts
[ ] V3.2.1 - Session regeneration on login
[ ] V3.3.1 - Session timeout configured
[ ] V3.4.1 - Cookie secure flags set
[ ] V3.5.1 - Session tokens sufficiently random
```

#### A08: Software and Data Integrity

```typescript
// Subresource Integrity for CDN resources
<script
  src="https://cdn.example.com/lib.js"
  integrity="sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC"
  crossorigin="anonymous"
></script>

// Deserialization - validate against schema
import Ajv from 'ajv';

const ajv = new Ajv({ allErrors: true });
const validate = ajv.compile(userSchema);

const processInput = (data: unknown) => {
  if (!validate(data)) {
    throw new ValidationError(validate.errors);
  }
  return data as UserInput;
};
```

**Checklist:**
```
[ ] CI/CD pipeline secured (branch protection, signed commits)
[ ] Subresource integrity for CDN resources
[ ] Deserialization validated against schema
[ ] Package integrity verified (checksums)
[ ] Build artifacts signed
```

#### A09: Security Logging and Monitoring

```typescript
// Structured security logging
import winston from 'winston';

const securityLogger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  defaultMeta: { service: 'security' },
  transports: [
    new winston.transports.File({ filename: 'security.log' })
  ]
});

const SecurityEvents = {
  AUTH_SUCCESS: (userId: string, ip: string) =>
    securityLogger.info('AUTH_SUCCESS', {
      event: 'authentication',
      status: 'success',
      userId,
      ip,
      userAgent: 'redacted'
    }),

  AUTH_FAILURE: (username: string, ip: string, reason: string) =>
    securityLogger.warn('AUTH_FAILURE', {
      event: 'authentication',
      status: 'failure',
      username: username.substring(0, 3) + '***',  // Partial for investigation
      ip,
      reason
    }),

  ACCESS_DENIED: (userId: string, resource: string, action: string) =>
    securityLogger.warn('ACCESS_DENIED', {
      event: 'authorization',
      status: 'denied',
      userId,
      resource,
      action
    }),

  SUSPICIOUS_ACTIVITY: (details: object) =>
    securityLogger.error('SUSPICIOUS_ACTIVITY', {
      event: 'threat',
      ...details,
      alertSent: true
    })
};
```

**Checklist:**
```
[ ] Login attempts logged (success and failure)
[ ] Access control failures logged
[ ] Input validation failures logged
[ ] Sensitive operations logged with actor
[ ] Logs don't contain passwords/tokens/PII
[ ] Log integrity protected (append-only)
[ ] Alerting configured for security events
[ ] Log retention policy defined
```

#### A10: Server-Side Request Forgery (SSRF)

```typescript
// SSRF Prevention - comprehensive URL validation
import { URL } from 'url';
import dns from 'dns';
import { promisify } from 'util';

const dnsLookup = promisify(dns.lookup);

const BLOCKED_IP_RANGES = [
  /^127\./,                    // Loopback
  /^10\./,                     // Private Class A
  /^172\.(1[6-9]|2[0-9]|3[0-1])\./, // Private Class B
  /^192\.168\./,               // Private Class C
  /^0\.0\.0\.0$/,              // Unspecified
  /^169\.254\./,               // Link-local
  /^100\.(6[4-9]|[7-9][0-9]|1[0-2][0-7])\./, // Carrier-grade NAT
  /^::1$/,                     // IPv6 loopback
  /^fe80:/i,                   // IPv6 link-local
  /^fc00:/i,                   // IPv6 unique local
  /^fd[0-9a-f]{2}:/i,         // IPv6 unique local
];

const ALLOWED_PROTOCOLS = ['https:'];
const ALLOWED_DOMAINS: string[] = [];  // Empty = all (use allowlist for sensitive)

async function validateUrl(urlString: string): Promise<URL> {
  const url = new URL(urlString);

  // 1. Protocol check
  if (!ALLOWED_PROTOCOLS.includes(url.protocol)) {
    throw new Error(`Protocol ${url.protocol} not allowed`);
  }

  // 2. Domain allowlist (if configured)
  if (ALLOWED_DOMAINS.length > 0 && !ALLOWED_DOMAINS.includes(url.hostname)) {
    throw new Error(`Domain ${url.hostname} not in allowlist`);
  }

  // 3. DNS resolution to check for internal IPs
  try {
    const { address } = await dnsLookup(url.hostname);
    if (BLOCKED_IP_RANGES.some(pattern => pattern.test(address))) {
      throw new Error('Internal IP addresses not allowed');
    }
  } catch (error) {
    if (error.message.includes('Internal IP')) throw error;
    throw new Error('Could not resolve hostname');
  }

  return url;
}

// Usage
app.post('/api/v1/fetch-url', async (req, res) => {
  try {
    const validatedUrl = await validateUrl(req.body.url);
    const response = await fetch(validatedUrl.toString(), {
      redirect: 'error',  // Don't follow redirects (could bypass validation)
      timeout: 5000
    });
    // Process response...
  } catch (error) {
    res.status(400).json({ error: 'Invalid URL' });
  }
});
```

**Checklist:**
```
[ ] URL validation for all external requests
[ ] Internal IP ranges blocked (including after DNS resolution)
[ ] Protocol restricted (HTTPS only)
[ ] Redirects handled carefully (re-validate destination)
[ ] Allowlist for permitted domains (when possible)
[ ] Response size limits
[ ] Timeout configured
```

### Phase 4: Additional Security Controls

#### CSRF Protection

```typescript
// Double-submit cookie pattern (for SPAs)
import csrf from 'csurf';

// Option 1: Traditional CSRF tokens
const csrfProtection = csrf({
  cookie: {
    httpOnly: true,
    secure: true,
    sameSite: 'strict'
  }
});

// Option 2: SameSite cookies (modern approach)
// If all clients are modern browsers, SameSite: strict provides CSRF protection

// Option 3: Custom header for APIs
const csrfHeaderProtection = (req, res, next) => {
  // Require custom header that browsers won't send cross-origin
  if (!req.headers['x-requested-with']) {
    return res.status(403).json({ error: 'CSRF validation failed' });
  }
  next();
};
```

#### XXE Prevention

```typescript
// XML External Entity (XXE) Prevention

// Node.js - libxmljs2 (secure by default)
import libxmljs from 'libxmljs2';
const doc = libxmljs.parseXml(xmlString, {
  noent: false,        // Don't expand entities
  nonet: true,         // Don't allow network access
  noblanks: true,
  nocdata: false,
  huge: false          // Reject huge documents
});

// Java example (for reference)
// DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
// factory.setFeature("http://apache.org/xml/features/disallow-doctype-decl", true);
// factory.setFeature("http://xml.org/sax/features/external-general-entities", false);

// Best practice: Use JSON instead of XML when possible
```

**XXE Checklist:**
```
[ ] XML parsing disabled external entities
[ ] DTD processing disabled
[ ] Network access disabled during parsing
[ ] Document size limits enforced
[ ] Consider using JSON instead of XML
```

#### XSS Prevention

```typescript
// Input sanitization with DOMPurify
import DOMPurify from 'isomorphic-dompurify';

const sanitize = (dirty: string): string => {
  return DOMPurify.sanitize(dirty, {
    ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'a', 'p', 'br'],
    ALLOWED_ATTR: ['href'],
    ALLOW_DATA_ATTR: false,
    USE_PROFILES: { html: true }
  });
};

// React: NEVER use dangerouslySetInnerHTML with user input
// Vue: NEVER use v-html with user input
// Use textContent, not innerHTML

// Output encoding
import he from 'he';
const encoded = he.encode(userInput);  // HTML entity encoding
```

---

## Security Tools Matrix

| Category | Tool | Purpose | Integration |
|----------|------|---------|-------------|
| **SAST** | Semgrep | Rule-based static analysis | CI/CD, IDE |
| | ESLint security plugins | JavaScript/TypeScript | CI/CD, IDE |
| | SonarQube | Multi-language SAST | CI/CD |
| | CodeQL | GitHub native | GitHub Actions |
| **DAST** | OWASP ZAP | Dynamic web scanning | CI/CD |
| | Burp Suite | Manual + automated | Manual testing |
| | Nuclei | Template-based scanning | CI/CD |
| **SCA** | npm audit | Node.js dependencies | Built-in |
| | Snyk | Multi-language, license | CI/CD, IDE |
| | Dependabot | Auto-update PRs | GitHub native |
| | OWASP Dependency-Check | Java, .NET, more | CI/CD |
| **Secrets** | gitleaks | Pre-commit, CI | CI/CD, pre-commit |
| | trufflehog | Cloud-aware detection | CI/CD |
| | detect-secrets | Baseline support | CI/CD |
| **Container** | Trivy | Images, IaC, SBOM | CI/CD |
| | Grype | Fast image scanning | CI/CD |
| | Clair | Kubernetes native | Kubernetes |
| **Headers** | securityheaders.com | Online check | Manual |
| | Mozilla Observatory | Comprehensive check | Manual |

### Tool Configuration Examples

```yaml
# .github/workflows/security.yml
name: Security Scan

on: [push, pull_request]

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      # Dependency scanning
      - name: npm audit
        run: npm audit --audit-level=high

      # SAST with Semgrep
      - name: Semgrep
        uses: returntocorp/semgrep-action@v1
        with:
          config: p/security-audit

      # Secrets detection
      - name: gitleaks
        uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      # Container scanning
      - name: Trivy
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: 'myapp:${{ github.sha }}'
          severity: 'CRITICAL,HIGH'
```

---

## Anti-patterns

| Anti-pattern | Risk | OWASP | Fix |
|--------------|------|-------|-----|
| `cors({ origin: '*' })` | CSRF, Data theft | A01 | Explicit allowlist |
| `eval(userInput)` | RCE | A03 | Remove or sandbox |
| `"SELECT * FROM x WHERE id=" + id` | SQL Injection | A03 | Parameterized queries |
| `console.log(password)` | Credential leak | A09 | Remove sensitive logging |
| `md5(password)` | Weak hash | A02 | argon2id or bcrypt |
| `innerHTML = userInput` | XSS | A03 | textContent or sanitize |
| `new Function(userInput)` | RCE | A03 | Remove |
| `JSON.parse(untrusted)` | Prototype pollution | A08 | Validate schema first |
| `child_process.exec(cmd)` | Command injection | A03 | execFile with array args |
| No rate limiting on login | Brute force | A07 | Rate limiter middleware |

---

## TAD Integration

### Gate Mapping

```yaml
Gate5_Security:
  skill: security-checklist.md
  enforcement: MANDATORY
  evidence_required:
    - dependency_scan: npm audit / snyk output
    - secrets_scan: gitleaks report
    - sast_report: Semgrep / CodeQL findings
    - security_headers: Header configuration
    - threat_model: For critical flows
  acceptance:
    - No critical/high vulnerabilities
    - No exposed secrets
    - All OWASP Top 10 addressed
    - Security headers configured
    - Threat model documented
  blocking: true  # Cannot proceed without passing
```

### Evidence Template

```markdown
## Security Audit Evidence

**Date:** [Date]
**Reviewer:** [Name]
**Commit:** [SHA]

### 1. Dependency Scan (SCA)

```bash
$ npm audit
found 0 vulnerabilities

$ snyk test
✓ Tested 245 dependencies for known vulnerabilities, no vulnerable paths found.
```

**SBOM:** `docs/security/sbom.json` (CycloneDX format)

### 2. Secrets Scan

```bash
$ gitleaks detect
No leaks found
```

**Pre-commit hook:** Installed ✓

### 3. SAST Results

```bash
$ semgrep --config=p/security-audit
Ran 150 rules on 89 files
0 findings
```

### 4. Security Headers

| Header | Value | Status |
|--------|-------|--------|
| Strict-Transport-Security | max-age=31536000; includeSubDomains; preload | ✓ |
| Content-Security-Policy | default-src 'self'; ... | ✓ |
| X-Content-Type-Options | nosniff | ✓ |
| X-Frame-Options | DENY | ✓ |
| Referrer-Policy | strict-origin-when-cross-origin | ✓ |
| Permissions-Policy | geolocation=(), camera=(), ... | ✓ |

**Mozilla Observatory Score:** A+

### 5. OWASP Top 10 Checklist

| # | Category | Status | Notes |
|---|----------|--------|-------|
| A01 | Broken Access Control | ✓ | RBAC + ownership checks |
| A02 | Cryptographic Failures | ✓ | argon2id for passwords |
| A03 | Injection | ✓ | Parameterized queries |
| A04 | Insecure Design | ✓ | Threat model complete |
| A05 | Security Misconfiguration | ✓ | Headers configured |
| A06 | Vulnerable Components | ✓ | No critical CVEs |
| A07 | Auth Failures | ✓ | Rate limiting, MFA |
| A08 | Data Integrity | ✓ | SRI, input validation |
| A09 | Logging | ✓ | Security events logged |
| A10 | SSRF | ✓ | URL validation |

### 6. Threat Model

**Critical Flows Analyzed:**
- User authentication
- Payment processing
- Admin operations

**Document:** `docs/security/threat-model.md`

### Sign-off

**Security Review Passed:** ✓
**Reviewer:** [Name]
**Date:** [Date]
```

---

## Related Skills

- `api-design.md` - API security patterns (OWASP API Top 10)
- `testing-strategy.md` - Security testing integration
- `verification.md` - Evidence-based verification
- `error-handling.md` - Secure error handling
- `performance-optimization.md` - DoS prevention

---

## References

- [OWASP Top 10 2021](https://owasp.org/Top10/)
- [OWASP ASVS 4.0.3](https://owasp.org/www-project-application-security-verification-standard/)
- [OWASP API Security Top 10](https://owasp.org/API-Security/)
- [CWE/SANS Top 25](https://cwe.mitre.org/top25/)
- [Mozilla Web Security Guidelines](https://infosec.mozilla.org/guidelines/web_security)
- [Node.js Security Best Practices](https://nodejs.org/en/docs/guides/security/)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)
- [CycloneDX SBOM Standard](https://cyclonedx.org/)

---

*This skill is MANDATORY and enforces comprehensive security checks before deployment. All Gate5 requirements must pass.*
