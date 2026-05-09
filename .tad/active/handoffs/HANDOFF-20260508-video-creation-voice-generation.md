---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: Video-Creation Pack — AI Voice Generation Integration (TTS + Cloning + SFX)

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-05-08
**Project:** video-creation capability pack (~/video-creation/)
**Task ID:** TASK-20260508-002
**Handoff Version:** 3.1.0

---

## 🔴 Gate 2: Design Completeness

**执行时间**: 2026-05-08

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 5 new sections in ai-asset-generation.md, decision tree expanded |
| Components Specified | ✅ | 3 files (1 expand + 2 updates), all sections outlined |
| Functions Verified | ✅ | N/A (Markdown reference content) |
| Data Flow Mapped | ✅ | Decision tree + TTS→scene timing→mix pipeline |

**Gate 2 结果**: ✅ PASS

**Expert Review**: 2 experts (code-reviewer + backend-architect), 6 P0 + 6 P1 found, all Resolved. See §9.2.

**Alex确认**: 我已验证所有设计要素，Blake可以独立根据本文档完成实现。

---

## 📋 Handoff Checklist (Blake必读)

- [ ] 阅读了所有章节
- [ ] 阅读了 `.research/sessions/RS-20260508-002/report.md`（本 handoff 的研究基础）
- [ ] 阅读了现有 `~/video-creation/references/ai-asset-generation.md`（要在此基础上扩展）
- [ ] 阅读了现有 `~/video-creation/references/audio-design.md`（衔接点）
- [ ] 确认可以独立完成

---

## 1. Task Overview

### What
Expand `references/ai-asset-generation.md` to cover AI **voice generation** (TTS voiceover + voice cloning + AI sound effects), completing the Generate layer's third leg: **Images + Video + Voice + SFX**.

### Why
The pack currently has "Generate → image" (Codex) and "Generate → video" (Seedance) but no "Generate → voice." Agent must leave the pack to figure out TTS independently. audio-design.md has 3 lines mentioning TTS tools but no API integration rules, cost control, or cloning workflows.

### Scope
3 files in ~/video-creation/:
1. `references/ai-asset-generation.md` — **EXPAND** (add ~200-250 lines: TTS rules + cloning + SFX sections)
2. `CAPABILITY.md` — **UPDATE** (routing table + Quick Rule Index for voice signals)
3. `references/audio-design.md` — **UPDATE** (replace `### AI TTS Alternatives` section lines 243-259 with cross-ref; fix sidechaincompress bug at line 219)

---

## 2. Research Basis

- **Session:** RS-20260508-002
- **Report:** `.research/sessions/RS-20260508-002/report.md`
- **ACs:** `.research/sessions/RS-20260508-002/acs.md`
- **Notebook:** `65359194` (21 sources, 5 ask rounds)
- **Key sources:** ElevenLabs API docs (TTS + cloning + SFX), Fish Audio docs + API comparison blog, OpenAI TTS model docs, awesome-ai-voice list

⚠️ Blake 必须在写规则时参考 report.md 中的具体 Claim 和引用编号。

---

## 3. Technical Design

### 3.1 ai-asset-generation.md Expansion

**Decision Tree update** — expand the existing tree to include voice/audio branches:

```
Need to GENERATE visual assets? →
  [existing image/video branches unchanged]

Need to GENERATE audio assets? →

  Need voiceover / narration?
    Does Seedance already provide lip-synced speech for this scene?
      YES → Use Seedance native lip-sync audio (free, auto-synced) (CR-P0-1)
      NO ↓
    Is cross-lingual or CJK quality critical?
      YES → Fish Audio S2 Pro (80+ lang, 10s clone, best CJK)
      NO ↓
    Is maximum English expressiveness critical?
      YES → ElevenLabs v3 (industry benchmark for English drama/emotion)
      NO ↓
    → OpenAI TTS tts-1-hd (simplest, cheapest, good-enough quality)

  Need voice cloning (brand voice consistency)?
    ⚠️ CONSENT GATE: agent MUST confirm user has authorization before ANY clone API call (BA-P0-3)
    Is cross-lingual cloning needed?
      YES → Fish Audio (10-15s sample, 80+ lang cross-lingual)
      NO → ElevenLabs IVC (30-60s sample, English benchmark)

  Need standalone sound effects?
    Is the SFX tied to video motion (diegetic)?
      YES → Use Seedance native audio (free, auto-synced)
      NO → ElevenLabs SFX API (POST /v1/sound-generation, max 30s, looping)
```

