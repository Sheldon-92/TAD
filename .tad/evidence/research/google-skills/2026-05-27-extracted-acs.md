# Extracted Actionable Items — google/skills Research

**Date:** 2026-05-27
**Notebook:** 6669167a-15ff-4b1f-8676-8876bc676445
**Source findings:** 2026-05-27-ask-findings.md (incl. Phase 4c unresolved weaknesses)

These are actionable items for TAD's evolution. Each AC explicitly states:
- **Evidence strength** (STRONG / MEDIUM / WEAK / UNSUPPORTED)
- **Coverage** in google/skills repo (out of 24 skills)
- **Recommendation** (Adopt / Consider / Avoid / Defer)

Evidence strength definitions:
- **STRONG**: Observed in ≥10/24 skills + supported by external generate-skill.md spec
- **MEDIUM**: Observed in 4-10/24 skills with clear pattern
- **WEAK**: Observed in <4/24 skills OR inferred from architecture
- **UNSUPPORTED**: Speculation; needs empirical validation

---

## AC1 — Minimal SKILL.md Frontmatter Contract
**Recommendation:** ✅ ADOPT (TAD already aligns)
**Evidence:** STRONG — `name` + `description` in 100% of 24 skills
**Source:** All Google SKILL.md files
**Action:** Verify TAD pack SKILL.md frontmatter requires `name` + `description`. Already standard; no change needed but document as cross-vendor compatible minimum.

## AC2 — Optional Frontmatter Fields for Provenance
**Recommendation:** 🟡 CONSIDER
**Evidence:** WEAK — only gke-basics uses `license`, only gemini-api uses `compatibility`
**Source:** gke-basics/SKILL.md, gemini-api/SKILL.md
**Action:** Consider adding optional fields to TAD pack template:
- `license: Apache-2.0` (or equivalent)
- `metadata.version` (semver for the pack itself, not the underlying tool)
- `compatibility` (text describing required env / dependencies)
**Caveat:** Google's own usage is inconsistent (1 skill each). Low-coverage pattern.

