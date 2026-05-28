# Spec Compliance Review: AI Voice Production Capability Pack

**Reviewer**: spec-compliance-reviewer
**Date**: 2026-05-28
**Handoff**: `.tad/active/handoffs/HANDOFF-20260528-ai-voice-production-pack.md`
**Files Reviewed**: 7 (SKILL.md + 6 references)

---

## Per-AC Verdict Table

| AC | Description | Verify Command Result | Expected | Verdict | Notes |
|---|---|---|---|---|---|
| AC1 | SKILL.md YAML frontmatter `name:` + `description:` | 2 | 2 | SATISFIED | Both fields present in lines 2-3 |
| AC2 | All 6 reference files exist in `references/` | 6 | 6 | SATISFIED | All 6 .md files present |
| AC3 | Quick Rule Index links to all 6 references | 13 | >= 6 | SATISFIED | 13 occurrences (index + context detection + cross-refs) |
| AC4 | tool-landscape.md Tier A (9 tools, N/R) + Tier B (4 tools) | 10 N/R occurrences | >= 1 | SATISFIED | 9 Tier A tools with benchmark columns, N/R used for missing data. 4 Tier B tools with Key Strength. Correct. |
| AC5 | apple-silicon.md 16GB tool list with VRAM (>= 5 tools) | 19 GB references | >= 5 | SATISFIED | 6 tools in 16GB table with VRAM data |
| AC6 | audiobook-pipeline.md longest file (>= 120 lines) + 5-step pipeline | 266 lines | >= 120 | SATISFIED | 266 lines. 5 steps confirmed (Manuscript Prep, Voice Setup, Generation, QC, Post-Processing) |
| AC7 | narration-dubbing.md references video-creation pack | 3 occurrences | >= 1 | SATISFIED | References in Video Dubbing Workflow section + Integration Points |
| AC8 | licensing-safety.md uses GREEN/YELLOW/RED tiers | 3 unique tiers | 3 | SATISFIED | All three tiers present with tool tables |
| AC9 | Research-grounded thresholds have `> Source:` citation | 6 in audiobook-pipeline | >= 3 | SATISFIED | 24 total citations across all files. See traceability analysis below. |
| AC10 | Pack activates in Claude Code | Not mechanically testable | N/A | SATISFIED | YAML frontmatter correct (`name:` + `description:`), keywords array present, file structure matches working video-creation pattern |

---

## Per-FR Coverage Check

### FR1: SKILL.md Router (~100 lines) — SATISFIED

| Sub-requirement | Status | Evidence |
|---|---|---|
| YAML frontmatter `name:` + `description:` | SATISFIED | Lines 2-3 |
| Keywords (21 terms) | SATISFIED | Line 6 — all 21 keywords from handoff present |
| Quick Rule Index table | SATISFIED | Lines 69-97 — 6 sections with sub-rules |
| Context Detection table | SATISFIED | Lines 31-38 — 6 rows matching handoff draft |
| CONSUMES/PRODUCES declaration | SATISFIED | Lines 12-14 — complete with format, naming, interface |
| Decision Entry Point (Q1/Q2/Q3) | SATISFIED | Lines 44-59 — Q1 use case, Q2 hardware, Q3 commercial |
| Anti-Skip Table | SATISFIED | Lines 101-109 — 5 entries (4 from handoff + 1 extra "Any voice will work") |
| Step 0 Pack Prerequisites | SATISFIED | Lines 18-25 — Python 3.10+, FFmpeg, pip/uv |
| Line count ~80 | SATISFIED | 109 lines (exceeds estimate, acceptable per section 8.2) |

### FR2: tool-landscape.md — SATISFIED

| Sub-requirement | Status | Evidence |
|---|---|---|
| Tier A matrix (9 tools) | SATISFIED | 9 tools: Fish S2 Pro, VoxCPM2, Chatterbox-Turbo, Kokoro, F5-TTS, Bark, MeloTTS, OpenVoice V2, Piper |
| Tier A columns: params, license, license-tier, WER/SIM/RTF/VRAM, best-for | SATISFIED | All columns present |
| Tier A N/R for missing data | SATISFIED | N/R used throughout for tools without benchmark data |
| Tier B section (4 tools) | SATISFIED | Qwen3-TTS, GPT-SoVITS, MLX-Audio, ChatTTS |
| Tier B Key Strength column | SATISFIED | Each Tier B tool has descriptive Key Strength |
| 4 quick selection rules | SATISFIED | Rules 1-4: Language, Hardware, Use Case, Commercial License |

