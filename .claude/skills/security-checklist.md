# Security Checklist Skill

---
title: "Security Checklist"
version: "2.0"
last_updated: "2026-01-06"
tags: [security, mandatory, gate5, owasp, asvs]
domains: [web, api, backend, frontend]
level: intermediate
estimated_time: "45min"
prerequisites: []
sources:
  - "OWASP Top 10 2021"
  - "OWASP ASVS 4.0"
  - "CWE/SANS Top 25"
enforcement: mandatory
---

## TL;DR Quick Checklist

```
1. [ ] Run `npm audit` / dependency scan - no critical/high vulnerabilities
2. [ ] All user inputs validated and sanitized
3. [ ] Authentication uses secure hashing (bcrypt/argon2) + rate limiting
4. [ ] Authorization checks on every API endpoint
5. [ ] No secrets in code/logs, all sensitive data encrypted
```

**Red Flags:**
- Hardcoded API keys or passwords
- SQL/NoSQL queries with string concatenation
- `eval()`, `Function()`, or dynamic code execution
- `innerHTML` with user input without sanitization
- CORS with `origin: '*'`

---

## Overview

This skill enforces comprehensive security checks across the entire application lifecycle. It maps to OWASP Top 10 (2021) and ASVS 4.0 requirements.

**Core Principle:** "Security is not a feature, it's a constraint. Code that violates security constraints is buggy, not 'working but risky'."

---

## Triggers

| Trigger | Context | Action |
|---------|---------|--------|
| Gate5 | Pre-deployment security gate | Full security audit |
| `*deploy` command | Blake deploying | Deployment security checklist |
| `*review` command | Alex reviewing implementation | Security review focus |
| Code touching auth/input/data | Any development | Inline security checks |

---

## Inputs

- Source code to be reviewed
- API endpoint definitions
- Database schema and queries
- Third-party dependencies list
- Infrastructure configuration

---

## Outputs / Evidence / Acceptance

### Required Evidence

| Evidence Type | Description | Location |
|---------------|-------------|----------|
| `security_audit` | Scan results and manual review | `.tad/evidence/security/` |
| `dependency_scan` | npm audit / pip-audit output | `.tad/evidence/security/deps-scan.txt` |
| `sast_report` | Static analysis results | `.tad/evidence/security/sast-report.json` |
| `secrets_scan` | No secrets in codebase | `.tad/evidence/security/secrets-scan.txt` |

### Acceptance Criteria

```
[ ] No critical or high vulnerabilities in dependencies
[ ] All OWASP Top 10 items addressed
[ ] No secrets in codebase (verified by scan)
[ ] Security headers configured correctly
[ ] Input validation on all user-facing endpoints
[ ] Authentication/Authorization properly implemented
```

---

## Procedure

### Phase 1: Dependency Security (Supply Chain)

```bash
# Node.js
npm audit --audit-level=high
npx better-npm-audit audit

# Python
pip-audit
safety check

# Go
govulncheck ./...

# Generate SBOM
npx @cyclonedx/cdxgen -o sbom.json
```

**Checklist:**
```
[ ] npm audit shows no critical/high vulnerabilities
[ ] Dependabot/Renovate configured for auto-updates
[ ] SBOM generated and stored
[ ] Unused dependencies removed
```

### Phase 2: Secrets Detection

```bash
# Using gitleaks
gitleaks detect --source . --verbose

# Using trufflehog
trufflehog filesystem . --only-verified

# Using detect-secrets
detect-secrets scan --all-files
```

**Checklist:**
```
[ ] No API keys in source code
[ ] No passwords in configuration files
[ ] No private keys committed
[ ] .env files in .gitignore
[ ] Secrets managed via environment or vault
```

### Phase 3: OWASP Top 10 (2021) Audit

#### A01: Broken Access Control

```javascript
// Access control checklist implementation

// 1. Server-side authorization (not just frontend)
app.get('/admin/users',
  authenticate,           // Verify identity
  authorize('admin'),     // Check role
  validateOwnership,      // Check resource ownership
  async (req, res) => { /*...*/ }
);

// 2. Deny by default
const permissions = {
  default: [],           // No permissions by default
  user: ['read:own'],
  admin: ['read:all', 'write:all']
};

// 3. CORS configuration
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || [],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
```

**Checklist:**
```
[ ] All endpoints require authentication (unless public)
[ ] Role-based access control implemented
[ ] Resource ownership validated
[ ] CORS properly configured (no wildcards in production)
[ ] Directory traversal prevented
[ ] IDOR vulnerabilities addressed
```

#### A02: Cryptographic Failures

