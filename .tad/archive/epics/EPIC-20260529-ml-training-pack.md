# Epic: ML Training Capability Pack (Cloud GPU + Human-AI Collaboration)

**Epic ID**: EPIC-20260529-ml-training-pack
**Created**: 2026-05-29
**Owner**: Alex
**Archived**: 2026-06-09
**Archive Reason**: User-directed archive. Phase 1 Research and Phase 2 Design + Build are complete; Phase 3 Validate + Dogfood remains planned and was not completed before archive.

---

## Objective
Build a cross-agent portable capability pack that gives AI agents the judgment rules and collaborative workflows for cloud GPU model training. The pack covers platform selection, LLM fine-tuning (LoRA/QLoRA), cost estimation, and a human-AI collaboration workflow where the agent operates cloud platforms (Colab/Kaggle) via Chrome MCP while the human handles authorization and file uploads.

## Success Criteria
- [ ] Pack installs in Claude Code and activates on training-related keywords
- [ ] 3 capabilities implemented: cloud GPU selection, LLM fine-tune workflow, cost estimation
- [ ] Human-AI collaboration workflow (Chrome MCP + cloud platform) documented as core pattern
- [ ] Dogfood: successfully used in Colin voice project for at least one cloud training session
- [ ] Anti-slop: specific numbers from research (platform limits, GPU specs, pricing) not generic advice
- [ ] Cross-agent portable: SKILL.md format works on Claude Code + Codex

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 1 | Research | ✅ Done | — (Alex-driven) | 14 sources, 8 deep-ask rounds, notebook 36711adf |
| 2 | Design + Build | ✅ Done | HANDOFF-20260529-ml-training-build.md | CAPABILITY.md + 5 refs + install.sh + ai-voice-production INTERFACE |
| 3 | Validate + Dogfood | ⬚ Planned | — | Expert review PASS + Colin project dogfood report |

### Phase Dependencies
All phases are sequential. Phase 2 depends on Phase 1 research findings. Phase 3 depends on Phase 2 built pack.

### Derived Status
Status and progress are computed from the Phase Map:
- **Status**: If all ⬚ → Planning | If any 🔄 or ✅ → In Progress | If all ✅ → Complete
- **Progress**: Count of ✅ Done / Total phases

---

## Phase Details

### Phase 1: Research

**Status:** ✅ Done
**Execution:** alex-driven (research is Conductor-side per TAD architecture)
**Completed:** 2026-05-29. 14 sources curated, 8 deep-ask rounds, notebook 36711adf.

#### Scope
Deep research on 3 areas: (1) Cloud GPU platforms — free and paid options, current limits/pricing/GPU models, (2) LLM fine-tuning — LoRA/QLoRA best practices, base model selection, data preparation, (3) Human-AI collaboration patterns for cloud training via browser MCP.

NOT in scope: voice-specific training (stays in ai-voice-production), image model training, model deployment/serving.

#### Input
- Existing Colin project dogfood experience (VoxCPM2 + GPT-SoVITS training on Colab via Chrome MCP)
- architecture.md "Cloud Compute Resource Awareness" entry (just created)
- ai-voice-production pack references (for anti-overlap analysis)

#### Output
- .tad/evidence/research/ml-training-pack/baseline-report.md
- .tad/evidence/research/ml-training-pack/ask-findings.md
- Platform comparison table with specific numbers (GPU type, VRAM, limits, pricing, last_verified dates)

#### Acceptance Criteria
- [ ] ≥15 research sources curated in NotebookLM notebook
- [ ] Platform comparison covers ≥3 free + ≥3 paid providers with specific GPU specs and pricing
- [ ] LoRA/QLoRA section covers base model selection for ≥4 model families (Qwen/LLaMA/Mistral/Gemma)
- [ ] MCP collaboration pattern documented from Colin project real experience
- [ ] All numeric claims have source citations (Category A traceability)

#### Files Likely Affected
- .tad/evidence/research/ml-training-pack/ (CREATE — research output directory)
- .tad/research-notebooks/REGISTRY.yaml (MODIFY — add new notebook entry)

#### Dependencies
None — first phase.

---

### Phase 2: Design + Build

**Status:** ✅ Done
**Execution:** blake-handoff
**Completed:** 2026-05-29. 7 files created + 1 modified. 59 source citations. 7 P0 fabricated numbers fixed. Commit 2ab17b3.

