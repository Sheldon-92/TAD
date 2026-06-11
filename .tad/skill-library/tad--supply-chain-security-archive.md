# T2 Reference: Supply Chain Security Domain Pack Archive

> Source: TAD project, 2026-06-11. Archived from `.tad/domains/` during Pack System Unification Phase 1.

## Archived Source File

- `.tad/archive/domains/2026-06-11-domain-pack-retirement/supply-chain-security.yaml`

## What to Reuse

- Pre-install dependency trust assessment framework ("Should I trust this dependency?")
- Socket CLI behavioral analysis pattern (detects zero-day supply chain poisoning beyond CVE scanning)
- Version pinning and lock file discipline rules
- The litellm 1.82.7/1.82.8 PyPI poisoning case study as a concrete threat model

## What NOT to Reuse

- YAML step model format (use SKILL.md reference-based architecture instead)
- Tool version numbers (research current versions before building a pack)
- Overlap with existing `code-security` Capability Pack (code-security covers SAST/DAST/secrets/IaC; supply-chain-security covers pre-install trust — they are distinct but check for boundary overlap)

## Criteria for Upgrading to Capability Pack

1. A real project dependency audit needs this (e.g., evaluating a new npm/PyPI package)
2. Research current supply-chain security tools (Socket CLI, Snyk, osv-scanner evolution)
3. Validate the pack produces better decisions than baseline LLM knowledge on a real audit
4. Ensure clear scope boundary with `code-security` pack (pre-install vs post-install)
