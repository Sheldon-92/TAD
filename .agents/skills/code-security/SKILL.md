---
name: code-security
description: Code security capability pack. Gives AI agents the judgment rules for SAST scanning (Semgrep), DAST testing (Nuclei), secret detection (Gitleaks/TruffleHog), IaC security linting (Checkov), and vulnerability triage (osv-scanner/Grype/Snyk). Research-grounded rules from tool documentation, OWASP guidelines, and real-world pipeline architecture. Use for any application security scanning, secret leak prevention, infrastructure hardening, or vulnerability prioritization task.
keywords: ["安全", "security", "SAST", "DAST", "密钥", "secret", "漏洞", "vulnerability", "semgrep", "nuclei", "gitleaks", "checkov", "trivy", "代码安全", "静态分析", "动态测试", "密钥检测", "基础设施安全"]
type: reference-based
---

**CONSUMES**: User code/repo + scan target URL (DAST) + IaC files + optional existing scan reports
**PRODUCES**: Applied security judgment rules + SARIF scan output + prioritized triage plan (P0-P3) + remediation actions + CI/CD gate configs

# Code Security Capability Pack

**Version**: 0.1.0
**Compatibility**: Claude Code (Phase 1); Codex / Cursor / Gemini in Phase 3
**License**: Apache 2.0

---

## What This Pack Does

AI agents set up security scanning by installing one tool and running it with default settings. They dump raw scanner output to the developer and call it done. They run SAST without DAST, missing runtime vulnerabilities entirely. They treat every CRITICAL CVSS as equally urgent, ignoring reachability and exploit probability. They detect secrets but clean up code before rotating the credential — leaving the attacker with a working key.

This pack embeds the judgment rules that application security engineers apply automatically — rules from Semgrep, Nuclei, Gitleaks, TruffleHog, Checkov, and vulnerability triage practices grounded in OWASP and real-world pipeline architecture.

**Pack = security judgment. Your workflow system = process constraints. No overlap.**

---

## Quick Capability Index

The full rule surface before you route. Each reference carries its own per-rule Quick Rule Index; this is the map across all five capabilities.

| Capability | Rule-ID prefix | Reference | What it decides |
|------------|----------------|-----------|-----------------|
| SAST scanning | **S** (S1-S8) | `references/sast-rules.md` | Semgrep tool/ruleset/diff-aware/taint(interfile)/SARIF/exit-code |
| DAST scanning | **D** (D1-D7) | `references/dast-rules.md` | Nuclei v3 tool select/prod-safety/severity/rate-limit precedence/templates/correlation |
| Secret detection | **SE** (SE1-SE…) | `references/secret-detection-rules.md` | Gitleaks/TruffleHog, rotate-before-cleanup, exit 183 |
| IaC security | **I** (I1-I…) | `references/iac-security-rules.md` | Checkov/TFLint/Trivy, policy-as-code, drift |
| Vulnerability triage | **V** (V1-V7) | `references/vulnerability-triage-rules.md` | CVSS+EPSS+KEV+reachability, SSVC/BOD 26-04 deadlines, dedup, owner+deadline |

**Validation scripts** (`scripts/`, deterministic — never punt to Claude):
- `scripts/triage-prioritize.sh` — ingests CVSS+EPSS+KEV+reachability per finding, emits P0-P3 + BOD 26-04 remediation deadline.
- `scripts/verify-pipeline-gates.sh` — asserts a CI config orders scans fastest-fail-first and honors the exit-code contract (Semgrep 1, TruffleHog 183, Checkov 1, Gitleaks 1).

---

## Cross-Cutting Rule: Four-Gate Pipeline (Fastest-Fail-First)

> **Security scans MUST be ordered by speed: pre-commit (<10s) before PR gates (~10s-1min) before full CI (minutes) before runtime (DAST sweeps).** Slow scans that block fast feedback loops cause developers to bypass security entirely. The fastest check that can catch a class of bug MUST run first.

| Gate | Time Budget | Tools | Catches |
|------|-------------|-------|---------|
| Pre-commit hooks | <10s | Gitleaks, TFLint, Trivy (fs) | Secrets, IaC syntax, known CVEs |
| PR gates (diff-aware) | ~10s-1min | Semgrep, Checkov, KICS | Code vulns (new only), IaC misconfig |
| Full CI/CD | minutes | CodeQL (deep), Snyk SCA, container scanners | Deep semantic bugs, full dependency tree |
| Runtime | async | Nuclei (DAST), Prowler (cloud posture) | Deployed misconfigs, exploitable endpoints |

This rule applies to every capability below. Placing a 5-minute full scan in pre-commit is a violation.

---

## Cross-Cutting Rule: Detection is NOT Remediation

> **Scanning without a fix workflow is security theater.** 72% of organizations use >10 AppSec tools but still fail to remediate critical findings because scanners produce alerts, not actions. Every scan output from this pack MUST feed into a triage plan with owner + deadline. Raw scanner dumps sent to developers without prioritization are a violation.

This rule applies to: SAST reports, DAST findings, secret detection alerts, IaC lint results, and vulnerability triage outputs. It is surfaced here because burying it in one reference file causes agents to miss it.