#### Scope
Design and build the capability pack: SKILL.md (router + decision tree), 4-5 reference files (platform-selection.md, lora-finetune.md, cost-estimation.md, mcp-collaboration.md, optional: data-preparation.md), and install.sh. Follow reference-based pack architecture (same pattern as ai-voice-production, ai-evaluation).

NOT in scope: building actual training notebooks (those are project-specific artifacts, not pack content). The pack provides judgment rules, not runnable code.

#### Input
- Phase 1 research findings (all evidence files)
- Existing pack architecture patterns (.claude/skills/ai-voice-production/ as template)
- Colin project dogfood notes (MCP collaboration workflow)

#### Output
- .tad/capability-packs/ml-training/CAPABILITY.md
- .tad/capability-packs/ml-training/install.sh
- .tad/capability-packs/ml-training/references/*.md (4-5 files)

#### Acceptance Criteria
- [ ] SKILL.md has YAML frontmatter (name + description — required for Claude Code activation)
- [ ] Context detection table covers ≥8 trigger keywords (Chinese + English)
- [ ] Decision entry point Q1-Q3 covers: use case → hardware → budget
- [ ] Platform selection reference: judgment rules (stable) + comparison table with last_verified dates (refreshable)
- [ ] LoRA/QLoRA reference: decision tree for when to use each, base model selection by language/task
- [ ] MCP collaboration reference: step-by-step human-AI workflow for Colab/Kaggle via Chrome MCP
- [ ] Cost estimation reference: GPU memory requirements by model size, time/cost estimation rules
- [ ] install.sh passes: installs SKILL.md to .claude/skills/ml-training/
- [ ] CONSUMES/PRODUCES interface declared in SKILL.md header
- [ ] Anti-slop: ≥5 specific thresholds/numbers from Phase 1 research (not generic advice)

#### Files Likely Affected
- .tad/capability-packs/ml-training/ (CREATE — pack source directory)
- .tad/capability-packs/pack-registry.yaml (MODIFY — register new pack)

#### Dependencies
Phase 1 complete (research findings available).

---

### Phase 3: Validate + Dogfood

**Status:** ⬚ Planned
**Execution:** pending

#### Scope
Expert review of the built pack (Layer 2: code-reviewer + backend-architect), fix P0s, then dogfood in Colin voice project — use the pack to guide at least one cloud GPU training session (voice cloning fine-tune or LLM fine-tune).

NOT in scope: training the actual model to production quality (that's a Colin project task, not a TAD task). Dogfood verifies the pack's judgment rules help, not that the model output is perfect.

#### Input
- Phase 2 built pack (all files)
- Colin voice project (active — Colab sessions available)

#### Output
- Expert review evidence (.tad/evidence/reviews/blake/ml-training-pack/)
- Dogfood report (.tad/evidence/research/ml-training-pack/dogfood-report.md)
- Pack registered in pack-registry.yaml and synced to Colin project

#### Acceptance Criteria
- [ ] Layer 2 expert review: ≥2 distinct reviewers, 0 unresolved P0
- [ ] Dogfood: pack loaded in Colin project session, guided ≥1 cloud training decision
- [ ] Dogfood report documents: what worked, what was missing, what rules were wrong
- [ ] Pack installed successfully in Colin project via install.sh
- [ ] If dogfood surfaces P0 issues: fix and re-review before acceptance

#### Files Likely Affected
- .tad/evidence/reviews/blake/ml-training-pack/ (CREATE — review evidence)
- .tad/evidence/research/ml-training-pack/dogfood-report.md (CREATE)
- .tad/capability-packs/pack-registry.yaml (MODIFY — finalize entry)

#### Dependencies
Phase 2 complete (pack built and installable).

---

## Context for Next Phase
(filled after each Phase completes)

---

## Notes
- **Origin**: Colin voice project — user discovered cloud GPU unlocks stalled ideas. See IDEA-20260529-ml-training-pack.md
- **Key innovation**: Human-AI collaboration via Chrome MCP for cloud platform operation. Agent writes scripts and operates Colab; human authorizes, uploads files, and makes decisions. This is a new interaction pattern not covered by any existing pack.
- **Anti-staleness strategy**: Judgment rules (SKILL.md + decision trees) are stable. Platform-specific numbers (pricing, GPU specs, quotas) go in reference files with `last_verified` dates. Quarterly research refresh recommended.
- **Live dogfood data**: User is actively running VoxCPM2 + GPT-SoVITS fine-tune on Colab via Chrome MCP during this Epic's creation. Real experience informs Phase 1 research.
