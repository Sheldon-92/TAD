# Completion Report: code-security Capability Pack

**Completed by:** Blake (Agent B)
**Date:** 2026-05-15

---

## Files Created (9 files)

| # | File | Words | Purpose |
|---|------|-------|---------|
| 1 | `.tad/capability-packs/code-security/CAPABILITY.md` | 1,247 | Main pack file: router + frontmatter + keywords + CONSUMES/PRODUCES + Anti-Skip Table |
| 2 | `.tad/capability-packs/code-security/install.sh` | — | Cross-agent installer (--force, --dry-run, --agent) |
| 3 | `.tad/capability-packs/code-security/LICENSE` | — | Apache 2.0 |
| 4 | `.tad/capability-packs/code-security/references/sast-rules.md` | — | 8 judgment rules: Semgrep CLI, rule sets, taint mode, diff-aware, SARIF, exit codes, custom rules, baseline |
| 5 | `.tad/capability-packs/code-security/references/dast-rules.md` | — | 7 judgment rules: Nuclei templates, production safety, severity filtering, rate limiting, template freshness, auto-scan, SAST+DAST correlation |
| 6 | `.tad/capability-packs/code-security/references/secret-detection-rules.md` | — | 7 judgment rules: two-layer defense, pre-commit, baseline, TruffleHog exit 183, inline suppression, remediation order, verified vs unverified triage |
| 7 | `.tad/capability-packs/code-security/references/iac-security-rules.md` | — | 7 judgment rules: Checkov/Hadolint selection, skip/suppress, compliance mapping, soft_fail transition, auto-detection, graph checks, pipeline gating |
| 8 | `.tad/capability-packs/code-security/references/vulnerability-triage-rules.md` | — | 7 judgment rules: CVSS limitations, ASPM consolidation, CLI tool selection, deduplication, owner+deadline, reachability, KEV catalog |
| 9 | `.claude/skills/code-security/` (installed) | — | 7 files copied by install.sh |

**Auto-generated:** `.tad/capability-packs/pack-registry.yaml` (scan-packs.sh ran successfully, 11 packs total)

---

## AC Verification Table

| AC | Description | Result | Evidence |
|----|-------------|--------|----------|
| AC1 | CAPABILITY.md has YAML frontmatter with `name:` and `description:` | PASS | `head -3 SKILL.md \| grep -q "^name:"` exit 0 |
| AC2 | Word count < 3,500 | PASS | `wc -w` = 1,247 words (under 3,500) |
| AC3 | All 5 capabilities covered in references/ | PASS | sast-rules.md, dast-rules.md, secret-detection-rules.md, iac-security-rules.md, vulnerability-triage-rules.md |
| AC4 | Each reference has Quick Rule Index + prescriptive rules + CLI commands | PASS | S1-S8, D1-D7, SE1-SE7, I1-I7, V1-V7 (36 rules total) |
| AC5 | Specific exit codes included | PASS | Semgrep exit 1 (S6), TruffleHog exit 183 (SE4), Checkov exit 1 (I7), Gitleaks exit 1 (SE1) |
| AC6 | Anti-patterns from research included | PASS | Tool sprawl 72% (V2), alert fatigue 30-50% (Anti-Skip Table), security theater (cross-cutting rule) |
| AC7 | Keywords include Chinese + English + tool names | PASS | 18 keywords in frontmatter |
| AC8 | CONSUMES/PRODUCES declaration | PASS | Both declared in CAPABILITY.md |
| AC9 | install.sh exits 0 with --force | PASS | 7 files installed, exit 0 |
| AC10 | pack-registry.yaml entry | PASS | scan-packs.sh scanned 11 packs, code-security entry present |
| AC11 | Cross-cutting rules surfaced in CAPABILITY.md | PASS | "Four-Gate Pipeline: fastest-fail-first" + "Detection != Remediation" |
| AC12 | `<!-- capability: X -->` tags in all reference files | PASS | sast_scan, dast_scan, secret_detection, iac_security_lint, vulnerability_triage |

---

## Design Decisions

1. **5 reference files matching 5 Domain Pack capabilities**: One reference per capability (sast, dast, secret, iac, triage) for clean separation. Each file is self-contained with Quick Rule Index and can be loaded independently by the router.

2. **Two cross-cutting rules** (not one): "Four-Gate Pipeline" governs scan ordering/placement; "Detection != Remediation" governs output quality. Both are surfaced in CAPABILITY.md because burying them in reference files causes agents to miss them.

3. **Exit codes as first-class content**: Semgrep (1), TruffleHog (183), Checkov (1), Gitleaks (1) are called out in both CAPABILITY.md and individual reference files because CI pipeline correctness depends on these values.

4. **Anti-patterns sourced from research**: Tool sprawl (72%), alert fatigue (30-50%), security theater — all from the 2026-05-15 deep-ask findings, not from Domain Pack YAML.

5. **Rule IDs follow consistent scheme**: S1-S8 (SAST), D1-D7 (DAST), SE1-SE7 (Secrets), I1-I7 (IaC), V1-V7 (Triage) — 36 rules total across 5 reference files.

---

## Source Traceability

| Content | Source |
|---------|--------|
| Semgrep CLI commands, taint mode, SARIF | Research findings Round 1 |
| Nuclei templates, severity filtering, rate limiting | Research findings Round 1 |
| Gitleaks/TruffleHog commands, exit 183, baseline | Research findings Round 1 |
| Checkov policies, skip/suppress, soft_fail | Research findings Round 2 |
| CVSS limitations, reachability, ASPM, KEV | Research findings Round 2 |
| Four-Gate Pipeline architecture | Research findings Round 3 |
| Anti-patterns (tool sprawl, alert fatigue, security theater) | Research findings Round 2 |
| Capability names (sast_scan, dast_scan, etc.) | Domain Pack code-security.yaml |
| Format/structure | ai-evaluation CAPABILITY.md reference |
