# IaC Security Linting Rules
<!-- capability: iac_security_lint -->

## Quick Rule Index

| # | Rule | Scope |
|---|------|-------|
| I1 | Default tool: Checkov for multi-framework IaC, Hadolint for Dockerfile-only | tool-selection |
| I2 | Skip/suppress: `--skip-check CKV_ID` or inline `checkov:skip=CKV_ID:reason` with mandatory reason | suppression |
| I3 | Compliance mapping: 1000+ policies mapped to CIS, SOC2, HIPAA, PCI DSS | compliance |
| I4 | soft_fail transition: start soft_fail=true, flip to false after critical fixes | adoption |
| I5 | Framework auto-detection: `checkov -d .` scans all IaC types automatically | config |
| I6 | Graph-based checks: 800+ cross-resource relationship checks (e.g., SG attached to public EC2) | depth |
| I7 | Pipeline gating: CRITICAL/HIGH fail, MEDIUM/LOW warn | ci-pipeline |

---

## Rules

### I1: Tool Selection by IaC Type

Match linting tool to IaC type:

| IaC Type | Files | Primary Tool | Command |
|----------|-------|-------------|---------|
| Terraform | `*.tf`, `*.tfvars` | Checkov | `checkov -d . --framework terraform` |
| Kubernetes | `*.yaml` in k8s/ | Checkov | `checkov -d ./k8s/ --framework kubernetes` |
| Dockerfile | `Dockerfile` | Hadolint + Checkov | `hadolint Dockerfile` |
| CloudFormation | `template.yaml` | Checkov | `checkov -d . --framework cloudformation` |
| Helm | `Chart.yaml` | Checkov | `checkov -d . --framework helm` |
| ARM/Bicep | `*.bicep` | Checkov | `checkov -d . --framework bicep` |
| Docker Compose | `docker-compose.yml` | Checkov | `checkov -f docker-compose.yml` |
| Multi-framework | Mixed | Checkov | `checkov -d .` (auto-detect) |

For Dockerfile, use both tools:
```bash
# Hadolint: Dockerfile best practices (FROM pinning, layer optimization)
hadolint Dockerfile

# Checkov: security-focused checks (running as root, exposed ports)
checkov -f Dockerfile --framework dockerfile
```

**Anti-pattern**: Using only Hadolint for container security. Hadolint checks Dockerfile best practices but misses Kubernetes-level security (pod security, network policies, RBAC).

### I2: Suppression with Documented Reason

Suppress known false positives or accepted risks with mandatory justification:

```bash
# CLI suppression (skip specific checks)
checkov -d . --skip-check CKV_AWS_18,CKV_AWS_21

# Inline suppression (in IaC file)
resource "aws_s3_bucket" "logs" {
  # checkov:skip=CKV_AWS_18:Access logging bucket doesn't need its own logging
  bucket = "my-access-logs"
}
```

For Kubernetes:
```yaml
apiVersion: v1
kind: Pod
metadata:
  annotations:
    # checkov:skip=CKV_K8S_40:Debug container requires privileged access in dev only
    checkov.io/skip: "CKV_K8S_40=Debug container"
```

Suppression governance:
1. Every skip MUST include a reason (`:reason` suffix)
2. Skips without reason are a P1 finding in review
3. `--skip-check` in CI should be tracked in a config file (`.checkov.yaml`), not inline flags
4. Review suppressions quarterly — accepted risks may become unacceptable

```yaml
# .checkov.yaml (preferred over CLI flags)
skip-check:
  - CKV_AWS_18  # Access logging bucket self-reference
  - CKV_K8S_40  # Dev-only debug containers
```

**Anti-pattern**: Adding `--skip-check` with a growing list of IDs and no documentation. This is how security exceptions accumulate into a blind spot.

### I3: Compliance Framework Mapping

Checkov maps 1000+ policies to compliance frameworks:

```bash
# Scan with specific compliance framework
checkov -d . --framework terraform --check-type CIS_AWS

# List available compliance frameworks
checkov --list

# Filter by compliance
checkov -d . --framework terraform --bc-api-key $KEY --compliance CIS_AWS_1.4
```

Key mappings for common findings:

| Finding | Checkov ID | CIS Benchmark | OWASP |
|---------|-----------|---------------|-------|
| Public S3 bucket | CKV_AWS_19 | CIS AWS 2.1.5 | A05 |
| Unencrypted EBS | CKV_AWS_3 | CIS AWS 2.2.1 | A02 |
| Public RDS | CKV_AWS_17 | CIS AWS 4.1 | A05 |
| Running as root | CKV_K8S_6 | CIS K8s 5.2.6 | A05 |
| No resource limits | CKV_K8S_11 | CIS K8s 5.4.1 | — |
| Wildcard IAM | CKV_AWS_1 | CIS AWS 1.16 | A01 |
| Unpinned base image | CKV_DOCKER_7 | CIS Docker 4.7 | A06 |

Scope boundary: Checkov FINDS misconfigurations. Formal compliance evidence (audit trails, attestation) belongs to a compliance pack. This capability provides remediation context, not compliance proof.

