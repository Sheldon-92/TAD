# Completion Report: AI Voice Production — ChatTTS Workflow Addition

**Handoff**: Post-acceptance enhancement (user-directed, no formal handoff)
**Origin**: Dogfood test of ai-voice-production pack (Barney Frank article → Chinese audio)
**Blake**: Implementation Complete
**Date**: 2026-05-28

---

## Context

After the ai-voice-production pack passed Gate 4 and was archived, user conducted a dogfood test:
1. English article → Kokoro TTS → success (6:17 MP3, -16.9 dB)
2. Chinese translation → Kokoro → heavy accent, unnatural rhythm
3. Chinese → Edge TTS (YunyangNeural) → too "播音腔", AI feel too strong
4. Chinese → ChatTTS → natural sound, but voice inconsistency across paragraphs
5. Chinese → ChatTTS (fixed seed + saved spk_emb) → consistent voice + natural feel

The iterative debugging surfaced a complete ChatTTS workflow that deserves capture as a reference file.

## What was Added

| # | File | Lines | Action |
|---|---|---|---|
| 1 | `.claude/skills/ai-voice-production/references/chattts-workflow.md` | 344 | CREATE |
| 2 | `.claude/skills/ai-voice-production/SKILL.md` | +6 | MODIFY (routing table + Quick Rule Index) |

## Content Summary

1. **When to choose ChatTTS** — scenario fit table (Chinese narration ✅, English ❌, commercial ❌)
2. **Environment setup** — dependency list including undocumented Chinese deps (ordered-set, pypinyin, cn2an, jieba)
3. **Voice persistence** — `.pt` file save/load for cross-session identity consistency
4. **Emotion parameter system** — oral/laugh/break 3-axis control + 6 scene presets + per-paragraph choreography
5. **`[uv_break]`** — inline pause marker for dramatic timing
6. **Dual-speaker dialogue** — two `.pt` files + shared seed for podcast/interview scenarios
7. **Post-processing** — blog (-16 LUFS) and ACX (-20 LUFS) ffmpeg commands
8. **Troubleshooting** — every error encountered during dogfood, with fixes

## Evidence

- Dogfood artifacts: `/tmp/barney-frank-*.mp3` (5 versions, iterative quality improvement)
- Commit: `f77de8a`
- Prior pack commits: `c119d1f` (original 7 files)

## Knowledge Assessment

**是否有新发现？** ✅ Yes

- ChatTTS 中文依赖（ordered-set, pypinyin, cn2an, jieba）不在 pip 自动依赖链中，必须手动安装
- `torch.manual_seed()` 每段前重置 + 保存的 `spk_emb` = 跨段落声音一致性的完整方案
- ChatTTS batch 模式（多段作为 list 传入）在 Mac 16GB 上极慢（25+ 分钟 CPU 未完成 12 段），逐段生成 + 固定种子是正确的方案
- Kokoro 82M 只有一个中文声音（zf_xiaobei），中文场景应优先考虑 ChatTTS 或 Edge TTS

## Deviations

- 这不是正式 handoff 产出，而是 dogfood 测试的自然延伸
- 未经 Layer 2 专家审查（用户直接指示写入 pack）
- Pack 从 7 个 reference 变为 8 个（但原始 AC2 只要求 6 个 reference，不受影响）
