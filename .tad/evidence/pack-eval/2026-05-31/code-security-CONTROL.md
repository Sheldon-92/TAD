# Security Pipeline Review

**Date:** 2026-05-31
**Scope:** Review of an existing security scanning pipeline.
**Stated current setup:**
- Semgrep (SAST) + Nuclei (DAST/vuln templates) run in the pipeline.
- All CRITICAL CVSS findings dumped to the dev channel.
- Findings fixed top-down by severity.
- Request: add secret scanning, and review the overall pipeline.

---

## 1. Executive Summary

The pipeline has a reasonable tool foundation (a SAST engine + a DAST/template engine), but the **operating model around those tools is where the real risk lives**. The three biggest problems are not about which scanner you run — they are:

1. **"Dump all CRITICAL to a channel" is alert noise, not a workflow.** It has no ownership, no deduplication, no SLA, no triage, and no suppression of false positives. It will be ignored within weeks (alert fatigue), which means real CRITICALs get missed.
2. **"Fix top-down by severity" (CVSS-only) is the wrong prioritization model.** CVSS base score ignores reachability, exploitability, exposure (internet-facing vs internal), and whether a fix even exists. You will burn effort on a CVSS 9.8 in a dev-only dependency while a CVSS 7.5 on your public login endpoint waits.
3. **There are no gates.** If scanners only *report* and never *block*, security is advisory. New CRITICALs can merge to main and ship to production.

Adding secret scanning is correct and important — but secret scanning has a critical design subtlety (it must scan **git history**, not just the current tree, and leaked secrets must be **rotated**, not just removed) that teams routinely get wrong.

Overall maturity grade: **Tools present, process immature.** Below are the specific gaps and concrete fixes.

---

## 2. What's Wrong (Detailed)

### 2.1 Findings routing: "dump all CRITICAL to dev channel"

**Problems:**
- **No deduplication.** The same finding re-posts on every pipeline run → channel becomes noise → people mute it.
- **No ownership / assignment.** A message in a channel is nobody's job. Findings need to become tracked, assigned work items.
- **No SLA / time-to-remediate.** "We post it" is not "we fix it." Without a clock, CRITICALs linger indefinitely.
- **Severity-only filter hides the real risk distribution.** Filtering to CRITICAL-only means you never see the HIGH-severity-but-reachable-and-internet-facing issues, which are often worse in practice than an unreachable CRITICAL.
- **No false-positive handling.** SAST and template scanners produce false positives. With no triage/suppression path, the channel fills with noise and the signal dies.
- **No status lifecycle.** Open → triaged → in-progress → fixed → verified-fixed. A channel dump has none of this.

### 2.2 Prioritization: "top-down by severity" (CVSS only)

CVSS base score is a **starting point, not a priority**. It deliberately omits:
- **Reachability** — is the vulnerable code path actually invoked? An unreachable CVSS 9.8 dependency is near-zero practical risk.
- **Exploitability in the wild** — is there a known exploit? (This is what EPSS and CISA KEV measure.) A CVSS 7.5 that is in CISA KEV (actively exploited) outranks a theoretical CVSS 9.8.
- **Exposure** — internet-facing vs internal-only vs build-time-only.
- **Environment / blast radius** — does it touch auth, payments, PII, or a throwaway dev tool?
- **Fix availability** — is there a patched version? An unfixable CRITICAL is a risk-acceptance decision, not a "fix" task.

**Better model:** prioritize by a composite of `CVSS × EPSS (exploit probability) × KEV flag × reachability × exposure`. Practically: **KEV + reachable + internet-facing** is your top bucket, regardless of raw CVSS.

### 2.3 No gating / enforcement

- If scanners run but never fail the build, they are advisory. Determine: **do they block merges/deploys, or just report?** If they only report, drift is inevitable.
- **Risk of the opposite failure:** turning on hard-blocking globally on day one — especially on an existing codebase full of pre-existing findings — will block every PR and the team will disable the gate. The fix is a **diff-aware / baseline** approach (block only *new* findings introduced by the PR; track existing findings as backlog).

### 2.4 Tool coverage gaps

The current stack (Semgrep + Nuclei) covers SAST + DAST/templates but is missing several standard layers:

- **SCA (Software Composition Analysis) / dependency CVEs.** Semgrep is code-pattern SAST; Nuclei is template/DAST. Neither robustly covers "which of my third-party dependencies have known CVEs." This is the single most common source of real-world CRITICALs. **Missing entirely.** Add an SCA scanner.
- **Secret scanning.** Being added (good) — see §3.
- **IaC / container misconfiguration.** If you deploy with Terraform / Kubernetes / Docker, misconfig scanning is a major gap (public S3 buckets, `0.0.0.0/0` security groups, root containers, etc.).
- **Nuclei DAST requires a running, representative target.** Confirm Nuclei is pointed at a deployed staging/preview environment with realistic data — not localhost with empty state, which finds nothing. Also confirm you have **authorization** to scan the target (DAST against shared/prod infra without sign-off is a problem).

### 2.5 Pipeline hygiene gaps

- **Scanner versions / rulesets not pinned or updated on a schedule** → either stale detection (missing new rules) or surprise breakage.
- **No measurement.** No metrics on time-to-remediate, false-positive rate, finding volume trend, or scan coverage. You can't improve what you don't measure.
- **No "scan ran successfully" verification.** A scanner that silently errors out (bad config, auth failure, network) reports zero findings — which looks identical to "clean." Treat a failed/empty scan as a pipeline failure, not a pass.

---

## 3. Setting Up Secret Scanning (Do It Right)

Secret scanning is the highest-leverage addition here, but the naive setup misses the two things that matter most.

### 3.1 Critical design rules

1. **Scan full git history, not just the working tree.** A secret committed last year and "deleted" in a later commit is still in history and still compromised. Run a one-time **full-history scan** of every repo now, then **per-commit/per-PR incremental scans** going forward.
2. **A leaked secret must be ROTATED, not just removed.** Deleting the line or rewriting history does **not** un-leak it — assume it's compromised the moment it hit a remote. The remediation is: **rotate/revoke the credential first**, then clean it from history. Make this explicit in the runbook.
3. **Block the leak at the source.** Add a **pre-commit hook** (client-side) so secrets are caught *before* they ever reach the remote. Pre-commit is prevention; CI scanning is the safety net. Use both.
4. **Enable push protection** if your git host supports it (GitHub/GitLab native secret push protection) — this rejects pushes containing detected secrets at the server, even if the local hook was bypassed.

### 3.2 Recommended approach

- **Tool:** Gitleaks (fast, easy CI integration, good default ruleset) and/or TruffleHog (notable for **live-credential verification** — it can validate whether a found secret is actually still active, which slashes false positives). A common combo: Gitleaks for breadth/speed in CI, TruffleHog when you want verification.
- **Three integration points:**
  1. **Pre-commit hook** (developer machines) — prevent.
  2. **CI on every PR** (incremental, diff-scoped) — catch.
  3. **Scheduled full-history scan** (e.g., nightly/weekly) — backstop against bypasses and history.
- **Baseline existing findings.** Run the full-history scan once, triage results, rotate anything real, and record a baseline so the per-PR scan only flags *new* secrets (otherwise every PR fails on legacy findings and the team disables it).
- **False-positive management.** Maintain an allowlist (e.g., `.gitleaks.toml`) for known test fixtures / example keys — but review additions carefully so a real secret isn't allowlisted away.

### 3.3 Secret scanning remediation runbook (make this a checklist)

1. Detected → **assume compromised**.
2. **Rotate/revoke** the credential at the provider immediately.
3. Replace with a reference to a secrets manager / CI secret store (never re-commit the new value).
4. Remove from git history (`git filter-repo` or BFG) — *optional cleanup, not the fix*.
5. Verify the old credential is dead (auth fails).
6. Add detection/allowlist tuning so it doesn't recur.

---

## 4. Concrete Recommendations (Prioritized)

### P0 — Do now
1. **Add secret scanning correctly** (§3): pre-commit + CI per-PR + scheduled full-history, with rotation-first remediation. Run the one-time history scan and rotate anything real this week.
2. **Add SCA / dependency CVE scanning.** This is the most likely source of real CRITICALs and it's currently uncovered. (e.g., osv-scanner for OSV/CVE breadth, Grype for containers+packages, or your ecosystem's native auditor as a baseline.) Most impactful single addition after secrets.
3. **Replace the channel-dump with tracked, owned tickets.** Every CRITICAL/HIGH (per the new prioritization) becomes a ticket with an owner and an SLA. Keep a channel notification, but the channel links to a ticket — it is not the system of record.

