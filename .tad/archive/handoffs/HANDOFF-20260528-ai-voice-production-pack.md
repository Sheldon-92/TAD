---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: [".claude/skills/ai-voice-production"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: AI Voice Production Capability Pack

**From:** Alex (Solution Lead)
**To:** Blake (Execution Master)
**Date:** 2026-05-28
**Priority:** P1
**Supersedes:** N/A

---

## 1. Task Overview

Build the **ai-voice-production** capability pack — a reference-based SKILL.md with 6 reference files providing judgment rules for AI-assisted voice production (TTS, voice cloning, voice design, audiobook/podcast/video dubbing pipelines).

Research is COMPLETE (NotebookLM notebook e2f862c7, 26 sources, 5 ask rounds). Findings at `.tad/evidence/research/ai-voice-production/`. Blake reads findings and writes the pack files.

## 2. Background & User Context

- User's hardware: **Mac Apple Silicon** (specific RAM TBD, assume 16GB as baseline)
- User's primary languages: **Chinese + English**
- Priority scenarios: **audiobook production** (最详细) + **blog/video narration** (详细), others at medium depth
- Pack style: **全景百科** — covers all 12 TTS tools with full comparison, not just user's specific tools
- Architecture: **reference-based** (same pattern as video-creation pack)

## 3. Requirements

### FR1: SKILL.md Router (~100 lines)
- YAML frontmatter with `name:` + `description:` (MANDATORY for Claude Code registration)
- Keywords: TTS, text-to-speech, 语音合成, voice cloning, 声音克隆, voice design, 音色设计, audiobook, 有声书, podcast, 播客, dubbing, 配音, narration, 旁白, audio production, 音频制作, voice acting, 语音, 朗读, prosody
- Quick Rule Index table pointing to 6 reference files
- Context Detection table (draft below — Blake refines):

  | User Signal | Load Reference |
  |---|---|
  | tool comparison, which TTS, choose | tool-landscape.md |
  | Mac, Apple Silicon, MPS, M-series, VRAM | apple-silicon.md |
  | clone voice, reference audio, sound like | voice-cloning.md |
  | audiobook, long-form, chapter, ACX, 有声书 | audiobook-pipeline.md |
  | narration, dubbing, podcast, blog voice, 配音 | narration-dubbing.md |
  | license, commercial, legal, watermark | licensing-safety.md |

- CONSUMES/PRODUCES declaration (see §3.1 Interface Contract below)
- Decision Entry Point (Q1: use case → Q2: hardware → route to reference)
- Anti-Skip Table (following video-creation pack pattern):
  - "I'll pick an appropriate TTS tool" → MUST use tool-landscape.md decision rules
  - "Short reference audio is fine" → MUST check minimum duration per tool in voice-cloning.md
  - "This tool is open source" → MUST check license tier in licensing-safety.md
  - "I'll master the audio later" → MUST apply ACX specs during pipeline, not after
- Step 0: Pack Prerequisites: Python 3.10+, FFmpeg (for post-processing), pip/uv

### §3.1 Interface Contract with video-creation pack (P0-2 FIX)

**Ownership boundary**: ai-voice-production pack OWNS all voice/TTS judgment:
- Tool selection for voice synthesis
- Voice cloning quality thresholds
- Audio mastering rules (ACX, podcast LUFS)
- Long-form consistency patterns

**video-creation pack** DEFERS to this pack for voice decisions. Its existing
TTS content in `references/ai-asset-generation.md` (lines 646-1035) covers
ElevenLabs/Fish Audio API integration — that is tool-specific API code, not
judgment rules. The two coexist:
- ai-voice-production: "which tool and why" (judgment)
- video-creation ai-asset-generation: "how to call the API" (integration code)

**Artifact handover**: ai-voice-production produces audio files.
- Format: WAV 48kHz (preferred) or 44.1kHz (ACX-ready)
- Naming: `{project}/{chapter|segment}-{NNN}.wav`
- video-creation pack consumes these as audio tracks

**Collision rule**: If both packs load, ai-voice-production takes precedence
for tool selection and quality thresholds. video-creation takes precedence
for video-specific timing (audio-to-video sync, pacing).

### FR2: references/tool-landscape.md
- Comparison matrix split into two tiers (P0-1 FIX):
  - **Tier A — Research-benchmarked** (have WER/SIM/RTF data): VoxCPM2, Fish S2 Pro, F5-TTS, Kokoro, Chatterbox-Turbo, Bark, MeloTTS, OpenVoice V2, Piper
  - **Tier B — Notable tools** (partial data, no full benchmarks): Qwen3-TTS, GPT-SoVITS, MLX-Audio, ChatTTS
- Columns: params, license, license-tier (GREEN/YELLOW/RED), best-for scenario (ALL tools)
- Benchmark columns (WER, SIM, RTF, VRAM): fill ONLY where research data exists, mark `N/R` (not researched) for others
- 4 quick selection rules (language, hardware, use case, commercial license)
- Tier B tools get a "Key Strength" text column instead of benchmark numbers

### FR3: references/apple-silicon.md
- 16GB memory budget table: only tools with VRAM data from research (VoxCPM2 ~8GB, Qwen3-TTS 6-8GB, Chatterbox ~6GB, Kokoro minimal, Bark-small <4GB)
- 32GB section: brief note that VoxCPM2 (2B) and Qwen3-TTS 1.7B are the main beneficiaries, no invented VRAM numbers for other tools
- MPS workaround configs from research: float32 for Qwen3-TTS Base, Chatterbox s3tokenizer patch, PYTORCH_ENABLE_MPS_FALLBACK for Kokoro
- Native frameworks: MLX-Audio (from research ask round 1)
- Decision rule: Mac user tool selection tree

### FR4: references/voice-cloning.md
- Three methods: zero-shot, fine-tuned, voice design (text description)
- Per-tool minimum reference duration table (from research ask round 3)
- Reference audio quality MUST/MUST NOT rules
- SIM/WER/MOS threshold interpretation guide (from research benchmarks)
- Failure modes table (noise leakage, accent bleeding, emotional flatness — all from ask round 5)
- Ultimate Cloning protocol (ref audio + transcript)
- **Boundary rule**: This file covers voice identity SETUP and VALIDATION. Chapter-level USE of that identity goes in audiobook-pipeline.md. Cross-reference, don't duplicate.

### FR5: references/audiobook-pipeline.md (**MOST DETAILED**)
- 4 non-negotiable requirements (from Fish Audio analysis in baseline report)
- Chunking strategy: sentence boundaries, chunk_size 100-150, Chatterbox defaults (from ask round 2)
- Consistency methods: seed locking, voice conditioning cache, FSQ bottleneck (from ask round 2)
- Multi-character management patterns
- Complete 5-step pipeline (manuscript prep → voice setup → generation → QC → post-processing)
- ACX/Audible specs (from ask round 2): MP3 192kbps, 44.1kHz, RMS -23 to -18 dB, peak <-3 dB
- ffmpeg mastering commands (DETERMINISTIC — exempt from AC9, see §8.1)
- Quality verification commands
- Throughput expectations
- Line estimate: ~150+ lines (this is the deepest file; exceed estimate freely for content completeness)

### FR6: references/narration-dubbing.md (**DETAILED**)
- Blog narration workflow (single voice, quick turnaround)
- Video dubbing workflow (emotion matching, multilingual)
- Chinese/English mixed-language strategy (MeloTTS advantage, from ask round 4)
- Short content (<5 min) vs medium content (5-30 min) decision paths
- Integration with video-creation pack (references §3.1 Interface Contract)
- Podcast specifications: -16 LUFS (Apple Podcasts), -14 LUFS (Spotify) — PLATFORM STANDARD, exempt from AC9

### FR7: references/licensing-safety.md
- GREEN/YELLOW/RED license classification for all tools (Tier A + Tier B)
- Watermarking traps (from ask round 5)
- Quality sabotage patterns (ChatTTS intentional degradation, from ask round 5)
- Decision rule: license check before deployment
- Anti-patterns: "open weights" != commercial use

## 4. Research Sources (Blake MUST read before writing)

1. **Baseline report**: `.tad/evidence/research/ai-voice-production/2026-05-28-baseline-report.md`
2. **Findings summary**: `.tad/evidence/research/ai-voice-production/2026-05-28-ask-findings-summary.md`
3. **NotebookLM notebook**: e2f862c7-d984-401c-b3c9-11c8c735668f (26 sources)

> Source: baseline report + 5 ask rounds. See §8.1 for the two-category traceability rule (research-grounded thresholds vs deterministic constants).

## 5. Files to Create

| # | File | Action | Lines Est. |
|---|------|--------|------------|
| 1 | `.claude/skills/ai-voice-production/SKILL.md` | CREATE | ~80 |
| 2 | `.claude/skills/ai-voice-production/references/tool-landscape.md` | CREATE | ~60 |
| 3 | `.claude/skills/ai-voice-production/references/apple-silicon.md` | CREATE | ~100 |
| 4 | `.claude/skills/ai-voice-production/references/voice-cloning.md` | CREATE | ~90 |
| 5 | `.claude/skills/ai-voice-production/references/audiobook-pipeline.md` | CREATE | ~130 |
| 6 | `.claude/skills/ai-voice-production/references/narration-dubbing.md` | CREATE | ~80 |
| 7 | `.claude/skills/ai-voice-production/references/licensing-safety.md` | CREATE | ~70 |

**Total**: 7 files, ~610 lines estimated

## 6. Files to Modify

| # | File | Action | Change |
|---|------|--------|--------|
| 1 | `.tad/research-notebooks/REGISTRY.yaml` | VERIFY | Notebook entry already added by Alex |

## 7. Acceptance Criteria

- [ ] AC1: SKILL.md has YAML frontmatter with `name:` + `description:` fields
  - Verify: `head -3 .claude/skills/ai-voice-production/SKILL.md | grep -c '^name:\|^description:'` → expected: 2
- [ ] AC2: All 6 reference files exist in `references/` subdirectory
  - Verify: `ls .claude/skills/ai-voice-production/references/*.md | wc -l` → expected: 6
- [ ] AC3: SKILL.md Quick Rule Index links to all 6 references with correct relative paths
  - Verify: `grep -c 'references/' .claude/skills/ai-voice-production/SKILL.md` → expected: ≥6
- [ ] AC4: tool-landscape.md contains Tier A matrix (9 researched tools with benchmark columns, N/R where data missing) AND Tier B section (4 notable tools with Key Strength text)
  - Verify: `grep -c 'N/R' .claude/skills/ai-voice-production/references/tool-landscape.md` → expected: ≥1 (proves N/R used for missing data)
- [ ] AC5: apple-silicon.md contains 16GB tool list with VRAM numbers from research (at least 5 tools)
  - Verify: `grep -cE '[0-9]+GB' .claude/skills/ai-voice-production/references/apple-silicon.md` → expected: ≥5
- [ ] AC6: audiobook-pipeline.md is the longest reference file (≥120 lines) with complete 5-step pipeline
  - Verify: `wc -l .claude/skills/ai-voice-production/references/audiobook-pipeline.md` → expected: ≥120
- [ ] AC7: narration-dubbing.md references video-creation pack integration (§3.1 Interface Contract)
  - Verify: `grep -c 'video-creation' .claude/skills/ai-voice-production/references/narration-dubbing.md` → expected: ≥1
- [ ] AC8: licensing-safety.md classifies tools using GREEN/YELLOW/RED tiers
  - Verify: `grep -oE 'GREEN|YELLOW|RED' .claude/skills/ai-voice-production/references/licensing-safety.md | sort -u | wc -l` → expected: 3
- [ ] AC9: Research-grounded thresholds (WER, SIM, RTF, VRAM, chunk_size) have inline `> Source: [file]` citation. Deterministic constants (ffmpeg syntax, ACX specs, LUFS standards) are exempt — see §8.1.
  - Verify: `grep -c '> Source:' .claude/skills/ai-voice-production/references/audiobook-pipeline.md` → expected: ≥3 (spot-check for citation pattern)
- [ ] AC10: Pack activates in Claude Code (visible in skill list after file creation)

## 8. Important Notes

### 8.1 Two-Category Traceability Rule (P0-3 FIX)

Content in this pack falls into two categories with different traceability requirements:

**Category A — Research-grounded thresholds** (MUST cite source):
Model-specific benchmarks (WER, SIM, RTF), VRAM usage, minimum reference audio duration,
chunk_size defaults, failure modes, tool-specific MPS workarounds.
These MUST have `> Source: baseline-report.md` or `> Source: ask-findings-summary.md` inline citation.
Example: `RTF ~0.13 with Nano-vLLM > Source: baseline-report.md §3`

**Category B — Deterministic constants** (exempt from citation):
ffmpeg command syntax, ACX/Audible published specs (44.1kHz, 192kbps, RMS -23 to -18 dB),
podcast LUFS standards (-16/-14 LUFS), file format specs, Python version requirements.
These are verifiable platform/tool documentation facts, not subjective judgment.
Blake may use domain knowledge for these without research traceability.

**Anti-slop rule remains**: The pack's value is specific numbers from research
(WER 0.99%, chunk_size 120, SIM 89%), not generic advice an LLM could generate
from training data. If a Category A number isn't in the research, don't include it.

### 8.2 Structure follows video-creation pack pattern
Reference: `.claude/skills/video-creation/` for the reference-based architecture pattern.
Line estimates are MINIMUMS — follow content completeness over line count.

### 8.3 audiobook-pipeline.md gets the most depth
User's primary interest. Include complete ffmpeg commands, not just descriptions.

---

## 🔴 Gate 2: Design Completeness

**执行时间**: 2026-05-28

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Reference-based, 7 files, clear routing, Anti-Skip Table |
| Components Specified | ✅ | All 7 files have detailed content requirements with boundary rules |
| Research Complete | ✅ | 26 sources, 5 ask rounds, findings saved |
| Data Flow Mapped | ✅ | §3.1 Interface Contract with video-creation pack (ownership + collision rule) |
| Expert Review | ✅ | 2 experts (code-reviewer + backend-architect), 6 P0s found and fixed |

**Gate 2 结果**: ✅ PASS (after P0 fixes)

**Alex确认**: 我已验证所有设计要素，Blake可以独立根据本文档完成实现。

---

## 📚 Project Knowledge

### ⚠️ Blake 必须注意的历史教训

- **Capability Pack: YAML Frontmatter is Load-Bearing** (architecture.md): Claude Code requires `name:` + `description:` YAML frontmatter. Without it, skill never activates.
- **Anti-AI-Slop as Cross-Pack Quality Bar** (architecture.md): Specific thresholds from research > generic principles from training data. Formula: specific threshold from research > generic principle from training data.
- **Capability Pack: Architecture Spectrum** (architecture.md): This is a reference-based pack (thin router + judgment rules in references/).
- **Source Citation Integrity for Adapted Values** (architecture.md): When citing research findings, cite BOTH the original source AND any adaptation. Citing only the original creates false provenance.
- **AC Verification Drift Pattern** (architecture.md): Every non-trivial AC verification command MUST be dry-run on representative artifacts during handoff drafting.

---

## 9.2 Expert Review Status

| Expert | Status | P0 Issues | Resolution |
|--------|--------|-----------|------------|
| code-reviewer | ✅ Done | P0-1: Tool list vs research data gap | Fixed: Tier A/B split in FR2, N/R for missing data, AC4 rewritten |
| code-reviewer | ✅ Done | P0-2: WER 1.84% in §8.1 | Fixed: Replaced with 0.99% + clarified two-category rule |
| code-reviewer | ✅ Done | P0-3: FR content beyond research scope | Fixed: §8.1 two-category rule (Category A needs citation, Category B exempt) |
| backend-architect | ✅ Done | P0-1: Tool list mismatch (same as CR P0-1) | Fixed: Tier A/B split |
| backend-architect | ✅ Done | P0-2: CONSUMES/PRODUCES collision | Fixed: §3.1 Interface Contract with ownership + collision rule |
| backend-architect | ✅ Done | P0-3: AC9 unverifiable | Fixed: Inline citation pattern `> Source:` + spot-check verification |

### P1 Integrations
| P1 | Source | Resolution |
|----|--------|------------|
| AC verification commands | Both | Added verification commands to all 10 ACs |
| Context Detection table draft | Both | Added to FR1 |
| Anti-Skip Table | Architect | Added to FR1 |
| License tier in tool matrix | Architect | Added license-tier column to FR2 |
| Step 0 Prerequisites | Code-reviewer | Added to FR1 |
| voice-cloning/audiobook boundary | Architect | Added boundary rule to FR4 |
| Line estimates are minimums | Code-reviewer | Added note in §8.2 |

### Audit Trail
| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | Tool list vs research data gap | FR2 Tier A/B split + AC4 rewrite | Resolved |
| code-reviewer | WER 1.84% not in research | §8.1 corrected to 0.99% | Resolved |
| code-reviewer | FR content beyond research scope | §8.1 two-category rule | Resolved |
| backend-architect | CONSUMES/PRODUCES undefined | §3.1 Interface Contract | Resolved |
| backend-architect | AC9 unverifiable | AC9 rewrite + citation pattern | Resolved |
| backend-architect | apple-silicon scope thin | Kept as separate file (Mac is user's primary hardware) | Resolved (design choice) |