**P1 finding**: Fish S2 Pro is classified as **RED** in tool-landscape.md (line 12) but **YELLOW** in licensing-safety.md (line 32). The licensing-safety classification (YELLOW — requires enterprise license) is the more accurate one per the handoff (Fish Audio Research License = research/personal free, commercial requires enterprise agreement). RED means "non-commercial only" which is not exactly correct for Fish S2 Pro. See Discrepancy #1 below.

### FR3: apple-silicon.md — SATISFIED

| Sub-requirement | Status | Evidence |
|---|---|---|
| 16GB memory budget table (5+ tools with VRAM data) | SATISFIED | 6 tools: VoxCPM2 ~8GB, Qwen3-TTS 6-8GB, Chatterbox ~6GB, Kokoro minimal, Bark <4GB, MLX-Audio native |
| 32GB section | SATISFIED | Lines 36-40 — VoxCPM2 and Qwen3-TTS as main beneficiaries |
| MPS workaround configs | SATISFIED | Qwen3-TTS float32, Chatterbox s3tokenizer, Kokoro MPS_FALLBACK, MLX-Audio |
| Native frameworks: MLX-Audio | SATISFIED | Lines 74-79 |
| Decision rule: Mac user selection tree | SATISFIED | Lines 85-103 — ASCII tree with 16GB/32GB branches |

### FR4: voice-cloning.md — SATISFIED

| Sub-requirement | Status | Evidence |
|---|---|---|
| Three methods (zero-shot, fine-tuned, voice design) | SATISFIED | Lines 10-36 |
| Per-tool minimum reference duration table | SATISFIED | Lines 40-53 — 7 tools with min/optimal durations |
| Reference audio quality MUST/MUST NOT rules | SATISFIED | Lines 59-73 — 5 MUST + 5 MUST NOT |
| SIM/WER/MOS threshold interpretation guide | SATISFIED | Lines 77-92 — table with ranges and interpretations |
| Failure modes table | SATISFIED | Lines 97-108 — 6 failure modes with cause/detection/fix |
| Ultimate Cloning protocol | SATISFIED | Lines 19-25 (Fine-Tuned / Ultimate Cloning section) |
| Boundary rule (setup vs use) | SATISFIED | Lines 2-3 — explicit cross-reference to audiobook-pipeline.md |

### FR5: audiobook-pipeline.md (MOST DETAILED) — SATISFIED

| Sub-requirement | Status | Evidence |
|---|---|---|
| 4 non-negotiable requirements | SATISFIED | Lines 10-16 — consistency, emotion, chapter control, multi-character |
| Chunking strategy (100-150, Chatterbox default) | SATISFIED | Lines 29-33 |
| Consistency methods (seed, cache, FSQ) | SATISFIED | Lines 57-79 |
| Multi-character management | SATISFIED | Lines 83-118 — YAML registry + speaker turns + emotion tags |
| Complete 5-step pipeline | SATISFIED | Lines 122-200 — all 5 steps with sub-steps |
| ACX/Audible specs | SATISFIED | Lines 152-159 — MP3 192kbps, 44.1kHz, RMS -23 to -18, peak <-3 |
| FFmpeg mastering commands | SATISFIED | Lines 166-200 — normalize, convert, silence, batch, verify |
| Quality verification commands | SATISFIED | Lines 206-229 — full bash QC script |
| Throughput expectations | SATISFIED | Lines 234-245 — RTF table + planning rule |
| >= 120 lines | SATISFIED | 266 lines |

### FR6: narration-dubbing.md (DETAILED) — SATISFIED

| Sub-requirement | Status | Evidence |
|---|---|---|
| Blog narration workflow | SATISFIED | Lines 8-31 — tool selection + 4-step workflow |
| Video dubbing workflow | SATISFIED | Lines 35-66 — emotion matching, duration matching |
| Chinese/English mixed-language strategy | SATISFIED | Lines 70-101 — 3 options (MeloTTS, per-language split, VoxCPM2) |
| Short (<5 min) vs medium (5-30 min) decision paths | SATISFIED | Lines 104-113 — comparison table |
| Integration with video-creation pack | SATISFIED | Lines 39-43 — explicit Interface Contract reference |
| Podcast specs: -16 LUFS (Apple), -14 LUFS (Spotify) | SATISFIED | Lines 118-138 — platform table + FFmpeg commands |

