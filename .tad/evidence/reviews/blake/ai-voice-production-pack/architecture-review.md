# Architecture Review: ai-voice-production Capability Pack

**Reviewer**: backend-architect
**Date**: 2026-05-28
**Files reviewed**: SKILL.md + 6 reference files (7 total)
**Pattern reference**: video-creation SKILL.md (reference-based pack)

---

## Summary

The ai-voice-production pack is a well-structured reference-based capability pack covering TTS tool selection, voice cloning, audiobook/podcast/dubbing pipelines, Apple Silicon optimization, and licensing safety. The pack contains 846 total lines across 7 files, with strong research-grounded thresholds and clear file boundary ownership. The cross-pack interface with video-creation is explicitly defined with ownership and collision rules.

Overall quality is high. The architecture follows the established reference-based pattern with minor structural deviations that warrant attention. No blocking issues found.

---

## P0 Findings (Blocking)

**None.**

---

## P1 Findings (Should Fix)

### P1-1: Step Numbering Deviation from Reference Pattern

**Location**: SKILL.md lines 44-65
**Issue**: The ai-voice-production SKILL.md introduces an extra step not present in the reference pattern:

- video-creation: Step 0 (Prerequisites) -> Step 1 (Context Detection) -> Step 2 (Apply Rules) -> Quick Rule Index -> Anti-Skip Table
- ai-voice-production: Step 0 (Prerequisites) -> Step 1 (Context Detection) -> **Step 2 (Decision Entry Point)** -> **Step 3 (Apply Rules)** -> Quick Rule Index -> Anti-Skip Table

The "Decision Entry Point" (Q1/Q2/Q3) is a useful addition that routes users through use case, hardware, and commercial intent before loading references. However, it breaks the structural symmetry with video-creation. An agent loading both packs would see different step numbering for equivalent functions.

**Recommendation**: Either (a) fold Decision Entry Point into Step 1 as "Step 1b: Decision Entry Point" with Context Detection becoming "Step 1a", or (b) rename Step 2 in video-creation's "Apply Rules" to Step 3 in a future update to align both packs. Option (a) is the lower-risk change. The Decision Entry Point content itself is valuable and should be kept.

### P1-2: Unidirectional Cross-Pack Interface

**Location**: SKILL.md line 14, narration-dubbing.md lines 39-43
**Issue**: The INTERFACE declaration in ai-voice-production clearly states: "video-creation pack defers to this pack for voice/TTS tool selection." However, the video-creation SKILL.md contains zero references to ai-voice-production (grep confirms only `name: video-creation` matches). This means the interface contract is declared unilaterally.

When both packs load simultaneously, an agent reading video-creation's SKILL.md has no signal that it should defer TTS decisions to another pack. The collision rule only works if the agent happens to also load ai-voice-production.

**Recommendation**: This is not Blake's responsibility to fix (video-creation is a separate pack), but the handoff should note a follow-up task: add a single line to video-creation SKILL.md's header or ai-asset-generation.md TTS section: `> For TTS tool selection judgment, defer to ai-voice-production pack if loaded.` Without this reciprocal pointer, the collision rule is unenforceable.

### P1-3: XTTS-v2 in licensing-safety.md Without Presence in tool-landscape.md

**Location**: licensing-safety.md line 41
**Issue**: XTTS-v2 appears in the RED license tier as a "non-commercial license trap" but does not appear anywhere in tool-landscape.md (neither Tier A nor Tier B). A user reading tool-landscape.md would never encounter XTTS-v2, then discover it is RED-listed only if they separately check licensing-safety.md. Conversely, XTTS-v2 being RED-listed without tool-landscape context means users cannot compare it against alternatives.

**Recommendation**: Either (a) add XTTS-v2 to Tier B in tool-landscape.md with a note `License: RED (non-commercial) -- see licensing-safety.md` and Key Strength "Historical: widely deployed but non-commercial trap", or (b) add a note in licensing-safety.md RED section: "XTTS-v2 is intentionally excluded from tool-landscape.md because it is not recommended for any use case. Listed here only as a common trap." Option (b) is lighter and preserves the current tool-landscape.md scope.

### P1-4: narration-dubbing.md Has Lowest Source Citation Density

**Location**: narration-dubbing.md (1 citation in 157 lines)
**Issue**: narration-dubbing.md contains only 1 `> Source:` citation (line 84, for MeloTTS mixed-language). The file includes research-grounded content that per the handoff's two-category rule (section 8.1) should be Category A (requires citation):

- Blog narration tool recommendation order (Kokoro fastest, Fish S2 Pro best quality) -- appears to be research-grounded selection, not deterministic
- Video dubbing emotion-matching tool choices (Chatterbox for paralinguistic, VoxCPM2 for multilingual)
- Short vs Medium content threshold table (chunking at 100-150 chars, seed locking for medium)

Compare: tool-landscape.md has 3 citations in 71 lines, voice-cloning.md has 6 in 130 lines, audiobook-pipeline.md has 6 in 266 lines.

**Recommendation**: Add `> Source:` citations for the tool selection recommendations in Blog Narration and Video Dubbing sections. These derive from research findings, not domain knowledge. The short-vs-medium table's chunking threshold (100-150 chars) and seed locking recommendation are also research-grounded (same data as audiobook-pipeline.md) and should cite the same source.

---

## P2 Findings (Nice to Have)

### P2-1: Context Detection Table Missing Some Plausible User Signals

**Location**: SKILL.md lines 31-38
**Issue**: The Context Detection table covers the primary signals well, but a few plausible user queries would not match any row:

- "text to speech" or "convert text to audio" -- general TTS intent that does not clearly map to any specific reference. Would probably benefit from routing to tool-landscape.md.
- "quality", "improve audio", "mastering" -- audio post-processing queries that span audiobook-pipeline.md (ACX mastering) and narration-dubbing.md (podcast LUFS).
- "consistency", "voice drift", "same voice across chapters" -- these map to audiobook-pipeline.md consistency management but the signal words are not in the table.
- "emotion", "expressive", "paralinguistic" -- maps to voice-cloning.md failure modes and audiobook-pipeline.md emotion tagging, but not signaled.

**Recommendation**: Consider adding rows for "text to audio, convert to speech, TTS" -> tool-landscape.md and "voice drift, consistency, same voice" -> audiobook-pipeline.md. Keep the table concise but these are high-probability user signals.

### P2-2: Anti-Skip Table Row 5 Could Cover Podcast-Specific Skip

**Location**: SKILL.md lines 101-109
**Issue**: The 5 anti-skip entries are realistic and cover the most common shortcuts. One additional high-probability skip attempt is missing: "I'll just use the same settings for podcast and audiobook" -- which would skip the significant LUFS vs RMS difference (-16 LUFS for podcast vs -23 to -18 RMS for ACX), format differences (128kbps vs 192kbps), and normalization approach differences documented in narration-dubbing.md lines 143-149.

**Recommendation**: Consider adding a 6th row: `"Same audio specs work for podcast and audiobook" -> MUST check platform-specific targets in narration-dubbing.md -- podcast (-16 LUFS, 128kbps) and audiobook (-23 to -18 RMS, 192kbps) have incompatible specs.`

### P2-3: Scalability — New Tool Addition Path Not Documented

**Location**: Structural observation
**Issue**: The pack's file structure is clean and new tools can be added to tool-landscape.md's Tier A/B tables, apple-silicon.md's memory budget table, voice-cloning.md's duration table, and licensing-safety.md's tier tables independently. This is good separation.

However, there is no documented "how to add a new tool" checklist. When a new TTS tool emerges (e.g., a hypothetical CosyVoice2 release), Blake would need to update 4-5 files in a specific order:
1. tool-landscape.md (add to Tier A or B)
2. licensing-safety.md (classify license tier)
3. apple-silicon.md (if VRAM data available)
4. voice-cloning.md (if cloning supported, add to duration table)
5. Any pipeline files that reference the tool

**Recommendation**: A brief comment at the top of tool-landscape.md noting the cross-file update requirement would prevent partial additions. Something like: `When adding a new tool: update this file + licensing-safety.md (mandatory), then apple-silicon.md / voice-cloning.md / pipeline files as applicable.`

### P2-4: audiobook-pipeline.md chunk_text() Does Not Handle CJK Sentence Boundaries

**Location**: audiobook-pipeline.md lines 40-53
**Issue**: The `chunk_text()` implementation splits on `r'(?<=[.!?。！？])\s+'` which requires whitespace AFTER the sentence-ending punctuation. Chinese text typically has no space after sentence-ending punctuation. For example, the text `"Hello. World."` splits correctly, but `"你好。世界。"` does not split because there is no `\s+` after the ideographic period. This is relevant because the pack explicitly targets Chinese+English users.

**Recommendation**: Adjust the regex to: `r'(?<=[.!?。！？])\s*'` (zero-or-more whitespace) or split CJK punctuation separately. Since this is example code in a judgment-rule pack (not production code), a comment noting the CJK limitation would also suffice.

---

## Positive Observations

1. **File boundary clarity is excellent.** voice-cloning.md handles identity SETUP, audiobook-pipeline.md handles identity USE in production. The cross-reference header in voice-cloning.md ("For chapter-level USE of a cloned voice, see audiobook-pipeline.md") makes this explicit.

2. **Two-category traceability is properly implemented.** Research-grounded thresholds (WER 0.99%, SIM 89.0, RTF 0.13, VRAM ~8GB, chunk_size 120) all have `> Source:` citations. Deterministic constants (ffmpeg syntax, ACX specs, LUFS targets) are correctly exempt. The anti-slop value is clearly in the specific numbers.

3. **Tier A/B split in tool-landscape.md is architecturally sound.** Separating benchmarked tools from notable-but-unbenched tools prevents the N/R inflation problem where half the table cells would be empty, making the matrix unreadable. The "N/R = not researched, never invent benchmarks" note is a strong anti-hallucination guard.

4. **The Decision Entry Point (Q1/Q2/Q3) pattern is a genuine improvement** over video-creation's direct Step 1 -> Step 2 flow. It provides structured routing through three orthogonal dimensions (use case, hardware, commercial intent) before loading references. Worth considering for adoption in video-creation pack.

5. **Licensing-safety.md GREEN/YELLOW/RED classification is immediately actionable.** The decision tree format (CHECK tier -> VERIFY weights vs code license -> CHECK training data -> DOCUMENT) provides a concrete workflow, not just a list.

6. **apple-silicon.md decision tree and troubleshooting table** provide Mac-specific operational guidance that would be impossible to inline into other files without breaking their focus.

---

## Overall Verdict: PASS

The pack demonstrates strong architectural discipline: clean file boundaries, research-grounded thresholds with proper citation, a well-defined cross-pack interface contract, and an extensible structure. The P1 findings are real issues that should be addressed but none are blocking. The step numbering deviation (P1-1) is the most structurally significant and should be resolved before the pack pattern is replicated further. The unidirectional interface (P1-2) needs a follow-up task to close the loop in video-creation pack.
