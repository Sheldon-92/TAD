---
name: supply-chain-security
description: "Supply chain security capability pack. Covers dependency audit, behavioral analysis, provenance verification, lockfile integrity, and typosquat detection. Use for any dependency trust review, pre-install package vetting, SBOM audit, dependency-update PR review, or supply chain security task."
version: 0.1.0
type: reference-based
keywords: ["supply chain security", "供应链安全", "dependency audit", "依赖审计", "SBOM", "软件物料清单", "behavioral analysis", "行为分析", "provenance", "来源验证", "lockfile", "锁文件", "typosquatting", "名称仿冒", "vulnerability scan", "漏洞扫描", "CVE", "package poisoning", "包投毒", "sigstore", "SLSA", "npm audit", "pip-audit"]
---

# Supply Chain Security Capability Pack

> Pre-install trust analysis. Core question: **"Should I trust this dependency?"**
> **PRODUCES**: Structured audit reports + remediation plans, NOT code. Artifacts go under `.tad/active/research/{project}/` (SBOM, audit/behavioral/provenance/lockfile/typosquat reports, raw scanner JSON).
> **SCOPE**: Pre-install analysis ONLY. Post-install CVE monitoring belongs to the security-monitoring pack.
> **ECOSYSTEMS**: npm, pip, cargo, go (detection also covers maven/gradle, ruby, PHP). Known limitation: lockfile integrity is full for npm/yarn, partial for pip/go (no hash verification equivalent).
> **REFERENCE INCIDENT**: litellm 1.82.7/1.82.8 PyPI poisoning (2026-03-24) — CVE-only scanners missed it entirely. Every audit must ask: "would this have caught it?"

---

## Severity Policy — MANDATORY Pipeline Gating

These rules are non-negotiable for any security-pack task:

- **CRITICAL and HIGH findings BLOCK the pipeline.** Never demote a CRITICAL/HIGH to a warning.
- **MEDIUM and LOW findings warn only** — they must not block.
- **accept_risk requires documented justification** in the triage report **with owner sign-off**. No silent risk acceptance.
- **Grace period**: existing findings get a 2-sprint remediation window.
- **litellm rule — NO grace period**: for behavioral analysis findings (socket CLI alerts), there is NO grace period. Behavioral anomalies in new/updated dependencies **block merge immediately**.

---

## Step 1: Context Detection

Non-circular triggers — each is an event you can recognize BEFORE reading any reference:

| User Signal / Event | Load Reference |
|---|---|
| "audit dependencies", CVE/vulnerability scan, SBOM request, "is this project's dependency tree safe", new project onboarding | `references/dependency-audit.md` |
| A lockfile diff shows new/updated packages, a Dependabot/Renovate PR is open, "is this package/version safe to install", post-incident package vetting | `references/behavioral-analysis.md` |
| Deploying a container image, "verify publisher/signature", SLSA/sigstore/cosign mentioned, GitHub Actions workflow review, maintainer-change worry | `references/provenance-verification.md` |
| Lockfile missing/modified/gitignored, hash validation, "reproducible installs", registry source policy, CI install gating | `references/lockfile-integrity.md` |
| Adding a package by typed name, "did I spell this package right", suspicious look-alike package name, pre-install name check | `references/typosquat-detection.md` |
| Final audit review, Gate 2 design review or Gate 4 acceptance of supply-chain work, "review this audit report" | `references/review-checklist.md` |

**Multi-signal**: load all matched references. A full audit loads all five capability references.

---

## Step 2: Decision Entry Point

**Q1 — What triggered this task?**
- Full project trust audit → start with `dependency-audit.md`. Generate the SBOM FIRST — it is the foundation artifact consumed by typosquat detection and downstream monitoring. Then run all other capabilities.
- Dependency change (lockfile diff, dep-update PR) → `behavioral-analysis.md` + `typosquat-detection.md`. Priority order: new packages > version updates > transitive updates.
- Container image deploy / release signing → `provenance-verification.md`.
- CI policy setup or install reproducibility → `lockfile-integrity.md` + Severity Policy above.

**Q2 — Which ecosystems?** Detect from package manager files: `package.json`/lockfiles → npm; `requirements.txt`/`pyproject.toml`/`uv.lock`/`poetry.lock` → pip; `Cargo.toml` → cargo; `go.mod` → go; `pom.xml`/`build.gradle` → maven/gradle; `Gemfile` → ruby; `composer.json` → PHP. Multiple ecosystems may coexist (JS frontend + Python backend) — scan ALL of them; a missed ecosystem is a failed audit.

**Q3 — Delivering or reviewing an audit?** Before delivering an audit report, or when running Gate 2/Gate 4 on supply-chain work → read `references/review-checklist.md` (Supply Chain Security Engineer persona, 10-item cross-cutting checklist, gate checklists, expected output tree).

---

## Quick Rule Index

### Dependency Audit (`references/dependency-audit.md`)
- **SBOM first**: syft-generated CycloneDX (spec >= 1.5) including direct AND transitive deps — the foundation artifact for every other capability.
- **Run ALL applicable scanners** (osv-scanner multi-ecosystem first pass; npm audit / pip-audit / cargo audit per ecosystem; depscan deep mode) — cross-referencing finds blind spots. CRITICAL findings must be cross-referenced by at least 2 scanners.
- **Every CRITICAL/HIGH** needs: fix version check, breaking-change risk, EPSS score, KEV catalog check (KEV = highest priority), and a remediation path or documented accept-risk.
- Separate direct vs transitive findings; flag unmaintained deps (no release in 12+ months). JSON output for CI consumption.

