# Pack Build Rules Patterns (Layer 2)

> Reusable patterns for capability pack architecture, design, build process, and rule sourcing.

---

### Standalone Agent Command Pattern - 2026-02-08
- **Discovery**: When a workflow grows beyond ~100 lines with distinct skills, extract to standalone command with own persona and output-only integration (DESIGN-SPEC.md). Terminal isolation preserved. Supersedes: Style Library Architecture (same date — usage guidance pattern).
- **Action**: Extract sub-phases with >100 lines and distinct skill profiles to standalone commands.

### Domain Pack Architecture Patterns - 2026-04-02
- **Discovery**: (1) Type A/B/Mixed step models: Document=search→analyze→derive→generate, Code=select→execute→verify→optimize, Mixed=human-AI 4D Protocol. (2) Declare tool availability boundaries explicitly. (3) Workflow steps > quality criteria text for improving pack quality. (4) Each capability judged independently — same pack can mix types.
- **Action**: Classify capabilities as A/B/Mixed first. Require ≥1 new step per research task. Declare platform scope.

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

### Capability Pack: Architecture Spectrum - 2026-05-08
- **Discovery**: Three patterns: (1) Reference-based (thin router + `references/*.md` judgment rules), (2) Deep-skill (3 interconnected SKILLs with session.json cross-skill state), (3) Orchestration-router (state-machine router with phase transitions and gates). Judgment rules → reference-based. Structured interaction → deep-skill. Workflow orchestration → router.
- **Action**: Classify pack type before starting. Classification determines file structure and content distribution.

### Capability Pack: Design and Build Rules - 2026-05-07
- **Discovery**: (1) Multi-agent install: `--agent` flag + Phase N stubs from Phase 1. (2) 3-skill deep design > 40 thin templates — interaction contracts + session.json state flow + product type adapters. (3) Rule sourcing: MUST read the cited source, not just the citation. Research findings = what to COVER, not what to SAY. (4) CONSUMES/PRODUCES interface contract between packs. (5) Write to project root first, session dir only on gate approval. (6) Use cost ratios not absolute prices (stable across years). Codex-edition SKILLs MUST follow strip-only rule to prevent drift.
- **Action**: Read cited sources before writing rules. Verify API parameter names against official docs. Declare CONSUMES/PRODUCES.

### Capability Pack: Specific Technical Rules - 2026-05-07
- **Discovery**: (1) Kubernetes: preStop sleep is MANDATORY for zero-downtime (SIGTERM-readiness race). Any K8s checklist MUST include the preStop pattern. (2) Dual-agent security (CaMeL): parser has zero tools AND planner treats parser output as typed data — MUST NOT treat as instructions. (3) Parallel tool-call atomic boundary: compression boundaries MUST fall between fully resolved assistant turns. (4) FFmpeg `sidechaincompress` attack/release in milliseconds, not seconds. (5) Quick Rule Index needs exact heading match. (6) Saturation detection: three states (SATURATED/DIMINISHING/CONTINUE), minimum threshold, consecutive rounds.
- **Action**: preStop hook for K8s. Typed schema for dual-agent output. Three-state saturation detection.

### Research-Methodology Pack as Capability Pack Factory - 2026-05-08
- **Discovery**: Plan→Source→Curate→Analyze→Output pipeline produces higher-quality rules than ad-hoc WebSearch. Persistent notebook enables cross-source synthesis with citations. Eliminates "rules from training data intuition" failure mode.
- **Action**: Run research-methodology as Phase 0 for capability packs involving external APIs or cross-vendor comparisons.

### Source Citation Integrity for Adapted Values - 2026-05-28
- **Context**: Phase 2 academic-research pack build. Code-reviewer P0 finding: tool-call thresholds were adapted from ScienceClaw SCIENCE.md (5/30/60/100+) to ranges (3-5/20-40/40-80/80+) per tad-mapping-blueprint.md Decision 6, but "> Source:" citations referenced only SCIENCE.md lines — omitting the adaptation step.
- **Discovery**: When a TAD mapping blueprint adjusts raw source values, the "> Source:" citation must reference BOTH the original source AND the adaptation document. Citing only the original creates false provenance — a user tracing the citation finds different numbers. This is the zero-hallucination principle applied to the pack's own build process. The code-reviewer caught this because the pack's content rules (zero-hallucination.md) require every claim to trace to its actual source.
- **Action**: For capability pack builds that adapt external source material via an intermediate analysis document (tad-mapping-blueprint, architecture-analysis), always cite "Adapted from [original source], adjusted per [adaptation document]". Apply this rule during Alex's AC dry-run step (§9.2 verification).
- **Grounded in**: .tad/evidence/reviews/blake/academic-research-pack-phase2/code-review.md (P0-1)

