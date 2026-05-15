---
task_type: mixed
e2e_required: no
research_required: yes
git_tracked_dirs: [".tad/capability-packs/ai-evaluation"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: ai-evaluation Capability Pack (Research-Driven Build)

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-05-15
**Project:** TAD
**Task ID:** TASK-20260515-001
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260507-agent-capability-packs.md (Phase 1g/11)

---

## 🔴 Gate 2: Design Completeness

**执行时间**: 2026-05-15

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Hybrid reference-based: 5 judgment-rule refs + 2 structured workflow refs |
| Components Specified | ✅ | CAPABILITY.md (main) + references/ + install.sh |
| Functions Verified | ✅ | NotebookLM CLI, scan-packs.sh, install.sh pattern all exist |
| Data Flow Mapped | ✅ | Research findings → pack build → scan-packs.sh → install → verify |

**Gate 2 结果**: ✅ PASS (expert review P0s resolved — see §9.2)

**Alex确认**: 我已验证所有设计要素，Blake可以独立根据本文档完成实现。

---

## 📋 Handoff Checklist (Blake必读)

- [ ] 阅读了所有章节
- [ ] 阅读了「📚 Project Knowledge」章节中的历史经验
- [ ] 理解了 Capability Pack vs Domain Pack 的区别
- [ ] 确认 /capability-upgrade SKILL 可用
- [ ] **确认研究发现文件存在且充分（AC0 gate）**

---

## 1. Task Overview

Build the ai-evaluation capability pack using the **research-driven /capability-upgrade 5-stage methodology** — the same process that produced all 8 existing packs (web-ui-design with 73 sources, web-frontend with 299 sources, etc.).

**This is NOT a Domain Pack YAML format conversion.** The YAML file (`.tad/domains/ai-evaluation.yaml`, 877 lines) is a starting point for understanding scope, but the pack's judgment rules must come from deep research — GitHub repos, real evaluation frameworks, academic papers on agent evaluation, and tool documentation.

**Source YAML capabilities (7):** eval_framework_design, benchmark_testing, ab_testing, regression_testing, adversarial_testing, automated_pipeline, human_eval_protocol.

## 2. Methodology: /capability-upgrade 5-Stage

Follow `.claude/skills/capability-upgrade/SKILL.md` exactly. Summary:

### Stage 1: Assessment (30 min)
- Read `.tad/domains/ai-evaluation.yaml` completely
- Determine AI agent capability boundaries for evaluation tasks
- Confirm capability list with user (which to keep, merge, add, remove)

### Stage 2: GitHub-First Deep Research (1-2 hours)
**⚠️ Research Execution Note:** Research is completed BEFORE this handoff reaches Blake. The research findings are saved to `.tad/evidence/research/ai-evaluation-capability-pack/`. Blake MUST verify this file exists and contains ≥30 source entries and ≥3 deep-ask rounds before proceeding to Stage 3. If findings are absent or insufficient → STOP and escalate to Alex.

- Phase 0: Research plan — per-capability questions with specificity anchors
- Phase 1: GitHub sourcing (awesome-lists → sub-pages → company repos → tool repos)
  - Key repos: promptfoo, deepeval, langfuse, ragas, giskard, trulens, deepteam, confident-ai
  - Target: ≥30 curated sources (≥3 per capability minimum)
- Phase 2: Auto-curate (remove errors + dedup + tier)
- Phase 3: Deep ask — ≥3 rounds, per-capability questions
- Phase 4: Gap backfill (deep research ONLY for gaps)

### Stage 3: Design (1 hour)
- Pack architecture: **Hybrid reference-based** (see §3 Architecture Decision)
- Design CAPABILITY.md router + reference file grouping
- Expert review of design

### Stage 4: Build (2-4 hours)
- Write CAPABILITY.md (< 5,000 tokens, YAML frontmatter with `name:` + `description:` MANDATORY)
- Write reference files: judgment-rule references (AKU format) + structured workflow references
- Reference files MAY use structured formats (tables, YAML blocks) for rubric specifications — not just prose "when X, do Y" rules
- Write install.sh with `--force` and `--dry-run` support (clone from existing pack, adapt paths)
- After build: run `bash .tad/scripts/scan-packs.sh` to regenerate pack-registry.yaml

### Stage 5: Verification
- `bash install.sh --agent=claude-code --force` → exit 0
- `head -3 .claude/skills/ai-evaluation/SKILL.md | grep -q "^name:"` → exit 0
- Token count check: `wc -w .tad/capability-packs/ai-evaluation/CAPABILITY.md` < 3,500 words

## 3. Architecture Decision: Hybrid Reference-Based

| Capability | Type | Reference Pattern | Why |
|-----------|------|-------------------|-----|
| benchmark_testing | Type B (Code) | Judgment rules | "when X, use Y tool" decisions |
| ab_testing | Type B (Code) | Judgment rules | Tool selection + statistical rules |
| regression_testing | Type B (Code) | Judgment rules | Baseline management + drift thresholds |
| adversarial_testing | Type B (Code) | Judgment rules | Red-team patterns + tool selection |
| automated_pipeline | Type B (Code) | Judgment rules | CI/CD integration patterns |
| eval_framework_design | Type A (Document) | **Structured workflow** | 5-step dimensional analysis + rubric derivation — sequential reasoning, not flat rules |
| human_eval_protocol | Type Mixed (4D) | **Structured workflow** | Inter-rater calibration + iterative rounds — inherently interactive |

**Result:** 5 judgment-rule reference files + 2 structured workflow reference files. All within the reference-based pattern's budget (web-backend already has 8 reference files). No escalation to deep-skill needed.

Other decisions:

| # | Decision | Chosen | Rationale |
|---|----------|--------|-----------|
| 1 | Token budget | < 5,000 | AKU research: optimal density |
| 2 | Research depth | ≥30 sources, ≥3 rounds | Raised from 20 per BA-P1-1 (7 capabilities need ≥3 sources each) |
| 3 | determinismLevel | Preserve from YAML | Critical metadata for eval runner sample counts |
| 4 | Registry update | scan-packs.sh (auto-gen) | pack-registry.yaml is auto-generated, not manually edited |

## 4. Files to Create

| # | File | Purpose |
|---|------|---------|
| 1 | `.tad/capability-packs/ai-evaluation/CAPABILITY.md` | Main file: router + frontmatter + keywords + CONSUMES/PRODUCES |
| 2 | `.tad/capability-packs/ai-evaluation/install.sh` | Cross-agent installer (with --force + --dry-run) |
| 3 | `.tad/capability-packs/ai-evaluation/references/benchmark-rules.md` | Judgment rules: benchmark + AB testing |
| 4 | `.tad/capability-packs/ai-evaluation/references/regression-rules.md` | Judgment rules: baseline management + drift detection |
| 5 | `.tad/capability-packs/ai-evaluation/references/adversarial-rules.md` | Judgment rules: red-team + deepteam/promptfoo-redteam tools |
| 6 | `.tad/capability-packs/ai-evaluation/references/pipeline-rules.md` | Judgment rules: CI/CD + automation patterns |
| 7 | `.tad/capability-packs/ai-evaluation/references/eval-framework-workflow.md` | **Structured workflow**: dimensional analysis → rubric derivation (5-step) |
| 8 | `.tad/capability-packs/ai-evaluation/references/human-eval-protocol.md` | **Structured workflow**: 4D Protocol calibration + statistical analysis |
| 9 | `.tad/capability-packs/ai-evaluation/LICENSE` | Apache 2.0 (same as prior packs) |
| 10 | `.tad/evidence/research/ai-evaluation-capability-pack/*.md` | Research findings (pre-populated before Blake starts) |

**Auto-generated (do NOT manually edit):** `.tad/capability-packs/pack-registry.yaml` — run `bash .tad/scripts/scan-packs.sh` after creating CAPABILITY.md

**Modify:** `.tad/research-notebooks/REGISTRY.yaml` — add notebook entry with id, notebook_id (captured at creation time), topic, source_count, notes. Follow existing entry format.

## 5. Acceptance Criteria

- [ ] AC0 (Gate): Research findings file exists at `.tad/evidence/research/ai-evaluation-capability-pack/` AND contains ≥30 source entries AND ≥3 deep-ask round results. **Blake MUST verify BEFORE entering Stage 3. If insufficient → STOP.**
- [ ] AC1: CAPABILITY.md has YAML frontmatter with `name:` and `description:` fields
  - Verify: `head -5 .tad/capability-packs/ai-evaluation/CAPABILITY.md | grep -q "^name:"`
- [ ] AC2: CAPABILITY.md word count < 3,500 (proxy for < 5,000 tokens)
  - Verify: `wc -w .tad/capability-packs/ai-evaluation/CAPABILITY.md`
- [ ] AC3: All confirmed capabilities have corresponding rules/workflows in references/
  - Verify: `for cap in eval_framework benchmark ab_test regression adversarial pipeline human_eval; do grep -rl "$cap" .tad/capability-packs/ai-evaluation/references/ || echo "MISSING: $cap"; done`
- [ ] AC4: Each reference file has ≥3 concrete decision rules or workflow steps
- [ ] AC5: Tool bindings present: promptfoo (benchmark/AB/regression/pipeline), deepeval (Python alternative), deepteam/promptfoo-redteam (adversarial). Other tools (langfuse, ragas) documented where applicable
  - Verify: `grep -r "promptfoo\|deepeval\|deepteam" .tad/capability-packs/ai-evaluation/references/ | wc -l` ≥ 5
- [ ] AC6: Each evaluation rubric rule carries determinismLevel annotation (deterministic / semi-deterministic / non-deterministic)
  - Verify: `grep -c 'deterministic' .tad/capability-packs/ai-evaluation/references/*.md` ≥ 3
- [ ] AC7: install.sh runs successfully
  - Verify: `bash .tad/capability-packs/ai-evaluation/install.sh --agent=claude-code --force; echo $?` → 0
- [ ] AC8: Post-install frontmatter check
  - Verify: `head -3 .claude/skills/ai-evaluation/SKILL.md | grep -q "^name:"`
- [ ] AC9: pack-registry.yaml entry auto-generated
  - Verify: `bash .tad/scripts/scan-packs.sh && grep "ai-evaluation" .tad/capability-packs/pack-registry.yaml`
- [ ] AC10: CAPABILITY.md contains CONSUMES/PRODUCES interface declaration

## 6. Important Notes

### Anti-Patterns
- ⚠️ **10 GitHub repos > 350 deep research articles** — source quality > quantity
- ⚠️ **Research findings = what to COVER, not what to SAY** — read sources, derive rules
- ⚠️ **AKU format is prescriptive** — "when X, do Y" not "X is important"
- ⚠️ **determinismLevel is load-bearing** — tells eval runner how many samples to draw
- ⚠️ **Structured formats OK for rubrics** — tables/YAML blocks within reference .md files are allowed (don't force rubric data into prose)
- ⚠️ **Judge=Optimizer bias** (from source YAML ab_testing anti-pattern) — cross-cutting rule, surface in CAPABILITY.md router, not buried in one reference file
- ⚠️ **"Mocks Hide SDK Shape Validation"** — preserve this evidence-grounded anti-pattern verbatim in benchmark rules

### 📚 Project Knowledge (Blake 必读)
- **Capability Pack: YAML Frontmatter is Load-Bearing** (architecture.md) — `name:` + `description:` MUST exist or skill never activates
- **Capability Pack: Architecture Spectrum** (architecture.md) — reference-based = thin router + references/; structured interaction → deep-skill (but hybrid stays within reference-based budget)
- **Capability Pack: Design and Build Rules** (architecture.md) — read cited sources, not just citations. Declare CONSUMES/PRODUCES.
- **Research Methodology** (feedback_research-methodology.md) — GitHub-First sourcing per /capability-upgrade Stage 2

### 9.2 Expert Review Status

| Reviewer | Type | Verdict | P0 Count | Key Findings |
|----------|------|---------|----------|-------------|
| code-reviewer | CR | CONDITIONAL PASS | 3 | CAPABILITY.md naming, scan-packs.sh auto-gen, YOLO ambiguity |
| backend-architect | BA | CONDITIONAL PASS | 3 | Architecture mismatch (hybrid fix), research gate, AC verification |

**P0 Resolution:**
| P0 | Resolution | Section |
|----|-----------|---------|
| CR-P0-1 (naming) | All references changed to CAPABILITY.md in pack dir, SKILL.md only at install target | §4, §5 AC1/AC2 |
| CR-P0-2 (registry) | Changed to `bash .tad/scripts/scan-packs.sh` | §2 Stage 4, §4, §5 AC9 |
| CR-P0-3 + BA-P0-2 (research clarity) | Added AC0 gate + explicit "research completed before Blake starts" note | §2 Stage 2, §5 AC0 |
| BA-P0-1 (architecture) | Hybrid: 5 judgment-rule + 2 structured workflow refs | §3, §4 file table |
| BA-P0-3 (AC verification) | Added grep commands for AC3, AC5, AC6 | §5 |

**P1 Addressed:**
| P1 | Resolution |
|----|-----------|
| BA-P1-1 (source floor) | Raised to ≥30 sources with ≥3/capability | §2, §5 AC0 |
| BA-P1-2 (determinismLevel AC) | Added AC6 | §5 |
| BA-P1-3 (structured rubric format) | Added explicit note allowing tables/YAML in refs | §6 |
| BA-P1-4 (tool scope) | Expanded AC5 to include deepteam, ragas, langfuse | §5 |
| CR-P1-1 (LICENSE) | Added LICENSE to file table | §4 |
| CR-P1-4 (--dry-run) | Added to install.sh requirements | §2 Stage 4 |

### Required Evidence Manifest
```yaml
evidence:
  research_findings: ".tad/evidence/research/ai-evaluation-capability-pack/"
  expert_reviews: ".tad/evidence/reviews/blake/capability-pack-ai-evaluation/"
  completion: ".tad/active/handoffs/COMPLETION-20260515-capability-pack-ai-evaluation.md"
  blake_reviews: "≥2 distinct reviewer types"
  knowledge_updates: ".tad/project-knowledge/ (if discoveries)"
```
