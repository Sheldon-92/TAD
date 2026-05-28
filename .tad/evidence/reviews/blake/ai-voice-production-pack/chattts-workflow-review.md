# Code Review: chattts-workflow.md

**Reviewer**: code-reviewer
**Date**: 2026-05-28
**Artifact**: `.claude/skills/ai-voice-production/references/chattts-workflow.md` (344 lines)
**Scope**: Single reference file added to accepted pack after dogfood testing
**Companion check**: SKILL.md routing table + Quick Rule Index integration

---

## Summary

The file documents an end-to-end ChatTTS workflow for Chinese narration, grounded in a dogfood test (Barney Frank article, Mac Apple Silicon, 2026-05-28). It covers environment setup, voice identity persistence, emotion control via oral/laugh/break parameters, single-speaker and dual-speaker generation, post-processing with FFmpeg, and troubleshooting. The writing quality is high: clear section progression, actionable code examples, and a pragmatic tone.

SKILL.md integration is correctly done: Context Detection table (line 38), Quick Rule Index (lines 95-99), and the new keyword cluster covers the right signal space.

---

## P0 Findings (Must Fix)

### P0-1: SKILL.md Step 2 Decision Entry Point does not route to chattts-workflow.md

**Location**: SKILL.md lines 47-52 (Step 2: Decision Entry Point Q1)

The Context Detection table (Step 1) correctly includes ChatTTS routing. The Quick Rule Index (Step 3+) correctly summarizes the file. But Step 2 -- the Decision Entry Point that agents follow for structured question-driven routing -- has NO path to `chattts-workflow.md`. The five Q1 options all route to `audiobook-pipeline.md`, `narration-dubbing.md`, or `tool-landscape.md`.

An agent following Step 2 (e.g., user says "I want to generate Chinese podcast audio with emotion control") would be routed to `narration-dubbing.md`, which recommends Kokoro/Fish S2 Pro/VoxCPM2 -- never surfacing ChatTTS as an option.

**Fix**: Add a Q1 entry such as:
```
- Chinese narration with emotion control (oral/laugh/break, dialogue) → load `chattts-workflow.md`
```
Or add a sub-bullet under existing entries pointing to ChatTTS when Chinese + emotion control is detected.

**Severity justification**: Without this, the primary agent navigation path (Step 2) silently bypasses the new file. Step 1 keyword matching may catch it, but Step 2 is the structured decision tree that agents rely on when the signal is ambiguous.

### P0-2: `.pt` file portability claim is misleading -- version coupling not documented

**Location**: chattts-workflow.md line 331

> ".pt 文件是模型无关的 PyTorch tensor。只要使用相同版本的 ChatTTS，在任何机器上加载都是同一个声音。"

The first sentence claims the file is "model-agnostic" (模型无关). The second sentence immediately constrains to "same version of ChatTTS." These two claims contradict each other. A `.pt` file contains a speaker embedding tensor whose dimensionality and semantics are defined by the ChatTTS model architecture. If ChatTTS changes its embedding dimension (e.g., from 768 to 1024 in a major version bump), old `.pt` files will fail to load or produce garbage output.

**Fix**: Remove "模型无关的" and state the actual constraint clearly:
```
`.pt` 文件是 PyTorch tensor，与特定 ChatTTS 版本的模型架构绑定。
只要使用相同版本的 ChatTTS，在任何机器上加载都是同一个声音。
升级 ChatTTS 版本时，需要验证已保存的 .pt 文件是否仍兼容。
```

**Severity justification**: A user who reads "model-agnostic" and upgrades ChatTTS will lose voice consistency with no warning. This is a silent data corruption risk for the voice asset pipeline.

---

## P1 Findings (Should Fix)

### P1-1: No cross-reference to licensing-safety.md despite ChatTTS being RED tier

**Location**: chattts-workflow.md lines 8-18 (何时选 ChatTTS table)

