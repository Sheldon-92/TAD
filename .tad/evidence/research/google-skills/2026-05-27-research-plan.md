# Research Plan — google/skills Repository Deep Analysis (v2 — post Phase 0c)

**Date:** 2026-05-27
**Notebook:** 6669167a-15ff-4b1f-8676-8876bc676445
**Topic:** google/skills — Repository Deep Analysis
**Status:** v2 (refined after Phase 0c challenge — Codex INSUFFICIENT, refined Q1-Q10 + Gemini Q11-Q13)

---

## Repository Snapshot

- **Repo:** github.com/google/skills
- **Stars:** 10,785
- **Language:** Python (primary)
- **License:** Apache 2.0
- **Created:** 2026-03-31
- **Last update:** 2026-05-28 (active)
- **Description:** "Agent Skills for Google products and technologies"

**Provisional observation (TO BE VALIDATED, NOT ASSUMED):**
- *Subset* of skills under `skills/cloud/` follow a 4-element pattern: SKILL.md + references/ + scripts/ + (optional) assets/
- Reference docs in `*-basics` use 6 modality-specific names: cli-usage, client-library-usage, core-concepts, iac-usage, iam-security, mcp-usage
- This may be `*-basics`-local convention, NOT a repo-wide canon. Active deviation hunting required.

---

## Refined Research Questions (v2)

All questions are **judgmental, not descriptive**. Each includes a specificity anchor and a decision criterion.

### Q1: Frontmatter Schema (existence + enforcement)
**Question:** `skills/cloud/*/SKILL.md` frontmatter — what is the actual field set? Which fields appear in 100% of files? Which appear in only some? Is there a schema/validator/CI workflow that mechanically enforces these fields?
**Source anchor:** All SKILL.md files + `.github/workflows/*` + any `schema.json` / `validate.py`
**Decision criterion:** Whether TAD can adopt Google's schema (need a validator file that defines the contract)

### Q2: Canonical Pattern Coverage + Deviations
**Question:** Is `SKILL.md + references/ + scripts/ + assets/` the repo-wide canon, or only `*-basics` convention? Enumerate ALL skills that deviate (missing references/, missing scripts/, extra directories like `agents/` or `tests/`). What do the deviations tell us about the actual canon?
**Source anchor:** Complete recursive tree listing — focus on outliers, not the conforming majority
**Decision criterion:** If >20% deviate, the "canon" claim is overstated

### Q3: 6-Doc References Pattern Coverage
**Question:** Across all skills, in how many does the 6-doc pattern (cli-usage, client-library-usage, core-concepts, iac-usage, iam-security, mcp-usage) appear COMPLETE? Which skills omit, rename, or add references? Is this generated from a template, hand-curated, or product-task driven?
**Source anchor:** All `references/*.md` files across all skills
**Decision criterion:** Generated vs hand-curated changes whether TAD should adopt as a fixed template