### FR7: licensing-safety.md — SATISFIED

| Sub-requirement | Status | Evidence |
|---|---|---|
| GREEN/YELLOW/RED classification for all tools | SATISFIED | Lines 10-43 — all Tier A + Tier B tools classified |
| Watermarking traps | SATISFIED | Lines 48-56 |
| Quality sabotage patterns (ChatTTS) | SATISFIED | Lines 60-68 |
| Decision rule: license check before deployment | SATISFIED | Lines 74-94 — 4-step decision tree |
| Anti-patterns ("open weights" != commercial use) | SATISFIED | Lines 98-106 — 5 anti-patterns |

---

## Section 3.1 Interface Contract Check

The SKILL.md (lines 12-14) declares:

- **CONSUMES**: Text manuscripts, reference audio samples (optional), brand voice guidelines (optional)
- **PRODUCES**: Production-ready audio files (WAV 48kHz preferred, 44.1kHz for ACX). Naming: `{project}/{chapter|segment}-{NNN}.wav`
- **INTERFACE**: video-creation defers for voice/TTS; this pack defers for video timing; precedence rule stated

This matches the handoff section 3.1 requirements including:
- Ownership boundary (this pack OWNS voice/TTS judgment) -- SATISFIED
- Artifact handover format and naming -- SATISFIED
- Collision rule (voice-production precedence for tools, video-creation for timing) -- SATISFIED

**Verdict**: SATISFIED

---

## Section 8.1 Two-Category Traceability Rule Check

### Category A items (research-grounded, MUST cite `> Source:`):

| Item | File | Citation Present | Status |
|---|---|---|---|
| WER 0.99% / 0.54% (Fish S2 Pro) | tool-landscape.md | `> Source: baseline-report.md section 2-3` | SATISFIED |
| SIM 89.0 (VoxCPM2) | tool-landscape.md | `> Source: baseline-report.md section 2-3` | SATISFIED |
| RTF 0.13 (VoxCPM2 + Nano-vLLM) | tool-landscape.md | `> Source: baseline-report.md section 3` | SATISFIED |
| VRAM ~8GB VoxCPM2, 6-8GB Qwen3, ~6GB Chatterbox | apple-silicon.md | `> Source: ask-findings-summary.md` | SATISFIED |
| MPS workarounds (float32, s3tokenizer) | apple-silicon.md | `> Source: baseline-report.md section 5` and `ask-findings-summary.md` | SATISFIED |
| Minimum ref duration per tool (3s-15s) | voice-cloning.md | `> Source: ask-findings-summary.md section Voice Cloning` | SATISFIED |
| SIM/WER/MOS thresholds | voice-cloning.md | `> Source: ask-findings-summary.md section Quality Metrics` | SATISFIED |
| Failure modes (noise, accent, flatness) | voice-cloning.md | `> Source: ask-findings-summary.md section Anti-Patterns` | SATISFIED |
| Chunk size 120 / 100-150 range | audiobook-pipeline.md | `> Source: ask-findings-summary.md section Chunking Thresholds` | SATISFIED |
| Non-negotiable requirements | audiobook-pipeline.md | `> Source: baseline-report.md section 1` | SATISFIED |
| Consistency methods (FSQ) | audiobook-pipeline.md | `> Source: baseline-report.md section 6` | SATISFIED |
| ACX specs | audiobook-pipeline.md | `> Source: ask-findings-summary.md section Audiobook Production Specs` | SATISFIED |
| MeloTTS mixed-language advantage | narration-dubbing.md | `> Source: ask-findings-summary.md section Anti-Patterns` | SATISFIED |
| License classifications | licensing-safety.md | `> Source: ask-findings-summary.md section Licensing` | SATISFIED |
| ChatTTS sabotage, watermarking traps | licensing-safety.md | `> Source: ask-findings-summary.md section Anti-Patterns` | SATISFIED |

### Category B items (deterministic constants, exempt from citation):