```javascript
// Secure password hashing
import bcrypt from 'bcrypt';
import argon2 from 'argon2';

// bcrypt (minimum 12 rounds)
const hash = await bcrypt.hash(password, 12);

// argon2 (preferred)
const hash = await argon2.hash(password, {
  type: argon2.argon2id,
  memoryCost: 65536,
  timeCost: 3,
  parallelism: 4
});

// Data encryption at rest
import crypto from 'crypto';

const algorithm = 'aes-256-gcm';
const key = crypto.scryptSync(process.env.ENCRYPTION_KEY, 'salt', 32);

function encrypt(text) {
  const iv = crypto.randomBytes(16);
  const cipher = crypto.createCipheriv(algorithm, key, iv);
  // ...
}
```

**Checklist:**
```
[ ] Passwords hashed with bcrypt (12+) or argon2
[ ] Sensitive data encrypted at rest (AES-256)
[ ] TLS 1.2+ for all connections
[ ] No deprecated algorithms (MD5, SHA1, DES)
[ ] Keys rotated periodically
```

#### A03: Injection

```javascript
// SQL Injection Prevention
// Using parameterized queries
const query = 'SELECT * FROM users WHERE id = $1';
await db.query(query, [userId]);  // SAFE

// Using ORM with proper escaping
await User.findOne({ where: { id: userId } });  // SAFE

// Command Injection Prevention
import { execFile } from 'child_process';
execFile('ls', ['-la', sanitizedPath]);  // SAFE (no shell)

// NoSQL Injection Prevention
// Validate and sanitize MongoDB queries
const sanitizedQuery = {
  username: { $eq: String(userInput) }  // Explicit operator
};
```

**Checklist:**
```
[ ] All SQL uses parameterized queries or ORM
[ ] No string concatenation in queries
[ ] Command execution uses execFile (not exec)
[ ] NoSQL queries use explicit operators
[ ] LDAP queries properly escaped
```

#### A04: Insecure Design

```
[ ] Threat modeling completed for critical flows
[ ] Rate limiting on sensitive operations
[ ] Account lockout after failed attempts
[ ] Secure password reset flow
[ ] No security-sensitive data in URLs
```

#### A05: Security Misconfiguration

```javascript
// Security headers with Helmet
import helmet from 'helmet';

app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      imgSrc: ["'self'", "data:", "https:"],
      connectSrc: ["'self'"],
      fontSrc: ["'self'"],
      objectSrc: ["'none'"],
      frameAncestors: ["'none'"],
      upgradeInsecureRequests: []
    }
  },
  hsts: {
    maxAge: 31536000,
    includeSubDomains: true,
    preload: true
  },
  referrerPolicy: { policy: 'strict-origin-when-cross-origin' },
  permissionsPolicy: {
    features: {
      geolocation: [],
      microphone: [],
      camera: []
    }
  }
}));
```

**Checklist:**
```
[ ] Debug mode disabled in production
[ ] Default credentials changed
[ ] Unnecessary features disabled
[ ] Error messages don't leak internal details
[ ] Security headers configured (CSP, HSTS, etc.)
[ ] Permissions-Policy restricts browser features
```

#### A06: Vulnerable Components

See Phase 1: Dependency Security

#### A07: Authentication Failures

```javascript
// Secure session configuration
app.use(session({
  secret: process.env.SESSION_SECRET,
  name: 'sessionId',  // Don't use default name
  resave: false,
  saveUninitialized: false,
  cookie: {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'strict',
    maxAge: 3600000  // 1 hour
  }
}));

// Rate limiting for login
import rateLimit from 'express-rate-limit';

const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,  // 15 minutes
  max: 5,  // 5 attempts
  message: 'Too many login attempts'
});

app.post('/login', loginLimiter, loginHandler);
```

**Checklist:**
```
[ ] Password policy enforced (length, complexity)
[ ] Rate limiting on login endpoint
[ ] Account lockout implemented
[ ] Session timeout configured
[ ] Secure cookie flags set
[ ] MFA available for sensitive accounts
```

#### A08: Software and Data Integrity

```
[ ] CI/CD pipeline secured
[ ] Code signing implemented
[ ] Subresource integrity for CDN resources
[ ] Deserialization validated against schema
```

#### A09: Security Logging and Monitoring

```javascript
// Security event logging
const securityLogger = {
  authSuccess: (userId, ip) =>
    logger.info('AUTH_SUCCESS', { userId, ip, timestamp: new Date() }),

  authFailure: (username, ip, reason) =>
    logger.warn('AUTH_FAILURE', { username, ip, reason, timestamp: new Date() }),

  accessDenied: (userId, resource, ip) =>
    logger.warn('ACCESS_DENIED', { userId, resource, ip, timestamp: new Date() }),

  suspiciousActivity: (details) =>
    logger.error('SUSPICIOUS_ACTIVITY', { ...details, timestamp: new Date() })
};
```