### Behavioral Analysis (`references/behavioral-analysis.md`)
- **HIGH RISK — block immediately**: new network calls to unknown domains; filesystem writes outside package dir; new eval/exec/system usage; install script added where none existed; obfuscated code.
- **MEDIUM — review required**: new optional deps; maintainer change between versions; >50% code size increase.
- **LOW — informational**: minor bump with no behavioral change; dev dependency update.
- No block without evidence; every package gets an explicit allow/block/review decision.
- Every report MUST answer: "Would this scan have caught the litellm 1.82.7 behavioral change?"

### Provenance Verification (`references/provenance-verification.md`)
- Verify container images with cosign (certificate identity + OIDC issuer); npm provenance via npm audit signatures.
- **GitHub Actions MUST be pinned to full commit SHA**, never mutable tags (trivy-action March 2026: 75/76 tags hijacked).
- Document SLSA level (1: provenance exists, 2: signed, 3: hardened build) per critical dependency.
- Publisher red flags: publisher changed between versions; single maintainer (bus factor = 1); email domain change; recent ownership transfer.
- OSSF Scorecard: flag overall score < 5, Branch-Protection = 0, Code-Review = 0, or any zero check on a critical dep. Provenance grade = signature status + SLSA level + Scorecard score.

### Lockfile Integrity (`references/lockfile-integrity.md`)
- **FAIL pipeline**: missing lockfile for a manifest; npm/yarn entries without integrity hashes; any non-HTTPS source; lockfile modified without a corresponding manifest change.
- **WARN**: pip requirements.txt without hash pins; go.sum entries not in go.mod.
- lockfile-lint validates npm/yarn (sha512, HTTPS-only, allowed hosts); cargo generate-lockfile --check catches stale/hand-edited Cargo.lock.
- pip has no default hashes — recommend pip-compile --generate-hashes or uv lock.
- Lockfiles must NOT be gitignored for applications (libraries may exclude, apps should not).

### Typosquat Detection (`references/typosquat-detection.md`)
- Apply **at least 4 variant techniques** per dependency: character swap, omission, addition, homoglyph (plus hyphen/underscore and scope confusion).
- Suspicion score: registered variant + low downloads + recent creation + publisher mismatch.
- Scan the FULL SBOM — typosquats hide in transitive deps, not just direct ones.
- Maintain an allowlist of verified-safe names — otherwise repeated runs create alert fatigue.

### Review & Gates (`references/review-checklist.md`)
- One cross-cutting Supply Chain Security Engineer persona reviews all capabilities in a single audit pass.
- Gate 2 design checklist (scope, behavioral coverage, SBOM planned, severity policy, accept-risk process) and Gate 4 acceptance checklist (remediation plans, signatures, lockfile validation, machine-readable report).

---

## Anti-Patterns

### Dependency Audit
- ❌ CVE-only scanning without behavioral analysis — misses litellm-class zero-day attacks
- ❌ Scanning only direct dependencies while ignoring transitive (the axios attack came through a transitive dep)
- ❌ Auto-fixing without checking breaking changes — cargo audit fix / npm audit fix may introduce regressions

### Behavioral Analysis
- ❌ Treating all socket CLI warnings as false positives — behavioral anomalies require investigation
- ❌ Only scanning direct dependencies when transitive deps change
- ❌ Auto-merging dependency PRs without behavioral review (Dependabot/Renovate + socket CLI needed)

### Provenance Verification
- ❌ Trust-by-popularity — GitHub stars are gameable (axios had 100M+ weekly downloads and was still compromised)
- ❌ Assuming cosign coverage is universal — most PyPI packages have NOT opted into sigstore
- ❌ Checking provenance once without continuous monitoring — maintainer changes happen anytime

### Lockfile Integrity
- ❌ Having a lockfile without verifying hashes — provides reproducibility but NOT integrity
- ❌ Adding lockfiles to .gitignore for applications (libraries may exclude, apps should not)
- ❌ Assuming pip requirements.txt provides lockfile-level integrity (it doesn't without --hash flags)

### Typosquat Detection
- ❌ Only checking direct dependencies — typosquats hide in transitive deps
- ❌ Ignoring homoglyph attacks (Cyrillic е looks identical to Latin e)
- ❌ Running detection once without maintaining allowlist — creates alert fatigue

---

## Anti-Skip Table

| Shortcut Attempt | Required Action |
|---|---|
| "The CVE scan is clean, we're done" | MUST also run behavioral analysis (`behavioral-analysis.md`) — CVE-only scanning missed the litellm 1.82.7 poisoning entirely |
| "It's just a minor version bump in the lockfile" | MUST diff the lockfile and behavioral-scan every new/updated package — behavioral anomalies block merge with NO grace period |
| "This package is popular, it's safe" | MUST run provenance checks (`provenance-verification.md`) — popularity is gameable; axios was compromised at 100M+ weekly downloads |
| "The lockfile exists, installs are safe" | MUST validate hashes and HTTPS-only sources (`lockfile-integrity.md`) — a lockfile without hash verification gives reproducibility, not integrity |
| "I'll downgrade this HIGH to a warning to unblock CI" | MUST NOT — CRITICAL/HIGH block the pipeline; the only exit is documented accept-risk with owner sign-off |
| "Direct deps are checked, transitive ones are fine" | MUST cross-reference the full SBOM — typosquats and vulnerable packages hide in transitive deps |
| "The audit report looks complete" | MUST run the 10-item checklist in `review-checklist.md`, including "would this have detected litellm 1.82.7?" |
