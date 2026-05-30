---
task_type: code
e2e_required: no
research_required: no
git_tracked_dirs: [".tad/capability-packs/ml-training", ".claude/skills/ml-training"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: ML Training Capability Pack — Design + Build (Phase 2)

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-05-29
**Project:** TAD Framework
**Task ID:** TASK-20260529-002
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260529-ml-training-pack (Phase 2/3)

---

## 🔴 Gate 2: Design Completeness

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Reference-based pack, same pattern as ai-voice-production |
| Components Specified | ✅ | SKILL.md + 5 reference files + install.sh |
| Functions Verified | ✅ | Template pack (ai-evaluation) install.sh verified |
| Data Flow Mapped | ✅ | Research → reference files → SKILL.md router |

**Gate 2 结果**: ✅ PASS

---

## 📋 Handoff Checklist (Blake必读)

- [ ] 阅读了所有章节
- [ ] **阅读了 Phase 1 research findings**: `.tad/evidence/research/ml-training-pack/deep-ask-findings.md`
- [ ] **阅读了模板 pack**: `.claude/skills/ai-voice-production/SKILL.md` (结构参考，含 Anti-Skip Table + Quick Rule Index)
- [ ] **阅读了 Colin 项目 MCP 协作 handoff**: `/Users/sheldonzhao/Downloads/Colin声音项目/.tad/active/handoffs/HANDOFF-20260529-colab-browser.md` §4.1-§4.3b (mcp-collaboration.md 的主要数据源)
- [ ] 确认可以独立使用本文档完成实现

---

## 1. Task Overview

**What:** 构建 ML Training capability pack — 一个 reference-based 的 SKILL.md 包，给 AI agent 关于云 GPU 模型训练的判断规则。覆盖 LLM fine-tune 和 voice model fine-tune 两条线。

**Why:** 独立开发者（8-16GB Mac）想训练/微调模型时，agent 要能给出具体可执行的指导：用哪个平台、哪个工具、什么配置、花多少钱。不是泛泛建议，是 if-then-because 决策规则。

**Scope:** 7 个文件。SKILL.md (router) + 5 reference files + install.sh。遵循 ai-voice-production pack 的 reference-based 架构。

---

## 3. Requirements

### FR1: SKILL.md — Router + Decision Tree
仿照 ai-voice-production 的 SKILL.md 结构：YAML frontmatter → Prerequisites → Context Detection → Decision Entry Point → Apply Rules。

### FR2: 5 个 Reference Files
| File | 内容 | Research 来源 |
|------|------|-------------|
| `platform-selection.md` | 云 GPU 平台选型判断规则 + 对比表（含 last_verified） | Round 2, 5, 8 |
| `lora-finetune.md` | LoRA/QLoRA 判断规则 + 基座模型选型 + 配置参数 | Round 1, 4, 6 |
| `data-preparation.md` | 训练数据准备：LLM (chat logs→ShareGPT) + Voice (audio→JSONL) | Round 3, 7 |
| `mcp-collaboration.md` | 人机协作工作流：Agent via Chrome MCP + PAUSE Protocol | Colin dogfood |
| `cost-estimation.md` | 端到端成本估算规则 + 平台×模型 cost table | Round 5, 8 |

### FR3: install.sh
仿照 ai-evaluation 的 install.sh（已验证可用）。支持 --dry-run, --force, --agent 标志。

---

## 4. Technical Design

### 4.1 Pack Architecture (reference-based)

```
.tad/capability-packs/ml-training/
├── CAPABILITY.md          # = SKILL.md source (pack source dir)
├── install.sh             # copies to .claude/skills/ml-training/
└── references/
    ├── platform-selection.md
    ├── lora-finetune.md
    ├── data-preparation.md
    ├── mcp-collaboration.md
    └── cost-estimation.md

After install → .claude/skills/ml-training/
├── SKILL.md               # copied from CAPABILITY.md
└── references/
    └── (same 5 files)
```

### 4.2 SKILL.md Structure

```markdown
---
name: ml-training
description: "ML model training on cloud GPU — platform selection, LoRA/QLoRA fine-tuning, cost estimation, human-AI collaboration via browser MCP"
version: 0.1.0
type: reference-based
keywords: [...]
---

# ML Training Capability Pack

> CONSUMES: ...
> PRODUCES: ...

## Step 0: Prerequisites
## Step 1: Context Detection (keyword → reference file mapping)
## Step 2: Decision Entry Point (Q1-Q4)
## Step 3: Apply Rules
## Quick Rule Index (per-reference key rules with section pointers)
## Anti-Skip Table (common rationalization → required action)
```

### 4.3 Context Detection Keywords (≥8, Chinese + English)

| User Signal | Load Reference |
|---|---|
| fine-tune, 微调, LoRA, QLoRA, train model, 训练模型 | `references/lora-finetune.md` |
| Colab, Kaggle, RunPod, Vast.ai, cloud GPU, 云GPU, 云训练 | `references/platform-selection.md` |
| training data, 训练数据, chat logs, 聊天记录, data prep | `references/data-preparation.md` |
| cost, 成本, pricing, 多少钱, budget, GPU hours | `references/cost-estimation.md` |
| browser automation, MCP, Colab操作, 人机协作 | `references/mcp-collaboration.md` |
| personality clone, 个性克隆, sound like, 像某人 | `references/lora-finetune.md` + `data-preparation.md` |

### 4.4 Decision Entry Point (Q1-Q4)

**Q1 — What type of model?**
- LLM (text: Qwen/Llama/Mistral) → load `lora-finetune.md`
- Voice (TTS/cloning: VoxCPM2/GPT-SoVITS) → defer to ai-voice-production pack; load `platform-selection.md` for GPU choice
- Image/other → out of scope, state clearly

**Q2 — What hardware do you have locally?**
- Apple Silicon 8-16GB → cloud training mandatory for 7B+; local only for QLoRA 2-bit or inference
- NVIDIA GPU ≥16GB → local QLoRA possible; cloud for LoRA 16-bit or larger models
- No GPU → cloud mandatory

**Q3 — What's your budget?**
- $0 → Colab Free / Kaggle (with gotcha awareness)
- $10-50/mo → Colab Pro (student free w/ .edu) / RunPod
- >$50/mo → RunPod Secure / Lambda (if uptime critical)

**Q4 — What tool?**
- Minimal setup + Colab/Kaggle → Unsloth
- Widest model support → LlamaFactory
- MLOps pipeline → Axolotl
- Voice → GPT-SoVITS or VoxCPM2 (defer to ai-voice-production)

### 4.5 CONSUMES / PRODUCES

```
CONSUMES: Training data (JSONL/ShareGPT/audio+transcript), base model name, hardware constraints, budget
PRODUCES: Platform recommendation, tool selection, training configuration, cost estimate
INTERFACE: ai-voice-production pack defers voice training platform selection to this pack's platform-selection.md.
           This pack defers voice-specific tool selection to ai-voice-production pack.
```

---

## 6. Files to Create

| # | File | Action |
|---|------|--------|
| 1 | `.tad/capability-packs/ml-training/CAPABILITY.md` | CREATE |
| 2 | `.tad/capability-packs/ml-training/references/platform-selection.md` | CREATE |
| 3 | `.tad/capability-packs/ml-training/references/lora-finetune.md` | CREATE |
| 4 | `.tad/capability-packs/ml-training/references/data-preparation.md` | CREATE |
| 5 | `.tad/capability-packs/ml-training/references/mcp-collaboration.md` | CREATE |
| 6 | `.tad/capability-packs/ml-training/references/cost-estimation.md` | CREATE |
| 7 | `.tad/capability-packs/ml-training/install.sh` | CREATE |
| 8 | `.claude/skills/ai-voice-production/SKILL.md` | MODIFY — add INTERFACE line for ml-training + update Q2 cloud GPU to reference ml-training platform-selection.md |

**Grounded Against:**
- .claude/skills/ai-voice-production/SKILL.md (structure template + INTERFACE update target, read at 2026-05-29)
- .tad/capability-packs/ai-evaluation/install.sh (install.sh template, read at 2026-05-29)
- .tad/evidence/research/ml-training-pack/deep-ask-findings.md (research input, created 2026-05-29)
- /Users/sheldonzhao/Downloads/Colin声音项目/.tad/active/handoffs/HANDOFF-20260529-colab-browser.md (MCP collaboration source, §4.1-§4.3b)

---

## 7. Implementation Details

### Content Rules (CRITICAL)

1. **Research-grounded**: Every numeric claim (VRAM, pricing, time, data size threshold) MUST come from `deep-ask-findings.md` with `> Source:` citation. Do NOT invent numbers.
2. **Anti-slop**: If a rule could be generated by a frontier LLM without the research notebook, it's low-value. Sharpen with specific numbers or remove.
3. **Judgment rules, not tutorials**: Write "IF X THEN Y BECAUSE Z" decision rules, not step-by-step how-to guides.
4. **Stable vs refreshable**: Judgment rules (SKILL.md decision tree) are stable. Platform-specific numbers (pricing, GPU specs, quotas) go in reference tables with `last_verified: 2026-05-29` dates.
5. **Two model types**: Every reference file that applies to both LLM and Voice must have separate sections or clearly labeled rows for each.
6. **Colin dogfood data**: First-hand data from Colin project (TORCHDYNAMO_DISABLE, VoxCPM2 22GB VRAM, PAUSE Protocol) is Category A — cite as "Colin dogfood 2026-05-29".

### Reference File Content Guide

**platform-selection.md:**
- Judgment rules: "IF budget=0 AND job<12h THEN Colab Free BECAUSE..." (from Round 4)
- Platform comparison table with columns: Platform, GPU, VRAM, Time Limit, Cost, Gotchas, last_verified
- Hidden limitations section (from Round 2 — Colab anti-abuse, Kaggle idle timeout, etc.)

**lora-finetune.md:**
- Decision: fine-tune vs prompting/RAG threshold (Round 4 Q1)
- LoRA vs QLoRA vs full fine-tune decision matrix (Round 1)
- Base model selection table by task/language (Round 4 Q3)
- Rank/LR/epochs configuration table (Round 4 Q4, Round 7)
- Tool selection: Unsloth vs LlamaFactory vs Axolotl head-to-head (Round 6)

**data-preparation.md:**
- LLM path: chat logs → clean → ShareGPT JSON format (Round 7)
- Voice path: audio → VAD → transcript → JSONL (Colin dogfood)
- AI bootstrap technique: use frontier model to generate synthetic training pairs (Round 7)
- Quality vs quantity rule: "200 curated > 2000 noisy" with source citation

**mcp-collaboration.md:**
- Complete workflow diagram: Agent actions vs Human actions (Colin handoff §4.1)
- PAUSE Protocol: triggers, forbidden tools, resume procedure (Colin handoff §4.3)
- Chrome MCP tool mapping table (Colin handoff §4.2)
- Security rules during auth pages (Colin handoff §4.3b)

**cost-estimation.md:**
- Estimation RULES (VRAM-to-cost mapping, total cost formula including storage/egress/compute)
- "Can I do it free?" quick-check decision tree
- VRAM requirements table by method (LlamaFactory verified numbers from Round 1)
- Reference platform-selection.md for raw pricing — do NOT duplicate the platform comparison table here

### Anti-Skip Table (in CAPABILITY.md, ≥3 entries)
Derive from research findings. Example entries:
| Skip Attempt | Required Action |
|---|---|
| "I'll just use Colab Free" | MUST read platform-selection.md gotchas (anti-abuse termination, Drive timeout, idle quota burn) |
| "200 examples should be enough for everything" | MUST check task-type threshold in lora-finetune.md (classification 100-500, generation 500-2K) |
| "I'll fine-tune first, test later" | MUST check fine-tune vs prompting/RAG threshold in lora-finetune.md Q1 — if <50 examples, use prompting |
| "My Mac can handle it" | MUST check VRAM requirements in lora-finetune.md — 7B LoRA 16-bit needs 16GB, local Mac 8GB = cloud mandatory |

### Quick Rule Index (in CAPABILITY.md)
Per-reference-file summary of key rules with section pointers. Example format:
```
**platform-selection.md** → 5 Platform Gotchas | Budget Decision Tree | Free Tier Comparison
**lora-finetune.md** → Fine-tune vs RAG Threshold | Rank Selection Table | Tool Head-to-Head
**data-preparation.md** → LLM Data Pipeline | Voice Data Pipeline | AI Bootstrap Technique
**mcp-collaboration.md** → PAUSE Protocol | Chrome MCP Tool Map | Security Rules
**cost-estimation.md** → VRAM-to-Cost Formula | "Can I Do It Free?" Tree
```

### Task 8: ai-voice-production SKILL.md — INTERFACE update

**Location:** `.claude/skills/ai-voice-production/SKILL.md` line 14 (INTERFACE declaration) + line 58 (Q2 cloud GPU option)

**Add to INTERFACE line (line 14), append after existing video-creation interface:**
```
> **INTERFACE**: [...existing text...] ml-training pack provides platform selection and cost estimation for cloud GPU training. This pack defers cloud platform details to ml-training's platform-selection.md. ml-training defers voice-specific tool selection to this pack.
```

**Update Q2 cloud GPU option (line 59) to reference ml-training:**
```
- No local GPU / insufficient VRAM → load ml-training pack's `references/platform-selection.md` for cloud GPU selection. Primary use case: training and fine-tuning; inference can often stay local.
```

**Precedence rule (add after INTERFACE line):**
```
> When both packs load for voice training: ml-training takes precedence for platform/cost decisions; ai-voice-production takes precedence for tool selection and audio quality thresholds.
```

---

## 9. Acceptance Criteria

| # | Criteria | Verification |
|---|----------|-------------|
| AC1 | CAPABILITY.md has YAML frontmatter with name + description | `head -6 .tad/capability-packs/ml-training/CAPABILITY.md \| grep -cE '^(name\|description):'` = 2 |
| AC2 | Context detection table has ≥6 signal rows | `grep -cE '^\|.*references/' .tad/capability-packs/ml-training/CAPABILITY.md` ≥ 6 |
| AC3 | Decision entry point covers Q1-Q4 | `grep -cE '^\*\*Q[1-4]' .tad/capability-packs/ml-training/CAPABILITY.md` ≥ 4 |
| AC4 | 5 reference files exist | `ls .tad/capability-packs/ml-training/references/*.md \| wc -l` = 5 |
| AC5 | platform-selection.md has last_verified dates | `grep -c 'last_verified' .tad/capability-packs/ml-training/references/platform-selection.md` ≥ 1 |
| AC6 | lora-finetune.md covers LLM AND voice separately | `grep -cE 'LLM|Voice|voice|语音' .tad/capability-packs/ml-training/references/lora-finetune.md` ≥ 2 |
| AC7 | mcp-collaboration.md has PAUSE Protocol | `grep -c 'PAUSE' .tad/capability-packs/ml-training/references/mcp-collaboration.md` ≥ 1 |
| AC8 | install.sh runs successfully | `bash .tad/capability-packs/ml-training/install.sh --dry-run` exits 0 |
| AC9 | CONSUMES/PRODUCES declared in SKILL.md header | `grep -cE 'CONSUMES|PRODUCES' .tad/capability-packs/ml-training/CAPABILITY.md` ≥ 2 |
| AC10 | Anti-slop: ≥5 specific numbers from research with > Source: citations | `grep -cE '> Source:' .tad/capability-packs/ml-training/references/*.md` ≥ 5 (semi-auto) + manual check that numbers include research-grounded values like 6GB QLoRA VRAM, 22GB VoxCPM2 VRAM, $0.34/hr RunPod |
| AC11 | Anti-Skip Table exists with ≥3 entries | `grep -c 'Anti-Skip' .tad/capability-packs/ml-training/CAPABILITY.md` ≥ 1 |
| AC12 | ai-voice-production SKILL.md updated with ml-training INTERFACE | `grep -c 'ml-training' .claude/skills/ai-voice-production/SKILL.md` ≥ 1 |

### 9.1 Spec Compliance Checklist

| AC | Verification Method | Expected | Verified Output |
|----|-------------------|----------|----------------|
| AC1 | `head -6 CAPABILITY.md \| grep -cE '^(name\|description):'` | 2 | (post-impl) |
| AC2 | `grep -cE '^\|.*references/' CAPABILITY.md` | ≥6 | (post-impl) |
| AC3 | `grep -cE '^\*\*Q[1-4]' CAPABILITY.md` | ≥4 | (post-impl) |
| AC4 | `ls references/*.md \| wc -l` | 5 | (post-impl) |
| AC5 | `grep -c 'last_verified' references/platform-selection.md` | ≥1 | (post-impl) |
| AC6 | `grep -cE 'LLM|Voice|voice|语音' references/lora-finetune.md` | ≥2 | (post-impl) |
| AC7 | `grep -c 'PAUSE' references/mcp-collaboration.md` | ≥1 | (post-impl) |
| AC8 | `bash install.sh --dry-run` | exit 0 | (post-impl) |
| AC9 | `grep -cE 'CONSUMES|PRODUCES' CAPABILITY.md` | ≥2 | (post-impl) |
| AC10 | `grep -cE '> Source:' references/*.md` | ≥5 | (post-impl) |
| AC11 | `grep -c 'Anti-Skip' CAPABILITY.md` | ≥1 | (post-impl) |
| AC12 | `grep -c 'ml-training' .claude/skills/ai-voice-production/SKILL.md` | ≥1 | (post-impl) |

---

## 📚 Project Knowledge

### ⚠️ Blake 必须注意的历史教训
- **Capability Pack: YAML Frontmatter is Load-Bearing** (architecture.md) — Claude Code requires `name:` + `description:` YAML frontmatter for SKILL.md registration. Without it, install succeeds but skill never activates.
- **Per-Tool Numeric Thresholds Require Research Provenance, Not Interpolation** (architecture.md) — When research provides a general range, do NOT split into per-tool entries. Only include tools with individually measured values.
- **Source Citation Integrity for Adapted Values** (architecture.md) — When adapting source values, cite BOTH original source AND adaptation document.
- **Anti-AI-Slop as Cross-Pack Quality Bar** (architecture.md) — Anti-slop formula: specific threshold from research > generic principle from training data.

## 🔧 Pack References (Blake 必读)

| Pack | File | Matched Capabilities |
|------|------|---------------------|
| ai-voice-production | .claude/skills/ai-voice-production/SKILL.md | Structure template (reference-based pack architecture) |

---

## 10. Important Notes

### 10.1 voice 相关内容的边界
voice model fine-tune 的判断规则在 **这个 pack** 中只覆盖平台选型和成本估算。voice-specific 的工具选型、音频质量标准、pipeline 设计仍然在 ai-voice-production pack 中。两个 pack 的关系是互相引用（CONSUMES/PRODUCES），不是合并。

### 10.2 install.sh 模板
直接复制 `.tad/capability-packs/ai-evaluation/install.sh` 修改 pack name 和 file list。不要从头写。

### 10.3 Research findings 是唯一数据源
所有写入 reference files 的数字必须来自 `deep-ask-findings.md`。如果 findings 中没有某个数字，不要编造，标记为 "data not available from research — verify before use"。

---

## 11. Decision Summary

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | Pack type | Thin router / Deep skill / Orchestration | Reference-based (thin router) | 5 独立 reference files + router，匹配 ai-voice-production 架构 |
| 2 | Voice 覆盖范围 | 全覆盖 / 只平台+成本 / 完全排除 | 只平台+成本 | voice-specific 规则留在 ai-voice-production，避免重复 |
| 3 | 数字的 staleness 策略 | 不写数字 / 写数字+定期更新 / 混合 | 混合：规则稳定 + 数字表 last_verified | 用户需要具体数字做决策，但数字会过时 |
