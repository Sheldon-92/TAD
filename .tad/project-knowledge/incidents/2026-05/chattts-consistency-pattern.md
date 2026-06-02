# ChatTTS Consistency Pattern: Seed Reset + Saved Embedding > Batch Mode

**Date:** 2026-05-28
**Linked to:** L2 research-methodology "Source Import Quality: False Success Patterns"

---

### ChatTTS Consistency Pattern: Seed Reset + Saved Embedding > Batch Mode - 2026-05-28
- **Context**: Dogfood test of ai-voice-production pack. Chinese narration of Barney Frank article. ChatTTS batch mode (12 paragraphs as list to single `infer()`) ran 25+ minutes on Mac 16GB without completing. Sequential per-paragraph mode with varying `spk_emb` state produced inconsistent voice and background noise across segments.
- **Discovery**: (1) **Batch mode is impractical on 16GB Mac** — memory and compute scale with paragraph count, 12 paragraphs exceeded reasonable wall-clock time (25+ min CPU, 18.7% RAM). (2) **Sequential + fixed seed is the correct pattern** — `torch.manual_seed(42)` before EACH `infer()` call + same `spk_emb` tensor = consistent voice characteristics across independently generated segments. Without per-paragraph seed reset, the random state drifts and voice timbre shifts. (3) **Speaker embedding persistence** — `torch.save(spk_emb, "narrator.pt")` (~4KB) enables cross-session, cross-project voice identity. This is the long-term consistency primitive. (4) **Undocumented Chinese dependencies** — ChatTTS requires ordered-set, pypinyin, cn2an, jieba for Chinese but does not declare them in its pip dependencies. Each missing dep surfaces as a separate `ModuleNotFoundError` at import time.
- **Action**: For any TTS tool generating long-form audio segment-by-segment: (a) Reset random seed before each segment for voice consistency. (b) Persist speaker embedding to disk for cross-session reuse. (c) Use sequential generation, not batch, on memory-constrained hardware. (d) Test Chinese/CJK dependencies explicitly during pack dogfood — pip metadata is unreliable for CJK support.
- **Grounded in**: .claude/skills/ai-voice-production/references/chattts-workflow.md, dogfood artifacts /tmp/barney-frank-chattts-*.mp3
