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

### Native Tool Boundary Requires Raw-Event Enforcement - 2026-08-27
- **Discovery**: A Codex assertion can return a valid-looking H1-H8/S1-S4 response while its native JSONL contains `command_execution` events. A runner that emits a synthetic `Read` call from the final message can therefore certify a shell-capable assertion as read-only; carrier hashes alone do not prove the declared tool boundary.
- **Action**: Bind the native event inventory to the raw carrier and fail strict authorization when forbidden event kinds appear. Keep degraded runs explicitly marked and never promote them to strict Gate 3 evidence.
- **failure_mode**: Naive default: trust the declared tool-policy metadata and final response after hashing the carrier. Why wrong: the raw event stream is the execution fact; a self-consistent synthetic record can omit forbidden native calls and let an assertion read or mutate outside its declared capability.
- **Grounded in**: `.tad/scripts/yolo-reference-runner.mjs`, `.tad/scripts/yolo-recovery.mjs`, `.tad/evidence/yolo/yolo2-verified-orchestration/phase2/reference-harness-capability.json`, and the final Phase-2 Group-0 review.