**New sections to add (after existing "Quality Thresholds" section):**

#### 1. TTS Voiceover Rules (~100 lines)
- **⚠️ API Pattern: Synchronous Response (NOT Async)** — TTS APIs return audio bytes directly in HTTP response body. NO task_id, NO polling, NO webhook. This is the OPPOSITE of Seedance (submit-then-poll). Add anti-pattern: "❌ Use submit-then-poll for TTS → TTS returns bytes directly — no polling needed" (BA-P0-1)
- Tool comparison table (ElevenLabs vs OpenAI vs Fish Audio: models, languages, pricing, formats)
- Model selection rules PER TOOL (ElevenLabs: v3/Multilingual v2/Flash v2.5; OpenAI: tts-1/tts-1-hd/gpt-4o-mini-tts; Fish Audio: S1/S2 Pro) (CR-P0-1 per-model coverage)
- Batch mode rule: wait for full response, NOT streaming (for video production)
- Emotion control: ElevenLabs via text cues; Fish Audio via 15,000+ inline tags/(happy) syntax; OpenAI none
- Code example: ElevenLabs Python SDK TTS invocation
- **Format recommendation**: request WAV/PCM output for video production pipelines (lossless intermediate); Fish Audio MP3-only → transcode: `ffmpeg -i vo.mp3 -c:a pcm_s16le vo.wav` (BA-P1-1)
- Error handling: 429 rate limit → backoff 10s; 400 bad request patterns
- Rate limiting: serialize multi-scene TTS calls (1 at a time); TTS is fast (1-5s each) so serialization cost is low (BA-P1-4)
- **Timing rule: generate TTS BEFORE composing video** (voiceover duration drives scene timing — cross-ref audio-design.md)

#### 2. Voice Cloning Rules (~80 lines)
- **⚠️ Consent Gate (MANDATORY)** — before ANY voice cloning API call, agent MUST AskUserQuestion: "You are about to clone a voice from [sample]. Do you have authorization from the voice owner?" User must confirm YES before proceeding. Log confirmation. This applies to ALL platforms. Platform-specific consent (ElevenLabs voice-captcha) is ADDITIONAL, not replacement. (BA-P0-3)
- Fish Audio workflow: upload 10-15s sample → get voice_id → use in TTS calls
- ElevenLabs workflow: IVC (instant, 30-60s) vs PVC (professional, 30min+, 3-6h training)
- Recording quality rule: SNR >30dB matters more than sample length
- Cross-lingual rule: Fish Audio preferred for CJK; ElevenLabs for English-only
- voice_id lifecycle: store in project config, validate before first use (`client.voices.get(voice_id)` → handle 404), do NOT auto-re-create on 404 (requires sample + consent) (BA-P1-5)
- voice_id reference pattern (same for both: voice_id in API call)

#### 3. AI Sound Effects Rules (~40 lines)
- ElevenLabs SFX: POST /v1/sound-generation, text + duration_seconds + loop
- Max 30s, looping for ambient, 48kHz WAV for non-looping
- Decision: Seedance native audio (diegetic, free) vs ElevenLabs SFX (specific/imaginative)
- Cost: 40 credits/second

#### 4. Voice Pipeline Integration (~40 lines)
- File path convention: assets/generated-audio/voiceover/ + assets/generated-audio/sfx/ (HyperFrames) or public/ (Remotion)
- Audio priority order: voiceover (100%) > SFX (duck) > music (10-20%)
- Fish Audio timestamps API for subtitle/caption sync
- Cross-reference: audio-design.md volume mix rules + FFmpeg ducking commands

#### 5. Voice Cost Control (~30 lines)
- Cost comparison: ElevenLabs (subscription $5+/mo) vs OpenAI ($15-30/1M chars) vs Fish Audio ($15/1M UTF-8 bytes)
- ElevenLabs SFX: 40 credits/second
- Batch billing rule: set API keys to avoid plan overconsumption

### 3.2 CAPABILITY.md Updates

**Step 0 Prerequisites** — add:
```
- **ElevenLabs API key** (`ELEVENLABS_API_KEY`) — for TTS, voice cloning, and AI SFX (optional)
- **Fish Audio API key** — for cross-lingual TTS and voice cloning (optional, alternative to ElevenLabs)
```