### P1 — Next
4. **Adopt risk-based prioritization, not CVSS-only.** Layer in EPSS + CISA KEV + reachability + exposure. Define buckets and SLAs, e.g.:
   - **P0 (24–48h):** KEV-listed OR reachable+internet-facing CRITICAL/HIGH.
   - **P1 (7 days):** Reachable CRITICAL/HIGH not in KEV.
   - **P2 (30 days):** HIGH internal / unreachable CRITICAL.
   - **P3 (backlog/risk-accept):** Low exploitability, no fix available, low exposure.
5. **Introduce diff-aware gating.** Fail the build on **new** CRITICAL/HIGH findings (SAST, SCA, secrets) introduced by a PR. Baseline pre-existing findings as backlog so you don't block on legacy debt. This is the single change that converts "advisory" into "enforced" without revolting the team.
6. **Add IaC / container misconfig scanning** if you ship infra-as-code or containers (e.g., Checkov / Trivy / Hadolint).

### P2 — Hardening & maturity
7. **Tune false positives** for Semgrep (custom rulesets, per-finding suppression with justification) and Nuclei (template selection, severity filters) so the gate stays credible.
8. **Verify Nuclei targets a real, authorized staging environment** with representative data and that you have scan authorization.
9. **Pin and schedule updates** for scanner versions + rulesets (e.g., monthly), so detection stays current without surprise breakage.
10. **Treat empty/failed scans as failures**, not passes — fail the pipeline if a scanner errors or produces no output when output is expected.
11. **Measure:** track time-to-remediate by severity, false-positive rate, finding trend, and scan coverage. Review monthly.
12. **Consider an aggregation layer** (DefectDojo or similar) once you have 3+ scanners, so dedup/triage/SLA tracking lives in one place instead of N channels.

---

## 5. Target-State Pipeline (Reference)

```
Developer machine
  └─ pre-commit hook: secret scan (Gitleaks) + fast SAST  → prevent

Pull Request (CI)
  ├─ SAST (Semgrep)        ─┐
  ├─ SCA / dep CVEs        ─┤  diff-aware: fail build ONLY on NEW
  ├─ Secret scan (incr.)   ─┤  CRITICAL/HIGH; baseline legacy as backlog
  └─ IaC/container misconfig┘
         │
         ▼
  Findings → normalized → deduplicated → risk-scored
   (CVSS × EPSS × KEV × reachability × exposure)
         │
         ▼
  Tracked tickets w/ owner + SLA   (channel = notification only)

Staging deploy
  └─ DAST (Nuclei) against authorized, representative target

Scheduled (nightly/weekly)
  ├─ full-history secret scan
  └─ full SCA re-scan (new CVEs land on old code)
```

---

## 6. Quick Scorecard

| Area | Current | Target |
|------|---------|--------|
| SAST | Semgrep present | Keep + tune FPs |
| DAST | Nuclei present | Verify target + authorization |
| SCA / dep CVEs | **Missing** | **Add (P0)** |
| Secret scanning | Being added | Add correctly: history + rotation + pre-commit (P0) |
| IaC / container | **Missing** | Add if applicable (P1) |
| Findings routing | Channel dump | Tracked tickets + owner + SLA (P0) |
| Prioritization | CVSS-only | Risk-based: +EPSS +KEV +reachability +exposure (P1) |
| Gating | Likely none | Diff-aware new-findings gate (P1) |
| FP management | None | Suppression + allowlist (P2) |
| Measurement | None | TTR / FP-rate / trend (P2) |

---

## 7. The One-Liner

You have scanners but not a security *process*. Fix the operating model — **owned tickets with SLAs instead of a channel dump, risk-based prioritization instead of CVSS-only, and diff-aware gates instead of advisory reports** — then close the coverage gaps (SCA now, IaC if applicable). For secret scanning specifically: **scan full history, rotate don't delete, and block at commit time.**
