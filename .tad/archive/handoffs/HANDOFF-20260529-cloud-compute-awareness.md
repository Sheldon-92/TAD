---
task_type: yaml
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: yes  # text-insertion-only task, no architectural learning expected
gate4_delta: []
---

# Handoff: Cloud Compute Resource Awareness (Cross-Cutting)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-05-29
**Project:** TAD Framework
**Task ID:** TASK-20260529-001
**Handoff Version:** 3.1.0

---

## 🔴 Gate 2: Design Completeness

**执行时间**: 2026-05-29

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Cross-cutting rule insertion, 3 embed points identified |
| Components Specified | ✅ | Exact files and sections specified |
| Functions Verified | ✅ | All target sections exist (grounded) |
| Data Flow Mapped | ✅ | N/A — text insertion, no data flow |

**Gate 2 结果**: ✅ PASS
**Alex确认**: Blake 可以独立根据本文档完成实现。

---

## 📋 Handoff Checklist (Blake必读)

- [ ] 阅读了所有章节
- [ ] 阅读了「📚 Project Knowledge」章节中的历史经验
- [ ] 确认可以独立使用本文档完成实现

---

## 1. Task Overview

**What:** 在 TAD 框架的 3 个位置嵌入"云计算资源意识"判断规则，让 agent 在遇到本地硬件不足的场景时自动建议云 GPU 方案，而不是停在"做不了"。

**Why:** 用户在 Colin 声音项目中发现，"本地跑不动 = 做不了"是一个普遍的认知 gap。免费/低成本云 GPU（Colab/Kaggle/RunPod）能解锁很多被卡住的任务（语音训练、LLM 微调、大规模推理），但 agent 从不主动建议。

**Scope:** 3 个文件的文本插入。无代码、无新文件、无架构变更。

---

## 3. Requirements

### FR1: Alex Socratic 提问维度扩展
在 Alex SKILL.md 的 `technical_constraints` 提问维度中，添加一条关于云计算资源的提示问题。

### FR2: project-knowledge 通用判断规则
在 `architecture.md` 的 Accumulated Learnings 中添加一条新 entry，记录"硬件限制不等于不可行 — 云 GPU 是默认 fallback"的判断规则。

### FR3: ai-voice-production pack 硬件判断扩展
在 ai-voice-production SKILL.md 的 Step 2 Q2 (hardware) 中，在现有 3 个选项（Apple Silicon / NVIDIA GPU / CPU only）后添加第 4 个选项：云 GPU。

---

## 6. Files to Modify

| # | File | Action | Section |
|---|------|--------|---------|
| 1 | `.claude/skills/alex/SKILL.md` | MODIFY | `technical_constraints` questions list (~line 2474) |
| 2 | `.tad/project-knowledge/architecture.md` | MODIFY | Accumulated Learnings (append new entry at end) |
| 3 | `.claude/skills/ai-voice-production/SKILL.md` | MODIFY | Step 2 Q2 hardware options (~line 56-58) |

**Grounded Against** (Alex step1c):
- .claude/skills/alex/SKILL.md (head 50 from line 2465, read at 2026-05-29)
- .tad/project-knowledge/architecture.md (head 30, read at 2026-05-29)
- .claude/skills/ai-voice-production/SKILL.md (head 70, read at 2026-05-29)

---

## 7. Implementation Details

### Task 1: Alex SKILL.md — technical_constraints 提问扩展

**Location:** `socratic_inquiry_protocol.question_dimensions.technical_constraints.questions` (~line 2474)

**Current (3 questions):**
```yaml
    technical_constraints:
      name: "技术约束"
      questions:
        - "有什么技术限制需要考虑？"
        - "需要兼容什么现有系统？"
        - "性能要求是什么？"
```

**Add after the 3rd question (indentation: 8 spaces before the dash, matching existing questions):**
```yaml
        - "如果本地硬件不够（GPU/内存/存储），是否考虑过云计算资源（Colab/Kaggle 免费 GPU，RunPod/Vast.ai 付费 GPU）？"
```

### Task 2: architecture.md — 通用判断规则

**Location:** End of `## Accumulated Learnings` section (append)

