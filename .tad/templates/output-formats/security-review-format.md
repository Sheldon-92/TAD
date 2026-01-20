# Security Review Output Format

> Extracted from security-checklist skill - use this for security audits

## Quick Checklist

```
1. [ ] npm audit / dependency scan - no critical/high vulnerabilities
2. [ ] gitleaks / secrets scan - no exposed credentials
3. [ ] All user inputs validated + sanitized (XSS, SQLi, XXE)
4. [ ] Auth: bcrypt/argon2 + rate limiting + session secure flags
5. [ ] HTTPS + Security headers (CSP, HSTS, Permissions-Policy)
```

## Red Flags (Instant Rejection)

- Hardcoded API keys, passwords, or private keys
- SQL/NoSQL queries with string concatenation
- `eval()`, `Function()`, `new Function()`, dynamic code execution
- `innerHTML`, `v-html`, `dangerouslySetInnerHTML` with user input
- CORS with `origin: '*'` in production
- XML parsing without disabling external entities (XXE)
- Missing CSRF protection on state-changing operations

## Output Format

### Security Audit Report

| Category | Check | Status | Finding |
|----------|-------|--------|---------|
| Dependencies | npm audit | Pass/Fail | [details] |
| Secrets | gitleaks scan | Pass/Fail | [details] |
| Input Validation | XSS prevention | Pass/Fail | [details] |
| Input Validation | SQL injection | Pass/Fail | [details] |
| Authentication | Password hashing | Pass/Fail | [details] |
| Authentication | Rate limiting | Pass/Fail | [details] |
| Transport | HTTPS enforced | Pass/Fail | [details] |
| Headers | CSP configured | Pass/Fail | [details] |

### Vulnerability Summary

| Severity | Count | Details |
|----------|-------|---------|
| Critical | 0 | - |
| High | 0 | - |
| Medium | 0 | - |
| Low | 0 | - |

### Recommendations

1. [High Priority] ...
2. [Medium Priority] ...
3. [Low Priority] ...
