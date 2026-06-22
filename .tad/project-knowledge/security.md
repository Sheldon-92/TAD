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
- **failure_mode**: Naive default: lump all security concerns into one monolithic "security" pack or tool. Why wrong: pre-install (supply chain), in-code (SAST/DAST), post-install (monitoring), and compliance are four distinct lifecycle stages with different tools and triggers — a single pack conflates them, leaving gaps in coverage at stage boundaries.

### Key Tool Insight: litellm-class Attack Detection
- Only **Socket CLI** detects behavioral changes between package versions (network calls, fs writes, eval usage)
- All CVE-only scanners (osv-scanner, pip-audit, cargo-audit) are blind to zero-day supply chain poisoning
- Context: User survived litellm 1.82.7/1.82.8 PyPI poisoning (2026-03-24) by being on 1.82.6
- **failure_mode**: Naive default: rely on CVE-based scanners (osv-scanner, pip-audit) for supply chain security. Why wrong: CVE databases only track KNOWN vulnerabilities — zero-day supply chain poisoning (injected network calls, fs writes, eval) has no CVE entry, so CVE-only scanners are completely blind to it.

### AI Security Hard Gaps (CLI Tooling)
- LLM03 (Training Data Poisoning): Zero CLI coverage — training-time concern
- LLM08 (Vector/Embedding Weaknesses): Zero CLI coverage — emerging area
- LLM10 (Unbounded Consumption): Zero CLI coverage — infrastructure-level
- These gaps are ecosystem-level, not Domain Pack design failures
- **failure_mode**: Naive default: assume CLI security tooling covers all OWASP LLM Top 10 categories. Why wrong: LLM03/LLM08/LLM10 have zero CLI coverage — no tool exists to scan for them at the CLI layer — so treating the pack as comprehensive creates a false sense of security for training-time, embedding, and resource-exhaustion threats.

---

## Accumulated Learnings

> ⚠️ Migrated to three-layer knowledge structure (2026-06-02, Knowledge Lifecycle Epic Phase 2).
> - Principles: `.tad/project-knowledge/principles.md`
> - Patterns: `.tad/project-knowledge/patterns/`
> - Incidents: `.tad/project-knowledge/incidents/`
> See `.tad/project-knowledge/README.md` for the Knowledge Lifecycle System documentation.