**New entry:**
```markdown
### Cloud Compute Resource Awareness — Hardware Limitation ≠ Infeasibility — 2026-05-29
- **Context**: Colin voice project — user assumed voice training was impossible on 8GB Mac. Discovered free cloud GPU (Colab T4 12GB, Kaggle P100 16GB) could do it. Many stalled ideas (voice cloning, LLM fine-tune, custom assistant training) were blocked by the false assumption "local hardware = all available compute".
- **Discovery**: When an agent encounters "local hardware insufficient for task X" (model training, large-scale inference, fine-tuning), the default response should NOT be "this can't be done" but rather "this can't be done locally — here are cloud alternatives." Free and paid cloud GPU tiers exist for most ML workloads. This applies to any ML-adjacent task, not just voice production.
- **Action**: (1) In Socratic inquiry, when user mentions hardware limitations, always ask about cloud GPU awareness. (2) In capability packs involving training/fine-tuning, include cloud GPU as a hardware option alongside local. (3) Never treat "my machine can't run this" as a terminal condition — treat it as a resource allocation question.
- **Grounded in**: Colin声音项目 dogfood session (2026-05-29), ChatTTS hardware limitation discovery
```

### Task 3: ai-voice-production SKILL.md — Step 2 Q2 扩展

**Location:** Step 2 Decision Entry Point, Q2 section (~line 55-58)

**Current:**
```markdown
**Q2 — What hardware?**
- Apple Silicon Mac → ALSO load `apple-silicon.md`
- NVIDIA GPU → proceed with tool default configs
- CPU only → check MeloTTS or Piper in `tool-landscape.md`
```

**Add after the 3rd option (CPU only line):**
```markdown
- No local GPU / insufficient VRAM → suggest cloud GPU (Colab free T4 / Kaggle free P100 / RunPod paid). Primary use case: training and fine-tuning; inference can often stay local.
```

---

## 9. Acceptance Criteria

| # | Criteria | Verification |
|---|----------|-------------|
| AC1 | Alex SKILL.md `technical_constraints` has 4 questions (was 3) | `sed -n '/technical_constraints:/,/^$/p' .claude/skills/alex/SKILL.md \| grep -c '^\s*- "'` = 4 |
| AC2 | architecture.md has "Cloud Compute Resource Awareness" entry | `grep -c 'Cloud Compute Resource Awareness' .tad/project-knowledge/architecture.md` = 1 |
| AC3 | ai-voice-production SKILL.md Q2 has cloud GPU option | `grep -c 'cloud GPU' .claude/skills/ai-voice-production/SKILL.md` ≥ 1 |
| AC4 | No existing content is deleted or modified (all changes are additive) | `git diff --numstat \| awk '{if ($2 != "0") print "FAIL: deletions in "$3}'` produces no output |

### 9.1 Spec Compliance Checklist

| AC | Verification Method | Expected Evidence | Verified Output |
|----|-------------------|-------------------|----------------|
| AC1 | `sed -n '/technical_constraints:/,/^$/p' .claude/skills/alex/SKILL.md \| grep -c '^\s*- "'` | 4 (was 3) | pre-impl: 3 ✅ |
| AC2 | `grep -c 'Cloud Compute Resource Awareness' .tad/project-knowledge/architecture.md` | 1 | pre-impl: 0 ✅ |
| AC3 | `grep -c 'cloud GPU' .claude/skills/ai-voice-production/SKILL.md` | ≥1 | pre-impl: 0 ✅ |
| AC4 | `git diff --numstat \| awk '{if ($2 != "0") print "FAIL"}'` | no output | (post-impl) |

---

## 📚 Project Knowledge

### ⚠️ Blake 必须注意的历史教训
- **Cognitive Firewall: Embed Into Existing Flows** (architecture.md) — Cross-cutting concerns are most effective embedded into existing mandatory flows, not standalone commands. This handoff follows that pattern.
- **Minimal Viable Cross-Cutting Enhancement** (architecture.md) — Start with the 2 most critical points rather than all possible points. This handoff targets 3 specific files, not a broad sweep.

---

## 10. Important Notes

### 10.1 Scope Constraint
This is a TEXT INSERTION task. Do not refactor, reorganize, or "improve" surrounding content. Add the specified text at the specified locations, nothing more.

### 10.2 ai-voice-production pack note
The cloud GPU option in Q2 does NOT require a new reference file. It's a one-line addition to the decision tree. A dedicated "cloud-training.md" reference file would be part of the future ML Training capability pack, not this handoff.

---

## 11. Decision Summary

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | Embed vs standalone pack | Standalone Cloud GPU pack / Cross-cutting embed | Cross-cutting embed | Anti-slop: cloud GPU awareness is a judgment rule, not a capability. Pack would be rule soup. |
| 2 | Scope of trigger | Only "GPU insufficient" / Any training task / Training + large inference | Training + large inference | User confirmed: both training and "local inference too slow" should trigger cloud suggestion |