## AC3 — Python Script I/O Contract (argparse + env fallback + ADC + exit codes)
**Recommendation:** ✅ ADOPT for any TAD pack with executable scripts
**Evidence:** STRONG — observed in all 4 analyzed Python scripts (skill_registry_ops.py, validate_env.py, tune_open_model.py, calculate_cost.py)
**Source:** All scripts/*.py in agent-platform-skill-registry, agent-platform-tuning
**Action:** TAD pack scripts (where applicable) should:
- Use argparse with subcommands for multi-operation scripts
- Accept `--project`, `--location` style flags with env var fallback
- Use ADC / well-known credential resolution patterns (no hardcoded keys)
- Exit with `sys.exit(1)` on missing required input
- NOT read from stdin (predictability)

## AC4 — Atomic Partial Updates via updateMask Pattern
**Recommendation:** ✅ ADOPT for TAD packs that manage stateful resources
**Evidence:** STRONG — implemented in skill_registry_ops.py PATCH operations
**Source:** agent-platform-skill-registry/scripts/skill_registry_ops.py
**Action:** When TAD packs need to mutate part of a resource (e.g., pack-registry.yaml entries), prefer PATCH-with-updateMask semantics over full-object replace. Example: `update --field name=foo,description=bar` modifies only those fields without overwriting the full entry.

## AC5 — MCP-Neutral Multi-Client Compatibility Statement
**Recommendation:** ✅ ADOPT for TAD packs that surface tools
**Evidence:** MEDIUM — explicit Claude Code/Codex/Gemini compatibility mentions in 3+ skills
**Source:** alloydb-basics, bigquery-basics, cloud-run-basics
**Action:** In TAD packs that integrate with AI agents, explicitly state cross-client compatibility:
- "This pack works with Claude Code, Codex, and Gemini CLI"
- Avoid vendor-lock language unless intentionally Gemini-only

## AC6 — Tier R/M/D Safety Classification with Typed Confirmation
**Recommendation:** 🟡 CONSIDER (for new TAD packs in destructive-op domains)
**Evidence:** WEAK — only 4/24 skills (17%) implement; agent-platform-* cluster only
**Source:** agent-platform-deploy, agent-platform-tuning-management, agent-platform-prompt-management, agent-platform-tuning
**Action:** For TAD packs that orchestrate destructive operations (e.g., delete data, drop tables, force-push), embed Tier R/M/D in SKILL.md:
- R (Read): no confirmation
- M (Mutate): "Confirm? (y/n)" — accept y/yes
- D (Destroy): "Type 'I confirm' to proceed" — string match
**Caveat:** Low coverage in Google's own repo. Tier D wording inconsistent across the 4 skills that use it ("I confirm" / "Yes, delete it" / "Yes, cancel it"). TAD should pick ONE canonical string.
**Related:** TAD already has Gate 4 human approval — Tier D could be a per-operation analog WITHIN a handoff.

## AC7 — Phase 0 Environment Initialization Section
**Recommendation:** 🟡 CONSIDER (for TAD packs requiring specific environments)
**Evidence:** WEAK — only 4/24 skills (17%) include explicit "Phase 0"
**Source:** agent-platform-{prompt,tuning,rag-engine,tuning}-management
**Action:** For TAD packs that require specific env setup (venv, API enablement, auth), add an explicit "Phase 0" section to SKILL.md. Forces agent to verify env BEFORE operational phases.
**Caveat:** Many Google skills skip Phase 0 entirely (they use "Quick Start" / "Setup" / "Mandatory prerequisites"). Naming is convention-only.

## AC8 — Workflow Decision Trees with STOP/Yield Directives
**Recommendation:** 🟡 CONSIDER (for TAD packs with branching workflows)
**Evidence:** WEAK — only 3/24 skills (13%) use formal decision trees
**Source:** agent-platform-tuning, agent-platform-tuning-management, agent-platform-rag-engine-management
**Action:** For complex multi-path TAD workflows, embed decision trees with explicit STOP commands:
- "If user didn't specify X: **STOP**. Ask user for X. Do NOT execute any tools in this turn. Yield."
**Caveat:** TAD's Socratic Inquiry already serves a similar purpose. Decision trees might be redundant or could complement Socratic for runtime branching (vs. design-time elicitation).

## AC9 — Explicit SDK/Tool Deprecation Bans (Anti-Hallucination Guardrails)
**Recommendation:** ✅ ADOPT when applicable
**Evidence:** MEDIUM — 2/24 strict bans, 9/24 general "DO NOT use" in description
**Source:** gemini-api/SKILL.md, gemini-interactions-api/SKILL.md + 9 others via description fields
**Action:** When TAD packs target tools that have legacy alternatives the LLM may know better (e.g., older API versions, deprecated SDKs), include explicit:
- "DO NOT use {old_thing}"
- "Legacy {X} is strictly unsupported"
- "Your knowledge is outdated; use {new_thing} only"
**Rationale:** LLMs have training bias toward older common tools. Explicit negative constraints force-override pretrained preferences.

## AC10 — "Related Skills" Cross-Reference Pattern (NOT declarative depends_on)
**Recommendation:** 🟡 CONSIDER (informal text refs, not formal field)
**Evidence:** MEDIUM — text-based cross-refs found in gemini-agents-api, bigquery-basics, firebase-basics
**Source:** Multiple SKILL.md "Related Skills" blocks
**Action:** TAD packs can document related-pack relationships in body text (not frontmatter). Format: `Related Skills: [pack-name](path/to/pack)`.
**Caveat:** Google does NOT use declarative `depends_on` frontmatter — only informal pointers. TAD's CONSUMES/PRODUCES pattern is more structured. Don't downgrade.

## AC11 — Universal "Developer Knowledge MCP Server" Retrieval Fallback Pattern
**Recommendation:** 🟡 DEFER (analog already exists in TAD via NotebookLM)
**Evidence:** MEDIUM — 7/24 skills reference it; implementation details NOT in public repo
**Source:** alloydb-basics, bigquery-basics, cloud-run-basics, firebase-basics, gke-basics, gemini-api
**Action:** TAD's `*research-notebook` provides similar retrieval-augmented help. Document this pattern as a TAD-specific best practice: when a pack's local docs are insufficient, suggest using the NotebookLM notebook tied to the pack's domain (per pack's `research_notebook_awareness`).
**Caveat:** Google's Developer Knowledge MCP server implementation is NOT public — we don't know how it's built. TAD's NotebookLM-based approach is functional equivalent without needing to build new infra.

## AC12 — AVOID: Inconsistent Tier D Coverage in Destructive Scripts (Google's Defect)
**Recommendation:** ❌ AVOID — TAD must NOT replicate
**Evidence:** STRONG — `agent-platform-skill-registry/scripts/skill_registry_ops.py` has destructive `requests.delete()` but `agent-platform-skill-registry/SKILL.md` has NO Tier D / typed-confirm directives
**Source:** Phase 4c Re-Ask 2 analysis
**Action:** **EVERY TAD pack that contains destructive scripts MUST have governance in SKILL.md** specifying user-confirmation requirements BEFORE script invocation. This is the script-as-headless-API contract. Google violates this in `agent-platform-skill-registry` — TAD must not.
**Rationale:** Script-as-headless-API is a defensible architectural choice ONLY IF the governing SKILL.md enforces the safety contract at the agent layer.

## AC13 — AVOID: Centralized auth_handler Module
**Recommendation:** ❌ AVOID — keep each TAD pack self-contained
**Evidence:** MEDIUM — Google has zero unified auth_handler module; possibly a Copybara artifact
**Source:** All scripts analyzed in Phase 4 Seed 2
**Action:** TAD should NOT create a shared auth/common module across packs. Each pack handles its own auth (matches Google's pattern + supports TAD's CONSUMES/PRODUCES isolation).
**Caveat:** If multiple TAD packs need identical auth logic, prefer DRY at the level of generating template code (install-time), not runtime shared library.

---

## Summary Table

| # | AC | Recommendation | Evidence | Coverage in Google |
|---|----|----|----------|---------------------|
| 1 | Minimal frontmatter (`name`+`description`) | ✅ Adopt (already done) | STRONG | 100% |
| 2 | Optional frontmatter (`license`, `version`, `compatibility`) | 🟡 Consider | WEAK | 1-2/24 |
| 3 | Python script I/O contract (argparse + ADC + exit) | ✅ Adopt | STRONG | 4/4 scripts analyzed |
| 4 | updateMask atomic PATCH | ✅ Adopt | STRONG | skill_registry_ops.py |
| 5 | MCP-neutral compatibility statement | ✅ Adopt | MEDIUM | 3+/24 |
| 6 | Tier R/M/D safety classification | 🟡 Consider | WEAK | 4/24 (17%) |
| 7 | Phase 0 env init section | 🟡 Consider | WEAK | 4/24 (17%) |
| 8 | Workflow Decision Trees with STOP/Yield | 🟡 Consider | WEAK | 3/24 (13%) |
| 9 | Explicit SDK deprecation bans | ✅ Adopt when applicable | MEDIUM | 2-9/24 |
| 10 | "Related Skills" text cross-refs | 🟡 Consider | MEDIUM | Multiple |
| 11 | Knowledge MCP retrieval fallback | 🟡 Defer (TAD has analog) | MEDIUM | 7/24 |
| 12 | AVOID: Destructive script without SKILL.md governance | ❌ Avoid | STRONG | Google defect |
| 13 | AVOID: Centralized auth_handler | ❌ Avoid | MEDIUM | Possibly Copybara artifact |

## TAD ↔ Google Comparison Matrix (Q8 deliverable)

| Dimension | TAD Capability Pack | Google Skill | Compatibility |
|-----------|---------------------|--------------|---------------|
| **Metadata format** | YAML frontmatter (`name`, `description` + various) | YAML frontmatter (`name`, `description` + optional) | **COMPATIBLE** — both minimal required fields match |
| **Loading flow** | install.sh → .claude/skills/ filesystem; pack-registry.yaml index | Copy to skills/ + register via REST API (`v1beta1/.../skills`) | **DIVERGENT** — TAD filesystem-only; Google has runtime registry |
| **State management** | Optional session.json (deep-skill pattern) | Stateless per skill (state lives in GCP resources) | **MOSTLY COMPATIBLE** — both default stateless |
| **Script execution** | Per-pack scripts (e.g., install.sh) | scripts/*.py and scripts/*.sh per skill | **COMPATIBLE** — both filesystem-based |
| **Security model** | Gate 4 acceptance + project-knowledge rules + cognitive firewall | Tier R/M/D in SKILL.md (4/24 cluster) + agent-layer confirmation contract | **PARTIAL** — TAD has gate-level safety; Google has per-operation typed-confirm |
| **Templating/scaffolding** | install.sh per pack; no central template tool | `agent-platform-skill-registry/references/generate-skill.md` (agent-prompt-based template) | **DIVERGENT** — TAD has install.sh; Google has agent-driven skill generation |
| **Versioning strategy** | Pack version in pack-registry.yaml entries; semver | `revisions/{revision_id}` via REST API | **DIVERGENT** — TAD file-based; Google runtime-versioned |

**Top 3 Borrowable Patterns (Q9 deliverable, after coverage adjustment):**

1. **#1 Borrowable: Script I/O Contract (AC3)** — STRONG evidence, low cost, high consistency improvement for TAD pack scripts
2. **#2 Borrowable: MCP-Neutral Compatibility Statement (AC5)** — MEDIUM evidence, near-zero cost, immediate cross-vendor signal
3. **#3 Borrowable: Explicit Deprecation Bans (AC9)** — MEDIUM evidence, low cost, anti-hallucination value

**Top Avoid:**
1. **#1 Avoid: AC12** — destructive-script-without-SKILL.md-governance defect
2. **#2 Avoid: AC13** — centralized auth_handler (possibly Copybara artifact, not architectural choice)
