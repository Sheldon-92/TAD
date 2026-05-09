---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: Video-Creation Pack — AI Asset Generation Integration

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-05-08
**Project:** video-creation capability pack (~/video-creation/)
**Task ID:** TASK-20260508-001
**Handoff Version:** 3.1.0

---

## 🔴 Gate 2: Design Completeness

**执行时间**: 2026-05-08

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Reference-based pack pattern, 7 sections in ai-asset-generation.md |
| Components Specified | ✅ | 3 files specified (1 new + 2 updates), all sections outlined in §3.1 |
| Functions Verified | ✅ | N/A (Markdown reference content, not code) |
| Data Flow Mapped | ✅ | Decision tree (tool selection → endpoint selection → async API → pipeline) |

**Gate 2 结果**: ✅ PASS

**Expert Review**: 2 experts (code-reviewer + backend-architect), 7 P0 + 6 P1 found, all P0 Resolved. See §9.2 Audit Trail.

**Alex确认**: 我已验证所有设计要素，Blake可以独立根据本文档完成实现。

---

## 📋 Handoff Checklist (Blake必读)

- [ ] 阅读了所有章节
- [ ] 阅读了「📚 Project Knowledge」章节中的历史经验
- [ ] 理解了真正意图（不只是字面需求）
- [ ] 确认可以独立使用本文档完成实现

---

## 1. Task Overview

### What
Add an **AI Asset Generation** reference file to the video-creation capability pack, integrating Codex gpt-image-2 (image generation) and Seedance 2.0 (video generation) as the "Generate" layer in the pipeline. Update CAPABILITY.md routing and tool-selection.md decision tree.

### Why
The current pack covers **Compose → Render → Export** but assumes visual assets already exist. This upgrade adds the missing **Generate** layer, enabling a full **Generate → Compose → Render → Export** pipeline. Without this, agents must leave the pack to figure out image/video generation independently.

### Scope
3 files in ~/video-creation/:
1. `references/ai-asset-generation.md` — **NEW** (main deliverable, ~300-400 lines)
2. `CAPABILITY.md` — UPDATE Step 1 routing table + Step 0 prerequisites
3. `references/tool-selection.md` — UPDATE decision tree

---

## 2. Business Requirements

Users (AI agents using this pack) should be able to:
- Decide which tool to use for asset generation (Seedance vs Codex vs Kling vs Runway)
- Call the chosen tool's API with correct parameters
- Handle async video generation without blocking
- Control costs with tiered generation strategy
- Maintain visual consistency across generated assets
- Feed generated assets into HyperFrames/Remotion compositions

---

## 3. Technical Design

### 3.1 New File: `references/ai-asset-generation.md`

Structure (reference-based pack pattern — concrete rules, not guidelines):

