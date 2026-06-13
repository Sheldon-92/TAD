# Phase 4 Review — ai-voice-production — Anti-Slop Lens

> Reviewer: subagent (anti-slop lens) | Date: 2026-06-13
> Target: `.claude/skills/ai-voice-production/` (SKILL.md + 7 references + 2 scripts + 1 fixture)
> Bar: `.tad/evidence/pack-quality/QUALITY-BAR.md` Layer B (depth) + anti-slop discriminability

## Lens

Anti-slop: are the Layer B "specifics" genuinely research-grounded (numbers/thresholds an LLM
could NOT emit from training), or generic rules dressed up? Flag vague/restatable rules
masquerading as depth. Flag unsourced numbers.

## meets_bar: TRUE

specN = **54** (UTF-8 locale, dedup) → Layer B bucket 4 (40-59 → 4/5). Comfortably clears the
≤2 negative-control band and the bucket-2 (15-24) shallow threshold. Reading-based review confirms
the count is NOT inflated by generic numerics: the bulk of specifics are pack-introduced thresholds
(ACX 8-spec set, per-tool reference-duration table, platform LUFS bands, emo_alpha, 150ms
first-packet, MPS float32). Four independent external fact-checks all PASSED. Genuinely
depth-bearing pack, not generic rules dressed up.

## Findings

### Genuinely research-grounded (clears the bar — LLM could NOT emit from training)

1. IndexTTS2 "duration control NOT yet enabled in release" caveat (SKILL L124, tool-landscape
   L13/L31, voice-cloning L61-63). The arXiv paper (2506.21619) is literally titled
   "...Duration-Controlled..." and the abstract describes token-count duration control as a
   feature — a training-data LLM would confidently say "IndexTTS2 supports duration control." The
   pack instead encodes the SHIPPED-RELEASE reality. VERIFIED against github.com/index-tts/index-tts:
   "This functionality is not yet enabled in this release." Strongest anti-slop signal in the pack
   — paper-vs-release disambiguation defeats the obvious hallucination.

2. CosyVoice2 metrics: 150ms first-packet latency, 30-50% pronunciation-error reduction vs
   CosyVoice1, MOS 5.4→5.53. ALL VERIFIED against funaudiollm.github.io/cosyvoice2/.

3. ACX 8 hard specs (audiobook-pipeline L152-166): RMS -23..-18 dBFS, peak <-3, noise floor <-60,
   44.1kHz, mono, 192kbps CBR. VERIFIED against help.acx.com — every number matches. Wired to an
   executable gate (acx-check.sh, exit-code-driven), not prose — the QUALITY-BAR's exact "exit code
   drives the gate" depth signal.

4. Platform LUFS bands (narration-dubbing L129-136): Apple -16 stereo / -19 mono, Spotify -14,
   YouTube -14, EBU -23, TP <=-1 dBTP. VERIFIED. The mono/stereo split (-16 vs -19) is a non-obvious
   specific an LLM would not reliably reproduce; backed by lufs-check.sh.

5. Fish S2 license (licensing-safety L34-45): Fish Audio Research License, commercial requires
   separate license even for self-hosted weights, business@fish.audio, Dual-AR 4B slow + 400M fast,
   10M+ hrs/80+ langs. ALL VERIFIED against HF fishaudio/s2-pro. Includes a documented
   "reviewer-trap avoided" note (aggregator falsely claimed MIT) — primary-source discipline.

6. Per-tool reference-duration table (voice-cloning L73-82): NeuTTS Air 3s, GPT-SoVITS 5s,
   VibeVoice 5s, XTTS-v2 6s, Chatterbox 10s, Kokoro 15s. Per-tool minimums are pack-specific; file
   honestly marks un-benchmarked tools as "10-30s general" rather than inventing numbers.

7. Two-pass loudnorm recipe (audiobook-pipeline L181-198): measure(print_format=json)→apply
   measured_I/TP/LRA/thresh/offset with linear=true. Correct non-trivial ffmpeg workflow
   (single-pass drifts); sourced to ffmpeg-normalize. Operationalized, not "normalize it."

8. ChatTTS emotion-param system (chattts-workflow): oral/laugh/break 0-9 with scene presets +
   temperature 0.2-0.3 / top_P 0.7 / top_K 20 + .pt seed-locked voice persistence. Grounded in a
   dated real-run (2026-05-28). Pack-specific primitives.

### Flagged: unsourced / over-specified numbers (do not sink the bar, but should be corrected)

