# Pack Build Rules Patterns (Layer 2)

> Reusable patterns for capability pack architecture, design, build process, and rule sourcing.

---

### Standalone Agent Command Pattern - 2026-02-08
- **Discovery**: When a workflow grows beyond ~100 lines with distinct skills, extract to standalone command with own persona and output-only integration (DESIGN-SPEC.md). Terminal isolation preserved. Supersedes: Style Library Architecture (same date — usage guidance pattern).
- **Action**: Extract sub-phases with >100 lines and distinct skill profiles to standalone commands.

### Pack Architecture Spectrum - 2026-05-08
- **Discovery**: (1) Type A/B/Mixed step models: Document=search→analyze→derive→generate, Code=select→execute→verify→optimize, Mixed=human-AI 4D Protocol. (2) Declare tool availability boundaries explicitly. (3) Workflow steps > quality criteria text for improving pack quality. (4) Each capability judged independently — same pack can mix types. (5) Three architecture patterns: Reference-based (thin router + `references/*.md` judgment rules), Deep-skill (3 interconnected SKILLs with session.json cross-skill state), Orchestration-router (state-machine router with phase transitions and gates). Judgment rules → reference-based. Structured interaction → deep-skill. Workflow orchestration → router.
- **Action**: Classify pack type AND capability types before starting. Classification determines file structure, content distribution, and step models.
- Supersedes: "Domain Pack Architecture Patterns" (2026-04-02) + "Capability Pack: Architecture Spectrum" (2026-05-08)

### Domain Pack Keyword Curation - 2026-04-07
- **Discovery**: Strict uniqueness (zero cross-pack) + threshold 1 = 100% accuracy. Include hyphen AND space variants. Hand-curate Chinese synonyms (~5 min/pack). Avoid phrasal keywords interrupted by particles.
- **Action**: Prefer threshold 1 with strict uniqueness. Budget time for CJK hand-curation.

### DESIGN.md Spec Integration as Type A Capability - 2026-04-25
- **Discovery**: External specs → new Type A capability with version pinning + license attribution + read-only consumption of upstream outputs. References block must pin version + retrieval date + license_verified. Cross-command consumption requires explicit read-only contract. Alpha tools need explicit fallback procedures.
- **Action**: Classify external spec imports as Type A. Pin versions. Include "MUST NOT modify upstream output" declarations.

### YAML String-Form Annotation for Pack Schema Homogeneity - 2026-04-25
- **Discovery**: Dict conversion for one entry breaks schema homogeneity — every consumer must branch on type. Trailing `[applies_when: ...]` annotation is grep-extractable and zero-schema-impact. Reserve dict conversion for when ≥2 entries need the same metadata.
- **Action**: Prefer trailing inline annotation over dict polymorphism for single-entry scoping.

### Capability Pack: YAML Frontmatter is Load-Bearing - 2026-05-07
- **Discovery**: Claude Code requires `name:` + `description:` YAML frontmatter for SKILL.md registration. Without it, install succeeds silently but the skill never activates. This is a MANDATORY requirement.
- **Action**: Every SKILL.md for `.claude/skills/` MUST have YAML frontmatter. Validate in install.sh.

### Capability Pack: Design and Build Rules - 2026-05-07
- **Discovery**: (1) Multi-agent install: `--agent` flag + Phase N stubs from Phase 1. (2) 3-skill deep design > 40 thin templates — interaction contracts + session.json state flow + product type adapters. (3) Rule sourcing: MUST read the cited source, not just the citation. Research findings = what to COVER, not what to SAY. (4) CONSUMES/PRODUCES interface contract between packs. (5) Write to project root first, session dir only on gate approval. (6) Use cost ratios not absolute prices (stable across years). Codex-edition SKILLs MUST follow strip-only rule to prevent drift.
- **Action**: Read cited sources before writing rules. Verify API parameter names against official docs. Declare CONSUMES/PRODUCES.