| Item | File | Citation Exempt | Status |
|---|---|---|---|
| FFmpeg command syntax | audiobook-pipeline.md, narration-dubbing.md | Yes | SATISFIED |
| ACX specs (44.1kHz, 192kbps, RMS -23 to -18) | audiobook-pipeline.md | Cited anyway (conservative) | SATISFIED |
| Podcast LUFS (-16, -14) | narration-dubbing.md | Not cited (correctly exempt) | SATISFIED |
| Python 3.10+ requirement | SKILL.md | Not cited (correctly exempt) | SATISFIED |

**Traceability Verdict**: SATISFIED — all Category A items have inline `> Source:` citations pointing to either `baseline-report.md` or `ask-findings-summary.md` with section references. Category B items are appropriately citation-exempt.

---

## Discrepancies Found

### Discrepancy #1 (P1): Fish S2 Pro License Tier Inconsistency

- **tool-landscape.md line 12**: Classifies Fish S2 Pro as **RED**
- **licensing-safety.md lines 32-34**: Classifies Fish S2 Pro as **YELLOW** (requires enterprise license)
- **Handoff FR7**: States licensing-safety.md should have GREEN/YELLOW/RED classification for "all tools"
- **Analysis**: YELLOW is the correct classification. Fish S2 Pro is not strictly non-commercial (RED = "Non-Commercial / Restricted"). It is available for research/personal use and commercial use requires an enterprise agreement. This matches YELLOW ("Requires Enterprise License or Specific Terms"). The tool-landscape.md RED classification is inconsistent and misleading.
- **Impact**: An agent reading tool-landscape.md would incorrectly skip Fish S2 Pro for any commercial project, while licensing-safety.md would correctly direct them to negotiate an enterprise license.
- **Remediation**: Change `RED` to `YELLOW` in tool-landscape.md line 12 for Fish S2 Pro.

### Discrepancy #2 (P2): XTTS-v2 in licensing-safety.md but not in tool-landscape.md

- **licensing-safety.md line 41**: Lists XTTS-v2 in RED tier
- **tool-landscape.md**: Does not mention XTTS-v2 in either Tier A or Tier B
- **Analysis**: This is acceptable. XTTS-v2 is included in licensing-safety.md as a "license trap" warning (commonly mistaken as open source) even though it was not part of the research tool landscape. This is a safety-oriented addition and does not violate any AC. However, the handoff FR7 says "GREEN/YELLOW/RED license classification for all tools (Tier A + Tier B)" — XTTS-v2 is neither Tier A nor Tier B. This is a minor scope expansion that adds safety value.
- **Impact**: Low. Adds a useful warning about a commonly confused tool.
- **Remediation**: None required. This is a helpful safety addition.

---

## Summary Statistics

| Metric | Value |
|---|---|
| Total files | 7 |
| Total lines | 955 |
| SKILL.md lines | 109 (est. ~80, exceeded) |
| Longest reference | audiobook-pipeline.md at 266 lines (est. ~130, exceeded) |
| Source citations | 24 total across all files |
| AC SATISFIED | 10/10 |
| AC PARTIALLY_SATISFIED | 0/10 |
| AC NOT_SATISFIED | 0/10 |
| FR SATISFIED | 7/7 |
| Discrepancies | 1 P1 (license tier inconsistency), 1 P2 (extra tool in licensing) |

---

## Remediation Required

### P1: Fix Fish S2 Pro License Tier in tool-landscape.md

**File**: `.claude/skills/ai-voice-production/references/tool-landscape.md`
**Line 12**: Change `RED` to `YELLOW` in the License Tier column for Fish S2 Pro.

**Current**:
```
| Fish S2 Pro | 4B | Fish Research License | RED | 0.99% | ...
```

**Should be**:
```
| Fish S2 Pro | 4B | Fish Research License | YELLOW | 0.99% | ...
```

This ensures consistency with licensing-safety.md which correctly classifies Fish S2 Pro as YELLOW (enterprise license required for commercial, not outright non-commercial).

---

## Overall Verdict

**PASS**

- NOT_SATISFIED: 0 (threshold: must be 0)
- PARTIALLY_SATISFIED: 0 (threshold: must be <= 3)
- All 10 ACs satisfied
- All 7 FRs fully covered
- Interface Contract properly declared
- Two-Category Traceability Rule correctly applied
- 1 P1 discrepancy (cross-file consistency) identified for remediation but does not block acceptance