### Q4: Skill Consumption Path (loading semantics)
**Question:** How are these skills actually consumed by an agent? Does the agent: (a) read only SKILL.md and treat references/scripts as optional, (b) follow references/ as required reading, or (c) execute scripts/ as part of the skill workflow? Validate via README, examples, registry docs, and any provided agent harness.
**Source anchor:** README.md + agent-platform-skill-registry/references/*.md + any `examples/` directory
**Decision criterion:** Documentation vs runtime protocol distinction

### Q5: Scripts/ Execution Model + Security Guards
**Question:** For scripts/*.py and scripts/*.sh: what are the execution categories (deployment / cost calc / validation / data prep)? What are the I/O contracts (args, stdin, env vars, exit codes)? What authentication is required? Are there security guards: dry-run flags, env validation, secret handling, destructive-operation guards?
**Source anchor:** All scripts under `skills/cloud/*/scripts/` — sample 10+ for breadth
**Decision criterion:** Production-quality executable tooling vs example snippets

### Q6: Skill Registry — Runtime or Sample?
**Question:** Is `agent-platform-skill-registry` a repo-wide runtime mechanism, or a single product's example skill? What is its storage scope (project / org / global)? What APIs does it expose for query, load, register, monitor? Does it interact with the static SKILL.md files in this repo, or is it self-contained?
**Source anchor:** `skills/cloud/agent-platform-skill-registry/` (scripts + all references)
**Decision criterion:** If runtime: TAD might want analog; if sample: irrelevant to TAD architecture

### Q7: Real Quality Bar (CI vs CONTRIBUTING)
**Question:** What is the ACTUAL quality bar enforced for skills? Compare CONTRIBUTING.md declarations against CI configuration (`.github/workflows/`), test files (`test_*.py`, `*_test.py`), lint configs (`.pylintrc`, `.flake8`), schema validation files. Where do declarations diverge from automated enforcement?
**Source anchor:** CONTRIBUTING.md + .github/workflows/* + scripts/validate_env.py + any test files
**Decision criterion:** A "high quality bar" without CI enforcement is theater

### Q8: TAD ↔ Google Compatibility Matrix (7 dimensions)
**Question:** For each of these dimensions, what are the compatibility and incompatibility points between TAD Capability Pack and Google Skill:
  - **Metadata format** (YAML frontmatter fields)
  - **Loading flow** (filesystem? registry? install script?)
  - **State management** (session.json? stateless?)
  - **Script execution** (sandboxed? PATH-dependent? container?)
  - **Security model** (credential handling, secrets, RBAC)
  - **Templating/scaffolding** (CLI tool? hand-crafted?)
  - **Versioning strategy** (semver? git tag? frontmatter version field?)
**Source anchor:** Multiple Google SKILL.md + `.tad/capability-packs/*/CAPABILITY.md` + `.claude/skills/*/SKILL.md`
**Decision criterion:** Direct decision input for any TAD "adopt Google patterns" handoff

### Q9: Top 3 Borrowable Patterns (ROI-ranked)
**Question:** If TAD borrows from Google, which 3 patterns yield the highest ROI (high benefit / low migration cost)? For each: state evidence (which Google skills demonstrate it), required TAD implementation changes, technical risk, and the explicit reason NOT to borrow.
**Source anchor:** Synthesis of Q1-Q8 findings
**Decision criterion:** Must produce 3 ranked recommendations with non-zero reasons-against

### Q10: Commit Intent Distribution
**Question:** Sample the latest 50 commits — classify by intent: new product coverage / documentation fix / API version update / scaffolding improvement / runtime change / security patch / refactor. Don't just count frequency; classify by file types touched and commit message subjects.
**Source anchor:** `gh api repos/google/skills/commits?per_page=50` + diff samples
**Decision criterion:** Shows whether skills are living docs (frequent API/product updates) or static catalogs (rare changes)

### Q11: Security Boundary (Gemini — supplementary)
**Question:** Review credential handling in `scripts/*.py`. Does Google provide a unified `auth_handler` script? Are there documented sandboxing/containerization requirements? Are there hardcoded credential checks or injection guards?
**Source anchor:** scripts/ across cloud skills + any `auth.py` or `credentials.py`
**Decision criterion:** TAD's pack scripts also handle secrets — direct lesson for code-security pack

### Q12: Inter-Skill Dependency Graph (Gemini — supplementary)
**Question:** Can skills depend on each other? Does any SKILL.md declare a `depends_on` field, `requires` list, or similar? Does `cloud-run` reference `iam-security` skill or duplicate its content? How does Google decouple "basics" from "advanced features"?
**Source anchor:** All SKILL.md frontmatter fields + cross-references in references/*.md
**Decision criterion:** TAD's CONSUMES/PRODUCES pattern vs Google's approach

### Q13: Protocol Neutrality — MCP vs Gemini-Native (Gemini — supplementary)
**Question:** All `*-basics` skills include `mcp-usage.md`. Are these skills MCP-protocol-neutral (consumable by Claude / Codex / Gemini), or are they Gemini-API-optimized? How does Google translate GCP product APIs into MCP-compatible tool definitions?
**Source anchor:** All `references/mcp-usage.md` + any MCP server definitions
**Decision criterion:** If neutral: cross-vendor signal; if Gemini-only: vendor lock-in

---

## Source Type Priority (expanded for v2)

| Priority | Source Type | Example |
|----------|------------|---------|
| 1 (first) | Root docs: README + CONTRIBUTING | Overview + contribution model |
| 2 | CI/test files: `.github/workflows/*`, `test_*.py`, `validate_*.py` | Actual quality enforcement (Q7) |
| 3 | Multiple SKILL.md files (10+ across categories) | Frontmatter pattern + deviations (Q1, Q2) |
| 4 | All references/*.md (esp. mcp-usage, iam-security) | Decomposition + security + protocol (Q3, Q11, Q13) |
| 5 | scripts/*.py (esp. skill_registry_ops.py, validate_env.py, tune_open_model.py) | Tooling + registry (Q4, Q5, Q6) |
| 6 | Full tree listing (recursive) + commit history | Coverage matrix + intent (Q2, Q10) |
| 7 (last) | Deep research (web articles about Anthropic Skills, Claude Skills SDK) | Cross-reference ONLY for Q11, Q13 |

---

## Success Criteria

After this research, I should be able to:
1. **Decide:** Adopt-or-skip Google's SKILL.md frontmatter schema for TAD packs
2. **Decide:** Adopt-or-skip the 6-doc references/ decomposition pattern
3. **Decide:** Whether TAD needs a runtime skill registry analog
4. **Output:** 13-row decision table (one per refined question) with evidence-backed conclusion
5. **Output:** 3 ranked borrowable patterns (Q9 deliverable)

---

## Out of Scope

- Performance benchmarking of skills
- Non-Google skill frameworks beyond Anthropic SKILL.md and TAD packs
- GCP product API details (only insofar as they reveal skill structure)
