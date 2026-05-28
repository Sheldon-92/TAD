# Code Review: AI Voice Production Capability Pack

**Reviewer**: code-reviewer (independent Layer 2)
**Date**: 2026-05-28
**Files reviewed**: 7 pack files + 2 research evidence files + handoff (sections 3 + 8.1)
**Review scope**: Anti-slop compliance, cross-file consistency, citation integrity, FR completeness

---

## Summary

Reference-based capability pack: 1 SKILL.md router + 6 reference files covering TTS tool selection, Apple Silicon optimization, voice cloning, audiobook pipeline, narration/dubbing, and licensing. Research base: NotebookLM notebook with 26 sources and 5 ask rounds. Two research evidence files (baseline-report.md and ask-findings-summary.md) serve as the Category A traceability ground truth.

Overall build quality is high. Architecture follows the reference-based pattern correctly, cross-file references are clean, and the majority of specific numbers (WER, SIM, RTF, VRAM, chunk sizes) trace cleanly to research. The two-category traceability rule from handoff section 8.1 is correctly applied in most places. There are 24 total `> Source:` citations across 6 reference files.

However, I found issues where specific numbers appear in the pack but NOT in the research evidence -- these are anti-slop violations that need correction before shipping.

---

## P0 Findings (Blocking)

### P0-1: voice-cloning.md Reference Duration Table contains 3 entries not in research

**File**: `.claude/skills/ai-voice-production/references/voice-cloning.md` lines 49-51
**Rule violated**: Anti-slop (Category A number without research backing) + citation integrity (false provenance)

The research (`ask-findings-summary.md` lines 22-27, "Voice Cloning Minimum Reference Duration") provides per-tool minimum durations for exactly 5 tools:
- 3s: Qwen3-TTS, NeuTTS Air
- 5s: GPT-SoVITS, VibeVoice
- 6s: XTTS-v2
- 10s: Chatterbox
- 15s: Kokoro

The pack's table includes these 5 (minus NeuTTS Air and VibeVoice -- see P0-3) plus 3 tools NOT in the research duration list:
- OpenVoice V2: 10s
- VoxCPM2: 10s
- Fish S2 Pro: 10s

The table cites `> Source: ask-findings-summary.md` for the entire table, but that source does NOT contain entries for these three tools. The baseline-report.md section 4 does say "10-30 seconds of reference audio" generically for zero-shot cloning (OpenVoice, Fish Speech, VoxCPM2), but this is a general range, not per-tool measured minimums. Presenting these as "Minimum Duration" values in the same table as research-measured values creates false provenance -- the reader cannot distinguish measured minimums from inferred floor values.

**Fix**: Either (a) remove the 3 non-researched entries, keeping only tools with explicit research data, or (b) add a footnote distinguishing measured minimums from inferred values: "* Inferred from general zero-shot cloning range (baseline-report.md section 4), not tool-specific measurement." The citation line must NOT imply the ask-findings-summary covers all rows.

### P0-2: "FSQ Bottleneck" claim in audiobook-pipeline.md has no research source

**File**: `.claude/skills/ai-voice-production/references/audiobook-pipeline.md` lines 77-78
**Rule violated**: Anti-slop (specific technical claim without research backing)

The file states: "VoxCPM2 uses Finite Scalar Quantization as a consistency bottleneck -- the tokenizer-free architecture inherently resists drift."

The research describes VoxCPM2 as "Tokenizer-free Diffusion-AR" (baseline-report.md line 18) but never mentions "Finite Scalar Quantization" or "FSQ" in either evidence file. The term "Finite Scalar Quantization" appears to come from general model knowledge, not from the research notebook. The citation on line 80 covers the chunking content above but does not cover the FSQ claim.

The second half of the sentence ("tokenizer-free architecture inherently resists drift") IS supported by the research's "Tokenizer-free Diffusion-AR" descriptor.