### Capability Pack: Specific Technical Rules - 2026-05-07
- **Discovery**: (1) Kubernetes: preStop sleep is MANDATORY for zero-downtime (SIGTERM-readiness race). Any K8s checklist MUST include the preStop pattern. (2) Dual-agent security (CaMeL): parser has zero tools AND treats parser output as typed data — MUST NOT treat as instructions. (3) Parallel tool-call atomic boundary: compression boundaries MUST fall between fully resolved assistant turns. (4) FFmpeg `sidechaincompress` attack/release in milliseconds, not seconds. (5) Quick Rule Index needs exact heading match. (6) Saturation detection: three states (SATURATED/DIMINISHING/CONTINUE), minimum threshold, consecutive rounds.
- **Action**: preStop hook for K8s. Typed schema for dual-agent output. Three-state saturation detection.

### Research-Methodology Pack as Capability Pack Factory - 2026-05-08
- **Discovery**: Plan→Source→Curate→Analyze→Output pipeline produces higher-quality rules than ad-hoc WebSearch. Persistent notebook enables cross-source synthesis with citations. Eliminates "rules from training data intuition" failure mode.
- **Action**: Run research-methodology as Phase 0 for capability packs involving external APIs or cross-vendor comparisons.

### Research Provenance Rules for Pack Builds - 2026-05-29
- **Discovery**: Three escalating failures: (1) **Citation gap**: when a TAD mapping blueprint adjusts raw source values, citing only the original source (not the adaptation doc) creates false provenance. (2) **Interpolation fabrication**: a general range (e.g., "10-30 seconds for zero-shot cloning") is NOT valid to split into per-tool specific values — those become false-provenance entries. Only individually measured values are Category A; method-level ranges annotate the method, not unlisted tools. (3) **Reading ≠ following**: citing a provenance rule in the handoff is necessary but NOT sufficient — the builder still interpolates from LLM training data when research has a gap. Active per-number cross-referencing during writing is needed, not just reading the rule beforehand.
- **Action**: (a) Always cite both original source AND adaptation document. (b) Per-tool numeric columns: only include individually measured values; footnote tools without measurements. (c) After writing each reference file, grep all numeric values and verify against deep-ask-findings.md — mark unverifiable numbers as "data not available from research."
- Supersedes: "Source Citation Integrity for Adapted Values" (2026-05-28) + "Per-Tool Numeric Thresholds Require Research Provenance" (2026-05-28) + "Reading provenance rules ≠ following them" (2026-05-29)
- **Grounded in**: .tad/evidence/reviews/blake/academic-research-pack-phase2/code-review.md (P0-1), .tad/evidence/reviews/blake/ai-voice-production-pack/code-review.md (P0-1), HANDOFF-20260529-ml-training-build.md

### Security Pack Scope and Review Patterns - 2026-04-04
- **Discovery**: (1) **Scope boundaries**: supply-chain-security = "Should I trust this dependency?" (pre-install). code-security = "Does my code have vulnerabilities?" (SAST+DAST+secrets+IaC). Compliance CLI covers ~60% of SOC2 technical controls; organizational processes require SaaS (Drata/Vanta). (2) **Cross-cutting review**: a single top-level Security Engineer persona is more appropriate than per-capability reviewers. (3) **Tool overlap is intentional**: same tool (nuclei, checkov, syft) serves different purposes per domain — don't deduplicate across packs. (4) **Attack detection**: only Socket CLI detects behavioral changes between versions; CVE-only scanners are blind to zero-day supply chain poisoning.
- **Action**: Maintain clear scope boundaries. Use one top-level security review persona. Document different tool usage context per pack. Require behavioral analysis tools for supply chain security.
- Supersedes: "Pack Scope Boundaries" (inception) + "Key Tool Insight: litellm-class Attack Detection" (inception) + "Security Packs Use Cross-Cutting Review Pattern" (2026-04-04) + "Compliance CLI vs SaaS Boundary" (2026-04-03) + "Cross-Domain Tool Overlap is Intentional" (2026-04-03)