**Anti-pattern**: Treating Checkov compliance output as sufficient for an audit. Checkov proves technical controls are in place — it does not prove organizational processes (access reviews, incident response, vendor management).

### I4: soft_fail Adoption Strategy

For existing infrastructure with many findings, start with soft_fail:

```bash
# Phase 1: soft_fail (log findings, don't block)
checkov -d . --soft-fail --output json --output-file-path checkov-baseline.json

# Phase 2: soft_fail with exclusions (block new critical only)
checkov -d . --hard-fail-on CKV_AWS_1,CKV_AWS_17,CKV_K8S_6

# Phase 3: hard_fail (block on all CRITICAL/HIGH)
checkov -d .
```

In CI pipeline (GitHub Actions):
```yaml
# Phase 1: soft_fail
- name: IaC Security Lint
  run: checkov -d . --soft-fail --output json
  continue-on-error: true  # redundant with --soft-fail, but explicit

# Phase 3: hard_fail (target state)
- name: IaC Security Lint
  run: checkov -d . --output json
  # Exit 1 on any failed check — blocks merge
```

Transition timeline:
1. **Week 1**: `--soft-fail`, triage all findings
2. **Week 2-4**: `--hard-fail-on` for top 5 critical checks
3. **Month 2**: Remove soft_fail, block on all CRITICAL/HIGH
4. **Quarter 2**: Expand to MEDIUM severity

**Anti-pattern**: Staying on `--soft-fail` permanently. It provides zero enforcement. Set a deadline (2-4 sprints) and communicate to the team.

### I5: Multi-Framework Auto-Detection

Checkov auto-detects IaC frameworks when scanning a directory:

```bash
# Auto-detect all IaC types in project
checkov -d .

# This automatically scans:
# - Terraform files (*.tf)
# - Kubernetes manifests (*.yaml in k8s patterns)
# - Dockerfiles
# - CloudFormation templates
# - Helm charts
# - Docker Compose files
# - Serverless framework configs
```

Override when you know the target:
```bash
# Specific framework (faster, more targeted)
checkov -d . --framework terraform

# Multiple specific frameworks
checkov -d . --framework terraform,kubernetes,dockerfile
```

**Anti-pattern**: Running `checkov -d . --framework terraform` in a project that also has Kubernetes manifests and Dockerfiles. Use auto-detect or explicitly list all frameworks.

### I6: Graph-Based Cross-Resource Checks

Checkov's 800+ graph-based checks analyze relationships between resources:

```bash
# Graph checks are automatic — no special flag needed
checkov -d . --framework terraform
# Includes checks like:
# - Security group allows ingress from 0.0.0.0/0 AND is attached to public EC2
# - S3 bucket has public ACL AND contains sensitive data tags
# - RDS instance is publicly accessible AND has no encryption
```

These are more valuable than single-resource checks because they catch dangerous combinations:

| Check | Single-Resource Miss | Graph-Based Catch |
|-------|---------------------|-------------------|
| Open SG | "SG allows 0.0.0.0/0" (maybe internal) | "Open SG attached to internet-facing ALB" |
| Public S3 | "Bucket has public ACL" (maybe static site) | "Public bucket tagged as PII storage" |
| No encryption | "EBS not encrypted" (maybe temp) | "Unencrypted EBS attached to prod instance" |

**Anti-pattern**: Dismissing a "public security group" finding because "it's internal." Check what the SG is attached to — graph checks reveal the full blast radius.

### I7: Pipeline Gating Thresholds

Apply severity-based gating in CI:

```bash
# Block on CRITICAL and HIGH only
checkov -d . --hard-fail-on CRITICAL,HIGH

# JSON output for downstream processing
checkov -d . --output json --output-file-path iac-results.json

# SARIF output for GitHub Security tab
checkov -d . --output sarif --output-file-path iac-results.sarif
```

Exit codes:
| Code | Meaning | CI Action |
|------|---------|-----------|
| 0 | All checks passed | Pass |
| 1 | Failed checks found | Fail (if matching hard-fail criteria) |
| 2 | Error during scan | Fail (investigate) |

Gating matrix:

| Severity | PR Gate | Nightly | Pre-Deploy |
|----------|---------|---------|------------|
| CRITICAL | Block | Block | Block |
| HIGH | Block | Block | Block |
| MEDIUM | Warn | Block | Warn |
| LOW | Skip | Warn | Skip |

**Anti-pattern**: Blocking PRs on LOW severity IaC findings. Missing a liveness probe annotation is not a reason to block a feature PR. Track in backlog, enforce in nightly.

---

## Common Checkov Gotchas

1. **Auto-detect vs explicit framework**: Auto-detect scans everything but is slower. Use explicit `--framework` when you know the target.
2. **Custom policies**: Write in Python, place in `--external-checks-dir ./policies/`
3. **Plan file scanning**: `checkov -f tfplan.json` scans Terraform plan output (catches runtime values)
4. **Docker image scanning**: `checkov --docker-image name:tag` scans running container images
5. **Output formats**: `--output json,sarif,junitxml` — multiple formats in one run