**Fix**: Replace line 77-78 with: "VoxCPM2's tokenizer-free architecture inherently resists drift. No additional configuration needed." Remove the "Finite Scalar Quantization" label. If FSQ is genuinely part of VoxCPM2's architecture, it needs a research source added.

### P0-3: Two researched tools (NeuTTS Air, VibeVoice) absent from pack without justification

**File**: All pack files
**Rule violated**: Research data completeness -- research findings dropped without documentation

The research `ask-findings-summary.md` lists minimum reference durations for NeuTTS Air (3s) and VibeVoice (5s). These tools appear NOWHERE in any of the 7 pack files. Meanwhile, XTTS-v2 (also from the same research duration list, at 6s) IS included in licensing-safety.md as a RED-tier tool.

The handoff FR2 specifies "Tier A = 9 researched tools, Tier B = 4 notable tools" -- a fixed list that does not include NeuTTS Air or VibeVoice. So the handoff itself may have excluded them. However, the pack now has a gap: two tools with researched data are absent, and the voice-cloning.md duration table omits them while simultaneously adding 3 non-researched tools (P0-1). This creates a credibility inversion -- the pack has entries WITHOUT research data but lacks entries WITH research data.

**Fix**: Add NeuTTS Air and VibeVoice to voice-cloning.md's Reference Duration Table (they have research-backed durations). If they should also appear in tool-landscape.md Tier B, add them there. If intentionally excluded from tool-landscape.md, add a comment in voice-cloning.md explaining the scope difference (e.g., "Duration data exists from research but tool not included in landscape table due to insufficient benchmark data").

---

## P1 Findings (Should Fix)

### P1-1: Chatterbox naming and params inconsistency across 6 files

**Files**: tool-landscape.md, apple-silicon.md, voice-cloning.md, audiobook-pipeline.md, narration-dubbing.md, licensing-safety.md

Three different names are used:
- "Chatterbox-Turbo" (tool-landscape.md line 14, narration-dubbing.md line 53, licensing-safety.md line 17)
- "Chatterbox-TTS" (apple-silicon.md line 16)
- "Chatterbox" (voice-cloning.md line 47, audiobook-pipeline.md lines 19/29/116)

Two different param values:
- 350M (tool-landscape.md, from baseline-report.md)
- 350M-1.2B (apple-silicon.md, from ask-findings-summary.md)

The research sources themselves are split: baseline-report uses "Chatterbox-Turbo 350M", ask-findings uses "Chatterbox-TTS 350M-1.2B". Both are correct (Turbo is the 350M distilled variant; TTS is the full model family up to 1.2B). But the pack does not explain this distinction, leaving readers with apparent contradictions.

**Fix**: Adopt one canonical reference per context. Suggest: "Chatterbox-Turbo (350M)" when referring to the inference variant and "Chatterbox-TTS (350M-1.2B)" when referring to the full model family (as in VRAM planning). Add a one-line note in tool-landscape.md Key Benchmark Notes or in apple-silicon.md explaining the naming relationship.

### P1-2: Quality threshold interpretation bands in voice-cloning.md are derived without marking

**File**: `.claude/skills/ai-voice-production/references/voice-cloning.md` lines 82-92
**Rule**: Source Citation Integrity for Adapted Values (architecture.md)

The SIM threshold bands:
- >85% "Excellent -- production-ready"
- 70-85% "Acceptable"
- <70% "Poor"

The research states "Speaker Similarity (SIM): 70-90% range for high-fidelity cloning" -- establishing 70-90% as the overall quality range but not defining an 85% split point. The 85% threshold is a judgment-based interpolation.

The WER threshold bands:
- <2% "Excellent intelligibility"
- 2-5% "Acceptable"
- >5% "Poor"

The research states "WER acceptable: EN 1-3%, ZH 0.5-2.5%". The pack's <2% "Excellent" boundary is TIGHTER than the research's upper acceptable bound (3% for EN). The 5% "Poor" boundary has no research backing.

