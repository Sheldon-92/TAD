# Migration Log — NotebookLM → Local Wiki 2026-08-28

- REGISTRY.yaml: 34 notebooks status set to archived (was 8 active, 10 archived, 16 dormant → now 34 archived)
  - Command: `yq -i '(.notebooks[].status = "archived")' .tad/research-notebooks/REGISTRY.yaml`
  - Verify: `grep -c 'status: archived' → 34 >=20 PASS`
- Seeds: copied 5 findings -> raw/papers (cp, no modify)
  - .tad/evidence/research/2026-07-staleness-trap-findings.md -> research/raw/papers/migrated-staleness-trap.md
  - agent-memory/findings.md -> migrated-agent-memory.md
  - ai-guardrails/findings.md -> migrated-ai-guardrails.md
  - agent-knowledge-systems/2026-06-22-findings.md -> migrated-agent-knowledge.md
  - product-capability-pack/2026-05-07-research-findings.md -> migrated-product-pack.md
  - Total papers now 6 (mcp-001 + 5 migrated) → `ls raw/papers/*.md | wc -l >=5` PASS
- Manifest: research/raw/manifests/migrated-from-notebooklm.txt created
- Cloud: no deletion via NotebookLM API (local archive only per Forbidden)
