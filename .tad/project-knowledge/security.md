# Security Knowledge

Project-specific security learnings accumulated through TAD workflow.

---

## Foundational: Security Domain Pack Architecture

> Established during Security Domain Pack Chain Epic (2026-04-03).

### Pack Scope Boundaries
- **supply-chain-security**: "Should I trust this dependency?" — pre-install analysis
- **code-security**: "Does my code have vulnerabilities?" — SAST + DAST + secrets + IaC
- **security-monitoring** (planned): "Are my existing deps still safe?" — post-install continuous scanning
- **compliance** (planned): "Can I prove I meet the policy?" — policy-as-code + audit evidence

### Key Tool Insight: litellm-class Attack Detection
- Only **Socket CLI** detects behavioral changes between package versions (network calls, fs writes, eval usage)
- All CVE-only scanners (osv-scanner, pip-audit, cargo-audit) are blind to zero-day supply chain poisoning
- Context: User survived litellm 1.82.7/1.82.8 PyPI poisoning (2026-03-24) by being on 1.82.6

### AI Security Hard Gaps (CLI Tooling)
- LLM03 (Training Data Poisoning): Zero CLI coverage — training-time concern
- LLM08 (Vector/Embedding Weaknesses): Zero CLI coverage — emerging area
- LLM10 (Unbounded Consumption): Zero CLI coverage — infrastructure-level
- These gaps are ecosystem-level, not Domain Pack design failures

---

## Accumulated Learnings

### Security Packs Use Cross-Cutting Review Pattern - 2026-04-04
- **Context**: Building supply-chain-security.yaml and code-security.yaml
- **Discovery**: A single top-level review persona (Security Engineer) is more appropriate than per-capability reviewers for security packs, because the same security engineer reviews all capabilities in one audit pass
- **Action**: Future security packs should use one top-level review section, not per-capability reviewers

### Nested output_structure Enhancement - 2026-04-04
- **Context**: Defining output directory structure in security Domain Packs
- **Discovery**: The `description + tree` nested format is richer than the flat string format in earlier packs
- **Action**: Future packs should adopt nested output_structure as the standard format

### Compliance CLI vs SaaS Boundary - 2026-04-03
- **Context**: Phase 0 research on compliance domain tools
- **Discovery**: CLI tools cover ~60% of SOC2 technical controls. Organizational processes (auditor portal, vendor risk, HR compliance) require SaaS platforms (Drata/Vanta). A compliance Domain Pack must declare this boundary explicitly.
- **Action**: If compliance pack is built, declare "CLI covers technical proof only" in description

### Cross-Domain Tool Overlap is Intentional - 2026-04-03
- **Context**: nuclei, checkov, syft appear in multiple domain packs
- **Discovery**: Same tool serves different purposes per domain (e.g., nuclei = DAST in code-security, network scanning in monitoring; checkov = IaC lint in code-security, compliance proof in compliance)
- **Action**: Don't deduplicate tools across packs — document the different usage context per pack
