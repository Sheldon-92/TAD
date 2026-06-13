# Phase 4 Adversarial Review — ai-voice-production (correctness lens)

- **Lens**: correctness (internal consistency, actionability, factual/technical accuracy of guidance vs the QUALITY-BAR dual-layer rubric)
- **Reviewer**: adversarial subagent (default-skeptic)
- **Date**: 2026-06-13
- **meets_bar**: true (clears Layer A 10/10 + Layer B bucket-4 depth) — but with material correctness defects that should be fixed; the headline defect is a false validation-completeness claim, exactly the "validation theater" risk the bar itself flags.

---

## Verdict reasoning

The bar is dual-layer: **Layer A** (structure, pass ≥7/10) and **Layer B** (domain depth, must be clearly > the ≤2 negative-control floor). On the bar's own measured axes the pack clears both:

- **Layer A = 10/10**: A1 frontmatter (name + third-person what+when description) ✓, A2 progressive disclosure (7 references) ✓, A3 body 125 lines (< 550) ✓, A4 Step 0-3 + signal→reference routing table ✓, A5 CONSUMES/PRODUCES ✓, A6 Anti-Skip table ✓, A7 Quick Rule Index ✓, A8 fixture present ✓, A9 `discriminative_pattern` + `min_discriminative` wired ✓, A10 two executable scripts ✓.
- **Layer B = bucket 4 (specN=54)**: recomputed specN over SKILL + references with the bar's DISC alternation under `LC_ALL=en_US.UTF-8` AND a null-delimited `find -print0 | xargs -0` (the path `/Users/.../01-on progress programs/TAD` contains spaces, which silently zeroed the naive `xargs`). 54 unique specific-threshold tokens → bucket 40-59 → Layer B 4/5. Content is operationalized (ACX 8-spec, MPS float32 mandate, IndexTTS2 emo_alpha sweep band, per-tool reference-duration table, per-platform LUFS table) — well above the shallow ≤2 floor.

So `meets_bar=true`. But the correctness lens surfaced real defects below. None individually drops Layer A below 7 or Layer B to ≤2, so the pack stays above the bar, but the F1 script-overclaim is the kind of defect the bar explicitly worries about and should block a strict "accepted".

---

## Findings (correctness defects, ranked)

### F1 (P0 — false validation-completeness claim / validation theater)
`scripts/acx-check.sh` asserts only **5 of the 8 ACX hard specs**, yet SKILL.md L80 says it "asserts all 8 ACX hard specs", L95 lists "MP3 192kbps … head/tail silence … validate with scripts/acx-check.sh", and the script's own header comment says it "asserts the full 8-spec set, not a subset." **Unchecked specs: #1 format (MP3 192 kbps CBR / codec), #7 head silence (0.5-1.0 s), #8 tail silence (1.0-5.0 s).** Empirically proven: a 320 kbps MP3 (violates spec #1) passes the format/bitrate/silence dimensions with zero scrutiny — the script never reads bit_rate, codec, or leading/trailing silence. Highest-severity defect: a *false completeness claim on the deterministic gate* — the exact "structural check proves files exist, not that they're correct" / validation-theater pattern QUALITY-BAR §4 + principles 2026-05-15 call out. Fix: implement codec/bitrate (`ffprobe` bit_rate+codec_name) + head/tail silence (`silencedetect`) checks, OR downgrade every "all 8" claim to "5 of 8 machine-checkable specs (format/silence verified manually)".

### F2 (P1 — internal method inconsistency, scale-relevant)
`audiobook-pipeline.md` §FFmpeg Mastering states "**Single-pass loudnorm is a one-shot estimate and drifts**" and presents two-pass as "the right way," but the **`Batch process all chapters`** command (L214-220) — the one a user actually runs across a whole book — uses the single-pass `loudnorm=I=-20:TP=-3:LRA=7` the file just warned against, and no two-pass batch variant is provided. The deterministic method is shown once, for a single file only. The documented at-scale path contradicts the documented quality rule. Fix: provide a two-pass batch loop, or annotate the batch command as "quick/non-deterministic; for ship-quality use two-pass per chapter."

### F3 (P2 — dangling cross-reference)
`narration-dubbing.md` L42 cites "Per §3.1 Interface Contract in SKILL.md", but SKILL.md has no §3.1 — the interface contract lives in the unnumbered top blockquote (the file uses Step 0-3 + `###` rule-index headings, no `§3.x` numbering). Broken pointer; a reader cannot locate "§3.1". Fix: reference "the INTERFACE blockquote at the top of SKILL.md" or add the section number.

### F4 (P2 — terminology conflation: "TP"/"true peak" vs sample peak)
`acx-check.sh` measures `volumedetect` `max_volume` (sample peak) and the SKILL index L80 labels it "TP < -3"; meanwhile `lufs-check.sh` correctly uses loudnorm `input_tp` (genuine true-peak dBTP) and the index L81 also calls it "true peak". ACX's spec is in fact a sample-peak requirement (-3 dB peak), so acx-check's *measurement* is defensible, but labeling both "TP/true peak" — one sample-peak dBFS, one dBTP — conflates two distinct quantities. A user could wrongly assume acx-check enforces -3 dBTP. Fix: label the acx-check value "peak (sample, dBFS)" and reserve "true peak/dBTP" for lufs-check.