F1. emo_alpha sweep value "1.4" is fabricated/extrapolated (voice-cloning L53). Verified IndexTTS2
    emo_alpha documented range is 0.0-1.0 (default 1.0). The pack's sweep "0 / 0.6 / 1.0 / 1.4" and
    "1.4 = over-driven" pushes a value OUTSIDE the documented API range with no source. Exactly an
    "unsourced number dressed up as depth." "Start at 0.9" is fine (in-range); drop or source 1.4.

F2. ACX head-silence "0.5-1.0s" is over-specified (audiobook-pipeline L163; also adelay=500 at L205).
    Official ACX says room tone "1-5 seconds at beginning and end" — does NOT specify a 0.5-1.0s head
    sub-band. The 0.5s opening is reasonable production convention but is presented as if an ACX spec.
    Label it convention, not requirement. (Note: acx-check.sh asserts no head/tail, so no code conflict.)

F3. Throughput "1 Hour Audio Generation Time" table (audiobook-pipeline L266-275) mixes one sourced
    figure (VoxCPM2 ~8 min from RTF 0.13) with "~15-30 minutes (estimated)" Kokoro / "~60 minutes (1:1)"
    MeloTTS. Estimated ones are honestly flagged "(estimated)" / "N/R" — acceptable, but soft padding.

F4. VoxCPM2 cross-lingual claims (tool-landscape L33): "17/24 languages on MiniMax-MLS-test; Finnish
    SIM 89.0, Arabic 79.1; 1.68% avg error across 30-language ASR." NOT independently verified this
    pass; numbers are precise enough to be plausible but §Source points only to internal
    baseline-report.md, not a primary URL (unlike IndexTTS2/CosyVoice2 which cite arXiv/project pages).
    Recommend adding primary source, per YOLO-audit "source URLs + retrieval dates" action.

### Structural anti-slop hygiene (positive)

- N/R discipline: tables mark "not researched" and instruct "never invent benchmarks"
  (tool-landscape L26, apple-silicon L4, voice-cloning L85). Un-benchmarked cells are blank, not
  hallucinated — the anti-slop guardrail working as intended.
- Anti-Skip table (SKILL L115-126) includes a falsifiable trap ("IndexTTS2 duration control will
  fail — NOT enabled") that is itself a verified fact, not generic "don't skip steps."
- Fixture (audiobook-tool-selection.md) has a real discriminative_pattern of pack-only markers
  (ACX|44.1kHz|emo_alpha|150ms|.pt|MPS|float32...) min_discriminative=3, excluding generic
  "TTS"/"audiobook" — eval-harness wired correctly (A9 satisfied).

## Fact-Checks (all external, this session)

- ACX specs (RMS -23..-18 / peak <-3 / noise <-60 / 44.1kHz / mono / 192kbps CBR / room tone 1-5s):
  VERIFIED — help.acx.com official submission requirements.
- IndexTTS2 duration control "not yet enabled in this release": VERIFIED — github.com/index-tts/index-tts.
  emo_alpha real range 0.0-1.0 default 1.0 → pack's 1.4 is out-of-range/unsourced (F1).
- CosyVoice2 150ms first-packet / 30-50% error reduction / MOS 5.53: VERIFIED — funaudiollm.github.io/cosyvoice2/.
- Platform LUFS (Apple -16/-19 mono, Spotify -14, YouTube -14, EBU -23, TP -1 dBTP): VERIFIED —
  multiple 2026 loudness sources incl. sone.app.
- Fish S2 license (Research License, commercial separate even self-hosted, Dual-AR 4B+400M,
  10M+hrs/80+langs): VERIFIED — huggingface.co/fishaudio/s2-pro.
- VoxCPM2 17/24-lang / Finnish 89.0 / 1.68% ASR: NOT verified this pass (internal-source only — F4).

## Verdict

meets_bar = TRUE. The pack genuinely clears the anti-slop bar: headline specifics are real, sourced,
dated, and several (IndexTTS2 release-vs-paper caveat, Fish license reviewer-trap, mono/stereo LUFS
split) are precisely the class of fact a frontier LLM would get WRONG from training memory.
Code-backed gates (ACX, LUFS) move thresholds out of prose into exit codes. Two concrete corrections
required before "accepted" (F1 emo_alpha 1.4 out-of-range; F2 ACX head 0.5-1.0s mislabeled as spec)
and two provenance hardenings recommended (F4 VoxCPM2 primary source; F3 estimated throughput already
labeled). None are bar-sinking; all are line-item fixes.