```
# AI Asset Generation Reference

## Decision Tree
- Need static image → Codex gpt-image-2
- Need video clip → Seedance 2.0 (default)
- Need video clip with 4K → Kling
- Already in Runway ecosystem → Runway Gen-4
(embedded competitive positioning — not a separate table)

## Seedance 2.0 Rules
### Endpoint Selection
- Text-only description → text-to-video
- Have a start image → image-to-video (supports end image too)
- Have multiple references (images + videos + audio) → reference-to-video

### Endpoint Specification Table
(From research Q1: resolution, duration, aspect ratio, audio, pricing per endpoint)

### Async API Pattern (for agents)
- Submit-then-poll (NOT subscribe — subscribe blocks thread)
- Task state machine: queued → running → succeeded / failed / expired
- Poll schedule: initial poll at 5s, then every 10s, max 120s timeout (BA-P0-1)
- Webhook alternative: if agent has reachable HTTP endpoint, use webhook + fallback poller (BA-P0-1)
- Request hashing for duplicate prevention
  - Hash = hash(model_id + route + prompt + media_urls + settings)
  - Re-generation escape hatch: if user explicitly requests re-roll, append attempt_number to hash or bypass dedup (BA-P0-2)
- Retry strategy: transport retries yes (backoff), generation retries no (content moderation → report to user, don't rephrase)
- Rate limiting: serialize multi-scene submissions (max 2-3 concurrent), on 429 → backoff 30s (BA-P0-3)

### Prompt Rules
- Motion safety: avoid "fast", one fast element at a time
- Duration-to-shot: min 3-5s per shot, explicit "Shot N:" labels
- Character consistency: 4K character sheet → @character:<id> tag
- Omni-reference: tag images as @Image1, @Image2 in prompt

### Cost Control
- Tiered generation: draft (480p/Fast) → approval → final (1080p/Standard)
- Duration caps: 5s tests first, 10-15s after style approval
- Video reference discount: 0.6x with video inputs
- Cost table: per-second pricing by tier and platform

## Codex gpt-image-2 Rules
### Asset Types
(Characters, backgrounds, product shots, storyboards, icons, banners)

### Output Specs
- Max 4K (stable at 2K), edges multiple of 16px
- PNG/JPEG/WebP, no native transparency
- Text rendering >99% accuracy

### Invocation
- $imagegen keyword or natural language in Codex
- Default save to $CODEX_HOME/generated_images/
- Set OPENAI_API_KEY for batch work (avoid 3-5x plan consumption)

### Prompt Structure
- Order: background/scene → subject → details → constraints
- Identity preservation: edit endpoint + reference image
- Invariant anchoring: "keep X unchanged" every iteration
- quality="high" for text/layout, "low" for drafts only

### Edit Capabilities
(inpainting, style transfer, background replacement, sketch→render)

## Pipeline Integration
### File Path Convention (split by tool — BA-P0-4)
HyperFrames projects: assets/generated-images/ and assets/generated-clips/ (no build, HTML paths resolve directly)
Remotion projects: public/generated-images/ and public/generated-clips/ (staticFile() resolves from public/ only)

### Post-Generation File Placement (BA-P1-3)
Codex saves to $CODEX_HOME/generated_images/ by default. Agent must move to project convention path after generation:
  HyperFrames: mv $CODEX_HOME/generated_images/hero.png ./assets/generated-images/
  Remotion: mv $CODEX_HOME/generated_images/hero.png ./public/generated-images/

### HyperFrames
Standard <img src="./assets/generated-images/hero.png">
Standard <video src="./assets/generated-clips/scene1.mp4">

### Remotion
<Img src={staticFile("generated-images/hero.png")}/> (file in public/generated-images/)
<Video src={staticFile("generated-clips/scene1.mp4")}/> (file in public/generated-clips/)

### FFmpeg Post-Processing
Concat, overlay, audio mix command patterns

## Visual Consistency Rules
(Cross-asset consistency for both tools)

## Quality Thresholds
- Seedance: reject clips with artifacts, check for compressed/skipped shots
- gpt-image-2: no-transparency limitation + chroma-key workaround
```

### 3.2 CAPABILITY.md Updates

**Step 0 Prerequisites** — add:
```
- **fal.ai API key** (`FAL_KEY`) — for Seedance 2.0 video generation (optional, only if using AI asset generation)
- **Codex CLI** — for gpt-image-2 image generation (optional)
```

**Step 1 Routing Table** — add new rows:
```
| generate image / AI image / character art / background art / $imagegen | references/ai-asset-generation.md §Codex |
| generate video / AI video / Seedance / video clip / animate image | references/ai-asset-generation.md §Seedance |
| cost / budget / pricing / how much | references/ai-asset-generation.md §Cost Control |
```

**Quick Rule Index** — add new subsection (CR-P0-3):
```
### AI Asset Generation (`references/ai-asset-generation.md`)
- **Seedance Default Rule**: Video clips → Seedance 2.0; 4K needed → Kling; existing Runway → Runway → §Decision Tree
- **Endpoint Selection**: text-only → text-to-video; have image → image-to-video; multi-ref → reference-to-video → §Seedance Endpoint Selection
- **Submit-Then-Poll Rule**: Never subscribe(), always submit-then-poll with 5s/10s/120s schedule → §Async API Pattern
- **Tiered Generation Rule**: Draft 480p/Fast → approval → Final 1080p/Standard → §Cost Control
- **Request Hashing Rule**: hash(model+prompt+settings) before every API call, re-roll uses attempt_number → §Async API Pattern
- **Prompt Consistency Rule**: gpt-image-2 invariant anchoring + Seedance @character:<id> → §Visual Consistency Rules
```
⚠️ §指针必须与 ai-asset-generation.md 的 ## 标题 byte-exact 匹配。Blake 写完 reference 后回头核对。

### 3.3 tool-selection.md Updates

Update the decision tree to add an AI generation branch BEFORE the current tree:

```
Need to produce a video? →

  Do you need to GENERATE visual assets first?
  (no existing images/video clips, need AI to create them)
    YES → See references/ai-asset-generation.md
    NO  ↓ (you already have assets)

  [existing decision tree continues unchanged]
```

---

## 4. Research Basis

All rules are grounded in the QCE research report:
- **Session:** RS-20260508-001
- **Report:** `.research/sessions/RS-20260508-001/report.md`
- **ACs:** `.research/sessions/RS-20260508-001/acs.md`
- **Notebook:** `7e9c2c57` (18 sources, 7 ask rounds)
- **Key sources:** Seedance 2.0 official docs, fal.ai SDK repo, Codex CLI features, Runway API, Kling docs

⚠️ Blake 必须在写规则时参考 report.md 中的具体 Claim 和引用编号，不要凭记忆写。

---

## 5. Files to Modify / Create

| # | File | Action | Lines Est. |
|---|------|--------|-----------|
| 1 | ~/video-creation/references/ai-asset-generation.md | CREATE | ~350-400 |
| 2 | ~/video-creation/CAPABILITY.md | UPDATE (Step 0 + Step 1 table) | ~15 lines added |
| 3 | ~/video-creation/references/tool-selection.md | UPDATE (decision tree) | ~10 lines added |

**Grounded Against** (Alex step1c 实际 Read 过的源文件):
- ~/video-creation/CAPABILITY.md (head 80, read at 2026-05-08)
- ~/video-creation/references/tool-selection.md (head 100, read at 2026-05-08)
- ~/video-creation/references/ai-asset-generation.md (new — will be created)

---

## 6. Acceptance Criteria

