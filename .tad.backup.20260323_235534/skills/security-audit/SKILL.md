---
name: "Security Audit"
id: "security-audit"
version: "1.0"
claude_subagent: "security-auditor"
fallback: "self-check"
min_tad_version: "2.1"
platforms: ["claude", "codex", "gemini"]
conditional: true
trigger_pattern: "auth|token|password|credential|api.*key|encrypt|decrypt|session|cookie|sql|query|upload|file|exec|eval"
---

# Security Audit Skill

## Purpose
Analyze code for security vulnerabilities, potential attack vectors, and compliance with security best practices.

## When to Use
- When code contains security-sensitive patterns
- During Gate 3 (implementation quality)
- During Gate 4 (integration verification)
- For authentication/authorization changes
- For data handling logic

## Trigger Patterns
This skill is conditionally triggered when code matches:
```regex
auth|token|password|credential|api.*key|encrypt|decrypt|session|cookie|sql|query|upload|file|exec|eval
```

## Checklist

### P0 - Blocking (Must Pass)
- [ ] No SQL injection vulnerabilities
- [ ] No command injection vulnerabilities
- [ ] No XSS (Cross-Site Scripting) vulnerabilities
- [ ] No hardcoded secrets or credentials
- [ ] No authentication bypass risks
- [ ] No sensitive data exposure in logs/errors

### P1 - Critical (Must Pass)
- [ ] Proper input validation on all user inputs
- [ ] Secure session management
- [ ] Correct authorization checks
- [ ] Safe file upload handling
- [ ] Secure API key/token handling

### P2 - Warning (Should Address)
- [ ] Security headers configured
- [ ] HTTPS enforced where applicable
- [ ] Rate limiting implemented
- [ ] Audit logging for sensitive operations
- [ ] Dependencies have no known CVEs

### P3 - Informational (Nice-to-have)
- [ ] Security documentation updated
- [ ] Threat model considerations
- [ ] Penetration testing recommendations
- [ ] Future security improvements

## Pass Criteria
| Severity | Requirement |
|----------|-------------|
| P0 | Zero issues allowed - blocks release |
| P1 | Zero issues allowed - must fix before merge |
| P2 | Max 5 with remediation plan |
| P3 | Optional improvements, document only |

## Evidence Output
Path: `.tad/evidence/reviews/{date}-security-audit-{task}.md`

## Execution Contract
- **Input**: file_paths[], context{}, patterns_found[]
- **Output**: {passed: bool, vulnerabilities: [{severity, category, file, line, description, remediation}], evidence_path: string}
- **Timeout**: 240s
- **Parallelizable**: true

## Claude Enhancement
When running on Claude Code, call subagent `security-auditor` for deeper analysis.
Reference: `.tad/templates/output-formats/security-review-format.md`

## Vulnerability Categories
1. Injection (SQL, Command, XSS)
2. Authentication/Authorization
3. Data Exposure
4. Cryptographic Issues
5. Security Misconfiguration
6. Input Validation

## OWASP Top 10 Coverage
- [ ] A01: Broken Access Control
- [ ] A02: Cryptographic Failures
- [ ] A03: Injection
- [ ] A04: Insecure Design
- [ ] A05: Security Misconfiguration
- [ ] A06: Vulnerable Components
- [ ] A07: Authentication Failures
- [ ] A08: Data Integrity Failures
- [ ] A09: Logging Failures
- [ ] A10: SSRF