**Checklist:**
```
[ ] Login attempts logged (success/failure)
[ ] Access control failures logged
[ ] Input validation failures logged
[ ] Sensitive operations logged with actor
[ ] Logs don't contain sensitive data
[ ] Alerting configured for security events
```

#### A10: Server-Side Request Forgery (SSRF)

```javascript
// SSRF Prevention
import { URL } from 'url';

function validateUrl(urlString) {
  const url = new URL(urlString);

  // Block internal IPs
  const blockedPatterns = [
    /^localhost$/i,
    /^127\./,
    /^10\./,
    /^172\.(1[6-9]|2[0-9]|3[0-1])\./,
    /^192\.168\./,
    /^0\.0\.0\.0$/,
    /^169\.254\./,  // Link-local
    /^::1$/,
    /^fc00:/i,
    /^fe80:/i
  ];

  if (blockedPatterns.some(p => p.test(url.hostname))) {
    throw new Error('Internal URLs not allowed');
  }

  // Only allow HTTPS
  if (url.protocol !== 'https:') {
    throw new Error('Only HTTPS URLs allowed');
  }

  return url;
}
```

**Checklist:**
```
[ ] URL validation for external requests
[ ] Internal IP ranges blocked
[ ] Protocol restricted (HTTPS only)
[ ] Allowlist for permitted domains (if applicable)
```

### Phase 4: Additional Checks

#### CSRF Protection

```javascript
// CSRF Token implementation
import csrf from 'csurf';

const csrfProtection = csrf({ cookie: true });

app.get('/form', csrfProtection, (req, res) => {
  res.render('form', { csrfToken: req.csrfToken() });
});

app.post('/submit', csrfProtection, (req, res) => {
  // Token validated automatically
});
```

#### XSS Prevention

```javascript
// Input sanitization
import DOMPurify from 'dompurify';
import { JSDOM } from 'jsdom';

const window = new JSDOM('').window;
const purify = DOMPurify(window);

const clean = purify.sanitize(userInput);

// React: avoid dangerouslySetInnerHTML
// Vue: avoid v-html
// Use textContent instead of innerHTML
```

---

## Security Tools Matrix

| Category | Tool | Purpose |
|----------|------|---------|
| SAST | ESLint security plugins, Semgrep, SonarQube | Static code analysis |
| DAST | OWASP ZAP, Burp Suite | Dynamic testing |
| Dependency | npm audit, Snyk, Dependabot | Vulnerability scanning |
| Secrets | gitleaks, trufflehog, detect-secrets | Secret detection |
| Container | Trivy, Clair, Grype | Image scanning |
| Headers | securityheaders.com, Mozilla Observatory | Header analysis |

---

## Anti-patterns

| Anti-pattern | Why Bad | Fix |
|--------------|---------|-----|
| `cors({ origin: '*' })` | Allows any origin | Whitelist specific origins |
| `eval(userInput)` | Code injection | Remove or sanitize |
| `query = "SELECT * FROM x WHERE id=" + id` | SQL injection | Use parameterized queries |
| `console.log(password)` | Credential exposure | Remove sensitive logging |
| `md5(password)` | Weak hashing | Use bcrypt/argon2 |

---

## TAD Integration

### Gate Mapping

```yaml
Gate5_Security:
  skill: security-checklist.md
  enforcement: MANDATORY
  evidence_required:
    - dependency_scan
    - secrets_scan
    - security_audit
  acceptance:
    - No critical vulnerabilities
    - All OWASP items addressed
    - Security headers configured
```

### Evidence Template

```markdown
## Security Audit Evidence

### Dependency Scan
\`\`\`
$ npm audit
found 0 vulnerabilities
\`\`\`

### Secrets Scan
\`\`\`
$ gitleaks detect
No secrets found
\`\`\`

### Security Headers
- CSP: Configured
- HSTS: Enabled (1 year)
- X-Frame-Options: DENY
- X-Content-Type-Options: nosniff

### OWASP Checklist
- [x] A01: Access Control - Implemented
- [x] A02: Cryptographic - Secure hashing
- [x] A03: Injection - Parameterized queries
...

### Reviewer Sign-off
Reviewed by: [Name]
Date: [Date]
```

---

## Related Skills

- `testing-strategy.md` - Security testing integration
- `api-design.md` - API security patterns
- `verification.md` - Evidence-based verification
- `error-handling.md` - Secure error handling

---

## References

- [OWASP Top 10 2021](https://owasp.org/Top10/)
- [OWASP ASVS 4.0](https://owasp.org/www-project-application-security-verification-standard/)
- [CWE/SANS Top 25](https://cwe.mitre.org/top25/)
- [Mozilla Web Security Guidelines](https://infosec.mozilla.org/guidelines/web_security)
- [Node.js Security Best Practices](https://nodejs.org/en/docs/guides/security/)

---

*This skill is MANDATORY and enforces comprehensive security checks before deployment.*