The citation on line 93 references N-MOS/S-MOS ranges specifically but appears to cover the entire table by proximity, creating ambiguity about which rows are research-grounded and which are derived.

**Fix**: Add a note above the SIM/WER rows: "SIM and WER tier boundaries are derived interpretations based on research ranges (SIM 70-90%, WER EN 1-3%, ZH 0.5-2.5%). The exact cutoffs are operational guidelines, not measured thresholds." This satisfies the architecture.md rule: "cite BOTH the original source AND the adaptation."

### P1-3: MPS fallback "~10-20% slower" in apple-silicon.md is uncited

**File**: `.claude/skills/ai-voice-production/references/apple-silicon.md` line 69
**Rule**: Category A (hardware performance threshold) needs research backing

The comment says: `# Performance impact: ~10-20% slower than native MPS, still faster than CPU`

Neither research file contains a performance degradation percentage for MPS fallback mode. This is a plausible general estimate but is not research-grounded.

**Fix**: Change to qualitative: `# Performance impact: some ops fall back to CPU -- expect slower than native MPS, still faster than CPU-only`.

### P1-4: SKILL.md Anti-Skip Table "retrofitting is 2-3x effort" is uncited

**File**: `.claude/skills/ai-voice-production/SKILL.md` line 109
**Rule**: Anti-slop (specific multiplier without research backing)

The text says: "MUST set up voice identity BEFORE generation in voice-cloning.md -- retrofitting is 2-3x effort". The "2-3x" multiplier does not appear in either research file.

**Fix**: Replace with: "retrofitting is significantly more effort" or just "retrofitting voice identity after generation is costly and may require full re-generation".

---

## P2 Findings (Suggestions)

### P2-1: XTTS-v2 in licensing-safety.md but absent from tool-landscape.md

XTTS-v2 appears in licensing-safety.md RED tier (line 41) and has research data (6s min ref duration) but is not in either Tier A or Tier B of tool-landscape.md. Since it has researched data AND is a common "trap" tool users encounter, adding it to Tier B with License Tier: RED would be useful. The handoff's Tier B list (Qwen3-TTS, GPT-SoVITS, MLX-Audio, ChatTTS) does not include it, so this may be an intentional scope decision.

### P2-2: narration-dubbing.md MeloTTS citation may be inaccurate

narration-dubbing.md line 84 cites `> Source: ask-findings-summary.md Anti-Patterns (MeloTTS advantage noted for mixed language)`. However, the Anti-Patterns section of ask-findings-summary.md mentions ChatTTS, Qwen3-TTS, Chatterbox-Turbo, XTTS-v2, Fish S2 Pro, and GPT-SoVITS -- but NOT MeloTTS. The mixed-language advantage claim likely comes from a deeper ask round not captured in the summary. The citation should reference the correct source or note "(from ask round 4, not in summary)".

### P2-3: narration-dubbing.md chunking threshold "100-150 chars" in Short vs Medium table lacks citation

narration-dubbing.md line 108 includes "Recommended (100-150 chars)" in the Medium content column. This is a Category A threshold from `ask-findings-summary.md` section Chunking Thresholds ("OOM mitigation: reduce to 100-150") but has no `> Source:` citation. The file has only 1 citation total, leaving Category A content uncited.

### P2-4: audiobook-pipeline.md ACX noise floor and silence specs may need Category B verification

audiobook-pipeline.md lines 157-159 specify "-60dB noise floor", "0.5-1.0s opening silence", "1.0-5.0s closing silence". The research only mentions "Silent segment at chapter start required" without durations. These values are likely legitimate ACX published standards (Category B exempt per handoff section 8.1), but since neither research file contains them AND they are quite specific, a brief "(ACX published standard)" note would make the Category B classification explicit and prevent future reviewers from flagging them.

### P2-5: Kokoro throughput estimate could mislead

