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

> ⚠️ Migrated to three-layer knowledge structure (2026-06-02, Knowledge Lifecycle Epic Phase 2).
> - Principles: `.tad/project-knowledge/principles.md`
> - Patterns: `.tad/project-knowledge/patterns/`
> - Incidents: `.tad/project-knowledge/incidents/`
> See `.tad/project-knowledge/README.md` for the Knowledge Lifecycle System documentation.