---

## Step 0: Context Detection

When the user mentions security scanning work, detect the context and load the right reference:

| User Signal | Reference to Load |
|-------------|-------------------|
| "SAST", "static analysis", "semgrep", "code scan", "静态分析", "代码扫描" | `references/sast-rules.md` |
| "DAST", "dynamic test", "nuclei", "penetration", "动态测试", "渗透" | `references/dast-rules.md` |
| "secret", "leaked key", "gitleaks", "trufflehog", "密钥", "泄露" | `references/secret-detection-rules.md` |
| "IaC", "terraform", "checkov", "dockerfile", "kubernetes security", "基础设施" | `references/iac-security-rules.md` |
| "vulnerability", "triage", "CVE", "CVSS", "prioritize findings", "漏洞", "分诊" | `references/vulnerability-triage-rules.md` |
| "full security scan", "complete audit", "security review", "安全审计" | Load **all references** sequentially |

---

## Step 1: Apply Rules

After loading the relevant reference file(s):

1. **Read the reference completely** — do not skim
2. **Apply each rule as a judgment check** against the user's security setup, config, or request
3. **For each violated rule**: state the violation clearly, then give the specific fix with exact CLI command
4. **Enforce the Four-Gate Pipeline cross-cutting rule** on every CI/CD configuration
5. **Enforce Detection != Remediation** — every scan output must connect to a triage/fix plan
6. **Check exit codes** — they determine pipeline pass/fail behavior:
   - Semgrep: exit 1 = blocking findings, exit 0 = clean
   - TruffleHog: exit 183 = verified leaked credentials, exit 1 = scanner error, exit 0 = clean
   - Checkov: exit 1 = failed checks, exit 0 = all passed
   - Gitleaks: exit 1 = leaks found, exit 0 = clean

Output format per finding:
```
[P0] Rule S3 (sast): Semgrep running without diff-aware mode on PRs — scanning entire repo on every PR.
-> Set SEMGREP_BASELINE_REF=main to scan only changed files. Reduces PR scan from 3min to ~10s.

[P1] Rule D2 (dast): Nuclei running against production URL without rate limiting.
-> Add -rl 50 flag and switch target to staging URL. Active DAST against production causes service disruption.
```

---

## Step 2: Output

Produce a structured security review:

```
## Security Review: [area reviewed]

### P0 — Blocking (must fix before merge/deploy)
- [finding + specific CLI fix]

### P1 — Required (fix this sprint)
- [finding + specific CLI fix]

### P2 — Advisory (improves security posture)
- [finding + specific CLI fix]

### Pipeline Gate Audit
[table: which gate each scan runs at, time budget compliance]

### Tool Recommendation
[semgrep / nuclei / gitleaks / checkov / osv-scanner based on user context]
```

---

## Anti-Skip Table

| Excuse | Counter |
|--------|---------|
| "We only need SAST" | SAST cannot detect runtime issues (broken access control, misconfigs). SAST+DAST together catch what each misses alone. At minimum add Nuclei CVE templates. |
| "We'll add secret scanning later" | Every day without pre-commit hooks is another day a secret can be committed. Gitleaks pre-commit takes 5 minutes to set up and <5s per commit. |
| "CVSS Critical = fix first" | CVSS measures theoretical severity, not actual risk. A CRITICAL in dead code is less urgent than a HIGH in a reachable endpoint. Add reachability analysis. |
| "We scan everything already" | 72% of orgs use >10 tools but still fail to remediate. Are your findings triaged with owners and deadlines, or just dumped as alerts? Detection without remediation is security theater. |
| "Alert fatigue — too many findings" | 30-50% of triage time is wasted on false positives. Use baseline mode (Semgrep --baseline-commit, Gitleaks --baseline-path) to see only NEW findings. |
| "IaC security is ops, not dev" | IaC misconfigs are cheaper to fix at code-write time. Same pipeline stage as code lint. Checkov runs in <30s. |

---

## Tool Quick Reference

| Tool | Install | Primary Use (current version) | Exit Code (fail) |
|------|---------|-------------|-------------------|
| semgrep | `pip install semgrep` or `brew install semgrep` | Multi-language SAST; v1.163.0 (2026-05-27) `--pro` interfile taint | 1 |
| nuclei | `go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest` | Template-based DAST; v3.8.0 (2026-04-18), default `-rate-limit 150` | 1 |
| gitleaks | `brew install gitleaks` | Fast secret detection, pre-commit | 1 |
| trufflehog | `brew install trufflehog` | Deep secret detection with verification | 183 |
| checkov | `pip install checkov` | IaC security lint, 1000+ policies | 1 |
| osv-scanner | `go install github.com/google/osv-scanner/v2/cmd/osv-scanner@latest` | OSS vuln DB (Google); v2 adds container + transitive (v2.3.5) | 1 |
| grype | `brew install grype` | Container/SBOM vulnerability scan | 1 |
| trivy | `brew install trivy` | All-in-one: fs, container, IaC, SBOM | 1 |