audiobook-pipeline.md line 239 lists Kokoro's 1-hour audio generation time as "~15-30 minutes (estimated)". The "(estimated)" is honest, but including it in a table alongside research-backed RTF numbers (VoxCPM2 RTF 0.13 = ~8 minutes) could blur the distinction between measured and estimated values. Consider marking as "N/R (estimated fast)" or removing.

### P2-6: F5-TTS license "Open-Source" is the vaguest entry in the pack

tool-landscape.md line 16 and licensing-safety.md line 24 both list F5-TTS as "Open-Source" GREEN. Every other tool has a specific license identifier (Apache-2.0, MIT, CC BY-NC 4.0). The GREEN classification without a named license is weaker assurance. The research baseline-report also says "Open-Source" without specifics, so this is research-accurate but potentially misleading.

### P2-7: audiobook-pipeline.md "15,000+ paralinguistic tags" for Fish S2 Pro could clarify source

audiobook-pipeline.md line 114 says "Fish S2 Pro supports 15,000+ paralinguistic tags" and SKILL.md's Quick Rule Index says "15K+ paralinguistic tags". This number IS in the research (baseline-report.md line 17), and tool-landscape.md line 12 cites it. Good. However, the audiobook-pipeline.md instance on line 114 is not near a citation. The nearest `> Source:` on line 118 covers it -- acceptable proximity but could be clearer.

---

## Cross-File Consistency Matrix

| Check | Status | Details |
|---|---|---|
| Tool names consistent | FAIL (P1-1) | Chatterbox: 3 name variants |
| Params consistent | FAIL (P1-1) | Chatterbox: 350M vs 350M-1.2B |
| License tiers consistent | PASS | All tools match between tool-landscape.md and licensing-safety.md |
| VRAM numbers consistent | PASS | VoxCPM2 ~8GB, Chatterbox ~6GB, Bark <4GB match across files |
| Reference file paths correct | PASS | All 6 paths use `references/` prefix, SKILL.md has 13 references |
| Cross-file links functional | PASS | voice-cloning.md -> audiobook-pipeline.md, narration-dubbing.md -> all others |
| Interface contract present | PASS | SKILL.md CONSUMES/PRODUCES/INTERFACE + narration-dubbing.md video-creation reference |
| WER numbers consistent | PASS | 0.99% EN, 0.54% ZH in tool-landscape.md matches research exactly |
| SIM numbers consistent | PASS | 89.0 (FI), 79.1 (AR) in tool-landscape.md matches research exactly |
| RTF numbers consistent | PASS | 0.13 in tool-landscape.md and audiobook-pipeline.md matches research |

## Anti-Slop Assessment

**Score: Strong (with exceptions noted above)**

Numbers confirmed traceable to research:
- Fish S2 Pro: WER 0.99% EN, 0.54% ZH, 81.88% EmergentTTS-Eval win rate, 4B params, 15,000+ paralinguistic tags
- VoxCPM2: SIM 89.0 (FI), 79.1 (AR), 1.68% avg error rate, 2B params, RTF 0.13 w/ Nano-vLLM
- Kokoro: 82M params
- Chatterbox: 350M (Turbo), 120 chars default chunk, 10s min ref
- Qwen3-TTS: 3s min ref, 6-8GB VRAM, float32 mandatory on MPS
- N-MOS: 3.91-4.25, S-MOS: 3.97-4.18

Numbers NOT traceable to research (flagged above):
- OpenVoice V2 / VoxCPM2 / Fish S2 Pro "10s" min ref duration (P0-1)
- "Finite Scalar Quantization" architecture label (P0-2)
- "~10-20% slower" MPS fallback (P1-3)
- "2-3x effort" retrofitting (P1-4)
- SIM 85% / WER 2%/5% tier cutoffs (P1-2)
- SNR >30dB (minor, arguably Category B)

The pack's core value IS its specific research-grounded numbers, and the majority pass traceability. The flagged items are localized and fixable.

## FR Completeness