The table mentions "CC BY-NC 4.0，商用需其他工具" in the "不适合" column for commercial use. But unlike other reference files (e.g., voice-cloning.md line 49 referencing "see licensing-safety.md"), there is no explicit cross-reference to `references/licensing-safety.md`. The pack's own Anti-Skip Table (SKILL.md line 113) says: "MUST check license tier in licensing-safety.md -- open weights != commercial use."

A user who reads only chattts-workflow.md gets a brief mention of CC BY-NC 4.0 but not the full context (watermarking traps, quality sabotage patterns, decision rule).

**Fix**: Add `(see licensing-safety.md §RED)` after the commercial use row, or add a standalone callout:
```
> **License**: ChatTTS uses CC BY-NC 4.0 (RED tier). See `licensing-safety.md` for
> full commercial restrictions and quality sabotage patterns.
```

### P1-2: ChatTTS not listed in apple-silicon.md 16GB Memory Budget table

**Location**: apple-silicon.md (entire file)

The dogfood test ran on Mac Apple Silicon 16GB. The performance table in chattts-workflow.md (lines 207-214) provides Apple Silicon timings. But `apple-silicon.md` -- the hardware-specific reference -- has no entry for ChatTTS in its 16GB Memory Budget table. This creates an information gap: a user following the hardware-first path (Step 2 Q2: "Apple Silicon Mac -> load apple-silicon.md") will not see ChatTTS as a viable option.

**Fix**: Add a ChatTTS row to apple-silicon.md's 16GB Memory Budget table:
```
| ChatTTS | ~300M | ~4-6GB (est.) | Yes (fallback) | `PYTORCH_ENABLE_MPS_FALLBACK=1` |
```
Note: exact VRAM was not measured in dogfood. If unmeasured, add with "N/R" per the pack's convention ("do not guess") and a note that it ran successfully on 16GB during dogfood.

### P1-3: Performance table lacks reproducibility metadata

**Location**: chattts-workflow.md lines 207-214

The source citation says "实测数据 2026-05-28, Mac Apple Silicon" but does not specify:
- Which Apple Silicon chip (M1/M2/M3/M4, base/pro/max)
- RAM (16GB assumed from context but not stated)
- ChatTTS version
- Whether MPS was active or fell back to CPU

Other reference files cite NotebookLM research reports with section references. This performance table cites "实测数据" without enough detail to reproduce or compare.

**Fix**: Expand the source line:
```
> Source: 实测数据 2026-05-28, Mac Apple Silicon M? 16GB, ChatTTS v?.?.?,
> MPS fallback mode, 逐段生成
```

### P1-4: Language inconsistency with other reference files

**Location**: Entire file

All 7 existing reference files are written in English (titles, section headings, body text, comments in code). The new file is written entirely in Chinese (title, headings, body text). While the pack serves a bilingual user base and Chinese is appropriate for a Chinese-focused TTS tool, the inconsistency means:

1. An agent loading multiple references simultaneously sees mixed-language section headings in the Quick Rule Index (SKILL.md lines 95-99 already shows this: English headings for 6 files, Chinese headings for ChatTTS).
2. Keyword-based navigation within the file uses Chinese headings, while all other files use English.

**Recommendation**: This is a judgment call for the pack owner. Two options:
- (a) Keep Chinese -- the content IS about Chinese TTS, and the user's workflow was in Chinese. Accept the inconsistency.
- (b) Use English headings with Chinese body text -- matches the pattern of other files while preserving Chinese explanations.

No strong P0 case either way. Flagging for conscious decision.

---

## P2 Findings (Consider)

### P2-1: Dual-speaker workflow uses same manual_seed(42) for both speakers

**Location**: chattts-workflow.md lines 291-293

In the dual-speaker generation loop, `torch.manual_seed(42)` is called before every turn regardless of speaker. The comment in the single-speaker section (line 173) says "每段重置种子 -- 确保声音特征一致." For dual speakers, using the same seed for both might be intentional (to keep the "recording environment" consistent as explained in line 309), but it could also mask a subtle issue: if the seed influences more than just environmental characteristics, both speakers might have correlated prosody patterns.

**Recommendation**: Add a brief comment in the dual-speaker section explaining why seed 42 is used for both (as opposed to seed 42 for host, seed 99 for guest matching their creation seeds).