### F5 (P3 — terminology: Apple Silicon "VRAM")
SKILL Step 0 ("VRAM-dependent") and `apple-silicon.md` repeatedly say "VRAM" for Apple Silicon, which has **unified memory**, not discrete VRAM. The numbers work as a memory-budget proxy and the file is clearly Mac-scoped, so cosmetic, but strictly inaccurate for the platform the file is about. Fix: say "unified-memory footprint" on the Apple Silicon path.

---

## What is correct (verified, not assumed)

- `lufs-check.sh` true-peak claim is accurate: parses loudnorm `input_tp` (real dBTP estimate) + `input_i` (integrated LUFS); platform bands (apple -16 / apple-mono -19 / spotify -14 / youtube -14 / ebu -23) match the cited source and the narration-dubbing table — consistent cross-file.
- Bitrate consistent: ACX path uses `-b:a 192k` everywhere (192k via libmp3lame = CBR); podcast path 128k — matches the podcast-vs-audiobook table. No drift. (Gap: acx-check never *verifies* the 192k landed — see F1.)
- Both scripts run cleanly under `set -euo pipefail` on ffmpeg 8.0; exit codes drive the gate (0/1/2) as documented; awk float-compare avoids a `bc` dependency.
- Fixture `discriminative_pattern` is genuinely pack-specific (emo_alpha, 150ms, .pt seed-reset, MPS/float32, ACX/LUFS numbers); correctly excludes generic "TTS"/"audiobook" — anti-slop discipline holds.
- ChatTTS reference grounded in dated real-world testing (2026-05-28), uses isolated `uv venv`, `weights_only=True` on torch.load (safe-load), per-paragraph `manual_seed` reset for consistency — internally consistent and actionable.
- IndexTTS2 / CosyVoice2 claims carry source URLs + retrieval dates; "duration control NOT yet enabled" caveat propagated consistently across SKILL Anti-Skip, tool-landscape, and voice-cloning — a correct, well-propagated negative claim (avoids promising a failing API).

---

## fact_checks

- specN recomputed = **54** (bucket 4) using bar's DISC + `LC_ALL=en_US.UTF-8` + null-delimited find/xargs; the naive piped command in QUALITY-BAR §2.3 returns 0 here purely because of the space in the repo path (word-splitting), independent of the documented locale bug — both must be handled.
- acx-check.sh checks exactly **5** dimensions (RMS, sample peak, noise floor, sample rate, mono); `grep -c fail=1` = 5; no codec/bitrate/silence assertions. EMPIRICALLY CONFIRMED a 320kbps MP3 passes those dimensions untouched. The "all 8 specs" claim in SKILL L80/L95 + script header is FALSE.
- lufs-check.sh "true peak via input_tp" claim CONFIRMED accurate against loudnorm JSON semantics.
- "§3.1 Interface Contract in SKILL.md" referenced by narration-dubbing.md L42 does NOT exist in SKILL.md (no numbered §3.x sections). CONFIRMED dangling reference.
- audiobook-pipeline batch command uses single-pass loudnorm despite the same file declaring single-pass "drifts" / two-pass "the right way". CONFIRMED internal inconsistency.
- ffmpeg available (8.0, /opt/homebrew/bin/ffmpeg); both scripts executable (mode 755) and run without syntax error.

## FIX applied (validated)

Validated 2026-06-13 against current primary docs (help.acx.com, github.com/2noise/ChatTTS, github.com/index-tts/index-tts, huggingface.co/ResembleAI/chatterbox, resemble-ai/chatterbox). Scripts re-tested under `set -euo pipefail` on ffmpeg 8.0 with built discriminative fixtures; shellcheck clean.