| FR | Status | Notes |
|---|---|---|
| FR1: SKILL.md Router | PASS | Frontmatter (name + description), 21 keywords, Quick Rule Index (6 sections), Context Detection table, Decision Entry Point (Q1-Q3), Anti-Skip Table (4 entries), Step 0 Prerequisites |
| FR2: tool-landscape.md | PASS | Tier A: 9 tools with benchmark columns + N/R. Tier B: 4 tools with Key Strength. 4 selection rules (language, hardware, use case, license) |
| FR3: apple-silicon.md | PASS | 16GB table (6 tools with VRAM), 32GB section, MPS configs (4 tools), MLX-Audio native, Decision Tree |
| FR4: voice-cloning.md | PASS (with P0-1 caveat) | 3 methods, duration table (7 tools), quality MUST/MUST NOT rules, threshold guide, 6 failure modes, cloning workflow, boundary rule to audiobook-pipeline.md |
| FR5: audiobook-pipeline.md | PASS | 4 non-negotiables, chunking strategy + code, consistency management (3 methods), multi-character YAML registry, 5-step pipeline, ACX specs, FFmpeg commands (4 variants), QC script, throughput table, file org template. 266 lines (exceeds 120 minimum) |
| FR6: narration-dubbing.md | PASS | Blog workflow, video dubbing (with interface contract ref), 3 mixed-language options, short vs medium table, podcast specs (4 platforms), integration points |
| FR7: licensing-safety.md | PASS | GREEN (11 tools), YELLOW (1), RED (2). Watermarking section, sabotage patterns (2 tools), decision rule flowchart, 5 anti-patterns |

## AC Verification

| AC | Expected | Actual | Status |
|---|---|---|---|
| AC1 | 2 (name + description in frontmatter) | Lines 2-3: `name: ai-voice-production`, `description: "AI voice production..."` | PASS |
| AC2 | 6 reference files | 6 .md files in references/ | PASS |
| AC3 | >=6 `references/` in SKILL.md | 13 occurrences | PASS |
| AC4 | >=1 N/R in tool-landscape.md | N/R used extensively in Tier A table | PASS |
| AC5 | >=5 GB mentions in apple-silicon.md | 6 tools with VRAM data (~8GB, 6-8GB, ~6GB, Minimal, <4GB, Native) | PASS |
| AC6 | >=120 lines in audiobook-pipeline.md | 266 lines | PASS |
| AC7 | >=1 video-creation in narration-dubbing.md | 3 occurrences | PASS |
| AC8 | 3 distinct tiers in licensing-safety.md | GREEN, YELLOW, RED all present | PASS |
| AC9 | >=3 Source citations in audiobook-pipeline.md | 6 citations | PASS |
| AC10 | Pack activation | Requires runtime verification | DEFERRED |

---

## Verdict

**FAIL** (P0=3, P1=4)

**P0 fixes required** (blocking):
1. **P0-1**: Remove or re-label the 3 non-researched entries in voice-cloning.md Reference Duration Table, and fix the citation to accurately reflect coverage
2. **P0-2**: Remove "Finite Scalar Quantization" label from audiobook-pipeline.md (keep "tokenizer-free architecture" which IS in research)
3. **P0-3**: Add NeuTTS Air (3s) and VibeVoice (5s) to voice-cloning.md Reference Duration Table, or document exclusion rationale

**P1 fixes recommended** (should fix before shipping):
1. **P1-1**: Standardize Chatterbox naming and params across all 6 files
2. **P1-2**: Mark quality threshold tier boundaries in voice-cloning.md as derived interpretations with dual citation
3. **P1-3**: Remove "~10-20% slower" specific percentage from apple-silicon.md MPS fallback comment
4. **P1-4**: Remove "2-3x effort" uncited multiplier from SKILL.md Anti-Skip Table

**Recommended fix order**: P0-1 + P0-3 together (voice-cloning.md duration table) > P0-2 (one line in audiobook-pipeline.md) > P1-1 (touches most files) > P1-2 through P1-4 (single-line fixes each).