### P2-2: `torch.load` without `map_location` parameter

**Location**: chattts-workflow.md line 164

```python
spk = torch.load("voices/narrator.pt", weights_only=True)
```

If the `.pt` file was saved on a CUDA machine and loaded on an MPS machine (or vice versa), `torch.load` without `map_location` may fail or place the tensor on the wrong device. Since this workflow targets Apple Silicon specifically, adding `map_location="cpu"` would make cross-device portability explicit:

```python
spk = torch.load("voices/narrator.pt", weights_only=True, map_location="cpu")
```

### P2-3: Missing `soundfile` import in audition script

**Location**: chattts-workflow.md line 81

The audition script calls `sf.write()` but does not include `import soundfile as sf`. The earlier setup section (line 27) lists `soundfile` as a pip dependency, and the full generation script (line 158) includes the import. But the audition snippet is self-contained enough that a user might copy-paste it alone.

**Fix**: Add `import soundfile as sf` at the top of the audition snippet.

### P2-4: No mention of `[uv_break]` effectiveness or limitations

**Location**: chattts-workflow.md lines 100-106

The text preparation section introduces `[uv_break]` for pause control. But:
- Is this a ChatTTS-native token or a convention? The `[oral_N]`/`[laugh_N]`/`[break_N]` tokens are in RefineTextParams.prompt, while `[uv_break]` appears inline in the text itself. These are different injection points.
- Were other inline tokens tested during dogfood (e.g., `[lbreak]`, `[speed_N]`)?

**Recommendation**: Add a brief note clarifying that `[uv_break]` is an inline text token (distinct from RefineTextParams prompt tokens) and whether it was validated during the dogfood test.

---

## Anti-Slop Assessment

**Score: 4/5**

Strengths:
- Performance table (lines 207-214) contains specific generation times that would not come from training data alone (e.g., "~150 chars -> ~30s -> ~25-30s audio" on Apple Silicon)
- The emotion preset system with concrete parameter values for specific scenarios (narration vs reflective vs dramatic) shows tested combinations
- The `manual_seed` reset-per-paragraph pattern for voice consistency is a practical finding, not generic knowledge
- Troubleshooting table covers real errors (`found invalid characters`, `ModuleNotFoundError: ordered_set`, MPS float64)

Weakness:
- The oral/laugh/break parameter ranges (0-9) and their qualitative effects (P1-3 above) could be generic documentation knowledge rather than tested assertions. Were all 10 levels of each parameter tested, or are the descriptive labels ("正式、播报感" vs "随意、口语化") interpolated?

---

## Cross-Reference Consistency

| Check | Status | Detail |
|---|---|---|
| SKILL.md Context Detection table | PASS | Line 38, correct keywords + file path |
| SKILL.md Quick Rule Index | PASS | Lines 95-99, three sub-entries |
| SKILL.md Step 2 Decision Entry Point | FAIL | No ChatTTS routing path (see P0-1) |
| SKILL.md Anti-Skip Table | PASS | No ChatTTS-specific skip needed |
| tool-landscape.md Tier B table | CONSISTENT | ChatTTS listed as RED, CC BY-NC 4.0 |
| licensing-safety.md RED tier | CONSISTENT | ChatTTS listed, anti-commercial noted |
| voice-cloning.md failure modes | CONSISTENT | Word omission for ChatTTS/Bark noted |
| apple-silicon.md | MISSING | No ChatTTS entry (see P1-2) |

---

## Verdict

**CONDITIONAL PASS** -- fix P0-1 and P0-2 before merge.

- P0-1 (SKILL.md Step 2 routing gap) is a functional bypass that makes the new file unreachable via the primary decision path.
- P0-2 (misleading portability claim) is a silent data risk for users who upgrade ChatTTS.

Both are small, localized fixes (1-3 lines each). The file itself is well-structured, grounded in real dogfood experience, and follows the pack's reference pattern closely. After P0 fixes, recommend also addressing P1-1 (licensing cross-ref) and P1-3 (performance metadata) as they affect the pack's internal consistency standards.