**Step 1 Routing Table** — add new rows:
```
| voiceover / narration / TTS / text-to-speech / generate voice | references/ai-asset-generation.md §TTS Voiceover Rules |
| voice clone / brand voice / clone voice / custom voice | references/ai-asset-generation.md §Voice Cloning Rules |
| sound effect / SFX / generate sound / ambient / foley | references/ai-asset-generation.md §AI Sound Effects Rules |
```

**Quick Rule Index** — add to existing `### AI Asset Generation` subsection:
```
- **TTS Tool Selection**: English expressiveness → ElevenLabs; CJK/cross-lingual → Fish Audio; simple/cheap → OpenAI → §TTS Voiceover Rules
- **Voice-First Timing Rule**: Generate TTS voiceover BEFORE composing video scenes — voiceover duration drives scene timing → §Voice Pipeline Integration
- **Clone Minimum**: Fish Audio 10s; ElevenLabs 30-60s (IVC) / 30min (PVC) → §Voice Cloning Rules
- **SFX Source Rule**: Diegetic/scene-tied → Seedance native; specific/imaginative/looping → ElevenLabs SFX API → §AI Sound Effects Rules
```

### 3.3 audio-design.md Updates

**Update 1 — Replace `### AI TTS Alternatives` section (lines 243-259, 17 lines, NOT 3 lines — CR-P0-3):**
Replace from `### AI TTS Alternatives` heading through the closing `</speak>` XML tag with:
```
### AI TTS & Voice Generation
For comprehensive TTS, voice cloning, and AI sound effects rules, see
**references/ai-asset-generation.md §TTS Voiceover Rules**.
This section covers tool comparison, API integration, emotion control,
voice cloning workflows, and cost control.
```
⚠️ Keep `## TTS Integration Rules` (line 102, Whisper/caption accuracy section) UNCHANGED — it covers caption alignment, not voice generation.

**Update 2 — Fix sidechaincompress bug (line 219 — BA-P0-2):**
Change `attack=0.1:release=0.3` to `attack=10:release=300` (milliseconds, consistent with the correct example at line 56 which uses `attack=20:release=250` and the warning note at line 224).