### Tool Selection & Decision Tree
- [ ] AC1: CAPABILITY.md Step 1 routing table has ≥3 new rows for AI asset generation signals (note: Quick Rule Index entries will add more hits — that's expected, ≥3 is a floor; CR-P0-2)
- [ ] AC2: ai-asset-generation.md contains top-level decision tree with 4 branches: Codex (images), Seedance (default video), Kling (4K video), Runway (existing ecosystem)
- [ ] AC2b: ai-asset-generation.md contains Seedance endpoint selection sub-tree: text-only → text-to-video; have start image → image-to-video; multiple references → reference-to-video (CR-P0-1)
- [ ] AC3: tool-selection.md decision tree updated with "generate assets?" branch inserted AFTER existing "Need to produce a video? →" line and BEFORE "Is it pure video processing?" (between current lines 13 and 15; CR-P1-1)
- [ ] AC3b: CAPABILITY.md Quick Rule Index has `### AI Asset Generation` subsection with ≥4 rule pointers to references/ai-asset-generation.md, §指针 byte-exact matching reference headings (CR-P0-3)

### Seedance Integration Rules
- [ ] AC4: Async API pattern documented: submit-then-poll with task state machine (queued/running/succeeded/failed)
- [ ] AC4b: Concrete poll schedule documented: initial 5s, then 10s interval, 120s max timeout (BA-P0-1)
- [ ] AC4c: Webhook alternative documented as complement for server agents, with fallback poller requirement (BA-P0-1)
- [ ] AC5: Request hashing rule documented with hash composition: hash(model_id + route + prompt + media_urls + settings)
- [ ] AC5b: Re-generation escape hatch documented: explicit re-roll appends attempt_number or bypasses dedup (BA-P0-2)
- [ ] AC5c: Rate limiting strategy documented: max 2-3 concurrent submissions, serialize multi-scene, 429 → backoff 30s (BA-P0-3)
- [ ] AC6: Tier selection rule: Fast=drafts, Standard=production
- [ ] AC7: Duration-to-shot allocation rule: min 3-5s/shot, "Shot N:" labeling
- [ ] AC8: Motion safety rule: avoid "fast", separate camera and subject motion

### Codex Image Generation Rules
- [ ] AC9: Prompt structure rule: background → subject → details → constraints
- [ ] AC10: Identity preservation rule: edit endpoint + reference image
- [ ] AC11: Invariant anchoring rule: "keep X unchanged" per iteration
- [ ] AC12: Quality parameter rule: high for text/layout, low for drafts
- [ ] AC13: Batch generation rule: set OPENAI_API_KEY for >3 images

### Pipeline Integration
- [ ] AC14: File path convention split by tool: HyperFrames → assets/generated-*/, Remotion → public/generated-*/ (BA-P0-4)
- [ ] AC14b: Post-generation file placement step: Codex default path → project convention path move command documented (BA-P1-3)
- [ ] AC15: HyperFrames integration: <img> and <video> HTML tags documented
- [ ] AC16: Remotion integration: <Img> and <Video> with staticFile("generated-images/...") documented (public/ prefix, BA-P0-4)

### Cost Control
- [ ] AC17: Tiered generation strategy: draft → approval → final
- [ ] AC18: Duration caps: 5s tests → 10-15s after approval
- [ ] AC19: Cost table with per-second pricing for BOTH fal.ai AND Atlas Cloud, per tier (BA-P1-2)
- [ ] AC20: Video reference discount (0.6x) documented

### Visual Consistency
- [ ] AC21: Seedance character sheet workflow documented: generate sheet → @character:<id>
- [ ] AC22: Omni-reference prompting: @Image1, @Image2 tagging documented
- [ ] AC23: Style drift mitigation rules for both tools documented

### Quality & Endpoint Specs
- [ ] AC24: Seedance endpoint specification table (3 endpoints × input/output/pricing)
- [ ] AC25: gpt-image-2 no-transparency limitation documented with concrete chroma-key workaround: prompt green bg → ffmpeg chromakey filter → verify alpha (BA-P1-6)
- [ ] AC25b: Reference file has "Pricing last verified: 2026-05-08" annotation at top

---

## 7. Important Notes

### 7.1 API Provider Strategy
规则写通用术语 (submit/poll/succeeded)，代码示例用 fal.ai Python SDK (`fal_client`)。换提供商只改示例不改规则。

### 7.2 Pricing Data Freshness
定价数据来自 2026-05-08 研究。在 reference 文件顶部加 `Pricing last verified: 2026-05-08` 标注。

### 7.3 Anti-Patterns (from research)
- ❌ 使用 `fal_client.subscribe()` — 会阻塞 agent 线程
- ❌ 不做 request hashing 就重试 — 最贵的 bug 是重复生成
- ❌ 直接用 1080p/Standard 做初稿 — 浪费钱
- ❌ 在 prompt 中使用 "fast" — 导致视觉抖动
- ❌ 在短时间内请求多个 shot — 导致压缩/跳帧

---

## 📚 Project Knowledge — ⚠️ Blake 必须注意的历史教训

### 从 architecture.md 匹配的相关教训：

1. **Capability Pack Rule Sourcing** (2026-05-07) — 写规则时必须读实际源文档，不能凭训练数据直觉。本 handoff 的所有规则来自 `.research/sessions/RS-20260508-001/report.md`，Blake 写 ai-asset-generation.md 时必须逐条对照 report 中的 Claim 和引用。

2. **Research Findings ≠ API Ground Truth** (2026-05-07) — 研究发现中的 API 参数名必须验证。如果 report 说某个参数叫 X，Blake 应该 WebFetch 官方文档确认。

3. **Capability Pack Quick Rule Index: Exact Heading Match** (2026-05-08) — CAPABILITY.md Quick Rule Index 的 §指针必须与 reference 文件的 ## 标题 byte-exact 匹配。

4. **FFmpeg sidechaincompress Uses Milliseconds** (2026-05-08) — FFmpeg 参数单位不可假设，必须查文档。本 handoff 的 FFmpeg 命令模式同理。

5. **Capability Pack Architecture Spectrum** (2026-05-08) — video-creation 是 reference-based 架构（CAPABILITY.md 是 router，bulk 在 references/*.md）。新增的 ai-asset-generation.md 遵循同样的 pattern。

---

## 9. Spec Compliance Checklist

| AC | Verification Method | Expected Evidence |
|----|---------------------|-------------------|
| AC1 | `grep -c 'ai-asset-generation' ~/video-creation/CAPABILITY.md` | ≥3 (floor; Quick Rule Index adds more) |
| AC2 | `grep -c '## Decision Tree' ~/video-creation/references/ai-asset-generation.md` | ≥1 |
| AC2b | `grep -cE 'text-only.*text-to-video\|start image.*image-to-video\|multiple ref.*reference-to-video' ~/video-creation/references/ai-asset-generation.md` | ≥2 |
| AC3 | `grep -c 'GENERATE.*assets\|generate.*assets' ~/video-creation/references/tool-selection.md` | ≥1 |
| AC3b | `grep -c '### AI Asset Generation' ~/video-creation/CAPABILITY.md` | ≥1 |
| AC4 | `grep -c 'submit.*poll\|poll.*status' ~/video-creation/references/ai-asset-generation.md` | ≥1 |
| AC4b | `grep -cE '5s\|10s\|120s\|poll.*interval\|backoff' ~/video-creation/references/ai-asset-generation.md` | ≥2 |
| AC5b | `grep -cE 're-roll\|attempt_number\|re-generat\|escape' ~/video-creation/references/ai-asset-generation.md` | ≥1 |
| AC5c | `grep -cE 'concurrent\|429\|rate.limit\|serialize' ~/video-creation/references/ai-asset-generation.md` | ≥1 |
| AC14 | `grep -cE 'public/generated\|assets/generated' ~/video-creation/references/ai-asset-generation.md` | ≥2 |
| AC19 | `grep -cE '\$0\.[0-9]+/s\|per.second' ~/video-creation/references/ai-asset-generation.md` | ≥4 (2 providers × 2 tiers) |
| AC24 | `grep -c 'text-to-video\|image-to-video\|reference-to-video' ~/video-creation/references/ai-asset-generation.md` | ≥3 |
| AC25b | `grep -c 'Pricing last verified' ~/video-creation/references/ai-asset-generation.md` | ≥1 |

---

## 9.2 Expert Review — Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | CR-P0-1: Research AC3 (Seedance endpoint selection) no standalone AC | §6 AC2b added | Resolved |
| code-reviewer | CR-P0-2: AC1 grep fragile due to Quick Rule Index | §6 AC1 note + §9 updated | Resolved |
| code-reviewer | CR-P0-3: Missing Quick Rule Index entries | §3.2 Quick Rule Index section + AC3b | Resolved |
| code-reviewer | CR-P1-1: tool-selection.md insertion position ambiguous | §6 AC3 clarified with line refs | Resolved |
| code-reviewer | CR-P1-5: AC19 grep escaping risk | §9 rewritten with single-quoted ERE | Resolved |
| code-reviewer | CR-P1-6: task_type yaml → mixed | Frontmatter fixed | Resolved |
| backend-architect | BA-P0-1: Missing poll interval/backoff + webhook | §3.1 Async API expanded | Resolved |
| backend-architect | BA-P0-2: Request hashing no re-generation escape | §3.1 + AC5b added | Resolved |
| backend-architect | BA-P0-3: Rate limiting strategy missing | §3.1 + AC5c added | Resolved |
| backend-architect | BA-P0-4: Remotion public/ vs assets/ path conflict | §3.1 Pipeline split by tool + AC14/16 updated | Resolved |
| backend-architect | BA-P1-2: AC19 needs both fal.ai and Atlas pricing | §6 AC19 updated | Resolved |
| backend-architect | BA-P1-3: Codex default path → convention move step | §3.1 Post-Generation File Placement added + AC14b | Resolved |
| backend-architect | BA-P1-6: Concrete chroma-key workaround | §6 AC25 updated | Resolved |

---

## 10. Blake Instructions

1. Read `.research/sessions/RS-20260508-001/report.md` FIRST — all rules must trace to a specific Claim
2. Review §9.2 Audit Trail — understand all 7 P0 fixes and why they were made
3. Review Project Knowledge lessons 1-5 below — especially #1 (Rule Sourcing) and #3 (Quick Rule Index heading match)
4. Create `references/ai-asset-generation.md` following the structure in §3.1 (note: expanded async API + pipeline sections per expert review)
5. Update CAPABILITY.md per §3.2 (routing table + Quick Rule Index + Step 0 prerequisites)
6. Update tool-selection.md per §3.3 (insert between lines 13-15 of existing file)
7. Run Layer 1 self-check: all 33 ACs (25 original + 8 added from expert review: AC2b, AC3b, AC4b, AC4c, AC5b, AC5c, AC14b, AC25b)
8. Run Layer 2: code-reviewer (required) + ≥1 additional expert

---

## 11. Decision Summary

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | Scope | Core ACs only / Full 25 ACs / Minimum | Full 25 ACs | 研究已完整覆盖，不需要分阶段 |
| 2 | Competitive positioning | Separate table / Embedded in tree / None | Embedded in decision tree | Agent 在做选择时看到对比，不用翻另一个表 |
| 3 | API provider | Pure fal.ai / Provider-agnostic / fal.ai + generic | fal.ai examples + generic rules | 换提供商只改代码示例不改规则 |