### Per-Tool Numeric Thresholds Require Research Provenance, Not Interpolation - 2026-05-28
- **Context**: AI voice production pack build. Code-reviewer P0-1: voice-cloning.md duration table included fabricated per-tool minimums (OpenVoice V2 10s, VoxCPM2 10s, Fish S2 Pro 10s) attributed to research but not present in research data. The baseline report mentioned "10-30 seconds" as a generic zero-shot cloning range, which was incorrectly split into per-tool entries.
- **Discovery**: When a research source provides a general range (e.g., "10-30 seconds for zero-shot cloning"), it is NOT valid to assign specific values from that range to individual tools as if they were independently measured. The research separately measured minimums for 7 specific tools (Qwen3-TTS 3s, NeuTTS Air 3s, GPT-SoVITS 5s, VibeVoice 5s, XTTS-v2 6s, Chatterbox 10s, Kokoro 15s) — these are Category A numbers. The generic "10-30s" range is a Category A range for the METHOD, not for unlisted tools. Interpolating it into per-tool entries creates false provenance: the `> Source:` citation implies research measurement when none occurred.
- **Action**: When building capability pack tables with per-tool numeric columns: (1) Only include tools with individually measured values, (2) Add a footnote for tools without measurements referencing the general range, (3) Never split a method-level range into tool-specific entries. Apply this pattern to any future pack with tool comparison matrices.
- **Grounded in**: .tad/evidence/reviews/blake/ai-voice-production-pack/code-review.md (P0-1)

### Reading provenance rules ≠ following them during pack builds - 2026-05-29
- **Context**: Building ml-training capability pack. Handoff §12 Project Knowledge explicitly cited "Per-Tool Numeric Thresholds Require Research Provenance, Not Interpolation" from architecture.md. Despite reading this rule, Blake fabricated 7 numbers across 5 reference files (full fine-tune VRAM 60-120GB, GPT-SoVITS ~8-12GB, Lambda pricing $1.10-2.49/hr, VoxCPM2 recommended data 10-30 min, dataset Recommended column, base model selection table).
- **Discovery**: Citing a provenance rule in the handoff is necessary but not sufficient. The builder still interpolates from LLM training data when the research file has a gap, especially for "obvious" numbers that feel correct. Active per-number cross-referencing during writing — not just reading the rule beforehand — is needed. The failure pattern: research provides a range for the METHOD → builder assigns specific numbers to individual TOOLS within that range.
- **Action**: For capability pack builds, add a mandatory self-check step: after writing each reference file, grep for all numeric values and verify each against deep-ask-findings.md. Numbers not found → mark as "data not available from research — verify before use" rather than interpolating.
- **Grounded in**: HANDOFF-20260529-ml-training-build.md, code-reviewer P0-1 through P0-7

### Pack Scope Boundaries - inception
- **Discovery**: supply-chain-security: "Should I trust this dependency?" — pre-install analysis. code-security: "Does my code have vulnerabilities?" — SAST + DAST + secrets + IaC. security-monitoring (planned): "Are my existing deps still safe?" — post-install continuous scanning. compliance (planned): "Can I prove I meet the policy?" — policy-as-code + audit evidence.
- **Action**: Maintain clear scope boundaries between security packs to avoid overlap confusion.

### Key Tool Insight: litellm-class Attack Detection - inception
- **Discovery**: Only **Socket CLI** detects behavioral changes between package versions (network calls, fs writes, eval usage). All CVE-only scanners (osv-scanner, pip-audit, cargo-audit) are blind to zero-day supply chain poisoning. Context: User survived litellm 1.82.7/1.82.8 PyPI poisoning (2026-03-24) by being on 1.82.6.
- **Action**: For supply chain security, require behavioral analysis tools (Socket CLI), not just CVE scanners.

### Security Packs Use Cross-Cutting Review Pattern - 2026-04-04
- **Context**: Building supply-chain-security.yaml and code-security.yaml
- **Discovery**: A single top-level review persona (Security Engineer) is more appropriate than per-capability reviewers for security packs, because the same security engineer reviews all capabilities in one audit pass
- **Action**: Future security packs should use one top-level review section, not per-capability reviewers

### Compliance CLI vs SaaS Boundary - 2026-04-03
- **Context**: Phase 0 research on compliance domain tools
- **Discovery**: CLI tools cover ~60% of SOC2 technical controls. Organizational processes (auditor portal, vendor risk, HR compliance) require SaaS platforms (Drata/Vanta). A compliance Domain Pack must declare this boundary explicitly.
- **Action**: If compliance pack is built, declare "CLI covers technical proof only" in description

### Cross-Domain Tool Overlap is Intentional - 2026-04-03
- **Context**: nuclei, checkov, syft appear in multiple domain packs
- **Discovery**: Same tool serves different purposes per domain (e.g., nuclei = DAST in code-security, network scanning in monitoring; checkov = IaC lint in code-security, compliance proof in compliance)
- **Action**: Don't deduplicate tools across packs — document the different usage context per pack