Keep all other existing voiceover volume rules, FFmpeg ducking commands, and mixing rules in audio-design.md (they're about MIXING, not GENERATING).

---

## 4. Files to Modify

| # | File | Action | Lines Est. |
|---|------|--------|-----------|
| 1 | ~/video-creation/references/ai-asset-generation.md | EXPAND (+200-250 lines) | ~660-710 total |
| 2 | ~/video-creation/CAPABILITY.md | UPDATE (Step 0 + routing + Quick Rule Index) | ~20 lines added |
| 3 | ~/video-creation/references/audio-design.md | UPDATE (replace shallow TTS section with cross-ref) | ~5 lines changed |

**Grounded Against:**
- ~/video-creation/references/ai-asset-generation.md (full read, 2026-05-08)
- ~/video-creation/CAPABILITY.md (full read, 2026-05-08)
- ~/video-creation/references/audio-design.md (grep'd TTS section, 2026-05-08)

---

## 5. Acceptance Criteria

### Decision Tree
- [ ] AC1: Decision tree expanded with "Need to GENERATE audio assets?" branch containing TTS / cloning / SFX sub-branches
- [ ] AC1b: TTS sub-tree includes Seedance lip-sync check as FIRST node before TTS tool routing (CR-P0-1)
- [ ] AC2: TTS sub-tree routes: Fish Audio (CJK) / ElevenLabs (English expressiveness) / OpenAI (simple/cheap)
- [ ] AC3: SFX decision: Seedance native (diegetic) vs ElevenLabs SFX (specific/imaginative)
- [ ] AC4: Voice cloning decision: Fish Audio (cross-lingual) vs ElevenLabs IVC/PVC (English)

### TTS Integration
- [ ] AC5: Tool comparison table with per-platform model selection rules (ElevenLabs 3 models, OpenAI 3 models, Fish Audio 2 models)
- [ ] AC5b: Explicit "API Pattern: Synchronous Response (NOT Async)" rule positioned BEFORE code example, with anti-pattern entry (BA-P0-1)
- [ ] AC6: Batch mode rule: "wait for full response, NOT streaming" for video production
- [ ] AC7: Emotion control rules: ElevenLabs text cues, Fish Audio inline tags, OpenAI none
- [ ] AC8: ElevenLabs Python SDK code example for TTS
- [ ] AC8b: Format recommendation: WAV/PCM for video pipelines; Fish Audio MP3→WAV transcode command (BA-P1-1)
- [ ] AC9: Timing rule: "generate TTS BEFORE composing video"

### Voice Cloning
- [ ] AC10: Fish Audio cloning workflow: 10-15s sample → voice_id → API calls
- [ ] AC11: ElevenLabs cloning: IVC vs PVC with requirements
- [ ] AC12: Recording quality rule: SNR >30dB
- [ ] AC13: Consent Gate (MANDATORY): agent must AskUserQuestion for authorization BEFORE any clone API call (BA-P0-3)
- [ ] AC13b: voice_id lifecycle: store, validate before use, handle 404, do NOT auto-re-create (BA-P1-5)

### Sound Effects
- [ ] AC14: ElevenLabs SFX API: endpoint + duration + looping documented
- [ ] AC15: Max 30s, output formats (MP3/WAV 48kHz/PCM 44.1kHz Pro tier)

### Pipeline
- [ ] AC16: File path convention: generated-audio/voiceover/ + generated-audio/sfx/ + generated-audio/cloned-voices/
- [ ] AC17: Audio priority order documented (voiceover > SFX > music)
- [ ] AC17b: Seedance native audio + TTS voiceover collision rule: strip Seedance speech audio when TTS voiceover exists for same scene (BA-P1-3)
- [ ] AC18: Fish Audio timestamps API for subtitle sync mentioned

### Cost & Routing
- [ ] AC19: Cost comparison table for all 3 TTS platforms (note ElevenLabs credit pricing varies by plan — BA-P1-2)
- [ ] AC20: CAPABILITY.md Step 1 has ≥3 new voice-related routing rows
- [ ] AC21: Quick Rule Index has ≥4 new voice-related rule pointers, section headings WITHOUT numeric prefixes for byte-exact match (CR-P1-5)
- [ ] AC22: audio-design.md `### AI TTS Alternatives` (lines 243-259) replaced with cross-ref; `## TTS Integration Rules` (line 102) unchanged (CR-P0-3)
- [ ] AC22b: audio-design.md sidechaincompress bug fixed: line 219 `attack=0.1:release=0.3` → `attack=10:release=300` (BA-P0-2)

---

## 6. Important Notes

### 6.1 Merge Strategy
Blake 在现有 ai-asset-generation.md (~460行) 末尾添加新 section，不修改现有的 Seedance/Codex 内容。决策树是唯一需要修改现有内容的地方（扩展 "Need to GENERATE visual assets?" 为 "visual + audio"）。

### 6.2 audio-design.md 保留边界
audio-design.md 保留所有关于混音、音量、FFmpeg 命令、BPM 规则的内容。只替换 "### AI TTS Alternatives" 这个 3 行浅列表。生成 vs 混音 的分界线清晰：ai-asset-generation.md = "怎么生成音频"，audio-design.md = "怎么混合音频"。

---

## 📚 Project Knowledge — ⚠️ Blake 必须注意的历史教训

1. **Capability Pack Rule Sourcing** (2026-05-07) — 规则必须追溯到 report.md 的 Claim，不能凭训练数据。
2. **Research Findings ≠ API Ground Truth** (2026-05-07) — API 参数名必须 WebFetch 官方文档确认。
3. **Quick Rule Index: Exact Heading Match** (2026-05-08) — §指针必须与 reference 的 ## 标题 byte-exact。

---

## 9. Spec Compliance Checklist

| AC | Verification Method | Expected |
|----|---------------------|----------|
| AC1 | `grep -c 'GENERATE audio' ~/video-creation/references/ai-asset-generation.md` | ≥1 |
| AC1b | `grep -cE 'lip-sync.*Seedance\|Seedance.*lip-sync' ~/video-creation/references/ai-asset-generation.md` | ≥1 |
| AC2 | `grep -cE 'Fish Audio\|ElevenLabs\|OpenAI TTS' ~/video-creation/references/ai-asset-generation.md` | ≥12 |
| AC5 | `grep -c '## TTS Voiceover Rules' ~/video-creation/references/ai-asset-generation.md` | ≥1 |
| AC5b | `grep -cE 'Synchronous\|NOT Async\|no polling\|returns.*bytes' ~/video-creation/references/ai-asset-generation.md` | ≥2 |
| AC13 | `grep -cE 'authorization\|consent\|MUST.*confirm\|Consent Gate' ~/video-creation/references/ai-asset-generation.md` | ≥2 |
| AC14 | `grep -c '/v1/sound-generation' ~/video-creation/references/ai-asset-generation.md` | ≥1 |
| AC20 | `grep -c 'ai-asset-generation' ~/video-creation/CAPABILITY.md` | ≥11 |
| AC22 | `grep -c 'ai-asset-generation.md' ~/video-creation/references/audio-design.md` | ≥1 |
| AC22b | `grep -c 'attack=10:release=300' ~/video-creation/references/audio-design.md` | ≥1 |

---

## 9.2 Expert Review — Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | CR-P0-1: Research AC4 (Seedance lip-sync routing) missing | §3.1 decision tree + AC1b | Resolved |
| code-reviewer | CR-P0-2: AC20 grep arithmetic wrong | §9 AC20 corrected to ≥11 | Resolved |
| code-reviewer | CR-P0-3: audio-design.md scope "3 lines" → actually 17 lines | §3.3 exact line range + §Scope | Resolved |
| code-reviewer | CR-P1-1: Decision tree insertion points ambiguous | Noted — Blake Instructions updated | Resolved |
| code-reviewer | CR-P1-5: Quick Rule Index heading format must match | §5 AC21 note added | Resolved |
| backend-architect | BA-P0-1: TTS sync vs Seedance async not distinguished | §3.1 TTS section + AC5b | Resolved |
| backend-architect | BA-P0-2: sidechaincompress bug at line 219 | §3.3 Update 2 + AC22b | Resolved |
| backend-architect | BA-P0-3: Voice cloning missing consent gate | §3.1 Cloning Rules + AC13 | Resolved |
| backend-architect | BA-P1-1: TTS output format mismatch with WAV pipeline | §3.1 TTS format recommendation + AC8b | Resolved |
| backend-architect | BA-P1-3: Seedance audio + TTS collision undocumented | §5 AC17b added | Resolved |
| backend-architect | BA-P1-4: Concurrent TTS rate limiting missing | §3.1 TTS rate limiting added | Resolved |
| backend-architect | BA-P1-5: voice_id lifecycle missing | §3.1 Cloning Rules + AC13b | Resolved |

---

## 10. Blake Instructions

1. Read `.research/sessions/RS-20260508-002/report.md` FIRST — all rules must trace to Claims
2. Review §9.2 Audit Trail — understand all 6 P0 fixes and why
3. Read existing `~/video-creation/references/ai-asset-generation.md` (understand current ~460-line structure)
4. Read existing `~/video-creation/references/audio-design.md` lines 100-260 (TTS Integration Rules + AI TTS Alternatives sections)
5. Expand decision tree — audio branch goes INSIDE the existing ``` code fence, immediately after the Seedance default line (~line 35). NOT a second tree. (CR-P1-1)
6. Add 5 new sections (TTS, Cloning, SFX, Pipeline, Cost) AFTER the Anti-Patterns table at end of file (~line 612). Section headings must NOT have numeric prefixes (write `## TTS Voiceover Rules` not `## 1. TTS Voiceover Rules`) for Quick Rule Index byte-exact match. (CR-P1-5)
7. Update CAPABILITY.md (Step 0 + 3 routing rows + 4 Quick Rule Index pointers)
8. Update audio-design.md: (a) replace lines 243-259 with cross-ref, (b) fix line 219 sidechaincompress
9. Layer 1: 30 ACs (22 original + 8 from expert review: AC1b, AC5b, AC8b, AC13, AC13b, AC17b, AC22b)
10. Layer 2: code-reviewer (required) + ≥1 expert

---

## 11. Decision Summary

| # | Decision | Options | Chosen | Rationale |
|---|----------|---------|--------|-----------|
| 1 | File structure | New file vs expand existing | Expand ai-asset-generation.md | Generate 层一个入口点，agent 不用判断去哪个文件 |
| 2 | TTS default | ElevenLabs vs Fish Audio vs OpenAI | Decision tree (no single default) | 用途决定工具，不是"最好的工具" |
| 3 | SFX strategy | All standalone vs Seedance first | Seedance first for diegetic, standalone for specific | 避免付费 SFX 替代免费 Seedance 原生音效 |