**correctness lens**
- F1 (P0 validation theater) — **FIXED**. `acx-check.sh` now asserts all 8 ACX specs, not 5. Added: spec #1 format/codec+bitrate (parsed from the `Stream … Audio:` line — scoped away from the container `Duration: … bitrate:` header to avoid a 194-vs-192 false-FAIL, a bug self-caught during fixture testing), spec #7 head room-tone duration (silencedetect, 0.5-1.0s), spec #8 tail room-tone duration (1.0-5.0s, must end at EOF). EMPIRICAL re-test: a 320 kbps MP3 now FAILs on format (`mp3 320 kb/s ≠ 192`) — previously passed untouched. Clean 192k mono PASSes format; no-silence file FAILs head/tail without crashing. SKILL.md L80/L95 + audiobook-pipeline §ACX block + script header rewritten to describe the actual (now-complete) scope, including the one residual MANUAL check (room-tone vs digital-zero — script measures duration only).
- F2 (P1 internal inconsistency) — **FIXED**. audiobook-pipeline.md "Batch process all chapters" converted from single-pass `loudnorm=I=-20:TP=-3:LRA=7` to a per-chapter TWO-PASS loop (measure → feed measured_I/TP/LRA/thresh/offset back, linear=true), matching the file's own "two-pass is the right way" rule. Added trailing `acx-check.sh final/ch-*.mp3` batch gate.
- F3 (P2 dangling reference) — **FIXED**. narration-dubbing.md L42 "Per §3.1 Interface Contract in SKILL.md" → "Per the INTERFACE contract in the SKILL.md top blockquote" (SKILL.md has no numbered §; it uses the top INTERFACE blockquote + Step 0-3).
- F4 (P2 terminology conflation) — **FIXED**. SKILL index + audiobook-pipeline spec #5 relabel acx-check's metric as "sample peak (dBFS)", explicitly "NOT dBTP", and point genuine dBTP at lufs-check.sh `input_tp`. acx-check.sh renamed `TP_MAX`→`PEAK_MAX` with a comment that ACX's "-3 dB peak" is sample peak. NOTE: ACX's spec is genuinely a sample-peak figure, so the script was numerically correct all along — only the "TP/true peak" *label* was wrong; fixed the label.
- F5 (P3 terminology VRAM) — **FIXED**. SKILL Step 0 + apple-silicon.md header/table relabeled "VRAM"→"unified memory" with an explicit "Apple Silicon uses unified memory, not discrete VRAM" note. Kept "VRAM" only as a routing *keyword* in the Step 1 trigger table (users still type it) and in the cross-platform tool-landscape memory column (which also covers NVIDIA).

**fact-api lens**
- F1 (HIGH ACX channels) — **FIXED**. VERIFIED via help.acx.com search: ACX allows "all mono OR all stereo" (mixed rejected). `acx-check.sh` no longer hard-FAILs non-mono; it accepts mono or stereo per-file and FAILs only on MIXED layout across the batch (validated: mono+stereo batch → channels FAIL on 2nd file). Prose in audiobook-pipeline spec #3 + SKILL index corrected ("all-mono OR all-stereo; mixed auto-rejected").
- F2 (MEDIUM ACX head silence) — **SKIPPED — FALSE POSITIVE**. The reviewer claimed pack head-silence "0.5-1.0s" is wrong vs ACX "1-5s both ends". VERIFIED via help.acx.com: ACX actually specifies **0.5-1.0s of room tone at the HEAD and 1-5s at the TAIL** — which is EXACTLY what the pack's spec #7 (head 0.5-1.0s) and #8 (tail 1.0-5.0s) already say. The reviewer conflated the two ends. (Same false positive appears in the anti-slop reviewer's "F2"; also skipped.) No change to the numbers; only added the "room tone, not digital zero" qualifier (an ACX requirement the pack had omitted).
- F3 (MEDIUM ChatTTS token ranges) — **FIXED**. VERIFIED via 2noise/ChatTTS README: `laugh_(0-2)`, `break_(0-7)`, `oral_(0-9)`. chattts-workflow.md parameter table corrected (laugh 0-9→0-2, break 0-9→0-7), "搞笑 5+" prose corrected to "搞笑 2（上限）", and an explicit official-range warning note added (with negative examples `[laugh_5]`/`[break_9]` flagged as out-of-range). All shipped PRESETS already within the corrected ranges (verified by grep).
- F4 (MEDIUM Chatterbox watermark) — **FIXED**. VERIFIED via huggingface.co/ResembleAI/chatterbox + resemble-ai/chatterbox: Perth `PerthImplicitWatermarker` on EVERY file by default, ~100% detection, survives MP3. Added a full Chatterbox entry to licensing-safety.md §Watermarking, a caveat to its GREEN License-Tiers row, a ⚠️ note in tool-landscape.md, and an explicit "GREEN means commercial-OK, NOT watermark-free" rule.
- F5 (LOW Chatterbox param count) — **FIXED**. VERIFIED vendor figure = "0.5B Llama backbone". tool-landscape.md (was 350M) and apple-silicon.md (was 350M-1.2B) both corrected to "0.5B (Llama backbone)".
- F6 (LOW/MEDIUM IndexTTS2 emo_alpha) — **FIXED**. VERIFIED via index-tts/index-tts README: range 0.0-1.0, default 1.0. voice-cloning.md sweep band changed `0/0.6/1.0/1.4` → `0/0.6/0.9/1.0`, removed the fabricated "1.4 = over-driven" claim, added documented-range note + "do NOT exceed 1.0" warning.

**anti-slop lens**
- F1 (emo_alpha 1.4 unsourced) — **FIXED** (same change as fact-api F6).
- F2 (ACX head-silence over-specified) — **SKIPPED — FALSE POSITIVE** (same as fact-api F2; ACX text genuinely specifies 0.5-1.0s at head).
- F4 (VoxCPM2 provenance gap, advisory) — **NOT FIXED (out of scope)**: this asks to add a primary URL for VoxCPM2 cross-lingual claims currently citing only internal baseline-report.md. Not a correctness defect (no claim shown to be wrong) and no primary URL was supplied/verifiable this pass; left as-is per the "don't invent sources" rule. Flagged for a future research pass.
